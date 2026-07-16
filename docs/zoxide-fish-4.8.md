# `~/.local/bin/zoxide` removido — 2026-07-16

O `cd` parou de funcionar com este erro:

```
fish: Unknown command: __zoxide_cd_internal
in function '__zoxide_cd' with arguments 'projetos'
```

Causa: **dois zoxide instalados**, e o mais velho ganhava.

| Binário | Versão | Origem |
| --- | --- | --- |
| `~/.local/bin/zoxide` | 0.9.7 (abr/2025) | instalado à mão |
| `/opt/homebrew/bin/zoxide` | 0.10.0 | Homebrew |

O `config.fish` faz `fish_add_path $HOME/.local/bin` **depois** do
`/opt/homebrew/bin`, e o `fish_add_path` insere no *início* do PATH — então o
último a ser adicionado é o primeiro a ser encontrado. O binário de abril
vencia, e o `brew outdated` não acusava nada: o pacote do brew *estava*
atualizado, só não era o que rodava.

## Por que quebrou agora

O fish 4.8 passou a **embutir suas funções no binário**: o diretório
`share/fish/functions/` não existe mais em disco (`type cd` agora responde
`Defined in embedded:functions/cd.fish`).

O init do zoxide 0.9.7 lê esse arquivo do disco para clonar o `cd`:

```fish
string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' \
    <$__fish_data_dir/functions/cd.fish | source
```

Arquivo inexistente → `__zoxide_cd_internal` nunca era definido → o `cd` quebrava.

O zoxide 0.10.0 já corrige, usando a API nova do fish para ler o arquivo embutido:

```fish
if status list-files functions/cd.fish &>/dev/null
    status get-file functions/cd.fish | string replace ... | source
```

O gatilho foi o `brew bundle` do `install.fish`, que atualizou o fish de 4.0.1
para 4.8.1. O zoxide velho já estava lá desde abril, esperando.

## O que foi feito

1. `rm ~/.local/bin/zoxide` — duplicata pura. O zoxide está no `Brewfile`, então
   quem o mantém é o `brew`. Era o único binário de `~/.local/bin` que sombreava
   o Homebrew (`claude`, `cursor-agent`, `graphify`, `uv` e `uvx` só existem lá).

2. O `alias cd="z"` saiu do `config.fish`, trocado por
   `zoxide init fish --cmd cd | source`. O próprio init do zoxide desaconselhava
   o alias: *"Avoid aliasing `cd` to `z` directly, use `zoxide init --cmd=cd fish`
   instead"*. Efeito prático: continua-se digitando `cd`, ganha-se o `cdi`
   (seleção interativa) e perdem-se o `z` e o `zi`.

## Como restaurar, se precisar

O binário removido era reinstalável e não tinha nada de local:

```fish
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

O histórico de diretórios do zoxide **não** estava nele — fica em
`~/.local/share/zoxide/db.zo` e não foi tocado.

Para voltar ao `z`/`zi` em vez do `cd`, troque no `config.fish`:

```fish
zoxide init fish | source
```

## Lição

Ferramenta instalada por script `curl | sh` fora do Homebrew não recebe
atualização de ninguém e sombreia a versão gerenciada em silêncio. Ao encontrar
comportamento estranho numa ferramenta de linha de comando, `which -a <nome>`
antes de qualquer outra coisa.
