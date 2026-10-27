function devutil_ejetar --description "Fecha o que usa o SSD externo e ejeta o volume com segurança"
    # Volume padrão é o SSD de projetos; outro pode vir como argumento.
    set -l vol /Volumes/Dev
    if test (count $argv) -gt 0
        set vol (string trim -r -c / -- $argv[1])
    end

    if not mount | string match -q -- "* on $vol (*"
        echo "ℹ️  $vol não está montado."
        return 0
    end

    # ~/Projetos é symlink para o SSD: comparo pelo caminho real, senão um shell
    # em ~/Projetos/x passaria despercebido segurando o volume.
    if string match -q -- "$vol/*" (pwd -P)/
        cd ~
        echo "📂 O shell atual estava dentro de $vol; fui para ~."
    end

    if diskutil eject $vol >/dev/null 2>&1
        echo "✅ $vol ejetado. Pode desconectar."
        return 0
    end

    set -l usando (_devutil_ejetar_usando $vol)

    # Shell com cwd no volume: o terminal integrado de um editor (pai direto é o
    # .app) fecha junto com o editor logo abaixo. O de um terminal de verdade
    # (Ghostty, Terminal) não dá para tirar de fora sem matar a aba: só aviso.
    set -l shells
    for linha in $usando
        set -l campos (string split \t -- $linha)
        contains -- (string replace -r '^-' '' -- $campos[2]) fish zsh bash sh; or continue
        _devutil_ejetar_app $campos[1] --pai >/dev/null; and continue
        set -a shells $linha
    end
    if test (count $shells) -gt 0
        echo "⚠️  Terminal com pasta em $vol aberto:"
        _devutil_ejetar_listar $vol $shells
        echo ""
        echo "   Rode 'cd ~' nele (ou feche a aba) e chame de novo."
        return 1
    end

    # Só a VM segura? Não há o que encerrar: a única saída é forçar.
    set -l so_vm 1
    for linha in $usando
        set -l pid (string split \t -- $linha)[1]
        if not string match -q '*com.apple.Virtualization*' -- (ps -o comm= -p $pid 2>/dev/null)
            set so_vm 0
            break
        end
    end
    if test $so_vm -eq 1
        _devutil_ejetar_forcar $vol
        return
    end

    echo "🔒 Usando $vol:"
    _devutil_ejetar_listar $vol $usando
    echo ""
    read -l -P "Encerrar tudo isso e ejetar? [s/N] " resp
    if not string match -qi 's*' -- $resp
        echo "🚫 Cancelado."
        return 0
    end

    # Apps de interface (VS Code, Cursor...) fecham pelo AppleScript: guardam o
    # estado e perguntam sobre arquivo não salvo, coisa que um kill não faz.
    set -l apps
    for linha in (_devutil_ejetar_usando $vol)
        set -l campos (string split \t -- $linha)
        # O próprio processo é de um .app, ou é um shell aberto direto por um
        # (terminal integrado: só sai do volume quando o editor fechar). Não subo
        # mais que isso: um node rodando no Ghostty não deve fechar o Ghostty.
        set -l app (string match -r -g '/([^/]+)\.app/' -- (ps -o comm= -p $campos[1] 2>/dev/null))[1]
        if test -z "$app"; and contains -- (string replace -r '^-' '' -- $campos[2]) fish zsh bash sh
            set app (_devutil_ejetar_app $campos[1] --pai)
        end
        if test -n "$app"; and not contains -- $app $apps
            set -a apps $app
        end
    end
    for app in $apps
        echo "👋 Fechando $app..."
        osascript -e "quit app \"$app\"" >/dev/null 2>&1
    end
    if test (count $apps) -gt 0
        _devutil_ejetar_esperar $vol 10
    end

    # O resto (dev server solto, node...) recebe SIGTERM. Sem SIGKILL: matar à
    # força no meio de uma escrita é justamente o que se quer evitar aqui. App de
    # interface que não fechou (ficou pedindo para salvar) também não é morto.
    for linha in (_devutil_ejetar_usando $vol)
        set -l campos (string split \t -- $linha)
        set -l exe (ps -o comm= -p $campos[1] 2>/dev/null)
        if string match -qr '\.app/' -- $exe
            continue
        end
        # VM (app Claude, Docker Desktop): matar derruba o app dono por baixo.
        if string match -q '*com.apple.Virtualization*' -- $exe
            continue
        end
        # Terminal integrado de editor que não fechou: fica com o editor.
        if contains -- (string replace -r '^-' '' -- $campos[2]) fish zsh bash sh
            and _devutil_ejetar_app $campos[1] --pai >/dev/null
            continue
        end
        kill $campos[1] 2>/dev/null
    end
    _devutil_ejetar_esperar $vol 5

    if diskutil eject $vol >/dev/null 2>&1
        echo "✅ $vol ejetado. Pode desconectar."
        return 0
    end

    if _devutil_ejetar_forcar $vol
        return 0
    end

    echo "❌ Não consegui ejetar. Ainda usando $vol:"
    _devutil_ejetar_listar $vol (_devutil_ejetar_usando $vol)
    echo "   App pedindo para salvar? Resolva nele e chame de novo."
    return 1
end
