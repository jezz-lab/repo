--[[
    TELEPORT GUI
    Fixed version

    Fixes:
    - RBXScriptSignal:Fire() errors
    - Better executor detection
    - Better icon dragging
    - Better viewport detection
    - Shared functions for buttons / keyboard / history
    - Clipboard availability check
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

if not player then
    player = Players.PlayerAdded:Wait()
end

-- ==================================================
-- CONFIG
-- ==================================================

local GUI_CONFIG = {
    WindowWidth = 320,
    WindowHeight = 240,

    WindowPositionX = 0.5,
    WindowPositionY = 0.5,

    IconSize = 45,
    IconPositionX = 0.02,
    IconPositionY = 0.5,

    BackgroundColor = Color3.new(0.12, 0.12, 0.15),
    BackgroundTransparency = 0.05,

    BorderColor = Color3.new(0.3, 0.7, 1),
    BorderSize = 2,

    TitleBarColor = Color3.new(0.2, 0.2, 0.25),
    TitleBarTransparency = 0.3,

    TitleText = "🚀 Teleport System",
    GetPosButtonText = "📍 Get Position",
    TeleportButtonText = "🚀 Teleport",
    CopyButtonText = "📋 Copy",
    ResetButtonText = "🔄 Reset",
    ClearButtonText = "🗑️ Clear",

    InputLabelText = "📍 Coordinates (X, Y, Z):",
    InputPlaceholder = "0, 10, 0",

    StatusText = "● Ready",
    HistoryLabelText = "📜 History (click to reuse):",
}

local W = GUI_CONFIG.WindowWidth
local H = GUI_CONFIG.WindowHeight

local DIMENSIONS = {
    TitleBarHeight = H * 0.15,
    TitleSize = W * 0.055,

    CloseButtonSize = W * 0.11,

    StatusBarHeight = H * 0.10,
    StatusSize = W * 0.04,

    InputLabelSize = W * 0.04,
    InputFieldHeight = H * 0.14,
    InputTextSize = W * 0.045,

    InputBorderSize = 1,

    ButtonHeight = H * 0.15,
    ButtonTextSize = W * 0.04,

    UtilityHeight = H * 0.13,
    UtilityTextSize = W * 0.038,

    HistoryLabelSize = W * 0.035,
    HistoryHeight = H * 0.09,
    HistoryTextSize = W * 0.03,

    HistoryMaxEntries = 5,

    PaddingHorizontal = 0.05,

    InputLabelOffset = 0.28,
    InputOffset = 0.34,
    ActionButtonsOffset = 0.52,
    UtilityOffset = 0.70,
    HistoryLabelOffset = 0.85,
    HistoryOffset = 0.91,
}

-- ==================================================
-- EXECUTOR DETECTION
-- ==================================================

local executorName = "Unknown"

pcall(function()
    if typeof(identifyexecutor) == "function" then
        executorName = identifyexecutor()
    elseif typeof(getexecutorname) == "function" then
        executorName = getexecutorname()
    end
end)

-- ==================================================
-- CREATE GUI
-- ==================================================

local function createTeleportGUI()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local playerGui = player:WaitForChild("PlayerGui")
    screenGui.Parent = playerGui

    -- ==================================================
    -- ICON
    -- ==================================================

    local dragIcon = Instance.new("ImageButton")

    dragIcon.Name = "TeleportIcon"
    dragIcon.Size = UDim2.fromOffset(
        GUI_CONFIG.IconSize,
        GUI_CONFIG.IconSize
    )

    dragIcon.Position = UDim2.new(
        GUI_CONFIG.IconPositionX,
        0,
        GUI_CONFIG.IconPositionY,
        -GUI_CONFIG.IconSize / 2
    )

    dragIcon.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    dragIcon.BackgroundTransparency = 0.1
    dragIcon.BorderSizePixel = 2
    dragIcon.BorderColor3 = Color3.new(0.3, 0.7, 1)

    dragIcon.Image = "rbxassetid://6031094675"
    dragIcon.ImageColor3 = Color3.new(1, 1, 1)

    dragIcon.ScaleType = Enum.ScaleType.Fit
    dragIcon.ZIndex = 10
    dragIcon.AutoButtonColor = true

    dragIcon.Parent = screenGui

    -- Glow
    local glow = Instance.new("Frame")

    glow.Size = UDim2.new(1.2, 0, 1.2, 0)
    glow.Position = UDim2.new(-0.1, 0, -0.1, 0)

    glow.BackgroundColor3 = Color3.new(0.3, 0.7, 1)
    glow.BackgroundTransparency = 0.5
    glow.BorderSizePixel = 0

    glow.Active = false
    glow.ZIndex = 9

    glow.Parent = dragIcon

    -- Label
    local iconLabel = Instance.new("TextLabel")

    iconLabel.Size = UDim2.new(1, 0, 0, 16)
    iconLabel.Position = UDim2.new(0, 0, 1, 5)

    iconLabel.Text = "TP"
    iconLabel.TextColor3 = Color3.new(1, 1, 1)
    iconLabel.TextSize = 10

    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold

    iconLabel.Active = false
    iconLabel.ZIndex = 11

    iconLabel.Parent = dragIcon

    -- ==================================================
    -- ICON DRAGGING
    -- ==================================================

    local draggingIcon = false
    local dragStart = nil
    local startPosition = nil
    local dragMoved = false

    dragIcon.InputBegan:Connect(function(input)

        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        draggingIcon = true
        dragMoved = false

        dragStart = input.Position
        startPosition = dragIcon.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                draggingIcon = false
            end

        end)

    end)

    UserInputService.InputChanged:Connect(function(input)

        if not draggingIcon then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            dragMoved = true
        end

        local camera = workspace.CurrentCamera

        if not camera then
            return
        end

        local viewport = camera.ViewportSize

        local newX = startPosition.X.Offset + delta.X
        local newY = startPosition.Y.Offset + delta.Y

        newX = math.clamp(
            newX,
            0,
            viewport.X - GUI_CONFIG.IconSize
        )

        newY = math.clamp(
            newY,
            0,
            viewport.Y - GUI_CONFIG.IconSize
        )

        dragIcon.Position = UDim2.fromOffset(newX, newY)

    end)

    -- ==================================================
    -- MAIN FRAME
    -- ==================================================

    local mainFrame = Instance.new("Frame")

    mainFrame.Name = "MainFrame"

    mainFrame.Size = UDim2.fromOffset(W, H)

    mainFrame.Position = UDim2.new(
        GUI_CONFIG.WindowPositionX,
        -W / 2,
        GUI_CONFIG.WindowPositionY,
        -H / 2
    )

    mainFrame.BackgroundColor3 = GUI_CONFIG.BackgroundColor
    mainFrame.BackgroundTransparency = GUI_CONFIG.BackgroundTransparency

    mainFrame.BorderSizePixel = GUI_CONFIG.BorderSize
    mainFrame.BorderColor3 = GUI_CONFIG.BorderColor

    mainFrame.Active = true
    mainFrame.ClipsDescendants = true

    mainFrame.Visible = true
    mainFrame.ZIndex = 1

    mainFrame.Parent = screenGui

    -- ==================================================
    -- TITLE BAR
    -- ==================================================

    local titleBar = Instance.new("Frame")

    titleBar.Size = UDim2.new(
        1,
        0,
        0,
        DIMENSIONS.TitleBarHeight
    )

    titleBar.BackgroundColor3 = GUI_CONFIG.TitleBarColor
    titleBar.BackgroundTransparency = GUI_CONFIG.TitleBarTransparency

    titleBar.BorderSizePixel = 0

    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")

    titleLabel.Size = UDim2.new(0.85, 0, 1, 0)
    titleLabel.Position = UDim2.fromOffset(10, 0)

    titleLabel.Text = GUI_CONFIG.TitleText

    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = DIMENSIONS.TitleSize

    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold

    titleLabel.Parent = titleBar

    -- Close
    local closeBtn = Instance.new("TextButton")

    closeBtn.Size = UDim2.fromOffset(
        DIMENSIONS.CloseButtonSize,
        DIMENSIONS.TitleBarHeight
    )

    closeBtn.Position = UDim2.new(
        1,
        -DIMENSIONS.CloseButtonSize,
        0,
        0
    )

    closeBtn.Text = "✕"

    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = DIMENSIONS.TitleSize + 2

    closeBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeBtn.BackgroundTransparency = 0.2

    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.Gotham

    closeBtn.Parent = titleBar

    -- ==================================================
    -- STATUS
    -- ==================================================

    local statusBar = Instance.new("Frame")

    statusBar.Size = UDim2.new(
        1,
        0,
        0,
        DIMENSIONS.StatusBarHeight
    )

    statusBar.Position = UDim2.new(
        0,
        0,
        0,
        DIMENSIONS.TitleBarHeight
    )

    statusBar.BackgroundColor3 = Color3.new(0.08, 0.08, 0.1)
    statusBar.BorderSizePixel = 0

    statusBar.Parent = mainFrame

    local statusLabel = Instance.new("TextLabel")

    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.fromOffset(10, 0)

    statusLabel.Text = GUI_CONFIG.StatusText

    statusLabel.TextColor3 = Color3.new(0.5, 1, 0.5)
    statusLabel.TextSize = DIMENSIONS.StatusSize

    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham

    statusLabel.Parent = statusBar

    -- ==================================================
    -- INPUT LABEL
    -- ==================================================

    local inputLabel = Instance.new("TextLabel")

    inputLabel.Size = UDim2.new(
        0.9,
        0,
        0,
        DIMENSIONS.InputFieldHeight * 0.5
    )

    inputLabel.Position = UDim2.new(
        DIMENSIONS.PaddingHorizontal,
        0,
        DIMENSIONS.InputLabelOffset,
        0
    )

    inputLabel.Text = GUI_CONFIG.InputLabelText

    inputLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    inputLabel.TextSize = DIMENSIONS.InputLabelSize

    inputLabel.TextXAlignment = Enum.TextXAlignment.Left

    inputLabel.BackgroundTransparency = 1
    inputLabel.Font = Enum.Font.Gotham

    inputLabel.Parent = mainFrame

    -- ==================================================
    -- INPUT
    -- ==================================================

    local inputField = Instance.new("TextBox")

    inputField.Size = UDim2.new(
        0.9,
        0,
        0,
        DIMENSIONS.InputFieldHeight
    )

    inputField.Position = UDim2.new(
        DIMENSIONS.PaddingHorizontal,
        0,
        DIMENSIONS.InputOffset,
        0
    )

    inputField.PlaceholderText = GUI_CONFIG.InputPlaceholder
    inputField.Text = ""

    inputField.TextColor3 = Color3.new(1, 1, 1)
    inputField.TextSize = DIMENSIONS.InputTextSize

    inputField.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
    inputField.BackgroundTransparency = 0.3

    inputField.BorderSizePixel = 1
    inputField.BorderColor3 = Color3.new(0.3, 0.3, 0.4)

    inputField.ClearTextOnFocus = false
    inputField.Font = Enum.Font.Gotham

    inputField.Parent = mainFrame

    -- ==================================================
    -- ACTION BUTTONS
    -- ==================================================

    local getPosBtn = Instance.new("TextButton")

    getPosBtn.Size = UDim2.new(
        0.43,
        0,
        0,
        DIMENSIONS.ButtonHeight
    )

    getPosBtn.Position = UDim2.new(
        DIMENSIONS.PaddingHorizontal,
        0,
        DIMENSIONS.ActionButtonsOffset,
        0
    )

    getPosBtn.Text = GUI_CONFIG.GetPosButtonText

    getPosBtn.TextColor3 = Color3.new(1, 1, 1)
    getPosBtn.TextSize = DIMENSIONS.ButtonTextSize

    getPosBtn.BackgroundColor3 = Color3.new(0.2, 0.5, 0.8)
    getPosBtn.BackgroundTransparency = 0.2

    getPosBtn.BorderSizePixel = 0
    getPosBtn.Font = Enum.Font.GothamBold

    getPosBtn.Parent = mainFrame

    local tpBtn = Instance.new("TextButton")

    tpBtn.Size = UDim2.new(
        0.43,
        0,
        0,
        DIMENSIONS.ButtonHeight
    )

    tpBtn.Position = UDim2.new(
        0.52,
        0,
        DIMENSIONS.ActionButtonsOffset,
        0
    )

    tpBtn.Text = GUI_CONFIG.TeleportButtonText

    tpBtn.TextColor3 = Color3.new(1, 1, 1)
    tpBtn.TextSize = DIMENSIONS.ButtonTextSize

    tpBtn.BackgroundColor3 = Color3.new(0.1, 0.8, 0.2)
    tpBtn.BackgroundTransparency = 0.2

    tpBtn.BorderSizePixel = 0
    tpBtn.Font = Enum.Font.GothamBold

    tpBtn.Parent = mainFrame

    -- ==================================================
    -- UTILITY FRAME
    -- ==================================================

    local utilFrame = Instance.new("Frame")

    utilFrame.Size = UDim2.new(
        0.9,
        0,
        0,
        DIMENSIONS.UtilityHeight
    )

    utilFrame.Position = UDim2.new(
        DIMENSIONS.PaddingHorizontal,
        0,
        DIMENSIONS.UtilityOffset,
        0
    )

    utilFrame.BackgroundTransparency = 1
    utilFrame.Parent = mainFrame

    local function createUtilityButton(text, position, color)

        local button = Instance.new("TextButton")

        button.Size = UDim2.new(
            0.3,
            -3,
            1,
            0
        )

        button.Position = position

        button.Text = text

        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = DIMENSIONS.UtilityTextSize

        button.BackgroundColor3 = color
        button.BackgroundTransparency = 0.3

        button.BorderSizePixel = 0
        button.Font = Enum.Font.Gotham

        button.Parent = utilFrame

        return button
    end

    local copyBtn = createUtilityButton(
        GUI_CONFIG.CopyButtonText,
        UDim2.new(0, 0, 0, 0),
        Color3.new(0.2, 0.4, 0.6)
    )

    local resetBtn = createUtilityButton(
        GUI_CONFIG.ResetButtonText,
        UDim2.new(0.34, 0, 0, 0),
        Color3.new(0.6, 0.3, 0.1)
    )

    local clearBtn = createUtilityButton(
        GUI_CONFIG.ClearButtonText,
        UDim2.new(0.68, 0, 0, 0),
        Color3.new(0.6, 0.1, 0.1)
    )

    -- ==================================================
    -- HISTORY
    -- ==================================================

    local historyLabel = Instance.new("TextLabel")

    historyLabel.Size = UDim2.new(
        0.9,
        0,
        0,
        DIMENSIONS.HistoryHeight * 0.6
    )

    historyLabel.Position = UDim2.new(
        DIMENSIONS.PaddingHorizontal,
        0,
        DIMENSIONS.HistoryLabelOffset,
        0
    )

    historyLabel.Text = GUI_CONFIG.HistoryLabelText

    historyLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    historyLabel.TextSize = DIMENSIONS.HistoryLabelSize

    historyLabel.TextXAlignment = Enum.TextXAlignment.Left

    historyLabel.BackgroundTransparency = 1
    historyLabel.Font = Enum.Font.Gotham

    historyLabel.Parent = mainFrame

    local historyFrame = Instance.new("Frame")

    historyFrame.Size = UDim2.new(
        0.9,
        0,
        0,
        DIMENSIONS.HistoryHeight
    )

    historyFrame.Position = UDim2.new(
        DIMENSIONS.PaddingHorizontal,
        0,
        DIMENSIONS.HistoryOffset,
        0
    )

    historyFrame.BackgroundTransparency = 1
    historyFrame.Parent = mainFrame

    local historyButtons = {}

    for i = 1, DIMENSIONS.HistoryMaxEntries do

        local btn = Instance.new("TextButton")

        local spacing = 1 / DIMENSIONS.HistoryMaxEntries

        btn.Size = UDim2.new(
            spacing - 0.02,
            0,
            1,
            0
        )

        btn.Position = UDim2.new(
            (i - 1) * spacing + 0.01,
            0,
            0,
            0
        )

        btn.Text = ""

        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = DIMENSIONS.HistoryTextSize

        btn.BackgroundColor3 = Color3.new(0.2, 0.4, 0.6)
        btn.BackgroundTransparency = 0.3

        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham

        btn.Visible = false

        btn.Parent = historyFrame

        historyButtons[i] = btn
    end

    -- ==================================================
    -- RETURN
    -- ==================================================

    return {
        ScreenGui = screenGui,

        DragIcon = dragIcon,
        MainFrame = mainFrame,

        StatusLabel = statusLabel,
        StatusBar = statusBar,

        InputField = inputField,

        GetPosBtn = getPosBtn,
        TpBtn = tpBtn,

        CopyBtn = copyBtn,
        ResetBtn = resetBtn,
        ClearBtn = clearBtn,

        HistoryButtons = historyButtons,

        TitleBar = titleBar,
        CloseBtn = closeBtn,
    },

    -- Needed for distinguishing click from drag
    function()
        return dragMoved
    end
end

-- ==================================================
-- CREATE
-- ==================================================

local gui
local getIconDragged

local success, err = pcall(function()

    gui, getIconDragged = createTeleportGUI()

end)

if not success then
    warn("Teleport GUI creation failed:", err)
    return
end

-- ==================================================
-- STATE
-- ==================================================

local history = {}

-- ==================================================
-- STATUS
-- ==================================================

local function updateStatus(message, isError)

    gui.StatusLabel.Text = "● " .. message

    if isError then
        gui.StatusLabel.TextColor3 =
            Color3.new(1, 0.2, 0.2)
    else
        gui.StatusLabel.TextColor3 =
            Color3.new(0.5, 1, 0.5)
    end

    task.delay(3, function()

        if not gui.StatusLabel.Parent then
            return
        end

        gui.StatusLabel.Text =
            GUI_CONFIG.StatusText

        gui.StatusLabel.TextColor3 =
            Color3.new(0.5, 1, 0.5)

    end)
end

-- ==================================================
-- PARSE COORDINATES
-- ==================================================

local function parseCoords(text)

    if not text or text == "" then
        return nil
    end

    text = text:gsub("%s+", "")

    local parts = {}

    for part in string.gmatch(text, "[^,]+") do

        local number = tonumber(part)

        if number == nil then
            return nil
        end

        table.insert(parts, number)
    end

    if #parts ~= 3 then
        return nil
    end

    return Vector3.new(
        parts[1],
        parts[2],
        parts[3]
    )
end

-- ==================================================
-- HISTORY DISPLAY
-- ==================================================

local function updateHistory()

    for i = 1, DIMENSIONS.HistoryMaxEntries do

        local button = gui.HistoryButtons[i]

        if history[i] then

            button.Text = history[i]
            button.Visible = true

        else

            button.Text = ""
            button.Visible = false

        end
    end
end

local function addToHistory(text)

    if not text or text == "" then
        return
    end

    for i, value in ipairs(history) do

        if value == text then

            table.remove(history, i)
            break

        end
    end

    table.insert(history, 1, text)

    while #history > DIMENSIONS.HistoryMaxEntries do
        table.remove(history)
    end

    updateHistory()
end

-- ==================================================
-- GET POSITION
-- ==================================================

local function getPosition()

    local character = player.Character

    if not character then

        updateStatus(
            "No character!",
            true
        )

        return
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root then

        updateStatus(
            "No root part!",
            true
        )

        return
    end

    local pos = root.Position

    local formatted = string.format(
        "%.1f, %.1f, %.1f",
        pos.X,
        pos.Y,
        pos.Z
    )

    gui.InputField.Text = formatted

    addToHistory(formatted)

    updateStatus(
        "Position copied!",
        false
    )
end

-- ==================================================
-- TELEPORT
-- ==================================================

local function teleport()

    local pos = parseCoords(
        gui.InputField.Text
    )

    if not pos then

        updateStatus(
            "Invalid format! Use: X, Y, Z",
            true
        )

        return
    end

    local character = player.Character

    if not character then

        updateStatus(
            "No character!",
            true
        )

        return
    end

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root then

        updateStatus(
            "No root part!",
            true
        )

        return
    end

    local success, teleportError =
        pcall(function()

            character:PivotTo(
                CFrame.new(pos)
            )

        end)

    if not success then

        updateStatus(
            "Failed: " .. tostring(teleportError),
            true
        )

        return
    end

    addToHistory(
        gui.InputField.Text
    )

    updateStatus(
        "Teleported! ✅",
        false
    )
end

-- ==================================================
-- BUTTONS
-- ==================================================

gui.GetPosBtn.MouseButton1Click:Connect(
    getPosition
)

gui.TpBtn.MouseButton1Click:Connect(
    teleport
)

gui.CloseBtn.MouseButton1Click:Connect(
    function()
        gui.MainFrame.Visible = false
    end
)

-- ==================================================
-- HISTORY BUTTONS
-- ==================================================

for i, button in ipairs(gui.HistoryButtons) do

    button.MouseButton1Click:Connect(
        function()

            if button.Text == "" then
                return
            end

            gui.InputField.Text = button.Text

            teleport()

        end
    )

end

-- ==================================================
-- COPY
-- ==================================================

gui.CopyBtn.MouseButton1Click:Connect(
    function()

        local text = gui.InputField.Text

        if text == "" then

            updateStatus(
                "Nothing to copy!",
                true
            )

            return
        end

        local copied = false

        if typeof(setclipboard) == "function" then

            copied = pcall(
                setclipboard,
                text
            )

        elseif typeof(toclipboard) == "function" then

            copied = pcall(
                toclipboard,
                text
            )

        end

        if copied then

            updateStatus(
                "Copied to clipboard! 📋",
                false
            )

        else

            updateStatus(
                "Clipboard unavailable!",
                true
            )

        end
    end
)

-- ==================================================
-- RESET
-- ==================================================

gui.ResetBtn.MouseButton1Click:Connect(
    function()

        gui.InputField.Text = ""

        updateStatus(
            "Reset",
            false
        )

    end
)

-- ==================================================
-- CLEAR
-- ==================================================

gui.ClearBtn.MouseButton1Click:Connect(
    function()

        gui.InputField.Text = ""

        table.clear(history)

        updateHistory()

        updateStatus(
            "History cleared! 🗑️",
            false
        )

    end
)

-- ==================================================
-- ENTER KEY
-- ==================================================

gui.InputField.FocusLost:Connect(
    function(enterPressed)

        if enterPressed then
            teleport()
        end

    end
)

-- ==================================================
-- ICON TOGGLE
-- ==================================================

gui.DragIcon.MouseButton1Click:Connect(
    function()

        -- Ignore the click if the user actually dragged
        if getIconDragged() then
            return
        end

        gui.MainFrame.Visible =
            not gui.MainFrame.Visible

    end
)

-- ==================================================
-- KEYBOARD SHORTCUTS
-- ==================================================

UserInputService.InputBegan:Connect(
    function(input, gameProcessed)

        if gameProcessed then
            return
        end

        local ctrlDown =
            UserInputService:IsKeyDown(
                Enum.KeyCode.LeftControl
            )
            or
            UserInputService:IsKeyDown(
                Enum.KeyCode.RightControl
            )

        if not ctrlDown then
            return
        end

        if input.KeyCode == Enum.KeyCode.T then

            teleport()

        elseif input.KeyCode == Enum.KeyCode.G then

            getPosition()

        elseif input.KeyCode == Enum.KeyCode.C then

            local text = gui.InputField.Text

            if text ~= "" then

                if typeof(setclipboard) == "function" then
                    pcall(setclipboard, text)

                elseif typeof(toclipboard) == "function" then
                    pcall(toclipboard, text)

                end

            end

        elseif input.KeyCode == Enum.KeyCode.R then

            gui.InputField.Text = ""

            updateStatus(
                "Reset",
                false
            )

        elseif input.KeyCode == Enum.KeyCode.H then

            gui.MainFrame.Visible =
                not gui.MainFrame.Visible

        end

    end
)

-- ==================================================
-- STARTUP
-- ==================================================

print(
    "🚀 Teleport GUI loaded on " ..
    tostring(executorName)
)

print("📌 Click blue icon = Toggle GUI")
print("📌 Drag blue icon = Move icon")
print("📌 Ctrl+G = Get Position")
print("📌 Ctrl+T = Teleport")
print("📌 Ctrl+C = Copy")
print("📌 Ctrl+R = Reset")
print("📌 Ctrl+H = Toggle GUI")

updateStatus(
    "Ready! Ctrl+G=Get, Ctrl+T=TP",
    false
)

-- ==================================================
-- ANTI-AFK
-- ==================================================

task.spawn(function()

    while gui.ScreenGui.Parent do

        task.wait(60)

        pcall(function()

            local virtualUser =
                game:GetService("VirtualUser")

            virtualUser:CaptureController()

            virtualUser:ClickButton2(
                Vector2.new()
            )

        end)

    end

end)
