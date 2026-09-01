--Farm a fish: bee event

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
-- REMOTE CONTAINER
--==================================================

local RemoContainer =
    ReplicatedStorage
        .rbxts_include
        .node_modules["@rbxts"]
        .remo
        .src
        .container

local StateSync = RemoContainer["state.sync"]
local PurchaseEvent = RemoContainer["shop.purchaseEventItem"]
local FeedKingBeeEvent = RemoContainer["bee.feedKingBeeAll"]


--==================================================
-- SETTINGS
--==================================================

-- Replace with your raw GitHub shop.json URL.
local SHOP_JSON_URL =
    "https://raw.githubusercontent.com/jezz-lab/repo/main/bee2/shop.json"

local DEFAULT_SPEED = 16
local SPEED = DEFAULT_SPEED

local AUTO_RUNNING = false

-- Change this later if needed.
local RESTOCK_BLINK_DURATION = 2

local STATE_CHECK_INTERVAL = 0.03
local PURCHASE_CONFIRM_TIMEOUT = 2

-- Maximum visible height for each category item list.
local ITEM_SCROLL_HEIGHT = 150


--==================================================
-- STATE
--==================================================

local ShopItems = {}

local SelectedItems = {}
local CurrentStock = {}

local Buying = {}
local Categories = {}

local BlinkToken = 0
local Terminated = false


--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Farm a Fish: Bee Event"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui


--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(360, 450)
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
-- CLOSE BUTTON
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
MainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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


local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Position = UDim2.new(1, -95, 0, 6)
StartButton.Size = UDim2.fromOffset(85, 30)
StartButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
StartButton.BorderSizePixel = 0
StartButton.Text = "Start"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.TextSize = 14
StartButton.Font = Enum.Font.GothamBold
StartButton.Parent = SpeedFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 4)
StartCorner.Parent = StartButton


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
-- DRAG FUNCTION
--==================================================

local function MakeDraggable(object, dragHandle)

    dragHandle = dragHandle or object

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

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging or Terminated then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        object.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

MakeDraggable(Main, TitleBar)


--==================================================
-- FLOATING TOGGLE ICON
--==================================================

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleIcon"
ToggleButton.Size = UDim2.fromOffset(52, 52)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -26)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "S"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.ZIndex = 30
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

MakeDraggable(ToggleButton)

ToggleButton.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    Main.Visible = not Main.Visible
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


local function GetStatusText(stock)

    if IsAvailable(stock) then
        return "[" .. tostring(stock) .. "]"
    end

    if IsNone(stock) then
        return "[Unavailable]"
    end

    return "[Not Restocked]"
end


--==================================================
-- SPEED
--==================================================

local function ApplySpeed()

    if Terminated then
        return
    end

    local Character = Player.Character

    if not Character then
        return
    end

    local Humanoid =
        Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid.WalkSpeed = SPEED
    end
end


--==================================================
-- RESTOCK BLINK
--==================================================

local function BlinkRestockDot()

    BlinkToken += 1

    local token = BlinkToken

    task.spawn(function()

        local endTime =
            os.clock() + RESTOCK_BLINK_DURATION

        local green = true

        while os.clock() < endTime do

            if Terminated then
                return
            end

            if token ~= BlinkToken then
                return
            end

            RestockDot.Visible = true

            if green then

                RestockDot.BackgroundColor3 =
                    Color3.fromRGB(0, 255, 0)

            else

                RestockDot.BackgroundColor3 =
                    Color3.fromRGB(255, 0, 0)
            end

            green = not green

            task.wait(0.15)
        end

        if not Terminated
            and token == BlinkToken then

            RestockDot.Visible = false
        end
    end)
end


--==================================================
-- UPDATE ITEM VISUAL
--==================================================

