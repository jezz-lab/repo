--catch and tame : potion only
--[[
    Auto Brew & Claim GUI
    Compatible with: Git, Delta, and any Roblox executor.

    DEBUG VERSION
    Debugging focuses on:
    - Potion/item names in Backpack
    - Amount attributes
    - Cash detection
    - ClaimPotion class/path confirmation
    - Detecting possible separate brew/start remotes

    NOT debugging:
    - ClaimPotion return-value format
    - Knit version/path
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure player is valid
local player = Players.LocalPlayer
if not player then
    warn("Waiting for LocalPlayer...")
    player = Players:WaitForChild("LocalPlayer")
end

-- ========== CONFIGURATION ==========
local TARGET_GAME_ID = nil -- Set to specific GameId to restrict

-- Startup message
print("[AUTO BREW] Script is running...")

-- ========== GAME ID CHECK ==========
if TARGET_GAME_ID and game.GameId ~= TARGET_GAME_ID then
    warn("[AUTO BREW] Wrong game! (ID: " .. game.GameId .. "). Exiting.")
    return
end

-- ========== REST OF SCRIPT ==========

local TIER_DATA = {
    ["Tier 2"] = { time = 300, cash = 100000 },
    ["Tier 3"] = { time = 600, cash = 1000000 }
}

-- ========== DEBUG HELPERS ==========

local DEBUG = true

local function debugPrint(...)
    if DEBUG then
        print("[AUTO BREW DEBUG]", ...)
    end
end

local function debugWarn(...)
    warn("[AUTO BREW DEBUG]", ...)
end

debugPrint("Game ID:", game.GameId)
debugPrint("Place ID:", game.PlaceId)
debugPrint("Player:", player.Name)

-- ========== REMOTE FINDER ==========

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

-- ========== DEBUG FUNCTIONS ==========

local function debugInventory()
    debugPrint("========== INVENTORY DEBUG ==========")
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        debugWarn("Backpack NOT FOUND")
        return
    end
    debugPrint("Backpack found:", backpack:GetFullName())
    local children = backpack:GetChildren()
    if #children == 0 then
        debugWarn("Backpack is empty")
        return
    end
    for _, obj in ipairs(children) do
        local amount = obj:GetAttribute("Amount")
        debugPrint("Backpack item:", obj.Name, "| Class:", obj.ClassName, "| Amount:", tostring(amount))
        local attributes = obj:GetAttributes()
        for attributeName, attributeValue in pairs(attributes) do
            debugPrint("   Attribute:", attributeName, "=", tostring(attributeValue))
        end
    end
    debugPrint("========== END INVENTORY DEBUG ==========")
end

local function debugCash()
    debugPrint("========== CASH DEBUG ==========")
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        debugWarn("leaderstats NOT FOUND")
        return
    end
    debugPrint("leaderstats found")
    for _, obj in ipairs(leaderstats:GetChildren()) do
        debugPrint("leaderstats item:", obj.Name, "| Class:", obj.ClassName, "| Value:", tostring(obj.Value))
    end
    local cashValue = leaderstats:FindFirstChild("Cash")
    if not cashValue then
        debugWarn("Cash object NOT FOUND")
    else
        debugPrint("Cash found:", cashValue:GetFullName(), "| Class:", cashValue.ClassName, "| Value:", tostring(cashValue.Value))
    end
    debugPrint("========== END CASH DEBUG ==========")
end

local function debugClaimRemote()
    debugPrint("========== CLAIM REMOTE DEBUG ==========")
    local claimRemote = getClaimPotionEvent()
    if not claimRemote then
        debugWarn("ClaimPotion NOT FOUND")
        return
    end
    debugPrint("ClaimPotion found:", claimRemote:GetFullName())
    debugPrint("ClaimPotion class:", claimRemote.ClassName)
    local parent = claimRemote.Parent
    if parent then
        debugPrint("ClaimPotion parent:", parent:GetFullName())
        for _, obj in ipairs(parent:GetChildren()) do
            debugPrint("Remote sibling:", obj.Name, "| Class:", obj.ClassName)
        end
    end
    debugPrint("========== END CLAIM REMOTE DEBUG ==========")
end

local function debugPotionService()
    debugPrint("========== POTION SERVICE DEBUG ==========")
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if not packages then
        debugWarn("Packages not found")
        return
    end
    local index = packages:FindFirstChild("_Index")
    if not index then
        debugWarn("_Index not found")
        return
    end
    local knitFolder = index:FindFirstChild('sleitnick_knit@1.7.0')
    if not knitFolder then
        debugWarn("Knit folder not found")
        return
    end
    local knit = knitFolder:FindFirstChild("knit")
    if not knit then
        debugWarn("knit folder not found")
        return
    end
    local services = knit:FindFirstChild("Services")
    if not services then
        debugWarn("Services folder not found")
        return
    end
    local potionService = services:FindFirstChild("PotionCauldronService")
    if not potionService then
        debugWarn("PotionCauldronService NOT FOUND")
        return
    end
    debugPrint("PotionCauldronService:", potionService:GetFullName())
    for _, obj in ipairs(potionService:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            debugPrint("Potion service remote:", obj:GetFullName(), "| Class:", obj.ClassName)
        end
    end
    debugPrint("========== END POTION SERVICE DEBUG ==========")
end

-- ========== DATA FETCHERS ==========

local function getPlayerCash()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local cashValue = leaderstats:FindFirstChild("Cash")
        if cashValue and cashValue:IsA("StringValue") then
            local cleaned = string.gsub(cashValue.Value, "[,%s]", "")
            return tonumber(cleaned) or 0
        end
    end
    return 0
end

local function getPotionCount(potionName)
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        return 0
    end
    local potionItem = backpack:FindFirstChild(potionName)
    if not potionItem then
        return 0
    end
    local amount = potionItem:GetAttribute("Amount")
    return tonumber(amount) or 0
end

-- ========== FORMAT HELPERS ==========

local function formatCash(amount)
    if amount >= 1000000 then
        return string.format("%.1fM", amount / 1000000)
    end
    if amount >= 1000 then
        return string.format("%.1fK", amount / 1000)
    end
    return tostring(amount)
end

local function formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%d:%02d", m, s)
end

-- ========== GUI CREATION ==========

local function createGUI()

    -- Toggle Icon
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

    local potionTypes = {
        "Speed Potion",
        "Money Potion",
        "Strength Potion"
    }

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

        potionRadios[name] = {
            radio = radio,
            circle = circle
        }
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
    local tiers = {
        "Tier 2",
        "Tier 3"
    }

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

        tierRadios[tier] = {
            radio = radio,
            circle = circle
        }
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

-- ========== STATE ==========

local gui = createGUI()
local claimPotionEvent = getClaimPotionEvent()

local autoEnabled = false
local isBrewing = false
local brewStartTime = 0
local brewDuration = 0
local brewedCount = 0
local targetCount = 0

-- ========== INITIAL DEBUG SCAN ==========

debugPrint("========================================")
debugPrint("INITIAL DEBUG SCAN")
debugPrint("========================================")
debugCash()
debugInventory()
debugClaimRemote()
debugPotionService()
debugPrint("========================================")
debugPrint("END INITIAL DEBUG SCAN")
debugPrint("========================================")

-- ========== HELPER FUNCTIONS ==========

local function toggleCheckbox(checkbox, checkmark)
    checkmark.Visible = not checkmark.Visible
    return checkmark.Visible
end

local function clearRadios(radios)
    for _, data in pairs(radios) do
        data.circle.Visible = false
    end
end

local function getSelectedPotion()
    for name, data in pairs(gui.PotionRadios) do
        if data.circle.Visible then
            return name
        end
    end
    return nil
end

local function getSelectedTier()
    for name, data in pairs(gui.TierRadios) do
        if data.circle.Visible then
            return name
        end
    end
    return nil
end

local function updatePotionCountDisplay()
    local potion = getSelectedPotion()
    local tier = getSelectedTier()
    local label = gui.PotionCountLabel

    if potion and tier then
        local name = potion .. " " .. tier
        local count = getPotionCount(name)
        label.Text = string.format("🧪 %s: %d/3 req.", name, count)
        label.TextColor3 = count >= 3 and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
        debugPrint("Potion check:", name, "| Count:", count)
    else
        label.Text = "🧪 Select a potion and tier"
        label.TextColor3 = Color3.fromRGB(150,200,255)
    end
end

local function updateLowerTierDisplay()
    local potion = getSelectedPotion()
    local tier = getSelectedTier()
    local label = gui.LowerTierLabel

    if potion and tier then
        local lowerTier = (tier == "Tier 2") and "Tier 1" or (tier == "Tier 3" and "Tier 2" or nil)
        if lowerTier then
            local lowerName = potion .. " " .. lowerTier
            local count = getPotionCount(lowerName)
            label.Text = string.format("🔽 %s available: %d", lowerName, count)
            label.TextColor3 = Color3.fromRGB(200,200,255)
            debugPrint("Lower-tier check:", lowerName, "| Count:", count)
        else
            label.Text = "🔽 Select a valid tier"
            label.TextColor3 = Color3.fromRGB(150,150,200)
        end
    else
        label.Text = "🔽 Select potion & tier"
        label.TextColor3 = Color3.fromRGB(150,150,200)
    end
end

local function updateCashDisplay()
    local cash = getPlayerCash()
    gui.CashLabel.Text = "💰 Cash: " .. formatCash(cash)
    debugPrint("Cash read:", cash)
end

local function updateTimerDisplay(elapsed, total)
    gui.TimerLabel.Text = string.format("⏱️ Brewing: %s / %s", formatTime(elapsed), formatTime(total))
    local progress = elapsed / total
    if progress >= 1 then
        gui.TimerLabel.TextColor3 = Color3.fromRGB(100,255,100)
    elseif progress >= 0.7 then
        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,255,100)
    elseif progress >= 0.3 then
        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,200,50)
    else
        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,150,50)
    end
