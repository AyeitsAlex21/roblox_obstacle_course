local assetHelper = {}

function assetHelper.find_part(model, name)
    --[[
    (model: Model, name: str) -> Part

    This function returns the part within the model with the name
    that matches the name parameter
    --]]

    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        error("Expected 'model' to be a Model instance, got " .. typeof(model))
    end

    for _, descendant in pairs(model:GetDescendants()) do

        if descendant:IsA("Part") and descendant.Name == name then
            return descendant
        end
    end

    error(string.format("In assetHelper.find_part Part with the name '%s' not found in model '%s'",  name, model.Name))

    return nil  

end

function assetHelper.apply_touched_event_to_part_name(model, eventFunction, partName)
    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        error("Expected 'model' to be a Model instance, got " .. typeof(model))
    end

    for _, descendant in pairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == partName then
            descendant.Touched:Connect(function(hit)

                eventFunction(descendant, hit)
            end)

            print("APPLIED")
            return true -- Successfully connected event
        end
    end

    -- No matching part found
    error(string.format("In assetHelper.apply_event_to_part_name: part with the name '%s' not found in model '%s'", partName, model.Name))
    return false
end

function assetHelper.find_model(model, name)
    --[[
    (model: Model, name: str) -> Model

    This function returns the model within the model with the name
    that matches the name parameter
    --]]

    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        error("Expected 'model' to be a Model instance, got " .. typeof(model))
    end

    for _, descendant in pairs(model:GetDescendants()) do

        if descendant:IsA("Model") and descendant.Name == name then
            return descendant
        end
    end

    error(string.format("In assetHelper.find_model Model with the name '%s' not found in model '%s'",  name, model.Name))

    return nil  

end

function assetHelper.set_part_attribute_in_model(model, attributeName, changeTo)
    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        error("Expected 'model' to be a Model instance, got " .. typeof(model))
    end

    if type(attributeName) ~= "string" or attributeName == "" then
        error("Expected 'attributeName' to be a non-empty string, got " .. tostring(attributeName))
    end

    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            -- Check if the attribute exists in the part
            local success, err = pcall(function()
                part[attributeName] = changeTo
            end)

            if not success then
                warn("Failed to set attribute '" .. attributeName .. "' in part '" .. part.Name .. "': " .. err)
            end
        end
    end
end

function assetHelper.get_bounding_box(model)
    --[[
    gets bounding box for a model object
    --]]
    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        error("Expected 'model' to be a Model instance, got " .. typeof(model))
    end

    if not model.PrimaryPart then return nil, nil end

    local minBound, maxBound = nil, nil
    local primaryCFrame = model.PrimaryPart.CFrame

    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local size = part.Size / 2
            local partCFrame = part.CFrame

            local localCorners = {
                Vector3.new(-size.X, -size.Y, -size.Z),
                Vector3.new(-size.X, -size.Y, size.Z),
                Vector3.new(-size.X, size.Y, -size.Z),
                Vector3.new(-size.X, size.Y, size.Z),
                Vector3.new(size.X, -size.Y, -size.Z),
                Vector3.new(size.X, -size.Y, size.Z),
                Vector3.new(size.X, size.Y, -size.Z),
                Vector3.new(size.X, size.Y, size.Z),
            }

            for _, localCorner in ipairs(localCorners) do
                local worldCorner = partCFrame:PointToWorldSpace(localCorner)

                if not minBound or not maxBound then
                    minBound, maxBound = worldCorner, worldCorner
                else
                    minBound = Vector3.new(
                        math.min(minBound.X, worldCorner.X),
                        math.min(minBound.Y, worldCorner.Y),
                        math.min(minBound.Z, worldCorner.Z)
                    )
                    maxBound = Vector3.new(
                        math.max(maxBound.X, worldCorner.X),
                        math.max(maxBound.Y, worldCorner.Y),
                        math.max(maxBound.Z, worldCorner.Z)
                    )
                end
            end
        end
    end

    return minBound, maxBound
end

return assetHelper