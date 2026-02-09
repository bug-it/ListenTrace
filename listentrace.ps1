Clear-Host

# ==========================================================
# ASCII ART — LISTENTRACE
# ==========================================================
Write-Host @"
 _      _     _          _______
| |    (_)   | |        |__   __|
| |     _ ___| |_ ___ _ __ | |_ __ __ _  ___ ___
| |    | / __| __/ _ \ '_ \| | '__/ _ |/ __/ _ \
| |____| \__ \ |_  __/ | | | | | | (_| | (__  __/
|______|_|___/\__\___|_| |_|_|_|  \__,_|\___\___|
"@ -ForegroundColor Cyan

Write-Host "                         Auditoria Correlacionada" -ForegroundColor DarkCyan
Write-Host "======================================================" -ForegroundColor DarkGray
Write-Host ""

# ==========================================================
# CONFIGURACAO DE CRITERIOS
# ==========================================================
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

$TargetPath = "C:\Windows"

# ==========================================================
# VALIDACAO
# ==========================================================
$ActiveCriteria = @()

if ($SearchPort) { $ActiveCriteria += "PORT" }
if ($SearchIP)   { $ActiveCriteria += "IP" }
if ($SearchKey -and $SearchKey.Count -gt 0) { $ActiveCriteria += "KEY" }

if ($ActiveCriteria.Count -eq 0) {
    Write-Host "Nenhum criterio definido. Abortando." -ForegroundColor Red
    exit
}

# ==========================================================
# REGEX SIMPLES (SEM UNICODE)
# ==========================================================
$RegexPort = if ($SearchPort) { [regex]::Escape($SearchPort) } else { $null }
$RegexIP   = if ($SearchIP)   { [regex]::Escape($SearchIP) }   else { $null }
$RegexKey  = if ($SearchKey)  {
    ($SearchKey | ForEach-Object { [regex]::Escape($_) }) -join "|"
} else {
    $null
}

# ==========================================================
# PAINEL
# ==========================================================
Write-Host "🔎 BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""
Write-Host " Porta : $SearchPort" -ForegroundColor Cyan
Write-Host " IP    : $SearchIP"   -ForegroundColor Green
Write-Host " Chave : $($SearchKey -join ', ')" -ForegroundColor Yellow
Write-Host " Diretorio: $TargetPath" -ForegroundColor Gray
Write-Host "======================================================" -ForegroundColor DarkGray
Write-Host ""

# ==========================================================
# VARREDURA
# ==========================================================
Get-ChildItem -Path $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        $Content = Get-Content $_.FullName -Raw -ErrorAction Stop
    } catch {
        return
    }

    $MatchPort = $true
    $MatchIP   = $true
    $MatchKey  = $true

    if ($RegexPort) { $MatchPort = $Content -match $RegexPort }
    if ($RegexIP)   { $MatchIP   = $Content -match $RegexIP }
    if ($RegexKey)  { $MatchKey  = $Content -match $RegexKey }

    if ($MatchPort -and $MatchIP -and $MatchKey) {
        Write-Host "MATCH:" -NoNewline -ForegroundColor Green
        Write-Host " $($_.FullName)" -ForegroundColor White

        if ($RegexPort) { Write-Host "  - Porta encontrada" -ForegroundColor Blue }
        if ($RegexIP)   { Write-Host "  - IP encontrado" -ForegroundColor Yellow }
        if ($RegexKey)  { Write-Host "  - Palavra-chave encontrada" -ForegroundColor Cyan }

        Write-Host ""
    }
}

Write-Host "Varredura finalizada com sucesso." -ForegroundColor Green
