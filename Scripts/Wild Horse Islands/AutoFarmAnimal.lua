local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Flaga kontrolująca działanie skryptu
_G.AutoFarmAnimalActive = true -- Używamy _G, aby można było ją zmieniać z innego skryptu

-- Funkcja do teleportowania gracza do wskazanego obiektu
local function teleportTo(part)
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = part.CFrame
    end
end

-- Funkcja do podążania za obiektem
local function followObject(target)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Funkcja aktualizująca położenie gracza na obiekcie
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if target and target.Parent then
            humanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 1.6, 0.4)
        else
            connection:Disconnect()
        end
    end)
end

-- Funkcja do określenia folderu obiektów w zależności od wyspy
local function getAnimalsFolder()
    local islandName = ""
    -- Sprawdź, na jakiej wyspie znajduje się gracz
    if Workspace.Islands:FindFirstChild("Mainland") then
        islandName = "Mainland"
    elseif Workspace.Islands:FindFirstChild("Desert Island") then
        islandName = "Desert Island"
    end

    -- Zwróć folder odpowiedniej wyspy
    if islandName ~= "" then
        return Workspace.Islands[islandName].Nodes.Animals
    end

    return nil
end

-- Szukanie wszystkich obiektów HumanoidRootPart w folderze Animals
local function getNextTarget()
    local animalsFolder = getAnimalsFolder()
    if animalsFolder then
        for _, animal in pairs(animalsFolder:GetChildren()) do
            if animal:FindFirstChild("HumanoidRootPart") then
                return animal.HumanoidRootPart
            end
        end
    end
    return nil
end

while _G.AutoFarmAnimalActive do
    local targetPart = getNextTarget()

    if targetPart then
        teleportTo(targetPart)
        followObject(targetPart)

        -- Czekaj, aż obiekt zniknie
        repeat
            wait(1)
        until not targetPart.Parent
    else
        -- Jeśli nie ma więcej obiektów, zakończ pętlę lub zrób coś innego
        print("Brak więcej obiektów do śledzenia.")
        break
    end
end
