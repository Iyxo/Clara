-- Horse Attribute Manipulator - Ultra-Optimized with Auto Teleportation
-- by Iyxo - 2025-07-22 08:01:25
-- Revolutionary horse control with ultra-optimized continuous enforcement + auto teleportation

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES & ULTRA-OPTIMIZATION
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- PROFESSIONAL CACHING SYSTEM
-- =================================
local Cache = {
    wildHorses = {},
    manipulatedHorses = {},
    horseData = {},
    lastWildUpdate = 0,
    lastManipulatedUpdate = 0,
    wildUpdateInterval = 2,
    manipulatedUpdateInterval = 0.5,
    maxCacheSize = 1000
}

-- =================================
-- ULTRA-OPTIMIZED HORSE MANIPULATOR SYSTEM
-- =================================
local horseManipulator = {
    -- Status
    isRunning = false,
    manipulatedHorses = {},
    
    -- High-performance connections
    connections = {
        manipulation = nil,
        enforcement = nil,
        scanning = nil,
        cleanup = nil,
        teleportation = nil
    },
    
    -- Optimized settings
    settings = {
        -- Core attributes
        fleeDistance = 0,
        behaviour = "Follower",
        enableFollower = true,
        enableFleeDistance = true,
        enableLastPlayerToThrow = true,
        
        -- Performance optimization
        manipulationInterval = 1.5,
        enforcementInterval = 0.25,
        scanInterval = 2,
        cleanupInterval = 15,
        
        -- Teleportation settings
        autoTeleport = false,
        teleportLoop = false,
        teleportInterval = 3,
        teleportRadius = 15,
        teleportHeight = 5,
        maxTeleportDistance = 500,
        
        -- Advanced options
        continuousEnforcement = true,
        globalManipulation = true,
        aggressiveEnforcement = true,
        batchProcessing = true,
        maxBatchSize = 15,
        ultraMode = true
    },
    
    -- High-performance runtime data
    runtime = {
        lastManipulationTime = 0,
        lastEnforcementTime = 0,
        lastScanTime = 0,
        lastCleanupTime = 0,
        lastTeleportTime = 0,
        manipulatedCount = 0,
        sessionStartTime = 0,
        enforcementCount = 0,
        scanCount = 0,
        batchCount = 0,
        globalScanCount = 0,
        teleportCount = 0,
        horsesNearby = 0
    },
    
    -- Professional statistics
    statistics = {
        totalManipulated = 0,
        totalEnforcements = 0,
        totalScans = 0,
        totalBatches = 0,
        totalTeleports = 0,
        sessionsRun = 0,
        horsesControlled = 0,
        averageEnforcementTime = 0,
        peakHorsesControlled = 0,
        enforcementsPerSecond = 0,
        globalCoverage = 0,
        horsesNearbyPeak = 0
    },
    
    -- Performance monitoring
    performance = {
        enforcementTimes = {},
        manipulationTimes = {},
        scanTimes = {},
        batchTimes = {},
        teleportTimes = {},
        maxEnforcementTime = 0,
        avgEnforcementTime = 0,
        maxBatchSize = 0
    }
}

-- =================================
-- ENHANCED UTILITY FUNCTIONS WITH BETTER NAME DETECTION
-- =================================

-- FIXED: Enhanced horse name getter with better detection
local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    -- Check cache first
    local cached = Cache.horseData[horse.Name]
    if cached and cached.name and cached.name ~= "Unknown" and cached.lastUpdate > tick() - 30 then
        return cached.name
    end
    
    local horseName = "Unknown"
    local success = false
    
    -- Enhanced name detection with multiple fallbacks
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                -- First try: BreedLabel
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" and breedLabel.Text ~= " " then
                    horseName = breedLabel.Text
                    success = true
                else
                    -- Second try: Other labels
                    for _, child in pairs(overhead:GetChildren()) do
                        if child:IsA("TextLabel") and child.Text and child.Text ~= "" and child.Text ~= " " and child.Text ~= "Wild" then
                            if child.Text:match("[A-Za-z]") then -- Contains letters
                                horseName = child.Text
                                success = true
                                break
                            end
                        end
                    end
                end
            end
        end
        
        -- Third try: Check for any text-containing parts
        if not success or horseName == "Unknown" then
            for _, descendant in pairs(horse:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Text and descendant.Text ~= "" and descendant.Text ~= " " and descendant.Text ~= "Wild" then
                    if descendant.Text:match("[A-Za-z]") and descendant.Text:len() > 2 then
                        horseName = descendant.Text
                        success = true
                        break
                    end
                end
            end
        end
        
        -- Fourth try: Use shortened ID as fallback
        if not success or horseName == "Unknown" then
            horseName = "Horse_" .. horse.Name:sub(2, 9)
            success = true
        end
    end)
    
    -- Enhanced caching
    if success then
        Cache.horseData[horse.Name] = {
            name = horseName,
            lastUpdate = tick(),
            isWild = nil
        }
    end
    
    return horseName
end

-- Ultra-fast wild horse checker with aggressive caching
local function isWildHorse(horse)
    if not horse then return false end
    
    local cached = Cache.horseData[horse.Name]
    if cached and cached.isWild ~= nil and cached.lastUpdate > tick() - 30 then
        return cached.isWild
    end
    
    local isWild = false
    local success = pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text == "Wild" then
                    isWild = true
                end
            end
        end
    end)
    
    if success then
        if not Cache.horseData[horse.Name] then
            Cache.horseData[horse.Name] = {
                name = "Unknown",
                lastUpdate = tick(),
                isWild = isWild
            }
        else
            Cache.horseData[horse.Name].isWild = isWild
            Cache.horseData[horse.Name].lastUpdate = tick()
        end
    end
    
    return isWild
