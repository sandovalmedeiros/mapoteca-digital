-- ===================================================================================
-- Mapoteca Digital - Script 04: Integração ESRI SDE e Attachments (CORRECTED)
-- ===================================================================================
-- Descrição: Configuração de integração com ESRI SDE para armazenamento de PDFs
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-17
-- Versão: 2.0 (CORRIGIDO - Nomenclatura com prefixo t_)
-- Dependências: Scripts 01, 02 e 03 CORRECTED devem ser executados primeiro
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. VERIFICAÇÃO DO AMBIENTE ESRI SDE
-- ===================================================================================

-- 1.1. Verificar versão do PostgreSQL
DO $$
DECLARE
    pg_version_text TEXT;
BEGIN
    SELECT version() INTO pg_version_text;
    RAISE NOTICE 'PostgreSQL Version: %', pg_version_text;

    -- Verificar se versão é 14+
    IF (SELECT split_part(split_part(version(), ' ', 2), '.', 1)::int) < 14 THEN
        RAISE EXCEPTION 'PostgreSQL 14+ é necessário. Versão atual: %', pg_version_text;
    END IF;

    RAISE NOTICE '✓ PostgreSQL version OK';
END $$;

-- 1.2. Verificar extensões necessárias
DO $$
BEGIN
    -- Verificar uuid-ossp
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') THEN
        RAISE EXCEPTION 'Extensão uuid-ossp não encontrada';
    END IF;
    RAISE NOTICE '✓ uuid-ossp extension OK';

    -- Verificar pg_trgm
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
        RAISE WARNING 'Extensão pg_trgm não encontrada (recomendada para busca)';
    ELSE
        RAISE NOTICE '✓ pg_trgm extension OK';
    END IF;

    -- Verificar postgis (opcional)
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') THEN
        RAISE NOTICE 'PostGIS não instalado (opcional para este projeto)';
    ELSE
        RAISE NOTICE '✓ PostGIS extension OK (opcional)';
    END IF;
END $$;

-- ===================================================================================
-- 2. VERIFICAÇÃO DAS TABELAS DE ATTACHMENTS
-- ===================================================================================

-- 2.1. Verificar estrutura das tabelas de attachments
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verificar t_publicacao__attach
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_schema = 'dados_mapoteca'
      AND table_name = 't_publicacao__attach'
      AND column_name IN ('objectid', 'globalid', 'rel_globalid', 'content_type', 'att_name', 'data_size', 'data');

    IF v_count < 7 THEN
        RAISE EXCEPTION 'Tabela t_publicacao__attach incompleta (% colunas encontradas, 7 esperadas)', v_count;
    END IF;

    RAISE NOTICE '✓ t_publicacao__attach structure OK (% columns)', v_count;

    -- Verificar t_publicacao_municipios_attach
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_schema = 'dados_mapoteca'
      AND table_name = 't_publicacao_municipios_attach'
      AND column_name IN ('attachmentid', 'globalid', 'rel_globalid', 'content_type', 'att_name', 'data_size', 'data');

    IF v_count < 7 THEN
        RAISE EXCEPTION 'Tabela t_publicacao_municipios_attach incompleta (% colunas encontradas, 7 esperadas)', v_count;
    END IF;

    RAISE NOTICE '✓ t_publicacao_municipios_attach structure OK (% columns)', v_count;
END $$;

-- ===================================================================================
-- 3. FUNÇÕES AUXILIARES PARA ATTACHMENTS
-- ===================================================================================

-- 3.1. Função para calcular MD5 checksum de attachment
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_attachment_md5(p_data BYTEA)
RETURNS TEXT AS $$
BEGIN
    RETURN md5(p_data);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION dados_mapoteca.fn_attachment_md5 IS 'Calcula MD5 checksum de dados binários de attachment';

