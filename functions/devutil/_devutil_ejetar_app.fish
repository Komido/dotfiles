function _devutil_ejetar_app --description "Nome do .app do processo, ou do ancestral mais próximo que seja um"
    # Sobe pela árvore de processos até achar um executável dentro de um .app.
    # Com --pai, olha só o pai direto: o shell aberto pelo próprio app (terminal
    # integrado do VS Code) tem o app como pai; o do Ghostty/Terminal passa pelo
    # `login` antes, então não casa.
    set -l pid $argv[1]
    # VM do Virtualization.framework (app Claude com pasta conectada, Docker
    # Desktop): roda sob o launchd, então a subida pela árvore não acha o dono.
    if string match -q '*com.apple.Virtualization*' -- (ps -o comm= -p $pid 2>/dev/null)
        echo "VM (Claude/Docker)"
        return 0
    end
    set -l niveis 8
    if test "$argv[2]" = --pai
        set pid (string trim -- (ps -o ppid= -p $pid 2>/dev/null))
        set niveis 1
    end

    for i in (seq $niveis)
        if test -z "$pid"; or test "$pid" -le 1
            return 1
        end
        set -l app (string match -r -g '/([^/]+)\.app/' -- (ps -o comm= -p $pid 2>/dev/null))[1]
        if test -n "$app"
            echo $app
            return 0
        end
        set pid (string trim -- (ps -o ppid= -p $pid 2>/dev/null))
    end
    return 1
end
