--==================================================
-- TELEPORT GUI - TRANSPARENT BACKGROUND
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove previous copy
local oldGui = playerGui:FindFirstChild("TeleportGUI")
if oldGui then
    oldGui:Destroy()
end

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    WindowWidth = 320,
    WindowHeight = 240,
    IconSize = 45,
    BackgroundColor = Color3.fromRGB(31, 31, 38),
    BorderColor = Color3.fromRGB(77, 179, 255),
    TitleColor = Color3.fromRGB(51, 51, 64),
    MaxHistory = 5,
    
    -- NEW: Transparency settings
    MainFrameTransparency = 0.5,  -- 0 = solid, 0.5 = half, 1 = invisible
    ShowBorder = true,          -- Show border around GUI
}

--==================================================
-- SCREEN GUI
--==================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

--==================================================
-- MAIN FRAME (Transparent)
--==================================================

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(CONFIG.WindowWidth, CONFIG.WindowHeight)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Black base
mainFrame.BackgroundTransparency = CONFIG.MainFrameTransparency  -- Set transparency
mainFrame.BorderSizePixel = CONFIG.ShowBorder and 2 or 0
mainFrame.BorderColor3 = CONFIG.BorderColor
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

--==================================================
-- TITLE BAR (Semi-transparent)
--==================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = CONFIG.TitleColor
titleBar.BackgroundTransparency = 0.3  -- Keep title bar slightly visible
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "🚀 Teleport System"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(40, 36)
closeButton.Position = UDim2.new(1, -40, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
closeButton.BackgroundTransparency = 0.3  -- Semi-transparent close button
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

--==================================================
-- STATUS
--==================================================

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.fromOffset(10, 39)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● Ready"
statusLabel.TextColor3 = Color3.fromRGB(130, 255, 130)
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local function status(text, errorMessage)
    statusLabel.Text = "● " .. text
    statusLabel.TextColor3 = errorMessage and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(130, 255, 130)
end

--==================================================
-- INPUT
--==================================================

local inputLabel = Instance.new("TextLabel")
inputLabel.Size = UDim2.new(1, -32, 0, 20)
inputLabel.Position = UDim2.fromOffset(16, 67)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "📍 Coordinates (X, Y, Z):"
inputLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
inputLabel.TextSize = 12
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.Font = Enum.Font.Gotham
inputLabel.Parent = mainFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -32, 0, 34)
inputBox.Position = UDim2.fromOffset(16, 88)
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 62)
inputBox.BackgroundTransparency = 0.3  -- Semi-transparent input
inputBox.BorderColor3 = Color3.fromRGB(80, 80, 95)
inputBox.TextColor3 = Color3.new(1, 1, 1)
inputBox.PlaceholderText = "0, 10, 0"
inputBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
inputBox.Text = ""
inputBox.TextSize = 14
inputBox.ClearTextOnFocus = false
inputBox.Font = Enum.Font.Gotham
inputBox.Parent = mainFrame

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(text, position, size, color)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.BackgroundTransparency = 0.2  -- Slightly transparent buttons
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = mainFrame
    return button
end

--==================================================
-- MAIN BUTTONS
--==================================================

local getPositionButton = createButton(
    "📍 Get Position",
    UDim2.fromOffset(16, 130),
    UDim2.fromOffset(137, 34),
    Color3.fromRGB(45, 115, 185)
)

local teleportButton = createButton(
    "🚀 Teleport",
    UDim2.fromOffset(167, 130),
    UDim2.fromOffset(137, 34),
    Color3.fromRGB(35, 165, 70)
)

--==================================================
-- UTILITY BUTTONS
--==================================================

local copyButton = createButton(
    "📋 Copy",
    UDim2.fromOffset(16, 170),
    UDim2.fromOffset(88, 28),
    Color3.fromRGB(50, 100, 145)
)

local resetButton = createButton(
    "🔄 Reset",
    UDim2.fromOffset(116, 170),
    UDim2.fromOffset(88, 28),
    Color3.fromRGB(145, 85, 35)
)

local clearButton = createButton(
    "🗑 Clear",
    UDim2.fromOffset(216, 170),
    UDim2.fromOffset(88, 28),
    Color3.fromRGB(145, 45, 45)
)

--==================================================
-- HISTORY
--==================================================

local historyLabel = Instance.new("TextLabel")
historyLabel.Size = UDim2.new(1, -32, 0, 18)
historyLabel.Position = UDim2.fromOffset(16, 202)
historyLabel.BackgroundTransparency = 1
historyLabel.Text = "📜 History:"
historyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
historyLabel.TextSize = 11
historyLabel.TextXAlignment = Enum.TextXAlignment.Left
historyLabel.Font = Enum.Font.Gotham
historyLabel.Parent = mainFrame

local historyFrame = Instance.new("Frame")
historyFrame.Size = UDim2.new(1, -32, 0, 28)
historyFrame.Position = UDim2.fromOffset(16, 220)
historyFrame.BackgroundTransparency = 1
historyFrame.Parent = mainFrame

