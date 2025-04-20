function maccy
    set_color brcyan
    echo ""
    echo "╭────────────────────────────╮"
    echo "│     📦 Instalando Maccy     │"
    echo "╰────────────────────────────╯"
    set_color normal

    if test -d "/Applications/Maccy.app" -o -d "$HOME/Applications/Maccy.app"
        echo "✅ Maccy já está instalado no sistema."
    else
        brew install --cask maccy
    end
end
