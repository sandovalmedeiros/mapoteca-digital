# 🗄️ Backend - Mapoteca Digital

## 📋 Visão Geral

Backend do Sistema de Automação da Mapoteca Digital baseado em **PostgreSQL 13+** com **PostGIS** e integração via **ArcGIS SDE (Spatial Database Engine)**.

**Stack:** PostgreSQL + PostGIS + SDE + Python 3.8+
**Versão:** 1.0.0
**Status:** ✅ Pronto para Produção

---

## 🎯 Objetivos

O backend foi desenvolvido para:

- ✅ **Armazenar 18 tabelas** com 1.210+ registros estruturais
- ✅ **Gerenciar attachments** (PDFs) via ESRI SDE Attachments
- ✅ **Validar dados** através de triggers e functions PostgreSQL
- ✅ **Garantir integridade** com foreign keys e constraints
- ✅ **Auditar operações** com log completo de INSERT/UPDATE/DELETE
- ✅ **Suportar queries espaciais** com PostGIS

---

## 🏗️ Arquitetura do Banco

```
┌─────────────────────────────────────────────┐
│         ArcGIS Experience Builder           │
│              (Frontend)                     │
├─────────────────────────────────────────────┤
│     ArcGIS Feature Services (REST API)      │
│     - FS_Mapoteca_Publicacoes               │
│     - FS_Mapoteca_Dominios                  │
│     - FS_Mapoteca_Relacionamentos           │
├─────────────────────────────────────────────┤
│         ArcGIS SDE (Geodatabase)            │
│     - Attachment Tables                     │
│     - Spatial Indexes                       │
├─────────────────────────────────────────────┤
│    PostgreSQL 13+ + PostGIS + SDE           │
│    - Schema: dados_mapoteca                 │
│    - 18 tabelas + 2 attachments             │
│    - Triggers de validação                  │
│    - Audit log                              │
└─────────────────────────────────────────────┘
```

---

## 📊 Estrutura do Banco de Dados

### Resumo: 18 Tabelas | 1.210+ Registros

#### 1. **Tabelas de Domínio** (9 tabelas)
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `t_classe_mapa` | 2 | Classes (Mapa, Cartograma) |
| `t_tipo_mapa` | 3 | Tipos (Estadual, Regional, Municipal) |
| `t_anos` | 33 | Anos de referência (1998-2030) |
| `t_escala` | 9 | Escalas cartográficas |
| `t_cor` | 2 | Esquemas de cor (Colorido, PB) |
| `t_tipo_regionalizacao` | 11 | Tipos de regionalização |
| `t_regiao` | 106 | Regiões geográficas |
| `t_tipo_tema` | 6 | Tipos de tema |
| `t_tema` | 55 | Temas específicos |

#### 2. **Tabelas de Relacionamento N:N** (3 tabelas)
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `t_classe_mapa_tipo_mapa` | 6 | Combinações válidas ⚠️ CRÍTICO |
| `t_regionalizacao_regiao` | 229 | Regiões por tipo de regionalização |
| `t_tipo_tema_tema` | 55 | Temas por tipo de tema |

#### 3. **Tabela de Dados** (1 tabela)
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `t_municipios` | 417 | Municípios da Bahia com dados completos |

#### 4. **Tabelas de Publicações** (2 tabelas)
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `t_publicacao` | Dinâmico | Publicações estaduais/regionais |
| `t_publicacao_municipios` | Dinâmico | Publicações municipais |

#### 5. **Tabelas de Attachments ESRI** (2 tabelas)
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `t_publicacao__attach` | Dinâmico | PDFs das publicações (max 50MB) |
| `t_publicacao_municipios__attach` | Dinâmico | PDFs das publicações municipais |

#### 6. **Tabela de Auditoria** (1 tabela)
| Tabela | Registros | Descrição |
|--------|-----------|-----------|
| `t_audit_log` | Dinâmico | Log de todas as operações |

---

## 📁 Estrutura de Arquivos

