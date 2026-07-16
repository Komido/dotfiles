function dothelp --description "Lista as funções destes dotfiles com suas descrições"
    # A lista se monta sozinha, a partir dos arquivos e das suas --description.
    #
    # A versão anterior era escrita à mão e já tinha apodrecido: anunciava um
    # `devutil slug` que nunca existiu e esquecia dock, ports e epoch. Toda lista
    # mantida em paralelo ao código diverge dele — é só questão de tempo.
    set -l config_link $__fish_config_dir/config.fish

    if not test -L $config_link
        echo "❌ ~/.config/fish/config.fish não é um link para o repo dos dotfiles."
        echo "   Rode o ./install.fish de dentro do clone primeiro."
        return 1
    end

    set -l repo (dirname (readlink $config_link))

    echo ""
    echo "📘 Funções destes dotfiles"
    echo ""

    for arquivo in $__fish_config_dir/functions/*.fish
        # Este diretório também guarda as funções do fisher (nvm, git, done): sem
        # este filtro, o dothelp listaria dezenas de funções que não são suas.
        # Só entra o que é symlink apontando para dentro do repo.
        test -L $arquivo; or continue
        string match -q -- "$repo/*" (readlink $arquivo); or continue

        set -l nome (string replace -r '\.fish$' '' -- (basename $arquivo))

        # Helpers (_dot_describe e cia) são detalhe interno, não interface.
        string match -q '_*' -- $nome; and continue

        set -l desc (_dot_describe $nome; or echo "—")
        printf "  🔹 %-14s %s\n" $nome $desc
    end

    echo ""
    echo "ℹ️  Utilitários de dev: devutil help"
    echo "📁 Fonte: $repo"
    echo ""
end
