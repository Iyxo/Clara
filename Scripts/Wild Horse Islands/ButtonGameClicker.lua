-- Button Game Clicker Module for Iyxo's Advanced Hub
-- Stworzony przez: Iyxo
-- Data: 2025-07-21

if not getgenv().IyxoHub or not getgenv().IyxoHub.Window then
    warn("❌ Main Hub not loaded! Load MainHub.lua first!")
    return
end

if getgenv().IyxoHub.Modules.ButtonGameClicker then
    warn("⚠️ Button Game Clicker already loaded!")
    return
end

-- Oznacz moduł jako załadowany
getgenv().IyxoHub.Modules.ButtonGameClicker = true

-- Usługi
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =================================
-- ZMIENNE BUTTON GAME CLICKER
-- =================================
local buttonClicker = {
    isActive = false,
    connections = {},
    gameDetected = false,
    debugMode = true,
    clickCount = 0,
    lastGameTime = 0,
    
    -- Settings
    instantClick = true,
    clickDelay = 0.005,
    
    -- Tracking
    lastEmptyButtonsCount = 0,
    emptyButtonsHistory = {}
}

-- =================================
-- ZAKŁADKA BUTTON GAME CLICKER
-- =================================
local Window = getgenv().IyxoHub.Window
local ButtonGameTab = Window:CreateTab("🎯 Button Game Clicker", 4483362458)

-- =================================
-- SEKCJE
-- =================================
local MainControlSection = ButtonGameTab:CreateSection("🎯 Dancing Horse Minigame Control")
local SettingsSection = ButtonGameTab:CreateSection("⚙️ Clicker Settings")
local StatusSection = ButtonGameTab:CreateSection("📊 Live Status")
local DebugSection = ButtonGameTab:CreateSection("🔧 Debug & Testing")

-- =================================
-- FUNKCJE BUTTON GAME CLICKER
-- =================================

-- Sprawdź czy firesignal dostępne
local function hasFireSignal()
    return firesignal ~= nil
end

-- Pobierz kontener ButtonFrame
local function getButtonContainer()
    local success, container = pcall(function()
        return playerGui.Prompts.ButtonReactionGame.Buttons
    end)
    return success and container or nil
end

-- Sprawdź czy gra aktywna
local function isGameActive()
    local container = getButtonContainer()
    if not container then return false end
    
    local gameGui = container.Parent
    return gameGui and gameGui.Visible and true or false
end

-- Skanuj ButtonFrame z pustymi TextLabel
local function scanEmptyTextLabelButtons()
    local container = getButtonContainer()
    if not container then return {}, {} end
    
    local allButtons = {}
    local emptyTextButtons = {}
    local numberedButtons = {}
    
    for _, child in pairs(container:GetChildren()) do
        if child.Name == "ButtonFrame" and child:IsA("GuiObject") and child.Visible then
            local textLabel = child:FindFirstChild("TextLabel")
            local disabledFrame = child:FindFirstChild("DisabledFrame")
            local icon = child:FindFirstChild("Icon")
            
            local buttonData = {
                button = child,
                textLabel = textLabel,
                disabledFrame = disabledFrame,
                icon = icon,
                
                getTextContent = function()
                    if textLabel and textLabel.Text then
                        return tostring(textLabel.Text)
                    end
                    return ""
                end,
                
                isEmpty = function()
                    local text = textLabel and textLabel.Text or ""
                    return text == "" or text == nil
                end,
                
                hasNumber = function()
                    local text = textLabel and textLabel.Text or ""
                    return text ~= "" and tonumber(text) ~= nil
                end,
                
                getNumber = function()
                    local text = textLabel and textLabel.Text or ""
                    return tonumber(text)
                end,
                
                isVisible = function()
                    return child.Visible
                end,
                
                isDisabled = function()
                    return disabledFrame and disabledFrame.Visible
                end,
                
                hasVisibleIcon = function()
                    return icon and icon.Visible
                end,
                
                isClickable = function()
                    return child.Visible and 
                           (not disabledFrame or not disabledFrame.Visible) and
                           (not icon or icon.Visible)
                end
            }
            
            table.insert(allButtons, buttonData)
            
            if buttonData.isEmpty() then
                table.insert(emptyTextButtons, buttonData)
            elseif buttonData.hasNumber() then
                local num = buttonData.getNumber()
                if num then
                    numberedButtons[num] = buttonData
                end
            end
        end
    end
    
    return allButtons, emptyTextButtons, numberedButtons
