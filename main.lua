-- ============================================================
-- KAWATAN HUB - INSTANT TP SCRIPT
-- ============================================================
-- Features:
-- Auto TP on Steal with Visual Indicators
-- Simple GUI with PVP theming
-- Mobile compatible & draggable
-- ============================================================

-- ============================================================
-- SERVICES
-- ============================================================

local S = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    ProximityPromptService = game:GetService("ProximityPromptService"),
    HttpService = game:GetService("HttpService")
}

S.LocalPlayer = S.Players.LocalPlayer
S.PlayerGui = S.LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- COLORS
-- ============================================================

local COLORS = {
    Accent = Color3.fromRGB(0,150,255),
    Surface = Color3.fromRGB(25,35,50),
    Background = Color3.fromRGB(8,8,15),
    Text = Color3.fromRGB(255,255,255),
    Success = Color3.fromRGB(120,255,200),
    Red = Color3.fromRGB(200,0,0)
}

-- ============================================================
-- CONFIG
-- ============================================================

local CONFIG_FILE = "KawatanInstantTPConfig.json"

local CONFIG = {
    GUI_POSITION_X = nil,
    GUI_POSITION_Y = nil,
    GUI_COLLAPSED = false,
    ENABLED = false,
    SAVED_POSITION = nil
}

local targetPositions = {
    Vector3.new(-481.88,-3.79,138.02),
    Vector3.new(-481.75,-3.79,89.18),
    Vector3.new(-481.82,-3.79,30.95),
    Vector3.new(-481.75,-3.79,-17.79),
    Vector3.new(-481.80,-3.79,-76.06),
    Vector3.new(-481.72,-3.79,-124.70),
    Vector3.new(-337.45,-3.85,-124.72),
    Vector3.new(-337.37,-3.85,-76.07),
    Vector3.new(-337.46,-3.79,-17.72),
    Vector3.new(-337.41,-3.79,30.92),
    Vector3.new(-337.32,-3.79,89.02),
    Vector3.new(-337.27,-3.79,137.90),
    Vector3.new(-337.45,-3.79,196.29),
    Vector3.new(-337.37,-3.79,244.91),
    Vector3.new(-481.72,-3.79,196.21),
    Vector3.new(-481.76,-3.79,244.92)
}

-- ============================================================
-- CONFIG SAVE / LOAD
-- ============================================================

local function saveConfig()
    if not writefile then return end

    local data = {
        GUI_POSITION_X = CONFIG.GUI_POSITION_X,
        GUI_POSITION_Y = CONFIG.GUI_POSITION_Y,
        GUI_COLLAPSED = CONFIG.GUI_COLLAPSED,
        ENABLED = CONFIG.ENABLED,
        SAVED_POSITION = CONFIG.SAVED_POSITION and {
            X = CONFIG.SAVED_POSITION.Position.X,
            Y = CONFIG.SAVED_POSITION.Position.Y,
            Z = CONFIG.SAVED_POSITION.Position.Z
        } or nil
    }

    writefile(CONFIG_FILE, S.HttpService:JSONEncode(data))
end

local function loadConfig()
    if not readfile or not isfile then return end
    if not isfile(CONFIG_FILE) then return end

    local raw = readfile(CONFIG_FILE)
    local decoded = S.HttpService:JSONDecode(raw)

    for k,v in pairs(decoded) do
        CONFIG[k] = v
    end

    if CONFIG.SAVED_POSITION then
        CONFIG.SAVED_POSITION = CFrame.new(
            CONFIG.SAVED_POSITION.X,
            CONFIG.SAVED_POSITION.Y,
            CONFIG.SAVED_POSITION.Z
        )
    end
end

loadConfig()

-- ============================================================
-- VISUAL SYSTEM (BEAM + DIAMOND)
-- ============================================================

local beam, att0, att1
local diamondModel

local function createIndicator(pos)
    if diamondModel then diamondModel:Destroy() end

    diamondModel = Instance.new("Model")
    diamondModel.Name = "TPIndicator"
    diamondModel.Parent = workspace

    local part = Instance.new("Part")
    part.Size = Vector3.new(6,12,6)
    part.Material = Enum.Material.Neon
    part.Color = COLORS.Red
    part.Anchored = true
    part.CanCollide = false
    part.Parent = diamondModel

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://9756362"
    mesh.Scale = Vector3.new(3,4,3)
    mesh.Parent = part

    diamondModel.PrimaryPart = part
    diamondModel:SetPrimaryPartCFrame(CFrame.new(pos))
