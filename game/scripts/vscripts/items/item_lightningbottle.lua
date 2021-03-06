item_lightningbottle = class({})
LinkLuaModifier( "modifier_item_lightningbottle_handle", "items/item_lightningbottle.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_lightningbottle_handle_shield", "items/item_lightningbottle.lua", LUA_MODIFIER_MOTION_NONE )

function item_lightningbottle:GetIntrinsicModifierName()
	return "modifier_item_lightningbottle_handle"
end

function item_lightningbottle:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("DOTA_Item.Mjollnir.Activate", target)
	target:AddNewModifier(caster, self, "modifier_item_lightningbottle_handle_shield", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_item_lightningbottle_handle = class({})
function modifier_item_lightningbottle_handle:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("bonus_attack_speed")
	
	self.mRestore = self:GetSpecialValueFor("mana_restore")
	self.hRestore = self:GetSpecialValueFor("heal_restore")
	
	self.mRestoreL = self:GetSpecialValueFor("mana_restore_lightning")
	self.hRestoreL = self:GetSpecialValueFor("heal_restore_lightning")
	self.cdr = self:GetSpecialValueFor("cdr")
end

function modifier_item_lightningbottle_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_lightningbottle_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
		}
end

function modifier_item_lightningbottle_handle:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_lightningbottle_handle:GetCooldownReduction(params)
	return self.cdr
end

function modifier_item_lightningbottle_handle:OnAbilityFullyCast(params)
	local caster = params.unit
	if params.unit == self:GetParent() then
		self:GetParent():GiveMana(self.mRestore)
		self:GetParent():HealEvent(self.hRestore, self:GetAbility(), self:GetParent())

		local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do
			self:GetParent():GiveMana(self.mRestoreL)
			self:GetParent():HealEvent(self.hRestoreL, self:GetAbility(), self:GetParent())

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), enemy, {})
			self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("strike_damage"))
		end
	end
end

function modifier_item_lightningbottle_handle:IsHidden()
	return true
end

modifier_item_lightningbottle_handle_shield = class({})
function modifier_item_lightningbottle_handle_shield:OnCreated()
	self.mRestoreS = self:GetSpecialValueFor("mana_restore_shield")
	self.hRestoreS = self:GetSpecialValueFor("heal_restore_shield")
end

function modifier_item_lightningbottle_handle_shield:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_lightningbottle_handle_shield:OnTakeDamage(params)
	if IsServer() then
		local caster = params.unit
		local attacker = params.attacker
		if caster == self:GetParent() and attacker:IsAlive() and RollPercentage(self:GetSpecialValueFor("strike_chance")) then
			local ability = self:GetAbility()

			if caster:IsIllusion() then return end

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, attacker, caster, {})

			local damage = caster:GetPrimaryStatValue() * self:GetSpecialValueFor("primary_to_damage") / 100
			self:GetAbility():DealDamage(caster, attacker, damage)
			self:GetParent():GiveMana(self.mRestoreS)
			self:GetParent():HealEvent(self.hRestoreS, self:GetAbility(), self:GetParent())
		end
	end
end

function modifier_item_lightningbottle_handle_shield:GetEffectName()
	return "particles/items2_fx/mjollnir_shield.vpcf"
end

function modifier_item_lightningbottle_handle_shield:IsDebuff()
	return false
end

function modifier_item_lightningbottle_handle_shield:GetTexture()
	return "bottle_doubledamage"
end