end

-- Znajdź następny pusty przycisk do kliknięcia
local function getNextEmptyTextLabelButton()
    local allButtons, emptyTextButtons, numberedButtons = scanEmptyTextLabelButtons()
    
    if buttonClicker.debugMode then
        local emptyCount = #emptyTextButtons
        local numberedCount = 0
        for _ in pairs(numberedButtons) do
            numberedCount = numberedCount + 1
        end
        
        if emptyCount ~= buttonClicker.lastEmptyButtonsCount then
            print(string.format("🔤 Empty TextLabel buttons count changed: %d -> %d", 
                buttonClicker.lastEmptyButtonsCount, emptyCount))
            buttonClicker.lastEmptyButtonsCount = emptyCount
        end
    end
    
    for _, buttonData in ipairs(emptyTextButtons) do
        if buttonData.isClickable() then
            return buttonData
        end
    end
    
    return nil
end

-- Ultra fast click
local function ultraFastEmptyClick(buttonData)
    if not buttonData or not buttonData.button then return false end
    
    local button = buttonData.button
    local success = false
    
    pcall(function()
        if hasFireSignal() then
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
        end
        
        if button.MouseButton1Click then
            button.MouseButton1Click:Fire()
            success = true
        end
        if button.Activated then
            button.Activated:Fire()
            success = true
        end
        if button.MouseButton1Down then
            button.MouseButton1Down:Fire()
            success = true
        end
        
        if button.MouseButton1Up then
            button.MouseButton1Up:Fire()
        end
        if button.InputBegan then
            button.InputBegan:Fire({UserInputType = Enum.UserInputType.MouseButton1})
        end
    end)
    
    return success
end

-- Główna pętla klikania
local function performEmptyTextLabelClicking()
    if not buttonClicker.isActive then return end
    if not isGameActive() then 
        buttonClicker.lastEmptyButtonsCount = 0
        return 
    end
    
    local nextEmptyButton = getNextEmptyTextLabelButton()
    
    if nextEmptyButton then
        if buttonClicker.instantClick then
            local success = ultraFastEmptyClick(nextEmptyButton)
            if success then
                buttonClicker.clickCount = buttonClicker.clickCount + 1
                
                if buttonClicker.debugMode then
                    print("⚡ CLICKED EMPTY TextLabel Button | Total clicks: " .. buttonClicker.clickCount)
                end
            end
        else
            spawn(function()
                wait(buttonClicker.clickDelay)
                if buttonClicker.isActive then
                    local success = ultraFastEmptyClick(nextEmptyButton)
                    if success then
                        buttonClicker.clickCount = buttonClicker.clickCount + 1
                    end
                end
            end)
        end
    end
end

