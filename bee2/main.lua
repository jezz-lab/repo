--==================================================
-- SHOP RESTOCK AUTO BUY GUI
--==================================================


--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")


--==================================================
-- PLAYER
--==================================================

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


--==================================================
-- SETTINGS
--==================================================

local SHOP_JSON_URL =
    "https://raw.githubusercontent.com/jezz-lab/repo/main/bee2/shop.json"

local DEFAULT_SPEED = 16
local SPEED = DEFAULT_SPEED

local AUTO_BUY = false

local RESTOCK_BLINK_DURATION = 2

local PURCHASE_INTERVAL = 0.05

local ITEM_SCROLL_HEIGHT = 180


--==================================================
-- CATEGORY ORDER
--==================================================

local CategoryOrder = {
    "gear",
    "event",
    "bait",
    "eggs"
}


--==================================================
-- STATE
--==================================================

local ShopItems = {}

local SelectedItems = {}

local CurrentStock = {}

local Categories = {}

local BlinkToken = 0

local Terminated = false

local RestockDelayToken = 0

local AutoBuyRunning = false
local AutoBuyTask = nil

local RemoContainer = nil


--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShopRestockGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui


--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(280, 400)
Main.Position = UDim2.new(0.5, -210, 0.5, -325)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main


--==================================================
-- TITLE BAR
--==================================================

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 20
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar


--==================================================
-- RESTOCK DOT
--==================================================

local RestockDot = Instance.new("Frame")
RestockDot.Name = "RestockDot"
RestockDot.Size = UDim2.fromOffset(9, 9)
RestockDot.Position = UDim2.fromOffset(10, 16)
RestockDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
RestockDot.BorderSizePixel = 0
RestockDot.Visible = false
RestockDot.ZIndex = 21
RestockDot.Parent = TitleBar

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = RestockDot


--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Position = UDim2.fromOffset(26, 0)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Shop Restock"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 21
Title.Parent = TitleBar


--==================================================
-- CLOSE
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.fromOffset(34, 34)
CloseButton.Position = UDim2.new(1, -39, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 22
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton


--==================================================
-- MAIN SCROLL
--==================================================

local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Name = "MainScroll"
MainScroll.Position = UDim2.fromOffset(0, 42)
MainScroll.Size = UDim2.new(1, 0, 1, -42)
MainScroll.BackgroundTransparency = 1
MainScroll.BorderSizePixel = 0
MainScroll.ScrollBarThickness = 6
MainScroll.ScrollingDirection = Enum.ScrollingDirection.Y
MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScroll.CanvasSize = UDim2.fromOffset(0, 0)
MainScroll.Parent = Main

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingTop = UDim.new(0, 10)
MainPadding.PaddingBottom = UDim.new(0, 10)
MainPadding.PaddingLeft = UDim.new(0, 10)
MainPadding.PaddingRight = UDim.new(0, 10)
MainPadding.Parent = MainScroll

local MainLayout = Instance.new("UIListLayout")
MainLayout.Padding = UDim.new(0, 6)
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainLayout.Parent = MainScroll


--==================================================
-- SPEED
--==================================================

local SpeedFrame = Instance.new("Frame")
SpeedFrame.Name = "SpeedFrame"
SpeedFrame.LayoutOrder = 1
SpeedFrame.Size = UDim2.new(1, -2, 0, 42)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedFrame.BorderSizePixel = 0
SpeedFrame.Parent = MainScroll

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedFrame


local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Position = UDim2.fromOffset(10, 0)
SpeedLabel.Size = UDim2.fromOffset(60, 42)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedFrame


local SpeedBox = Instance.new("TextBox")
SpeedBox.Name = "SpeedBox"
SpeedBox.Position = UDim2.fromOffset(70, 6)
SpeedBox.Size = UDim2.fromOffset(65, 30)
SpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedBox.BorderSizePixel = 0
SpeedBox.Text = tostring(SPEED)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.TextSize = 14
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.ClearTextOnFocus = false
SpeedBox.TextXAlignment = Enum.TextXAlignment.Center
SpeedBox.Parent = SpeedFrame

local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 4)
SpeedBoxCorner.Parent = SpeedBox


local SpeedSetButton = Instance.new("TextButton")
SpeedSetButton.Name = "SpeedSetButton"
SpeedSetButton.Position = UDim2.new(1, -95, 0, 6)
SpeedSetButton.Size = UDim2.fromOffset(85, 30)
SpeedSetButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedSetButton.BorderSizePixel = 0
SpeedSetButton.Text = "Set"
SpeedSetButton.TextColor3 = Color3.new(1, 1, 1)
SpeedSetButton.TextSize = 14
SpeedSetButton.Font = Enum.Font.GothamBold
SpeedSetButton.Parent = SpeedFrame

