boss_aeon_deteriorate = class({})

function boss_aeon_deteriorate:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetSpecialValueFor("radius"))
	return true
end

function boss_aeon_deteriorate:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			enemy:AddNewModifier(caster, self, "modifier_boss_aeon_deteriorate", {duration = self:GetSpecialValueFor("duration")})
		end
	end
	
	caster:EmitSound("Hero_Dazzle.Weave")
	ParticleManager:FireParticle("particles/units/heroes/hero_dazzle/dazzle_weave.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
end

modifier_boss_aeon_deteriorate = class({})
LinkLuaModifier("modifier_boss_aeon_deteriorate", "bosses/boss_aeon/boss_aeon_deteriorate", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_deteriorate:OnCreated()
	self.armor = 0
	self.loss = self:GetSpecialValueFor("total_armor_reduction") / self:GetRemainingTime()
	self:StartIntervalThink(1)
end

function modifier_boss_aeon_deteriorate:OnIntervalThink()
	self.armor = self.armor - self.loss
end

function modifier_boss_aeon_deteriorate:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss_aeon_deteriorate:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_boss_aeon_deteriorate:IsPurgable()
	return false
end