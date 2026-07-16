# Tudo aqui é prefixado com _devutil_tempmail_.
#
# A versão anterior definia `inbox`, `read_message`, `create_account`,
# `save_session` e `show_credentials` como funções GLOBAIS: nomes genéricos
# demais para viverem soltos no shell, prontos para colidir com um script ou com
# um binário de mesmo nome.

# Caminho como função, e não `set -g` no topo: arquivo de autoload deve conter só
# definições — código solto ali roda como efeito colateral do carregamento, e uma
# variável global some se alguém carregar só uma das funções.
function _devutil_tempmail_cache --description "Caminho do cache de sessão do tempmail"
    echo ~/.cache/tempmail.json
end

function _devutil_tempmail_salvar --description "Grava a sessão do tempmail no cache"
    set -l cache (_devutil_tempmail_cache)
    mkdir -p (dirname $cache)

    # A senha vai em texto plano no disco (a API do mail.tm exige a senha para
    # renovar o token), então o arquivo nasce 600 — nem `umask` frouxo nem outro
    # usuário da máquina leem. `touch` antes do redirect: o chmod precisa
    # acontecer ANTES do conteúdo entrar.
    touch $cache
    chmod 600 $cache

    jq -n --arg email "$argv[1]" --arg password "$argv[2]" --arg token "$argv[3]" \
        '{email: $email, password: $password, token: $token}' >$cache
end

function _devutil_tempmail_token --description "Lê o token salvo do tempmail"
    set -l cache (_devutil_tempmail_cache)
    test -f $cache; or return 1
    set -l token (jq -r '.token // empty' $cache 2>/dev/null)
    test -n "$token"; or return 1
    echo $token
end

function _devutil_tempmail_criar --description "Cria uma conta nova no mail.tm"
    set -l dominio (curl -sf https://api.mail.tm/domains | jq -r '.["hydra:member"][0].domain // empty')
    if test -z "$dominio"
        echo "❌ Não foi possível obter um domínio do mail.tm."
        return 1
    end

    set -l email (uuidgen | string lower)@$dominio
    set -l senha (string split '@' -- $email)[1]

    echo "📧 E-mail gerado: $email"

    # jq -n --arg escapa o valor; montar o JSON com interpolação de string
    # quebraria no primeiro caractere especial.
    set -l payload (jq -n --arg address "$email" --arg password "$senha" \
        '{address: $address, password: $password}')

    if not curl -sf -X POST https://api.mail.tm/accounts \
            -H "Content-Type: application/json" -d "$payload" >/dev/null
        echo "❌ Falha ao criar a conta no mail.tm."
        return 1
    end

    set -l token (curl -sf -X POST https://api.mail.tm/token \
        -H "Content-Type: application/json" -d "$payload" | jq -r '.token // empty')

    if test -z "$token"
        echo "❌ Conta criada, mas o token não veio. Tente de novo."
        return 1
    end

    _devutil_tempmail_salvar $email $senha $token
    printf '%s' $email | pbcopy
    echo "✅ E-mail salvo e copiado para a área de transferência."
end

function _devutil_tempmail_inbox --description "Lista a caixa de entrada e abre a mensagem escolhida"
    set -l token (_devutil_tempmail_token)
    if test -z "$token"
        echo "❌ Nenhuma sessão salva. Crie um e-mail primeiro (opção 1)."
        return 1
    end

    set -l mensagens (curl -sf -H "Authorization: Bearer $token" https://api.mail.tm/messages)
    if test -z "$mensagens"
        echo "❌ Falha ao consultar a caixa (token pode ter expirado)."
        return 1
    end

    set -l total (echo $mensagens | jq '.["hydra:member"] | length')
    if test "$total" -eq 0
        echo "📭 Caixa de entrada vazia."
        return 0
    end

    # Uma linha por mensagem, formatada pelo jq: o loop anterior fazia um
    # base64 + decode + 3 chamadas de jq por mensagem só para ler 3 campos.
    set -l linhas (echo $mensagens | jq -r '.["hydra:member"][] | "\(.id)\t\(.from.address)\t\(.subject)"')

    echo "📬 Caixa de Entrada ($total):"
    set -l ids
    set -l i 1
    for linha in $linhas
        set -l campos (string split \t -- $linha)
        set -a ids $campos[1]
        printf "  [%d] 📨 %s — 📌 %s\n" $i $campos[2] $campos[3]
        set i (math $i + 1)
    end

    echo ""
    read -l -P "🆔 Número da mensagem para ler (Enter para sair): " escolha

    if test -z "$escolha"
        echo "🚪 Saindo."
        return 0
    end

    if not string match -qr '^\d+$' -- $escolha; or test $escolha -lt 1 -o $escolha -gt (count $ids)
        echo "❌ Número inválido."
        return 1
    end

    _devutil_tempmail_ler $ids[$escolha]
end

function _devutil_tempmail_ler --description "Mostra uma mensagem do tempmail pelo ID"
    set -l token (_devutil_tempmail_token)
    if test -z "$token"
        echo "❌ Nenhuma sessão salva."
        return 1
    end

    set -l id $argv[1]
    if test -z "$id"
        read -l -P "🆔 ID da mensagem: " id
        test -n "$id"; or return 1
    end

    curl -sf -H "Authorization: Bearer $token" https://api.mail.tm/messages/$id \
        | jq -r '"\n📩 Assunto: \(.subject)\n👤 De: \(.from.address)\n\n\(.text)"'
end

function _devutil_tempmail_credenciais --description "Mostra as credenciais salvas do tempmail"
    set -l cache (_devutil_tempmail_cache)
    if not test -f $cache
        echo "❌ Nenhuma credencial encontrada."
        return 1
    end
    echo "🔐 Credenciais salvas ($cache):"
    jq . $cache
end

function devutil_tempmail --description "Cria e gerencia e-mails temporários via mail.tm"
    if not type -q jq
        echo "❌ jq não encontrado. Instale com: brew install jq"
        return 1
    end

    echo ""
    echo "📫 TEMPMAIL — e-mail temporário para testes"
    echo "  1) Novo e-mail temporário"
    echo "  2) Ver caixa de entrada"
    echo "  3) Ler mensagem (ID manual)"
    echo "  4) Ver credenciais salvas"
    echo ""

    read -l -P "Escolha uma opção (1/2/3/4): " escolha

    switch $escolha
        case 1
            _devutil_tempmail_criar
        case 2
            _devutil_tempmail_inbox
        case 3
            _devutil_tempmail_ler
        case 4
            _devutil_tempmail_credenciais
        case '*'
            echo "❌ Opção inválida."
            return 1
    end
end
