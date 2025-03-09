local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")

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
        100
    )

    print(ObstacleCourseModel:WaitForChild("Checkpoints").length)

end


return midnightJobs