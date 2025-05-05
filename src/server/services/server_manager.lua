local MemoryStoreService = game:GetService("MemoryStoreService")

local ServerRegistry = {}
ServerRegistry.__index = ServerRegistry

function ServerRegistry.new(stageId, expires, serverId)
    local self = setmetatable({}, ServerRegistry)
    self.stageId = stageId
    self.serverId = serverId

    self.expires = expires or 90

    -- MemoryStore keys (based only on stage)
    self.sortedMap = MemoryStoreService:GetSortedMap("Stage_" .. stageId .. "_Sorted")
    self.metaMap = MemoryStoreService:GetMap("Stage_" .. stageId .. "_Meta")

    return self
end

-- Register or update a server's score + metadata
function ServerRegistry:UpdateServer(currentPlayers, maxPlayers)
    local availabilityScore = maxPlayers - currentPlayers

    -- Save to SortedMap (for matchmaking based on open slots)
    self.sortedMap:SetAsync(self.serverId, availabilityScore, self.expires)

    -- Save metadata
    local metadata = {
        Stage = self.stageId,
        CurrentPlayers = currentPlayers,
        MaxPlayers = maxPlayers,
        LastUpdated = os.time(),
    }

    self.metaMap:SetAsync(self.serverId, metadata, self.expires)
end

-- Completely unregister server (when shutting down)
function ServerRegistry:RemoveServer()
    self.sortedMap:RemoveAsync(self.serverId)
    self.metaMap:RemoveAsync(self.serverId)
end

-- Find a suitable server with open slots
function ServerRegistry:FindBestServer(minOpenSlots)
    local results = self.sortedMap:GetRangeAsync(Enum.SortDirection.Descending, 10)

    for _, entry in ipairs(results) do
        local key = entry.key
        local metadata = self.metaMap:GetAsync(key)

        if metadata then
            local available = metadata.MaxPlayers - metadata.CurrentPlayers
            if available >= minOpenSlots then
                return key
            end
        end
    end

    return nil
end

return ServerRegistry
