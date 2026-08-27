-- Steal the brainrot base

--==================================================
-- LUCKY DROP TELEPORT GUI
-- Optimized & Debugged | Functions Preserved
-- X button completely terminates the GUI
-- Game ID restricted
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- GAME ID RESTRICTION
--==================================================

local TARGET_GAME_ID = 1234567890  -- REPLACE WITH YOUR GAME ID

-- Check if running in the correct game
if game.PlaceId ~= TARGET_GAME_ID then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Wrong Game",
        Text = "This script only works in the designated game.",
        Duration = 5
    })
    return
end

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

local COLORS = {
    BACKGROUND = Color3.fromRGB(30, 30, 30),
    BACKGROUND_ACTIVE = Color3.fromRGB(35, 35, 35),
    BUTTON_YES = Color3.fromRGB(55, 180, 90),
    BUTTON_NO = Color3.fromRGB(65, 65, 65),
    BUTTON_CLOSE = Color3.fromRGB(55, 55, 55),
    DOT = Color3.fromRGB(70, 220, 100),
    TEXT = Color3.fromRGB(255, 255, 255),
    TEXT_DIM = Color3.fromRGB(190, 190, 190),
}

local SIZES = {
    ACTIVE = {105, 38},
    PANEL = {300, 150},
    DOT = {10, 10},
    CLOSE = {28, 28},
    BUTTON = {115, 38},
}

--==================================================
-- CLEAN OLD GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("LuckyDropTeleport")
if oldGui then
    oldGui:Destroy()
end

--==================================================
-- GUI CREATION
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "LuckyDropTeleport"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--==================================================
-- DRAG SYSTEM (Optimized)
--==================================================

