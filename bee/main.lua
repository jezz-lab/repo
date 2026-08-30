--==================================================
-- FARM A FISH | BEE EVENT
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old GUI
local oldGui = playerGui:FindFirstChild("ActionGui")
if oldGui then
oldGui:Destroy()
end

--==================================================
-- SETTINGS
--==================================================

local FRAME_WIDTH = 240
local MIN_HEIGHT = 120
local MAX_HEIGHT = 500

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ActionGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

--==================================================
-- MAIN FRAME
--==================================================

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(FRAME_WIDTH, MIN_HEIGHT)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

--==================================================
-- TOGGLE ICON
--==================================================

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleIcon"
toggleButton.Text = "⚡"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextSize = 24
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.BorderSizePixel = 0
toggleButton.Size = UDim2.fromOffset(45, 45)
toggleButton.Position = UDim2.fromOffset(15, 100)
toggleButton.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleButton

--==================================================
-- ICON DRAGGING
--==================================================

local iconDragging = false
local iconDragStart
local iconStartPosition
local iconMoved = false

toggleButton.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

```
	iconDragging = true
	iconMoved = false
	iconDragStart = input.Position
	iconStartPosition = toggleButton.Position

	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			iconDragging = false
		end
	end)
end
```

end)

UserInputService.InputChanged:Connect(function(input)
if not iconDragging then
return
end

```
if input.UserInputType ~= Enum.UserInputType.MouseMovement
	and input.UserInputType ~= Enum.UserInputType.Touch then
	return
end

local delta = input.Position - iconDragStart

if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
	iconMoved = true
end

toggleButton.Position = UDim2.new(
	iconStartPosition.X.Scale,
	iconStartPosition.X.Offset + delta.X,
	iconStartPosition.Y.Scale,
	iconStartPosition.Y.Offset + delta.Y
)
```

end)

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Text = "Farm a Fish: Bee Event"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 10
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.fromOffset(10, 0)
title.Parent = frame

--==================================================
-- CLOSE BUTTON
--==================================================

local close = Instance.new("TextButton")
close.Name = "CloseButton"
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 18
close.Font = Enum.Font.GothamBold
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.BorderSizePixel = 0
close.Size = UDim2.fromOffset(40, 35)
close.Position = UDim2.new(1, -45, 0, 5)
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
gui:Destroy()
end)

--==================================================
-- TOGGLE FRAME
--==================================================

toggleButton.MouseButton1Click:Connect(function()
if iconMoved then
iconMoved = false
return
end

```
frame.Visible = not frame.Visible
```

end)

--==================================================
-- MAIN FRAME DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then

```
	dragging = true
	dragStart = input.Position
	startPosition = frame.Position

	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			dragging = false
		end
	end)
end
```

end)

UserInputService.InputChanged:Connect(function(input)
if not dragging then
return
end

```
if input.UserInputType ~= Enum.UserInputType.MouseMovement
	and input.UserInputType ~= Enum.UserInputType.Touch then
	return
end

local delta = input.Position - dragStart

frame.Position = UDim2.new(
	startPosition.X.Scale,
	startPosition.X.Offset + delta.X,
	startPosition.Y.Scale,
	startPosition.Y.Offset + delta.Y
)
```

end)

--==================================================
-- BUTTON CONTAINER
--==================================================

local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "Buttons"
buttonFrame.BackgroundTransparency = 1
buttonFrame.Size = UDim2.new(1, -20, 1, -50)
buttonFrame.Position = UDim2.fromOffset(10, 45)
buttonFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = buttonFrame

--==================================================
-- SPEED INPUT ROW
--==================================================

local speedRow = Instance.new("Frame")
speedRow.Name = "SpeedRow"
speedRow.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
speedRow.BorderSizePixel = 0
speedRow.Size = UDim2.new(1, 0, 0, 40)
speedRow.LayoutOrder = 1
speedRow.Parent = buttonFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedRow

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Speed"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 15
speedLabel.Font = Enum.Font.Gotham
speedLabel.BackgroundTransparency = 1
speedLabel.Size = UDim2.new(1, -95, 1, 0)
speedLabel.Position = UDim2.fromOffset(10, 0)
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedRow

local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Text = "16"
speedInput.PlaceholderText = "Speed"
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
speedInput.TextSize = 14
speedInput.Font = Enum.Font.Gotham
speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedInput.BorderSizePixel = 0
speedInput.Size = UDim2.fromOffset(75, 30)
speedInput.Position = UDim2.new(1, -85, 0.5, -15)
speedInput.ClearTextOnFocus = false
speedInput.Parent = speedRow

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 5)
speedInputCorner.Parent = speedInput

