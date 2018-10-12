boss_flesh_behemoth_meat_pile = class({})

function boss_flesh_behemoth_meat_pile:GetIntrinsicModifierName()
	return "modifier_boss_flesh_behemoth_meat_pile"
end

modifier_boss_flesh_behemoth_meat_pile = class({})
LinkLuaModifier("modifier_boss_flesh_behemoth_meat_pile", "bosses/boss_flesh_behemoth/boss_flesh_behemoth_meat_pile", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_flesh_behemoth_meat_pile:OnCreated()
	self.hp = self:GetSpecialValueFor("zombie_health")
	self.chance = self:GetSpecialValueFor("zombie_chance")
end

function modifier_boss_flesh_behemoth_meat_pile:OnRefresh()
	self.hp = self:GetSpecialValueFor("zombie_health")
	self.chance = self:GetSpecialValueFor("zombie_chance")
end

function modifier_boss_flesh_behemoth_meat_pile:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_flesh_behemoth_meat_pile:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.unit:PassivesDisabled() and self:RollPRNG( self.chance ) then
		local zombie = CreateUnitByName("npc_dota_boss3a_b", params.unit:GetAbsOrigin() + RandomVector(150), true, nil, nil, params.unit:GetTeamNumber() )
		zombie:SetCoreHealth( self.hp )
		self:GetAbility():SetCooldown()
	end
end

function modifier_boss_flesh_behemoth_meat_pile:IsHidden()
	return true
end