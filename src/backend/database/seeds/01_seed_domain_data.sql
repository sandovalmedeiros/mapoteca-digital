-- ============================================================================
-- Mapoteca Digital - Seed Domain Data
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Descrição: População das tabelas de domínio com dados iniciais
-- ============================================================================

SET search_path TO dados_mapoteca, public;

BEGIN;

-- ============================================================================
-- 1. t_classe_mapa (2 registros)
-- ============================================================================

INSERT INTO dados_mapoteca.t_classe_mapa (id_classe_mapa, nome_classe_mapa, descricao) VALUES
('01', 'Mapa', 'Representação cartográfica convencional com base geográfica'),
('02', 'Cartograma', 'Representação cartográfica temática com distorção proporcional')
ON CONFLICT (id_classe_mapa) DO NOTHING;

-- ============================================================================
-- 2. t_tipo_mapa (3 registros)
-- ============================================================================

INSERT INTO dados_mapoteca.t_tipo_mapa (id_tipo_mapa, nome_tipo_mapa, descricao) VALUES
('01', 'Estadual', 'Abrangência estadual (todo o estado da Bahia)'),
('02', 'Regional', 'Abrangência regional (grupos de municípios ou regiões específicas)'),
('03', 'Municipal', 'Abrangência municipal (um único município)')
ON CONFLICT (id_tipo_mapa) DO NOTHING;

-- ============================================================================
-- 3. t_anos (33 registros: 1998-2030)
-- ============================================================================

INSERT INTO dados_mapoteca.t_anos (ano, descricao) VALUES
(1998, 'Ano de referência 1998'),
(1999, 'Ano de referência 1999'),
(2000, 'Ano de referência 2000 - Censo IBGE'),
(2001, 'Ano de referência 2001'),
(2002, 'Ano de referência 2002'),
(2003, 'Ano de referência 2003'),
(2004, 'Ano de referência 2004'),
(2005, 'Ano de referência 2005'),
(2006, 'Ano de referência 2006'),
(2007, 'Ano de referência 2007'),
(2008, 'Ano de referência 2008'),
(2009, 'Ano de referência 2009'),
(2010, 'Ano de referência 2010 - Censo IBGE'),
(2011, 'Ano de referência 2011'),
(2012, 'Ano de referência 2012'),
(2013, 'Ano de referência 2013'),
(2014, 'Ano de referência 2014'),
(2015, 'Ano de referência 2015'),
(2016, 'Ano de referência 2016'),
(2017, 'Ano de referência 2017'),
(2018, 'Ano de referência 2018'),
(2019, 'Ano de referência 2019'),
(2020, 'Ano de referência 2020'),
(2021, 'Ano de referência 2021'),
(2022, 'Ano de referência 2022 - Censo IBGE'),
(2023, 'Ano de referência 2023'),
(2024, 'Ano de referência 2024'),
(2025, 'Ano de referência 2025'),
(2026, 'Ano de referência 2026 - Projeção'),
(2027, 'Ano de referência 2027 - Projeção'),
(2028, 'Ano de referência 2028 - Projeção'),
(2029, 'Ano de referência 2029 - Projeção'),
(2030, 'Ano de referência 2030 - Projeção')
ON CONFLICT (ano) DO NOTHING;

-- ============================================================================
-- 4. t_escala (9 registros)
-- ============================================================================

INSERT INTO dados_mapoteca.t_escala (codigo_escala, nome_escala, valor_numerico, descricao, ordem) VALUES
('1:2.000.000', 'Escala 1:2.000.000', 2000000, 'Escala estadual - visão geral', 1),
('1:1.000.000', 'Escala 1:1.000.000', 1000000, 'Escala regional', 2),
('1:500.000', 'Escala 1:500.000', 500000, 'Escala regional detalhada', 3),
('1:250.000', 'Escala 1:250.000', 250000, 'Escala sub-regional', 4),
('1:100.000', 'Escala 1:100.000', 100000, 'Escala municipal/microrregional', 5),
('1:50.000', 'Escala 1:50.000', 50000, 'Escala municipal detalhada', 6),
('1:25.000', 'Escala 1:25.000', 25000, 'Escala local', 7),
('1:10.000', 'Escala 1:10.000', 10000, 'Escala urbana', 8),
('VARIAVEL', 'Escala Variável', NULL, 'Escala variável conforme região', 9)
ON CONFLICT (codigo_escala) DO NOTHING;