--==================================================
-- ACTION ROW CREATOR
--==================================================

local function createAction(name, order, callback)
local row = Instance.new("Frame")
row.Name = name .. "Row"
row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
row.BorderSizePixel = 0
row.Size = UDim2.new(1, 0, 0, 40)
row.LayoutOrder = order
row.Parent = buttonFrame

```
local rowCorner = Instance.new("UICorner")
rowCorner.CornerRadius = UDim.new(0, 6)
rowCorner.Parent = row

-- Label
local label = Instance.new("TextLabel")
label.Name = "Label"
label.Text = name
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 14
label.Font = Enum.Font.Gotham
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, -55, 1, 0)
label.Position = UDim2.fromOffset(10, 0)
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = row

-- Action button
local actionButton = Instance.new("TextButton")
actionButton.Name = "ActionButton"

-- Primary ASCII icon
actionButton.Text = ">"

actionButton.TextColor3 = Color3.new(1, 1, 1)
actionButton.TextSize = 18
actionButton.Font = Enum.Font.GothamBold
actionButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
actionButton.BorderSizePixel = 0
actionButton.Size = UDim2.fromOffset(30, 30)
actionButton.Position = UDim2.new(1, -38, 0.5, -15)
actionButton.AutoButtonColor = false
actionButton.Parent = row

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 7)
buttonCorner.Parent = actionButton

-- Hover
actionButton.MouseEnter:Connect(function()
	actionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end)

actionButton.MouseLeave:Connect(function()
	actionButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
end)

-- Press
actionButton.MouseButton1Down:Connect(function()
	actionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

actionButton.MouseButton1Up:Connect(function()
	actionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end)

actionButton.MouseButton1Click:Connect(function()
	callback()
end)

return actionButton
```

end

--==================================================
-- SET SPEED
--==================================================

createAction("Set Speed", 2, function()
local character = player.Character

```
if not character then
	return
end

local humanoid = character:FindFirstChildOfClass("Humanoid")

if not humanoid then
	return
end

local speed = tonumber(speedInput.Text)

if not speed then
	warn("Please enter a valid number for speed.")
	return
end

humanoid.WalkSpeed = speed

print("Speed set to:", speed)
```

end)

--==================================================
-- INSERT LEFT
--==================================================

createAction("Insert <Left>", 3, function()
local Event = game:GetService("ReplicatedStorage")
.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]

```
Event:FireServer(1)

print("Insert Left clicked!")
```

end)

--==================================================
-- INSERT MIDDLE
--==================================================

createAction("Insert <Middle>", 4, function()
local Event = game:GetService("ReplicatedStorage")
.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]

```
Event:FireServer(2)

print("Insert Middle clicked!")
```

end)

--==================================================
-- INSERT RIGHT
--==================================================

createAction("Insert <Right>", 5, function()
local Event = game:GetService("ReplicatedStorage")
.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]

```
Event:FireServer(3)

print("Insert Right clicked!")
```

end)

--==================================================
-- PURCHASE BEE BAIT
--==================================================

createAction("Purchase Bee Bait Pack", 6, function()
local Event = game:GetService("ReplicatedStorage")
.rbxts_include.node_modules["@rbxts"].remo.src.container["shop.purchaseEventItem"]

```
Event:FireServer("baitpack:Bee")

print("Purchase clicked!")
```

end)

--==================================================
-- FEED KING BEE
--==================================================

createAction("Feed King Bee", 7, function()
local Event1 = game:GetService("ReplicatedStorage")
.rbxts_include.node_modules["@rbxts"].remo.src.container["npc.dialogueCompleted"]

```
local Event2 = game:GetService("ReplicatedStorage")
	.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.feedKingBeeAll"]

-- First
Event1:FireServer("KingBee")

-- Second
Event2:FireServer()

print("King Bee fed!")
```

end)

--==================================================
-- AUTOMATIC HEIGHT
--==================================================

local function updateHeight()
local contentHeight = layout.AbsoluteContentSize.Y

```
local newHeight = math.clamp(
	contentHeight + 60,
	MIN_HEIGHT,
	MAX_HEIGHT
)

frame.Size = UDim2.fromOffset(FRAME_WIDTH, newHeight)
```

end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)

-- Initial height
updateHeight()