end

local function setStatus(text, color)
    gui.StatusLine.Text = text
    gui.StatusLine.TextColor3 = color
end

-- ========== CLAIM FUNCTION ==========

local function claimPotion(potionName)
    if not claimPotionEvent then
        return false, "Event not found"
    end
    debugPrint("Claim requested for:", potionName)
    debugPrint("Claim remote:", claimPotionEvent:GetFullName())
    debugPrint("Claim remote class:", claimPotionEvent.ClassName)

    local ok, result = pcall(function()
        if claimPotionEvent:IsA("RemoteFunction") then
            debugPrint("Invoking ClaimPotion RemoteFunction for:", potionName)
            return claimPotionEvent:InvokeServer()
        elseif claimPotionEvent:IsA("RemoteEvent") then
            debugPrint("Firing ClaimPotion RemoteEvent for:", potionName)
            claimPotionEvent:FireServer()
            return true
        else
            debugWarn("ClaimPotion has unexpected class:", claimPotionEvent.ClassName)
            return nil
        end
    end)

    if not ok then
        debugWarn("ClaimPotion call errored:", tostring(result))
        return false, "Error"
    end

    if type(result) == "table" and #result >= 2 and result[2] == "Not finished" then
        return false, "Not finished"
    end

    if result then
        return true, result
    else
        return false, "Failed"
    end
