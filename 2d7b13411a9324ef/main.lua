-- Steal the Brainrot Base

--==================================================
-- LUCKY DROP TELEPORT GUI
--==================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--==================================================
-- PLAYER
--==================================================

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- GAME ID RESTRICTION
--==================================================

local TARGET_GAME_ID = 103050497819513

if game.PlaceId ~= TARGET_GAME_ID then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Wrong Game",
            Text = "This script only works in the designated game.",
            Duration = 5
        })
    end)

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
    BUTTON_YES_HOVER = Color3.fromRGB(70, 210, 100),

    BUTTON_NO = Color3.fromRGB(65, 65, 65),
    BUTTON_NO_HOVER = Color3.fromRGB(85, 85, 85),

    BUTTON_CLOSE = Color3.fromRGB(55, 55, 55),
    BUTTON_CLOSE_HOVER = Color3.fromRGB(80, 80, 80),

    DOT = Color3.fromRGB(70, 220, 100),

    TEXT = Color3.fromRGB(255, 255, 255),
    TEXT_DIM = Color3.fromRGB(190, 190, 190),

    BORDER = Color3.fromRGB(60, 60, 60),
    BORDER_LIGHT = Color3.fromRGB(80, 80, 80),
}

local SIZES = {
    ICON = 46,

    PANEL_WIDTH = 300,
    PANEL_HEIGHT = 150,

    CLOSE = 28,

    BUTTON_WIDTH = 115,
    BUTTON_HEIGHT = 38,
}

--==================================================
-- STATE
--==================================================

local state = {
    currentBase = nil,
    terminated = false,
    pendingTeleport = false,
    isPanelVisible = false,
}

--==================================================
-- CONNECTION REFERENCES
--==================================================

local notificationConnection = nil
local dragConnection = nil
local inputConnection = nil
local characterConnection = nil
local ancestryConnection = nil

--==================================================
-- CHARACTER CACHE
--==================================================

local cachedCharacter = nil
local cachedRoot = nil

local function invalidateCache()
    cachedCharacter = nil
    cachedRoot = nil
end

local function getRootPart()
    if state.terminated then
        return nil
    end

    if not cachedCharacter or not cachedCharacter.Parent then
        cachedCharacter = Player.Character
    end

    if not cachedCharacter then
        return nil
    end

    if not cachedRoot or not cachedRoot.Parent then
        cachedRoot = cachedCharacter:FindFirstChild("HumanoidRootPart")
    end

    return cachedRoot
end

--==================================================
-- CLEAN OLD GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("LuckyDropTeleport")

if oldGui then
    oldGui:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "LuckyDropTeleport"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999
Gui.Parent = PlayerGui

--==================================================
-- HELPERS
--==================================================

local function createCorner(instance, radius)
    local corner = Instance.new("UICorner")

    if type(radius) == "number" then
        corner.CornerRadius = UDim.new(0, radius)
    else
        corner.CornerRadius = radius
    end

    corner.Parent = instance

    return corner
end

--==================================================
-- DRAG SYSTEM
--==================================================