local function UpdateItemVisual(itemData, stock)

    if not itemData then
        return
    end

    local selected =
        SelectedItems[itemData.Category]
        and SelectedItems[itemData.Category][itemData.ItemName]

    itemData.Label.Text =
        itemData.ItemName
        .. "  "
        .. GetStatusText(stock)

    itemData.CheckButton.Text =
        selected and "☑" or "☐"

    if IsAvailable(stock) then

        itemData.Label.TextColor3 =
            Color3.new(1, 1, 1)

        itemData.CheckButton.TextColor3 =
            Color3.new(1, 1, 1)

    else

        itemData.Label.TextColor3 =
            Color3.fromRGB(150, 150, 150)

        itemData.CheckButton.TextColor3 =
            Color3.fromRGB(150, 150, 150)
    end
end


--==================================================
-- AUTO BUY
--==================================================

local function AutoBuy(category, itemName)

    local key =
        category .. ":" .. itemName

    if Buying[key] then
        return
    end

    Buying[key] = true

    task.spawn(function()

        while not Terminated
            and AUTO_RUNNING do

            if not SelectedItems[category]
                or not SelectedItems[category][itemName] then

                break
            end

            local categoryStock =
                CurrentStock[category]

            if not categoryStock then
                break
            end

            local stock =
                categoryStock[itemName]

            -- Only a positive number can be purchased.
            if not IsAvailable(stock) then
                break
            end

            local oldStock = stock

            -- Purchase request.
            PurchaseEvent:FireServer(itemName)

            -- Wait for the next state update.
            local changed = false
            local checkStart = os.clock()

            while not Terminated
                and AUTO_RUNNING
                and os.clock() - checkStart
                    < PURCHASE_CONFIRM_TIMEOUT do

                task.wait(STATE_CHECK_INTERVAL)

                local latestCategory =
                    CurrentStock[category]

                local latestStock =
                    latestCategory
                    and latestCategory[itemName]

                if latestStock ~= oldStock then

                    changed = true
                    break
                end
            end

            -- Prevent endless firing if server state
            -- doesn't confirm the purchase.
            if not changed then
                break
            end
        end

        Buying[key] = nil
    end)
end


--==================================================
-- SET SELECTION
--==================================================

local function SetSelected(
    category,
    itemName,
    enabled
)

    SelectedItems[category] =
        SelectedItems[category] or {}

    SelectedItems[category][itemName] =
        enabled

    local categoryData =
        Categories[category]

    if categoryData then

        local itemData =
            categoryData.Items[itemName]

        if itemData then

            local stock =
                CurrentStock[category]
                and CurrentStock[category][itemName]

            UpdateItemVisual(
                itemData,
                stock
            )
        end
    end

    -- Immediately buy if selected,
    -- started, and currently stocked.
    if enabled
        and AUTO_RUNNING then

        local stock =
            CurrentStock[category]
            and CurrentStock[category][itemName]

        if IsAvailable(stock) then

            AutoBuy(
                category,
                itemName
            )
        end
    end
end


--==================================================
-- CREATE EMPTY CATEGORY
--==================================================

