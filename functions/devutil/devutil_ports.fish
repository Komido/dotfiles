function devutil_ports --description "Lista processos escutando em portas TCP e encerra o escolhido"
    if not type -q lsof
        echo "❌ lsof não encontrado (deveria vir com o macOS)."
        return 1
    end

    set -l processos (lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 { printf "%-20s │ %-6s │ %s\n", $1, $2, $9 }' | sort -u)

    if test (count $processos) -eq 0
        echo "⚠️  Nenhuma porta em uso detectada."
        return 0
    end

    set -l selecionado (printf "%s\n" $processos | fzf --ansi --reverse --height=40% --border \
        --prompt="Encerrar processo ▶ " \
        --header="📦 COMANDO           │ 🔢 PID  │ 🌐 PORTA")

    if test -z "$selecionado"
        echo "🚫 Cancelado."
        return 0
    end

    set -l pid (string split '│' -- $selecionado)[2]
    set pid (string trim -- $pid)
    set -l porta (string trim -- (string split '│' -- $selecionado)[3])
    set -l nome (string trim -- (string split '│' -- $selecionado)[1])

    # kill -9 não deixa o processo rodar handler de saída: um servidor perde o
    # flush de log e um banco pode deixar lock para trás. Pede educadamente
    # primeiro e só apela se o processo ignorar.
    echo "🔍 Encerrando $nome (PID $pid, porta $porta)..."
    if not kill $pid 2>/dev/null
        echo "❌ Não foi possível sinalizar o PID $pid."
        return 1
    end

    for i in (seq 10)
        if not kill -0 $pid 2>/dev/null
            echo "✅ Processo $pid encerrado."
            return 0
        end
        sleep 0.2
    end

    echo "⚠️  PID $pid ignorou o SIGTERM; forçando com SIGKILL."
    kill -9 $pid 2>/dev/null
    echo "✅ Processo $pid finalizado."
end
