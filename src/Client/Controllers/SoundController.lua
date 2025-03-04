-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService: SoundService = game:GetService("SoundService")
local TweenService: TweenService = game:GetService("TweenService")

-- Packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local SOUND_GROUPS = { UI = "UI", SFX = "SFX", Music = "Music" }
--
local SoundController = Knit.CreateController({
	Name = script.Name,
})

-- Gets Sound in Sound Service
function SoundController:GetSound(SoundName: string, group: string)
	return SoundService:FindFirstChild(group):FindFirstChild(SoundName, true)
end

function SoundController:PlaySound(SoundName: string, FadeInTime: number)
	-- Find Sound
	local SoundToPlay: Sound = self:GetSound(SoundName, SOUND_GROUPS.Music)
	if not SoundToPlay then
		warn("Cannot find Sound: " .. SoundName)
		return
	end
	if self._tweens[SoundName .. "Play"] then
		self._tweens[SoundName .. "Play"]:Cancel()
		return
	end
	--
	local VolumeGoal: number = self._originalVolumes[SoundName]
	-- Play Sound with Fade In
	SoundToPlay.Volume = 0
	SoundToPlay.TimePosition = self._timePositions[SoundName]
	self._timePositions[SoundName] = 0
	SoundToPlay:Play()
	local tween: Tween = TweenService:Create(
		SoundToPlay,
		TweenInfo.new(FadeInTime or 0.001, Enum.EasingStyle.Linear),
		{ Volume = VolumeGoal }
	)
	self._tweens[SoundName .. "Play"] = tween
	tween.Completed:Connect(function()
		table.remove(self._tweens, table.find(self._tweens, tween))
		self._tweens[SoundName .. "Play"] = nil
	end)
	tween:Play()
	self._currentSound = SoundName
end

function SoundController:PlaySoundEffect(SoundName: string)
	-- Find Sound
	local SoundToPlay: Sound = self:GetSound(SoundName, SOUND_GROUPS.SFX)

	if not SoundToPlay then
		warn("Cannot find Sound: " .. SoundName)
		return
	end
	-- Play Sound
	SoundToPlay:Play()
end
function SoundController:PlayUISoundEffect(SoundName: string)
	-- Find Sound
	local SoundToPlay: Sound = self:GetSound(SoundName, SOUND_GROUPS.UI)

	if not SoundToPlay then
		warn("Cannot find Sound: " .. SoundName)
		return
	end
	-- Play Sound
	SoundToPlay:Play()
end
function SoundController:StopSoundEffect(SoundName: string)
	-- Find Sound
	local SoundToPlay: Sound = self:GetSound(SoundName, SOUND_GROUPS.SFX)

	if not SoundToPlay then
		warn("Cannot find Sound: " .. SoundName)
		return
	end
	-- Stop Sound
	SoundToPlay:Stop()
end

function SoundController:PlayRandomTypewriterSFX()
	-- Find Sound
	local typeWriterFolder = SoundService:FindFirstChild(SOUND_GROUPS.SFX):FindFirstChild("Typewriter") :: Folder
	local typeWriterSounds = typeWriterFolder:GetChildren()
	local SoundToPlay: Sound = typeWriterSounds[math.random(1, #typeWriterSounds)]

	-- Play Sound
	SoundToPlay:Play()
end

function SoundController:StopSound(SoundName: string, FadeOutTime: number)
	-- Find Sound
	if not SoundName then
		SoundName = self._currentSound
	end
	local SoundToStop: Sound = self:GetSound(SoundName, SOUND_GROUPS.Music)

	if not SoundToStop then
		warn("Cannot find Sound: " .. SoundName)
		return
	end
	if self._tweens[SoundName .. "Stop"] then
		self._tweens[SoundName .. "Stop"]:Cancel()
		return
	end

	-- Save Orig Volume
	local OrigVolume: number = self._originalVolumes[SoundName]

	--
	local tween: Tween =
		TweenService:Create(SoundToStop, TweenInfo.new(FadeOutTime or 0.001, Enum.EasingStyle.Linear), { Volume = 1 })
	tween.Completed:Connect(function()
		table.remove(self._tweens, table.find(self._tweens, tween))
		self._tweens[SoundName .. "Stop"] = nil
	end)
	tween:Play()
	task.delay(FadeOutTime or 0.001, function()
		SoundToStop:Stop()
		SoundToStop.Volume = OrigVolume
	end)
end
--
function SoundController:PauseSound(SoundName: string)
	-- Find Sound
	local SoundToStop: Sound = self:GetSound(SoundName, SOUND_GROUPS.Music)

	if not SoundToStop then
		warn("Cannot find Sound: " .. SoundName)
		return
	end

	SoundToStop:Pause()
	self._timePositions[SoundName] = SoundToStop.TimePosition
end

--
function SoundController:ChangeVolume(SoundName: string, VolumeSelected: number, FadeTime: number)
	-- Find Sound
	local Sound: Sound = self:GetSound(SoundName, SOUND_GROUPS.Music)

	if not Sound then
		warn("Cannot find Sound: " .. SoundName)
		return
	end

	TweenService:Create(Sound, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { Volume = VolumeSelected }):Play()
end

--
function SoundController:KnitInit() end

function SoundController:SetupConnections()
	self.RoundService.Countdown:Connect(function(starting: boolean, count: number)
		if starting then
			if count > 0 then
				self:PlaySoundEffect("countdown")
			else
				self:PlaySoundEffect("countdown_finished")
			end
		end
	end)
end

function SoundController:KnitStart()
	-- Services
	self.RoundService = Knit.GetService("RoundService")

	-- Vars
	self._tweens = {}
	self._originalVolumes = {}
	self._timePositions = {}

	-- Initialize volumes & positions
	for _, sound in ipairs(SoundService:GetDescendants()) do
		if not sound:IsA("Sound") then
			continue
		end
		self._originalVolumes[sound.Name] = sound:FindFirstAncestorOfClass("SoundGroup").Volume
		self._timePositions[sound.Name] = sound.TimePosition
	end

	-- Set up connections
	self:SetupConnections()

	-- Start main sound
	self:PlaySound("Main", 1)
end

return SoundController