local SpeedSetCorner = Instance.new("UICorner")
SpeedSetCorner.CornerRadius = UDim.new(0, 4)
SpeedSetCorner.Parent = SpeedSetButton


--==================================================
-- DEFAULT
--==================================================

local DefaultButton = Instance.new("TextButton")
DefaultButton.Name = "DefaultButton"
DefaultButton.LayoutOrder = 2
DefaultButton.Size = UDim2.new(1, -2, 0, 36)
DefaultButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DefaultButton.BorderSizePixel = 0
DefaultButton.Text = "Default"
DefaultButton.TextColor3 = Color3.new(1, 1, 1)
DefaultButton.TextSize = 14
DefaultButton.Font = Enum.Font.GothamBold
DefaultButton.Parent = MainScroll

local DefaultCorner = Instance.new("UICorner")
DefaultCorner.CornerRadius = UDim.new(0, 6)
DefaultCorner.Parent = DefaultButton


--==================================================
-- FEED KING BEE
--==================================================

local FeedButton = Instance.new("TextButton")
FeedButton.Name = "FeedKingBee"
FeedButton.LayoutOrder = 3
FeedButton.Size = UDim2.new(1, -2, 0, 40)
FeedButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FeedButton.BorderSizePixel = 0
FeedButton.Text = "Feed King Bee"
FeedButton.TextColor3 = Color3.new(1, 1, 1)
FeedButton.TextSize = 14
FeedButton.Font = Enum.Font.GothamBold
FeedButton.Parent = MainScroll

local FeedCorner = Instance.new("UICorner")
FeedCorner.CornerRadius = UDim.new(0, 6)
FeedCorner.Parent = FeedButton


--==================================================
-- SHOP RESTOCK HEADER
--==================================================

local ShopHeader = Instance.new("TextLabel")
ShopHeader.Name = "ShopRestockHeader"
ShopHeader.LayoutOrder = 4
ShopHeader.Size = UDim2.new(1, -2, 0, 30)
ShopHeader.BackgroundTransparency = 1
ShopHeader.Text = "SHOP RESTOCK"
ShopHeader.TextColor3 = Color3.new(1, 1, 1)
ShopHeader.TextSize = 14
ShopHeader.Font = Enum.Font.GothamBold
ShopHeader.TextXAlignment = Enum.TextXAlignment.Left
ShopHeader.Parent = MainScroll


--==================================================
-- AUTO BUY
--==================================================

local AutoBuyFrame = Instance.new("Frame")
AutoBuyFrame.Name = "AutoBuyFrame"
AutoBuyFrame.LayoutOrder = 5
AutoBuyFrame.Size = UDim2.new(1, -2, 0, 40)
AutoBuyFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
AutoBuyFrame.BorderSizePixel = 0
AutoBuyFrame.Parent = MainScroll

local AutoBuyCorner = Instance.new("UICorner")
AutoBuyCorner.CornerRadius = UDim.new(0, 6)
AutoBuyCorner.Parent = AutoBuyFrame


local AutoBuyLabel = Instance.new("TextLabel")
AutoBuyLabel.Position = UDim2.fromOffset(10, 0)
AutoBuyLabel.Size = UDim2.new(1, -55, 1, 0)
AutoBuyLabel.BackgroundTransparency = 1
AutoBuyLabel.Text = "Auto Buy"
AutoBuyLabel.TextColor3 = Color3.new(1, 1, 1)
AutoBuyLabel.TextSize = 14
AutoBuyLabel.Font = Enum.Font.GothamBold
AutoBuyLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoBuyLabel.Parent = AutoBuyFrame


local AutoBuyButton = Instance.new("TextButton")
AutoBuyButton.Name = "Checkbox"
AutoBuyButton.Size = UDim2.fromOffset(34, 34)
AutoBuyButton.Position = UDim2.new(1, -40, 0, 3)
AutoBuyButton.BackgroundTransparency = 1
AutoBuyButton.BorderSizePixel = 0
AutoBuyButton.Text = "☐"
AutoBuyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoBuyButton.TextSize = 21
AutoBuyButton.Font = Enum.Font.GothamBold
AutoBuyButton.Parent = AutoBuyFrame


--==================================================
-- DRAG
--==================================================

local function MakeDraggable(
    object,
    dragHandle
)

    dragHandle =
        dragHandle or object

    local dragging = false
    local dragStart
    local startPosition


    dragHandle.InputBegan:Connect(function(input)

        if Terminated then
            return
        end


        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then

            return
        end


        dragging = true
        dragStart = input.Position
        startPosition = object.Position


        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false
            end
        end)
    end)


    UserInputService.InputChanged:Connect(function(input)

        if not dragging
            or Terminated then

            return
        end


        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            return
        end


        local delta =
            input.Position - dragStart


        object.Position =
            UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
    end)
end


