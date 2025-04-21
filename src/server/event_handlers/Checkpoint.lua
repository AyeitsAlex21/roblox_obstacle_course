local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CheckpointEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Checkpoint")

local TOLERABLE_CHECKPOINTS_TRAVELED = 2

local function onCheckpointTouched(checkpointModel, hit)
    return nil
    --[[
    local player = game.Players:GetPlayerFromCharacter(hit.Parent)

    -- return if player DNE
    if not player then return nil end

    -- get player data from mem cache
    local PlayerData = PlayerMemStoreORM:load(player.UserId)
    if PlayerData == nil then
        PlayerData = PlayerMemStoreORM:create_default()
    end

    local curCheckpointNum = checkpointModel:GetAttribute("checkpoint_num")
    local playerCheckpointNum = player:GetAttribute("checkpoint_num")

    -- if player did not have a checkpoint_num
    if not playerCheckpointNum then
        playerCheckpointNum = -1
    end

    local numCheckpointsTraveled = curCheckpointNum - playerCheckpointNum
    -- you can only skip one checkpoint
    if 0 < numCheckpointsTraveled and numCheckpointsTraveled <= TOLERABLE_CHECKPOINTS_TRAVELED then
        player:SetAttribute("checkpoint_num", curCheckpointNum)

        PlayerData.stages[curCheckpointNum] = curCheckpointNum
        PlayerMemStoreORM:save(player.UserId, PlayerData)

        -- send the model so client can animate it
        CheckpointEvent:FireClient(player, checkpointModel)
    end
    --]]
end

return onCheckpointTouched
