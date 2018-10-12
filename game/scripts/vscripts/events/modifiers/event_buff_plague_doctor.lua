event_buff_plague_doctor_curse = class(relicBaseClass)

function event_buff_plague_doctor_curse:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function event_buff_plague_doctor_curse:GetModifierPhysicalArmorBonus()
	return -10
end

function event_buff_plague_doctor_curse:GetModifierMagicalResistanceBonus()
	return -25
end

function event_buff_plague_doctor_curse:IsDebuff( )
    return true
end

event_buff_plague_doctor_blessing = class(relicBaseClass)

function event_buff_plague_doctor_blessing:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function event_buff_plague_doctor_blessing:GetModifierPreAttack_BonusDamage()
	return 80
end

function event_buff_plague_doctor_blessing:GetModifierSpellAmplify_Percentage()
	return 32
end

function event_buff_plague_doctor_blessing:GetModifierMoveSpeedBonus_Constant()
	return 20
end