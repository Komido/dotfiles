function proj
    set base_dir ~/Projetos
    set choices

    # Cabeçalho formatado como uma "opção fake" para fzf (não selecionável)
    set header (printf "%s %-9s %-38s %-20s • %-12s  %s   %s" \
        "📂" "Tipo" "Projeto" "Versão" "Node" "Git" "⏱ Último Commit")
    set choices "0 ->> $header ->> /dev/null" # linha fake para fzf

    for dir in (fd '' $base_dir --type d --max-depth 1)
        set name (basename $dir)

        # Tipo
        if string match -iq '*api*' $name
            set tipo 1
            set icon "" # ícone Nerd Font de API (caixa)
            set label "[api]"
        else if string match -iq '*app*' $name
            set tipo 2
            set icon "" # ícone Nerd Font de web/app
            set label "[app]"
        else if string match -iq '*script*' $name
            set tipo 3
            set icon "" # ícone Nerd Font de terminal/script
            set label "[script]"
        else if string match -iq '*serverless*' $name
            set tipo 4
            set icon "" # ícone Nerd Font de nuvem
            set label "[srv]"
        else
            set tipo 9
            set icon "" # ícone Nerd Font de pasta
            set label "[other]"
        end

        # Versão
        set app_version -
        if test -f "$dir/package.json"
            set app_version (jq -r '.version // empty' "$dir/package.json" 2>/dev/null)
            if test -z "$app_version"
                set app_version -
            end
        end

        # Node version
        set node -
        if test -f "$dir/.nvmrc"
            set node (cat "$dir/.nvmrc")
        else if test -f "$dir/package.json"
            set node (jq -r '.engines.node // empty' "$dir/package.json" 2>/dev/null)
        end
        if test -z "$node"
            set node -
        end

        # Git status
        set git_icon "–"
        if test -d "$dir/.git"
            set git_status (command git -C $dir status --porcelain 2>/dev/null)
            if test $status -eq 0
                if test -z "$git_status"
                    set git_icon "✔"
                else
                    set git_icon "✚"
                end
            else
                set git_icon "✖"
            end
        end

        # Último commit
        set last_commit -
        if test -d "$dir/.git"
            set last_commit (command git -C $dir log -1 --format="%cs" 2>/dev/null)
            if test -z "$last_commit"
                set last_commit -
            end
        end

        # Linha formatada
        set formatted (printf "%s %-9s %-38s %-20s • %-12s  %s   ⏱ %s" \
            "$icon" "$label" "$name" "v$app_version" "$node" "$git_icon" "$last_commit")

        set choices $choices "$tipo ->> $formatted ->> $dir"
    end

    # Exibe com cabeçalho fixo no topo
    set selected (printf "%s\n" $choices | sort | fzf \
        --delimiter=" ->> " --with-nth=2 --no-sort \
        --header-lines=1 --reverse)

    # Ignora seleção do cabeçalho
    if test -n "$selected"
        set path (string split " ->> " $selected)[3]
        if test "$path" != /dev/null
            cd $path
            open -a Cursor $path
        end
    end
end
