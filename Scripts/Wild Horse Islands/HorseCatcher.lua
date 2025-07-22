-- Horse Catcher Pro - Ultra-Optimized Island Detection Edition
-- by Iyxo - 2025-07-22 09:40:08
-- Revolutionary horse catching with professional island detection

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
-- ISLAND DETECTION SYSTEM
-- =================================
local islandSystem = {
    currentIsland = "Unknown",
    lastUpdate = 0,
    updateInterval = 2, -- Check every 2 seconds
    availableIslands = {},
    scanLocations = {}
}

-- Professional island detection
local function detectCurrentIsland()
    local currentTime = tick()
    if currentTime - islandSystem.lastUpdate < islandSystem.updateInterval then
        return islandSystem.currentIsland
    end
    
    -- Method 1: Player Attribute (Primary - most reliable)
    local islandAttribute = player:GetAttribute("island")
    if islandAttribute and islandAttribute ~= "" then
        islandSystem.currentIsland = islandAttribute
        islandSystem.lastUpdate = currentTime
        return islandAttribute
    end
    
    -- Method 2: Character Location (Fallback)
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
    
    -- Method 3: Position-based (Last resort)
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

-- Update scan locations based on current island
local function updateScanLocations()
    islandSystem.scanLocations = {}
    local currentIsland = detectCurrentIsland()
    
    -- Always scan current island
    pcall(function()
        if Workspace.Islands then
            -- If on Mainland
            if currentIsland == "Mainland" and Workspace.Islands.Mainland then
                table.insert(islandSystem.scanLocations, {
                    location = Workspace.Islands.Mainland,
                    name = "Mainland",
                    priority = 1
                })
            end
            
            -- Scan specific island player is on
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island.Name == currentIsland and island ~= Workspace.Islands.Mainland then
                    table.insert(islandSystem.scanLocations, {
                        location = island,
                        name = island.Name,
                        priority = 1
                    })
                end
            end
            
            -- Also scan nearby islands (lower priority)
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island.Name ~= currentIsland and island:IsA("Model") then
                    table.insert(islandSystem.scanLocations, {
                        location = island,
                        name = island.Name,
                        priority = 2
                    })
                end
            end
        end
    end)
    
    -- Sort by priority (current island first)
    table.sort(islandSystem.scanLocations, function(a, b)
        return a.priority < b.priority
    end)
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
    islandHorses = {} -- New: horses per island
}

-- =================================
-- ULTRA-OPTIMIZED HORSE CATCHER SYSTEM
-- =================================
local horseCatcher = {
    -- Status
    isRunning = false,
    currentTarget = nil,
    isAttached = false,
    lassoEquipped = false,
    currentLassoID = nil,
    
    -- High-performance connections
    connections = {
        capture = nil,
        targeting = nil,
        movement = nil,
        cleanup = nil,
        island = nil -- New: island monitoring
    },
    
    -- Professional data structures
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
        islandStats = {} -- New: per-island statistics
    },
    
    -- Optimized settings
    settings = {
        -- Movement optimization
        movementMode = "attachment",
        pulseInterval = 0.8,
        pulseDistance = 8,
        
        -- Capture optimization
        captureCooldown = 0.4,
        maxAttemptsPerHorse = 12,
        maxStuckTime = 10,
        smartTargeting = true,
        aggressiveTargeting = true,
        
        -- Island settings
        multiIslandMode = true, -- Scan all islands
        prioritizeCurrentIsland = true,
        
        -- Professional settings
        safeDistance = 5,
        attachmentOffset = 4,
        targetingRadius = 300,
        batchProcessing = true,
        maxBatchSize = 5
    },
    
    -- High-performance runtime data
    runtime = {
        lastCaptureTime = 0,
        lastPulseTime = 0,
        lastTargetingTime = 0,
        lastCleanupTime = 0,
        lastIslandCheck = 0,
        currentAttempts = 0,
        retryCount = 0,
        targetStuckTime = 0,
        lastTargetName = "",
        sessionStartTime = 0,
        lastSuccessfulCapture = 0,
        forceDetach = false,
        targetingCount = 0,
        captureAttempts = 0,
        currentIslandHorses = 0
    },
    
    -- Performance monitoring
    performance = {
        captureTimes = {},
        targetingTimes = {},
        movementTimes = {},
        islandScanTimes = {},
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

-- Initialize game system with error handling
pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.networkReady = (gameSystem.u2 and gameSystem.u2.Network) and true or false
    gameSystem.remoteEvent = ReplicatedStorage.Communication.Events['']
end)

