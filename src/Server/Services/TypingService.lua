--[[
    TypingService.lua
    1/18/25

    Description: Checks against active worse
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Enums = require(ReplicatedStorage.Shared.Enums)

local TypingService = Knit.CreateService({
	Name = script.Name,
	Client = { StringGenerated = Knit.CreateSignal() },
})

function TypingService:KnitStart() end

function TypingService:SetRoundString()
	self.ActiveString = self.WordGeneratorService:GenerateStringOfRandomWords(Enums.RaceLevels.EASY)
	self.Client.StringGenerated:FireAll(self.ActiveString)
end

function TypingService:GetRoundString()
	return self.ActiveString
end

function TypingService:CheckPlayerInputAgainstActiveWords(playerString: string)
	if playerString == self.ActiveString then
		print("player was correct")
	end
end

function TypingService:CheckForWin(player: Player, playerString: string)
	if playerString == self.ActiveString then
		print(player.Name .. " won.")
		self.RoundService:EndRace()
		return true
	else
		return false
	end
end

function TypingService:CalculateWPM(typedString: string, seconds: number): number
	local wpm = (string.len(typedString) / 5) / (seconds / 60)
	return wpm
end

function TypingService:CheckPlayerString(player: Player, playerString: string)
	print(playerString, string.sub(self:GetRoundString(), 1, string.len(playerString)))
	if playerString ~= string.sub(self:GetRoundString(), 1, string.len(playerString)) then
		print("CHEATER DETECTED: " .. player.Name)
		return false
	else
		print(player.Name .. " did not cheat")
		local wpm = self:CalculateWPM(playerString, self.RoundService.RaceTime)
		print("WPM: " .. tostring(wpm))
		self.RoundService:AddPlayerResult(player, wpm)
		return true
	end
end

-- client
function TypingService.Client:CheckPlayerString(player: Player, playerString: string)
	return self.Server:CheckPlayerString(player, playerString)
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
