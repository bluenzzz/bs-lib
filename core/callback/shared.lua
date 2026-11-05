--[[
    Based on ox_lib's callback system (https://github.com/overextended/ox_lib)
    Original license: LGPL-3.0 (https://www.gnu.org/licenses/lgpl-3.0.en.html)
    Copyright © 2025 Linden (https://github.com/thelindat)
    Changes: bug fixes and stability improvements
]]

local CALLBACK_EVENT <const> = "__bs_cb_%s"

local RegisteredCallbacks = {}

local function OnResourceStop(resourceName)
    if resourceName == RESOURCE_NAME then return end

    for callbackName, owner in pairs(RegisteredCallbacks) do
        if owner == resourceName then
            RegisteredCallbacks[callbackName] = nil
        end
    end
end
AddEventHandler("onResourceStop", OnResourceStop)

---@param callbackName string
---@param isValid boolean
function Lib.SetValidCallback(callbackName, isValid)
    local resourceName = GetInvokingResource() or RESOURCE_NAME
    local owner = RegisteredCallbacks[callbackName]

    if not owner then
        RegisteredCallbacks[callbackName] = resourceName
        return
    end

    if not isValid then
        RegisteredCallbacks[callbackName] = nil
        return
    end

    if owner == resourceName then return end

    local message = ("^1resource '%s' attempted to overwrite callback '%s' owned by resource '%s'^0"):format(resourceName, callbackName, owner)
    local stackTrace = Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ""
    print(("^1SCRIPT ERROR: %s^0\n%s"):format(message, stackTrace))
end

---@param callbackName string
function Lib.IsCallbackValid(callbackName)
    return RegisteredCallbacks[callbackName] == (GetInvokingResource() or RESOURCE_NAME)
end

local function ValidateCallback(callbackName, invokingResource, key)
    if RegisteredCallbacks[callbackName] then return end
    if not invokingResource or invokingResource == "" then return end

    local event = CALLBACK_EVENT:format(invokingResource)
    if IS_SERVER then return TriggerClientEvent(event, source, key, "cb_invalid") end

    TriggerServerEvent(event, key, "cb_invalid")
end
RegisterNetEvent("bs-lib:validateCallback", ValidateCallback)