-- 3.2. Função para formatar tamanho de arquivo
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_format_file_size(p_bytes BIGINT)
RETURNS TEXT AS $$
BEGIN
    IF p_bytes IS NULL THEN
        RETURN 'N/A';
    ELSIF p_bytes < 1024 THEN
        RETURN p_bytes || ' bytes';
    ELSIF p_bytes < 1048576 THEN
        RETURN ROUND(p_bytes::NUMERIC / 1024, 2) || ' KB';
    ELSIF p_bytes < 1073741824 THEN
        RETURN ROUND(p_bytes::NUMERIC / 1048576, 2) || ' MB';
    ELSE
        RETURN ROUND(p_bytes::NUMERIC / 1073741824, 2) || ' GB';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION dados_mapoteca.fn_format_file_size IS 'Formata tamanho de arquivo em formato legível';

-- 3.3. Função para validar PDF
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_validate_pdf(p_data BYTEA)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verifica se os primeiros 4 bytes são %PDF
    IF p_data IS NULL THEN
        RETURN FALSE;
    END IF;

    IF substring(p_data, 1, 4) = '\x25504446'::bytea THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION dados_mapoteca.fn_validate_pdf IS 'Valida se os dados binários são um PDF válido (verifica header)';

-- 3.4. Trigger para validar PDF antes de INSERT
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_trigger_validate_pdf_attach()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar se é PDF
    IF NEW.data IS NOT NULL AND NOT dados_mapoteca.fn_validate_pdf(NEW.data) THEN
        RAISE EXCEPTION 'Arquivo não é um PDF válido: %', NEW.att_name
        USING HINT = 'Apenas arquivos PDF são permitidos';
    END IF;

    -- Validar tamanho (máximo 50MB)
    IF NEW.data_size > 52428800 THEN
        RAISE EXCEPTION 'Arquivo muito grande: % (% bytes). Máximo permitido: 50MB',
            NEW.att_name, NEW.data_size
        USING HINT = 'Comprima o arquivo PDF ou divida em partes menores';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger em ambas as tabelas de attachments
DROP TRIGGER IF EXISTS trigger_validate_pdf_attach ON dados_mapoteca.t_publicacao__attach;
CREATE TRIGGER trigger_validate_pdf_attach
    BEFORE INSERT OR UPDATE ON dados_mapoteca.t_publicacao__attach
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_trigger_validate_pdf_attach();

DROP TRIGGER IF EXISTS trigger_validate_pdf_attach_mun ON dados_mapoteca.t_publicacao_municipios_attach;
CREATE TRIGGER trigger_validate_pdf_attach_mun
    BEFORE INSERT OR UPDATE ON dados_mapoteca.t_publicacao_municipios_attach
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_trigger_validate_pdf_attach();

-- ===================================================================================
-- 4. VIEWS PARA MONITORAMENTO DE ATTACHMENTS
-- ===================================================================================

-- 4.1. View de estatísticas de attachments
CREATE OR REPLACE VIEW dados_mapoteca.vw_attachment_stats AS
SELECT
    'Estaduais/Regionais' as tipo_publicacao,
    COUNT(*) as total_attachments,
    SUM(data_size) as total_bytes,
    dados_mapoteca.fn_format_file_size(SUM(data_size)) as total_size,
    dados_mapoteca.fn_format_file_size(AVG(data_size)::BIGINT) as avg_size,
    dados_mapoteca.fn_format_file_size(MIN(data_size)) as min_size,
    dados_mapoteca.fn_format_file_size(MAX(data_size)) as max_size
FROM dados_mapoteca.t_publicacao__attach

UNION ALL

SELECT
    'Municipais' as tipo_publicacao,
    COUNT(*) as total_attachments,
    SUM(data_size) as total_bytes,
    dados_mapoteca.fn_format_file_size(SUM(data_size)) as total_size,
    dados_mapoteca.fn_format_file_size(AVG(data_size)::BIGINT) as avg_size,
    dados_mapoteca.fn_format_file_size(MIN(data_size)) as min_size,
    dados_mapoteca.fn_format_file_size(MAX(data_size)) as max_size
FROM dados_mapoteca.t_publicacao_municipios_attach;

