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

# 🔧 Critérios ("" ou $null = ignora)
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

$BasePath = "C:\Windows"
$Extensions = @(
    "*.conf","*.cfg","*.ini","*.json","*.yaml","*.yml",
    "*.xml","*.env","*.log","*.py","*.js","*.ps1"
)

$SnippetSize = 160

# ================= REGEX =================

# 🔑 Palavras-chave
$RegexKey = $null
$RegexPort = $null
$RegexIP = $null

if ($SearchKey -and $SearchKey.Count -gt 0) {
    $KeysEscaped = $SearchKey | ForEach-Object { [regex]::Escape($_) }
    $KeysPattern = ($KeysEscaped -join "|")
    $RegexKey = "(?i)\b($KeysPattern)\b"
}

# 🔢 Porta vinculada às palavras-chave
if ($SearchPort -and $RegexKey) {
    $RegexPort = "(?i)\b($KeysPattern)\b\s*[:=]?\s*[""' ]*$SearchPort[""' ]*(?!\d)"
}

# 🌐 IP
if ($SearchIP) {
    $RegexIP = "(?i)\b$([regex]::Escape($SearchIP))\b"
}

# 🔒 Regras ativas
$ActiveRules = @($RegexKey,$RegexPort,$RegexIP) | Where-Object { $_ }

if ($ActiveRules.Count -eq 0) {
    Write-Host "❌ Nenhum critério definido" -ForegroundColor Red
    Pause
    exit
}

# ================= HEADER =================

Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host " 🔎 BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""

if ($SearchPort) { Write-Host " 🟦 Porta : $SearchPort" -ForegroundColor Yellow }
if ($SearchIP)   { Write-Host " 🟨 IP    : $SearchIP" -ForegroundColor Green }
if ($SearchKey)  { Write-Host " 🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Cyan }

Write-Host " 📂 Diretório: $BasePath" -ForegroundColor DarkGray
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

# ================= EXECUÇÃO =================

Get-ChildItem $BasePath -Recurse -File -Include $Extensions -ErrorAction SilentlyContinue |
ForEach-Object {

    # evita arquivos grandes/binários
    if ($_.Length -gt 5MB) { return }

    try {
        $Content = Get-Content $_.FullName -Encoding UTF8 -ErrorAction Stop
    } catch {
        return
    }

    # exige TODAS as regras no mesmo arquivo
    foreach ($Rule in $ActiveRules) {
        if (-not ($Content -match $Rule)) { return }
    }

    Write-Host "📁 Pasta   :" -NoNewline -ForegroundColor DarkGray
    Write-Host " $($_.DirectoryName)" -ForegroundColor Gray

    Write-Host "📄 Arquivo :" -NoNewline -ForegroundColor DarkGray
    Write-Host " $($_.Name)" -ForegroundColor Cyan

    $LineNumber = 0
    foreach ($Line in $Content) {
        $LineNumber++

        if (
            ($RegexKey  -and $Line -match $RegexKey)  -or
            ($RegexPort -and $Line -match $RegexPort) -or
            ($RegexIP   -and $Line -match $RegexIP)
        ) {
            $Out = $Line.Trim()
            if ($Out.Length -gt $SnippetSize) {
                $Out = $Out.Substring(0,$SnippetSize) + "..."
            }

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
