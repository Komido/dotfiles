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
- Função `maccy`: instala o gerenciador de área de transferência Maccy via Homebrew
- Função `dotsetup`: executa o `install.fish` a partir de qualquer lugar para atualizar ou reconfigurar o ambiente

## 📄 Arquivos

### `config.fish`

Responsável por carregar:

- `starship` (tema do prompt)
- `fzf` (busca fuzzy)
- `zoxide` (cd inteligente)
- Aliases personalizados
- Funções personalizadas como `proj`, `fin`, `musica`, `gitclone`, `maccy` e `dotsetup`

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

Instala o Maccy (gerenciador de histórico de área de transferência para macOS) via Homebrew:

- Verifica se já está instalado
- Caso contrário, instala com `brew install --cask maccy`

### `functions/dotsetup.fish`

Executa o script de instalação dos dotfiles a partir de qualquer lugar.  
Ideal para atualizar ou reconfigurar o ambiente com um único comando:

```bash
dotsetup

## 🛠️ Requisitos

- [fish shell](https://fishshell.com/)
- [starship](https://starship.rs/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fzf](https://github.com/junegunn/fzf)
- [bat](https://github.com/sharkdp/bat)
- [eza](https://github.com/eza-community/eza)
- [jq](https://stedolan.github.io/jq/)
- JetBrainsMono Nerd Font

## 🚀 Primeira Instalação

```bash
git clone https://github.com/Komido/dotfiles ~/.dotfiles
cd ~/.dotfiles

# Dá permissão de execução ao instalador
chmod +x install.fish

# Roda o script
./install.fish

## 🧼 Licença
MIT — Sinta-se à vontade para copiar, modificar, usar, sugerir melhorias e distribuir.