MakeDraggable(
    Main,
    TitleBar
)


--==================================================
-- FLOATING TOGGLE
--==================================================

local ToggleButton =
    Instance.new("TextButton")

ToggleButton.Name =
    "ToggleIcon"

ToggleButton.Size =
    UDim2.fromOffset(52, 52)

ToggleButton.Position =
    UDim2.new(
        0,
        20,
        0.5,
        -26
    )

ToggleButton.BackgroundColor3 =
    Color3.fromRGB(40, 40, 40)

ToggleButton.BorderSizePixel =
    0

ToggleButton.Text =
    "S"

ToggleButton.TextColor3 =
    Color3.new(1, 1, 1)

ToggleButton.TextSize =
    24

ToggleButton.Font =
    Enum.Font.GothamBold

ToggleButton.ZIndex =
    30

ToggleButton.Parent =
    ScreenGui


local ToggleCorner =
    Instance.new("UICorner")

ToggleCorner.CornerRadius =
    UDim.new(1, 0)

ToggleCorner.Parent =
    ToggleButton


MakeDraggable(
    ToggleButton
)


ToggleButton.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    Main.Visible =
        not Main.Visible
end)


--==================================================
-- HELPERS
--==================================================

local function IsAvailable(stock)

    return type(stock) == "number"
        and stock > 0
end


local function IsNone(stock)

    return type(stock) == "table"
        and stock.__none == "__none"
end


--==================================================
-- GET STATUS TEXT
--==================================================

local function GetStatusText(stock)

    if type(stock) == "number" then

        return "[" .. tostring(stock) .. "]"

    end

    return "[Not Restocked]"
end


--==================================================
-- JSON ITEM HELPERS
--==================================================

local function GetItemId(item)

    if type(item) == "string" then

        if item == "" then
            return nil
        end

        return item
    end


    if type(item) ~= "table" then
        return nil
    end


    local id =
        item.id


    if type(id) ~= "string"
        or id == "" then

        return nil
    end


    return id
end


local function GetItemName(item)

    if type(item) == "string" then

        if item == "" then
            return nil
        end

        return item
    end


    if type(item) ~= "table" then
        return nil
    end


    local itemId =
        GetItemId(item)


    local name =
        item.name


    if type(name) == "string"
        and name ~= "" then

        return name
    end


    return itemId
end


--==================================================
-- PURCHASE
--==================================================

local function PurchaseItem(
    category,
    itemId
)

    if not itemId
        or itemId == "" then

        return false
    end


    if not RemoContainer then

        warn(
            "[ShopRestock] RemoContainer unavailable."
        )

        return false
    end


    local success, err =
        pcall(function()

            if category == "event" then

                RemoContainer["shop.purchaseEventItem"]:FireServer(
                    itemId
                )

            elseif category == "gear" then

                RemoContainer["shop.purchaseGear"]:FireServer(
                    itemId
                )

            elseif category == "eggs" then

                RemoContainer["shop.purchaseEgg"]:FireServer(
                    itemId
                )

            elseif category == "bait" then

                RemoContainer["shop.purchaseBait"]:FireServer(
                    itemId
                )

            else

                error(
                    "Unknown category: "
                    .. tostring(category)
                )
            end
        end)


    if not success then

        warn(
            "[ShopRestock] Purchase error:",
            category,
            itemId,
            err
        )

        return false
    end


    return true
end


--==================================================
-- APPLY SPEED
--==================================================

local function ApplySpeed()

    if Terminated then
        return
    end


    local Character =
        Player.Character


    if not Character then
        return
    end


    local Humanoid =
        Character:FindFirstChildOfClass(
            "Humanoid"
        )


    if Humanoid then

        Humanoid.WalkSpeed =
            SPEED
    end
end


--==================================================
-- RESTOCK BLINK
--==================================================

local function BlinkRestockDot()

    BlinkToken += 1

    local token =
        BlinkToken


    task.spawn(function()

        local endTime =
            os.clock()
            + RESTOCK_BLINK_DURATION


        local green =
            true


        while os.clock() < endTime do

            if Terminated
                or token ~= BlinkToken then

                return
            end


            RestockDot.Visible =
                true


            if green then

                RestockDot.BackgroundColor3 =
                    Color3.fromRGB(
                        0,
                        255,
                        0
                    )

            else

                RestockDot.BackgroundColor3 =
                    Color3.fromRGB(
                        255,
                        0,
                        0
                    )
            end


            green =
                not green


            task.wait(0.15)
        end


        if not Terminated
            and token == BlinkToken then

            RestockDot.Visible =
                false
        end
    end)
end


--==================================================
-- UPDATE ITEM VISUAL
--==================================================

