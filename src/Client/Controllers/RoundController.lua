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
	self.LobbyMain.Visible = true
	local joinRace: TextButton = self.LobbyMain:WaitForChild("JoinRace")
	local typingMain = hud:WaitForChild("TypingMain")
	self.RaceEndsTL = typingMain:WaitForChild("RaceEnds") :: TextLabel
	local raceStatus = self.LobbyMain:WaitForChild("RaceStatus") :: TextLabel
	local playersInQueueTL = self.LobbyMain:WaitForChild("PlayersInQueue") :: TextLabel
	self.RoundService:GetRaceStatus():andThen(function(isActive: boolean)
		self.RaceActive = isActive
		raceStatus.Text = isActive and "Race In Progress" or "Waiting for Players"
	end)
	self.InQueue = false
	joinRace.MouseButton1Click:Connect(function()
		self.InQueue = not self.InQueue
		self.RoundService:JoinOrLeaveWaitingQueue(self.InQueue)
		joinRace.Text = self.InQueue == true and "Leave Queue" or "Join Race"
		joinRace.BackgroundColor3 = self.InQueue == false and Color3.new(0.094118, 0.431373, 0.050980)
			or Color3.new(0.431373, 0.050980, 0.050980)
	end)

	self.RoundService.RaceStatusChanged:Connect(function(active: boolean)
		self.RaceActive = active
		raceStatus.Text = self.RaceActive and "Race In Progress" or "Waiting for Players"
	end)

	self.RoundService.RaceStarted:Connect(function()
		self.InQueue = false
		self:ToggleLobbyUI(false)
		joinRace.Text = "Join Race"
		joinRace.BackgroundColor3 = Color3.new(0.094118, 0.431373, 0.050980)
		self.TypingController:ToggleTypingUI(true)
		raceStatus.Text = "Race In Progress"
	end)

	self.RoundService.RaceEnded:Connect(function()
		self.TypingController:ToggleTypingUI(false)
		raceStatus.Text = "Waiting for Players"
	end)

	self.RoundService.PlayerCountChanged:Connect(function(playerCount: number)
		playersInQueueTL.Text = "Players in Queue: " .. tostring(playerCount)
		if self.RaceActive then
			raceStatus.Text = "Race In Progress"
			return
		end
		if playerCount < 2 then
			raceStatus.Text = "Waiting for Players"
		end
	end)

	self.RoundService.Countdown:Connect(function(starting: boolean, count: number)
		local textLabel: TextLabel = starting == false and self.RaceEndsTL or raceStatus
		textLabel.Visible = true
		local goal: string = starting == true and "Starting" or "Ending"
		textLabel.Text = "Race " .. goal .. " in 5"
		textLabel.Text = textLabel.Text.sub(textLabel.Text, 1, string.len(textLabel.Text) - 1) .. tostring(count)

		if count == 0 then
			if starting then
				textLabel.Text = "Generating Race. Please wait."
			else
				textLabel.Visible = false
			end
		end
	end)
end

function RoundController:ToggleLobbyUI(toggle: boolean)
	self.LobbyMain.Visible = toggle
end

function RoundController:KnitInit()
	self.RoundService = Knit.GetService("RoundService")
	self.TypingService = Knit.GetService("TypingService")

	self.TypingController = Knit.GetController("TypingController")
	self.SoundController = Knit.GetController("SoundController")
end

return RoundController
