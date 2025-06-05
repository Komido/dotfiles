function devutil_cnpj
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
end
