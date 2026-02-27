--============================================================
-- Ryxx Instant Steal (Paid)
-- Neon GUI | Big Beams | Desync Enable | Server ESP
-- WHITELIST
--============================================================

local whitelist = {
    "HaroldEs08",
    "poulet123445",
    "Mongralcba321",
    "RANE1167840",
    "Alessandro_The8svc",
    "soul_reaper0746"
}

local function isWhitelisted(name)
    for _, v in ipairs(whitelist) do
        if v:lower() == name:lower() then
            return true
        end
    end
    return false
end

--============================================================
-- SERVICES
--============================================================

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

if not isWhitelisted(LocalPlayer.Name) then
    LocalPlayer:Kick("Not Whitelisted")
    return
end

if _G.RyxxInstantStealLoaded then return end
_G.RyxxInstantStealLoaded = true

--============================================================
-- DESYNC FFLAGS
--============================================================

local FFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
    LargeReplicatorWrite5 = true,
    LargeReplicatorEnabled9 = true,
    AngularVelociryLimit = 360,
    TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
    S2PhysicsSenderRate = 15000,
    DisableDPIScale = true,
    MaxDataPacketPerSend = 2147483647,
    PhysicsSenderMaxBandwidthBps = 20000,
    TimestepArbiterHumanoidLinearVelThreshold = 21,
    MaxMissedWorldStepsRemembered = -2147483648,
    PlayerHumanoidPropertyUpdateRestrict = true,
    SimDefaultHumanoidTimestepMultiplier = 0,
    StreamJobNOUVolumeLengthCap = 2147483647,
    DebugSendDistInSteps = -2147483648,
    GameNetDontSendRedundantNumTimes = 1,
    CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
    CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
    LargeReplicatorSerializeRead3 = true,
    ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,
    CheckPVCachedVelThresholdPercent = 10,
    CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
    GameNetDontSendRedundantDeltaPositionMillionth = 1,
    InterpolationFrameVelocityThresholdMillionth = 5,
    StreamJobNOUVolumeCap = 2147483647,
    InterpolationFrameRotVelocityThresholdMillionth = 5,
    CheckPVCachedRotVelThresholdPercent = 10,
    WorldStepMax = 30,
    InterpolationFramePositionThresholdMillionth = 5,
    TimestepArbiterHumanoidTurningVelThreshold = 1,
    SimOwnedNOUCountThresholdMillionth = 2147483647,
    GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,
    NextGenReplicatorEnabledWrite4 = true,
    TimestepArbiterOmegaThou = 1073741823,
    MaxAcceptableUpdateDelay = 1,
    LargeReplicatorSerializeWrite4 = true
}

--============================================================
-- DESYNC CORE
--============================================================

local ESPFolder, ServerESP
local serverPosition
local positionConn

local function ApplyFFlags()
    for name, value in pairs(FFlags) do
        pcall(function()
            setfflag(tostring(name), tostring(value))
        end)
    end
end

local function RespawnPlayer()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Dead)
    end

    char:ClearAllChildren()

    local temp = Instance.new("Model", Workspace)
    LocalPlayer.Character = temp
    task.wait()
    LocalPlayer.Character = char
    temp:Destroy()
end

local function ClearESP()
    if positionConn then
        positionConn:Disconnect()
        positionConn = nil
    end
    if ESPFolder then
        ESPFolder:Destroy()
        ESPFolder = nil
    end
    ServerESP = nil
end

local function CreateESPPart(name, color)
    local part = Instance.new("Part")
    part.Size = Vector3.new(2,5,2)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = 0.25
    part.Parent = ESPFolder

    local highlight = Instance.new("Highlight", part)
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.4

    local bb = Instance.new("BillboardGui", part)
    bb.Size = UDim2.new(0,130,0,30)
    bb.AlwaysOnTop = true
    bb.Adornee = part

    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = name
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = color

    return part
end

local function TrackServer(hrp)
    serverPosition = hrp.Position
    positionConn = hrp:GetPropertyChangedSignal("Position"):Connect(function()
        task.wait(0.15)
        if hrp then
            serverPosition = hrp.Position
            if ServerESP then
                ServerESP.CFrame = CFrame.new(serverPosition)
            end
        end
    end)
end

local function SetServerESP()
    ClearESP()
    ESPFolder = Instance.new("Folder", Workspace)
    ESPFolder.Name = "DesyncESP"
    ServerESP = CreateESPPart("SERVER POSITION", Color3.fromRGB(0,200,255))

    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            TrackServer(hrp)
            ServerESP.CFrame = CFrame.new(serverPosition)
        end
    end
end

--============================================================
-- TARGET POSITIONS
--============================================================

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

--============================================================
-- GUI
--============================================================

local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.Name = "RyxxInstantStealUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(250,210)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(10,25,35)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(0,200,255)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-10,0,34)
title.Position = UDim2.fromOffset(5,5)
title.BackgroundTransparency = 1
title.Text = "Ryxx Instant Steal (Paid)"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0,220,255)
title.TextXAlignment = Enum.TextXAlignment.Center

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-10,0,24)
status.Position = UDim2.fromOffset(5,42)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.Font = Enum.Font.GothamMedium
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(0,200,255)
status.TextXAlignment = Enum.TextXAlignment.Center
