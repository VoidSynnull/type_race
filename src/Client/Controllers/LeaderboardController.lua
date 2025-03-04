--[[
    LeaderboardController.lua

    Description:
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local NUM_ENTRIES = 51

local LeaderboardController = Knit.CreateController({ Name = script.Name })

function LeaderboardController:KnitStart()
	local hud = PlayerGui:WaitForChild("HUD")
	local lobbyMain = hud:WaitForChild("LobbyMain")
	local lobbyLeaderButton = lobbyMain:WaitForChild("LeaderboardsBtn")

	self.CanFetch = true
	self.UI = hud:WaitForChild("LeaderboardMain")
	local frame = self.UI:WaitForChild("Frame")
	local leaderButtons = frame:WaitForChild("Buttons")
	self.LeaderboardsBtns = {}
	self.LoadingImg = frame:WaitForChild("LoadingImg")
	self.LoadingImg.Visible = false

	self.UI.Visible = false
	local backBtn = self.UI:WaitForChild("BackBtn")
	local refreshBtn = self.UI:WaitForChild("RefreshBtn")
	self.CurrentCategory = "TOTALPLAYS"

	local dataFrame = frame:WaitForChild("Data")
	self.ScrollingFrame = dataFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
	local temp = self.ScrollingFrame:WaitForChild("temp")
	for i = 1, NUM_ENTRIES do
		local entry = temp:Clone()
		entry.Name = tostring(i)
		entry.Visible = false
		entry.Parent = self.ScrollingFrame
	end

	self.Data = {}
	self.UserNames = {}

	for _, button: TextButton in leaderButtons:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end
		table.insert(self.LeaderboardsBtns, button)
		button.MouseButton1Click:Connect(function()
			if not self.CanFetch then
				return
			end
			self.CurrentCategory = button.Name
			self:ToggleButton()
			if not self.Data[button.Name] then
				self:FetchData(button.Name)
			end
			self:PopulateData(button.Name)
		end)
	end
	lobbyLeaderButton.MouseButton1Click:Connect(function()
		self:ToggleUI(true)
		if not self.Data[self.CurrentCategory] then
			self:FetchDataForCurrentCategory()
		end
	end)
	backBtn.MouseButton1Click:Connect(function()
		self:ToggleUI(false)
	end)

	refreshBtn.MouseButton1Click:Connect(function()
		self:FetchDataForCurrentCategory()
	end)
end

function LeaderboardController:FetchDataForCurrentCategory()
	if not self.CanFetch then
		return
	end
	self:FetchData(self.CurrentCategory)
	self:PopulateData(self.CurrentCategory)
end

function LeaderboardController:ToggleButton()
	for _, button: TextButton in self.LeaderboardsBtns do
		if button.Name == self.CurrentCategory then
			button.BackgroundColor3 = Color3.new(0.239216, 0.239216, 0.239216)
			button.TextColor3 = Color3.new(1.000000, 1.000000, 1.000000)
		else
			button.BackgroundColor3 = Color3.new(1.000000, 1.000000, 1.000000)
			button.TextColor3 = Color3.new(0.000000, 0.000000, 0.000000)
		end
	end
end
function LeaderboardController:ToggleLoadingImg(toggle: boolean)
	if not toggle then
		task.cancel(self.LoadingUpdate)
		self.LoadingImg.Visible = false
		return
	end
	self.LoadingImg.Visible = true
	self.LoadingUpdate = task.spawn(function()
		while true do
			self.LoadingImg.Rotation -= 3
			if self.LoadingImg.Rotation <= -180 then
				self.LoadingImg.Rotation = 180
			end
			task.wait()
		end
	end)
end

function LeaderboardController:FetchData(dsName: string)
	if not self.CanFetch then
		return
	end
	self:HideEntries()
	self.CanFetch = false
	self:ToggleLoadingImg(true)
	self.LeaderboardService:GetTopValues(dsName, NUM_ENTRIES):andThen(function(data)
		if not data then
			return
		end
		self.Data[dsName] = data
	end)
end

function LeaderboardController:ConvertUserIdToName(userId)
	local name
	local success, error = pcall(function()
		name = Players:GetNameFromUserIdAsync(userId)
	end)

	if success then
		self.UserNames[userId] = name
	end
	return self.UserNames[userId] or tostring(userId)
end

function LeaderboardController:PopulateData(dsName: string)
	repeat
		task.wait()
	until self.Data[dsName]

	for i = 1, #self.Data[dsName] do
		local entry = self.ScrollingFrame:FindFirstChild(tostring(i))
		local userId = self.Data[dsName][i]["key"]
		local data = self.Data[dsName][i]["value"]
		if dsName == "WPM" then
			data = data / 100
		end
		entry:FindFirstChild("PlayerName").Text = self.UserNames[userId] or self:ConvertUserIdToName(userId)
		entry:FindFirstChild("Data").Text = data
		entry.Visible = true
	end
	self:ToggleLoadingImg(false)
	self.CanFetch = true
end

function LeaderboardController:HideEntries()
	for i = 1, 50 do
		local entry = self.ScrollingFrame:FindFirstChild(tostring(i))
		entry.Visible = false
	end
end

function LeaderboardController:ToggleUI(toggle: boolean)
	self.UI.Visible = toggle
end

function LeaderboardController:KnitInit()
	self.LeaderboardService = Knit.GetService("LeaderboardService")
end

return LeaderboardController
