function dock
    set -l cmd $argv[1]

    switch $cmd
        case hide
            defaults write com.apple.dock autohide -bool true
            killall Dock
            echo "🙈 Dock oculto automaticamente."

        case show
            defaults write com.apple.dock autohide -bool false
            killall Dock
            echo "👀 Dock sempre visível."

        case reset
            killall Dock
            echo "🔄 Dock reiniciado."

        case '*'
            echo "Uso: dock [hide|show|reset]"
    end
end
