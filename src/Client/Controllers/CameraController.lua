--[[
    CameraController.lua
    Author:

    Description: Manage camera
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local CameraController = Knit.CreateController({ Name = "CameraController" })

function CameraController:MoveCameraToPart(part: BasePart)
	self.Camera.CFrame = part.CFrame
end

function CameraController:MoveCameraToRandomSpot()
	self.Camera.CameraType = Enum.CameraType.Scriptable
	local spots = self.CameraSpots:GetChildren()
	local randomSpot = spots[math.random(1, #spots)]
	self.Camera.CFrame = randomSpot.CFrame
end
function CameraController:ResetCamera()
	self.Camera.CameraType = Enum.CameraType.Custom
end
function CameraController:KnitStart()
	self.Camera = workspace.CurrentCamera
	self.CameraSpots = workspace:WaitForChild("CameraSpots")
end

function CameraController:KnitInit() end

return CameraController
