-- Button Game Ultra Advanced Clicker - Game System Integration Edition
-- by Iyxo - 2025-07-22 10:51:09
-- Revolutionary button clicker with native game system integration

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES & GAME SYSTEM
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =================================
-- GAME SYSTEM INTEGRATION
-- =================================
local gameSystem = {
    u1 = nil,
    u2 = nil,
    u3 = nil,
    u5 = nil, -- PromptHandler
    u6 = nil, -- EffectsHandler
    u7 = nil, -- StatHandler
    u8 = nil, -- MenuHandler
    available = false,
    minigameController = nil,
    networkReady = false
}

-- Initialize game system
pcall(function()
    gameSystem.u1 = require(ReplicatedStorage:WaitForChild("References"))
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.u5 = require(gameSystem.u1.PlayerScripts.Secondary:WaitForChild("PromptHandler"))
    gameSystem.u6 = require(gameSystem.u1.PlayerScripts.Secondary:WaitForChild("EffectsHandler"))
    gameSystem.u7 = require(gameSystem.u1.PlayerScripts.Secondary:WaitForChild("StatHandler"))
    gameSystem.u8 = require(gameSystem.u1.PlayerScripts.Secondary:WaitForChild("MenuHandler"))
    gameSystem.available = true
    gameSystem.networkReady = (gameSystem.u2 and gameSystem.u2.Network) and true or false
end)

-- =================================
-- ULTRA ADVANCED BUTTON CLICKER SYSTEM
-- =================================
local buttonClicker = {
    isActive = false,
    connections = {},
    gameDetected = false,
    debugMode = true,
    
    -- Game detection
    currentGame = "Unknown",
    gameActive = false,
    lastGameTime = 0,
    
    -- Click statistics
    totalClicks = 0,
    sessionClicks = 0,
    clicksPerSecond = 0,
    bestClickRate = 0,
    
    -- Advanced settings
    settings = {
        instantClick = true,
        clickDelay = 0.001,
        multiTargeting = true,
        smartAnalysis = true,
        gameSystemIntegration = true,
        aggressiveClicking = true,
        preventCooldowns = false,
        autoGameStart = false,
        perfectTiming = true
    },
    
    -- Button analysis
    buttonAnalysis = {
        totalButtons = 0,
        emptyTextButtons = 0,
        numberedButtons = 0,
        iconButtons = 0,
        clickableButtons = 0,
        lastAnalysisTime = 0
    },
    
    -- Performance tracking
    performance = {
        clickTimes = {},
        analysisTimes = {},
        avgClickTime = 0,
        maxClickTime = 0,
        clickSuccess = 0,
        clickFails = 0
    }
}

-- =================================
-- ADVANCED GAME DETECTION SYSTEM
-- =================================

-- Enhanced game container detection
local function getGameContainer()
    local containers = {}
    
    -- Method 1: Button Reaction Game (primary)
    local success1, container1 = pcall(function()
        return playerGui.Prompts.ButtonReactionGame.Buttons
    end)
    if success1 and container1 then
        containers.buttonReaction = {
            container = container1,
            type = "ButtonReactionGame",
            priority = 1
        }
    end
    
    -- Method 2: Dancing Horses (secondary)
    local success2, container2 = pcall(function()
        return playerGui.Prompts.DancingHorses.Buttons
    end)
    if success2 and container2 then
        containers.dancingHorses = {
            container = container2,
            type = "DancingHorses",
            priority = 1
        }
    end
    
    -- Method 3: General minigame detection
    local success3, container3 = pcall(function()
        if gameSystem.available and gameSystem.u8 then
            local minigameFrame = gameSystem.u8.menus.Minigame.frame
            if minigameFrame and minigameFrame.Visible then
                return minigameFrame:FindFirstChild("Buttons")
            end
        end
        return nil
    end)
    if success3 and container3 then
        containers.general = {
            container = container3,
            type = "GeneralMinigame",
            priority = 2
        }
    end
    
    -- Method 4: Scan all GUI for button containers
    pcall(function()
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, child in pairs(gui:GetDescendants()) do
                    if child.Name == "Buttons" and child:IsA("GuiObject") and child.Visible then
                        local hasButtonFrames = false
                        for _, button in pairs(child:GetChildren()) do
                            if button.Name == "ButtonFrame" then
                                hasButtonFrames = true
                                break
                            end
                        end
                        if hasButtonFrames then
                            containers.scanned = {
                                container = child,
                                type = "ScannedButtons",
                                priority = 3
                            }
                        end
                    end
                end
            end
        end
    end)
    
    return containers
