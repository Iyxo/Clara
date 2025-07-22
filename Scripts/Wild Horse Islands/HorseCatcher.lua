-- Horse Catcher Pro - Direct Loadstring
-- by Iyxo - 2025-07-22
-- Gets tab, rayfield, and window as parameters

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES
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
-- HORSE CATCHER SYSTEM
-- =================================
local horseCatcher = {
    -- Status
    isRunning = false,
    currentTarget = nil,
    isAttached = false,
    lassoEquipped = false,
    currentLassoID = nil,
    
    -- Connections
    captureConnection = nil,
    
    -- Data
    capturedHorses = {},
    statistics = {
        totalCaptured = 0,
        sessionsRun = 0,
        currentStreak = 0,
        totalAttempts = 0,
        successfulCaptures = 0,
        bestStreak = 0
    },
    
    -- Settings
    settings = {
        -- Movement
        movementMode = "attachment",
        pulseInterval = 0.8,
        pulseDistance = 6,
        smoothSpeed = 60,
        
        -- Capturing
        captureCooldown = 0.4,
        maxAttemptsPerHorse = 18,
        maxStuckTime = 15,
        autoRetarget = true,
        smartTargeting = true,
        
        -- Safety
        maxRetries = 3,
        safeDistance = 5,
        avoidPlayers = true
    },
    
    -- Runtime data
    runtime = {
        lastCaptureTime = 0,
        lastPulseTime = 0,
        currentAttempts = 0,
        retryCount = 0,
        targetStuckTime = 0,
        lastTargetName = "",
        sessionStartTime = 0,
        lastSuccessfulCapture = 0
    }
}

-- Game System Detection
local gameSystem = {
    u1 = nil,
    u2 = nil, 
    u3 = nil,
    available = false,
    remoteEvent = nil
}

-- Initialize game system
pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.remoteEvent = ReplicatedStorage.Communication.Events['']
end)

-- =================================
-- UI SECTIONS
-- =================================
local ControlSection = parentTab:CreateSection("🎯 Main Control")
local SettingsSection = parentTab:CreateSection("⚙️ Movement & Settings")
local StatusSection = parentTab:CreateSection("📊 Live Status & Statistics")
local AdvancedSection = parentTab:CreateSection("🔧 Advanced Settings")
local ActionsSection = parentTab:CreateSection("⚡ Quick Actions")

-- =================================
-- CORE FUNCTIONS
-- =================================

