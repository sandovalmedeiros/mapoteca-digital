-- ===================================================================================
-- Mapoteca Digital - Script 03: Índices e Constraints Adicionais (CORRECTED)
-- ===================================================================================
-- Descrição: Índices otimizados, constraints e triggers para performance e integridade
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-17
-- Versão: 2.0 (CORRIGIDO - Nomenclatura com prefixo t_)
-- Dependências: Scripts 01 e 02 CORRECTED devem ser executados primeiro
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. ÍNDICES ADICIONAIS PARA PERFORMANCE
-- ===================================================================================

-- 1.1. Índices parciais para registros ativos
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_t_municipios_ativos
ON dados_mapoteca.t_municipios(nommun, ativo)
WHERE ativo = true;

-- 1.2. Índices GIN para busca full-text (se aplicável)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_t_tema_nome_busca
ON dados_mapoteca.t_tema USING GIN (to_tsvector('portuguese', nome_tema));

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_t_regiao_nome_busca
ON dados_mapoteca.t_regiao USING GIN (to_tsvector('portuguese', nome_regiao));

-- 1.3. Índices para ordenação e filtragem
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_t_anos_ano_desc
ON dados_mapoteca.t_anos(ano DESC);

-- ===================================================================================
-- 2. CONSTRAINTS ADICIONAIS DE VALIDAÇÃO
-- ===================================================================================

-- 2.1. Validação de formato de códigos
ALTER TABLE dados_mapoteca.t_classe_mapa
ADD CONSTRAINT chk_id_classe_mapa_formato
CHECK (id_classe_mapa ~ '^[0-9]{2}$');

ALTER TABLE dados_mapoteca.t_tipo_mapa
ADD CONSTRAINT chk_id_tipo_mapa_formato
CHECK (id_tipo_mapa ~ '^[0-9]{2}$');

-- 2.2. Validação de tamanho de attachments (máximo 50MB conforme .clinerules)
ALTER TABLE dados_mapoteca.t_publicacao__attach
ADD CONSTRAINT chk_attach_tamanho_maximo
CHECK (data_size <= 52428800);  -- 50MB em bytes

ALTER TABLE dados_mapoteca.t_publicacao_municipios_attach
ADD CONSTRAINT chk_attach_mun_tamanho_maximo
CHECK (data_size IS NULL OR data_size <= 52428800);

-- 2.3. Validação de content_type apenas PDF
ALTER TABLE dados_mapoteca.t_publicacao__attach
ADD CONSTRAINT chk_attach_content_type
CHECK (content_type = 'application/pdf');

ALTER TABLE dados_mapoteca.t_publicacao_municipios_attach
ADD CONSTRAINT chk_attach_mun_content_type
CHECK (content_type IS NULL OR content_type = 'application/pdf');

-- ===================================================================================
-- 3. VIEWS ÚTEIS PARA CONSULTAS
-- ===================================================================================

-- 3.1. View completa de publicações com todos os relacionamentos
CREATE OR REPLACE VIEW dados_mapoteca.vw_publicacao_completa AS
SELECT
    p.id_publicacao,
    p.globalid,
    -- Classificação
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    -- Metadados
    a.ano,
    r.nome_regiao,
    r.abrangencia,
    e.nome_escala,
    cor.nome_cor,
    tr.nome_tipo_regionalizacao,
    -- Tema
    t.codigo_tema,
    t.nome_tema,
    tt.codigo_tipo_tema,
    tt.nome_tipo_tema
FROM dados_mapoteca.t_publicacao p
LEFT JOIN dados_mapoteca.t_classe_mapa cm ON p.id_classe_mapa = cm.id_classe_mapa
LEFT JOIN dados_mapoteca.t_tipo_mapa tm ON p.id_tipo_mapa = tm.id_tipo_mapa
LEFT JOIN dados_mapoteca.t_anos a ON p.id_ano = a.id_ano
LEFT JOIN dados_mapoteca.t_regiao r ON p.id_regiao = r.id_regiao
LEFT JOIN dados_mapoteca.t_escala e ON p.codigo_escala = e.codigo_escala
LEFT JOIN dados_mapoteca.t_cor cor ON p.codigo_cor = cor.codigo_cor
LEFT JOIN dados_mapoteca.t_tipo_regionalizacao tr ON p.id_tipo_regionalizacao = tr.id_tipo_regionalizacao
LEFT JOIN dados_mapoteca.t_tema t ON p.id_tema = t.id_tema
LEFT JOIN dados_mapoteca.t_tipo_tema tt ON p.id_tipo_tema = tt.id_tipo_tema;

COMMENT ON VIEW dados_mapoteca.vw_publicacao_completa IS 'View completa com todos os dados das publicações';

-- 3.2. View de publicações com anexos
CREATE OR REPLACE VIEW dados_mapoteca.vw_publicacao_com_anexos AS
SELECT
    p.id_publicacao,
    p.globalid,
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    a.ano,
    r.nome_regiao,
    t.nome_tema,
    -- Informações de anexos
    COUNT(att.objectid) as quantidade_anexos,
    SUM(att.data_size) as tamanho_total_bytes,
    ROUND(SUM(att.data_size)::numeric / 1048576, 2) as tamanho_total_mb,
    STRING_AGG(att.att_name, ', ' ORDER BY att.objectid) as nomes_anexos
