function devutil_uuid
    try_install_tool uuidgen brew
    set id (uuidgen | string lower)
    printf "%s" $id | tee /dev/tty | pbcopy
    printf "\n\n📋 UUID copiado.\n\n"
end
