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
        numObstalces
    )

    local serialized = Obstacle_Course_Generator:serialize_obstacle_course(ObstacleCourseModel)
    local unserialized = Obstacle_Course_Generator:deserialize_obstacle_course(serialized)

    if ObstacleCourseModel.PrimaryPart then
        ObstacleCourseModel:SetPrimaryPartCFrame(
            ObstacleCourseModel.PrimaryPart.CFrame * CFrame.new(0, 30, 0)
        )
    end

    ObstacleCourseModel.Parent = workspace
    unserialized.Parent = workspace

end


return midnightJobs