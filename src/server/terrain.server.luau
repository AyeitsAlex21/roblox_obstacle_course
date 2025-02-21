local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptsService = game:GetService("ServerScriptService")



-- server/env/terrain.lua
local function createTerrain()
    -- A hill part
    local hill = Instance.new("Part")
    hill.Size = Vector3.new(50, 20, 50)
    hill.Position = Vector3.new(100, 10, 100)
    hill.Color = Color3.fromRGB(139, 69, 19)  -- brown
    hill.Anchored = true
    hill.Parent = game.Workspace

    --local Obstacle_Generator = require(ServerScriptsService:WaitForChild("Server"):WaitForChild("services"):WaitForChild("generate_stage"))
    local PlayerDataService = require(ServerScriptsService.Server.services["PlayerDataService.module"])
    PlayerDataService.OnStart()
    
    --Obstacle_Generator.generate_obstacle_course(123)

    

end

createTerrain()  -- Call the function to generate the environment