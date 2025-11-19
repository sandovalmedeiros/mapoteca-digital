-- ============================================================================
-- Mapoteca Digital - Municípios Table
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Descrição: Criação da tabela de municípios da Bahia
-- Registros: 417 municípios
-- ============================================================================

SET search_path TO dados_mapoteca, public;

-- ============================================================================
-- TABELA: t_municipios
-- Descrição: Municípios da Bahia com informações detalhadas
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_municipios (
    id_municipio SERIAL PRIMARY KEY,
    codigo_ibge VARCHAR(7) NOT NULL UNIQUE,
    nome_municipio VARCHAR(100) NOT NULL,
    nome_municipio_sem_acento VARCHAR(100),
    microrregiao VARCHAR(100),
    mesorregiao VARCHAR(100),
    regiao_intermediaria VARCHAR(100),
    regiao_imediata VARCHAR(100),
    territorio_identidade VARCHAR(100),
    area_km2 NUMERIC(12, 4),
    populacao INTEGER,
    pib_per_capita NUMERIC(12, 2),
    idh NUMERIC(5, 3),
    latitude NUMERIC(10, 7),
    longitude NUMERIC(11, 7),
    geom GEOMETRY(POINT, 4326),
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT chk_codigo_ibge_length CHECK (LENGTH(codigo_ibge) = 7),
    CONSTRAINT chk_codigo_ibge_ba CHECK (LEFT(codigo_ibge, 2) = '29'), -- Bahia = 29
    CONSTRAINT chk_latitude CHECK (latitude BETWEEN -18.5 AND -8.5), -- Limites da Bahia
    CONSTRAINT chk_longitude CHECK (longitude BETWEEN -47.0 AND -37.0),
    CONSTRAINT chk_area CHECK (area_km2 > 0),
    CONSTRAINT chk_populacao CHECK (populacao >= 0),
    CONSTRAINT chk_idh CHECK (idh BETWEEN 0 AND 1)
);

COMMENT ON TABLE dados_mapoteca.t_municipios IS 'Municípios da Bahia com informações demográficas e geográficas';
COMMENT ON COLUMN dados_mapoteca.t_municipios.codigo_ibge IS 'Código IBGE de 7 dígitos (formato: 29XXXXX)';
COMMENT ON COLUMN dados_mapoteca.t_municipios.nome_municipio IS 'Nome oficial do município com acentuação';
COMMENT ON COLUMN dados_mapoteca.t_municipios.nome_municipio_sem_acento IS 'Nome do município sem acentuação para busca';
COMMENT ON COLUMN dados_mapoteca.t_municipios.microrregiao IS 'Microrregião geográfica IBGE';
COMMENT ON COLUMN dados_mapoteca.t_municipios.mesorregiao IS 'Mesorregião geográfica IBGE';
COMMENT ON COLUMN dados_mapoteca.t_municipios.regiao_intermediaria IS 'Região Geográfica Intermediária';
COMMENT ON COLUMN dados_mapoteca.t_municipios.regiao_imediata IS 'Região Geográfica Imediata';
COMMENT ON COLUMN dados_mapoteca.t_municipios.territorio_identidade IS 'Território de Identidade (regionalização Bahia)';
COMMENT ON COLUMN dados_mapoteca.t_municipios.area_km2 IS 'Área em km² (IBGE)';
COMMENT ON COLUMN dados_mapoteca.t_municipios.populacao IS 'População estimada (último censo)';
COMMENT ON COLUMN dados_mapoteca.t_municipios.pib_per_capita IS 'PIB per capita em R$';
COMMENT ON COLUMN dados_mapoteca.t_municipios.idh IS 'Índice de Desenvolvimento Humano Municipal (0 a 1)';
COMMENT ON COLUMN dados_mapoteca.t_municipios.latitude IS 'Latitude da sede municipal (WGS84)';
COMMENT ON COLUMN dados_mapoteca.t_municipios.longitude IS 'Longitude da sede municipal (WGS84)';
COMMENT ON COLUMN dados_mapoteca.t_municipios.geom IS 'Geometria POINT da sede municipal (SRID 4326)';

-- ============================================================================
-- Trigger para atualização de geom baseado em lat/long
-- ============================================================================

CREATE OR REPLACE FUNCTION dados_mapoteca.update_municipio_geom()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.geom = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.update_municipio_geom() IS 'Atualiza geometria POINT baseado em latitude e longitude';

CREATE TRIGGER trigger_update_municipio_geom
    BEFORE INSERT OR UPDATE OF latitude, longitude
    ON dados_mapoteca.t_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_municipio_geom();

-- ============================================================================
-- Trigger para normalizar nome sem acento
-- ============================================================================

