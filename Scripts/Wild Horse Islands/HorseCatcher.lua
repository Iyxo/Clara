-- Horse Catcher Pro - Professional Smart Scanning Edition
-- by Iyxo - 2025-07-22 22:05:30
-- Revolutionary horse catching with intelligent scanning and CaptureProgress monitoring

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES & OPTIMIZATION
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- ENHANCED ISLAND DETECTION SYSTEM
-- =================================
local islandSystem = {
    currentIsland = "Unknown",
    lastUpdate = 0,
    updateInterval = 3,
    availableIslands = {},
    islandHorseCount = {}
}

local function detectCurrentIsland()
    local currentTime = tick()
    if currentTime - islandSystem.lastUpdate < islandSystem.updateInterval then
        return islandSystem.currentIsland
    end
    
    local islandAttribute = player:GetAttribute("island")
    if islandAttribute and islandAttribute ~= "" then
        islandSystem.currentIsland = islandAttribute
        islandSystem.lastUpdate = currentTime
        return islandAttribute
    end
    
    pcall(function()
        if character and character.Parent then
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if character.Parent == island then
                    islandSystem.currentIsland = island.Name
                    islandSystem.lastUpdate = currentTime
                    return
                end
            end
        end
    end)
    
    if islandSystem.currentIsland == "Unknown" then
        pcall(function()
            local playerPos = humanoidRootPart.Position
            local closestIsland = "Mainland"
            local shortestDistance = math.huge
            
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island:IsA("Model") and island:FindFirstChild("Terrain") then
                    local islandPos = island:GetPivot().Position
                    local distance = (playerPos - islandPos).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestIsland = island.Name
                    end
                end
            end
            
            islandSystem.currentIsland = closestIsland
        end)
    end
    
    islandSystem.lastUpdate = currentTime
    return islandSystem.currentIsland
end

-- =================================
-- PROFESSIONAL INTELLIGENT SCANNING SYSTEM
-- =================================
local intelligentScanner = {
    enabled = false,
    isScanning = false,
    isPaused = false,
    
    -- Island bounds configuration
    islandBounds = {
        ["Mainland"] = {
            corner1 = Vector3.new(-992.5, 6.8, -951.3),
            corner2 = Vector3.new(1084.9, 6.7, 861.8)
        }
        -- Add more islands here as needed
    },
    
    -- Known horse locations for intelligent targeting
    knownHorseLocations = {},
    lastKnownUpdate = 0,
    
    -- Scanning settings
    settings = {
        scanType = "terrain", -- "terrain" or "random"
        scanSpeed = 0.5, -- seconds between teleports
        autoScan = true,
        smartTargeting = true,
        landOnly = true,
        scanPoints = 12,
        maxKnownLocations = 100
    },
    
    -- Runtime data
    runtime = {
        currentScanIndex = 0,
        totalScanPoints = 0,
        lastScanTime = 0,
        scanStartTime = 0,
        horsesFoundThisScan = 0,
        totalHorsesFound = 0,
        originalPosition = nil,
        currentScanPoints = {}
    },
    
    connections = {
        scanner = nil,
        horseWatcher = nil
    }
}

-- Check if position is on land (terrain-based)
local function isOnLand(position)
    if not intelligentScanner.settings.landOnly then return true end
    
    local success, result = pcall(function()
        local raycast = workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -50, 0))
        
        if raycast and raycast.Instance and raycast.Instance:IsA("Terrain") then
            local material = raycast.Material
            
            -- Land materials (not water)
            local landMaterials = {
                Enum.Material.Grass,
                Enum.Material.Ground,
                Enum.Material.Rock,
                Enum.Material.Sand,
                Enum.Material.Snow,
                Enum.Material.Mud,
                Enum.Material.LeafyGrass,
                Enum.Material.Concrete,
                Enum.Material.Brick,
                Enum.Material.Cobblestone,
                Enum.Material.Pebble
            }
            
            for _, landMat in pairs(landMaterials) do
                if material == landMat then
                    return true
                end
            end
            
            return material ~= Enum.Material.Water
        end
        
        return true -- If not terrain, assume land
    end)
    
    return success and result
end

-- Generate intelligent scan points
local function generateScanPoints(islandName)
    local bounds = intelligentScanner.islandBounds[islandName]
    if not bounds then return {} end
    
    local points = {}
    local count = intelligentScanner.settings.scanPoints
    
    local minX = math.min(bounds.corner1.X, bounds.corner2.X)
    local maxX = math.max(bounds.corner1.X, bounds.corner2.X)
    local minZ = math.min(bounds.corner1.Z, bounds.corner2.Z)
    local maxZ = math.max(bounds.corner1.Z, bounds.corner2.Z)
    local avgY = (bounds.corner1.Y + bounds.corner2.Y) / 2
    
    if intelligentScanner.settings.scanType == "terrain" then
        -- Smart terrain-based grid distribution
        local gridSize = math.ceil(math.sqrt(count))
        local stepX = (maxX - minX) / gridSize
        local stepZ = (maxZ - minZ) / gridSize
        
        for i = 0, gridSize - 1 do
            for j = 0, gridSize - 1 do
                if #points >= count then break end
                
                local baseX = minX + (i + 0.5) * stepX
                local baseZ = minZ + (j + 0.5) * stepZ
                
                -- Add randomization within grid cell
                local randomX = baseX + (math.random() - 0.5) * stepX * 0.6
                local randomZ = baseZ + (math.random() - 0.5) * stepZ * 0.6
                local randomY = avgY + math.random(-30, 120)
                
                local point = Vector3.new(randomX, randomY, randomZ)
                
                -- Terrain validation
                if intelligentScanner.settings.landOnly then
                    local attempts = 0
                    while not isOnLand(point) and attempts < 8 do
                        randomX = baseX + (math.random() - 0.5) * stepX
                        randomZ = baseZ + (math.random() - 0.5) * stepZ
                        randomY = avgY + math.random(-30, 120)
                        point = Vector3.new(randomX, randomY, randomZ)
                        attempts = attempts + 1
                    end
                end
                
                table.insert(points, point)
            end
        end
    else
        -- Pure random distribution
        for i = 1, count do
            local attempts = 0
            local point
            
            repeat
                local randomX = minX + (maxX - minX) * math.random()
                local randomZ = minZ + (maxZ - minZ) * math.random()
                local randomY = avgY + math.random(-30, 120)
                point = Vector3.new(randomX, randomY, randomZ)
                attempts = attempts + 1
            until not intelligentScanner.settings.landOnly or isOnLand(point) or attempts > 15
            
            table.insert(points, point)
        end
    end
    
    -- Add known horse locations for intelligent targeting
    if intelligentScanner.settings.smartTargeting then
        local currentTime = tick()
        for location, data in pairs(intelligentScanner.knownHorseLocations) do
            if currentTime - data.lastSeen < 300 and data.island == islandName then -- 5 minutes
                if #points < count * 1.5 then -- Don't exceed 150% of scan points
                    table.insert(points, 1, data.position) -- Add at beginning for priority
                end
            end
        end
    end
    
    return points
end