local historyButtons = {}
for i = 1, CONFIG.MaxHistory do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1 / CONFIG.MaxHistory, -4, 1, 0)
    button.Position = UDim2.new((i - 1) / CONFIG.MaxHistory, 2, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(45, 85, 120)
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = ""
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 9
    button.Font = Enum.Font.Gotham
    button.Visible = false
    button.Parent = historyFrame
    historyButtons[i] = button
end

--==================================================
-- HISTORY DATA
--==================================================

local history = {}

local function updateHistory()
    for i = 1, CONFIG.MaxHistory do
        local button = historyButtons[i]
        if history[i] then
            button.Text = history[i]
            button.Visible = true
        else
            button.Text = ""
            button.Visible = false
        end
    end
end

local function addHistory(text)
    if not text or text == "" then return end
    for i, value in ipairs(history) do
        if value == text then
            table.remove(history, i)
            break
        end
    end
    table.insert(history, 1, text)
    while #history > CONFIG.MaxHistory do
        table.remove(history)
    end
    updateHistory()
end

--==================================================
-- PARSE COORDINATES
--==================================================

local function parseCoordinates(text)
    if not text or text == "" then return nil end
    text = text:gsub("%s+", "")
    local values = {}
    for value in string.gmatch(text, "[^,]+") do
        local number = tonumber(value)
        if not number then return nil end
        table.insert(values, number)
    end
    if #values ~= 3 then return nil end
    return Vector3.new(values[1], values[2], values[3])
end

--==================================================
-- GET POSITION
--==================================================

local function getPosition()
    local character = player.Character
    if not character then
        status("No character!", true)
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        status("No HumanoidRootPart!", true)
        return
    end
    local position = root.Position
    local text = string.format("%.1f, %.1f, %.1f", position.X, position.Y, position.Z)
    inputBox.Text = text
    addHistory(text)
    status("Position loaded!")
end

--==================================================
-- TELEPORT
--==================================================

local function teleport()
    local position = parseCoordinates(inputBox.Text)
    if not position then
        status("Invalid format! Use X, Y, Z", true)
        return
    end
    local character = player.Character
    if not character then
        status("No character!", true)
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        status("No HumanoidRootPart!", true)
        return
    end
    character:PivotTo(CFrame.new(position))
    addHistory(inputBox.Text)
    status("Teleported! ✅")
end

--==================================================
-- BUTTON EVENTS
--==================================================

getPositionButton.MouseButton1Click:Connect(getPosition)
teleportButton.MouseButton1Click:Connect(teleport)

resetButton.MouseButton1Click:Connect(function()
    inputBox.Text = ""
    status("Reset")
end)

clearButton.MouseButton1Click:Connect(function()
    inputBox.Text = ""
    table.clear(history)
    updateHistory()
    status("History cleared!")
end)

--==================================================
-- HISTORY EVENTS
--==================================================

for _, button in ipairs(historyButtons) do
    button.MouseButton1Click:Connect(function()
        if button.Text == "" then return end
        inputBox.Text = button.Text
        teleport()
    end)
end

--==================================================
-- ENTER KEY
--==================================================

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        teleport()
    end
end)

--==================================================
-- ICON
--==================================================

local icon = Instance.new("TextButton")
icon.Name = "TeleportIcon"
icon.Size = UDim2.fromOffset(CONFIG.IconSize, CONFIG.IconSize)
icon.Position = UDim2.new(0.02, 0, 0.5, -22)
icon.BackgroundColor3 = Color3.fromRGB(45, 115, 210)
icon.BackgroundTransparency = 0.1
icon.BorderColor3 = CONFIG.BorderColor
icon.BorderSizePixel = 2
icon.Text = "🚀"
icon.TextSize = 21
icon.TextColor3 = Color3.new(1, 1, 1)
icon.Font = Enum.Font.GothamBold
icon.Parent = screenGui

--==================================================
-- ICON DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition
local moved = false

icon.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    dragging = true
    moved = false
    dragStart = input.Position
    startPosition = icon.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    local delta = input.Position - dragStart
    if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
        moved = true
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local x = math.clamp(startPosition.X.Offset + delta.X, 0, viewport.X - CONFIG.IconSize)
    local y = math.clamp(startPosition.Y.Offset + delta.Y, 0, viewport.Y - CONFIG.IconSize)
    icon.Position = UDim2.fromOffset(x, y)
end)

icon.MouseButton1Click:Connect(function()
    if moved then return end
    mainFrame.Visible = not mainFrame.Visible
end)

--==================================================
-- KEYBOARD SHORTCUTS
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
    if not ctrl then return end
    if input.KeyCode == Enum.KeyCode.T then
        teleport()
    elseif input.KeyCode == Enum.KeyCode.G then
        getPosition()
    elseif input.KeyCode == Enum.KeyCode.R then
        inputBox.Text = ""
        status("Reset")
    elseif input.KeyCode == Enum.KeyCode.H then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

--==================================================
-- DRAG MAIN WINDOW
--==================================================

local windowDragging = false
local windowDragStart
local windowStartPosition

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    windowDragging = true
    windowDragStart = input.Position
    windowStartPosition = mainFrame.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            windowDragging = false
        end
    end)
end)

UserInputService.InputChanged:Connect(function(input)
    if not windowDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    local delta = input.Position - windowDragStart
    mainFrame.Position = UDim2.new(
        windowStartPosition.X.Scale,
        windowStartPosition.X.Offset + delta.X,
        windowStartPosition.Y.Scale,
        windowStartPosition.Y.Offset + delta.Y
    )
end)

print("🚀 Teleport GUI loaded (Transparent)")
print("Ctrl+G = Get Position")
print("Ctrl+T = Teleport")
print("Ctrl+R = Reset")
print("Ctrl+H = Toggle GUI")
