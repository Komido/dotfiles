function _devutil_ejetar_listar --description "Resume por app e pasta quem usa o volume"
    set -l vol $argv[1]
    set -e argv[1]
    test (count $argv) -gt 0; or return 0

    # Um editor aberto num projeto vira vários processos (host de extensões,
    # servidor do TypeScript, ESLint...). Agrupar por app + pasta mostra o que
    # importa: quais janelas/projetos estão segurando o volume.
    set -l rotulos
    set -l pastas
    set -l contagens
    for linha in $argv
        set -l campos (string split \t -- $linha)
        set -l pasta (_devutil_ejetar_pasta $campos[1] $vol; or echo "—")
        set -l rotulo (_devutil_ejetar_app $campos[1])
        if test -z "$rotulo"
            # Processo solto (dev server numa aba do terminal): não tem app para
            # fechar, então o que interessa é o PID.
            set rotulo "$campos[2] (PID $campos[1])"
        end

        # `seq 0` no macOS conta para trás (1, 0): só percorro se já houver grupo.
        set -l achou 0
        if test (count $rotulos) -gt 0
            for i in (seq (count $rotulos))
                if test "$rotulos[$i]" = "$rotulo"; and test "$pastas[$i]" = "$pasta"
                    set contagens[$i] (math $contagens[$i] + 1)
                    set achou 1
                    break
                end
            end
        end
        if test $achou -eq 0
            set -a rotulos $rotulo
            set -a pastas $pasta
            set -a contagens 1
        end
    end

    printf "   %-28s %-5s %s\n" APP PROC PASTA
    for i in (seq (count $rotulos))
        printf "   %-28s %-5s %s\n" (string sub -l 28 -- $rotulos[$i]) $contagens[$i] $pastas[$i]
    end
end