-- Scan horses at current position
local function scanHorsesAtPosition(position)
    local foundHorses = {}
    local currentTime = tick()
    
    pcall(function()
        local currentIsland = detectCurrentIsland()
        local islandObject = nil
        
        if Workspace.Islands:FindFirstChild(currentIsland) then
            islandObject = Workspace.Islands[currentIsland]
        end
        
        if islandObject then
            for _, child in pairs(islandObject:GetChildren()) do
                if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                    local distance = (position - child.HumanoidRootPart.Position).Magnitude
                    
                    if distance <= 512 then -- Within streaming range
                        local humanoid = child:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                            -- Check if wild horse
                            local isWild = false
                            local horseName = "Unknown"
                            
                            pcall(function()
                                local overhead = child:FindFirstChild("OverheadPart")
                                if overhead and overhead:FindFirstChild("Overhead") then
                                    local nameLabel = overhead.Overhead:FindFirstChild("NameLabel")
                                    if nameLabel and nameLabel.Text == "Wild" then
                                        isWild = true
                                    end
                                    
                                    local breedLabel = overhead.Overhead:FindFirstChild("BreedLabel")
                                    if breedLabel and breedLabel.Text ~= "" then
                                        horseName = breedLabel.Text
                                    else
                                        horseName = child.Name:sub(2, 9) .. "..."
                                    end
                                end
                            end)
                            
                            if isWild then
                                foundHorses[child.Name] = {
                                    object = child,
                                    name = horseName,
                                    position = child.HumanoidRootPart.Position,
                                    distance = distance,
                                    island = currentIsland,
                                    scanPoint = position,
                                    timestamp = currentTime
                                }
                                
                                -- Add to known locations for future intelligent targeting
                                intelligentScanner.knownHorseLocations[child.Name] = {
                                    position = child.HumanoidRootPart.Position,
                                    island = currentIsland,
                                    lastSeen = currentTime,
                                    name = horseName
                                }
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return foundHorses
end

-- Start intelligent scanning
local function startIntelligentScan()
    if intelligentScanner.isScanning then return false end
    
    local currentIsland = detectCurrentIsland()
    if not intelligentScanner.islandBounds[currentIsland] then
        Rayfield:Notify({
           Title = "❌ Island Not Configured",
           Content = "No scanning bounds set for " .. currentIsland,
           Duration = 4,
           Image = 4483362458,
        })
        return false
    end
    
    intelligentScanner.isScanning = true
    intelligentScanner.isPaused = false
    intelligentScanner.runtime.originalPosition = humanoidRootPart.CFrame
    intelligentScanner.runtime.scanStartTime = tick()
    intelligentScanner.runtime.horsesFoundThisScan = 0
    intelligentScanner.runtime.currentScanIndex = 0
    
    -- Generate scan points
    intelligentScanner.runtime.currentScanPoints = generateScanPoints(currentIsland)
    intelligentScanner.runtime.totalScanPoints = #intelligentScanner.runtime.currentScanPoints
    
    Rayfield:Notify({
       Title = "🚀 Intelligent Scan Started",
       Content = "Island: " .. currentIsland .. " | Points: " .. intelligentScanner.runtime.totalScanPoints .. " | Type: " .. intelligentScanner.settings.scanType:upper(),
       Duration = 3,
       Image = 4483362458,
    })
    
    return true
end

-- Stop intelligent scanning
local function stopIntelligentScan()
    intelligentScanner.isScanning = false
    intelligentScanner.isPaused = false
    
    if intelligentScanner.runtime.originalPosition then
        humanoidRootPart.CFrame = intelligentScanner.runtime.originalPosition
    end
    
    local scanTime = tick() - intelligentScanner.runtime.scanStartTime
    
    Rayfield:Notify({
       Title = "🏁 Intelligent Scan Complete",
       Content = "Found: " .. intelligentScanner.runtime.horsesFoundThisScan .. " horses | Time: " .. string.format("%.1f", scanTime) .. "s",
       Duration = 4,
       Image = 4483362458,
    })
end

-- Pause/Resume scanning
local function toggleScanPause()
    intelligentScanner.isPaused = not intelligentScanner.isPaused
    
    Rayfield:Notify({
       Title = intelligentScanner.isPaused and "⏸️ Scan Paused" or "▶️ Scan Resumed",
       Content = intelligentScanner.isPaused and "Scanning paused" or "Scanning resumed",
       Duration = 2,
       Image = 4483362458,
    })
end

-- =================================
-- PROFESSIONAL CAPTURE PROGRESS SYSTEM
-- =================================
local captureProgressSystem = {
    trackedHorses = {},
    lastUpdate = 0,
    updateInterval = 0.5,
    maxTracked = 100
}

local function getCaptureProgress(horse)
    if not horse or not horse.Parent then return nil end
    
    local progressData = {
        current = 0,
        max = 0,
        text = "0/0",
        isComplete = false,
        exists = false
    }
    
    pcall(function()
        local captureProgress = horse:FindFirstChild("CaptureProgress")
        if captureProgress then
            local progress = captureProgress:FindFirstChild("Progress")
            if progress then
                local textLabel = progress:FindFirstChild("TextLabel")
                if textLabel and textLabel.Text then
                    progressData.exists = true
                    progressData.text = textLabel.Text
                    
                    local current, max = progressData.text:match("(%d+)/(%d+)")
                    if current and max then
                        progressData.current = tonumber(current)
                        progressData.max = tonumber(max)
                        progressData.isComplete = (progressData.current >= progressData.max and progressData.max > 0)
                    end
                end
            end
        end
    end)
    
    return progressData
end

local function updateCaptureProgressTracking()
    local currentTime = tick()
    if currentTime - captureProgressSystem.lastUpdate < captureProgressSystem.updateInterval then
        return
    end
    
    captureProgressSystem.lastUpdate = currentTime
    
    for horseId, data in pairs(captureProgressSystem.trackedHorses) do
        if currentTime - data.lastSeen > 30 then
            captureProgressSystem.trackedHorses[horseId] = nil
        end
    end
end

-- =================================
-- NOCLIP SYSTEM FOR SMOOTH MODE
-- =================================
local noclipSystem = {
    active = false,
    originalCanCollide = {},
    connections = {}
}

local function enableNoclip()
    if noclipSystem.active then return end
    
    noclipSystem.active = true
    
    local function setNoclip(object)
        if object:IsA("BasePart") and object.CanCollide then
            noclipSystem.originalCanCollide[object] = true
            object.CanCollide = false
        end
    end
    
    pcall(function()
        for _, part in pairs(character:GetChildren()) do
            setNoclip(part)
        end
    end)
    
    noclipSystem.connections.childAdded = character.ChildAdded:Connect(function(child)
        if noclipSystem.active then
            wait(0.1)
            setNoclip(child)
        end
    end)
end

local function disableNoclip()
    if not noclipSystem.active then return end
    
    noclipSystem.active = false
    
    pcall(function()
        for part, _ in pairs(noclipSystem.originalCanCollide) do
            if part and part.Parent then
                part.CanCollide = true
            end
        end
    end)
    
    noclipSystem.originalCanCollide = {}
    
    if noclipSystem.connections.childAdded then
        noclipSystem.connections.childAdded:Disconnect()
        noclipSystem.connections.childAdded = nil
    end
end

-- =================================
-- PROFESSIONAL CACHING SYSTEM
-- =================================
local Cache = {
    horses = {},
    horsesById = {},
    lastUpdate = 0,
    updateInterval = 1.5,
    maxCacheSize = 500,
    islandHorses = {}
}

-- =================================
-- ULTRA-OPTIMIZED HORSE CATCHER SYSTEM
-- =================================
local horseCatcher = {
    isRunning = false,
    currentTarget = nil,
    currentTargetProgress = nil,
    isAttached = false,
    lassoEquipped = false,
    currentLassoID = nil,
    
    connections = {
        capture = nil,
        targeting = nil,
        movement = nil,
        cleanup = nil,
        islandMonitor = nil,
        progressMonitor = nil,
        lassoProtection = nil,
        intelligentScanner = nil -- NEW: Intelligent scanner connection
    },
    
    capturedHorses = {},
    statistics = {
        totalCaptured = 0,
        sessionsRun = 0,
        currentStreak = 0,
        totalAttempts = 0,
        successfulCaptures = 0,
        bestStreak = 0,
        averageCaptureTime = 0,
        horsesPerMinute = 0,
        islandStats = {},
        progressStats = {
            totalProgressHits = 0,
            averageProgressToCapture = 0,
            fastestCapture = 999,
            slowestCapture = 0
        },
        scanningStats = { -- NEW: Scanning statistics
            totalScans = 0,
            horsesFoundByScanning = 0,
            averageScanTime = 0,
            lastScanEfficiency = 0
        }
    },
    
    settings = {
        movementMode = "attachment",
        pulseInterval = 0.8,
        pulseDistance = 8,
        captureCooldown = 0.4,
        smartTargeting = true,
        aggressiveTargeting = true,
        
        progressMonitoring = true,
        abandonOnStuckProgress = true,
        maxStuckProgressTime = 15,
        
        safeDistance = 5,
        attachmentOffset = 4,
        targetingRadius = 300,
        batchProcessing = true,
        maxBatchSize = 5,
        
        -- NEW: Scanning integration settings
        autoScanWhenNoTargets = true,
        pauseScanningWhenCatching = true,
        preferScannedTargets = true
    },
    
    runtime = {
        lastCaptureTime = 0,
        lastPulseTime = 0,
        lastTargetingTime = 0,
        lastCleanupTime = 0,
        lastIslandCheck = 0,
        lastProgressCheck = 0,
        lastLassoCheck = 0,
        
        currentTargetStartTime = 0,
        lastProgressChange = 0,
        lastProgressValue = "0/0",
        progressStuckTime = 0,
        
        sessionStartTime = 0,
        lastSuccessfulCapture = 0,
        forceDetach = false,
        targetingCount = 0,
        captureAttempts = 0,
        currentIslandHorses = 0,
        
        -- NEW: Scanning integration runtime
        lastAutoScanTime = 0,
        isUsingScannedTarget = false
    },
    
    performance = {
        captureTimes = {},
        targetingTimes = {},
        movementTimes = {},
        islandScanTimes = {},
        progressCheckTimes = {},
        maxCaptureTime = 0,
        avgCaptureTime = 0
    }
}

-- Game System Detection
local gameSystem = {
    u1 = nil,
    u2 = nil, 
    u3 = nil,
    available = false,
    remoteEvent = nil,
    networkReady = false
}

pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.networkReady = (gameSystem.u2 and gameSystem.u2.Network) and true or false
    gameSystem.remoteEvent = ReplicatedStorage.Communication.Events['']
end)

