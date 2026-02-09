# ================================
# ListenTrace - Auditoria Correlacionada
# ================================

Clear-Host

# ================================
# BANNER
# ================================
Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host "+  ListenTrace - Auditoria Correlacionada  +" -ForegroundColor Yellow
Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host ""

# ================================
# 🔧 CRITÉRIOS ("" ou $null para ignorar)
# ================================
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

$RootPath   = "C:\Windows"

# Extensões de texto permitidas
$TextExtensions = @(
    ".txt",".log",".conf",".cfg",".ini",".xml",
    ".json",".yaml",".yml",".ps1",".psm1"
)

# ================================
# STATUS ATIVO
# ================================
Write-Host "🔎 BUSCADOR ATIVO" -ForegroundColor Cyan
Write-Host ""
Write-Host "🟦 Porta : $SearchPort" -ForegroundColor Blue
Write-Host "🟨 IP    : $SearchIP"   -ForegroundColor Yellow
Write-Host "🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Green
Write-Host "📂 Diretório: $RootPath"
Write-Host "==================================================" -ForegroundColor DarkGray
Write-Host ""

# ================================
# FUNÇÃO PRINCIPAL
# ================================
function Buscar-Ativos {
    param (
        [string]$Arquivo
    )

    $LinhaNumero = 0

    Get-Content -LiteralPath $Arquivo -ErrorAction SilentlyContinue | ForEach-Object {

        $LinhaNumero++
        $Linha = $_
        $Encontrou = $false
        $TipoMatch = ""

        if ($SearchPort -and $Linha -match "(?<!\d)$SearchPort(?!\d)") {
            $Encontrou = $true
            $TipoMatch = "Porta ($SearchPort)"
        }

        if (-not $Encontrou -and $SearchIP -and $Linha -match [regex]::Escape($SearchIP)) {
            $Encontrou = $true
            $TipoMatch = "IP ($SearchIP)"
        }

        if (-not $Encontrou) {
            foreach ($Key in $SearchKey) {
                if ($Linha -match "(?i)\b$Key\b") {
                    $Encontrou = $true
                    $TipoMatch = "Chave ($Key)"
                    break
                }
            }
        }

        if ($Encontrou) {
            Write-Host "🔢 Linha $LinhaNumero :" -ForegroundColor Magenta
            Write-Host "   $Linha"
            Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
            Write-Host "🧷 ATIVO   : $TipoMatch" -ForegroundColor Green
            Write-Host ""
        }
    }
}

# ================================
# VARREDURA
# ================================
Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue |
Where-Object {
    $TextExtensions -contains $_.Extension.ToLower()
} |
ForEach-Object {

    Write-Host "📁 Pasta   : $($_.DirectoryName)" -ForegroundColor Cyan
    Write-Host "📄 Arquivo : $($_.Name)" -ForegroundColor White
    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

    Buscar-Ativos -Arquivo $_.FullName
}

# ================================
# FINALIZAÇÃO
# ================================
Write-Host ""
Write-Host "✅ Varredura finalizada com sucesso." -ForegroundColor Green
