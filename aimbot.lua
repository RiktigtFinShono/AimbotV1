-- Final Aimbot + ESP Script w/ Target Locking, Clean GUI, and Distance Scaled ESP

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SurvivorAimbotGUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 260)
main.Position = UDim2.new(0, 30, 0, 120)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Text = "Aimbot & ESP Panel | V1"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Variables
local aimbotEnabled = false
local aimbotToggled = false
local toggleKey = Enum.UserInputType.MouseButton2
local aimPart = "Head"
local aimRadius = 150
local espEnabled = false
local currentTarget = nil
local drawings = {}

-- Aimbot Enable
local enableButton = Instance.new("TextButton", main)
enableButton.Text = "Aimbot: OFF"
enableButton.Position = UDim2.new(0, 10, 0, 40)
enableButton.Size = UDim2.new(0, 150, 0, 30)
enableButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
enableButton.TextColor3 = Color3.new(1, 1, 1)
enableButton.Font = Enum.Font.Gotham
enableButton.TextSize = 14
Instance.new("UICorner", enableButton).CornerRadius = UDim.new(0, 5)
enableButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	enableButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

-- Hotkey Box
local hotkeyBox = Instance.new("TextBox", main)
hotkeyBox.Size = UDim2.new(0, 150, 0, 30)
hotkeyBox.Position = UDim2.new(0, 10, 0, 80)
hotkeyBox.Text = "Hotkey: Right Mouse"
hotkeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hotkeyBox.TextColor3 = Color3.new(1, 1, 1)
hotkeyBox.Font = Enum.Font.Gotham
hotkeyBox.TextSize = 14
Instance.new("UICorner", hotkeyBox).CornerRadius = UDim.new(0, 5)
hotkeyBox.FocusLost:Connect(function()
	local key = hotkeyBox.Text:upper()
	if Enum.KeyCode[key] then
		toggleKey = Enum.KeyCode[key]
		hotkeyBox.Text = "Hotkey: " .. key
	elseif key == "RIGHT MOUSE" then
		toggleKey = Enum.UserInputType.MouseButton2
		hotkeyBox.Text = "Hotkey: Right Mouse"
	end
end)

-- Body Part Dropdown
local dropdown = Instance.new("TextButton", main)
dropdown.Position = UDim2.new(0, 10, 0, 120)
dropdown.Size = UDim2.new(0, 150, 0, 30)
dropdown.Text = "Body Part: Head"
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 14
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 5)

local options = {"Head", "Torso", "HumanoidRootPart"}
local currentOption = 1
dropdown.MouseButton1Click:Connect(function()
	currentOption = currentOption % #options + 1
	aimPart = options[currentOption]
	dropdown.Text = "Body Part: " .. aimPart
end)

-- ESP Toggle
local espButton = Instance.new("TextButton", main)
espButton.Size = UDim2.new(0, 150, 0, 30)
espButton.Position = UDim2.new(0, 180, 0, 40)
espButton.Text = "ESP: OFF"
espButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
espButton.TextColor3 = Color3.new(1, 1, 1)
espButton.Font = Enum.Font.Gotham
espButton.TextSize = 14
Instance.new("UICorner", espButton).CornerRadius = UDim.new(0, 5)
espButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
end)

-- Aim Circle
local aimCircle = Drawing.new("Circle")
aimCircle.Filled = false
aimCircle.NumSides = 100
aimCircle.Radius = aimRadius
aimCircle.Thickness = 1
aimCircle.Visible = false
aimCircle.Color = Color3.fromRGB(255, 255, 255)

-- Hotkey Toggle Logic
UIS.InputBegan:Connect(function(i)
	if aimbotEnabled and (i.KeyCode == toggleKey or i.UserInputType == toggleKey) then
		aimbotToggled = not aimbotToggled
		if not aimbotToggled then
			currentTarget = nil
		end
	end
end)

-- Get Closest Player
local function getClosest()
	local closest, dist = nil, aimRadius
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild(aimPart) then
			local pos, vis = Camera:WorldToScreenPoint(p.Character[aimPart].Position)
			local diff = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
			if vis and diff < dist then
				dist = diff
				closest = p
			end
		end
	end
	return closest
end

-- ESP Generator
local function createESP(p)
	local obj = {
		name = Drawing.new("Text"),
		health = Drawing.new("Text"),
		distance = Drawing.new("Text"),
		box = Drawing.new("Square"),
		line = Drawing.new("Line")
	}
	for _, d in pairs(obj) do
		d.Visible = false
		d.Center = true
		d.Outline = true
	end
	obj.name.Color = Color3.new(1,1,1)
	obj.health.Color = Color3.new(1,0,0)
	obj.distance.Color = Color3.new(0,1,1)
	obj.box.Color = Color3.fromRGB(255,255,0)
	obj.box.Thickness = 1
	obj.line.Color = Color3.fromRGB(255,255,255)
	obj.line.Thickness = 1
	drawings[p] = obj
end

local function removeESP(p)
	if drawings[p] then
		for _, d in pairs(drawings[p]) do d:Remove() end
		drawings[p] = nil
	end
end

for _, p in pairs(Players:GetPlayers()) do
	if p ~= LP then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LP then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

-- Main Render Loop
RS.RenderStepped:Connect(function()
	-- Aim Circle Visual
	aimCircle.Visible = aimbotEnabled
	aimCircle.Position = Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
	aimCircle.Color = aimbotToggled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)

	-- Aimbot Lock
	if aimbotEnabled and aimbotToggled then
		if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild(aimPart) then
			currentTarget = getClosest()
		end
		if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(aimPart) then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character[aimPart].Position)
		end
	end

	-- ESP Drawing
	for p, d in pairs(drawings) do
		local char = p.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and espEnabled then
			local pos, vis = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
			if vis then
				local dist = (Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude
				local scale = math.clamp(500 / dist, 0.5, 1.5)
				local size = Vector2.new(20, 40) * scale

				d.name.Text = p.Name
				d.name.Position = Vector2.new(pos.X, pos.Y - 40)
				d.name.Visible = true

				d.health.Text = "HP: " .. math.floor(char.Humanoid.Health)
				d.health.Position = Vector2.new(pos.X, pos.Y - 25)
				d.health.Visible = true

				d.distance.Text = "Dist: " .. math.floor(dist)
				d.distance.Position = Vector2.new(pos.X, pos.Y - 10)
				d.distance.Visible = true

				d.box.Size = size
				d.box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
				d.box.Visible = true

				d.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				d.line.To = Vector2.new(pos.X, pos.Y)
				d.line.Visible = true
			else
				for _, v in pairs(d) do v.Visible = false end
			end
		else
			for _, v in pairs(d) do v.Visible = false end
		end
	end
end)
