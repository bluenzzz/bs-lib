rawset(Lib, "UiReady", promise.new())

local function OnUiReady(_, cb)
    Lib.UiReady:resolve(true)
    cb("ok")
end
RegisterNUICallback("uiReady", OnUiReady)
