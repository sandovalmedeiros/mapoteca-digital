# Script PowerShell para gerar todos os arquivos da Mapoteca Digital no Windows
# Execute: .\gerar-arquivos-windows.ps1

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Mapoteca Digital - Gerador de Arquivos" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar pasta de destino
$destino = Read-Host "Digite o caminho onde deseja criar a pasta (ex: C:\Users\SeuUsuario\Documents)"

if (-not (Test-Path $destino)) {
    Write-Host "ERRO: O caminho $destino não existe!" -ForegroundColor Red
    exit
}

# Criar estrutura de pastas
$projeto = Join-Path $destino "mapoteca-digital"
Write-Host "Criando estrutura de pastas em: $projeto" -ForegroundColor Green

New-Item -ItemType Directory -Force -Path $projeto | Out-Null
New-Item -ItemType Directory -Force -Path "$projeto\docs" | Out-Null
New-Item -ItemType Directory -Force -Path "$projeto\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$projeto\src\backend\database\schema" | Out-Null
New-Item -ItemType Directory -Force -Path "$projeto\src\frontend\widgets" | Out-Null
New-Item -ItemType Directory -Force -Path "$projeto\tests\unit" | Out-Null

Write-Host "✓ Estrutura de pastas criada" -ForegroundColor Green
Write-Host ""
Write-Host "Baixando arquivos do repositório remoto..." -ForegroundColor Yellow
Write-Host ""

# Função para baixar arquivo
function Download-File {
    param(
        [string]$url,
        [string]$output
    )
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $output)
        Write-Host "✓ $(Split-Path $output -Leaf)" -ForegroundColor Green
    } catch {
        Write-Host "✗ Falha ao baixar $(Split-Path $output -Leaf)" -ForegroundColor Red
    }
}

# URL base do repositório
$baseUrl = "http://127.0.0.1:36334/git/sandovalmedeiros/mapoteca-digital/raw/branch/claude/execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW"

# Lista de arquivos para baixar
$arquivos = @{
    "README.md" = "README.md"
    "MIGRATION-GUIDE.md" = "MIGRATION-GUIDE.md"
    "docs/FEATURE-SERVICES-CONFIG.md" = "docs\FEATURE-SERVICES-CONFIG.md"
    "docs/EXPERIENCE-BUILDER-CONFIG.md" = "docs\EXPERIENCE-BUILDER-CONFIG.md"
    "docs/VALIDATIONS-LOGIC.md" = "docs\VALIDATIONS-LOGIC.md"
    "docs/DEPLOYMENT-GUIDE.md" = "docs\DEPLOYMENT-GUIDE.md"
    "scripts/00-validate-environment.sql" = "scripts\00-validate-environment.sql"
    "scripts/01-setup-schema-CORRECTED.sql" = "scripts\01-setup-schema-CORRECTED.sql"
    "scripts/02-populate-data-CORRECTED.sql" = "scripts\02-populate-data-CORRECTED.sql"
    "scripts/03-indexes-constraints-CORRECTED.sql" = "scripts\03-indexes-constraints-CORRECTED.sql"
    "scripts/04-esri-integration-CORRECTED.sql" = "scripts\04-esri-integration-CORRECTED.sql"
}

foreach ($arquivo in $arquivos.GetEnumerator()) {
    $url = "$baseUrl/$($arquivo.Key)"
    $output = Join-Path $projeto $arquivo.Value
    Download-File -url $url -output $output
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Concluído!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Arquivos salvos em: $projeto" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Abra a pasta: $projeto"
Write-Host "2. Leia o arquivo: docs\DEPLOYMENT-GUIDE.md"
Write-Host "3. Execute os scripts SQL na ordem correta"
Write-Host ""
