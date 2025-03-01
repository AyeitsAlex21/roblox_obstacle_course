

local function onCheckpointTouched(checkpointModel, hit)
    print("OK IM HERE INSIDE  A THING", checkpointModel:GetAttribute("checkpoint_num"), hit)
    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
    if player then
        print(player.Name .. " touched the checkpoint: " .. checkpointModel.Name)
        -- CheckpointEvent:FireServer(checkpointModel) -- Send the checkpoint MODEL, not just the part
    end
end

return onCheckpointTouched