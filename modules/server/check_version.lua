Citizen.CreateThread(function()
    local URL = 'https://raw.githubusercontent.com/bluenzzz/bs-versions/refs/heads/main/index.json'
    local RESOURCE = GetCurrentResourceName()

    PerformHttpRequest(URL, 
        function(err, text, headers) 
            if ( err == 200 ) then
                local decode = json.decode(text)
                local data = decode[ RESOURCE ]
                if ( data ) then
                    if ( data.version ~= GetResourceMetadata(RESOURCE, 'version', 0) ) then
                        print('^5['..RESOURCE..']^7: New version available ^3'..data.version..'^7')
                    else
                        print('^5['..RESOURCE..']^7: You are running the latest version')
                    end
                end
            end
        end, 
        'GET', '[]', 
    { ['Content-Type'] = 'application/json' })
end)