function _devutil_tempmail_preview --description "Renderiza uma mensagem no painel de preview do fzf"
    # Arquivo próprio, e não um helper dentro do devutil_tempmail.fish: o fzf
    # chama o preview num shell NOVO (`fish -c "_devutil_tempmail_preview {1}"`),
    # que não tem as funções daquele arquivo carregadas. Só o autoload resolve —
    # e o autoload procura um arquivo com o nome da função.
    set -l id $argv[1]

    # As entradas de navegação da lista não são mensagens.
    switch $id
        case __atualizar
            echo "Reconsulta a caixa no servidor."
            return 0
        case __voltar
            echo "Volta ao menu."
            return 0
    end

    set -l cache_dir ~/.cache/tempmail-msgs
    set -l arquivo $cache_dir/$id.json

    # Cache em disco porque o preview dispara a CADA movimento de seta: sem ele,
    # descer a lista com o dedo no ↓ vira uma rajada de chamadas na API do mail.tm.
    if not test -f $arquivo
        set -l token (jq -r '.token // empty' ~/.cache/tempmail.json 2>/dev/null)
        test -n "$token"; or begin
            echo "(sem sessão)"
            return 1
        end

        mkdir -p $cache_dir
        curl -sf -H "Authorization: Bearer $token" https://api.mail.tm/messages/$id >$arquivo 2>/dev/null
        or begin
            rm -f $arquivo
            echo "(falha ao buscar a mensagem)"
            return 1
        end
    end

    set_color brblue
    echo "📩 "(jq -r '.subject // "(sem assunto)"' $arquivo)
    set_color normal
    echo "👤 "(jq -r '.from.address // "?"' $arquivo)
    echo "🕐 "(_devutil_tempmail_hora (jq -r '.createdAt // empty' $arquivo) "%Y-%m-%d %H:%M:%S")
    echo ""

    set -l texto (jq -r '.text // empty' $arquivo | string collect)
    if test -n "$texto"
        echo $texto
    else
        # Sem esta saída, um e-mail só-HTML aparecia em branco, como se
        # estivesse vazio.
        jq -r '.html[]? // empty' $arquivo \
            | string replace -ra '<(script|style)[^>]*>.*?</\\1>' '' \
            | string replace -ra '<[^>]+>' ' ' \
            | string replace -ra '&nbsp;' ' ' \
            | string replace -ra '\\s+' ' ' \
            | string trim
    end
end
