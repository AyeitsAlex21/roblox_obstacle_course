local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Local = {}
local Shared = {}

Shared.Guis = {
	Right = PlayerGui:WaitForChild("Right"),
    Shop = PlayerGui:WaitForChild("Shop"),
}

return Shared
