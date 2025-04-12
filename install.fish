#!/usr/bin/env fish

echo "🔧 Iniciando instalação dos seus dotfiles..."

set DOTFILES (pwd)
set CONFIG_DIR ~/.config/fish
set FUNCTIONS_DIR $CONFIG_DIR/functions

mkdir -p $FUNCTIONS_DIR

if test -f $DOTFILES/config.fish
    echo "🔗 Linkando config.fish..."
    ln -sf $DOTFILES/config.fish $CONFIG_DIR/config.fish
end

for func in $DOTFILES/functions/*.fish
    echo "🔗 Linkando função (basename $func)..."
    ln -sf $func $FUNCTIONS_DIR/(basename $func)
end

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
try_install starship
try_install zoxide
try_install fzf
try_install bat
try_install eza
try_install jq
try_install fd

echo ""
echo "✅ Tudo pronto! Reinicie seu terminal ou execute: exec fish"
