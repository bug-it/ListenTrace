Clear-Host
$Host.UI.RawUI.WindowTitle = "ListentTrace :: Auditoria / Monitoramento"

# ================= CORES =================
$CorTitulo    = "Cyan"
$CorValor     = "White"
$CorSeparador = "Yellow"
$CorSenha     = "Red"
$CorConteudo  = "Gray"
$CorDestaque  = "Yellow"
$CorSub       = "Gray"
$CorLinha     = "DarkGray"

# ===== INFORMAÇÕES DINÂMICAS =====
$DataHora   = (Get-Date -Format "dd/MM/yyyy HH:mm:ss")
$Usuario    = $env:USERNAME
$Maquina    = $env:COMPUTERNAME
$VersaoPS   = $PSVersionTable.PSVersion.ToString()

Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor $CorLinha
Write-Host "║                                                                         ║" -ForegroundColor $CorLinha
Write-Host "║             ██╗     ██╗███████╗████████╗███████╗███╗   ██╗              ║" -ForegroundColor $CorTitulo
Write-Host "║             ██║     ██║██╔════╝╚══██╔══╝██╔════╝████╗  ██║              ║" -ForegroundColor $CorTitulo
Write-Host "║             ██║     ██║███████╗   ██║   █████╗  ██╔██╗ ██║              ║" -ForegroundColor $CorTitulo
Write-Host "║             ██║     ██║╚════██║   ██║   ██╔══╝  ██║╚██╗██║              ║" -ForegroundColor $CorTitulo
Write-Host "║             ███████╗██║███████║   ██║   ███████╗██║ ╚████║              ║" -ForegroundColor $CorTitulo
Write-Host "║             ╚══════╝╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝              ║" -ForegroundColor $CorTitulo
Write-Host "║                                                                         ║" -ForegroundColor $CorLinha
Write-Host "║                ████████╗██████╗  █████╗  ██████╗███████╗                ║" -ForegroundColor $CorTitulo
Write-Host "║                ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝                ║" -ForegroundColor $CorTitulo
Write-Host "║                   ██║   ██████╔╝███████║██║     █████╗                  ║" -ForegroundColor $CorTitulo
Write-Host "║                   ██║   ██╔══██╗██╔══██║██║     ██╔══╝                  ║" -ForegroundColor $CorTitulo
Write-Host "║                   ██║   ██║  ██║██║  ██║╚██████╗███████╗                ║" -ForegroundColor $CorTitulo
Write-Host "║                   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝                ║" -ForegroundColor $CorTitulo
Write-Host "║                                                                         ║" -ForegroundColor $CorLinha
Write-Host "║                     BUSCADOR ATIVO - LISTEN TRACE v1.0                  ║" -ForegroundColor $CorDestaque
Write-Host "║                                                                         ║" -ForegroundColor $CorLinha
Write-Host "║                                   BUG IT                                ║" -ForegroundColor $CorDestaque
Write-Host "║                                                                         ║" -ForegroundColor $CorLinha
Write-Host "╠═════════════════════════════════════════════════════════════════════════╣" -ForegroundColor $CorLinha

Write-Host -NoNewline "║  Usuário     : " -ForegroundColor $CorSub
Write-Host $Usuario -ForegroundColor Cyan
Write-Host -NoNewline "║  Máquina     : " -ForegroundColor $CorSub
Write-Host $Maquina -ForegroundColor Yellow
Write-Host -NoNewline "║  PowerShell  : " -ForegroundColor $CorSub
Write-Host $VersaoPS -ForegroundColor Green
Write-Host -NoNewline "║  Data/Hora   : " -ForegroundColor $CorSub
Write-Host $DataHora -ForegroundColor Magenta
Write-Host "╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor $CorLinha
Write-Host ""

# ================= PALAVRAS =================
$PALAVRAS = @("psexec","127.0.0.1")
$RegexAll = ($PALAVRAS | ForEach-Object { [regex]::Escape($_) }) -join "|"
$TotalArquivosEncontrados = 0

