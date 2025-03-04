--[[
    ResultsContoller.lua

    Description:
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local ResultsController = Knit.CreateController({ Name = script.Name })

function ResultsController:KnitStart()
	local hud = PlayerGui:WaitForChild("HUD")
	self.ResultsFrame = hud:WaitForChild("ResultsMain")
	local frame = self.ResultsFrame:WaitForChild("Frame")
	local dataFrame = frame:WaitForChild("Data")
	self.DataFrame = dataFrame:WaitForChild("ScrollingFrame")
	self.PlayerResultFrame = self.DataFrame:WaitForChild("temp")
	local typingMain = hud:WaitForChild("TypingMain")
	self.WaitingForResultsTL = typingMain:WaitForChild("WaitingForResults")

	local liveResultsFrame = typingMain:WaitForChild("LiveResults")
	local liveDataFrame = liveResultsFrame:WaitForChild("Data")
	self.LiveDataFrame = liveDataFrame:WaitForChild("ScrollingFrame")

	local resultsContinueButton: TextButton = self.ResultsFrame:WaitForChild("ContinueButton")

	resultsContinueButton.MouseButton1Click:Connect(function()
		self:ToggleResultsUI(false)
		self:ClearPlayerResults()
		self.RoundController:ToggleLobbyUI(true)
	end)
	self.RoundService.CollectRaceResults:Connect(function()
		self.WaitingForResultsTL.Visible = true
		self.TypingService:CheckPlayerString(self.TypingController:GetData())
	end)

	self.RoundService.LiveResultAdded:Connect(function(result)
		self:AddPlayerResults({ result }, self.LiveDataFrame)
	end)
	self.RoundService.RaceEnded:Connect(function(results)
		self:AddPlayerResults(results, self.DataFrame)
		self.WaitingForResultsTL.Visible = false
		self:ToggleResultsUI(true)
	end)
	self.RoundService.RaceStarted:Connect(function()
		self:ClearPlayerResults()
	end)
end

function ResultsController:AddPlayerResults(results, parent)
	for _, result in results do
		local newPlayerResultFrame = self.PlayerResultFrame:Clone()
		newPlayerResultFrame.Placement.Text = result.Placement
		newPlayerResultFrame.PlayerName.Text = result.PlayerName
		newPlayerResultFrame.WPM.Text = "WPM: " .. self:RoundWPM(result.WPM)
		newPlayerResultFrame.Name = result.PlayerName
		newPlayerResultFrame.Visible = true
		newPlayerResultFrame.Parent = parent
	end
end

function ResultsController:RoundWPM(wpm: number): string
	wpm *= 100
	wpm = math.floor(wpm)
	wpm = wpm / 100
	return tostring(wpm)
end

function ResultsController:ClearPlayerResults()
	for _, result in self.DataFrame:GetChildren() do
		if result:IsA("Frame") and result.Name ~= "temp" then
			result:Destroy()
		end
	end
	for _, result in self.LiveDataFrame:GetChildren() do
		if result:IsA("Frame") and result.Name ~= "temp" then
			result:Destroy()
		end
	end
end

function ResultsController:ToggleResultsUI(toggle: boolean)
	self.ResultsFrame.Visible = toggle
end

function ResultsController:KnitInit()
	self.RoundService = Knit.GetService("RoundService")
	self.TypingController = Knit.GetController("TypingController")
	self.RoundController = Knit.GetController("RoundController")
	self.TypingService = Knit.GetService("TypingService")
end

return ResultsController