-- =================================
-- ULTRA-OPTIMIZED HORSE FUNCTIONS
-- =================================

local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    local cached = Cache.horsesById[horse.Name]
    if cached and cached.name then
        return cached.name
    end
    
    local horseName = "Unknown"
    local success = pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" then
                    horseName = breedLabel.Text
                else
                    horseName = horse.Name:sub(2, 9)
                end
            end
        end
    end)
    
    if success then
        Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
        Cache.horsesById[horse.Name].name = horseName
    end
    
    return horseName
end

local function isWildHorse(horse)
    if not horse then return false end
    
    local cached = Cache.horsesById[horse.Name]
    if cached and cached.isWild ~= nil then
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
        Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
        Cache.horsesById[horse.Name].isWild = isWild
    end
    
    return isWild
end

-- ENHANCED: Horse cache with intelligent scanning integration
local function updateHorseCache()
    local currentTime = tick()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    local startTime = tick()
    Cache.horses = {}
    Cache.islandHorses = {}
    local horseCount = 0
    local currentIsland = detectCurrentIsland()
    
    local function scanLocation(location, islandName, priority)
        if not location then return end
        
        local children = location:GetChildren()
        local localHorseCount = 0
        
        for i = 1, #children do
            local child = children[i]
            
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseCatcher.capturedHorses[child.Name] then
                        local distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        
                        horseCount = horseCount + 1
                        localHorseCount = localHorseCount + 1
                        
                        -- NEW: Mark if this horse was found by scanning
                        local wasScanned = intelligentScanner.knownHorseLocations[child.Name] ~= nil
                        
                        Cache.horses[horseCount] = {
                            horse = child,
                            island = islandName,
                            priority = wasScanned and (priority - 0.5) or priority, -- Scanned horses get higher priority
                            distance = distance,
                            wasScanned = wasScanned
                        }
                        
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
        
        Cache.islandHorses[islandName] = localHorseCount
    end
    
    pcall(function()
        if Workspace.Islands then
            local currentIslandPriority = 1
            
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island:IsA("Model") and island.Name ~= "Islands" then
                    local priority = (island.Name == currentIsland) and currentIslandPriority or 2
                    scanLocation(island, island.Name, priority)
                end
            end
            
            if Workspace.Islands:FindFirstChild("Mainland") then
                local priority = (currentIsland == "Mainland") and currentIslandPriority or 2
                scanLocation(Workspace.Islands.Mainland, "Mainland", priority)
            end
        end
    end)
    
    -- NEW: Add known horse locations from intelligent scanner
    for horseId, locationData in pairs(intelligentScanner.knownHorseLocations) do
        if currentTime - locationData.lastSeen < 180 then -- 3 minutes
            if not horseCatcher.capturedHorses[horseId] then
                local distance = (humanoidRootPart.Position - locationData.position).Magnitude
                
                if distance <= horseCatcher.settings.targetingRadius * 1.5 then
                    horseCount = horseCount + 1
                    
                    Cache.horses[horseCount] = {
                        horse = nil, -- Will be found when we get closer
                        island = locationData.island .. " (Scanned)",
                        priority = 0.5, -- Highest priority for scanned locations
                        distance = distance,
                        wasScanned = true,
                        knownLocation = locationData
                    }
                end
            end
        else
            -- Clean up old locations
            intelligentScanner.knownHorseLocations[horseId] = nil
        end
    end
    
    table.sort(Cache.horses, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.distance < b.distance
        end
    end)
    
    Cache.lastUpdate = currentTime
    
    local scanTime = tick() - startTime
    table.insert(horseCatcher.performance.targetingTimes, scanTime)
    table.insert(horseCatcher.performance.islandScanTimes, scanTime)
    if #horseCatcher.performance.targetingTimes > 100 then
        table.remove(horseCatcher.performance.targetingTimes, 1)
    end
    if #horseCatcher.performance.islandScanTimes > 50 then
        table.remove(horseCatcher.performance.islandScanTimes, 1)
    end
    
    horseCatcher.runtime.targetingCount = horseCatcher.runtime.targetingCount + 1
    horseCatcher.runtime.currentIslandHorses = Cache.islandHorses[currentIsland] or 0
    
    return Cache.horses
end

-- Auto-equip and protect lasso system (always active)
local function equipLasso()
    if horseCatcher.lassoEquipped and horseCatcher.currentLassoID then
        return true, horseCatcher.currentLassoID
    end
    
    local success = false
    local toolID = nil
    
    if gameSystem.available and gameSystem.u3 and gameSystem.networkReady then
        local lastEquipped = gameSystem.u3.GetLocal({"lastEquippedLasso"})
        if lastEquipped then
            local inventoryItem = gameSystem.u3.GetLocal({"inventory", lastEquipped})
            if inventoryItem then
                pcall(function()
                    local currentlyEquipped = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
                    if currentlyEquipped ~= lastEquipped then
                        gameSystem.u2.Network:FireServer("Inventory", "Use", lastEquipped)
                    end
                    success = true
                    toolID = lastEquipped
                end)
            end
        else
            pcall(function()
                local inventory = gameSystem.u3.GetLocal({"inventory"}) or {}
                for itemId, itemData in pairs(inventory) do
                    if itemId:find("{") and itemData.id then
                        local itemInfo = gameSystem.u1.Items.GetInfo(itemData.id)
                        if itemInfo and itemInfo.name and itemInfo.name:lower():find("lasso") then
                            gameSystem.u2.Network:FireServer("Inventory", "Use", itemId)
                            success = true
                            toolID = itemId
                            break
                        end
                    end
                end
            end)
        end
    end
    
    if not success then
        toolID = "{60769f1f-cade-463b-ae32-adaacc91116f}"
        success = true
    end
    
    if success then
        horseCatcher.lassoEquipped = true
        horseCatcher.currentLassoID = toolID
    end
    
    return success, toolID
end

-- Lasso protection system (always active)
local function protectLasso()
    if not horseCatcher.isRunning then
        return
    end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastLassoCheck < 1 then
        return
    end
    
    horseCatcher.runtime.lastLassoCheck = currentTime
    
    pcall(function()
        if gameSystem.available and gameSystem.u3 and gameSystem.networkReady then
            local currentlyEquipped = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
            
            if not currentlyEquipped or currentlyEquipped ~= horseCatcher.currentLassoID then
                if horseCatcher.currentLassoID then
                    local inventoryItem = gameSystem.u3.GetLocal({"inventory", horseCatcher.currentLassoID})
                    if inventoryItem then
                        gameSystem.u2.Network:FireServer("Inventory", "Use", horseCatcher.currentLassoID)
                    else
                        equipLasso()
                    end
                end
            end
        end
    end)
end

