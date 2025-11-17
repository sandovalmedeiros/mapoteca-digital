-- ===================================================================================
-- Mapoteca Digital - Script 00: Validação de Ambiente (PRÉ-EXECUÇÃO)
-- ===================================================================================
-- Descrição: Validar ambiente antes de executar scripts de criação
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Data: 2025-11-17
-- ===================================================================================

\set ON_ERROR_STOP on
SET client_min_messages TO NOTICE;

-- Cabeçalho
SELECT '=====================================================================' as info;
SELECT 'MAPOTECA DIGITAL - VALIDAÇÃO DE AMBIENTE' as info;
SELECT '=====================================================================' as info;

-- ===================================================================================
-- 1. VALIDAR VERSÃO DO POSTGRESQL
-- ===================================================================================

DO $$
DECLARE
    pg_version_num INTEGER;
    pg_version_text TEXT;
BEGIN
    SELECT split_part(split_part(version(), ' ', 2), '.', 1)::integer INTO pg_version_num;
    SELECT version() INTO pg_version_text;

    RAISE NOTICE '';
    RAISE NOTICE '1. POSTGRESQL VERSION';
    RAISE NOTICE '   Current: %', pg_version_text;

    IF pg_version_num >= 14 THEN
        RAISE NOTICE '   Status: ✓ OK (PostgreSQL 14+ required)';
    ELSE
        RAISE EXCEPTION '   Status: ✗ FAIL - PostgreSQL 14+ is required, current version is %', pg_version_num;
    END IF;
END $$;

-- ===================================================================================
-- 2. VALIDAR EXTENSÕES DISPONÍVEIS
-- ===================================================================================

DO $$
DECLARE
    v_uuid_ossp BOOLEAN;
    v_pg_trgm BOOLEAN;
    v_postgis BOOLEAN;
BEGIN
    -- uuid-ossp
    SELECT EXISTS(SELECT 1 FROM pg_available_extensions WHERE name = 'uuid-ossp') INTO v_uuid_ossp;

    -- pg_trgm
    SELECT EXISTS(SELECT 1 FROM pg_available_extensions WHERE name = 'pg_trgm') INTO v_pg_trgm;

    -- postgis
    SELECT EXISTS(SELECT 1 FROM pg_available_extensions WHERE name = 'postgis') INTO v_postgis;

    RAISE NOTICE '';
    RAISE NOTICE '2. REQUIRED EXTENSIONS';
    RAISE NOTICE '   uuid-ossp: % %', v_uuid_ossp, CASE WHEN v_uuid_ossp THEN '✓' ELSE '✗ REQUIRED' END;
    RAISE NOTICE '   pg_trgm:   % %', v_pg_trgm, CASE WHEN v_pg_trgm THEN '✓' ELSE '⚠ RECOMMENDED' END;
    RAISE NOTICE '   postgis:   % %', v_postgis, CASE WHEN v_postgis THEN '✓' ELSE '(optional)' END;

    IF NOT v_uuid_ossp THEN
        RAISE EXCEPTION '   Extension uuid-ossp is REQUIRED but not available';
    END IF;
END $$;

-- ===================================================================================
-- 3. VALIDAR PERMISSÕES DO USUÁRIO
-- ===================================================================================

DO $$
DECLARE
    v_current_user TEXT;
    v_is_superuser BOOLEAN;
    v_can_create_db BOOLEAN;
    v_can_create_role BOOLEAN;
BEGIN
    SELECT current_user INTO v_current_user;
    SELECT usesuper, usecreatedb, usecreaterole
    INTO v_is_superuser, v_can_create_db, v_can_create_role
    FROM pg_user
    WHERE usename = v_current_user;

    RAISE NOTICE '';
    RAISE NOTICE '3. USER PERMISSIONS';
    RAISE NOTICE '   Current User: %', v_current_user;
    RAISE NOTICE '   Superuser: %', v_is_superuser;
    RAISE NOTICE '   Can Create DB: %', v_can_create_db;
    RAISE NOTICE '   Can Create Role: %', v_can_create_role;

    IF NOT v_is_superuser AND NOT v_can_create_db THEN
        RAISE WARNING '   User does not have CREATEDB permission';
    END IF;
END $$;

-- ===================================================================================
-- 4. VERIFICAR SE SCHEMA dados_mapoteca JÁ EXISTE
-- ===================================================================================

DO $$
DECLARE
    v_schema_exists BOOLEAN;
    v_table_count INTEGER;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM information_schema.schemata
        WHERE schema_name = 'dados_mapoteca'
    ) INTO v_schema_exists;

    RAISE NOTICE '';
    RAISE NOTICE '4. SCHEMA STATUS';

    IF v_schema_exists THEN
        SELECT COUNT(*) INTO v_table_count
        FROM information_schema.tables
        WHERE table_schema = 'dados_mapoteca';

        RAISE NOTICE '   Schema: ⚠ EXISTS';
        RAISE NOTICE '   Tables: % tables found', v_table_count;
        RAISE WARNING '   Schema dados_mapoteca already exists with % tables', v_table_count;
        RAISE NOTICE '   Action: Script 01 will DROP CASCADE this schema';
    ELSE
        RAISE NOTICE '   Schema: ✓ NOT EXISTS (ready for creation)';
    END IF;
END $$;

-- ===================================================================================
-- 5. VERIFICAR ESPAÇO EM DISCO
-- ===================================================================================

SELECT
    ''::TEXT as sep,
    '5. DISK SPACE' as category;

SELECT
    pg_database.datname as database_name,
    pg_size_pretty(pg_database_size(pg_database.datname)) as size
FROM pg_database
WHERE datname = current_database();

-- ===================================================================================
-- 6. VERIFICAR CONFIGURAÇÕES DO POSTGRESQL
-- ===================================================================================

SELECT
    ''::TEXT as sep,
    '6. POSTGRESQL CONFIGURATION' as category;

SELECT
    name,
    setting,
    unit,
    short_desc
FROM pg_settings
WHERE name IN (
    'max_connections',
    'shared_buffers',
    'effective_cache_size',
    'maintenance_work_mem',
    'work_mem'
)
ORDER BY name;

-- ===================================================================================
-- 7. RESUMO DA VALIDAÇÃO
-- ===================================================================================

SELECT '=====================================================================' as info;
SELECT 'VALIDATION SUMMARY' as info;
SELECT '=====================================================================' as info;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'VALIDATION COMPLETED SUCCESSFULLY!';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '  1. Review the validation results above';
    RAISE NOTICE '  2. Execute scripts in order:';
    RAISE NOTICE '     psql -d mapoteca -f 01-setup-schema-CORRECTED.sql';
    RAISE NOTICE '     psql -d mapoteca -f 02-populate-data-CORRECTED.sql';
    RAISE NOTICE '     psql -d mapoteca -f 03-indexes-constraints-CORRECTED.sql';
    RAISE NOTICE '     psql -d mapoteca -f 04-esri-integration-CORRECTED.sql';
    RAISE NOTICE '';
END $$;

-- ===================================================================================
-- FIM DA VALIDAÇÃO
-- ===================================================================================
