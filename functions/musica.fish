function musica --description "Controla o app Música do macOS (play, pause, volume, playlists)"
    set options "▶ Tocar playlist" "⏸ Pausar" "⏭ Próxima música" "⏮ Anterior" "🔊 Ajustar volume" "🎧 Tocando agora" "🚪 Sair"
    set selected (printf "%s\n" $options | fzf --prompt="🎵 Música > ")

    switch $selected
        case "▶ Tocar playlist"
            set playlists (osascript -e '
                tell application "Music"
                    set out to ""
                    repeat with p in playlists
                        set out to out & (get name of p) & linefeed
                    end repeat
                    return out
                end tell')

            if test -z "$playlists"
                echo "⚠️  Nenhuma playlist encontrada ou erro ao acessar o app Music."
                return
            end

            set playlist (printf "%s\n" $playlists | fzf --prompt="🎶 Playlists > ")
            if test -n "$playlist"
                osascript -e "tell application \"Music\" to play playlist \"$playlist\""
            end
        case "⏸ Pausar"
            osascript -e 'tell application "Music" to pause'
        case "⏭ Próxima música"
            osascript -e 'tell application "Music" to next track'
        case "⏮ Anterior"
            osascript -e 'tell application "Music" to previous track'
        case "🔊 Ajustar volume"
            set volume (seq 0 10 100 | fzf --prompt="🔊 Volume (0–100) > ")
            if test -n "$volume"
                osascript -e "set volume output volume $volume"
            end
        case "🎧 Tocando agora"
            osascript -e 'tell application "Music"
                if player state is playing then
                    set trackName to name of current track
                    set artistName to artist of current track
                    return trackName & " - " & artistName
                else
                    return "Nada tocando"
                end if
            end tell'
        case "🚪 Sair"
            return
    end
end