-- ============================================================================
-- 5. t_cor (2 registros)
-- ============================================================================

INSERT INTO dados_mapoteca.t_cor (codigo_cor, nome_cor, descricao) VALUES
('COLOR', 'Colorido', 'Mapa em cores'),
('PB', 'Preto e Branco', 'Mapa em escala de cinza')
ON CONFLICT (codigo_cor) DO NOTHING;

-- ============================================================================
-- 6. t_tipo_regionalizacao (11 registros)
-- ============================================================================

INSERT INTO dados_mapoteca.t_tipo_regionalizacao (id_tipo_regionalizacao, nome_tipo_regionalizacao, descricao, numero_regioes) VALUES
('TRG01', 'Estado da Bahia', 'Todo o estado da Bahia', 1),
('TRG02', 'Mesorregiões Geográficas', 'Divisão em mesorregiões geográficas do IBGE', 7),
('TRG03', 'Microrregiões Geográficas', 'Divisão em microrregiões geográficas do IBGE', 32),
('TRG04', 'Regiões Geográficas Intermediárias', 'Nova divisão regional do IBGE (2017)', 9),
('TRG05', 'Territórios de Identidade', 'Divisão em territórios de identidade do Governo da Bahia', 26),
('TRG06', 'Regiões Econômicas', 'Divisão em regiões econômicas', 8),
('TRG07', 'Regiões Administrativas', 'Divisão em regiões administrativas estaduais', 15),
('TRG08', 'Bacias Hidrográficas', 'Divisão por bacias hidrográficas', 12),
('TRG09', 'Regiões de Saúde', 'Divisão em regiões de saúde', 9),
('TRG10', 'Regiões de Planejamento', 'Divisão em regiões de planejamento', 10),
('TRG11', 'Outras Regionalizações', 'Outras formas de regionalização', NULL)
ON CONFLICT (id_tipo_regionalizacao) DO NOTHING;

-- ============================================================================
-- 7. t_tipo_tema (6 registros)
-- ============================================================================

INSERT INTO dados_mapoteca.t_tipo_tema (id_tipo_tema, codigo_tipo_tema, nome_tipo_tema, descricao, ordem) VALUES
('TTM01', 'CT', 'Cartografia', 'Temas relacionados a cartografia básica', 1),
('TTM02', 'PA', 'Político-Administrativo', 'Divisões políticas e administrativas', 2),
('TTM03', 'FA', 'Físico-Ambiental', 'Aspectos físicos e ambientais', 3),
('TTM04', 'INF', 'Infraestrutura', 'Infraestrutura e equipamentos', 4),
('TTM05', 'SE', 'Socioeconômico', 'Indicadores socioeconômicos', 5),
('TTM06', 'OUT', 'Outros', 'Outros temas', 6)
ON CONFLICT (id_tipo_tema) DO NOTHING;

COMMIT;

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Dados de domínio inseridos com sucesso!';
    RAISE NOTICE 'Resumo:';
    RAISE NOTICE '  - t_classe_mapa: 2 registros';
    RAISE NOTICE '  - t_tipo_mapa: 3 registros';
    RAISE NOTICE '  - t_anos: 33 registros (1998-2030)';
    RAISE NOTICE '  - t_escala: 9 registros';
    RAISE NOTICE '  - t_cor: 2 registros';
    RAISE NOTICE '  - t_tipo_regionalizacao: 11 registros';
    RAISE NOTICE '  - t_tipo_tema: 6 registros';
END $$;
