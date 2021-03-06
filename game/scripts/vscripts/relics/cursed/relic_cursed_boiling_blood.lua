relic_cursed_boiling_blood = class(relicBaseClass)

function relic_cursed_boiling_blood:OnCreated()
	if IsServer() then self:StartIntervalThink(1) end
end

function relic_cursed_boiling_blood:OnIntervalThink()
	local parent = self:GetParent()
	local enemies = parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 600 )
	for _, enemy in ipairs( enemies ) do
		ApplyDamage({victim = enemy, attacker = parent, damage = parent:GetMaxHealth() * 0.02, damage_type = DAMAGE_TYPE_MAGICAL})
	end
	if #enemies > 0 and not self:GetParent():HasModifier("relic_unique_ritual_candle") then ApplyDamage({victim = parent, attacker = parent, damage = parent:GetHealth() * 0.02, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL }) end
end