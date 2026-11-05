local CORE_SOURCE <const> = ("@%s/core"):format(RESOURCE_NAME)
local CONTEXT <const> = IS_SERVER and "server" or "client"

local function ExportCoreFunction(self, key, value)
    rawset(self, key, value)

    if type(value) ~= "function" then return end

    local source = debug.getinfo(2, "S").source
    if source:find(CORE_SOURCE, 1, true) then
        exports(key, value)
    end
end

local function LoadImport(self, key)
    local directory = ("imports/%s"):format(key)
    local shared = LoadResourceFile(RESOURCE_NAME, ("%s/shared.lua"):format(directory))
    local chunk = LoadResourceFile(RESOURCE_NAME, ("%s/%s.lua"):format(directory, CONTEXT))

    if shared then
        chunk = chunk and (shared .. "\n" .. chunk) or shared
    end

    if not chunk then return end

    local fn, err = load(chunk, ("@%s/%s/%s.lua"):format(RESOURCE_NAME, directory, CONTEXT))
    if not fn then
        error(("\n^1Error importing module (%s): %s^0"):format(directory, err), 3)
    end

    local module = fn()
    rawset(self, key, module)
    return module
end

Lib = setmetatable({
    name = RESOURCE_NAME,
    context = CONTEXT,
}, {
    __newindex = ExportCoreFunction,
    __index = LoadImport,
})

function Lib.Ready()
    return true
end
