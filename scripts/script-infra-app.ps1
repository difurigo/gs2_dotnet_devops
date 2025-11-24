<#
    Script de provisionamento da infraestrutura na Azure
    TCC DevOps - Avant API

    Recursos criados:
    - Resource Group
    - App Service Plan (Windows)
    - Web App
    - Azure SQL Server
    - Azure SQL Database
    - Connection String (DefaultConnection) no Web App

    Uso (exemplo no PowerShell da sua máquina):

    ./script-infra-app.ps1 `
        -prefix "avantgs2" `
        -location "brazilsouth" `
        -sqlAdmin "avantadmin" `
        -sqlPassword "SuaSenhaForteAqui123!"
#>

param(
    [string]$prefix = "avant",
    [string]$location = "brazilsouth",
    [string]$sqlAdmin = "avantadmin",
    [string]$sqlPassword
)

if (-not $sqlPassword) {
    throw "Parâmetro -sqlPassword é obrigatório. Use -sqlPassword 'SenhaBemForte123!'."
}

# Nomes dos recursos baseados no prefixo
$rg   = "$prefix-rg"
$plan = "$prefix-plan"
$app  = "$prefix-webapp"
$sql  = "$prefix-sqlserver"
$db   = "$prefix-db"

Write-Output "============================================="
Write-Output " Iniciando provisionamento da infraestrutura "
Write-Output " Prefixo: $prefix"
Write-Output " Localização: $location"
Write-Output "============================================="

Write-Output "`n[1/5] Criando Resource Group..."
az group create `
    --name $rg `
    --location $location `
    | Out-Null

Write-Output "[2/5] Criando App Service Plan (Windows)..."
az appservice plan create `
    --name $plan `
    --resource-group $rg `
    --sku B1 `
    | Out-Null

Write-Output "[3/5] Criando Web App..."
az webapp create `
    --name $app `
    --resource-group $rg `
    --plan $plan `
    | Out-Null

Write-Output "[4/5] Criando Azure SQL Server..."
az sql server create `
    --name $sql `
    --resource-group $rg `
    --location $location `
    --admin-user $sqlAdmin `
    --admin-password $sqlPassword `
    | Out-Null

Write-Output "[5/5] Criando Azure SQL Database..."
az sql db create `
    --resource-group $rg `
    --server $sql `
    --name $db `
    --service-objective S0 `
    | Out-Null

# Monta a connection string para SQL Azure
$connectionString = "Server=tcp:$sql.database.windows.net,1433;Initial Catalog=$db;Persist Security Info=False;User ID=$sqlAdmin;Password=$sqlPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Output "`nConfigurando Connection String 'DefaultConnection' no Web App..."
az webapp config connection-string set `
    --resource-group $rg `
    --name $app `
    --settings DefaultConnection="$connectionString" `
    --connection-string-type SQLAzure `
    | Out-Null

Write-Output "`nProvisionamento concluído com sucesso!"
Write-Output "Resource Group........: $rg"
Write-Output "App Service Plan......: $plan"
Write-Output "Web App...............: $app"
Write-Output "SQL Server............: $sql"
Write-Output "SQL Database..........: $db"
Write-Output "`nImportante:"
Write-Output "- Em Production (Azure), a API usa UseSqlServer com a connection string 'DefaultConnection'."
Write-Output "- Dados sensíveis ficaram só na configuração do Web App, não no código."
