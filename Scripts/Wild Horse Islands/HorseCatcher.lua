-- Horse Catcher Module for Iyxo's Advanced Hub
-- Stworzony przez: Iyxo
-- Data: 2025-07-21

if not getgenv().IyxoHub or not getgenv().IyxoHub.Window then
    warn("❌ Main Hub not loaded! Load MainHub.lua first!")
    return
end

if getgenv().IyxoHub.Modules.HorseCatcher then
    warn("⚠️ Horse Catcher already loaded!")
    return
end

-- Oznacz moduł jako załadowany
getgenv().IyxoHub.Modules.HorseCatcher = true

-- Usługi
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- ZMIENNE HORSE CATCHER
-- =================================
local horseCatcher = {
    isRunning = false,
    captureConnection = nil,
    currentTarget = nil,
    isAttached = false,
    capturedHorses = {},
    lassoEquipped = false,
    currentLassoID = nil,
    lastCaptureTime = 0,
    
    -- Ustawienia domyślne (zaktualizowane)
    captureCooldown = 0.5,
    maxCaptureAttempts = 15,
    maxStuckTime = 8,
    
    currentAttempts = 0,
    forceDetach = false,
    retryCount = 0,
    maxRetries = 3,
    lastTargetName = "",
    targetStuckTime = 0,
    
    -- Movement settings
    movementMode = "Attach", -- "Attach" lub "Pulse"
    pulseInterval = 1,
    lastPulseTime = 0,
    pulseDistance = 8
}

-- System gry
local gameSystem = {
    u1 = nil,
    u2 = nil,
    u3 = nil,
    available = false
}

pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
end)

-- =================================
-- ZAKŁADKA HORSE CATCHER
-- =================================
local Window = getgenv().IyxoHub.Window
local HorseCatcherTab = Window:CreateTab("🐎 Horse Catcher", 4483362458)

-- =================================
-- SEKCJE - UPORZĄDKOWANE
-- =================================
local MainControlSection = HorseCatcherTab:CreateSection("🎯 Horse Catcher Control")
local MovementSection = HorseCatcherTab:CreateSection("📍 Movement Settings")
local AdvancedSection = HorseCatcherTab:CreateSection("⚙️ Advanced Settings")
local StatusSection = HorseCatcherTab:CreateSection("📊 Live Status")

-- =================================
-- FUNKCJE HORSE CATCHER
-- =================================

-- Ulepszone znajdowanie narzędzi
local function getTool(toolType)
    if gameSystem.available and gameSystem.u3 then
        local lastEquipped = gameSystem.u3.GetLocal({("lastEquipped%s"):format(toolType)})
        if lastEquipped then
            local inventoryItem = gameSystem.u3.GetLocal({"inventory", lastEquipped})
            if inventoryItem then
                return lastEquipped, inventoryItem
            end
        end
    end
    return nil, nil
end

-- Ulepszone używanie narzędzi z retry
local function useTool(toolType)
    local toolID, toolData = getTool(toolType)
    if toolID and toolData then
        local success = false
        for i = 1, 3 do
            pcall(function()
                if gameSystem.available and gameSystem.u2 then
                    gameSystem.u2.Network:FireServer("Inventory", "Use", toolID)
                else
                    ReplicatedStorage.Communication.Events['']:FireServer("Use", toolID)
                end
                success = true
            end)
            if success then break end
            wait(0.1)
        end
        return success, toolID, toolData.amt or 1
    end
    return false, nil, 0
end

-- Znajdowanie Wild koni
local function findWildHorses()
    local wildHorses = {}
    
    pcall(function()
        local locations = {
            Workspace.Islands.Mainland,
            Workspace.Islands
        }
        
        for _, location in pairs(locations) do
            if location then
                for _, child in pairs(location:GetChildren()) do
                    if child.Name:match("%{[%w%-]+%}") and child:FindFirstChild("HumanoidRootPart") then
                        local humanoid = child:FindFirstChild("Humanoid")
                        if humanoid and not Players:GetPlayerFromCharacter(child) then
                            local overheadPart = child:FindFirstChild("OverheadPart")
                            if overheadPart then
                                local overhead = overheadPart:FindFirstChild("Overhead")
                                if overhead then
                                    local nameLabel = overhead:FindFirstChild("NameLabel")
                                    if nameLabel and nameLabel.Text == "Wild" then
                                        if not horseCatcher.capturedHorses[child.Name] and humanoid.Health > 0 then
                                            local rootPart = child.HumanoidRootPart
                                            if rootPart.Velocity.Magnitude > 0.1 or not horseCatcher.isRunning then
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
        end
    end)
    
    return wildHorses
