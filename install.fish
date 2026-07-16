#!/usr/bin/env fish

echo "🔧 Iniciando instalação dos seus dotfiles..."

# O script se localiza sozinho, em vez de confiar no diretório atual.
#
# Com `(pwd)`, ele só funcionava se você já estivesse dentro do repo — e ninguém
# avisava quando não estava. O `dotsetup` (que descobre o repo pelo symlink e
# chama daqui) e o `bootstrap.sh` (que calcula o caminho e faz `exec fish
# "$DOTFILES/install.fish"`) rodam SEM dar `cd` antes, então o pwd era o
# diretório de onde você chamou. O resultado era um silêncio perfeito: nenhum
# `test -f $DOTFILES/config.fish` batia, nenhuma função era linkada, e no fim
# saía "✅ Tudo pronto!".
#
# `realpath` do arquivo antes do `dirname`: assim também funciona se este script
# for chamado através de um symlink, caso em que `status dirname` devolveria o
# diretório do link, e não o do repo.
set DOTFILES (dirname (realpath (status filename)))
set CONFIG_DIR ~/.config/fish
set FUNCTIONS_DIR $CONFIG_DIR/functions

mkdir -p $FUNCTIONS_DIR

# Um `set -U PATH` congela um snapshot de PATH no fish_variables que atravessa
# sessões e ignora o config.fish — mudanças de PATH "não pegam" e não há erro.
# Aqui o PATH é montado só com fish_add_path, no config.fish.
if set --query --universal PATH
    echo "🧹 Removendo PATH universal (set -U) — quem manda no PATH é o config.fish."
    set --erase --universal PATH
end

# Homebrew e fish são responsabilidade do ./bootstrap.sh — ele é bash e roda numa
# máquina zero, coisa que este arquivo não faz (é fish; sem fish, não executa).
if not type -q brew
    echo "❌ Homebrew não encontrado. Numa máquina nova, comece pelo ./bootstrap.sh."
    exit 1
end
echo "✅ Homebrew já instalado."

# Verifica arquitetura do chip
set ARCH (uname -m)
if test $ARCH = arm64
    echo "💻 Apple Silicon (M1/M2/M3/M4) detectado."
else if test $ARCH = x86_64
    echo "💻 Intel Mac detectado."
else
    echo "⚠️ Arquitetura desconhecida: $ARCH"
end

# Faz backup de um arquivo real que seria sobrescrito pelo link.
#
# `test -e` segue symlinks, então a partir da segunda execução o alvo já é um
# link nosso e o `mv` "fazia backup" movendo o ponteiro — gerando um .bak que
# aponta para o arquivo VIVO no repo. Não preservava nada e acumulava um lixo
# novo a cada rodada. Um link nosso não tem o que preservar: o conteúdo está
# versionado no repo.
function backup_file
    set target $argv[1]

    if test -L $target
        rm -f $target
        return
    end

    if test -e $target
        set timestamp (date +%Y%m%d_%H%M%S)
        set backup_name "$target.bak.$timestamp"
        echo "📦 Backup: $target -> $backup_name"
        mv $target $backup_name
    end
end

# Link do config principal
if test -f $DOTFILES/config.fish
    echo "🔗 Linkando config.fish..."
    backup_file $CONFIG_DIR/config.fish
    ln -sf $DOTFILES/config.fish $CONFIG_DIR/config.fish
end

# Link de todas as funções, incluindo subpastas (ex: devutil)
for func in (find $DOTFILES/functions -name '*.fish')
    set relative_path (string replace "$DOTFILES/functions/" "" $func)
    set target_dir (dirname $relative_path)
    mkdir -p $FUNCTIONS_DIR/$target_dir

    echo "🔗 Linkando função $relative_path..."
    backup_file $FUNCTIONS_DIR/$relative_path
    ln -sf $func $FUNCTIONS_DIR/$relative_path
end

# Remove links que apontam para arquivos que não existem mais no repo.
#
# Renomear ou apagar uma função deixava o symlink velho para trás: o install só
# cria, nunca removia. O fish então tenta carregar um alvo inexistente e a função
# some sem erro nenhum — o sintoma é "essa função sumiu" sem causa aparente.
# Só mexe no que aponta para dentro do repo; funções do fisher não são tocadas.
echo ""
echo "🧹 Procurando links órfãos..."
set -l orfaos 0
for link in (find $FUNCTIONS_DIR -type l)
    set -l alvo (readlink $link)
    string match -q "$DOTFILES/*" $alvo; or continue
    if not test -e $alvo
        echo "🗑️  Removendo link órfão: "(string replace "$FUNCTIONS_DIR/" "" $link)
        rm -f $link
        set orfaos (math $orfaos + 1)
    end
