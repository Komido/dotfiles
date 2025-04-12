function api_get
    curl -X GET $argv[1] -H "Content-Type: application/json"
end