end

-- ULTRA-OPTIMIZED GLOBAL HORSE SCANNING
local function updateGlobalWildHorses()
    local currentTime = tick()
    if currentTime - Cache.lastWildUpdate < Cache.wildUpdateInterval then
        return Cache.wildHorses
    end
    
    local startTime = tick()
    Cache.wildHorses = {}
    local horseCount = 0
    
    local function scanLocation(location, locationName)
        if not location then return end
        
        local children = location:GetChildren()
        for i = 1, #children do
            local child = children[i]
            
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseManipulator.manipulatedHorses[child.Name] then
                        horseCount = horseCount + 1
                        Cache.wildHorses[horseCount] = {
                            horse = child,
                            location = locationName,
                            distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        }
                        
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
    end
    
    pcall(function()
        if Workspace.Islands then
            if Workspace.Islands.Mainland then
                scanLocation(Workspace.Islands.Mainland, "Mainland")
            end
            scanLocation(Workspace.Islands, "Islands")
            
            for _, location in pairs(Workspace.Islands:GetChildren()) do
                if location:IsA("Model") and location ~= Workspace.Islands.Mainland then
                    scanLocation(location, location.Name)
                end
            end
        end
    end)
    
    Cache.lastWildUpdate = currentTime
    
    local scanTime = tick() - startTime
    table.insert(horseManipulator.performance.scanTimes, scanTime)
    if #horseManipulator.performance.scanTimes > 100 then
        table.remove(horseManipulator.performance.scanTimes, 1)
    end
    
    horseManipulator.runtime.scanCount = horseManipulator.runtime.scanCount + 1
    horseManipulator.runtime.globalScanCount = horseManipulator.runtime.globalScanCount + 1
    horseManipulator.statistics.totalScans = horseManipulator.statistics.totalScans + 1
    
    return Cache.wildHorses
end

-- ENHANCED: Get manipulated horses with better tracking
local function updateManipulatedHorses()
    local currentTime = tick()
    if currentTime - Cache.lastManipulatedUpdate < Cache.manipulatedUpdateInterval then
        return Cache.manipulatedHorses
    end
    
    Cache.manipulatedHorses = {}
    local manipulatedCount = 0
    local nearbyCount = 0
    local playerPos = humanoidRootPart.Position
    
    for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
        pcall(function()
            local horse = nil
            if Workspace.Islands and Workspace.Islands.Mainland then
                horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
            end
            
            if not horse and Workspace.Islands then
                for _, location in pairs(Workspace.Islands:GetChildren()) do
                    if location:IsA("Model") then
                        horse = location:FindFirstChild(horseId)
                        if horse then break end
                    end
                end
            end
            
            if horse and horse:FindFirstChild("HumanoidRootPart") then
                local humanoid = horse:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    manipulatedCount = manipulatedCount + 1
                    
                    local distance = (playerPos - horse.HumanoidRootPart.Position).Magnitude
                    if distance <= horseManipulator.settings.teleportRadius + 20 then
                        nearbyCount = nearbyCount + 1
                    end
                    
                    Cache.manipulatedHorses[manipulatedCount] = {
                        horse = horse,
                        distance = distance,
                        name = horseData.name or getHorseName(horse)
                    }
                end
            end
        end)
    end
    
    horseManipulator.runtime.horsesNearby = nearbyCount
    if nearbyCount > horseManipulator.statistics.horsesNearbyPeak then
        horseManipulator.statistics.horsesNearbyPeak = nearbyCount
    end
    
    Cache.lastManipulatedUpdate = currentTime
    return Cache.manipulatedHorses
end

-- =================================
-- HORSE TELEPORTATION SYSTEM
-- =================================

