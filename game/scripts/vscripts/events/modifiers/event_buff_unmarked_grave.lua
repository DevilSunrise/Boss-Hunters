event_buff_unmarked_grave = class(relicBaseClass)

function event_buff_unmarked_grave:GetModifierHealAmplify_Percentage()
	return -80
end

function event_buff_unmarked_grave:IsDebuff( )
    return true
end