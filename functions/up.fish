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
            # Olha a SAÍDA, não o exit code: o `brew outdated` sai 0 sempre, com
            # ou sem pendência, então o `; or echo "tudo atualizado"` que estava
            # aqui era código morto — a mensagem nunca aparecia, e com tudo em dia
            # esta seção imprimia o cabeçalho e mais nada.
            set -l pendentes (brew outdated --verbose)
            if test (count $pendentes) -eq 0
                echo "✅ Tudo atualizado."
            else
                printf '%s\n' $pendentes
            end
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
            # Mesmo tratamento do brew, e pelo motivo oposto: o `npm outdated` sai
            # com 1 justamente QUANDO HÁ pendências. O `; or echo` daqui estava
            # invertido — listava os pacotes desatualizados e logo abaixo garantia
            # que estava tudo atualizado. Olhar a saída evita ter de decorar a
            # semântica de exit code de cada ferramenta.
            set -l pendentes (npm -g outdated 2>/dev/null)
            if test (count $pendentes) -eq 0
                echo "✅ Tudo atualizado."
            else
                printf '%s\n' $pendentes
            end
        else
            npm -g update
        end
    end

    echo ""
    set_color brgreen
    echo "✅ Fim."
    set_color normal
end
