Clear-Host

# ==========================================================
# LISTENTRACE - ASCII ART
# ==========================================================
Write-Host " _      _     _          _______ " -ForegroundColor Cyan
Write-Host "| |    (_)   | |        |__   __|" -ForegroundColor Cyan
Write-Host "| |     _ ___| |_ ___ _ __ | |_ __ __ _  ___ ___" -ForegroundColor Cyan
Write-Host "| |    | / __| __/ _ \ '_ \| | '__/ _ |/ __/ _ \" -ForegroundColor Cyan
Write-Host "| |____| \__ \ |_  __/ | | | | | | (_| | (__  __/" -ForegroundColor Cyan
Write-Host "|______|_|___/\__\___|_| |_|_|_|  \__,_|\___\___|" -ForegroundColor Cyan

Write-Host ""
Write-Host "ListenTrace - Auditoria Correlacionada" -ForegroundColor DarkCyan
Write-Host "==================================================" -ForegroundColor DarkGray
Write-Host ""

# ==========================================================
# CRITERIOS (deixe "" ou $null para ignorar)
# ==========================================================
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

$BasePath = "C:\Windows"

# ==========================================================
# VALIDACAO
# ==========================================================
if (-not $SearchPort -and -not $SearchIP -and (-not $SearchKey -or $SearchKey.Count -eq 0)) {
    Write-Host "Nenhum criterio definido. Abortando." -ForegroundColor Red
    exit
}

# ==========================================================
# REGEX SIMPLES E SEGURA
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
Write-Host "BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""
if ($SearchPort) { Write-Host " Porta : $SearchPort" -ForegroundColor Blue }
if ($SearchIP)   { Write-Host " IP    : $SearchIP"   -ForegroundColor Yellow }
if ($SearchKey)  { Write-Host " Chave : $($SearchKey -join ', ')" -ForegroundColor Green }
Write-Host " Diretorio: $BasePath" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor DarkGray
Write-Host ""

# ==========================================================
# VARREDURA
# ==========================================================
Get-ChildItem -Path $BasePath -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        $Content = Get-Content $_.FullName -Raw -ErrorAction Stop
    } catch {
        return
    }

    $OkPort = $true
    $OkIP   = $true
    $OkKey  = $true

    if ($RegexPort) { $OkPort = $Content -match $RegexPort }
    if ($RegexIP)   { $OkIP   = $Content -match $RegexIP }
    if ($RegexKey)  { $OkKey  = $Content -match $RegexKey }

    if ($OkPort -and $OkIP -and $OkKey) {
        Write-Host "MATCH:" -NoNewline -ForegroundColor Green
        Write-Host " $($_.FullName)" -ForegroundColor White
        Write-Host ""
    }
}

Write-Host "Varredura finalizada com sucesso." -ForegroundColor Green
Pause
