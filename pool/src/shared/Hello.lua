local EventHandlersCenter = {}

local EventHandlers = {
    ["PlayerJumped"] = function(player, height)
        print(player.Name.." ��Ծ�߶�: "..height)
    end,
}

function EventHandlersCenter:HandleEvents(EventSync, eventType, player, ...)
    local handler = EventHandlers[eventType]
    if handler then
        handler(player, ...)
        -- �㲥���������
        EventSync.FireAllClients(eventType, player.UserId, ...) 
    else
        warn("δ֪�¼�����: "..tostring(eventType))
    end
end

return EventHandlersCenter