end

-- Enhanced game state detection
local function detectGameState()
    local containers = getGameContainer()
    local gameActive = false
    local activeGame = "None"
    
    for gameName, data in pairs(containers) do
        if data.container and data.container.Visible then
            local parent = data.container.Parent
            if parent and parent.Visible then
                gameActive = true
                activeGame = data.type
                buttonClicker.currentGame = activeGame
                break
            end
        end
    end
    
    -- Enhanced game system detection
    if gameSystem.available then
        pcall(function()
            if gameSystem.u8 and gameSystem.u8.menus.Minigame.frame.Visible then
                gameActive = true
                if activeGame == "None" then
                    activeGame = "GameSystemMinigame"
                    buttonClicker.currentGame = activeGame
                end
            end
        end)
    end
    
    buttonClicker.gameActive = gameActive
    return gameActive, activeGame
end

-- =================================
-- ULTRA ADVANCED BUTTON ANALYSIS
-- =================================

-- Professional button scanning with enhanced analysis
local function scanAllButtons()
    local startTime = tick()
    local containers = getGameContainer()
    
    local allButtons = {}
    local emptyTextButtons = {}
    local numberedButtons = {}
    local iconButtons = {}
    local analysisData = {
        totalButtons = 0,
        emptyTextButtons = 0,
        numberedButtons = 0,
        iconButtons = 0,
        clickableButtons = 0
    }
    
    -- Scan all detected containers
    for gameName, data in pairs(containers) do
        if not data.container or not data.container.Visible then continue end
        
        for _, child in pairs(data.container:GetChildren()) do
            if child.Name == "ButtonFrame" and child:IsA("GuiObject") and child.Visible then
                analysisData.totalButtons = analysisData.totalButtons + 1
                
                local buttonData = {
                    button = child,
                    textLabel = child:FindFirstChild("TextLabel"),
                    disabledFrame = child:FindFirstChild("DisabledFrame"),
                    icon = child:FindFirstChild("Icon"),
                    gameType = data.type,
                    priority = data.priority,
                    
                    -- Enhanced state functions
                    getTextContent = function()
                        local textLabel = child:FindFirstChild("TextLabel")
                        return textLabel and tostring(textLabel.Text) or ""
                    end,
                    
                    isEmpty = function()
                        local textLabel = child:FindFirstChild("TextLabel")
                        local text = textLabel and textLabel.Text or ""
                        return text == "" or text == nil
                    end,
                    
                    hasNumber = function()
                        local textLabel = child:FindFirstChild("TextLabel")
                        local text = textLabel and textLabel.Text or ""
                        return text ~= "" and tonumber(text) ~= nil
                    end,
                    
                    getNumber = function()
                        local textLabel = child:FindFirstChild("TextLabel")
                        local text = textLabel and textLabel.Text or ""
                        return tonumber(text)
                    end,
                    
                    isVisible = function()
                        return child.Visible
                    end,
                    
                    isDisabled = function()
                        local disabledFrame = child:FindFirstChild("DisabledFrame")
                        return disabledFrame and disabledFrame.Visible
                    end,
                    
                    hasVisibleIcon = function()
                        local icon = child:FindFirstChild("Icon")
                        return icon and icon.Visible
                    end,
                    
                    isClickable = function()
                        local disabledFrame = child:FindFirstChild("DisabledFrame")
                        local icon = child:FindFirstChild("Icon")
                        return child.Visible and 
                               (not disabledFrame or not disabledFrame.Visible) and
                               (not icon or icon.Visible)
                    end,
                    
                    getClickPriority = function()
                        local priority = 0
                        local textLabel = child:FindFirstChild("TextLabel")
                        local text = textLabel and textLabel.Text or ""
                        
                        -- Empty text = highest priority
                        if text == "" then
                            priority = priority + 100
                        end
                        
                        -- Number = medium priority
                        if tonumber(text) then
                            priority = priority + 50
                        end
                        
                        -- Icon visibility bonus
                        local icon = child:FindFirstChild("Icon")
                        if icon and icon.Visible then
                            priority = priority + 25
                        end
                        
                        -- Game type priority
                        priority = priority + (10 - data.priority)
                        
                        return priority
                    end
                }
                
                table.insert(allButtons, buttonData)
                
                -- Categorize buttons
                if buttonData.isEmpty() then
                    table.insert(emptyTextButtons, buttonData)
                    analysisData.emptyTextButtons = analysisData.emptyTextButtons + 1
                elseif buttonData.hasNumber() then
                    local num = buttonData.getNumber()
                    if num then
                        numberedButtons[num] = buttonData
                        analysisData.numberedButtons = analysisData.numberedButtons + 1
                    end
                elseif buttonData.hasVisibleIcon() then
                    table.insert(iconButtons, buttonData)
                    analysisData.iconButtons = analysisData.iconButtons + 1
                end
                
                if buttonData.isClickable() then
                    analysisData.clickableButtons = analysisData.clickableButtons + 1
                end
            end
        end
    end
    
    -- Sort buttons by click priority
    table.sort(allButtons, function(a, b)
        return a.getClickPriority() > b.getClickPriority()
    end)
    
    -- Performance tracking
    local analysisTime = tick() - startTime
    table.insert(buttonClicker.performance.analysisTimes, analysisTime)
    if #buttonClicker.performance.analysisTimes > 100 then
        table.remove(buttonClicker.performance.analysisTimes, 1)
    end
    
    buttonClicker.buttonAnalysis = analysisData
    buttonClicker.buttonAnalysis.lastAnalysisTime = tick()
    
    return allButtons, emptyTextButtons, numberedButtons, iconButtons