-- ENHANCED: Find optimal target with scanning integration
local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local currentIsland = detectCurrentIsland()
    local candidates = {}
    
    for i = 1, math.min(#horses, horseCatcher.settings.maxBatchSize * 2) do
        local horseData = horses[i]
        
        -- Handle known locations from scanning
        if horseData.knownLocation and not horseData.horse then
            -- Try to find the actual horse object now that we're targeting it
            local knownLoc = horseData.knownLocation
            local distance = (playerPos - knownLoc.position).Magnitude
            
            if distance <= horseCatcher.settings.targetingRadius then
                -- Teleport closer to try to load the horse
                local targetPos = knownLoc.position + Vector3.new(0, 50, 0)
                humanoidRootPart.CFrame = CFrame.new(targetPos)
                wait(0.5) -- Wait for streaming
                
                -- Try to find the horse now
                local currentIslandObj = Workspace.Islands:FindFirstChild(currentIsland)
                if currentIslandObj then
                    for _, child in pairs(currentIslandObj:GetChildren()) do
                        if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                            local childDist = (knownLoc.position - child.HumanoidRootPart.Position).Magnitude
                            if childDist < 100 then -- Close to known location
                                horseData.horse = child
                                horseCatcher.runtime.isUsingScannedTarget = true
                                break
                            end
                        end
                    end
                end
            end
        end
        
        if horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            local horse = horseData.horse
            local horsePos = horse.HumanoidRootPart.Position
            local distance = (playerPos - horsePos).Magnitude
            local velocity = horse.HumanoidRootPart.Velocity.Magnitude
            
            if distance > horseCatcher.settings.targetingRadius then
                continue
            end
            
            local score = 1000
            
            -- Enhanced scoring with scanning bonus
            if horseData.wasScanned then
                score = score + 300 -- Bonus for scanned horses
            end
            
            if horseData.island == currentIsland then
                score = score + 500
            elseif horseData.priority == 1 then
                score = score + 200
            end
            
            if distance < 50 then
                score = score + 300
            elseif distance < 100 then
                score = score + 200
            elseif distance < 200 then
                score = score + 100
            else
                score = score - (distance * 0.5)
            end
            
            if velocity > 5 then
                score = score + 400
            elseif velocity > 2 then
                score = score + 200
            elseif velocity > 0.5 then
                score = score + 100
            else
                score = score - 100
            end
            
            local heightDiff = math.abs(horsePos.Y - playerPos.Y)
            if heightDiff < 10 then
                score = score + 150
            elseif heightDiff < 25 then
                score = score + 50
            else
                score = score - (heightDiff * 2)
            end
            
            local raycast = workspace:Raycast(playerPos, (horsePos - playerPos).Unit * distance)
            if not raycast or raycast.Instance == horse then
                score = score + 100
            end
            
            table.insert(candidates, {
                horse = horse,
                score = score,
                distance = distance,
                velocity = velocity,
                island = horseData.island,
                priority = horseData.priority,
                wasScanned = horseData.wasScanned
            })
        end
    end
    
    if #candidates > 0 then
        table.sort(candidates, function(a, b) return a.score > b.score end)
        return candidates[1].horse
    end
    
    return nil
end

local function captureHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") or not horseCatcher.currentLassoID then
        return false
    end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCaptureTime < horseCatcher.settings.captureCooldown then
        return false
    end
    
    local startTime = tick()
    local success = false
    
    pcall(function()
        if gameSystem.available and gameSystem.networkReady then
            gameSystem.u2.Network:FireServer("Equipment", horseCatcher.currentLassoID, "Activate", horse)
            success = true
        end
        
        horseCatcher.runtime.lastCaptureTime = currentTime
        horseCatcher.runtime.captureAttempts = horseCatcher.runtime.captureAttempts + 1
        horseCatcher.statistics.totalAttempts = horseCatcher.statistics.totalAttempts + 1
    end)
    
    if success then
        local captureTime = tick() - startTime
        table.insert(horseCatcher.performance.captureTimes, captureTime)
        if #horseCatcher.performance.captureTimes > 1000 then
            table.remove(horseCatcher.performance.captureTimes, 1)
        end
        
        if captureTime > horseCatcher.performance.maxCaptureTime then
            horseCatcher.performance.maxCaptureTime = captureTime
        end
    end
    
    return success
end

-- Movement functions
local function pulseTeleportToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastPulseTime < horseCatcher.settings.pulseInterval then
        return false
    end
    
    pcall(function()
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local horseVelocity = horseRoot.Velocity
        
        local prediction = horsePos + (horseVelocity * 0.4)
        
        local approaches = {
            horseRoot.CFrame.RightVector * horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.RightVector * -horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.LookVector * -horseCatcher.settings.pulseDistance,
            (horseRoot.CFrame.RightVector + horseRoot.CFrame.LookVector).Unit * horseCatcher.settings.pulseDistance
        }
        
        local bestOffset = approaches[1]
        local shortestDist = math.huge
        local playerPos = humanoidRootPart.Position
        
        for _, offset in pairs(approaches) do
            local targetPos = prediction + offset
            local dist = (playerPos - targetPos).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                bestOffset = offset
            end
        end
        
        local heightOffset = Vector3.new(0, 3, 0)
        local finalPos = prediction + bestOffset + heightOffset
        
        humanoidRootPart.CFrame = CFrame.lookAt(finalPos, horsePos)
        horseCatcher.runtime.lastPulseTime = currentTime
    end)
    
    return true
end

local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if (attachment.Name == "HorseAttachment" or attachment.Name:find("Weld")) and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local horseVelocity = horseRoot.Velocity
        
        local prediction = horsePos + (horseVelocity * 0.2)
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.settings.attachmentOffset
        local heightOffset = Vector3.new(0, 3.5, 0)
        
        humanoidRootPart.CFrame = CFrame.lookAt(prediction + sideOffset + heightOffset, prediction)
        wait(0.03)
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = horseRoot
        weld.Parent = humanoidRootPart
        weld.Name = "HorseAttachment"
        
        horseCatcher.isAttached = true
    end)
    
    return true
end

-- Enhanced smooth follow with noclip
local function smoothFollow(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        local horsePos = horse.HumanoidRootPart.Position
        local horseVelocity = horse.HumanoidRootPart.Velocity
        local currentPos = humanoidRootPart.Position
        
        local prediction = horsePos + (horseVelocity * 0.3)
        local direction = (prediction - currentPos).Unit
        local distance = (prediction - currentPos).Magnitude
        
        if distance > horseCatcher.settings.safeDistance + 1 then
            local targetPos = prediction - direction * horseCatcher.settings.safeDistance
            targetPos = targetPos + Vector3.new(0, 2.5, 0)
            
            local tweenInfo = TweenInfo.new(
                0.4,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )
            
            local tween = TweenService:Create(
                humanoidRootPart,
                tweenInfo,
                {CFrame = CFrame.lookAt(targetPos, prediction)}
            )
            tween:Play()
        end
    end)
    
    return true
end

local function detachFromHorse()
    pcall(function()
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if (attachment.Name == "HorseAttachment" or attachment.Name:find("Weld")) then
                if attachment:IsA("WeldConstraint") or attachment:IsA("Weld") then
                    attachment:Destroy()
                end
            end
        end
        horseCatcher.isAttached = false
        horseCatcher.runtime.forceDetach = false
    end)
end

