-- to detect when a player joins
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

--export type UpdateStateAction = UpdateState.UpdateStateAction

-- ProfileService library makes securely manager the players data simple and reliable
local DataTemplate = require(ServerScriptService.Server.services.PlayerData)
local ProfileStore = require(ServerScriptService.Server.Libs["ProfileStore"])
local UpdateState = require(ReplicatedStorage.Functions)

local DATASTORE_NAME = "Production" -- DO NOT MODIFY

--[[
the ONLY time we change the datastore name is when we are working inside roblox studio
If the script is ran in roblox studio, then use the datastore testing
--]]
if RunService:IsStudio() then
	DATASTORE_NAME = "Testing"
	print("DATASTORE IN USE: Testing")
else
	print("DATASTORE IN USE: Prod")
end

-- profilestore easy to use datastorage
local PlayerStore = ProfileStore.New(DATASTORE_NAME, DataTemplate.DEFAULT_PLAYER_DATA)

-- create a variable to hold all the players profiles
local Profiles: {[Player]: typeof(PlayerStore:StartSessionAsync())} = {}


-- tables
-- Local table can only be shared with functions in this script
local Local = {}
-- Shared table can be shared with other scripts
local Shared = {}
-- Lookup table for storing each players time instance
local playerTimers = {}

Shared.ProfileLoaded = Instance.new("BindableEvent")

-- Onstart function can be used by other scripts
function Shared.OnStart()

    -- when the player leaves, remove them from the lookup table
    Players.PlayerRemoving:Connect(function(player)
        playerTimers[player] = nil
    end)
    -- account for players that are somehow loaded into the game before the script runs
    -- iterate through all the players that are currently in the game
    for _, player in Players:GetPlayers() do
        task.spawn(Local.CreateProfile, player)
    end

	-- to detect when a player joins connects leaderstats function to playeradded event
	Players.PlayerAdded:Connect(Local.CreateProfile)
	Players.PlayerRemoving:Connect(Local.RemoveProfile)

	-- Shared timer loop that updates every second.
	task.spawn(function()
		while true do
			task.wait(1) -- Update interval: 1 second
			for player, timer in pairs(playerTimers) do
				if player.Parent then -- check if player is still in the game
					timer.Value = timer.Value + 1 -- increment timer by 1 second
				else
					playerTimers[player] = nil -- clean up if player is no longer present
				end
			end
		end
	end)
end

function Local.RemoveProfile(player: Player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end

function Shared.GetData(player:Player): DataTemplate.PlayerData?
	local profile = Profiles[player]
	if not profile then return end
	return profile.Data
end

--update
--[[
function Shared.UpdateDeaths(player: Player, amount: number)
	local data = Shared.GetData(player)
	if not data then return end
	local deaths = data.deaths
	print(`Player had {deaths} deaths`)
	data.deaths += amount
	local newDeaths = data.deaths
	print(`Player now has {newDeaths} deaths`)
	print(Shared.GetData(player))
end

]]--

function Shared.Update(player: Player, action: UpdateState.UpdateDataAction)
	local profile = Profiles[player]
	if not profile then
		return
	end

	if action.type == "UpdateTime" then
		player.leaderstats.timer.Value += action.amount
		print("TIME IS BEING UPDATED!!")
	elseif action.type == "UpdateDeaths" then
		player.leaderstats.deaths.Value += action.amount
		print("DEATH IS BEING UPDATED!!")
	end
	UpdateState(profile.Data, action)
end


-- change stage to timer
function Local.CreateLeaderstats(player: Player)
	-- Create a leaderstats folder and parent it to the player.
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"
	print("leaderstats created for", player.Name)

	-- Create a timer value that starts at 0.
	local timer = Instance.new("NumberValue")
	timer.Name = "timer"
	timer.Value = 0 -- start timer at 0 seconds
	timer.Parent = leaderstats
	print("timer created for", player.Name)
	-- Add this player's timer to our lookup table.
	playerTimers[player] = timer

	-- Create a deaths value that starts at 0.
	local deaths = Instance.new("NumberValue")
	deaths.Name = "deaths"
	deaths.Value = 0
	deaths.Parent = leaderstats
	print("deaths created for", player.Name)

	-- Create a deaths value that starts at 0.
	local CheckPoints = Instance.new("NumberValue")
	CheckPoints.Name = "Checkpoints"
	CheckPoints.Value = 0
	CheckPoints.Parent = leaderstats
	print("CheckPoints created for", player.Name)
end

function Local.CreateProfile(player: Player)
	local userId = player.UserId
	local profileKey = `{userId}_Data`
	-- get the players profile from the profilestore
	local profile = PlayerStore:StartSessionAsync(profileKey)
	-- make sure if we do actually have access to the players profile
	if not profile then
		player:Kick("Unable to load your player data.")
		return
	end
	-- cleanup method when the player leaves our game. Release removes the session lock from the profile 
	-- and the data will immediately be saved for the last time
	-- remove the players profile from the profile table and kick them
	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil
		player:Kick("Profile session ended. Please rejoin")
	end)

	local isInGame = player.Parent == Players
	if isInGame then
		Profiles[player] = profile
	else
		profile:EndSession()
	end

	--associate a players UserID with their profile
	profile:AddUserId(player.UserId)
	--whenever we make changes to the playerdata template, reconcile will fill in all missing variables
	profile:Reconcile()

	Profiles[player] = profile
	Local.CreateLeaderstats(player)

	Shared.ProfileLoaded:Fire(player)
end

local function printPlayerData(player)
    local data = Shared.GetData(player)
    if data then
        print("Data for", player.Name, ":", data)
    else
        print("No data found for", player.Name)
    end
end

Players.PlayerAdded:Connect(function(player)
    task.wait(5)  -- Give time for the profile and leaderstats to be set up
    printPlayerData(player)
end)

--[[
local RunService = game:GetService("RunService")
local frameCount = 0
local elapsedTime = 0

RunService.Heartbeat:Connect(function(deltaTime)
	frameCount = frameCount + 1
	elapsedTime = elapsedTime + deltaTime

	if elapsedTime >= 1 then
		print("Server FPS (approx):", frameCount)
		frameCount = 0
		elapsedTime = 0
	end
end)--]]
return Shared