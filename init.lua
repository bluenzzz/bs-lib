--[[
    Based on ox_lib by Overextended (https://github.com/overextended/ox_lib)
    Credits to the ox_lib contributors for the module loading pattern and structure.
]]

if not _VERSION:find("5.4") then
    error("Lua 5.4 must be enabled in the resource manifest!", 2)
end

local BS_LIB <const> = "bs-lib"
local ResourceName = GetCurrentResourceName()

if ResourceName == BS_LIB then return end

if Lib?.name == BS_LIB then
    error(("Cannot load bs-lib more than once.\n\tRemove any duplicate entries from '@%s/fxmanifest.lua'"):format(ResourceName))
end

if GetResourceState(BS_LIB) ~= "started" then
    error("^1bs-lib must be started before this resource.^0", 0)
end

local Export = exports[BS_LIB]

local status = Export.Ready()
if status ~= true then error(status, 2) end

msgpack.setoption("ignore_invalid", true)

local CONTEXT <const> = IsDuplicityVersion() and "server" or "client"

local function Noop() end

local function LoadModule(self, moduleName)
    local directory = ("imports/%s"):format(moduleName)
    local shared = LoadResourceFile(BS_LIB, ("%s/shared.lua"):format(directory))
    local chunk = LoadResourceFile(BS_LIB, ("%s/%s.lua"):format(directory, CONTEXT))

    if shared then
        chunk = chunk and (shared .. "\n" .. chunk) or shared
    end

    if not chunk then return end

    local fn, err = load(chunk, ("@bs-lib/%s/%s.lua"):format(directory, CONTEXT))
    if not fn then
        error(("\n^1Error importing module (%s): %s^0"):format(directory, err), 3)
    end

    local result = fn()
    self[moduleName] = result or Noop
    return self[moduleName]
end

local function GetModule(self, index, ...)
    local module = rawget(self, index)
    if module then return module end

    self[index] = Noop
    module = LoadModule(self, index)
    if module then return module end

    local method = function(...)
        return Export[index](nil, ...)
    end

    if not ... then
        self[index] = method
    end

    return method
end

Lib = setmetatable({
    name = BS_LIB,
    context = CONTEXT,
}, {
    __index = GetModule,
    __call = GetModule,
})

if CONTEXT == "client" then
    for key, value in pairs(Export.Cache()) do
        rawset(Lib, key, value)
    end

    local function OnCacheUpdate(key, value)
        rawset(Lib, key, value)
    end
    AddEventHandler("bs-lib:client:cache", OnCacheUpdate)
end

for i = 1, GetNumResourceMetadata(ResourceName, "bs_lib") do
    local moduleName = GetResourceMetadata(ResourceName, "bs_lib", i - 1)
    if not rawget(Lib, moduleName) then
        LoadModule(Lib, moduleName)
    end
end
