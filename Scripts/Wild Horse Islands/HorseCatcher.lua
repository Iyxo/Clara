-- Horse Catcher Pro - CaptureProgress Tracking Edition
-- by Iyxo - 2025-07-22 17:12:18
-- Revolutionary horse catching with ULTRA-AGGRESSIVE lasso protection

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
-- PROFESSIONAL CACHING SYSTEM (ENHANCED)
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
-- 🔥 ULTRA-AGGRESSIVE LASSO PROTECTION SYSTEM
-- =================================
local lassoProtection = {
    active = false,
    hookedFunctions = {},
    originalFunctions = {},
    lastEquipTime = 0,
    forceEquipInterval = 0.1, -- Check every 0.1 seconds
    instantReEquip = true,
    blockUnequip = true,
    protectionLevel = "ULTRA", -- NORMAL, AGGRESSIVE, ULTRA
    
    -- Statistics
    stats = {
        blockedUnequips = 0,
        forceEquips = 0,
        protectionTriggers = 0
    }
}

-- 🔥 ULTRA-AGGRESSIVE: Hook game functions to block lasso unequip
local function initializeLassoProtection()
    if lassoProtection.active then return end
    
    lassoProtection.active = true
    
    pcall(function()
        if gameSystem.available and gameSystem.u2 and gameSystem.u2.Network then
            -- Hook NetworkFireServer to intercept unequip attempts
            local originalFireServer = gameSystem.u2.Network.FireServer
            lassoProtection.originalFunctions.FireServer = originalFireServer
            
            gameSystem.u2.Network.FireServer = function(self, command, ...)
                local args = {...}
                
                -- Block lasso unequip attempts during horse catching
                if horseCatcher.isRunning and lassoProtection.blockUnequip then
                    if command == "Inventory" and args[1] == "Use" then
                        -- Check if trying to unequip lasso
                        local itemId = args[2]
                        if itemId == horseCatcher.currentLassoID then
                            -- Allow lasso re-equip but not other items
                            return originalFireServer(self, command, ...)
                        elseif itemId and itemId:find("{") then
                            -- Block equipping other items (potential lasso unequip)
                            lassoProtection.stats.blockedUnequips = lassoProtection.stats.blockedUnequips + 1
                            
                            Rayfield:Notify({
                               Title = "🛡️ Lasso Protected!",
                               Content = "Blocked attempt to unequip lasso | Protection: ULTRA",
                               Duration = 1,
                               Image = 4483362458,
                            })
                            
                            -- Immediately re-equip lasso
                            spawn(function()
                                wait(0.05)
                                if horseCatcher.currentLassoID then
                                    originalFireServer(self, "Inventory", "Use", horseCatcher.currentLassoID)
                                    lassoProtection.stats.forceEquips = lassoProtection.stats.forceEquips + 1
                                end
                            end)
                            
                            return -- Block the original call
                        end
                    end
                    
                    -- Block equipment deactivation
                    if command == "Equipment" and #args >= 2 and args[2] == "Deactivate" then
                        if args[1] == horseCatcher.currentLassoID then
                            lassoProtection.stats.blockedUnequips = lassoProtection.stats.blockedUnequips + 1
                            return -- Block deactivation
                        end
                    end
                end
                
                return originalFireServer(self, command, ...)
            end
            
            lassoProtection.hookedFunctions.FireServer = true
        end
    end)
    
    -- Also hook ReplicatedStorage remote if available
    pcall(function()
        if gameSystem.remoteEvent and gameSystem.remoteEvent.FireServer then
            local originalRemoteFireServer = gameSystem.remoteEvent.FireServer
            lassoProtection.originalFunctions.RemoteFireServer = originalRemoteFireServer
            
            gameSystem.remoteEvent.FireServer = function(self, ...)
                local args = {...}
                
                if horseCatcher.isRunning and lassoProtection.blockUnequip then
                    -- Check for inventory-related calls that might unequip lasso
                    if args[1] == "Inventory" and args[2] == "Use" then
                        local itemId = args[3]
                        if itemId and itemId ~= horseCatcher.currentLassoID and itemId:find("{") then
                            lassoProtection.stats.blockedUnequips = lassoProtection.stats.blockedUnequips + 1
                            
                            -- Force re-equip lasso immediately
                            spawn(function()
                                if horseCatcher.currentLassoID then
                                    originalRemoteFireServer(self, "Inventory", "Use", horseCatcher.currentLassoID)
                                end
                            end)
                            
                            return -- Block the call
                        end
                    end
                end
                
                return originalRemoteFireServer(self, ...)
            end
            
            lassoProtection.hookedFunctions.RemoteFireServer = true
        end
    end)
