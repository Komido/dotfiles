
function devutil
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case cnpj
            source ~/.config/fish/functions/devutil/cnpj.fish
            devutil_cnpj $argv

        case cpf
            source ~/.config/fish/functions/devutil/cpf.fish
            devutil_cpf $argv

        case cuid
            source ~/.config/fish/functions/devutil/cuid.fish
            devutil_cuid $argv

        case epoch
            source ~/.config/fish/functions/devutil/epoch.fish
            devutil_epoch $argv

        case jwt
            source ~/.config/fish/functions/devutil/jwt.fish
            devutil_jwt $argv

        case tempmail
            source ~/.config/fish/functions/devutil/tempmail.fish
            tempmail $argv

        case uuid
            source ~/.config/fish/functions/devutil/uuid.fish
            devutil_uuid $argv

        case ports
            source ~/.config/fish/functions/devutil/ports.fish
            devutil_ports $argv

        case pass
            source ~/.config/fish/functions/devutil/pass.fish
            devutil_pass $argv

        case lorem
            source ~/.config/fish/functions/devutil/lorem.fish
            devutil_lorem $argv

        case base64
            source ~/.config/fish/functions/devutil/base64.fish
            devutil_base64 $argv

        case help '*'
            echo ""
            echo "🔧 devutil — utilitários para dev full stack"
            echo ""
            echo "Comandos disponíveis:"
            echo "  devutil cnpj       → Gera um CNPJ válido"
            echo "  devutil cpf        → Gera um CPF válido"
            echo "  devutil cuid       → Gera um CUID aleatório"
            echo "  devutil uuid       → Gera um UUID e copia para a área de transferência"
            echo "  devutil pass       → Gera uma senha forte aleatória"
            echo "  devutil lorem      → Gera texto Lorem Ipsum"
            echo "  devutil base64     → Encode/Decode base64"
            echo "  devutil epoch      → Converte epoch para data ou gera timestamp atual"
            echo "  devutil jwt        → Decodifica um JWT e mostra o payload"
            echo "  devutil tempmail   → Gerencia e-mails temporários (criar, inbox, ler)"
            echo "  devutil ports      → Encerra processos escutando em portas"
            echo ""
    end
end
