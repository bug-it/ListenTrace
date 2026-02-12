# ListenTrace

🔍 Buscador Avançado de Configurações (PowerShell)

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/3386ea29-6e81-4101-85ae-986cd4f89dd6" />

<img width="1916" height="1031" alt="image" src="https://github.com/user-attachments/assets/3c7b319b-ff11-4134-9976-14a550071098" />

Ferramenta em PowerShell para auditoria, troubleshooting e análise de arquivos de configuração, com correlação inteligente por arquivo e redução agressiva de falsos positivos.

O ListenTrace localiza porta, IP e/ou palavra-chave apenas quando todos os critérios ativos coexistem no mesmo arquivo, evitando resultados irrelevantes comuns em buscas linha-a-linha.

Projetado para ambientes corporativos, infraestrutura, segurança e auditorias técnicas.


🚀 Principais Recursos

✅ Filtros dinâmicos por Porta, IP e Palavra-chave

✅ Correlação lógica por arquivo

3 critérios definidos → exige os 3 no mesmo arquivo

2 critérios definidos → exige os 2

1 critério definido → exige apenas 1

❌ Elimina falsos positivos e lixo binário

🎨 Saída colorida e padronizada (estilo corporativo / SOC)

📂 Varredura recursiva por extensões específicas

🧠 Foco em configurações reais, não logs aleatórios

💼 Ideal para auditoria, hardening e investigação


🧩 Extensões analisadas
.conf  .cfg  .ini  .json  .yaml  .yml
.xml   .env  .toml .py    .js

Extensões podem ser ajustadas facilmente no bloco de configuração.

⚙️ Configuração

Edite apenas este bloco no início do script:

$SearchPort = "443"          # Porta (ex: 443)
$SearchIP   = "127.0.0.1"    # IP (ex: 127.0.0.1)
$SearchKey  = "python"       # Palavra-chave (ex: python)

$BasePath = "C:\Windows\"

🔹 Regras importantes

Se o valor estiver vazio (""), ele não entra na busca

O script nunca retorna resultados parciais

Todos os critérios ativos devem existir no mesmo arquivo

📄 Exemplos de Uso
🔎 Buscar apenas por porta
$SearchPort = "443"
$SearchIP   = ""
$SearchKey  = ""

🌐 Buscar por IP + palavra-chave
$SearchPort = ""
$SearchIP   = "0.0.0.0"
$SearchKey  = "nginx"

🧠 Auditoria completa (porta + IP + chave)
$SearchPort = "8080"
$SearchIP   = "127.0.0.1"
$SearchKey  = "flask"


👉 O arquivo só será exibido se todos existirem juntos.

🔐 1. Hardening de servidores
Identificar serviços escutando em portas sensíveis vinculadas a IPs locais ou públicos.
Exemplo:

Porta: 22
IP: 0.0.0.0
Chave: ssh

Resultado:

Apenas arquivos de configuração reais do SSH
Nenhum dump, log ou falso positivo

🌐 2. Auditoria de aplicações web
Localizar aplicações rodando em portas específicas com frameworks sensíveis.
Exemplo:

Porta: 5000
IP: 127.0.0.1
Chave: flask

Resultado:

Configurações reais de aplicações Flask
Exclusão automática de arquivos irrelevantes

🛡️ 3. Investigação de exposição indevida
Verificar se aplicações estão escutando fora do padrão corporativo.
Exemplo:

Porta: 3000
IP: 0.0.0.0
Chave: react

Resultado:

Visão clara de serviços expostos
Suporte a relatórios de auditoria
