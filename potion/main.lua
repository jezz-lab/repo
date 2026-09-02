--catch and tame : potion only

--[[
    Auto Brew & Claim GUI
]]

print("[AUTO BREW] Script started.")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then
    warn("Waiting for LocalPlayer...")
    player = Players:WaitForChild("LocalPlayer")
end

print("[AUTO BREW] Player:", player.Name)

-- ========== CREATE GUI ==========

local toggleScreen = Instance.new("ScreenGui")
toggleScreen.Name = "ToggleGUI"
toggleScreen.ResetOnSpawn = false
toggleScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(0, 40, 0, 40)
toggleFrame.Position = UDim2.new(0, 10, 0, 10)
toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleFrame.BackgroundTransparency = 0.2
toggleFrame.BorderSizePixel = 2
toggleFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
toggleFrame.Parent = toggleScreen

local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://0"
toggleButton.Parent = toggleFrame

local toggleText = Instance.new("TextLabel")
toggleText.Size = UDim2.new(1, 0, 1, 0)
toggleText.BackgroundTransparency = 1
toggleText.Text = "⚗️"
toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleText.TextSize = 24
toggleText.Font = Enum.Font.GothamBold
toggleText.Parent = toggleButton

-- Main GUI – NOW VISIBLE BY DEFAULT
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoPotionGUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled = true  -- <-- opens automatically

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 445)
mainFrame.Position = UDim2.new(0, 60, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
mainFrame.Parent = screenGui

-- X button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -28, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BackgroundTransparency = 0.3
closeButton.BorderSizePixel = 1
closeButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.ZIndex = 2
closeButton.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚗️ Auto Brew & Claim"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 18
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local sep = Instance.new("Frame")
sep.Size = UDim2.new(0.9, 0, 0, 1)
sep.Position = UDim2.new(0.05, 0, 0, 30)
sep.BackgroundColor3 = Color3.fromRGB(100,100,120)
sep.BackgroundTransparency = 0.5
sep.Parent = mainFrame

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "CashLabel"
cashLabel.Size = UDim2.new(1, 0, 0, 25)
cashLabel.Position = UDim2.new(0, 0, 0, 35)
cashLabel.BackgroundTransparency = 1
cashLabel.Text = "💰 Cash: 0"
cashLabel.TextColor3 = Color3.fromRGB(255,215,0)
cashLabel.TextSize = 14
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Font = Enum.Font.Gotham
cashLabel.Parent = mainFrame

local potionCountLabel = Instance.new("TextLabel")
potionCountLabel.Name = "PotionCountLabel"
potionCountLabel.Size = UDim2.new(1, 0, 0, 25)
potionCountLabel.Position = UDim2.new(0, 0, 0, 60)
potionCountLabel.BackgroundTransparency = 1
potionCountLabel.Text = "🧪 Potions: 0/3 req."
potionCountLabel.TextColor3 = Color3.fromRGB(150,200,255)
potionCountLabel.TextSize = 13
potionCountLabel.TextXAlignment = Enum.TextXAlignment.Left
potionCountLabel.Font = Enum.Font.Gotham
potionCountLabel.Parent = mainFrame

local enableFrame = Instance.new("Frame")
enableFrame.Size = UDim2.new(1, 0, 0, 30)
enableFrame.Position = UDim2.new(0, 0, 0, 85)
enableFrame.BackgroundTransparency = 1
enableFrame.Parent = mainFrame

local enableLabel = Instance.new("TextLabel")
enableLabel.Size = UDim2.new(0.6, 0, 1, 0)
enableLabel.Position = UDim2.new(0, 10, 0, 0)
enableLabel.BackgroundTransparency = 1
enableLabel.Text = "Auto Brew & Claim"
enableLabel.TextColor3 = Color3.fromRGB(255,255,255)
enableLabel.TextSize = 14
enableLabel.TextXAlignment = Enum.TextXAlignment.Left
enableLabel.Font = Enum.Font.Gotham
enableLabel.Parent = enableFrame

local enableCheckbox = Instance.new("ImageButton")
enableCheckbox.Name = "EnableCheckbox"
enableCheckbox.Size = UDim2.new(0, 20, 0, 20)
enableCheckbox.Position = UDim2.new(0.85, 0, 0.15, 0)
enableCheckbox.BackgroundColor3 = Color3.fromRGB(60,60,80)
enableCheckbox.BorderSizePixel = 1
enableCheckbox.BorderColor3 = Color3.fromRGB(100,100,120)
enableCheckbox.Image = "rbxassetid://0"
enableCheckbox.Parent = enableFrame

local enableCheckmark = Instance.new("ImageLabel")
enableCheckmark.Size = UDim2.new(0.8, 0, 0.8, 0)
enableCheckmark.Position = UDim2.new(0.1, 0, 0.1, 0)
enableCheckmark.BackgroundTransparency = 1
enableCheckmark.Image = "rbxassetid://0"
enableCheckmark.Visible = false
enableCheckmark.Parent = enableCheckbox

local statusLine = Instance.new("TextLabel")
statusLine.Name = "StatusLine"
statusLine.Size = UDim2.new(1, 0, 0, 25)
statusLine.Position = UDim2.new(0, 0, 0, 410)
statusLine.BackgroundTransparency = 1
statusLine.Text = "🟢 Script is running"   -- <-- visible message
statusLine.TextColor3 = Color3.fromRGB(100,255,100)
statusLine.TextSize = 13
statusLine.TextXAlignment = Enum.TextXAlignment.Left
statusLine.Font = Enum.Font.Gotham
statusLine.Parent = mainFrame

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, 0, 0, 30)
timerLabel.Position = UDim2.new(0, 0, 0, 375)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "⏱️ Brewing: 0:00 / 0:00"
timerLabel.TextColor3 = Color3.fromRGB(200,200,200)
timerLabel.TextSize = 14
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Font = Enum.Font.Gotham
timerLabel.Parent = mainFrame

