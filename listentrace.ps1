Clear-Host

# ================= ASCII =================
Write-Host @"
 _      _     _          _______
| |    (_)   | |        |__   __|
| |     _ ___| |_ ___ _ __ | |_ __ __ _  ___ ___
| |    | / __| __/ _ \ '_ \| | '__/ _ |/ __/ _ \
| |____| \__ \ |_  __/ | | | | | | (_| | (__  __/
|______|_|___/\__\___|_| |_|_|_|  \__,_|\___\___|
ListenTrace - Auditoria Correlacionada
==================================================
"@ -ForegroundColor Cyan

# ================= CONFIGURAÇÕES =================

# 🔧 Critérios ("" ou $null para ignorar)
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

$BasePath = "C:\Windows"
$Extensions = @(
    "*.conf","*.cfg","*.ini","*.json","*.yaml","*.yml",
    "*.xml","*.env","*.log","*.py","*.js","*.txt"
)

$SnippetSize = 160

# ================= REGEX =================

$RegexRules = @()

if ($SearchPort) {
    $RegexRules += @{
        Name  = "Porta"
        Regex = "(?i)\b$([regex]::Escape($SearchPort))\b"
    }
}

if ($SearchIP) {
    $RegexRules += @{
        Name  = "IP"
        Regex = "(?i)\b$([regex]::Escape($SearchIP))\b"
    }
}

if ($SearchKey -and $SearchKey.Count -gt 0) {
    $Keys = ($SearchKey | ForEach-Object { [regex]::Escape($_) }) -join "|"
    $RegexRules += @{
        Name  = "Chave"
        Regex = "(?i)\b($Keys)\b"
    }
}

if ($RegexRules.Count -eq 0) {
    Write-Host "❌ Nenhum critério definido" -ForegroundColor Red
    Pause
    exit
}

# ================= HEADER =================

Write-Host ""
Write-Host "🔎 BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""
if ($SearchPort) { Write-Host "🟦 Porta : $SearchPort" -ForegroundColor Yellow }
if ($SearchIP)   { Write-Host "🟨 IP    : $SearchIP" -ForegroundColor Green }
if ($SearchKey)  { Write-Host "🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Cyan }
Write-Host "📂 Diretório: $BasePath"
Write-Host "=================================================="
Write-Host ""

# ================= EXECUÇÃO =================

Get-ChildItem $BasePath -Recurse -File -Include $Extensions -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        $Content = Get-Content $_.FullName -Encoding UTF8 -ErrorAction Stop
    } catch {
        return
    }

    # 🔎 valida correlação (todas regras no mesmo arquivo)
    foreach ($Rule in $RegexRules) {
        if (-not ($Content -match $Rule.Regex)) {
            return
        }
    }

    Write-Host "📁 Pasta   : $($_.DirectoryName)" -ForegroundColor DarkGray
    Write-Host "📄 Arquivo : $($_.Name)" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------"

    $LineNumber = 0
    foreach ($Line in $Content) {
        $LineNumber++

        foreach ($Rule in $RegexRules) {
            if ($Line -match $Rule.Regex) {

                $Out = $Line.Trim()
                if ($Out.Length -gt $SnippetSize) {
                    $Out = $Out.Substring(0,$SnippetSize) + "..."
                }

                Write-Host "🔢 Linha $LineNumber :" -ForegroundColor DarkGray
                Write-Host "   $Out" -ForegroundColor White
                Write-Host "🧷 ATIVO   : $($Rule.Name)" -ForegroundColor Yellow
                Write-Host "--------------------------------------------------"
            }
        }
    }

    Write-Host ""
}

Write-Host "✅ Varredura finalizada com sucesso." -ForegroundColor Green
Write-Host ""
Pause
