--========================
-- SERVICES
--========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================
-- VARIABLES
--========================
local SAVED_POSITION = nil
local AUTO_STEAL = false

--========================
-- ROOT
--========================
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

--========================
-- TP SYSTEM
--========================
local targetPositions = {
    Vector3.new(-481.88,-3.79,138.02),
    Vector3.new(-481.75,-3.79,89.18),
    Vector3.new(-337.45,-3.79,196.29),
    Vector3.new(-337.37,-3.79,244.91)
}

local function closestPos()
    local hrp = getHRP()
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
    hrp.CFrame = SAVED_POSITION
    task.wait(0.05)
    local pos2 = closestPos()
    if pos2 then
        hrp.CFrame = pos2
    end
end

local function savePos()
    SAVED_POSITION = getHRP().CFrame
end

--========================
-- GUI EXACTO A LA FOTO
--========================
local gui = Instance.new("ScreenGui")
gui.Parent = PlayerGui
gui.ResetOnSpawn = false

-- MAIN PANEL
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 340, 0, 430)
main.Position = UDim2.new(0.5, -170, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(12,12,12)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,25)

-- TITLE
local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1,0,0,60)
title.BackgroundTransparency = 1
title.Text = "⚡ HAROLD TOP 😼"
title.TextColor3 = Color3.fromRGB(255,70,70)
title.Font = Enum.Font.GothamBold
title.TextSize = 26

-- CONTAINER
local container = Instance.new("Frame")
container.Parent = main
container.Position = UDim2.new(0,0,0,70)
container.Size = UDim2.new(1,0,1,-70)
container.BackgroundTransparency = 1

-- FUNCTION CREATE BUTTON
local function createButton(parent,text)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(110,0,0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,20)
    return btn
end

-- 1️⃣ TP
local tpBtn = createButton(container,"TP")
tpBtn.Size = UDim2.new(0.9,0,0,55)
tpBtn.Position = UDim2.new(0.05,0,0,0)

tpBtn.MouseButton1Click:Connect(function()
    teleport()
end)

-- 2️⃣ SAVE
local saveBtn = createButton(container,"SAVE")
saveBtn.Size = UDim2.new(0.9,0,0,55)
saveBtn.Position = UDim2.new(0.05,0,0,70)

saveBtn.MouseButton1Click:Connect(function()
    savePos()
end)

-- 3️⃣ FAST-GRAB
local grabBtn = createButton(container,"FAST-GRAB [OFF]")
grabBtn.Size = UDim2.new(0.9,0,0,55)
grabBtn.Position = UDim2.new(0.05,0,0,140)

grabBtn.MouseButton1Click:Connect(function()
    AUTO_STEAL = not AUTO_STEAL
    grabBtn.Text = "FAST-GRAB ["..(AUTO_STEAL and "ON" or "OFF").."]"
end)

-- 4️⃣ FILA DOBLE (VACIO VACIO)
local leftBtn = createButton(container,"VACIO")
leftBtn.Size = UDim2.new(0.42,0,0,55)
leftBtn.Position = UDim2.new(0.05,0,0,210)

local rightBtn = createButton(container,"VACIO")
rightBtn.Size = UDim2.new(0.42,0,0,55)
rightBtn.Position = UDim2.new(0.53,0,0,210)

-- 5️⃣ BOTON FINAL
local bottomBtn = createButton(container,"VACIO")
bottomBtn.Size = UDim2.new(0.9,0,0,55)
bottomBtn.Position = UDim2.new(0.05,0,0,280)