local function UpdateItemVisual(
    itemData,
    stock
)

    if not itemData then
        return
    end


    local selected =
        SelectedItems[itemData.Category]
        and SelectedItems[itemData.Category]
            [itemData.ItemKey]


    itemData.Label.Text =
        itemData.DisplayName
        .. "  "
        .. GetStatusText(stock)


    itemData.CheckButton.Text =
        selected
        and "☑"
        or "☐"


    if IsAvailable(stock) then

        itemData.Label.TextColor3 =
            Color3.new(
                1,
                1,
                1
            )

        itemData.CheckButton.TextColor3 =
            Color3.new(
                1,
                1,
                1
            )

    else

        itemData.Label.TextColor3 =
            Color3.fromRGB(
                150,
                150,
                150
            )

        itemData.CheckButton.TextColor3 =
            Color3.fromRGB(
                150,
                150,
                150
            )
    end
end


--==================================================
-- PURCHASE WITH RETRY
--==================================================

local function PurchaseItemWithRetry(
    category,
    itemId,
    maxAttempts
)

    maxAttempts =
        maxAttempts or 3


    for attempt = 1, maxAttempts do

        if Terminated
            or not AutoBuyRunning then

            return false
        end


        local success =
            PurchaseItem(
                category,
                itemId
            )


        if success then
            return true
        end


        task.wait(0.2)
    end


    return false
end


--==================================================
-- AUTO BUY
--==================================================

local function AutoBuyLoop()

    while AutoBuyRunning
        and not Terminated do

        local anyPurchased =
            false


        --==========================================
        -- CATEGORY ORDER
        --==========================================

        for _, category
            in ipairs(CategoryOrder) do

            local selected =
                SelectedItems[category]


            if selected then

                local categoryStock =
                    CurrentStock[category]


                if categoryStock then

                    for itemKey, enabled
                        in pairs(selected) do

                        if enabled
                            and AutoBuyRunning
                            and not Terminated then

                            local stock =
                                categoryStock[itemKey]


                            --======================
                            -- ONLY BUY > 0
                            --======================

                            if IsAvailable(stock) then

                                local itemData =
                                    Categories[category]
                                    and Categories[category]
                                        .Items[itemKey]


                                if itemData then

                                    local purchased =
                                        PurchaseItemWithRetry(
                                            category,
                                            itemData.ItemId,
                                            3
                                        )


                                    if purchased then

                                        --==================
                                        -- LOCAL DECREMENT
                                        --==================

                                        local newStock =
                                            math.max(
                                                stock - 1,
                                                0
                                            )


                                        CurrentStock[category][itemKey] =
                                            newStock


                                        UpdateItemVisual(
                                            itemData,
                                            newStock
                                        )


                                        anyPurchased =
                                            true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end


        --==========================================
        -- NOTHING AVAILABLE
        --==========================================

        if not anyPurchased then

            -- At 0 / unavailable, wait.
            -- The next shopRestock will replace
            -- CurrentStock and restart the loop.

            task.wait(0.5)

        else

            task.wait(
                PURCHASE_INTERVAL
            )
        end
    end
end


--==================================================
-- START AUTO BUY
--==================================================

local function StartAutoBuy()

    if AutoBuyRunning then
        return
    end


    AutoBuyRunning =
        true


    AutoBuyTask =
        task.spawn(
            AutoBuyLoop
        )
end


--==================================================
-- STOP AUTO BUY
--==================================================

local function StopAutoBuy()

    AutoBuyRunning =
        false


    if AutoBuyTask then

        task.cancel(
            AutoBuyTask
        )


        AutoBuyTask =
            nil
    end
end


--==================================================
-- SET SELECTED
--==================================================

local function SetSelected(
    category,
    itemKey,
    enabled
)

    SelectedItems[category] =
        SelectedItems[category]
        or {}


    SelectedItems[category][itemKey] =
        enabled


    local categoryData =
        Categories[category]


    if categoryData then

        local itemData =
            categoryData.Items[itemKey]


        if itemData then

            local stock =
                CurrentStock[category]
                and CurrentStock[category][itemKey]


            UpdateItemVisual(
                itemData,
                stock
            )
        end
    end


    if AUTO_BUY
        and enabled then

        StartAutoBuy()
    end
end


--==================================================
-- CATEGORY MESSAGE
--==================================================

local function ShowCategoryMessage(
    category,
    message,
    textColor
)

    local categoryData =
        Categories[category]


    if not categoryData then
        return
    end


    for _, child in ipairs(
        categoryData.List:GetChildren()
    ) do

        if not child:IsA(
            "UIListLayout"
        ) then

            child:Destroy()
        end
    end


    categoryData.Items =
        {}


    local Label =
        Instance.new("TextLabel")


    Label.Name =
        "Status"


    Label.Size =
        UDim2.new(
            1,
            -10,
            0,
            30
        )


    Label.BackgroundTransparency =
        1


    Label.Text =
        "  "
        .. tostring(message)


    Label.TextColor3 =
        textColor
        or Color3.fromRGB(
            140,
            140,
            140
        )


    Label.TextSize =
        13


    Label.Font =
        Enum.Font.Gotham


    Label.TextXAlignment =
        Enum.TextXAlignment.Left


    Label.Parent =
        categoryData.List
