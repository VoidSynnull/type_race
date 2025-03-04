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
	[Enums.RaceLevels.EASY] = 25,
	[Enums.RaceLevels.MEDIUM] = 35,
	[Enums.RaceLevels.HARD] = 50,
}
local WordGeneratorService = Knit.CreateService({
	Name = script.Name,
	Client = { WordGenerated = Knit.CreateSignal() },
})

function WordGeneratorService:KnitStart() end

function WordGeneratorService:GenerateWord(): string
	return WordDB[math.random(1, #WordDB)]
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

function WordGeneratorService:GenerateAIString(level: number): string
	local sentence = self.AIService:GeminiRequest(NUM_WORDS[level])
	sentence = string.sub(sentence, 1, string.len(sentence) - 1)
	if sentence == "" then
		sentence = self:GenerateStringOfRandomWords(NUM_WORDS[level])
	end
	return sentence
end

function WordGeneratorService:KnitInit()
	self.AIService = Knit.GetService("AIService")
end

return WordGeneratorService