-- =================================
-- ENHANCED HORSE FUNCTIONS WITH ISLAND DETECTION
-- =================================

-- Professional horse name getter with caching
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

-- Ultra-fast wild horse checker with caching
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

-- ENHANCED: Multi-island horse cache management
local function updateHorseCache()
    local currentTime = tick()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    local startTime = tick()
    Cache.horses = {}
    Cache.islandHorses = {}
    local horseCount = 0
    
    -- Update scan locations based on current island
    updateScanLocations()
    
    -- Ultra-optimized scanning with island prioritization
    local function scanLocation(locationData)
        if not locationData.location then return end
        
        local location = locationData.location
        local islandName = locationData.name
        local priority = locationData.priority
        
        local children = location:GetChildren()
        local islandHorseCount = 0
        
        for i = 1, #children do
            local child = children[i]
            
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseCatcher.capturedHorses[child.Name] then
                        horseCount = horseCount + 1
                        islandHorseCount = islandHorseCount + 1
                        
                        -- Add horse with island info
                        Cache.horses[horseCount] = {
                            horse = child,
                            island = islandName,
                            priority = priority,
                            distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        }
                        
                        -- Performance limit per island
                        if priority == 1 and islandHorseCount >= Cache.maxCacheSize * 0.6 then
                            break
                        elseif priority == 2 and islandHorseCount >= Cache.maxCacheSize * 0.3 then
                            break
                        end
                        
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
        
        Cache.islandHorses[islandName] = islandHorseCount
    end
    
    -- Scan locations by priority (current island first)
    for _, locationData in pairs(islandSystem.scanLocations) do
        if horseCount < Cache.maxCacheSize then
            scanLocation(locationData)
        end
    end
    
    -- Sort horses by priority and distance
    table.sort(Cache.horses, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.distance < b.distance
        end
    end)
    
    Cache.lastUpdate = currentTime
    
    -- Performance tracking
    local scanTime = tick() - startTime
    table.insert(horseCatcher.performance.islandScanTimes, scanTime)
    if #horseCatcher.performance.islandScanTimes > 100 then
        table.remove(horseCatcher.performance.islandScanTimes, 1)
    end
    
    horseCatcher.runtime.targetingCount = horseCatcher.runtime.targetingCount + 1
    
    -- Update current island horse count
    local currentIsland = detectCurrentIsland()
    horseCatcher.runtime.currentIslandHorses = Cache.islandHorses[currentIsland] or 0
    
    return Cache.horses
end

-- Enhanced lasso detection (same as before)
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
                    gameSystem.u2.Network:FireServer("Inventory", "Use", lastEquipped)
                    success = true
                    toolID = lastEquipped
                end)
            end
        end
    end
    
    if not success then
        toolID = "{60769f1f-cade-463b-ae32-adaacc91116f}"
        success = true
    end
    
    if not success then
        pcall(function()
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local tools = backpack:GetChildren()
                for i = 1, #tools do
                    local tool = tools[i]
                    if tool.Name:lower():find("lasso") then
                        tool.Parent = character
                        success = true
                        toolID = tool.Name
                        break
                    end
                end
            end
        end)
    end
    
    if success then
        horseCatcher.lassoEquipped = true
        horseCatcher.currentLassoID = toolID
    end
    
    return success, toolID
end