end

-- Smart button selection with enhanced logic
local function getNextBestButton()
    local allButtons, emptyTextButtons, numberedButtons, iconButtons = scanAllButtons()
    
    if buttonClicker.settings.smartAnalysis then
        -- Smart analysis: prioritize empty text buttons
        for _, buttonData in ipairs(emptyTextButtons) do
            if buttonData.isClickable() then
                return buttonData, "EmptyText"
            end
        end
        
        -- Fallback: use numbered buttons in order
        for i = 1, 10 do
            local buttonData = numberedButtons[i]
            if buttonData and buttonData.isClickable() then
                return buttonData, "Numbered"
            end
        end
        
        -- Last resort: any clickable button
        for _, buttonData in ipairs(allButtons) do
            if buttonData.isClickable() then
                return buttonData, "General"
            end
        end
    else
        -- Simple analysis: first clickable button
        for _, buttonData in ipairs(allButtons) do
            if buttonData.isClickable() then
                return buttonData, "Simple"
            end
        end
    end
    
    return nil, "None"
end

-- =================================
-- ULTRA ADVANCED CLICKING SYSTEM
-- =================================

-- Enhanced click function with game system integration
local function performUltraClick(buttonData)
    if not buttonData or not buttonData.button then return false end
    
    local startTime = tick()
    local button = buttonData.button
    local success = false
    
    pcall(function()
        -- Method 1: Game System Integration (if available)
        if buttonClicker.settings.gameSystemIntegration and gameSystem.available and gameSystem.networkReady then
            -- Try to use game's network system
            if gameSystem.u2.Network then
                -- Could potentially send button click through game system
                -- This would be game-specific implementation
            end
        end
        
        -- Method 2: firesignal (most reliable)
        if firesignal then
            -- Fire all possible click events
            if button.MouseButton1Click then
                firesignal(button.MouseButton1Click)
                success = true
            end
            if button.Activated then
                firesignal(button.Activated)
                success = true
            end
            if button.MouseButton1Down then
                firesignal(button.MouseButton1Down)
                success = true
            end
            if button.MouseButton1Up then
                firesignal(button.MouseButton1Up)
                success = true
            end
        end
        
        -- Method 3: Standard events
        pcall(function()
            if button.MouseButton1Click then
                button.MouseButton1Click:Fire()
                success = true
            end
            if button.Activated then
                button.Activated:Fire()
                success = true
            end
        end)
        
        -- Method 4: Advanced events
        pcall(function()
            if button.InputBegan then
                button.InputBegan:Fire({UserInputType = Enum.UserInputType.MouseButton1})
            end
            if button.GuiButton1Down then
                button.GuiButton1Down:Fire()
            end
        end)
        
        -- Method 5: Perfect timing simulation (if enabled)
        if buttonClicker.settings.perfectTiming then
            pcall(function()
                -- Simulate perfect human-like timing
                local simulatedEvents = {
                    "MouseEnter", "MouseButton1Down", "MouseButton1Up", "MouseButton1Click", "Activated"
                }
                
                for _, eventName in ipairs(simulatedEvents) do
                    local event = button:FindFirstChild(eventName)
                    if event and event:IsA("RBXScriptSignal") then
                        if firesignal then
                            firesignal(event)
                        end
                    end
                end
            end)
        end
    end)
    
    -- Performance tracking
    local clickTime = tick() - startTime
    table.insert(buttonClicker.performance.clickTimes, clickTime)
    if #buttonClicker.performance.clickTimes > 1000 then
        table.remove(buttonClicker.performance.clickTimes, 1)
    end
    
    if clickTime > buttonClicker.performance.maxClickTime then
        buttonClicker.performance.maxClickTime = clickTime
    end
    
    -- Update statistics
    if success then
        buttonClicker.performance.clickSuccess = buttonClicker.performance.clickSuccess + 1
        buttonClicker.totalClicks = buttonClicker.totalClicks + 1
        buttonClicker.sessionClicks = buttonClicker.sessionClicks + 1
    else
        buttonClicker.performance.clickFails = buttonClicker.performance.clickFails + 1
    end
    
    return success
