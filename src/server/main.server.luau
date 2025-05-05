local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptsService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

print(ServerScriptsService.Server.services:GetDescendants())
local assetHelper = require(ServerScriptsService.Server.helpers.assets)
local ServerManagerService = require(ServerScriptsService.Server.services.server_manager)
local stageStore = require(ServerScriptsService.Server.models.stage)
local SERVER_CONFIG = require(ServerScriptsService.Server.config.server_config)
local Obstacle_Course_Generator = require(ServerScriptsService.Server.services.generate_stage)

-- Function to load the map based on teleport data
local function loadMapFromTeleportData()
    -- Check if the server was spawned by another server
    local teleportData = TeleportService:GetLocalPlayerTeleportData()
    local stageId = SERVER_CONFIG.main_lobby_name

    if teleportData then
        print("Server spawned by another server with teleport data:", teleportData)

        -- Extract the stage ID or other arguments from the teleport data
        stageId = teleportData.stageId

        if stageId then
            -- WE ARE A STAGE SERVER
            print("Loading map for stage:", stageId)

            local stageDocument = stageStore:GetDocument(stageId)
            -- Generate the obstacle course for the stage
            local obstacleCourse = Obstacle_Course_Generator:deserialize_obstacle_course(
                stageDocument.obstacle_course
            )
            if obstacleCourse then
                obstacleCourse.Parent = Workspace

                print("Map loaded successfully for stage:", stageId)
            else
                warn("Failed to generate obstacle course for stage:", stageId)
            end
        else
            warn("Invalid teleport data. Missing required fields.")
        end
    else
        -- WE ARE A MAIN LOBBY SERVER
        print("Server was not spawned by another server. No teleport data found.")

        local MainLobby = ReplicatedStorage.assets[stageId]:Clone()

        assetHelper.set_part_attribute_in_model(MainLobby, "Anchored", false)
        assetHelper.set_part_attribute_in_model(MainLobby, "Anchored", true)

        MainLobby.Parent = workspace
    end

    local ServerManager = ServerManagerService.new(
        stageId,
        SERVER_CONFIG.expires,
        game.JobId
    )

    print(#game.Players:GetPlayers(),
    game.Players.MaxPlayers)

    ServerManager:UpdateServer(
        #game.Players:GetPlayers(),
        game.Players.MaxPlayers
    )
end

-- Call the function to load the map
loadMapFromTeleportData()