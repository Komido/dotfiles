function _devutil_ejetar_rapido --description "Ejeta sem fechar os apps, só depois de verificar que nada está gravando"
    # Para quem não quer fechar VS Code e Claude a cada vez que leva o SSD. Os
    # apps ficam abertos e só perdem o acesso aos arquivos até reconectar. O que
    # torna isso aceitável é não haver escrita em andamento na hora: dev servers
    # param antes, e um `git` no meio (o VS Code faz fetch e status sozinho) é
    # esperado em vez de cortado, porque é o que deixaria um index.lock órfão.
    set -l vol $argv[1]

    # 1. Algo trabalhando de verdade (install, build, migration, agente ativo)?
    # Checado antes de parar processos: matar um install no meio é pior do que
    # simplesmente não ejetar agora.
    set -l motivos (_devutil_ejetar_ocupados $vol trabalho)
    if test (count $motivos) -gt 0
        echo "🚦 Modo rápido recusado: há trabalho em andamento no SSD."
        printf "   %s\n" $motivos
        echo "   Espere terminar ou use o modo seguro [f]."
        return 1
    end

    # 2. Dev servers e afins podem parar: não guardam nada que se perca.
    _devutil_ejetar_soltos $vol

    # 3. Só fica aberto o app que sabidamente aguenta a pasta sumir e voltar.
    # O VS Code e o Claude só reclamam até o reload; o Bruno, no primeiro teste
    # (out/2026), fechou com erro porque vigiava a coleção no SSD. O resto sai
    # do jeito normal, como no modo seguro, e se não sair (pedindo para salvar),
    # recuso em vez de desmontar por baixo dele.
    set -l tolerantes "Visual Studio Code" Cursor Claude
    set -l fechar
    for linha in (_devutil_ejetar_usando $vol)
        set -l campos (string split \t -- $linha)
        set -l app (string match -r -g '/([^/]+)\.app/' -- (ps -o comm= -p $campos[1] 2>/dev/null))[1]
        if test -z "$app"; and contains -- (string replace -r '^-' '' -- $campos[2]) fish zsh bash sh
            set app (_devutil_ejetar_app $campos[1] --pai)
        end
        test -n "$app"; or continue
        contains -- $app $tolerantes $fechar; and continue
        set -a fechar $app
    end
    for app in $fechar
        echo "👋 Fechando $app (não aguenta o disco sumir com ele aberto)..."
        osascript -e "quit app \"$app\"" >/dev/null 2>&1
    end
    if test (count $fechar) -gt 0
        for i in (seq 10)
            set -l restam
            for app in $fechar
                pgrep -fq -- "/$app.app/"; and set -a restam $app
            end
            test (count $restam) -eq 0; and break
            sleep 1
        end
        for app in $fechar
            if pgrep -fq -- "/$app.app/"
                echo "🚦 Modo rápido recusado: $app não fechou (pedindo para salvar?)."
                echo "   Resolva nele e chame de novo."
                return 1
            end
        end
    end

    for i in (seq 10)
        set -l git_ativo 0
        for linha in (_devutil_ejetar_usando $vol)
            set -l campos (string split \t -- $linha)
            if test "$campos[2]" = git
                set git_ativo 1
                break
            end
        end
        test $git_ativo -eq 0; and break
        test $i -eq 1; and echo "⏳ Esperando um git terminar..."
        sleep 1
    end

    set -l abas
    for linha in (_devutil_ejetar_usando $vol)
        set -l campos (string split \t -- $linha)
        if test "$campos[2]" = git
            echo "❌ Ainda há um git rodando em $vol depois de 10 s. Tente de novo em instantes."
            return 1
        end
        if contains -- (string replace -r '^-' '' -- $campos[2]) fish zsh bash sh
            and not _devutil_ejetar_app $campos[1] --pai >/dev/null
            set -a abas $linha
        end
    end

    # 4. Teste final e direto: ninguém com arquivo aberto para gravação. Dou
    # alguns segundos para quem acabou de receber SIGTERM fechar o que tinha.
    for i in (seq 5)
        set motivos (_devutil_ejetar_ocupados $vol escrita)
        test (count $motivos) -eq 0; and break
        sleep 1
    end
    if test (count $motivos) -gt 0
        echo "🚦 Modo rápido recusado: ainda há escrita no SSD."
        printf "   %s\n" $motivos
        echo "   Tente de novo em instantes ou use o modo seguro [f]."
        return 1
    end

    _devutil_ejetar_desmontar $vol; or return 1

    echo ""
    echo "Ao reconectar o SSD:"
    echo "   VS Code: Cmd+Shift+P > Reload Window em cada janela de projeto."
    echo "   Arquivos não salvos continuam abertos; salve depois do reload."
    echo "   Claude: reconecte a pasta na conversa, se ela estava conectada."
    if test (count $abas) -gt 0
        echo "   Terminais que estavam dentro do SSD: rode 'cd ~' neles."
        _devutil_ejetar_listar $vol $abas 2>/dev/null
    end
end
