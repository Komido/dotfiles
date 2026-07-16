function slug --description "Converte texto em slug URL-safe e copia (trata acentuação)"
    # `read -z`, e não `(cat)`: substituição de comando no fish não herda a stdin
    # do pipe, então `set x (cat)` aqui voltaria vazio em silêncio.
    set -l texto
    if test (count $argv) -gt 0
        set texto (string join ' ' -- $argv)
    else if not isatty stdin
        read -z texto
    else
        echo "Uso: slug \"Meu Título Ótimo\""
        echo "     echo \"Meu Título\" | slug"
        return 1
    end

    # Acentuação via NFD, e não via `iconv //TRANSLIT`.
    #
    # O iconv do macOS é péssimo nisso: //TRANSLIT transforma "Ação" em "Ac~ao"
    # (e ainda retorna status 1), e o -c dropa o caractere inteiro, virando "Ao".
    # Converter para UTF-8-MAC decompõe "ç" em "c" + cedilha combinante; o `tr`
    # então joga fora tudo que não é ASCII imprimível e sobra o "c". Resultado:
    # "Ação" → "acao", que é o que se espera de um slug.
    set -l s (printf '%s' $texto | iconv -f UTF-8 -t UTF-8-MAC | LC_ALL=C tr -cd '\11\12\15\40-\176')

    set s (string lower -- $s)
    set s (string replace -ra '[^a-z0-9]+' '-' -- $s)
    set s (string trim -c '-' -- $s)

    if test -z "$s"
        echo "❌ Nada sobrou depois de limpar o texto."
        return 1
    end

    printf '%s' $s | pbcopy
    printf '%s\n📋 Slug copiado.\n' $s
end
