function _devutil_base36 --description "Converte um inteiro para base36, com largura fixa opcional"
    set -l n $argv[1]
    set -l largura $argv[2]
    set -l alfabeto 0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z

    # `set -l saida ""` (string vazia), e NÃO `set -l saida` (lista vazia): em
    # fish, concatenar texto com uma lista vazia devolve lista vazia, e o valor
    # sumiria a cada volta do laço. A função retornava vazio para todo n > 0.
    set -l saida ""

    if test $n -eq 0
        set saida 0
    end

    # O `math` do fish mantém precisão exata nesta ordem de grandeza: o timestamp
    # em ms é ~1,7e12, e a ida e volta (q * 36 + r) foi conferida antes de escrever.
    while test $n -gt 0
        set saida $alfabeto[(math (math "$n % 36") + 1)]$saida
        set n (math -s0 "$n / 36")
    end

    if test -n "$largura"
        while test (string length -- "$saida") -lt $largura
            set saida "0$saida"
        end
        if test (string length -- "$saida") -gt $largura
            set saida (string sub -s (math (string length -- "$saida") - $largura + 1) -- "$saida")
        end
    end

    echo $saida
end

function _devutil_base36_random --description "Gera N caracteres base36 aleatórios"
    LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c $argv[1]
end

function devutil_cuid --description "Gera um CUID e copia para a área de transferência"
    # Gerado aqui, sem npm.
    #
    # Antes chamava `try_install_tool cuid-cli`, que instala um pacote GLOBAL do
    # npm — e global do npm mora dentro da versão de Node ativa. O cuid-cli estava
    # no Node 22 enquanto o default é o 20, então a função não achava o binário e
    # pedia para instalar de novo a cada troca de versão, deixando uma cópia em
    # cada uma. É a mesma bagunça que docs/limpeza-shells-legado.md registrou
    # (serverless instalado em três versões de Node diferentes).
    #
    # Formato CUID v1, o mesmo do `@default(cuid())` do Prisma:
    #   c + timestamp(8) + contador(4) + fingerprint(4) + aleatório(8) = 25 chars

    # O `date` do macOS é BSD, mas o do Darwin 25 aceita %N (nanossegundos) —
    # verificado. A guarda cobre um BSD antigo, onde %N sairia literal.
    set -l ns (date +%N 2>/dev/null)
    if not string match -qr '^[0-9]+$' -- "$ns"
        set ns 000000000
    end
    set -l ts (_devutil_base36 (date +%s)(string sub -l 3 -- $ns))

    # No cuid original o contador incrementa dentro do processo, para desempatar
    # IDs criados no mesmo milissegundo. Aqui cada chamada é um processo novo, e
    # quem garante unicidade são o timestamp em ms e os 8 chars aleatórios.
    set -l contador (_devutil_base36 (random 0 1679615) 4)

    # Fingerprint: 2 chars do PID + 2 do hostname, como no original — identifica
    # de qual máquina/processo o ID saiu. 1296 = 36², o teto de 2 dígitos base36.
    set -l host_soma (hostname | cksum | string split ' ')[1]
    set -l fp (_devutil_base36 (math "$fish_pid % 1296") 2)(_devutil_base36 (math "$host_soma % 1296") 2)

    set -l id "c$ts$contador$fp"(_devutil_base36_random 8)

    printf '%s' $id | pbcopy
    printf '\n%s\n\n📋 CUID copiado.\n\n' $id
end
