-- Horse Attribute Manipulator - Advanced Edition
-- by Iyxo - 2025-01-22
-- Revolutionary horse control system

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- HORSE MANIPULATOR SYSTEM
-- =================================
local horseManipulator = {
    -- Status
    isRunning = false,
    manipulatedHorses = {},
    
    -- Connections
    manipulationConnection = nil,
    
    -- Settings
    settings = {
        autoManipulate = true,
        fleeDistance = 0,
        behaviour = "Follower",
        manipulationRadius = 200,
        enableFollower = true,
        enableFleeDistance = true,
        enableLastPlayerToThrow = true,
        manipulationInterval = 2
    },
    
    -- Runtime data
    runtime = {
        lastManipulationTime = 0,
        manipulatedCount = 0,
        sessionStartTime = 0,
        lastScanTime = 0
    },
    
    -- Statistics
    statistics = {
        totalManipulated = 0,
        sessionsRun = 0,
        horsesComing = 0,
        horsesControlled = 0
    }
}

-- =================================
-- HORSE NAME FUNCTIONS
-- =================================

-- Get real horse name from BreedLabel
local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    local horseName = "Unknown"
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" then
                    horseName = breedLabel.Text
                else
                    -- Fallback to shortened ID if no breed name
                    horseName = horse.Name:sub(1, 8) .. "..."
                end
            end
        end
    end)
    
    return horseName
end

-- =================================
-- ATTRIBUTE MANIPULATION FUNCTIONS
-- =================================

-- Check if horse is wild
local function isWildHorse(horse)
    if not horse then return false end
    
    local isWild = false
    pcall(function()
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
    
    return isWild
end

-- Get all wild horses in range
local function findWildHorsesInRange()
    local wildHorses = {}
    local playerPos = humanoidRootPart.Position
    
    pcall(function()
        local function scanLocation(location)
            for _, child in pairs(location:GetChildren()) do
                if child.Name:match("%{[%w%-]+%}") and child:FindFirstChild("HumanoidRootPart") then
                    local humanoid = child:FindFirstChild("Humanoid")
                    if humanoid and not Players:GetPlayerFromCharacter(child) and humanoid.Health > 0 then
                        if isWildHorse(child) then
                            local distance = (playerPos - child.HumanoidRootPart.Position).Magnitude
                            if distance <= horseManipulator.settings.manipulationRadius then
                                table.insert(wildHorses, {horse = child, distance = distance})
                            end
                        end
                    end
                end
            end
        end
        
        -- Scan locations
        if Workspace.Islands and Workspace.Islands.Mainland then
            scanLocation(Workspace.Islands.Mainland)
        end
        if Workspace.Islands then
            scanLocation(Workspace.Islands)
        end
    end)
    
    return wildHorses
end

-- REVOLUTIONARY ATTRIBUTE MANIPULATION
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
    local success = false
    local horseName = getHorseName(horse)
    
    pcall(function()
        -- Set behaviour to Follower
        if horseManipulator.settings.enableFollower then
            horse:SetAttribute("behaviour", horseManipulator.settings.behaviour)
            horse:SetAttribute("followPlayer", player.Name)
        end
        
        -- Set flee distance to 0 (no running away)
        if horseManipulator.settings.enableFleeDistance then
            horse:SetAttribute("fleeDistance", horseManipulator.settings.fleeDistance)
        end
        
        -- Set last player to throw lasso (exclusive control)
        if horseManipulator.settings.enableLastPlayerToThrow then
            horse:SetAttribute("lastPlayerToThrowLasso", player.Name)
        end
        
        -- Mark as manipulated
        horseManipulator.manipulatedHorses[horse.Name] = {
            name = horseName,
            time = tick(),
            controlled = true
        }
        
        horseManipulator.runtime.manipulatedCount = horseManipulator.runtime.manipulatedCount + 1
        horseManipulator.statistics.totalManipulated = horseManipulator.statistics.totalManipulated + 1
        
        success = true
    end)
    
    return success, horseName
end

-- Check horse attributes status
local function getHorseAttributeStatus(horse)
    if not horse then return {} end
    
    local status = {
        behaviour = "Unknown",
        followPlayer = "None",
        fleeDistance = "Unknown",
        lastPlayerToThrow = "None",
        isManipulated = false
    }
    
    pcall(function()
        status.behaviour = horse:GetAttribute("behaviour") or "Unknown"
        status.followPlayer = horse:GetAttribute("followPlayer") or "None"
        status.fleeDistance = horse:GetAttribute("fleeDistance") or "Unknown"
        status.lastPlayerToThrow = horse:GetAttribute("lastPlayerToThrowLasso") or "None"
        
        -- Check if fully manipulated
        status.isManipulated = (status.followPlayer == player.Name and 
                              status.lastPlayerToThrow == player.Name and 
                              status.fleeDistance == 0)
    end)
    
    return status
end

-- =================================
-- MAIN MANIPULATION LOGIC
-- =================================
local function startHorseManipulation()
    if horseManipulator.isRunning then return false end
    
    horseManipulator.isRunning = true
    horseManipulator.runtime.sessionStartTime = tick()
    horseManipulator.statistics.sessionsRun = horseManipulator.statistics.sessionsRun + 1
    horseManipulator.runtime.manipulatedCount = 0
    
    Rayfield:Notify({
       Title = "🎭 Horse Manipulation Started!",
       Content = "Revolutionary control system active | Radius: " .. horseManipulator.settings.manipulationRadius,
       Duration = 4,
       Image = 4483362458,
    })
    
    horseManipulator.manipulationConnection = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        
        -- Manipulation interval check
        if currentTime - horseManipulator.runtime.lastManipulationTime < horseManipulator.settings.manipulationInterval then
            return
        end
        
        -- Find wild horses in range
        local wildHorses = findWildHorsesInRange()
        local manipulatedThisRound = 0
        
        for _, horseData in pairs(wildHorses) do
            local horse = horseData.horse
            
            -- Skip already manipulated horses
            if not horseManipulator.manipulatedHorses[horse.Name] then
                local success, horseName = manipulateHorseAttributes(horse)
                
                if success then
                    manipulatedThisRound = manipulatedThisRound + 1
                    
                    Rayfield:Notify({
                       Title = "🎭 Horse Controlled!",
                       Content = horseName .. " is now under your control!",
                       Duration = 2,
                       Image = 4483362458,
                    })
                end
                
                -- Limit manipulations per round to avoid lag
                if manipulatedThisRound >= 3 then
                    break
                end
            end
        end
        
        horseManipulator.runtime.lastManipulationTime = currentTime
    end)
    
    return true
