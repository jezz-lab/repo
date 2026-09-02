--catch and tame : potion only

--[[
    Auto Brew & Claim – with cash parser for "$100M" etc.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer or Players:WaitForChild("LocalPlayer")

-- ========== CONFIG ==========
local TARGET_GAME_ID = nil  -- set to restrict to a specific game

-- ========== STATUS PANEL (auto‑disappears) ==========

local function createStatusPanel(text, isError, autoDisappearDelay)
    autoDisappearDelay = autoDisappearDelay or 3

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StatusPanel"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 60)
    frame.Position = UDim2.new(0.5, -200, 0, 10)
    frame.BackgroundColor3 = isError and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(30, 180, 30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 2
    frame.BorderColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(100, 255, 100)
    frame.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 22
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame

    -- Drag for status panel
    local function makeDraggable(obj)
        local dragging, dragInput, dragStart, startPos
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = obj.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        obj.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    makeDraggable(frame)

    -- Auto‑disappear
    local destroyTask = nil
    if autoDisappearDelay > 0 then
        destroyTask = task.delay(autoDisappearDelay, function()
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        if destroyTask then task.cancel(destroyTask) end
        screenGui:Destroy()
    end)

    return screenGui
end

-- ========== GAME ID CHECK ==========

if TARGET_GAME_ID and game.GameId ~= TARGET_GAME_ID then
    local panel = createStatusPanel("❌ Wrong game! (ID: " .. game.GameId .. ")", true, 3)
    panel.Parent = player:WaitForChild("PlayerGui")
    print("[AUTO BREW] Wrong game – exiting.")
    return
end

-- ========== RUNNING PANEL ==========

local statusPanel = createStatusPanel("✅ Script is running", false, 3)
statusPanel.Parent = player:WaitForChild("PlayerGui")
print("[AUTO BREW] Status panel created (disappears in 3s).")

-- ========== MAIN SCRIPT LOGIC ==========

local TIER_DATA = {
    ["Tier 2"] = { time = 300, cash = 100000 },
    ["Tier 3"] = { time = 600, cash = 1000000 }
}

local function formatCash(amount)
    if amount >= 1000000000 then return string.format("%.1fB", amount/1000000000) end
    if amount >= 1000000 then return string.format("%.1fM", amount/1000000) end
    if amount >= 1000 then return string.format("%.1fK", amount/1000) end
    return tostring(amount)
end

local function formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%d:%02d", m, s)
end

local function getClaimPotionEvent()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        local index = packages:FindFirstChild("_Index")
        if index then
            local knitFolder = index:FindFirstChild('sleitnick_knit@1.7.0')
            if knitFolder then
                local knit = knitFolder:FindFirstChild("knit")
                if knit then
                    local services = knit:FindFirstChild("Services")
                    if services then
                        local potionService = services:FindFirstChild("PotionCauldronService")
                        if potionService then
                            local rf = potionService:FindFirstChild("RF")
                            if rf then
                                return rf:FindFirstChild("ClaimPotion")
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- ========== CASH PARSER (handles "$100M", "$1.5B", etc.) ==========

local function parseCashString(str)
    if type(str) ~= "string" then return tonumber(str) or 0 end
    -- Remove leading/trailing spaces, $, commas
    local clean = str:gsub("[%$,%s]", "")
    -- Find suffix (K, M, B) at end
    local suffix = clean:match("([KMB])$")
    local numPart = clean:gsub("[KMB]$", "")
    local num = tonumber(numPart)
    if not num then return 0 end
    if suffix == "K" then return num * 1000 end
    if suffix == "M" then return num * 1000000 end
    if suffix == "B" then return num * 1000000000 end
    return num
end

-- ========== IMPROVED CASH FETCHER ==========

local function getPlayerCash()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        print("[DEBUG] leaderstats not found.")
        return 0
    end

    -- Try common cash names
    local cashNames = {"Cash", "Money", "Coins", "Gold"}
    for _, name in ipairs(cashNames) do
        local valueObj = leaderstats:FindFirstChild(name)
        if valueObj then
            if valueObj:IsA("StringValue") then
                local parsed = parseCashString(valueObj.Value)
                if parsed > 0 then
                    print("[DEBUG] Cash parsed from StringValue: " .. name .. " = " .. parsed)
                    return parsed
                end
            elseif valueObj:IsA("NumberValue") or valueObj:IsA("IntValue") then
                print("[DEBUG] Cash found as NumberValue: " .. name .. " = " .. valueObj.Value)
                return valueObj.Value
            else
                -- Try to convert .Value to number anyway
                local num = tonumber(valueObj.Value)
                if num then
                    print("[DEBUG] Cash found (converted): " .. name .. " = " .. num)
                    return num
                end
            end
        end
    end

    -- If nothing found, print all leaderstats children for debug
    print("[DEBUG] No cash object found. leaderstats children:")
    for _, child in ipairs(leaderstats:GetChildren()) do
        print("  " .. child.Name .. " (" .. child.ClassName .. ") = " .. tostring(child.Value))
    end

    return 0
end

-- ========== POTION COUNT ==========

local function getPotionCount(potionName)
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return 0 end
    local potionItem = backpack:FindFirstChild(potionName)
    if not potionItem then return 0 end
    return tonumber(potionItem:GetAttribute("Amount")) or 0
end

-- ========== CREATE FLASK ICON & MAIN GUI ==========

local function createMainGUI()
    local toggleScreen = Instance.new("ScreenGui")
    toggleScreen.Name = "ToggleGUI"
    toggleScreen.ResetOnSpawn = false

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 50, 0, 50)
    toggleFrame.Position = UDim2.new(0.5, -25, 0, 80)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    toggleFrame.BackgroundTransparency = 0.2
    toggleFrame.BorderSizePixel = 3
    toggleFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    toggleFrame.Parent = toggleScreen

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = toggleFrame

    local toggleText = Instance.new("TextLabel")
    toggleText.Size = UDim2.new(1, 0, 1, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = "⚗️"
    toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleText.TextSize = 30
    toggleText.Font = Enum.Font.GothamBold
    toggleText.Parent = toggleButton

    -- Main GUI (hidden initially)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoPotionGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 445)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -222)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
    mainFrame.Parent = screenGui

    -- X button (terminate)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 2
    closeBtn.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
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
    potionLabel.Text = "Select Potion Type:"
    potionLabel.TextColor3 = Color3.fromRGB(200,200,200)
    potionLabel.TextSize = 13
    potionLabel.TextXAlignment = Enum.TextXAlignment.Left
    potionLabel.Font = Enum.Font.Gotham
    potionLabel.Parent = potionSection

    local potionTypes = {"Speed Potion", "Money Potion", "Strength Potion"}
    local potionRadios = {}
    for i, name in ipairs(potionTypes) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.32, 0, 0, 22)
        frame.Position = UDim2.new((i-1)*0.33, 0, 0, 25)
        frame.BackgroundTransparency = 1
        frame.Parent = potionSection

        local radio = Instance.new("ImageButton")
        radio.Size = UDim2.new(0, 16, 0, 16)
        radio.Position = UDim2.new(0, 0, 0.15, 0)
        radio.BackgroundColor3 = Color3.fromRGB(60,60,80)
        radio.BorderSizePixel = 1
        radio.BorderColor3 = Color3.fromRGB(100,100,120)
        radio.Image = "rbxassetid://0"
        radio.Parent = frame

        local circle = Instance.new("ImageLabel")
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
    tierSection.Size = UDim2.new(1, 0, 0, 80)
    tierSection.Position = UDim2.new(0, 0, 0, 265)
    tierSection.BackgroundTransparency = 1
    tierSection.Parent = mainFrame

    local tierLabel = Instance.new("TextLabel")
    tierLabel.Size = UDim2.new(1, 0, 0, 20)
    tierLabel.Position = UDim2.new(0, 10, 0, 0)
    tierLabel.BackgroundTransparency = 1
    tierLabel.Text = "Select Tier:"
    tierLabel.TextColor3 = Color3.fromRGB(200,200,200)
    tierLabel.TextSize = 13
    tierLabel.TextXAlignment = Enum.TextXAlignment.Left
    tierLabel.Font = Enum.Font.Gotham
    tierLabel.Parent = tierSection

    local tierRadios = {}
    local tiers = {"Tier 2", "Tier 3"}
    for i, tier in ipairs(tiers) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.45, 0, 0, 45)
        frame.Position = UDim2.new((i-1)*0.45 + 0.05, 0, 0, 25)
        frame.BackgroundTransparency = 1
        frame.Parent = tierSection

        local radio = Instance.new("ImageButton")
        radio.Size = UDim2.new(0, 16, 0, 16)
        radio.Position = UDim2.new(0, 0, 0.1, 0)
        radio.BackgroundColor3 = Color3.fromRGB(60,60,80)
        radio.BorderSizePixel = 1
        radio.BorderColor3 = Color3.fromRGB(100,100,120)
        radio.Image = "rbxassetid://0"
        radio.Parent = frame

        local circle = Instance.new("ImageLabel")
        circle.Size = UDim2.new(0.6, 0, 0.6, 0)
        circle.Position = UDim2.new(0.2, 0, 0.2, 0)
        circle.BackgroundTransparency = 1
        circle.Image = "rbxassetid://0"
        circle.Visible = false
        circle.ImageColor3 = Color3.fromRGB(100,200,255)
        circle.Parent = radio

        local text = Instance.new("TextLabel")
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

    -- Lower-tier info
    local lowerTierLabel = Instance.new("TextLabel")
    lowerTierLabel.Name = "LowerTierLabel"
    lowerTierLabel.Size = UDim2.new(1, 0, 0, 25)
    lowerTierLabel.Position = UDim2.new(0, 0, 0, 350)
    lowerTierLabel.BackgroundTransparency = 1
    lowerTierLabel.Text = "🔽 Select tier to see lower-tier potions"
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
    statusLine.Text = "Ready"
    statusLine.TextColor3 = Color3.fromRGB(150,150,200)
    statusLine.TextSize = 13
    statusLine.TextXAlignment = Enum.TextXAlignment.Left
    statusLine.Font = Enum.Font.Gotham
    statusLine.Parent = mainFrame

    return {
        ToggleScreen = toggleScreen,
        ToggleFrame = toggleFrame,
        ToggleButton = toggleButton,
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        CloseButton = closeBtn,
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

-- ========== BUILD GUI ==========

local gui = createMainGUI()
local playerGui = player:WaitForChild("PlayerGui")
gui.ToggleScreen.Parent = playerGui
gui.ScreenGui.Parent = playerGui

-- ========== DRAG FUNCTIONS ==========

-- Generic draggable function with threshold to avoid click interference
local function makeDraggableWithThreshold(obj, clickCallback)
    local isDragging = false
    local pressPos = nil
    local startPos = nil
    local threshold = 10  -- pixels

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressPos = input.Position
            startPos = obj.Position
            isDragging = false
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if pressPos then
                local delta = input.Position - pressPos
                if delta.Magnitude > threshold then
                    isDragging = true
                    local newPos = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                    obj.Position = newPos
                end
            end
        end
    end)

    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not isDragging and clickCallback then
                clickCallback()
            end
            pressPos = nil
            startPos = nil
            isDragging = false
        end
    end)
