--[[
    LeaderboardService.lua
    1/18/25

    Description: Generates words
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Modules = ServerStorage:WaitForChild("Modules")
local Shared = ReplicatedStorage:WaitForChild("Shared")
-- Modules
local Types = require(Shared:WaitForChild("Types"))
local OrderedDB = require(Modules:WaitForChild("OrderedDB"))

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local DATA_VERSION = 1
local DS_NAMES = {
	"WINS",
	"WPM",
	"TOTALPLAYS",
}
local LeaderboardService = Knit.CreateService({
	Name = script.Name,
	Client = {},
})

function LeaderboardService:KnitStart()
	self.DS = {}
	self.Timeout = {}
	self:GetDS()
end

function LeaderboardService:GetTopValues(requestingPlayer: Player, dsName: string, entriesToFetch: number)
	local ds = self.DS[dsName]
	if not ds then
		return
	end

	if self.Timeout[requestingPlayer] then
		return
	end
	self.Timeout[requestingPlayer] = true
	task.delay(2, function()
		self.Timeout[requestingPlayer] = false
	end)
	return ds:GetTopValues(entriesToFetch)
end

function LeaderboardService:GetDS()
	for _, name in DS_NAMES do
		self.DS[name] = OrderedDB.new(name .. DATA_VERSION)
	end
end

function LeaderboardService:SaveResults(player: Player, results: Types.RaceResults)
	self.DS["TOTALPLAYS"]:AddToValue(player.UserId, 1)
	local recordedWPM = self.DS["WPM"]:GetValue(player.UserId)
	if recordedWPM < results.WPM * 100 then
		self.DS["WPM"]:SetValue(player.UserId, results.WPM * 100)
	end
	if results.Placement == 1 then
		self.DS["WINS"]:AddToValue(player.UserId, 1)
	end
end

function LeaderboardService:KnitInit()
	self.PlayerService = Knit.GetService("PlayerService")
end

function LeaderboardService.Client:GetTopValues(requestingPlayer: Player, dsName: string, entriesToFetch: number)
	return self.Server:GetTopValues(requestingPlayer, dsName, entriesToFetch)
end

return LeaderboardService