Write-Host "▸ Palavra Chave  : " -NoNewline -ForegroundColor $CorValor
$PALAVRAS | ForEach-Object { Write-Host "$_ " -NoNewline -ForegroundColor $CorSenha }
Write-Host "`n"

# ================= CONFIG =================
$Diretorios = @("C:\")
$Extensoes = @(".exe",".sys",".dll",".ini")
$MaxPorArquivo = 5
$MaxFileSizeMB = 10

function Write-Separador {
    Write-Host "========================================================================" -ForegroundColor $CorSeparador
}

function Write-ConteudoColorido {
    param([string]$Linha)

    $pos = 0
    $matches = [regex]::Matches($Linha, $RegexAll, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if ($matches.Count -eq 0) {
        Write-Host $Linha -ForegroundColor $CorConteudo
        return
    }

    foreach ($m in $matches) {
        if ($m.Index -gt $pos) {
            Write-Host $Linha.Substring($pos, $m.Index - $pos) -NoNewline -ForegroundColor $CorConteudo
        }
        Write-Host $m.Value -NoNewline -ForegroundColor $CorSenha
        $pos = $m.Index + $m.Length
    }

    if ($pos -lt $Linha.Length) {
        Write-Host $Linha.Substring($pos) -NoNewline -ForegroundColor $CorConteudo
    }

    Write-Host ""
}

# ================= RELATÓRIO HTML =================
$DataExecucao = Get-Date
$RelatorioPath = "$PSScriptRoot\Relatorio_ListentTrace_$($DataExecucao.ToString("yyyyMMdd_HHmmss")).html"

@"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Relatório ListentTrace</title>
</head>
<body>
<h2>Relatório Listen Trace</h2>
<p>Execução: $($DataExecucao.ToString("dd/MM/yyyy HH:mm:ss"))</p>
<p>Status: PROCESSANDO...</p>
<table border="1" cellpadding="5" cellspacing="0">
<tr>
<th>Pasta</th>
<th>Arquivo</th>
<th>Linha</th>
<th>Conteúdo</th>
</tr>
"@ | Out-File -Encoding UTF8 $RelatorioPath

foreach ($Dir in $Diretorios) {

    if (!(Test-Path $Dir)) { continue }

    Get-ChildItem -Path $Dir -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        ($Extensoes -contains $_.Extension.ToLower()) -and
        (($_.Length / 1MB) -le $MaxFileSizeMB)
    } |
    ForEach-Object {

        $Arquivo = $_
        $TotalEncontrado = 0

        try { $Linhas = Get-Content $Arquivo.FullName -ErrorAction Stop } catch { return }

        for ($i = 0; $i -lt $Linhas.Count; $i++) {

            if ($Linhas[$i] -match $RegexAll) {

                if ($TotalEncontrado -ge $MaxPorArquivo) { break }

                $ConteudoHtml = [System.Net.WebUtility]::HtmlEncode($Linhas[$i])

                foreach ($p in $PALAVRAS) {
                    $ConteudoHtml = [regex]::Replace(
                        $ConteudoHtml,
                        [regex]::Escape($p),
                        "<mark class=`"senha`">$p</mark>",
                        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
                    )
                }

@"
<tr>
<td>$($Arquivo.DirectoryName)</td>
<td>$($Arquivo.Name)</td>
<td>$($i + 1)</td>
<td>$ConteudoHtml</td>
</tr>
"@ | Out-File -Append -Encoding UTF8 -FilePath $RelatorioPath

                $TotalEncontrado++
                $TotalArquivosEncontrados++
            }
        }
    }
}

(Get-Content $RelatorioPath -Raw) -replace "PROCESSANDO...", "$TotalArquivosEncontrados ocorrência(s) encontrada(s)" |
Set-Content -Encoding UTF8 $RelatorioPath

@"
</table>
</body>
</html>
"@ | Out-File -Append -Encoding UTF8 $RelatorioPath

Start-Process $RelatorioPath

Write-Host ""
Write-Host "Relatório gerado com sucesso:" -ForegroundColor Green
Write-Host $RelatorioPath -ForegroundColor Yellow
Write-Host "Pressione ENTER para sair..." -ForegroundColor Yellow
Read-Host
