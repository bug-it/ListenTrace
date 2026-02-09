Clear-Host

# ================= BANNER =================
Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host "+  ListenTrace - Auditoria Correlacionada  +" -ForegroundColor Yellow
Write-Host "+==========================================+" -ForegroundColor Yellow
Write-Host ""

# ================= CONFIG =================
$Porta     = 443
$IP        = "127.0.0.1"
$Chaves    = @("Port", "Porta", "Listen")
$Diretorio = "C:\Windows"

# ================= HEADER =================
Write-Host "🔎 BUSCADOR ATIVO" -ForegroundColor Cyan
Write-Host ""
Write-Host "🟦 Porta : $Porta" -ForegroundColor Blue
Write-Host "🟨 IP    : $IP" -ForegroundColor Yellow
Write-Host "🟩 Chave : $($Chaves -join ', ')" -ForegroundColor Green
Write-Host "📂 Diretório: $Diretorio" -ForegroundColor Magenta
Write-Host "=================================================="
Write-Host ""

# ================= FUNÇÃO =================
function Buscar-Chaves {
    param (
        [string]$Arquivo
    )

    $linhaNum = 0

    Get-Content $Arquivo -ErrorAction SilentlyContinue | ForEach-Object {
        $linhaNum++
        foreach ($chave in $Chaves) {
            if ($_ -match $chave) {
                Write-Host "🔢 Linha $linhaNum :" -ForegroundColor Cyan
                Write-Host " $_" -ForegroundColor White
                Write-Host "🧷 ATIVO   : Chave ($chave)" -ForegroundColor Green
                Write-Host "--------------------------------------------------"
            }
        }
    }
}

# ================= EXECUÇÃO =================
Get-ChildItem -Path $Diretorio -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {
    Buscar-Chaves $_.FullName
}

Write-Host ""
Write-Host "✅ Varredura finalizada." -ForegroundColor Green
