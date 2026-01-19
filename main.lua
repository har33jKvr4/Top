-- HAROLD TOP 😹
-- Full GUI Script | Movible | Toggle | Click Sound

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

---------------- CLICK SOUND ----------------
local function playClick(parent)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://12221967"
	s.Volume = 1
	s.Parent = parent
	s:Play()
	game.Debris:AddItem(s, 2)
end

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "HAROLD_TOP_GUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.28, 0.45)
main.Position = UDim2.fromScale(0.36, 0.25)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
main.BorderSizePixel = 0

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0.15,0)
title.BackgroundTransparency = 1
title.Text = "HAROLD TOP 😹"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0,10)

---------------- BUTTON CREATOR ----------------
local function makeButton(text, sizeX)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(sizeX or 0.9,0,0.1,0)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
	b.Parent = main
	return b
end

---------------- BUTTONS (ORDER) ----------------
local desyncBtn = makeButton("DESYNC")
local speedBtn = makeButton("SPEED")
local kickBtn = makeButton("KICK")

-- ESP + RAY ROW
local row = Instance.new("Frame", main)
row.Size = UDim2.new(0.9,0,0.1,0)
row.BackgroundTransparency = 1

local espBtn = Instance.new("TextButton", row)
espBtn.Size = UDim2.new(0.48,0,1,0)
espBtn.Position = UDim2.new(0,0,0,0)
espBtn.Text = "ESP"
espBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
espBtn.TextColor3 = Color3.new(1,1,1)
espBtn.Font = Enum.Font.GothamBold
espBtn.TextScaled = true
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,12)

local rayBtn = Instance.new("TextButton", row)
rayBtn.Size = UDim2.new(0.48,0,1,0)
rayBtn.Position = UDim2.new(0.52,0,0,0)
rayBtn.Text = "RAY"
rayBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
rayBtn.TextColor3 = Color3.new(1,1,1)
rayBtn.Font = Enum.Font.GothamBold
rayBtn.TextScaled = true
Instance.new("UICorner", rayBtn).CornerRadius = UDim.new(0,12)

local antiBtn = makeButton("ANTI RAGDOLL")

------------------------------------------------
---------------- FEATURES -----------------------
------------------------------------------------

-- DESYNC (simple)
local desync = false
desyncBtn.MouseButton1Click:Connect(function()
	playClick(desyncBtn)
	desync = not desync
	RunService:Set3dRenderingEnabled(not desync)
end)

-- SPEED
local speed = false
speedBtn.MouseButton1Click:Connect(function()
	playClick(speedBtn)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	speed = not speed
	hum.WalkSpeed = speed and 38.5 or 16
end)

-- KICK (YOUR SOURCE)
local kickEnabled = false
kickBtn.MouseButton1Click:Connect(function()
	playClick(kickBtn)
	if kickEnabled then return end
	kickEnabled = true

	local PlayerGui = player:WaitForChild("PlayerGui")
	local KEYWORD = "you stole"
	local KICK_MESSAGE = "Discord@rznnq"

	local function check(obj)
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			if string.find(string.lower(obj.Text), KEYWORD) then
				player:Kick(KICK_MESSAGE)
			end
		end
	end

	for _,g in pairs(PlayerGui:GetDescendants()) do
		check(g)
	end

	PlayerGui.DescendantAdded:Connect(check)
end)

-- ESP (simple box)
local espOn = false
espBtn.MouseButton1Click:Connect(function()
	playClick(espBtn)
	espOn = not espOn
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			for _,v in pairs(p.Character:GetChildren()) do
				if v:IsA("BasePart") then
					v.LocalTransparencyModifier = espOn and 0.3 or 0
				end
			end
		end
	end
end)

-- RAY (YOUR SOURCE)
rayBtn.MouseButton1Click:Connect(function()
	playClick(rayBtn)

	local original = {}
	local function isBase(o)
		local n = o.Name:lower()
		return n:find("base") or n:find("claim")
	end

	for _,o in pairs(Workspace:GetDescendants()) do
		if o:IsA("BasePart") and isBase(o) then
			original[o] = o.LocalTransparencyModifier
			o.LocalTransparencyModifier = 0.8
		end
	end
end)

-- ANTI RAGDOLL (simplified toggle)
local anti = false
antiBtn.MouseButton1Click:Connect(function()
	playClick(antiBtn)
	anti = not anti
	local char = player.Character or player.CharacterAdded:Wait()
	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BallSocketConstraint") then
			v.Enabled = not anti
		end
	end
end)
