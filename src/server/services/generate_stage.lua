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

    local lastSize = (lastFrontPart.Position - lastBackPart.Position)
    local newSize = (newFrontPart.Position - lastBackPart.Position)


    local angle, rotX, rotY, rotZ = Obstacle_Course_Generator.get_euler_angles(lastSize, newSize)


     -- get direction of last object to spawn object in front of last one
    local lastDirection = lastSize.unit

    -- get the new position by moving the new obstacle just in front of the last one 
    local newPosition = lastFrontPart.Position + lastDirection * newSize.Magnitude

    -- move new obstacle in front of old one
    newObstacle:SetPrimaryPartCFrame(
        CFrame.new(newPosition) * CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))
    )
    newObstacle.Parent = workspace

    -- Print debug information
    print("Last obstacle front part position:", lastFrontPart.Position)
    print("New obstacle front part position:", newFrontPart.Position)
    print("Calculated new position:", newPosition)
end

function Obstacle_Course_Generator.get_euler_angles(v1, v2)

    -- Normalize vectors
    local mag1 = v1.Magnitude
    local mag2 = v2.Magnitude
    local v1Norm = v1 / mag1
    local v2Norm = v2 / mag2

    -- Compute dot product (angle)
    local dot = v1Norm:Dot(v2Norm)
    local angleRad = math.acos(math.clamp(dot, -1, 1)) -- Clamp to avoid NaN
    local angleDeg = math.deg(angleRad)

    -- Compute cross product (rotation axis)
    local axis = v1:Cross(v2)
    local axisNorm = axis.Unit -- Normalize the axis

    -- Convert axis to Euler angles (approximate method)
    local rotX = math.deg(math.atan2(axisNorm.Y, axisNorm.Z)) -- Rotation around X-axis
    local rotY = math.deg(math.atan2(axisNorm.Z, axisNorm.X)) -- Rotation around Y-axis
    local rotZ = math.deg(math.atan2(axisNorm.X, axisNorm.Y)) -- Rotation around Z-axis

    return angleDeg, rotX, rotY, rotZ
    
end

return Obstacle_Course_Generator