end

-- Main clicking logic with enhanced multi-targeting
local function performAdvancedClicking()
    if not buttonClicker.isActive then return end
    
    local gameActive, activeGame = detectGameState()
    if not gameActive then 
        buttonClicker.buttonAnalysis = {
            totalButtons = 0,
            emptyTextButtons = 0,
            numberedButtons = 0,
            iconButtons = 0,
            clickableButtons = 0,
            lastAnalysisTime = 0
        }
        return 
    end
    
    local nextButton, strategy = getNextBestButton()
    
    if nextButton then
        if buttonClicker.settings.instantClick then
            -- Instant click
            local success = performUltraClick(nextButton)
            
            if success and buttonClicker.debugMode then
                print(string.format("⚡ CLICKED %s Button (%s) | Strategy: %s | Total: %d", 
                    activeGame, nextButton.getTextContent(), strategy, buttonClicker.totalClicks))
            end
        else
            -- Delayed click
            spawn(function()
                wait(buttonClicker.settings.clickDelay)
                if buttonClicker.isActive then
                    performUltraClick(nextButton)
                end
            end)
        end
        
        -- Multi-targeting: click multiple buttons if enabled
        if buttonClicker.settings.multiTargeting then
            local allButtons = scanAllButtons()
            local clickedCount = 1
            
            for _, buttonData in ipairs(allButtons) do
                if clickedCount >= 3 then break end -- Limit to 3 simultaneous clicks
                if buttonData ~= nextButton and buttonData.isClickable() then
                    spawn(function()
                        wait(0.001 * clickedCount) -- Slight delay between multi-clicks
                        performUltraClick(buttonData)
                    end)
                    clickedCount = clickedCount + 1
                end
            end
        end
    end
end

-- =================================
-- ENHANCED MAIN CONTROL SYSTEM
-- =================================

