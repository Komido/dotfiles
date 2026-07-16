function devutil_uuid --description "Gera um UUID v4 e copia para a área de transferência"
    # uuidgen vem com o macOS; não há o que instalar.
    set -l id (uuidgen | string lower)
    printf '%s' $id | pbcopy
    printf '\n%s\n\n📋 UUID copiado.\n\n' $id
end
