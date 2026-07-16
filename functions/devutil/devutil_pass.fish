function devutil_pass --description "Gera uma senha forte aleatória (padrão: 20 caracteres)"
    set -l tamanho 20
    if test -n "$argv[1]"
        set tamanho $argv[1]
    end

    if not string match -qr '^\d+$' -- $tamanho
        echo "❌ '$tamanho' não é um número."
        return 1
    end

    if test $tamanho -lt 4
        echo "❌ Tamanho mínimo é 4 (para caber Aa1@)."
        return 1
    end

    set -l senha
    while true
        # Alfabeto sem ambíguos (0/O/o, l/1/I) — senha que vai ser lida em voz
        # alta ou digitada à mão não pode ter caractere que se confunde.
        set senha (LC_ALL=C tr -dc 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#$%&*+=?-' </dev/urandom | head -c $tamanho)

        if string match -qr '[A-Z]' -- $senha
            and string match -qr '[a-z]' -- $senha
            and string match -qr '[0-9]' -- $senha
            and string match -qr '[!@#$%&*+\-=?]' -- $senha
            break
        end
    end

    printf '%s' $senha | pbcopy
    printf '\n🔑 Senha de %s caracteres gerada e copiada:\n%s\n\n' $tamanho $senha
end