local function CreateEmptyCategory(
    category,
    order
)

    local Container = Instance.new("Frame")
    Container.Name = category
    Container.LayoutOrder = order

    Container.Size =
        UDim2.new(1, -2, 0, 40)

    Container.BackgroundColor3 =
        Color3.fromRGB(35, 35, 35)

    Container.BorderSizePixel = 0
    Container.AutomaticSize =
        Enum.AutomaticSize.Y

    Container.Parent = MainScroll


    local ContainerCorner =
        Instance.new("UICorner")

    ContainerCorner.CornerRadius =
        UDim.new(0, 6)

    ContainerCorner.Parent =
        Container


    --==================================================
    -- CATEGORY HEADER
    --==================================================

    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size =
        UDim2.new(1, 0, 0, 40)

    Header.BackgroundTransparency = 1

    Header.Text =
        "  "
        .. string.upper(category)
        .. "    ▼"

    Header.TextColor3 =
        Color3.new(1, 1, 1)

    Header.TextSize = 15
    Header.Font =
        Enum.Font.GothamBold

    Header.TextXAlignment =
        Enum.TextXAlignment.Left

    Header.Parent = Container


    --==================================================
    -- ITEM SCROLL
    --==================================================

    local ItemScroll =
        Instance.new("ScrollingFrame")

    ItemScroll.Name = "Items"

    ItemScroll.Position =
        UDim2.fromOffset(0, 40)

    ItemScroll.Size =
        UDim2.new(
            1,
            0,
            0,
            ITEM_SCROLL_HEIGHT
        )

    ItemScroll.BackgroundTransparency = 1
    ItemScroll.BorderSizePixel = 0

    ItemScroll.ScrollBarThickness = 5

    ItemScroll.ScrollingDirection =
        Enum.ScrollingDirection.Y

    ItemScroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    ItemScroll.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    ItemScroll.Visible = true

    ItemScroll.Parent = Container


    --==================================================
    -- ITEM LAYOUT
    --==================================================

    local ItemLayout =
        Instance.new("UIListLayout")

    ItemLayout.Padding =
        UDim.new(0, 2)

    ItemLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    ItemLayout.Parent = ItemScroll


    --==================================================
    -- CATEGORY DATA
    --==================================================

    Categories[category] = {
        Frame = Container,
        Header = Header,
        List = ItemScroll,
        Items = {}
    }


    --==================================================
    -- LOADING MESSAGE
    --==================================================

    local Loading =
        Instance.new("TextLabel")

    Loading.Name = "Loading"
    Loading.LayoutOrder = 1
    Loading.Size =
        UDim2.new(1, -10, 0, 30)

    Loading.BackgroundTransparency = 1

    Loading.Text =
        "  Loading..."

    Loading.TextColor3 =
        Color3.fromRGB(140, 140, 140)

    Loading.TextSize = 13
    Loading.Font = Enum.Font.Gotham

    Loading.TextXAlignment =
        Enum.TextXAlignment.Left

    Loading.Parent = ItemScroll


    --==================================================
    -- OPEN / CLOSE
    --==================================================

    Header.MouseButton1Click:Connect(function()

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
    end)
end


--==================================================
-- CREATE DROPDOWNS IMMEDIATELY
--==================================================

CreateEmptyCategory("gear", 5)
CreateEmptyCategory("event", 6)
CreateEmptyCategory("bait", 7)
CreateEmptyCategory("eggs", 8)


--==================================================
-- CLEAR ITEMS
--==================================================