-- Professional horse teleportation with smooth positioning
local function teleportHorseToPlayer(horse, index)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local success = false
    local startTime = tick()
    
    pcall(function()
        local playerPos = humanoidRootPart.Position
        local playerLook = humanoidRootPart.CFrame.LookVector
        local playerRight = humanoidRootPart.CFrame.RightVector
        
        -- Calculate optimal position around player
        local angle = (index - 1) * (math.pi * 2 / math.min(#Cache.manipulatedHorses, 8))
        local radius = horseManipulator.settings.teleportRadius
        
        -- Create circular formation around player
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        local targetPos = playerPos + Vector3.new(offsetX, horseManipulator.settings.teleportHeight, offsetZ)
        
        -- Advanced positioning for multiple horses
        if #Cache.manipulatedHorses > 8 then
            local ring = math.floor((index - 1) / 8)
            radius = horseManipulator.settings.teleportRadius + (ring * 8)
            offsetX = math.cos(angle) * radius
            offsetZ = math.sin(angle) * radius
            targetPos = playerPos + Vector3.new(offsetX, horseManipulator.settings.teleportHeight, offsetZ)
        end
        
        -- Ensure horses don't teleport too far (performance optimization)
        local currentDistance = (playerPos - horse.HumanoidRootPart.Position).Magnitude
        if currentDistance <= horseManipulator.settings.maxTeleportDistance then
            -- Smooth teleportation
            horse.HumanoidRootPart.CFrame = CFrame.lookAt(targetPos, playerPos)
            
            -- Optional: Add small upward velocity for more natural movement
            if horse.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                horse.HumanoidRootPart.BodyVelocity:Destroy()
            end
            
            success = true
        end
    end)
    
    -- Performance tracking
    if success then
        local teleportTime = tick() - startTime
        table.insert(horseManipulator.performance.teleportTimes, teleportTime)
        if #horseManipulator.performance.teleportTimes > 100 then
            table.remove(horseManipulator.performance.teleportTimes, 1)
        end
        
        horseManipulator.runtime.teleportCount = horseManipulator.runtime.teleportCount + 1
        horseManipulator.statistics.totalTeleports = horseManipulator.statistics.totalTeleports + 1
    end
    
    return success
end

-- Batch teleport all controlled horses
local function batchTeleportControlledHorses()
    if not horseManipulator.settings.autoTeleport then return 0 end
    
    local manipulatedHorses = updateManipulatedHorses()
    local teleported = 0
    
    for i, horseData in pairs(manipulatedHorses) do
        if horseData.horse and horseData.distance > horseManipulator.settings.teleportRadius then
            if teleportHorseToPlayer(horseData.horse, i) then
                teleported = teleported + 1
            end
        end
        
        -- Limit teleportations per batch for performance
        if teleported >= 5 then break end
    end
    
    return teleported
end

-- =================================
-- ENHANCED ATTRIBUTE MANIPULATION
-- =================================

-- ULTRA-OPTIMIZED BATCH ATTRIBUTE ENFORCEMENT
local function batchEnforceAttributes(horses)
    if not horses or #horses == 0 then return 0, 0 end
    
    local startTime = tick()
    local batchSize = math.min(#horses, horseManipulator.settings.maxBatchSize)
    local enforced = 0
    local totalChanges = 0
    
    for i = 1, batchSize do
        local horseData = horses[i]
        local horse = horseData.horse or horseData
        
        if horse and horse.Parent then
            local changes = 0
            
            pcall(function()
                local attributesToSet = {}
                
                if horseManipulator.settings.enableFollower then
                    local currentBehaviour = horse:GetAttribute("behaviour")
                    if currentBehaviour ~= horseManipulator.settings.behaviour then
                        attributesToSet.behaviour = horseManipulator.settings.behaviour
                        changes = changes + 1
                    end
                    
                    local currentFollowPlayer = horse:GetAttribute("followPlayer")
                    if currentFollowPlayer ~= player.Name then
                        attributesToSet.followPlayer = player.Name
                        changes = changes + 1
                    end
                end
                
                if horseManipulator.settings.enableFleeDistance then
                    local currentFleeDistance = horse:GetAttribute("fleeDistance")
                    if currentFleeDistance ~= horseManipulator.settings.fleeDistance then
                        attributesToSet.fleeDistance = horseManipulator.settings.fleeDistance
                        changes = changes + 1
                    end
                end
                
                if horseManipulator.settings.enableLastPlayerToThrow then
                    local currentLastPlayer = horse:GetAttribute("lastPlayerToThrowLasso")
                    if currentLastPlayer ~= player.Name then
                        attributesToSet.lastPlayerToThrowLasso = player.Name
                        changes = changes + 1
                    end
                end
                
                for attribute, value in pairs(attributesToSet) do
                    horse:SetAttribute(attribute, value)
                end
                
                if changes > 0 then
                    enforced = enforced + 1
                    totalChanges = totalChanges + changes
                    
                    if horseManipulator.manipulatedHorses[horse.Name] then
                        horseManipulator.manipulatedHorses[horse.Name].lastEnforcement = tick()
                        horseManipulator.manipulatedHorses[horse.Name].enforcementCount = 
                            (horseManipulator.manipulatedHorses[horse.Name].enforcementCount or 0) + 1
                    end
                end
            end)
        end
    end
    
    local batchTime = tick() - startTime
    table.insert(horseManipulator.performance.batchTimes, batchTime)
    if #horseManipulator.performance.batchTimes > 100 then
        table.remove(horseManipulator.performance.batchTimes, 1)
    end
    
    if batchSize > horseManipulator.performance.maxBatchSize then
        horseManipulator.performance.maxBatchSize = batchSize
    end
    
    horseManipulator.runtime.batchCount = horseManipulator.runtime.batchCount + 1
    horseManipulator.runtime.enforcementCount = horseManipulator.runtime.enforcementCount + enforced
    horseManipulator.statistics.totalBatches = horseManipulator.statistics.totalBatches + 1
    horseManipulator.statistics.totalEnforcements = horseManipulator.statistics.totalEnforcements + enforced
    
    return enforced, totalChanges
end

-- ENHANCED: Initial manipulation with better name detection
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
    local startTime = tick()
    local success = false
    local horseName = getHorseName(horse) -- Using enhanced name detection
    
    pcall(function()
        local attributesToSet = {}
        
        if horseManipulator.settings.enableFollower then
            attributesToSet.behaviour = horseManipulator.settings.behaviour
            attributesToSet.followPlayer = player.Name
        end
        
        if horseManipulator.settings.enableFleeDistance then
            attributesToSet.fleeDistance = horseManipulator.settings.fleeDistance
        end
        
        if horseManipulator.settings.enableLastPlayerToThrow then
            attributesToSet.lastPlayerToThrowLasso = player.Name
        end
        
        for attribute, value in pairs(attributesToSet) do
            horse:SetAttribute(attribute, value)
        end
        
        -- Enhanced metadata with better name
        horseManipulator.manipulatedHorses[horse.Name] = {
            name = horseName, -- Now uses proper horse name
            time = tick(),
            controlled = true,
            lastEnforcement = tick(),
            enforcementCount = 0,
            location = "Unknown"
        }
        
        horseManipulator.runtime.manipulatedCount = horseManipulator.runtime.manipulatedCount + 1
        horseManipulator.statistics.totalManipulated = horseManipulator.statistics.totalManipulated + 1
        
        local currentControlled = 0
        for _ in pairs(horseManipulator.manipulatedHorses) do
            currentControlled = currentControlled + 1
        end
        
        if currentControlled > horseManipulator.statistics.peakHorsesControlled then
            horseManipulator.statistics.peakHorsesControlled = currentControlled
        end
        
        success = true
    end)
    
    local manipulationTime = tick() - startTime
    table.insert(horseManipulator.performance.manipulationTimes, manipulationTime)
    if #horseManipulator.performance.manipulationTimes > 100 then
        table.remove(horseManipulator.performance.manipulationTimes, 1)
    end
    
    return success, horseName
end

-- Professional cleanup system
local function cleanupDisconnectedHorses()
    local currentTime = tick()
    local cleaned = 0
    
    for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
        local horseExists = false
        
        pcall(function()
            if Workspace.Islands then
                if Workspace.Islands.Mainland then
                    local horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
                    if horse and horse:FindFirstChild("HumanoidRootPart") then
                        local humanoid = horse:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            horseExists = true
                        end
                    end
                end
                
                if not horseExists then
                    for _, location in pairs(Workspace.Islands:GetChildren()) do
                        if location:IsA("Model") and location ~= Workspace.Islands.Mainland then
                            local horse = location:FindFirstChild(horseId)
                            if horse and horse:FindFirstChild("HumanoidRootPart") then
                                local humanoid = horse:FindFirstChild("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    horseExists = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        if not horseExists or (currentTime - horseData.time > 600) then
            horseManipulator.manipulatedHorses[horseId] = nil
            Cache.horseData[horseId] = nil
            cleaned = cleaned + 1
        end
    end
    
    return cleaned
end

-- =================================
-- ULTRA-OPTIMIZED MAIN LOGIC WITH TELEPORTATION
-- =================================
local function startHorseManipulation()
    if horseManipulator.isRunning then return false end
    
    horseManipulator.isRunning = true
    horseManipulator.runtime.sessionStartTime = tick()
    horseManipulator.statistics.sessionsRun = horseManipulator.statistics.sessionsRun + 1
    horseManipulator.runtime.manipulatedCount = 0
    horseManipulator.runtime.enforcementCount = 0
    horseManipulator.runtime.scanCount = 0
    horseManipulator.runtime.batchCount = 0
    horseManipulator.runtime.globalScanCount = 0
    horseManipulator.runtime.teleportCount = 0
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Manipulation Started!",
       Content = "Global enforcement + Auto teleportation | Ultra-optimized system active",
       Duration = 4,
       Image = 4483362458,
    })
    
    -- SCANNING CONNECTION
    horseManipulator.connections.scanning = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastScanTime < horseManipulator.settings.scanInterval then
            return
        end
        
        updateGlobalWildHorses()
        horseManipulator.runtime.lastScanTime = currentTime
    end)
    
    -- MANIPULATION CONNECTION
    horseManipulator.connections.manipulation = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastManipulationTime < horseManipulator.settings.manipulationInterval then
            return
        end
        
        local wildHorses = updateGlobalWildHorses()
        local manipulatedThisRound = 0
        
        local batchSize = math.min(#wildHorses, horseManipulator.settings.maxBatchSize)
        for i = 1, batchSize do
            local horseData = wildHorses[i]
            if horseData and horseData.horse and not horseManipulator.manipulatedHorses[horseData.horse.Name] then
                local success, horseName = manipulateHorseAttributes(horseData.horse)
                
                if success then
                    manipulatedThisRound = manipulatedThisRound + 1
                    
                    if manipulatedThisRound <= 3 then
                        Rayfield:Notify({
                           Title = "🎭 " .. horseName .. " Controlled!",
                           Content = "Location: " .. horseData.location .. " | Auto-teleport: " .. (horseManipulator.settings.autoTeleport and "✅" or "❌"),
                           Duration = 2,
                           Image = 4483362458,
                        })
                    end
                end
            end
        end
        
        if manipulatedThisRound > 3 then
            Rayfield:Notify({
               Title = "🌍 Mass Global Control!",
               Content = "Controlled " .. manipulatedThisRound .. " horses! Auto-teleport: " .. (horseManipulator.settings.autoTeleport and "Active" or "Disabled"),
               Duration = 3,
               Image = 4483362458,
            })
        end
        
        horseManipulator.runtime.lastManipulationTime = currentTime
    end)
    
    -- ENFORCEMENT CONNECTION
    if horseManipulator.settings.continuousEnforcement then
        horseManipulator.connections.enforcement = RunService.Heartbeat:Connect(function()
            if not horseManipulator.isRunning then return end
            
            local currentTime = tick()
            if currentTime - horseManipulator.runtime.lastEnforcementTime < horseManipulator.settings.enforcementInterval then
                return
            end
            
            local manipulatedHorses = updateManipulatedHorses()
            
            if #manipulatedHorses > 0 then
                local enforced, changes = batchEnforceAttributes(manipulatedHorses)
                
                local sessionTime = currentTime - horseManipulator.runtime.sessionStartTime
                if sessionTime > 0 then
                    horseManipulator.statistics.enforcementsPerSecond = horseManipulator.runtime.enforcementCount / sessionTime
                end
            end
            
            horseManipulator.runtime.lastEnforcementTime = currentTime
        end)
    end
    
    -- TELEPORTATION CONNECTION
    if horseManipulator.settings.autoTeleport then
        horseManipulator.connections.teleportation = RunService.Heartbeat:Connect(function()
            if not horseManipulator.isRunning then return end
            
            local currentTime = tick()
            
            -- Different intervals for loop vs auto teleport
            local teleportInterval = horseManipulator.settings.teleportLoop and horseManipulator.settings.teleportInterval or (horseManipulator.settings.teleportInterval * 2)
            
            if currentTime - horseManipulator.runtime.lastTeleportTime < teleportInterval then
                return
            end
            
            local teleported = batchTeleportControlledHorses()
            
            if teleported > 0 and horseManipulator.settings.teleportLoop then
                -- Only show notifications for loop mode
                if teleported >= 3 then
                    Rayfield:Notify({
                       Title = "🌀 Loop Teleport!",
                       Content = "Teleported " .. teleported .. " horses to you!",
                       Duration = 1.5,
                       Image = 4483362458,
                    })
                end
            end
            
            horseManipulator.runtime.lastTeleportTime = currentTime
        end)
    end
    
    -- CLEANUP CONNECTION
    horseManipulator.connections.cleanup = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastCleanupTime < horseManipulator.settings.cleanupInterval then
            return
        end
        
        local cleaned = cleanupDisconnectedHorses()
        
        if #Cache.wildHorses > Cache.maxCacheSize * 0.8 then
            for i = Cache.maxCacheSize * 0.6, #Cache.wildHorses do
                Cache.wildHorses[i] = nil
            end
        end
        
        horseManipulator.runtime.lastCleanupTime = currentTime
    end)
    
    return true
end

local function stopHorseManipulation()
    horseManipulator.isRunning = false
    
    for name, connection in pairs(horseManipulator.connections) do
        if connection then
            connection:Disconnect()
            horseManipulator.connections[name] = nil
        end
    end
    
    local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    Rayfield:Notify({
       Title = "🏁 Ultra Session Ended",
       Content = "Controlled: " .. horseManipulator.runtime.manipulatedCount .. " | Teleports: " .. horseManipulator.runtime.teleportCount .. " | Time: " .. minutes .. "m " .. seconds .. "s",
       Duration = 5,
       Image = 4483362458,
    })
end

-- =================================
-- ENHANCED UI WITH TELEPORTATION CONTROLS
-- =================================

-- 🎭 MAIN CONTROL SECTION
local MainControlSection = parentTab:CreateSection("🎭 Ultra Manipulation Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Global Manipulation",
   CurrentValue = false,
   Flag = "UltraHorseManipulationToggle",
   Callback = function(Value)
      if Value then
         local success = startHorseManipulation()
         if not success then
            MainToggle:Set(false)
         end
      else
         stopHorseManipulation()
      end
   end,
})

