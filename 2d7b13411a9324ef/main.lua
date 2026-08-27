--for Steal the Brainrot Base

--==================================================
-- LUCKY DROP TELEPORT GUI
-- No hooks required
-- Detects ReplicatedStorage.Events.ShowNotification
-- Draggable "Active" indicator + teleport prompt
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local TELEPORTS = {
	["Easter's Base"] = Vector3.new(4.4, -114.9, 215.3),
	["67's Base"] = Vector3.new(-54.0, 5.0, 302.8),
	["Pot Hotspot's Base"] = Vector3.new(54.5, 5.0, 372.8),
	["Dragon Cannelloni's Base"] = Vector3.new(-56.8, 5.0, 232.5),
	["Cappuccino Assassino's Base"] = Vector3.new(56.0, 5.0, 302.9),
}

--==================================================
-- GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("LuckyDropTeleport")
if oldGui then
	oldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LuckyDropTeleport"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--==================================================
-- DRAG FUNCTION
--==================================================

local function makeDraggable(object)
	local dragging = false
	local dragStart
	local startPosition

	object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStart

			object.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
end

--==================================================
-- ACTIVE INDICATOR
--==================================================

local Active = Instance.new("Frame")
Active.Name = "Active"
Active.Size = UDim2.fromOffset(105, 38)
Active.Position = UDim2.fromOffset(20, 20)
Active.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Active.BorderSizePixel = 0
Active.Parent = Gui

local ActiveCorner = Instance.new("UICorner")
ActiveCorner.CornerRadius = UDim.new(1, 0)
ActiveCorner.Parent = Active

local ActiveDot = Instance.new("Frame")
ActiveDot.Size = UDim2.fromOffset(10, 10)
ActiveDot.Position = UDim2.new(0, 13, 0.5, -5)
ActiveDot.BackgroundColor3 = Color3.fromRGB(70, 220, 100)
ActiveDot.BorderSizePixel = 0
ActiveDot.Parent = Active

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = ActiveDot

local ActiveText = Instance.new("TextLabel")
ActiveText.Size = UDim2.new(1, -32, 1, 0)
ActiveText.Position = UDim2.fromOffset(30, 0)
ActiveText.BackgroundTransparency = 1
ActiveText.Text = "Active"
ActiveText.TextColor3 = Color3.fromRGB(255, 255, 255)
ActiveText.TextSize = 15
ActiveText.Font = Enum.Font.GothamMedium
ActiveText.TextXAlignment = Enum.TextXAlignment.Left
ActiveText.Parent = Active

makeDraggable(Active)

--==================================================
-- NOTIFICATION PANEL
--==================================================

local Panel = Instance.new("Frame")
Panel.Name = "Prompt"
Panel.Size = UDim2.fromOffset(300, 150)
Panel.Position = UDim2.new(0.5, -150, 0.5, -75)
Panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Parent = Gui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

--==================================================
-- MESSAGE
--==================================================

local Message = Instance.new("TextLabel")
Message.Name = "Message"
Message.Size = UDim2.new(1, -30, 0, 55)
Message.Position = UDim2.fromOffset(15, 15)
Message.BackgroundTransparency = 1
Message.Text = "Lucky Drop at Base"
Message.TextColor3 = Color3.fromRGB(255, 255, 255)
Message.TextSize = 17
Message.Font = Enum.Font.GothamMedium
Message.TextWrapped = true
Message.Parent = Panel

--==================================================
-- QUESTION
--==================================================

local Question = Instance.new("TextLabel")
Question.Size = UDim2.new(1, 0, 0, 25)
Question.Position = UDim2.fromOffset(0, 68)
Question.BackgroundTransparency = 1
Question.Text = "Teleport?"
Question.TextColor3 = Color3.fromRGB(190, 190, 190)
Question.TextSize = 14
Question.Font = Enum.Font.Gotham
Question.Parent = Panel

--==================================================
-- YES BUTTON
--==================================================

local Yes = Instance.new("TextButton")
Yes.Name = "Yes"
Yes.Size = UDim2.fromOffset(115, 38)
Yes.Position = UDim2.fromOffset(25, 105)
Yes.BackgroundColor3 = Color3.fromRGB(55, 180, 90)
Yes.BorderSizePixel = 0
Yes.Text = "Yes"
Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
Yes.TextSize = 15
Yes.Font = Enum.Font.GothamMedium
Yes.Parent = Panel

local YesCorner = Instance.new("UICorner")
YesCorner.CornerRadius = UDim.new(0, 8)
YesCorner.Parent = Yes

--==================================================
-- NO BUTTON
--==================================================

local No = Instance.new("TextButton")
No.Name = "No"
No.Size = UDim2.fromOffset(115, 38)
No.Position = UDim2.fromOffset(160, 105)
No.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
No.BorderSizePixel = 0
No.Text = "No"
No.TextColor3 = Color3.fromRGB(255, 255, 255)
No.TextSize = 15
No.Font = Enum.Font.GothamMedium
No.Parent = Panel

local NoCorner = Instance.new("UICorner")
NoCorner.CornerRadius = UDim.new(0, 8)
NoCorner.Parent = No

--==================================================
-- TELEPORT
--==================================================

local currentBase = nil

local function teleportToBase(baseName)
	local position = TELEPORTS[baseName]
	if not position then
		return
	end

	local character = Player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	root.CFrame = CFrame.new(position)
end

--==================================================
-- BUTTONS
--==================================================

Yes.MouseButton1Click:Connect(function()
	if currentBase then
		teleportToBase(currentBase)
	end

	currentBase = nil
	Panel.Visible = false
end)

No.MouseButton1Click:Connect(function()
	currentBase = nil
	Panel.Visible = false
end)

--==================================================
-- NOTIFICATION DETECTION
--==================================================

local Events = ReplicatedStorage:WaitForChild("Events")
local ShowNotification = Events:WaitForChild("ShowNotification")

ShowNotification.OnClientEvent:Connect(function(message, color)

	if typeof(message) ~= "string" then
		return
	end

	for baseName in pairs(TELEPORTS) do

		if message:find(baseName, 1, true) then

			currentBase = baseName

			Message.Text = "Lucky Drop at " .. baseName
			Panel.Visible = true

			break
		end
	end
end)

print("✅ Lucky Drop Teleport GUI active — no hook required")
