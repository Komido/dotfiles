# Tudo aqui é prefixado com _devutil_tempmail_.
#
# A versão original definia `inbox`, `read_message`, `create_account`,
# `save_session` e `show_credentials` como funções GLOBAIS: nomes genéricos
# demais para viverem soltos no shell, prontos para colidir com um script ou com
# um binário de mesmo nome.
#
# A navegação é fzf, e não um menu numerado com `read`: o menu de texto reimprime
# tudo a cada ação e vai empilhando o terminal. O fzf desenha numa região fixa,
# aceita seta, filtra por digitação e some ao sair — e já é o padrão do resto
# deste repo (proj, musica, devutil ports).

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

function _devutil_tempmail_email --description "Lê o endereço da sessão salva"
    set -l cache (_devutil_tempmail_cache)
    test -f $cache; or return 1
    set -l email (jq -r '.email // empty' $cache 2>/dev/null)
    test -n "$email"; or return 1
    echo $email
end

function _devutil_tempmail_buscar --description "Busca as mensagens: uma linha id/de/assunto/lida por mensagem"
    # Códigos de saída distintos porque "caixa vazia" e "falhou" produzem a mesma
    # saída (nenhuma linha), e quem chama precisa saber a diferença: uma pede
    # "📭 vazia", a outra pede "❌ token expirou".
    set -l token (_devutil_tempmail_token)
    test -n "$token"; or return 2

    set -l resposta (curl -sf -H "Authorization: Bearer $token" https://api.mail.tm/messages | string collect)
    test $status -eq 0 -a -n "$resposta"; or return 1

    echo $resposta | jq -r '.["hydra:member"][]? | "\(.id)\t\(.from.address)\t\(.subject)\t\(.seen)\t\(.createdAt)"'
end

function _devutil_tempmail_criar --description "Cria uma conta nova no mail.tm"
    set -l dominio (curl -sf https://api.mail.tm/domains | jq -r '.["hydra:member"][0].domain // empty')
    if test -z "$dominio"
        echo "❌ Não foi possível obter um domínio do mail.tm."
        return 1
    end

    set -l email (uuidgen | string lower)@$dominio
    set -l senha (string split '@' -- $email)[1]

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

    # O cache de mensagens é da conta antiga; sem limpar, o preview mostraria
    # e-mail de outro endereço.
    rm -rf ~/.cache/tempmail-msgs

    _devutil_tempmail_salvar $email $senha $token
    printf '%s' $email | pbcopy
    # Silencioso no sucesso: quem chama (o menu) mostra a confirmação no cabeçalho
    # e o novo endereço já aparece no topo. Imprimir aqui vazaria acima do menu —
    # e as mensagens de erro acima é que precisam ser vistas, essas ficam.
end

function _devutil_tempmail_itens --description "Monta as linhas do fzf a partir das mensagens"
    for linha in $argv
        set -l c (string split \t -- $linha)
        # `.seen` diz se já foi aberta — poupa reler o que você já leu.
        set -l icone 📨
        test "$c[4]" = true; and set icone 📖
        set -l quando (_devutil_tempmail_hora $c[5] "%H:%M")
        printf "%s\t%s %s  %-30s  %s\n" $c[1] $icone $quando (string sub -l 30 -- $c[2]) $c[3]
    end
end

function _devutil_tempmail_inbox --description "Caixa de entrada navegável, com preview"
    while true
        # clear a cada volta: o fzf com --height desenha inline (não em tela
        # cheia), então qualquer coisa impressa na volta anterior — a mensagem que
        # você abriu no less, um erro — ficaria acima da caixa quando ela
        # redesenha. Limpar antes de desenhar mata esse acúmulo.
        clear
        set -l linhas (_devutil_tempmail_buscar)
        set -l resultado $status

        switch $resultado
            case 2
                echo "❌ Nenhuma sessão. Crie um e-mail primeiro."
                return 1
            case 1
                echo "❌ Falha ao consultar a caixa (o token pode ter expirado)."
                return 1
        end

        # Navegação como item da lista, no padrão do ti-hooks (`← não, voltar`):
        # a ação fica visível e alcançável pela seta, em vez de virar uma legenda
        # de teclas que ninguém lê.
        #
        # Via printf, e não "__atualizar\t↻": o fish NÃO interpreta \t dentro de
        # aspas (nem duplas nem simples) — sairia o literal barra-t, o
        # --delimiter do fzf não acharia o campo e o id apareceria na tela.
        set -l itens (printf '__atualizar\t↻ Atualizar') (printf '__voltar\t← Voltar ao menu')
        if test (count $linhas) -gt 0
            set -p itens (_devutil_tempmail_itens $linhas)
        end

        set -l cabecalho (_devutil_tempmail_email)
        if test (count $linhas) -eq 0
            set cabecalho "$cabecalho — 📭 caixa vazia"
        else
            set cabecalho "$cabecalho — 📬 "(count $linhas)
        end

        set -l escolha (printf '%s\n' $itens | fzf \
            --delimiter=\t --with-nth=2 --ansi \
            --height=90% --reverse --border \
            --prompt="📫 " \
            --header="$cabecalho" \
            --preview='fish -c "_devutil_tempmail_preview {1}"' \
            --preview-window=right,55%,wrap)

        # ESC devolve vazio: sai como se fosse "voltar".
        test -n "$escolha"; or return 0

        set -l id (string split \t -- $escolha)[1]
        switch $id
            case __voltar
                return 0
            case __atualizar
                # O cache é por mensagem, então atualizar não precisa derrubá-lo;
                # só a lista é reconsultada.
                continue
            case '*'
                _devutil_tempmail_ler $id
        end
    end
end


function _devutil_tempmail_ler --description "Abre uma mensagem no pager e copia o código, se houver"
    set -l id $argv[1]
    set -l arquivo ~/.cache/tempmail-msgs/$id.json

    # O preview já baixou e guardou; aqui normalmente é só ler do disco.
    if not test -f $arquivo
        set -l token (_devutil_tempmail_token)
        test -n "$token"; or begin
            echo "❌ Nenhuma sessão salva."
            return 1
        end
        mkdir -p (dirname $arquivo)
        curl -sf -H "Authorization: Bearer $token" https://api.mail.tm/messages/$id >$arquivo 2>/dev/null
        or begin
            rm -f $arquivo
            echo "❌ Falha ao buscar a mensagem."
            return 1
        end
    end

    # Códigos de confirmação são o motivo nº 1 de se abrir um e-mail temporário;
    # achá-los e já copiar poupa o select-com-o-mouse.
    set -l texto (jq -r '.text // empty' $arquivo | string collect)
    set -l codigo (echo $texto | string match -rg '\b(\d{4,8})\b' | head -1)

    test -n "$codigo"; and printf '%s' $codigo | pbcopy

    # SEMPRE pelo less, e sem `-F` nem `-X`.
    #
    # A caixa é um fzf com --height, que desenha inline (não em tela cheia). Ao
    # voltar para ela, o fzf redesenha logo abaixo do cursor — então tudo que
    # esta função imprimir DIRETO no terminal fica preso acima da caixa. Foi o
    # texto do corpo que vazou no topo da tela.
    #
    # A versão anterior usava `less -R -F -X`: `-F` faz o less despejar e sair na
    # hora se o conteúdo cabe numa tela, e `-X` o impede de usar a tela
    # alternativa — a combinação exata que deixa o texto para trás. O `less -R`
    # puro entra na tela alternativa e a restaura ao sair (tecla q), devolvendo a
    # caixa sem sujeira. Vale a tecla q até para mensagem curta: é o preço de não
    # vazar.
    begin
        if test -n "$codigo"
            set_color brgreen
            echo "🔑 Código $codigo — copiado para a área de transferência."
            set_color normal
            echo ""
        end
        _devutil_tempmail_preview $id
        echo ""
        set_color brblack
        echo "(q volta para a caixa)"
        set_color normal
    end | less -R
end

function _devutil_tempmail_copiar --description "Copia o endereço da sessão atual"
    # Silencioso: o menu confirma no cabeçalho e o preview já mostra o endereço.
    set -l email (_devutil_tempmail_email)
    test -n "$email"; or return 1
    printf '%s' $email | pbcopy
end

function _devutil_tempmail_menu_itens --description "Linhas do menu do tempmail (id + rótulo)"
    printf 'inbox\t📥 Caixa de entrada\n'
    printf 'novo\t✨ Novo e-mail temporário\n'
    printf 'copiar\t📋 Copiar o endereço atual\n'
    printf 'cred\t🔐 Credenciais salvas\n'
    printf 'sair\t🚪 Sair\n'
end

# _devutil_tempmail_header, _enter e _action ficam em arquivos próprios: o fzf os
# chama em shells novos (via transform-header/transform/execute), que só resolvem
# função por autoload — ou seja, por arquivo com o nome dela.

function devutil_tempmail --description "Cria e gerencia e-mails temporários via mail.tm"
    for dep in jq fzf
        if not type -q $dep
            echo "❌ $dep não encontrado. Instale com: brew install $dep"
            return 1
        end
    end

    # Um único fzf, que fica de pé a sessão inteira: a lista da esquerda é fixa e
    # cada Enter roda uma ação via bind (execute/execute-silent) sem fechar o fzf.
    # A versão anterior era um laço que derrubava e recriava o fzf a cada ação —
    # o intervalo entre derrubar e recriar (mais a latência do curl ao criar) era
    # a tela preta que piscava.
    #
    # $SHELL aqui é o zsh, e o fzf roda os binds por ele; por isso cada bind chama
    # `fish -c` explicitamente, senão as funções (que são do fish) não existiriam.
    _devutil_tempmail_menu_itens | fzf \
        --delimiter=\t --with-nth=2 --ansi \
        --height=90% --reverse --border \
        --prompt="📫 " \
        --header=(_devutil_tempmail_header | string collect) \
        --preview='fish -c "_devutil_tempmail_menu_preview {1}"' \
        --preview-window=right,55%,wrap \
        --bind='enter:transform:fish -c "_devutil_tempmail_enter {1}"'
end
