--[[
This file kicks off a midnight job to create stages
--]]

local ServerScriptService = game:GetService("ServerScriptService")

local timeHelper = require(ServerScriptService.Server.helpers.times)
local midnightJobs = require(ServerScriptService.Server.services.midnight_jobs)
local semaphoreService = require(ServerScriptService.Server.services.server_communication.semaphore)

local mutexLock = semaphoreService.new("stage_generation", 60, 1) -- 10 seconds then lock expires and only 1 server can have lock



local function triggerMidnightEvent()
    print("Midnight event triggered! Firing RemoteEvent...")
    
    midnightJobs.pre_make_obstacle_courses()
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

print("Will start try to do midnight job in " .. tostring(timeHelper.getTimeUntilMidnightPST()) .. " seconds")

task.delay(
    timeHelper.getTimeUntilMidnightPST(), 
    attemptToBeJobServer
)