local function ClearCategoryItems(category)

    local categoryData =
        Categories[category]

    if not categoryData then
        return
    end

    for _, child in ipairs(
        categoryData.List:GetChildren()
    ) do

        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    categoryData.Items = {}
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
        return
    end

    if type(itemList) ~= "table" then
        return
    end

    ClearCategoryItems(category)


    for index, itemName
        in ipairs(itemList) do

        if type(itemName) ~= "string" then
            continue
        end

        local stock =
            CurrentStock[category]
            and CurrentStock[category][itemName]


        --==================================================
        -- ITEM ROW
        --==================================================

        local Row = Instance.new("Frame")

        Row.Name = itemName
        Row.LayoutOrder = index

        Row.Size =
            UDim2.new(1, -8, 0, 34)

        Row.BackgroundColor3 =
            Color3.fromRGB(45, 45, 45)

        Row.BorderSizePixel = 0
        Row.Parent = categoryData.List


        local RowCorner =
            Instance.new("UICorner")

        RowCorner.CornerRadius =
            UDim.new(0, 4)

        RowCorner.Parent = Row


        --==================================================
        -- CHECKBOX
        --==================================================

        local CheckButton =
            Instance.new("TextButton")

        CheckButton.Name = "Check"

        CheckButton.Size =
            UDim2.fromOffset(30, 30)

        CheckButton.Position =
            UDim2.fromOffset(4, 2)

        CheckButton.BackgroundTransparency = 1

        CheckButton.TextSize = 19

        CheckButton.Font =
            Enum.Font.GothamBold

        local selected =
            SelectedItems[category]
            and SelectedItems[category][itemName]

        CheckButton.Text =
            selected and "☑" or "☐"

        CheckButton.TextColor3 =
            Color3.fromRGB(200, 200, 200)

        CheckButton.Parent = Row


        --==================================================
        -- ITEM NAME
        --==================================================

        local Label =
            Instance.new("TextLabel")

        Label.Name = "Item"

        Label.Position =
            UDim2.fromOffset(38, 0)

        Label.Size =
            UDim2.new(1, -40, 1, 0)

        Label.BackgroundTransparency = 1

        Label.TextSize = 13

        Label.Font =
            Enum.Font.Gotham

        Label.TextXAlignment =
            Enum.TextXAlignment.Left

        Label.Text =
            itemName
            .. "  "
            .. GetStatusText(stock)

        Label.Parent = Row


        --==================================================
        -- ITEM DATA
        --==================================================

        local ItemData = {
            Category = category,
            ItemName = itemName,
            Row = Row,
            Label = Label,
            CheckButton = CheckButton
        }

        categoryData.Items[itemName] =
            ItemData


        UpdateItemVisual(
            ItemData,
            stock
        )


        --==================================================
        -- CHECKBOX CLICK
        --==================================================

        CheckButton.MouseButton1Click:Connect(function()

            if Terminated then
                return
            end

            local selectedNow =
                SelectedItems[category]
                and SelectedItems[category][itemName]

            SetSelected(
                category,
                itemName,
                not selectedNow
            )
        end)
    end


    --==================================================
    -- EMPTY JSON CATEGORY
    --==================================================

    if #itemList == 0 then

        local Empty =
            Instance.new("TextLabel")

        Empty.Name = "Empty"
        Empty.LayoutOrder = 1

        Empty.Size =
            UDim2.new(1, -10, 0, 30)

        Empty.BackgroundTransparency = 1

        Empty.Text =
            "  No items"

        Empty.TextColor3 =
            Color3.fromRGB(140, 140, 140)

        Empty.TextSize = 13

        Empty.Font =
            Enum.Font.Gotham

        Empty.TextXAlignment =
            Enum.TextXAlignment.Left

        Empty.Parent =
            categoryData.List
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

        warn(
            "[ShopRestock] Set SHOP_JSON_URL first."
        )

        for _, category in ipairs({
            "gear",
            "event",
            "bait",
            "eggs"
        }) do

            ClearCategoryItems(category)

            local categoryData =
                Categories[category]

            if categoryData then

                local ErrorLabel =
                    Instance.new("TextLabel")

                ErrorLabel.Name = "Error"

                ErrorLabel.Size =
                    UDim2.new(1, -10, 0, 30)

                ErrorLabel.BackgroundTransparency = 1

                ErrorLabel.Text =
                    "  Set shop.json URL"

                ErrorLabel.TextColor3 =
                    Color3.fromRGB(180, 100, 100)

                ErrorLabel.TextSize = 13
                ErrorLabel.Font = Enum.Font.Gotham

                ErrorLabel.TextXAlignment =
                    Enum.TextXAlignment.Left

                ErrorLabel.Parent =
                    categoryData.List
            end
        end

        return false
    end


    --==================================================
    -- SHOW LOADING
    --==================================================

    for _, category in ipairs({
        "gear",
        "event",
        "bait",
        "eggs"
    }) do

        ClearCategoryItems(category)

        local categoryData =
            Categories[category]

        if categoryData then

            local Loading =
                Instance.new("TextLabel")

            Loading.Name = "Loading"

            Loading.Size =
                UDim2.new(1, -10, 0, 30)

            Loading.BackgroundTransparency = 1

            Loading.Text =
                "  Loading..."

            Loading.TextColor3 =
                Color3.fromRGB(140, 140, 140)

            Loading.TextSize = 13
            Loading.Font = Enum.Font.Gotham

            Loading.TextXAlignment =
                Enum.TextXAlignment.Left

            Loading.Parent =
                categoryData.List
        end
    end


    --==================================================
    -- HTTP REQUEST
    --==================================================

    local success, response =
        pcall(function()

            return game:HttpGet(
                SHOP_JSON_URL
            )

        end)


    if Terminated then
        return false
    end


    if not success then

        warn(
            "[ShopRestock] Failed to fetch shop.json:",
            response
        )

        for _, category in ipairs({
            "gear",
            "event",
            "bait",
            "eggs"
        }) do

            ClearCategoryItems(category)

            local categoryData =
                Categories[category]

            if categoryData then

                local ErrorLabel =
                    Instance.new("TextLabel")

                ErrorLabel.Name = "Error"

                ErrorLabel.Size =
                    UDim2.new(1, -10, 0, 30)

                ErrorLabel.BackgroundTransparency = 1

                ErrorLabel.Text =
                    "  Failed to load"

                ErrorLabel.TextColor3 =
                    Color3.fromRGB(180, 100, 100)

                ErrorLabel.TextSize = 13
                ErrorLabel.Font = Enum.Font.Gotham

                ErrorLabel.TextXAlignment =
                    Enum.TextXAlignment.Left

                ErrorLabel.Parent =
                    categoryData.List
            end
        end

        return false
    end


    if type(response) ~= "string"
        or response == "" then

        warn(
            "[ShopRestock] shop.json is empty."
        )

        return false
    end


    --==================================================
    -- JSON DECODE
    --==================================================

    local decodeSuccess, decoded =
        pcall(function()

            return HttpService:JSONDecode(
                response
            )

        end)


    if not decodeSuccess
        or type(decoded) ~= "table" then

        warn(
            "[ShopRestock] Invalid shop.json:",
            decoded
        )

        for _, category in ipairs({
            "gear",
            "event",
            "bait",
            "eggs"
        }) do

            ClearCategoryItems(category)

            local categoryData =
                Categories[category]

            if categoryData then

                local ErrorLabel =
                    Instance.new("TextLabel")

                ErrorLabel.Name = "Error"

                ErrorLabel.Size =
                    UDim2.new(1, -10, 0, 30)

                ErrorLabel.BackgroundTransparency = 1

                ErrorLabel.Text =
                    "  Invalid JSON"

                ErrorLabel.TextColor3 =
                    Color3.fromRGB(180, 100, 100)

                ErrorLabel.TextSize = 13
                ErrorLabel.Font = Enum.Font.Gotham

                ErrorLabel.TextXAlignment =
                    Enum.TextXAlignment.Left

                ErrorLabel.Parent =
                    categoryData.List
            end
        end

        return false
    end


    ShopItems = decoded

    return true
