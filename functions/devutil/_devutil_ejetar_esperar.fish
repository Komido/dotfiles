function _devutil_ejetar_esperar --description "Espera até N segundos o volume ficar livre"
    for i in (seq $argv[2])
        test (count (_devutil_ejetar_usando $argv[1])) -eq 0; and return 0
        sleep 1
    end
    return 1
end