end

-- Make the flask icon draggable (click toggles GUI only if not dragged)
local guiVisible = false
makeDraggableWithThreshold(gui.ToggleButton, function()
    guiVisible = not guiVisible
    gui.ScreenGui.Enabled = guiVisible
end)

-- Make the main GUI draggable (simple drag without click conflict)
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(gui.MainFrame)

-- ========== UI EVENTS ==========

-- Potion radios
for name, data in pairs(gui.PotionRadios) do
    data.radio.MouseButton1Click:Connect(function()
        for _, d in pairs(gui.PotionRadios) do d.circle.Visible = false end
        data.circle.Visible = true
        gui.StatusLine.Text = "Selected potion: " .. name
        gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
    end)
end

-- Tier radios
for name, data in pairs(gui.TierRadios) do
    data.radio.MouseButton1Click:Connect(function()
        for _, d in pairs(gui.TierRadios) do d.circle.Visible = false end
        data.circle.Visible = true
        gui.StatusLine.Text = "Selected tier: " .. name
        gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
    end)
end

-- ========== TERMINATE ==========

local function terminateScript()
    autoEnabled = false
    isBrewing = false
    if statusPanel and statusPanel.Parent then statusPanel:Destroy() end
    gui.ToggleScreen:Destroy()
    gui.ScreenGui:Destroy()
    print("[AUTO BREW] Script terminated.")
