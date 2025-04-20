# 🐟 Dotfiles do Daniel — Fish Shell Setup
![Shell](https://img.shields.io/badge/shell-fish-00aced?logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Last Update](https://img.shields.io/github/last-commit/Komido/dotfiles)

Este repositório contém minha configuração pessoal para o terminal Fish Shell no macOS. Foco em produtividade, estética e automações para desenvolvimento.

## 🌟 Features

- Prompt com Starship
- Navegação rápida com `zoxide` + `fzf`
- Visual avançado com `eza`, `bat`, Nerd Font
- Função `proj`: exibição interativa dos meus projetos com metadados
- Função `fin`: abre o Finder na pasta atual do terminal
- Função `musica`: controle do app Música pelo terminal (play/pause, próxima faixa, volume, playlists)
- Função `gitclone`: exibe detalhes do repositório remoto antes de confirmar o clone (clona sempre em `~/Projetos`)
- Função `maccy`: instala e configura o gerenciador de área de transferência Maccy com atalho, inicialização automática e sincronização via iCloud/Dropbox (detecta se já está instalado)
- Função `clean_maccy`: limpa itens antigos do histórico do Maccy sem remover os fixados

## 📄 Arquivos

### `config.fish`

Responsável por carregar:

- `starship` (tema do prompt)
- `fzf` (busca fuzzy)
- `zoxide` (cd inteligente)
- Aliases personalizados
- Funções personalizadas como `proj`, `fin`, `musica`, `gitclone`, `maccy` e `clean_maccy`

### `functions/proj.fish`

Mostra os projetos da pasta `~/Projetos` com:
- Tipo (api, app, script, serverless)
- Versão (package.json)
- Node version (package.json ou .nvmrc)
- Status do Git
- Data do último commit
- Interface fzf com colunas organizadas

### `functions/fin.fish`

Abre a pasta atual do terminal no Finder, com tamanho da janela definido.

### `functions/gitclone.fish`

Recebe uma URL de repositório (`git@...` ou `https://...`), exibe:

- Nome do projeto
- Branch padrão
- Branches disponíveis
- Teste de acesso ao repositório
- Confirmação antes de clonar
- Clona sempre dentro de `~/Projetos`

### `functions/maccy.fish`

Automatiza a configuração do Maccy, gerenciador de área de transferência para macOS:

- Detecta se o app já está instalado
- Instala via Homebrew (se necessário)
- Define atalho `⌃ + ⌘ + V` para abrir
- Ativa inicialização com o sistema
- Permite sincronizar o histórico via iCloud ou Dropbox
- Reinicia o app para aplicar todas as configurações

### `functions/clean_maccy.fish`

Remove itens antigos do histórico do Maccy **sem apagar itens fixados**:

- Mantém um número máximo de itens configurável (ex: 1000)
- Protege os itens com `"pinned": true` nos arquivos JSON
- Ideal para rodar manualmente ou via agendamento

## 🛠️ Requisitos

- [fish shell](https://fishshell.com/)
- [starship](https://starship.rs/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fzf](https://github.com/junegunn/fzf)
- [bat](https://github.com/sharkdp/bat)
- [eza](https://github.com/eza-community/eza)
- [jq](https://stedolan.github.io/jq/)
- JetBrainsMono Nerd Font

## 🚀 Instalação

```bash
git clone https://github.com/Komido/dotfiles ~/.dotfiles
cd ~/.dotfiles

# Dá permissão de execução ao instalador
chmod +x install.fish

# Roda o script
./install.fish