local function makeDraggable(object)
    local dragging = false
    local dragStart = nil
    local startPosition = nil
    local dragConnection = nil
    
    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            
            dragging = true
            dragStart = input.Position
            startPosition = object.Position
        end
    end)
    
    object.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    dragConnection = UserInputService.InputChanged:Connect(function(input)
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
    
    return dragConnection
end

--==================================================
-- UI CREATION HELPERS (Optimized)
--==================================================

local function createCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = type(radius) == "number" and UDim.new(0, radius) or radius
    corner.Parent = instance
    return corner
end

local function createTextLabel(parent, name, props)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.TextColor3 = props.TextColor3 or COLORS.TEXT
    label.TextSize = props.TextSize or 15
    label.Font = props.Font or Enum.Font.GothamMedium
    label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
    label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    label.TextWrapped = props.TextWrapped or false
    label.ClipsDescendants = props.ClipsDescendants or false
    
    if props.Size then label.Size = props.Size end
    if props.Position then label.Position = props.Position end
    if props.Text then label.Text = props.Text end
    
    label.Parent = parent
    return label
end

local function createButton(parent, name, props)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = props.Size or UDim2.fromOffset(100, 30)
    button.BackgroundColor3 = props.BackgroundColor3 or COLORS.BUTTON_NO
    button.BorderSizePixel = 0
    button.Text = props.Text or ""
    button.TextColor3 = props.TextColor3 or COLORS.TEXT
    button.TextSize = props.TextSize or 15
    button.Font = props.Font or Enum.Font.GothamMedium
    button.AutoButtonColor = true
    button.BackgroundTransparency = props.BackgroundTransparency or 0
    
    if props.Position then button.Position = props.Position end
    
    if props.CornerRadius then
        createCorner(button, props.CornerRadius)
    end
    
    button.Parent = parent
    return button
end

--==================================================
-- ACTIVE INDICATOR (FIXED)
--==================================================

local Active = Instance.new("Frame")
Active.Name = "Active"
Active.Size = UDim2.fromOffset(SIZES.ACTIVE[1], SIZES.ACTIVE[2])
Active.Position = UDim2.fromOffset(20, 20)
Active.BackgroundColor3 = COLORS.BACKGROUND_ACTIVE
Active.BorderSizePixel = 1
Active.BorderColor3 = Color3.fromRGB(80, 80, 80)
Active.ClipsDescendants = true
Active.Active = true
Active.Parent = Gui

-- Corner for Active frame
local ActiveCorner = Instance.new("UICorner")
ActiveCorner.CornerRadius = UDim.new(1, 0)
ActiveCorner.Parent = Active

-- Active Dot (Green pulsing dot)
local ActiveDot = Instance.new("Frame")
ActiveDot.Name = "Dot"
ActiveDot.Size = UDim2.fromOffset(SIZES.DOT[1], SIZES.DOT[2])
ActiveDot.Position = UDim2.new(0, 13, 0.5, -SIZES.DOT[2]/2)
ActiveDot.BackgroundColor3 = COLORS.DOT
ActiveDot.BorderSizePixel = 0
ActiveDot.BackgroundTransparency = 0
ActiveDot.ClipsDescendants = true
ActiveDot.Parent = Active

-- Dot Corner
local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = ActiveDot

-- Pulse animation for dot
task.spawn(function()
    while Gui and Gui.Parent do
        if not ActiveDot or not ActiveDot.Parent then break end
        
        -- Pulse effect
        for i = 1, 20 do
            if not ActiveDot or not ActiveDot.Parent then break end
            local scale = 0.8 + (i / 20) * 0.4
            ActiveDot.Size = UDim2.fromOffset(SIZES.DOT[1] * scale, SIZES.DOT[2] * scale)
            ActiveDot.Position = UDim2.new(0, 13 - (SIZES.DOT[1] * (scale - 1) / 2), 0.5, -SIZES.DOT[2] * scale / 2)
            task.wait(0.02)
        end
        
        for i = 1, 20 do
            if not ActiveDot or not ActiveDot.Parent then break end
            local scale = 1.2 - (i / 20) * 0.4
            ActiveDot.Size = UDim2.fromOffset(SIZES.DOT[1] * scale, SIZES.DOT[2] * scale)
            ActiveDot.Position = UDim2.new(0, 13 - (SIZES.DOT[1] * (scale - 1) / 2), 0.5, -SIZES.DOT[2] * scale / 2)
            task.wait(0.02)
        end
    end
end)

-- Active Text Label
local ActiveText = Instance.new("TextLabel")
ActiveText.Name = "ActiveText"
ActiveText.Size = UDim2.new(1, -32, 1, 0)
ActiveText.Position = UDim2.fromOffset(30, 0)
ActiveText.BackgroundTransparency = 1
ActiveText.Text = "Active"
ActiveText.TextColor3 = COLORS.TEXT
ActiveText.TextSize = 15
ActiveText.Font = Enum.Font.GothamMedium
ActiveText.TextXAlignment = Enum.TextXAlignment.Left
ActiveText.TextYAlignment = Enum.TextYAlignment.Center
ActiveText.ClipsDescendants = false
ActiveText.Parent = Active

-- Make the Active indicator draggable
local dragConnection = makeDraggable(Active)

--==================================================
-- PROMPT PANEL
--==================================================

local Panel = Instance.new("Frame")
Panel.Name = "Prompt"
Panel.Size = UDim2.fromOffset(SIZES.PANEL[1], SIZES.PANEL[2])
Panel.Position = UDim2.new(0.5, -SIZES.PANEL[1]/2, 0.5, -SIZES.PANEL[2]/2)
Panel.BackgroundColor3 = COLORS.BACKGROUND
Panel.BorderSizePixel = 1
Panel.BorderColor3 = Color3.fromRGB(60, 60, 60)
Panel.Visible = false
Panel.ClipsDescendants = true
Panel.Active = true
Panel.Parent = Gui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

--==================================================
-- X CLOSE / TERMINATE BUTTON
--==================================================

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Size = UDim2.fromOffset(SIZES.CLOSE[1], SIZES.CLOSE[2])
Close.Position = UDim2.new(1, -SIZES.CLOSE[1] - 6, 0, 6)
Close.BackgroundColor3 = COLORS.BUTTON_CLOSE
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = COLORS.TEXT
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = true
Close.ClipsDescendants = true
Close.Parent = Panel

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = Close

--==================================================
-- MESSAGE
--==================================================

local Message = Instance.new("TextLabel")
Message.Name = "Message"
Message.Size = UDim2.new(1, -55, 0, 55)
Message.Position = UDim2.fromOffset(15, 15)
Message.BackgroundTransparency = 1
Message.Text = "Lucky Drop at Base"
Message.TextColor3 = COLORS.TEXT
Message.TextSize = 17
Message.Font = Enum.Font.GothamMedium
Message.TextWrapped = true
Message.ClipsDescendants = false
Message.Parent = Panel

--==================================================
-- QUESTION
--==================================================

local Question = Instance.new("TextLabel")
Question.Size = UDim2.new(1, 0, 0, 25)
Question.Position = UDim2.fromOffset(0, 68)
Question.BackgroundTransparency = 1
Question.Text = "Teleport?"
Question.TextColor3 = COLORS.TEXT_DIM
Question.TextSize = 14
Question.Font = Enum.Font.Gotham
Question.ClipsDescendants = false
Question.Parent = Panel

--==================================================
-- YES BUTTON
--==================================================

local Yes = Instance.new("TextButton")
Yes.Name = "Yes"
Yes.Size = UDim2.fromOffset(SIZES.BUTTON[1], SIZES.BUTTON[2])
Yes.Position = UDim2.fromOffset(25, 105)
Yes.BackgroundColor3 = COLORS.BUTTON_YES
Yes.BorderSizePixel = 0
Yes.Text = "Yes"
Yes.TextColor3 = COLORS.TEXT
Yes.TextSize = 15
Yes.Font = Enum.Font.GothamMedium
Yes.AutoButtonColor = true
Yes.ClipsDescendants = true
Yes.Parent = Panel

local YesCorner = Instance.new("UICorner")
YesCorner.CornerRadius = UDim.new(0, 8)
YesCorner.Parent = Yes

--==================================================
-- NO BUTTON
--==================================================

local No = Instance.new("TextButton")
No.Name = "No"
No.Size = UDim2.fromOffset(SIZES.BUTTON[1], SIZES.BUTTON[2])
No.Position = UDim2.fromOffset(SIZES.PANEL[1] - SIZES.BUTTON[1] - 25, 105)
No.BackgroundColor3 = COLORS.BUTTON_NO
No.BorderSizePixel = 0
No.Text = "No"
No.TextColor3 = COLORS.TEXT
No.TextSize = 15
No.Font = Enum.Font.GothamMedium
No.AutoButtonColor = true
No.ClipsDescendants = true
No.Parent = Panel

local NoCorner = Instance.new("UICorner")
NoCorner.CornerRadius = UDim.new(0, 8)
NoCorner.Parent = No

--==================================================
-- STATE
--==================================================

local state = {
    currentBase = nil,
    terminated = false,
    pendingTeleport = false,
}

--==================================================
-- CACHED CHARACTER REFERENCES (Optimization)
--==================================================

local cachedCharacter = nil
local cachedRoot = nil

local function invalidateCache()
    cachedCharacter = nil
    cachedRoot = nil
end

local function getRootPart()
    if not cachedCharacter or not cachedCharacter.Parent then
        cachedCharacter = Player.Character
    end
    
    if not cachedRoot or not cachedRoot.Parent then
        cachedRoot = cachedCharacter and cachedCharacter:FindFirstChild("HumanoidRootPart")
    end
    
    return cachedRoot
end

--==================================================
-- TELEPORT (Optimized)
--==================================================

local function teleportToBase(baseName)
    if state.terminated then return end
    
    local position = TELEPORTS[baseName]
    if not position then
        warn("Base not found: " .. baseName)
        return false
    end
    
    local root = getRootPart()
    if not root then
        warn("No HumanoidRootPart found")
        return false
    end
    
    -- Teleport with safety check
    root.CFrame = CFrame.new(position)
    print("🚀 Teleported to: " .. baseName)
    
    -- Visual feedback for panel
    state.pendingTeleport = false
    Panel.Visible = false
    
    return true
end

--==================================================
-- PANEL SHOW WITH ANIMATION
--==================================================

local function showPanel(baseName)
    if state.terminated then return end
    
    state.currentBase = baseName
    
    -- Update message
    if Message then
        Message.Text = "Lucky Drop at " .. baseName
    end
    
    -- Show with slight animation
    Panel.Visible = true
    Panel.BackgroundTransparency = 0.5
    
    -- Smooth fade in
    task.spawn(function()
        for i = 1, 10 do
            if state.terminated then break end
            Panel.BackgroundTransparency = 0.5 - (i * 0.05)
            task.wait(0.02)
        end
        Panel.BackgroundTransparency = 0
    end)
end

--==================================================
-- TERMINATE (Optimized)
--==================================================

local function terminate()
    if state.terminated then
        return
    end
    
    state.terminated = true
    state.currentBase = nil
    state.pendingTeleport = false
    
    -- Clean up notification connection
    if notificationConnection then
        notificationConnection:Disconnect()
        notificationConnection = nil
    end
    
    -- Clean up drag connection
    if dragConnection then
        dragConnection:Disconnect()
        dragConnection = nil
    end
    
    -- Remove GUI with cleanup
    if Gui and Gui.Parent then
        Gui:Destroy()
    end
    
    print("🛑 Lucky Drop Teleport GUI terminated")
end

--==================================================
-- BUTTON EVENTS
--==================================================

Yes.MouseButton1Click:Connect(function()
    if state.terminated or not state.currentBase then
        return
    end
    
    teleportToBase(state.currentBase)
end)

No.MouseButton1Click:Connect(function()
    if state.terminated then
        return
    end
    
    state.currentBase = nil
    state.pendingTeleport = false
    Panel.Visible = false
end)

-- X = FULL TERMINATION
Close.MouseButton1Click:Connect(function()
    terminate()
end)

--==================================================
-- KEYBOARD SHORTCUT
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or state.terminated then
        return
    end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.X then
            terminate()
        elseif input.KeyCode == Enum.KeyCode.Y and Panel.Visible then
            Yes.MouseButton1Click:Fire()
        elseif input.KeyCode == Enum.KeyCode.N and Panel.Visible then
            No.MouseButton1Click:Fire()
        end
    end
end)

