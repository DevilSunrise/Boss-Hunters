if IsServer() then
	require( "ai/ai_core" )
	
	AI_STATE_CLOSE_COMBAT = 1
	AI_STATE_CHASING = 2
	
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.leap = thisEntity:FindAbilityByName("boss1b_leap")
		thisEntity.pin = thisEntity:FindAbilityByName("boss1b_spear_pin")
		thisEntity.pierce = thisEntity:FindAbilityByName("boss1b_spear_pierce")
		
		AITimers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
				thisEntity.leap:SetLevel(1)
				thisEntity.pin:SetLevel(1)
				thisEntity.pierce:SetLevel(1)
			else
				thisEntity.leap:SetLevel(2)
				thisEntity.pin:SetLevel(2)
				thisEntity.pierce:SetLevel(2)
			end
		end)
	end


	function AIThink(thisEntity)
		if thisEntity and not thisEntity:IsNull() then
			if not thisEntity:IsDominated() and not thisEntity:IsCommandRestricted() then
				EvaluateBehavior(thisEntity)
				if thisEntity.AIstate == AI_STATE_CLOSE_COMBAT then
					local target = AICore:GetHighestPriorityTarget(thisEntity)
					if thisEntity.pin:IsFullyCastable() and not target:IsStunned() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetAbsOrigin(),
							AbilityIndex = thisEntity.pin:entindex()
						})
						return AI_THINK_RATE
					end
					
					-- BEHAVIOR SPECIFIC
					if thisEntity.leap:IsFullyCastable() then
						local attackedByOthers = (AICore:BeingAttacked( thisEntity ) > 1 and target:IsAttackingEntity(thisEntity) )
						if thisEntity:GetAIBehavior() == AI_BEHAVIOR_AGGRESSIVE then -- uses all abilities without concern of options
							local targetPos = AICore:OptimalHitPosition(thisEntity, thisEntity.leap:GetTrueCastRange(), thisEntity.leap:GetSpecialValueFor("leap_radius"), false)
							if targetPos then
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = target:GetAbsOrigin(),
									AbilityIndex = thisEntity.leap:entindex()
								})
								return AI_THINK_RATE
							end
						elseif attackedByOthers then -- only uses leap if not being focused
							local targetPos
							for _, attacker in ipairs( AICore:BeingAttackedBy( thisEntity ) ) do
								targetPos = ((targetPos or attacker:GetAbsOrigin()) + attacker:GetAbsOrigin()) / 2
							end
							local runDir = CalculateDirection(thisEntity, targetPos)
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								Position =  thisEntity:GetAbsOrigin() + runDir * thisEntity.leap:GetTrueCastRange(),
								AbilityIndex = thisEntity.leap:entindex()
							})
							return AI_THINK_RATE
						elseif thisEntity.AIbehavior == AI_BEHAVIOR_CAUTIOUS then -- holds leap to jump out if focused
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								Position = target:GetAbsOrigin(),
								AbilityIndex = thisEntity.leap:entindex()
							})
							return AI_THINK_RATE					
						end
					end
					if thisEntity.pierce:IsFullyCastable() and (AICore:NumEnemiesInLine(thisEntity, thisEntity.pierce:GetSpecialValueFor("spear_distance"), thisEntity.pierce:GetSpecialValueFor("spear_width"), true) <= math.min(PlayerResource:FindActivePlayerCount(), 2) or thisEntity:GetAIBehavior() == AI_BEHAVIOR_AGGRESSIVE) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetAbsOrigin(),
							AbilityIndex = thisEntity.pierce:entindex()
						})
						return AI_THINK_RATE
					end
				elseif thisEntity.AIstate == AI_STATE_CHASING then
					local target = AICore:GetHighestPriorityTarget(thisEntity)
					if target then
						local pathLength = GridNav:FindPathLength(thisEntity:GetAbsOrigin(), target:GetAbsOrigin()) 
						if pathLength - 5 > CalculateDistance(thisEntity, target) and thisEntity.leap:IsFullyCastable() then -- if need to path around something
							local distToReach = math.min(thisEntity.leap:GetTrueCastRange(), CalculateDistance(target, thisEntity))
							local targetPos = thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * distToReach
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								Position = targetPos,
								AbilityIndex = thisEntity.leap:entindex()
							})
							return AI_THINK_RATE
						end
					end
				end
				return AICore:AttackHighestPriority( thisEntity )
			else return AI_THINK_RATE end
		end
	end
	
	function EvaluateBehavior(entity)
		if AICore:IsNearEnemyUnit(entity, entity:GetAttackRange() + entity:GetIdealSpeed() * 0.8 ) then
			entity.AIstate = AI_STATE_CLOSE_COMBAT
		else
			entity.AIstate = AI_STATE_CHASING
		end
	end
end