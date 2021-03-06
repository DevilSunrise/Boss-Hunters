modifier_boss_attackspeed = class({})

function modifier_boss_attackspeed:IsHidden()
	return true
end

function modifier_boss_attackspeed:OnCreated()
	if IsServer() then
		self:SetStackCount(math.floor(GameRules.gameDifficulty + 0.5) + RoundManager:GetAscensions())
		self.thinkTime = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_boss_attackspeed:OnIntervalThink()
	local parent = self:GetParent()
	if not parent:IsInvisible() then
		self.thinkTime = self.thinkTime + 0.1
		if self.thinkTime >= 5 then
			self.thinkTime = 0
			AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 516, 1, false)
		end
		GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), parent:GetHullRadius() + 5, true)
	end
end

function modifier_boss_attackspeed:CheckState()
	if IsServer() then
		return {[MODIFIER_STATE_CANNOT_MISS] = self:RollPRNG( math.min( 8 + self:GetStackCount() * 2 + RoundManager:GetZonesFinished() * 2.5, 65 ) ) }
	end
end

function modifier_boss_attackspeed:GetPriority()
	return MODIFIER_PRIORITY_LOW
end

function modifier_boss_attackspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ABILITY_START,
	}
	return funcs
end
--------------------------------------------------------------------------------
function modifier_boss_attackspeed:GetModifierAttackSpeedBonus_Constant( params )
	return 100 + self:GetStackCount() * 25
end

function modifier_boss_attackspeed:GetModifierMoveSpeedBonus_Constant( params )
	return (self:GetStackCount() - 1) * 5
end

--[[function modifier_boss_attackspeed:GetModifierConstantManaRegen( params )
	return self:GetStackCount()*2.5
end

function modifier_boss_attackspeed:GetModifierManaBonus( params )
	return self:GetStackCount()*250
end]]

function modifier_boss_attackspeed:GetModifierPreAttack_CriticalStrike( params )
	local maxTick = math.floor( 100 / ( 5 * self:GetStackCount() ) + 0.5 )
	self.ticks = (self.ticks or 0) + 1
	if self.ticks >= maxTick then	
		self.ticks = 0
		if self:GetParent():HasModifier("modifier_elite_assassin") then
			return 250
		else
			return 175
		end
	end
end

function modifier_boss_attackspeed:GetModifierPhysicalArmorBonus( params )
	local bonusarmor = self:GetStackCount()
	if self:GetParent():IsRangedAttacker() then bonusarmor = bonusarmor / 2 end
	return self:GetParent():GetPhysicalArmorBaseValue() * 0.08 * self:GetStackCount() + bonusarmor
end

function modifier_boss_attackspeed:GetModifierBaseDamageOutgoing_Percentage( params )
	return 10 + 2.5 * self:GetStackCount()
end

function modifier_boss_attackspeed:OnAbilityStart( params )
	if params.unit == self:GetParent() then
		AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 516, 3, false)
		params.unit:AddNewModifier(params.unit, params.ability, "modifier_status_immunity", {duration = params.ability:GetCastPoint() + 0.1})
	end
end

function modifier_boss_attackspeed:OnAbilityFullyCast( params )
	if params.unit == self:GetParent() then
		AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 516, 3, false)
	end
end

function modifier_boss_attackspeed:IsPurgable()
	return false
end