function devutil_jwt
    try_install_tool jq brew
    if test (count $argv) -lt 1
        echo "📥 Informe o token JWT para decodificar:"
        return 1
    end
    echo $argv[1] | cut -d "." -f2 | base64 --decode | jq .
end