end

-- ========== MAIN AUTO LOOP ==========

local function autoLoop()
    brewedCount = 0
    debugPrint("AUTO LOOP STARTED")

    while autoEnabled do
        local potion = getSelectedPotion()
        local tier = getSelectedTier()

        updateCashDisplay()
        updatePotionCountDisplay()
        updateLowerTierDisplay()

        local countText = gui.CountBox.Text:match("%d+") or "0"
        targetCount = tonumber(countText) or 0

        debugPrint("Loop state:", "Potion =", tostring(potion), "Tier =", tostring(tier), "Target =", targetCount, "Brewed =", brewedCount)

        if targetCount > 0 and brewedCount >= targetCount then
            setStatus(string.format("✅ Done! Brewed %d %s %s", brewedCount, potion or "", tier or ""), Color3.fromRGB(100,255,100))
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

            debugPrint("----------------------------------------")
            debugPrint("BREW CHECK")
            debugPrint("Potion:", potionName)
            debugPrint("Potion count:", potionCount)
            debugPrint("Required potions: 3")
            debugPrint("Cash:", currentCash)
            debugPrint("Required cash:", requiredCash)
            debugPrint("Brew duration:", brewTime)

            if potionCount < 3 then
                debugWarn("Insufficient potion:", potionName, "| Have:", potionCount, "| Need: 3")
                setStatus(string.format("❌ Need 3 %s (have %d)", potionName, potionCount), Color3.fromRGB(255,100,100))
                gui.TimerLabel.Text = "⏱️ Insufficient Potions!"
                gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
                wait(5)
                continue
            end

            if currentCash < requiredCash then
                debugWarn("Insufficient cash:", currentCash, "| Need:", requiredCash)
                setStatus(string.format("❌ Need %s cash (have %s)", formatCash(requiredCash), formatCash(currentCash)), Color3.fromRGB(255,100,100))
                gui.TimerLabel.Text = "⏱️ Insufficient Cash!"
                gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
                wait(5)
                continue
            end

            debugPrint("Requirements passed for:", potionName)
            debugPrint("Beginning local brew timer.")

            isBrewing = true
            brewStartTime = tick()
            brewDuration = brewTime

            setStatus(string.format("🔄 Brewing %s... (%d/%s)", potionName, brewedCount, targetCount == 0 and "∞" or targetCount), Color3.fromRGB(255,200,50))

            while isBrewing and autoEnabled do
                local elapsed = tick() - brewStartTime
                local remaining = brewDuration - elapsed

                if remaining <= 0 then
                    isBrewing = false
                    gui.TimerLabel.Text = string.format("✅ Brewing: %s / %s - READY!", formatTime(brewDuration), formatTime(brewDuration))
                    gui.TimerLabel.TextColor3 = Color3.fromRGB(100,255,100)
                    debugPrint("Local brew timer finished:", potionName)

                    local attempts = 0
                    local maxAttempts = 10
                    local claimed = false

                    while not claimed and attempts < maxAttempts do
                        attempts = attempts + 1
                        setStatus(string.format("⏳ Claiming %s (attempt %d)", potionName, attempts), Color3.fromRGB(255,200,50))
                        debugPrint("Claim attempt:", attempts, "/", maxAttempts, "| Potion:", potionName)

                        local success, statusOrResult = claimPotion(potionName)

                        if success then
                            claimed = true
                            brewedCount = brewedCount + 1
                            setStatus(string.format("✅ Claimed %s! (%d/%s)", potionName, brewedCount, targetCount == 0 and "∞" or targetCount), Color3.fromRGB(100,255,100))
                            gui.TimerLabel.Text = "✅ Brewed & Claimed: " .. potionName
                            gui.TimerLabel.TextColor3 = Color3.fromRGB(100,255,100)
                            updateCashDisplay()
                            updatePotionCountDisplay()
                            updateLowerTierDisplay()
                            debugPrint("Claim reported success:", potionName)
                            break
                        elseif statusOrResult == "Not finished" then
                            setStatus(string.format("⏳ Not ready, retry %d/%d in 5s", attempts, maxAttempts), Color3.fromRGB(255,200,50))
                            gui.TimerLabel.Text = "⏳ Waiting for potion..."
                            gui.TimerLabel.TextColor3 = Color3.fromRGB(255,200,50)
                            wait(5)
                        else
                            debugWarn("Claim failed for:", potionName, "| Status:", tostring(statusOrResult))
                            setStatus(string.format("❌ Claim failed: %s", potionName), Color3.fromRGB(255,100,100))
                            gui.TimerLabel.Text = "❌ Claim failed"
                            gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
                            break
                        end
                    end

                    if not claimed then
                        debugWarn("All claim attempts exhausted:", potionName)
                        setStatus(string.format("⚠️ Claim attempts exhausted for %s", potionName), Color3.fromRGB(255,200,50))
                    end
                    break
                else
                    updateTimerDisplay(elapsed, brewDuration)
                    local timeLeft = formatTime(remaining)
                    setStatus(string.format("⏳ Brewing %s (%s left) 💰%s | 🧪 %d/3", potionName, timeLeft, formatCash(requiredCash), potionCount), Color3.fromRGB(255,200,50))
                    wait(1)
                end
            end

            if not autoEnabled then
                isBrewing = false
                debugPrint("Auto loop stopped while brewing.")
                break
            end
        else
            if not potion and not tier then
                setStatus("⚠️ Select a potion and tier", Color3.fromRGB(255,200,50))
            elseif not potion then
                setStatus("⚠️ Select a potion type", Color3.fromRGB(255,200,50))
            elseif not tier then
                setStatus("⚠️ Select a tier", Color3.fromRGB(255,200,50))
            else
                setStatus("⚠️ No ClaimPotion event found", Color3.fromRGB(255,100,100))
            end
            gui.TimerLabel.Text = "⏱️ Brewing: 0:00 / 0:00"
            gui.TimerLabel.TextColor3 = Color3.fromRGB(200,200,200)
            wait(2)
        end
    end

    if not autoEnabled then
        gui.EnableCheckmark.Visible = false
    end

    debugPrint("AUTO LOOP ENDED")
