function devutil_epoch --description "Timestamp atual, ou converte um epoch para data legível"
    if test (count $argv) -gt 0
        # Epoch em milissegundos (JS/Prisma dão isso o tempo todo) tem 13 dígitos:
        # passar direto para o `date -r` daria um ano lá no ano 55 mil.
        set -l ts $argv[1]
        if string match -qr '^\d{13}$' -- $ts
            echo "ℹ️  Detectado epoch em milissegundos; convertendo para segundos."
            set ts (math -s0 "$ts / 1000")
        end

        if not string match -qr '^\d+$' -- $ts
            echo "❌ '$argv[1]' não é um epoch numérico."
            return 1
        end

        date -r $ts "+%Y-%m-%d %H:%M:%S"
    else
        set -l agora (date +%s)
        printf '%s' $agora | pbcopy
        printf '%s\n✅ Timestamp copiado para a área de transferência.\n' $agora
    end
end
