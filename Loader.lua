--[[
    Wild Horse Islands - Loader (v3, with error reporting)
    ----------------------------------------------------------------
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
-- Helpery
-- =================================================================
local function fetchScript(name)
    local url = CONFIG.BASE_URL .. "/" .. name
    local ok, source = pcall(game.HttpGet, game, url)
    if not ok then
        return nil, "HttpGet error: " .. tostring(source)
    end
    if not source or source == "" then
        return nil, "pusty plik / 404 dla " .. url
    end
    return source, nil
end

local function showError(tab, name, err)
    warn(("[Loader] %s: %s"):format(name, tostring(err)))
    pcall(function()
        tab:CreateSection("BLAD: " .. name)
        tab:CreateParagraph({
            Title = "Skrypt sie nie zaladowal",
            Content = tostring(err),
        })
        tab:CreateButton({
            Name = "Sprobuj ponownie (przeladuj " .. name .. ")",
            Callback = function()
                Rayfield:Notify({Title = "Reload", Content = "Przeladuj cale UI: F1 lub odpal loader jeszcze raz", Duration = 4})
            end,
        })
    end)
end

local function runWithTab(name, tab)
    local source, fetchErr = fetchScript(name)
    if not source then
        showError(tab, name, fetchErr)
        return
    end
    local fn, compileErr = loadstring(source, "=" .. name)
    if not fn then
        showError(tab, name, "compile: " .. tostring(compileErr))
        return
    end
    local ok, runErr = pcall(fn, tab, Rayfield, Window)
    if not ok then
        showError(tab, name, "runtime: " .. tostring(runErr))
        return
    end
    print(("[Loader] %s OK"):format(name))
end

local function runStandalone(name)
    local source, fetchErr = fetchScript(name)
    if not source then
        Rayfield:Notify({Title = "Blad pobierania", Content = name .. ": " .. fetchErr, Duration = 5})
        return false
    end
    local fn, compileErr = loadstring(source, "=" .. name)
    if not fn then
        Rayfield:Notify({Title = "Blad kompilacji", Content = name .. ": " .. tostring(compileErr), Duration = 5})
        return false
    end
    local ok, runErr = pcall(fn)
    if not ok then
        Rayfield:Notify({Title = "Blad runtime", Content = name .. ": " .. tostring(runErr), Duration = 5})
        return false
    end
    return true
end

-- =================================================================
-- Tab: Auto Farm (logika inline, niezalezna od GitHuba)
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
            if runStandalone("AntiAfk.lua") then
                Rayfield:Notify({Title = "Anti AFK", Content = "Wlaczone.", Duration = 2})
            end
        else
            Rayfield:Notify({Title = "Anti AFK", Content = "Wylaczone.", Duration = 2})
        end
    end,
})

FarmTab:CreateSection("Farmy")
local farms = {
    {label = "Auto Farm Animals", flag = "AutoFarmAnimalToggle", gflag = "AutoFarmAnimalActive", file = "AutoFarmAnimal.lua"},
    {label = "Auto Farm Collectables", flag = "AutoFarmCollectablesToggle", gflag = "AutoFarmCollectablesActive", file = "AutoFarmCollectables.lua"},
    {label = "Auto Farm Crystals (Unicorn Island)", flag = "AutoFarmCrystalsToggle", gflag = "AutoFarmCrystalActive", file = "AutoFarmCrystals.lua"},
    {label = "Auto Farm Training Island", flag = "AutoFarmTrainingToggle", gflag = "TrainingAutoFarmActive", file = "AutoFarmTrainingIsland.lua"},
}

for _, f in ipairs(farms) do
    FarmTab:CreateToggle({
        Name = f.label,
        CurrentValue = false,
        Flag = f.flag,
        Callback = function(value)
            _G[f.gflag] = value
            if value then
                if runStandalone(f.file) then
                    Rayfield:Notify({Title = f.label, Content = "Wlaczone.", Duration = 2})
                end
            else
                Rayfield:Notify({Title = f.label, Content = "Wylaczone.", Duration = 2})
            end
        end,
    })
end

FarmTab:CreateSection("Info")
FarmTab:CreateParagraph({
    Title = "Jak to dziala",
    Content = "Wlacz toggle - skrypt sie pobiera z GitHuba i startuje. Wylacz - flaga _G zostaje ustawiona na false i skrypt sam sie zatrzymuje.",
})

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
    Suffix = " studs/s",
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
-- Taby z duzymi skryptami (laduja sie z GitHuba w tle)
-- =================================================================
local HorseCatcherTab = Window:CreateTab("Horse Catcher", 4483362458)
local HorseManipulatorTab = Window:CreateTab("Horse Manipulator", 4483362458)
local ButtonGameTab = Window:CreateTab("Button Game", 4483362458)

-- Placeholder zanim skrypty sie zaladuja
HorseCatcherTab:CreateParagraph({Title = "Ladowanie...", Content = "Pobieranie HorseCatcher.lua z GitHuba..."})
HorseManipulatorTab:CreateParagraph({Title = "Ladowanie...", Content = "Pobieranie HorseManipulator.lua z GitHuba..."})
ButtonGameTab:CreateParagraph({Title = "Ladowanie...", Content = "Pobieranie ButtonGameClicker.lua z GitHuba..."})

-- =================================================================
-- Tab: Settings
-- =================================================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Loader")
SettingsTab:CreateParagraph({
    Title = "Wersja",
    Content = "Clara Loader v3 - Wild Horse Islands",
})
SettingsTab:CreateParagraph({
    Title = "BASE_URL",
    Content = CONFIG.BASE_URL,
})
SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})
SettingsTab:CreateButton({
    Name = "Wymus zatrzymanie wszystkich farm",
    Callback = function()
        _G.AntiAFKActive = false
        _G.AutoFarmAnimalActive = false
        _G.AutoFarmCollectablesActive = false
        _G.AutoFarmCrystalActive = false
        _G.TrainingAutoFarmActive = false
        Rayfield:Notify({Title = "Stop", Content = "Wszystkie farmy wylaczone.", Duration = 3})
    end,
})

Rayfield:LoadConfiguration()
Rayfield:Notify({
    Title = "Clara zaladowana",
    Content = "Otworz/zamknij menu klawiszem K.",
    Duration = 4,
})

-- =================================================================
-- Asynchroniczne ladowanie duzych skryptow (zeby nie blokowac UI)
-- =================================================================
task.spawn(function()
    runWithTab("HorseCatcher.lua", HorseCatcherTab)
end)
task.spawn(function()
    runWithTab("HorseManipulator.lua", HorseManipulatorTab)
end)
task.spawn(function()
    runWithTab("ButtonGameClicker.lua", ButtonGameTab)
end)
