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
        if key ~= "Checkpoint" then
            table.insert(obstacleNames, key)
        end
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

        assetHelper.set_part_attribute_in_model(curCheckpoint, "Anchored", false)
        Obstacle_Course_Generator.move_obstacle_to_last_location(lastObstacle, curCheckpoint)
        assetHelper.set_part_attribute_in_model(curCheckpoint, "Anchored", true)

        lastObstacle = curCheckpoint
        
        -- Generate the current obstacle
        local curObstacleInd = math.random(1, #obstacleNames)  -- Corrected the index here
        local curObstacleName = obstacleNames[curObstacleInd]
        local curObstacleModel = objectFolder:WaitForChild(curObstacleName):Clone()

        
        Obstacle_Course_Generator.move_obstacle_to_last_location(lastObstacle, curObstacleModel)
        Obstacle_Course_Generator.apply_permutations_to_groups(curObstacleModel)
        -- Move the new obstacle in front of the last one

        -- Set the position of the new obstacle based on the last obstacle's location
        curObstacleModel.Parent = workspace

        -- Update lastObstacle to the current obstacle
        lastObstacle = curObstacleModel
        
    
    end

    return nil
end

function Obstacle_Course_Generator.move_obstacle_to_last_location(lastObjectModel, newObstacle)
    --[[ 
    Moves the new obstacle in front of the last one maintaining a persistent direction
    except we also apply a permutation rotation
    --]]

    -- Set obstacle to beginning
    newObstacle:SetPrimaryPartCFrame(CFrame.new())

    local lastFrontPart = assetHelper.find_part(lastObjectModel, "Front")
    local lastBackPart = assetHelper.find_part(lastObjectModel, "Back")
    local newFrontPart = assetHelper.find_part(newObstacle, "Front")
    local newBackPart = assetHelper.find_part(newObstacle, "Back")

    -- get directions
    local newDirection = (newFrontPart.Position - newBackPart.Position).unit
    local lastDirection = (lastFrontPart.Position - lastBackPart.Position)
    lastDirection = Vector3.new(lastDirection.X, 0, lastDirection.Z).unit

    -- get size of new object
    local newSize = (newFrontPart.Position - newBackPart.Position).Magnitude / 2

    local offset = newBackPart.Position - newObstacle.PrimaryPart.Position

    -- Compute new position in front of the last obstacle
    local newPosition = lastFrontPart.Position + (7 + offset.Magnitude) * lastDirection

    -- Get CFrame to rotate NewDirection into lastDirection
    local rotationFromOriginalCframe = CFrame.fromRotationBetweenVectors(newDirection, lastDirection)

    local permuationPositionCframe, 
        permuationOrientationCframe, 
        permuationSizeVector = Obstacle_Course_Generator.get_model_permuation_matrices(newObstacle)

    -- Combine the rotations and position
    -- POSITION
    local newObjectCFrame = 
        CFrame.new()
        * CFrame.new(newPosition) -- Move to new position
        * permuationPositionCframe

    -- ROTATIONS
    -- Apply the alignment rotation first to avoid gimbal lock
    newObjectCFrame *= rotationFromOriginalCframe 

    -- Apply permutation rotation correctly in object space
    newObjectCFrame *= newObjectCFrame:ToWorldSpace(permuationOrientationCframe):ToObjectSpace(newObjectCFrame)

    -- Set the final CFrame
    newObstacle:SetPrimaryPartCFrame(newObjectCFrame)


    -- apply scaling to all parts in the obstacle
    for _, part in pairs(newObstacle:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = part.Size * permuationSizeVector
        end
    end

    -- Parent it to workspace
    newObstacle.Parent = workspace
end

function Obstacle_Course_Generator.get_model_permuation_matrices(ObstacleModel)
    --[[
    (model) -> (Cframe, Cframe, Vector)

    Uses the obstacle_config to get matrices to permuate the whole obstacle model
    --]]
    if typeof(ObstacleModel) ~= "Instance" or not ObstacleModel:IsA("Model") then
        error("Expected 'model' to be a Model instance, got " .. typeof(ObstacleModel))
    end

    local positionCframe = CFrame.new()
    local rotationCframe = CFrame.new()
    local sizeVector = Vector3.new(1, 1, 1)

    local ObstacleConfigTable = Obstacle_Course_Generator.obstacle_config
    local ObstacleName = ObstacleModel.Name

    local obstacleConfig = ObstacleConfigTable[ObstacleName]

    if not obstacleConfig then
        error(string.format("'%s' is not found in obstacle_course Config", ObstacleName))
    end

    if obstacleConfig.position then
        local xPos = (obstacleConfig.position.x[1] == obstacleConfig.position.x[2]) and 0 or math.random(obstacleConfig.position.x[1], obstacleConfig.position.x[2])
        local yPos = (obstacleConfig.position.y[1] == obstacleConfig.position.y[2]) and 0 or math.random(obstacleConfig.position.y[1], obstacleConfig.position.y[2])
        local zPos = (obstacleConfig.position.z[1] == obstacleConfig.position.z[2]) and 0 or math.random(obstacleConfig.position.z[1], obstacleConfig.position.z[2])
        positionCframe = CFrame.new(xPos, yPos, zPos)
    end

    if obstacleConfig.orientation then
        local xRot = obstacleConfig.orientation.x and math.rad(math.random(obstacleConfig.orientation.x[1], obstacleConfig.orientation.x[2])) or 0
        local yRot = obstacleConfig.orientation.y and math.rad(math.random(obstacleConfig.orientation.y[1], obstacleConfig.orientation.y[2])) or 0
        local zRot = obstacleConfig.orientation.z and math.rad(math.random(obstacleConfig.orientation.z[1], obstacleConfig.orientation.z[2])) or 0
        rotationCframe = CFrame.Angles(xRot, yRot, zRot)
    end

    if obstacleConfig.size then
        local xSize = (obstacleConfig.size.x[1] == obstacleConfig.size.x[2]) and 1 or math.random(obstacleConfig.size.x[1], obstacleConfig.size.x[2])
        local ySize = (obstacleConfig.size.y[1] == obstacleConfig.size.y[2]) and 1 or math.random(obstacleConfig.size.y[1], obstacleConfig.size.y[2])
        local zSize = (obstacleConfig.size.z[1] == obstacleConfig.size.z[2]) and 1 or math.random(obstacleConfig.size.z[1], obstacleConfig.size.z[2])
        sizeVector = Vector3.new(xSize, ySize, zSize)
    end

    return positionCframe, rotationCframe, sizeVector
    
end

function Obstacle_Course_Generator.apply_permutations_to_groups(ObstacleModel)
    --[[
    (Model) -> None

    This function uses the obstacle_config file permutate the model groups
    inside the model given
    --]]
    if typeof(ObstacleModel) ~= "Instance" or not ObstacleModel:IsA("Model") then
        error("Expected 'model' to be a Model instance, got " .. typeof(ObstacleModel))
    end
    

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

        -- if ground model not found skip
        if group_model then
            -- apply random position shift if specified in group_data
            local positionOffset = Vector3.new(0, 0, 0)
            if group_data.position then
                local xPos = (group_data.position.x[1] == group_data.position.x[2]) and 0 or math.random(group_data.position.x[1], group_data.position.x[2])
                local yPos = (group_data.position.y[1] == group_data.position.y[2]) and 0 or math.random(group_data.position.y[1], group_data.position.y[2])
                local zPos = (group_data.position.z[1] == group_data.position.z[2]) and 0 or math.random(group_data.position.z[1], group_data.position.z[2])
                positionOffset = Vector3.new(xPos, yPos, zPos)
            end

            -- apply random rotation if specified in group_data
            local rotationOffset = CFrame.Angles(0, 0, 0)
            if group_data.orientation then
                local xRot = group_data.orientation.x and math.rad(math.random(group_data.orientation.x[1], group_data.orientation.x[2])) or 0
                local yRot = group_data.orientation.y and math.rad(math.random(group_data.orientation.y[1], group_data.orientation.y[2])) or 0
                local zRot = group_data.orientation.z and math.rad(math.random(group_data.orientation.z[1], group_data.orientation.z[2])) or 0
                rotationOffset = CFrame.Angles(xRot, yRot, zRot)
            end

            -- apply random scaling if specified in group_data
            local scaleFactor = Vector3.new(1, 1, 1)
            if group_data.size then
                local xSize = (group_data.size.x[1] == group_data.size.x[2]) and 1 or math.random(group_data.size.x[1], group_data.size.x[2])
                local ySize = (group_data.size.y[1] == group_data.size.y[2]) and 1 or math.random(group_data.size.y[1], group_data.size.y[2])
                local zSize = (group_data.size.z[1] == group_data.size.z[2]) and 1 or math.random(group_data.size.z[1], group_data.size.z[2])
                scaleFactor = Vector3.new(xSize, ySize, zSize)
            end

            -- Apply the permutations to each part
            for _, part in pairs(group_model:GetDescendants()) do
                if part:IsA("BasePart") then
                     -- apply the scaling
                     part.Size = part.Size * scaleFactor

                     -- apply position then rotation to the parts CFrame
                     part.CFrame = part.CFrame * CFrame.new(positionOffset) * rotationOffset

                end
            end
        end
    end

    return nil
end

return Obstacle_Course_Generator