warlock_summon_imp = class({})
LinkLuaModifier("modifier_warlock_summon_imp", "heroes/hero_warlock/warlock_summon_imp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warlock_summon_imp_aghs", "heroes/hero_warlock/warlock_summon_imp", LUA_MODIFIER_MOTION_NONE)

function warlock_summon_imp:IsStealable()
	return true
end

function warlock_summon_imp:IsHiddenWhenStolen()
	return false
end

function warlock_summon_imp:GetIntrinsicModifierName()
	return "modifier_warlock_summon_imp_aghs"
end

function warlock_summon_imp:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Furion.TreantSpawn", caster)
	local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		if unit:GetTeam() == caster:GetTeam() and unit:GetUnitName() == "npc_dota_warlock_imp" then
			unit:ForceKill(false)
		end
	end

	local imp = CreateUnitByName("npc_dota_warlock_imp", caster:GetAbsOrigin(), true, caster, caster, self:GetTeam())
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_POINT_FOLLOW, imp, {})
	imp:AddNewModifier(caster, self, "modifier_warlock_summon_imp", {})
end

modifier_warlock_summon_imp = class({})
function modifier_warlock_summon_imp:CheckState()
	local state = { [MODIFIER_STATE_NO_TEAM_SELECT] = true}
	return state
end

function modifier_warlock_summon_imp:IsHidden()
	return true
end

modifier_warlock_summon_imp_aghs = class({})
function modifier_warlock_summon_imp_aghs:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_warlock_summon_imp_aghs:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		if caster:HasScepter() then
			local ability = caster:FindAbilityByName("warlock_demonic_summons")
			if ability:IsTrained() then
				local position = params.unit:GetAbsOrigin()
				if params.unit == caster then
					ability:CreateGolem(position)
				elseif params.unit:GetUnitName() == "npc_dota_warlock_imp" then
					local golem = ability:CreateGolem(position)
					golem:SetCoreHealth( golem:GetBaseMaxHealth() * 0.33 )
					golem:SetModelScale( golem:GetModelScale() * 0.66 )
				end
			end
		end
	end
end

function modifier_warlock_summon_imp_aghs:IsHidden()
	return true
end