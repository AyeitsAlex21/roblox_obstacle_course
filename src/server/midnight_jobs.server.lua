local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")

local timeHelper = require(ServerScriptService.Server.helpers.times)
local midnightJobs = require(ServerScriptService.Server.services.midnight_jobs)
local semaphoreService = require(ServerScriptService.Server.services.server_communication.semaphore)

local mutexLock = semaphoreService.new("stage_generation", 30, 1) -- 10 seconds then lock expires and only 1 server can have lock

local function triggerMidnightEvent()
    print("Midnight event triggered! Firing RemoteEvent...")
    

    local ObstacleCourseModel = midnightJobs.make_obstacle_courses()

end


local function attemptToBeJobServer() 
    -- if one of the servers gets the lock then do the midnight event
    -- otherwise try later
    --print("Attempting to be job server")
    if mutexLock:TryLock() then
        print("Acquired lock! Running midnight jobs...")
        triggerMidnightEvent()
    else
        print("Failed to acquire lock. Another server is running the midnight jobs.")
    end

    task.delay(
        timeHelper.getTimeUntilMidnightPST(), 
        attemptToBeJobServer
    )
end

task.delay(
    1,--timeHelper.getTimeUntilMidnightPST(), 
    attemptToBeJobServer
)
