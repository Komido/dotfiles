function _devutil_tempmail_header --description "Cabeçalho do menu (endereço atual + aviso opcional)"
    # Arquivo próprio e AUTOSSUFICIENTE: o fzf chama isto num shell novo (via
    # transform-header), então lê o cache direto com jq em vez de depender de
    # _devutil_tempmail_email, que vive no arquivo principal e não estaria
    # carregado nesse shell.
    set -l email (jq -r '.email // empty' ~/.cache/tempmail.json 2>/dev/null)
    set -l base "📫 tempmail — nenhuma sessão ainda"
    test -n "$email"; and set base "📧 $email"
    test (count $argv) -gt 0; and set base "$base   ·   $argv[1]"
    echo $base
end
