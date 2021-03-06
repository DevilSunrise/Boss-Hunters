local function CheckPlayerChoices(self)
	for pID, choice in pairs( self._playerChoices ) do
		if not choice then
			return false
		end
	end
	self:EndEvent(true)
	return true
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = true
	
	if hero then
		StatsScreen:RegisterPlayer( hero, hero.hasRespecced ) -- Reset stats screen
		local modifiers = hero:FindAllModifiers()
		for i = 0, 23 do
			local ability = hero:GetAbilityByIndex(i)
			if ability and not ability:IsInnateAbility() then 
				ability:SetLevel(0)
			end
		end
		for _, modifier in ipairs( modifiers ) do
			if modifier:GetAbility() then
				if not modifier:GetAbility():IsInnateAbility() and modifier:GetCaster() == hero and not modifier:GetAbility():IsItem() and modifier:GetAbility():GetName() ~= "item_relic_handler" then -- destroy passive modifiers and any buffs
					modifier:Destroy()
				end
			end
		end
		hero.bonusAbilityPoints = hero.bonusAbilityPoints or 0
		hero:SetAbilityPoints( hero:GetLevel() + math.floor(hero:GetLevel() / GameRules.gameDifficulty) + hero.bonusAbilityPoints) -- give back ability points
		CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	end
	
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function StartEvent(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "grove_event_well_of_youth", choices = 2})
	self._vEventHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self.timeRemaining = 30
	self.eventEnded = false
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if self.timeRemaining >= 0 then
			self.timeRemaining = self.timeRemaining - 1
			return 1
		elseif not self.eventEnded then
			self:EndEvent(true)
		end
	end)
	
	self._playerChoices = {}
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			self._playerChoices[i] = false
		end
	end
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
}

return funcs