local DataStoreService = game:GetService("DataStoreService")
local DocumentService = require(game:GetService("ReplicatedStorage").Packages.DocumentService)
local Guard = require(game:GetService("ReplicatedStorage").Packages.Guard)

-- Define the Player data schema
type PlayerDataSchema = {
    perks: { [string]: {} },
    stages: { [string]: { -- Dictionary keyed by stage ID
        checkpoint: number, -- The checkpoint the player is on
        completed: boolean, -- Whether the stage is completed
    } },
    vips: { [string]: {} },
    login_dates: { [string]: {} },
}

-- Define the data interface for validation using Guard
local DataInterface = {
    perks = Guard.Dictionary(Guard.Boolean), -- Validates a dictionary of booleans
    stages = Guard.Dictionary(Guard.Struct({
        checkpoint = Guard.Integer, -- Validates the checkpoint as an integer
        completed = Guard.Boolean, -- Validates completion as a boolean
    })),
    vips = Guard.Dictionary(Guard.Boolean), -- Validates a dictionary of booleans
    login_dates = Guard.Dictionary(Guard.Boolean), -- Validates a dictionary of booleans
}

-- Define the data check function
local function dataCheck(value: unknown): PlayerDataSchema
    assert(type(value) == "table", "Data must be a table")
    local Value: any = value

    return {
        perks = DataInterface.perks(Value.perks),
        stages = DataInterface.stages(Value.stages),
        vips = DataInterface.vips(Value.vips),
        login_dates = DataInterface.login_dates(Value.login_dates),
    }
end

-- Create the Player DocumentStore
local PlayerStore = DocumentService.DocumentStore.new({
    dataStore = DataStoreService:GetDataStore("PlayerData") :: any,
    -- For mockDataStores, use the following line instead:
    -- dataStore = MockDataStore:GetDataStore("Mock"),
    check = Guard.Check(dataCheck), -- Use Guard.Check for validation
    default = {
        perks = {},
        stages = {
            --checkpoint = 0,
            --completed = false
        },
        vips = {},
        login_dates = {},
    },
    migrations = {}, -- Add migrations here if needed
    lockSessions = true, -- Enable session locking for player data
})

return PlayerStore