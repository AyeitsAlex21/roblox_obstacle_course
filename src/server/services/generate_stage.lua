local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptsService = game:GetService("ServerScriptService")

local assetHelper = require(ServerScriptsService:WaitForChild("Server"):WaitForChild("helpers"):WaitForChild("assets"))

local Obstacle_Course_Generator = {
    ["obstacle_config"] = require(ServerStorage:WaitForChild("config"):WaitForChild("obstacle_config")),
    ["stage_config"] = require(ServerStorage:WaitForChild("config"):WaitForChild("stage_config"))
}

function Obstacle_Course_Generator.generate_obstacle_course(seed)
    --[[
    (seed: str) -> model

    This function generates an obstacle course with random properties based on the seed
    given if there is no seed given will use the current date
    --]]
    
    -- set the seed so the course is generated the same way
    math.randomseed(seed)

    local obstacleNames = {}
    for key, _ in pairs(Obstacle_Course_Generator.obstacle_config) do
        table.insert(obstacleNames, key)
    end

    local assetsFolder = ReplicatedStorage:WaitForChild("assets")
    local objectFolder = assetsFolder:WaitForChild("obstacles")

    local checkpointModel = assetsFolder:WaitForChild("Checkpoint")


    local numObstacles = math.random(
        Obstacle_Course_Generator.stage_config.number_of_obstacles[1], 
        Obstacle_Course_Generator.stage_config.number_of_obstacles[2]
    )

    local lastObstacle = checkpointModel:Clone()
    lastObstacle.Parent = workspace



    for i = 1, numObstacles do
        local curCheckpoint = checkpointModel:Clone()

        Obstacle_Course_Generator.move_obstacle_to_last_location(lastObstacle, curCheckpoint)

        lastObstacle = curCheckpoint

        --[[

        -- Generate the current obstacle
        local curObstacleInd = math.random(1, #obstacleNames)  -- Corrected the index here
        local curObstacleName = obstacleNames[curObstacleInd]
        local curObstacleModel = objectFolder:WaitForChild(curObstacleName):Clone()

        -- Move the new obstacle in front of the last one
        Obstacle_Course_Generator.move_obstacle_to_last_location(lastObstacle, curObstacleModel)

        -- Set the position of the new obstacle based on the last obstacle's location
        curObstacleModel.Parent = workspace

        -- Update lastObstacle to the current obstacle
        lastObstacle = curObstacleModel

        --]]

    
    end

    return nil
end

function Obstacle_Course_Generator.move_obstacle_to_last_location(lastObjectModel, newObstacle)
    --[[ 
    (Model, str) -> Model

    Generates the object using the object name then puts it in front of the lastObjectModel
    by placing it in front of the last object
    --]]

    local lastFrontPart = assetHelper.find_part(lastObjectModel, "Front")
    local lastBackPart = assetHelper.find_part(lastObjectModel, "Back")

    local newFrontPart = assetHelper.find_part(newObstacle, "Front")
    local newBackPart = assetHelper.find_part(newObstacle, "Back")

    local direction = (lastFrontPart.Position - lastBackPart.Position).unit  -- Unit vector pointing in the direction from back to front

    -- Calculate the distance between the back and front of the new obstacle
    local newObstacleSize = newBackPart.Position - newObstacle.PrimaryPart.Position

    -- Calculate the new position by moving the new obstacle just in front of the last one
    local newPosition = lastFrontPart.Position + direction * newObstacleSize.Magnitude

    -- Move the new obstacle to the calculated position
    newObstacle:SetPrimaryPartCFrame(CFrame.new(newPosition))

    newObstacle.Parent = workspace

    -- Print debug information
    print("Last obstacle front part position:", lastFrontPart.Position)
    print("New obstacle front part position:", newFrontPart.Position)
    print("Calculated new position:", newPosition)
end

return Obstacle_Course_Generator