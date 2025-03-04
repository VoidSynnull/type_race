--[[
    OrderedDB.lua
    Author:
    Description: Class that manages a connection to an ordered datastore
]]
--

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- References
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ran = Random.new()

-- Modules
local Promise = require(Packages:WaitForChild("Promise"))

local OrderedDB = {}
OrderedDB.__index = OrderedDB

function OrderedDB.new(dataStoreName: string)
	local self = setmetatable({}, OrderedDB)

	self.DataStoreName = dataStoreName
	self._connectedDataStore = self:_connect(dataStoreName)

	if not self._connectedDataStore then
		self._connectedDataStore = self:_tryReconnect(dataStoreName)
	end

	return self
end

function OrderedDB:WipePlayerData(userId: number)
	-- RemoveAsync is not throttled so jump right in
	local status, res = pcall(function()
		return self._connectedDataStore:RemoveAsync(tostring(userId))
	end)

	if not status then
		warn(res)
		return
	end

	return res
end

function OrderedDB:GetTopValues(count: number)
	assert(count, "Must provide a count argument")

	-- Use mocks in studio
	if RunService:IsStudio() then
		local mock = {}
		local mockCount = 0

		for i, player in Players:GetPlayers() do
			mock[i] = {
				key = tostring(player.UserId),
				value = ran:NextInteger(1, 500),
			}

			mockCount += 1

			if mockCount == count then
				return mock
			end
		end

		for i = 1, count - mockCount do
			local mockUserId = ran:NextInteger(100000000, 999999999)
			local mockValue = ran:NextInteger(1, 500)

			mock[i] = {
				key = tostring(mockUserId),
				value = mockValue,
			}

			mockCount += 1

			if mockCount == count then
				return mock
			end
		end

		return mock
	end

	while DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetSortedAsync) < 3 do
		task.wait(0.1)
	end

	local status, values = pcall(function()
		return self._connectedDataStore:GetSortedAsync(false, count)
	end)

	if not status then
		warn(values)

		task.wait(1)

		return self:GetTopValues(count)
	else
		return values:GetCurrentPage()
	end
end

-- Same thing as GetTopValues but as a promise
function OrderedDB:GetTopValuesPromise(count: number)
	assert(count, "Must provide a count argument")

	-- Use mocks in studio
	if RunService:IsStudio() then
		return Promise.new(function(resolve, reject, onCancel)
			local mock = {}
			local mockCount = 0

			for _, player in Players:GetPlayers() do
				mock[player.UserId] = ran:NextInteger(1, 500)

				mockCount += 1

				if mockCount == count then
					resolve(mock)
				end
			end

			for i = 1, count - mockCount do
				local mockUserId = ran:NextInteger(100000000, 999999999)
				local mockValue = ran:NextInteger(1, 500)

				mock[mockUserId] = mockValue

				mockCount += 1

				if mockCount == count then
					resolve(mock)
				end
			end

			resolve(mock)
		end)
	end

	return Promise.new(function(resolve, reject, onCancel)
		task.spawn(function()
			while DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetSortedAsync) < 3 do
				task.wait(0.2)
			end

			local status, values = pcall(function()
				return self._connectedDataStore:GetSortedAsync(false, count)
			end)

			if not status then
				warn(values)
				reject(values)
			else
				resolve(values:GetCurrentPage())
			end
		end)
	end)
end

function OrderedDB:GetValue(userId: number)
	-- Early exit in studio
	if RunService:IsStudio() then
		return 45
	end

	while DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync) < 3 do
		task.wait(0.1)
	end

	local status, value = pcall(function()
		return self._connectedDataStore:GetAsync(userId)
	end)

	if not status then
		warn(value)

		return false
	else
		if value == nil then
			return 0
		else
			return value
		end
	end
end

function OrderedDB:SetValue(userId: number, newValue: number)
	if not newValue then
		return
	end

	if type(newValue) ~= "number" then
		warn(`Can only set a number to OrderedDB. Value is type {type(newValue)}`)
		return
	end

	newValue = math.floor(newValue) -- double isn't allowed in ordered datastore
	-- Early exit in studio
	if RunService:IsStudio() then
		return true
	end

	while DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) < 3 do
		task.wait(0.1)
	end

	local status, values = pcall(function()
		return self._connectedDataStore:UpdateAsync(userId, function(oldValue)
			if not oldValue or newValue > oldValue then
				return newValue
			else
				return nil
			end
		end)
	end)

	if not status then
		warn(values)

		return false
	else
		return true
	end
end

function OrderedDB:AddToValue(userId: number, valueToAdd: number)
	-- Early exit in studio
	if RunService:IsStudio() then
		return true
	end

	while DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) < 3 do
		task.wait(0.1)
	end

	local status, values = pcall(function()
		return self._connectedDataStore:UpdateAsync(userId, function(oldValue)
			if not oldValue then
				oldValue = 0
			end
			return oldValue + valueToAdd, userId
		end)
	end)

	if not status then
		warn(values)
		return false
	else
		return true
	end
end

function OrderedDB:_tryReconnect(dataStoreName: string)
	task.delay(5, function()
		self._connectedDataStore = self:_connect(dataStoreName)

		if not self._connectedDataStore then
			return self:_tryReconnect(dataStoreName)
		else
			return self._connectedDataStore
		end
	end)
end

function OrderedDB:_connect(dataStoreName: string)
	local status, connection = pcall(function()
		return DataStoreService:GetOrderedDataStore(dataStoreName)
	end)

	if not status then
		warn(connection)
		return
	else
		return connection
	end
end

return OrderedDB
