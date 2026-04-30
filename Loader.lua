--[[
    Wild Horse Islands - Loader
    ----------------------------------------------------------------
    Skrypt do executora Robloxa. Zaduje Rayfield UI, tworzy zakladki
    dla wszystkich farmow oraz zaladowuje duze skrypty (HorseCatcher,
    HorseManipulator, ButtonGameClicker) z GitHuba.

    USTAWIENIA:
      Ponizej w `CONFIG.BASE_URL` wpisz raw URL swojego repo, np.:
        https://raw.githubusercontent.com/<user>/<repo>/main/Scripts/Wild%20Horse%20Islands

    URUCHOMIENIE w executorze:
      loadstring(game:HttpGet("https://raw.githubusercontent.com/Iyxo/Clara/main/Loader.lua"))()
--]]

local CONFIG = {
    BASE_URL = "https://raw.githubusercontent.com/Iyxo/Clara/main/Scripts/Wild%20Horse%20Islands",
    THEME = "Default",
}

-- =================================================================
-- Wczytanie Rayfield UI
-- =================================================================
local Rayfield
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if not ok or not lib then
        warn("[Loader] Nie udalo sie zaladowac Rayfield: " .. tostring(lib))
        return
    end
    Rayfield = lib
end

local Window = Rayfield:CreateWindow({
    Name = "Wild Horse Islands - Clara",
    LoadingTitle = "Clara Loader",
    LoadingSubtitle = "by Iyxo",
    Theme = CONFIG.THEME,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClaraWHI",
        FileName = "ClaraWHI-Config",
    },
    KeySystem = false,
})

-- =================================================================
-- Helper: zaladuj skrypt z GitHuba i przekaz mu (tab, Rayfield, Window)
-- =================================================================
local function fetchScript(name)
    local url = CONFIG.BASE_URL .. "/" .. name
    local ok, source = pcall(game.HttpGet, game, url)
    if not ok or not source or source == "" then
        warn(("[Loader] Blad pobierania %s: %s"):format(name, tostring(source)))
        return nil
    end
    return source
end

local function runWithTab(name, tab)
    local source = fetchScript(name)
    if not source then
        Rayfield:Notify({Title = "Blad", Content = "Nie pobrano " .. name, Duration = 4})
        return
    end
    local fn, err = loadstring(source)
    if not fn then
        warn(("[Loader] loadstring %s: %s"):format(name, tostring(err)))
        Rayfield:Notify({Title = "Blad", Content = name .. " sie nie skompilowal", Duration = 4})
        return
    end
    local ok2, runErr = pcall(fn, tab, Rayfield, Window)
    if not ok2 then
        warn(("[Loader] Runtime %s: %s"):format(name, tostring(runErr)))
        Rayfield:Notify({Title = "Blad", Content = name .. " runtime: " .. tostring(runErr), Duration = 6})
    end
end

local function runStandalone(name)
    local source = fetchScript(name)
    if not source then
        Rayfield:Notify({Title = "Blad", Content = "Nie pobrano " .. name, Duration = 4})
        return false
    end
    local fn, err = loadstring(source)
    if not fn then
        warn(("[Loader] loadstring %s: %s"):format(name, tostring(err)))
        return false
    end
    local ok, runErr = pcall(fn)
    if not ok then
        warn(("[Loader] Runtime %s: %s"):format(name, tostring(runErr)))
        return false
    end
    return true
end

-- =================================================================
-- Tab: Auto Farm
-- =================================================================
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
FarmTab:CreateSection("Anti AFK")

FarmTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(value)
        _G.AntiAFKActive = value
        if value then
            runStandalone("AntiAfk.lua")
        end
    end,
})

FarmTab:CreateSection("Farmy")

FarmTab:CreateToggle({
    Name = "Auto Farm Animals",
    CurrentValue = false,
    Flag = "AutoFarmAnimalToggle",
    Callback = function(value)
        _G.AutoFarmAnimalActive = value
        if value then
            runStandalone("AutoFarmAnimal.lua")
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Farm Collectables",
    CurrentValue = false,
    Flag = "AutoFarmCollectablesToggle",
    Callback = function(value)
        _G.AutoFarmCollectablesActive = value
        if value then
            runStandalone("AutoFarmCollectables.lua")
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Farm Crystals (Unicorn Island)",
    CurrentValue = false,
    Flag = "AutoFarmCrystalsToggle",
    Callback = function(value)
        _G.AutoFarmCrystalActive = value
        if value then
            runStandalone("AutoFarmCrystals.lua")
        end
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Farm Training Island",
    CurrentValue = false,
    Flag = "AutoFarmTrainingToggle",
    Callback = function(value)
        _G.TrainingAutoFarmActive = value
        if value then
            runStandalone("AutoFarmTrainingIsland.lua")
        end
    end,
})

FarmTab:CreateSection("Info")
FarmTab:CreateParagraph({
    Title = "Jak to dziala",
    Content = "Wlacz toggle, zeby uruchomic dany skrypt. Wylacz, zeby zatrzymac (skrypty czytaja flagi _G).",
})

-- =================================================================
-- Tab: Horse Catcher (zewnetrzny skrypt z Rayfield UI)
-- =================================================================
local HorseCatcherTab = Window:CreateTab("Horse Catcher", 4483362458)
runWithTab("HorseCatcher.lua", HorseCatcherTab)

-- =================================================================
-- Tab: Horse Manipulator
-- =================================================================
local HorseManipulatorTab = Window:CreateTab("Horse Manipulator", 4483362458)
runWithTab("HorseManipulator.lua", HorseManipulatorTab)

-- =================================================================
-- Tab: Button Game
-- =================================================================
local ButtonGameTab = Window:CreateTab("Button Game", 4483362458)
runWithTab("ButtonGameClicker.lua", ButtonGameTab)

-- =================================================================
-- Tab: Player
-- =================================================================
local PlayerTab = Window:CreateTab("Player", 4483362458)
PlayerTab:CreateSection("Szybkosc / Skok")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        local h = getHumanoid()
        if h then h.WalkSpeed = value end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        local h = getHumanoid()
        if h then
            h.JumpPower = value
            h.UseJumpPower = true
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local h = getHumanoid()
        if h then h.Health = 0 end
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    local h = char:WaitForChild("Humanoid", 5)
    if not h then return end
    task.wait(0.5)
    pcall(function()
        local ws = Rayfield.Flags["WalkSpeedSlider"]
        local jp = Rayfield.Flags["JumpPowerSlider"]
        if ws and ws.CurrentValue then h.WalkSpeed = ws.CurrentValue end
        if jp and jp.CurrentValue then
            h.JumpPower = jp.CurrentValue
            h.UseJumpPower = true
        end
    end)
end)

-- =================================================================
-- Tab: Settings
-- =================================================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

SettingsTab:CreateParagraph({
    Title = "Wersja",
    Content = "Clara Loader v2 - Wild Horse Islands",
})

Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Clara zaladowana",
    Content = "Otworz menu klawiszem K (domyslnie Rayfield).",
    Duration = 5,
})
