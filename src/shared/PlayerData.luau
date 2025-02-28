local Shared = {}
--[[
export type PlayerData = {
    --change stage to time
    time: number,
    deaths: number,
    --[[
    skips: number,
    codes: {
        [string]: boolean
    },
    settings: {
        [string]: boolean
    },
    perks: {
        [string]: boolean
    },
    vip: boolean,
}

-- variable of the playerdata type used for the players default data
local DEFAULT_PLAYER_DATA: PlayerData = {
    --change stage to time
    time = 0,
    deaths = 0
}



Shared.DEFAULT_PLAYER_DATA = DEFAULT_PLAYER_DATA
--]]

Shared.DEFAULT_PLAYER_DATA = {
    time = 0,
    deaths = 0,
    coins = 0,
	gems = 1_000
}

export type PlayerData = typeof(Shared.DEFAULT_PLAYER_DATA)

return Shared