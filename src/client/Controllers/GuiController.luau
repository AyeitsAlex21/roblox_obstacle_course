local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ShopGui = PlayerGui:WaitForChild("ShopGui")
local Shared = {}
Shared.Guis = {
    Right = ShopGui:WaitForChild("Right"),
    Shop = ShopGui:WaitForChild("Shop"),
}

return Shared
