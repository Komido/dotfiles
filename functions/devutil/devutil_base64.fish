function devutil_base64 --description "Codifica ou decodifica base64 (aceita texto ou stdin)"
    set -l acao $argv[1]
    set -l dados $argv[2..-1]

    if test -z "$acao"
        echo "Uso: devutil base64 [encode|decode] \"texto\""
        echo "     cat arquivo | devutil base64 encode"
        return 1
    end

    # Sem argumento de texto, lê da stdin: permite encadear com pipe em vez de
    # obrigar a colar o conteúdo inteiro na linha de comando.
    #
    # `read -z`, e não `(cat)`: substituição de comando no fish NÃO herda a stdin
    # do pipe — `set x (cat)` dentro de uma função no fim de um pipe volta vazio,
    # sem erro nenhum. O `read` builtin lê a stdin da própria função.
    set -l entrada
    if test (count $dados) -gt 0
        set entrada (string join ' ' -- $dados)
    else if not isatty stdin
        read -z entrada
        set entrada (string trim -r -c \n -- $entrada)
    else
        echo "❌ Texto não fornecido."
        return 1
    end

    if test -z "$entrada"
        echo "❌ Entrada vazia."
        return 1
    end

    set -l resultado
    switch $acao
        case encode
            set resultado (printf '%s' $entrada | base64)
        case decode
            set resultado (_devutil_b64url $entrada); or return 1
        case '*'
            echo "❌ Ação desconhecida: $acao. Use 'encode' ou 'decode'."
            return 1
    end

    printf '%s' $resultado | pbcopy
    printf '\n📋 Resultado copiado:\n%s\n\n' $resultado
end
