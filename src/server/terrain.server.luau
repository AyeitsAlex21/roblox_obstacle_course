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
end

createTerrain()  -- Call the function to generate the environment