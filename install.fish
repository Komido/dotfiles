#!/usr/bin/env fish

echo "🔧 Iniciando instalação dos seus dotfiles..."

set DOTFILES (pwd)
set CONFIG_DIR ~/.config/fish
set FUNCTIONS_DIR $CONFIG_DIR/functions

mkdir -p $FUNCTIONS_DIR

# Instala Command Line Tools (necessário para o brew funcionar)
if not type -q git
    echo "🧰 Instalando Command Line Tools..."
    xcode-select --install
end

# Verifica/instala o Homebrew
if not type -q brew
    echo "🍺 Instalando Homebrew..."
    /bin/bash -c "(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval (/opt/homebrew/bin/brew shellenv)

    # Verificação de sucesso
    if not type -q brew
        echo "❌ Homebrew não foi instalado corretamente. Abortando script."
        exit 1
    end
else
    echo "✅ Homebrew já instalado."
end

# Verifica arquitetura do chip
set ARCH (uname -m)
if test $ARCH = arm64
    echo "💻 Apple Silicon (M1/M2/M3/M4) detectado."
else if test $ARCH = x86_64
    echo "💻 Intel Mac detectado."
else
    echo "⚠️ Arquitetura desconhecida: $ARCH"
end

# Link do config principal
if test -f $DOTFILES/config.fish
    echo "🔗 Linkando config.fish..."
    ln -sf $DOTFILES/config.fish $CONFIG_DIR/config.fish
end

# Link de todas as funções
for func in $DOTFILES/functions/*.fish
    echo "🔗 Linkando função "(basename $func)"..."
    ln -sf $func $FUNCTIONS_DIR/(basename $func)
end

# Define função para instalar ferramentas via brew
function try_install
    if not type -q $argv[1]
        echo "📦 Instalando $argv[1]..."
        brew install $argv[1]
    else
        echo "✅ $argv[1] já instalado."
    end
end

echo ""
echo "🧪 Verificando dependências..."
try_install fish
try_install starship
try_install zoxide
try_install fzf
try_install bat
try_install eza
try_install jq
try_install fd

# Define Fish como shell padrão
set FISH_PATH (which fish)
if test (echo $SHELL) != $FISH_PATH
    echo "🐟 Definindo o Fish como shell padrão..."
    if not grep -q $FISH_PATH /etc/shells
        echo $FISH_PATH | sudo tee -a /etc/shells
    end
    chsh -s $FISH_PATH
end

echo ""
echo "🎨 Lembrete: configure a JetBrainsMono Nerd Font no seu terminal."
echo "✅ Tudo pronto! Reinicie o terminal ou execute: exec fish"
