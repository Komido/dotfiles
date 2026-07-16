function tunnel --description "Expõe uma porta local na internet (útil para webhook de Stripe e afins)"
    set -l porta $argv[1]

    if test -z "$porta"
        # Sem porta, oferece o que está escutando: na prática você quer expor um
        # servidor que já subiu, e quase nunca lembra em que porta ele foi parar.
        if not type -q lsof
            echo "Uso: tunnel <porta>"
            return 1
        end

        set -l candidatas (lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null \
            | awk 'NR>1 { split($9, a, ":"); printf "%s\t%s\n", a[length(a)], $1 }' \
            | sort -un | head -20)

        if test (count $candidatas) -eq 0
            echo "Uso: tunnel <porta>"
            return 1
        end

        set -l escolha (printf '%s\n' $candidatas | fzf --reverse --height=40% --border \
            --delimiter=\t --with-nth=1,2 \
            --prompt="Expor qual porta? ▶ " \
            --header="PORTA · PROCESSO")

        test -n "$escolha"; or return 0
        set porta (string split \t -- $escolha)[1]
    end

    if not string match -qr '^\d+$' -- $porta
        echo "❌ '$porta' não é uma porta válida."
        return 1
    end

    # Só avisa; não impede. Um túnel para uma porta que ainda vai subir é um uso
    # legítimo — dá para deixar o túnel de pé e reiniciar o servidor à vontade.
    if type -q lsof; and not lsof -nP -iTCP:$porta -sTCP:LISTEN >/dev/null 2>&1
        echo "⚠️  Nada escutando na porta $porta ainda."
    end

    if type -q cloudflared
        echo "🌩️  Túnel via cloudflared para localhost:$porta"
        cloudflared tunnel --url http://localhost:$porta
    else if type -q ngrok
        echo "🚇 Túnel via ngrok para localhost:$porta"
        echo "ℹ️  URL pública e requisições: http://127.0.0.1:4040"
        ngrok http $porta
    else
        echo "❌ Nenhuma ferramenta de túnel encontrada."
        echo "   brew install --cask ngrok      (precisa de conta)"
        echo "   brew install cloudflared       (sem conta, URL aleatória)"
        return 1
    end
end