end


--==================================================
-- CLEAR CATEGORY
--==================================================

local function ClearCategoryItems(
    category
)

    local categoryData =
        Categories[category]


    if not categoryData then
        return
    end


    for _, child in ipairs(
        categoryData.List:GetChildren()
    ) do

        if not child:IsA(
            "UIListLayout"
        ) then

            child:Destroy()
        end
    end


    categoryData.Items =
        {}
end


--==================================================
-- POPULATE CATEGORY
--==================================================

local function PopulateCategory(
    category,
    itemList
)

    local categoryData =
        Categories[category]


    if not categoryData then
        return false
    end


    if type(itemList) ~= "table" then

        ShowCategoryMessage(
            category,
            "Invalid category",
            Color3.fromRGB(
                255,
                80,
                80
            )
        )


        return false
    end


    ClearCategoryItems(
        category
    )


    local validCount =
        0

    local errorCount =
        0


    for index, item in ipairs(itemList) do

        local success, err =
            pcall(function()

                local itemId =
                    GetItemId(item)


                local displayName =
                    GetItemName(item)


                if not itemId
                    or itemId == "" then

                    error(
                        "Missing item id"
                    )
                end


                if not displayName
                    or displayName == "" then

                    displayName =
                        itemId
                end


                validCount +=
                    1


                local stock =
                    CurrentStock[category]
                    and CurrentStock[category][itemId]


                --==================================
                -- ROW
                --==================================

                local Row =
                    Instance.new("Frame")


                Row.Name =
                    itemId:gsub(
                        "[^%w_]",
                        "_"
                    )


                Row.LayoutOrder =
                    index


                Row.Size =
                    UDim2.new(
                        1,
                        -8,
                        0,
                        34
                    )


                Row.BackgroundColor3 =
                    Color3.fromRGB(
                        45,
                        45,
                        45
                    )


                Row.BorderSizePixel =
                    0


                Row.Parent =
                    categoryData.List


                local RowCorner =
                    Instance.new("UICorner")


                RowCorner.CornerRadius =
                    UDim.new(
                        0,
                        4
                    )


                RowCorner.Parent =
                    Row


                --==================================
                -- CHECKBOX
                --==================================

                local CheckButton =
                    Instance.new("TextButton")


                CheckButton.Name =
                    "Check"


                CheckButton.Size =
                    UDim2.fromOffset(
                        30,
                        30
                    )


                CheckButton.Position =
                    UDim2.fromOffset(
                        4,
                        2
                    )


                CheckButton.BackgroundTransparency =
                    1


                CheckButton.TextSize =
                    19


                CheckButton.Font =
                    Enum.Font.GothamBold


                local selected =
                    SelectedItems[category]
                    and SelectedItems[category][itemId]


                CheckButton.Text =
                    selected
                    and "☑"
                    or "☐"


                CheckButton.TextColor3 =
                    Color3.fromRGB(
                        200,
                        200,
                        200
                    )


                CheckButton.Parent =
                    Row


                --==================================
                -- ITEM NAME
                --==================================

                local Label =
                    Instance.new("TextLabel")


                Label.Name =
                    "Item"


                Label.Position =
                    UDim2.fromOffset(
                        38,
                        0
                    )


                Label.Size =
                    UDim2.new(
                        1,
                        -40,
                        1,
                        0
                    )


                Label.BackgroundTransparency =
                    1


                Label.TextSize =
                    13


                Label.Font =
                    Enum.Font.Gotham


                Label.TextXAlignment =
                    Enum.TextXAlignment.Left


                Label.Text =
                    displayName
                    .. "  "
                    .. GetStatusText(stock)


                Label.Parent =
                    Row


                --==================================
                -- ITEM DATA
                --==================================

                local ItemData = {

                    Category =
                        category,

                    ItemKey =
                        itemId,

                    ItemId =
                        itemId,

                    DisplayName =
                        displayName,

                    Row =
                        Row,

                    Label =
                        Label,

                    CheckButton =
                        CheckButton
                }


                categoryData.Items[itemId] =
                    ItemData


                UpdateItemVisual(
                    ItemData,
                    stock
                )


                --==================================
                -- CHECKBOX CLICK
                --==================================

                CheckButton.MouseButton1Click:Connect(
                    function()

                        if Terminated then
                            return
                        end


                        local selectedNow =
                            SelectedItems[category]
                            and SelectedItems[category][itemId]


                        SetSelected(
                            category,
                            itemId,
                            not selectedNow
                        )
                    end
                )
            end)


        if not success then

            errorCount +=
                1


            warn(
                "[ShopRestock][" ..
                category ..
                "] Item " ..
                tostring(index) ..
                " error:",
                err
            )
        end
    end


    if validCount == 0 then

        if errorCount > 0 then

            ShowCategoryMessage(
                category,
                "Error loading items",
                Color3.fromRGB(
                    255,
                    80,
                    80
                )
            )

        else

            ShowCategoryMessage(
                category,
                "No items",
                Color3.fromRGB(
                    140,
                    140,
                    140
                )
            )
        end


        return false
    end


    return true
