function _devutil_cnpj_digito --description "Dígito verificador de CNPJ (módulo 11, aceita alfanumérico)"
    set -l chars (string split '' -- $argv[1])

    # 12 caracteres = 1º verificador; 13 = 2º (a base já cresceu com o primeiro).
    set -l pesos 5 4 3 2 9 8 7 6 5 4 3 2
    if test (count $chars) -eq 13
        set pesos 6 5 4 3 2 9 8 7 6 5 4 3 2
    end

    set -l soma 0
    for i in (seq (count $chars))
        # Regra da Receita para o CNPJ alfanumérico: valor = código ASCII - 48.
        # Dígitos continuam valendo 0-9; letras valem A=17 ... Z=42.
        set -l valor (math (printf '%d' "'$chars[$i]") - 48)
        set soma (math "$soma + $valor * $pesos[$i]")
    end

    set -l resto (math "$soma % 11")
    if test $resto -lt 2
        echo 0
    else
        math "11 - $resto"
    end
end

function devutil_cnpj --description "Gera um CNPJ válido e copia — devutil cnpj novo gera o alfanumérico (jul/2026)"
    set -l raiz
    switch "$argv[1]"
        case '' numerico antigo
            set raiz (string join '' (for i in (seq 8); random 0 9; end))
        case novo alfa alfanumerico
            # Padrão alfanumérico (Receita, jul/2026): raiz e ordem aceitam A-Z,
            # só os verificadores seguem numéricos. Regenera até ter ao menos uma
            # letra — um "novo" todo numérico não serve para testar o formato.
            set -l alfabeto (string split '' 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ)
            while true
                set raiz (string join '' (for i in (seq 8); random choice $alfabeto; end))
                string match -qr '[A-Z]' -- $raiz; and break
            end
        case '*'
            echo "❌ Uso: devutil cnpj [novo]  (sem argumento gera o numérico)"
            return 1
    end

    set -l filial 0001
    set -l base "$raiz$filial"

    set -l d1 (_devutil_cnpj_digito $base)
    set -l d2 (_devutil_cnpj_digito "$base$d1")
    set -l cnpj "$base$d1$d2"

    # A máscara é só exibição; o clipboard leva o cru, que é o que se cola.
    # `.` em vez de `\d` porque no padrão novo raiz e ordem aceitam letras.
    set -l mascara (string replace -r '^(.{2})(.{3})(.{3})(.{4})(.{2})$' '$1.$2.$3/$4-$5' -- $cnpj)
    printf '%s' $cnpj | pbcopy
    printf '\n%s\n%s\n\n📋 CNPJ válido copiado (sem máscara).\n\n' $cnpj $mascara
end
