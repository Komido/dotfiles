function _devutil_ejetar_pasta --description "Pasta atual (cwd) do processo, relativa ao volume"
    set -l cwd (lsof -a -nP -p $argv[1] -d cwd -Fn 2>/dev/null | string match -r -g '^n(.*)')[1]
    test -n "$cwd"; or return 1
    # /Volumes/Dev/Projetos/x vira Projetos/x; fora do volume fica o caminho todo.
    # `string replace` sai com status 1 quando não troca nada; o caminho já foi
    # impresso, então o status não pode vazar e disparar o fallback de quem chama.
    string replace -- "$argv[2]/" "" $cwd
    return 0
end
