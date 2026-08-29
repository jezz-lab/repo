-- Become a Brainrot
--==================================================
-- AUTO COLLECT CASH
--==================================================

--==================================================
-- CONFIG
--==================================================

local ALLOWED_GAME_ID = "" -- "" = every game
local MAX_STAND = 20
local CHECK_INTERVAL = 1

--==================================================
-- GAME ID LIMITER
--==================================================

if ALLOWED_GAME_ID ~= "" and game.GameId ~= tonumber(ALLOWED_GAME_ID) then
return
end

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- GUI PARENT
--==================================================

local GuiParent

if typeof(gethui) == "function" then
GuiParent = gethui()
else
GuiParent = game:GetService("CoreGui")
end

--==================================================
-- CLEAN OLD GUI
--==================================================

local OldGui = GuiParent:FindFirstChild("AutoCollectCash")

if OldGui then
OldGui:Destroy()
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoCollectCash"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

--==================================================
-- MAIN FRAME
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(240, 100)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -50)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 0, 35)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "AUTO COLLECT CASH"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

--==================================================
-- CLOSE
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.new(1, -34, 0, 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 21
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

--==================================================
-- CHECKBOX
--==================================================

local CheckBox = Instance.new("TextButton")
CheckBox.Size = UDim2.fromOffset(28, 28)
CheckBox.Position = UDim2.fromOffset(12, 50)
CheckBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
CheckBox.BorderSizePixel = 0
CheckBox.Text = ""
CheckBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBox.TextSize = 19
CheckBox.Font = Enum.Font.GothamBold
CheckBox.Parent = MainFrame

local CheckCorner = Instance.new("UICorner")
CheckCorner.CornerRadius = UDim.new(0, 5)
CheckCorner.Parent = CheckBox

--==================================================
-- LABEL
--==================================================

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, -55, 0, 30)
Label.Position = UDim2.fromOffset(50, 49)
Label.BackgroundTransparency = 1
Label.Text = "Auto Collect Cash"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 15
Label.Font = Enum.Font.Gotham
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = MainFrame

--==================================================
-- FLOATING ICON
--==================================================

local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.fromOffset(45, 45)
ToggleIcon.Position = UDim2.new(0, 20, 0.5, -22)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToggleIcon.BorderSizePixel = 0
ToggleIcon.Text = "$"
ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.TextSize = 20
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.Parent = ScreenGui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = ToggleIcon

--==================================================
-- DRAG
--==================================================

local function MakeDraggable(Object)

```
local Dragging = false
local DragStart
local StartPosition

Object.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Object.Position

    end

end)

Object.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement
        and Input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = Input.Position - DragStart

    Object.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )

end)
```

end

MakeDraggable(MainFrame)
MakeDraggable(ToggleIcon)

--==================================================
-- TOGGLE GUI
--==================================================

ToggleIcon.MouseButton1Click:Connect(function()
MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
MainFrame.Visible = false
end)

--==================================================
-- AUTO COLLECT STATE
--==================================================

local Enabled = false

local function UpdateCheckbox()

```
if Enabled then
    CheckBox.Text = "✓"
    CheckBox.BackgroundColor3 = Color3.fromRGB(60, 120, 70)
else
    CheckBox.Text = ""
    CheckBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
end
```

end

CheckBox.MouseButton1Click:Connect(function()

```
Enabled = not Enabled
UpdateCheckbox()
```

end)

--==================================================
-- REMOTE
--==================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events", 10)

if not Events then
warn("AutoCollectCash: Events folder not found.")
return
end

local CollectCash = Events:WaitForChild("CollectCash", 10)

if not CollectCash then
warn("AutoCollectCash: CollectCash RemoteEvent not found.")
return
end

--==================================================
-- COLLECTION LOOP
--==================================================

task.spawn(function()

```
while ScreenGui.Parent do

    if Enabled then

        local AnimalStands =
            LocalPlayer:FindFirstChild("AnimalStands")

        if AnimalStands then

            for i = 1, MAX_STAND do

                local Stand =
                    AnimalStands:FindFirstChild(tostring(i))

                if Stand then
                    CollectCash:FireServer(Stand)
                end

            end

        end

    end

    task.wait(CHECK_INTERVAL)

end
```

end)

--==================================================
-- INITIAL STATE
--==================================================

UpdateCheckbox()

print("AutoCollectCash loaded successfully.")
