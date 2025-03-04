--[[
    RoundService.lua
    1/21/25

    Description: 
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local NUM_PLAYERS_TO_START_RACE = 1

local RoundService = Knit.CreateService({
	Name = script.Name,
	Client = {
		PlayerJoined = Knit.CreateSignal(),
		RaceStarted = Knit.CreateSignal(),
		CollectRaceResults = Knit.CreateSignal(),
		LiveResultAdded = Knit.CreateSignal(),
		RaceEnded = Knit.CreateSignal(),
		Countdown = Knit.CreateSignal(),
		PlayerCountChanged = Knit.CreateSignal(),
		RaceStatusChanged = Knit.CreateSignal(),
	},
})

function RoundService:KnitStart()
	self.ActivePlayers = {}
	self.RaceResults = {}
	self.RaceActive = false
	self.CountdownActive = false
	self.RaceStartTime = 0
	self.RaceEndTime = 0
	self.WaitingPlayers = {}

	Players.PlayerRemoving:Connect(function(player)
		self:RemovePlayerFromGame(player)
	end)
end

function RoundService:RemovePlayerFromGame(player: Player)
	self:RemoveWaitingPlayer(player)
	self:RemoveActivePlayer(player)
end

function RoundService:AddWaitingPlayer(player: Player)
	--if self.RaceActive == false and self.CountdownActive == true then
	--return
	--end
	if player and not table.find(self.WaitingPlayers, player) then
		table.insert(self.WaitingPlayers, player)
		self.Client.PlayerCountChanged:FireAll(#self.WaitingPlayers)
		if #self.WaitingPlayers >= NUM_PLAYERS_TO_START_RACE and not self.RaceActive and not self.CountdownActive then
			self:StartRace()
		end
	end
end

function RoundService:RemoveActivePlayer(player: Player)
	if player then
		table.remove(self.ActivePlayers, table.find(self.ActivePlayers, player))
		if #self.ActivePlayers == 0 then
			self:EndRace()
		end
	end
end

function RoundService:RemoveWaitingPlayer(player: Player)
	if player then
		table.remove(self.WaitingPlayers, table.find(self.WaitingPlayers, player))
		self.Client.PlayerCountChanged:FireAll(#self.WaitingPlayers)
	end
end

function RoundService:GetRandomPlayer(): Player
	local activePlayers = Players:GetPlayers()
	return activePlayers[math.random(1, #activePlayers)]
end

function RoundService:StartCountdown(startingRace: boolean)
	self.CountdownActive = true
	local countdown = 5
	while countdown >= 0 do
		self.Client.Countdown:FireAll(startingRace, countdown)
		task.wait(1)
		countdown -= 1
		if startingRace and #self.WaitingPlayers < NUM_PLAYERS_TO_START_RACE then
			break
		end
	end
end

function RoundService:EndRace()
	if self.RaceActive == false and self.CountdownActive == true then
		return
	end
	self:StartCountdown(false)
	self.RaceEndTime = tick()
	self.RaceTime = self.RaceEndTime - self.RaceStartTime
	self:CollectPlayerResults()
	self:VerfiyResults()
	self:DeterminePlaces()
	for _, player in self.ActivePlayers do
		self.Client.RaceEnded:Fire(player, self.RaceResults)
	end
	self:SaveResultsToLeaderboards()
	table.clear(self.ActivePlayers)
	self.RaceActive = false
	self.Client.RaceStatusChanged:FireAll(self.RaceActive)
	self.CountdownActive = false

	if #self.WaitingPlayers >= 1 and not self.RaceActive and not self.CountdownActive then
		self:StartRace()
	end
end

function RoundService:SaveResultsToLeaderboards()
	for _, player in self.ActivePlayers do
		self.LeaderboardService:SaveResults(player, self:GetPlayerResults(player))
	end
end

function RoundService:VerfiyResults()
	while #self.RaceResults < #self.ActivePlayers do
		task.wait(1)
	end
end

function RoundService:GetPlayerResults(player: Player)
	for _, result in self.RaceResults do
		if result.PlayerName == player.Name then
			return result
		end
	end
	return nil
end

function RoundService:CollectPlayerResults()
	for _, player in self.ActivePlayers do
		for _, result in self.RaceResults do
			if result.PlayerName == player.Name then
				continue
			end
			self.Client.CollectRaceResults:Fire(player)
		end
	end
end

function RoundService:StartRace()
	self:StartCountdown(true)
	if #self.WaitingPlayers < NUM_PLAYERS_TO_START_RACE then
		self.CountdownActive = false
		return
	end
	table.clear(self.RaceResults)
	self.RaceActive = true
	self.Client.RaceStatusChanged:FireAll(self.RaceActive)
	self.CountdownActive = false
	self.DeterminedPlaces = 0
	self.ActivePlayers = table.clone(self.WaitingPlayers)
	table.clear(self.WaitingPlayers)
	self.Client.PlayerCountChanged:FireAll(#self.WaitingPlayers)
	self.TypingService:SetRoundString()
	self.RaceStartTime = tick()
	for _, player in self.ActivePlayers do
		self.Client.RaceStarted:Fire(player)
	end
end

function RoundService:KnitInit()
	self.TypingService = Knit.GetService("TypingService")
	self.LeaderboardService = Knit.GetService("LeaderboardService")
	self.CurrencyService = Knit.GetService("CurrencyService")
end

function RoundService:AddPlayerResult(player: Player, result)
	result.Placement = "?"
	if result.TypedString == self.TypingService:GetRoundString() then
		result.Placement = #self.RaceResults + 1
		self.DeterminedPlaces += 1
	end
	table.insert(self.RaceResults, result)
	if self.RaceActive then
		self.Client.LiveResultAdded:FireAll(result)
	end
	if self.RaceActive and not self.CountdownActive then
		self:EndRace()
	end
end

function RoundService:GetMostCharactersTyped()
	local numChars = 0
	local nextPlaceResult = nil
	for _, result in self.RaceResults do
		if result.Placement == "?" and numChars < string.len(result.TypedString) then
			numChars = string.len(result.TypedString)
			nextPlaceResult = result
		end
	end
	return nextPlaceResult
end

function RoundService:DeterminePlaces()
	for _, result in self.RaceResults do
		if result.Placement == "?" and result == self:GetMostCharactersTyped() then
			self.DeterminedPlaces += 1
			result.Placement = self.DeterminedPlaces
		end
	end
end

-- client
function RoundService.Client:JoinOrLeaveWaitingQueue(player: Player, join: boolean)
	if join then
		return join == true and self.Server:AddWaitingPlayer(player)
	else
		return self.Server:RemoveWaitingPlayer(player)
	end
end

function RoundService.Client:GetRaceStatus()
	return self.Server.RaceActive
end

return RoundService
