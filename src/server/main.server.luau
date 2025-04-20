local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptsService = game:GetService("ServerScriptService")

-- server/env/terrain.lua
local function createTerrain()

    local Obstacle_Generator = require(ServerScriptsService:WaitForChild("Server"):WaitForChild("services"):WaitForChild("generate_stage"))
    

    local ObGenObj = Obstacle_Generator.new()
    local stageModel = ObGenObj:generate_obstacle_course(3, 100)
    --stageModel.Parent = workspace

end

local RunService = game:GetService("RunService")
local frameCount = 0
local elapsedTime = 0
--[[
RunService.Heartbeat:Connect(function(deltaTime)
    frameCount = frameCount + 1
    elapsedTime = elapsedTime + deltaTime

    if elapsedTime >= 1 then
        print("Server FPS (approx):", frameCount)
        frameCount = 0
        elapsedTime = 0
    end
end)
--]]
createTerrain()  -- Call the function to generate the environment