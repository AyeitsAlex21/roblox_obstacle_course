local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- server/env/terrain.lua
local function createTerrain()
    -- Ground part
    local ground = Instance.new("Part")
    ground.Size = Vector3.new(500, 1, 500)
    ground.Position = Vector3.new(0, 0, 0)
    ground.Color = Color3.fromRGB(100, 200, 100)
    ground.Anchored = true
    ground.Parent = game.Workspace

    -- A hill part
    local hill = Instance.new("Part")
    hill.Size = Vector3.new(50, 20, 50)
    hill.Position = Vector3.new(100, 10, 100)
    hill.Color = Color3.fromRGB(139, 69, 19)  -- brown
    hill.Anchored = true
    hill.Parent = game.Workspace

    local model = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("assets"):FindFirstChild("Checkpoint")

    print("ok dude")
    model:WaitForChild("Checkpoint Spawn"):WaitForChild("Red Arrow")

    print("ok dude")
    local checkpoint = model:Clone()
    checkpoint.Parent = Workspace
    -- checkpoint.Rotation = Vector3.new(0, 90, 0)
    checkpoint:SetPrimaryPartCFrame(CFrame.new(Vector3.new(10, 5, 0)))

    print("ok dude")
end

createTerrain()  -- Call the function to generate the environment