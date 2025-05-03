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
- Função `tempmail`: cria e gerencia e-mails temporários com `mail.tm`, lista inbox com índice numérico e permite ler mensagens diretamente
- Função `maccy`: instala o gerenciador de área de transferência Maccy via Homebrew
- Função `dotsetup`: executa o `install.fish` a partir de qualquer lugar para atualizar ou reconfigurar o ambiente
- Função `devutil`: toolkit para devs (gera CUID, UUID, CPF, CNPJ, decodifica JWT)
- Função `try_install_tool`: função auxiliar para verificar e instalar ferramentas com `npm` ou `brew`
- Função `api_test`: testa APIs REST/GraphQL com suporte a diferentes métodos HTTP e autenticação

## 📄 Arquivos

### `config.fish`

Responsável por carregar:

- `starship` (tema do prompt)
- `fzf` (busca fuzzy)
- `zoxide` (cd inteligente)
- Aliases personalizados
- Funções personalizadas como `proj`, `fin`, `musica`, `gitclone`, `tempmail`, `maccy`, `dotsetup`, `devutil`, `api_test`

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

### `functions/tempmail.fish`

Cria um novo e-mail temporário com `mail.tm`, armazena as credenciais no cache e permite:

- Listar a caixa de entrada no terminal (uma linha por e-mail, com índice numérico)
- Exibir os remetentes e assuntos numerados
- Selecionar e ler a mensagem diretamente pelo índice
- Exibir as credenciais salvas

Exemplo de uso:

```bash
tempmail
```

### `functions/maccy.fish`

Instala o Maccy (gerenciador de histórico de área de transferência para macOS) via Homebrew:

- Verifica se já está instalado
- Caso contrário, instala com `brew install --cask maccy`

### `functions/dotsetup.fish`

Executa o script de instalação dos dotfiles a partir de qualquer lugar.

```bash
dotsetup
```

### `functions/devutil.fish`

Toolkit prático com comandos para desenvolvimento:

- `devutil cuid` → gera CUID (usa pacote `cuid-cli`)
- `devutil uuid` → gera UUID v4 e copia para área de transferência
- `devutil jwt TOKEN` → decodifica JWT (mostra payload com `jq`)
- `devutil cpf` → gera um CPF válido e copia sem quebra de linha
- `devutil cnpj` → gera um CNPJ válido e copia sem quebra de linha
- `devutil epoch` → mostra timestamp atual (epoch)
- `devutil epoch [epoch]` → converte epoch para data legível

### `functions/api_test.fish`

Testa APIs REST/GraphQL com suporte a diferentes métodos HTTP e autenticação.  
**Agora mais simples:**

- Headers: passe como `Chave:Valor` (ex: `Authorization:'Bearer token'`)
- Dados: passe como `chave=valor` (ex: `name=John age=30`)
- GraphQL: envie a query como `query='...'`
- Query Params: adicione `?chave=valor` na URL
- Path Params: use `:valor` na URL

#### Exemplos de uso:

```bash
# REST API básica
api_test get https://api.github.com/users/octocat
api_test post https://api.example.com/users name=John age=30

# Headers de autenticação
api_test get https://api.example.com/users Authorization:'Bearer token123'
api_test post https://api.example.com/users Authorization:'Bearer token123' name=John age=30

# Query Params
api_test get https://api.example.com/users?page=1&limit=10
api_test get https://api.example.com/users?page=1&limit=10 Authorization:'Bearer token123'

# Path Params
api_test get https://api.example.com/users/:id
api_test get https://api.example.com/users/:id Authorization:'Bearer token123'

# Métodos HTTP
api_test put https://api.example.com/users/1 name=John age=31
api_test patch https://api.example.com/users/1 age=32
api_test delete https://api.example.com/users/1

# GraphQL
api_test post https://api.example.com/graphql query='query { users { id name } }'
api_test post https://api.example.com/graphql Authorization:'Bearer token123' query='query { users { id name } }'
```

**Ordem dos argumentos:**

1. Método HTTP (`get`, `post`, `put`, `delete`, `patch`)
2. URL do endpoint (pode incluir query params e path params)
3. Headers (opcional): `Chave:Valor`
4. Dados (opcional): `chave=valor`
5. Query GraphQL (opcional): `query='...'`

### `functions/try_install_tool.fish`

Função auxiliar que verifica se uma ferramenta está instalada e pergunta se deseja instalar com `npm` (padrão) ou `brew`.

## 🛠️ Requisitos

- [fish shell](https://fishshell.com/)
- [starship](https://starship.rs/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fzf](https://github.com/junegunn/fzf)
- [bat](https://github.com/sharkdp/bat)
- [eza](https://github.com/eza-community/eza)
- [jq](https://stedolan.github.io/jq/)
- [cuid-cli (npm)](https://www.npmjs.com/package/cuid-cli)
- JetBrainsMono Nerd Font

## 🚀 Primeira Instalação

```bash
git clone https://github.com/Komido/dotfiles ~/.dotfiles
cd ~/.dotfiles

chmod +x install.fish
./install.fish
```

Para reinstalar ou reconfigurar o ambiente futuramente:

```bash
dotsetup
```

## 🧼 Licença

MIT — Sinta-se à vontade para copiar, modificar, usar, sugerir melhorias e distribuir.

## 💡 Funções disponíveis

```bash
proj             # Lista projetos com metadados e fzf
gitclone         # Exibe dados do repositório antes de clonar em ~/Projetos
fin              # Abre a pasta atual no Finder (com tamanho fixo)
musica           # Controla o app Música (play/pause/próxima/volume/playlists)
api_test         # Testa APIs REST/GraphQL com suporte a diferentes métodos HTTP e autenticação
tempmail         # Gera e gerencia e-mails temporários com mail.tm
devutil          # Utilitários diversos: UUID, slug, base64, senha aleatória etc.
dotsetup         # Setup auxiliar de pós-instalação e dotfiles
maccy            # Instala e configura o Maccy via Homebrew
try_install_tool # Instala ferramentas com brew ou npm (com confirmação)
dothelp          # Lista e explica todas as funções acima
```
