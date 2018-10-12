--[[
Broodking AI
]]

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
end


function AIThink(thisEntity)
	if thisEntity and not thisEntity:IsNull() then
		if not thisEntity:IsDominated() then
			return AICore:AttackHighestPriority( thisEntity )
		else return 1 end
	end
end