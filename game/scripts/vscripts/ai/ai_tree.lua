--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.armor = thisEntity:FindAbilityByName("boss_living_armor")
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_tree")
	
	AITimers:CreateTimer(0.1, function() 
		thisEntity.armor:SetLevel( math.min(thisEntity.armor:GetMaxLevel(), math.floor(GameRules:GetGameDifficulty()/4) + RoundManager:GetRaidsFinished() ) )
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if thisEntity.armor:IsFullyCastable() and not thisEntity:HasModifier("modifier_treant_living_armor") then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity:entindex(),
				AbilityIndex = thisEntity.armor:entindex()
			})
			return thisEntity.armor:GetCastPoint()
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end