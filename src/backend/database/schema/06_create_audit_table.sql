-- ============================================================================
-- Mapoteca Digital - Audit Table
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Descrição: Criação da tabela de auditoria para log de operações
-- ============================================================================

SET search_path TO dados_mapoteca, public;

-- ============================================================================
-- TABELA: t_audit_log
-- Descrição: Log de auditoria para todas as operações críticas
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_audit_log (
    id_audit BIGSERIAL PRIMARY KEY,
    tabela VARCHAR(100) NOT NULL,
    operacao VARCHAR(10) NOT NULL CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE')),
    registro_id VARCHAR(50),
    usuario VARCHAR(100) NOT NULL,
    dados_antigos JSONB,
    dados_novos JSONB,
    ip_address INET,
    user_agent VARCHAR(500),
    session_id VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE dados_mapoteca.t_audit_log IS 'Log de auditoria para todas as operações de INSERT, UPDATE e DELETE';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.tabela IS 'Nome da tabela onde ocorreu a operação';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.operacao IS 'Tipo de operação: INSERT, UPDATE ou DELETE';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.registro_id IS 'ID do registro afetado';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.usuario IS 'Usuário que executou a operação';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.dados_antigos IS 'JSON com dados antes da alteração (apenas UPDATE e DELETE)';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.dados_novos IS 'JSON com dados depois da alteração (apenas INSERT e UPDATE)';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.ip_address IS 'Endereço IP do cliente';
COMMENT ON COLUMN dados_mapoteca.t_audit_log.timestamp IS 'Data e hora da operação';

-- ============================================================================
-- Criar índices para performance
-- ============================================================================

CREATE INDEX idx_audit_tabela ON dados_mapoteca.t_audit_log(tabela);
CREATE INDEX idx_audit_operacao ON dados_mapoteca.t_audit_log(operacao);
CREATE INDEX idx_audit_usuario ON dados_mapoteca.t_audit_log(usuario);
CREATE INDEX idx_audit_timestamp ON dados_mapoteca.t_audit_log(timestamp DESC);
CREATE INDEX idx_audit_registro_id ON dados_mapoteca.t_audit_log(registro_id);
CREATE INDEX idx_audit_tabela_registro ON dados_mapoteca.t_audit_log(tabela, registro_id);

-- Índice GIN para busca em JSON
CREATE INDEX idx_audit_dados_antigos ON dados_mapoteca.t_audit_log USING GIN(dados_antigos);
CREATE INDEX idx_audit_dados_novos ON dados_mapoteca.t_audit_log USING GIN(dados_novos);

-- ============================================================================
-- Criar partições por ano (opcional, para melhor performance)
-- ============================================================================

-- Habilitar particionamento por ano
-- CREATE TABLE dados_mapoteca.t_audit_log_2025 PARTITION OF dados_mapoteca.t_audit_log
--     FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- ============================================================================
-- Views auxiliares para auditoria
-- ============================================================================

-- View: Resumo de operações por tabela
CREATE OR REPLACE VIEW dados_mapoteca.v_audit_resumo_tabelas AS
SELECT
    tabela,
    COUNT(*) AS total_operacoes,
    COUNT(*) FILTER (WHERE operacao = 'INSERT') AS total_inserts,
    COUNT(*) FILTER (WHERE operacao = 'UPDATE') AS total_updates,
    COUNT(*) FILTER (WHERE operacao = 'DELETE') AS total_deletes,
    MIN(timestamp) AS primeira_operacao,
    MAX(timestamp) AS ultima_operacao
FROM dados_mapoteca.t_audit_log
GROUP BY tabela
ORDER BY total_operacoes DESC;

COMMENT ON VIEW dados_mapoteca.v_audit_resumo_tabelas IS 'Resumo de operações de auditoria por tabela';

-- View: Resumo de operações por usuário
CREATE OR REPLACE VIEW dados_mapoteca.v_audit_resumo_usuarios AS
SELECT
    usuario,
    COUNT(*) AS total_operacoes,
    COUNT(*) FILTER (WHERE operacao = 'INSERT') AS total_inserts,
    COUNT(*) FILTER (WHERE operacao = 'UPDATE') AS total_updates,
    COUNT(*) FILTER (WHERE operacao = 'DELETE') AS total_deletes,
    COUNT(DISTINCT tabela) AS tabelas_afetadas,
    MIN(timestamp) AS primeira_operacao,
    MAX(timestamp) AS ultima_operacao
FROM dados_mapoteca.t_audit_log
GROUP BY usuario
ORDER BY total_operacoes DESC;

COMMENT ON VIEW dados_mapoteca.v_audit_resumo_usuarios IS 'Resumo de operações de auditoria por usuário';

-- View: Operações recentes (últimas 100)
CREATE OR REPLACE VIEW dados_mapoteca.v_audit_recentes AS
SELECT
    id_audit,
    tabela,
    operacao,
    registro_id,
    usuario,
    timestamp,
    ip_address
FROM dados_mapoteca.t_audit_log
ORDER BY timestamp DESC
LIMIT 100;

COMMENT ON VIEW dados_mapoteca.v_audit_recentes IS 'Últimas 100 operações de auditoria';

-- View: Histórico de um registro específico
CREATE OR REPLACE FUNCTION dados_mapoteca.f_audit_historico_registro(
    p_tabela VARCHAR,
    p_registro_id VARCHAR
)
RETURNS TABLE (
    id_audit BIGINT,
    operacao VARCHAR,
    usuario VARCHAR,
    dados_antigos JSONB,
    dados_novos JSONB,
    timestamp TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_audit,
        a.operacao,
        a.usuario,
        a.dados_antigos,
        a.dados_novos,
        a.timestamp
    FROM dados_mapoteca.t_audit_log a
    WHERE a.tabela = p_tabela
      AND a.registro_id = p_registro_id
    ORDER BY a.timestamp DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.f_audit_historico_registro IS 'Retorna histórico completo de auditoria de um registro específico';

-- ============================================================================
-- Função para limpar logs antigos (manutenção)
-- ============================================================================

CREATE OR REPLACE FUNCTION dados_mapoteca.f_limpar_audit_log(
    p_dias_retencao INTEGER DEFAULT 365
)
RETURNS INTEGER AS $$
DECLARE
    v_registros_deletados INTEGER;
BEGIN
    DELETE FROM dados_mapoteca.t_audit_log
    WHERE timestamp < CURRENT_TIMESTAMP - (p_dias_retencao || ' days')::INTERVAL;

    GET DIAGNOSTICS v_registros_deletados = ROW_COUNT;

    RAISE NOTICE 'Deletados % registros de auditoria com mais de % dias', v_registros_deletados, p_dias_retencao;

    RETURN v_registros_deletados;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.f_limpar_audit_log IS 'Remove registros de auditoria mais antigos que o período de retenção especificado';

-- ============================================================================
-- Função para exportar auditoria de um período
-- ============================================================================

CREATE OR REPLACE FUNCTION dados_mapoteca.f_exportar_audit_log(
    p_data_inicio TIMESTAMP,
    p_data_fim TIMESTAMP,
    p_tabela VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_audit BIGINT,
    tabela VARCHAR,
    operacao VARCHAR,
    registro_id VARCHAR,
    usuario VARCHAR,
    timestamp TIMESTAMP,
    dados_antigos TEXT,
    dados_novos TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_audit,
        a.tabela,
        a.operacao,
        a.registro_id,
        a.usuario,
        a.timestamp,
        a.dados_antigos::TEXT,
        a.dados_novos::TEXT
    FROM dados_mapoteca.t_audit_log a
    WHERE a.timestamp BETWEEN p_data_inicio AND p_data_fim
      AND (p_tabela IS NULL OR a.tabela = p_tabela)
    ORDER BY a.timestamp;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.f_exportar_audit_log IS 'Exporta registros de auditoria de um período específico';

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Tabela de auditoria criada com sucesso!';
    RAISE NOTICE 'Índices de performance criados (incluindo GIN para JSONB)';
    RAISE NOTICE 'Views de resumo criadas';
    RAISE NOTICE 'Funções auxiliares criadas:';
    RAISE NOTICE '  - f_audit_historico_registro()';
    RAISE NOTICE '  - f_limpar_audit_log()';
    RAISE NOTICE '  - f_exportar_audit_log()';
END $$;
