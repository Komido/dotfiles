set -g fish_greeting ""

# Define variáveis de ambiente
set -gx USER (whoami)
set -gx HOSTNAME (hostname -s)

# Define a versão padrão do Node.js para nvm.fish
set -gx nvm_default_version lts

# Adiciona o Homebrew ao PATH
fish_add_path /opt/homebrew/bin

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