end


--==================================================
-- BUILD FROM JSON
--==================================================

local function BuildFromJson()

    local CategoryOrder = {
        "gear",
        "event",
        "bait",
        "eggs"
    }

    for _, category in ipairs(CategoryOrder) do

        local items =
            ShopItems[category]

        if type(items) == "table" then

            PopulateCategory(
                category,
                items
            )

        else

            ClearCategoryItems(category)

            local categoryData =
                Categories[category]

            if categoryData then

                local Empty =
                    Instance.new("TextLabel")

                Empty.Name = "Empty"

                Empty.Size =
                    UDim2.new(1, -10, 0, 30)

                Empty.BackgroundTransparency = 1

                Empty.Text =
                    "  No items"

                Empty.TextColor3 =
                    Color3.fromRGB(140, 140, 140)

                Empty.TextSize = 13
                Empty.Font = Enum.Font.Gotham

                Empty.TextXAlignment =
                    Enum.TextXAlignment.Left

                Empty.Parent =
                    categoryData.List
            end
        end
    end
end


--==================================================
-- REFRESH ITEMS
--==================================================

local function RefreshAllItems()

    for category, categoryData
        in pairs(Categories) do

        for itemName, itemData
            in pairs(categoryData.Items) do

            local stock =
                CurrentStock[category]
                and CurrentStock[category][itemName]

            UpdateItemVisual(
                itemData,
                stock
            )
        end
    end
