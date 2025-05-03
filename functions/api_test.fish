function api_test
    # Verifica dependências
    if not command -q curl
        echo "Erro: curl não está instalado"
        return 1
    end

    if not command -q jq
        echo "Erro: jq não está instalado"
        return 1
    end

    set -l method (string lower $argv[1])
    set -l url $argv[2]
    set -l headers "-H" "Content-Type: application/json"
    set -l data_pairs
    set -l query

    for arg in $argv[3..-1]
        if string match -qr '^[A-Za-z0-9-]+:.*' -- $arg
            set headers $headers "-H" $arg
        else if string match -qr '^[A-Za-z0-9_]+=.*' -- $arg
            set data_pairs $data_pairs $arg
        else if string match -qr '^query=.*' -- $arg
            set query (string split -m1 "=" $arg)[2]
        end
    end

    set -l data
    if test (count $data_pairs) -gt 0
        set -l json_pairs
        for pair in $data_pairs
            set key (string split -m1 "=" $pair)[1]
            set value (string split -m1 "=" $pair)[2]
            set json_pairs $json_pairs '"'$key'":"'$value'"'
        end
        set data "{"(string join "," $json_pairs)"}"
    end

    switch $method
        case get
            curl -s -X GET $url $headers | jq
        case post put patch
            if test -n "$query"
                curl -s -X POST $url $headers -d "{\"query\": $query}" | jq
            else if test -n "$data"
                curl -s -X (string upper $method) $url $headers -d "$data" | jq
            else
                curl -s -X (string upper $method) $url $headers | jq
            end
        case delete
            curl -s -X DELETE $url $headers | jq
        case help --help -h
            echo "Uso simplificado: api_test <método> <url> [headers] [dados]"
            echo ""
            echo "Headers: Passe como Chave:Valor (ex: Authorization:'Bearer token')"
            echo "Dados: Passe como chave=valor (ex: name=John age=30)"
            echo "GraphQL: Passe a query como query='...'"
            echo ""
            echo "Exemplos:"
            echo "  # REST API"
            echo "  api_test get https://api.example.com/users Authorization:'Bearer token'"
            echo "  api_test post https://api.example.com/users name=John age=30"
            echo "  api_test post https://api.example.com/users Authorization:'Bearer token' name=John"
            echo ""
            echo "  # Query Params"
            echo "  api_test get https://api.example.com/users?page=1&limit=10"
            echo "  api_test get https://api.example.com/users?page=1&limit=10 Authorization:'Bearer token'"
            echo ""
            echo "  # Path Params"
            echo "  api_test get https://api.example.com/users/:id"
            echo "  api_test get https://api.example.com/users/:id Authorization:'Bearer token'"
            echo ""
            echo "  # GraphQL"
            echo "  api_test post https://api.example.com/graphql query='query { users { id name } }'"
            echo "  api_test post https://api.example.com/graphql Authorization:'Bearer token' query='query { users { id name } }'"
        case '*'
            echo "Método não suportado"
    end
end 