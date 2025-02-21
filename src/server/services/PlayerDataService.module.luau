-- to detect when a player joins
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- tables
-- Local table can only be shared with functions in this script
local Local = {}
-- Shared table can be shared with other scripts
local Shared = {}

-- Lookup table for storing each players time instance
local playerTimers = {}

-- Onstart function can be used by other scripts
function Shared.OnStart()
    -- to detect when a player joins connects leaderstats function to playeradded event
    Players.PlayerAdded:Connect(Local.CreateLeaderstats)

    -- when the player leaves, remove them from the lookup table
    Players.PlayerRemoving:Connect(function(player)
        playerTimers[player] = nil
    end)
    -- account for players that are somehow loaded into the game before the script runs
    -- iterate through all the players that are currently in the game
    for _, player in Players:GetPlayers() do
        Local.CreateLeaderstats(player)
    end

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
end

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