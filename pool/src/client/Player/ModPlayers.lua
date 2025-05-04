local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local playerCtrlTemplate = require(game.StarterPlayer.StarterPlayerScripts.Player.PlayerController)
local ModPlayers = {}
local Players = game:GetService("Players")
local players = Players:GetPlayers()
local playerCtrls = {}

-- ���н�ɫ�����ʱ�򴴽�PlayerController
local function HandlePlayerAdded(player)
    local playerCtrl = playerCtrlTemplate:new(player)
    if not playerCtrls[player] then
        playerCtrls[player] = playerCtrl
    end
end

for _, existPlayer in players do
    HandlePlayerAdded(existPlayer)
end

Players.PlayerAdded:Connect(HandlePlayerAdded)

function ModPlayers:Update()
    for _, playerCtrl in playerCtrls do
        playerCtrl:Update()
    end
end

handleSAttack = function(player)
    if not player then
        return
    end

    if playerCtrls[player] then
        playerCtrls[player]:HandlgeSAttack()
    end
end
EventCenter:AddSEventListener(EventCenter.EventType.SAttack, handleSAttack)

return ModPlayers