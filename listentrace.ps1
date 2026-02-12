# FORÇA UTF-8 NO POWERSHELL 5.1 (mantém emojis funcionando)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

# ================= FUNÇÕES =================
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

                $TotalEncontrado++
                $TotalArquivosEncontrados++
            }
        }
    }
}

Write-Host ""
Write-Host "Total de ocorrências encontradas: $TotalArquivosEncontrados" -ForegroundColor Green
Write-Host "Pressione ENTER para sair..." -ForegroundColor Yellow
Read-Host
