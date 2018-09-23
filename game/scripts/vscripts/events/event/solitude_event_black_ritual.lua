local function CheckPlayerChoices(self)
	local count = 0
	for pID, choice in pairs( self._playerChoices ) do
		if not choice then
			return false
		end
		count = count + 1
	end
	if count == 0 then return false end
	self:EndEvent(true)
	return true
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:AddRelic( "relic_unique_ritual_candle" )
	
	hero:SetGold( 0, true )
	hero:SetGold( 0, false )
	
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:AddRelic( "relic_cursed_forbidden_contract" )
	
	hero:SetGold( 0, true )
	hero:SetGold( 0, false )
	
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function ThirdChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:AddRelic( RelicManager:RollRandomGenericRelicForPlayer( event.pID ) )
	hero:AddRelic( RelicManager:RollRandomGenericRelicForPlayer( event.pID ) )
	hero:AddRelic( RelicManager:RollRandomGenericRelicForPlayer( event.pID ) )
	
	hero:SetGold( 0, true )
	hero:SetGold( 0, false )
	self._playerChoices[event.pID] = true
	
	CheckPlayerChoices(self)
end

local function FourthChoice(self, userid, event)
	self._playerChoices[event.pID] = true
	
	CheckPlayerChoices(self)
end

local function StartEvent(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 4})
	self._vEventHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_3', Context_Wrap( self, 'ThirdChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_4', Context_Wrap( self, 'FourthChoice') ),
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
	["ThirdChoice"] = ThirdChoice,
	["FourthChoice"] = FourthChoice,
}

return funcs