COMMENT ON VIEW dados_mapoteca.vw_attachment_stats IS 'Estatísticas de uso de storage de attachments';

-- 4.2. View de attachments sem publicação (órfãos)
CREATE OR REPLACE VIEW dados_mapoteca.vw_orphan_attachments AS
SELECT
    'Estaduais/Regionais' as tipo,
    att.objectid,
    att.globalid,
    att.rel_globalid,
    att.att_name,
    att.data_size,
    dados_mapoteca.fn_format_file_size(att.data_size) as size_formatted
FROM dados_mapoteca.t_publicacao__attach att
LEFT JOIN dados_mapoteca.t_publicacao p ON att.rel_globalid = p.globalid
WHERE p.globalid IS NULL

UNION ALL

SELECT
    'Municipais' as tipo,
    att.attachmentid as objectid,
    att.globalid,
    att.rel_globalid,
    att.att_name,
    att.data_size,
    dados_mapoteca.fn_format_file_size(att.data_size) as size_formatted
FROM dados_mapoteca.t_publicacao_municipios_attach att
LEFT JOIN dados_mapoteca.t_publicacao_municipios p ON att.rel_globalid = p.globalid
WHERE p.globalid IS NULL;

COMMENT ON VIEW dados_mapoteca.vw_orphan_attachments IS 'Attachments órfãos (sem publicação associada)';

-- ===================================================================================
-- 5. PROCEDURES PARA MANUTENÇÃO
-- ===================================================================================

-- 5.1. Procedure para limpar attachments órfãos
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_cleanup_orphan_attachments()
RETURNS TABLE(
    tipo TEXT,
    deleted_count INTEGER,
    freed_bytes BIGINT,
    freed_size TEXT
) AS $$
DECLARE
    v_deleted_estaduais INTEGER;
    v_deleted_municipais INTEGER;
    v_freed_estaduais BIGINT;
    v_freed_municipais BIGINT;
BEGIN
    -- Deletar attachments estaduais/regionais órfãos
    WITH deleted AS (
        DELETE FROM dados_mapoteca.t_publicacao__attach att
        WHERE NOT EXISTS (
            SELECT 1 FROM dados_mapoteca.t_publicacao p
            WHERE p.globalid = att.rel_globalid
        )
        RETURNING data_size
    )
    SELECT COUNT(*), COALESCE(SUM(data_size), 0)
    INTO v_deleted_estaduais, v_freed_estaduais
    FROM deleted;

    -- Deletar attachments municipais órfãos
    WITH deleted AS (
        DELETE FROM dados_mapoteca.t_publicacao_municipios_attach att
        WHERE NOT EXISTS (
            SELECT 1 FROM dados_mapoteca.t_publicacao_municipios p
            WHERE p.globalid = att.rel_globalid
        )
        RETURNING data_size
    )
    SELECT COUNT(*), COALESCE(SUM(data_size), 0)
    INTO v_deleted_municipais, v_freed_municipais
    FROM deleted;

    -- Retornar resultados
    RETURN QUERY SELECT
        'Estaduais/Regionais'::TEXT,
        v_deleted_estaduais,
        v_freed_estaduais,
        dados_mapoteca.fn_format_file_size(v_freed_estaduais);

    RETURN QUERY SELECT
        'Municipais'::TEXT,
        v_deleted_municipais,
        v_freed_municipais,
        dados_mapoteca.fn_format_file_size(v_freed_municipais);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.fn_cleanup_orphan_attachments IS
'Remove attachments órfãos e retorna estatísticas de limpeza';

-- ===================================================================================
-- 6. VALIDAÇÃO FINAL E TESTES
-- ===================================================================================

-- 6.1. Verificar integridade de GlobalIDs
DO $$
DECLARE
    v_duplicados INTEGER;
