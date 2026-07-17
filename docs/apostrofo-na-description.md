# Apóstrofo na --description quebrava o help

## O problema

O `_dot_describe` extraía a description com o regex `--description '([^']*)'`
sobre a saída de `functions <nome>`. Só que o fish reimprime a definição com o
apóstrofo escapado — `--description 'Gera CNPJ\'s válidos'` — e o `[^']*` para
no `\`, o fechamento não casa e o match falha em silêncio. Resultado: `devutil
help` e `dothelp` mostravam `—` no lugar da descrição, sem nenhum erro.

Na época o contorno foi reescrever a description do `devutil_cnpj` sem o
apóstrofo — ou seja, o parser é que ditava como se podia escrever português.

## A correção

Em vez de endurecer o regex para aceitar `\'` (mais um escape para errar
depois), o parser trocou de fonte: `functions -Dv <nome>` imprime a description
crua na 5ª linha, sem aspas nem escapes. Não há parse, logo não há caso que
escape dele.

## Teste manual

Depois de mexer no `_dot_describe`, `dothelp` ou `devutil`, conferir que uma
description com apóstrofo aparece inteira no help:

```fish
# em ~/.config/fish/functions/devutil/devutil_teste.fish
function devutil_teste --description "Gera CNPJ's válidos p/ teste"
    true
end
```

`devutil help` deve listar `teste → Gera CNPJ's válidos p/ teste` — se aparecer
`—`, o parser regrediu. Apagar o arquivo depois de conferir.
