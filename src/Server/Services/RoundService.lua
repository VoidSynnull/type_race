--[[
    RoundService.lua
    1/21/25

    Description: 
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local RoundService = Knit.CreateService({
	Name = script.Name,
	Client = {
		PlayerJoined = Knit.CreateSignal(),
		RaceStarted = Knit.CreateSignal(),
		CollectRaceResults = Knit.CreateSignal(),
		RaceEnded = Knit.CreateSignal(),
	},
})

function RoundService:KnitStart()
	self.ActivePlayers = {}
	self.RaceResults = {}
	self.RaceActive = false
	self.RaceStartTime = 0
	self.RaceEndTime = 0
	self.WaitingPlayers = {}
end

function RoundService:AddWaitingPlayer(player: Player)
	if player and not table.find(self.WaitingPlayers, player) then
		table.insert(self.WaitingPlayers, player)
		if #self.WaitingPlayers >= 1 and not self.RaceActive then
			self:StartRace()
		end
	end
end

function RoundService:RemoveWaitingPlayer(player: Player)
	if player then
		table.remove(self.WaitingPlayers, table.find(self.WaitingPlayers, player))
	end
end

function RoundService:GetRandomPlayer(): Player
	local activePlayers = Players:GetPlayers()
	return activePlayers[math.random(1, #activePlayers)]
end

function RoundService:EndRace()
	if self.RaceActive == false then
		return
	end
	self.RaceEndTime = tick()
	self.RaceTime = self.RaceEndTime - self.RaceStartTime
	self.Client.CollectRaceResults:FireAll()
	self:VerfiyResults()
	print(self.RaceResults)
	self.Client.RaceEnded:FireAll(self.RaceResults)
	self.RaceActive = false
end

function RoundService:VerfiyResults()
	print(#self.RaceResults, #self.ActivePlayers)
	while #self.RaceResults < #self.ActivePlayers do
		task.wait(1)
		print("waiting for results")
	end
	print("results received")
end

function RoundService:StartRace()
	table.clear(self.RaceResults)
	self.RaceActive = true
	self.ActivePlayers = table.clone(self.WaitingPlayers)
	self.RaceStartTime = tick()
	self.TypingService:SetRoundString()
	self.Client.RaceStarted:FireAll()
end

function RoundService:KnitInit()
	self.TypingService = Knit.GetService("TypingService")
	self.CurrencyService = Knit.GetService("CurrencyService")
end

function RoundService:AddPlayerResult(player: Player, wpm)
	local playerResults = {
		Placement = "?",
		PlayerName = player.Name,
		WPM = wpm,
	}
	table.insert(self.RaceResults, playerResults)
end

-- client
function RoundService.Client:JoinOrLeaveWaitingQueue(player: Player, join: boolean)
	return join == true and self.Server:AddWaitingPlayer(player) or self.Server:RemoveWaitingPlayer(player)
end

return RoundService
