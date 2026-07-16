function devutil_cuid --description "Gera um CUID e copia para a área de transferência"
    try_install_tool cuid-cli; or return 1
    set -l id (cuid)
    printf '%s' $id | pbcopy
    printf '\n%s\n\n📋 CUID copiado.\n\n' $id
end
