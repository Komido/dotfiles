function api_test --description "Testa APIs REST/GraphQL com headers, dados tipados e status HTTP"
    if not type -q curl
        echo "❌ curl não encontrado."
        return 1
    end

    if not type -q jq
        echo "❌ jq não encontrado. Instale com: brew install jq"
        return 1
    end

    set -l metodo (string lower -- "$argv[1]")

    switch $metodo
        case '' help --help -h
            _api_test_help
            return 0
    end

    switch $metodo
        case get post put patch delete head options
        case '*'
            echo "❌ Método não suportado: $metodo"
            echo "   Use: get, post, put, patch, delete, head, options"
            return 1
    end

    set -l url $argv[2]
    if test -z "$url"
        echo "❌ URL não informada."
        echo ""
        _api_test_help
        return 1
    end

    set -l headers -H "Content-Type: application/json"
    set -l pares

    for arg in $argv[3..-1]
        if string match -qr '^[A-Za-z0-9_.-]+:=' -- $arg
            # `chave:=valor` → JSON puro (número, booleano, array, objeto)
            set -a pares $arg
        else if string match -qr '^[A-Za-z0-9-]+:' -- $arg
            set -a headers -H $arg
        else if string match -qr '^[A-Za-z0-9_.-]+=' -- $arg
            set -a pares $arg
        else
            echo "⚠️  Argumento ignorado (não é header nem dado): $arg"
        end
    end

    # O corpo é montado pelo jq, não por interpolação de string.
    #
    # A versão anterior fazia '"'$key'":"'$value'"' na mão: qualquer valor com
    # aspas gerava JSON inválido — `name='John "JJ" Doe'` virava
    # {"name":"John "JJ" Doe"} e o servidor recusava.
    #
    # Convenção do httpie: `chave=valor` é sempre string; `chave:=valor` é JSON
    # puro. Nada de adivinhar o tipo pelo formato — `cpf=01234567890` viraria
    # número e perderia o zero à esquerda, e `versao=1.20` viraria 1.2.
    # `jq -c` (compacto) é obrigatório aqui, não é estética: o jq formata em
    # várias linhas por padrão, e a substituição de comando quebraria o JSON numa
    # LISTA de linhas. O `-d $corpo` então viraria `-d {` seguido de vários
    # argumentos soltos, que o curl tenta interpretar como URL.
    set -l corpo "{}"
    for par in $pares
        if string match -qr '^[A-Za-z0-9_.-]+:=' -- $par
            set -l chave (string split -m1 ':=' -- $par)[1]
            set -l valor (string split -m1 ':=' -- $par)[2]
            set corpo (echo $corpo | jq -c --arg k "$chave" --argjson v "$valor" '. + {($k): $v}' 2>/dev/null)
            or begin
                echo "❌ '$valor' não é JSON válido (em $chave:=)."
                return 1
            end
        else
            set -l chave (string split -m1 '=' -- $par)[1]
            set -l valor (string split -m1 '=' -- $par)[2]
            set corpo (echo $corpo | jq -c --arg k "$chave" --arg v "$valor" '. + {($k): $v}')
        end
    end

    set -l dados
    if test "$corpo" != "{}"
        set dados -d $corpo
    end

    # Corpo e status saem separados: o status é o que você quer ver primeiro ao
    # testar uma API, e o `| jq` engolia essa informação por completo.
    set -l arquivo (mktemp)
    set -l codigo (curl -sS -o $arquivo -w '%{http_code}' \
        -X (string upper -- $metodo) $headers $dados $url)
    set -l curl_status $status

    if test $curl_status -ne 0
        rm -f $arquivo
        return $curl_status
    end

    echo ""
    if test $codigo -ge 200 -a $codigo -lt 300
        set_color brgreen
    else if test $codigo -ge 400
        set_color brred
    else
        set_color bryellow
    end
    echo "⟵ HTTP $codigo  ($(string upper -- $metodo) $url)"
    set_color normal

    # Nem toda resposta é JSON: um 502 do nginx vem em HTML, e o `jq` sozinho
    # cuspiria erro de parse em cima do erro que você foi investigar.
    if test -s $arquivo
        if jq . $arquivo 2>/dev/null
        else
            cat $arquivo
            echo ""
        end
    end

    rm -f $arquivo

    test $codigo -lt 400
end

function _api_test_help --description "Ajuda do api_test"
    echo ""
    echo "🌐 api_test <método> <url> [headers] [dados]"
    echo ""
    echo "  Métodos: get, post, put, patch, delete, head, options"
    echo "  Headers: Chave:Valor          → Authorization:'Bearer token'"
    echo "  Dados:   chave=valor          → sempre string"
    echo "           chave:=valor         → JSON puro (número, bool, array, objeto)"
    echo ""
    echo "Exemplos:"
    echo "  api_test get https://api.github.com/users/octocat"
    echo "  api_test get https://api.example.com/users Authorization:'Bearer tk'"
    echo ""
    echo "  # string vs. número — repare no ':='"
    echo "  api_test post https://api.example.com/users name=John age:=30"
    echo "  api_test post https://api.example.com/users cpf=01234567890   # zero à esquerda preservado"
    echo "  api_test post https://api.example.com/users tags:='[\"a\",\"b\"]' ativo:=true"
    echo ""
    echo "  # GraphQL (a query é uma string comum)"
    echo "  api_test post https://api.example.com/graphql query='query { users { id name } }'"
    echo ""
    echo "  # query params e path params vão na própria URL"
    echo "  api_test get 'https://api.example.com/users?page=1&limit=10'"
    echo ""
end
