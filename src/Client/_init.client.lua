-- local LocalPlayer = game.Players.LocalPlayer
-- set camera
-- workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

local Player = game.Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

Knit.AddControllers(PlayerScripts:WaitForChild("Controllers"))
-- load interfaces
-- Knit.AddControllers(PlayerScripts.Controllers:WaitForChild("Interface"))
Knit.Start():catch()
