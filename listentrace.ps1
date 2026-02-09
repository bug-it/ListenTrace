Clear-Host

Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host "+  ListenTrace - Auditoria Correlacionada  +" -ForegroundColor Yellow
Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host ""

# ================= CONFIGURAÇÕES =================

# 🔧 Critérios ("" ou $null para ignorar)
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

$BasePath = "C:\Windows"

# 📄 Somente arquivos de texto
$Extensions = @(
    "*.conf","*.cfg","*.ini","*.json","*.yaml","*.yml",
    "*.xml","*.env","*.log","*.txt","*.ps1","*.py","*.js"
)

$SnippetSize = 160

# ================= REGEX =================

$RegexPort = if ($SearchPort) {
    "(?i)\b$([regex]::Escape($SearchPort))\b"
}

$RegexIP = if ($SearchIP) {
    "(?i)\b$([regex]::Escape($SearchIP))\b"
}

$RegexKey = if ($SearchKey -and $SearchKey.Count -gt 0) {
    "(?i)\b(" + ($SearchKey | ForEach-Object { [regex]::Escape($_) }) -join "|" + ")\b"
}

$ActiveRules = @($RegexPort,$RegexIP,$RegexKey) | Where-Object { $_ }

if ($ActiveRules.Count -eq 0) {
    Write-Host "Nenhum critério definido." -ForegroundColor Red
    Pause
    exit
}

# ================= CABEÇALHO =================

Write-Host ""
Write-Host "🔎 BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""
if ($SearchPort) { Write-Host "🟦 Porta : $SearchPort" -ForegroundColor Yellow }
if ($SearchIP)   { Write-Host "🟨 IP    : $SearchIP"   -ForegroundColor Green }
if ($SearchKey)  { Write-Host "🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Cyan }
Write-Host "📂 Diretório: $BasePath" -ForegroundColor DarkGray
Write-Host "==================================================" -ForegroundColor DarkGray
Write-Host ""

# ================= EXECUÇÃO =================

Get-ChildItem -Path $BasePath -Recurse -File -Include $Extensions -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        $Content = Get-Content $_.FullName -Encoding UTF8 -ErrorAction Stop
    } catch {
        return
    }

    # valida correlação (TODOS os critérios no mesmo arquivo)
    foreach ($Rule in $ActiveRules) {
        if (-not ($Content -match $Rule)) {
            return
        }
    }

    Write-Host "📁 Pasta   : $($_.DirectoryName)" -ForegroundColor Gray
    Write-Host "📄 Arquivo : $($_.Name)" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

    $LineNumber = 0

    foreach ($Line in $Content) {
        $LineNumber++

        $MatchPort = $RegexPort -and ($Line -match $RegexPort)
        $MatchIP   = $RegexIP   -and ($Line -match $RegexIP)
        $MatchKey  = $RegexKey  -and ($Line -match $RegexKey)

        if ($MatchPort -or $MatchIP -or $MatchKey) {

            $Out = $Line.Trim()
            if ($Out.Length -gt $SnippetSize) {
                $Out = $Out.Substring(0,$SnippetSize) + "..."
            }

            Write-Host "🔢 Linha $LineNumber :" -ForegroundColor DarkGray
            Write-Host "   $Out" -ForegroundColor White

            if ($MatchPort) { Write-Host "🧷 ATIVO   : Porta ($SearchPort)" -ForegroundColor Yellow }
            if ($MatchIP)   { Write-Host "🧷 ATIVO   : IP ($SearchIP)"     -ForegroundColor Green }
            if ($MatchKey)  { Write-Host "🧷 ATIVO   : Chave ($($Matches[0]))" -ForegroundColor Cyan }

            Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
}

Write-Host "Varredura finalizada com sucesso." -ForegroundColor Green
Write-Host ""
Pause
