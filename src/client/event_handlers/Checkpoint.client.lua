local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CheckpointEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Checkpoint")

CheckpointEvent.OnClientEvent:Connect(function(checkpointModel)

    local flagModel = checkpointModel:WaitForChild("Flag")

    local flagPrimaryPart = flagModel.PrimaryPart
    local flagCframe = flagPrimaryPart.CFrame

    -- rotate flag to be up
    local rotationCFrame = CFrame.fromEulerAnglesXYZ(0, 0, math.rad(-90))

    -- Apply rotation
    flagModel:SetPrimaryPartCFrame(flagCframe * rotationCFrame)
end)