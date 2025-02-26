local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local GuiController = require(script.Parent.Parent.GuiController)
local StateController = require(script.Parent.Parent.StateController)

local Gui = GuiController.Guis.Right
local Frame = Gui.Frame.Currency
local Coins = Frame.Coins
local Gems = Frame.Gems


local Local = {}
local Shared = {}

function Shared.OnStart()
	StateController.UpdateState.Event:Connect(function(action: StateController.StateAction)
		if action.action == "UpdateCurrency" then
			Local.UpdateCurrency(action.currency)
		end
	end)
end

function Local.UpdateCurrency(currency: string)
	if currency == "coins" then
		Coins.Amount.Text = StateController.GetState().coins
	elseif currency == "gems" then
		Gems.Amount.Text = StateController.GetState().gems
	end
end

return Shared