local function isHorseCapturedOrComplete(horse)
    if not horse or not horse.Parent then
        return true, "Horse disappeared"
    end
    
    local captured = false
    local horseName = "Unknown"
    local reason = ""
    
    pcall(function()
        local progressData = getCaptureProgress(horse)
        if progressData.exists and progressData.isComplete then
            captured = true
            reason = "Progress complete (" .. progressData.text .. ")"
        end
        
        if not captured then
            local overheadPart = horse:FindFirstChild("OverheadPart")
            if overheadPart then
                local overhead = overheadPart:FindFirstChild("Overhead")
                if overhead then
                    local nameLabel = overhead:FindFirstChild("NameLabel")
                    if nameLabel and nameLabel.Text ~= "Wild" then
                        captured = true
                        reason = "Name changed from Wild"
                    end
                    
                    local breedLabel = overhead:FindFirstChild("BreedLabel")
                    if breedLabel and breedLabel.Text ~= "" then
                        horseName = breedLabel.Text
                    end
                end
            end
        end
        
        if not captured then
            local humanoid = horse:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                captured = true
                reason = "Horse died/removed"
            end
        end
    end)
    
    if captured then
        horseCatcher.capturedHorses[horse.Name] = true
        horseCatcher.statistics.totalCaptured = horseCatcher.statistics.totalCaptured + 1
        horseCatcher.statistics.currentStreak = horseCatcher.statistics.currentStreak + 1
        horseCatcher.statistics.successfulCaptures = horseCatcher.statistics.successfulCaptures + 1
        horseCatcher.runtime.lastSuccessfulCapture = tick()
        
        -- NEW: Track if this was a scanned horse
        if horseCatcher.runtime.isUsingScannedTarget then
            horseCatcher.statistics.scanningStats.horsesFoundByScanning = horseCatcher.statistics.scanningStats.horsesFoundByScanning + 1
            horseCatcher.runtime.isUsingScannedTarget = false
        end
        
        local captureTime = tick() - horseCatcher.runtime.currentTargetStartTime
        if captureTime < horseCatcher.statistics.progressStats.fastestCapture then
            horseCatcher.statistics.progressStats.fastestCapture = captureTime
        end
        if captureTime > horseCatcher.statistics.progressStats.slowestCapture then
            horseCatcher.statistics.progressStats.slowestCapture = captureTime
        end
        
        local currentIsland = detectCurrentIsland()
        if not horseCatcher.statistics.islandStats[currentIsland] then
            horseCatcher.statistics.islandStats[currentIsland] = 0
        end
        horseCatcher.statistics.islandStats[currentIsland] = horseCatcher.statistics.islandStats[currentIsland] + 1
        
        if horseCatcher.statistics.currentStreak > horseCatcher.statistics.bestStreak then
            horseCatcher.statistics.bestStreak = horseCatcher.statistics.currentStreak
        end
        
        local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
        horseCatcher.statistics.horsesPerMinute = (horseCatcher.statistics.currentStreak / (sessionTime / 60))
        
        Rayfield:Notify({
           Title = "🎉 " .. horseName .. " Captured!",
           Content = "Island: " .. currentIsland .. " | Reason: " .. reason .. " | Time: " .. string.format("%.1f", captureTime) .. "s | Streak: " .. horseCatcher.statistics.currentStreak .. (horseCatcher.runtime.isUsingScannedTarget and " (Scanned)" or ""),
           Duration = 3,
           Image = 4483362458,
        })
        
        -- NEW: Resume scanning after capture if enabled
        if intelligentScanner.settings.autoScan and not intelligentScanner.isScanning then
            local currentTime = tick()
            if currentTime - horseCatcher.runtime.lastAutoScanTime > 30 then -- Don't scan too frequently
                horseCatcher.runtime.lastAutoScanTime = currentTime
                startIntelligentScan()
            end
        end
    end
    
    return captured, reason
end

local function cleanupSystem()
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCleanupTime < 15 then
        return
    end
    
    if #Cache.horses > Cache.maxCacheSize * 0.8 then
        for i = Cache.maxCacheSize * 0.6, #Cache.horses do
            Cache.horses[i] = nil
        end
    end
    
    if #horseCatcher.performance.captureTimes > 1000 then
        for i = 1, 500 do
            table.remove(horseCatcher.performance.captureTimes, 1)
        end
    end
    
    updateCaptureProgressTracking()
    
    -- NEW: Clean up old known horse locations
    local currentTime = tick()
    for horseId, data in pairs(intelligentScanner.knownHorseLocations) do
        if currentTime - data.lastSeen > 600 then -- 10 minutes
            intelligentScanner.knownHorseLocations[horseId] = nil
        end
    end
    
    horseCatcher.runtime.lastCleanupTime = currentTime
end

-- =================================
-- ENHANCED MAIN LOGIC WITH INTELLIGENT SCANNING
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    local lassoReady, lassoID = equipLasso()
    if not lassoReady then
        Rayfield:Notify({
           Title = "❌ Lasso Required!",
           Content = "No lasso found in inventory!",
           Duration = 4,
           Image = 4483362458,
        })
        return false
    end
    
    if not gameSystem.available or not gameSystem.networkReady then
        Rayfield:Notify({
           Title = "❌ Network System Error!",
           Content = "Cannot access game network system!",
           Duration = 4,
           Image = 4483362458,
        })
        return false
    end
    
    horseCatcher.isRunning = true
    horseCatcher.runtime.sessionStartTime = tick()
    horseCatcher.statistics.sessionsRun = horseCatcher.statistics.sessionsRun + 1
    horseCatcher.statistics.currentStreak = 0
    horseCatcher.runtime.lastCaptureTime = 0
    horseCatcher.runtime.lastPulseTime = 0
    horseCatcher.runtime.targetingCount = 0
    horseCatcher.runtime.captureAttempts = 0
    horseCatcher.runtime.lastIslandCheck = 0
    horseCatcher.runtime.lastProgressCheck = 0
    horseCatcher.runtime.lastLassoCheck = 0
    horseCatcher.runtime.lastAutoScanTime = 0
    horseCatcher.runtime.isUsingScannedTarget = false
    
    horseCatcher.runtime.currentTargetStartTime = 0
    horseCatcher.runtime.lastProgressChange = 0
    horseCatcher.runtime.lastProgressValue = "0/0"
    horseCatcher.runtime.progressStuckTime = 0
    
    local movementMode = horseCatcher.settings.movementMode == "pulse" and "Pulse TP" or 
                        horseCatcher.settings.movementMode == "attachment" and "Attachment" or "Smooth"
    
    local currentIsland = detectCurrentIsland()
    
    -- Enable noclip for smooth mode
    if horseCatcher.settings.movementMode == "smooth" then
        enableNoclip()
    end
    
    -- NEW: Start auto scanning if enabled
    if intelligentScanner.settings.autoScan then
        startIntelligentScan()
    end
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Catching Started!",
       Content = "Island: " .. currentIsland .. " | Mode: " .. movementMode .. (horseCatcher.settings.movementMode == "smooth" and " (Noclip)" or "") .. (intelligentScanner.settings.autoScan and " | Auto-Scan ON" or ""),
       Duration = 3,
       Image = 4483362458,
    })
    
    horseCatcher.connections.islandMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastIslandCheck < 5 then
            return
        end
        
        detectCurrentIsland()
        horseCatcher.runtime.lastIslandCheck = currentTime
    end)
    
    horseCatcher.connections.lassoProtection = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        protectLasso()
    end)
    
    horseCatcher.connections.progressMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning or not horseCatcher.currentTarget then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastProgressCheck < 0.5 then
            return
        end
        
        local startTime = tick()
        local progressData = getCaptureProgress(horseCatcher.currentTarget)
        
        if progressData.exists then
            horseCatcher.currentTargetProgress = progressData
            
            if progressData.text ~= horseCatcher.runtime.lastProgressValue then
                horseCatcher.runtime.lastProgressChange = currentTime
                horseCatcher.runtime.lastProgressValue = progressData.text
                horseCatcher.runtime.progressStuckTime = 0
                
                horseCatcher.statistics.progressStats.totalProgressHits = horseCatcher.statistics.progressStats.totalProgressHits + 1
            else
                horseCatcher.runtime.progressStuckTime = currentTime - horseCatcher.runtime.lastProgressChange
            end
        end
        
        horseCatcher.runtime.lastProgressCheck = currentTime
        
        local checkTime = tick() - startTime
        table.insert(horseCatcher.performance.progressCheckTimes, checkTime)
        if #horseCatcher.performance.progressCheckTimes > 100 then
            table.remove(horseCatcher.performance.progressCheckTimes, 1)
        end
    end)
    
    -- NEW: Intelligent scanner connection
    horseCatcher.connections.intelligentScanner = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning or not intelligentScanner.enabled then return end
        
        local currentTime = tick()
        
        -- Pause scanning when actively catching a horse
        if horseCatcher.settings.pauseScanningWhenCatching and horseCatcher.currentTarget then
            if intelligentScanner.isScanning and not intelligentScanner.isPaused then
                intelligentScanner.isPaused = true
            end
            return
        else
            if intelligentScanner.isScanning and intelligentScanner.isPaused then
                intelligentScanner.isPaused = false
            end
        end
        
        -- Auto-start scanning when no targets found
        if horseCatcher.settings.autoScanWhenNoTargets and not horseCatcher.currentTarget then
            if not intelligentScanner.isScanning and currentTime - horseCatcher.runtime.lastAutoScanTime > 60 then -- Every minute
                horseCatcher.runtime.lastAutoScanTime = currentTime
                startIntelligentScan()
            end
        end
        
        -- Continue scanning process
        if intelligentScanner.isScanning and not intelligentScanner.isPaused then
            if currentTime - intelligentScanner.runtime.lastScanTime >= intelligentScanner.settings.scanSpeed then
                intelligentScanner.runtime.lastScanTime = currentTime
                
                if intelligentScanner.runtime.currentScanIndex < intelligentScanner.runtime.totalScanPoints then
                    intelligentScanner.runtime.currentScanIndex = intelligentScanner.runtime.currentScanIndex + 1
                    local scanPoint = intelligentScanner.runtime.currentScanPoints[intelligentScanner.runtime.currentScanIndex]
                    
                    if scanPoint then
                        -- Teleport to scan point
                        humanoidRootPart.CFrame = CFrame.new(scanPoint)
                        
                        -- Scan for horses
                        spawn(function()
                            wait(intelligentScanner.settings.scanSpeed * 0.5) -- Wait half the scan speed for streaming
                            local foundHorses = scanHorsesAtPosition(scanPoint)
                            intelligentScanner.runtime.horsesFoundThisScan = intelligentScanner.runtime.horsesFoundThisScan + table.getn(foundHorses)
                            intelligentScanner.runtime.totalHorsesFound = intelligentScanner.runtime.totalHorsesFound + table.getn(foundHorses)
                        end)
                    end
                else
                    -- Scanning complete
                    stopIntelligentScan()
                    horseCatcher.statistics.scanningStats.totalScans = horseCatcher.statistics.scanningStats.totalScans + 1
                    horseCatcher.statistics.scanningStats.lastScanEfficiency = intelligentScanner.runtime.horsesFoundThisScan / intelligentScanner.runtime.totalScanPoints
                end
            end
        end
    end)
    
    horseCatcher.connections.capture = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        if horseCatcher.currentTarget then
            local captured, reason = isHorseCapturedOrComplete(horseCatcher.currentTarget)
            if captured then
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.currentTargetProgress = nil
                horseCatcher.runtime.currentTargetStartTime = 0
                horseCatcher.runtime.lastProgressChange = 0
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.runtime.progressStuckTime = 0
                return
            end
        end
        
        if horseCatcher.currentTarget and horseCatcher.settings.abandonOnStuckProgress then
            if horseCatcher.runtime.progressStuckTime > horseCatcher.settings.maxStuckProgressTime then
                Rayfield:Notify({
                   Title = "⏭️ Skipping Stuck Horse",
                   Content = "No progress for " .. math.floor(horseCatcher.runtime.progressStuckTime) .. "s - Moving to next target",
                   Duration = 2,
                   Image = 4483362458,
                })
                
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.currentTargetProgress = nil
                horseCatcher.runtime.currentTargetStartTime = 0
                horseCatcher.runtime.lastProgressChange = 0
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.runtime.progressStuckTime = 0
                return
            end
        end
        
        if not horseCatcher.currentTarget then
            if horseCatcher.settings.smartTargeting then
                horseCatcher.currentTarget = findOptimalTarget()
            else
                local horses = updateHorseCache()
                horseCatcher.currentTarget = horses[1] and (horses[1].horse or horses[1])
            end
            
            if horseCatcher.currentTarget then
                horseCatcher.runtime.currentTargetStartTime = tick()
                horseCatcher.runtime.lastProgressChange = tick()
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.runtime.progressStuckTime = 0
                horseCatcher.currentTargetProgress = getCaptureProgress(horseCatcher.currentTarget)
            else
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                return
            end
        end
        
        if horseCatcher.currentTarget then
            if horseCatcher.settings.movementMode == "pulse" then
                pulseTeleportToHorse(horseCatcher.currentTarget)
            elseif horseCatcher.settings.movementMode == "attachment" then
                if not horseCatcher.isAttached or horseCatcher.runtime.forceDetach then
                    attachToHorse(horseCatcher.currentTarget)
                end
            elseif horseCatcher.settings.movementMode == "smooth" then
                smoothFollow(horseCatcher.currentTarget)
            end
            
            captureHorse(horseCatcher.currentTarget)
        else
            if horseCatcher.settings.movementMode == "attachment" then
                detachFromHorse()
            end
        end
    end)
    
    horseCatcher.connections.cleanup = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        cleanupSystem()
    end)
    
    return true