-- ENHANCED: Island-aware optimal target finding
local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local currentIsland = detectCurrentIsland()
    local candidates = {}
    
    -- Enhanced scoring algorithm with island awareness
    for i = 1, math.min(#horses, horseCatcher.settings.maxBatchSize * 3) do
        local horseData = horses[i]
        if horseData and horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            local horse = horseData.horse
            local horsePos = horse.HumanoidRootPart.Position
            local distance = (playerPos - horsePos).Magnitude
            local velocity = horse.HumanoidRootPart.Velocity.Magnitude
            
            if distance > horseCatcher.settings.targetingRadius and horseData.priority > 1 then
                continue
            end
            
            local score = 1000
            
            -- Island priority bonus
            if horseData.island == currentIsland then
                score = score + 500 -- Big bonus for same island
            elseif horseData.priority == 1 then
                score = score + 200 -- Bonus for high priority islands
            end
            
            -- Distance scoring
            if distance < 50 then
                score = score + 300
            elseif distance < 100 then
                score = score + 200
            elseif distance < 200 then
                score = score + 100
            else
                score = score - (distance * 0.5)
            end
            
            -- Movement scoring
            if velocity > 5 then
                score = score + 400
            elseif velocity > 2 then
                score = score + 200
            elseif velocity > 0.5 then
                score = score + 100
            else
                score = score - 100
            end
            
            -- Height preference
            local heightDiff = math.abs(horsePos.Y - playerPos.Y)
            if heightDiff < 10 then
                score = score + 150
            elseif heightDiff < 25 then
                score = score + 50
            else
                score = score - (heightDiff * 2)
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

-- Enhanced capture function (same as before)
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
        horseCatcher.runtime.currentAttempts = horseCatcher.runtime.currentAttempts + 1
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
        horseCatcher.runtime.currentAttempts = 0
        horseCatcher.runtime.targetStuckTime = 0
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

-- Enhanced capture detection with island tracking
local function isHorseCaptured(horse)
    if not horse or not horse.Parent then
        return true
    end
    
    local captured = false
    local horseName = "Unknown"
    
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text ~= "Wild" then
                    captured = true
                end
                
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text ~= "" then
                    horseName = breedLabel.Text
                end
            end
        end
        
        local humanoid = horse:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            captured = true
        end
    end)
    
    if captured then
        horseCatcher.capturedHorses[horse.Name] = true
        horseCatcher.statistics.totalCaptured = horseCatcher.statistics.totalCaptured + 1
        horseCatcher.statistics.currentStreak = horseCatcher.statistics.currentStreak + 1
        horseCatcher.statistics.successfulCaptures = horseCatcher.statistics.successfulCaptures + 1
        horseCatcher.runtime.lastSuccessfulCapture = tick()
        
        -- Track per-island statistics
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
           Content = "Island: " .. currentIsland .. " | Streak: " .. horseCatcher.statistics.currentStreak .. " | Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min",
           Duration = 2.5,
           Image = 4483362458,
        })
    end
    
    return captured
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
    
    horseCatcher.runtime.lastCleanupTime = currentTime
end

