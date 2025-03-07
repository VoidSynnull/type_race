--- Makes playing and loading tracks into a humanoid easy
-- @classmod AnimationPlayer
local RunService = game:GetService("RunService")
-- local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Signal = require(game.ReplicatedStorage.Packages.Signal)

local AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer
AnimationPlayer.ClassName = "AnimationPlayer"

--- Constructs a new animation player
-- @constructor
-- @tparam Humanoid Humanoid
function AnimationPlayer.new(Humanoid)
	local self = setmetatable({}, AnimationPlayer)
	self.Humanoid = Humanoid or error("No Humanoid")
	self.Animator = Humanoid:WaitForChild("Animator")
	self.Tracks = {}
	self.FadeTime = 0.2 -- Default

	self.TrackPlayed = Signal.new()
	self.TrackPlaying = false

	self._tracker = RunService.Heartbeat:Connect(function()
		for _, track in pairs(self.Tracks) do
			if track.IsPlaying then
				self.TrackPlaying = true
				return
			end
		end
		self.TrackPlaying = false
	end)

	return self
end

--- Adds an animation to use
function AnimationPlayer:ClearAllTracks()
	for i, v in pairs(self.Tracks) do
		self.Tracks[i]:Destroy()
		self.Tracks[i] = nil
	end
	return self
end

function AnimationPlayer:RemoveTrack(Name)
	if self.Tracks[Name] ~= nil then
		self.Tracks[Name]:Destroy()
	end

	self.Tracks[Name] = nil
	return self
end

function AnimationPlayer:WithAnimation(Animation: Animation, name: string | nil)
	self.Tracks[name or Animation.Name] = self.Animator:LoadAnimation(Animation)

	return self.Tracks[name or Animation.Name]
end

--- Adds an animation to play
function AnimationPlayer:AddAnimation(Name, AnimationId)
	local Animation = Instance.new("Animation")

	if tonumber(AnimationId) then
		Animation.AnimationId = "http://www.roblox.com/Asset?ID=" .. AnimationId or error("No AnimationId")
	else
		Animation.AnimationId = AnimationId
	end

	Animation.Name = Name or error("No name")

	return self:WithAnimation(Animation)
end

--- Returns a track in the player
function AnimationPlayer:GetTrack(TrackName)
	return self.Tracks[TrackName] --or error("Track does not exist")
end

function AnimationPlayer:AdjustWeight(TrackName, weight)
	local track = self:GetTrack(TrackName)
	track:AdjustWeight(weight)
end

---Plays a track
-- @tparam string TrackName Name of the track to play
-- @tparam[opt=0.4] number FadeTime How much time it will take to transition into the animation.
-- @tparam[opt=1] number Weight Acts as a multiplier for the offsets and rotations of the playing animation
-- This parameter is extremely unstable.
-- Any parameter higher than 1.5 will result in very shaky motion, and any parameter higher '
-- than 2 will almost always result in NAN errors. Use with caution.
-- @tparam[opt=1] number Speed The time scale of the animation.
-- Setting this to 2 will make the animation 2x faster, and setting it to 0.5 will make it
-- run 2x slower.
-- @tparam[opt=0.4] number StopFadeTime
function AnimationPlayer:PlayTrack(TrackName, Speed, FadeTime, Weight, StopFadeTime)
	FadeTime = FadeTime or self.FadeTime
	local Track = self:GetTrack(TrackName)

	if not Track.IsPlaying then
		self.TrackPlayed:Fire(TrackName, FadeTime, Weight, Speed, StopFadeTime)

		self:StopAllTracks(StopFadeTime or FadeTime)
		Track:Play(FadeTime, 1, Speed)
	else
		self.TrackPlayed:Fire(TrackName, FadeTime, Weight, Speed, StopFadeTime)
		Track:AdjustWeight(Weight or 0.95)
	end

	return Track
end

--- Stops a track from being played
-- @tparam string TrackName
-- @tparam[opt=0.4] number FadeTime
-- @treturn AnimationTrack
function AnimationPlayer:StopTrack(TrackName, FadeTime)
	FadeTime = FadeTime or self.FadeTime

	local Track = self:GetTrack(TrackName)
	if Track.IsPlaying then
		Track:Stop()
	end
	return Track
end

--- Stops all tracks playing
function AnimationPlayer:StopAllTracks(FadeTime)
	for TrackName, _ in pairs(self.Tracks) do
		self:StopTrack(TrackName, FadeTime)
	end
end

function AnimationPlayer:GetTracks()
	return self.Tracks
end
---
function AnimationPlayer:Destroy()
	self:StopAllTracks()
	setmetatable(self, nil)
end

return AnimationPlayer
