function _dot_describe --description "Lê a --description de uma função"
    set -l nome $argv[1]

    functions -q $nome; or return 1

    # `functions -Dv` imprime 5 linhas: caminho, autoload, linha, shadowing e a
    # description crua (sem aspas nem escapes). É mais robusto que regex sobre a
    # definição reimpressa, que escapa apóstrofos como \' e quebrava o parse.
    set -l detalhes (functions -Dv $nome)
    if test (count $detalhes) -lt 5
        return 1
    end

    # A description ocupa da 5ª linha em diante (caso contenha quebras de linha).
    set -l desc (string join \n -- $detalhes[5..-1])
    if test -n "$desc"
        echo $desc
        return 0
    end

    return 1
end