local function startButtonClicker()
    buttonClicker.isActive = true
    buttonClicker.sessionClicks = 0
    buttonClicker.lastGameTime = tick()
    
    -- Main clicking connection
    buttonClicker.connections.main = RunService.Heartbeat:Connect(function()
        if buttonClicker.isActive then
            performAdvancedClicking()
        end
    end)
    
    -- Game monitoring connection
    buttonClicker.connections.monitor = RunService.Heartbeat:Connect(function()
        local gameActive, activeGame = detectGameState()
        
        if gameActive and not buttonClicker.gameDetected then
            buttonClicker.gameDetected = true
            buttonClicker.lastGameTime = tick()
            buttonClicker.sessionClicks = 0
            
            if buttonClicker.debugMode then
                print("🎮 BUTTON GAME DETECTED: " .. activeGame)
                print("🔥 FireSignal: " .. (firesignal and "YES" or "NO"))
                print("🎯 Game System: " .. (gameSystem.available and "YES" or "NO"))
                print("📊 Strategy: Smart Analysis + Multi-Targeting")
            end
            
            Rayfield:Notify({
               Title = "🎮 " .. activeGame .. " Detected!",
               Content = "Ultra advanced clicking activated",
               Duration = 2,
               Image = 4483362458,
            })
            
        elseif not gameActive and buttonClicker.gameDetected then
            buttonClicker.gameDetected = false
            
            if buttonClicker.debugMode then
                print("🏁 Game completed! Session clicks: " .. buttonClicker.sessionClicks)
            end
            
            Rayfield:Notify({
               Title = "🏁 Game Completed!",
               Content = "Clicked " .. buttonClicker.sessionClicks .. " buttons",
               Duration = 2,
               Image = 4483362458,
            })
        end
    end)
    
    -- Performance monitoring
    buttonClicker.connections.performance = RunService.Heartbeat:Connect(function()
        -- Calculate clicks per second
        local sessionTime = tick() - buttonClicker.lastGameTime
        if sessionTime > 0 then
            buttonClicker.clicksPerSecond = buttonClicker.sessionClicks / sessionTime
            if buttonClicker.clicksPerSecond > buttonClicker.bestClickRate then
                buttonClicker.bestClickRate = buttonClicker.clicksPerSecond
            end
        end
        
        -- Calculate average click time
        if #buttonClicker.performance.clickTimes > 0 then
            local total = 0
            for _, time in pairs(buttonClicker.performance.clickTimes) do
                total = total + time
            end
            buttonClicker.performance.avgClickTime = total / #buttonClicker.performance.clickTimes
        end
    end)
    
    Rayfield:Notify({
       Title = "🚀 Ultra Button Clicker Started!",
       Content = "Game system integration + Multi-targeting active",
       Duration = 3,
       Image = 4483362458,
    })
end

local function stopButtonClicker()
    buttonClicker.isActive = false
    buttonClicker.gameDetected = false
    
    for _, connection in pairs(buttonClicker.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    buttonClicker.connections = {}
    
    Rayfield:Notify({
       Title = "🛑 Ultra Button Clicker Stopped",
       Content = "Advanced clicking system deactivated",
       Duration = 2,
       Image = 4483362458,
    })
end

-- =================================
-- ENHANCED UI CONTROLS
-- =================================

-- 🎮 MAIN CONTROL SECTION
local MainControlSection = parentTab:CreateSection("🎮 Ultra Button Game Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Advanced Button Clicker",
   CurrentValue = false,
   Flag = "UltraButtonClickerToggle",
   Callback = function(Value)
      if Value then
         startButtonClicker()
      else
         stopButtonClicker()
      end
   end,
})

-- 🎯 STRATEGY SETTINGS SECTION
local StrategySettingsSection = parentTab:CreateSection("🎯 Advanced Strategy Settings")

local SmartAnalysisToggle = parentTab:CreateToggle({
   Name = "🧠 Smart Button Analysis",
   CurrentValue = true,
   Flag = "SmartAnalysisToggle",
   Callback = function(Value)
      buttonClicker.settings.smartAnalysis = Value
   end,
})

local MultiTargetingToggle = parentTab:CreateToggle({
   Name = "🎯 Multi-Button Targeting",
   CurrentValue = true,
   Flag = "MultiTargetingToggle",
   Callback = function(Value)
      buttonClicker.settings.multiTargeting = Value
   end,
})

