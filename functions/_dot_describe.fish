function _dot_describe --description "Lê a --description de uma função"
    set -l nome $argv[1]

    functions -q $nome; or return 1

    # O fish não expõe a description por flag, mas `functions <nome>` reimprime a
    # definição já normalizada — com a description entre aspas simples,
    # independente de como foi escrita no arquivo.
    for linha in (functions $nome)
        set -l desc (string match -rg -- "--description '([^']*)'" $linha)
        if test -n "$desc"
            echo $desc
            return 0
        end
    end

    return 1
end
