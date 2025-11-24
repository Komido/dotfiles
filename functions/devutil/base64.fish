function devutil_base64
    set -l action $argv[1]
    set -l data $argv[2]

    if test -z "$action"
        echo "Uso: devutil base64 [encode|decode] \"texto\""
        return 1
    end

    if test -z "$data"
        echo "Erro: Texto não fornecido."
        return 1
    end

    set -l result ""
    switch $action
        case encode
            set result (echo -n $data | base64)
        case decode
            set result (echo -n $data | base64 --decode)
        case '*'
            echo "Ação desconhecida: $action. Use 'encode' ou 'decode'."
            return 1
    end

    echo -n "$result" | pbcopy
    echo ""
    echo "📋 Resultado copiado para a área de transferência:"
    echo "$result"
    echo ""
end
