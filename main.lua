--// HAROLD TOP 😹
--// Full GUI + Sources

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-------------------------------------------------
-- GUI BASE
-------------------------------------------------
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "HAROLD_TOP"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 210, 0, 260)
main.Position = UDim2.new(0.5, -105, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "⚡ HAROLD TOP 😹"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255,80,80)

-------------------------------------------------
-- CLICK SOUND
-------------------------------------------------
local click = Instance.new("Sound", gui)
click.SoundId = "rbxassetid://12221967"
click.Volume = 1

local function sound()
	click:Play()
end

-------------------------------------------------
-- BUTTON MAKER
-------------------------------------------------
local function button(txt, y, w)
	local b = Instance.new("TextButton", main)
	b.Size = w or UDim2.new(1,-20,0,32)
	b.Position = UDim2.new(0,10,0,y)
	b.BackgroundColor3 = Color3.fromRGB(40,0,0)
	b.Text = txt.." [OFF]"
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

-------------------------------------------------
-- BUTTONS (ORDER CORRECTO)
-------------------------------------------------
local DesyncBtn = button("DESYNC", 45)
local SpeedBtn  = button("SPEED", 85)
local KickBtn   = button("KICK", 125)

local ESPBtn = button("ESP", 165, UDim2.new(0.48,-5,0,32))
ESPBtn.Position = UDim2.new(0,10,0,165)

local RayBtn = button("RAY", 165, UDim2.new(0.48,-5,0,32))
RayBtn.Position = UDim2.new(0.52,0,0,165)

local AntiBtn = button("ANTIRADGOLL", 205)

-------------------------------------------------
-- STATES
-------------------------------------------------
local desyncOn, speedOn, kickOn, espOn, rayOn, antiOn = false,false,false,false,false,false
local normalSpeed = 16

-------------------------------------------------
-- DESYNC (simple)
-------------------------------------------------
DesyncBtn.MouseButton1Click:Connect(function()
	sound()
	desyncOn = not desyncOn
	DesyncBtn.Text = "DESYNC ["..(desyncOn and "ON" or "OFF").."]"
	DesyncBtn.BackgroundColor3 = desyncOn and Color3.fromRGB(120,0,0) or Color3.fromRGB(40,0,0)
end)

-------------------------------------------------
-- SPEED (38.5)
-------------------------------------------------
SpeedBtn.MouseButton1Click:Connect(function()
	sound()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
	if not hum then return end
	speedOn = not speedOn
	hum.WalkSpeed = speedOn and 38.5 or normalSpeed
	SpeedBtn.Text = "SPEED ["..(speedOn and "ON" or "OFF").."]"
	SpeedBtn.BackgroundColor3 = speedOn and Color3.fromRGB(0,120,255) or Color3.fromRGB(40,0,0)
end)

-------------------------------------------------
-- KICK SOURCE
-------------------------------------------------
local keyword = "you stole"
local function watchKick(obj)
	if obj:IsA("TextLabel") or obj:IsA("TextButton") then
		obj:GetPropertyChangedSignal("Text"):Connect(function()
			if kickOn and string.find(string.lower(obj.Text), keyword) then
				LocalPlayer:Kick("Discord@rznnq")
			end
		end)
	end
end

KickBtn.MouseButton1Click:Connect(function()
	sound()
	kickOn = not kickOn
	KickBtn.Text = "KICK ["..(kickOn and "ON" or "OFF").."]"
	KickBtn.BackgroundColor3 = kickOn and Color3.fromRGB(120,0,0) or Color3.fromRGB(40,0,0)
	if kickOn then
		for _,v in pairs(PlayerGui:GetDescendants()) do
			watchKick(v)
		end
	end
end)

-------------------------------------------------
-- ESP SOURCE
-------------------------------------------------
local espObjects = {}

local function addESP(plr)
	if plr == LocalPlayer then return end
	local c = plr.Character
	if not c then return end
	local hrp = c:FindFirstChild("HumanoidRootPart")
	local head = c:FindFirstChild("Head")
	if not (hrp and head) then return end

	local box = Instance.new("BoxHandleAdornment", hrp)
	box.Size = Vector3.new(4,6,2)
	box.AlwaysOnTop = true
	box.Transparency = 0.6
	box.Color3 = Color3.fromRGB(255,0,255)

	local bb = Instance.new("BillboardGui", head)
	bb.Size = UDim2.new(0,200,0,40)
	bb.AlwaysOnTop = true
	local tl = Instance.new("TextLabel", bb)
	tl.Size = UDim2.new(1,0,1,0)
	tl.BackgroundTransparency = 1
	tl.Text = plr.Name
	tl.TextColor3 = Color3.fromRGB(255,0,255)
	tl.TextScaled = true

	espObjects[plr] = {box,bb}
end

ESPBtn.MouseButton1Click:Connect(function()
	sound()
	espOn = not espOn
	ESPBtn.Text = "ESP ["..(espOn and "ON" or "OFF").."]"
	ESPBtn.BackgroundColor3 = espOn and Color3.fromRGB(0,200,0) or Color3.fromRGB(40,0,0)
	if espOn then
		for _,p in pairs(Players:GetPlayers()) do addESP(p) end
	else
		for _,t in pairs(espObjects) do
			for _,o in pairs(t) do o:Destroy() end
		end
		espObjects = {}
	end
end)

-------------------------------------------------
-- RAY (BASE WALLHACK)
-------------------------------------------------
local rayParts = {}

local function isBase(p)
	local n = p.Name:lower()
	return n:find("base") or n:find("claim")
end

RayBtn.MouseButton1Click:Connect(function()
	sound()
	rayOn = not rayOn
	RayBtn.Text = "RAY ["..(rayOn and "ON" or "OFF").."]"
	RayBtn.BackgroundColor3 = rayOn and Color3.fromRGB(255,140,0) or Color3.fromRGB(40,0,0)

	for _,v in pairs(Workspace:GetDescendants()) do
		if v:IsA("BasePart") and isBase(v) then
			if rayOn then
				rayParts[v] = v.LocalTransparencyModifier
				v.LocalTransparencyModifier = 0.8
			else
				v.LocalTransparencyModifier = rayParts[v] or 0
			end
		end
	end
end)

-------------------------------------------------
-- ANTI RAGDOLL (simple & stable)
-------------------------------------------------
AntiBtn.MouseButton1Click:Connect(function()
	sound()
	antiOn = not antiOn
	AntiBtn.Text = "ANTIRADGOLL ["..(antiOn and "ON" or "OFF").."]"
	AntiBtn.BackgroundColor3 = antiOn and Color3.fromRGB(120,120,120) or Color3.fromRGB(40,0,0)
end)

RunService.Heartbeat:Connect(function()
	if antiOn then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if hum and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
			hum:ChangeState(Enum.HumanoidStateType.Running)
		end
	end
end)
