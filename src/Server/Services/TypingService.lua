--[[
    TypingService.lua
    1/18/25

    Description: Checks against active worse
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Enums = require(ReplicatedStorage.Shared.Enums)
local Types = require(ReplicatedStorage.Shared.Types)

local TypingService = Knit.CreateService({
	Name = script.Name,
	Client = { StringGenerated = Knit.CreateSignal() },
})

function TypingService:KnitStart()
	self.NextAIString = ""
	task.spawn(function()
		self.NextAIString = self.WordGeneratorService:GenerateAIString(math.random(1, 3))
	end)
end

function TypingService:SetRoundString()
	if self.NextAIString ~= "" then
		self.ActiveString = self.NextAIString
		self.NextAIString = ""
		task.spawn(function()
			self.NextAIString = self.WordGeneratorService:GenerateAIString(math.random(1, 3))
		end)
	else
		self.ActiveString = self.WordGeneratorService:GenerateStringOfRandomWords(math.random(1, 3))
	end
	for _, player in self.RoundService.ActivePlayers do
		self.Client.StringGenerated:Fire(player, self.ActiveString)
	end
end

function TypingService:GetRoundString()
	return self.ActiveString
end

function TypingService:CheckForWin(player: Player, data)
	if self.RoundService:GetPlayerResults(player) then
		return
	end
	if data.TypedString == self.ActiveString then
		local wpm = self:CalculateWPM(data.TypedString, tick() - self.RoundService.RaceStartTime)
		data.WPM = wpm
		self.RoundService:AddPlayerResult(player, data)
		return true
	else
		return false
	end
end

function TypingService:CalculateWPM(typedString: string, seconds: number): number
	local wpm = (string.len(typedString) / 5) / (seconds / 60)
	return wpm
end

function TypingService:CheckPlayerString(player: Player, data: Types.RaceResults)
	if data.TypedString ~= string.sub(self:GetRoundString(), 1, string.len(data.TypedString)) then
		player:Kick("Cheating detected.")
		self.RoundService:RemovePlayerFromGame(player)
		return false
	else
		data.WPM = self:CalculateWPM(data.TypedString, tick() - self.RoundService.RaceStartTime)
		self.RoundService:AddPlayerResult(player, data)
		return true
	end
end

-- client
function TypingService.Client:CheckPlayerString(player: Player, data)
	return self.Server:CheckPlayerString(player, data)
end
function TypingService.Client:CheckForWin(player: Player, playerString: string)
	return self.Server:CheckForWin(player, playerString)
end

function TypingService:KnitInit()
	self.ActiveString = ""
	self.WordGeneratorService = Knit.GetService("WordGeneratorService")
	self.RoundService = Knit.GetService("RoundService")
end

return TypingService
