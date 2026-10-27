function _devutil_menu_enter --description "Ação fzf disparada pelo Enter, por item do menu do devutil"
    # Roda dentro de um `transform`; a saída são as ações que o fzf aplica. É o
    # que mantém o menu fixo: cada Enter age sem fechar o fzf.
    switch $argv[1]
        case uuid cuid cpf cnpj cnpjnovo pass lorem epoch
            # Geradores: `execute-silent` roda a geração sem o fzf sair, e
            # `refresh-preview` atualiza o painel com o valor recém-copiado.
            echo "execute-silent(fish -c \"_devutil_menu_action $argv[1]\")+refresh-preview"
        case b64enc b64dec jwt ports tempmail
            # Precisam do terminal (prompt de input, less, fzf próprio): `execute`
            # cede a tela e devolve ao fzf ao terminar.
            echo "execute(fish -c \"_devutil_menu_action $argv[1]\")+refresh-preview"
        case ejetar
            # `become` troca o fzf pelo ejetar (mesmo PID): o menu não fica
            # aberto segurando o volume, e o ejetar já se exclui da lista.
            echo "become(fish -c \"devutil_ejetar\")"
        case sair
            echo "abort"
    end
end
