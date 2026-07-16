# `~/.rbenv` e `~/.dotnet` removidos — 2026-07-16

Duas instalações manuais órfãs, 762 MB somados. Ambas eram **duplicatas ou
restos**: nada que estivesse em uso foi tocado.

## `~/.dotnet` — 493 MB, removido

Era uma **segunda instalação completa do .NET**, paralela à que o sistema usa.
É o diretório padrão do `dotnet-install.sh` (o script de instalação da
Microsoft), então quase certamente veio de um `curl | sh` em abril/2024.

| | `/usr/local/share/dotnet` (mantida) | `~/.dotnet` (removida) |
| --- | --- | --- |
| SDK | 6.0.428 | 6.0.125 |
| Runtime | 6.0.36 | 6.0.25 |
| Data | out/2024 | abr/2024 |
| Usada? | sim — é o que o PATH resolve | nunca |

Verificado antes de remover:

- `which dotnet` → `/usr/local/share/dotnet/dotnet`; o `~/.dotnet` nunca vencia.
- `dotnet --list-sdks` só enxergava `/usr/local/share/dotnet`.
- `DOTNET_ROOT` não estava definido em lugar nenhum.
- `~/.dotnet/tools` estava vazia (0 ferramentas globais).
- O SDK 6.0.125 dela **nem serviria**: o `global.json` dos projetos fixa 6.0.419.

Depois de remover, o `dotnet --version` seguiu em 6.0.428, os runtimes seguiram
visíveis e o `global.json` do `api-tray-admin` seguiu resolvendo.

### O .NET do sistema NÃO pode ser removido

Três projetos ativos dependem dele:

| Projeto | Último commit | Exige |
| --- | --- | --- |
| `api-tray-admin` | 2025-08-18 | net6.0, SDK 6.0.419 |
| `api-yampi-admin` | 2025-06-04 | net6.0, SDK 6.0.419 |
| `api-tray-influencer` | 2025-06-02 | net6.0 |

O .NET 6 está em fim de vida desde nov/2024, mas quem manda aqui é o
`global.json`, não o calendário da Microsoft. Ele também não entra no Brewfile:
o brew só tem versões novas, que esses projetos não aceitam.

## `~/.rbenv` — 269 MB, removido

Ruby 3.2.0 (119 gems) e 3.2.2 (86 gems), com o `rbenv` **ausente**: não existia
`~/.rbenv/bin`, e os shims falhavam literalmente com
`/opt/homebrew/bin/rbenv: No such file or directory`. Os Rubies eram
inalcançáveis de qualquer shell.

O único projeto Ruby é o `maisfy-mobile` (Gemfile + `ios/Podfile`), e ele não
precisava de nada disso:

- O `Gemfile` pede `ruby ">= 2.6.10"`, e o Ruby do sistema é exatamente 2.6.10.
- Não há `.ruby-version` fixando a 3.2.
- O `Gemfile` pede `cocoapods >= 1.13`; o que estava no rbenv era o **1.12.1** —
  velho demais para o projeto.
- O `pod` do rbenv estava **quebrado**: reclamava de `missing psych (for YAML
  output)` e de extensões não compiladas. Sem psych, o CocoaPods nem lê o Podfile.
- Prova final: o `ios/Podfile.lock` registra `COCOAPODS: 1.16.2`. O projeto foi
  construído com a 1.16.2, nunca com a 1.12.1 de lá.

### Parte precisou de sudo

O `rm -rf` normal parou em 66 MB: os arquivos restantes eram **`root:wheel`**,
datados de agosto/2023 — resto de um `sudo gem install` da época. Foi preciso
`sudo rm -rf ~/.rbenv` para terminar.

Ficou a dica: gem instalada com sudo deixa arquivo de root dentro do seu home,
que o seu próprio usuário não consegue apagar.

### Se precisar de Ruby de novo

Para o `pod install` do maisfy-mobile, o caminho limpo hoje **não é o rbenv**:

```fish
brew install cocoapods   # traz o próprio Ruby, sem gerenciador de versão
```

Se realmente quiser gerenciar versões de Ruby: `brew install rbenv` e
`rbenv install 3.2.2` — os Rubies são baixáveis, nada aqui era local.

## O padrão, de novo

`~/.dotnet` (curl | sh), `~/.rbenv` (curl | sh), `~/.local/bin/zoxide`
(curl | sh), nvm clássico (curl | sh). Quatro no mesmo dia, todos órfãos, todos
invisíveis até quebrarem ou serem procurados.

O `dotdoctor` vigia a parte que dá para automatizar (binário do Homebrew
sombreado, formula órfã, drift do Brewfile). O resto é hábito: `brew search`
antes de qualquer `curl | sh`.
