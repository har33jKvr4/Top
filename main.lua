--========================
-- SERVICES
--========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))

--========================
-- VARIABLES
--========================
local SAVED_POSITION = nil
local TP_ENABLED = true
local AUTO_STEAL = false

local allAnimalsCache = {}
local PromptMemoryCache = {}
local InternalStealCache = {}

local AUTO_STEAL_PROX_RADIUS = 20
local IsStealing = false

--========================
-- ROOT
--========================
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

--========================
-- TELEPORT POSITIONS
--========================
local targetPositions = {
    Vector3.new(-481.88,-3.79,138.02),
    Vector3.new(-481.75,-3.79,89.18),
    Vector3.new(-337.45,-3.79,196.29),
    Vector3.new(-337.37,-3.79,244.91)
}

local function closestPos()
    local hrp = getHRP()
    if not hrp then return end

    local closestDist = math.huge
    local closest

    for _,v in ipairs(targetPositions) do
        local d = (hrp.Position - v).Magnitude
        if d < closestDist then
            closestDist = d
            closest = v
        end
    end

    return closest and CFrame.new(closest)
end

local function teleport()
    if not SAVED_POSITION then return end
    local hrp = getHRP()
    if not hrp then return end

    local pos2 = closestPos()

    hrp.CFrame = SAVED_POSITION
    if pos2 then
        task.wait(0.05)
        hrp.CFrame = pos2
    end
end

--========================
-- SAVE POSITION
--========================
local function savePos()
    local hrp = getHRP()
    if hrp then
        SAVED_POSITION = hrp.CFrame
    end
end

--========================
-- SCANNER / STEAL SYSTEM
--========================
local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled
        end
    end
    return false
end

local function scanPlot(plot)
    if isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end

    for _,pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            table.insert(allAnimalsCache,{
                plot=plot.Name,
                slot=pod.Name,
                worldPosition=pod:GetPivot().Position,
                uid=plot.Name.."_"..pod.Name
            })
        end
    end
end

local function initScanner()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots")

    for _,p in ipairs(plots:GetChildren()) do
        scanPlot(p)
    end

    task.spawn(function()
        while task.wait(5) do
            table.clear(allAnimalsCache)
            for _,p in ipairs(plots:GetChildren()) do
                scanPlot(p)
            end
        end
    end)
end

local function findPrompt(data)
    local plot = workspace.Plots:FindFirstChild(data.plot)
    if not plot then return end

    local podium = plot.AnimalPodiums:FindFirstChild(data.slot)
    if not podium then return end

    local attach = podium.Base.Spawn:FindFirstChild("PromptAttachment")
    if not attach then return end

    for _,p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            PromptMemoryCache[data.uid]=p
            return p
        end
    end
end

local function build(prompt)
    if InternalStealCache[prompt] then return end

    local data={hold={},trigger={},ready=true}

    for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
        table.insert(data.hold,c.Function)
    end
    for _,c in ipairs(getconnections(prompt.Triggered)) do
        table.insert(data.trigger,c.Function)
    end

    InternalStealCache[prompt]=data
end

local function steal(prompt)
    local data=InternalStealCache[prompt]
    if not data or not data.ready then return end

    data.ready=false
    IsStealing=true

    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        task.wait(1.3)
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        task.wait(0.3)
        data.ready=true
        IsStealing=false
    end)
end

local function nearest()
    local hrp=getHRP()
    if not hrp then return end

    local nearest,dist=nil,math.huge

    for _,a in ipairs(allAnimalsCache) do
        if not isMyBase(a.plot) then
            local d=(hrp.Position-a.worldPosition).Magnitude
            if d<dist then
                dist=d
                nearest=a
            end
        end
    end
    return nearest,dist
end

RunService.Heartbeat:Connect(function()
    if not AUTO_STEAL then return end
    if IsStealing then return end

    local target,dist=nearest()
    if not target or dist>20 then return end

    local prompt=PromptMemoryCache[target.uid] or findPrompt(target)
    if not prompt then return end

    build(prompt)
    steal(prompt)
end)

initScanner()

--========================
-- GUI ESTILO FOTO
--========================
local gui=Instance.new("ScreenGui",PlayerGui)
gui.ResetOnSpawn=false

local main=Instance.new("Frame",gui)
main.Size=UDim2.new(0,320,0,420)
main.Position=UDim2.new(0.5,-160,0.5,-210)
main.BackgroundColor3=Color3.fromRGB(10,10,10)
main.BorderSizePixel=0
Instance.new("UICorner",main).CornerRadius=UDim.new(0,20)

-- TITLE
local title=Instance.new("TextLabel",main)
title.Size=UDim2.new(1,0,0,60)
title.BackgroundTransparency=1
title.Text="⚡ HAROLD TOP 😼"
title.TextColor3=Color3.fromRGB(255,80,80)
title.Font=Enum.Font.GothamBold
title.TextSize=26

-- LAYOUT
local container=Instance.new("Frame",main)
container.Position=UDim2.new(0,0,0,60)
container.Size=UDim2.new(1,0,1,-60)
container.BackgroundTransparency=1

local layout=Instance.new("UIListLayout",container)
layout.Padding=UDim.new(0,15)
layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
layout.SortOrder=Enum.SortOrder.LayoutOrder

local function createButton(text,callback)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.85,0,0,55)
    b.BackgroundColor3=Color3.fromRGB(120,0,0)
    b.Text=text
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold
    b.TextSize=20
    b.Parent=container
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,15)

    if callback then
        b.MouseButton1Click:Connect(function()
            callback(b)
        end)
    end
end

-- BOTONES
createButton("TP",function()
    teleport()
end)

createButton("SAVE",function()
    savePos()
end)

createButton("FAST-GRAB: OFF",function(btn)
    AUTO_STEAL=not AUTO_STEAL
    btn.Text="FAST-GRAB: "..(AUTO_STEAL and "ON" or "OFF")
end)

createButton("VACIO")
createButton("VACIO")
createButton("VACIO")
