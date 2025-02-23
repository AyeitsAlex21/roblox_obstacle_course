--dont worry about this script

local Players = game:GetService("Players")
local ServerScriptsService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local PlayerDataService = require(ServerScriptsService.Server.services["PlayerDataService.module"])

local Local = {}
local Shared = {}

function Shared.OnStart()
    PlayerDataService.ProfileLoaded.Event:Connect(function(player: Player)
		Shared.RespawnPlayer(player)
		player.CharacterAdded:Connect(function()
			Shared.RespawnPlayer(player)
		end)
    end)

    for _, player in Players:GetPlayers() do
        Shared.RespawnPlayer(player)
        player.CharacterAdded:Connect(function()
            Shared.RespawnPlayer(player)
        end)
    end
end

function Shared.RespawnPlayer(player: Player)
    local playerState = PlayerDataService.GetState(player)
    if not playerState then return end

    local stage = playerState.stage
    local spawnLocation = Workspace.Stages[stage].SpawnLocation
    if not spawnLocation then return end
    
    player:RequestStreamAroundAsync(spawnLocation.Position)

    local character = player.Character
    if character then
        character:PivotTo(spawnLocation.CFrame)
    end

end

return Shared