--==================================================
-- NOTIFICATION DETECTION (Optimized)
--==================================================

local Events = ReplicatedStorage:WaitForChild("Events")
local ShowNotification = Events:WaitForChild("ShowNotification")

notificationConnection = ShowNotification.OnClientEvent:Connect(function(message, color)
    if state.terminated then
        return
    end
    
    if typeof(message) ~= "string" then
        return
    end
    
    -- Optimized: Check for base names with early exit
    local foundBase = nil
    for baseName in pairs(TELEPORTS) do
        if message:find(baseName, 1, true) then
            foundBase = baseName
            break
        end
    end
    
    if foundBase then
        showPanel(foundBase)
    end
end)

--==================================================
-- CHARACTER RESPAWN HANDLER
--==================================================

Player.CharacterAdded:Connect(function(character)
    invalidateCache()
    
    -- Reset pending teleport state
    if state.pendingTeleport then
        state.pendingTeleport = false
        Panel.Visible = false
    end
end)

--==================================================
-- GUI CLOSE ON RESPAWN
--==================================================

Player.CharacterAdded:Connect(function()
    if Panel then
        Panel.Visible = false
    end
end)

--==================================================
-- BETTER ERROR HANDLING
--==================================================

local function safeTeleport(baseName)
    local success, err = pcall(function()
        teleportToBase(baseName)
    end)
    
    if not success then
        warn("Teleport failed: " .. tostring(err))
        state.currentBase = nil
        Panel.Visible = false
    end
end

-- Override Yes button with safe teleport
Yes.MouseButton1Click:Connect(function()
    if state.terminated or not state.currentBase then
        return
    end
    
    safeTeleport(state.currentBase)
end)

--==================================================
-- CLEANUP ON PLAYER LEAVING
--==================================================

local function onPlayerRemoving()
    terminate()
end

-- Disconnect when player leaves
local playerRemovingConnection
playerRemovingConnection = Player.AncestryChanged:Connect(function()
    if not Player.Parent then
        playerRemovingConnection:Disconnect()
        terminate()
    end
end)

--==================================================
-- DEBUG INFO (Optional)
--==================================================

print("✅ Lucky Drop Teleport GUI active")
print("📍 Game ID: " .. game.PlaceId .. " (Verified)")
print("📌 " .. #TELEPORTS .. " teleport locations loaded")
print("⌨️ Press X to terminate, Y/N for Yes/No")

--==================================================
-- RETURN FUNCTIONS FOR EXTERNAL USE
--==================================================

return {
    Gui = Gui,
    terminate = terminate,
    teleportToBase = teleportToBase,
    getState = function() return state end,
}
