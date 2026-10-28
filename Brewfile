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
brew "gitleaks" # varre o repo atrás de segredo commitado (chave, token, .env)

# --- Bancos ---
brew "libpq" # psql sem instalar o Postgres inteiro

# --- Nuvem ---
brew "awscli" # o perfil AWS usado nos projetos e pela extensão do VS Code
brew "minio-mc" # cliente de storage compatível com S3

# --- Java / Android ---
brew "openjdk@17"
brew "gradle"
cask "android-commandlinetools"

# --- Mídia e PDF ---
brew "ffmpeg"
brew "poppler"
brew "qpdf"

# --- Apps ---
# VS Code e iTerm2 entraram em out/2026: o próprio repo depende deles (o
# DOT_EDITOR do config.fish abre o VS Code; o PATH inclui os utilitários do
# iTerm), mas um Mac novo terminava o bootstrap sem nenhum dos dois.
#
# Num Mac em que já foram instalados à mão (arrastando para Aplicativos), o
# `brew bundle` falha com "already an App at". Uma vez só, para o Homebrew
# assumir os apps existentes: brew install --cask --adopt visual-studio-code iterm2
cask "visual-studio-code"
cask "iterm2"
cask "bruno" # cliente de API (GUI); o api_test cobre o caso de terminal
cask "ngrok" # túnel público — usado pelo `tunnel`
cask "appcleaner"
cask "maccy" # histórico de área de transferência
cask "codex" # agente de código da OpenAI no terminal
cask "rustdesk" # acesso remoto

# --- Fonte ---
# O install.fish só imprimia "🎨 Lembrete: configure a JetBrainsMono Nerd Font".
# Um lembrete não instala fonte, e sem ela os ícones do eza, do starship e do
# proj viram quadradinhos vazios num Mac recém-configurado.
cask "font-jetbrains-mono-nerd-font"

# --- Deliberadamente fora ---
#
# nvm (formula) → removida em 2026-07-16. Era o zumbi de
#                 docs/limpeza-shells-legado.md: recriava ~/.nvm a cada início de
#                 zsh. O gerenciador de Node aqui é o nvm.fish (via fisher), e a
#                 formula do brew é um script bash/zsh sem uso nenhum no fish.
#
# dotnet        → não vem pelo brew: o SDK 6.0 está em /usr/local/share/dotnet,
#                 instalado pelo pacote oficial da Microsoft, e é o que os
#                 projetos api-tray-admin, api-yampi-admin e api-tray-influencer
#                 exigem (global.json fixa 6.0.419, TargetFramework net6.0).
#                 O brew só tem versões novas; um `brew install dotnet` aqui
#                 traria um SDK que esses projetos não aceitam.