local function makeDraggable(object)

    local dragging = false
    local dragStart = nil
    local startPosition = nil

    local connection

    object.InputBegan:Connect(function(input)

        if state.terminated then
            return
        end

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

    connection = UserInputService.InputChanged:Connect(function(input)

        if state.terminated then
            return
        end

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

    return connection
end

--==================================================
-- ACTIVE CIRCULAR ICON
--==================================================

local Active = Instance.new("TextButton")

Active.Name = "Active"
Active.Size = UDim2.fromOffset(
    SIZES.ICON,
    SIZES.ICON
)

Active.Position = UDim2.fromOffset(20, 20)

Active.BackgroundColor3 = COLORS.BACKGROUND_ACTIVE
Active.BackgroundTransparency = 0

Active.BorderSizePixel = 1
Active.BorderColor3 = COLORS.BORDER_LIGHT

Active.Text = ""
Active.AutoButtonColor = false

Active.ZIndex = 20

Active.Parent = Gui

createCorner(Active, 999)

--==================================================
-- ICON GREEN DOT
--==================================================

local ActiveDot = Instance.new("Frame")

ActiveDot.Name = "Dot"

ActiveDot.Size = UDim2.fromOffset(12, 12)

ActiveDot.Position = UDim2.new(
    0.5,
    -6,
    0.5,
    -6
)

ActiveDot.BackgroundColor3 = COLORS.DOT
ActiveDot.BackgroundTransparency = 0

ActiveDot.BorderSizePixel = 0

ActiveDot.ZIndex = 21

ActiveDot.Parent = Active

createCorner(ActiveDot, 999)

--==================================================
-- DOT PULSE
--==================================================

local pulseTween = TweenService:Create(
    ActiveDot,

    TweenInfo.new(
        0.8,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        -1,
        true
    ),

    {
        Size = UDim2.fromOffset(16, 16),

        Position = UDim2.new(
            0.5,
            -8,
            0.5,
            -8
        )
    }
)

pulseTween:Play()

--==================================================
-- PROMPT PANEL
--==================================================

local Panel = Instance.new("Frame")

Panel.Name = "Prompt"

Panel.Size = UDim2.fromOffset(
    SIZES.PANEL_WIDTH,
    SIZES.PANEL_HEIGHT
)

Panel.Position = UDim2.new(
    0.5,
    -SIZES.PANEL_WIDTH / 2,
    0.5,
    -SIZES.PANEL_HEIGHT / 2
)

Panel.BackgroundColor3 = COLORS.BACKGROUND
Panel.BackgroundTransparency = 0

Panel.BorderSizePixel = 1
Panel.BorderColor3 = COLORS.BORDER

Panel.Visible = false
Panel.ClipsDescendants = true

Panel.ZIndex = 10

Panel.Parent = Gui

createCorner(Panel, 12)

--==================================================
-- CLOSE BUTTON
--==================================================

local Close = Instance.new("TextButton")

Close.Name = "Close"

Close.Size = UDim2.fromOffset(
    SIZES.CLOSE,
    SIZES.CLOSE
)

Close.Position = UDim2.new(
    1,
    -SIZES.CLOSE - 6,
    0,
    6
)

Close.BackgroundColor3 = COLORS.BUTTON_CLOSE

Close.BorderSizePixel = 0

Close.Text = "×"

Close.TextColor3 = COLORS.TEXT
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold

Close.AutoButtonColor = false

Close.ZIndex = 15

Close.Parent = Panel

createCorner(Close, 999)

--==================================================
-- CLOSE HOVER
--==================================================

Close.MouseEnter:Connect(function()

    if state.terminated then
        return
    end

    Close.BackgroundColor3 = COLORS.BUTTON_CLOSE_HOVER
end)

Close.MouseLeave:Connect(function()

    if state.terminated then
        return
    end

    Close.BackgroundColor3 = COLORS.BUTTON_CLOSE
end)

--==================================================
-- MESSAGE
--==================================================

local Message = Instance.new("TextLabel")

Message.Name = "Message"

Message.Size = UDim2.new(
    1,
    -55,
    0,
    55
)

Message.Position = UDim2.fromOffset(15, 15)

Message.BackgroundTransparency = 1

Message.Text = "Lucky Drop at Base"

Message.TextColor3 = COLORS.TEXT
Message.TextSize = 17

Message.Font = Enum.Font.GothamMedium

Message.TextWrapped = true

Message.ZIndex = 11

Message.Parent = Panel

--==================================================
-- QUESTION
--==================================================

local Question = Instance.new("TextLabel")

Question.Name = "Question"

Question.Size = UDim2.new(
    1,
    0,
    0,
    25
)

Question.Position = UDim2.fromOffset(0, 68)

Question.BackgroundTransparency = 1

Question.Text = "Teleport?"

Question.TextColor3 = COLORS.TEXT_DIM
Question.TextSize = 14

Question.Font = Enum.Font.Gotham

Question.ZIndex = 11

Question.Parent = Panel

--==================================================
-- YES BUTTON
--==================================================

local Yes = Instance.new("TextButton")

Yes.Name = "Yes"

Yes.Size = UDim2.fromOffset(
    SIZES.BUTTON_WIDTH,
    SIZES.BUTTON_HEIGHT
)

Yes.Position = UDim2.fromOffset(25, 105)

Yes.BackgroundColor3 = COLORS.BUTTON_YES

Yes.BorderSizePixel = 0

Yes.Text = "Yes"

Yes.TextColor3 = COLORS.TEXT
Yes.TextSize = 15

Yes.Font = Enum.Font.GothamMedium

Yes.AutoButtonColor = false

Yes.ZIndex = 12

Yes.Parent = Panel

createCorner(Yes, 8)

--==================================================
-- YES HOVER
--==================================================

Yes.MouseEnter:Connect(function()

    if state.terminated then
        return
    end

    Yes.BackgroundColor3 = COLORS.BUTTON_YES_HOVER
end)

Yes.MouseLeave:Connect(function()

    if state.terminated then
        return
    end

    Yes.BackgroundColor3 = COLORS.BUTTON_YES
end)

--==================================================
-- NO BUTTON
--==================================================

local No = Instance.new("TextButton")

No.Name = "No"

No.Size = UDim2.fromOffset(
    SIZES.BUTTON_WIDTH,
    SIZES.BUTTON_HEIGHT
)

No.Position = UDim2.fromOffset(
    SIZES.PANEL_WIDTH - SIZES.BUTTON_WIDTH - 25,
    105
)

No.BackgroundColor3 = COLORS.BUTTON_NO

No.BorderSizePixel = 0

No.Text = "No"

No.TextColor3 = COLORS.TEXT
No.TextSize = 15

No.Font = Enum.Font.GothamMedium

No.AutoButtonColor = false

No.ZIndex = 12

No.Parent = Panel

createCorner(No, 8)

--==================================================
-- NO HOVER
--==================================================

No.MouseEnter:Connect(function()

    if state.terminated then
        return
    end

    No.BackgroundColor3 = COLORS.BUTTON_NO_HOVER
end)

No.MouseLeave:Connect(function()

    if state.terminated then
        return
    end

    No.BackgroundColor3 = COLORS.BUTTON_NO
end)

--==================================================
-- PANEL FUNCTIONS
--==================================================

local function hidePanel()

    if state.terminated then
        return
    end

    state.currentBase = nil
    state.pendingTeleport = false
    state.isPanelVisible = false

    Panel.Visible = false
    Panel.BackgroundTransparency = 0
end

local function showPanel(baseName)

    if state.terminated then
        return
    end

    if not TELEPORTS[baseName] then
        return
    end

    state.currentBase = baseName
    state.pendingTeleport = true
    state.isPanelVisible = true

    Message.Text = "Lucky Drop at " .. baseName

    Panel.BackgroundTransparency = 1
    Panel.Visible = true

    local tween = TweenService:Create(
        Panel,

        TweenInfo.new(
            0.3,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),

        {
            BackgroundTransparency = 0
        }
    )

    tween:Play()
end

--==================================================
-- TELEPORT
--==================================================

local function teleportToBase(baseName)

    if state.terminated then
        return false
    end

    local position = TELEPORTS[baseName]

    if not position then

        warn(
            "[LuckyDrop] Base not found: "
            .. tostring(baseName)
        )

        return false
    end

    local root = getRootPart()

    if not root then

        warn(
            "[LuckyDrop] HumanoidRootPart not found"
        )

        return false
    end

    local success, err = pcall(function()

        root.CFrame = CFrame.new(position)

    end)

    if success then

        print(
            "🚀 Teleported to: "
            .. baseName
        )

        state.pendingTeleport = false

        state.currentBase = nil
        state.isPanelVisible = false

        Panel.Visible = false
        Panel.BackgroundTransparency = 0

        return true

    else

        warn(
            "[LuckyDrop] Teleport failed: "
            .. tostring(err)
        )

        return false
    end
end

--==================================================
-- ICON CLICK
--==================================================

Active.MouseButton1Click:Connect(function()

    if state.terminated then
        return
    end

    if Panel.Visible then

        hidePanel()

    elseif state.currentBase then

        showPanel(state.currentBase)

    end
end)

--==================================================
-- DRAG ICON
--==================================================

dragConnection = makeDraggable(Active)

--==================================================
-- BUTTON EVENTS
--==================================================

Yes.MouseButton1Click:Connect(function()

    if state.terminated then
        return
    end

    if not state.currentBase then
        return
    end

    teleportToBase(state.currentBase)
end)

No.MouseButton1Click:Connect(function()

    if state.terminated then
        return
    end

    hidePanel()
end)

--==================================================
-- TERMINATE
--==================================================

local function terminate()

    if state.terminated then
        return
    end

    state.terminated = true

    state.currentBase = nil
    state.pendingTeleport = false
    state.isPanelVisible = false

    -- Stop pulse
    pcall(function()
        pulseTween:Cancel()
    end)

    -- Disconnect notification
    if notificationConnection then

        notificationConnection:Disconnect()
        notificationConnection = nil

    end

    -- Disconnect drag
    if dragConnection then

        dragConnection:Disconnect()
        dragConnection = nil

    end

    -- Disconnect keyboard input
    if inputConnection then

        inputConnection:Disconnect()
        inputConnection = nil

    end

    -- Disconnect character handler
    if characterConnection then

        characterConnection:Disconnect()
        characterConnection = nil

    end

    -- Disconnect ancestry handler
    if ancestryConnection then

        ancestryConnection:Disconnect()
        ancestryConnection = nil

    end

    -- Destroy GUI
    if Gui and Gui.Parent then
        Gui:Destroy()
    end

    print("🛑 Lucky Drop Teleport GUI terminated")
end

--==================================================
-- X BUTTON
--==================================================

Close.MouseButton1Click:Connect(function()

    terminate()

end)

--==================================================
-- KEYBOARD SHORTCUTS
--==================================================

inputConnection = UserInputService.InputBegan:Connect(
    function(input, processed)

        if processed then
            return
        end

        if state.terminated then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        -- X = terminate
        if input.KeyCode == Enum.KeyCode.X then

            terminate()

            return
        end

        -- Y = Yes
        if input.KeyCode == Enum.KeyCode.Y then

            if state.isPanelVisible
                and state.currentBase then

                teleportToBase(state.currentBase)
            end

            return
        end

        -- N = No
        if input.KeyCode == Enum.KeyCode.N then

            if state.isPanelVisible then
                hidePanel()
            end

            return
        end

    end
)

--==================================================
-- NOTIFICATION DETECTION
--==================================================

local function setupNotificationDetection()

    if state.terminated then
        return
    end

    local Events = ReplicatedStorage:FindFirstChild("Events")

    if not Events then

        warn(
            "[LuckyDrop] Events folder not found"
        )

        return
    end

    local ShowNotification =
        Events:FindFirstChild("ShowNotification")

    if not ShowNotification then

        warn(
            "[LuckyDrop] ShowNotification event not found"
        )

        return
    end

    if not ShowNotification:IsA("RemoteEvent") then

        warn(
            "[LuckyDrop] ShowNotification is not a RemoteEvent"
        )

        return
    end

    notificationConnection =
        ShowNotification.OnClientEvent:Connect(
            function(message, color)

                if state.terminated then
                    return
                end

                if typeof(message) ~= "string" then
                    return
                end

                local foundBase = nil

                for baseName in pairs(TELEPORTS) do

                    if message:find(
                        baseName,
                        1,
                        true
                    ) then

                        foundBase = baseName
                        break
                    end
                end

                if foundBase then

                    showPanel(foundBase)

                    print(
                        "📢 Lucky Drop detected: "
                        .. foundBase
                    )

                end
            end
        )
end

--==================================================
-- START NOTIFICATION DETECTION
--==================================================

setupNotificationDetection()

--==================================================
-- CHARACTER RESPAWN
--==================================================

characterConnection =
    Player.CharacterAdded:Connect(
        function(character)

            if state.terminated then
                return
            end

            invalidateCache()

            cachedCharacter = character

            state.pendingTeleport = false

            if state.isPanelVisible then
                hidePanel()
            end
        end
    )

--==================================================
-- PLAYER REMOVAL
--==================================================

ancestryConnection =
    Player.AncestryChanged:Connect(
        function()

            if not Player.Parent then

                terminate()

            end
        end
    )

--==================================================
-- TELEPORT COUNT
--==================================================

local teleportCount = 0

for _ in pairs(TELEPORTS) do
    teleportCount += 1
end

--==================================================
-- DEBUG
--==================================================

print("==========================================")
print("✅ Lucky Drop Teleport GUI active")
print("📍 Game ID: " .. tostring(game.PlaceId))
print("📌 " .. teleportCount .. " teleport locations loaded")
print("🟢 Circular Active icon created")
print("🖱️ Drag the green icon to move it")
print("👆 Click the icon to show/hide the panel")
print("⌨️ X = terminate")
print("⌨️ Y = Yes / Teleport")
print("⌨️ N = No / Hide")
print("==========================================")

--==================================================
-- RETURN
--==================================================

return {
    Gui = Gui,

    terminate = terminate,

    teleportToBase = teleportToBase,

    getState = function()
        return state
    end,

    showPanel = showPanel,

    hidePanel = hidePanel,
}