end

local function stopHorseManipulation()
    horseManipulator.isRunning = false
    
    if horseManipulator.manipulationConnection then
        horseManipulator.manipulationConnection:Disconnect()
        horseManipulator.manipulationConnection = nil
    end
    
    local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    Rayfield:Notify({
       Title = "🛑 Manipulation Stopped",
       Content = "Controlled: " .. horseManipulator.runtime.manipulatedCount .. " horses | Time: " .. minutes .. "m " .. seconds .. "s",
       Duration = 4,
       Image = 4483362458,
    })
end

-- =================================
-- UI SECTIONS & CONTROLS
-- =================================

-- 🎭 MAIN CONTROL SECTION
local MainControlSection = parentTab:CreateSection("🎭 Horse Manipulation Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🎭 Auto Horse Manipulation",
   CurrentValue = false,
   Flag = "HorseManipulationMainToggle",
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

local ScanNearbyButton = parentTab:CreateButton({
   Name = "🔍 Scan Nearby Horses",
   Callback = function()
      local wildHorses = findWildHorsesInRange()
      local manipulated = 0
      for _ in pairs(horseManipulator.manipulatedHorses) do
         manipulated = manipulated + 1
      end
      
      Rayfield:Notify({
         Title = "🔍 Scan Results",
         Content = "Wild horses: " .. #wildHorses .. " | Controlled: " .. manipulated,
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- 🎛️ MANIPULATION SETTINGS SECTION
local ManipulationSettingsSection = parentTab:CreateSection("🎛️ Manipulation Settings")

local RadiusSlider = parentTab:CreateSlider({
   Name = "📍 Manipulation Radius",
   Range = {50, 500},
   Increment = 10,
   Suffix = " studs",
   CurrentValue = 200,
   Flag = "ManipulationRadiusSlider",
   Callback = function(Value)
      horseManipulator.settings.manipulationRadius = Value
   end,
})

local IntervalSlider = parentTab:CreateSlider({
   Name = "⏱️ Manipulation Interval",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "s",
   CurrentValue = 2,
   Flag = "ManipulationIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.manipulationInterval = Value
   end,
})

local FleeDistanceSlider = parentTab:CreateSlider({
   Name = "🏃 Flee Distance",
   Range = {0, 100},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 0,
   Flag = "FleeDistanceSlider",
   Callback = function(Value)
      horseManipulator.settings.fleeDistance = Value
   end,
})

-- 🎯 ATTRIBUTE TOGGLES SECTION
local AttributeTogglesSection = parentTab:CreateSection("🎯 Attribute Controls")

local FollowerToggle = parentTab:CreateToggle({
   Name = "🐎 Enable Follower Behaviour",
   CurrentValue = true,
   Flag = "FollowerToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFollower = Value
   end,
})

local FleeDistanceToggle = parentTab:CreateToggle({
   Name = "🏃 Enable Flee Distance Control",
   CurrentValue = true,
   Flag = "FleeDistanceToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFleeDistance = Value
   end,
})

local LastPlayerToggle = parentTab:CreateToggle({
   Name = "🎯 Enable Exclusive Control",
   CurrentValue = true,
   Flag = "LastPlayerToggle",
   Callback = function(Value)
      horseManipulator.settings.enableLastPlayerToThrow = Value
   end,
})

-- 📊 LIVE STATUS SECTION
local LiveStatusSection = parentTab:CreateSection("📊 Live Status")

local ManipulationStatus = parentTab:CreateParagraph({Title = "🎭 Manipulation Status", Content = "Ready"})
local NearbyHorses = parentTab:CreateParagraph({Title = "🐎 Nearby Horses", Content = "Scanning..."})
local ControlledHorses = parentTab:CreateParagraph({Title = "🎯 Controlled Horses", Content = "None"})

-- ⚡ QUICK ACTIONS SECTION
local QuickActionsSection = parentTab:CreateSection("⚡ Quick Actions")

local ManipulateAllButton = parentTab:CreateButton({
   Name = "🎭 Manipulate All Nearby",
   Callback = function()
      local wildHorses = findWildHorsesInRange()
      local manipulated = 0
      
      for _, horseData in pairs(wildHorses) do
         local horse = horseData.horse
         if not horseManipulator.manipulatedHorses[horse.Name] then
            local success, horseName = manipulateHorseAttributes(horse)
            if success then
               manipulated = manipulated + 1
            end
         end
      end
      
      Rayfield:Notify({
         Title = "🎭 Mass Manipulation",
         Content = "Controlled " .. manipulated .. " horses instantly!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local ResetControlButton = parentTab:CreateButton({
   Name = "🗑️ Reset Controlled List",
   Callback = function()
      horseManipulator.manipulatedHorses = {}
      horseManipulator.runtime.manipulatedCount = 0
      Rayfield:Notify({
         Title = "✅ List Reset",
         Content = "Controlled horses list cleared",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ResetStatsButton = parentTab:CreateButton({
   Name = "📊 Reset Statistics",
   Callback = function()
      horseManipulator.statistics = {
         totalManipulated = 0,
         sessionsRun = 0,
         horsesComing = 0,
         horsesControlled = 0
      }
      Rayfield:Notify({
         Title = "📊 Stats Reset",
         Content = "All statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 STATISTICS SECTION
local StatisticsSection = parentTab:CreateSection("📈 Statistics")

local SessionStats = parentTab:CreateParagraph({Title = "📈 Session Statistics", Content = "Ready to start"})
local AllTimeStats = parentTab:CreateParagraph({Title = "🏆 All-Time Records", Content = "No data yet"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(1) do
        -- Manipulation Status
        local statusText = ""
        if horseManipulator.isRunning then
            local runtime = tick() - horseManipulator.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            statusText = "🟢 ACTIVE (Revolutionary Control)\n"
            statusText = statusText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            statusText = statusText .. "📍 Radius: " .. horseManipulator.settings.manipulationRadius .. " studs\n"
            statusText = statusText .. "🎭 Manipulated: " .. horseManipulator.runtime.manipulatedCount
        else
            statusText = "🔴 STOPPED\n💤 Ready to start\n🎭 Revolutionary horse control system\n⚡ Instant manipulation available"
        end
        ManipulationStatus:Set({Title = "🎭 Manipulation Status", Content = statusText})
        
        -- Nearby Horses
        local wildHorses = findWildHorsesInRange()
        local nearbyText = "🔍 Scanning area...\n🐎 Wild horses found: " .. #wildHorses .. "\n📍 Range: " .. horseManipulator.settings.manipulationRadius .. " studs"
        
        if #wildHorses > 0 then
            local closest = wildHorses[1]
            for _, horseData in pairs(wildHorses) do
                if horseData.distance < closest.distance then
                    closest = horseData
                end
            end
            
            local closestName = getHorseName(closest.horse)
            nearbyText = nearbyText .. "\n🎯 Closest: " .. closestName .. " (" .. math.floor(closest.distance) .. " studs)"
        end
        NearbyHorses:Set({Title = "🐎 Nearby Horses", Content = nearbyText})
        
        -- Controlled Horses
        local controlledCount = 0
        local controlledList = {}
        for _, horseInfo in pairs(horseManipulator.manipulatedHorses) do
            controlledCount = controlledCount + 1
            if controlledCount <= 3 then
                table.insert(controlledList, horseInfo.name)
            end
        end
        
        local controlledText = "🎯 Total Controlled: " .. controlledCount .. "\n"
        if #controlledList > 0 then
            controlledText = controlledText .. "📋 Recent: " .. table.concat(controlledList, ", ")
            if controlledCount > 3 then
                controlledText = controlledText .. " +" .. (controlledCount - 3) .. " more"
            end
        else
            controlledText = controlledText .. "📋 No horses controlled yet"
        end
        controlledText = controlledText .. "\n🎭 System: Revolutionary Control"
        ControlledHorses:Set({Title = "🎯 Controlled Horses", Content = controlledText})
        
        -- Session Statistics
        if horseManipulator.isRunning then
            local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🎭 Horses Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            sessionText = sessionText .. "📍 Current Radius: " .. horseManipulator.settings.manipulationRadius .. " studs\n"
            sessionText = sessionText .. "🔄 Interval: " .. horseManipulator.settings.manipulationInterval .. "s"
            
            SessionStats:Set({Title = "📈 Session Statistics", Content = sessionText})
        else
            SessionStats:Set({Title = "📈 Session Statistics", Content = "No active session\nStart manipulation to see stats\n🎭 Revolutionary system ready"})
        end
        
        -- All-Time Statistics
        local allTimeText = "🎭 Total Manipulated: " .. horseManipulator.statistics.totalManipulated .. "\n"
        allTimeText = allTimeText .. "🎮 Sessions Run: " .. horseManipulator.statistics.sessionsRun .. "\n"
        allTimeText = allTimeText .. "🎯 Currently Controlled: " .. controlledCount .. "\n"
        allTimeText = allTimeText .. "⚡ System: Attribute Manipulation\n"
        allTimeText = allTimeText .. "🔧 Features: Follower, No Flee, Exclusive"
        
        AllTimeStats:Set({Title = "🏆 All-Time Records", Content = allTimeText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Stop manipulation if running
    if horseManipulator.isRunning then
        stopHorseManipulation()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Horse manipulation stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🎭 Horse Manipulator Loaded!",
   Content = "Revolutionary attribute control system | Make horses come to YOU!",
   Duration = 5,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "🎯 System Features",
   Content = "✅ Follower Behaviour ✅ No Flee Distance ✅ Exclusive Control",
   Duration = 4,
   Image = 4483362458,
})

print("🎭 Horse Attribute Manipulator - Revolutionary Edition Loaded!")
print("🎯 Features: behaviour=Follower, followPlayer=" .. player.Name .. ", fleeDistance=0")
print("⚡ Revolutionary: Horses come to YOU, no more chasing!")
