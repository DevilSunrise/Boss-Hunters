modifier_dazed_generic = class({})

function modifier_dazed_generic:OnCreated()
	--if IsServer() then
		self:StartIntervalThink(0.5)
	--end
end

function modifier_dazed_generic:OnIntervalThink()
	if IsServer() then
		if RollPercentage(25) then
			self:GetParent():SetInitialGoalEntity(nil)
			self:GetParent():Stop()
			self:GetParent():Interrupt()
			self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin()+ActualRandomVector(500, -500))
		end
	end
end

function modifier_dazed_generic:GetEffectName()
	return "particles/generic_dazed_side.vpcf"
end

function modifier_dazed_generic:IsPurgable()
	return true
end

function modifier_dazed_generic:IsDebuff()
	return true
end

function modifier_dazed_generic:OnRemoved()
	if IsServer() then
		self:GetParent():Stop()
	end
end