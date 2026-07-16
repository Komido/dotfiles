function envdiff --description "Compara .env com .env.example e aponta as chaves faltando"
    set -l exemplo .env.example
    set -l atual .env

    switch (count $argv)
        case 1
            set atual $argv[1]
        case 2
            set atual $argv[1]
            set exemplo $argv[2]
    end

    # .env.example tem meia dúzia de nomes possíveis conforme o projeto; procura
    # os usuais antes de desistir.
    if not test -f $exemplo
        for candidato in .env.example .env.sample .env.template .env.dist
            if test -f $candidato
                set exemplo $candidato
                break
            end
        end
    end

    if not test -f $exemplo
        echo "❌ Nenhum arquivo de exemplo encontrado (.env.example, .env.sample, .env.template)."
        echo "   Uso: envdiff [.env] [.env.example]"
        return 1
    end

    if not test -f $atual
        echo "❌ $atual não existe."
        echo "   Comece com: cp $exemplo $atual"
        return 1
    end

    set -l chaves_exemplo (_envdiff_chaves $exemplo)
    set -l chaves_atual (_envdiff_chaves $atual)

    set -l faltando
    for chave in $chaves_exemplo
        contains -- $chave $chaves_atual; or set -a faltando $chave
    end

    set -l sobrando
    for chave in $chaves_atual
        contains -- $chave $chaves_exemplo; or set -a sobrando $chave
    end

    # Chave declarada mas sem valor quebra igual a chave ausente, e é mais difícil
    # de ver: o `cp .env.example .env` deixa o arquivo cheio delas.
    set -l vazias (_envdiff_vazias $atual)

    echo ""
    echo "📋 $atual  ←→  $exemplo"
    echo ""

    if test (count $faltando) -gt 0
        set_color brred
        echo "❌ Faltando em $atual ("(count $faltando)"):"
        set_color normal
        for chave in $faltando
            echo "   $chave"
        end
        echo ""
    end

    if test (count $vazias) -gt 0
        set_color bryellow
        echo "⚠️  Declaradas sem valor ("(count $vazias)"):"
        set_color normal
        for chave in $vazias
            echo "   $chave"
        end
        echo ""
    end

    if test (count $sobrando) -gt 0
        set_color brblue
        echo "ℹ️  Só em $atual, ausentes do exemplo ("(count $sobrando)"):"
        set_color normal
        for chave in $sobrando
            echo "   $chave"
        end
        echo "   (vale adicionar ao $exemplo para o próximo que clonar)"
        echo ""
    end

    if test (count $faltando) -eq 0 -a (count $vazias) -eq 0
        set_color brgreen
        echo "✅ Todas as "(count $chaves_exemplo)" chaves do exemplo estão preenchidas."
        set_color normal
        echo ""
    end

    test (count $faltando) -eq 0
end

function _envdiff_chaves --description "Extrai os nomes das chaves de um arquivo .env"
    # Ignora comentário e linha em branco; aceita o prefixo `export`.
    string match -rg '^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=' -- (cat $argv[1])
end

function _envdiff_vazias --description "Lista chaves declaradas sem valor num .env"
    string match -rg '^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*[\'"]?[\'"]?\s*$' -- (cat $argv[1])
end
