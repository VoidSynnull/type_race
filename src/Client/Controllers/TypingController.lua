--[[
    TypingController.lua

    Description:
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local LocalPlayer = Players.LocalPlayer
local CHAIN_MODIFER = 0.4
local DEFAULT_STYLE = "<b><stroke color='#fdcb01' joins='round' thickness='4'>|</stroke></b>"
local TypingController = Knit.CreateController({ Name = script.Name })

function TypingController:KnitStart()
	self.ActiveString = ""
	self.TypedString = ""
	self.CurrentChain = 0
	self:SetUpUI()
	self:SetFirstCharacterStyle()
end

function TypingController:SetFirstCharacterStyle(style: string)
	if not style then
		style = DEFAULT_STYLE
	end
	self.FirstCharStyle = string.split(style, "|")
end
function TypingController:SetUpUI()
	local hud = LocalPlayer.PlayerGui:WaitForChild("HUD")
	self.Main = hud:WaitForChild("TypingMain")
	self.InputText = self.Main:WaitForChild("InputText")
	local activeStringFrame = self.Main:WaitForChild("ActiveStringFrame")
	self.ActiveCharacterArrow = activeStringFrame:WaitForChild("ActiveCharacterArrow")

	local tweenInfo: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, -1, true)
	self.ArrowTween =
		TweenService:Create(self.ActiveCharacterArrow, tweenInfo, { Position = UDim2.fromScale(0.505, 2) })
	self.ArrowTween:Play()
	--self.InputText:CaptureFocus()
	self.InputText:GetPropertyChangedSignal("Text"):Connect(function()
		if self.InputText.Text == "" or self.ActiveString == "" then
			return
		end

		self:CheckInputAgainstCurrentCharacter(self.InputText.Text)
		self.InputText.Text = ""
	end)

	self.Main.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self.InputText:CaptureFocus()
		end
	end)

	self.ActiveStringTextLabel = activeStringFrame:WaitForChild("ActiveString")
	self.CompletedActiveStringTextLabel = activeStringFrame:WaitForChild("CompletedActiveString")
	self.ActiveStringTextLabel.RichText = true
	self.Main.Visible = false
end

function TypingController:KnitInit()
	self.TypingService = Knit.GetService("TypingService")

	self.TypingService.StringGenerated:Connect(function(activeString: string)
		self.TypedString = ""
		self.ActiveString = activeString
		self.CurrentIndex = 1
		self.MaxIndex = string.len(self.ActiveString) + 1
		self.ActiveStringTextLabel.Text = self.ActiveString

		self.CompletedActiveStringTextLabel.Text = ""

		self:ApplyFirstCharStyle()
		--self:StrokeActiveLetter()
	end)
end

function TypingController:ApplyFirstCharStyle()
	local firstChar = self.FirstCharStyle[1]
		.. string.sub(self.ActiveStringTextLabel.Text, 1, 1)
		.. self.FirstCharStyle[2]
	local restOfString = string.sub(self.ActiveStringTextLabel.Text, 2, string.len(self.ActiveStringTextLabel.Text))
	self.ActiveStringTextLabel.Text = firstChar .. restOfString
end

function TypingController:MoveCharacterToCompletedLabel()
	local firstChar = string.sub(self.ActiveStringTextLabel.Text, 1, 1)
	self.CompletedActiveStringTextLabel.Text = self.CompletedActiveStringTextLabel.Text .. firstChar

	self.ActiveStringTextLabel.Text =
		string.sub(self.ActiveStringTextLabel.Text, 2, string.len(self.ActiveStringTextLabel.Text))
end

function TypingController:RemoveFirstCharStyle()
	self.ActiveStringTextLabel.Text = self.ActiveStringTextLabel.ContentText
end

function TypingController:GetActiveCharacter(): string
	return string.sub(self.ActiveString, self.CurrentIndex, self.CurrentIndex)
end

function TypingController:GetTypedString(): string
	return self.TypedString
end

function TypingController:ToggleTypingUI(toggle: boolean)
	self.Main.Visible = toggle
	if toggle == true then
		self.InputText:CaptureFocus()
	end
end

function TypingController:CheckInputAgainstCurrentCharacter(currentInput: string)
	local characters = string.split(currentInput, "")
	for _, character in characters do
		if character == self:GetActiveCharacter() then
			self.CurrentIndex += 1
			self.CurrentChain += 1
			self.TypedString = self.TypedString .. character
			self:RemoveFirstCharStyle()
			self:MoveCharacterToCompletedLabel()
			self:ApplyFirstCharStyle()
		else
			self.CurrentChain = 0
		end
	end

	if self.CurrentIndex == self.MaxIndex then
		self.TypingService:CheckForWin(self.TypedString):andThen(function(winner: boolean)
			print("winner: " .. tostring(winner))
		end)
	end
end

return TypingController
