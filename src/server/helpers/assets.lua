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

    return nil  -- Return nil if no "Back" part is found

end

function assetHelper.set_anchored(model, anchorState)
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = anchorState
        end
    end
end

return assetHelper