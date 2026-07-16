function dotsetup --description "Reexecuta o install.fish dos dotfiles de qualquer lugar"
    # Descobre o repo pelo symlink que o install.fish criou, em vez de fixar um
    # caminho: o clone pode estar em qualquer pasta, e um caminho fixo aqui
    # discorda do README na primeira vez que alguém clona em outro lugar.
    set -l config_link ~/.config/fish/config.fish

    if not test -L $config_link
        echo "❌ ~/.config/fish/config.fish não é um link para o repo."
        echo "   Rode o ./install.fish (ou ./bootstrap.sh) de dentro do clone primeiro."
        return 1
    end

    set -l dotfiles (dirname (readlink $config_link))

    if not test -f $dotfiles/install.fish
        echo "❌ install.fish não encontrado em $dotfiles"
        return 1
    end

    echo "🚀 Executando o install.fish de $dotfiles..."
    fish $dotfiles/install.fish
end
