--[[
    CurrencyService.lua
    1/18/25

    Description: Generates words
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local CurrencyService = Knit.CreateService({
	Name = script.Name,
	Client = { WordGenerated = Knit.CreateSignal() },
})

function CurrencyService:KnitStart() end

function CurrencyService:AddCurrency(player: Player, amount: number)
	local container = self.PlayerService:GetContainer(player)
	if container then
		container.Replica:Write("IncrementCurrency", amount)
	end
end

function CurrencyService:KnitInit()
	self.PlayerService = Knit.GetService("PlayerService")
end

return CurrencyService