end


--==================================================
-- APPLY SHOP DATA
--==================================================

local function ApplyShopData(shopRestock)

    if type(shopRestock) ~= "table" then
        return
    end

    local availableItems =
        shopRestock.availableItems

    if type(availableItems) ~= "table" then
        return
    end


    -- Update only categories included
    -- in the state.sync packet.
    for _, category in ipairs({
        "gear",
        "event",
        "bait",
        "eggs"
    }) do

        if type(availableItems[category])
            == "table" then

            CurrentStock[category] =
                availableItems[category]
        end
    end


    -- Update stock/status text.
    RefreshAllItems()


    --==================================================
    -- AUTO RESUME AFTER RESTOCK
    --==================================================

    if not AUTO_RUNNING then
        return
    end

    for category, selected
        in pairs(SelectedItems) do

        local categoryStock =
            CurrentStock[category]

        if categoryStock then

            for itemName, enabled
                in pairs(selected) do

                if enabled then

                    local stock =
                        categoryStock[itemName]

                    if IsAvailable(stock) then

                        AutoBuy(
                            category,
                            itemName
                        )
                    end
                end
            end
        end
    end
end


--==================================================
-- SPEED INPUT
--==================================================

SpeedBox.FocusLost:Connect(function()

    if Terminated then
        return
    end

    local value =
        tonumber(SpeedBox.Text)

    if value then

        SPEED = value

        SpeedBox.Text =
            tostring(SPEED)

        ApplySpeed()

    else

        SpeedBox.Text =
            tostring(SPEED)
    end
end)


--==================================================
-- DEFAULT
--==================================================

DefaultButton.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    SPEED = DEFAULT_SPEED

    SpeedBox.Text =
        tostring(SPEED)

    ApplySpeed()
end)


--==================================================
-- START / STOP
--==================================================

StartButton.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    AUTO_RUNNING =
        not AUTO_RUNNING

    if AUTO_RUNNING then

        StartButton.Text = "Stop"

        -- Start currently selected items.
        for category, selected
            in pairs(SelectedItems) do

            local categoryStock =
                CurrentStock[category]

            if categoryStock then

                for itemName, enabled
                    in pairs(selected) do

                    if enabled then

                        local stock =
                            categoryStock[itemName]

                        if IsAvailable(stock) then

                            AutoBuy(
                                category,
                                itemName
                            )
                        end
                    end
                end
            end
        end

    else

        StartButton.Text = "Start"
    end
end)


--==================================================
-- FEED KING BEE
--==================================================

FeedButton.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    FeedKingBeeEvent:FireServer()
end)


--==================================================
-- CHARACTER RESPAWN
--==================================================

Player.CharacterAdded:Connect(function()

    if Terminated then
        return
    end

    task.wait(1)

    ApplySpeed()
end)


--==================================================
-- STATE.SYNC
--==================================================

StateSync.OnClientEvent:Connect(function(payload)

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

    local shopRestock =
        payload.data.shopRestock

    if not shopRestock then
        return
    end

    BlinkRestockDot()

    ApplyShopData(shopRestock)
end)


--==================================================
-- TERMINATE
--==================================================

CloseButton.MouseButton1Click:Connect(function()

    if Terminated then
        return
    end

    Terminated = true

    AUTO_RUNNING = false

    BlinkToken += 1

    SelectedItems = {}
    CurrentStock = {}
    Buying = {}
    Categories = {}
    ShopItems = {}

    ScreenGui:Destroy()
end)


--==================================================
-- INITIALIZATION
--==================================================

-- Main GUI + empty dropdowns already exist.
ApplySpeed()

-- Load JSON AFTER GUI creation.
task.spawn(function()

    local loaded =
        LoadShopJson()

    if Terminated then
        return
    end

    if loaded then
        BuildFromJson()
    end
end)
