--[[
    RoundService.lua
    1/21/25

    Description: 
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Waypoints: Folder = workspace:WaitForChild("Waypoints")
local Start = Waypoints:WaitForChild("Start") :: Part
local End = Waypoints:WaitForChild("End") :: Part

local Lobby: Folder = workspace:WaitForChild("Lobby")
local RoundWaitingPart = Lobby:WaitForChild("RoundWaitingPart") :: Part

local RoundService = Knit.CreateService({
	Name = script.Name,
	Client = {
		PlayerJoined = Knit.CreateSignal(),
		RaceStarted = Knit.CreateSignal(),
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
	RoundWaitingPart.Touched:Connect(function(hit)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if player and not table.find(self.WaitingPlayers, player) then
			table.insert(self.WaitingPlayers, player)
			if #self.WaitingPlayers >= 1 and not self.RaceActive then
				self:StartRace()
			end
		end
	end)
	RoundWaitingPart.TouchEnded:Connect(function(hit)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			table.remove(self.WaitingPlayers, table.find(self.WaitingPlayers, player))
		end
	end)
end

function RoundService:GetRandomPlayer(): Player
	local activePlayers = Players:GetPlayers()
	return activePlayers[math.random(1, #activePlayers)]
end
function RoundService:MoveTo(player, targetPoint, andThen)
	local humanoid = player.character:FindFirstChild("Humanoid") :: Humanoid
	if not humanoid then
		return
	end

	local targetReached = false

	-- listen for the humanoid reaching its target
	self.MoveToConnectsion[player] = humanoid.MoveToFinished:Connect(function(reached)
		targetReached = true
		self.MoveToConnectsion[player]:Disconnect()
		self.MoveToConnectsion[player] = nil
		if andThen then
			andThen(reached)
		end
	end)

	-- start walking
	humanoid:MoveTo(targetPoint)

	-- execute on a new thread so as to not yield function
	self.MoveToUpdates[player] = task.spawn(function()
		while not targetReached do
			-- does the humanoid still exist?
			if not (humanoid and humanoid.Parent) then
				break
			end
			-- has the target changed?
			if humanoid.WalkToPoint ~= targetPoint then
				break
			end
			-- refresh the timeout
			humanoid:MoveTo(targetPoint)
			print("move to")
			task.wait(1)
		end

		-- disconnect the connection if it is still connected
		if self.MoveToConnectsion[player] then
			print("dc")
			self.MoveToConnectsion[player]:Disconnect()
			self.MoveToConnectsion[player] = nil
		end
	end)
end

function RoundService:EndRace()
	if self.RaceActive == false then
		return
	end
	self.RaceEndTime = tick()
	self.RaceTime = self.RaceEndTime - self.RaceStartTime
	print(self.RaceTime)
	print("end race")
	self.EndRaceConnection:Disconnect()
	self.EndRaceConnection = nil
	End:Destroy()
	for _, player in Players:GetPlayers() do
		-- disconnect the connection if it is still connected
		if self.MoveToConnectsion[player] then
			print("dc")
			self.MoveToConnectsion[player]:Disconnect()
			self.MoveToConnectsion[player] = nil
		end
		if self.MoveToUpdates[player] then
			task.cancel(self.MoveToUpdates[player])
		end
	end
	self.RaceActive = false
	self.Client.RaceEnded:FireAll()
	self:VerfiyResults()
end

function RoundService:VerfiyResults()
	table.clear({ self.RaceResults })
	print(#self.RaceResults, #self.ActivePlayers)
	while #self.RaceResults < #self.ActivePlayers do
		task.wait(1)
		print("waiting for results")
	end
	print("results received")
end

function RoundService:StartRace()
	self.RaceActive = true
	self.ActivePlayers = table.clone(self.WaitingPlayers)
	self.RaceStartTime = tick()
	self.TypingService:SetRoundString()
	self.Client.RaceStarted:FireAll()

	self.EndRaceConnection = End.Touched:Connect(function(hit)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)

		if player then -- player is found
			print(player.Name .. " won")
			self.CurrencyService:AddCurrency(player, 10)
			self:EndRace()
		end
	end)

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then
			continue
		end
		character:MoveTo(Start.CFrame.Position)
		task.wait()
		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid then
			continue
		end
		humanoid.WalkSpeed = 2
		--humanoid:MoveTo(End.CFrame.Position)
		self:MoveTo(player, End.CFrame.Position, function()
			print("finished")
		end)
	end
end

function RoundService:KnitInit()
	self.TypingService = Knit.GetService("TypingService")
	self.CurrencyService = Knit.GetService("CurrencyService")

	self.MoveToConnectsion = {}
	self.MoveToUpdates = {}

	Players.PlayerAdded:Connect(function(player)
		--table.insert(self.ActivePlayers, player)
		self.Client.PlayerJoined:FireAll(player.Name)
		--task.wait(3)
		--self:StartRace()
	end)
end

function RoundService:CheckPlayerString(player: Player, playerString: string)
	print(playerString, string.sub(self.TypingService:GetRoundString(), 1, string.len(playerString)))
	if playerString ~= string.sub(self.TypingService:GetRoundString(), 1, string.len(playerString)) then
		print("CHEATER DETECTED: " .. player.Name)
	else
		print(player.Name .. " did not cheat")
	end
	table.insert(self.RaceResults, { player, self.TypingService:CalculateWPM(playerString, self.RaceTime) })
end

-- client
function RoundService.Client:CheckPlayerString(player: Player, playerString: string)
	return self.Server:CheckPlayerString(player, playerString)
end

return RoundService
