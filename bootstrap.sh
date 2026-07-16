#!/bin/bash
#
# Ponto de entrada para uma máquina nova.
#
# O install.fish é escrito em fish, então não roda antes do fish existir — e o
# `try_install fish` lá dentro é inalcançável num Mac zero. Este script é bash
# (sempre presente no macOS) e resolve só o mínimo para o fish existir, depois
# entrega o resto para o install.fish.
#
# Uso:
#   git clone https://github.com/Komido/dotfiles ~/Projetos/dotfiles
#   cd ~/Projetos/dotfiles && ./bootstrap.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Preparando a máquina..."

# --- Command Line Tools (traz o git) ---
# `xcode-select --install` só ABRE o instalador gráfico e retorna na hora, então
# não dá para seguir em frente na mesma execução — o brew precisa do git.
if ! xcode-select -p >/dev/null 2>&1; then
    echo "🧰 Instalando Command Line Tools..."
    xcode-select --install
    echo ""
    echo "⏳ Conclua a instalação na janela que abriu e rode ./bootstrap.sh de novo."
    exit 0
fi
echo "✅ Command Line Tools presentes."

# --- Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
    echo "🍺 Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# O instalador não deixa o brew no PATH da sessão atual. O prefixo muda conforme
# o chip: /opt/homebrew no Apple Silicon, /usr/local no Intel.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Homebrew não ficou disponível. Abra um terminal novo e rode de novo."
    exit 1
fi
echo "✅ Homebrew pronto ($(brew --prefix))."

# --- Fish ---
if ! command -v fish >/dev/null 2>&1; then
    echo "🐟 Instalando o Fish..."
    brew install fish
fi
echo "✅ Fish pronto ($(command -v fish))."

# --- Entrega para o install.fish ---
echo ""
echo "🎣 Passando o resto para o install.fish..."
echo ""
exec fish "$DOTFILES/install.fish"
