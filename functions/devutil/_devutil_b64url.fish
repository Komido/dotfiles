function _devutil_b64url --description "Decodifica base64url (JWT) repondo o padding"
    set -l data (string replace -a -- '-' '+' $argv[1] | string replace -a -- '_' '/')

    # JWT é base64url SEM padding, e o `base64` do macOS exige o padding. Sem
    # esta reposição ele não falha: retorna status 0 e TRUNCA os últimos bytes
    # em silêncio, entregando um JSON cortado que só estoura lá na frente, no
    # jq. Só passava quando o tamanho calhava de ser múltiplo de 4.
    switch (math (string length -- $data) % 4)
        case 2
            set data "$data=="
        case 3
            set data "$data="
        case 1
            echo "❌ Segmento base64url inválido: tamanho impossível." >&2
            return 1
    end

    printf '%s' $data | base64 --decode
end
