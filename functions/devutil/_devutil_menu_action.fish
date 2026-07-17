function _devutil_menu_action --description "Executa o item escolhido no menu do devutil"
    # Arquivo próprio: o fzf chama isto num shell novo (via execute). Os geradores
    # (devutil_uuid etc.) são autoloadáveis um a um, então resolvem sozinhos ao
    # serem chamados; não precisa de source.
    set -l key $argv[1]
    # Cache do preview: guarda valores sensíveis (senha, etc.) em texto plano,
    # então 700 e vida curta — o _devutil_menu apaga o diretório ao sair.
    set -l dir ~/.cache/devutil-last
    mkdir -p -m 700 $dir

    switch $key
        case uuid cuid cpf cnpj pass lorem epoch
            # O gerador já copia o valor cru para o clipboard; rodo silencioso
            # (a saída decorada iria para /dev/null) e guardo o que foi copiado
            # para o preview mostrar. `pbpaste` é o valor exato que foi para a
            # área de transferência.
            # Se o gerador falhar, aborta antes do pbpaste — senão o cache
            # ganharia o que já estava no clipboard, alheio ao devutil.
            devutil_$key >/dev/null 2>&1; or return
            pbpaste | string trim >$dir/$key

        case cnpjnovo
            # Não é uma função própria: é o devutil_cnpj no modo alfanumérico.
            devutil_cnpj novo >/dev/null 2>&1; or return
            pbpaste | string trim >$dir/cnpjnovo

        case b64enc
            read -l -P "📦 texto para encode: " txt
            test -n "$txt"; or return
            devutil_base64 encode "$txt" >/dev/null 2>&1; or return
            pbpaste | string trim >$dir/b64enc

        case b64dec
            read -l -P "📦 texto (base64) para decode: " txt
            test -n "$txt"; or return
            devutil_base64 decode "$txt" >/dev/null 2>&1; or return
            pbpaste | string trim >$dir/b64dec

        case jwt
            read -l -P "🎫 token JWT: " tok
            test -n "$tok"; or return
            # Saída multilinha (header + payload); no less para não empurrar a tela.
            devutil_jwt "$tok" | less -R

        case ports
            devutil_ports

        case tempmail
            devutil_tempmail
    end
end
