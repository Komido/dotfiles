function devutil
    switch $argv[1]
        case cpf
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
        case cnpj
            function calc_cnpj_digit
                set -l numbers $argv[1]
                set -l weights_1 5 4 3 2 9 8 7 6 5 4 3 2
                set -l weights_2 6 5 4 3 2 9 8 7 6 5 4 3 2

                set -l weights $weights_1
                if test (string length $numbers) -eq 13
                    set weights $weights_2
                end

                set -l sum 0
                for i in (seq (string length $numbers))
                    set -l digit (string sub -s $i -l 1 $numbers)
                    set sum (math "$sum + $digit * $weights[$i]")
                end

                set -l mod (math "$sum % 11")
                if test $mod -lt 2
                    echo 0
                else
                    echo (math "11 - $mod")
                end
            end

            set root (string join "" (for i in (seq 8); random 0 9; end))
            set branch 0001
            set base "$root$branch"
            set d1 (calc_cnpj_digit $base)
            set d2 (calc_cnpj_digit "$base$d1")
            set cnpj "$base$d1$d2"

            printf "%s" $cnpj | tee /dev/tty | pbcopy
            printf "\n\n📋 CNPJ válido copiado.\n\n"

        case help '*'
            echo ""
            echo "🔧 devutil — utilitários para dev full stack"
            echo ""
            echo "Comandos disponíveis:"
            echo "  devutil cuid        → gera um CUID"
            echo "  devutil uuid        → gera um UUID"
            echo "  devutil jwt TOKEN   → decodifica um JWT (payload)"
            echo "  devutil cpf         → gera um CPF válido"
            echo "  devutil cnpj        → gera um CNPJ válido"
            echo ""
    end
end
