# nvm clássico (`~/.nvm`) — removido em 2026-07-16

O `~/.nvm` (nvm clássico, instalado via git clone) foi removido. O gerenciador de
Node desta máquina é o **nvm.fish**, em `~/.local/share/nvm`, configurado no
`config.fish`.

Este documento existe para que a remoção seja reversível sem depender de memória.

## Por que foi removido

- 2.8 GB em disco.
- Referenciado só por `~/.zshrc` e `~/.bash_profile`; o shell padrão é o fish
  desde sempre e o `.zsh_history` não era tocado desde maio/2025.
- Nenhum dos binários globais era alcançável a partir do fish — os dois nvm usam
  layouts incompatíveis (`$NVM_DIR/versions/node/vX/bin` no clássico,
  `$nvm_data/vX/bin` no nvm.fish), então nada dali estava em uso.
- Conteúdo 100% reinstalável: um checkout limpo do nvm na v0.39.7 (sem commits
  locais), binários de Node baixáveis e pacotes públicos do npm. O único `.npmrc`
  continha apenas `package-lock=false`, sem credenciais.

## Como restaurar, se algum dia precisar

O nvm.fish cobre o fish. Isto só é necessário para ter Node em **zsh ou bash**:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20        # o alias `default` apontava para 20
```

`~/.zshrc` e `~/.bash_profile` também foram removidos — veja a seção abaixo.

## Pacotes globais que existiam (reinstale só o que sentir falta)

Estavam espalhados por versões antigas de Node e provavelmente desatualizados —
prefira reinstalar na versão atual em vez de fixar estas.

| Pacote | Versão | Estava no Node |
| --- | --- | --- |
| `netlify-cli` | 3.29.14 | v16.20.0 |
| `next` | 15.0.2 | v18.13.0 |
| `serverless` | 4.1.22 | v18.13.0 |
| `serverless` | 3.23.0 | v19.0.0 |
| `serverless` | 3.38.0-d09dc659 | v20.13.1 |
| `@angular/cli` | 14.2.6 | v19.0.0 |
| `@angular/cli` | 18.1.2 | v20.13.1 |
| `@ionic/cli` | 7.1.1 | v19.0.0 |
| `@shopify/cli` | 3.60.1 | v19.0.0 |
| `json-server` | 0.17.3 | v19.0.0 |
| `live-server` | 1.2.2 | v19.0.0 |
| `nodemon` | 2.0.20 | v19.0.0 |
| `yarn` | 1.22.19 | v19.0.0 |
| `pm2` | 6.0.5 | v20.13.1 |

Reinstalação, na versão ativa:

```fish
npm install -g netlify-cli serverless @angular/cli @ionic/cli @shopify/cli \
  json-server live-server nodemon yarn pm2
```

`vitest-environment-prisma@1.0.0` também aparecia em v19.0.0, mas era um `npm link`
para `~/Projetos/api-checkout/prisma/vitest-environment-prisma` — um link já
quebrado na remoção, apontando para um caminho inexistente. Nada a restaurar.

## Versões de Node que existiam lá

v11.11.0, v16.20.0, v18.12.1, v18.13.0, v18.16.1, v18.17.0, v19.0.0, v20.13.1,
v20.20.2, v22.14.0. Reinstale sob demanda com `nvm install <versão>`.

## `~/.zshrc`, `~/.bash_profile` e `~/.oh-my-zsh` também saíram (2026-07-16)

O fish é o shell padrão e cobria tudo que esses arquivos faziam:

| No zsh/bash | No fish |
| --- | --- |
| oh-my-zsh + tema spaceship | starship |
| `plugins=(git)` | `jhillyerd/plugin-git` |
| `plugins=(python)` + prompt de virtualenv | starship (nativo) |
| `NVM_DIR` + `nvm.sh` | nvm.fish |
| `rbenv init` | nada — rbenv não está instalado, a linha era morta |
| `alias claude-mem=...` | nada — colado pelo instalador do plugin; o uso real é `npx claude-mem` |

O zsh e o bash continuam instalados e iniciam sem erro; só ficaram sem config.
Para voltar ao oh-my-zsh: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`.

Isso também matou um zumbi: `~/.zshrc` fazia `source $(brew --prefix nvm)/nvm.sh`
com `NVM_DIR=~/.nvm`, e o nvm do Homebrew **recriava `~/.nvm`** (0 bytes, dois
symlinks) a cada início de zsh ou bash. Era essa a origem do
`~/.nvm/versions/node/v20.20.2` datado de 2026-07-08 — uma sessão de shell, não
uso real. Sem o `.zshrc`, o diretório não volta mais.

## A formula `nvm` do Homebrew também saiu (2026-07-16)

