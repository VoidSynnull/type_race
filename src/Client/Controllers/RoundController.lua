--[[
    RoundController.lua

    Description:
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local RoundController = Knit.CreateController({ Name = script.Name })

function RoundController:KnitStart()
	self.RoundService.RaceStarted:Connect(function()
		self.CameraController:MoveCameraToRandomSpot()
		self.TypingController:ToggleTypingUI(true)
	end)
	self.RoundService.RaceEnded:Connect(function()
		self.RoundService:CheckPlayerString(self.TypingController:GetTypedString())
		self.TypingController:ToggleTypingUI(false)
		self.CameraController:ResetCamera()
	end)
end

function RoundController:KnitInit()
	self.RoundService = Knit.GetService("RoundService")
	self.CameraController = Knit.GetController("CameraController")
	self.TypingController = Knit.GetController("TypingController")
end

return RoundController
