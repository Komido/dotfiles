function save_session
    set -l email $argv[1]
    set -l password $argv[2]
    set -l token $argv[3]
    mkdir -p ~/.cache
    jo -p email="$email" password="$password" token="$token" > ~/.cache/tempmail.json
end

function read_session
    set -l cache_file ~/.cache/tempmail.json
    if test -f $cache_file
        set -l email (jq -r '.email' $cache_file)
        set -l password (jq -r '.password' $cache_file)
        set -l token (jq -r '.token' $cache_file)
        echo "$email,$password,$token"
    else
        echo ""
    end
end

function create_account
    set -l domain (curl -s https://api.mail.tm/domains | jq -r '.["hydra:member"][0].domain')
    set -l email (uuidgen | string lower)@$domain
    set -l password (string split "@" $email)[1]

    echo "📧 E-mail gerado: $email"

    curl -s -X POST https://api.mail.tm/accounts \
        -H "Content-Type: application/json" \
        -d (jo address=$email password=$password) > /dev/null

    set -l login_payload "{\"address\":\"$email\",\"password\":\"$password\"}"

    set -l token (curl -s -X POST https://api.mail.tm/token \
        -H "Content-Type: application/json" \
        -d "$login_payload" | jq -r '.token')

    if test -z "$token" -o "$token" = "null"
        echo "❌ Falha ao obter token. Verifique se a conta foi criada corretamente."
        return 1
    end

    save_session $email $password $token
    echo $email | tee /dev/tty | pbcopy
    echo "✅ E-mail salvo e copiado para a área de transferência."
end

function inbox
    set -l creds (string split "," (read_session))
    set -l email $creds[1]
    set -l token $creds[3]

    if test -z "$token"
        echo "❌ Token não encontrado. Crie um e-mail primeiro."
        return
    end

    set -l messages (curl -s -H "Authorization: Bearer $token" https://api.mail.tm/messages)

    if test -z "$messages"
        echo "📭 Nenhuma mensagem encontrada ou resposta vazia."
        return
    end

    set -l ids (echo $messages | jq -r '.["hydra:member"][] | @base64')

    if test (count $ids) -eq 0
        echo "📭 Nenhuma mensagem na caixa de entrada."
        return
    end

    echo "📬 Caixa de Entrada:"
    set -l index 1
    set -l id_map

    for encoded in $ids
        set -l json (echo $encoded | base64 --decode | jq .)
        set -l from (echo $json | jq -r '.from.address')
        set -l subject (echo $json | jq -r '.subject')
        set -l msg_id (echo $json | jq -r '.id')

        echo "[$index] 📨 $from — 📌 $subject"
        set id_map[$index] $msg_id
        set index (math $index + 1)
    end

    echo -n "\n🆔 Digite o número da mensagem para ler (ou pressione Enter para sair): "
    read -l num_choice

    if test -n "$num_choice" -a "$num_choice" -ge 1 -a "$num_choice" -le (count $id_map)
        set -l selected_id $id_map[$num_choice]
        set -l message (curl -s -H "Authorization: Bearer $token" https://api.mail.tm/messages/$selected_id)
        echo $message | jq -r '"\n📩 Assunto: \(.subject)\n✉️ Conteúdo:\n\(.text)"'
    else if test -n "$num_choice"
        echo "❌ Número inválido."
    else
        echo "🚪 Saindo sem ler mensagens."
    end
end


function read_message
    set -l creds (read_session)
    set -l token (string split "," $creds)[3]

    if test -z "$token"
        echo "❌ Token não encontrado."
        return
    end

    echo -n "🆔 Informe o ID da mensagem: "
    read -l id
    set -l message (curl -s -H "Authorization: Bearer $token" https://api.mail.tm/messages/$id)
    echo $message | jq -r '"\n📩 Assunto: \(.subject)\n✉️ Conteúdo:\n\(.text)"'
end

function show_credentials
    set -l cache_file ~/.cache/tempmail.json
    if test -f $cache_file
        echo "🔐 Credenciais salvas:"
        cat $cache_file | jq
    else
        echo "❌ Nenhuma credencial encontrada."
    end
end

function tempmail
    echo ""
    echo "📫 TEMPMAIL — E-mail temporário para testes"
    echo "1) Novo e-mail temporário"
    echo "2) Ver caixa de entrada"
    echo "3) Ler mensagem (ID manual)"
    echo "4) Ver credenciais salvas"
    echo ""

    echo -n "Escolha uma opção (1/2/3/4): "
    read -l choice

    switch $choice
        case 1
            create_account
        case 2
            inbox
        case 3
            read_message
        case 4
            show_credentials
        case '*'
            echo "❌ Opção inválida."
    end
end
