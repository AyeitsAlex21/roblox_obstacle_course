
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptsService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local PlayerDataService = require(ServerScriptsService.Server.services["PlayerDataService.module"])


Players.PlayerAdded:Connect(function(player)
    task.wait(2)  -- wait until the profile and leaderstats are set up
    print("Testing UpdateTime for", player.Name)
    PlayerDataService.Update(player, { type = "UpdateTime", amount = 10 })
    
    task.wait(2)
    print("Testing UpdateDeaths for", player.Name)
    PlayerDataService.Update(player, { type = "UpdateDeaths", amount = 1 })
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			-- Increment the player's death count by 1 when they die
			PlayerDataService.Update(player, { type = "UpdateDeaths", amount = 1 })
		end)
	end)
end)
