-- AutoFarmCrystals - teleportuje gracza nad krysztaly na Unicorn Island

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

if _G.AutoFarmCrystalActive == nil then
    _G.AutoFarmCrystalActive = true
end

if _G.__AutoFarmCrystalRunning then
    return
end
_G.__AutoFarmCrystalRunning = true

local TELEPORT_HEIGHT = 5
local CRYSTAL_NAME = "Meshes/Gems 2"

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function getUnicornIsland()
    local islands = Workspace:FindFirstChild("Islands")
    return islands and islands:FindFirstChild("Unicorn Island")
end

local function findGem()
    local island = getUnicornIsland()
    if not island then return nil end

    for _, descendant in ipairs(island:GetDescendants()) do
        if descendant.Name == CRYSTAL_NAME and descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

local connection
connection = RunService.Heartbeat:Connect(function()
    if not _G.AutoFarmCrystalActive then
        connection:Disconnect()
        _G.__AutoFarmCrystalRunning = nil
        print("[AutoFarmCrystals] Skrypt zatrzymany.")
        return
    end

    local gem = findGem()
    if gem then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(gem.Position + Vector3.new(0, TELEPORT_HEIGHT, 0))
        end
    end
end)

print("[AutoFarmCrystals] Aktywny.")
