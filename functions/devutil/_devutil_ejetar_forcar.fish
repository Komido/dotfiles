function _devutil_ejetar_forcar --description "Força a desmontagem quando só VM segura o volume, e ejeta o disco físico"
    set -l vol $argv[1]

    # Só VM sobrou? Qualquer outro processo ainda usando o volume perderia dados
    # numa desmontagem forçada, então nesse caso não ofereço.
    for linha in (_devutil_ejetar_usando $vol)
        set -l pid (string split \t -- $linha)[1]
        string match -q '*com.apple.Virtualization*' -- (ps -o comm= -p $pid 2>/dev/null); or return 1
    end

    # A VM pode ser do Docker Desktop, e aí um container (banco num bind mount)
    # pode estar gravando no volume: forçar seria arriscar corromper dados.
    if pgrep -f 'Docker.app/Contents' >/dev/null
        echo "⚠️  O Docker Desktop está rodando: pare os containers que usam $vol"
        echo "   (ou feche o Docker) antes de ejetar. Não forço com ele aberto."
        return 1
    end

    echo "ℹ️  Só a VM do app Claude segura $vol (pasta conectada a uma conversa)."
    echo "   Forçar a desmontagem não fecha o Claude; a conversa só perde o acesso"
    echo "   à pasta até você reconectá-la."
    read -l -P "Forçar e ejetar? [s/N] " resp
    if not string match -qi 's*' -- $resp
        echo "🚫 Cancelado."
        return 0
    end

    # Guardo o disco físico antes: depois de desmontar, o volume não responde
    # mais ao `diskutil info`. Volume APFS encriptado fica num container
    # sintetizado; o que se ejeta é o disco físico por baixo dele.
    set -l store (diskutil info $vol | string match -r -g 'APFS Physical Store:\s+(\S+)')[1]
    set -l disco (string replace -r 's\d+$' '' -- $store)

    if not diskutil unmount force $vol >/dev/null 2>&1
        echo "❌ Nem forçando consegui desmontar $vol."
        return 1
    end

    if test -n "$disco"; and diskutil eject $disco >/dev/null 2>&1
        echo "✅ $vol ejetado. Pode desconectar."
    else
        echo "✅ $vol desmontado. Ejete '$vol' pelo Finder antes de desconectar."
    end
    return 0
end
