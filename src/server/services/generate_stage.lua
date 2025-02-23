local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptsService = game:GetService("ServerScriptService")

local assetHelper = require(ServerScriptsService.Server.helpers.assets)

local Obstacle_Course_Generator = {
    ["obstacle_config"] = require(ServerScriptsService.Server.config.obstacle_config),
    ["stage_config"] = require(ServerScriptsService.Server.config.stage_config)
}

local Obstalce_Grid = {
    grid_table = {},
    obstacle_to_grids = {}
}

local GRID_SIZE = Obstacle_Course_Generator.stage_config.grid_size

function Obstalce_Grid.addObstacleToGrid(obstacle, grid_table, obstacle_to_grids)
    local minBound, maxBound = assetHelper.get_bounding_box(obstacle)
    if not minBound or not maxBound then return end

    local grid_min = Vector3.new(
        math.floor(minBound.X / GRID_SIZE),
        math.floor(minBound.Y / GRID_SIZE),
        math.floor(minBound.Z / GRID_SIZE)
    )
    local grid_max = Vector3.new(
        math.floor(maxBound.X / GRID_SIZE),
        math.floor(maxBound.Y / GRID_SIZE),
        math.floor(maxBound.Z / GRID_SIZE)
    )

    local occupied_cells = {}
    for x = grid_min.X, grid_max.X do
        for y = grid_min.Y, grid_max.Y do
            for z = grid_min.Z, grid_max.Z do
                local key = x .. "_" .. y .. "_" .. z
                if not grid_table[key] then grid_table[key] = {} end
                table.insert(grid_table[key], obstacle)
                table.insert(occupied_cells, key)
            end
        end
    end

    obstacle_to_grids[obstacle] = occupied_cells
end

-- Utility: Remove an obstacle from the grid table (for backtracking)
function Obstalce_Grid.removeObstacleFromGrid(obstacle, grid_table, obstacle_to_grids)
    local cells = obstacle_to_grids[obstacle]
    if cells then
        for _, key in ipairs(cells) do
            if grid_table[key] then
                for i = #grid_table[key], 1, -1 do
                    if grid_table[key][i] == obstacle then
                        table.remove(grid_table[key], i)
                    end
                end
                if #grid_table[key] == 0 then
                    grid_table[key] = nil
                end
            end
        end
        obstacle_to_grids[obstacle] = nil
    end
end

function Obstacle_Course_Generator.check_collision_grid(newObstacle, grid_table)
    local newCheckpoint = newObstacle:GetAttribute("checkpoint_num")
    local newMin, newMax = assetHelper.get_bounding_box(newObstacle)
    if not newMin or not newMax then return false end

    local grid_min = Vector3.new(
        math.floor(newMin.X / GRID_SIZE),
        math.floor(newMin.Y / GRID_SIZE),
        math.floor(newMin.Z / GRID_SIZE)
    )
    local grid_max = Vector3.new(
        math.floor(newMax.X / GRID_SIZE),
        math.floor(newMax.Y / GRID_SIZE),
        math.floor(newMax.Z / GRID_SIZE)
    )

    -- Compute the expanded bounding box for newObstacle.
    local newCenter = (newMin + newMax) * 0.5
    local newSize = newMax - newMin

    local MIN_BOUND_SIZE = Vector3.new(10, 20, 10)

    newSize = Vector3.new(
        math.max(newSize.X, MIN_BOUND_SIZE.X),
        math.max(newSize.Y, MIN_BOUND_SIZE.Y),
        math.max(newSize.Z, MIN_BOUND_SIZE.Z)
    )


    local expandedNewHalf = (newSize * 2)
    local expandedNewMin = newCenter - expandedNewHalf
    local expandedNewMax = newCenter + expandedNewHalf

    -- Check in the current grid cells plus a 1-cell margin in all directions
    for x = grid_min.X - 1, grid_max.X + 1 do
        for y = grid_min.Y - 1, grid_max.Y + 1 do
            for z = grid_min.Z - 1, grid_max.Z + 1 do
                local key = x .. "_" .. y .. "_" .. z
                local obstacles_in_cell = grid_table[key]
                if obstacles_in_cell then
                    for _, obstacle in ipairs(obstacles_in_cell) do
                        local otherCheckpoint = obstacle:GetAttribute("checkpoint_num")
                        if otherCheckpoint ~= nil and (newCheckpoint - otherCheckpoint > 2) then
                            local otherMin, otherMax = assetHelper.get_bounding_box(obstacle)
                            if otherMin and otherMax then
                                local otherCenter = (otherMin + otherMax) * 0.5
                                local otherSize = otherMax - otherMin
                                local expandedOtherHalf = (otherSize * 1) * 0.5
                                local expandedOtherMin = otherCenter - expandedOtherHalf
                                local expandedOtherMax = otherCenter + expandedOtherHalf

                                if (expandedNewMin.X <= expandedOtherMax.X and expandedNewMax.X >= expandedOtherMin.X) and
                                   (expandedNewMin.Y <= expandedOtherMax.Y and expandedNewMax.Y >= expandedOtherMin.Y) and
                                   (expandedNewMin.Z <= expandedOtherMax.Z and expandedNewMax.Z >= expandedOtherMin.Z) then
                                    print("Collision detected with obstacle:", obstacle.Name)
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return false
end

