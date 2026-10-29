function _devutil_ejetar_forcar --description "Força a desmontagem quando só VM segura o volume, e ejeta o disco físico"
    set -l vol $argv[1]

    # Só VM sobrou? Qualquer outro processo ainda usando o volume perderia dados
    # numa desmontagem forçada, então nesse caso não ofereço.
    for linha in (_devutil_ejetar_usando $vol)
        set -l pid (string split \t -- $linha)[1]
        string match -q '*com.apple.Virtualization*' -- (ps -o comm= -p $pid 2>/dev/null); or return 1
    end

    echo "ℹ️  Só a VM do app Claude segura $vol (pasta conectada a uma conversa)."
    echo "   Forçar a desmontagem não fecha o Claude; a conversa só perde o acesso"
    echo "   à pasta até você reconectá-la."
    read -l -P "Forçar e ejetar? [s/N] " resp
    if not string match -qi 's*' -- $resp
        echo "🚫 Cancelado."
        return 0
    end

    _devutil_ejetar_desmontar $vol
end
