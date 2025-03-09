local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")

local LockService = {}
LockService.__index = LockService

function LockService.new(lockName, timeout, count)
    local self = setmetatable({}, LockService)
    self.queue = MemoryStoreService:GetQueue(lockName, count or 1) -- Allow multiple items
    self.timeout = timeout or 10 -- Default lock timeout in seconds
    self.lockName = lockName
    self.maxCount = count or 1 -- Max number of concurrent locks
    return self
end

-- Get current count of locks in use
function LockService:GetCount()
    local success, items = pcall(function()
        return self.queue:ReadAsync(self.maxCount, false) -- Read current queue size
    end)
    return success and #items or 0
end

-- Try to acquire a lock (Non-blocking)
function LockService:TryLock()
    if self:GetCount() < self.maxCount then
        local success = pcall(function()
            self.queue:AddAsync("LOCKED", self.timeout)
        end)
        return success
    end
    return false
end

-- Blocking lock (waits until a slot is available)
function LockService:Lock()
    while not self:TryLock() do
        local event = Instance.new("BindableEvent")

        -- Subscribe to unlock notifications
        local connection
        connection = MessagingService:SubscribeAsync(self.lockName .. "_UNLOCK", function()
            connection:Disconnect()
            event:Fire() -- Trigger when a lock is released
        end)

        -- Wait for unlock notification before retrying
        event.Event:Wait()
    end
    return true
end

-- Release a lock and notify waiting servers
function LockService:Unlock()
    local success = pcall(function()
        self.queue:RemoveAsync()
    end)

    if success then
        MessagingService:PublishAsync(self.lockName .. "_UNLOCK", {}) -- Notify waiting servers
    end

    return success
end

return LockService