```
src/backend/
├── README.md                      # Este arquivo
│
├── database/                      # Scripts SQL
│   ├── schema/                    # DDL das tabelas
│   │   ├── 01_create_schema.sql              # Schema e funções
│   │   ├── 02_create_domain_tables.sql       # Tabelas de domínio
│   │   ├── 03_create_relationship_tables.sql # Tabelas N:N
│   │   ├── 04_create_municipios_table.sql    # Tabela de municípios
│   │   ├── 05_create_publication_tables.sql  # Tabelas de publicações
│   │   └── 06_create_audit_table.sql         # Tabela de auditoria
│   │
│   ├── seeds/                     # Dados iniciais
│   │   ├── 01_seed_domain_data.sql           # Dados de domínio
│   │   └── 02_seed_relationship_data.sql     # Dados de relacionamento
│   │
│   ├── migrations/                # Migrações versionadas
│   │   └── (migrations futuras)
│   │
│   └── views/                     # Views úteis
│       └── (views auxiliares)
│
└── scripts/                       # Scripts Python
    ├── migrate_csv.py            # Migração de dados CSV
    ├── validate_data.py          # Validação de dados
    ├── generate_docs.py          # Geração de documentação
    └── requirements.txt          # Dependências Python
```

---

## 🚀 Quick Start

### Pré-requisitos

```bash
# Software necessário
✅ PostgreSQL 13+ instalado
✅ PostGIS 3.0+ instalado
✅ Python 3.8+ instalado
✅ psycopg2 (pip install psycopg2-binary)
```

### 1. Criar Banco de Dados

```bash
# Conectar como superuser
psql -U postgres

# Criar banco
CREATE DATABASE mapoteca;

# Conectar ao banco
\c mapoteca

# Habilitar PostGIS
CREATE EXTENSION postgis;
CREATE EXTENSION "uuid-ossp";
```

### 2. Executar Scripts de Schema

```bash
# Navegar para o diretório
cd src/backend/database/schema

# Executar scripts em ordem
psql -U postgres -d mapoteca -f 01_create_schema.sql
psql -U postgres -d mapoteca -f 02_create_domain_tables.sql
psql -U postgres -d mapoteca -f 03_create_relationship_tables.sql
psql -U postgres -d mapoteca -f 04_create_municipios_table.sql
psql -U postgres -d mapoteca -f 05_create_publication_tables.sql
psql -U postgres -d mapoteca -f 06_create_audit_table.sql
```

### 3. Popular Dados Iniciais

```bash
# Navegar para seeds
cd ../seeds

# Executar seeds
psql -U postgres -d mapoteca -f 01_seed_domain_data.sql
psql -U postgres -d mapoteca -f 02_seed_relationship_data.sql
```

### 4. Migrar Dados CSV (Opcional)

```bash
# Configurar variáveis de ambiente
export DB_NAME=mapoteca
export DB_USER=postgres
export DB_PASSWORD=sua_senha
export DB_HOST=localhost
export DB_PORT=5432
export CSV_DIR=./data/csv

# Executar migração
cd ../../scripts
python3 migrate_csv.py --csv-dir ../data/csv

# Ver estatísticas
python3 migrate_csv.py --stats

# Validar dados
python3 migrate_csv.py --validate
```

---

## 🔑 Validações Críticas

### 1. Validação Classe + Tipo ⚠️ CRÍTICA

**Apenas 6 combinações são válidas:**

```sql
-- Tabela: t_classe_mapa_tipo_mapa
SELECT * FROM dados_mapoteca.v_classe_tipo_validos;

-- Resultado esperado:
-- 01 | Mapa       | 01 | Estadual  ✓
-- 01 | Mapa       | 02 | Regional  ✓
-- 01 | Mapa       | 03 | Municipal ✓
-- 02 | Cartograma | 01 | Estadual  ✓
-- 02 | Cartograma | 02 | Regional  ✓
-- 02 | Cartograma | 03 | Municipal ✓
```

**Trigger de validação:**
```sql
-- Implementado em: validate_classe_tipo()
-- Ativado BEFORE INSERT/UPDATE em t_publicacao
-- Lança EXCEPTION se combinação inválida
```

### 2. Validação Tipo Regionalização + Região

```sql
-- View auxiliar
SELECT * FROM dados_mapoteca.v_regioes_por_tipo
WHERE id_tipo_regionalizacao = 'TRG05'
ORDER BY nome_regiao;

-- Retorna 26 Territórios de Identidade válidos
```

**Trigger de validação:**
```sql
-- Implementado em: validate_regionalizacao_regiao()
-- Ativado BEFORE INSERT/UPDATE em t_publicacao
```

### 3. Validação Tipo Tema + Tema

```sql
-- View auxiliar
SELECT * FROM dados_mapoteca.v_temas_por_tipo
WHERE id_tipo_tema = 'TTM05'
ORDER BY nome_tema;

-- Retorna 15 temas socioeconômicos válidos
```

**Trigger de validação:**
```sql
-- Implementado em: validate_tipo_tema_tema()
-- Ativado BEFORE INSERT/UPDATE em t_publicacao
```

