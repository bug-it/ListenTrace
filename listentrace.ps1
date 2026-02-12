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

# ================= RELATÓRIO HTML =================
$DataExecucao = Get-Date
$BasePath = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$RelatorioPath = Join-Path $BasePath "Relatorio_ListentTrace_$($DataExecucao.ToString('yyyyMMdd_HHmmss')).html"

@"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="5">
<title>Relatório ListentTrace</title>
<style>
body{font-family:"Segoe UI",Arial,sans-serif;background:#ffffff;color:#000;margin:0;padding:30px;}
.header{border-left:6px solid #0b3d91;padding-left:15px;margin-bottom:20px;}
h2{margin:0;color:#0b3d91;}
small{color:#555;}
.status{margin-top:8px;font-weight:600;color:#1a7f37;}
table{width:100%;border-collapse:collapse;font-size:14px;}
th{background:#0b3d91;color:#ffffff;padding:10px;text-align:left;}
td{padding:8px;border-bottom:1px solid #e0e0e0;}
mark.senha{background:#ffd54f;padding:2px 4px;border-radius:4px;font-weight:bold;}
pre{margin:0;font-family:Consolas,monospace;white-space:pre-wrap;}
.footer{margin-top:25px;padding-top:10px;border-top:2px solid #0b3d91;font-size:13px;color:#666;}
</style>
</head>
<body>
<div class="header">
<h2>Relatório Listen Trace</h2>
<small>Execução: $($DataExecucao.ToString("dd/MM/yyyy HH:mm:ss"))</small>
<div class="status">Status: PROCESSANDO...</div>
</div>
<table>
<tr>
<th>Pasta</th>
<th>Arquivo</th>
<th>Linha</th>
<th>Conteúdo</th>
</tr>
"@ | Out-File -Encoding UTF8 $RelatorioPath

Invoke-Item $RelatorioPath

# ================= FUNÇÕES =================
function Write-Separador {
    Write-Host "========================================================================" -ForegroundColor $CorSeparador
}

function Write-ConteudoColorido {
    param([string]$Linha)

    $pos = 0
    $matches = [regex]::Matches($Linha, $RegexAll, 'IgnoreCase')

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

# ================= EXECUÇÃO =================
foreach ($Dir in $Diretorios) {

    if (!(Test-Path $Dir)) { continue }

    Write-Host "📂 Analisando diretório: $Dir" -ForegroundColor DarkCyan

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

                Write-Separador
                Write-Host "📁 Pasta   : $($Arquivo.DirectoryName)" -ForegroundColor $CorValor
                Write-Host "📄 Arquivo : $($Arquivo.Name)" -ForegroundColor $CorValor
                Write-Host "🔢 Linha   : $($i + 1)" -ForegroundColor $CorValor
                Write-Host "📌 Conteúdo:" -ForegroundColor $CorValor
                Write-ConteudoColorido $Linhas[$i]
                Write-Host ""

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
<td><pre>$ConteudoHtml</pre></td>
</tr>
"@ | Out-File -Append -Encoding UTF8 -FilePath $RelatorioPath

                $TotalEncontrado++
                $TotalArquivosEncontrados++
            }
        }
    }
}

(Get-Content $RelatorioPath -Raw) -replace "Status: PROCESSANDO...", "Status: $TotalArquivosEncontrados ocorrência(s) encontrada(s)" |
Set-Content -Encoding UTF8 $RelatorioPath

@"
</table>
<div class="footer">
Relatório gerado automaticamente pelo Listen Trace.
</div>
</body>
</html>
"@ | Out-File -Append -Encoding UTF8 $RelatorioPath

Write-Host ""
Write-Host "Relatório gerado com sucesso:" -ForegroundColor Green
Write-Host $RelatorioPath -ForegroundColor Yellow
Write-Host "Pressione ENTER para sair..." -ForegroundColor Yellow
Read-Host
