--[[
    WordGeneratorService.lua
    1/18/25

    Description: Generates words
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local Enums = require(ReplicatedStorage.Shared.Enums)
local ServerStorage = game:GetService("ServerStorage")
local Data = ServerStorage:WaitForChild("Data")
local WordDB = require(Data.WordDB)

local NUM_WORDS = {
	[Enums.RaceLevels.EASY] = 5,
	[Enums.RaceLevels.MEDIUM] = 50,
	[Enums.RaceLevels.HARD] = 100,
}
local WordGeneratorService = Knit.CreateService({
	Name = script.Name,
	Client = { WordGenerated = Knit.CreateSignal() },
})

function WordGeneratorService:KnitStart() end

function WordGeneratorService:GenerateWord(): string
	return WordDB[math.random(1, #WordDB)]
	--self.Client.WordGenerated:FireAll(self.Word)
end

function WordGeneratorService:GenerateStringOfRandomWords(level: number): string
	local generatedString = ""
	for i = 1, NUM_WORDS[level] do
		generatedString = generatedString .. self:GenerateWord()
		if i < NUM_WORDS[level] then
			generatedString = generatedString .. " "
		end
	end
	return generatedString
end

function WordGeneratorService:KnitInit() end

return WordGeneratorService
