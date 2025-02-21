local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptsService = game:GetService("ServerScriptService")

-- server/env/terrain.lua
local function createTerrain()

    local Obstacle_Generator = require(ServerScriptsService:WaitForChild("Server"):WaitForChild("services"):WaitForChild("generate_stage"))
    
    Obstacle_Generator.generate_obstacle_course(1234)

    

end

createTerrain()  -- Call the function to generate the environment