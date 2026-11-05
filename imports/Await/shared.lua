local DEFAULT_TIMEOUT <const> = 10000

---@param cb function
---@param timeout? number
---@param message? string
local function Await(cb, timeout, message)
    local expiresAt = GetGameTimer() + (timeout or DEFAULT_TIMEOUT)
    local result = cb()

    while result == nil do
        if GetGameTimer() >= expiresAt then
            if message then print(message) end
            return false
        end

        Wait(100)
        result = cb()
    end

    return result
end

return Await