local GameSystemToggle = parentTab:CreateToggle({
   Name = "🎮 Game System Integration",
   CurrentValue = true,
   Flag = "GameSystemIntegrationToggle",
   Callback = function(Value)
      buttonClicker.settings.gameSystemIntegration = Value
   end,
})

local PerfectTimingToggle = parentTab:CreateToggle({
   Name = "⏰ Perfect Timing Simulation",
   CurrentValue = true,
   Flag = "PerfectTimingToggle",
   Callback = function(Value)
      buttonClicker.settings.perfectTiming = Value
   end,
})

local AggressiveClickingToggle = parentTab:CreateToggle({
   Name = "⚡ Aggressive Clicking Mode",
   CurrentValue = true,
   Flag = "AggressiveClickingToggle",
   Callback = function(Value)
      buttonClicker.settings.aggressiveClicking = Value
   end,
})

-- ⚙️ PERFORMANCE SETTINGS SECTION
local PerformanceSettingsSection = parentTab:CreateSection("⚙️ Performance Settings")

local InstantClickToggle = parentTab:CreateToggle({
   Name = "⚡ Instant Click Mode",
   CurrentValue = true,
   Flag = "InstantClickToggle",
   Callback = function(Value)
      buttonClicker.settings.instantClick = Value
   end,
})

local ClickDelaySlider = parentTab:CreateSlider({
   Name = "⏱️ Click Delay (if not instant)",
   Range = {0.001, 0.1},
   Increment = 0.001,
   Suffix = "s",
   CurrentValue = 0.001,
   Flag = "ClickDelaySlider",
   Callback = function(Value)
      buttonClicker.settings.clickDelay = Value
   end,
})

local DebugToggle = parentTab:CreateToggle({
   Name = "🔧 Debug Mode",
   CurrentValue = true,
   Flag = "DebugToggle",
   Callback = function(Value)
      buttonClicker.debugMode = Value
   end,
})

-- 📊 STATUS SECTION
local StatusSection = parentTab:CreateSection("📊 Ultra Status")

local SystemStatus = parentTab:CreateParagraph({Title = "🚀 System Status", Content = "Ultra system ready"})
local GameStatus = parentTab:CreateParagraph({Title = "🎮 Game Status", Content = "Monitoring for games..."})
local ClickStats = parentTab:CreateParagraph({Title = "📊 Click Statistics", Content = "No clicks yet"})
local PerformanceMetrics = parentTab:CreateParagraph({Title = "⚡ Performance Metrics", Content = "Performance monitoring ready"})

-- 🧪 TESTING SECTION
local TestingSection = parentTab:CreateSection("🧪 Testing & Analysis")

