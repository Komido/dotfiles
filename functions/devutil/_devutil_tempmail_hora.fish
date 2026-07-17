function _devutil_tempmail_hora --description "Converte o createdAt (UTC) do mail.tm para a hora local"
    # Arquivo próprio: usado tanto pela lista (arquivo principal) quanto pelo
    # preview (shell novo), então precisa resolver por autoload nos dois.
    #
    # O mail.tm devolve createdAt em UTC (…T16:13:06+00:00). Exibir cru mostrava
    # 3h a mais no horário de Brasília. Aqui: pega data+hora, interpreta como UTC
    # (-u) para virar epoch, e o `date -r` reformata no fuso local da máquina.
    set -l iso $argv[1]
    set -l fmt $argv[2]
    test -n "$fmt"; or set fmt "%H:%M"

    set -l dt (string match -rg '^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})' -- $iso)
    if test -z "$dt"
        echo $iso
        return
    end

    set -l epoch (date -j -u -f "%Y-%m-%dT%H:%M:%S" "$dt" "+%s" 2>/dev/null)
    if test -z "$epoch"
        echo $iso
        return
    end

    date -r $epoch "+$fmt"
end
