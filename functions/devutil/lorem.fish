function devutil_lorem
    set -l type "paragraph"
    if test -n "$argv[1]"
        set type $argv[1]
    end

    set -l text ""
    set -l base_text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    # Verifica se o argumento é um número
    if string match -qr '^[0-9]+$' -- $type
        set -l length $type
        # Repete o texto base até ter tamanho suficiente
        while test (string length $text) -lt $length
            set text "$text $base_text"
        end
        # Corta para o tamanho exato
        set text (string sub -l $length $text)
    else
        switch $type
            case "word"
                set text "Lorem"
            case "sentence"
                set text "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
            case "paragraph"
                set text $base_text
            case "*"
                echo "Tipo desconhecido. Use: word, sentence, paragraph ou um número (quantidade de caracteres)"
                return 1
        end
    end

    echo -n "$text" | pbcopy
    echo ""
    echo "📋 Texto copiado para a área de transferência:"
    echo "$text"
    echo ""
end
