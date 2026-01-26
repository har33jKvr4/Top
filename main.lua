--[[ 
====================================================
 Speed Boost | Harold lua
 Tsunami UI + LKZ Speed
====================================================
]]

-------------------------------------------------
-- SERVICIOS
-------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- CHARACTER
-------------------------------------------------
local character, hrp, hum

local function setupCharacter(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
	hum = char:WaitForChild("Humanoid")
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-------------------------------------------------
-- LOADING SCREEN
-------------------------------------------------
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "TsunamiLoading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.Parent = PlayerGui

local Background = Instance.new("Frame", LoadingGui)
Background.Size = UDim2.new(1,0,1,0)
Background.BackgroundColor3 = Color3.fromRGB(0,0,0)
Background.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Background)
Title.Size = UDim2.new(1,0,0,60)
Title.Position = UDim2.new(0,0,0.4,0)
Title.BackgroundTransparency = 1
Title.Text = "Loading Speed Boost..."
Title.TextColor3 = Color3.fromRGB(255,0,0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 32
Title.TextTransparency = 1

local BarBack = Instance.new("Frame", Background)
BarBack.Size = UDim2.new(0.4,0,0,18)
BarBack.Position = UDim2.new(0.3,0,0.52,0)
BarBack.BackgroundColor3 = Color3.fromRGB(40,40,40)
BarBack.BackgroundTransparency = 1
BarBack.BorderSizePixel = 0
Instance.new("UICorner", BarBack)

local Bar = Instance.new("Frame", BarBack)
Bar.Size = UDim2.new(0,0,1,0)
Bar.BackgroundColor3 = Color3.fromRGB(255,0,0)
Bar.BorderSizePixel = 0
Instance.new("UICorner", Bar)

TweenService:Create(Background,TweenInfo.new(0.6),{BackgroundTransparency=0}):Play()
TweenService:Create(Title,TweenInfo.new(0.6),{TextTransparency=0}):Play()
TweenService:Create(BarBack,TweenInfo.new(0.6),{BackgroundTransparency=0}):Play()

task.wait(0.6)

TweenService:Create(Bar,TweenInfo.new(1.2),{Size=UDim2.new(1,0,1,0)}):Play()
task.wait(1.5)

LoadingGui:Destroy()

-------------------------------------------------
-- UI HUB
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedBoostHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,260,0,150)
MainFrame.Position = UDim2.new(0.5,-130,0.5,-75)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255,0,0)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

local CreatorLabel = Instance.new("TextLabel", MainFrame)
CreatorLabel.Size = UDim2.new(1,0,0,25)
CreatorLabel.Position = UDim2.new(0,0,0,5)
CreatorLabel.BackgroundTransparency = 1
CreatorLabel.Text = "Speed Boost | Harold lua"
CreatorLabel.TextColor3 = Color3.fromRGB(255,0,0)
CreatorLabel.Font = Enum.Font.GothamBold
CreatorLabel.TextSize = 14

local BoostButton = Instance.new("TextButton", MainFrame)
BoostButton.Size = UDim2.new(0.9,0,0,45)
BoostButton.Position = UDim2.new(0.05,0,0,60)
BoostButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
BoostButton.Text = "BOOST"
BoostButton.TextColor3 = Color3.fromRGB(255,255,255)
BoostButton.Font = Enum.Font.GothamBold
BoostButton.TextSize = 18
BoostButton.BorderSizePixel = 0
Instance.new("UICorner", BoostButton).CornerRadius = UDim.new(0,10)

-------------------------------------------------
-- DISCORD (SIN CAMBIOS)
-------------------------------------------------
local DiscordLabel = Instance.new("TextLabel", MainFrame)
DiscordLabel.Size = UDim2.new(0,55,0,15)
DiscordLabel.Position = UDim2.new(0.05,0,0,115)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "discord:"
DiscordLabel.TextColor3 = Color3.fromRGB(255,255,255)
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.TextSize = 11
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left

local DiscordLink = Instance.new("TextButton", MainFrame)
DiscordLink.Size = UDim2.new(0,170,0,15)
DiscordLink.Position = UDim2.new(0.27,0,0,115)
DiscordLink.BackgroundTransparency = 1
DiscordLink.Text = "https://discord.gg/WvmRU6RYn"
DiscordLink.TextColor3 = Color3.fromRGB(120,170,255)
DiscordLink.Font = Enum.Font.Gotham
DiscordLink.TextSize = 11
DiscordLink.TextXAlignment = Enum.TextXAlignment.Left
DiscordLink.AutoButtonColor = false

DiscordLink.MouseButton1Click:Connect(function()
	pcall(function()
		GuiService:OpenBrowserWindow("https://discord.gg/WvmRU6RYn")
	end)
end)

-------------------------------------------------
-- SPEED BOOST
-------------------------------------------------
local boostEnabled = false
local speedConnection

local speedNoSteal = 16
local speedSteal = 50

BoostButton.MouseButton1Click:Connect(function()
	boostEnabled = not boostEnabled

	if boostEnabled then
		BoostButton.Text = "ON"
		BoostButton.BackgroundColor3 = Color3.fromRGB(40,40,40)

		speedConnection = RunService.Heartbeat:Connect(function()
			if character and hrp and hum then
				local dir = hum.MoveDirection
				if dir.Magnitude > 0 then
					local steal = hum.WalkSpeed < 25
					local spd = steal and speedSteal or speedNoSteal

					hrp.AssemblyLinearVelocity = Vector3.new(
						dir.X * spd,
						hrp.AssemblyLinearVelocity.Y,
						dir.Z * spd
					)
				end
			end
		end)

	else
		BoostButton.Text = "BOOST"
		BoostButton.BackgroundColor3 = Color3.fromRGB(200,0,0)

		if speedConnection then
			speedConnection:Disconnect()
			speedConnection = nil
		end
	end
end)
