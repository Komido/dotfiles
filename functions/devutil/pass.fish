function devutil_pass
    set -l length 20
    if test -n "$argv[1]"
        set length $argv[1]
    end

    if test $length -lt 4
        echo "Erro: O tamanho mínimo para garantir os requisitos (Aa1@) é 4."
        return 1
    end

    set -l password ""
    while true
        # Gera senha candidata usando /dev/urandom para melhor distribuição
        # Excluindo ambíguos: 0, O, o, l, 1, I
        # Caracteres especiais permitidos: !@#$%&*+=?-
        set password (LC_ALL=C tr -dc 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#$%&*+=?-' < /dev/urandom | head -c $length)

        # Verifica requisitos: Maiúscula, Minúscula, Número, Especial
        if string match -q -r '[A-Z]' -- $password
        and string match -q -r '[a-z]' -- $password
        and string match -q -r '[0-9]' -- $password
        and string match -q -r '[!@#$%&*+\-=?]' -- $password
            break
        end
    end
    
    echo $password | pbcopy
    echo ""
    echo "🔑 Senha de $length caracteres gerada e copiada:"
    echo $password
    echo ""
end
