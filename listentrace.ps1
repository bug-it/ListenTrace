# ================================
# Banner
# ================================
Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host "+  ListenTrace - Auditoria Correlacionada  +" -ForegroundColor Yellow
Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host ""

# ================================
# Configuracoes de Busca
# ================================
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("Porta","Port","Listen")

$DiretorioBase = "C:\Windows"

$ExtensoesTexto = @(
    ".txt",".log",".conf",".cfg",".ini",
    ".xml",".json",".yaml",".yml",
    ".ps1",".psm1"
)

# ================================
# Status Ativo
# ================================
Write-Host "🔎 BUSCADOR ATIVO" -ForegroundColor Cyan
Write-Host ""
Write-Host "🟦 Porta : $SearchPort" -ForegroundColor Blue
Write-Host "🟨 IP    : $SearchIP" -ForegroundColor Yellow
Write-Host "🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Green
Write-Host "📂 Diretório: $DiretorioBase"
Write-Host "==================================================" -ForegroundColor DarkGray
Write-Host ""

# ================================
# Varredura de Arquivos
# ================================
Get-ChildItem -Path $DiretorioBase -Recurse -File -ErrorAction SilentlyContinue |
Where-Object {
    $ExtensoesTexto -contains $_.Extension.ToLower()
} |
ForEach-Object {

    $arquivo = $_.FullName
    $linhaNum = 0

    Write-Host "📁 Pasta   : $($_.DirectoryName)" -ForegroundColor Cyan
    Write-Host "📄 Arquivo : $($_.Name)" -ForegroundColor White
    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

    Get-Content $arquivo -ErrorAction SilentlyContinue | ForEach-Object {

        $linhaNum++
        $linha = $_
        $achou = $false
        $tipo  = ""

        if ($SearchPort -and $linha -match $SearchPort) {
            $achou = $true
            $tipo  = "Porta ($SearchPort)"
        }

        if (-not $achou -and $SearchIP -and $linha -match $SearchIP) {
            $achou = $true
            $tipo  = "IP ($SearchIP)"
        }

        if (-not $achou) {
            foreach ($chave in $SearchKey) {
                if ($linha -match $chave) {
                    $achou = $true
                    $tipo  = "Chave ($chave)"
                    break
                }
            }
        }

        if ($achou) {
            Write-Host "🔢 Linha $linhaNum :" -ForegroundColor Magenta
            Write-Host "   $linha"
            Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
            Write-Host "🧷 ATIVO   : $tipo" -ForegroundColor Green
            Write-Host ""
        }
    }
}

# ================================
# Finalizacao
# ================================
Write-Host ""
Write-Host "+==========================================+" -ForegroundColor Green
Write-Host "+      Varredura finalizada com sucesso    +" -ForegroundColor Green
Write-Host "+==========================================+" -ForegroundColor Green
Write-Host ""

pause
