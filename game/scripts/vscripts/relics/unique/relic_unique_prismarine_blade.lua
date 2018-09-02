relic_unique_prismarine_blade = class(relicBaseClass)

function relic_unique_prismarine_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_unique_prismarine_blade:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():InWater() then
		return 80
	end
end

function relic_unique_prismarine_blade:GetModifierPreAttack_BonusDamage()
	if self:GetParent():InWater() then
		return 80
	end
end