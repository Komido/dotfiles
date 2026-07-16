function wt --description "Git worktrees: troca, cria e remove sem mexer no que você está fazendo"
    if not command git rev-parse --git-dir >/dev/null 2>&1
        echo "❌ Não é um repositório git."
        return 1
    end

    set -l cmd $argv[1]
    set -e argv[1]

    switch "$cmd"
        case '' switch
            _wt_switch
        case new add
            _wt_new $argv
        case rm remove
            _wt_rm
        case list ls
            command git worktree list
        case pr
            _wt_pr $argv
        case help --help -h
            _wt_help
        case '*'
            echo "❌ Subcomando desconhecido: $cmd"
            echo ""
            _wt_help
            return 1
    end
end

function _wt_help --description "Ajuda do wt"
    echo ""
    echo "🌲 wt — git worktrees"
    echo ""
    echo "  wt             → troca de worktree (fzf)"
    echo "  wt new <branch> → cria worktree para a branch (existente ou nova)"
    echo "  wt pr <número>  → cria worktree com o PR do GitHub (precisa do gh)"
    echo "  wt rm          → remove um worktree (fzf)"
    echo "  wt list        → lista os worktrees"
    echo ""
    echo "Worktree é um segundo diretório de trabalho do MESMO repositório: dá para"
    echo "revisar um PR sem stashear, sem trocar de branch e sem rebuildar o que já"
    echo "estava compilado na sua branch atual."
    echo ""
end

function _wt_raiz --description "Diretório onde os worktrees deste repo são criados"
    # Irmão do repo, e não dentro dele: um worktree criado no próprio diretório
    # entra no `find`/`fd` das ferramentas, polui o watcher do dev server e ainda
    # é fácil de commitar por engano.
    set -l principal (command git worktree list --porcelain | string match -rg '^worktree (.+)$' | head -1)
    echo (dirname $principal)/(basename $principal).worktrees
end

function _wt_switch --description "Troca de worktree via fzf"
    set -l linhas (command git worktree list)

    if test (count $linhas) -le 1
        echo "ℹ️  Só existe o worktree principal. Crie um com: wt new <branch>"
        return 0
    end

    set -l escolha (printf '%s\n' $linhas | fzf --reverse --height=40% --border \
        --prompt="Ir para ▶ " --header="CAMINHO · COMMIT · BRANCH")

    test -n "$escolha"; or return 0

    set -l destino (string split ' ' -- $escolha)[1]
    cd $destino
    echo "📂 "(pwd)
end

function _wt_new --description "Cria um worktree para uma branch"
    set -l branch $argv[1]

    if test -z "$branch"
        echo "Uso: wt new <branch>"
        return 1
    end

    set -l raiz (_wt_raiz)
    set -l destino $raiz/(string replace -a '/' '-' -- $branch)

    if test -e $destino
        echo "❌ $destino já existe."
        return 1
    end

    mkdir -p $raiz

    # Branch remota existente → rastreia. Nova → cria a partir do HEAD.
    if command git show-ref --verify --quiet refs/heads/$branch
        command git worktree add $destino $branch
    else if command git ls-remote --exit-code --heads origin $branch >/dev/null 2>&1
        command git worktree add $destino -b $branch --track origin/$branch
    else
        echo "🌱 Branch '$branch' não existe; criando a partir do HEAD."
        command git worktree add $destino -b $branch
    end
    or return 1

    cd $destino
    echo "📂 "(pwd)
end

function _wt_pr --description "Cria um worktree a partir de um PR do GitHub"
    set -l numero $argv[1]

    if not type -q gh
        echo "❌ gh não encontrado. Instale com: brew install gh"
        return 1
    end

    if test -z "$numero"
        set -l escolha (gh pr list --limit 30 | fzf --reverse --height=40% --border \
            --prompt="Qual PR? ▶ ")
        test -n "$escolha"; or return 0
        set numero (string split \t -- $escolha)[1]
    end

    set -l branch (gh pr view $numero --json headRefName -q .headRefName 2>/dev/null)
    if test -z "$branch"
        echo "❌ PR #$numero não encontrado."
        return 1
    end

    echo "🔀 PR #$numero → branch $branch"
    command git fetch origin $branch
    _wt_new $branch
end

function _wt_rm --description "Remove um worktree via fzf"
    set -l linhas (command git worktree list | tail -n +2)

    if test (count $linhas) -eq 0
        echo "ℹ️  Nenhum worktree além do principal."
        return 0
    end

    set -l escolha (printf '%s\n' $linhas | fzf --reverse --height=40% --border \
        --prompt="Remover ▶ " --header="CAMINHO · COMMIT · BRANCH")

    test -n "$escolha"; or return 0

    set -l alvo (string split ' ' -- $escolha)[1]

    # Sai de dentro antes de remover: apagar o diretório em que você está deixa o
    # shell num cwd que não existe mais, e todo comando seguinte falha.
    if string match -q "$alvo*" -- (pwd)
        cd (command git worktree list --porcelain | string match -rg '^worktree (.+)$' | head -1)
        echo "📂 Voltando para "(pwd)
    end

    # Sem --force de graça: o git recusa se houver alteração não commitada, e é
    # exatamente isso que você quer que aconteça.
    if not command git worktree remove $alvo
        echo ""
        echo "⚠️  O git recusou — provavelmente há trabalho não commitado em $alvo."
        read -l -P "Remover mesmo assim, perdendo o que estiver lá? (s/N) " confirma
        if test "$confirma" = s -o "$confirma" = S
            command git worktree remove --force $alvo
        else
            echo "🚫 Mantido."
            return 0
        end
    end

    echo "✅ Worktree removido."
end
