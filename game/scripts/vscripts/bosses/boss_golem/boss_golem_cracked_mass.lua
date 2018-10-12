boss_golem_cracked_mass = class({})

function boss_golem_cracked_mass:GetIntrinsicModifierName()
	return "modifier_boss_golem_cracked_mass"
end

modifier_boss_golem_cracked_mass = class({})
LinkLuaModifier( "modifier_boss_golem_cracked_mass", "bosses/boss_golem/boss_golem_cracked_mass", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_golem_cracked_mass:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_golem_cracked_mass:OnTakeDamage(params)
	if params.unit == self:GetParent() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) and self:GetAbility():IsActivated() and not self:GetParent():PassivesDisabled() then 
		local chance = math.min( self:GetSpecialValueFor("shard_chance") * self:GetParent():GetModelScale(), math.max(1, (params.original_damage / params.unit:GetMaxHealth()) * 100 ) )
		if RollPercentage( chance ) then
			local hp = math.min( self:GetParent():GetMaxHealth() * 0.5, math.max( params.original_damage * self:GetSpecialValueFor("shard_damage_mult"), self:GetSpecialValueFor("shard_min_hp")) )
			local scale = self:GetParent():GetModelScale()
			
			shardling = CreateUnitByName("npc_dota_boss12_shardling", self:GetParent():GetAbsOrigin() + RandomVector(250), false, nil, nil, self:GetParent():GetTeam())
			shardling:SetModelScale( math.max(shardling:GetModelScale() * scale, 0.4 ) )
			shardling:SetAverageBaseDamage( shardling:GetAverageBaseDamage() * math.min(scale * 2, 1), 25 )
			shardling:SetCoreHealth( math.max(1, hp) )
			shardling.hasBeenInitialized = true
			shardling:SetBaseMoveSpeed( math.min( 350, self:GetParent():GetBaseMoveSpeed() / scale ) )
		end
	end
end