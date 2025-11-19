-- ============================================================================
-- Mapoteca Digital - Relationship Tables (N:N)
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Descrição: Criação das tabelas de relacionamento N:N
-- Total: 3 tabelas
-- ============================================================================

SET search_path TO dados_mapoteca, public;

-- ============================================================================
-- 1. TABELA: t_classe_mapa_tipo_mapa
-- Descrição: Relacionamento entre classe_mapa e tipo_mapa
-- Registros: 6 (apenas 6 combinações válidas)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_classe_mapa_tipo_mapa (
    id SERIAL PRIMARY KEY,
    id_classe_mapa VARCHAR(2) NOT NULL,
    id_tipo_mapa VARCHAR(2) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_classe_mapa
        FOREIGN KEY (id_classe_mapa)
        REFERENCES dados_mapoteca.t_classe_mapa(id_classe_mapa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_tipo_mapa
        FOREIGN KEY (id_tipo_mapa)
        REFERENCES dados_mapoteca.t_tipo_mapa(id_tipo_mapa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Garantir combinação única
    CONSTRAINT uk_classe_tipo
        UNIQUE (id_classe_mapa, id_tipo_mapa)
);

COMMENT ON TABLE dados_mapoteca.t_classe_mapa_tipo_mapa IS 'Relacionamento N:N entre classe_mapa e tipo_mapa - Define combinações válidas';
COMMENT ON COLUMN dados_mapoteca.t_classe_mapa_tipo_mapa.id_classe_mapa IS 'FK para t_classe_mapa';
COMMENT ON COLUMN dados_mapoteca.t_classe_mapa_tipo_mapa.id_tipo_mapa IS 'FK para t_tipo_mapa';

-- Criar índices
CREATE INDEX idx_classe_mapa_tipo_classe ON dados_mapoteca.t_classe_mapa_tipo_mapa(id_classe_mapa);
CREATE INDEX idx_classe_mapa_tipo_tipo ON dados_mapoteca.t_classe_mapa_tipo_mapa(id_tipo_mapa);

-- ============================================================================
-- 2. TABELA: t_regionalizacao_regiao
-- Descrição: Relacionamento entre tipo_regionalizacao e regiao
-- Registros: 229
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_regionalizacao_regiao (
    id SERIAL PRIMARY KEY,
    id_tipo_regionalizacao VARCHAR(10) NOT NULL,
    id_regiao VARCHAR(10) NOT NULL,
    ordem INTEGER,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_tipo_regionalizacao
        FOREIGN KEY (id_tipo_regionalizacao)
        REFERENCES dados_mapoteca.t_tipo_regionalizacao(id_tipo_regionalizacao)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_regiao
        FOREIGN KEY (id_regiao)
        REFERENCES dados_mapoteca.t_regiao(id_regiao)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Garantir combinação única
    CONSTRAINT uk_regionalizacao_regiao
        UNIQUE (id_tipo_regionalizacao, id_regiao)
);

COMMENT ON TABLE dados_mapoteca.t_regionalizacao_regiao IS 'Relacionamento N:N entre tipo_regionalizacao e regiao - Define quais regiões pertencem a cada tipo de regionalização';
COMMENT ON COLUMN dados_mapoteca.t_regionalizacao_regiao.id_tipo_regionalizacao IS 'FK para t_tipo_regionalizacao';
COMMENT ON COLUMN dados_mapoteca.t_regionalizacao_regiao.id_regiao IS 'FK para t_regiao';
COMMENT ON COLUMN dados_mapoteca.t_regionalizacao_regiao.ordem IS 'Ordem de exibição da região dentro do tipo';

-- Criar índices
CREATE INDEX idx_regionalizacao_regiao_tipo ON dados_mapoteca.t_regionalizacao_regiao(id_tipo_regionalizacao);
CREATE INDEX idx_regionalizacao_regiao_regiao ON dados_mapoteca.t_regionalizacao_regiao(id_regiao);
CREATE INDEX idx_regionalizacao_regiao_ordem ON dados_mapoteca.t_regionalizacao_regiao(id_tipo_regionalizacao, ordem);

-- ============================================================================
-- 3. TABELA: t_tipo_tema_tema
-- Descrição: Relacionamento entre tipo_tema e tema
-- Registros: 55
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_tipo_tema_tema (
    id SERIAL PRIMARY KEY,
    id_tipo_tema VARCHAR(10) NOT NULL,
    id_tema INTEGER NOT NULL,
    ordem INTEGER,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_tipo_tema
        FOREIGN KEY (id_tipo_tema)
        REFERENCES dados_mapoteca.t_tipo_tema(id_tipo_tema)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_tema
        FOREIGN KEY (id_tema)
        REFERENCES dados_mapoteca.t_tema(id_tema)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Garantir combinação única
    CONSTRAINT uk_tipo_tema_tema
        UNIQUE (id_tipo_tema, id_tema)
);

COMMENT ON TABLE dados_mapoteca.t_tipo_tema_tema IS 'Relacionamento N:N entre tipo_tema e tema - Define quais temas pertencem a cada tipo de tema';
COMMENT ON COLUMN dados_mapoteca.t_tipo_tema_tema.id_tipo_tema IS 'FK para t_tipo_tema';
COMMENT ON COLUMN dados_mapoteca.t_tipo_tema_tema.id_tema IS 'FK para t_tema';
COMMENT ON COLUMN dados_mapoteca.t_tipo_tema_tema.ordem IS 'Ordem de exibição do tema dentro do tipo';

-- Criar índices
CREATE INDEX idx_tipo_tema_tema_tipo ON dados_mapoteca.t_tipo_tema_tema(id_tipo_tema);
CREATE INDEX idx_tipo_tema_tema_tema ON dados_mapoteca.t_tipo_tema_tema(id_tema);
CREATE INDEX idx_tipo_tema_tema_ordem ON dados_mapoteca.t_tipo_tema_tema(id_tipo_tema, ordem);

-- ============================================================================
-- Criar triggers para atualização automática de timestamp
-- ============================================================================

CREATE TRIGGER update_t_classe_mapa_tipo_mapa_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_classe_mapa_tipo_mapa
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_regionalizacao_regiao_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_regionalizacao_regiao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_tipo_tema_tema_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_tipo_tema_tema
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

-- ============================================================================
-- Views auxiliares para facilitar queries
-- ============================================================================

-- View: Combinações válidas de classe + tipo com nomes
CREATE OR REPLACE VIEW dados_mapoteca.v_classe_tipo_validos AS
SELECT
    cm.id_classe_mapa,
    cm.nome_classe_mapa,
    tm.id_tipo_mapa,
    tm.nome_tipo_mapa,
    cmt.descricao,
    cmt.ativo
FROM dados_mapoteca.t_classe_mapa_tipo_mapa cmt
JOIN dados_mapoteca.t_classe_mapa cm USING (id_classe_mapa)
JOIN dados_mapoteca.t_tipo_mapa tm USING (id_tipo_mapa)
WHERE cmt.ativo = TRUE
  AND cm.ativo = TRUE
  AND tm.ativo = TRUE
ORDER BY cm.nome_classe_mapa, tm.nome_tipo_mapa;

COMMENT ON VIEW dados_mapoteca.v_classe_tipo_validos IS 'View com combinações válidas de classe e tipo de mapa';

-- View: Regiões por tipo de regionalização com nomes
CREATE OR REPLACE VIEW dados_mapoteca.v_regioes_por_tipo AS
SELECT
    tr.id_tipo_regionalizacao,
    tr.nome_tipo_regionalizacao,
    r.id_regiao,
    r.nome_regiao,
    r.abrangencia,
    rr.ordem,
    rr.ativo
FROM dados_mapoteca.t_regionalizacao_regiao rr
JOIN dados_mapoteca.t_tipo_regionalizacao tr USING (id_tipo_regionalizacao)
JOIN dados_mapoteca.t_regiao r USING (id_regiao)
WHERE rr.ativo = TRUE
  AND tr.ativo = TRUE
  AND r.ativo = TRUE
ORDER BY tr.nome_tipo_regionalizacao, rr.ordem, r.nome_regiao;

COMMENT ON VIEW dados_mapoteca.v_regioes_por_tipo IS 'View com regiões agrupadas por tipo de regionalização';

-- View: Temas por tipo de tema com nomes
CREATE OR REPLACE VIEW dados_mapoteca.v_temas_por_tipo AS
SELECT
    tt.id_tipo_tema,
    tt.nome_tipo_tema,
    t.id_tema,
    t.codigo_tema,
    t.nome_tema,
    ttt.ordem,
    ttt.ativo
FROM dados_mapoteca.t_tipo_tema_tema ttt
JOIN dados_mapoteca.t_tipo_tema tt USING (id_tipo_tema)
JOIN dados_mapoteca.t_tema t USING (id_tema)
WHERE ttt.ativo = TRUE
  AND tt.ativo = TRUE
  AND t.ativo = TRUE
ORDER BY tt.nome_tipo_tema, ttt.ordem, t.nome_tema;

COMMENT ON VIEW dados_mapoteca.v_temas_por_tipo IS 'View com temas agrupados por tipo de tema';

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Tabelas de relacionamento N:N criadas com sucesso!';
    RAISE NOTICE 'Total: 3 tabelas';
    RAISE NOTICE '  - t_classe_mapa_tipo_mapa (6 registros esperados)';
    RAISE NOTICE '  - t_regionalizacao_regiao (229 registros esperados)';
    RAISE NOTICE '  - t_tipo_tema_tema (55 registros esperados)';
    RAISE NOTICE 'Triggers de timestamp criados.';
    RAISE NOTICE 'Índices de performance criados.';
    RAISE NOTICE 'Views auxiliares criadas.';
END $$;
