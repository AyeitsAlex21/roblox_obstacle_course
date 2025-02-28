local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdateState = require(ReplicatedStorage.Functions)
local Remotes = ReplicatedStorage.PlayerData

export type StateAction = UpdateState.UpdateDataAction
export type PlayerData = UpdateState.PlayerData

local State: PlayerData

local Local = {}
local Shared = {}

Shared.UpdateState = Instance.new("BindableEvent")
function Shared.OnStart()
	Remotes.SetState.OnClientEvent:Connect(function(playerData: PlayerData)
		State = playerData
	end)

	Remotes.UpdateState.OnClientEvent:Connect(function(action: StateAction)
		if not State then
			return
		end

		UpdateState(State, action)
		Shared.UpdateState:Fire(action, State)
	end)

	Remotes.Start:FireServer()
end

function Shared.GetState(): PlayerData
	while State == nil do
		task.wait(0.01)
	end

	return State
end

return Shared
