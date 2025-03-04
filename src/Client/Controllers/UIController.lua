--[[
    UIController.lua

    Description:
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local UIController = Knit.CreateController({ Name = script.Name })

function UIController:KnitStart()
	local hud = PlayerGui:WaitForChild("HUD")
	self.ResultsFrame = hud:WaitForChild("ResultsMain")
	local frame = self.ResultsFrame:WaitForChild("Frame")
	self.DataFrame = frame:WaitForChild("Data")
	local scrollingFrame = self.DataFrame:WaitForChild("ScrollingFrame")
	self.PlayerResultFrame = scrollingFrame:WaitForChild("temp")
	local typingMain = hud:WaitForChild("TypingMain")
	self.WaitingForResultsTL = typingMain:WaitForChild("WaitingForResults")

	local liveResultsFrame = typingMain:WaitForChild("LiveResults")
	self.LiveDataFrame = liveResultsFrame:WaitForChild("Data")

	local resultsContinueButton: TextButton = self.ResultsFrame:WaitForChild("ContinueButton")
end

function UIController:KnitInit()
	self.RoundService = Knit.GetService("RoundService")
	self.TypingController = Knit.GetController("TypingController")
	self.RoundController = Knit.GetController("RoundController")
	self.ResultsController = Knit.GetController("ResultsController")
	self.TypingService = Knit.GetService("TypingService")
end

return UIController
