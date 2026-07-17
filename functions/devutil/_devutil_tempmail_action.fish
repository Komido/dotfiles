function _devutil_tempmail_action --description "Executa a ação do item escolhido no menu"
    # Arquivo próprio porque o fzf chama isto num shell novo (via execute). Ao
    # contrário do _enter, esta função USA os helpers do arquivo principal (a
    # caixa, o criar), que um shell novo não carrega ao chamar só por aqui — daí
    # o source, guardado para não reprocessar se já estiver carregado.
    if not functions -q _devutil_tempmail_inbox
        source $__fish_config_dir/functions/devutil/devutil_tempmail.fish
    end

    switch $argv[1]
        case inbox
            _devutil_tempmail_inbox
        case novo
            _devutil_tempmail_criar
        case copiar
            _devutil_tempmail_copiar
    end
end