end


--==================================================
-- CREATE CATEGORY
--==================================================

local function CreateCategory(
    category,
    order
)

    local Container =
        Instance.new("Frame")


    Container.Name =
        category


    Container.LayoutOrder =
        order


    Container.Size =
        UDim2.new(
            1,
            -2,
            0,
            40
        )


    Container.BackgroundColor3 =
        Color3.fromRGB(
            35,
            35,
            35
        )


    Container.BorderSizePixel =
        0


    Container.AutomaticSize =
        Enum.AutomaticSize.Y


    Container.Parent =
        MainScroll


    local ContainerCorner =
        Instance.new("UICorner")


    ContainerCorner.CornerRadius =
        UDim.new(
            0,
            6
        )


    ContainerCorner.Parent =
        Container


    --==============================================
    -- HEADER
    --==============================================

    local Header =
        Instance.new("TextButton")


    Header.Name =
        "Header"


    Header.Size =
        UDim2.new(
            1,
            0,
            0,
            40
        )


    Header.BackgroundTransparency =
        1


    Header.Text =
        "  "
        .. string.upper(category)
        .. "    ▼"


    Header.TextColor3 =
        Color3.new(
            1,
            1,
            1
        )


    Header.TextSize =
        15


    Header.Font =
        Enum.Font.GothamBold


    Header.TextXAlignment =
        Enum.TextXAlignment.Left


    Header.Parent =
        Container


    --==============================================
    -- ITEM SCROLL
    --==============================================

    local ItemScroll =
        Instance.new("ScrollingFrame")


    ItemScroll.Name =
        "Items"


    ItemScroll.Position =
        UDim2.fromOffset(
            0,
            40
        )


    ItemScroll.Size =
        UDim2.new(
            1,
            0,
            0,
            ITEM_SCROLL_HEIGHT
        )


    ItemScroll.BackgroundTransparency =
        1


    ItemScroll.BorderSizePixel =
        0


    ItemScroll.ScrollBarThickness =
        5


    ItemScroll.ScrollingDirection =
        Enum.ScrollingDirection.Y


    ItemScroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y


    ItemScroll.CanvasSize =
        UDim2.fromOffset(
            0,
            0
        )


    ItemScroll.Visible =
        true


    ItemScroll.Parent =
        Container


    --==============================================
    -- ITEM LAYOUT
    --==============================================

    local ItemLayout =
        Instance.new("UIListLayout")


    ItemLayout.Padding =
        UDim.new(
            0,
            2
        )


    ItemLayout.SortOrder =
        Enum.SortOrder.LayoutOrder


    ItemLayout.Parent =
        ItemScroll


    --==============================================
    -- SAVE CATEGORY
    --==============================================

    Categories[category] = {

        Frame =
            Container,

        Header =
            Header,

        List =
            ItemScroll,

        Items =
            {}
    }


    --==============================================
    -- LOADING
    --==============================================

    ShowCategoryMessage(
        category,
        "Loading..."
    )


    --==============================================
    -- CATEGORY TOGGLE
    --==============================================

    Header.MouseButton1Click:Connect(
        function()

            if Terminated then
                return
            end


            ItemScroll.Visible =
                not ItemScroll.Visible


            Header.Text =
                "  "
                .. string.upper(category)
                .. (
                    ItemScroll.Visible
                    and "    ▲"
                    or "    ▼"
                )
        end
    )
end


--==================================================
-- CREATE ALL CATEGORIES
--==================================================

for index, category in ipairs(
    CategoryOrder
) do

    CreateCategory(
        category,
        index + 5
    )
end


--==================================================
-- JSON ERROR HELPER
--==================================================

local function SetAllCategoryMessages(
    message,
    textColor
)

    for _, category
        in ipairs(CategoryOrder) do

        ShowCategoryMessage(
            category,
            message,
            textColor
        )
    end
end


--==================================================
-- LOAD SHOP.JSON
--==================================================