-- 🌀 TELEPORTATION CONTROL SECTION
local TeleportationControlSection = parentTab:CreateSection("🌀 Horse Teleportation")

local AutoTeleportToggle = parentTab:CreateToggle({
   Name = "🌀 Auto Teleport Controlled Horses",
   CurrentValue = false,
   Flag = "AutoTeleportToggle",
   Callback = function(Value)
      horseManipulator.settings.autoTeleport = Value
      
      -- Restart teleportation connection if needed
      if horseManipulator.isRunning then
         if horseManipulator.connections.teleportation then
            horseManipulator.connections.teleportation:Disconnect()
            horseManipulator.connections.teleportation = nil
         end
         
         if Value then
            horseManipulator.connections.teleportation = RunService.Heartbeat:Connect(function()
               if not horseManipulator.isRunning then return end
               
               local currentTime = tick()
               local teleportInterval = horseManipulator.settings.teleportLoop and horseManipulator.settings.teleportInterval or (horseManipulator.settings.teleportInterval * 2)
               
               if currentTime - horseManipulator.runtime.lastTeleportTime < teleportInterval then
                  return
               end
               
               local teleported = batchTeleportControlledHorses()
               
               if teleported > 0 and horseManipulator.settings.teleportLoop then
                  if teleported >= 3 then
                     Rayfield:Notify({
                        Title = "🌀 Loop Teleport!",
                        Content = "Teleported " .. teleported .. " horses to you!",
                        Duration = 1.5,
                        Image = 4483362458,
                     })
                  end
               end
               
               horseManipulator.runtime.lastTeleportTime = currentTime
            end)
         end
      end
      
      Rayfield:Notify({
         Title = "🌀 Auto Teleport " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Controlled horses will be teleported to you!" or "Auto teleportation disabled",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local TeleportLoopToggle = parentTab:CreateToggle({
   Name = "🔄 Teleport Loop Mode",
   CurrentValue = false,
   Flag = "TeleportLoopToggle",
   Callback = function(Value)
      horseManipulator.settings.teleportLoop = Value
      Rayfield:Notify({
         Title = "🔄 Loop Mode " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Horses will be continuously teleported!" or "Single teleport mode",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local TeleportRadiusSlider = parentTab:CreateSlider({
   Name = "🌀 Teleport Radius",
   Range = {8, 50},
   Increment = 2,
   Suffix = " studs",
   CurrentValue = 15,
   Flag = "TeleportRadiusSlider",
   Callback = function(Value)
      horseManipulator.settings.teleportRadius = Value
   end,
})

local TeleportIntervalSlider = parentTab:CreateSlider({
   Name = "⏱️ Teleport Interval",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "s",
   CurrentValue = 3,
   Flag = "TeleportIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.teleportInterval = Value
   end,
})

local TeleportHeightSlider = parentTab:CreateSlider({
   Name = "📏 Teleport Height",
   Range = {0, 15},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 5,
   Flag = "TeleportHeightSlider",
   Callback = function(Value)
      horseManipulator.settings.teleportHeight = Value
   end,
})

local InstantTeleportButton = parentTab:CreateButton({
   Name = "⚡ Instant Teleport All",
   Callback = function()
      local teleported = batchTeleportControlledHorses()
      Rayfield:Notify({
         Title = "⚡ Instant Teleport",
         Content = "Teleported " .. teleported .. " controlled horses to you!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- 🎛️ ULTRA SETTINGS SECTION
local UltraSettingsSection = parentTab:CreateSection("🎛️ Ultra Optimization")

local GlobalModeToggle = parentTab:CreateToggle({
   Name = "🌍 Global Mode (No Distance Limits)",
   CurrentValue = true,
   Flag = "UltraGlobalModeToggle",
   Callback = function(Value)
      horseManipulator.settings.globalManipulation = Value
   end,
})

local UltraModeToggle = parentTab:CreateToggle({
   Name = "⚡ Ultra Performance Mode",
   CurrentValue = true,
   Flag = "UltraPerformanceModeToggle",
   Callback = function(Value)
      horseManipulator.settings.ultraMode = Value
      if Value then
         horseManipulator.settings.enforcementInterval = 0.25
         horseManipulator.settings.maxBatchSize = 15
      else
         horseManipulator.settings.enforcementInterval = 0.5
         horseManipulator.settings.maxBatchSize = 10
      end
   end,
})

local ManipulationIntervalSlider = parentTab:CreateSlider({
   Name = "⏱️ Manipulation Interval",
   Range = {0.5, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 1.5,
   Flag = "UltraManipulationIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.manipulationInterval = Value
   end,
})

local EnforcementIntervalSlider = parentTab:CreateSlider({
   Name = "🔒 Enforcement Interval",
   Range = {0.1, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.25,
   Flag = "UltraEnforcementIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.enforcementInterval = Value
   end,
})

local BatchSizeSlider = parentTab:CreateSlider({
   Name = "📦 Ultra Batch Size",
   Range = {5, 25},
   Increment = 1,
   Suffix = " horses",
   CurrentValue = 15,
   Flag = "UltraBatchSizeSlider",
   Callback = function(Value)
      horseManipulator.settings.maxBatchSize = Value
   end,
})

local FleeDistanceSlider = parentTab:CreateSlider({
   Name = "🏃 Flee Distance Override",
   Range = {0, 100},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 0,
   Flag = "UltraFleeDistanceSlider",
   Callback = function(Value)
      horseManipulator.settings.fleeDistance = Value
   end,
})

-- 🎯 ATTRIBUTE CONTROLS SECTION
local AttributeControlsSection = parentTab:CreateSection("🎯 Attribute Controls")

local ContinuousEnforcementToggle = parentTab:CreateToggle({
   Name = "🔒 Continuous Enforcement",
   CurrentValue = true,
   Flag = "UltraContinuousEnforcementToggle",
   Callback = function(Value)
      horseManipulator.settings.continuousEnforcement = Value
   end,
})

local FollowerToggle = parentTab:CreateToggle({
   Name = "🐎 Follower Behaviour",
   CurrentValue = true,
   Flag = "UltraFollowerToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFollower = Value
   end,
})

local FleeDistanceToggle = parentTab:CreateToggle({
   Name = "🏃 Flee Distance Control",
   CurrentValue = true,
   Flag = "UltraFleeDistanceToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFleeDistance = Value
   end,
})

local ExclusiveControlToggle = parentTab:CreateToggle({
   Name = "🎯 Exclusive Control",
   CurrentValue = true,
   Flag = "UltraExclusiveControlToggle",
   Callback = function(Value)
      horseManipulator.settings.enableLastPlayerToThrow = Value
   end,
})

-- 📊 ENHANCED STATUS SECTION
local EnhancedStatusSection = parentTab:CreateSection("📊 Enhanced Status")

local SystemStatus = parentTab:CreateParagraph({Title = "🚀 Ultra System Status", Content = "Ultra-optimized system ready"})
local TeleportStatus = parentTab:CreateParagraph({Title = "🌀 Teleportation Status", Content = "Teleportation ready"})
local GlobalStats = parentTab:CreateParagraph({Title = "🌍 Global Statistics", Content = "Global monitoring ready"})
local PerformanceMetrics = parentTab:CreateParagraph({Title = "⚡ Performance Metrics", Content = "Ultra-performance monitoring"})

-- ⚡ ENHANCED ACTIONS SECTION
local EnhancedActionsSection = parentTab:CreateSection("⚡ Enhanced Actions")

local GlobalInstantButton = parentTab:CreateButton({
   Name = "🌍 Instant Global Manipulation",
   Callback = function()
      local wildHorses = updateGlobalWildHorses()
      local manipulated = 0
      
      for _, horseData in pairs(wildHorses) do
         if horseData.horse and not horseManipulator.manipulatedHorses[horseData.horse.Name] then
            local success, horseName = manipulateHorseAttributes(horseData.horse)
            if success then
               manipulated = manipulated + 1
            end
         end
      end
      
      Rayfield:Notify({
         Title = "🌍 Global Manipulation Complete",
         Content = "Instantly controlled " .. manipulated .. " horses globally!",
         Duration = 5,
         Image = 4483362458,
      })
   end,
})

local UltraEnforceButton = parentTab:CreateButton({
   Name = "🔒 Ultra Global Enforcement",
   Callback = function()
      local manipulatedHorses = updateManipulatedHorses()
      local enforced, changes = batchEnforceAttributes(manipulatedHorses)
      
      Rayfield:Notify({
         Title = "🔒 Ultra Enforcement Complete",
         Content = "Ultra-enforced " .. enforced .. " horses with " .. changes .. " changes!",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})

local ResetStatsButton = parentTab:CreateButton({
   Name = "📊 Reset Statistics",
   Callback = function()
      horseManipulator.statistics = {
         totalManipulated = 0,
         totalEnforcements = 0,
         totalScans = 0,
         totalBatches = 0,
         totalTeleports = 0,
         sessionsRun = 0,
         horsesControlled = 0,
         averageEnforcementTime = 0,
         peakHorsesControlled = 0,
         enforcementsPerSecond = 0,
         globalCoverage = 0,
         horsesNearbyPeak = 0
      }
      horseManipulator.runtime.manipulatedCount = 0
      horseManipulator.runtime.enforcementCount = 0
      horseManipulator.runtime.teleportCount = 0
      
      Rayfield:Notify({
         Title = "📊 Stats Reset",
         Content = "All statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 ENHANCED STATISTICS SECTION
local EnhancedStatisticsSection = parentTab:CreateSection("📈 Enhanced Statistics")

local SessionMetrics = parentTab:CreateParagraph({Title = "📈 Session Metrics", Content = "Enhanced session ready"})
local AllTimeMetrics = parentTab:CreateParagraph({Title = "🏆 All-Time Records", Content = "No data yet"})
local TeleportMetrics = parentTab:CreateParagraph({Title = "🌀 Teleportation Metrics", Content = "Teleport tracking ready"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM WITH TELEPORTATION
-- =================================
spawn(function()
    while wait(0.5) do
        -- Enhanced System Status
        local statusText = ""
        if horseManipulator.isRunning then
            local runtime = tick() - horseManipulator.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            statusText = "🚀 ULTRA-ACTIVE (Global + Teleport)\n"
            statusText = statusText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            statusText = statusText .. "🌍 Global: " .. (horseManipulator.settings.globalManipulation and "✅" or "❌") .. "\n"
            statusText = statusText .. "🎭 Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            statusText = statusText .. "🔒 Enforcements: " .. horseManipulator.runtime.enforcementCount .. "\n"
            statusText = statusText .. "🌀 Teleports: " .. horseManipulator.runtime.teleportCount
        else
            statusText = "🔴 STOPPED\n💤 Enhanced system ready\n🌍 Global manipulation available\n🌀 Auto teleportation ready\n⚡ Ultra-performance optimizations\n🚀 Maximum efficiency mode"
        end
        SystemStatus:Set({Title = "🚀 Ultra System Status", Content = statusText})
        
        -- Teleportation Status
        local teleportText = ""
        if horseManipulator.settings.autoTeleport then
            teleportText = "🌀 AUTO-TELEPORT ACTIVE\n"
            teleportText = teleportText .. "🔄 Loop Mode: " .. (horseManipulator.settings.teleportLoop and "✅" or "❌") .. "\n"
            teleportText = teleportText .. "📏 Radius: " .. horseManipulator.settings.teleportRadius .. " studs\n"
            teleportText = teleportText .. "⏱️ Interval: " .. horseManipulator.settings.teleportInterval .. "s\n"
            teleportText = teleportText .. "📊 Horses Nearby: " .. horseManipulator.runtime.horsesNearby .. "\n"
            teleportText = teleportText .. "🌀 Total Teleports: " .. horseManipulator.runtime.teleportCount
        else
            teleportText = "🔴 TELEPORT DISABLED\n⚙️ Radius: " .. horseManipulator.settings.teleportRadius .. " studs\n⏱️ Interval: " .. horseManipulator.settings.teleportInterval .. "s\n🌀 Manual teleportation available\n📊 Nearby tracking active"
        end
        TeleportStatus:Set({Title = "🌀 Teleportation Status", Content = teleportText})
        
        -- Enhanced Global Statistics
        local wildHorsesCount = #Cache.wildHorses
        local manipulatedCount = 0
        for _ in pairs(horseManipulator.manipulatedHorses) do
            manipulatedCount = manipulatedCount + 1
        end
        
        local globalCoverage = wildHorsesCount > 0 and (manipulatedCount / wildHorsesCount) * 100 or 0
        
        local globalText = "🌍 Horses Scanned: " .. wildHorsesCount .. "\n"
        globalText = globalText .. "🎯 Controlled: " .. manipulatedCount .. "\n"
        globalText = globalText .. "📊 Coverage: " .. string.format("%.1f", globalCoverage) .. "%\n"
        globalText = globalText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        globalText = globalText .. "🌀 Horses Nearby: " .. horseManipulator.runtime.horsesNearby .. "\n"
        globalText = globalText .. "📈 Peak Nearby: " .. horseManipulator.statistics.horsesNearbyPeak
        GlobalStats:Set({Title = "🌍 Global Statistics", Content = globalText})
        
        -- Enhanced Performance Metrics
        local avgTeleportTime = 0
        if #horseManipulator.performance.teleportTimes > 0 then
            local total = 0
            for _, time in pairs(horseManipulator.performance.teleportTimes) do
                total = total + time
            end
            avgTeleportTime = total / #horseManipulator.performance.teleportTimes
        end
        
        local performanceText = "⚡ Enforcement: " .. string.format("%.2f", horseManipulator.statistics.enforcementsPerSecond) .. "/s\n"
        performanceText = performanceText .. "🌀 Avg Teleport: " .. string.format("%.3f", avgTeleportTime * 1000) .. "ms\n"
        performanceText = performanceText .. "📦 Max Batch: " .. horseManipulator.performance.maxBatchSize .. "\n"
        performanceText = performanceText .. "🔄 Cache: " .. wildHorsesCount .. " horses\n"
        performanceText = performanceText .. "🚀 Status: ULTRA-OPTIMIZED"
        PerformanceMetrics:Set({Title = "⚡ Performance Metrics", Content = performanceText})
        
        -- Enhanced Session Metrics
        if horseManipulator.isRunning then
            local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local manipulationRate = sessionTime > 0 and (horseManipulator.runtime.manipulatedCount / (sessionTime / 60)) or 0
            local teleportRate = sessionTime > 0 and (horseManipulator.runtime.teleportCount / (sessionTime / 60)) or 0
            
            local sessionText = "⏱️ Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🎭 Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            sessionText = sessionText .. "📈 Control Rate: " .. string.format("%.1f", manipulationRate) .. "/min\n"
            sessionText = sessionText .. "🌀 Teleports: " .. horseManipulator.runtime.teleportCount .. "\n"
            sessionText = sessionText .. "📊 Teleport Rate: " .. string.format("%.1f", teleportRate) .. "/min\n"
            sessionText = sessionText .. "🌍 Coverage: " .. string.format("%.1f", globalCoverage) .. "%"
            
            SessionMetrics:Set({Title = "📈 Session Metrics", Content = sessionText})
        else
            SessionMetrics:Set({Title = "📈 Session Metrics", Content = "No session active\nEnhanced monitoring ready\n🌍 Global manipulation\n🌀 Auto teleportation\n🚀 Ultra-performance"})
        end
        
        -- Enhanced All-Time Metrics
        local allTimeText = "🎭 Total Manipulated: " .. horseManipulator.statistics.totalManipulated .. "\n"
        allTimeText = allTimeText .. "🔒 Total Enforcements: " .. horseManipulator.statistics.totalEnforcements .. "\n"
        allTimeText = allTimeText .. "🌀 Total Teleports: " .. horseManipulator.statistics.totalTeleports .. "\n"
        allTimeText = allTimeText .. "🎮 Sessions: " .. horseManipulator.statistics.sessionsRun .. "\n"
        allTimeText = allTimeText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        allTimeText = allTimeText .. "📊 Best Coverage: " .. string.format("%.1f", horseManipulator.statistics.globalCoverage) .. "%"
        
        AllTimeMetrics:Set({Title = "🏆 All-Time Records", Content = allTimeText})
        
        -- Teleportation Metrics
        local teleportMetricsText = "🌀 Session Teleports: " .. horseManipulator.runtime.teleportCount .. "\n"
        teleportMetricsText = teleportMetricsText .. "📊 Total Teleports: " .. horseManipulator.statistics.totalTeleports .. "\n"
        teleportMetricsText = teleportMetricsText .. "⚡ Avg Time: " .. string.format("%.3f", avgTeleportTime * 1000) .. "ms\n"
        teleportMetricsText = teleportMetricsText .. "🎯 Current Nearby: " .. horseManipulator.runtime.horsesNearby .. "\n"
        teleportMetricsText = teleportMetricsText .. "📈 Peak Nearby: " .. horseManipulator.statistics.horsesNearbyPeak .. "\n"
        teleportMetricsText = teleportMetricsText .. "🌀 Mode: " .. (horseManipulator.settings.autoTeleport and "AUTO" or "MANUAL")
        
        TeleportMetrics:Set({Title = "🌀 Teleportation Metrics", Content = teleportMetricsText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if horseManipulator.isRunning then
        stopHorseManipulation()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Enhanced manipulation stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- ENHANCED INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Enhanced Horse Manipulator Loaded!",
   Content = "Global control + Auto teleportation | Fixed horse names | Ultra-optimized!",
   Duration = 6,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "🌀 Auto Teleportation Ready!",
   Content = "Controlled horses can be automatically teleported to you!",
   Duration = 4,
   Image = 4483362458,
})

print("🚀 Enhanced Horse Attribute Manipulator - Global + Teleportation Edition Loaded!")
print("🌍 Features: Global unlimited control, auto teleportation, fixed horse names")
print("🌀 Teleportation: Auto-teleport controlled horses, loop mode, circular formation")
print("⚡ Performance: Ultra-optimized, real-time tracking, professional analytics")
print("🎯 Enhanced: Better name detection, comprehensive monitoring, maximum efficiency!")