end

-- ========== WIRE UP UI EVENTS ==========

local guiVisible = false

gui.ToggleFrame.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    gui.ScreenGui.Enabled = guiVisible
    debugPrint("GUI visibility:", guiVisible)
end)

-- Radio buttons
for name, data in pairs(gui.PotionRadios) do
    data.radio.MouseButton1Click:Connect(function()
        clearRadios(gui.PotionRadios)
        data.circle.Visible = true
        debugPrint("Selected potion:", name)
        updatePotionCountDisplay()
        updateLowerTierDisplay()
        local potion = getSelectedPotion()
        local tier = getSelectedTier()
        if potion and tier then
            debugPrint("Selected combination:", potion .. " " .. tier)
            setStatus(string.format("Selected: %s %s", potion, tier), Color3.fromRGB(100,255,100))
        else
            setStatus("Select potion & tier", Color3.fromRGB(150,150,200))
        end
    end)
end

-- Tier buttons
for name, data in pairs(gui.TierRadios) do
    data.radio.MouseButton1Click:Connect(function()
        clearRadios(gui.TierRadios)
        data.circle.Visible = true
        debugPrint("Selected tier:", name)
        updatePotionCountDisplay()
        updateCashDisplay()
        updateLowerTierDisplay()
        local potion = getSelectedPotion()
        local tier = getSelectedTier()
        if potion and tier then
            debugPrint("Selected combination:", potion .. " " .. tier)
            setStatus(string.format("Selected: %s %s", potion, tier), Color3.fromRGB(100,255,100))
        else
            setStatus("Select potion & tier", Color3.fromRGB(150,150,200))
        end
    end)
