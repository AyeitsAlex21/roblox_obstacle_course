local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StageStore = require(ServerScriptService.Server.models.stage)

local timeHelper = require(ServerScriptService.Server.helpers.times)
local Obstacle_Course_Generator = require(ServerScriptService.Server.services.generate_stage)
local MIDNIGHT_JOBS_CONFIG = require(ServerScriptService.Server.config.midnight_jobs_config)

Obstacle_Course_Generator = Obstacle_Course_Generator.new()


local midnightJobs = {}

function midnightJobs.pre_make_obstacle_courses()
    local daysAheadofCurrentDate = MIDNIGHT_JOBS_CONFIG.days_ahead
    local overwrite_existing = MIDNIGHT_JOBS_CONFIG.overwrite_existing

    for i = 0, daysAheadofCurrentDate do
        -- Calculate the date for `i` days ahead
        local futureDate = os.date("%m/%d/%Y", os.time() + (i * 24 * 60 * 60)) -- Add `i` days in seconds
        local futureDateSeed = timeHelper.getDatesSeed(futureDate)
        print(futureDate)

        local document = StageStore:GetDocument(futureDate)
        local readResult = document:Read()

        -- if stage document exists then skip and we are not overwriting existing
        if readResult.success and not overwrite_existing then
            continue -- Skip to the next iteration
        end

        local numObstacles = math.random(
            Obstacle_Course_Generator.stage_config.number_of_obstacles[1], 
            Obstacle_Course_Generator.stage_config.number_of_obstacles[2]
        )

        -- Generate the obstacle course
        local ObstacleCourseModel = Obstacle_Course_Generator:generate_obstacle_course(
            futureDateSeed,
            numObstacles
        )

        if not ObstacleCourseModel then
            error("Failed to generate obstacle course for date: " + tostring(futureDate), 2)
        end

        -- Serialize the obstacle course to JSON
        local serialized = Obstacle_Course_Generator:serialize_obstacle_course(ObstacleCourseModel)

        -- Open and update the document with the stage data
        local result = document:OpenAndUpdate(function(data)
            return {
                stage_id = futureDate, -- Use the future date as the stage ID
                seed = tostring(futureDateSeed), -- Seed for reproducibility
                num_checkpoints = numObstacles, -- Number of checkpoints
                obstacle_course = serialized, -- Serialized obstacle course
                created_on = os.date("%Y-%m-%d %H:%M:%S"), -- Timestamp for creation
                last_updated = os.date("%Y-%m-%d %H:%M:%S"), -- Timestamp for last update
            }
        end)

        -- Handle the result
        if result.success then
            print("Stage created successfully with ID:", futureDate)
        else
            warn("Failed to create stage:", result.reason)
        end
    end

    print("All " .. daysAheadofCurrentDate .. " obstacle courses have been processed!")
end


return midnightJobs