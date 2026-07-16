function _devutil_cnpj_digito --description "Dígito verificador de CNPJ (módulo 11)"
    set -l digitos (string split '' -- $argv[1])

    # 12 dígitos = 1º verificador; 13 = 2º (a base já cresceu com o primeiro).
    set -l pesos 5 4 3 2 9 8 7 6 5 4 3 2
    if test (count $digitos) -eq 13
        set pesos 6 5 4 3 2 9 8 7 6 5 4 3 2
    end

    set -l soma 0
    for i in (seq (count $digitos))
        set soma (math "$soma + $digitos[$i] * $pesos[$i]")
    end

    set -l resto (math "$soma % 11")
    if test $resto -lt 2
        echo 0
    else
        math "11 - $resto"
    end
end

function devutil_cnpj --description "Gera um CNPJ válido e copia para a área de transferência"
    set -l raiz (string join '' (for i in (seq 8); random 0 9; end))
    set -l filial 0001
    set -l base "$raiz$filial"

    set -l d1 (_devutil_cnpj_digito $base)
    set -l d2 (_devutil_cnpj_digito "$base$d1")
    set -l cnpj "$base$d1$d2"

    printf '%s' $cnpj | pbcopy
    printf '\n%s\n\n📋 CNPJ válido copiado.\n\n' $cnpj
end
