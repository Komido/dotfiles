function _devutil_ejetar_soltos --description "Manda SIGTERM no que usa o volume e não é app, VM nem terminal de editor"
    # Dev server solto, node, watcher... Sem SIGKILL: matar à força no meio de
    # uma escrita é justamente o que se quer evitar. App de interface (fecha pelo
    # AppleScript ou fica aberto no modo rápido), VM (matar derruba o app dono) e
    # terminal integrado de editor (fica com o editor) não entram.
    set -l vol $argv[1]
    for linha in (_devutil_ejetar_usando $vol)
        set -l campos (string split \t -- $linha)
        set -l exe (ps -o comm= -p $campos[1] 2>/dev/null)
        string match -qr '\.app/' -- $exe; and continue
        string match -q '*com.apple.Virtualization*' -- $exe; and continue
        if contains -- (string replace -r '^-' '' -- $campos[2]) fish zsh bash sh
            # Shell: nunca mato. O de editor fica com o editor; o de terminal de
            # verdade é a aba de alguém, e quem decide sobre ela é a pessoa.
            continue
        end
        kill $campos[1] 2>/dev/null
    end
end
