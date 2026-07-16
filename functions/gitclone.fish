function gitclone --description "Mostra os dados do repositório remoto e clona em ~/Projetos"
    if test (count $argv) -eq 0
        echo "❌ URL do repositório não informada."
        echo "ℹ️  Uso: gitclone <url-do-repositorio>"
        return 1
    end

    set -l url $argv[1]
    set -l destino ~/Projetos
    set -l nome (basename (string replace -r '\.git$' '' -- $url))

    echo ""
    echo "🔍 Coletando informações do repositório..."
    echo ""
    echo "📦 Projeto: $nome"
    echo "🔗 URL: $url"
    echo "📁 Destino: $destino/$nome"

    if not string match -qr '^(git@|ssh://)' -- $url
        echo "🔐 Protocolo HTTPS detectado. Se possível, prefira SSH."
    end

    if test -e $destino/$nome
        echo ""
        echo "❌ $destino/$nome já existe. Escolha outro destino ou remova a pasta."
        return 1
    end

    # --symref faz o remoto dizer para onde o HEAD aponta, numa linha própria:
    #   ref: refs/heads/main	HEAD
    # Sem ela, o HEAD vem só como um SHA, e era daí que saía o bug: o código
    # antigo pegava a linha do HEAD e lia o campo 2, que é o literal "HEAD" —
    # a função reportava "branch padrão: HEAD" em todo repositório do mundo.
    set -l refs (command git ls-remote --symref $url 2>&1)
    if test $status -ne 0
        echo ""
        echo "❌ Falha ao acessar o repositório:"
        printf '%s\n' $refs
        return 1
    end

    # `string match` sobre a LISTA, sem passar por `echo`: $refs tem uma linha por
    # elemento, e `echo $refs` juntava tudo numa linha só separada por espaço —
    # era o que fazia o awk ler o campo errado.
    set -l branch_padrao (string match -rg '^ref: refs/heads/(\S+)\s+HEAD$' -- $refs)
    set -l branches (string match -rg '^[0-9a-f]+\s+refs/heads/(\S+)$' -- $refs)

    echo ""
    if test -n "$branch_padrao"
        echo "🌳 Branch padrão: $branch_padrao"
    else
        echo "🌳 Branch padrão: (não informado pelo remoto)"
    end

    if test (count $branches) -gt 0
        echo "🪵 Branches disponíveis ("(count $branches)"):"
        for b in $branches
            if test "$b" = "$branch_padrao"
                echo "   → $b (padrão)"
            else
                echo "   → $b"
            end
        end
    end

    echo ""
    read -l -P "📥 Clonar \"$nome\" em $destino? (S/n) " confirma

    # Com aspas: sem elas, um Enter vazio vira `test = s` e o test reclama de
    # argumento faltando em vez de simplesmente cancelar.
    if test -n "$confirma" -a "$confirma" != s -a "$confirma" != S -a "$confirma" != y -a "$confirma" != Y
        echo "🚫 Clone cancelado."
        return 0
    end

    mkdir -p $destino
    if not command git clone $url $destino/$nome
        echo "❌ Falha ao clonar."
        return 1
    end

    echo "✅ Clonado em: $destino/$nome"
end
