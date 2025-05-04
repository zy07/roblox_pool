local ClientEventCenter = {}

ClientEventCenter.EventType = {
    CAttack = 1,

    SeverEvent = 10000,
    SAttack = 10001,
}

local event = game.ReplicatedStorage:WaitForChild("GameEventSync")

local sEventHandlers = {
}

local cEventHandlers = {
}

local player = game:GetService("Players")
local localPlayer = player.LocalPlayer

event.onClientEvent:Connect(function(eventType, ...)
    local handler = sEventHandlers[eventType]
    if handler then
        handler(...)
    else
        warn("δ֪�¼�����: "..tostring(eventType))
    end
end)

function ClientEventCenter:SendSEvent(eventType, ...)
    event:FireServer(eventType, ...)
end

function ClientEventCenter:AddSEventListener(eventType, callback)
    if not sEventHandlers[eventType] then
        sEventHandlers[eventType] = callback
    else
        warn("�¼������Ѵ���: "..tostring(eventType))
    end
end

function ClientEventCenter:AddCEventListener(eventType, callback)
    if not cEventHandlers[eventType] then
        cEventHandlers[eventType] = {}
        cEventHandlers[eventType][1] = callback
    else
        for _, item in cEventHandlers[eventType] do
            if item == callback then
                warn("�¼�����: "..tostring(eventType).."�ص��ظ�ע��")
            end
        end
    end
end

function ClientEventCenter:RemoveCEventListener(eventType, callback)
    if not cEventHandlers[eventType] then
        warn("�¼�����: "..tostring(eventType).."�ص��ظ���ע��")
    else
        for i = #cEventHandlers[eventType], 1, -1 do
            if cEventHandlers[eventType][i] == callback then
                table.remove(cEventHandlers[eventType], i)
            end
        end
    end
end

function ClientEventCenter:SendEvent(eventType, ...)
    if cEventHandlers[eventType] then
        for _, callback in ipairs(cEventHandlers[eventType]) do
            callback(...)
        end
    else
        warn("�¼�����: "..tostring(eventType).."������")
    end
end

return ClientEventCenter