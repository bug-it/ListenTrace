Clear-Host

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

$Rules = @()

if ($SearchPort) {
    $Rules += @{ Tipo="Porta"; Regex="(?i)\b$([regex]::Escape($SearchPort))\b" }
}

if ($SearchIP) {
    $Rules += @{ Tipo="IP"; Regex="(?i)\b$([regex]::Escape($SearchIP))\b" }
}

if ($SearchKey.Count -gt 0) {
    $Keys = ($SearchKey | ForEach-Object { [regex]::Escape($_) }) -join "|"
    $Rules += @{ Tipo="Chave"; Regex="(?i)\b($Keys)\b" }
}

# ================= HEADER =================

Write-Host ""
Write-Host "🔎 BUSCADOR ATIVO"
Write-Host ""
Write-Host "🟦 Porta : $SearchPort" -ForegroundColor Yellow
Write-Host "🟨 IP    : $SearchIP"   -ForegroundColor Green
Write-Host "🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Cyan
Write-Host "📂 Diretório: $BasePath"
Write-Host "=================================================="
Write-Host ""

# ================= EXECUÇÃO =================

Get-ChildItem $BasePath -Recurse -File -Include $Extensions -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        $Lines = Get-Content $_.FullName -Encoding UTF8 -ErrorAction Stop
    } catch {
        return
    }

    # 🔒 correlação: todas regras precisam existir no arquivo
    foreach ($Rule in $Rules) {
        if (-not ($Lines -match $Rule.Regex)) {
            return
        }
    }

    Write-Host "📁 Pasta   : $($_.DirectoryName)" -ForegroundColor DarkGray
    Write-Host "📄 Arquivo : $($_.Name)" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------"

    for ($i = 0; $i -lt $Lines.Count; $i++) {

        foreach ($Rule in $Rules) {

            if ($Lines[$i] -match $Rule.Regex) {

                $Out = $Lines[$i].Trim()
                if ($Out.Length -gt $SnippetSize) {
                    $Out = $Out.Substring(0,$SnippetSize) + "..."
                }

                Write-Host "🔢 Linha $($i + 1) :" -ForegroundColor DarkGray
                Write-Host "   $Out" -ForegroundColor White
                Write-Host "🧷 ATIVO   : $($Rule.Tipo)" -ForegroundColor Yellow
                Write-Host "--------------------------------------------------"
            }
        }
    }

    Write-Host ""
}

Write-Host "✅ Varredura finalizada com sucesso." -ForegroundColor Green
Write-Host ""
Pause
