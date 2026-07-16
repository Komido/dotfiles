function up --description "Atualiza tudo: Homebrew, Fisher, plugins e pacotes globais do npm"
    set -l so_conferir false
    if contains -- $argv[1] --check -n --dry-run
        set so_conferir true
        echo "🔎 Modo conferência: nada será alterado."
    end

    echo ""
    set_color brblue
    echo "🍺 Homebrew"
    set_color normal

    if not type -q brew
        echo "⚠️  brew não encontrado; pulando."
    else
        brew update
        if test $so_conferir = true
            brew outdated --verbose; or echo "✅ Tudo atualizado."
        else
            brew upgrade
            # Sem isso o Homebrew guarda toda versão antiga que já instalou; são
            # dezenas de GB depois de alguns meses.
            brew cleanup --prune=30
        end
    end

    echo ""
    set_color brblue
    echo "🎣 Fisher"
    set_color normal

    if not functions -q fisher
        echo "⚠️  fisher não encontrado; pulando."
    else if test $so_conferir = true
        fisher list
    else
        fisher update
    end

    echo ""
    set_color brblue
    echo "📗 npm (globais)"
    set_color normal

    if not type -q npm
        echo "⚠️  npm não encontrado; pulando."
    else
        # Amarrado à versão de Node ativa: cada versão do nvm tem sua própria
        # pasta de globais, então isto atualiza os globais do Node ativo agora.
        echo "ℹ️  Node ativo: "(node --version)
        if test $so_conferir = true
            npm -g outdated; or echo "✅ Tudo atualizado."
        else
            npm -g update
        end
    end

    echo ""
    set_color brgreen
    echo "✅ Fim."
    set_color normal
end
