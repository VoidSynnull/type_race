--[[
    TypingController.lua

    Description:
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local LocalPlayer = Players.LocalPlayer
local BASE_WALKSPEED = 2
local WRONG_DEDUCTION = 2
local CHAIN_MODIFER = 0.4

local TypingController = Knit.CreateController({ Name = script.Name })

function TypingController:KnitStart()
	self.ActiveString = ""
	self.TypedString = ""
	self.CurrentChain = 0
	self:SetUpUI()
end

function TypingController:SetUpUI()
	local hud = LocalPlayer.PlayerGui:WaitForChild("HUD")
	self.Main = hud:WaitForChild("TypingMain")
	self.InputText = self.Main:WaitForChild("InputText")
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

	local activeStringFrame = self.Main:WaitForChild("ActiveStringFrame")
	self.ActiveStringTextLabel = activeStringFrame:WaitForChild("ActiveString")
	self.CompletedActiveStringTextLabel = activeStringFrame:WaitForChild("CompletedActiveString")
	self.ActiveStringTextLabel.RichText = true
	self.Main.Visible = false
end

function TypingController:AdjustSpeed()
	local human = LocalPlayer.Character.Humanoid
	human.WalkSpeed = BASE_WALKSPEED + (BASE_WALKSPEED * (self.CurrentChain * CHAIN_MODIFER))
end
function TypingController:KnitInit()
	self.TypingService = Knit.GetService("TypingService")

	self.TypingService.StringGenerated:Connect(function(activeString: string)
		self.ActiveString = activeString
		self.CurrentIndex = 1
		self.MaxIndex = string.len(self.ActiveString) + 1
		self.ActiveStringTextLabel.Text = self.ActiveString

		self:BoldActiveLetter()
	end)

	self:SetUpUI()
end

function TypingController:BoldActiveLetter()
	local firstChar = "<b>" .. string.sub(self.ActiveStringTextLabel.Text, 1, 1) .. "</b>"
	local restOfString = string.sub(self.ActiveStringTextLabel.Text, 2, string.len(self.ActiveStringTextLabel.Text))
	self.ActiveStringTextLabel.Text = firstChar .. restOfString
end

function TypingController:MoveCharacterToCompletedLabel()
	local firstChar = string.sub(self.ActiveStringTextLabel.Text, 1, 1)
	self.CompletedActiveStringTextLabel.Text = self.CompletedActiveStringTextLabel.Text .. firstChar

	self.ActiveStringTextLabel.Text =
		string.sub(self.ActiveStringTextLabel.Text, 2, string.len(self.ActiveStringTextLabel.Text))
end

function TypingController:BoldActiveLetterOld()
	if string.find(self.ActiveStringTextLabel.Text, "<b>") then
		--self.ActiveStringTextLabel.Text = string.find(self.ActiveStringTextLabel.Text, "<b>")
	end
	local firstChar = "<b>" .. string.sub(self.ActiveStringTextLabel.Text, 1, 1) .. "</b>"
	local completedString = "<font color='#6b6b6b'>"
		.. string.sub(self.ActiveString, 1, self.CurrentIndex - 1)
		.. "</font>"
	local restOfString = string.sub(self.ActiveString, self.CurrentIndex + 1, string.len(self.ActiveString))
	self.ActiveStringTextLabel.Text = completedString .. firstChar .. restOfString
end

function TypingController:RemoveBold()
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
			self:RemoveBold()
			self:MoveCharacterToCompletedLabel()
			self:BoldActiveLetter()
		else
			self.CurrentChain = 0
		end
		self:AdjustSpeed()
	end

	if self.CurrentIndex == self.MaxIndex then
	end
end

return TypingController