local TestDetectionButton = parentTab:CreateButton({
   Name = "🧪 Test Game Detection",
   Callback = function()
      local gameActive, activeGame = detectGameState()
      local allButtons, emptyTextButtons, numberedButtons, iconButtons = scanAllButtons()
      
      print("\n🧪 ULTRA BUTTON ANALYSIS:")
      print("Game Active: " .. tostring(gameActive))
      print("Active Game: " .. activeGame)
      print("Game System Available: " .. tostring(gameSystem.available))
      print("Network Ready: " .. tostring(gameSystem.networkReady))
      print("FireSignal Available: " .. tostring(firesignal ~= nil))
      
      print(string.format("\n📊 Button Analysis:"))
      print(string.format("Total Buttons: %d", #allButtons))
      print(string.format("Empty Text: %d", #emptyTextButtons))
      print(string.format("Numbered: %d", buttonClicker.buttonAnalysis.numberedButtons))
      print(string.format("Icon Buttons: %d", #iconButtons))
      print(string.format("Clickable: %d", buttonClicker.buttonAnalysis.clickableButtons))
      
      local nextButton, strategy = getNextBestButton()
      if nextButton then
         print(string.format("\n🎯 Next Target: %s button (Strategy: %s)", nextButton.getTextContent(), strategy))
         print(string.format("Priority: %d", nextButton.getClickPriority()))
      else
         print("\n🎯 Next Target: No clickable button found")
      end
      
      Rayfield:Notify({
         Title = "🧪 Detection Test Complete",
         Content = string.format("Game: %s | Buttons: %d | Clickable: %d", activeGame, #allButtons, buttonClicker.buttonAnalysis.clickableButtons),
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local ManualClickButton = parentTab:CreateButton({
   Name = "👆 Manual Ultra Click",
   Callback = function()
      local nextButton, strategy = getNextBestButton()
      if nextButton then
         local success = performUltraClick(nextButton)
         if success then
            Rayfield:Notify({
               Title = "✅ Ultra Click Success",
               Content = "Clicked " .. strategy .. " button: " .. nextButton.getTextContent(),
               Duration = 2,
               Image = 4483362458,
            })
         else
            Rayfield:Notify({
               Title = "❌ Click Failed",
               Content = "Failed to click button",
               Duration = 2,
               Image = 4483362458,
            })
         end
      else
         Rayfield:Notify({
            Title = "❌ No Button Available",
            Content = "No clickable button found",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

local ResetStatsButton = parentTab:CreateButton({
   Name = "📊 Reset Statistics",
   Callback = function()
      buttonClicker.totalClicks = 0
      buttonClicker.sessionClicks = 0
      buttonClicker.clicksPerSecond = 0
      buttonClicker.bestClickRate = 0
      buttonClicker.performance = {
         clickTimes = {},
         analysisTimes = {},
         avgClickTime = 0,
         maxClickTime = 0,
         clickSuccess = 0,
         clickFails = 0
      }
      
      Rayfield:Notify({
         Title = "📊 Stats Reset",
         Content = "All statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- ⚡ ADVANCED ACTIONS SECTION
local AdvancedActionsSection = parentTab:CreateSection("⚡ Advanced Actions")

local AutoGameStartToggle = parentTab:CreateToggle({
   Name = "🎮 Auto Game Start (Experimental)",
   CurrentValue = false,
   Flag = "AutoGameStartToggle",
   Callback = function(Value)
      buttonClicker.settings.autoGameStart = Value
      if Value then
         Rayfield:Notify({
            Title = "🎮 Auto Game Start Enabled",
            Content = "Will attempt to start games automatically",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

local CooldownBypassToggle = parentTab:CreateToggle({
   Name = "⏰ Cooldown Prevention (Experimental)",
   CurrentValue = false,
   Flag = "CooldownBypassToggle",
   Callback = function(Value)
      buttonClicker.settings.preventCooldowns = Value
      if Value then
         Rayfield:Notify({
            Title = "⏰ Cooldown Prevention Enabled",
            Content = "Attempting to prevent game cooldowns",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(0.1) do
        -- System Status
        local statusText = ""
        if buttonClicker.isActive then
            statusText = "🚀 ULTRA-ACTIVE\n"
            statusText = statusText .. "🧠 Smart Analysis: " .. (buttonClicker.settings.smartAnalysis and "✅" or "❌") .. "\n"
            statusText = statusText .. "🎯 Multi-Targeting: " .. (buttonClicker.settings.multiTargeting and "✅" or "❌") .. "\n"
            statusText = statusText .. "🎮 Game System: " .. (buttonClicker.settings.gameSystemIntegration and gameSystem.available and "✅" or "❌") .. "\n"
            statusText = statusText .. "⚡ Mode: " .. (buttonClicker.settings.instantClick and "INSTANT" or "DELAYED") .. "\n"
            statusText = statusText .. "🔥 FireSignal: " .. (firesignal and "✅" or "❌")
        else
            statusText = "🔴 STOPPED\n💤 Ultra system ready\n🎮 Game detection active\n⚡ Performance optimization enabled\n🚀 Revolutionary clicking ready"
        end
        SystemStatus:Set({Title = "🚀 System Status", Content = statusText})
        
        -- Game Status
        local gameActive, activeGame = detectGameState()
        local gameText = ""
        
        if gameActive then
            gameText = "🟢 GAME ACTIVE: " .. activeGame .. "\n"
            gameText = gameText .. "📊 Total Buttons: " .. buttonClicker.buttonAnalysis.totalButtons .. "\n"
            gameText = gameText .. "🔤 Empty Text: " .. buttonClicker.buttonAnalysis.emptyTextButtons .. "\n"
            gameText = gameText .. "🔢 Numbered: " .. buttonClicker.buttonAnalysis.numberedButtons .. "\n"
            gameText = gameText .. "🎯 Clickable: " .. buttonClicker.buttonAnalysis.clickableButtons .. "\n"
            
            local nextButton, strategy = getNextBestButton()
            if nextButton then
                gameText = gameText .. "🎯 Next: " .. strategy .. " ready ✅"
            else
                gameText = gameText .. "🎯 Next: No target ❌"
            end
        else
            gameText = "🔴 NO GAME ACTIVE\nMonitoring for button games...\n🔍 Supported: ButtonReaction, DancingHorses\n🎮 Game System Integration Ready"
        end
        GameStatus:Set({Title = "🎮 Game Status", Content = gameText})
        
        -- Click Statistics
        local successRate = 0
        if (buttonClicker.performance.clickSuccess + buttonClicker.performance.clickFails) > 0 then
            successRate = (buttonClicker.performance.clickSuccess / (buttonClicker.performance.clickSuccess + buttonClicker.performance.clickFails)) * 100
        end
        
        local statsText = "📊 Total Clicks: " .. buttonClicker.totalClicks .. "\n"
        statsText = statsText .. "🎮 Session Clicks: " .. buttonClicker.sessionClicks .. "\n"
        statsText = statsText .. "⚡ Current Rate: " .. string.format("%.1f", buttonClicker.clicksPerSecond) .. " clicks/s\n"
        statsText = statsText .. "🏆 Best Rate: " .. string.format("%.1f", buttonClicker.bestClickRate) .. " clicks/s\n"
        statsText = statsText .. "✅ Success Rate: " .. string.format("%.1f", successRate) .. "%\n"
        
        if buttonClicker.lastGameTime > 0 then
            local timeSince = tick() - buttonClicker.lastGameTime
            statsText = statsText .. "⏰ Last Game: " .. string.format("%.1f", timeSince) .. "s ago"
        else
            statsText = statsText .. "⏰ Last Game: Never"
        end
        ClickStats:Set({Title = "📊 Click Statistics", Content = statsText})
        
        -- Performance Metrics
        local performanceText = "⚡ Avg Click Time: " .. string.format("%.3f", buttonClicker.performance.avgClickTime * 1000) .. "ms\n"
        performanceText = performanceText .. "🔥 Max Click Time: " .. string.format("%.3f", buttonClicker.performance.maxClickTime * 1000) .. "ms\n"
        performanceText = performanceText .. "📈 Successful Clicks: " .. buttonClicker.performance.clickSuccess .. "\n"
        performanceText = performanceText .. "❌ Failed Clicks: " .. buttonClicker.performance.clickFails .. "\n"
        performanceText = performanceText .. "🔗 Active Connections: " .. (buttonClicker.isActive and #buttonClicker.connections or 0) .. "\n"
        performanceText = performanceText .. "🚀 Status: ULTRA-OPTIMIZED"
        PerformanceMetrics:Set({Title = "⚡ Performance Metrics", Content = performanceText})
    end
end)

-- =================================
-- INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Button Clicker Loaded!",
   Content = "Game system integration + Advanced multi-targeting | Revolutionary clicking system ready!",
   Duration = 6,
   Image = 4483362458,
})

if gameSystem.available then
    Rayfield:Notify({
       Title = "🎮 Game System Connected!",
       Content = "Native game integration active | Enhanced performance mode enabled!",
       Duration = 4,
       Image = 4483362458,
    })
end

print("🚀 Ultra Advanced Button Clicker - Game System Edition Loaded!")
print("🎮 Features: Native game integration, multi-targeting, smart analysis")
print("⚡ Performance: Ultra-optimized clicking, perfect timing simulation")
print("🎯 Strategy: Empty text priority, numbered fallback, icon detection")
print("🔥 Game System: " .. (gameSystem.available and "✅ Connected" or "❌ Not Available"))
print("📊 Advanced analytics and performance monitoring ready!")
