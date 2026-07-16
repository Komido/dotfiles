function devutil_lorem --description "Gera texto Lorem Ipsum (word, sentence, paragraph ou nº de caracteres)"
    set -l tipo paragraph
    if test -n "$argv[1]"
        set tipo $argv[1]
    end

    set -l base "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    set -l texto
    if string match -qr '^\d+$' -- $tipo
        while test (string length -- "$texto") -lt $tipo
            set texto "$texto $base"
        end
        set texto (string sub -l $tipo -- (string trim -- $texto))
    else
        switch $tipo
            case word
                set texto Lorem
            case sentence
                set texto "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
            case paragraph
                set texto $base
            case '*'
                echo "❌ Tipo desconhecido: $tipo"
                echo "   Use: word, sentence, paragraph ou um número de caracteres."
                return 1
        end
    end

    printf '%s' $texto | pbcopy
    printf '\n📋 Texto copiado:\n%s\n\n' $texto
end
