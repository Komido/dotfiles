function _devutil_tempmail_menu_preview --description "Preview de cada item do menu do tempmail"
    # Arquivo próprio pelo mesmo motivo do preview da caixa: o fzf chama o preview
    # num shell novo, que só enxerga funções resolvidas por autoload.
    set -l key $argv[1]
    set -l cache ~/.cache/tempmail.json
    set -l email (jq -r '.email // empty' $cache 2>/dev/null)

    switch $key
        case inbox
            set_color brblue
            echo "📥 Caixa de entrada"
            set_color normal
            echo ""
            echo "Abre a lista navegável de mensagens, com o"
            echo "conteúdo de cada uma no painel ao lado."

        case novo
            set_color brblue
            echo "✨ Novo e-mail temporário"
            set_color normal
            echo ""
            if test -n "$email"
                set_color bryellow
                echo "⚠️  Substitui o endereço atual:"
                set_color normal
                echo "   $email"
            else
                echo "Gera o primeiro endereço temporário."
            end

        case copiar
            if test -n "$email"
                set_color brblue
                echo "📋 Copiar endereço"
                set_color normal
                echo ""
                set_color brgreen
                echo "$email"
                set_color normal
                echo ""
                echo "⏎ copia para a área de transferência."
            else
                echo "Nenhuma sessão ainda."
                echo "Crie um e-mail primeiro (✨)."
            end

        case cred
            if test -f $cache
                set_color brblue
                echo "🔐 Credenciais salvas"
                set_color normal
                echo ""
                # A mesma info que antes era despejada no terminal, agora só aqui.
                jq . $cache
            else
                echo "Nenhuma credencial salva ainda."
            end

        case sair
            echo "🚪 Fecha o tempmail."
    end
end
