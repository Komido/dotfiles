function devutil --description "Utilitários para dev: uuid, cpf, cnpj, jwt, pass, ports, tempmail..."
    set -l cmd $argv[1]
    set -e argv[1]

    switch "$cmd"
        case ''
            # Sem argumento abre o menu interativo em fzf; `devutil <nome>`
            # continua rodando direto, para quem já sabe o que quer.
            _devutil_menu
            return 0
        case help --help -h
            _devutil_help
            return 0
    end

    # Despacho por nome: `devutil uuid` → `devutil_uuid`, resolvido pelo autoload
    # (a subpasta está no $fish_function_path, registrada no config.fish).
    #
    # A versão anterior tinha um `case` por subcomando com
    # `source ~/.config/fish/functions/devutil/x.fish` — caminho fixo, relido do
    # disco a cada chamada, e contradizendo o dotsetup, que justamente descobre o
    # repo sozinho para não fixar caminho. Cada utilitário novo exigia editar
    # este arquivo em dois lugares (o case e o texto de ajuda).
    if not functions -q devutil_$cmd
        echo "❌ Subcomando desconhecido: $cmd"
        echo ""
        _devutil_help
        return 1
    end

    devutil_$cmd $argv
end

function _devutil_menu --description "Menu interativo do devutil (fzf persistente)"
    for dep in fzf
        if not type -q $dep
            echo "❌ $dep não encontrado. Instale com: brew install $dep"
            return 1
        end
    end

    # Um único fzf, fixo: cada Enter roda uma ação via bind sem fechar o menu.
    # Geradores mostram o valor copiado no preview; base64/jwt pedem o input.
    # O $SHELL aqui é o zsh (o fzf roda os binds por ele), então cada bind chama
    # `fish -c` explicitamente para achar as funções, que são do fish.
    _devutil_menu_itens | fzf \
        --delimiter=\t --with-nth=2 --ansi \
        --height=90% --reverse --border \
        --prompt="🔧 " --header="devutil — Enter age · Esc sai" \
        --preview='fish -c "_devutil_menu_preview {1}"' \
        --preview-window=right,55%,wrap \
        --bind='enter:transform:fish -c "_devutil_menu_enter {1}"'

    # Os valores gerados (inclusive senhas) ficam em texto plano nesse cache
    # só para o preview; apagar ao sair para nada sensível sobreviver ao menu.
    rm -rf ~/.cache/devutil-last
end

function _devutil_menu_itens --description "Linhas do menu do devutil (id + rótulo)"
    printf 'uuid\t🆔 UUID v4\n'
    printf 'cuid\t🔑 CUID\n'
    printf 'cpf\t👤 CPF válido\n'
    printf 'cnpj\t🏢 CNPJ válido\n'
    printf 'pass\t🔒 Senha forte\n'
    printf 'lorem\t📝 Lorem Ipsum\n'
    printf 'epoch\t🕐 Timestamp atual\n'
    printf 'b64enc\t📦 Base64 encode\n'
    printf 'b64dec\t📦 Base64 decode\n'
    printf 'jwt\t🎫 JWT decode\n'
    printf 'ports\t🔌 Portas — matar processo\n'
    printf 'tempmail\t📫 E-mail temporário\n'
    printf 'sair\t🚪 Sair\n'
end

function _devutil_help --description "Ajuda do devutil, montada a partir dos arquivos"
    echo ""
    echo "🔧 devutil — utilitários para dev full stack"
    echo ""
    echo "Uso: devutil <subcomando> [args]"
    echo ""

    # A lista vem dos arquivos e das suas --description: um utilitário novo
    # aparece aqui sozinho, sem editar este arquivo — que era exatamente como a
    # ajuda antiga apodreceu.
    for arquivo in $__fish_config_dir/functions/devutil/devutil_*.fish
        set -l nome (string replace -r '\.fish$' '' -- (basename $arquivo))
        set -l sub (string replace 'devutil_' '' -- $nome)
        set -l desc (_dot_describe $nome; or echo "—")
        printf "  %-11s → %s\n" $sub $desc
    end

    echo ""
end
