boss_aether_meteor_shower = class({})
function boss_aether_meteor_shower:OnAbilityPhaseStart()
	EmitSoundOn( "Hero_AbyssalUnderlord.Firestorm.Start", self:GetCaster() )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	return true
end

function boss_aether_meteor_shower:OnAbilityPhaseInterrupted()
	StopSoundOn( "Hero_AbyssalUnderlord.Firestorm.Start", self:GetCaster() )
end

function boss_aether_meteor_shower:OnSpellStart()
	local caster = self:GetCaster()
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), -1)
	
	EmitSoundOn( "Hero_AbyssalUnderlord.Firestorm.Cast", caster )
	for i = 0, self:GetTalentSpecialValueFor("meteor_count") do
		local randomInt = RandomInt(1, math.min(#enemies * 2.5) )
		local position = caster:GetAbsOrigin() + ActualRandomVector(1800, 500)
		if enemies[randomInt] then
			local enemy = enemies[randomInt]
			position = enemy:GetAbsOrigin() + ActualRandomVector(self:GetSpecialValueFor("impact_radius") * 2.5)
		end
		Timers:CreateTimer( RandomFloat(0.75, 3.5), function() self:CreateMeteor(position) end )
	end
end

function boss_aether_meteor_shower:CreateMeteor(endPos)
	local caster = self:GetCaster()
	local radius = self:GetTalentSpecialValueFor("impact_radius")
	local delay = self:GetTalentSpecialValueFor("impact_delay")
	local damage = self:GetTalentSpecialValueFor("impact_damage")
	local sDuration = self:GetTalentSpecialValueFor("slow_duration")
	
	ParticleManager:FireWarningParticle(endPos, radius)
	Timers:CreateTimer(delay, function()
		EmitSoundOn( "Hero_AbyssalUnderlord.Firestorm", caster )
		local meteorFX = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(meteorFX, 0, endPos)
		ParticleManager:SetParticleControl(meteorFX, 4, Vector(radius, 0, 0))
		local enemies = caster:FindEnemyUnitsInRadius(endPos, radius)
		for _, enemy in ipairs( enemies ) do
			if not enemy:TriggerSpellAbsorb(self) then
				self:DealDamage( caster, enemy, damage )
				enemy:AddNewModifier( caster, self, "modifier_boss_aether_meteor_shower_debuff", {duration = sDuration})
			end
		end
	end)
end

modifier_boss_aether_meteor_shower_debuff = class({})
LinkLuaModifier("modifier_boss_aether_meteor_shower_debuff", "bosses/boss_aether/boss_aether_meteor_shower", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_meteor_shower_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_aether_meteor_shower_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("impact_slow")
end

function modifier_boss_aether_meteor_shower_debuff:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_slow_debuff.vpcf"
end