FROM dados_mapoteca.t_publicacao p
LEFT JOIN dados_mapoteca.t_classe_mapa cm ON p.id_classe_mapa = cm.id_classe_mapa
LEFT JOIN dados_mapoteca.t_tipo_mapa tm ON p.id_tipo_mapa = tm.id_tipo_mapa
LEFT JOIN dados_mapoteca.t_anos a ON p.id_ano = a.id_ano
LEFT JOIN dados_mapoteca.t_regiao r ON p.id_regiao = r.id_regiao
LEFT JOIN dados_mapoteca.t_tema t ON p.id_tema = t.id_tema
LEFT JOIN dados_mapoteca.t_publicacao__attach att ON p.globalid = att.rel_globalid
GROUP BY p.id_publicacao, p.globalid, cm.nome_classe_mapa, tm.nome_tipo_mapa,
         a.ano, r.nome_regiao, t.nome_tema;

COMMENT ON VIEW dados_mapoteca.vw_publicacao_com_anexos IS 'View de publicações com estatísticas de anexos';

-- 3.3. View de combinações válidas
CREATE OR REPLACE VIEW dados_mapoteca.vw_combinacoes_validas AS
SELECT
    cm.id_classe_mapa,
    cm.nome_classe_mapa,
    tm.id_tipo_mapa,
    tm.nome_tipo_mapa,
    cm.nome_classe_mapa || ' ' || tm.nome_tipo_mapa as tipo_publicacao_completo
FROM dados_mapoteca.t_classe_mapa_tipo_mapa cmtm
JOIN dados_mapoteca.t_classe_mapa cm ON cmtm.id_classe_mapa = cm.id_classe_mapa
JOIN dados_mapoteca.t_tipo_mapa tm ON cmtm.id_tipo_mapa = tm.id_tipo_mapa
ORDER BY cm.id_classe_mapa, tm.id_tipo_mapa;

COMMENT ON VIEW dados_mapoteca.vw_combinacoes_validas IS 'View das 6 combinações válidas de classe e tipo';

-- 3.4. View de regiões por tipo de regionalização
CREATE OR REPLACE VIEW dados_mapoteca.vw_regioes_por_tipo AS
SELECT
    tr.id_tipo_regionalizacao,
    tr.nome_tipo_regionalizacao,
    r.id_regiao,
    r.nome_regiao,
    r.abrangencia
FROM dados_mapoteca.t_regionalizacao_regiao rr
JOIN dados_mapoteca.t_tipo_regionalizacao tr ON rr.id_tipo_regionalizacao = tr.id_tipo_regionalizacao
JOIN dados_mapoteca.t_regiao r ON rr.id_regiao = r.id_regiao
ORDER BY tr.nome_tipo_regionalizacao, r.nome_regiao;

COMMENT ON VIEW dados_mapoteca.vw_regioes_por_tipo IS 'View de regiões organizadas por tipo de regionalização';

-- 3.5. View de temas por tipo
CREATE OR REPLACE VIEW dados_mapoteca.vw_temas_por_tipo AS
SELECT
    tt.id_tipo_tema,
    tt.codigo_tipo_tema,
    tt.nome_tipo_tema,
    t.id_tema,
    t.codigo_tema,
    t.nome_tema
FROM dados_mapoteca.t_tipo_tema_tema ttt
JOIN dados_mapoteca.t_tipo_tema tt ON ttt.id_tipo_tema = tt.id_tipo_tema
JOIN dados_mapoteca.t_tema t ON ttt.id_tema = t.id_tema
ORDER BY tt.codigo_tipo_tema, t.nome_tema;

COMMENT ON VIEW dados_mapoteca.vw_temas_por_tipo IS 'View de temas organizados por tipo';

-- ===================================================================================
-- 4. FUNÇÕES DE VALIDAÇÃO
-- ===================================================================================

