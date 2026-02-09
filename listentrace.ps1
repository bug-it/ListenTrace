Clear-Host

Write-Host @"
 _      _     _          _______                 
| |    (_)   | |        |__   __|                
| |     _ ___| |_ ___ _ __ | |_ __ __ _  ___ ___ 
| |    | / __| __/ _ \ '_ \| | '__/ _` |/ __/ _ \
| |____| \__ \ |_  __/ | | | | | | (_| | (__  __/
|______|_|___/\__\___|_| |_|_|_|  \__,_|\___\___|
"@ -ForegroundColor Cyan

# ================= CONFIGURAÇÕES =================

$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = "Porta","Port"

$BasePath = "C:\Windows\"
$Extensions = @("*.conf","*.cfg","*.ini","*.json","*.yaml","*.yml","*.xml","*.env","*.log","*.py","*.js")

$SnippetSize = 160

# ================= REGEX =================

$RegexPort = if ($SearchPort) { "(?i)(port|porta|listen|bind|server\.port|http\.port)\s*[:=]?\s*[""' ]*$SearchPort[""' ]*(?!\d)" }
$RegexIP   = if ($SearchIP)   { "(?i)\b$([regex]::Escape($SearchIP))\b" }
$RegexKey  = if ($SearchKey)  { "(?i)\b$([regex]::Escape($SearchKey))\b" }

$ActiveRules = @($RegexPort,$RegexIP,$RegexKey) | Where-Object { $_ }

if ($ActiveRules.Count -eq 0) {
    Write-Host "❌ Nenhum critério definido" -ForegroundColor Red
    exit
}

# ================= EXECUÇÃO =================

Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host " 🔎 BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""
if ($SearchPort) { Write-Host " 🟦 Porta : $SearchPort" -ForegroundColor Yellow }
if ($SearchIP)   { Write-Host " 🟨 IP    : $SearchIP" -ForegroundColor Green }
if ($SearchKey)  { Write-Host " 🟩 Chave : $SearchKey" -ForegroundColor Cyan }
Write-Host " 📂 Diretório: $BasePath" -ForegroundColor DarkGray
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

Get-ChildItem $BasePath -Recurse -File -Include $Extensions -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        # 🔒 tenta ler como texto real
        $Content = Get-Content $_.FullName -Encoding UTF8 -ErrorAction Stop
    } catch {
        return
    }

    # 🧠 valida TODAS as regras no mesmo arquivo
    foreach ($Rule in $ActiveRules) {
        if (-not ($Content -match $Rule)) {
            return
        }
    }

    Write-Host "📁 Pasta   :" -NoNewline -ForegroundColor DarkGray
    Write-Host " $($_.DirectoryName)" -ForegroundColor Gray

    Write-Host "📄 Arquivo :" -NoNewline -ForegroundColor DarkGray
    Write-Host " $($_.Name)" -ForegroundColor Cyan

    $LineNumber = 0
    foreach ($Line in $Content) {
        $LineNumber++

        if (
            ($RegexPort -and $Line -match $RegexPort) -or
            ($RegexIP   -and $Line -match $RegexIP)   -or
            ($RegexKey  -and $Line -match $RegexKey)
        ) {
            $Out = $Line.Trim()
            if ($Out.Length -gt $SnippetSize) { $Out = $Out.Substring(0,$SnippetSize)+"..." }

            Write-Host "🔢 Linha $LineNumber :" -ForegroundColor DarkGray
            Write-Host "   $Out" -ForegroundColor White
        }
    }

    Write-Host "──────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host ""
Write-Host "✅ Busca concluída com correlação total de critérios" -ForegroundColor Green
Write-Host ""
Pause
