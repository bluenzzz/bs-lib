local Locales = {}

local function FlattenLocale(localeTable, prefix, result)
    for key, value in pairs(localeTable) do
        local path = prefix .. key

        if type(value) == "table" then
            FlattenLocale(value, path .. ".", result)
        else
            result[path] = value
        end
    end
end

function Lib.LoadLocale(directory)
    local resourceName = GetInvokingResource() or RESOURCE_NAME
    local file = LoadResourceFile(resourceName, directory)
    if not file then return {} end

    local decoded = json.decode(file)
    if not decoded then return {} end

    local locale = Locales[resourceName] or {}
    FlattenLocale(decoded, "", locale)
    Locales[resourceName] = locale
    return locale
end

function Lib.Translate(path, args)
    assert(type(path) == "string", "path must be a string")

    local resourceName = GetInvokingResource() or RESOURCE_NAME
    local locale = Locales[resourceName]
    local translation = locale and locale[path] or path
    if not args then return translation end

    for key, value in pairs(args) do
        local escapedKey = tostring(key):gsub("%p", "%%%0")
        local replacement = tostring(value):gsub("%%", "%%%%")
        translation = translation:gsub("{" .. escapedKey .. "}", replacement)
    end

    return translation
end
