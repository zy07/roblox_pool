local EffectManager = {}

function EffectManager:AddReplicatedStorageEffect(effectName, privot, part, parent)
    local effectTemplate = game:GetService("ReplicatedStorage"):WaitForChild(effectName)
    local effectClone = effectTemplate:Clone()
    effectClone:PivotTo(privot)

	-- ʹ�ú���Լ���̶�λ��
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = part
	weld.Part1 = effectClone
	weld.Parent = effectClone

	effectClone.Parent = parent
    return effectClone
end

return EffectManager