local function LoadShopJson()

    if SHOP_JSON_URL == ""
        or SHOP_JSON_URL:find(
            "YOUR_USERNAME",
            1,
            true
        ) then

        SetAllCategoryMessages(
            "Set shop.json URL",
            Color3.fromRGB(
                255,
                80,
                80
            )
        )


        warn(
            "[ShopRestock] SHOP_JSON_URL is not set."
        )


        return false
    end


    local success, response =
        pcall(function()

            return game:HttpGet(
                SHOP_JSON_URL
            )
        end)


    if not success then

        SetAllCategoryMessages(
            "HTTP Error",
            Color3.fromRGB(
                255,
                80,
                80
            )
        )


        warn(
            "[ShopRestock] HTTP error:",
            response
        )


        return false
    end


    if type(response) ~= "string"
        or response == "" then

        SetAllCategoryMessages(
            "Empty JSON",
            Color3.fromRGB(
                255,
                80,
                80
            )
        )


        return false
    end


    response =
        response:gsub(
            "^\239\187\191",
            ""
        )


    local decodeSuccess, decoded =
        pcall(function()

            return HttpService:JSONDecode(
                response
            )
        end)


    if not decodeSuccess then

        SetAllCategoryMessages(
            "JSON Decode Error",
            Color3.fromRGB(
                255,
                80,
                80
            )
        )


        warn(
            "[ShopRestock] JSON decode error:",
            decoded
        )


        return false
    end


    if type(decoded) ~= "table" then

        SetAllCategoryMessages(
            "JSON Root Invalid",
            Color3.fromRGB(
                255,
                80,
                80
            )
        )


        return false
    end


    ShopItems =
        decoded


    return true
end


--==================================================
-- BUILD FROM JSON
--==================================================

local function BuildFromJson()

    for _, category
        in ipairs(CategoryOrder) do

        local success, err =
            pcall(function()

                local items =
                    ShopItems[category]


                if items == nil then

                    ShowCategoryMessage(
                        category,
                        "Missing in JSON",
                        Color3.fromRGB(
                            255,
                            190,
                            70
                        )
                    )

                    return
                end


                if type(items) ~= "table" then

                    ShowCategoryMessage(
                        category,
                        "Invalid category",
                        Color3.fromRGB(
                            255,
                            80,
                            80
                        )
                    )

                    return
                end


                PopulateCategory(
                    category,
                    items
                )
            end)


        if not success then

            ShowCategoryMessage(
                category,
                "Error: " .. tostring(err),
                Color3.fromRGB(
                    255,
                    80,
                    80
                )
            )


            warn(
                "[ShopRestock][" ..
                category ..
                "] Build error:",
                err
            )
        end
    end
end


--==================================================
-- REFRESH ALL ITEMS
--==================================================

local function RefreshAllItems()

    for category, categoryData
        in pairs(Categories) do

        if categoryData.Items then

            for itemKey, itemData
                in pairs(categoryData.Items) do

                local stock =
                    CurrentStock[category]
                    and CurrentStock[category][itemKey]


                UpdateItemVisual(
                    itemData,
                    stock
                )
            end
        end
    end
end


--==================================================
-- APPLY RESTOCK
--==================================================

local function ApplyShopData(
    shopRestock
)

    if type(shopRestock) ~= "table" then
        return
    end


    local availableItems =
        shopRestock.availableItems


    if type(availableItems) ~= "table" then
        return
    end


    --==============================================
    -- COPY SERVER STOCK
    --==============================================

    for _, category
        in ipairs(CategoryOrder) do

        local data =
            availableItems[category]


        if type(data) == "table" then

            local copiedStock =
                {}


            for itemKey, stock
                in pairs(data) do

                copiedStock[itemKey] =
                    stock
            end


            CurrentStock[category] =
                copiedStock
        end
    end


    --==============================================
    -- REFRESH GUI
    --==============================================

    RefreshAllItems()


    --==============================================
    -- RESTART AUTO BUY
    --==============================================

    if AUTO_BUY then

        StopAutoBuy()

        StartAutoBuy()
    end
end


--==================================================
-- SPEED SET
--==================================================

SpeedSetButton.MouseButton1Click:Connect(
    function()

        if Terminated then
            return
        end


        local value =
            tonumber(
                SpeedBox.Text
            )


        if value then

            SPEED =
                value


            SpeedBox.Text =
                tostring(SPEED)


            ApplySpeed()

        else

            SpeedBox.Text =
                tostring(SPEED)
        end
    end
)


--==================================================
-- DEFAULT
--==================================================

DefaultButton.MouseButton1Click:Connect(
    function()

        if Terminated then
            return
        end


        SPEED =
            DEFAULT_SPEED


        SpeedBox.Text =
            tostring(SPEED)


        ApplySpeed()
    end
)


--==================================================
-- AUTO BUY CHECKBOX
--==================================================

AutoBuyButton.MouseButton1Click:Connect(
    function()

        if Terminated then
            return
        end


        AUTO_BUY =
            not AUTO_BUY


        if AUTO_BUY then

            AutoBuyButton.Text =
                "☑"


            AutoBuyButton.TextColor3 =
                Color3.new(
                    1,
                    1,
                    1
                )


            StartAutoBuy()

        else

            AutoBuyButton.Text =
                "☐"


            AutoBuyButton.TextColor3 =
                Color3.fromRGB(
                    200,
                    200,
                    200
                )


            StopAutoBuy()
        end
    end
)