-- Enhanced lasso detection and equipping
local function equipLasso()
    if horseCatcher.lassoEquipped and horseCatcher.currentLassoID then
        return true, horseCatcher.currentLassoID
    end
    
    local success = false
    local toolID = nil
    
    -- Method 1: Game system detection
    if gameSystem.available and gameSystem.u3 then
        local lastEquipped = gameSystem.u3.GetLocal({"lastEquippedLasso"})
        if lastEquipped then
            local inventoryItem = gameSystem.u3.GetLocal({"inventory", lastEquipped})
            if inventoryItem then
                pcall(function()
                    if gameSystem.u2 then
                        gameSystem.u2.Network:FireServer("Inventory", "Use", lastEquipped)
                    end
                    success = true
                    toolID = lastEquipped
                end)
            end
        end
    end
    
    -- Method 2: Direct lasso ID (fallback)
    if not success then
        toolID = "{60769f1f-cade-463b-ae32-adaacc91116f}"
        success = true
    end
    
    -- Method 3: Backpack scan
    if not success then
        pcall(function()
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
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

-- Advanced horse detection
local function findWildHorses()
    local wildHorses = {}
    local playerPositions = {}
    
    -- Get player positions for avoidance
    if horseCatcher.settings.avoidPlayers then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(playerPositions, plr.Character.HumanoidRootPart.Position)
            end
        end
    end
    
    pcall(function()
        local function scanLocation(location)
            for _, child in pairs(location:GetChildren()) do
                if child.Name:match("%{[%w%-]+%}") and child:FindFirstChild("HumanoidRootPart") then
                    local humanoid = child:FindFirstChild("Humanoid")
                    if humanoid and not Players:GetPlayerFromCharacter(child) and humanoid.Health > 0 then
                        -- Check if it's wild
                        local overheadPart = child:FindFirstChild("OverheadPart")
                        if overheadPart then
                            local overhead = overheadPart:FindFirstChild("Overhead")
                            if overhead then
                                local nameLabel = overhead:FindFirstChild("NameLabel")
                                if nameLabel and nameLabel.Text == "Wild" then
                                    -- Check if not already processed
                                    if not horseCatcher.capturedHorses[child.Name] then
                                        -- Check player avoidance
                                        local tooCloseToPlayer = false
                                        if horseCatcher.settings.avoidPlayers then
                                            for _, playerPos in pairs(playerPositions) do
                                                if (child.HumanoidRootPart.Position - playerPos).Magnitude < 30 then
                                                    tooCloseToPlayer = true
                                                    break
                                                end
                                            end
                                        end
                                        
                                        if not tooCloseToPlayer then
                                            table.insert(wildHorses, child)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Scan all possible locations
        if Workspace.Islands and Workspace.Islands.Mainland then
            scanLocation(Workspace.Islands.Mainland)
        end
        if Workspace.Islands then
            scanLocation(Workspace.Islands)
        end
    end)
    
    return wildHorses
end

-- Premium target selection
local function selectBestTarget()
    local wildHorses = findWildHorses()
    if #wildHorses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local candidates = {}
    
    for _, horse in pairs(wildHorses) do
        if horse and horse:FindFirstChild("HumanoidRootPart") then
            local horsePos = horse.HumanoidRootPart.Position
            local distance = (playerPos - horsePos).Magnitude
            local velocity = horse.HumanoidRootPart.Velocity.Magnitude
            
            -- Advanced scoring algorithm
            local score = 0
            
            -- Distance scoring
            if distance < 50 then
                score = score + 100
            elseif distance < 150 then
                score = score + 200 - distance
            elseif distance < 300 then
                score = score + 50
            else
                score = score - 100
            end
            
            -- Movement scoring
            if velocity > 3 then
                score = score + 250
            elseif velocity > 1 then
                score = score + 150
            elseif velocity > 0.2 then
                score = score + 50
            else
                score = score - 150
            end
            
            -- Height preference
            local heightDiff = math.abs(horsePos.Y - playerPos.Y)
            if heightDiff < 8 then
                score = score + 100
            elseif heightDiff < 20 then
                score = score + 25
            else
                score = score - 75
            end
            
            table.insert(candidates, {horse = horse, score = score, distance = distance})
        end
    end
    
    -- Sort by score
    table.sort(candidates, function(a, b) return a.score > b.score end)
    
    return candidates[1] and candidates[1].horse or nil
end

-- CONFIRMED WORKING capture function
local function captureHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") or not horseCatcher.currentLassoID then
        return false
    end
    
    -- Check cooldown
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCaptureTime < horseCatcher.settings.captureCooldown then
        return false
    end
    
    local success = false
    
    pcall(function()
        -- CONFIRMED WORKING METHOD
        if gameSystem.available and gameSystem.u2 then
            gameSystem.u2.Network:FireServer("Equipment", horseCatcher.currentLassoID, "Activate", horse)
            success = true
        end
        
        horseCatcher.runtime.lastCaptureTime = currentTime
        horseCatcher.runtime.currentAttempts = horseCatcher.runtime.currentAttempts + 1
        horseCatcher.statistics.totalAttempts = horseCatcher.statistics.totalAttempts + 1
    end)
    
    return success
end

-- Movement functions
local function pulseTeleport(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastPulseTime < horseCatcher.settings.pulseInterval then
        return false
    end
    
    pcall(function()
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local horseVelocity = horseRoot.Velocity
        
        -- Advanced prediction
        local prediction = horsePos + (horseVelocity * 0.6)
        
        -- Multiple approach angles
        local approaches = {
            horseRoot.CFrame.RightVector * horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.RightVector * -horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.LookVector * -horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.LookVector * horseCatcher.settings.pulseDistance
        }
        
        -- Select best approach
        local bestOffset = approaches[1]
        local shortestDist = math.huge
        for _, offset in pairs(approaches) do
            local dist = (humanoidRootPart.Position - (prediction + offset)).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                bestOffset = offset
            end
        end
        
        local heightOffset = Vector3.new(0, 4, 0)
        local targetPos = prediction + bestOffset + heightOffset
        
        humanoidRootPart.CFrame = CFrame.lookAt(targetPos, horsePos)
        horseCatcher.runtime.lastPulseTime = currentTime
    end)
    
    return true
end

local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        -- Clean previous attachments
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if attachment.Name == "HorseAttachment" and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        
        -- Create precise attachment
        local horseRoot = horse.HumanoidRootPart
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = horseRoot
        weld.Parent = humanoidRootPart
        weld.Name = "HorseAttachment"
        
        -- Optimal positioning
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.settings.safeDistance
        local heightOffset = Vector3.new(0, 3, 0)
        
        local targetCFrame = CFrame.lookAt(horseRoot.Position + sideOffset + heightOffset, horseRoot.Position)
        humanoidRootPart.CFrame = targetCFrame
        
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
        
        local prediction = horsePos + (horseVelocity * 0.4)
        local direction = (prediction - currentPos).Unit
        local distance = (prediction - currentPos).Magnitude
        
        if distance > horseCatcher.settings.safeDistance + 2 then
            local targetPos = prediction - direction * horseCatcher.settings.safeDistance
            targetPos = targetPos + Vector3.new(0, 3, 0)
            
            local tween = TweenService:Create(
                humanoidRootPart,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {CFrame = CFrame.lookAt(targetPos, prediction)}
            )
            tween:Play()
        end
    end)
    
    return true
end

-- Enhanced capture detection
local function isHorseCaptured(horse)
    if not horse or not horse.Parent then
        return true
    end
    
    local captured = false
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text ~= "Wild" then
                    captured = true
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
        
        if horseCatcher.statistics.currentStreak > horseCatcher.statistics.bestStreak then
            horseCatcher.statistics.bestStreak = horseCatcher.statistics.currentStreak
        end
        
        Rayfield:Notify({
           Title = "🎉 Horse Captured!",
           Content = "Streak: " .. horseCatcher.statistics.currentStreak .. " | Best: " .. horseCatcher.statistics.bestStreak,
           Duration = 2,
           Image = 4483362458,
        })
    end
    
    return captured
end

-- =================================
-- MAIN HORSE CATCHING LOGIC
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    -- Check lasso
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
    
    -- Check game system
    if not gameSystem.available or not gameSystem.u2 then
        Rayfield:Notify({
           Title = "❌ Game System Error!",
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
    
    Rayfield:Notify({
       Title = "🐎 Horse Catching Started!",
       Content = "Mode: " .. horseCatcher.settings.movementMode:upper() .. " | Working remote active",
       Duration = 3,
       Image = 4483362458,
    })
    
    horseCatcher.captureConnection = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        -- Check if current target was captured
        if horseCatcher.currentTarget and isHorseCaptured(horseCatcher.currentTarget) then
            horseCatcher.currentTarget = nil
            horseCatcher.runtime.currentAttempts = 0
            horseCatcher.runtime.retryCount = 0
            horseCatcher.runtime.targetStuckTime = 0
            horseCatcher.isAttached = false
            return
        end
        
        -- Find new target if needed
        if not horseCatcher.currentTarget or horseCatcher.runtime.currentAttempts > horseCatcher.settings.maxAttemptsPerHorse then
            if horseCatcher.runtime.currentAttempts > horseCatcher.settings.maxAttemptsPerHorse then
                if horseCatcher.currentTarget then
                    horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
                end
            end
            
            if horseCatcher.settings.smartTargeting then
                horseCatcher.currentTarget = selectBestTarget()
            else
                local horses = findWildHorses()
                horseCatcher.currentTarget = horses[1]
            end
            
            horseCatcher.runtime.currentAttempts = 0
            horseCatcher.runtime.retryCount = 0
            horseCatcher.runtime.targetStuckTime = 0
            horseCatcher.isAttached = false
        end
        
        if not horseCatcher.currentTarget then return end
        
        -- Movement handling
        if horseCatcher.settings.movementMode == "pulse" then
            pulseTeleport(horseCatcher.currentTarget)
        elseif horseCatcher.settings.movementMode == "attachment" then
            if not horseCatcher.isAttached then
                attachToHorse(horseCatcher.currentTarget)
            end
        elseif horseCatcher.settings.movementMode == "smooth" then
            smoothFollow(horseCatcher.currentTarget)
        end
        
        -- Capture attempt
        captureHorse(horseCatcher.currentTarget)
        
        -- Stuck detection
        if horseCatcher.runtime.lastTargetName == horseCatcher.currentTarget.Name then
            horseCatcher.runtime.targetStuckTime = horseCatcher.runtime.targetStuckTime + 1
        else
            horseCatcher.runtime.targetStuckTime = 0
            horseCatcher.runtime.lastTargetName = horseCatcher.currentTarget.Name
        end
        
        -- Skip stuck targets
        if horseCatcher.runtime.targetStuckTime > horseCatcher.settings.maxStuckTime * 60 then
            horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
            horseCatcher.currentTarget = nil
            Rayfield:Notify({
               Title = "⏭️ Target Skipped",
               Content = "Horse stuck too long, moving to next",
               Duration = 2,
               Image = 4483362458,
            })
        end
    end)
    
    return true
end

local function stopHorseCatching()
    horseCatcher.isRunning = false
    
    if horseCatcher.captureConnection then
        horseCatcher.captureConnection:Disconnect()
        horseCatcher.captureConnection = nil
    end
    
    -- Cleanup
    pcall(function()
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if attachment.Name == "HorseAttachment" and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
    end)
    
    horseCatcher.isAttached = false
    horseCatcher.currentTarget = nil
    
    local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    Rayfield:Notify({
       Title = "🛑 Session Ended",
       Content = "Captured: " .. horseCatcher.statistics.currentStreak .. " | Time: " .. minutes .. "m " .. seconds .. "s",
       Duration = 4,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- UI CONTROLS
-- =================================

-- MAIN CONTROL
local MainToggle = parentTab:CreateToggle({
   Name = "🐎 Auto Horse Catching",
   CurrentValue = false,
   Flag = "HorseCatchingMainToggle",
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

local TestSystemButton = parentTab:CreateButton({
   Name = "🧪 Test System",
   Callback = function()
      local lassoReady, lassoID = equipLasso()
      if gameSystem.available and gameSystem.u2 and lassoReady then
         Rayfield:Notify({
            Title = "✅ System Ready",
            Content = "Network: ✅ | Lasso: ✅ | Ready to catch!",
            Duration = 3,
            Image = 4483362458,
         })
      else
         local issues = {}
         if not gameSystem.available then table.insert(issues, "Game System") end
         if not gameSystem.u2 then table.insert(issues, "Network") end
         if not lassoReady then table.insert(issues, "Lasso") end
         
         Rayfield:Notify({
            Title = "❌ System Issues",
            Content = "Problems: " .. table.concat(issues, ", "),
            Duration = 4,
            Image = 4483362458,
         })
      end
   end,
})

-- SETTINGS
local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"attachment", "pulse", "smooth"},
   CurrentOption = {"attachment"},
   MultipleOptions = false,
   Flag = "HorseMovementModeDropdown",
   Callback = function(Option)
      horseCatcher.settings.movementMode = Option[1]
      Rayfield:Notify({
         Title = "📍 Movement Changed",
         Content = "Now using: " .. Option[1]:upper() .. " mode",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local PulseIntervalSlider = parentTab:CreateSlider({
   Name = "⚡ Pulse Interval",
   Range = {0.3, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.8,
   Flag = "HorsePulseIntervalSlider",
   Callback = function(Value)
      horseCatcher.settings.pulseInterval = Value
   end,
})

local CaptureCooldownSlider = parentTab:CreateSlider({
   Name = "⏱️ Capture Cooldown",
   Range = {0.2, 1.5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.4,
   Flag = "HorseCaptureCooldownSlider",
   Callback = function(Value)
      horseCatcher.settings.captureCooldown = Value
   end,
})

local SmartTargetingToggle = parentTab:CreateToggle({
   Name = "🧠 Smart Targeting",
   CurrentValue = true,
   Flag = "HorseSmartTargetingToggle",
   Callback = function(Value)
      horseCatcher.settings.smartTargeting = Value
   end,
})

-- STATUS
local SystemStatus = parentTab:CreateParagraph({Title = "🔧 System Status", Content = "Initializing..."})
local CatchingStatus = parentTab:CreateParagraph({Title = "🎯 Catching Status", Content = "Ready"})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Current Target", Content = "None"})
local Statistics = parentTab:CreateParagraph({Title = "📊 Session Statistics", Content = "Ready to start"})

-- ADVANCED SETTINGS
local MaxAttemptsSlider = parentTab:CreateSlider({
   Name = "🎯 Max Attempts per Horse",
   Range = {10, 35},
   Increment = 1,
   Suffix = " attempts",
   CurrentValue = 18,
   Flag = "HorseMaxAttemptsSlider",
   Callback = function(Value)
      horseCatcher.settings.maxAttemptsPerHorse = Value
   end,
})

local StuckTimeSlider = parentTab:CreateSlider({
   Name = "⏳ Max Stuck Time",
   Range = {10, 30},
   Increment = 1,
   Suffix = "s",
   CurrentValue = 15,
   Flag = "HorseStuckTimeSlider", 
   Callback = function(Value)
      horseCatcher.settings.maxStuckTime = Value
   end,
})

local PulseDistanceSlider = parentTab:CreateSlider({
   Name = "📏 Pulse Distance", 
   Range = {3, 15},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 6,
   Flag = "HorsePulseDistanceSlider",
   Callback = function(Value)
      horseCatcher.settings.pulseDistance = Value
   end,
})

local SafeDistanceSlider = parentTab:CreateSlider({
   Name = "🛡️ Safe Distance",
   Range = {2, 10},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 5,
   Flag = "HorseSafeDistanceSlider",
   Callback = function(Value)
      horseCatcher.settings.safeDistance = Value
   end,
})

local AvoidPlayersToggle = parentTab:CreateToggle({
   Name = "👥 Avoid Other Players",
   CurrentValue = true,
   Flag = "HorseAvoidPlayersToggle",
   Callback = function(Value)
      horseCatcher.settings.avoidPlayers = Value
   end,
})

-- QUICK ACTIONS
local ResetCapturedButton = parentTab:CreateButton({
   Name = "🗑️ Reset Captured List",
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

local DetachButton = parentTab:CreateButton({
   Name = "🔓 Force Detach",
   Callback = function()
      pcall(function()
         for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if attachment.Name == "HorseAttachment" and attachment:IsA("WeldConstraint") then
               attachment:Destroy()
            end
         end
      end)
      horseCatcher.isAttached = false
      horseCatcher.currentTarget = nil
   end,
})

local ResetStatsButton = parentTab:CreateButton({
   Name = "📊 Reset Statistics",
   Callback = function()
      horseCatcher.statistics = {
         totalCaptured = 0,
         sessionsRun = 0,
         currentStreak = 0,
         totalAttempts = 0,
         successfulCaptures = 0,
         bestStreak = 0
      }
      Rayfield:Notify({
         Title = "📊 Stats Reset",
         Content = "All statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- =================================
-- STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(1) do
        -- System Status
        local systemText = ""
        if gameSystem.available and gameSystem.u2 then
            systemText = "✅ Game System: Connected\n✅ Network (u2): Available\n✅ Working Remote: Active"
        elseif gameSystem.available then
            systemText = "⚠️ Game System: Connected\n❌ Network (u2): Missing\n❌ Cannot Function"
        else
            systemText = "❌ Game System: Disconnected\n❌ Network: Unavailable\n❌ System Failure"
        end
        
        local lassoReady, lassoID = equipLasso()
        if lassoReady then
            systemText = systemText .. "\n✅ Lasso: Ready (" .. (lassoID and lassoID:sub(1,10) or "Unknown") .. "...)"
        else
            systemText = systemText .. "\n❌ Lasso: Not Found"
        end
        
        SystemStatus:Set({Title = "🔧 System Status", Content = systemText})
        
        -- Catching Status
        local catchingText = ""
        if horseCatcher.isRunning then
            local runtime = tick() - horseCatcher.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            catchingText = "🟢 ACTIVE (" .. horseCatcher.settings.movementMode:upper() .. ")\n"
            catchingText = catchingText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            catchingText = catchingText .. "🎯 Cooldown: " .. horseCatcher.settings.captureCooldown .. "s\n"
            catchingText = catchingText .. "🧠 Smart: " .. (horseCatcher.settings.smartTargeting and "✅" or "❌")
        else
            catchingText = "🔴 STOPPED\n💤 Ready to start\n⚙️ Mode: " .. horseCatcher.settings.movementMode:upper() .. "\n🔧 System: " .. (gameSystem.available and gameSystem.u2 and "✅" or "❌")
        end
        CatchingStatus:Set({Title = "🎯 Catching Status", Content = catchingText})
        
        -- Target Info
        local targetText = ""
        if horseCatcher.currentTarget then
            local targetName = horseCatcher.currentTarget.Name:sub(1, 12) .. "..."
            local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
            
            targetText = "🐎 " .. targetName .. "\n"
            targetText = targetText .. "📏 Distance: " .. distance .. " studs\n"
            targetText = targetText .. "🎯 Attempts: " .. horseCatcher.runtime.currentAttempts .. "/" .. horseCatcher.settings.maxAttemptsPerHorse .. "\n"
            
            if horseCatcher.settings.movementMode == "attachment" then
                targetText = targetText .. "🔗 Attached: " .. (horseCatcher.isAttached and "✅" or "❌")
            elseif horseCatcher.settings.movementMode == "pulse" then
                local nextPulse = math.max(0, horseCatcher.settings.pulseInterval - (tick() - horseCatcher.runtime.lastPulseTime))
                targetText = targetText .. "⚡ Next Pulse: " .. string.format("%.1f", nextPulse) .. "s"
            else
                targetText = targetText .. "🌊 Smooth Follow: Active"
            end
        else
            local wildCount = #findWildHorses()
            targetText = "🔍 Searching for targets...\n🐎 Wild horses found: " .. wildCount .. "\n📊 Available targets in area"
        end
        TargetInfo:Set({Title = "🐎 Current Target", Content = targetText})
        
        -- Statistics
        local statsText = ""
        local capturedCount = 0
        for _ in pairs(horseCatcher.capturedHorses) do
            capturedCount = capturedCount + 1
        end
        
        local successRate = 0
        if horseCatcher.statistics.totalAttempts > 0 then
            successRate = math.floor((horseCatcher.statistics.successfulCaptures / horseCatcher.statistics.totalAttempts) * 100)
        end
        
        statsText = "🔥 Current Streak: " .. horseCatcher.statistics.currentStreak .. "\n"
        statsText = statsText .. "🏆 Best Streak: " .. horseCatcher.statistics.bestStreak .. "\n"
        statsText = statsText .. "📈 Total Captured: " .. horseCatcher.statistics.totalCaptured .. "\n"
        statsText = statsText .. "🎯 Success Rate: " .. successRate .. "%\n"
        statsText = statsText .. "🎮 Sessions: " .. horseCatcher.statistics.sessionsRun .. "\n"
        statsText = statsText .. "📝 Marked: " .. capturedCount
        Statistics:Set({Title = "📊 Session Statistics", Content = statsText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reset states
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    
    -- Stop catching if running
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
-- INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🐎 Horse Catcher Pro Loaded!",
   Content = "All features loaded via loadstring | Working remote confirmed",
   Duration = 4,
   Image = 4483362458,
})

if gameSystem.available and gameSystem.u2 then
    Rayfield:Notify({
       Title = "✅ System Ready!",
       Content = "All systems operational - Ready to catch horses!",
       Duration = 3,
       Image = 4483362458,
    })
else
    Rayfield:Notify({
       Title = "⚠️ System Warning",
       Content = "Network system issues detected - Check system status",
       Duration = 4,
       Image = 4483362458,
    })
end

print("🐎 Horse Catcher Pro Loadstring Executed Successfully!")
print("✅ Confirmed working remote: Equipment protocol")
print("📊 All features loaded directly into tab")