---

## 📊 Queries Úteis

### Estatísticas Gerais

```sql
-- Total de registros por tabela
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
    (SELECT COUNT(*) FROM dados_mapoteca.|| tablename) AS rows
FROM pg_tables
WHERE schemaname = 'dados_mapoteca'
ORDER BY tablename;
```

### Validar Integridade

```sql
-- Validar combinações classe+tipo
SELECT COUNT(*) AS total_combinacoes_validas
FROM dados_mapoteca.t_classe_mapa_tipo_mapa
WHERE ativo = TRUE;
-- Esperado: 6

-- Validar regiões por tipo de regionalização
SELECT
    id_tipo_regionalizacao,
    COUNT(*) AS total_regioes
FROM dados_mapoteca.t_regionalizacao_regiao
WHERE ativo = TRUE
GROUP BY id_tipo_regionalizacao
ORDER BY id_tipo_regionalizacao;

-- Validar temas por tipo
SELECT
    tt.nome_tipo_tema,
    COUNT(*) AS total_temas
FROM dados_mapoteca.t_tipo_tema_tema ttt
JOIN dados_mapoteca.t_tipo_tema tt USING (id_tipo_tema)
WHERE ttt.ativo = TRUE
GROUP BY tt.nome_tipo_tema
ORDER BY tt.nome_tipo_tema;
```

### Auditoria

```sql
-- Últimas 20 operações
SELECT * FROM dados_mapoteca.v_audit_recentes
LIMIT 20;

-- Resumo por tabela
SELECT * FROM dados_mapoteca.v_audit_resumo_tabelas;

-- Resumo por usuário
SELECT * FROM dados_mapoteca.v_audit_resumo_usuarios;

-- Histórico de um registro específico
SELECT * FROM dados_mapoteca.f_audit_historico_registro('t_publicacao', '123');
```

### Estatísticas de Municípios

```sql
-- Estatísticas gerais
SELECT * FROM dados_mapoteca.v_estatisticas_municipios;

-- Municípios por Território de Identidade
SELECT * FROM dados_mapoteca.v_municipios_por_territorio
ORDER BY total_municipios DESC;

-- Ranking de municípios
SELECT * FROM dados_mapoteca.v_ranking_municipios
LIMIT 20;
```

---

## 🔧 Manutenção

### Backup

```bash
# Backup completo
pg_dump -U postgres -d mapoteca -F c -b -v -f mapoteca_backup_$(date +%Y%m%d).backup

# Backup apenas schema
pg_dump -U postgres -d mapoteca -s > mapoteca_schema_$(date +%Y%m%d).sql

# Backup apenas dados
pg_dump -U postgres -d mapoteca -a > mapoteca_data_$(date +%Y%m%d).sql
```

### Restore

```bash
# Restore completo
pg_restore -U postgres -d mapoteca -v mapoteca_backup_20251119.backup

# Restore apenas schema
psql -U postgres -d mapoteca < mapoteca_schema_20251119.sql
```

### Limpeza de Auditoria

```sql
-- Limpar logs com mais de 1 ano
SELECT dados_mapoteca.f_limpar_audit_log(365);

-- Exportar auditoria de um período
SELECT * FROM dados_mapoteca.f_exportar_audit_log(
    '2024-01-01'::timestamp,
    '2024-12-31'::timestamp,
    't_publicacao'
);
```

### Vacuum e Analyze

```bash
# Vacuum completo
psql -U postgres -d mapoteca -c "VACUUM FULL ANALYZE;"

# Vacuum por tabela
psql -U postgres -d mapoteca -c "VACUUM FULL ANALYZE dados_mapoteca.t_publicacao;"

# Reindex
psql -U postgres -d mapoteca -c "REINDEX DATABASE mapoteca;"
```

---

## 🧪 Testes

### Teste de Validações