end

-- Znajdowanie najbliższego konia
local function findNearestWildHorse()
    local wildHorses = findWildHorses()
    local nearestHorse = nil
    local shortestDistance = math.huge
    
    local movingHorses = {}
    local stillHorses = {}
    
    for _, horse in pairs(wildHorses) do
        if horse and horse:FindFirstChild("HumanoidRootPart") then
            local distance = (humanoidRootPart.Position - horse.HumanoidRootPart.Position).Magnitude
            
            if horse.HumanoidRootPart.Velocity.Magnitude > 1 then
                table.insert(movingHorses, {horse = horse, distance = distance})
            else
                table.insert(stillHorses, {horse = horse, distance = distance})
            end
        end
    end
    
    local targetList = #movingHorses > 0 and movingHorses or stillHorses
    
    for _, data in pairs(targetList) do
        if data.distance < shortestDistance then
            shortestDistance = data.distance
            nearestHorse = data.horse
        end
    end
    
    return nearestHorse, shortestDistance
end

-- Pulse Teleport do konia
local function pulseTeleportToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentTime = tick()
    if currentTime - horseCatcher.lastPulseTime < horseCatcher.pulseInterval then
        return false
    end
    
    pcall(function()
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.pulseDistance
        local heightOffset = Vector3.new(0, 2, 0)
        
        humanoidRootPart.CFrame = CFrame.new(horsePos + sideOffset + heightOffset, horsePos)
        
        horseCatcher.lastPulseTime = currentTime
    end)
    
    return true
end

-- Przyczepienie do konia (Attach mode)
local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        detachFromHorse()
        
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local sideOffset = horseRoot.CFrame.RightVector * 4
        local heightOffset = Vector3.new(0, 3, 0)
        
        humanoidRootPart.CFrame = CFrame.new(horsePos + sideOffset + heightOffset, horsePos)
        wait(0.05)
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = horseRoot
        weld.Parent = humanoidRootPart
        weld.Name = "HorseAttachment"
        horseCatcher.isAttached = true
        
        horseCatcher.currentAttempts = 0
        horseCatcher.targetStuckTime = 0
    end)
    
    return true
end

-- Łapanie konia
local function captureHorseAdvanced(horse)
    if not horse or not horseCatcher.currentLassoID or not gameSystem.available then 
        return false 
    end
    
    local currentTime = tick()
    if currentTime - horseCatcher.lastCaptureTime < horseCatcher.captureCooldown then
        return false
    end
    
    local success = false
    
    pcall(function()
        local horseRoot = horse.HumanoidRootPart
        local lassoID = horseCatcher.currentLassoID
        
        if gameSystem.u2 and gameSystem.u2.Network then
            gameSystem.u2.Network:FireServer(lassoID, "Activate", horse)
            gameSystem.u2.Network:FireServer("Equipment", lassoID, "Activate", horse)
            gameSystem.u2.Network:FireServer("Inventory", "Activate", lassoID, horse)
        end
        
        local commEvents = ReplicatedStorage:FindFirstChild("Communication")
        if commEvents then
            local events = commEvents:FindFirstChild("Events")
            if events then
                local mainEvent = events:FindFirstChild("")
                if mainEvent then
                    mainEvent:FireServer(lassoID, "Activate", horse)
                    mainEvent:FireServer("Use", lassoID, horse)
                end
            end
        end
        
        horseCatcher.lastCaptureTime = currentTime
        horseCatcher.currentAttempts = horseCatcher.currentAttempts + 1
        success = true
    end)
    
    return success
end

-- Odczepienie
function detachFromHorse()
    pcall(function()
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if attachment.Name == "HorseAttachment" or attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        horseCatcher.isAttached = false
        horseCatcher.forceDetach = false
    end)
end

