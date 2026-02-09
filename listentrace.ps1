Clear-Host

# ================= ASCII =================
Write-Host @"
 _      _     _          _______
| |    (_)   | |        |__   __|
| |     _ ___| |_ ___ _ __ | |_ __ __ _  ___ ___
| |    | / __| __/ _ \ '_ \| | '__/ _ |/ __/ _ \
| |____| \__ \ |_  __/ | | | | | | (_| | (__  __/
|______|_|___/\__\___|_| |_|_|_|  \__,_|\___\___|
"@ -ForegroundColor Cyan

Write-Host "Auditoria Correlacionada" -ForegroundColor DarkCyan
Write-Host "==================================================" -ForegroundColor DarkGray
Write-Host ""

# ================= CONFIGURAÇÕES =================
# 🔧 Critérios (deixe "" ou $null para ignorar)
$SearchPort = "443"
$SearchIP   = "127.0.0.1"
$SearchKey  = @("")

$BasePath = "C:\Windows"

# 🔒 SOMENTE EXTENSÕES DE TEXTO
$Extensions = @(
    "*.conf","*.cfg","*.ini","*.json","*.yaml","*.yml",
    "*.xml","*.env","*.log","*.txt","*.ps1","*.psm1"
)

$SnippetSize = 200

# ================= REGEX =================
$RegexPort = if ($SearchPort) {
    "(?i)\b(port|porta|listen)\b\s*[:=]?\s*$SearchPort\b"
}

$RegexIP = if ($SearchIP) {
    "\b$([regex]::Escape($SearchIP))\b"
}

# Regex seguro para palavras-chave (SEM falso positivo)
$RegexKeys = @()
foreach ($Key in $SearchKey) {
    $RegexKeys += "\b$([regex]::Escape($Key))\b\s*[:=]?"
}

$ActiveRules = @($RegexPort,$RegexIP) + $RegexKeys | Where-Object { $_ }

if ($ActiveRules.Count -eq 0) {
    Write-Host "❌ Nenhum critério definido" -ForegroundColor Red
    Pause
    exit
}

# ================= HEADER =================
Write-Host "🔎 BUSCADOR ATIVO" -ForegroundColor White
Write-Host ""
if ($SearchPort) { Write-Host "🟦 Porta : $SearchPort" -ForegroundColor Yellow }
if ($SearchIP)   { Write-Host "🟨 IP    : $SearchIP" -ForegroundColor Green }
if ($SearchKey)  { Write-Host "🟩 Chave : $($SearchKey -join ', ')" -ForegroundColor Cyan }
Write-Host "📂 Diretório: $BasePath" -ForegroundColor DarkGray
Write-Host "==================================================" -ForegroundColor DarkGray
Write-Host ""

# ================= EXECUÇÃO =================
Get-ChildItem $BasePath -Recurse -File -Include $Extensions -ErrorAction SilentlyContinue |
ForEach-Object {

    try {
        $Content = Get-Content $_.FullName -Encoding UTF8 -ErrorAction Stop
    } catch {
        return
    }

    # 🔍 valida correlação no arquivo inteiro
    foreach ($Rule in $ActiveRules) {
        if (-not ($Content -match $Rule)) {
            return
        }
    }

    $FilePrinted = $false
    $LineNumber = 0

    foreach ($Line in $Content) {
        $LineNumber++

        $Matched = $false

        if ($RegexPort -and $Line -match $RegexPort) {
            $MatchLabel = "Porta ($SearchPort)"
            $Matched = $true
        }
        elseif ($RegexIP -and $Line -match $RegexIP) {
            $MatchLabel = "IP ($SearchIP)"
            $Matched = $true
        }
        else {
            foreach ($Key in $SearchKey) {
                $SafeKeyRegex = "\b$([regex]::Escape($Key))\b\s*[:=]?"
                if ($Line -match $SafeKeyRegex) {
                    $MatchLabel = "Chave ($Key)"
                    $Matched = $true
                    break
                }
            }
        }

        if ($Matched) {

            if (-not $FilePrinted) {
                Write-Host "📁 Pasta   : $($_.DirectoryName)" -ForegroundColor DarkGray
                Write-Host "📄 Arquivo : $($_.Name)" -ForegroundColor Cyan
                $FilePrinted = $true
            }

            $Out = $Line.Trim()
            if ($Out.Length -gt $SnippetSize) {
                $Out = $Out.Substring(0,$SnippetSize) + "..."
            }

            Write-Host "🧷 ATIVO   : $MatchLabel" -ForegroundColor Cyan
            Write-Host "🔢 Linha $LineNumber :" -ForegroundColor DarkGray
            Write-Host "   $Out" -ForegroundColor White
            Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
        }
    }

    if ($FilePrinted) {

        Write-Host ""
    }
}

Write-Host "✅ Varredura finalizada com sucesso." -ForegroundColor Green
Write-Host ""
Pause
