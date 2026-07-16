function try_install_tool --argument-names tool method \
    --description "Verifica se uma ferramenta existe e oferece instalar (npm ou brew)"
    if not set -q method; or test -z "$method"
        set method npm
    end

    if test "$tool" = --help -o "$tool" = -h
        echo ""
        echo "📦 try_install_tool <ferramenta> [npm|brew]"
        echo ""
        echo "  Verifica se a ferramenta está instalada e pergunta se deve instalar."
        echo "  Se nenhum método for especificado, usa 'npm' como padrão."
        echo ""
        echo "  Exemplos:"
        echo "    try_install_tool cuid-cli"
        echo "    try_install_tool jq brew"
        echo ""
        return 0
    end

    # Mapeia tool → comando real (por exemplo: cuid-cli instala cuid)
    set real_command $tool
    switch $tool
        case cuid-cli
            set real_command cuid
    end

    if not type -q $real_command
        set method (string lower $method)
        set_color bryellow
        read -l -P "🔧 '$tool' não está instalado. Deseja instalar com $method? (Y/n) " choice
        set_color normal

        if test -z "$choice" -o "$choice" = Y -o "$choice" = y
            switch $method
                case npm
                    npm install -g $tool
                case brew
                    brew install $tool
                case '*'
                    echo "⚠️ Método de instalação desconhecido: $method"
                    return 1
            end
        else
            echo "⏭️ $tool não foi instalado. Abortando."
            return 1
        end
    end
end