end

local function stopHorseCatching()
    horseCatcher.isRunning = false
    
    -- Stop intelligent scanning
    if intelligentScanner.isScanning then
        stopIntelligentScan()
    end
    
    -- Disable noclip
    disableNoclip()
    
    for name, connection in pairs(horseCatcher.connections) do
        if connection then
            connection:Disconnect()
            horseCatcher.connections[name] = nil
        end
    end
    
    for name, connection in pairs(intelligentScanner.connections) do
        if connection then
            connection:Disconnect()
            intelligentScanner.connections[name] = nil
        end
    end
    
    detachFromHorse()
    horseCatcher.currentTarget = nil
    horseCatcher.currentTargetProgress = nil
    
    local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🏁 Session Ended",
       Content = "Island: " .. currentIsland .. " | Captured: " .. horseCatcher.statistics.currentStreak .. " | Time: " .. minutes .. "m " .. seconds .. "s | Scanned: " .. horseCatcher.statistics.scanningStats.horsesFoundByScanning,
       Duration = 5,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- ENHANCED UI WITH INTELLIGENT SCANNING
-- =================================

-- Intelligent Scanning Section
local IntelligentScanningSection = parentTab:CreateSection("🧠 Intelligent Scanning System")

local AutoScanToggle = parentTab:CreateToggle({
   Name = "🔄 Auto Scanning",
   CurrentValue = true,
   Flag = "AutoScanningToggle",
   Callback = function(Value)
      intelligentScanner.settings.autoScan = Value
   end,
})

