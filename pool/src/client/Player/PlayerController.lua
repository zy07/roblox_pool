local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local EffectManager = require(game.StarterPlayer.StarterPlayerScripts.Effect.EffectManager)
local Search = require(game.StarterPlayer.StarterPlayerScripts.Battle.Search.Search)
local machineTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerStateMachine)
local idleStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerIdleState)
local skillStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerSkillState)

local PlayerController = {}

-- Services
local Players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

-- LocalPlayer
local Player = Players.LocalPlayer
local Character = nil
local characterParts = nil
local humanoid = nil
local humanoidRootPart = nil
local animator = nil
local animationIds = {
	"70625062208041",
}
local animationTracks = {}
local rushEff = nil
local rushEffParticle = nil

-- StateMachine
local playerStateMachine = machineTemplate:new()
local idleState = idleStateTemplate:new(playerStateMachine)
local skillState = skillStateTemplate:new(playerStateMachine)
playerStateMachine:AddState("Idle", idleState)
playerStateMachine:AddState("Skill", skillState)

function PlayerController:new(player)
	local obj = {}
	self.__index = self
	setmetatable(obj, self)
	obj.Player = player
	obj.Character = player.Character or player.CharacterAdded:Wait()
	obj:Init()
	return obj
end

function PlayerController:Init()
	Character = Player.Character or Player.CharacterAdded:Wait()
	characterParts = Character:GetDescendants()
	-- Ensure that the character's humanoid contains an "Animator" object
	humanoid = Character:WaitForChild("Humanoid")
	humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	animator = humanoid:WaitForChild("Animator")
	-- Load the animation onto the animator
	for _, animId in animationIds do
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://"..animId
		local track = animator:LoadAnimation(animation)
		if animationTracks[animId] == nil then
			animationTracks[animId] = track
		end
	end
    rushEff = EffectManager:AddReplicatedStorageEffect("通用-冲刺特效", humanoidRootPart.CFrame, humanoidRootPart, Character)
    rushEffParticle = rushEff:FindFirstChildWhichIsA("ParticleEmitter")
	hideRushEffect()
	playerStateMachine:Run("Idle")
end

-- local function onCharacterAdded(playerCharacter)
-- 	Character = playerCharacter
-- 	characterParts = Character:GetDescendants()
-- 	-- Ensure that the character's humanoid contains an "Animator" object
-- 	humanoid = Character:WaitForChild("Humanoid")
-- 	humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
-- 	animator = humanoid:WaitForChild("Animator")
-- 	-- Load the animation onto the animator
-- 	for _, animId in animationIds do
-- 		local animation = Instance.new("Animation")
-- 		animation.AnimationId = "rbxassetid://"..animId
-- 		local track = animator:LoadAnimation(animation)
-- 		if animationTracks[animId] == nil then
-- 			animationTracks[animId] = track
-- 		end
-- 	end
--     rushEff = EffectManager:AddReplicatedStorageEffect("ͨ��-������?", humanoidRootPart.CFrame, humanoidRootPart, Character)
--     rushEffParticle = rushEff:FindFirstChildWhichIsA("ParticleEmitter")
-- 	hideRushEffect()
-- 	playerStateMachine:Run("Idle")
-- end

function showRushEffect()
	rushEffParticle.Enabled = true
end

function hideRushEffect()
	rushEffParticle.Enabled = false
end

-- Player.CharacterAdded:Connect(onCharacterAdded)

function setPlayerTransparency(transparency)
	for _, pair in characterParts do
		if pair:IsA("BasePart") and pair.Name ~= "HumanoidRootPart" then
			pair.Transparency = transparency
			pair.CastShadow = false
		elseif pair:IsA("Decal") or pair:IsA("Texture") then
			pair.Transparency = transparency
		end
	end

	for _, accessory in ipairs(Character:GetChildren()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			if handle then
				handle.Transparency = transparency
			end
		end
	end
end

function PlayerController:PlayAnim(animId)
	playAnim(animId)
end

function playAnim(animId)
	if animationTracks[animId] ~= nil then
		animationTracks[animId]:Play()
		return animationTracks[animId]
	else
		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		local track = animator:LoadAnimation(anim)
		animationTracks[animId] = track
		track:Play()
		return track
	end
end

handleAttack = function()
    local ball, dir = Search:SearchNearlyByTag(humanoidRootPart.CFrame.p, "Ball")
	if ball ~= nil then
		local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		setPlayerTransparency(1)
		local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(ball.Position - dir * 5)})
		CFrame.lookAt(humanoidRootPart.Position, ball.Position)
		tween:Play()
		showRushEffect()
		task.wait(0.1)
		setPlayerTransparency(0)
		hideRushEffect()
	end

	EventCenter:SendSEvent(EventCenter.EventType.SAttack)

	-- Play the animation track
	local anim = playAnim("70625062208041")
	anim:Play()
	anim.Ended:Connect(function()
		print("Animation ended")
	end)
	anim:GetMarkerReachedSignal("Punch"):Connect(function(paramString)
		print("Punch")
	end)
end

-- handleSAttack = function()
-- 	setPlayerTransparency(1)
-- 	showRushEffect()
-- 	task.wait(0.1)
-- 	setPlayerTransparency(0)
-- 	hideRushEffect()
-- 	-- local anim = playAnim("70625062208041")
-- 	-- anim:Play()
-- end

EventCenter:AddCEventListener(EventCenter.EventType.CAttack, handleAttack)
-- EventCenter:AddSEventListener(EventCenter.EventType.SAttack, handleSAttack)

function PlayerController:HandleSAttack()
	setPlayerTransparency(1)
	showRushEffect()
	task.wait(0.1)
	setPlayerTransparency(0)
	hideRushEffect()
end



function PlayerController:Update()
	playerStateMachine:Update()
end

return PlayerController