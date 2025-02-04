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
	self.DataFrame = frame:WaitForChild("Data")
	self.PlayerResultFrame = self.DataFrame:WaitForChild("temp")

	local resultsContinueButton: TextButton = self.ResultsFrame:WaitForChild("ContinueButton")

	resultsContinueButton.MouseButton1Click:Connect(function()
		self:ToggleResultsUI(false)
		self:ClearPlayerResults()
		self.RoundController:ToggleLobbyUI(true)
	end)
	self.RoundService.CollectRaceResults:Connect(function()
		self.TypingService:CheckPlayerString(self.TypingController:GetTypedString())
	end)
	self.RoundService.RaceEnded:Connect(function(results)
		self:AddPlayerResults(results)
		self:ToggleResultsUI(true)
	end)
end

function ResultsController:AddPlayerResults(results)
	for _, result in results do
		local newPlayerResultFrame = self.PlayerResultFrame:Clone()
		newPlayerResultFrame.Placement.Text = result.Placement
		newPlayerResultFrame.PlayerName.Text = result.PlayerName
		newPlayerResultFrame.WPM.Text = "WPM: " .. tostring(result.WPM)
		newPlayerResultFrame.Name = result.PlayerName
		newPlayerResultFrame.Visible = true
		newPlayerResultFrame.Parent = self.DataFrame
	end
end
function ResultsController:ClearPlayerResults()
	for _, result in self.DataFrame:GetChildren() do
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
