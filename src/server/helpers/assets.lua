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

return assetHelper