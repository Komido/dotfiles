function devutil_jwt --description "Decodifica um JWT: header, payload e validade"
    if not type -q jq
        echo "❌ jq não encontrado. Instale com: brew install jq"
        return 1
    end

    if test (count $argv) -lt 1
        echo "Uso: devutil jwt <token>"
        return 1
    end

    set -l parts (string split '.' -- $argv[1])
    if test (count $parts) -lt 2
        echo "❌ Isso não parece um JWT (esperado <header>.<payload>.<assinatura>)."
        return 1
    end

    # `string collect` mantém o JSON como UM elemento: sem ele a substituição de
    # comando quebraria a saída por linhas e o `echo` a remontaria com espaços.
    set -l header (_devutil_b64url $parts[1] | string collect); or return 1
    set -l payload (_devutil_b64url $parts[2] | string collect); or return 1

    echo ""
    set_color brblue
    echo "🔖 Header"
    set_color normal
    if not echo $header | jq . 2>/dev/null
        echo "❌ Header não é JSON válido."
        return 1
    end

    echo ""
    set_color brblue
    echo "📦 Payload"
    set_color normal
    if not echo $payload | jq . 2>/dev/null
        echo "❌ Payload não é JSON válido."
        return 1
    end

    set -l exp (echo $payload | jq -r '.exp // empty' 2>/dev/null)
    if test -n "$exp"
        set -l quando (date -r $exp "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
        echo ""
        if test $exp -lt (date +%s)
            set_color brred
            echo "⛔ Token expirado em $quando"
        else
            set_color brgreen
            echo "✅ Token válido até $quando"
        end
        set_color normal
    end
    echo ""
end
