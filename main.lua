local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local plr = Players.LocalPlayer
local gui = Instance.new("ScreenGui", plr.PlayerGui)

gui.Name = "CustomMenu"
gui.ResetOnSpawn = false

--==================================================
-- TP LOGIC
--==================================================

local ENABLED = false
local promptConnection

local positions = {
    Vector3.new(-481, -3, 138),
    Vector3.new(-337, -3, -124),
    Vector3.new(-481, -3, -76),
}

local SAVED_POS = nil

local function closest(hrp)
    local dist = math.huge
    local best

    for _,v in pairs(positions) do
        local d = (hrp.Position - v).Magnitude
        if d < dist then
            dist = d
            best = v
        end
    end

    return best and CFrame.new(best)
end

local function teleport(plr, savedPos)
    local char = plr.Character
    if not char or not savedPos then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos2 = closest(hrp)
    hrp.CFrame = savedPos
    task.wait(.05)
    if pos2 then hrp.CFrame = pos2 end
end

local function enableDetect(plr)
    if promptConnection then return end
    
    promptConnection = ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt,who)
        if who ~= plr then return end
        if prompt.Name ~= "Steal" and prompt.ActionText ~= "Steal" then return end
        if not ENABLED then return end
        
        teleport(plr, SAVED_POS)
    end)
end

local function disableDetect()
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end
end

function ToggleTP(plr)
    ENABLED = not ENABLED
    
    if ENABLED then
        enableDetect(plr)
    else
        disableDetect()
    end
    
    return ENABLED
end

function SavePosition(plr)
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        SAVED_POS = char.HumanoidRootPart.CFrame
    end
end

--==================================================
-- UI
--==================================================

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,200)
frame.Position = UDim2.new(0.5,-150,0.5,-100)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,12)

--==================================================
-- TOGGLE CREATOR
--==================================================

local function createToggle(text, yPos, callback)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6,0,0,40)
    label.Position = UDim2.new(0,15,0,yPos)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.3,0,0,40)
    button.Position = UDim2.new(0.65,0,0,yPos)
    button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    button.Text = "OFF"
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    
    local c = Instance.new("UICorner", button)
    c.CornerRadius = UDim.new(0,8)
    
    local state = false
    
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = state and "ON" or "OFF"
        
        if callback then
            callback(state)
        end
    end)
end

--==================================================
-- BOTONES
--==================================================

createToggle("TP", 20, function()
    ToggleTP(plr)
end)

createToggle("SAVE POSITION", 70, function()
    SavePosition(plr)
end)

--==================================================
-- FOOTER
--==================================================

local discord = Instance.new("TextLabel", frame)
discord.Size = UDim2.new(1,0,0,40)
discord.Position = UDim2.new(0,0,1,-45)
discord.BackgroundTransparency = 1
discord.Text = "discord.gg/t4EYjEJ4r"
discord.Font = Enum.Font.GothamBlack
discord.TextColor3 = Color3.new(1,1,1)
discord.TextScaled = true
