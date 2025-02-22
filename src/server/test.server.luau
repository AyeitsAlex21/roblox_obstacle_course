local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptsService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local DataService = require(ServerScriptsService.Server.services["PlayerDataService.module"])

while true do
    for _, player in Players:GetChildren() do
        DataService.UpdateDeaths(player, 100)
    end
    task.wait(1)
end