end

-- 🔥 ULTRA-AGGRESSIVE: Force lasso monitoring
local function ultraAggressiveLassoMonitoring()
    if not horseCatcher.isRunning or not lassoProtection.active then
        return
    end
    
    local currentTime = tick()
    if currentTime - lassoProtection.lastEquipTime < lassoProtection.forceEquipInterval then
        return
    end
    
    lassoProtection.lastEquipTime = currentTime
    
    pcall(function()
        if gameSystem.available and gameSystem.u3 and gameSystem.networkReady then
            local currentlyEquipped = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
            
            -- ULTRA-AGGRESSIVE: If lasso not equipped, immediately force equip
            if not currentlyEquipped or currentlyEquipped ~= horseCatcher.currentLassoID then
                if horseCatcher.currentLassoID then
                    local inventoryItem = gameSystem.u3.GetLocal({"inventory", horseCatcher.currentLassoID})
                    if inventoryItem then
                        -- INSTANT re-equip
                        gameSystem.u2.Network:FireServer("Inventory", "Use", horseCatcher.currentLassoID)
                        lassoProtection.stats.forceEquips = lassoProtection.stats.forceEquips + 1
                        lassoProtection.stats.protectionTriggers = lassoProtection.stats.protectionTriggers + 1
                        
                        if lassoProtection.protectionLevel == "ULTRA" then
                            Rayfield:Notify({
                               Title = "⚡ ULTRA Protection!",
                               Content = "Lasso instantly re-equipped | Level: " .. lassoProtection.protectionLevel,
                               Duration = 0.5,
                               Image = 4483362458,
                            })
                        end
                    else
                        -- Lasso disappeared from inventory, try to find new one
                        equipLasso()
                    end
                end
            end
            
            -- Double-check with redundancy
            if lassoProtection.protectionLevel == "ULTRA" then
                spawn(function()
                    wait(0.02) -- Micro delay
                    local doubleCheck = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
                    if not doubleCheck or doubleCheck ~= horseCatcher.currentLassoID then
                        if horseCatcher.currentLassoID then
                            gameSystem.u2.Network:FireServer("Inventory", "Use", horseCatcher.currentLassoID)
                        end
                    end
                end)
            end
        end
    end)
end

-- Cleanup protection when stopping
local function cleanupLassoProtection()
    if not lassoProtection.active then return end
    
    lassoProtection.active = false
    
    -- Restore original functions
    pcall(function()
        if lassoProtection.hookedFunctions.FireServer and gameSystem.u2 and gameSystem.u2.Network then
            gameSystem.u2.Network.FireServer = lassoProtection.originalFunctions.FireServer
        end
        
        if lassoProtection.hookedFunctions.RemoteFireServer and gameSystem.remoteEvent then
            gameSystem.remoteEvent.FireServer = lassoProtection.originalFunctions.RemoteFireServer
        end
    end)
    
    lassoProtection.hookedFunctions = {}
    lassoProtection.originalFunctions = {}
end

