local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StageStore = require(ServerScriptService.Server.models.stage)

local timeHelper = require(ServerScriptService.Server.helpers.times)
local Obstacle_Course_Generator = require(ServerScriptService.Server.services.generate_stage)

Obstacle_Course_Generator = Obstacle_Course_Generator.new()


local midnightJobs = {}


function midnightJobs.make_obstacle_courses()

    local todaysDate = os.date("%m/%d/%Y")  -- todays date
    local numObstalces = 100
    local todaysDateSeed = timeHelper.getDatesSeed(todaysDate)
   
    local ObstacleCourseModel = Obstacle_Course_Generator:generate_obstacle_course(
        todaysDateSeed,
        numObstalces
    )

    -- Serialize the obstacle course to JSON
    local serialized = Obstacle_Course_Generator:serialize_obstacle_course(ObstacleCourseModel)

    -- Retrieve or create the stage document
    local document = StageStore:GetDocument(todaysDate)

    -- Open and update the document with the stage data
    local result = document:OpenAndUpdate(function(data)
        return {
            stage_id = todaysDate, -- Use today's date as the stage ID
            seed = tostring(todaysDateSeed), -- Seed for reproducibility
            num_checkpoints = numObstalces, -- Number of checkpoints
            obstacle_course = serialized, -- Serialized obstacle course
            created_on = os.date("%Y-%m-%d %H:%M:%S"), -- Timestamp for creation
            last_updated = os.date("%Y-%m-%d %H:%M:%S"), -- Timestamp for last update
        }
    end)

    -- Handle the result
    if result.success then
        print("Stage created successfully with ID:", todaysDate)
    else
        warn("Failed to create stage:", result.reason)
    end

end


return midnightJobs