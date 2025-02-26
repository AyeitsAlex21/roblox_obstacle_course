local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptsService = game:GetService("ServerScriptService")
local PlayerData = require(ServerScriptsService.Server.services["PlayerData"])
export type PlayerData = PlayerData.PlayerData

export type UpdateDataAction = {
	type: "UpdateTime",
	amount: number,
} | {
	type: "UpdateDeaths",
	amount: number,
} | {
	type: "UpdateGems",
	amount: number,
} | {
	type: "UpdateCurrency",
	currency: "coins" | "gems",
	amount: number
}

--[[
local action: UpdateDataAction= {
    type = "UpdateDeaths",
    amount = 1
}
--]]

return function(playerData: PlayerData.PlayerData, action: UpdateDataAction)
	if action.type == "UpdateTime" then
		playerData.time += action.amount
	elseif action.type == "UpdateDeaths" then
		playerData.deaths += action.amount
	elseif action.action == "UpdateGems" then
		playerData.gems += action.amount
	elseif action.action == "UpdateCurrency" then
		playerData[action.currency] += action.amount
	end
end
