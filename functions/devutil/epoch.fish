function devutil_epoch
    if test (count $argv) -gt 0
        date -r $argv[1] "+%Y-%m-%d %H:%M:%S"
    else
        set -l now (date +%s)
        echo $now | tee /dev/tty | pbcopy
        echo "✅ Timestamp copiado para a área de transferência."
    end
end
