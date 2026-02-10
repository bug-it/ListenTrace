Clear-Host

# ================= CONFIGURAÇÕES =================
$Porta       = ""
$IPDNSRegex  = "127.0.0.1"
$ChavesRaw   = ""
$Diretorio   = "C:\Windows"

$MaxLinhasConteudo = 5
# =================================================

# ================= PREPARO =================
$Chaves = @()
if ($ChavesRaw -ne "") {
    $Chaves = $ChavesRaw.Split(",") | ForEach-Object { $_.Trim() }
}

$PortaOut = "-"
if ($Porta -ne "") { $PortaOut = $Porta }

$IPDNSOut = "-"
if ($IPDNSRegex -ne "") { $IPDNSOut = ($IPDNSRegex -replace '\\','') }

$ChavesOut = "-"
if ($ChavesRaw -ne "") { $ChavesOut = $ChavesRaw }

function Is-BinaryFile {
    param($Path)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)[0..200]
        foreach ($b in $bytes) {
            if ($b -eq 0) { return $true }
        }
        return $false
    } catch { return $true }
}

# ================= HEADER =================
Write-Host ""
Write-Host "┌──────────────────────────────┐" -ForegroundColor Cyan
Write-Host "│   ListenTrace :: Auditoria   │" -ForegroundColor Cyan
Write-Host "│ Blue Team | DFIR | Hardening │" -ForegroundColor DarkGray
Write-Host "└──────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] BUSCADOR ATIVO" -ForegroundColor Yellow
Write-Host "─────────────────────────────────" -ForegroundColor DarkGray
Write-Host " ▸ Porta    : $PortaOut" -ForegroundColor White
Write-Host " ▸ IP / DNS : $IPDNSOut" -ForegroundColor White
Write-Host " ▸ Chaves   : $ChavesOut" -ForegroundColor White
Write-Host " ▸ Diretório: $Diretorio" -ForegroundColor Green
Write-Host ""

# ================= BUSCA =================
$Arquivos = Get-ChildItem -Path $Diretorio -Recurse -File -Force -ErrorAction SilentlyContinue
$Hits = 0

foreach ($Arquivo in $Arquivos) {

    if (Is-BinaryFile $Arquivo.FullName) { continue }

    try {
        $Linhas = Get-Content $Arquivo.FullName -ErrorAction Stop
    } catch { continue }

    for ($i = 0; $i -lt $Linhas.Count; $i++) {

        $Linha = $Linhas[$i]
        if ($Linha.Length -gt 300) { continue }

        $Match = $false

        if ($Porta -ne "" -and $Linha -match "(^|\D)$Porta(\D|$)") {
            $Match = $true
        }

        if ($IPDNSRegex -ne "" -and $Linha -match $IPDNSRegex) {
            $Match = $true
        }

        foreach ($c in $Chaves) {
            if ($Linha -match [regex]::Escape($c)) {
                $Match = $true
                break
            }
        }

        if (-not $Match) { continue }

        $start = [Math]::Max(0, $i - 2)
        $end   = [Math]::Min($Linhas.Count - 1, $i + 2)

        Write-Host "─────────────────────────────────" -ForegroundColor DarkGray
        Write-Host " 📄 Arquivo : $($Arquivo.FullName)" -ForegroundColor Cyan
        Write-Host " 🔢 Linha   : $($i + 1)" -ForegroundColor Yellow
        Write-Host " ─ Conteúdo:" -ForegroundColor Gray

        for ($x = $start; $x -le $end; $x++) {
            $out = $Linhas[$x] -replace '[^\x20-\x7E]', ''
            Write-Host "   $out" -ForegroundColor DarkGray
        }

        $Hits++
        break
    }
}

Write-Host ""
Write-Host "─────────────────────────────────" -ForegroundColor DarkGray
Write-Host " ✔ Evidências encontradas: $Hits" -ForegroundColor Cyan
Write-Host ""