-- Start Button Game Clicker
local function startButtonGameClicker()
    buttonClicker.isActive = true
    buttonClicker.clickCount = 0
    buttonClicker.lastEmptyButtonsCount = 0
    
    local buttonConnection = RunService.Heartbeat:Connect(function()
        if buttonClicker.isActive then
            performEmptyTextLabelClicking()
        end
    end)
    table.insert(buttonClicker.connections, buttonConnection)
    
    local gameMonitor = RunService.Heartbeat:Connect(function()
        local gameActive = isGameActive()
        
        if gameActive and not buttonClicker.gameDetected then
            buttonClicker.gameDetected = true
            buttonClicker.lastGameTime = tick()
            buttonClicker.lastEmptyButtonsCount = 0
            
            if buttonClicker.debugMode then
                local allButtons, emptyTextButtons, numberedButtons = scanEmptyTextLabelButtons()
                print("🎮 DANCING HORSE BUTTON GAME DETECTED!")
                print("📊 Total ButtonFrames: " .. #allButtons)
                print("🔤 Empty TextLabel buttons: " .. #emptyTextButtons)
            end
            
            getgenv().Rayfield:Notify({
               Title = "🎯 Dancing Horse Game Detected!",
               Content = "Button clicker activated",
               Duration = 2,
               Image = 4483362458,
            })
            
        elseif not gameActive and buttonClicker.gameDetected then
            buttonClicker.gameDetected = false
            
            if buttonClicker.debugMode then
                print("🏁 Dancing Horse button game completed! Total clicks: " .. buttonClicker.clickCount)
            end
            
            getgenv().Rayfield:Notify({
               Title = "🏁 Dancing Horse Completed!",
               Content = "Clicked " .. buttonClicker.clickCount .. " buttons",
               Duration = 2,
               Image = 4483362458,
            })
        end
    end)
    table.insert(buttonClicker.connections, gameMonitor)
    
    getgenv().Rayfield:Notify({
       Title = "🎯 Button Game Clicker Started!",
       Content = "Monitoring for Dancing Horse minigame...",
       Duration = 3,
       Image = 4483362458,
    })
end

-- Stop Button Game Clicker
local function stopButtonGameClicker()
    buttonClicker.isActive = false
    buttonClicker.gameDetected = false
    
    for _, connection in pairs(buttonClicker.connections) do
        connection:Disconnect()
    end
    buttonClicker.connections = {}
    
    getgenv().Rayfield:Notify({
       Title = "🛑 Button Game Clicker Stopped",
       Content = "Dancing Horse clicker deactivated",
       Duration = 2,
       Image = 4483362458,
    })
end

-- =================================
-- KONTROLKI
-- =================================

-- Main Control
local ButtonGameToggle = MainControlSection:CreateToggle({
   Name = "🎯 Dancing Horse Button Clicker",
   CurrentValue = false,
   Flag = "ButtonGameToggle",
   Callback = function(Value)
      if Value then
         startButtonGameClicker()
      else
         stopButtonGameClicker()
      end
   end,
})

-- Settings
local FireSignalStatus = SettingsSection:CreateParagraph({
    Title = "🔥 FireSignal Status", 
    Content = hasFireSignal() and "✅ FireSignal Available" or "❌ FireSignal NOT Available"
})

local InstantClickToggle = SettingsSection:CreateToggle({
   Name = "⚡ Instant Click Mode",
   CurrentValue = true,
   Flag = "InstantClick",
   Callback = function(Value)
      buttonClicker.instantClick = Value
   end,
})

local ClickDelaySlider = SettingsSection:CreateSlider({
   Name = "⏱️ Click Delay (if not instant)",
   Range = {0.001, 0.05},
   Increment = 0.001,
   Suffix = "s",
   CurrentValue = 0.005,
   Flag = "ClickDelay",
   Callback = function(Value)
      buttonClicker.clickDelay = Value
   end,
})

local DebugToggle = SettingsSection:CreateToggle({
   Name = "🔧 Debug Mode",
   CurrentValue = true,
   Flag = "DebugMode",
   Callback = function(Value)
      buttonClicker.debugMode = Value
   end,
})

-- Status
local ButtonClickerStatus = StatusSection:CreateParagraph({Title = "🎯 Clicker Status", Content = "Ready"})
local ButtonGameStatus = StatusSection:CreateParagraph({Title = "🎮 Game Status", Content = "No game"})
local ButtonClickStats = StatusSection:CreateParagraph({Title = "📊 Statistics", Content = "No clicks"})

-- Debug
local TestButtonGameButton = DebugSection:CreateButton({
   Name = "🧪 Test Button Game Detection",
   Callback = function()
      local gameActive = isGameActive()
      local allButtons, emptyTextButtons, numberedButtons = scanEmptyTextLabelButtons()
      
      print("\n🧪 BUTTON GAME TEST:")
      print("Game Active: " .. tostring(gameActive))
      print("Total ButtonFrames: " .. #allButtons)
      print("Empty TextLabel buttons: " .. #emptyTextButtons)
      
      getgenv().Rayfield:Notify({
         Title = "🧪 Test Complete",
         Content = string.format("Empty: %d | Total: %d", #emptyTextButtons, #allButtons),
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local ManualClickButton = DebugSection:CreateButton({
   Name = "👆 Manual Click Empty Button",
   Callback = function()
      local nextEmptyButton = getNextEmptyTextLabelButton()
      if nextEmptyButton then
         local success = ultraFastEmptyClick(nextEmptyButton)
         if success then
            buttonClicker.clickCount = buttonClicker.clickCount + 1
            getgenv().Rayfield:Notify({
               Title = "✅ Button Clicked",
               Content = "Clicked empty TextLabel button",
               Duration = 2,
               Image = 4483362458,
            })
         end
      else
         getgenv().Rayfield:Notify({
            Title = "❌ No Empty Button",
            Content = "No empty TextLabel button found",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

-- =================================
-- STATUS UPDATE LOOP
-- =================================
spawn(function()
    while wait(1) do
        -- Update FireSignal status
        FireSignalStatus:Set({
            Title = "🔥 FireSignal Status", 
            Content = hasFireSignal() and "✅ FireSignal Available" or "❌ FireSignal NOT Available"
        })
        
        -- Clicker Status
        if buttonClicker.isActive then
            local status = "🟢 DANCING HORSE CLICKER ACTIVE\n"
            status = status .. "Mode: " .. (buttonClicker.instantClick and "⚡ INSTANT" or ("⏱️ " .. buttonClicker.clickDelay .. "s")) .. "\n"
            status = status .. "Strategy: Click EMPTY TextLabels\n"
            status = status .. "FireSignal: " .. (hasFireSignal() and "✅" or "❌")
            ButtonClickerStatus:Set({Title = "🎯 Clicker Status", Content = status})
        else
            ButtonClickerStatus:Set({Title = "🎯 Clicker Status", Content = "🔴 STOPPED\nReady for Dancing Horse game"})
        end
        
        -- Game Status
        local gameActive = isGameActive()
        local allButtons, emptyTextButtons, numberedButtons = scanEmptyTextLabelButtons()
        
        if gameActive then
            local numberedCount = 0
            for _ in pairs(numberedButtons) do
                numberedCount = numberedCount + 1
            end
            
            local status = "🟢 DANCING HORSE ACTIVE\n"
            status = status .. "Total ButtonFrames: " .. #allButtons .. "\n"
            status = status .. "Empty TextLabels: " .. #emptyTextButtons .. "\n"
            status = status .. "Numbered TextLabels: " .. numberedCount
            ButtonGameStatus:Set({Title = "🎮 Game Status", Content = status})
        else
            ButtonGameStatus:Set({Title = "🎮 Game Status", Content = "🔴 NO DANCING HORSE GAME\nWaiting for minigame..."})
        end
        
        -- Statistics
        local stats = "📊 Total Clicks: " .. buttonClicker.clickCount .. "\n"
        stats = stats .. "🔤 Last Empty Count: " .. buttonClicker.lastEmptyButtonsCount .. "\n"
        if buttonClicker.lastGameTime > 0 then
            local timeSince = tick() - buttonClicker.lastGameTime
            stats = stats .. "⏰ Last Game: " .. string.format("%.1f", timeSince) .. "s ago"
        else
            stats = stats .. "⏰ Last Game: Never"
        end
        ButtonClickStats:Set({Title = "📊 Statistics", Content = stats})
    end
end)

-- =================================
-- MODULE LOADED
-- =================================
getgenv().Rayfield:Notify({
   Title = "🎯 Button Game Clicker Loaded!",
   Content = "Module ready for Dancing Horse minigame!",
   Duration = 3,
   Image = 4483362458,
})

print("🎯 Button Game Clicker Module loaded successfully!")
print("🎮 Target: Dancing Horse minigame")
print("🔤 Strategy: Click empty TextLabel buttons")
