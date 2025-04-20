function devutil
    switch $argv[1]
        case cuid
            try_install_tool cuid-cli
            set id (cuid)
            echo $id | tee /dev/tty | pbcopy
            echo "📋 CUID copiado para a área de transferência."

        case uuid
            try_install_tool uuidgen brew
            set id (uuidgen | string lower)
            echo $id | tee /dev/tty | pbcopy
            echo "📋 UUID copiado para a área de transferência."

        case jwt
            try_install_tool jq brew
            if test (count $argv) -lt 2
                echo "📥 Informe o token JWT para decodificar:"
                return 1
            end
            echo $argv[2] | cut -d "." -f2 | base64 --decode | jq .

        case help '*'
            echo ""
            echo "🔧 devutil — utilitários para dev full stack"
            echo ""
            echo "Comandos disponíveis:"
            echo "  devutil cuid        → gera um CUID"
            echo "  devutil uuid        → gera um UUID"
            echo "  devutil jwt TOKEN   → decodifica um JWT (payload)"
            echo ""
    end
end
