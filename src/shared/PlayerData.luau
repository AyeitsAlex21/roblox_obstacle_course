export type PlayerData = {
    --change stage to time
    stage: number,
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
    vip: boolean,--]]
}

-- variable of the playerdata type used for the players default data
local DEFAULT_PLAYER_DATA: PlayerData = {
    --change stage to time
    stage = 1,
    deaths = 0
}

local Shared = {}

Shared.DEFAULT_PLAYER_DATA = DEFAULT_PLAYER_DATA

return Shared