-- ========== INSERT GUI ==========

local playerGui = player:WaitForChild("PlayerGui")
toggleScreen.Parent = playerGui
screenGui.Parent = playerGui

print("[AUTO BREW] GUI inserted – main panel is now visible.")

-- ========== UI LOGIC ==========

local autoEnabled = false
local guiVisible = true   -- because it's enabled

-- Toggle GUI on icon click
toggleButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    screenGui.Enabled = guiVisible
    print("[AUTO BREW] GUI visibility:", guiVisible)
end)

-- Enable/disable toggle (demo)
enableCheckbox.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    enableCheckmark.Visible = autoEnabled
    if autoEnabled then
        statusLine.Text = "🟢 Auto Brew ENABLED"
        statusLine.TextColor3 = Color3.fromRGB(100,255,100)
    else
        statusLine.Text = "🔴 Auto Brew DISABLED"
        statusLine.TextColor3 = Color3.fromRGB(255,100,100)
    end
    print("[AUTO BREW] Auto enabled:", autoEnabled)
end)

-- X button – terminate
closeButton.MouseButton1Click:Connect(function()
    autoEnabled = false
    enableCheckmark.Visible = false
    enableCheckbox.BackgroundColor3 = Color3.fromRGB(60,60,80)
    statusLine.Text = "⏹️ Script terminated (X)"
    statusLine.TextColor3 = Color3.fromRGB(255,100,100)
    timerLabel.Text = "⏱️ Terminated"
    timerLabel.TextColor3 = Color3.fromRGB(255,100,100)
    print("[AUTO BREW] Terminated by X button.")
end)

-- ========== DRAG FUNCTIONALITY ==========

do
    local dragging, dragInput, dragStart, startPos
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = toggleFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    toggleFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            toggleFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                             startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

do
    local dragging, dragInput, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                           startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

print("[AUTO BREW] Ready. Click the ✕ button to stop.")
