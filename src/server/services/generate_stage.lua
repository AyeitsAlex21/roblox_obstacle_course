local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptsService = game:GetService("ServerScriptService")

local assetHelper = require(ServerScriptsService.Server.helpers.assets)

local Obstacle_Course_Generator = {
    ["obstacle_config"] = require(ServerScriptsService.Server.config.obstacle_config),
    ["stage_config"] = require(ServerScriptsService.Server.config.stage_config)
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
        curCheckpoint.Parent = workspace

        assetHelper.set_anchored(curCheckpoint, false)
        Obstacle_Course_Generator.move_obstacle_to_last_location(lastObstacle, curCheckpoint)
        assetHelper.set_anchored(curCheckpoint, true)

        lastObstacle = curCheckpoint

        
        
        -- Generate the current obstacle
        local curObstacleInd = math.random(1, #obstacleNames)  -- Corrected the index here
        local curObstacleName = obstacleNames[curObstacleInd]
        local curObstacleModel = objectFolder:WaitForChild(curObstacleName):Clone()

        Obstacle_Course_Generator.apply_permutations_to_groups(curObstacleModel)
        -- Move the new obstacle in front of the last one
        Obstacle_Course_Generator.move_obstacle_to_last_location(lastObstacle, curObstacleModel)

        -- Set the position of the new obstacle based on the last obstacle's location
        curObstacleModel.Parent = workspace

        -- Update lastObstacle to the current obstacle
        lastObstacle = curObstacleModel
        
    
    end

    return nil
end

function Obstacle_Course_Generator.move_obstacle_to_last_location(lastObjectModel, newObstacle)
    --[[ 
    Moves the new obstacle in front of the last one while maintaining rotation.
    Adds a 15-degree clockwise rotation to the new obstacle, relative to its local axes.
    --]]

    -- Set obstacle to beginning
    newObstacle:SetPrimaryPartCFrame(CFrame.new())

    local lastFrontPart = assetHelper.find_part(lastObjectModel, "Front")
    local lastBackPart = assetHelper.find_part(lastObjectModel, "Back")
    local newFrontPart = assetHelper.find_part(newObstacle, "Front")
    local newBackPart = assetHelper.find_part(newObstacle, "Back")

    -- Get size and direction
    local lastDirection = (lastFrontPart.Position - lastBackPart.Position).unit
    local newDirection = (newFrontPart.Position - newBackPart.Position).unit

    local newSize = (newFrontPart.Position - newBackPart.Position).Magnitude / 2

    -- Compute new position in front of the last obstacle
    local newPosition = lastFrontPart.Position + newSize * lastDirection

    

    -- Get CFrame to rotate NewDirection into lastDirection
    local rotationCframe = CFrame.fromRotationBetweenVectors(newDirection, lastDirection)

    -- Add a 15-degree clockwise rotation around the Y-axis (local axes)
    local additionalRotation = CFrame.Angles(0, 0, 0) -- Negative for clockwise

    if math.random(0, 100) > 60
    then
        additionalRotation = CFrame.Angles(0, math.rad(-45), 0)
    end

    -- Combine the rotations and position
    local newObjectCFrame = 
        -- POSISTION
        CFrame.new() -- Create a neutral frame at 0,0,0 and neutral rotation
        * CFrame.new(newPosition) -- Move to new position

        -- ROTATIONS
        -- do additional roation first to avoid gimble lock
        * additionalRotation
        * rotationCframe

    -- Set the final CFrame
    newObstacle:SetPrimaryPartCFrame(newObjectCFrame)

    -- Parent it to workspace
    newObstacle.Parent = workspace
end


function Obstacle_Course_Generator.apply_permutations_to_groups(ObstacleModel)
    local ObstacleConfigTable = Obstacle_Course_Generator.obstacle_config
    local ObstacleName = ObstacleModel.Name

    -- If there are no groups, then we are done
    if not ObstacleConfigTable[ObstacleName] or not ObstacleConfigTable[ObstacleName].groups then
        return nil
    end

    local groups = ObstacleConfigTable[ObstacleName].groups

    -- Loop through each group in the configuration
    for group_name, group_data in pairs(groups) do
        local group_model = assetHelper.find_model(ObstacleModel, group_name)

        -- Make sure we found the group model
        if group_model then
            -- Apply random position shift if specified in group_data
            local positionOffset = Vector3.new(0, 0, 0)
            if group_data.position then
                local xPos = (group_data.position.x[1] == group_data.position.x[2]) and 0 or math.random(group_data.position.x[1], group_data.position.x[2])
                local yPos = (group_data.position.y[1] == group_data.position.y[2]) and 0 or math.random(group_data.position.y[1], group_data.position.y[2])
                local zPos = (group_data.position.z[1] == group_data.position.z[2]) and 0 or math.random(group_data.position.z[1], group_data.position.z[2])
                positionOffset = Vector3.new(xPos, yPos, zPos)
            end

            -- Apply random rotation (orientation) if specified in group_data
            local rotationOffset = CFrame.Angles(0, 0, 0)
            if group_data.orientation then
                local xRot = group_data.orientation.x and math.rad(math.random(group_data.orientation.x[1], group_data.orientation.x[2])) or 0
                local yRot = group_data.orientation.y and math.rad(math.random(group_data.orientation.y[1], group_data.orientation.y[2])) or 0
                local zRot = group_data.orientation.z and math.rad(math.random(group_data.orientation.z[1], group_data.orientation.z[2])) or 0
                rotationOffset = CFrame.Angles(xRot, yRot, zRot)
            end

            -- Apply random scaling if specified in group_data
            local scaleFactor = Vector3.new(1, 1, 1)
            if group_data.size then
                local xSize = (group_data.size.x[1] == group_data.size.x[2]) and 1 or math.random(group_data.size.x[1], group_data.size.x[2])
                local ySize = (group_data.size.y[1] == group_data.size.y[2]) and 1 or math.random(group_data.size.y[1], group_data.size.y[2])
                local zSize = (group_data.size.z[1] == group_data.size.z[2]) and 1 or math.random(group_data.size.z[1], group_data.size.z[2])
                scaleFactor = Vector3.new(xSize, ySize, zSize)
            end

            -- Apply transformations to each part in the group
            for _, part in pairs(group_model:GetChildren()) do
                if part:IsA("BasePart") then
                    -- Apply scaling to the part's size
                    part.Size = part.Size * scaleFactor

                    -- Apply position and rotation to the part's CFrame
                    part.CFrame = part.CFrame * CFrame.new(positionOffset) * rotationOffset
                end
            end
        end
    end

    return nil
end


return Obstacle_Course_Generator