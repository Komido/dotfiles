function maccy
    set_color brcyan
    echo ""
    echo "╭────────────────────────────╮"
    echo "│     📋 Setup do Maccy      │"
    echo "╰────────────────────────────╯"
    set_color normal

    if type -q maccy
        echo "✅ Maccy já está instalado. Pulando instalação."
    else
        read -l -P "📦 Maccy não encontrado. Deseja instalar? (Y/n) " install
        if test -z "$install" -o "$install" = "Y" -o "$install" = "y"
            brew install --cask maccy
        else
            echo "⏭️ Instalação cancelada. Continuando setup..."
        end
    end

    read -l -P "⚙️ Iniciar com o sistema? (Y/n) " autostart
    if test -z "$autostart" -o "$autostart" = "Y" -o "$autostart" = "y"
        defaults write org.p0deje.Maccy launchAtLogin -bool true
    end

    read -l -P "🎯 Configurar atalho ⌃⌘V para abrir? (Y/n) " shortcut
    if test -z "$shortcut" -o "$shortcut" = "Y" -o "$shortcut" = "y"
        defaults write org.p0deje.Maccy hotkey -dict key -string "v" modifiers -array "command" "control"
    end

    read -l -P "☁️ Sincronizar histórico entre Macs? (Y/n) " sync
    if test -z "$sync" -o "$sync" = "Y" -o "$sync" = "y"
        echo "🌩️ Onde deseja salvar o histórico?"
        echo "1. iCloud Drive"
        echo "2. Dropbox"
        read -l -P "Escolha 1 ou 2: " option

        switch $option
            case "1"
                set sync_path "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Maccy"
            case "2"
                set sync_path "$HOME/Dropbox/Maccy"
            case '*'
                echo "❌ Opção inválida. Pulando sincronização."
                set sync_path ""
        end

        if test -n "$sync_path"
            mkdir -p "$sync_path"
            defaults write org.p0deje.Maccy storagePath -string "$sync_path"
            echo "✅ Histórico será salvo em: $sync_path"
        end
    end

    echo "♻️ Reiniciando o Maccy..."
    killall Maccy 2>/dev/null
    open -a Maccy
end
