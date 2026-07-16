# Brewfile — o que esta máquina precisa ter instalado.
#
# Aplicado pelo install.fish com `brew bundle`. Antes disto, a lista de pacotes
# vivia como uma sequência de `try_install` no install.fish (só as formulae) e os
# casks não estavam em lugar nenhum: um Mac novo terminava o bootstrap.sh sem
# editor, sem cliente de API e sem a fonte que o próprio script mandava
# configurar num echo.
#
# Para adicionar o que já está instalado aqui: `brew bundle dump --force`.
# Para conferir o que está instalado e não está listado: `brew bundle cleanup`.

# --- Shell e prompt ---
brew "fish"
brew "starship"

# --- Navegação e busca ---
brew "fzf"
brew "zoxide"
brew "fd"
brew "eza"
brew "bat"

# --- Dados e texto ---
brew "jq" # dependência dura: devutil, api_test e tempmail não rodam sem
brew "jo"

# --- Git e GitHub ---
brew "gh" # usado pelo `wt` e pelo fluxo de PR

# --- Bancos ---
brew "libpq" # psql sem instalar o Postgres inteiro

# --- Java / Android ---
brew "openjdk@17"
brew "gradle"
cask "android-commandlinetools"

# --- Mídia e PDF ---
brew "ffmpeg"
brew "poppler"
brew "qpdf"

# --- Apps ---
cask "bruno" # cliente de API (GUI); o api_test cobre o caso de terminal
cask "ngrok" # túnel público — usado pelo `tunnel`
cask "appcleaner"

# --- Fonte ---
# O install.fish só imprimia "🎨 Lembrete: configure a JetBrainsMono Nerd Font".
# Um lembrete não instala fonte, e sem ela os ícones do eza, do starship e do
# proj viram quadradinhos vazios num Mac recém-configurado.
cask "font-jetbrains-mono-nerd-font"

# --- Deliberadamente fora ---
#
# maccy         → instalado na máquina, mas fora dos dotfiles por decisão sua.
#                 Para voltar a reproduzi-lo num Mac novo: cask "maccy".
#
# nvm (formula) → é o zumbi documentado em docs/limpeza-shells-legado.md: era ele
#                 que recriava ~/.nvm a cada início de zsh. O gerenciador de Node
#                 aqui é o nvm.fish (via fisher), então a formula está órfã.
#                 Remova com: brew uninstall nvm
