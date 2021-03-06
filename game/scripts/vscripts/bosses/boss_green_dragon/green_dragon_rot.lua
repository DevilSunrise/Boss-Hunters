green_dragon_rot = class({})
LinkLuaModifier( "modifier_green_dragon_rot_handle", "bosses/boss_green_dragon/green_dragon_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_rot", "bosses/boss_green_dragon/green_dragon_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_toxic_pool", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )

function green_dragon_rot:GetIntrinsicModifierName()
	return "modifier_green_dragon_rot_handle"
end

modifier_green_dragon_rot_handle = class({})
function modifier_green_dragon_rot_handle:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_green_dragon_rot_handle:OnIntervalThink()
	local caster = self:GetCaster()
	caster:SpendMana(33, self:GetAbility())
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,enemy in pairs(enemies) do
		if enemy:IsHero() and (not enemy:IsMagicImmune()) and (not enemy:IsInvulnerable()) and (not enemy:HasModifier("modifier_green_dragon_rot")) and (not caster:HasModifier("modifier_green_dragon_etheral_armor")) then
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_green_dragon_rot", {Duration = self:GetSpecialValueFor("duration")})
			break
		end
	end
	self:StartIntervalThink(self:GetSpecialValueFor("duration")+math.random(1,3))
end

function modifier_green_dragon_rot_handle:IsHidden()
	return true
end

function modifier_green_dragon_rot_handle:CheckState()
	local state = { [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end

modifier_green_dragon_rot = class({})
function modifier_green_dragon_rot:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_green_dragon_rot:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	EmitSoundOn("Hero_Venomancer.Plague_Ward", parent)
	local radius = self:GetSpecialValueFor("radius")
	local nfx = ParticleManager:CreateParticle("particles/bosses/boss_green_dragon/boss_green_dragon_rot_explosion.vpcf", PATTACH_POINT_FOLLOW, parent)
				ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
	self:StartIntervalThink(self:GetSpecialValueFor("tick_rate"))
end

function modifier_green_dragon_rot:OnRemoved()
    if IsServer() then
    	local caster = self:GetCaster()
    	local parent = self:GetParent()
    	local ability = caster:FindAbilityByName("green_dragon_toxic_pool")
    	CreateModifierThinker(caster, ability, "modifier_green_dragon_toxic_pool", {Duration = ability:GetSpecialValueFor("pool_duration")}, parent:GetAbsOrigin(), caster:GetTeam(), false)
    end
end

function modifier_green_dragon_rot:IsDebuff()
	return true
end

function modifier_green_dragon_rot:IsPurgable()
	return true
end

function modifier_green_dragon_rot:IsPurgeException()
	return true
end