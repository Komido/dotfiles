function devutil_cuid
    try_install_tool cuid-cli
    set id (cuid)
    printf "%s" $id | tee /dev/tty | pbcopy
    printf "\n\n📋 CUID copiado.\n\n"
end