--==================================================
-- FEED KING BEE
--==================================================

FeedButton.MouseButton1Click:Connect(
    function()

        if Terminated then
            return
        end


        if not RemoContainer then

            warn(
                "[ShopRestock] RemoContainer not available yet."
            )

            return
        end


        local success, err =
            pcall(function()

                RemoContainer[
                    "bee.feedKingBeeAll"
                ]:FireServer()
            end)


        if not success then

            warn(
                "[ShopRestock] Feed King Bee error:",
                err
            )
        end
    end
)


--==================================================
-- CHARACTER RESPAWN
--==================================================

Player.CharacterAdded:Connect(
    function()

        if Terminated then
            return
        end


        task.wait(1)


        ApplySpeed()
    end
)


--==================================================
-- STATE.SYNC
--==================================================

local function GetRemoContainer()

    local success, result =
        pcall(function()

            local rbxtsInclude =
                ReplicatedStorage:WaitForChild(
                    "rbxts_include",
                    10
                )


            if not rbxtsInclude then
                error("rbxts_include not found")
            end


            local nodeModules =
                rbxtsInclude:WaitForChild(
                    "node_modules",
                    10
                )


            if not nodeModules then
                error("node_modules not found")
            end


            local rbxts =
                nodeModules:WaitForChild(
                    "@rbxts",
                    10
                )


            if not rbxts then
                error("@rbxts not found")
            end


            local remo =
                rbxts:WaitForChild(
                    "remo",
                    10
                )


            if not remo then
                error("remo not found")
            end


            local src =
                remo:WaitForChild(
                    "src",
                    10
                )


            if not src then
                error("remo.src not found")
            end


            local container =
                src:WaitForChild(
                    "container",
                    10
                )


            if not container then
                error("remo container not found")
            end


            return container
        end)


    if not success then

        warn(
            "[ShopRestock] Failed to get RemoContainer:",
            result
        )


        return nil
    end


    return result
end


--==================================================
-- INITIALIZE REMOTES
--==================================================

RemoContainer =
    GetRemoContainer()


if RemoContainer then

    local StateSync =
        RemoContainer:FindFirstChild(
            "state.sync"
        )


    if StateSync then

        StateSync.OnClientEvent:Connect(
            function(payload)

                if Terminated then
                    return
                end


                if type(payload) ~= "table" then
                    return
                end


                if payload.type ~= "patch" then
                    return
                end


                if type(payload.data) ~= "table" then
                    return
                end


                --==================================
                -- ONLY NORMAL SHOP RESTOCK
                --==================================

                local shopRestock =
                    payload.data.shopRestock


                if type(shopRestock) ~= "table" then
                    return
                end


                local availableItems =
                    shopRestock.availableItems


                if type(availableItems) ~= "table" then
                    return
                end


                --==================================
                -- BLINK
                --==================================

                BlinkRestockDot()


                --==================================
                -- DELAY
                --==================================

                RestockDelayToken =
                    RestockDelayToken + 1


                local myToken =
                    RestockDelayToken


                task.spawn(function()

                    local delay =
                        1 + math.random()


                    task.wait(delay)


                    if Terminated
                        or myToken ~= RestockDelayToken then

                        return
                    end


                    ApplyShopData(
                        shopRestock
                    )
                end)
            end
        )

    else

        warn(
            "[ShopRestock] state.sync not found."
        )
    end

else

    warn(
        "[ShopRestock] RemoContainer unavailable."
    )
end


--==================================================
-- TERMINATE
--==================================================

CloseButton.MouseButton1Click:Connect(
    function()

        if Terminated then
            return
        end


        Terminated =
            true


        AUTO_BUY =
            false


        StopAutoBuy()


        BlinkToken += 1


        RestockDelayToken += 1


        SelectedItems =
            {}


        CurrentStock =
            {}


        Categories =
            {}


        ShopItems =
            {}


        ScreenGui:Destroy()
    end
)


--==================================================
-- INITIALIZE
--==================================================

ApplySpeed()


task.spawn(
    function()

        if Terminated then
            return
        end


        local success, err =
            pcall(function()

                local loaded =
                    LoadShopJson()


                if Terminated then
                    return
                end


                if loaded then

                    BuildFromJson()

                end
            end)


        if not success then

            warn(
                "[ShopRestock] Initialization error:",
                err
            )


            if not Terminated then

                SetAllCategoryMessages(
                    "Initialization Error",
                    Color3.fromRGB(
                        255,
                        80,
                        80
                    )
                )
            end
        end
    end
)
