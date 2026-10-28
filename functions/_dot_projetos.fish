function _dot_projetos --description "Caminho real da pasta de projetos; avisa se o SSD não estiver montado"
    # $DOT_PROJECTS é o caminho de sempre (~/Projetos). Desde out/2026 ele é um
    # symlink para o SSD externo, e `find`/`fd` não entram em symlink por padrão:
    # varrendo pelo link, o nmreap e o proj voltavam vazios sem erro nenhum.
    # Quem varre usa o caminho real que esta função devolve.
    set -l base $DOT_PROJECTS
    test -n "$base"; or set base ~/Projetos

    # `test -d` segue o link: com o SSD desconectado, o link existe mas não leva
    # a lugar nenhum, e o aviso precisa dizer isso em vez de "não existe".
    if not test -d $base
        if test -L $base
            echo "💽 $base aponta para "(readlink $base)", que não está montado. Conecte o SSD." >&2
        else
            echo "❌ $base não existe." >&2
        end
        return 1
    end

    realpath $base
end
