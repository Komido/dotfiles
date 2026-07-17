function _devutil_menu_preview --description "Preview de cada item do menu do devutil"
    # Arquivo próprio: o fzf chama num shell novo.
    set -l key $argv[1]
    set -l last ~/.cache/devutil-last/$key

    set -l titulo ""
    set -l desc ""
    set -l acao "⏎ gera e copia."

    switch $key
        case uuid
            set titulo "🆔 UUID v4"
            set desc "Identificador único universal (aleatório)."
        case cuid
            set titulo "🔑 CUID"
            set desc "ID colisão-resistente, o mesmo do @default(cuid()) do Prisma."
        case cpf
            set titulo "👤 CPF válido"
            set desc "CPF que passa na validação de dígito (para testes)."
        case cnpj
            set titulo "🏢 CNPJ válido (numérico)"
            set desc "CNPJ no formato tradicional, só dígitos (para testes)."
        case cnpjnovo
            set titulo "🏢 CNPJ válido (alfanumérico)"
            set desc "CNPJ no padrão novo da Receita (jul/2026): raiz com letras, DVs numéricos."
        case pass
            set titulo "🔒 Senha forte"
            set desc "20 caracteres, sem ambíguos (0/O, l/1/I)."
        case lorem
            set titulo "📝 Lorem Ipsum"
            set desc "Texto placeholder (um parágrafo)."
        case epoch
            set titulo "🕐 Timestamp atual"
            set desc "Epoch em segundos, agora."
        case b64enc
            set titulo "📦 Base64 encode"
            set desc "Codifica um texto em base64."
            set acao "⏎ pede o texto e copia o resultado."
        case b64dec
            set titulo "📦 Base64 decode"
            set desc "Decodifica um base64 (aceita base64url de JWT)."
            set acao "⏎ pede o texto e copia o resultado."
        case jwt
            set titulo "🎫 JWT decode"
            set desc "Mostra header, payload e validade de um token."
            set acao "⏎ pede o token e mostra o conteúdo."
        case ports
            set titulo "🔌 Portas"
            set desc "Lista processos escutando e encerra o escolhido."
            set acao "⏎ abre a lista."
        case tempmail
            set titulo "📫 E-mail temporário"
            set desc "Cria e gerencia e-mails descartáveis (mail.tm)."
            set acao "⏎ abre o gerenciador."
        case sair
            echo "🚪 Fecha o menu."
            return 0
    end

    set_color brblue
    echo $titulo
    set_color normal
    echo ""
    echo $desc
    echo ""
    set_color brblack
    echo $acao
    set_color normal

    # Depois de gerar, mostra aqui o valor que foi copiado — é o "veja na direita
    # o que foi para a área de transferência" que o fluxo pede.
    if test -f $last
        echo ""
        set_color brgreen
        echo "✅ copiado para a área de transferência:"
        set_color normal
        echo ""
        cat $last
        # O cache não termina em newline (vem de `string trim`); fecha a linha.
        echo ""
        # Máscara só na exibição — o clipboard fica com o valor cru do cache.
        switch $key
            case cpf
                string replace -r '^(\d{3})(\d{3})(\d{3})(\d{2})$' '$1.$2.$3-$4' -- (cat $last)
            case cnpj cnpjnovo
                string replace -r '^(.{2})(.{3})(.{3})(.{4})(.{2})$' '$1.$2.$3/$4-$5' -- (cat $last)
        end
    end
end
