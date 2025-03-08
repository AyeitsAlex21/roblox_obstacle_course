local ServerScriptService = game:GetService("ServerScriptService")
local tableHelper = require(ServerScriptService.Server.helpers.tables)

-- MemoryStore and DataStore ORM
local ORM = {}
ORM.__index = ORM



-- Constructor
function ORM.new(storeType, storeName, model)
    local self = setmetatable({}, ORM)
    self.storeType = storeType:lower()
    self.model = model or {}
    self.isMemoryStore = false
    
    if self.storeType == "memorystore" then
        self.isMemoryStore = true
        self.store = game:GetService("MemoryStoreService"):GetHashMap(storeName)
    elseif self.storeType == "datastore" then
        self.store = game:GetService("DataStoreService"):GetDataStore(storeName)
    else
        error("Invalid store type. Use 'MemoryStore' or 'DataStore'.")
    end
    
    return self
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

-- Create or Update (upsert) data
function ORM:save(key, data)
    if self:validateRow(data, self.model) then
        local success, errorMessage = pcall(function()

            if self.isMemoryStore then
                self.store:SetAsync(key, data, 30) 
            else 
                self.store:SetAsync(key, data) 
            end

        end)
        
        if not success then
            warn("Error saving data: " .. errorMessage)
        end
    else
        warn("Invalid data for saving: " .. key)
    end
end

-- Set a column (field) name to a value in a data table
function ORM:setColumn(key, columnName, value)
    local data = self:load(key)
    if data then
        data[columnName] = value
        self:save(key, data)
    else
        warn("No data found to update.")
    end
end

-- Read data
function ORM:load(key)
    local success, result = pcall(function()
        return self.store:GetAsync(key)
    end)
    
    if success then
        return result
    else
        return nil
    end
end

-- Delete data
function ORM:delete(key)
    local success, errorMessage = pcall(function()
        self.store:RemoveAsync(key)
    end)
    
    if not success then
        warn("Error deleting data: " .. errorMessage)
    end
end

function ORM:create_default()
    return tableHelper.deepCopy(self.model)
end

return ORM
