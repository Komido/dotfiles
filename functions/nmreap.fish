function nmreap --description "Acha node_modules em ~/Projetos e libera o espaço que você escolher"
    set -l base ~/Projetos
    if test -n "$argv[1]"
        set base $argv[1]
    end

    if not test -d $base
        echo "❌ $base não existe."
        return 1
    end

    echo "🔍 Procurando node_modules em $base..."

    # -prune: para de descer assim que acha um node_modules. Sem isso a busca
    # entraria nas dependências das dependências e reportaria o mesmo espaço
    # dezenas de vezes — além de demorar uma eternidade.
    set -l pastas (find $base -type d -name node_modules -prune 2>/dev/null)

    if test (count $pastas) -eq 0
        echo "✅ Nenhum node_modules encontrado."
        return 0
    end

    echo "📦 "(count $pastas)" encontrados. Medindo..."

    set -l linhas
    for pasta in $pastas
        set -l tamanho (du -sk $pasta 2>/dev/null | cut -f1)
        test -n "$tamanho"; or continue

        set -l projeto (dirname $pasta)
        set -l nome (string replace "$base/" "" -- $projeto)

        # A data do último commit separa "projeto que dormi ontem" de "projeto que
        # não toco há dois anos" — é o dado que decide o que pode ir embora.
        set -l ultimo "sem git"
        if test -d $projeto/.git
            set ultimo (command git -C $projeto log -1 --format=%cs 2>/dev/null; or echo "sem commit")
        end

        set -a linhas (printf "%d\t%s\t%s\t%s" $tamanho (_nmreap_humano $tamanho) $ultimo $nome)
    end

    set -l total_kb 0
    for linha in $linhas
        set total_kb (math $total_kb + (string split \t -- $linha)[1])
    end

    echo ""
    echo "💾 Total ocupado: "(_nmreap_humano $total_kb)
    echo ""

    # Maior primeiro: é onde está o espaço.
    set -l ordenadas (printf '%s\n' $linhas | sort -rn -k1)

    set -l escolhidas (printf '%s\n' $ordenadas | fzf --multi --reverse --height=60% --border \
        --delimiter=\t --with-nth=2,3,4 \
        --prompt="Apagar (TAB marca vários) ▶ " \
        --header="TAB seleciona · ENTER confirma · ESC cancela │ TAMANHO · ÚLTIMO COMMIT · PROJETO")

    if test (count $escolhidas) -eq 0
        echo "🚫 Nada selecionado."
        return 0
    end

    set -l alvos
    set -l soma 0
    for escolha in $escolhidas
        set -l campos (string split \t -- $escolha)
        set -a alvos "$base/$campos[4]/node_modules"
        set soma (math $soma + $campos[1])
    end

    echo ""
    echo "🗑️  Serão apagados "(count $alvos)" node_modules ("(_nmreap_humano $soma)"):"
    for alvo in $alvos
        echo "   $alvo"
    end

    echo ""
    read -l -P "Confirma? Reversível apenas com um novo install de dependências. (s/N) " confirma

    if test "$confirma" != s -a "$confirma" != S
        echo "🚫 Cancelado."
        return 0
    end

    for alvo in $alvos
        # Confere o sufixo antes de apagar: um `rm -rf` montado a partir de string
        # não pode nunca receber um caminho que não seja um node_modules.
        if not string match -q '*/node_modules' -- $alvo
            echo "⚠️  Ignorando caminho inesperado: $alvo"
            continue
        end
        echo "   removendo $alvo"
        rm -rf $alvo
    end

    echo ""
    echo "✅ "(_nmreap_humano $soma)" liberados."
end

function _nmreap_humano --description "Converte KB em MB/GB legível"
    set -l kb $argv[1]
    if test $kb -ge 1048576
        printf '%.1f GB' (math "$kb / 1048576")
    else if test $kb -ge 1024
        printf '%.0f MB' (math "$kb / 1024")
    else
        printf '%d KB' $kb
    end
end