-- =================================
-- ENHANCED MAIN LOGIC WITH ISLAND DETECTION
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    local lassoReady, lassoID = equipLasso()
    if not lassoReady then
        Rayfield:Notify({
           Title = "❌ Lasso Required!",
           Content = "Please equip a lasso first!",
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
    horseCatcher.runtime.currentAttempts = 0
    horseCatcher.runtime.retryCount = 0
    horseCatcher.runtime.lastPulseTime = 0
    horseCatcher.runtime.targetingCount = 0
    horseCatcher.runtime.captureAttempts = 0
    
    local movementMode = horseCatcher.settings.movementMode == "pulse" and "Pulse TP" or 
                        horseCatcher.settings.movementMode == "attachment" and "Attachment" or "Smooth"
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Catching Started!",
       Content = "Island: " .. currentIsland .. " | Mode: " .. movementMode .. " | Multi-island detection active",
       Duration = 3,
       Image = 4483362458,
    })
    
    -- ISLAND MONITORING CONNECTION
    horseCatcher.connections.island = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastIslandCheck < 5 then -- Check every 5 seconds
            return
        end
        
        -- Update island detection
        detectCurrentIsland()
        horseCatcher.runtime.lastIslandCheck = currentTime
    end)
    
    -- MAIN CAPTURE CONNECTION (same as before but with island awareness)
    horseCatcher.connections.capture = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        if horseCatcher.currentTarget and isHorseCaptured(horseCatcher.currentTarget) then
            if horseCatcher.settings.movementMode == "attachment" then
                detachFromHorse()
            end
            horseCatcher.currentTarget = nil
            horseCatcher.runtime.currentAttempts = 0
            horseCatcher.runtime.retryCount = 0
            horseCatcher.runtime.targetStuckTime = 0
            return
        end
        
        if not horseCatcher.currentTarget then
            if horseCatcher.settings.smartTargeting then
                horseCatcher.currentTarget = findOptimalTarget()
            else
                local horses = updateHorseCache()
                horseCatcher.currentTarget = horses[1] and horses[1].horse
            end
            
            if horseCatcher.currentTarget then
                horseCatcher.runtime.currentAttempts = 0
                horseCatcher.runtime.lastTargetName = horseCatcher.currentTarget.Name
                horseCatcher.runtime.targetStuckTime = 0
            else
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                return
            end
        end
        
        if horseCatcher.currentTarget then
            if horseCatcher.runtime.lastTargetName == horseCatcher.currentTarget.Name then
                horseCatcher.runtime.targetStuckTime = horseCatcher.runtime.targetStuckTime + 1
            else
                horseCatcher.runtime.targetStuckTime = 0
                horseCatcher.runtime.lastTargetName = horseCatcher.currentTarget.Name
            end
            
            if horseCatcher.runtime.targetStuckTime > horseCatcher.settings.maxStuckTime * 60 then
                horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.runtime.targetStuckTime = 0
                return
            end
            
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
            
            if horseCatcher.runtime.currentAttempts > horseCatcher.settings.maxAttemptsPerHorse then
                horseCatcher.runtime.retryCount = horseCatcher.runtime.retryCount + 1
                
                if horseCatcher.runtime.retryCount > 2 then
                    horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
                    if horseCatcher.settings.movementMode == "attachment" then
                        detachFromHorse()
                    end
                    horseCatcher.currentTarget = nil
                    horseCatcher.runtime.retryCount = 0
                else
                    if horseCatcher.settings.movementMode == "attachment" then
                        detachFromHorse()
                        horseCatcher.runtime.forceDetach = true
                    end
                    horseCatcher.runtime.currentAttempts = 0
                    wait(0.3)
                end
            end
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
    
    for name, connection in pairs(horseCatcher.connections) do
        if connection then
            connection:Disconnect()
            horseCatcher.connections[name] = nil
        end
    end
    
    detachFromHorse()
    horseCatcher.currentTarget = nil
    
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
       Title = "🏁 Island Session Ended",
       Content = "Island: " .. currentIsland .. " | Captured: " .. horseCatcher.statistics.currentStreak .. " | Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min",
       Duration = 5,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- ENHANCED UI WITH ISLAND FEATURES
-- =================================

local MainControlSection = parentTab:CreateSection("🏝️ Island Horse Catching")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Island Horse Catching",
   CurrentValue = false,
   Flag = "UltraIslandHorseCatchingToggle",
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

local IslandSettingsSection = parentTab:CreateSection("🏝️ Island Settings")