-- Auto-equip Lasso
local function autoEquipLasso()
    if horseCatcher.lassoEquipped and horseCatcher.currentLassoID then
        return true, horseCatcher.currentLassoID
    end
    
    local success, toolID = useTool("Lasso")
    if success then
        horseCatcher.lassoEquipped = true
        horseCatcher.currentLassoID = toolID
        return true, toolID
    end
    return false
end

-- Sprawdzenie czy koń został złapany
local function checkIfHorseCaptured(horse)
    if not horse or not horse.Parent then
        if horse and horseCatcher.currentTarget == horse then
            horseCatcher.capturedHorses[horse.Name] = true
        end
        return true
    end
    
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text ~= "Wild" then
                    horseCatcher.capturedHorses[horse.Name] = true
                    return true
                end
            end
        end
    end)
    
    return false
end

-- GŁÓWNA FUNKCJA ŁAPANIA
function startHorseCatching()
    if not gameSystem.available then
        getgenv().Rayfield:Notify({
           Title = "❌ Błąd systemu!",
           Content = "System gry niedostępny!",
           Duration = 5,
           Image = 4483362458,
        })
        return false
    end
    
    local equipped, lassoID = autoEquipLasso()
    if not equipped then
        getgenv().Rayfield:Notify({
           Title = "❌ Błąd Lasso!",
           Content = "Nie można wyposażyć Lasso!",
           Duration = 5,
           Image = 4483362458,
        })
        return false
    end
    
    horseCatcher.isRunning = true
    horseCatcher.lastCaptureTime = 0
    horseCatcher.currentAttempts = 0
    horseCatcher.retryCount = 0
    horseCatcher.lastPulseTime = 0
    
    getgenv().Rayfield:Notify({
       Title = "🐎 Horse Catcher Started!",
       Content = "Mode: " .. horseCatcher.movementMode,
       Duration = 3,
       Image = 4483362458,
    })
    
    horseCatcher.captureConnection = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        if horseCatcher.currentTarget and checkIfHorseCaptured(horseCatcher.currentTarget) then
            if horseCatcher.movementMode == "Attach" then
                detachFromHorse()
            end
            horseCatcher.currentTarget = nil
            horseCatcher.currentAttempts = 0
            horseCatcher.retryCount = 0
            horseCatcher.targetStuckTime = 0
            return
        end
        
        if not horseCatcher.currentTarget then
            local horse, distance = findNearestWildHorse()
            if horse then
                horseCatcher.currentTarget = horse
                horseCatcher.currentAttempts = 0
                horseCatcher.lastTargetName = horse.Name
                horseCatcher.targetStuckTime = 0
            else
                if horseCatcher.movementMode == "Attach" then
                    detachFromHorse()
                end
                return
            end
        end
        
        if horseCatcher.currentTarget then
            if horseCatcher.lastTargetName == horseCatcher.currentTarget.Name then
                horseCatcher.targetStuckTime = horseCatcher.targetStuckTime + 1
            else
                horseCatcher.targetStuckTime = 0
                horseCatcher.lastTargetName = horseCatcher.currentTarget.Name
            end
            
            if horseCatcher.targetStuckTime > horseCatcher.maxStuckTime * 60 then
                horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
                if horseCatcher.movementMode == "Attach" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.targetStuckTime = 0
                return
            end
            
            -- WYBÓR TRYBU MOVEMENT
            if horseCatcher.movementMode == "Pulse" then
                pulseTeleportToHorse(horseCatcher.currentTarget)
            else -- Attach
                if not horseCatcher.isAttached or horseCatcher.forceDetach then
                    attachToHorse(horseCatcher.currentTarget)
                end
            end
            
            local captured = captureHorseAdvanced(horseCatcher.currentTarget)
            
            if horseCatcher.currentAttempts > horseCatcher.maxCaptureAttempts then
                horseCatcher.retryCount = horseCatcher.retryCount + 1
                
                if horseCatcher.retryCount > horseCatcher.maxRetries then
                    horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
                    if horseCatcher.movementMode == "Attach" then
                        detachFromHorse()
                    end
                    horseCatcher.currentTarget = nil
                    horseCatcher.retryCount = 0
                else
                    if horseCatcher.movementMode == "Attach" then
                        detachFromHorse()
                        horseCatcher.forceDetach = true
                    end
                    horseCatcher.currentAttempts = 0
                    wait(0.5)
                end
            end
        end
    end)
    
    return true