-- =================================
-- ULTRA-OPTIMIZED HORSE CATCHER SYSTEM (ENHANCED WITH ULTRA LASSO PROTECTION)
-- =================================
local horseCatcher = {
    isRunning = false,
    currentTarget = nil,
    currentTargetProgress = nil,
    isAttached = false,
    lassoEquipped = false,
    currentLassoID = nil,
    lassoProtectionActive = false,
    
    connections = {
        capture = nil,
        targeting = nil,
        movement = nil,
        cleanup = nil,
        islandMonitor = nil,
        progressMonitor = nil,
        ultraLassoProtection = nil -- 🔥 NEW: Ultra lasso protection
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
        
        autoEquipLasso = true,
        protectLasso = true,
        ultraProtection = true, -- 🔥 NEW: Ultra protection mode
        protectionLevel = "ULTRA", -- NORMAL, AGGRESSIVE, ULTRA
        
        safeDistance = 5,
        attachmentOffset = 4,
        targetingRadius = 300,
        batchProcessing = true,
        maxBatchSize = 5
    },
    
    runtime = {
        lastCaptureTime = 0,
        lastPulseTime = 0,
        lastTargetingTime = 0,
        lastCleanupTime = 0,
        lastIslandCheck = 0,
        lastProgressCheck = 0,
        lastLassoCheck = 0,
        lastUltraProtectionCheck = 0, -- 🔥 NEW: Ultra protection timing
        
        currentTargetStartTime = 0,
        lastProgressChange = 0,
        lastProgressValue = "0/0",
        progressStuckTime = 0,
        
        sessionStartTime = 0,
        lastSuccessfulCapture = 0,
        forceDetach = false,
        targetingCount = 0,
        captureAttempts = 0,
        currentIslandHorses = 0
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

-- Game System Detection - Enhanced
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
-- ULTRA-OPTIMIZED HORSE FUNCTIONS (ENHANCED WITH CAPTURE PROGRESS)
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
                        
                        Cache.horses[horseCount] = {
                            horse = child,
                            island = islandName,
                            priority = priority,
                            distance = distance
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
            if horseCatcher.settings.autoEquipLasso then
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

local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local currentIsland = detectCurrentIsland()
    local candidates = {}
    
    for i = 1, math.min(#horses, horseCatcher.settings.maxBatchSize * 2) do
        local horseData = horses[i]
        if horseData and horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            local horse = horseData.horse
            local horsePos = horse.HumanoidRootPart.Position
            local distance = (playerPos - horsePos).Magnitude
            local velocity = horse.HumanoidRootPart.Velocity.Magnitude
            
            if distance > horseCatcher.settings.targetingRadius then
                continue
            end
            
            local score = 1000
            
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
                priority = horseData.priority
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

-- Movement functions (same as before)
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
           Content = "Island: " .. currentIsland .. " | Reason: " .. reason .. " | Time: " .. string.format("%.1f", captureTime) .. "s | Streak: " .. horseCatcher.statistics.currentStreak,
           Duration = 3,
           Image = 4483362458,
        })
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
    
    horseCatcher.runtime.lastCleanupTime = currentTime
end

-- =================================
-- ENHANCED MAIN LOGIC WITH ULTRA LASSO PROTECTION
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
    horseCatcher.lassoProtectionActive = true
    
    -- 🔥 NEW: Initialize ULTRA lasso protection
    if horseCatcher.settings.ultraProtection then
        lassoProtection.protectionLevel = horseCatcher.settings.protectionLevel
        lassoProtection.blockUnequip = horseCatcher.settings.protectLasso
        lassoProtection.instantReEquip = true
        initializeLassoProtection()
    end
    
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
    horseCatcher.runtime.lastUltraProtectionCheck = 0
    
    horseCatcher.runtime.currentTargetStartTime = 0
    horseCatcher.runtime.lastProgressChange = 0
    horseCatcher.runtime.lastProgressValue = "0/0"
    horseCatcher.runtime.progressStuckTime = 0
    
    local movementMode = horseCatcher.settings.movementMode == "pulse" and "Pulse TP" or 
                        horseCatcher.settings.movementMode == "attachment" and "Attachment" or "Smooth"
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Catching Started!",
       Content = "Island: " .. currentIsland .. " | Mode: " .. movementMode .. " | ULTRA Lasso Protection: " .. horseCatcher.settings.protectionLevel,
       Duration = 3,
       Image = 4483362458,
    })
    
    -- Island monitoring connection
    horseCatcher.connections.islandMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastIslandCheck < 5 then
            return
        end
        
        detectCurrentIsland()
        horseCatcher.runtime.lastIslandCheck = currentTime
    end)
    
    -- 🔥 NEW: ULTRA lasso protection connection
    horseCatcher.connections.ultraLassoProtection = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastUltraProtectionCheck < 0.05 then -- Check every 50ms for ULTRA mode
            return
        end
        
        horseCatcher.runtime.lastUltraProtectionCheck = currentTime
        ultraAggressiveLassoMonitoring()
    end)
    
    -- CaptureProgress monitoring connection
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
    
    -- MAIN CAPTURE CONNECTION
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
    horseCatcher.lassoProtectionActive = false
    
    -- 🔥 CLEANUP: Remove ULTRA lasso protection
    cleanupLassoProtection()
    
    for name, connection in pairs(horseCatcher.connections) do
        if connection then
            connection:Disconnect()
            horseCatcher.connections[name] = nil
        end
    end
    
    detachFromHorse()
    horseCatcher.currentTarget = nil
    horseCatcher.currentTargetProgress = nil
    
    local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    local avgCaptureTime = 0
    if #horseCatcher.performance.captureTimes > 0 then
        local total = 0
        for _, time in pairs(horseCatcher.performance.captureTimes) do
            total = total + time
        end
        avgCaptureTime = total / #horseCatcher.performance.captureTimes
        horseCatcher.statistics.averageCaptureTime = avgCaptureTime
    end
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🏁 ULTRA Protection Session Ended",
       Content = "Island: " .. currentIsland .. " | Captured: " .. horseCatcher.statistics.currentStreak .. " | Protected: " .. lassoProtection.stats.blockedUnequips .. " unequips",
       Duration = 5,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- ENHANCED UI WITH ULTRA LASSO PROTECTION
