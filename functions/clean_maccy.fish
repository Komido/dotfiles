function clean_maccy
    set_color brmagenta
    echo ""
    echo "🧹 Limpando histórico do Maccy (sem apagar fixados)..."
    set_color normal

    set STORAGE_DIR (defaults read org.p0deje.Maccy storagePath ^/dev/null)

    if test -z "$STORAGE_DIR" -o ! -d "$STORAGE_DIR"
        echo "❌ Diretório de armazenamento não encontrado. Abortando."
        return
    end

    set LIMIT 1000

    # Lista todos os arquivos e separa os fixados
    set PINNED_FILES (grep -l '"pinned"[ \t]*:[ \t]*true' $STORAGE_DIR/*.json)
    set NON_PINNED_FILES ()

    for file in (ls -1t $STORAGE_DIR/*.json)
        if not contains $file $PINNED_FILES
            set NON_PINNED_FILES $NON_PINNED_FILES $file
        end
    end

    set TOTAL_NON_PINNED (count $NON_PINNED_FILES)

    if test $TOTAL_NON_PINNED -le $LIMIT
        echo "✅ Nenhuma limpeza necessária. Total de itens não fixados: $TOTAL_NON_PINNED"
        return
    end

    set TO_DELETE (math $TOTAL_NON_PINNED - $LIMIT)
    set FILES_TO_DELETE (echo $NON_PINNED_FILES | tr ' ' '\n' | tail -n $TO_DELETE)

    for file in $FILES_TO_DELETE
        rm "$file"
    end

    echo "🗂️ Removidos $TO_DELETE itens não fixados. Histórico agora com no máximo $LIMIT itens (sem apagar fixados)."
end
