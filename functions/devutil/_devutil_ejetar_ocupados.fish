function _devutil_ejetar_ocupados --description "Lista o que impede o modo rápido: install/build, agente trabalhando ou arquivo aberto para escrita"
    # Uso: _devutil_ejetar_ocupados <volume> trabalho|escrita
    #   trabalho: instalação, build, migration ou agente de IA ativo no volume.
    #             Checado antes de parar qualquer processo, para não cortar um
    #             `npm install` no meio só porque ele parecia um processo solto.
    #   escrita:  arquivo comum aberto para gravação no volume, depois que os
    #             dev servers já pararam. É o teste direto de "há escrita agora".
    # Imprime uma linha por motivo; sem saída, está livre.
    set -l vol $argv[1]

    switch $argv[2]
        case trabalho
            for linha in (_devutil_ejetar_usando $vol)
                set -l pid (string split \t -- $linha)[1]
                set -l args (ps -o args= -p $pid 2>/dev/null)
                test -n "$args"; or continue

                if string match -qr '\b(npm|pnpm|yarn|bun)\b.*\s(install|i|ci|add|remove|update|upgrade)(\s|$)' -- $args
                    or string match -qr '\bprisma\b.*\s(migrate|db\s+push|generate)' -- $args
                    or string match -qr '\b(next|vite|tsc|turbo|nest)\b.*\sbuild\b' -- $args
                    echo "📦 instalação/build em andamento (PID $pid): "(string sub -l 70 -- $args)
                    continue
                end

                # Agente de IA parado esperando você não grava nada; trabalhando,
                # pode estar no meio de uma edição. O %CPU do ps é uma média
                # recente, o suficiente para separar um do outro.
                if string match -qr '(^|/)(claude|codex|cursor-agent)(\s|$)' -- $args
                    set -l cpu (string trim -- (ps -o %cpu= -p $pid 2>/dev/null | string replace , .))
                    if test -n "$cpu"; and test (math "round($cpu)") -ge 2
                        echo "🤖 agente trabalhando (PID $pid, $cpu% CPU): "(string sub -l 50 -- $args)
                    end
                end
            end

        case escrita
            # Com -F, cada arquivo vem em linhas de campo: 'p' (PID), 'c' (comando),
            # 'a' (acesso: r, w ou u) e 't' (tipo). Gravação é w ou u num REG.
            set -l pid ""
            set -l cmd ""
            set -l acesso ""
            for campo in (lsof -nP -F pcat -- $vol 2>/dev/null)
                switch $campo
                    case 'p*'
                        set pid (string sub -s 2 -- $campo)
                    case 'c*'
                        set cmd (string sub -s 2 -- $campo)
                    case 'f*'
                        set acesso ""
                    case 'a*'
                        set acesso (string sub -s 2 -- $campo)
                    case 't*'
                        test (string sub -s 2 -- $campo) = REG; or continue
                        contains -- $acesso w u; or continue
                        # A VM do Claude mantém a pasta compartilhada aberta,
                        # sem estar gravando: não conta.
                        string match -q '*com.apple.Virtualization*' -- (ps -o comm= -p $pid 2>/dev/null); and continue
                        echo "✏️  arquivo aberto para escrita por $cmd (PID $pid)"
                end
            end | sort -u
    end
end