```sql
-- Teste 1: Tentar inserir combinação inválida classe+tipo
-- Esperado: EXCEPTION
BEGIN;
INSERT INTO dados_mapoteca.t_publicacao (
    id_classe_mapa, id_tipo_mapa, id_ano, id_regiao,
    id_tipo_regionalizacao, id_tema, id_tipo_tema,
    codigo_escala, codigo_cor
) VALUES (
    '01', '99', -- Combinação inválida!
    (SELECT id_ano FROM dados_mapoteca.t_anos WHERE ano = 2023),
    'BA', 'TRG01',
    (SELECT id_tema FROM dados_mapoteca.t_tema LIMIT 1),
    'TTM01', '1:2.000.000', 'COLOR'
);
ROLLBACK;

-- Teste 2: Tentar inserir regionalização+região inválida
-- Esperado: EXCEPTION
BEGIN;
INSERT INTO dados_mapoteca.t_publicacao (
    id_classe_mapa, id_tipo_mapa, id_ano, id_regiao,
    id_tipo_regionalizacao, id_tema, id_tipo_tema,
    codigo_escala, codigo_cor
) VALUES (
    '01', '01',
    (SELECT id_ano FROM dados_mapoteca.t_anos WHERE ano = 2023),
    'MESO01', 'TRG05', -- TRG05 não tem MESO01!
    (SELECT id_tema FROM dados_mapoteca.t_tema LIMIT 1),
    'TTM01', '1:2.000.000', 'COLOR'
);
ROLLBACK;
```

### Teste de Performance

```sql
-- Teste de INSERT em lote
EXPLAIN ANALYZE
INSERT INTO dados_mapoteca.t_publicacao (
    id_classe_mapa, id_tipo_mapa, id_ano, id_regiao,
    id_tipo_regionalizacao, id_tema, id_tipo_tema,
    codigo_escala, codigo_cor
)
SELECT
    '01', '01',
    (SELECT id_ano FROM dados_mapoteca.t_anos WHERE ano = 2023),
    'BA', 'TRG01',
    id_tema, 'TTM01', '1:2.000.000', 'COLOR'
FROM dados_mapoteca.t_tema
LIMIT 100;
```

---

## 📚 Documentação Adicional

### Para Desenvolvedores

- **[Database Schema](../../docs/database.md)** - Schema completo detalhado
- **[Diagrama ER](../../docs/Diagrama_ER.md)** - Diagramas de relacionamento
- **[DFD](../../docs/DFD.md)** - Fluxo de dados

### Para Administradores

- **[Feature Services Config](../../docs/FEATURE-SERVICES-CONFIG.md)** - Configuração de serviços
- **[PRD](../../docs/prd.md)** - Requisitos do produto

---

## 🔍 Troubleshooting

### Problema: Extension PostGIS não encontrada

**Solução:**
```bash
# Instalar PostGIS (Ubuntu/Debian)
sudo apt-get install postgresql-13-postgis-3

# Instalar PostGIS (CentOS/RHEL)
sudo yum install postgis30_13

# Habilitar no banco
psql -U postgres -d mapoteca -c "CREATE EXTENSION postgis;"
```

### Problema: Erro de permissões

**Solução:**
```sql
-- Conceder permissões ao usuário
GRANT ALL PRIVILEGES ON SCHEMA dados_mapoteca TO seu_usuario;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dados_mapoteca TO seu_usuario;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dados_mapoteca TO seu_usuario;
```

### Problema: Triggers não estão funcionando

**Solução:**
```sql
-- Verificar triggers existentes
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'dados_mapoteca'
ORDER BY event_object_table, trigger_name;

-- Recriar trigger se necessário
DROP TRIGGER IF EXISTS validate_publicacao_classe_tipo ON dados_mapoteca.t_publicacao;
CREATE TRIGGER validate_publicacao_classe_tipo
    BEFORE INSERT OR UPDATE
    ON dados_mapoteca.t_publicacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.validate_classe_tipo();
```

---

## 👥 Contatos

### Equipe

- **Desenvolvimento:** SEIGEO - seigeo@sei.ba.gov.br
- **Infraestrutura:** TI SEI-BA
- **Suporte:** suporte@sei.ba.gov.br

---

## 📝 Changelog

### Versão 1.0.0 (2025-11-19)

**Schema:**
- ✅ 18 tabelas criadas com constraints e índices
- ✅ Triggers de validação (classe+tipo, regionalização+região, tipo_tema+tema)
- ✅ Triggers de auditoria
- ✅ Triggers de timestamp automático
- ✅ Support para ESRI Attachments

**Dados:**
- ✅ 1.210+ registros estruturais
- ✅ 6 combinações válidas classe+tipo
- ✅ 229 relacionamentos regionalização+região
- ✅ 55 relacionamentos tipo_tema+tema
- ✅ 417 municípios da Bahia

**Scripts:**
- ✅ Script de migração CSV
- ✅ Scripts de validação
- ✅ Views auxiliares
- ✅ Funções de auditoria e manutenção

---

**Versão:** 1.0.0
**Status:** ✅ Pronto para Produção
**Última Atualização:** 2025-11-19