`brew uninstall nvm` — 10 arquivos, 211 KB. Era o que sobrava do zumbi acima: sem
o `.zshrc` ela tinha parado de agir, mas continuava instalada e sem uso.

Antes de remover, foi verificado que ela não tem relação nenhuma com o nvm que
funciona aqui:

| | nvm.fish (o que você usa) | formula do brew (removida) |
| --- | --- | --- |
| O quê | plugin do fisher | `libexec/nvm.sh`, um script **bash/zsh** |
| Onde | `~/.config/fish/functions/nvm.fish` | `/opt/homebrew/Cellar/nvm/0.40.2/` |
| Dados | `~/.local/share/nvm` (v16, v18, v20, v22) | nenhum |

`brew uses --installed nvm` vinha vazio, `~/.nvm` não existia mais e nenhum
arquivo de shell referenciava o `nvm.sh`. Depois da remoção, `node --version`
seguiu em v20.19.0 e o `nvm list` seguiu mostrando as 4 versões.

Para reinstalar (só faz sentido se você voltar a usar zsh/bash): `brew install nvm`.

## 47 formulae órfãs removidas (2026-07-16)

`brew autoremove` levou 46 dependências que nenhum pacote pedia mais — restos que
o upgrade do **ffmpeg para a 8.1.2** deixou para trás (`aom`, `libass`, `rav1e`,
`jpeg-xl`, `tesseract`, `icu4c@77`...). Com a formula do nvm, 47 no total:
**Cellar de 2.2 GB → 1.9 GB**, 133 → 86 formulae.

Foi verificado antes que as 46 formavam um **cluster fechado**: 25 delas
apareciam como "em uso", mas só por outras da própria lista (`brotli` ← `aom`,
`jpeg-xl`; `fribidi` ← `libass`, `pango`, `tesseract`). Nenhuma tinha usuário
fora do grupo, e nenhuma constava em `brew list --installed-on-request`.

Foi preciso rodar o `autoremove` **duas vezes**: remover o primeiro nível deixou
mais 8 órfãs (`brotli`, `icu4c@77`...), que só ficaram sem usuário depois que
`aom` e `jpeg-xl` saíram. Vale rodar até dizer "0 unneeded".

Nada quebrou: o ffmpeg foi testado encodando um vídeo real com libx264, e não só
pelo `--version`. Se um dia algo precisar de uma delas, o brew a reinstala
sozinha como dependência.

O `dotdoctor` passou a vigiar isso: ele acusa formula órfã, binário do Homebrew
sombreado por instalação manual e drift do Brewfile.

## Gotcha: globais de npm são por versão de Node (pnpm, yarn, etc.)

Depois que o `config.fish` passou a montar o PATH só com a versão de Node **ativa**,
um global instalado em outra versão some do PATH. O sintoma é enganoso —
`fish: Unknown command: pnpm` num terminal que abre normalmente.

Foi o que aconteceu com o `pnpm`: ele estava instalado como global só no **Node v22**.
O bug antigo do glob (`set -gx PATH $NVM_DIR/v*/bin $PATH`) colocava as quatro versões
no PATH ao mesmo tempo, então o `pnpm` do v22 era alcançado por acaso, mesmo com o
`node` sendo outro. Com o PATH limpo (só o v20 ativo), esse acesso acidental sumiu — o
`pnpm` não foi removido, só deixou de vazar entre versões.

**Não reinstale o global por versão.** Use o `corepack`, que vem com o Node e lê o
campo `packageManager` do projeto:

```fish
corepack enable pnpm    # cria o shim no bin da versão de Node ATIVA
```

Dentro de um projeto que declara `"packageManager": "pnpm@10.19.0"`, o corepack usa
exatamente essa versão, sem você gerenciar nada. Reverter: `corepack disable`.

Duas consequências a lembrar:

- O shim vive no bin de **cada** versão de Node. Ao trocar de versão (`nvm use 22`),
  rode `corepack enable pnpm` de novo naquela versão, ou o `pnpm` some outra vez.
- Qualquer outro global que você tenha instalado com `npm install -g` em uma versão
  específica (`vercel`, `serverless`, CLIs diversas) tem o mesmo comportamento — se
  sumir depois de trocar de Node, é isto, não a config quebrada. `npm ls -g` na versão
  onde ele estava mostra o que existe lá.

## Pendência conhecida: `~/.rbenv`

269MB com Ruby 3.2.0 e 3.2.2, mas **o rbenv não está instalado** — os binários
estão órfãos e inutilizáveis em qualquer shell, e já estavam antes desta limpeza.
Mantido por decisão explícita. Para usar: `brew install rbenv`. Para remover:
`rm -rf ~/.rbenv`.
