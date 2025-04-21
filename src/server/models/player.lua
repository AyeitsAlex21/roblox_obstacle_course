local DataStoreService = game:GetService("DataStoreService")
local DocumentService = require(game:GetService("ReplicatedStorage").Packages.DocumentService)
local Guard = require(game:GetService("ReplicatedStorage").Packages.Guard)

-- Define the Player data schema
type PlayerDataSchema = {
    perks: { [string]: boolean },
    stages: { [string]: { -- Dictionary keyed by stage ID
        checkpoint: number, -- The checkpoint the player is on
        completed: boolean, -- Whether the stage is completed
    } },
    vips: { [string]: boolean },
    login_dates: { [string]: boolean },
}

-- Custom validation for stages

-- Define the data interface for validation using Guard
local DataInterface = {
    perks = Guard.Map(Guard.String, Guard.Boolean), -- Validates a dictionary with string keys and boolean values
    stages = Guard.Map(Guard.String, Guard.Map(Guard.Any, Guard.Any)), -- Validates a dictionary with string keys and custom stage validation
    vips = Guard.Map(Guard.String, Guard.Boolean), -- Validates a dictionary with string keys and boolean values
    login_dates = Guard.Map(Guard.String, Guard.Boolean), -- Validates a dictionary with string keys and boolean values
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
        perks = {}, -- Empty dictionary for perks
        stages = {}, -- Empty dictionary for stages
        vips = {}, -- Empty dictionary for VIP perks
        login_dates = {}, -- Empty dictionary for login dates
    },
    migrations = {}, -- Add migrations here if needed
    lockSessions = true, -- Enable session locking for player data
})

return PlayerStore