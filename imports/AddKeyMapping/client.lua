---@param data { command: string, description: string, defaultMapper: string, defaultKey: string, onPressed?: function, onReleased?: function }
local function AddKeyMapping(data)
    local pressCommand = ("+%s_mapper"):format(data.command)
    local releaseCommand = ("-%s_mapper"):format(data.command)

    local function onPressed()
        if IsPauseMenuActive() then return end
        if data.onPressed then data:onPressed() end
    end

    local function onReleased()
        if IsPauseMenuActive() then return end
        if data.onReleased then data:onReleased() end
    end

    RegisterCommand(data.command, onPressed)
    RegisterCommand(pressCommand, onPressed)
    RegisterCommand(releaseCommand, onReleased)
    RegisterKeyMapping(pressCommand, data.description, data.defaultMapper, data.defaultKey)

    SetTimeout(500, function()
        TriggerEvent("chat:removeSuggestion", "/" .. pressCommand)
        TriggerEvent("chat:removeSuggestion", "/" .. releaseCommand)
    end)
end

return AddKeyMapping
