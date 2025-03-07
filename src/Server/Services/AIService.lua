--[[
    ShopService.lua
    Author: 

    Description:
]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Shared = ReplicatedStorage:WaitForChild("Shared")

-- local Packages = ReplicatedStorage.Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

local AIService = Knit.CreateService({
	Name = "AIService",
	Client = {},
})

function AIService:GeminiRequest(numWords: number)
	local API_KEY = "AIzaSyAd1gECsPzqcg_HBnxAWz3GIjXSCtj6sSk"
	local API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key="
		.. API_KEY
	local requestBody = {
		contents = {
			role = "user",
			parts = {
				{
					text = "Generate a random sentence about "
						.. self.WordGeneratorService:GenerateWord()
						.. " in "
						.. tostring(numWords + math.random(0, 8))
						.. " words.",
				},
			},
		},
	}

	-- Convert Lua table to JSON
	local requestJson = HttpService:JSONEncode(requestBody)

	-- Set HTTP Headers
	local headers = {
		["Content-Type"] = "application/json",
		--["Authorization"] = "Bearer " .. API_KEY,
	}
	-- Send HTTP Request
	local success, response = pcall(function()
		--return HttpService:Request(API_URL, requestJson, Enum.HttpContentType.ApplicationJson, false, headers)
		local response = HttpService:RequestAsync({
			["Url"] = API_URL,
			["Method"] = "POST",
			["Headers"] = headers,
			["Body"] = requestJson,
		})
		return response
	end)

	-- Handle Response

	if success then
		local decodedResponse = HttpService:JSONDecode(response["Body"])
		if decodedResponse["error"] then
			print(
				"Gemini error code: " .. decodedResponse["error"]["code"] .. " " .. decodedResponse["error"]["message"]
			)
			return ""
		else
			return decodedResponse["candidates"][1]["content"]["parts"][1]["text"]
		end
	else
		warn("Failed to make request:", response)
		return ""
	end
end

function AIService:ChatGPTRequest()
	local API_URL = "https://api.openai.com/v1/chat/completions"
	local API_KEY =
		"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"
	local requestBody = {
		model = "gpt-4o-mini",
		messages = {
			{
				role = "user",
				content = "Generate a random sentence about " .. self.WordGeneratorService:GenerateWord(),
			},
		},
	}

	-- Convert Lua table to JSON
	local requestJson = HttpService:JSONEncode(requestBody)

	-- Set HTTP Headers
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. API_KEY,
	}

	-- Send HTTP Request
	local success, response = pcall(function()
		--return HttpService:Request(API_URL, requestJson, Enum.HttpContentType.ApplicationJson, false, headers)
		local response = HttpService:RequestAsync({
			["Url"] = API_URL,
			["Method"] = "POST",
			["Headers"] = headers,
			["Body"] = requestJson,
		})
		return response
	end)

	-- Handle Response
	if success then
		local decodedResponse = HttpService:JSONDecode(response)
	else
		warn("Failed to make request:", response)
	end
end

function AIService:KnitStart() end

function AIService:KnitInit()
	self.WordGeneratorService = Knit.GetService("WordGeneratorService")
end

return AIService