end

local function createBeam()
    local char = S.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not diamondModel then return end

    att0 = Instance.new("Attachment", hrp)
    att1 = Instance.new("Attachment", diamondModel.PrimaryPart)

    beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Width0 = 0.25
    beam.Width1 = 0.25
    beam.Color = ColorSequence.new(COLORS.Red)
    beam.Parent = hrp
end

local function destroyVisuals()
    if beam then beam:Destroy() end
    if att0 then att0:Destroy() end
    if att1 then att1:Destroy() end
    if diamondModel then diamondModel:Destroy() end
    beam,att0,att1,diamondModel = nil,nil,nil,nil
end

local function updateVisuals()
    if not CONFIG.ENABLED or not CONFIG.SAVED_POSITION then
        destroyVisuals()
        return
    end

    createIndicator(CONFIG.SAVED_POSITION.Position)
    createBeam()
end

-- ============================================================
-- TELEPORT
-- ============================================================

local function findClosest()
    local hrp = S.LocalPlayer.Character and
                S.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dist = math.huge
    local closest

    for _,v in ipairs(targetPositions) do
        local d = (hrp.Position - v).Magnitude
        if d < dist then
            dist = d
            closest = v
        end
    end

    return closest and CFrame.new(closest)
end

local function performTeleport()
    local char = S.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos1 = CONFIG.SAVED_POSITION
    local pos2 = findClosest()

    if pos1 then hrp.CFrame = pos1 end
    if pos2 then task.wait(0.05) hrp.CFrame = pos2 end
end

-- ============================================================
-- PROMPT DETECTION
-- ============================================================

local promptConnection

local function enablePrompt()
    if promptConnection then return end

    promptConnection = S.ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt,who)
        if who ~= S.LocalPlayer then return end
        if not CONFIG.ENABLED then return end
        if prompt.Name ~= "Steal" and prompt.ActionText ~= "Steal" then return end

        performTeleport()
    end)
end

local function disablePrompt()
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end
end

-- ============================================================
-- GUI
-- ============================================================

local screen = Instance.new("ScreenGui")
screen.Name = "KawatanInstantTP"
screen.Parent = S.PlayerGui
screen.ResetOnSpawn = false

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0,230,0,130)
frame.Position = UDim2.new(0.5,-115,0,150)
frame.BackgroundColor3 = COLORS.Surface
frame.BorderSizePixel = 0
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,8)

local header = Instance.new("TextLabel",frame)
header.Size = UDim2.new(1,0,0,30)
header.BackgroundTransparency = 1
header.Text = "Instant TP"
header.TextColor3 = COLORS.Accent
header.Font = Enum.Font.GothamBold
header.TextSize = 14

local toggle = Instance.new("TextButton",frame)
toggle.Size = UDim2.new(1,-20,0,30)
toggle.Position = UDim2.new(0,10,0,40)
toggle.BackgroundColor3 = COLORS.Accent
toggle.Text = "Instant TP: OFF"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12
Instance.new("UICorner",toggle).CornerRadius = UDim.new(0,6)

toggle.MouseButton1Click:Connect(function()
    CONFIG.ENABLED = not CONFIG.ENABLED
    toggle.Text = CONFIG.ENABLED and "Instant TP: ON" or "Instant TP: OFF"

    if CONFIG.ENABLED then
        enablePrompt()
        updateVisuals()
    else
        disablePrompt()
        destroyVisuals()
    end

    saveConfig()
end)

local saveBtn = toggle:Clone()
saveBtn.Parent = frame
saveBtn.Position = UDim2.new(0,10,0,80)
saveBtn.Text = "Save Position"

saveBtn.MouseButton1Click:Connect(function()
    local hrp = S.LocalPlayer.Character and
                S.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        CONFIG.SAVED_POSITION = hrp.CFrame
        updateVisuals()
        saveConfig()
    end
end)

-- ============================================================
-- HEARTBEAT
-- ============================================================

S.RunService.Heartbeat:Connect(function()
    if CONFIG.ENABLED then
        updateVisuals()
    end
end)

S.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if CONFIG.ENABLED then
        updateVisuals()
    end
end)
