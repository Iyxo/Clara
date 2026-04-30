-- AutoFarmTrainingIsland - automatyzuje farme na Training Island

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

if _G.TrainingAutoFarmActive == nil then
    _G.TrainingAutoFarmActive = true
end

if _G.__TrainingAutoFarmRunning then
    return
end
_G.__TrainingAutoFarmRunning = true

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function getEvents()
    local comm = ReplicatedStorage:FindFirstChild("Communication")
    local events = comm and comm:FindFirstChild("Events")
    if not events then return {} end

    local list = {}
    for _, ev in ipairs(events:GetChildren()) do
        if ev:IsA("RemoteEvent") then
            table.insert(list, ev)
        end
    end
    return list
end

local function fireAll(...)
    local args = {...}
    for _, ev in ipairs(getEvents()) do
        pcall(function()
            ev:FireServer(table.unpack(args))
        end)
    end
end

local function selectArenaLayout()
    local trainingIsland = Workspace.Islands:FindFirstChild("Training Island")
    local outdoorArena = trainingIsland and trainingIsland:FindFirstChild("Outdoor Arena")
    local dynamicArena = outdoorArena and outdoorArena:FindFirstChild("DynamicArena")
    if not dynamicArena then
        warn("[AutoFarmTrainingIsland] Nie znaleziono DynamicArena.")
        return false
    end
    fireAll("SelectLayout", dynamicArena, 1)
    return true
end

local function triggerCheckpoint()
    local layout = Workspace:FindFirstChild("_LAYOUT")
    local checkpoint = layout and layout:FindFirstChild("CheckpointActivity")
    if not checkpoint then
        warn("[AutoFarmTrainingIsland] Nie znaleziono CheckpointActivity.")
        return false
    end
    fireAll("TriggerInteractable", checkpoint)
    return true
end

local function randomOffset()
    local m = 0.2
    return Vector3.new(
        math.random() * m - m / 2,
        math.random() * m - m / 2,
        math.random() * m - m / 2
    )
end

local heartbeatConn

local function startMarkerFollow()
    local marker = Workspace:WaitForChild("CheckpointMarker", 10)
    marker = marker and marker:WaitForChild("Marker", 5)
    if not marker then
        warn("[AutoFarmTrainingIsland] Brak markera checkpointu.")
        return
    end

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not _G.TrainingAutoFarmActive then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
            return
        end
        local root = getRoot()
        if root and marker.Parent then
            root.CFrame = CFrame.new(marker.Position + randomOffset())
        end
    end)
end

task.spawn(function()
    if not selectArenaLayout() then return end
    task.wait(1)
    if not _G.TrainingAutoFarmActive then return end

    if not triggerCheckpoint() then return end
    task.wait(1)
    if not _G.TrainingAutoFarmActive then return end

    startMarkerFollow()

    while _G.TrainingAutoFarmActive do
        task.wait(1)
    end

    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end

    _G.__TrainingAutoFarmRunning = nil
    print("[AutoFarmTrainingIsland] Skrypt zatrzymany.")
end)

print("[AutoFarmTrainingIsland] Aktywny.")
