Clear-Host
$Host.UI.RawUI.WindowTitle = "ListentTrace :: Auditoria / Monitoramento"

# ================= CORES =================
$CorTitulo    = "Cyan"
$CorValor     = "White"
$CorSeparador = "DarkGray"
$CorAtivo     = "Yellow"
$CorConteudo  = "Gray"

# ================= TOPO =================
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor $CorTitulo
Write-Host "║          BUSCADOR ATIVO - LISTENTRACE                ║" -ForegroundColor $CorTitulo
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor $CorTitulo
Write-Host ""

# ================= PALAVRAS =================
$PALAVRAS = @(
    "Kwmip2@24",
    "Kwmip2@25",
    "Kwmip2@26",
    "joao.unterckircher@gmail.com",
    "316459658880",
    "316.459.658-80"
)

Write-Host "▸ Palavra  : " -NoNewline -ForegroundColor $CorValor
for ($i = 0; $i -lt $PALAVRAS.Count; $i++) {
    Write-Host $PALAVRAS[$i] -NoNewline -ForegroundColor $CorAtivo
    if ($i -lt ($PALAVRAS.Count - 1)) {
        Write-Host " | " -NoNewline -ForegroundColor $CorValor
    }
}
Write-Host "`n"

# ================= CONFIG =================
$Diretorios = @("C:\")
$ExtensoesTexto = "*.*"
$MaxPorArquivo = 5
$MaxFileSizeMB = 10

# ================= RELATÓRIO HTML (CRIADO NO START) =================
$DataExecucao = Get-Date
$RelatorioPath = "$PSScriptRoot\Relatorio_ListentTrace_$($DataExecucao.ToString("yyyyMMdd_HHmmss")).html"

@"
<html>
<head>
<meta charset="UTF-8">
<title>Relatório ListentTrace</title>
<style>
body { font-family: Consolas, monospace; background:#0e0e0e; color:#eee; }
h2 { color:#00ffff; }
small { color:#aaa; }
table { width:100%; border-collapse:collapse; margin-top:15px; }
th, td { border:1px solid #333; padding:8px; vertical-align:top; }
th { background:#1f1f1f; }
tr:nth-child(even){ background:#151515; }
mark { background:#ffd700; color:#000; font-weight:bold; }
pre { white-space:pre-wrap; word-break:break-word; margin:0; }
</style>
</head>
<body>
<h2>Relatório ListentTrace</h2>
<small>Execução: $($DataExecucao.ToString("dd/MM/yyyy HH:mm:ss"))</small>
<table>
<tr>
<th>Pasta</th>
<th>Arquivo</th>
<th>Linha</th>
<th>Conteúdo</th>
</tr>
"@ | Out-File -Encoding UTF8 $RelatorioPath

# ================= FUNÇÕES =================
function Write-Separador {
    Write-Host "----------------------------------------------------------------------------------------------" -ForegroundColor $CorSeparador
}

function Write-ConteudoColorido {
    param ($Texto, $Palavras)

    $pos = 0
    $regex = ($Palavras | ForEach-Object { [regex]::Escape($_) }) -join "|"
    $matches = [regex]::Matches($Texto, $regex, "IgnoreCase")

    foreach ($m in $matches) {
        if ($m.Index -gt $pos) {
            Write-Host ($Texto.Substring($pos, $m.Index - $pos)) -NoNewline -ForegroundColor $CorConteudo
        }
        Write-Host ($Texto.Substring($m.Index, $m.Length)) -NoNewline -ForegroundColor $CorAtivo
        $pos = $m.Index + $m.Length
    }

    if ($pos -lt $Texto.Length) {
        Write-Host ($Texto.Substring($pos)) -ForegroundColor $CorConteudo
    } else {
        Write-Host ""
    }
}

# ================= EXECUÇÃO =================
foreach ($Dir in $Diretorios) {

    if (!(Test-Path $Dir)) { continue }

    Write-Host "📂 Analisando diretório: $Dir" -ForegroundColor DarkCyan

    Get-ChildItem -Path $Dir -Recurse -File -Include $ExtensoesTexto -ErrorAction SilentlyContinue |
    Where-Object { ($_.Length / 1MB) -le $MaxFileSizeMB } |
    ForEach-Object {

        $Arquivo = $_
        $EncontrouArquivo = $false
        $TotalEncontrado = 0

        try { $Linhas = Get-Content $Arquivo.FullName } catch { return }

        for ($i = 0; $i -lt $Linhas.Count; $i++) {
            foreach ($P in $PALAVRAS) {
                if ($Linhas[$i] -match [regex]::Escape($P)) {

                    if (-not $EncontrouArquivo) {
                        Write-Separador
                        Write-Host "📁 Pasta   : $($Arquivo.DirectoryName)"
                        Write-Host "📄 Arquivo : $($Arquivo.Name)"
                        Write-Separador
                        $EncontrouArquivo = $true
                    }

                    if ($TotalEncontrado -ge $MaxPorArquivo) { break }

                    Write-Host "🔢 Linha   : $($i + 1)"
                    Write-Host "📌 Conteúdo:"
                    Write-Host "     " -NoNewline
                    Write-ConteudoColorido -Texto $Linhas[$i] -Palavras $PALAVRAS
                    Write-Host ""

                    $ConteudoHtml = [System.Net.WebUtility]::HtmlEncode($Linhas[$i])
                    foreach ($P2 in $PALAVRAS) {
                        $ConteudoHtml = $ConteudoHtml -replace [regex]::Escape($P2), "<mark>$P2</mark>"
                    }

                    "<tr>
<td>$($Arquivo.DirectoryName)</td>
<td>$($Arquivo.Name)</td>
<td>$($i + 1)</td>
<td><pre>$ConteudoHtml</pre></td>
</tr>" | Out-File -Append -Encoding UTF8 $RelatorioPath

                    $TotalEncontrado++
                }
            }
        }
    }
}

# ================= FECHAR HTML =================
"</table></body></html>" | Out-File -Append -Encoding UTF8 $RelatorioPath

# ================= FINAL =================
Write-Host ""
Write-Host "Relatório atualizado em tempo real:" -ForegroundColor Green
Write-Host $RelatorioPath -ForegroundColor Yellow
Write-Host "Pressione ENTER para sair..." -ForegroundColor Yellow
Read-Host
