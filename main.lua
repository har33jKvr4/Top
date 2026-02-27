--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local guiParent = plr:WaitForChild("PlayerGui")

--// LOADING SCREEN
do
    local loadGui = Instance.new("ScreenGui", guiParent)
    loadGui.IgnoreGuiInset = true
    loadGui.ResetOnSpawn = false

    local bg = Instance.new("Frame", loadGui)
    bg.Size = UDim2.fromScale(1,1)
    bg.BackgroundColor3 = Color3.new(0,0,0)
    bg.BackgroundTransparency = 1

    TweenService:Create(bg,TweenInfo.new(.6),{BackgroundTransparency=0}):Play()

    local thumb = Players:GetUserThumbnailAsync(
        plr.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size420x420
    )

    local avatar = Instance.new("ImageLabel", bg)
    avatar.Size = UDim2.fromOffset(120,120)
    avatar.Position = UDim2.new(.5,-60,.35,-60)
    avatar.BackgroundTransparency = 1
    avatar.Image = thumb

    local name = Instance.new("TextLabel", bg)
    name.Size = UDim2.new(1,0,0,40)
    name.Position = UDim2.new(0,0,.55,0)
    name.BackgroundTransparency = 1
    name.Text = plr.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.Font = Enum.Font.GothamBold
    name.TextScaled = true

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1,0,0,30)
    txt.Position = UDim2.new(0,0,.65,0)
    txt.BackgroundTransparency = 1
    txt.Text = "Loading..."
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Font = Enum.Font.Gotham
    txt.TextScaled = true

    local barBG = Instance.new("Frame", bg)
    barBG.Size = UDim2.new(.4,0,0,18)
    barBG.Position = UDim2.new(.5,0,.75,0)
    barBG.AnchorPoint = Vector2.new(.5,0)
    barBG.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner",barBG).CornerRadius=UDim.new(1,0)

    local bar = Instance.new("Frame", barBG)
    bar.Size = UDim2.new(0,0,1,0)
    bar.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    TweenService:Create(bar,TweenInfo.new(2),{
        Size = UDim2.new(1,0,1,0)
    }):Play()

    task.wait(2.2)

    local fade = TweenService:Create(bg,TweenInfo.new(.6),{BackgroundTransparency=1})
    fade:Play()
    fade.Completed:Wait()

    loadGui:Destroy()
end

--// CONFIG
local ENABLED = false
local SAVED_POS = nil
local promptConnection

--// TP POSITIONS
local positions = {
    Vector3.new(-481, -3, 138),
    Vector3.new(-337, -3, -124),
    Vector3.new(-481, -3, -76),
}

--// GUI
local gui = Instance.new("ScreenGui", guiParent)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,130)
frame.Position = UDim2.new(.5,-100,.4,0)
frame.BackgroundTransparency = .35
frame.BackgroundColor3 = Color3.new(1,1,1)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Harold | TP ⚡"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local minimize = Instance.new("TextButton", frame)
minimize.Size = UDim2.new(0,25,0,25)
minimize.Position = UDim2.new(1,-25,0,0)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextScaled = true
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)

-- BOTON TP
local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(.9,0,0,35)
tpBtn.Position = UDim2.new(0.05,0,0,35)
tpBtn.Text = "TP OFF"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextScaled = true

-- BOTON SAVE
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.new(.9,0,0,35)
saveBtn.Position = UDim2.new(0.05,0,0,80)
saveBtn.Text = "SAVE POS"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextScaled = true

for _,b in pairs({saveBtn,tpBtn}) do
    b.BackgroundTransparency=.3
    b.BackgroundColor3=Color3.new(1,1,1)
end

--// RAINBOW
RunService.RenderStepped:Connect(function()
    local t = tick()*0.5
    local c = Color3.fromHSV(t%1,1,1)
    stroke.Color = c
    frame.BackgroundColor3 = c
end)

--// MINIMIZE
local minimized=false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    saveBtn.Visible = not minimized
    tpBtn.Visible = not minimized
    frame.Size = minimized and UDim2.new(0,200,0,25) or UDim2.new(0,200,0,130)
end)

--// SAVE POS
saveBtn.MouseButton1Click:Connect(function()
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        SAVED_POS = char.HumanoidRootPart.CFrame
    end
end)

--// FIND CLOSEST
local function closest()
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

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

--// TELEPORT
local function teleport()
    local char = plr.Character
    if not char or not SAVED_POS then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos2 = closest()
    hrp.CFrame = SAVED_POS
    task.wait(.05)
    if pos2 then hrp.CFrame = pos2 end
end

--// DETECT STEAL
local function enableDetect()
    if promptConnection then return end
    promptConnection = ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt,who)
        if who ~= plr then return end
        if prompt.Name ~= "Steal" and prompt.ActionText ~= "Steal" then return end
        if not ENABLED then return end
        teleport()
    end)
end

local function disableDetect()
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection=nil
    end
end

--// TOGGLE
tpBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    
    if ENABLED then
        tpBtn.Text = "TP ON"
        enableDetect()
    else
        tpBtn.Text = "TP OFF"
        disableDetect()
    end
end)
