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

## Pendência conhecida: `~/.rbenv`

269MB com Ruby 3.2.0 e 3.2.2, mas **o rbenv não está instalado** — os binários
estão órfãos e inutilizáveis em qualquer shell, e já estavam antes desta limpeza.
Mantido por decisão explícita. Para usar: `brew install rbenv`. Para remover:
`rm -rf ~/.rbenv`.