end

gui.CloseButton.MouseButton1Click:Connect(terminateScript)

-- ========== AUTO BREW LOGIC ==========

local claimPotionEvent = getClaimPotionEvent()
local autoEnabled = false
local isBrewing = false
local brewStartTime = 0
local brewDuration = 0
local brewedCount = 0
local targetCount = 0

local function updateCashDisplay()
    local cash = getPlayerCash()
    gui.CashLabel.Text = "💰 Cash: " .. formatCash(cash)
end

local function updatePotionCountDisplay()
    local potion, tier = nil, nil
    for name, data in pairs(gui.PotionRadios) do
        if data.circle.Visible then potion = name; break end
    end
    for name, data in pairs(gui.TierRadios) do
        if data.circle.Visible then tier = name; break end
    end
    if potion and tier then
        local fullName = potion .. " " .. tier
        local count = getPotionCount(fullName)
        gui.PotionCountLabel.Text = string.format("🧪 %s: %d/3 req.", fullName, count)
        gui.PotionCountLabel.TextColor3 = count >= 3 and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
    else
        gui.PotionCountLabel.Text = "🧪 Select potion and tier"
        gui.PotionCountLabel.TextColor3 = Color3.fromRGB(150,200,255)
    end
end

local function updateLowerTierDisplay()
    local potion, tier = nil, nil
    for name, data in pairs(gui.PotionRadios) do
        if data.circle.Visible then potion = name; break end
    end
    for name, data in pairs(gui.TierRadios) do
        if data.circle.Visible then tier = name; break end
    end
    if potion and tier then
        local lowerTier = tier == "Tier 2" and "Tier 1" or (tier == "Tier 3" and "Tier 2" or nil)
        if lowerTier then
            local lowerName = potion .. " " .. lowerTier
            local count = getPotionCount(lowerName)
            gui.LowerTierLabel.Text = string.format("🔽 %s available: %d", lowerName, count)
            gui.LowerTierLabel.TextColor3 = Color3.fromRGB(200,200,255)
        else
            gui.LowerTierLabel.Text = "🔽 Select a valid tier"
            gui.LowerTierLabel.TextColor3 = Color3.fromRGB(150,150,200)
        end
    else
        gui.LowerTierLabel.Text = "🔽 Select potion & tier"
        gui.LowerTierLabel.TextColor3 = Color3.fromRGB(150,150,200)
    end