CREATE OR REPLACE FUNCTION dados_mapoteca.normalize_municipio_name()
RETURNS TRIGGER AS $$
BEGIN
    -- Remover acentos e converter para maiúsculas para facilitar buscas
    NEW.nome_municipio_sem_acento = UPPER(
        TRANSLATE(
            NEW.nome_municipio,
            'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇáàãâäéèêëíìîïóòõôöúùûüç',
            'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiioooooouuuuc'
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dados_mapoteca.normalize_municipio_name() IS 'Normaliza nome do município removendo acentos';

CREATE TRIGGER trigger_normalize_municipio_name
    BEFORE INSERT OR UPDATE OF nome_municipio
    ON dados_mapoteca.t_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.normalize_municipio_name();

-- ============================================================================
-- Trigger para atualização de timestamp
-- ============================================================================

CREATE TRIGGER update_t_municipios_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

-- ============================================================================
-- Criar índices para performance
-- ============================================================================

CREATE INDEX idx_t_municipios_codigo_ibge ON dados_mapoteca.t_municipios(codigo_ibge);
CREATE INDEX idx_t_municipios_nome ON dados_mapoteca.t_municipios(nome_municipio);
CREATE INDEX idx_t_municipios_nome_sem_acento ON dados_mapoteca.t_municipios(nome_municipio_sem_acento);
CREATE INDEX idx_t_municipios_territorio ON dados_mapoteca.t_municipios(territorio_identidade);
CREATE INDEX idx_t_municipios_microrregiao ON dados_mapoteca.t_municipios(microrregiao);
CREATE INDEX idx_t_municipios_mesorregiao ON dados_mapoteca.t_municipios(mesorregiao);

-- Índice espacial
CREATE INDEX idx_t_municipios_geom ON dados_mapoteca.t_municipios USING GIST(geom);

-- Índice para busca full-text
CREATE INDEX idx_t_municipios_fulltext ON dados_mapoteca.t_municipios
    USING GIN(to_tsvector('portuguese', nome_municipio));

-- ============================================================================
-- Views auxiliares
-- ============================================================================

-- View: Estatísticas dos municípios
CREATE OR REPLACE VIEW dados_mapoteca.v_estatisticas_municipios AS
SELECT
    COUNT(*) AS total_municipios,
    SUM(area_km2) AS area_total_ba,
    SUM(populacao) AS populacao_total_ba,
    AVG(pib_per_capita) AS pib_per_capita_medio,
    AVG(idh) AS idh_medio,
    MIN(area_km2) AS menor_area,
    MAX(area_km2) AS maior_area,
    MIN(populacao) AS menor_populacao,
    MAX(populacao) AS maior_populacao
FROM dados_mapoteca.t_municipios
WHERE ativo = TRUE;

COMMENT ON VIEW dados_mapoteca.v_estatisticas_municipios IS 'Estatísticas agregadas dos municípios da Bahia';

-- View: Municípios por Território de Identidade
CREATE OR REPLACE VIEW dados_mapoteca.v_municipios_por_territorio AS
SELECT
    territorio_identidade,
    COUNT(*) AS total_municipios,
    SUM(area_km2) AS area_total,
    SUM(populacao) AS populacao_total,
    AVG(idh) AS idh_medio,
    ARRAY_AGG(nome_municipio ORDER BY nome_municipio) AS municipios
FROM dados_mapoteca.t_municipios
WHERE ativo = TRUE
  AND territorio_identidade IS NOT NULL
GROUP BY territorio_identidade
ORDER BY territorio_identidade;

COMMENT ON VIEW dados_mapoteca.v_municipios_por_territorio IS 'Municípios agrupados por Território de Identidade';

-- View: Ranking de municípios
CREATE OR REPLACE VIEW dados_mapoteca.v_ranking_municipios AS
SELECT
    codigo_ibge,
    nome_municipio,
    area_km2,
    populacao,
    pib_per_capita,
    idh,
    RANK() OVER (ORDER BY populacao DESC NULLS LAST) AS rank_populacao,
    RANK() OVER (ORDER BY area_km2 DESC NULLS LAST) AS rank_area,
    RANK() OVER (ORDER BY pib_per_capita DESC NULLS LAST) AS rank_pib,
    RANK() OVER (ORDER BY idh DESC NULLS LAST) AS rank_idh
FROM dados_mapoteca.t_municipios
WHERE ativo = TRUE
ORDER BY populacao DESC;

COMMENT ON VIEW dados_mapoteca.v_ranking_municipios IS 'Ranking de municípios por diferentes indicadores';

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Tabela de municípios criada com sucesso!';
    RAISE NOTICE 'Total esperado: 417 municípios da Bahia';
    RAISE NOTICE 'Triggers criados:';
    RAISE NOTICE '  - Atualização automática de geometria';
    RAISE NOTICE '  - Normalização de nome sem acento';
    RAISE NOTICE '  - Atualização de timestamp';
    RAISE NOTICE 'Índices criados (incluindo espacial e full-text)';
    RAISE NOTICE 'Views auxiliares criadas.';
END $$;
