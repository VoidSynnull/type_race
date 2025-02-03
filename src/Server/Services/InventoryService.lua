--[[
    ShopService.lua
    Author: 

    Description:
]]
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Assets = ServerStorage:WaitForChild("Assets")
local Trails = Assets:WaitForChild("Trails")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Shared = ReplicatedStorage:WaitForChild("Shared")

-- local Packages = ReplicatedStorage.Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

local InventoryService = Knit.CreateService({
	Name = "InventoryService",
	Client = {},
})

function InventoryService:EquipTrail(player: Player, trailName: string)
	local trail = Trails:FindFirstChild(trailName)
	if not trail then
		return
	end
	local playerTrail: Part = trail:Clone()
	local character = player.Character
	if not character then
		return
	end
	local hrp: Part = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	playerTrail.Parent = character

	local weld: Weld = Instance.new("Weld")
	weld.Part0 = hrp
	weld.Part1 = playerTrail
	weld.Parent = playerTrail
	weld.C0 = CFrame.new() * CFrame.Angles(0, 0, math.rad(90))
end

function InventoryService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		self:EquipTrail(player, "ColorTrail")
	end)
end

function InventoryService:KnitInit() end

return InventoryService
