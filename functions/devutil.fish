function devutil --description "Utilitários para dev: uuid, cpf, cnpj, jwt, pass, ports, tempmail..."
    set -l cmd $argv[1]
    set -e argv[1]

    switch "$cmd"
        case '' help --help -h
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
