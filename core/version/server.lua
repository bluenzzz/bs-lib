local VERSIONS_URL <const> = "https://raw.githubusercontent.com/bluenzzz/bs-versions/refs/heads/main/index.json"

function Lib.VersionCheck()
    local resourceName = GetInvokingResource() or RESOURCE_NAME
    local currentVersion = GetResourceMetadata(resourceName, "version", 0)

    PerformHttpRequest(VERSIONS_URL, function(status, body)
        if status ~= 200 or not body then return end

        local versions = json.decode(body)
        if not versions then return end

        local resourceVersion = versions[resourceName]
        if not resourceVersion then return end

        if resourceVersion.version == currentVersion then
            return print(("^5[%s]^7: You are running the latest version"):format(resourceName))
        end

        print(("^5[%s]^7: New version available ^3%s^7"):format(resourceName, resourceVersion.version))
    end, "GET")
end

Lib.VersionCheck()
