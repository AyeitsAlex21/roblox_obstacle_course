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

    local model = ReplicatedStorage:FindFirstChild("assets"):FindFirstChild("Checkpoint")
    
    print("ok dude")
    local checkpoint = model:Clone()

    checkpoint:WaitForChild("Checkpoint Spawn"):WaitForChild("Arrow"):WaitForChild("Part")

    checkpoint.Parent = Workspace
    -- checkpoint.Rotation = Vector3.new(0, 90, 0)
    checkpoint:SetPrimaryPartCFrame(CFrame.new(Vector3.new(10, 5, 0)))

    print("ok dude")
    ------------------------------------------

    print(ServerScriptsService:WaitForChild("Server"))
    print(ServerScriptsService:WaitForChild("Server"):WaitForChild("services"))
    print(ServerScriptsService:WaitForChild("Server"):WaitForChild("services"):WaitForChild("generate_stage"))
    local Obstacle_Generator = require(ServerScriptsService:WaitForChild("Server"):WaitForChild("services"):WaitForChild("generate_stage"))

    print(Obstacle_Generator)
    Obstacle_Generator.generate_obstacle_course(123)

    

end

createTerrain()  -- Call the function to generate the environment