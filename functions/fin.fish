function fin
    set path (pwd)
    osascript -e "
    tell application \"Finder\"
        activate
        open POSIX file \"$path\"
        set bounds of front window to {0, 0, 1440, 900}
    end tell"
end
