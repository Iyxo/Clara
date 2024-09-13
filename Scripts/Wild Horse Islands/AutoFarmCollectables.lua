-- Flaga kontrolująca działanie skryptu
_G.AutoFarmCollectablesActive = true -- Używamy _G, aby można było ją zmieniać z innego skryptu

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local islandsFolder = game:GetService("Workspace").Islands
local RunService = game:GetService("RunService")

-- Lista obiektów, do których należy się teleportować
local targetObjects = {
    "Meshes/Bush (1)",
    "Meshes/Cattail_Cattail",
    "Meshes/Wheat Plane",
    "Meshes/Cotton Plant_Stem",
    "Primary",
    "Meshes/Corn Stalk"
}

-- Funkcja symulująca wciśnięcie klawisza
local function simulateKeyPress(key)
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    wait(0.1) -- Krótkie opóźnienie
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Funkcja do teleportacji
local function teleportToTarget()
    if not _G.AutoFarmCollectablesActive then return end -- Sprawdzenie, czy skrypt jest aktywny

    local found = false
    for _, folder in pairs(islandsFolder:GetChildren()) do
        if folder:IsA("Folder") and folder:FindFirstChild("Collectables") then
            local collectablesFolder = folder.Collectables
            for _, model in pairs(collectablesFolder:GetChildren()) do
                if model:IsA("Model") then
                    for _, objName in pairs(targetObjects) do
                        local target = model:FindFirstChild(objName, true)
                        if target then
                            -- Przypisz obiektowi CFrame i symuluj kliknięcie
                            rootPart.CFrame = target.CFrame
                            wait(1) -- Poczekaj 1 sekundę
                            simulateKeyPress("E")
                            found = true
                            break -- Zatrzymaj po znalezieniu pierwszego dopasowania
                        end
                    end
                end
                if found then break end
            end
        end
        if found then break end
    end
end

-- Użycie RunService.Stepped do szybkiego sprawdzania i teleportacji
local connection
connection = RunService.Stepped:Connect(function()
    if _G.AutoFarmCollectablesActive then
        teleportToTarget()
    else
        -- Wyłączanie symulacji klawisza 'E' gdy skrypt jest wyłączony
        connection:Disconnect()
    end
end)
