Clear-Host
$Host.UI.RawUI.WindowTitle = "ListentTrace :: Auditoria / Monitoramento"

# ================= CORES =================
$CorTitulo    = "Cyan"
$CorValor     = "White"
$CorSeparador = "DarkGray"
$CorSenha     = "Yellow"
$CorHash      = "Magenta"
$CorToken     = "Green"
$CorConteudo  = "Gray"

# ================= TOPO =================
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor $CorTitulo
Write-Host "║          BUSCADOR ATIVO - LISTENTRACE                ║" -ForegroundColor $CorTitulo
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor $CorTitulo
Write-Host ""

# ================= PALAVRAS POR TIPO =================
$PALAVRAS = @{
    SENHA = @(
        "password=","passwd=","senha=","pwd=",
        "DB_PASSWORD",".env"
    )
    HASH = @(
        "MD5","SHA1","SHA256","bcrypt",
        "password_hash","NTLM","LMHash"
    )
    TOKEN = @(
        "Authorization:","Bearer ",
        "BEGIN PRIVATE KEY"
    )
}

# ================= TODAS AS PALAVRAS =================
$TodasPalavras = @()
$PALAVRAS.Values | ForEach-Object { $TodasPalavras += $_ }

# 🔒 REGEX ÚNICO (CORRIGIDO)
$RegexAll = ($TodasPalavras | ForEach-Object { [regex]::Escape($_) }) -join "|"

# ================= EXIBIR PALAVRAS =================
Write-Host "▸ Palavra  : " -NoNewline -ForegroundColor $CorValor
$TodasPalavras | ForEach-Object {
    Write-Host "$_ " -NoNewline -ForegroundColor $CorSenha
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
mark.senha { background:#ffd700; color:#000; font-weight:bold; }
mark.hash  { background:#ff00ff; color:#000; font-weight:bold; }
mark.token { background:#00ff99; color:#000; font-weight:bold; }
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
    param ($Texto)

    $pos = 0
    $matches = [regex]::Matches($Texto, $RegexAll, "IgnoreCase")

    foreach ($m in $matches) {

        if ($m.Index -gt $pos) {
            Write-Host ($Texto.Substring($pos, $m.Index - $pos)) -NoNewline -ForegroundColor $CorConteudo
        }

        $cor = $CorConteudo
        if ($PALAVRAS.SENHA -contains $m.Value) { $cor = $CorSenha }
        elseif ($PALAVRAS.HASH -contains $m.Value) { $cor = $CorHash }
        elseif ($PALAVRAS.TOKEN -contains $m.Value) { $cor = $CorToken }

        Write-Host ($m.Value) -NoNewline -ForegroundColor $cor
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
        $TotalEncontrado = 0

        try { $Linhas = Get-Content $Arquivo.FullName -ErrorAction Stop } catch { return }

        for ($i = 0; $i -lt $Linhas.Count; $i++) {

            if ($Linhas[$i] -match $RegexAll) {

                if ($TotalEncontrado -eq 0) {
                    Write-Separador
                    Write-Host "📁 Pasta   : $($Arquivo.DirectoryName)"
                    Write-Host "📄 Arquivo : $($Arquivo.Name)"
                    Write-Separador
                }

                if ($TotalEncontrado -ge $MaxPorArquivo) { break }

                Write-Host "🔢 Linha   : $($i + 1)"
                Write-Host "📌 Conteúdo:"
                Write-Host "     " -NoNewline
                Write-ConteudoColorido $Linhas[$i]
                Write-Host ""

                # ===== HTML HIGHLIGHT POR TIPO =====
                $ConteudoHtml = [System.Net.WebUtility]::HtmlEncode($Linhas[$i])

                foreach ($p in $PALAVRAS.SENHA) {
                    $ConteudoHtml = $ConteudoHtml -replace [regex]::Escape($p), "<mark class='senha'>$p</mark>"
                }
                foreach ($p in $PALAVRAS.HASH) {
                    $ConteudoHtml = $ConteudoHtml -replace [regex]::Escape($p), "<mark class='hash'>$p</mark>"
                }
                foreach ($p in $PALAVRAS.TOKEN) {
                    $ConteudoHtml = $ConteudoHtml -replace [regex]::Escape($p), "<mark class='token'>$p</mark>"
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

# ================= FECHAR HTML =================
"</table></body></html>" | Out-File -Append -Encoding UTF8 $RelatorioPath

# ================= FINAL =================
Write-Host ""
Write-Host "Relatório gerado com sucesso:" -ForegroundColor Green
Write-Host $RelatorioPath -ForegroundColor Yellow
Write-Host "Pressione ENTER para sair..." -ForegroundColor Yellow
Read-Host