end

local function claimPotion(potionName)
    if not claimPotionEvent then return false, "Event not found" end
    local ok, result = pcall(function()
        if claimPotionEvent:IsA("RemoteFunction") then
            return claimPotionEvent:InvokeServer()
        elseif claimPotionEvent:IsA("RemoteEvent") then
            claimPotionEvent:FireServer()
            return true
        else
            return nil
        end
    end)
    if not ok then return false, "Error" end
    if type(result) == "table" and #result >= 2 and result[2] == "Not finished" then
        return false, "Not finished"
    end
    return result ~= nil, result
end

local function autoLoop()
    brewedCount = 0
    while autoEnabled do
        local potion, tier = nil, nil
        for name, data in pairs(gui.PotionRadios) do
            if data.circle.Visible then potion = name; break end
        end
        for name, data in pairs(gui.TierRadios) do
            if data.circle.Visible then tier = name; break end
        end
        updateCashDisplay()
        updatePotionCountDisplay()
        updateLowerTierDisplay()

        local countText = gui.CountBox.Text:match("%d+") or "0"
        targetCount = tonumber(countText) or 0

        if targetCount > 0 and brewedCount >= targetCount then
            gui.StatusLine.Text = string.format("✅ Done! Brewed %d", brewedCount)
            gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
            autoEnabled = false
            gui.EnableCheckmark.Visible = false
            gui.EnableCheckbox.BackgroundColor3 = Color3.fromRGB(60,60,80)
            gui.TimerLabel.Text = "⏱️ Finished"
            gui.TimerLabel.TextColor3 = Color3.fromRGB(100,255,100)
            break
        end

        if potion and tier and claimPotionEvent then
            local potionName = potion .. " " .. tier
            local data = TIER_DATA[tier]
            local requiredCash = data.cash
            local brewTime = data.time
            local potionCount = getPotionCount(potionName)
            local currentCash = getPlayerCash()

            if potionCount < 3 then
                gui.StatusLine.Text = string.format("❌ Need 3 %s (have %d)", potionName, potionCount)
                gui.StatusLine.TextColor3 = Color3.fromRGB(255,100,100)
                gui.TimerLabel.Text = "⏱️ Insufficient Potions!"
                gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
                wait(5)
                continue
            end

            if currentCash < requiredCash then
                gui.StatusLine.Text = string.format("❌ Need %s cash (have %s)", formatCash(requiredCash), formatCash(currentCash))
                gui.StatusLine.TextColor3 = Color3.fromRGB(255,100,100)
                gui.TimerLabel.Text = "⏱️ Insufficient Cash!"
                gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
                wait(5)
                continue
            end

            -- Start brewing
            isBrewing = true
            brewStartTime = tick()
            brewDuration = brewTime
            gui.StatusLine.Text = string.format("🔄 Brewing %s... (%d/%s)", potionName, brewedCount, targetCount == 0 and "∞" or targetCount)
            gui.StatusLine.TextColor3 = Color3.fromRGB(255,200,50)

            while isBrewing and autoEnabled do
                local elapsed = tick() - brewStartTime
                local remaining = brewDuration - elapsed

                if remaining <= 0 then
                    isBrewing = false
                    gui.TimerLabel.Text = string.format("✅ Brewing: %s / %s - READY!", formatTime(brewDuration), formatTime(brewDuration))
                    gui.TimerLabel.TextColor3 = Color3.fromRGB(100,255,100)

                    local attempts = 0
                    local maxAttempts = 10
                    local claimed = false
                    while not claimed and attempts < maxAttempts do
                        attempts = attempts + 1
                        gui.StatusLine.Text = string.format("⏳ Claiming %s (attempt %d)", potionName, attempts)
                        gui.StatusLine.TextColor3 = Color3.fromRGB(255,200,50)

                        local success, statusOrResult = claimPotion(potionName)
                        if success then
                            claimed = true
                            brewedCount = brewedCount + 1
                            gui.StatusLine.Text = string.format("✅ Claimed %s! (%d/%s)", potionName, brewedCount, targetCount == 0 and "∞" or targetCount)
                            gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
                            gui.TimerLabel.Text = "✅ Brewed & Claimed: " .. potionName
                            gui.TimerLabel.TextColor3 = Color3.fromRGB(100,255,100)
                            updateCashDisplay()
                            updatePotionCountDisplay()
                            updateLowerTierDisplay()
                            break
                        elseif statusOrResult == "Not finished" then
                            gui.StatusLine.Text = string.format("⏳ Not ready, retry %d/%d in 5s", attempts, maxAttempts)
                            gui.TimerLabel.Text = "⏳ Waiting for potion..."
                            gui.TimerLabel.TextColor3 = Color3.fromRGB(255,200,50)
                            wait(5)
                        else
                            gui.StatusLine.Text = string.format("❌ Claim failed: %s", potionName)
                            gui.StatusLine.TextColor3 = Color3.fromRGB(255,100,100)
                            gui.TimerLabel.Text = "❌ Claim failed"
                            gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
                            break
                        end
                    end
                    break
                else
                    gui.TimerLabel.Text = string.format("⏱️ Brewing: %s / %s", formatTime(elapsed), formatTime(brewDuration))
                    local progress = elapsed / brewDuration
                    if progress >= 1 then
                        gui.TimerLabel.TextColor3 = Color3.fromRGB(100,255,100)
                    elseif progress >= 0.7 then
                        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,255,100)
                    elseif progress >= 0.3 then
                        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,200,50)
                    else
                        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,150,50)
                    end
                    gui.StatusLine.Text = string.format("⏳ Brewing %s (%s left) 💰%s | 🧪 %d/3", potionName, formatTime(remaining), formatCash(requiredCash), potionCount)
                    wait(1)
                end
            end

            if not autoEnabled then
                isBrewing = false
                break
            end
        else
            gui.StatusLine.Text = "⚠️ Select potion, tier, and ensure event exists"
            gui.StatusLine.TextColor3 = Color3.fromRGB(255,200,50)
            wait(2)
        end
    end
    gui.EnableCheckmark.Visible = false
end

-- ========== ENABLE TOGGLE ==========

gui.EnableCheckbox.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    gui.EnableCheckmark.Visible = autoEnabled
    if autoEnabled then
        brewedCount = 0
        gui.StatusLine.Text = "🟢 Auto Brew ENABLED"
        gui.StatusLine.TextColor3 = Color3.fromRGB(100,255,100)
        updateCashDisplay()
        updatePotionCountDisplay()
        updateLowerTierDisplay()
        coroutine.wrap(autoLoop)()
    else
        isBrewing = false
        gui.StatusLine.Text = "🔴 Auto Brew DISABLED"
        gui.StatusLine.TextColor3 = Color3.fromRGB(255,100,100)
        gui.TimerLabel.Text = "⏱️ Brewing: 0:00 / 0:00"
        gui.TimerLabel.TextColor3 = Color3.fromRGB(200,200,200)
    end
end)

-- ========== FINAL ==========

if claimPotionEvent then
    print("[AUTO BREW] ClaimPotion event found.")
else
    warn("[AUTO BREW] ClaimPotion event NOT found – auto brewing may fail.")
end

print("[AUTO BREW] Ready. Drag the ⚗️ flask icon to move it; click to open the main GUI.")