end

-- ========== ENABLE TOGGLE ==========

gui.EnableCheckbox.MouseButton1Click:Connect(function()
    autoEnabled = toggleCheckbox(gui.EnableCheckbox, gui.EnableCheckmark)
    debugPrint("Auto enabled:", autoEnabled)

    if autoEnabled then
        isBrewing = false
        brewedCount = 0
        debugPrint("========== STARTUP CHECK ==========")
        debugCash()
        debugInventory()
        debugClaimRemote()
        debugPotionService()
        debugPrint("========== END STARTUP CHECK ==========")

        setStatus("🟢 Auto Brew & Claim ENABLED", Color3.fromRGB(100,255,100))
        updateCashDisplay()
        updatePotionCountDisplay()
        updateLowerTierDisplay()

        local countText = gui.CountBox.Text:match("%d+") or "0"
        targetCount = tonumber(countText) or 0
        debugPrint("Target brew count:", targetCount)

        coroutine.wrap(autoLoop)()
    else
        isBrewing = false
        setStatus("🔴 Auto Brew & Claim DISABLED", Color3.fromRGB(255,100,100))
        gui.TimerLabel.Text = "⏱️ Brewing: 0:00 / 0:00"
        gui.TimerLabel.TextColor3 = Color3.fromRGB(200,200,200)
    end
end)

-- ========== X BUTTON TERMINATION ==========

gui.CloseButton.MouseButton1Click:Connect(function()
    if autoEnabled or isBrewing then
        autoEnabled = false
        isBrewing = false
        setStatus("⏹️ Script terminated (X)", Color3.fromRGB(255,100,100))
        gui.EnableCheckmark.Visible = false
        gui.EnableCheckbox.BackgroundColor3 = Color3.fromRGB(60,60,80)
        gui.TimerLabel.Text = "⏱️ Terminated"
        gui.TimerLabel.TextColor3 = Color3.fromRGB(255,100,100)
        print("[AUTO BREW] Script terminated by X button.")
    else
        print("[AUTO BREW] Script is not active; nothing to terminate.")
    end
end)

-- ========== DRAG FUNCTIONALITY ==========

-- Toggle icon
do
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    gui.ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.ToggleFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            gui.ToggleFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main GUI
do
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    gui.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            gui.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ========== INITIALIZE UI ==========

updateCashDisplay()
updatePotionCountDisplay()
updateLowerTierDisplay()

setStatus("Select potion & tier", Color3.fromRGB(150,150,200))

if claimPotionEvent then
    print("✅ Auto Brew & Claim: ClaimPotion event found.")
    debugPrint("ClaimPotion:", claimPotionEvent:GetFullName())
    debugPrint("ClaimPotion Class:", claimPotionEvent.ClassName)
else
    warn("⚠️ Auto Brew & Claim: ClaimPotion event NOT found!")
    setStatus("⚠️ Event not found!", Color3.fromRGB(255,50,50))
end

-- Insert GUIs
local playerGui = player:WaitForChild("PlayerGui")
gui.ToggleScreen.Parent = playerGui
gui.ScreenGui.Parent = playerGui

debugPrint("GUI inserted into PlayerGui.")
debugPrint("Auto Brew debug script initialized successfully.")

print("[AUTO BREW] Click the ⚗️ flask icon to open the menu, then use the ✕ button to terminate.")
