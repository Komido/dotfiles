function devutil_cpf
    function aleatorio_bloco
        set -l num (random 0 999)
        printf "%03d" $num
    end

    function calc_digito
        set -l numeros (string split '' $argv[1])
        set -l len (string length $argv[1])
        set -l peso (math "$len + 1")
        set -l soma 0
        for i in (seq (string length $argv[1]))
            set soma (math "$soma + $numeros[$i] * $peso")
            set peso (math "$peso - 1")
        end
        set resto (math "$soma % 11")
        if test $resto -lt 2
            echo 0
        else
            echo (math "11 - $resto")
        end
    end

    set n1 (aleatorio_bloco)
    set n2 (aleatorio_bloco)
    set n3 (aleatorio_bloco)

    set base "$n1$n2$n3"
    set d1 (calc_digito $base)
    set d2 (calc_digito "$base$d1")

    set cpf "$base$d1$d2"
    printf "%s" $cpf | tee /dev/tty | pbcopy
    printf "\n\n📋 CPF válido copiado.\n\n"
end
