Clear-Host

# ==========================================================
# ASCII ART — IDENTIDADE LISTENTRACE
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
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

# ==========================================================
# 🔧 Critérios (deixe "" ou $null para ignorar)
# ==========================================================
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

# 📂 Diretório alvo
$TargetPath = "C:\Windows"

# ==========================================================
# 🎯 Validação de critérios ativos
# ==========================================================
$ActiveCriteria = @()

if ($SearchPort -and $SearchPort -ne "") { $ActiveCriteria += "PORT" }
if ($SearchIP   -and $SearchIP   -ne "") { $ActiveCriteria += "IP" }
if ($SearchKey  -and $SearchKey.Count -gt 0) { $ActiveCriteria += "KEY" }

if ($ActiveCriteria.Count -eq 0) {
    Write-Host "❌ Nenhum critério definido. Abortando." -ForegroundColor Red
    return
}

# ==========================================================
# 🧠 Regex simples e objetiva
# ==========================================================
$RegexPort = if ($SearchPort) { [regex]::Escape($SearchPort) }
$RegexIP   = if ($SearchIP)   { [regex]::Escape($SearchIP) }
$RegexKey  = if ($SearchKey)  {
    (($SearchKey | ForEach-Object { [regex]::Escape($_) }) -join "|")
}

# ==========================================================
# 📊 Painel de critérios
# ==========================================================
Write-Host " 🔎 BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""
Write-Host " 🟦 Porta : $SearchPort" -ForegroundColor Cyan
Write-Host " 🟨 IP    : $SearchIP"   -ForegroundColor Green
Write-Host " 🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Yellow
Write-Host " 📂 Diretório: $TargetPath" -ForegroundColor Gray
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

# ==========================================================
# 🔍 Varredura correlacionada real
# ==========================================================
Get-ChildItem -Path $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        $Content = Get-Content $_.FullName -Raw -ErrorAction Stop
    } catch {
        return
    }

    $MatchPort = $false
    $MatchIP   = $false
    $MatchKey  = $false

    if ($RegexPort) { $MatchPort = $Content -match $RegexPort }
    if ($RegexIP)   { $MatchIP   = $Content -match $RegexIP }
    if ($RegexKey)  { $MatchKey  = $Content -match $RegexKey }

    # 🧠 Regra de correlação absoluta
    $Valid = $true
    if ($ActiveCriteria -contains "PORT" -and -not $MatchPort) { $Valid = $false }
    if ($ActiveCriteria -contains "IP"   -and -not $MatchIP)   { $Valid = $false }
    if ($ActiveCriteria -contains "KEY"  -and -not $MatchKey)  { $Valid = $false }

    if ($Valid) {
        Write-Host "📄 MATCH: $($_.FullName)" -ForegroundColor Green
        if ($MatchPort) { Write-Host "   ✔ Porta encontrada" -ForegroundColor Blue }
        if ($MatchIP)   { Write-Host "   ✔ IP encontrado" -ForegroundColor Yellow }
        if ($MatchKey)  { Write-Host "   ✔ Palavra-chave encontrada" -ForegroundColor Cyan }
        Write-Host ""
    }
}

Write-Host "✅ Varredura finalizada com sucesso." -ForegroundColor Green
