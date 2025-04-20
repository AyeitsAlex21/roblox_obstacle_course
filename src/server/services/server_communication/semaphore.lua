local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")

local LockService = {}
LockService.__index = LockService

function LockService.new(lockName, timeout, count)
    assert(lockName, "Lock name must be provided")
    local self = setmetatable({}, LockService)

    local success, queue = pcall(function()
        return MemoryStoreService:GetQueue(lockName, count or 1)
    end)

    if not success or not queue then
        error("Failed to initialize MemoryStore queue for lock: " .. tostring(lockName))
    end

    print("MemoryStore queue initialized for lock:", lockName)
    self.queue = queue
    self.timeout = timeout or 10 -- Default lock timeout in seconds
    self.lockName = lockName
    self.maxCount = count or 1 -- Max number of concurrent locks

    return self
end

-- Get current count of locks in use
function LockService:GetCount()
    if not self.queue then
        warn("Queue not initialized for lock:", self.lockName)
        return 0
    end

    local success, items = pcall(function()
        return self.queue:ReadAsync(self.maxCount, false, 0) -- Visibility timeout of 0
    end)

    if success then
        if items and #items > 0 then
            print("Queue read successfully. Items in queue:", #items)
            return #items -- Return the number of items in the queue
        else
            print("Queue is empty for lock:", self.lockName)
            return 0
        end
    else
        warn("Failed to read queue for lock:", self.lockName)
        return 0
    end
end

function LockService:TryLock()
    if not self.queue then
        warn("Queue not initialized for lock:", self.lockName)
        return false
    end

    local currentCount = self:GetCount()

    if currentCount < self.maxCount then
        local success, err = pcall(function()
            self.queue:AddAsync("LOCKED", self.timeout) -- Add item with timeout
        end)

        if success then
            print("Lock acquired successfully:", self.lockName)
            return true
        else
            warn("Failed to acquire lock due to error:", err)
        end
    else
        print("Lock not available:", self.lockName)
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
