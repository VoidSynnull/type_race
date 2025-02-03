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

function TypingService:CalculateWPM(typedString: string, seconds: number)
	local wpm = (string.len(typedString) / 5) / (seconds / 60)
	print(wpm)
end

function TypingService:KnitInit()
	self.ActiveString = ""
	self.WordGeneratorService = Knit.GetService("WordGeneratorService")
	self.RoundService = Knit.GetService("RoundService")
end

return TypingService
