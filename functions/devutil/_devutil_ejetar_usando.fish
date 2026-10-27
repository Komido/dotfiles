function _devutil_ejetar_usando --description "PID e comando de quem tem arquivo aberto no volume (tab-separado)"
    # lsof num ponto de montagem lista tudo aberto naquele filesystem. Com -F, a
    # saída vem por campos: uma linha 'p<pid>' seguida de 'c<comando>'.
    set -l pid ""
    for linha in (lsof -nP -Fpc -- $argv[1] 2>/dev/null)
        switch $linha
            case 'p*'
                set pid (string sub -s 2 -- $linha)
            case 'c*'
                # O próprio shell que chamou não conta: ele já saiu do volume.
                test "$pid" = "$fish_pid"; and continue
                printf '%s\t%s\n' $pid (string sub -s 2 -- $linha)
        end
    end
end
