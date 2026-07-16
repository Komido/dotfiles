set -g fish_greeting ""

# Define variáveis de ambiente
set -gx USER (whoami)
set -gx HOSTNAME (hostname -s)

# Define a versão padrão do Node.js para nvm.fish.
# Não use "lts": não é um alias, e sim a pasta alias/lts com gallium/hydrogen/iron/jod
# dentro — o nvm resolve pelo primeiro em ordem alfabética, gallium, que é o Node 16.
set -gx nvm_default_version lts/iron # Node 20

# --- PATH ---
# Tudo aqui, e nada via `set -U PATH`: uma variável universal congela um snapshot
# que atravessa sessões, ignora este arquivo e sobrevive a edições dele — mudança
# de config "não pega" e ninguém entende por quê.
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.antigravity/antigravity/bin

# Python (pip install --user)
fish_add_path $HOME/Library/Python/3.9/bin

# .NET
fish_add_path /usr/local/share/dotnet
fish_add_path $HOME/.dotnet/tools

# Utilitários do iTerm (imgcat, it2copy...)
fish_add_path /Applications/iTerm.app/Contents/Resources/utilities

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# Configurações para sessões interativas
if status is-interactive
    # Inicializa o Starship
    starship init fish | source

    # Inicializa fzf
    fzf --fish | source

    # Inicializa zoxide
    zoxide init fish | source

    # Aliases
    alias cat="bat --theme=\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
    alias l="ls -la"
    alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
    alias cd="z"
    alias code="open -a Cursor"

    # Configurações do fzf
    set -gx FZF_CTRL_T_OPTS "
      --style full
      --walker-skip .git,node_modules,target
      --preview 'bat -n --color=always {}'
      --bind 'ctrl-/:change-preview-window(down|hidden|)'"
end

# --- Node.js via nvm.fish ---
# Não mexa no PATH manualmente aqui: o nvm.fish já gerencia (via $nvm_data, definido
# em conf.d/nvm.fish). Um `set -gx PATH $nvm_data/v*/bin $PATH` expande o glob para
# TODAS as versões instaladas e fixa a mais antiga na frente, ignorando o nvm.
#
# O conf.d do plugin ativaria a versão padrão sozinho, mas ele roda ANTES deste
# arquivo e por isso não enxerga o nvm_default_version definido acima — daí a
# ativação explícita.
#
# Sem guarda de "já está ativo": nvm_current_version é exportado e vaza para os
# processos filhos, então terminais embutidos (Cursor/VSCode) herdam um valor
# velho. Confiar nele faz a ativação ser pulada e o node do Homebrew assumir.
if type -q nvm
    nvm use --silent $nvm_default_version
end

# Carrega configurações locais (não versionadas).
# Instaladores que anexam PATH no fim deste arquivo (Antigravity, bun) são
# sobrescritos a cada `install.fish` — coloque essas linhas aqui.
if test -f ~/.config.fish.local
    source ~/.config.fish.local
end
