--catch and tame : potion only

--[[
    Auto Brew & Claim GUI (with X terminate button)
]]

print("[AUTO BREW] Script started.")

-- Wrap everything to catch errors
local success, err = pcall(function()

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    if not player then
        warn("Waiting for LocalPlayer...")
        player = Players:WaitForChild("LocalPlayer")
    end
    print("[AUTO BREW] Player found:", player.Name)

    -- Configuration
    local TARGET_GAME_ID = nil
    if TARGET_GAME_ID and game.GameId ~= TARGET_GAME_ID then
        warn("[AUTO BREW] Wrong game! (ID: " .. game.GameId .. "). Exiting.")
        return
    end

    -- Tier data (only used if remote is found)
    local TIER_DATA = {
        ["Tier 2"] = { time = 300, cash = 100000 },
        ["Tier 3"] = { time = 600, cash = 1000000 }
    }

    -- Helper: format cash
    local function formatCash(amount)
        if amount >= 1000000 then return string.format("%.1fM", amount/1000000) end
        if amount >= 1000 then return string.format("%.1fK", amount/1000) end
        return tostring(amount)
    end

    -- Helper: format time
    local function formatTime(seconds)
        local m = math.floor(seconds / 60)
        local s = math.floor(seconds % 60)
        return string.format("%d:%02d", m, s)
    end

    -- ========== CREATE GUI (always appears) ==========

    local function createGUI()
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

        local toggleText = Instance.new("TextLabel")
        toggleText.Size = UDim2.new(1, 0, 1, 0)
        toggleText.BackgroundTransparency = 1
        toggleText.Text = "⚗️"
        toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleText.TextSize = 24
        toggleText.Font = Enum.Font.GothamBold
        toggleText.Parent = toggleFrame

        -- Main GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoPotionGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Enabled = false

        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 300, 0, 445)
        mainFrame.Position = UDim2.new(0, 60, 0, 10)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.BorderSizePixel = 1
        mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
        mainFrame.Parent = screenGui

        -- X button (terminate)
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

        -- Separator
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(0.9, 0, 0, 1)
        sep.Position = UDim2.new(0.05, 0, 0, 30)
        sep.BackgroundColor3 = Color3.fromRGB(100,100,120)
        sep.BackgroundTransparency = 0.5
        sep.Parent = mainFrame

        -- Cash
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

        -- Potion count
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

        -- Enable toggle
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

        -- Brew Count
        local countFrame = Instance.new("Frame")
        countFrame.Size = UDim2.new(1, 0, 0, 30)
        countFrame.Position = UDim2.new(0, 0, 0, 115)
        countFrame.BackgroundTransparency = 1
        countFrame.Parent = mainFrame

        local countLabel = Instance.new("TextLabel")
        countLabel.Size = UDim2.new(0.45, 0, 1, 0)
        countLabel.Position = UDim2.new(0, 10, 0, 0)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = "Brew Count:"
        countLabel.TextColor3 = Color3.fromRGB(200,200,200)
        countLabel.TextSize = 13
        countLabel.TextXAlignment = Enum.TextXAlignment.Left
        countLabel.Font = Enum.Font.Gotham
        countLabel.Parent = countFrame

        local countBox = Instance.new("TextBox")
        countBox.Name = "CountBox"
        countBox.Size = UDim2.new(0.15, 0, 1, 0)
        countBox.Position = UDim2.new(0.47, 0, 0, 0)
        countBox.BackgroundColor3 = Color3.fromRGB(60,60,80)
        countBox.BorderSizePixel = 1
        countBox.BorderColor3 = Color3.fromRGB(100,100,120)
        countBox.Text = "0"
        countBox.TextColor3 = Color3.fromRGB(255,255,255)
        countBox.TextSize = 13
        countBox.TextXAlignment = Enum.TextXAlignment.Center
        countBox.Font = Enum.Font.Gotham
        countBox.Parent = countFrame

        local countHint = Instance.new("TextLabel")
        countHint.Size = UDim2.new(0.35, 0, 1, 0)
        countHint.Position = UDim2.new(0.65, 0, 0, 0)
        countHint.BackgroundTransparency = 1
        countHint.Text = "(0 = infinite)"
        countHint.TextColor3 = Color3.fromRGB(150,150,200)
        countHint.TextSize = 11
        countHint.TextXAlignment = Enum.TextXAlignment.Left
        countHint.Font = Enum.Font.Gotham
        countHint.Parent = countFrame

        -- Potion selection
        local potionSection = Instance.new("Frame")
        potionSection.Name = "PotionSection"
        potionSection.Size = UDim2.new(1, 0, 0, 110)
        potionSection.Position = UDim2.new(0, 0, 0, 150)
        potionSection.BackgroundTransparency = 1
        potionSection.Parent = mainFrame

        local potionLabel = Instance.new("TextLabel")
        potionLabel.Size = UDim2.new(1, 0, 0, 20)
        potionLabel.Position = UDim2.new(0, 10, 0, 0)
        potionLabel.BackgroundTransparency = 1
        potionLabel.Text = "Select Potion Type: (Select one)"
        potionLabel.TextColor3 = Color3.fromRGB(200,200,200)
        potionLabel.TextSize = 13
        potionLabel.TextXAlignment = Enum.TextXAlignment.Left
        potionLabel.Font = Enum.Font.Gotham
        potionLabel.Parent = potionSection

        local potionTypes = {"Speed Potion", "Money Potion", "Strength Potion"}
        local potionRadios = {}

        for i, name in ipairs(potionTypes) do
            local frame = Instance.new("Frame")
            frame.Name = name .. "Frame"
            frame.Size = UDim2.new(0.32, 0, 0, 22)
            frame.Position = UDim2.new((i-1)*0.33, 0, 0, 25)
            frame.BackgroundTransparency = 1
            frame.Parent = potionSection

            local radio = Instance.new("ImageButton")
            radio.Name = "Radio"
            radio.Size = UDim2.new(0, 16, 0, 16)
            radio.Position = UDim2.new(0, 0, 0.15, 0)
            radio.BackgroundColor3 = Color3.fromRGB(60,60,80)
            radio.BorderSizePixel = 1
            radio.BorderColor3 = Color3.fromRGB(100,100,120)
            radio.Image = "rbxassetid://0"
            radio.Parent = frame

            local circle = Instance.new("ImageLabel")
            circle.Name = "Circle"
            circle.Size = UDim2.new(0.6, 0, 0.6, 0)
            circle.Position = UDim2.new(0.2, 0, 0.2, 0)
            circle.BackgroundTransparency = 1
            circle.Image = "rbxassetid://0"
            circle.Visible = false
            circle.ImageColor3 = Color3.fromRGB(100,200,255)
            circle.Parent = radio

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(0.7, 0, 1, 0)
            text.Position = UDim2.new(0.25, 0, 0, 0)
            text.BackgroundTransparency = 1
            text.Text = name
            text.TextColor3 = Color3.fromRGB(255,255,255)
            text.TextSize = 11
            text.TextXAlignment = Enum.TextXAlignment.Left
            text.Font = Enum.Font.Gotham
            text.Parent = frame

            potionRadios[name] = { radio = radio, circle = circle }
        end

        -- Tier selection
        local tierSection = Instance.new("Frame")
        tierSection.Name = "TierSection"
        tierSection.Size = UDim2.new(1, 0, 0, 80)
        tierSection.Position = UDim2.new(0, 0, 0, 265)
        tierSection.BackgroundTransparency = 1
        tierSection.Parent = mainFrame

        local tierLabel = Instance.new("TextLabel")
        tierLabel.Size = UDim2.new(1, 0, 0, 20)
        tierLabel.Position = UDim2.new(0, 10, 0, 0)
        tierLabel.BackgroundTransparency = 1
        tierLabel.Text = "Select Tier: (Select one)"
        tierLabel.TextColor3 = Color3.fromRGB(200,200,200)
        tierLabel.TextSize = 13
        tierLabel.TextXAlignment = Enum.TextXAlignment.Left
        tierLabel.Font = Enum.Font.Gotham
        tierLabel.Parent = tierSection

        local tierRadios = {}
        local tiers = {"Tier 2", "Tier 3"}

        for i, tier in ipairs(tiers) do
            local frame = Instance.new("Frame")
            frame.Name = tier .. "Frame"
            frame.Size = UDim2.new(0.45, 0, 0, 45)
            frame.Position = UDim2.new((i-1)*0.45 + 0.05, 0, 0, 25)
            frame.BackgroundTransparency = 1
            frame.Parent = tierSection

            local radio = Instance.new("ImageButton")
            radio.Name = "Radio"
            radio.Size = UDim2.new(0, 16, 0, 16)
            radio.Position = UDim2.new(0, 0, 0.1, 0)
            radio.BackgroundColor3 = Color3.fromRGB(60,60,80)
            radio.BorderSizePixel = 1
            radio.BorderColor3 = Color3.fromRGB(100,100,120)
            radio.Image = "rbxassetid://0"
            radio.Parent = frame

            local circle = Instance.new("ImageLabel")
            circle.Name = "Circle"
            circle.Size = UDim2.new(0.6, 0, 0.6, 0)
            circle.Position = UDim2.new(0.2, 0, 0.2, 0)
            circle.BackgroundTransparency = 1
            circle.Image = "rbxassetid://0"
            circle.Visible = false
            circle.ImageColor3 = Color3.fromRGB(100,200,255)
            circle.Parent = radio

            local text = Instance.new("TextLabel")
            text.Name = "Text"
            text.Size = UDim2.new(0.7, 0, 0.5, 0)
            text.Position = UDim2.new(0.25, 0, 0, 0)
            text.BackgroundTransparency = 1
            text.Text = tier
            text.TextColor3 = Color3.fromRGB(255,255,255)
            text.TextSize = 12
            text.TextXAlignment = Enum.TextXAlignment.Left
            text.Font = Enum.Font.Gotham
            text.Parent = frame

            local cashReq = Instance.new("TextLabel")
            cashReq.Name = "CashReq"
            cashReq.Size = UDim2.new(0.7, 0, 0.5, 0)
            cashReq.Position = UDim2.new(0.25, 0, 0.5, 0)
            cashReq.BackgroundTransparency = 1
            cashReq.Text = "💰 " .. formatCash(TIER_DATA[tier].cash) .. " req."
            cashReq.TextColor3 = Color3.fromRGB(255,215,0)
            cashReq.TextSize = 10
            cashReq.TextXAlignment = Enum.TextXAlignment.Left
            cashReq.Font = Enum.Font.Gotham
            cashReq.Parent = frame

            tierRadios[tier] = { radio = radio, circle = circle }
        end

        -- Lower-tier availability
        local lowerTierLabel = Instance.new("TextLabel")
        lowerTierLabel.Name = "LowerTierLabel"
        lowerTierLabel.Size = UDim2.new(1, 0, 0, 25)
        lowerTierLabel.Position = UDim2.new(0, 0, 0, 350)
        lowerTierLabel.BackgroundTransparency = 1
        lowerTierLabel.Text = "🔽 Select tier to show lower-tier potions"
        lowerTierLabel.TextColor3 = Color3.fromRGB(200,200,255)
        lowerTierLabel.TextSize = 12
        lowerTierLabel.TextXAlignment = Enum.TextXAlignment.Left
        lowerTierLabel.Font = Enum.Font.Gotham
        lowerTierLabel.Parent = mainFrame

        -- Timer
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

        -- Status
        local statusLine = Instance.new("TextLabel")
        statusLine.Name = "StatusLine"
        statusLine.Size = UDim2.new(1, 0, 0, 25)
        statusLine.Position = UDim2.new(0, 0, 0, 410)
        statusLine.BackgroundTransparency = 1
        statusLine.Text = "Brewing..."
        statusLine.TextColor3 = Color3.fromRGB(150,150,200)
        statusLine.TextSize = 13
        statusLine.TextXAlignment = Enum.TextXAlignment.Left
        statusLine.Font = Enum.Font.Gotham
        statusLine.Parent = mainFrame

        return {
            ToggleScreen = toggleScreen,
            ToggleFrame = toggleFrame,
            ScreenGui = screenGui,
            MainFrame = mainFrame,
            CloseButton = closeButton,
            EnableCheckbox = enableCheckbox,
            EnableCheckmark = enableCheckmark,
            CountBox = countBox,
            CashLabel = cashLabel,
            PotionCountLabel = potionCountLabel,
            LowerTierLabel = lowerTierLabel,
            TimerLabel = timerLabel,
            StatusLine = statusLine,
            PotionRadios = potionRadios,
            TierRadios = tierRadios,
        }
    end

    -- ========== BUILD AND INSERT GUI ==========

    print("[AUTO BREW] Creating GUI...")
    local gui = createGUI()
    print("[AUTO BREW] GUI created. Inserting into PlayerGui...")

    local playerGui = player:WaitForChild("PlayerGui")
    gui.ToggleScreen.Parent = playerGui
    gui.ScreenGui.Parent = playerGui

    print("[AUTO BREW] GUI inserted successfully.")

    -- ========== STATE ==========

    local autoEnabled = false
    local isBrewing = false

    -- ========== UI EVENT WIRING ==========

    -- Toggle GUI visibility
    local guiVisible = false
    gui.ToggleFrame.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        gui.ScreenGui.Enabled = guiVisible
        print("[AUTO BREW] GUI visibility:", guiVisible)
    end)

    -- Radio buttons (simplified – just update status)
    for name, data in pairs(gui.PotionRadios) do
        data.radio.MouseButton1Click:Connect(function()
            for _, d in pairs(gui.PotionRadios) do d.circle.Visible = false end
            data.circle.Visible = true
            gui.StatusLine.Text = "Selected potion: " .. name
            gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
        end)
    end

    for name, data in pairs(gui.TierRadios) do
        data.radio.MouseButton1Click:Connect(function()
            for _, d in pairs(gui.TierRadios) do d.circle.Visible = false end
            data.circle.Visible = true
            gui.StatusLine.Text = "Selected tier: " .. name
            gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
        end)
    end

    -- Enable/disable toggle (simple demonstration)
    gui.EnableCheckbox.MouseButton1Click:Connect(function()
        autoEnabled = not autoEnabled
        gui.EnableCheckmark.Visible = autoEnabled
        if autoEnabled then
            gui.StatusLine.Text = "🟢 Auto Brew ENABLED (simulated)"
            gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
        else
            gui.StatusLine.Text = "🔴 Auto Brew DISABLED"
            gui.StatusLine.TextColor3 = Color3.fromRGB(255,100,100)
        end
        print("[AUTO BREW] Auto enabled:", autoEnabled)
    end)

    -- ========== X BUTTON – TERMINATE ==========

    gui.CloseButton.MouseButton1Click:Connect(function()
        autoEnabled = false
        isBrewing = false
        gui.EnableCheckmark.Visible = false
        gui.EnableCheckbox.BackgroundColor3 = Color3.fromRGB(60,60,80)
        gui.StatusLine.Text = "⏹️ Script terminated (X)"
        gui.StatusLine.TextColor3 = Color3.fromRGB(255,100,100)
        gui.TimerLabel.Text = "⏱️ Terminated"
        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
        print("[AUTO BREW] Script terminated by X button.")
    end)

    -- ========== DRAG FUNCTIONALITY (simplified) ==========

    do
        local dragging, dragInput, dragStart, startPos
        gui.ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.ToggleFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        gui.ToggleFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                gui.ToggleFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    do
        local dragging, dragInput, dragStart, startPos
        gui.MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.MainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        gui.MainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                gui.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- ========== INITIAL STATUS ==========

    gui.StatusLine.Text = "Select potion & tier"
    gui.StatusLine.TextColor3 = Color3.fromRGB(150,150,200)
    print("[AUTO BREW] Ready. Click the ⚗️ icon to open the menu.")
    print("[AUTO BREW] Press the red ✕ button to terminate the script.")

end) -- end of pcall

-- ========== ERROR HANDLING ==========

if not success then
    warn("[AUTO BREW] ERROR: " .. tostring(err))
    print("[AUTO BREW] The script encountered an error. Check the console for details.")
else
    print("[AUTO BREW] Script loaded without errors.")
end
