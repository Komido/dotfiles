# 🐟 Dotfiles do Daniel — Fish Shell Setup

Este repositório contém minha configuração pessoal para o terminal Fish Shell no macOS. Foco em produtividade, estética e automações para desenvolvimento.

## 🌟 Features

- Prompt com Starship
- Navegação rápida com `zoxide` + `fzf`
- Visual avançado com `eza`, `bat`, Nerd Font
- Função `proj`: exibição interativa dos meus projetos com metadados
- Função `fin`: abre o Finder na pasta atual do terminal

## 📄 Arquivos

### `config.fish`

Responsável por carregar:

- `starship` (tema do prompt)
- `fzf` (busca fuzzy)
- `zoxide` (cd inteligente)
- Aliases personalizados
- Funções personalizadas como `proj` e `fin`

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

## 🔗 Extras

Para aplicar o fish como shell padrão:

```bash
chsh -s (which fish)
```

## 🧼 Licença

MIT — Sinta-se à vontade para copiar, modificar, usar, sugerir melhorias e distribuir.