end
if test $orfaos -eq 0
    echo "✅ Nenhum link órfão."
end

# --- Dependências, via Brewfile ---
# A lista vivia aqui como uma sequência de `try_install`, e cobria só formulae.
# Casks (editor, fonte, ngrok) não estavam versionados em lugar nenhum.
echo ""
echo "🍺 Aplicando o Brewfile..."
if test -f $DOTFILES/Brewfile
    brew bundle --file $DOTFILES/Brewfile
else
    echo "⚠️  Brewfile não encontrado em $DOTFILES — pulando."
end

# Avisa se o próprio fish foi atualizado agora.
#
# O Homebrew apaga o diretório da versão antiga, e TODA sessão de fish já aberta
# guarda o caminho dela no $fish_function_path. Essas sessões viram zumbis: as
# setas param de funcionar ("Unknown command: up-or-search", porque a função mora
# na pasta que sumiu) e funções somem sem explicação. O sintoma não lembra em
# nada a causa, então o aviso precisa ser explícito.
#
# $version é a versão do interpretador que está executando este script; o
# `fish --version` lê o binário no disco. Diferentes = trocaram o fish agora.
set -l fish_no_disco (fish --version | string match -rg 'version ([0-9.]+)')
if test -n "$fish_no_disco" -a "$version" != "$fish_no_disco"
    echo ""
    set_color -o bryellow
    echo "⚠️  O FISH FOI ATUALIZADO NESTA EXECUÇÃO ($version → $fish_no_disco)."
    set_color normal
    echo "   Todo terminal que já estava aberto ficou quebrado: as setas param de"
    echo "   buscar histórico e algumas funções somem. Não é a sua config."
    echo "   Feche os terminais abertos, ou rode 'exec fish' em cada um."
end

# --- Fisher + plugins ---
# Sem isto, o config.fish chama `nvm`, o `type -q nvm` dá falso, o bloco do Node é
# pulado e a máquina fica SEM node — sem nenhum erro visível.
echo ""
echo "🎣 Verificando Fisher e plugins..."
if not functions -q fisher
    echo "📦 Instalando Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end

for plugin in jorgebucaran/nvm.fish franciscolourenco/done jhillyerd/plugin-git
    if not fisher list $plugin >/dev/null 2>&1
        echo "📦 Instalando $plugin..."
        fisher install $plugin
    else
        echo "✅ $plugin já instalado."
    end
end

# --- Node.js ---
# nvm_default_version vem do config.fish; instala a versão se ainda não existir.
echo ""
echo "📗 Verificando Node.js..."
if functions -q nvm
    set -l alvo (test -n "$nvm_default_version"; and echo $nvm_default_version; or echo lts/iron)
    if not nvm use --silent $alvo 2>/dev/null
        echo "📦 Instalando Node ($alvo)..."
        nvm install $alvo
    end
    nvm use --silent $alvo
    echo "✅ Node "(node --version)" ativo."
else
    echo "⚠️  nvm.fish indisponível nesta sessão — rode 'exec fish' e depois 'nvm install lts/iron'."
end

# Define Fish como shell padrão.
#
# Consulta o shell de login no diretório do usuário, e não $SHELL: essa variável
# é herdada do processo pai, então rodar o script de dentro de um bash/zsh (ou de
# um terminal embutido) faz $SHELL vir /bin/zsh mesmo com o fish já configurado —
# e o chsh dispara à toa, pedindo senha em toda execução.
echo ""
set FISH_PATH (command -v fish)
set LOGIN_SHELL (dscl . -read /Users/$USER UserShell 2>/dev/null | string replace 'UserShell: ' '')

if test "$LOGIN_SHELL" = "$FISH_PATH"
    echo "✅ Fish já é o shell padrão."
else
    echo "🐟 Definindo o Fish como shell padrão (vai pedir sua senha)..."
    if not grep -q $FISH_PATH /etc/shells
        echo $FISH_PATH | sudo tee -a /etc/shells
    end
    chsh -s $FISH_PATH
end

echo ""
echo "🎨 A JetBrainsMono Nerd Font vem pelo Brewfile — falta só selecioná-la no seu terminal."
echo "✅ Tudo pronto! Reinicie o terminal ou execute: exec fish"
