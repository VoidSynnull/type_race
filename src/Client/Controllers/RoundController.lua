--[[
    RoundController.lua

    Description:
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local RoundController = Knit.CreateController({ Name = script.Name })

function RoundController:KnitStart()
	local hud = PlayerGui:WaitForChild("HUD")
	self.LobbyMain = hud:WaitForChild("LobbyMain")
	local joinRace: TextButton = self.LobbyMain:WaitForChild("JoinRace")

	self.InQueue = false
	joinRace.MouseButton1Click:Connect(function()
		self.InQueue = not self.InQueue
		print(self.RoundService:JoinOrLeaveWaitingQueue(self.InQueue))
	end)

	self.RoundService.RaceStarted:Connect(function()
		self.InQueue = false
		self:ToggleLobbyUI(false)
		self.TypingController:ToggleTypingUI(true)
	end)

	self.RoundService.RaceEnded:Connect(function()
		self.TypingController:ToggleTypingUI(false)
	end)
end

function RoundController:ToggleLobbyUI(toggle: boolean)
	self.LobbyMain.Visible = toggle
end

function RoundController:KnitInit()
	self.RoundService = Knit.GetService("RoundService")
	self.TypingController = Knit.GetController("TypingController")
	self.TypingService = Knit.GetService("TypingService")
end

return RoundController
