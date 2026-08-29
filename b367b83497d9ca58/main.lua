-- Become a Brainrot
--==================================================
-- AUTO COLLECT CASH
--==================================================

--==================================================
-- CONFIG
--==================================================

local ALLOWED_GAME_ID = ""    -- "" = every game
local MAX_STAND = 20
local CHECK_INTERVAL = 1

--==================================================
-- GAME ID LIMITER
--==================================================

if ALLOWED_GAME_ID ~= "" then
    if game.GameId ~= tonumber(ALLOWED_GAME_ID) then
        return
    end
end

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
-- STATE
--==================================================

local Enabled = false
local Terminated = false

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
Title.Name = "Title"
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
-- TERMINATE BUTTON
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Terminate"
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
CheckBox.Name = "CheckBox"
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

local CheckLabel = Instance.new("TextLabel")
CheckLabel.Name = "Label"
CheckLabel.Size = UDim2.new(1, -55, 0, 30)
CheckLabel.Position = UDim2.fromOffset(50, 49)
CheckLabel.BackgroundTransparency = 1
CheckLabel.Text = "Auto Collect Cash"
CheckLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckLabel.TextSize = 15
CheckLabel.Font = Enum.Font.Gotham
CheckLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckLabel.Parent = MainFrame

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
-- DRAG FUNCTION
--==================================================

local Connections = {}

local function MakeDraggable(Object)

    local Dragging = false
    local DragStart
    local StartPosition

    local InputBegan = Object.InputBegan:Connect(function(Input)

        if Terminated then
            return
        end

        if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then

            Dragging = true
            DragStart = Input.Position
            StartPosition = Object.Position

        end

    end)

    local InputEnded = Object.InputEnded:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then

            Dragging = false

        end

    end)

    local InputChanged = UserInputService.InputChanged:Connect(function(Input)

        if Terminated or not Dragging then
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

    table.insert(Connections, InputBegan)
    table.insert(Connections, InputEnded)
    table.insert(Connections, InputChanged)

end

MakeDraggable(MainFrame)
MakeDraggable(ToggleIcon)

--==================================================
-- GUI TOGGLE
--==================================================

local ToggleConnection = ToggleIcon.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    MainFrame.Visible = not MainFrame.Visible

end)

table.insert(Connections, ToggleConnection)

--==================================================
-- CHECKBOX
--==================================================

local function UpdateCheckbox()

    if Enabled then
        CheckBox.Text = "✓"
        CheckBox.BackgroundColor3 = Color3.fromRGB(60, 120, 70)
    else
        CheckBox.Text = ""
        CheckBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    end

end

local CheckConnection = CheckBox.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    Enabled = not Enabled
    UpdateCheckbox()

end)

table.insert(Connections, CheckConnection)

--==================================================
-- TERMINATE
--==================================================

local TerminateConnection

TerminateConnection = CloseButton.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    Terminated = true
    Enabled = false

    for _, Connection in ipairs(Connections) do
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    if TerminateConnection and TerminateConnection.Connected then
        TerminateConnection:Disconnect()
    end

    ScreenGui:Destroy()

end)

--==================================================
-- REMOTE
--==================================================

local Events = ReplicatedStorage:WaitForChild("Events", 10)

if not Events then
    warn("AutoCollectCash: Events folder not found.")
else

    local CollectCash = Events:WaitForChild("CollectCash", 10)

    if not CollectCash then
        warn("AutoCollectCash: CollectCash RemoteEvent not found.")
    else

        --==================================================
        -- COLLECTION LOOP
        --==================================================

        task.spawn(function()

            while not Terminated and ScreenGui.Parent do

                if Enabled then

                    local AnimalStands =
                        LocalPlayer:FindFirstChild("AnimalStands")

                    if AnimalStands then

                        for i = 1, MAX_STAND do

                            if Terminated then
                                break
                            end

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

        end)

    end

end

--==================================================
-- INITIAL STATE
--==================================================

UpdateCheckbox()

print("AutoCollectCash loaded successfully.")
