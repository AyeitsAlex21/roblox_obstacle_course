local DataStoreService = game:GetService("DataStoreService")
local DocumentService = require(game:GetService("ReplicatedStorage").Packages.DocumentService)
local Guard = require(game:GetService("ReplicatedStorage").Packages.Guard)

-- Define the Stage schema
type StageSchema = {
    stage_id: string, -- Unique identifier for the stage
    seed: string, -- Seed used to generate the stage
    num_checkpoints: number, -- Number of checkpoints in the stage
    obstacle_course: string, -- Serialized JSON string of the obstacle course
    created_on: string, -- Date when the stage was created
    last_updated: string, -- Date when the stage was last updated
    place_id: string, -- Place ID for the dynamically created place
}

-- Define the data interface for validation using Guard
local StageInterface = {
    stage_id = Guard.String, -- Validate stage_id as a string
    seed = Guard.String, -- Validate seed as a string
    num_checkpoints = Guard.Integer, -- Validate num_checkpoints as an integer
    obstacle_course = Guard.String, -- Validate obstacle_course as a JSON string
    created_on = Guard.String, -- Validate created_on as a string
    last_updated = Guard.String, -- Validate last_updated as a string
    place_id = Guard.String, -- Validate place_id as a string
}

-- Define the data check function
local function stageDataCheck(value: unknown): StageSchema
    assert(type(value) == "table", "Data must be a table")
    local Value: any = value

    return {
        stage_id = StageInterface.stage_id(Value.stage_id),
        seed = StageInterface.seed(Value.seed),
        num_checkpoints = StageInterface.num_checkpoints(Value.num_checkpoints),
        obstacle_course = StageInterface.obstacle_course(Value.obstacle_course),
        created_on = StageInterface.created_on(Value.created_on),
        last_updated = StageInterface.last_updated(Value.last_updated),
        place_id = StageInterface.place_id(Value.place_id),
    }
end

-- Create the Stage DocumentStore
local StageStore = DocumentService.DocumentStore.new({
    dataStore = DataStoreService:GetDataStore("StageData") :: any,
    check = Guard.Check(stageDataCheck), -- Use Guard.Check for validation
    default = {
        stage_id = "",
        seed = "",
        num_checkpoints = 0,
        obstacle_course = "{}",
        created_on = "",
        last_updated = "",
        place_id = "",
    },
    migrations = {}, -- Add migrations here if needed
    lockSessions = false, -- Disable session locking since stages are shared data
})

return StageStore