BEGIN
    -- Verificar duplicados em t_publicacao
    SELECT COUNT(*) INTO v_duplicados
    FROM (
        SELECT globalid, COUNT(*)
        FROM dados_mapoteca.t_publicacao
        GROUP BY globalid
        HAVING COUNT(*) > 1
    ) x;

    IF v_duplicados > 0 THEN
        RAISE EXCEPTION 'GlobalIDs duplicados encontrados em t_publicacao: % registros', v_duplicados;
    END IF;

    RAISE NOTICE '✓ GlobalIDs em t_publicacao são únicos';

    -- Verificar duplicados em t_publicacao_municipios
    SELECT COUNT(*) INTO v_duplicados
    FROM (
        SELECT globalid, COUNT(*)
        FROM dados_mapoteca.t_publicacao_municipios
        GROUP BY globalid
        HAVING COUNT(*) > 1
    ) x;

    IF v_duplicados > 0 THEN
        RAISE EXCEPTION 'GlobalIDs duplicados encontrados em t_publicacao_municipios: % registros', v_duplicados;
    END IF;

    RAISE NOTICE '✓ GlobalIDs em t_publicacao_municipios são únicos';
END $$;

-- 6.2. Verificar integridade referencial de attachments
DO $$
DECLARE
    v_orfaos INTEGER;
BEGIN
    -- Verificar órfãos em t_publicacao__attach
    SELECT COUNT(*) INTO v_orfaos
    FROM dados_mapoteca.t_publicacao__attach att
    LEFT JOIN dados_mapoteca.t_publicacao p ON att.rel_globalid = p.globalid
    WHERE p.globalid IS NULL;

    IF v_orfaos > 0 THEN
        RAISE WARNING 'Attachments órfãos em t_publicacao__attach: % registros', v_orfaos;
    ELSE
        RAISE NOTICE '✓ Nenhum attachment órfão em t_publicacao__attach';
    END IF;

    -- Verificar órfãos em t_publicacao_municipios_attach
    SELECT COUNT(*) INTO v_orfaos
    FROM dados_mapoteca.t_publicacao_municipios_attach att
    LEFT JOIN dados_mapoteca.t_publicacao_municipios p ON att.rel_globalid = p.globalid
    WHERE p.globalid IS NULL;

    IF v_orfaos > 0 THEN
        RAISE WARNING 'Attachments órfãos em t_publicacao_municipios_attach: % registros', v_orfaos;
    ELSE
        RAISE NOTICE '✓ Nenhum attachment órfão em t_publicacao_municipios_attach';
    END IF;
END $$;

-- 6.3. Resumo final da integração ESRI
SELECT
    'RESUMO DA INTEGRAÇÃO ESRI SDE' as categoria,
    'Script 04 concluído com sucesso' as status;

-- Listar funções criadas
SELECT
    'FUNÇÕES ESRI' as categoria,
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines
WHERE routine_schema = 'dados_mapoteca'
  AND routine_name LIKE 'fn_%'
ORDER BY routine_name;

-- Listar views de monitoramento
SELECT
    'VIEWS DE MONITORAMENTO' as categoria,
    table_name as view_name
FROM information_schema.views
WHERE table_schema = 'dados_mapoteca'
  AND table_name LIKE 'vw_%attach%'
ORDER BY table_name;

-- Fim do Script 04 (CORRIGIDO)
-- ===================================================================================
-- ✅ Integração ESRI SDE configurada com sucesso:
-- ✓ Verificação de ambiente PostgreSQL 14+
-- ✓ Verificação de extensões (uuid-ossp, pg_trgm, postgis)
-- ✓ Verificação de estrutura de tabelas de attachments
-- ✓ 3 Funções auxiliares (MD5, format_size, validate_pdf)
-- ✓ 2 Triggers de validação de PDF e tamanho
-- ✓ 2 Views de monitoramento (estatísticas e órfãos)
-- ✓ 1 Procedure de limpeza de attachments órfãos
-- ✓ Validações de integridade (GlobalIDs únicos, attachments órfãos)
-- ===================================================================================
-- PRONTO PARA: Integração com ArcGIS Experience Builder e Feature Services
-- ===================================================================================
