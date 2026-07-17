function _devutil_tempmail_enter --description "Ações fzf disparadas pelo Enter, por item do menu"
    # Arquivo próprio porque o fzf chama isto num shell novo (via `transform`), e
    # shell novo só acha função que esteja num arquivo com o nome dela. Não
    # precisa dos outros helpers do tempmail — só imprime a string de ações que o
    # fzf vai aplicar, o que mantém o menu fixo (cada Enter age sem fechar o fzf).
    switch $argv[1]
        case inbox
            # Precisa do terminal (fzf da caixa, less): `execute` cede a tela ao
            # comando e devolve ao fzf quando ele termina.
            echo "execute(fish -c \"_devutil_tempmail_action inbox\")+refresh-preview+transform-header(fish -c _devutil_tempmail_header)"
        case novo
            # `execute-silent`: o fzf NÃO sai, o curl (1-2s) roda por baixo e a
            # lista continua na tela. É o que mata a tela preta ao criar.
            echo "execute-silent(fish -c \"_devutil_tempmail_action novo\")+refresh-preview+transform-header(fish -c _devutil_tempmail_header)"
        case copiar
            echo "execute-silent(fish -c \"_devutil_tempmail_action copiar\")+transform-header(fish -c \"_devutil_tempmail_header '📋 copiado'\")"
        case cred
            # As credenciais já estão no preview; nada a executar.
            echo "refresh-preview"
        case sair
            echo "abort"
    end
end
