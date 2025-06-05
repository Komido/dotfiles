function devutil_ports
    set -l script_version "4.0.3"

    if not type -q lsof
        echo "❌ lsof não encontrado. Instale com: brew install lsof"
        return 1
    end

    # Cabeçalho bonito e organizado
    set -l header (printf "📦 COMANDO           │ 🔢 PID │🌐 PORTA — v%s" $script_version)

    # Processos ouvindo conexões TCP
    set -l processes (lsof -nP -iTCP -sTCP:LISTEN | awk 'NR>1 { printf "%-20s │ %-6s │ %s\n", $1, $2, $9 }' | sort -u)

    if test (count $processes) -eq 0
        echo "⚠️ Nenhuma porta em uso detectada."
        return
    end

    # FZF com melhor aparência
    set -l selected (printf "%s\n" $processes | fzf --ansi --reverse --height=40% --border \
        --prompt="Selecione o processo para encerrar ▶ " \
        --header="$header")

    if test -z "$selected"
        echo "❌ Nenhum processo selecionado."
        return
    end

    set -l pid (echo $selected | awk -F '│' '{print $2}' | tr -d ' ')
    set -l port (echo $selected | awk -F '│' '{print $3}' | tr -d ' ')

    echo ""
    echo "🔍 Encerrando processo PID $pid (porta $port)..."
    kill -9 $pid
    echo "✅ Processo $pid finalizado."
end