-- 4.1. Função para validar combinação classe + tipo
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_validar_classe_tipo(
    p_id_classe VARCHAR,
    p_id_tipo VARCHAR
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM dados_mapoteca.t_classe_mapa_tipo_mapa
        WHERE id_classe_mapa = p_id_classe
          AND id_tipo_mapa = p_id_tipo
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION dados_mapoteca.fn_validar_classe_tipo IS 'Valida se a combinação de classe e tipo é permitida';

-- 4.2. Função para validar tipo_regionalizacao + regiao
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_validar_regionalizacao_regiao(
    p_id_tipo_regionalizacao VARCHAR,
    p_id_regiao VARCHAR
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM dados_mapoteca.t_regionalizacao_regiao
        WHERE id_tipo_regionalizacao = p_id_tipo_regionalizacao
          AND id_regiao = p_id_regiao
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION dados_mapoteca.fn_validar_regionalizacao_regiao IS 'Valida se a combinação de tipo de regionalização e região é permitida';

-- 4.3. Função para validar tipo_tema + tema
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_validar_tipo_tema_tema(
    p_id_tipo_tema VARCHAR,
    p_id_tema INTEGER
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM dados_mapoteca.t_tipo_tema_tema
        WHERE id_tipo_tema = p_id_tipo_tema
          AND id_tema = p_id_tema
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION dados_mapoteca.fn_validar_tipo_tema_tema IS 'Valida se a combinação de tipo de tema e tema é permitida';

-- ===================================================================================
-- 5. TRIGGERS DE VALIDAÇÃO
-- ===================================================================================

-- 5.1. Trigger para validar combinações antes de INSERT/UPDATE em t_publicacao
CREATE OR REPLACE FUNCTION dados_mapoteca.fn_trigger_validar_publicacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar classe + tipo
    IF NOT dados_mapoteca.fn_validar_classe_tipo(NEW.id_classe_mapa, NEW.id_tipo_mapa) THEN
        RAISE EXCEPTION 'Combinação inválida: classe=% tipo=%', NEW.id_classe_mapa, NEW.id_tipo_mapa
        USING HINT = 'Consulte t_classe_mapa_tipo_mapa para combinações válidas';
    END IF;

    -- Validar regionalização + região
    IF NOT dados_mapoteca.fn_validar_regionalizacao_regiao(NEW.id_tipo_regionalizacao, NEW.id_regiao) THEN
        RAISE EXCEPTION 'Combinação inválida: tipo_regionalizacao=% regiao=%', NEW.id_tipo_regionalizacao, NEW.id_regiao
        USING HINT = 'Consulte t_regionalizacao_regiao para combinações válidas';
    END IF;

    -- Validar tipo_tema + tema
    IF NOT dados_mapoteca.fn_validar_tipo_tema_tema(NEW.id_tipo_tema, NEW.id_tema) THEN
        RAISE EXCEPTION 'Combinação inválida: tipo_tema=% tema=%', NEW.id_tipo_tema, NEW.id_tema
        USING HINT = 'Consulte t_tipo_tema_tema para combinações válidas';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger
DROP TRIGGER IF EXISTS trigger_validar_publicacao ON dados_mapoteca.t_publicacao;
CREATE TRIGGER trigger_validar_publicacao
    BEFORE INSERT OR UPDATE ON dados_mapoteca.t_publicacao
    FOR EACH ROW EXECUTE FUNCTION dados_mapoteca.fn_trigger_validar_publicacao();

COMMENT ON TRIGGER trigger_validar_publicacao ON dados_mapoteca.t_publicacao IS
'Valida combinações em cascata antes de INSERT/UPDATE';

-- ===================================================================================
-- 6. COLETAR ESTATÍSTICAS
-- ===================================================================================

-- Coletar estatísticas de todas as tabelas para o otimizador
ANALYZE dados_mapoteca.t_classe_mapa;
ANALYZE dados_mapoteca.t_tipo_mapa;
ANALYZE dados_mapoteca.t_anos;
ANALYZE dados_mapoteca.t_escala;
ANALYZE dados_mapoteca.t_cor;
ANALYZE dados_mapoteca.t_tipo_tema;
ANALYZE dados_mapoteca.t_tipo_regionalizacao;
ANALYZE dados_mapoteca.t_regiao;
ANALYZE dados_mapoteca.t_tema;
ANALYZE dados_mapoteca.t_municipios;
ANALYZE dados_mapoteca.t_classe_mapa_tipo_mapa;
ANALYZE dados_mapoteca.t_regionalizacao_regiao;
ANALYZE dados_mapoteca.t_tipo_tema_tema;
ANALYZE dados_mapoteca.t_publicacao;
ANALYZE dados_mapoteca.t_publicacao_municipios;
ANALYZE dados_mapoteca.t_publicacao__attach;
ANALYZE dados_mapoteca.t_publicacao_municipios_attach;

-- ===================================================================================
-- 7. VALIDAÇÃO FINAL
-- ===================================================================================

-- 7.1. Listar todos os índices criados
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'dados_mapoteca'
ORDER BY tablename, indexname;

-- 7.2. Listar todas as constraints
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'dados_mapoteca'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 7.3. Listar todas as views criadas
SELECT
    table_name as view_name,
    view_definition
FROM information_schema.views
WHERE table_schema = 'dados_mapoteca'
ORDER BY table_name;

-- 7.4. Listar todas as funções criadas
SELECT
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'dados_mapoteca'
ORDER BY routine_name;

-- 7.5. Listar todos os triggers
SELECT
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'dados_mapoteca'
ORDER BY event_object_table, trigger_name;

-- Fim do Script 03 (CORRIGIDO)
-- ===================================================================================
-- ✅ Índices, constraints e triggers criados com sucesso:
-- ✓ Índices adicionais para performance
-- ✓ Constraints de validação (formato, tamanho, content_type)
-- ✓ 5 Views úteis para consultas
-- ✓ 3 Funções de validação (classe/tipo, regionalização/região, tipo_tema/tema)
-- ✓ 1 Trigger de validação em cascata para t_publicacao
-- ✓ Estatísticas coletadas para otimização de queries
-- ===================================================================================
