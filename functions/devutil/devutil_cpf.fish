function _devutil_cpf_digito --description "Dígito verificador de CPF (módulo 11)"
    set -l numeros (string split '' -- $argv[1])
    set -l peso (math (count $numeros) + 1)
    set -l soma 0

    for n in $numeros
        set soma (math "$soma + $n * $peso")
        set peso (math "$peso - 1")
    end

    set -l resto (math "$soma % 11")
    if test $resto -lt 2
        echo 0
    else
        math "11 - $resto"
    end
end

function devutil_cpf --description "Gera um CPF válido e copia para a área de transferência"
    set -l base
    while true
        set base (string join '' (for i in (seq 9); random 0 9; end))

        # CPF de dígitos repetidos (111.111.111-11 e cia) passa no módulo 11, mas
        # é rejeitado por qualquer validador de verdade — inclusive o da Receita.
        # Gerar um deles daria um CPF "válido" que falha no primeiro formulário.
        if not string match -qr '^(.)\1{8}$' -- $base
            break
        end
    end

    set -l d1 (_devutil_cpf_digito $base)
    set -l d2 (_devutil_cpf_digito "$base$d1")
    set -l cpf "$base$d1$d2"

    # A máscara é só exibição; o clipboard leva o cru, que é o que se cola.
    set -l mascara (string replace -r '^(\d{3})(\d{3})(\d{3})(\d{2})$' '$1.$2.$3-$4' -- $cpf)
    printf '%s' $cpf | pbcopy
    printf '\n%s\n%s\n\n📋 CPF válido copiado (sem máscara).\n\n' $cpf $mascara
end