local ScanTypeDropdown = parentTab:CreateDropdown({
   Name = "🎯 Scan Type",
   Options = {"terrain", "random"},
   CurrentOption = {"terrain"},
   MultipleOptions = false,
   Flag = "ScanTypeDropdown",
   Callback = function(Option)
      intelligentScanner.settings.scanType = Option[1]
      Rayfield:Notify({
         Title = "🎯 Scan Type Updated",
         Content = "Now using: " .. Option[1]:upper() .. " scanning",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ScanSpeedSlider = parentTab:CreateSlider({
   Name = "⚡ Scan Speed",
   Range = {0.2, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "ScanSpeedSlider",
   Callback = function(Value)
      intelligentScanner.settings.scanSpeed = Value
   end,
})

local ScanPointsSlider = parentTab:CreateSlider({
   Name = "📍 Scan Points",
   Range = {4, 25},
   Increment = 1,
   Suffix = " points",
   CurrentValue = 12,
   Flag = "ScanPointsSlider",
   Callback = function(Value)
      intelligentScanner.settings.scanPoints = Value
   end,
})

local LandOnlyToggle = parentTab:CreateToggle({
   Name = "🌱 Land Only Scanning",
   CurrentValue = true,
   Flag = "LandOnlyScanningToggle",
   Callback = function(Value)
      intelligentScanner.settings.landOnly = Value
   end,
})

local SmartTargetingToggle = parentTab:CreateToggle({
   Name = "🎯 Smart Targeting (Use Scanned Locations)",
   CurrentValue = true,
   Flag = "SmartTargetingScanToggle",
   Callback = function(Value)
      intelligentScanner.settings.smartTargeting = Value
   end,
})

-- Scanning Control Buttons
local ScanControlSection = parentTab:CreateSection("🔧 Scan Control")

local StartScanButton = parentTab:CreateButton({
   Name = "🚀 Start Manual Scan",
   Callback = function()
      if not intelligentScanner.isScanning then
         startIntelligentScan()
      else
         Rayfield:Notify({
            Title = "⚠️ Already Scanning",
            Content = "Scanning is already in progress",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

local StopScanButton = parentTab:CreateButton({
   Name = "⏹️ Stop Scan",
   Callback = function()
      if intelligentScanner.isScanning then
         stopIntelligentScan()
      end
   end,
})

local PauseScanButton = parentTab:CreateButton({
   Name = "⏸️ Pause/Resume Scan",
   Callback = function()
      if intelligentScanner.isScanning then
         toggleScanPause()
      end
   end,
})

-- CaptureProgress Control Section
local CaptureProgressSection = parentTab:CreateSection("🎯 CaptureProgress System")

local ProgressMonitoringToggle = parentTab:CreateToggle({
   Name = "📊 CaptureProgress Monitoring",
   CurrentValue = true,
   Flag = "ProgressMonitoringToggle",
   Callback = function(Value)
      horseCatcher.settings.progressMonitoring = Value
   end,
})

local AbandonStuckToggle = parentTab:CreateToggle({
   Name = "⏭️ Abandon Stuck Progress",
   CurrentValue = true,
   Flag = "AbandonStuckProgressToggle",
   Callback = function(Value)
      horseCatcher.settings.abandonOnStuckProgress = Value
   end,
})

local MaxStuckProgressSlider = parentTab:CreateSlider({
   Name = "⏳ Max Stuck Progress Time",
   Range = {5, 30},
   Increment = 1,
   Suffix = "s",
   CurrentValue = 15,
   Flag = "MaxStuckProgressSlider",
   Callback = function(Value)
      horseCatcher.settings.maxStuckProgressTime = Value
   end,
})

-- Main Control Section
local MainControlSection = parentTab:CreateSection("🎯 Professional Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Horse Catching",
   CurrentValue = false,
   Flag = "UltraHorseCatchingMainToggle",
   Callback = function(Value)
      if Value then
         local success = startHorseCatching()
         if not success then
            MainToggle:Set(false)
         end
      else
         stopHorseCatching()
      end
   end,
})

-- Scanning Integration Settings
local ScanIntegrationSection = parentTab:CreateSection("🔗 Scanning Integration")

local AutoScanNoTargetsToggle = parentTab:CreateToggle({
   Name = "🔍 Auto Scan When No Targets",
   CurrentValue = true,
   Flag = "AutoScanNoTargetsToggle",
   Callback = function(Value)
      horseCatcher.settings.autoScanWhenNoTargets = Value
   end,
})

local PauseScanCatchingToggle = parentTab:CreateToggle({
   Name = "⏸️ Pause Scanning When Catching",
   CurrentValue = true,
   Flag = "PauseScanCatchingToggle",
   Callback = function(Value)
      horseCatcher.settings.pauseScanningWhenCatching = Value
   end,
})

local PreferScannedToggle = parentTab:CreateToggle({
   Name = "⭐ Prefer Scanned Targets",
   CurrentValue = true,
   Flag = "PreferScannedTargetsToggle",
   Callback = function(Value)
      horseCatcher.settings.preferScannedTargets = Value
   end,
})

-- Movement Settings Section
local MovementSettingsSection = parentTab:CreateSection("📍 Movement & Optimization")

local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"attachment", "pulse", "smooth"},
   CurrentOption = {"attachment"},
   MultipleOptions = false,
   Flag = "UltraHorseMovementModeDropdown",
   Callback = function(Option)
      local oldMode = horseCatcher.settings.movementMode
      horseCatcher.settings.movementMode = Option[1]
      
      -- Handle noclip for smooth mode
      if horseCatcher.isRunning then
          if Option[1] == "smooth" and oldMode ~= "smooth" then
              enableNoclip()
          elseif Option[1] ~= "smooth" and oldMode == "smooth" then
              disableNoclip()
          end
      end
      
      Rayfield:Notify({
         Title = "📍 Movement Updated",
         Content = "Now using: " .. Option[1]:upper() .. " mode" .. (Option[1] == "smooth" and " (Noclip)" or ""),
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local PulseIntervalSlider = parentTab:CreateSlider({
   Name = "⚡ Pulse Interval",
   Range = {0.4, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.8,
   Flag = "UltraHorsePulseIntervalSlider",
   Callback = function(Value)
      horseCatcher.settings.pulseInterval = Value
   end,
})

local PulseDistanceSlider = parentTab:CreateSlider({
   Name = "📏 Pulse Distance", 
   Range = {4, 15},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 8,
   Flag = "UltraHorsePulseDistanceSlider",
   Callback = function(Value)
      horseCatcher.settings.pulseDistance = Value
   end,
})

local CaptureCooldownSlider = parentTab:CreateSlider({
   Name = "⏱️ Capture Cooldown",
   Range = {0.2, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.4,
   Flag = "UltraHorseCaptureCooldownSlider",
   Callback = function(Value)
      horseCatcher.settings.captureCooldown = Value
   end,
})

local SmartTargetingToggleMain = parentTab:CreateToggle({
   Name = "🧠 Smart Targeting",
   CurrentValue = true,
   Flag = "UltraHorseSmartTargetingToggle",
   Callback = function(Value)
      horseCatcher.settings.smartTargeting = Value
   end,
})

local AggressiveTargetingToggle = parentTab:CreateToggle({
   Name = "🎯 Aggressive Targeting",
   CurrentValue = true,
   Flag = "UltraHorseAggressiveTargetingToggle",
   Callback = function(Value)
      horseCatcher.settings.aggressiveTargeting = Value
   end,
})

-- Enhanced Status Section
local LiveStatusSection = parentTab:CreateSection("📊 Professional Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Island Information", Content = "Detecting current island..."})
local ScanningStatus = parentTab:CreateParagraph({Title = "🧠 Scanning Status", Content = "Intelligent scanning ready"})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Current Target", Content = "No target selected"})

-- Quick Actions Section
local QuickActionsSection = parentTab:CreateSection("⚡ Quick Actions")

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Cache",
   Callback = function()
      Cache.horses = {}
      Cache.horsesById = {}
      Cache.islandHorses = {}
      Cache.lastUpdate = 0
      horseCatcher.performance.captureTimes = {}
      horseCatcher.performance.targetingTimes = {}
      horseCatcher.performance.movementTimes = {}
      
      Rayfield:Notify({
         Title = "🗑️ Cache Cleared",
         Content = "Performance cache optimized",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ClearScannedButton = parentTab:CreateButton({
   Name = "🧠 Clear Scanned Locations",
   Callback = function()
      intelligentScanner.knownHorseLocations = {}
      Rayfield:Notify({
         Title = "🧠 Scanned Locations Cleared",
         Content = "Known horse locations cleared",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ResetCapturedButton = parentTab:CreateButton({
   Name = "🔄 Reset Captured List",
   Callback = function()
      horseCatcher.capturedHorses = {}
      Rayfield:Notify({
         Title = "✅ List Reset",
         Content = "Captured horses list cleared",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- Enhanced Statistics Section
local StatisticsSection = parentTab:CreateSection("📈 Advanced Statistics")

local SessionStats = parentTab:CreateParagraph({Title = "📈 Session Metrics", Content = "Ready for session"})
local ScanningStats = parentTab:CreateParagraph({Title = "🧠 Scanning Statistics", Content = "No scanning data yet"})
local IslandStats = parentTab:CreateParagraph({Title = "🏝️ Island Statistics", Content = "No island data yet"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(1) do
        local currentIsland = detectCurrentIsland()
        
        -- Island Information
        local islandText = "🏝️ Current Island: " .. currentIsland .. "\n"
        islandText = islandText .. "🐎 Horses on Island: " .. (horseCatcher.runtime.currentIslandHorses or 0) .. "\n"
        
        local totalIslands = 0
        local totalHorses = 0
        for islandName, horseCount in pairs(Cache.islandHorses) do
            totalIslands = totalIslands + 1
            totalHorses = totalHorses + horseCount
        end
        
        islandText = islandText .. "🌍 Islands Scanned: " .. totalIslands .. "\n"
        islandText = islandText .. "📊 Total Horses: " .. totalHorses .. "\n"
        islandText = islandText .. "🧠 Known Locations: " .. table.getn(intelligentScanner.knownHorseLocations) .. "\n"
        islandText = islandText .. "🔍 Auto-Scanning: ✅"
        
        IslandInfo:Set({Title = "🏝️ Island Information", Content = islandText})
        
        -- Enhanced Scanning Status
        local scanText = ""
        if intelligentScanner.isScanning then
            local progress = intelligentScanner.runtime.currentScanIndex / math.max(intelligentScanner.runtime.totalScanPoints, 1)
            local scanTime = tick() - intelligentScanner.runtime.scanStartTime
            
            scanText = "🚀 Status: SCANNING" .. (intelligentScanner.isPaused and " (PAUSED)" or "") .. "\n"
            scanText = scanText .. "📊 Progress: " .. intelligentScanner.runtime.currentScanIndex .. "/" .. intelligentScanner.runtime.totalScanPoints .. " (" .. string.format("%.1f", progress * 100) .. "%)\n"
            scanText = scanText .. "🎯 Type: " .. intelligentScanner.settings.scanType:upper() .. "\n"
            scanText = scanText .. "⚡ Speed: " .. intelligentScanner.settings.scanSpeed .. "s per point\n"
            scanText = scanText .. "🐎 Found This Scan: " .. intelligentScanner.runtime.horsesFoundThisScan .. "\n"
            scanText = scanText .. "⏱️ Scan Time: " .. string.format("%.1f", scanTime) .. "s"
        else
            scanText = "🎯 Status: " .. (intelligentScanner.settings.autoScan and "AUTO READY" or "MANUAL READY") .. "\n"
            scanText = scanText .. "🧠 Known Locations: " .. table.getn(intelligentScanner.knownHorseLocations) .. "\n"
            scanText = scanText .. "📊 Total Scans: " .. horseCatcher.statistics.scanningStats.totalScans .. "\n"
            scanText = scanText .. "🎯 Horses Found: " .. intelligentScanner.runtime.totalHorsesFound .. "\n"
            scanText = scanText .. "⚡ Last Efficiency: " .. string.format("%.1f", horseCatcher.statistics.scanningStats.lastScanEfficiency * 100) .. "%"
        end
        
        ScanningStatus:Set({Title = "🧠 Scanning Status", Content = scanText})
        
        -- Enhanced Target Information
        local targetText = ""
        if horseCatcher.currentTarget then
            local targetName = getHorseName(horseCatcher.currentTarget)
            local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
            local velocity = math.floor(horseCatcher.currentTarget.HumanoidRootPart.Velocity.Magnitude)
            local timeOnTarget = tick() - horseCatcher.runtime.currentTargetStartTime
            
            targetText = "🐎 " .. targetName .. (horseCatcher.runtime.isUsingScannedTarget and " (Scanned)" or "") .. "\n"
            targetText = targetText .. "📏 Distance: " .. distance .. " studs\n"
            targetText = targetText .. "🏃 Speed: " .. velocity .. " studs/s\n"
            targetText = targetText .. "⏱️ Target Time: " .. string.format("%.1f", timeOnTarget) .. "s\n"
            
            if horseCatcher.currentTargetProgress and horseCatcher.currentTargetProgress.exists then
                targetText = targetText .. "📊 Progress: " .. horseCatcher.currentTargetProgress.text
            else
                targetText = targetText .. "📊 Progress: No data"
            end
            
            if horseCatcher.settings.movementMode == "attachment" then
                targetText = targetText .. "\n🔗 Attached: " .. (horseCatcher.isAttached and "✅" or "❌")
            elseif horseCatcher.settings.movementMode == "pulse" then
                local nextPulse = math.max(0, horseCatcher.settings.pulseInterval - (tick() - horseCatcher.runtime.lastPulseTime))
                targetText = targetText .. "\n⚡ Next Pulse: " .. string.format("%.1f", nextPulse) .. "s"
            else
                targetText = targetText .. "\n🌊 Smooth Follow: ✅ (Noclip)"
            end
        else
            local wildCount = #Cache.horses
            targetText = "🔍 Scanning for targets...\n🐎 Wild horses: " .. wildCount .. "\n🎯 Smart targeting: " .. (horseCatcher.settings.smartTargeting and "✅" or "❌") .. "\n🧠 Using scanned data: " .. (horseCatcher.settings.preferScannedTargets and "✅" or "❌") .. "\n🏝️ Island horses: " .. (horseCatcher.runtime.currentIslandHorses or 0)
        end
        TargetInfo:Set({Title = "🐎 Current Target", Content = targetText})
        
        -- Enhanced Session Statistics
        if horseCatcher.isRunning then
            local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🐎 Horses Captured: " .. horseCatcher.statistics.currentStreak .. "\n"
            sessionText = sessionText .. "📈 Capture Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min\n"
            sessionText = sessionText .. "🧠 From Scanning: " .. horseCatcher.statistics.scanningStats.horsesFoundByScanning .. "\n"
            sessionText = sessionText .. "🏝️ Current Island: " .. currentIsland .. "\n"
            sessionText = sessionText .. "📊 Mode: " .. horseCatcher.settings.movementMode:upper() .. (horseCatcher.settings.movementMode == "smooth" and " (Noclip)" or "")
            
            SessionStats:Set({Title = "📈 Session Metrics", Content = sessionText})
        else
            SessionStats:Set({Title = "📈 Session Metrics", Content = "No active session\nIntelligent scanning ready\n🚀 Auto-lasso & protection ready\n🧠 Smart scanning integration"})
        end
        
        -- Enhanced Scanning Statistics
        local scanStatsText = "🧠 Total Scans: " .. horseCatcher.statistics.scanningStats.totalScans .. "\n"
        scanStatsText = scanStatsText .. "🐎 Horses Found by Scanning: " .. horseCatcher.statistics.scanningStats.horsesFoundByScanning .. "\n"
        scanStatsText = scanStatsText .. "🎯 Total Locations Known: " .. intelligentScanner.runtime.totalHorsesFound .. "\n"
        if horseCatcher.statistics.scanningStats.lastScanEfficiency > 0 then
            scanStatsText = scanStatsText .. "📊 Last Scan Efficiency: " .. string.format("%.1f", horseCatcher.statistics.scanningStats.lastScanEfficiency * 100) .. "%\n"
        end
        scanStatsText = scanStatsText .. "⚡ Scan Type: " .. intelligentScanner.settings.scanType:upper() .. "\n"
        scanStatsText = scanStatsText .. "🔄 Auto Scan: " .. (intelligentScanner.settings.autoScan and "ON" or "OFF")
        
        ScanningStats:Set({Title = "🧠 Scanning Statistics", Content = scanStatsText})
        
        -- Island Statistics
        local islandStatsText = "🏝️ Per-Island Captures:\n"
        local hasStats = false
        for islandName, captures in pairs(horseCatcher.statistics.islandStats) do
            islandStatsText = islandStatsText .. "• " .. islandName .. ": " .. captures .. " horses\n"
            hasStats = true
        end
        
        if not hasStats then
            islandStatsText = islandStatsText .. "No captures yet"
        else
            islandStatsText = islandStatsText .. "\n🌍 Total Islands: " .. totalIslands
        end
        
        IslandStats:Set({Title = "🏝️ Island Statistics", Content = islandStatsText})
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    
    disableNoclip()
    
    -- Stop scanning on respawn
    if intelligentScanner.isScanning then
        stopIntelligentScan()
    end
    
    islandSystem.currentIsland = "Unknown"
    islandSystem.lastUpdate = 0
    
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Horse catching stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- ENHANCED INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Horse Catcher Pro Loaded!",
   Content = "Professional intelligent scanning | CaptureProgress monitoring | Auto-lasso | Noclip smooth mode",
   Duration = 5,
   Image = 4483362458,
})

local initialIsland = detectCurrentIsland()

if gameSystem.available and gameSystem.networkReady then
    Rayfield:Notify({
       Title = "✅ Professional System Ready!",
       Content = "Island: " .. initialIsland .. " | Intelligent scanning | CaptureProgress tracking | Auto-lasso protection!",
       Duration = 4,
       Image = 4483362458,
    })
else
    Rayfield:Notify({
       Title = "⚠️ Performance Warning",
       Content = "Network system issues detected | Intelligent scanning may be limited | Island: " .. initialIsland,
       Duration = 4,
       Image = 4483362458,
    })
end

spawn(function()
    wait(2)
    local detectedIsland = detectCurrentIsland()
    if detectedIsland ~= "Unknown" then
        Rayfield:Notify({
           Title = "🎯 Professional System Ready!",
           Content = "Island: " .. detectedIsland .. " | Intelligent scanning ready | All systems operational!",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)