-- Modified generate_obstacle_course using grid–based collision detection.
function Obstacle_Course_Generator.generate_obstacle_course(seed)
    math.randomseed(seed)
    
    local obstacleCourseModel = Instance.new("Model")
    obstacleCourseModel.Name = "ObstacleCourse"
    obstacleCourseModel.Parent = workspace
    
    local checkpointsFolder = Instance.new("Folder")
    checkpointsFolder.Name = "Checkpoints"
    checkpointsFolder.Parent = obstacleCourseModel
    
    local obstaclesFolder = Instance.new("Folder")
    obstaclesFolder.Name = "Obstacles"
    obstaclesFolder.Parent = obstacleCourseModel
    
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
    
    -- Create final checkpoint
    local finalCheckpoint = checkpointModel:Clone()
    finalCheckpoint.Parent = checkpointsFolder
    finalCheckpoint:SetAttribute("checkpoint_num", 0)
    obstacleCourseModel.PrimaryPart = finalCheckpoint.PrimaryPart

    -- Set up grid tables:
    local grid_table = {}          -- Maps grid cell keys to a list of obstacles in that cell.
    local obstacle_to_grids = {}   -- Maps each obstacle to the grid cells it occupies.
    
    local function try_place(index, lastObstacle)
        task.wait()

        -- if true done placing obstacles end recursion
        if index > numObstacles then 
            return true 
        end
    
        local newObstacle = nil
        local ParentsFolder = nil
    
        if lastObstacle.Name ~= "Checkpoint" then
            newObstacle = checkpointModel:Clone()
            ParentsFolder = checkpointsFolder
        else
            local curObstacleInd = math.random(1, #obstacleNames)
            local curObstacleName = obstacleNames[curObstacleInd]
            newObstacle = objectFolder:WaitForChild(curObstacleName):Clone()
            ParentsFolder = obstaclesFolder
        end
    
        newObstacle:SetAttribute("checkpoint_num", index)
        local MAX_ATTEMPTS = 5
        -- For non-checkpoint obstacles, we increment index by one after placement.
        local newInd = (newObstacle.Name == "Checkpoint") and index or index + 1
        local origCframe = newObstacle.PrimaryPart.CFrame
        newObstacle.Parent = ParentsFolder
    
        for i = 1, MAX_ATTEMPTS do
            newObstacle:SetPrimaryPartCFrame(origCframe)
            assetHelper.set_part_attribute_in_model(newObstacle, "Anchored", false)
    
            Obstacle_Course_Generator.apply_permutations_to_groups(newObstacle)
            Obstacle_Course_Generator.move_obstacle_to_last_location(lastObstacle, newObstacle, finalCheckpoint.PrimaryPart.Position)
    
            assetHelper.set_part_attribute_in_model(newObstacle, "Anchored", true)
            
            -- Use the grid–based collision check instead of raycasting.
            if Obstacle_Course_Generator.check_collision_grid(newObstacle, grid_table) then
                continue
            end


            -- If valid, add the obstacle to the grid table.
            Obstalce_Grid.addObstacleToGrid(newObstacle, grid_table, obstacle_to_grids)
            
            if try_place(newInd, newObstacle) then
                return true
            end
 
            --if newObstacle.Name == "Checkpoint" then
            --    break
            --end

            -- Backtracking: remove this obstacle from the grid since subsequent placement failed.
            Obstalce_Grid.removeObstacleFromGrid(newObstacle, grid_table, obstacle_to_grids)
        end

        print("Backtracking from obstacle", newObstacle.Name)
        newObstacle:Destroy()
        return false
    end
    
    if not try_place(1, finalCheckpoint) then
        obstacleCourseModel:Destroy()
        error("Failed to generate obstacle course with backtracking")
        return nil
    end
    
    return obstacleCourseModel
end

-- Revised placement function with improved physics update and logging.

function Obstacle_Course_Generator.move_obstacle_to_last_location(lastObjectModel, newObstacle, biasLocation)
    --[[ 
    Moves the new obstacle in front of the last one maintaining a persistent direction
    except we also apply a permutation rotation
    --]]

    -- Set obstacle to beginning
    newObstacle:SetPrimaryPartCFrame(CFrame.new())

    --print(lastObjectModel, newObstacle)

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
        permuationSizeVector = Obstacle_Course_Generator.get_model_permuation_matrices(newObstacle, biasLocation, lastObjectModel.PrimaryPart.Position)

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

end

function Obstacle_Course_Generator.get_model_permuation_matrices(ObstacleModel, biasLocation, lastPosition)
    --[[ 
    (model, Vector3?) -> (CFrame, CFrame, Vector3)

    Uses the obstacle_config to get matrices to permute the whole obstacle model.
    If biasLocation is provided and the obstacle is over 1000 units away in X,Z,
    the Y rotation is nudged towards that point within allowed rotation bounds.
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

    -- Position Calculation
    local xPos, yPos, zPos = 0, 0, 0
    if obstacleConfig.position then
        xPos = (obstacleConfig.position.x[1] == obstacleConfig.position.x[2]) and 0 or math.random(obstacleConfig.position.x[1], obstacleConfig.position.x[2])
        yPos = (obstacleConfig.position.y[1] == obstacleConfig.position.y[2]) and 0 or math.random(obstacleConfig.position.y[1], obstacleConfig.position.y[2])
        zPos = (obstacleConfig.position.z[1] == obstacleConfig.position.z[2]) and 0 or math.random(obstacleConfig.position.z[1], obstacleConfig.position.z[2])
    end

    positionCframe = CFrame.new(xPos, yPos, zPos)

    -- Rotation Calculation
    local xRot, yRot, zRot = 0, 0, 0
    if obstacleConfig.orientation then
        xRot = obstacleConfig.orientation.x and math.rad(math.random(obstacleConfig.orientation.x[1], obstacleConfig.orientation.x[2])) or 0
        yRot = obstacleConfig.orientation.y and math.rad(math.random(obstacleConfig.orientation.y[1], obstacleConfig.orientation.y[2])) or 0
        zRot = obstacleConfig.orientation.z and math.rad(math.random(obstacleConfig.orientation.z[1], obstacleConfig.orientation.z[2])) or 0
    end

    if biasLocation and obstacleConfig.orientation and obstacleConfig.orientation.y then
        local distanceXZ = (Vector3.new(lastPosition.x, 0, lastPosition.z) - Vector3.new(biasLocation.X, 0, biasLocation.Z)).Magnitude
        if distanceXZ > 1000 then
            local minYRot = math.rad(obstacleConfig.orientation.y[1])
            local maxYRot = math.rad(obstacleConfig.orientation.y[2])

            local directionToBias = (Vector3.new(biasLocation.X, 0, biasLocation.Z) - Vector3.new(xPos, 0, zPos)).Unit
            local targetYRot = math.atan2(directionToBias.X, directionToBias.Z) -- Desired facing angle

            -- Blend rotation towards target while staying within limits
            local blendFactor = 0.5 -- Adjust this to control how strongly it shifts (0 = no change, 1 = full change)
            local adjustedYRot = yRot + blendFactor * (targetYRot - yRot)

            -- Clamp to allowed rotation range
            yRot = math.clamp(adjustedYRot, minYRot, maxYRot)
        end
    end

    rotationCframe = CFrame.Angles(xRot, yRot, zRot)

    -- Size Calculation
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