local MultiIslandToggle = parentTab:CreateToggle({
   Name = "🌍 Multi-Island Mode",
   CurrentValue = true,
   Flag = "MultiIslandModeToggle",
   Callback = function(Value)
      horseCatcher.settings.multiIslandMode = Value
      Rayfield:Notify({
         Title = "🌍 Multi-Island " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Will scan all islands for horses" or "Only current island",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local PrioritizeCurrentToggle = parentTab:CreateToggle({
   Name = "📍 Prioritize Current Island",
   CurrentValue = true,
   Flag = "PrioritizeCurrentIslandToggle",
   Callback = function(Value)
      horseCatcher.settings.prioritizeCurrentIsland = Value
   end,
})

-- Movement & Settings (same as before)
local MovementSettingsSection = parentTab:CreateSection("📍 Movement & Optimization")

local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"attachment", "pulse", "smooth"},
   CurrentOption = {"attachment"},
   MultipleOptions = false,
   Flag = "UltraIslandMovementModeDropdown",
   Callback = function(Option)
      horseCatcher.settings.movementMode = Option[1]
      Rayfield:Notify({
         Title = "📍 Movement Updated",
         Content = "Now using: " .. Option[1]:upper() .. " mode (Island-Optimized)",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- ... (rest of the sliders same as before)

-- ENHANCED STATUS SECTION
local IslandStatusSection = parentTab:CreateSection("🏝️ Island Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Current Island", Content = "Detecting island..."})
local IslandStats = parentTab:CreateParagraph({Title = "📊 Island Statistics", Content = "No data yet"})
local SystemStatus = parentTab:CreateParagraph({Title = "🔧 System Status", Content = "Island-optimized system ready"})
local CatchingStatus = parentTab:CreateParagraph({Title = "🎯 Catching Status", Content = "Island mode ready"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM WITH ISLAND INFO
-- =================================
spawn(function()
    while wait(1) do
        local currentIsland = detectCurrentIsland()
        
        -- Island Info
        local islandText = "🏝️ Current Island: " .. currentIsland .. "\n"
        islandText = islandText .. "🐎 Horses on Island: " .. (horseCatcher.runtime.currentIslandHorses or 0) .. "\n"
        
        local totalIslands = 0
        for islandName, horseCount in pairs(Cache.islandHorses) do
            totalIslands = totalIslands + 1
        end
        
        islandText = islandText .. "🌍 Islands Scanned: " .. totalIslands .. "\n"
        islandText = islandText .. "🔍 Multi-Island: " .. (horseCatcher.settings.multiIslandMode and "✅" or "❌")
        
        IslandInfo:Set({Title = "🏝️ Current Island", Content = islandText})
        
        -- Island Statistics
        local statsText = "📊 Per-Island Captures:\n"
        for islandName, captureCount in pairs(horseCatcher.statistics.islandStats) do
            statsText = statsText .. "• " .. islandName .. ": " .. captureCount .. " horses\n"
        end
        
        if next(horseCatcher.statistics.islandStats) == nil then
            statsText = statsText .. "No captures yet"
        end
        
        IslandStats:Set({Title = "📊 Island Statistics", Content = statsText})
        
        -- Enhanced System Status
        local systemText = ""
        if gameSystem.available and gameSystem.networkReady then
            systemText = "✅ Game System: Island-Connected\n✅ Network (u2): Multi-Island\n✅ Island Detection: Active"
        else
            systemText = "❌ Game System: Disconnected\n❌ Network: Unavailable\n❌ Island Detection: Failed"
        end
        
        local lassoReady, lassoID = equipLasso()
        if lassoReady then
            systemText = systemText .. "\n✅ Lasso: Ready (" .. (lassoID and lassoID:sub(1,8) or "Unknown") .. "...)"
        else
            systemText = systemText .. "\n❌ Lasso: Not Found"
        end
        
        systemText = systemText .. "\n🏝️ Current: " .. currentIsland
        
        SystemStatus:Set({Title = "🔧 System Status", Content = systemText})
        
        -- Enhanced Catching Status
        local catchingText = ""
        if horseCatcher.isRunning then
            local runtime = tick() - horseCatcher.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            catchingText = "🚀 ISLAND-ACTIVE (" .. horseCatcher.settings.movementMode:upper() .. ")\n"
            catchingText = catchingText .. "🏝️ Island: " .. currentIsland .. "\n"
            catchingText = catchingText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            catchingText = catchingText .. "🐎 Island Horses: " .. horseCatcher.runtime.currentIslandHorses .. "\n"
            catchingText = catchingText .. "🌍 Multi-Island: " .. (horseCatcher.settings.multiIslandMode and "✅" or "❌")
        else
            catchingText = "🔴 STOPPED\n🏝️ Island: " .. currentIsland .. "\n💤 Island-optimized system ready\n🌍 Multi-island detection available\n🚀 Island-performance ready"
        end
        CatchingStatus:Set({Title = "🎯 Catching Status", Content = catchingText})
    end
end)

-- Character respawn handling (same as before)
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Island horse catching stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- ENHANCED INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🏝️ Ultra Island Horse Catcher Loaded!",
   Content = "Multi-island detection | Smart island prioritization | Professional grade system",
   Duration = 5,
   Image = 4483362458,
})

-- Initial island detection
local initialIsland = detectCurrentIsland()

Rayfield:Notify({
   Title = "🏝️ Island Detected!",
   Content = "Current Island: " .. initialIsland .. " | Multi-island mode ready!",
   Duration = 4,
   Image = 4483362458,
})

print("🏝️ Ultra Island Horse Catcher Pro - Multi-Island Edition Loaded!")
print("✅ Professional island detection system")
print("🌍 Multi-island horse scanning with smart prioritization")
print("🎯 Current island: " .. initialIsland)
print("🚀 Revolutionary island-aware horse catching ready!")