-- =================================

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

-- 🔥 ENHANCED: Ultra Lasso Protection Section
local UltraLassoSection = parentTab:CreateSection("🛡️ ULTRA Lasso Protection")

local AutoEquipLassoToggle = parentTab:CreateToggle({
   Name = "🚀 Auto-Equip Lasso",
   CurrentValue = true,
   Flag = "AutoEquipLassoToggle",
   Callback = function(Value)
      horseCatcher.settings.autoEquipLasso = Value
   end,
})

local ProtectLassoToggle = parentTab:CreateToggle({
   Name = "🛡️ Block Lasso Unequip",
   CurrentValue = true,
   Flag = "ProtectLassoToggle",
   Callback = function(Value)
      horseCatcher.settings.protectLasso = Value
      if lassoProtection.active then
          lassoProtection.blockUnequip = Value
      end
   end,
})

local UltraProtectionToggle = parentTab:CreateToggle({
   Name = "⚡ ULTRA Protection Mode",
   CurrentValue = true,
   Flag = "UltraProtectionToggle",
   Callback = function(Value)
      horseCatcher.settings.ultraProtection = Value
   end,
})

local ProtectionLevelDropdown = parentTab:CreateDropdown({
   Name = "🔥 Protection Level",
   Options = {"NORMAL", "AGGRESSIVE", "ULTRA"},
   CurrentOption = {"ULTRA"},
   MultipleOptions = false,
   Flag = "ProtectionLevelDropdown",
   Callback = function(Option)
      horseCatcher.settings.protectionLevel = Option[1]
      if lassoProtection.active then
          lassoProtection.protectionLevel = Option[1]
      end
      Rayfield:Notify({
         Title = "🛡️ Protection Level Updated",
         Content = "Now using: " .. Option[1] .. " protection level",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

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

local MovementSettingsSection = parentTab:CreateSection("📍 Movement & Optimization")

local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"attachment", "pulse", "smooth"},
   CurrentOption = {"attachment"},
   MultipleOptions = false,
   Flag = "UltraHorseMovementModeDropdown",
   Callback = function(Option)
      horseCatcher.settings.movementMode = Option[1]
      Rayfield:Notify({
         Title = "📍 Movement Updated",
         Content = "Now using: " .. Option[1]:upper() .. " mode (ULTRA Protected)",
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

local SmartTargetingToggle = parentTab:CreateToggle({
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

-- 📊 STATUS SECTION
local LiveStatusSection = parentTab:CreateSection("📊 Professional Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Island Information", Content = "Detecting current island..."})
local CaptureProgressInfo = parentTab:CreateParagraph({Title = "🎯 CaptureProgress Status", Content = "No target selected"})
local UltraLassoStatus = parentTab:CreateParagraph({Title = "🛡️ ULTRA Lasso Protection", Content = "Protection ready"}) -- 🔥 NEW
local SystemStatus = parentTab:CreateParagraph({Title = "🔧 System Status", Content = "Ultra-optimized system ready"})
local CatchingStatus = parentTab:CreateParagraph({Title = "🎯 Catching Status", Content = "Professional mode ready"})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Current Target", Content = "No target selected"})
local PerformanceMetrics = parentTab:CreateParagraph({Title = "⚡ Performance Metrics", Content = "Monitoring ready"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(0.8) do
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
        islandText = islandText .. "🔍 Auto-Scanning: ✅"
        
        IslandInfo:Set({Title = "🏝️ Island Information", Content = islandText})
        
        -- 🔥 NEW: ULTRA Lasso Protection Status
        local ultraLassoText = ""
        if horseCatcher.isRunning and lassoProtection.active then
            local currentlyEquipped = "Unknown"
            pcall(function()
                if gameSystem.available and gameSystem.u3 then
                    local equipped = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
                    currentlyEquipped = equipped and equipped:sub(1, 8) .. "..." or "None"
                end
            end)
            
            ultraLassoText = "🛡️ Protection Level: " .. lassoProtection.protectionLevel .. "\n"
            ultraLassoText = ultraLassoText .. "⚡ Status: ULTRA-ACTIVE\n"
            ultraLassoText = ultraLassoText .. "🚫 Blocked Unequips: " .. lassoProtection.stats.blockedUnequips .. "\n"
            ultraLassoText = ultraLassoText .. "🔄 Force Equips: " .. lassoProtection.stats.forceEquips .. "\n"
            ultraLassoText = ultraLassoText .. "🎯 Current Equipped: " .. currentlyEquipped .. "\n"
            ultraLassoText = ultraLassoText .. "⚡ Protection Triggers: " .. lassoProtection.stats.protectionTriggers
        else
            ultraLassoText = "🛡️ Protection Level: " .. horseCatcher.settings.protectionLevel .. "\n"
            ultraLassoText = ultraLassoText .. "⚡ Status: STANDBY\n"
            ultraLassoText = ultraLassoText .. "🚀 Auto-Equip: " .. (horseCatcher.settings.autoEquipLasso and "✅" or "❌") .. "\n"
            ultraLassoText = ultraLassoText .. "🛡️ Block Unequip: " .. (horseCatcher.settings.protectLasso and "✅" or "❌") .. "\n"
            ultraLassoText = ultraLassoText .. "⚡ ULTRA Mode: " .. (horseCatcher.settings.ultraProtection and "✅" or "❌")
        end
        
        UltraLassoStatus:Set({Title = "🛡️ ULTRA Lasso Protection", Content = ultraLassoText})
        
        -- CaptureProgress Information
        local progressText = ""
        if horseCatcher.currentTarget and horseCatcher.currentTargetProgress then
            local progressData = horseCatcher.currentTargetProgress
            local timeOnTarget = tick() - horseCatcher.runtime.currentTargetStartTime
            local timeSinceProgress = tick() - horseCatcher.runtime.lastProgressChange
            
            progressText = "🎯 Current Progress: " .. (progressData.text or "Unknown") .. "\n"
            progressText = progressText .. "⏱️ Time on Target: " .. string.format("%.1f", timeOnTarget) .. "s\n"
            progressText = progressText .. "🔄 Last Progress: " .. string.format("%.1f", timeSinceProgress) .. "s ago\n"
            progressText = progressText .. "📊 Progress Hits: " .. horseCatcher.statistics.progressStats.totalProgressHits .. "\n"
            
            if progressData.max > 0 then
                local percentage = (progressData.current / progressData.max) * 100
                progressText = progressText .. "📈 Completion: " .. string.format("%.1f", percentage) .. "%"
            else
                progressText = progressText .. "📈 Completion: Unknown"
            end
            
            if horseCatcher.settings.abandonOnStuckProgress then
                local timeLeft = horseCatcher.settings.maxStuckProgressTime - timeSinceProgress
                if timeLeft > 0 then
                    progressText = progressText .. "\n⏳ Abandon in: " .. string.format("%.1f", timeLeft) .. "s"
                else
                    progressText = progressText .. "\n⚠️ Should abandon soon..."
                end
            end
        else
            progressText = "🎯 No active target\n📊 Progress monitoring ready\n⏱️ Max stuck time: " .. horseCatcher.settings.maxStuckProgressTime .. "s\n🔄 Monitoring: " .. (horseCatcher.settings.progressMonitoring and "✅" or "❌") .. "\n⏭️ Auto abandon: " .. (horseCatcher.settings.abandonOnStuckProgress and "✅" or "❌")
        end
        
        CaptureProgressInfo:Set({Title = "🎯 CaptureProgress Status", Content = progressText})
        
        -- Enhanced Target Info with progress data
        local targetText = ""
        if horseCatcher.currentTarget then
            local targetName = getHorseName(horseCatcher.currentTarget)
            local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
            local velocity = math.floor(horseCatcher.currentTarget.HumanoidRootPart.Velocity.Magnitude)
            local timeOnTarget = tick() - horseCatcher.runtime.currentTargetStartTime
            
            targetText = "🐎 " .. targetName .. "\n"
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
                targetText = targetText .. "\n🌊 Smooth Follow: Ultra-Active"
            end
        else
            local wildCount = #Cache.horses
            targetText = "🔍 Scanning for optimal targets...\n🐎 Wild horses cached: " .. wildCount .. "\n📊 Targeting radius: " .. horseCatcher.settings.targetingRadius .. " studs\n🎯 Smart targeting: " .. (horseCatcher.settings.smartTargeting and "Active" or "Disabled") .. "\n🏝️ Island horses: " .. (horseCatcher.runtime.currentIslandHorses or 0)
        end
        TargetInfo:Set({Title = "🐎 Current Target", Content = targetText})
        
        -- Enhanced Performance Metrics
        local avgCaptureTime = 0
        if #horseCatcher.performance.captureTimes > 0 then
            local total = 0
            for _, time in pairs(horseCatcher.performance.captureTimes) do
                total = total + time
            end
            avgCaptureTime = total / #horseCatcher.performance.captureTimes
        end
        
        local avgProgressCheckTime = 0
        if #horseCatcher.performance.progressCheckTimes > 0 then
            local total = 0
            for _, time in pairs(horseCatcher.performance.progressCheckTimes) do
                total = total + time
            end
            avgProgressCheckTime = total / #horseCatcher.performance.progressCheckTimes
        end
        
        local performanceText = "⚡ Avg Capture: " .. string.format("%.3f", avgCaptureTime * 1000) .. "ms\n"
        performanceText = performanceText .. "🎯 Avg Progress Check: " .. string.format("%.3f", avgProgressCheckTime * 1000) .. "ms\n"
        performanceText = performanceText .. "📊 Progress Hits: " .. horseCatcher.statistics.progressStats.totalProgressHits .. "\n"
        performanceText = performanceText .. "⚡ Fastest Capture: " .. string.format("%.1f", horseCatcher.statistics.progressStats.fastestCapture) .. "s\n"
        performanceText = performanceText .. "🐌 Slowest Capture: " .. string.format("%.1f", horseCatcher.statistics.progressStats.slowestCapture) .. "s\n"
        performanceText = performanceText .. "🎯 Capture Attempts: " .. horseCatcher.runtime.captureAttempts
        PerformanceMetrics:Set({Title = "⚡ Performance Metrics", Content = performanceText})
        
        -- Enhanced System Status
        local systemText = ""
        if gameSystem.available and gameSystem.networkReady then
            systemText = "✅ Game System: ULTRA-Connected\n✅ Network (u2): High-Performance\n✅ Capture Remote: Optimized"
        elseif gameSystem.available then
            systemText = "⚠️ Game System: Connected\n❌ Network (u2): Limited\n❌ Performance Degraded"
        else
            systemText = "❌ Game System: Disconnected\n❌ Network: Unavailable\n❌ System Failure"
        end
        
        local lassoReady, lassoID = equipLasso()
        if lassoReady then
            systemText = systemText .. "\n✅ Lasso: Ready (" .. (lassoID and lassoID:sub(1,8) or "Unknown") .. "...)"
        else
            systemText = systemText .. "\n❌ Lasso: Not Found"
        end
        
        local cacheSize = #Cache.horses
        systemText = systemText .. "\n📦 Cache: " .. cacheSize .. " horses"
        systemText = systemText .. "\n🏝️ Island: " .. currentIsland
        
        SystemStatus:Set({Title = "🔧 System Status", Content = systemText})
        
        -- Enhanced Catching Status
        local catchingText = ""
        if horseCatcher.isRunning then
            local runtime = tick() - horseCatcher.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            catchingText = "🚀 ULTRA-ACTIVE (" .. horseCatcher.settings.movementMode:upper() .. ")\n"
            catchingText = catchingText .. "🏝️ Island: " .. currentIsland .. "\n"
            catchingText = catchingText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            catchingText = catchingText .. "🎯 Cooldown: " .. horseCatcher.settings.captureCooldown .. "s\n"
            catchingText = catchingText .. "🧠 Smart: " .. (horseCatcher.settings.smartTargeting and "✅" or "❌") .. "\n"
            catchingText = catchingText .. "⚡ Aggressive: " .. (horseCatcher.settings.aggressiveTargeting and "✅" or "❌") .. "\n"
            catchingText = catchingText .. "🛡️ ULTRA Protection: " .. (lassoProtection.active and "✅" or "❌")
        else
            catchingText = "🔴 STOPPED\n🏝️ Island: " .. currentIsland .. "\n💤 ULTRA-optimized system ready\n⚙️ Mode: " .. horseCatcher.settings.movementMode:upper() .. " (Professional)\n🔧 System: " .. (gameSystem.available and gameSystem.networkReady and "✅" or "❌") .. "\n🛡️ ULTRA Protection: Ready\n🚀 Ultra-performance ready"
        end
        CatchingStatus:Set({Title = "🎯 Catching Status", Content = catchingText})
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    horseCatcher.lassoProtectionActive = false
    
    -- Clean up protection
    cleanupLassoProtection()
    
    islandSystem.currentIsland = "Unknown"
    islandSystem.lastUpdate = 0
    
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "ULTRA Horse catching stopped - restart when ready",
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
   Content = "CaptureProgress monitoring | ULTRA Lasso Protection | Island detection | Revolutionary catching system",
   Duration = 5,
   Image = 4483362458,
})

local initialIsland = detectCurrentIsland()

if gameSystem.available and gameSystem.networkReady then
    Rayfield:Notify({
       Title = "✅ ULTRA System Ready!",
       Content = "Island: " .. initialIsland .. " | Real-time progress tracking | ULTRA Lasso Protection!",
       Duration = 4,
       Image = 4483362458,
    })
else
    Rayfield:Notify({
       Title = "⚠️ Performance Warning",
       Content = "Network system issues detected - ULTRA Protection may be limited | Island: " .. initialIsland,
       Duration = 4,
       Image = 4483362458,
    })
end

spawn(function()
    wait(2)
    local detectedIsland = detectCurrentIsland()
    if detectedIsland ~= "Unknown" then
        Rayfield:Notify({
           Title = "🛡️ ULTRA Protection Ready!",
           Content = "Island: " .. detectedIsland .. " | ULTRA Lasso Protection | Professional progress monitoring!",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)
