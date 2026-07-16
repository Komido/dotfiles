function dotdoctor --description "Diagnostica o ambiente: binário sombreado, link órfão, drift do Brewfile"
    set -g _dotdoctor_problemas 0
    set -g _dotdoctor_avisos 0

    echo ""
    set_color -o
    echo "🩺 dotdoctor"
    set_color normal

    _dotdoctor_sessao
    _dotdoctor_path_sombreado
    _dotdoctor_path_inexistente
    _dotdoctor_links_orfaos
    _dotdoctor_brewfile
    _dotdoctor_brew_orfaos
    _dotdoctor_descricoes

    echo ""
    if test $_dotdoctor_problemas -gt 0
        set_color -o brred
        echo "❌ $_dotdoctor_problemas problema(s) e $_dotdoctor_avisos aviso(s)."
        set_color normal
    else if test $_dotdoctor_avisos -gt 0
        set_color -o bryellow
        echo "⚠️  Nenhum problema, $_dotdoctor_avisos aviso(s)."
        set_color normal
    else
        set_color -o brgreen
        echo "✅ Ambiente saudável."
        set_color normal
    end
    echo ""

    set -l saida $_dotdoctor_problemas
    set -e _dotdoctor_problemas
    set -e _dotdoctor_avisos
    return $saida
end

function _dotdoctor_titulo
    echo ""
    set_color brblue
    echo "── $argv[1]"
    set_color normal
end

function _dotdoctor_erro
    set_color brred
    echo "  ❌ $argv[1]"
    set_color normal
    set _dotdoctor_problemas (math $_dotdoctor_problemas + 1)
end

function _dotdoctor_aviso
    set_color bryellow
    echo "  ⚠️  $argv[1]"
    set_color normal
    set _dotdoctor_avisos (math $_dotdoctor_avisos + 1)
end

function _dotdoctor_ok
    set_color brgreen
    echo "  ✅ $argv[1]"
    set_color normal
end

function _dotdoctor_repo --description "Descobre o repo dos dotfiles pelo symlink do config"
    set -l link $__fish_config_dir/config.fish
    test -L $link; or return 1
    dirname (readlink $link)
end

function _dotdoctor_sessao --description "Confere se esta sessão está rodando a versão de fish que está no disco"
    _dotdoctor_titulo "Sessão"

    set -l no_disco (fish --version | string match -rg 'version ([0-9.]+)')

    if test -n "$no_disco" -a "$version" != "$no_disco"
        _dotdoctor_erro "Esta sessão roda o fish $version, mas o disco tem o $no_disco."
        echo "     A sessão é zumbi: as setas e algumas funções vão falhar."
        echo "     Correção: exec fish"
    else
        _dotdoctor_ok "fish $version — sessão em dia com o disco."
    end

    # Não se checa aqui se cada pasta do $fish_function_path existe: o fish já
    # nasce apontando para vendor_functions.d de vários prefixos que podem não
    # existir, e isso é normal — a primeira versão desta função acusava 4 erros
    # falsos por causa disso. O zumbi de sessão é pego pela versão, acima.
end

