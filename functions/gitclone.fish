function gitclone
    if test (count $argv) -eq 0
        echo "❌ URL do repositório não informada."
        echo "ℹ️  Uso: gitclone <url-do-repositorio>"
        return 1
    end

    set url $argv[1]
    set is_ssh (string match -r '^git@|^ssh://' $url)

    echo ""
    echo "🔍 Coletando informações do repositório..."

    # Nome do projeto
    set repo_name (basename (string replace -r '\.git$' '' $url))

    echo "📦 Projeto: $repo_name"
    echo "🔗 URL: $url"

    if not test $is_ssh
        echo "🔐 Detectado protocolo HTTPS. Se possível, prefira usar SSH para evitar problemas de autenticação."
    end

    # Verifica conexão com o repositório
    set ls_remote (command git ls-remote $url 2>&1)

    if test $status -ne 0
        echo ""
        echo "❌ Falha ao acessar o repositório:"
        echo $ls_remote
        return 1
    end

    # Branch padrão
    set default_branch (echo $ls_remote | grep HEAD | awk '{print $2}' | sed 's|refs/heads/||')

    echo ""
    echo "🌳 Branch padrão: $default_branch"

    # Lista branches
    echo "🪵 Branches disponíveis:"
    echo "$ls_remote" | grep 'refs/heads/' | awk '{print "   → " $2}' | sed 's|refs/heads/||'

    echo ""
    read -P "📥 Deseja clonar o repositório \"$repo_name\" para a pasta atual? (s/n) " confirm
    if test $confirm = "s"
        git clone $url
        echo "✅ Clonado com sucesso."
    else
        echo "🚫 Clone cancelado."
    end
end
