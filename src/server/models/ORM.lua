local ServerScriptService = game:GetService("ServerScriptService")
local tableHelper = require(ServerScriptService.Server.helpers.tables)

-- MemoryStore and DataStore ORM
local ORM = {}
ORM.__index = ORM



-- Constructor
function ORM.new(storeName, model, cacheExpirationTime, onSyncEvent)
    local self = setmetatable({}, ORM)
    self.model = model or {}
    self.inMemoryCache = {} -- In-memory cache (server-specific)
    self.cacheExpiration = {} -- Tracks expiration times for cache keys
    self.permanentStore = game:GetService("DataStoreService"):GetDataStore(storeName)
    self.cacheExpirationTime = cacheExpirationTime or 300 -- Default expiration time (in seconds)
    self.onSyncEvent = onSyncEvent -- Optional event trigger for syncing
    return self
end

-- Create or Update (upsert) data
function ORM:save(key, data)
    -- Validate data
    if not self:validateRow(data, self.model) then
        warn("Invalid data for saving: " .. key)
        return
    end

    -- Update in-memory cache
    self.inMemoryCache[key] = data
    self.cacheExpiration[key] = os.time() + self.cacheExpirationTime -- Set expiration time

    -- If an event trigger is provided, connect it to sync the data
    if self.onSyncEvent then
        self.onSyncEvent:Connect(function()
            self:syncKey(key)
        end)
    end
end

-- Read data
function ORM:load(key)
    -- Check in-memory cache
    if self.inMemoryCache[key] then
        -- Check if the cache has expired
        if os.time() > (self.cacheExpiration[key] or 0) then
            self:syncKey(key) -- Sync expired data to permanent storage
            self.inMemoryCache[key] = nil -- Remove expired data from cache
            self.cacheExpiration[key] = nil
        else
            return self.inMemoryCache[key] -- Return cached data
        end
    end

    -- Fetch from permanent storage (DataStore)
    local success, permanentData = pcall(function()
        return self.permanentStore:GetAsync(key)
    end)
    if success and permanentData then
        -- Update in-memory cache
        self.inMemoryCache[key] = permanentData
        self.cacheExpiration[key] = os.time() + self.cacheExpirationTime -- Set expiration time
        return permanentData
    end

    -- Return nil if data is not found
    return nil
end

-- Delete data
function ORM:delete(key)
    -- Remove from in-memory cache
    self.inMemoryCache[key] = nil
    self.cacheExpiration[key] = nil

    -- Remove from permanent storage
    task.spawn(function()
        local success, err = pcall(function()
            self.permanentStore:RemoveAsync(key)
        end)
        if not success then
            warn("Failed to remove key from permanent storage:", key, err)
        end
    end)
end


function ORM:startCacheCleanup(interval)
    interval = interval or 60 -- Default cleanup interval (in seconds)
    task.spawn(function()
        while true do
            task.wait(interval)
            for key, expirationTime in pairs(self.cacheExpiration) do
                if os.time() > expirationTime then
                    self:syncKey(key) -- Sync expired data to permanent storage
                end
            end
        end
    end)
end

function ORM:syncKey(key)
    if not self.inMemoryCache[key] then
        return -- No data to sync
    end

    -- Write data to permanent storage
    local success, err = pcall(function()
        self.permanentStore:SetAsync(key, self.inMemoryCache[key])
    end)
    if not success then
        warn("Failed to sync key to permanent storage:", key, err)
    end

    -- Remove the key from the cache
    self.inMemoryCache[key] = nil
    self.cacheExpiration[key] = nil
end

function ORM:syncAll()
    for key, _ in pairs(self.inMemoryCache) do
        self:syncKey(key)
    end
end

-- Validate the data against the model
function ORM:validateRow(data, model)

    for field, expectedType in pairs(model) do
        if data[field] == nil then
            warn("Missing field: " .. field)
            return false
        end

        local dataType = type(data[field])
        local expectedDataType = type(expectedType)

        if expectedDataType == "table" and type(expectedType) == "table" then
            if dataType ~= "table" then
                warn("Invalid type for field: " .. field .. ". Expected table but got " .. dataType)
                return false
            end
            if not self:validateRow(data[field], expectedType) then
                return false
            end
        elseif dataType ~= expectedDataType then
            warn("Invalid type for field: " .. field .. ". Expected " .. expectedDataType .. " but got " .. dataType)
            return false
        end
    end
    return true
end


return ORM