end

function stopHorseCatching()
    horseCatcher.isRunning = false
    
    if horseCatcher.captureConnection then
        horseCatcher.captureConnection:Disconnect()
        horseCatcher.captureConnection = nil
    end
    
    detachFromHorse()
    horseCatcher.currentTarget = nil
    
    getgenv().Rayfield:Notify({
       Title = "🛑 Horse Catcher Stopped",
       Content = "Łapanie zostało zatrzymane.",
       Duration = 3,
       Image = 4483362458,
    })
end

-- =================================
-- KONTROLKI - NOWY UKŁAD
-- =================================

-- 1. GŁÓWNA FUNKCJA NA GÓRZE
local HorseCatchingToggle = MainControlSection:CreateToggle({
   Name = "🐎 Auto Horse Catching",
   CurrentValue = false,
   Flag = "HorseCatchingToggle",
   Callback = function(Value)
      if Value then
         local success = startHorseCatching()
         if not success then
            HorseCatchingToggle:Set(false)
         end
      else
         stopHorseCatching()
      end
   end,
})

-- 2. WYBÓR TRYBU MOVEMENT (DROPDOWN ZAMIAST TOGGLE)
local MovementModeDropdown = MovementSection:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"Attach", "Pulse"},
   CurrentOption = "Attach",
   Flag = "MovementModeDropdown",
   Callback = function(Option)
      horseCatcher.movementMode = Option
      if Option == "Attach" then
         detachFromHorse()
         getgenv().Rayfield:Notify({
            Title = "🔗 Attach Mode",
            Content = "Klasyczny tryb przyczepienia",
            Duration = 2,
            Image = 4483362458,
         })
      else
         detachFromHorse()
         getgenv().Rayfield:Notify({
            Title = "⚡ Pulse Mode",
            Content = "Teleportacja co " .. horseCatcher.pulseInterval .. "s",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

-- 3. USTAWIENIA PULSE (WIDOCZNE TYLKO PRZY PULSE)
local PulseIntervalSlider = MovementSection:CreateSlider({
   Name = "⏱️ Pulse Interval",
   Range = {0.5, 3},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 1,
   Flag = "PulseInterval",
   Callback = function(Value)
      horseCatcher.pulseInterval = Value
   end,
})

local PulseDistanceSlider = MovementSection:CreateSlider({
   Name = "📍 Pulse Distance",
   Range = {3, 15},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 8,
   Flag = "PulseDistance",
   Callback = function(Value)
      horseCatcher.pulseDistance = Value
   end,
})

-- 4. ADVANCED SETTINGS (ZAKTUALIZOWANE DOMYŚLNE)
local CooldownSlider = AdvancedSection:CreateSlider({
   Name = "⏱️ Capture Cooldown",
   Range = {0.1, 3},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "CaptureCooldown",
   Callback = function(Value)
      horseCatcher.captureCooldown = Value
   end,
})

local MaxAttemptsSlider = AdvancedSection:CreateSlider({
   Name = "🎯 Max Attempts per Horse",
   Range = {5, 30},
   Increment = 1,
   Suffix = " attempts",
   CurrentValue = 15,
   Flag = "MaxAttempts",
   Callback = function(Value)
      horseCatcher.maxCaptureAttempts = Value
   end,
})

local StuckTimeSlider = AdvancedSection:CreateSlider({
   Name = "⏳ Max Time per Horse",
   Range = {3, 20},
   Increment = 1,
   Suffix = "s",
   CurrentValue = 8,
   Flag = "StuckTime",
   Callback = function(Value)
      horseCatcher.maxStuckTime = Value
   end,
})

-- 5. STATUS DISPLAYS
local SystemStatus = StatusSection:CreateParagraph({Title = "🔧 System Status", Content = "Checking..."})
local CatchingStatus = StatusSection:CreateParagraph({Title = "🎯 Catching Status", Content = "Ready"})
local TargetStatus = StatusSection:CreateParagraph({Title = "🐎 Current Target", Content = "None"})
local StatsStatus = StatusSection:CreateParagraph({Title = "📊 Statistics", Content = "Loading..."})

-- 6. DEBUG CONTROLS
local ClearCapturedButton = AdvancedSection:CreateButton({
   Name = "🗑️ Clear Captured List",
   Callback = function()
      horseCatcher.capturedHorses = {}
      getgenv().Rayfield:Notify({
         Title = "✅ List Cleared",
         Content = "Lista złapanych koni wyczyszczona.",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ForceDetachButton = AdvancedSection:CreateButton({
   Name = "🔓 Force Detach",
   Callback = function()
      detachFromHorse()
      horseCatcher.currentTarget = nil
      getgenv().Rayfield:Notify({
         Title = "🔓 Detached",
         Content = "Odczepiono od konia.",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- =================================
-- STATUS UPDATE LOOP
-- =================================
spawn(function()
    while wait(1) do
        -- System Status
        if gameSystem.available then
            SystemStatus:Set({Title = "🔧 System Status", Content = "✅ Game System Connected\n✅ References Available\n✅ Network Ready"})
        else
            SystemStatus:Set({Title = "🔧 System Status", Content = "❌ Game System Unavailable\n⚠️ Limited Functionality"})
        end
        
        -- Catching Status
        if horseCatcher.isRunning then
            local status = "🟢 CATCHING ACTIVE\n"
            status = status .. "📍 Mode: " .. horseCatcher.movementMode .. "\n"
            status = status .. "⏱️ Cooldown: " .. horseCatcher.captureCooldown .. "s\n"
            status = status .. "🎯 Max Attempts: " .. horseCatcher.maxCaptureAttempts
            CatchingStatus:Set({Title = "🎯 Catching Status", Content = status})
        else
            CatchingStatus:Set({Title = "🎯 Catching Status", Content = "🔴 STOPPED\n💤 Ready to start"})
        end
        
        -- Target Status
        if horseCatcher.currentTarget then
            local targetInfo = "🐎 " .. horseCatcher.currentTarget.Name:sub(1, 15) .. "\n"
            
            if horseCatcher.movementMode == "Pulse" then
                local timeSinceLastPulse = tick() - horseCatcher.lastPulseTime
                local nextPulse = math.max(0, horseCatcher.pulseInterval - timeSinceLastPulse)
                targetInfo = targetInfo .. "⚡ Next Pulse: " .. string.format("%.1f", nextPulse) .. "s\n"
            else
                targetInfo = targetInfo .. "🔗 Attached: " .. (horseCatcher.isAttached and "✅" or "❌") .. "\n"
            end
            
            targetInfo = targetInfo .. "🎯 Attempts: " .. horseCatcher.currentAttempts .. "/" .. horseCatcher.maxCaptureAttempts .. "\n"
            targetInfo = targetInfo .. "🔄 Retry: " .. horseCatcher.retryCount .. "/" .. horseCatcher.maxRetries
            TargetStatus:Set({Title = "🐎 Current Target", Content = targetInfo})
        else
            TargetStatus:Set({Title = "🐎 Current Target", Content = "🔍 Searching for Wild horses..."})
        end
        
        -- Statistics
        local wildHorses = findWildHorses()
        local capturedCount = 0
        for _ in pairs(horseCatcher.capturedHorses) do
            capturedCount = capturedCount + 1
        end
        
        local stats = "🐎 Wild Horses Found: " .. #wildHorses .. "\n"
        stats = stats .. "✅ Horses Captured: " .. capturedCount .. "\n"
        stats = stats .. "🪢 Lasso Equipped: " .. (horseCatcher.lassoEquipped and "✅" or "❌") .. "\n"
        stats = stats .. "📍 Movement: " .. horseCatcher.movementMode
        StatsStatus:Set({Title = "📊 Statistics", Content = stats})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    horseCatcher.isAttached = false
    detachFromHorse()
    
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
end)

-- =================================
-- MODULE LOADED
-- =================================
getgenv().Rayfield:Notify({
   Title = "🐎 Horse Catcher Loaded!",
   Content = "Module ready with improved UI layout!",
   Duration = 3,
   Image = 4483362458,
})

print("🐎 Horse Catcher Module loaded successfully!")
print("📍 Movement modes: Attach, Pulse")
print("⚙️ Improved UI layout with organized sections")
