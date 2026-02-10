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
    "127.0.0.1"
)

Write-Host "▸ Palavra  : " -NoNewline -ForegroundColor $CorValor
for ($i = 0; $i -lt $PALAVRAS.Count; $i++) {
    Write-Host $PALAVRAS[$i] -NoNewline -ForegroundColor $CorAtivo
    if ($i -lt ($PALAVRAS.Count - 1)) {
        Write-Host " | " -NoNewline -ForegroundColor $CorValor
    }
}
Write-Host ""
Write-Host ""

# ================= CONFIG =================
$Diretorios = @("C:\")
$ExtensoesTexto = "*.*"

$Contexto      = 80
$MaxPorArquivo = 5
$MaxFileSizeMB = 10

# ================= RELATÓRIO HTML (ADICIONADO) =================
$Relatorio = @()
$RelatorioPath = "$PSScriptRoot\Relatorio_ListentTrace.html"

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

    Write-Host ""
    Write-Host "📂 Analisando diretório: $Dir" -ForegroundColor DarkCyan

    Get-ChildItem -Path $Dir -Recurse -File -Include $ExtensoesTexto -ErrorAction SilentlyContinue |
    Where-Object { ($_.Length / 1MB) -le $MaxFileSizeMB } |
    ForEach-Object {

        $Arquivo = $_
        $EncontrouArquivo = $false
        $TotalEncontrado = 0

        try {
            $Linhas = Get-Content $Arquivo.FullName -ErrorAction Stop
        } catch {
            return
        }

        for ($i = 0; $i -lt $Linhas.Count; $i++) {

            $Encontradas = @()
            foreach ($P in $PALAVRAS) {
                if ($Linhas[$i] -match [regex]::Escape($P)) {
                    $Encontradas += $P
                }
            }

            if ($Encontradas.Count -gt 0) {

                if (-not $EncontrouArquivo) {
                    Write-Separador
                    Write-Host "📁 Pasta   : $($Arquivo.DirectoryName)"
                    Write-Host "📄 Arquivo : $($Arquivo.Name)"
                    Write-Separador
                    $EncontrouArquivo = $true
                }

                if ($TotalEncontrado -ge $MaxPorArquivo) { break }

                $LinhaOriginal = $Linhas[$i]
                $Indice = $LinhaOriginal.ToLower().IndexOf($Encontradas[0].ToLower())

                if ($Indice -ge 0) {
                    $Inicio = [Math]::Max(0, $Indice - $Contexto)
                    $Fim    = [Math]::Min($LinhaOriginal.Length, $Indice + $Encontradas[0].Length + $Contexto)

                    $Linha = $LinhaOriginal.Substring($Inicio, $Fim - $Inicio)
                    if ($Inicio -gt 0) { $Linha = "..." + $Linha }
                    if ($Fim -lt $LinhaOriginal.Length) { $Linha = $Linha + "..." }
                } else {
                    $Linha = $LinhaOriginal
                }

                Write-Host "🔢 Linha   : $($i + 1)"
                Write-Host "📌 Conteúdo:"
                Write-Host "     " -NoNewline
                Write-ConteudoColorido -Texto $Linha -Palavras $PALAVRAS
                Write-Host ""

                # ======= ADICIONADO: COLETA PARA HTML (SEM ALTERAR TEXTO) =======
                $Relatorio += [PSCustomObject]@{
                    Pasta   = $Arquivo.DirectoryName
                    Arquivo = $Arquivo.Name
                    Linha   = ($i + 1)
                    Conteudo = $LinhaOriginal
                }

                $TotalEncontrado++
            }
        }
    }
}

# ================= GERAR HTML (ADICIONADO) =================
$Html = @"
<html>
<head>
<meta charset="UTF-8">
<title>Relatório ListentTrace</title>
<style>
body { font-family: Consolas, monospace; background:#111; color:#eee; }
table { width:100%; border-collapse:collapse; }
th, td { border:1px solid #444; padding:6px; vertical-align:top; }
th { background:#222; }
tr:nth-child(even){ background:#1a1a1a; }
</style>
</head>
<body>
<h2>Relatório ListentTrace</h2>
<table>
<tr>
<th>Pasta</th>
<th>Arquivo</th>
<th>Linha</th>
<th>Conteúdo</th>
</tr>
"@

foreach ($R in $Relatorio) {
    $Html += "<tr><td>$($R.Pasta)</td><td>$($R.Arquivo)</td><td>$($R.Linha)</td><td><pre>$($R.Conteudo)</pre></td></tr>"
}

$Html += "</table></body></html>"
$Html | Out-File -Encoding UTF8 $RelatorioPath

# ================= PAUSE (ADICIONADO) =================
Write-Host ""
Write-Host "Relatório gerado em: $RelatorioPath" -ForegroundColor Green
Write-Host "Pressione ENTER para sair..." -ForegroundColor Yellow
Read-Host
