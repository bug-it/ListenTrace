Clear-Host

# ================== CONFIGURACAO ==================
$DiretorioRaiz = "C:\Windows"

$PortaBusca = "443"
$IPBusca    = ""
$DNSBusca   = ""

$PalavrasChave = @(
    "",
    $IPBusca,
    $DNSBusca,
    $PortaBusca
)

$Extensoes = "*.log","*.txt","*.ini","*.ps1","*.inf"
# ==================================================

# ================== BANNER ==================
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host " ListenTrace - Auditoria Forense Correlacionada" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host ""

# ================== BUSCA ==================
Get-ChildItem -Path $DiretorioRaiz -Recurse -File -Include $Extensoes -ErrorAction SilentlyContinue |
ForEach-Object {

    $Arquivo = $_
    $LinhaNum = 0
    $Evidencia = $null

    try {
        Get-Content $Arquivo.FullName -ErrorAction Stop | ForEach-Object {

            $LinhaNum++
            $LinhaTexto = $_.Trim()

            foreach ($Chave in $PalavrasChave) {

                # Regex exato: palavra inteira ou número
                if ($Chave -match '^\d+$') {
                    $Regex = "(?<!\d)$Chave(?!\d)"
                } else {
                    $Regex = "\b$([regex]::Escape($Chave))\b"
                }

                if ($LinhaTexto -imatch $Regex) {
                    $Evidencia = [PSCustomObject]@{
                        Linha    = $LinhaNum
                        Chave    = $Chave
                        Conteudo = $LinhaTexto
                    }
                    break
                }
            }

            if ($Evidencia) { return } # Para após encontrar a primeira ocorrência
        }
    }
    catch {
        return
    }

    # Só mostra se encontrou algo e se DNS/IP/Porta/Chave não forem vazios
    if ($Evidencia -and ($Evidencia.Chave -ne "" -and $Arquivo -ne $null)) {

        $TipoArquivo = $Arquivo.Extension.TrimStart('.')

        Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host (" Pasta .............: {0}" -f $Arquivo.DirectoryName) -ForegroundColor White
        Write-Host (" Arquivo ...........: {0}" -f $Arquivo.Name)          -ForegroundColor White
        Write-Host (" Tipo ..............: {0}" -f $TipoArquivo)          -ForegroundColor White
        Write-Host (" Ultima Alteracao ..: {0}" -f $Arquivo.LastWriteTime) -ForegroundColor White
        Write-Host ""

        if ($DNSBusca -ne "") { Write-Host (" DNS ...............: {0}" -f $DNSBusca) -ForegroundColor Yellow }
        if ($IPBusca  -ne "") { Write-Host (" IP ................: {0}" -f $IPBusca) -ForegroundColor Yellow }
        if ($PortaBusca -ne "") { Write-Host (" Porta .............: {0}" -f $PortaBusca) -ForegroundColor Yellow }
        if ($Evidencia.Chave -ne "") { Write-Host (" Chave .............: {0}" -f $Evidencia.Chave) -ForegroundColor Yellow }

        Write-Host ""
        Write-Host (" Linha .............: {0}" -f $Evidencia.Linha) -ForegroundColor Cyan
        Write-Host (" Conteudo ..........: {0}" -f $Evidencia.Conteudo) -ForegroundColor Gray
        Write-Host ""
    }
}

# ================== FINAL ==================
Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " ANALISE FINALIZADA" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