function _dotdoctor_path_sombreado --description "Acha binários do Homebrew sombreados por instalação manual"
    _dotdoctor_titulo "Binários sombreados no PATH"

    if not type -q brew
        _dotdoctor_aviso "brew não encontrado; pulando."
        return
    end

    set -l prefixo (brew --prefix)
    set -l achou 0

    # Varre o que o brew instalou e pergunta quem o PATH escolhe de verdade.
    # Se a resposta não for o binário do brew, alguém está na frente dele — foi
    # exatamente o caso do zoxide 0.9.7 em ~/.local/bin sombreando o 0.10.0.
    for bin in $prefixo/bin/*
        test -x $bin; or continue

        set -l nome (basename $bin)
        set -l vencedor (command -v $nome 2>/dev/null)

        test -n "$vencedor"; or continue

        # Compara o arquivo REAL, não o caminho: quase tudo em bin/ é symlink
        # para o Cellar (ou para share/, no caso do android-commandlinetools), e
        # comparar strings acusava o brew de sombrear a si mesmo — 6 falsos
        # positivos na primeira versão desta função.
        test (realpath $vencedor 2>/dev/null) != (realpath $bin 2>/dev/null); or continue

        # Gerenciadores de versão (nvm, rbenv, pyenv) sombreiam de propósito:
        # é o trabalho deles. Acusar isso seria ruído em toda execução.
        if string match -q "*/nvm/*" -- $vencedor
            or string match -q "*/.rbenv/*" -- $vencedor
            or string match -q "*/.pyenv/*" -- $vencedor
            continue
        end

        set achou 1
        _dotdoctor_aviso "$nome: o PATH usa uma instalação fora do Homebrew."
        echo "       usando: $vencedor"
        echo "                 "(_dotdoctor_versao $vencedor)
        echo "       brew:   $bin"
        echo "                 "(_dotdoctor_versao $bin)
        echo "       Se não houver motivo para manter a de fora, apague-a: o brew"
        echo "       atualiza a dele; a manual não é atualizada por ninguém."
    end

    if test $achou -eq 0
        _dotdoctor_ok "Nenhum binário do Homebrew sombreado."
    end
end

function _dotdoctor_versao --description "Tenta descobrir a versão de um binário"
    set -l v ($argv[1] --version 2>/dev/null | head -1)
    if test -z "$v"
        echo "(versão desconhecida)"
    else
        echo $v
    end
end

function _dotdoctor_path_inexistente --description "Lista entradas de PATH que não existem"
    _dotdoctor_titulo "Entradas do PATH"

    set -l mortas
    for dir in $PATH
        test -d $dir; or set -a mortas $dir
    end

    if test (count $mortas) -eq 0
        _dotdoctor_ok (count $PATH)" entradas, todas existem."
        return
    end

    # Informativo, sem contar como aviso: o macOS injeta sozinho um punhado de
    # caminhos que não existem (os cryptexd, /usr/local/bin num Apple Silicon), e
    # o fish ignora todos sem custo real. Contar isso como problema faria o
    # dotdoctor nascer vermelho numa máquina perfeitamente saudável — e um
    # diagnóstico que sempre reclama é um diagnóstico que ninguém lê.
    _dotdoctor_ok (math (count $PATH) - (count $mortas))" de "(count $PATH)" entradas existem."
    echo "     ℹ️  Inexistentes (inofensivas, a maioria vem do próprio macOS):"
    for dir in $mortas
        echo "        $dir"
    end
end

function _dotdoctor_links_orfaos --description "Acha symlinks quebrados na config do fish"
    _dotdoctor_titulo "Links das funções"

    set -l quebrados
    for link in (find $__fish_config_dir/functions -type l 2>/dev/null)
        test -e $link; or set -a quebrados $link
    end

    if test (count $quebrados) -eq 0
        _dotdoctor_ok "Nenhum link órfão."
    else
        for link in $quebrados
            _dotdoctor_erro "Link órfão: "(string replace "$__fish_config_dir/functions/" "" $link)" → "(readlink $link)
        end
        echo "       A função existe no papel e some sem erro ao ser chamada."
        echo "       Correção: dotsetup"
    end
end

function _dotdoctor_brewfile --description "Compara o Brewfile com o que está instalado"
    _dotdoctor_titulo "Brewfile"

    set -l repo (_dotdoctor_repo)
    if test -z "$repo"
        _dotdoctor_aviso "Não achei o repo dos dotfiles (config.fish não é link)."
        return
    end

    set -l brewfile $repo/Brewfile
    if not test -f $brewfile
        _dotdoctor_aviso "Brewfile não encontrado em $repo."
        return
    end

    if not type -q brew
        _dotdoctor_aviso "brew não encontrado; pulando."
        return
    end

    # Listado mas não instalado: o Mac novo instalaria, este aqui não tem.
    if brew bundle check --file $brewfile >/dev/null 2>&1
        _dotdoctor_ok "Tudo que o Brewfile lista está instalado."
    else
        _dotdoctor_erro "O Brewfile lista coisas que não estão instaladas aqui."
        brew bundle check --file $brewfile 2>&1 | string match -r '^→.*' | head -10
        echo "       Correção: dotsetup"
    end

    # Instalado mas não listado: existe nesta máquina e sumiria num Mac novo.
    set -l listados (string match -rg '^\s*(?:brew|cask)\s+"([^"]+)"' -- (cat $brewfile))
    set -l faltando

    # `--installed-on-request`, e não `brew leaves`: leaves lista o que ninguém
    # depende, o que inclui dependência abandonada por um upgrade — 21 libs do
    # ffmpeg (aom, libass, rav1e...) apareciam aqui como se fossem escolha sua.
    # O que deve estar no Brewfile é o que você pediu, e isso é installed-on-request.
    for f in (brew list --installed-on-request --formula 2>/dev/null)
        contains -- $f $listados; or set -a faltando "brew \"$f\""
    end
    for c in (brew list --cask 2>/dev/null)
        contains -- $c $listados; or set -a faltando "cask \"$c\""
    end

    if test (count $faltando) -eq 0
        _dotdoctor_ok "Nada instalado fora do Brewfile."
    else
        _dotdoctor_aviso (count $faltando)" instalado(s) aqui e ausente(s) do Brewfile:"
        for f in $faltando
            echo "       $f"
        end
        echo "       Num Mac novo, isso não voltaria. Para registrar, adicione ao"
        echo "       Brewfile — ou apague o que não usa mais."
    end
end

function _dotdoctor_brew_orfaos --description "Acha formulae que ninguém mais precisa"
    _dotdoctor_titulo "Formulae órfãs"

    if not type -q brew
        _dotdoctor_aviso "brew não encontrado; pulando."
        return
    end

    # Dependência abandonada por um upgrade não some sozinha: fica instalada para
    # sempre, ocupando disco, e não aparece em lugar nenhum que você olhe no dia
    # a dia. É a mesma família do nvm zumbi de docs/limpeza-shells-legado.md.
    set -l saida (brew autoremove --dry-run 2>&1)
    set -l quantas (string match -rg 'Would autoremove (\d+) unneeded' -- $saida)

    if test -z "$quantas" -o "$quantas" = 0
        _dotdoctor_ok "Nenhuma formula órfã."
        return
    end

    _dotdoctor_aviso "$quantas formula(e) instaladas que ninguém mais precisa."
    echo "       São dependências que algum upgrade largou para trás."
    echo "       Ver a lista: brew autoremove --dry-run"
    echo "       Remover:     brew autoremove"
end

function _dotdoctor_descricoes --description "Acha funções dos dotfiles sem --description"
    _dotdoctor_titulo "Descrições das funções"

    set -l repo (_dotdoctor_repo)
    if test -z "$repo"
        _dotdoctor_aviso "Não achei o repo dos dotfiles."
        return
    end

    set -l mudas
    for arquivo in $__fish_config_dir/functions/*.fish
        test -L $arquivo; or continue
        string match -q -- "$repo/*" (readlink $arquivo); or continue

        set -l nome (string replace -r '\.fish$' '' -- (basename $arquivo))
        string match -q '_*' -- $nome; and continue

        _dot_describe $nome >/dev/null; or set -a mudas $nome
    end

    if test (count $mudas) -eq 0
        _dotdoctor_ok "Todas as funções se descrevem."
    else
        for nome in $mudas
            _dotdoctor_aviso "$nome não tem --description (aparece como '—' no dothelp)."
        end
    end
end
