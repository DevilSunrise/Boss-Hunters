modifier_boss_evasion = class({})

function modifier_boss_evasion:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }

    return funcs
end

function modifier_boss_evasion:GetModifierEvasion_Constant()
  return math.min( 75, math.max( 10, self:GetStackCount() ) )
end

function modifier_boss_evasion:IsHidden()
    return true
end

function modifier_boss_evasion:IsPurgable()
	return false
end