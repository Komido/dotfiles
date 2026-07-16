# 🐟 Dotfiles — Fish Shell Setup

![Shell](https://img.shields.io/badge/shell-fish-00aced?logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Last Update](https://img.shields.io/github/last-commit/Komido/dotfiles)

Minha configuração pessoal do Fish Shell no macOS. Foco em produtividade, estética
e automações para desenvolvimento.

## 🚀 Primeira instalação

Numa máquina nova, comece pelo `bootstrap.sh`. Ele é bash — o `install.fish` é
fish e não roda antes do fish existir:

```bash
git clone https://github.com/Komido/dotfiles ~/Projetos/dotfiles
cd ~/Projetos/dotfiles

chmod +x bootstrap.sh
./bootstrap.sh
```

O `bootstrap.sh` instala Command Line Tools, Homebrew e o fish, e então chama o
`install.fish` sozinho. Se as Command Line Tools estiverem faltando, ele abre o
instalador da Apple e pede para você rodar o comando de novo quando terminar —
esse instalador é gráfico e não dá para esperar por ele dentro do script.

Ao final, abra um terminal novo (ou rode `exec fish`) e selecione a
**JetBrainsMono Nerd Font** no seu terminal (ela é instalada pelo Brewfile).

O clone pode ficar em qualquer pasta: os scripts se localizam sozinhos.

Para reconfigurar depois, de qualquer lugar:

```bash
dotsetup
```

O `install.fish` é idempotente: rodar de novo só reafirma o estado. Ele também
remove links de funções que não existem mais no repo.

### Configurações locais

Para tokens e configurações específicas da máquina, crie `~/.config.fish.local`.
É carregado automaticamente e ignorado pelo Git.

## 📦 O que é instalado

Tudo vem do [`Brewfile`](./Brewfile), aplicado com `brew bundle`. Formulae e
casks — incluindo a Nerd Font. Para registrar algo que você instalou depois:

```bash
brew bundle dump --force   # captura o estado atual da máquina
brew bundle cleanup        # mostra o que está instalado e não está listado
```

## 💡 Funções

Todas se descrevem sozinhas. Para a lista sempre atualizada:

```bash
dothelp        # lista as funções destes dotfiles
devutil help   # lista os utilitários de dev
```

Nenhuma das duas listas é escrita à mão: elas se montam a partir dos arquivos e
das suas `--description`, então não têm como divergir do código.

### Projetos e git

| Função | O que faz |
| --- | --- |
| `proj` | Lista `~/Projetos` no fzf com tipo, versão, Node, status do git e último commit. Abre o escolhido no editor. |
| `gitclone <url>` | Mostra branch padrão, branches e acesso do repositório remoto antes de confirmar o clone em `~/Projetos`. |
| `wt` | Git worktrees: troca, cria e remove. `wt new <branch>`, `wt pr <nº>`, `wt rm`, `wt list`. |
| `nmreap [dir]` | Acha os `node_modules` de `~/Projetos`, mostra tamanho e último commit de cada projeto, e apaga os que você marcar. |

### Desenvolvimento

| Função | O que faz |
| --- | --- |
| `api_test` | Testa APIs REST/GraphQL. Mostra o status HTTP; `chave=valor` é string, `chave:=valor` é JSON puro. |
| `envdiff [.env] [.env.example]` | Compara os dois e aponta chave faltando, chave declarada sem valor e chave só local. |
| `tunnel [porta]` | Expõe uma porta local na internet (cloudflared ou ngrok). Sem argumento, escolhe entre as portas que estão escutando. |
| `devutil` | Utilitários: `uuid`, `cuid`, `cpf`, `cnpj`, `jwt`, `pass`, `lorem`, `base64`, `epoch`, `ports`, `tempmail`. |
| `slug` | Texto → slug URL-safe, tratando acentuação. Aceita argumento ou stdin. |

### Sistema

| Função | O que faz |
| --- | --- |
| `up [--check]` | Atualiza Homebrew, Fisher e globais do npm. `--check` só mostra o que está desatualizado. |
| `dock` | `hide`, `show` ou `reset` do Dock do macOS. |
| `fin` | Abre a pasta atual no Finder. |
| `musica` | Controla o app Música (play, pause, volume, playlists). |
| `dotsetup` | Reexecuta o `install.fish` de qualquer lugar. |
| `try_install_tool` | Verifica se uma ferramenta existe e oferece instalar via npm ou brew. |

### Exemplos de `api_test`

```bash
api_test get https://api.github.com/users/octocat
api_test get https://api.example.com/users Authorization:'Bearer tk'

# `=` é string; `:=` é JSON puro. Sem adivinhação de tipo:
api_test post https://api.example.com/users name=John age:=30 ativo:=true
api_test post https://api.example.com/users cpf=01234567890   # zero à esquerda preservado
api_test post https://api.example.com/users 'tags:=["a","b"]'

# GraphQL — a query é uma string comum
api_test post https://api.example.com/graphql 'query=query { users { id name } }'

# Query params e path params vão na própria URL
api_test get 'https://api.example.com/users?page=1&limit=10'
```

## 📄 Estrutura

```
bootstrap.sh          bash — o mínimo para o fish existir numa máquina zero
install.fish          fish — links, Brewfile, fisher, node, shell padrão
Brewfile              tudo que a máquina precisa ter instalado
config.fish           PATH, autoload, aliases, prompt, nvm
functions/*.fish      uma função por arquivo (o nome do arquivo é o nome da função)
functions/devutil/    subcomandos do devutil (devutil_uuid.fish → devutil uuid)
docs/                 decisões de manutenção que precisam sobreviver à memória
```

### Como adicionar uma função

Crie `functions/nome.fish` com `function nome --description "o que faz"` e rode
`dotsetup`. Ela aparece no `dothelp` sozinha.

Para um subcomando do `devutil`: crie `functions/devutil/devutil_algo.fish` com
`function devutil_algo --description "..."`. O `devutil algo` passa a funcionar e
aparece no `devutil help` — sem editar o dispatcher. O autoload resolve pelo nome
do arquivo, por isso ele precisa bater com o nome da função.

## 🧼 Licença

MIT — sinta-se à vontade para copiar, modificar, usar e distribuir.
