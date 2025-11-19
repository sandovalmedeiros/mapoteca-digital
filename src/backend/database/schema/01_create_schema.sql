-- ============================================================================
-- Mapoteca Digital - Database Schema Creation
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Autor: SEIGEO - SEI-BA
-- Descrição: Criação do schema e configurações iniciais do banco
-- ============================================================================

-- Criar schema se não existir
CREATE SCHEMA IF NOT EXISTS dados_mapoteca;

-- Comentário do schema
COMMENT ON SCHEMA dados_mapoteca IS 'Schema principal do Sistema Mapoteca Digital - SEIGEO/SEI-BA';

-- Configurar search_path para facilitar queries
SET search_path TO dados_mapoteca, public;

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Comentários das extensões
COMMENT ON EXTENSION postgis IS 'Extensão PostGIS para dados espaciais';
COMMENT ON EXTENSION "uuid-ossp" IS 'Geração de UUIDs';

-- Criar função para atualizar timestamp automaticamente
CREATE OR REPLACE FUNCTION dados_mapoteca.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.update_timestamp() IS 'Função trigger para atualizar data_atualizacao automaticamente';

-- Criar função para validar combinação classe + tipo
CREATE OR REPLACE FUNCTION dados_mapoteca.validate_classe_tipo()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se combinação é válida na tabela de relacionamento
    IF NOT EXISTS (
        SELECT 1
        FROM dados_mapoteca.t_classe_mapa_tipo_mapa
        WHERE id_classe_mapa = NEW.id_classe_mapa
          AND id_tipo_mapa = NEW.id_tipo_mapa
    ) THEN
        RAISE EXCEPTION 'Combinação inválida de Classe (%) e Tipo (%). Consulte t_classe_mapa_tipo_mapa.',
            NEW.id_classe_mapa, NEW.id_tipo_mapa;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.validate_classe_tipo() IS 'Valida combinação de classe_mapa e tipo_mapa';

-- Criar função para validar regionalização + região
CREATE OR REPLACE FUNCTION dados_mapoteca.validate_regionalizacao_regiao()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se combinação é válida
    IF NOT EXISTS (
        SELECT 1
        FROM dados_mapoteca.t_regionalizacao_regiao
        WHERE id_tipo_regionalizacao = NEW.id_tipo_regionalizacao
          AND id_regiao = NEW.id_regiao
    ) THEN
        RAISE EXCEPTION 'Combinação inválida de Tipo Regionalização (%) e Região (%). Consulte t_regionalizacao_regiao.',
            NEW.id_tipo_regionalizacao, NEW.id_regiao;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.validate_regionalizacao_regiao() IS 'Valida combinação de tipo_regionalizacao e regiao';

-- Criar função para validar tipo tema + tema
CREATE OR REPLACE FUNCTION dados_mapoteca.validate_tipo_tema_tema()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se combinação é válida
    IF NOT EXISTS (
        SELECT 1
        FROM dados_mapoteca.t_tipo_tema_tema
        WHERE id_tipo_tema = NEW.id_tipo_tema
          AND id_tema = NEW.id_tema
    ) THEN
        RAISE EXCEPTION 'Combinação inválida de Tipo Tema (%) e Tema (%). Consulte t_tipo_tema_tema.',
            NEW.id_tipo_tema, NEW.id_tema;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.validate_tipo_tema_tema() IS 'Valida combinação de tipo_tema e tema';

-- Criar função para log de auditoria
CREATE OR REPLACE FUNCTION dados_mapoteca.log_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO dados_mapoteca.t_audit_log (
            tabela, operacao, registro_id, usuario,
            dados_novos, ip_address, timestamp
        ) VALUES (
            TG_TABLE_NAME, 'INSERT', NEW.id_publicacao::text,
            current_user, row_to_json(NEW)::jsonb,
            inet_client_addr(), CURRENT_TIMESTAMP
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO dados_mapoteca.t_audit_log (
            tabela, operacao, registro_id, usuario,
            dados_antigos, dados_novos, ip_address, timestamp
        ) VALUES (
            TG_TABLE_NAME, 'UPDATE', NEW.id_publicacao::text,
            current_user, row_to_json(OLD)::jsonb,
            row_to_json(NEW)::jsonb, inet_client_addr(),
            CURRENT_TIMESTAMP
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO dados_mapoteca.t_audit_log (
            tabela, operacao, registro_id, usuario,
            dados_antigos, ip_address, timestamp
        ) VALUES (
            TG_TABLE_NAME, 'DELETE', OLD.id_publicacao::text,
            current_user, row_to_json(OLD)::jsonb,
            inet_client_addr(), CURRENT_TIMESTAMP
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.log_audit() IS 'Registra operações de INSERT, UPDATE e DELETE para auditoria';

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Schema dados_mapoteca criado com sucesso!';
    RAISE NOTICE 'Extensões PostGIS e UUID-OSSP habilitadas.';
    RAISE NOTICE 'Funções de validação e auditoria criadas.';
END $$;
