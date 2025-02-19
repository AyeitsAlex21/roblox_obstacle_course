local assetHelper = {}

function assetHelper.find_part(model, name)
    --[[
    (model: Model, name: str) -> Part

    This function returns the part within the model with the name
    that matches the name parameter
    --]]

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

    for _, descendant in pairs(model:GetDescendants()) do

        if descendant:IsA("Model") and descendant.Name == name then
            return descendant
        end
    end

    error(string.format("In assetHelper.find_model Model with the name '%s' not found in model '%s'",  name, model.Name))

    return nil  

end

function assetHelper.set_anchored(model, anchorState)
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = anchorState
        end
    end
end

return assetHelper