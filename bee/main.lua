--==================================================
-- FARM A FISH | BEE EVENT
--==================================================

--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local RepSto = game:GetService("ReplicatedStorage")

--// PLAYER
local player = Players.LocalPlayer
if not player then
    error("LocalPlayer not available")
end

local pGui = player:WaitForChild("PlayerGui")

--// CONFIG
local BASE_URL = "https://raw.githubusercontent.com/jezz-lab/repo/main/bee/"
local ERROR_PANEL_URL = BASE_URL .. "ErrorPanel.lua"

local FRAME_W = 300
local MIN_H = 200
local MAX_H = 520
local INV_CHECK = 0.2

--==================================================
-- REMOVE OLD GUI
--==================================================

local old = pGui:FindFirstChild("ActionGui")

if old then
    old:Destroy()
end

--==================================================
-- ERROR PANEL
--==================================================

local ErrorPanel

do
    local ok, mod = xpcall(function()

        if not game.HttpGet then
            error("HttpGet unavailable")
        end

        local src = game:HttpGet(ERROR_PANEL_URL)

        if not src or src == "" then
            error("ErrorPanel.lua returned empty source")
        end

        if not loadstring then
            error("loadstring unavailable")
        end

        local fn = loadstring(src)

        if not fn then
            error("Failed to compile ErrorPanel.lua")
        end

        local m = fn()

        if type(m) ~= "table" then
            error("ErrorPanel did not return a table")
        end

        if type(m.Init) ~= "function" then
            error("ErrorPanel.Init missing")
        end

        if type(m.Add) ~= "function" then
            error("ErrorPanel.Add missing")
        end

        if type(m.Toggle) ~= "function" then
            error("ErrorPanel.Toggle missing")
        end

        return m

    end, function(e)
        return debug.traceback(tostring(e), 2)
    end)

    if ok then
        ErrorPanel = mod
    else
        warn("[ActionGui] ErrorPanel load failed:\n" .. tostring(mod))
    end
end

--==================================================
-- SAFE REMOTE LOOKUP
--==================================================

local function getBeeContainer()
    local include = RepSto:FindFirstChild("rbxts_include")

    if not include then
        return nil
    end

    local nodeModules = include:FindFirstChild("node_modules")

    if not nodeModules then
        return nil
    end

    local rbxts = nodeModules:FindFirstChild("@rbxts")

    if not rbxts then
        return nil
    end

    local remo = rbxts:FindFirstChild("remo")

    if not remo then
        return nil
    end

    local src = remo:FindFirstChild("src")

    if not src then
        return nil
    end

    local container = src:FindFirstChild("container")

    if not container then
        return nil
    end

    return container
end

local function getRemote(name)
    local container = getBeeContainer()

    if not container then
        return nil
    end

    return container:FindFirstChild(name)
end

--==================================================
-- MAIN SCRIPT
--==================================================

local startupSuccess, startupError = xpcall(function()

    --==================================================
    -- GUI
    --==================================================

    local gui = Instance.new("ScreenGui")
    gui.Name = "ActionGui"
    gui.ResetOnSpawn = false
    gui.Parent = pGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.fromOffset(FRAME_W, MIN_H)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    --==================================================
    -- TOGGLE ICON
    --==================================================

    local toggle = Instance.new("TextButton")
    toggle.Name = "ToggleIcon"
    toggle.Text = "⚡"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 24
    toggle.Font = Enum.Font.GothamBold
    toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggle.BorderSizePixel = 0
    toggle.Size = UDim2.fromOffset(45, 45)
    toggle.Position = UDim2.fromOffset(15, 100)
    toggle.AutoButtonColor = false
    toggle.Parent = gui

    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

    --==================================================
    -- TOGGLE DRAG
    --==================================================

    local iconDrag = false
    local iconStart = nil
    local iconStartPos = nil
    local iconMoved = false

    toggle.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            iconDrag = true
            iconMoved = false

            iconStart = input.Position
            iconStartPos = toggle.Position

            input.Changed:Connect(function()

                if input.UserInputState == Enum.UserInputState.End then
                    iconDrag = false
                end

            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)

        if not iconDrag then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - iconStart

        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            iconMoved = true
        end

        toggle.Position = UDim2.new(
            iconStartPos.X.Scale,
            iconStartPos.X.Offset + delta.X,
            iconStartPos.Y.Scale,
            iconStartPos.Y.Offset + delta.Y
        )
    end)

    --==================================================
    -- TITLE
    --==================================================

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "Farm a Fish: Bee Event"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -60, 0, 40)
    title.Position = UDim2.fromOffset(10, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    --==================================================
    -- CLOSE
    --==================================================

    local close = Instance.new("TextButton")
    close.Name = "CloseButton"
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.BorderSizePixel = 0
    close.Size = UDim2.fromOffset(40, 35)
    close.Position = UDim2.new(1, -45, 0, 5)
    close.AutoButtonColor = false
    close.Parent = frame

    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

    --==================================================
    -- BUTTON CONTAINER
    --==================================================

    local btnFrame = Instance.new("Frame")
    btnFrame.Name = "Buttons"
    btnFrame.BackgroundTransparency = 1
    btnFrame.Size = UDim2.new(1, -20, 1, -95)
    btnFrame.Position = UDim2.fromOffset(10, 45)
    btnFrame.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = btnFrame

    --==================================================
    -- FOOTER
    --==================================================

    local footer = Instance.new("Frame")
    footer.Name = "NotificationFooter"
    footer.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    footer.BorderSizePixel = 0
    footer.Size = UDim2.new(1, -20, 0, 35)
    footer.Position = UDim2.new(0, 10, 1, -45)
    footer.Parent = frame

    Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 6)

    local footerLabel = Instance.new("TextLabel")
    footerLabel.Name = "FooterLabel"
    footerLabel.Text = "Ready"
    footerLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    footerLabel.TextSize = 12
    footerLabel.Font = Enum.Font.Gotham
    footerLabel.BackgroundTransparency = 1
    footerLabel.Size = UDim2.new(1, -45, 1, 0)
    footerLabel.Position = UDim2.fromOffset(10, 0)
    footerLabel.TextXAlignment = Enum.TextXAlignment.Left
    footerLabel.Parent = footer

    local notifBtn = Instance.new("TextButton")
    notifBtn.Name = "NotificationIcon"
    notifBtn.Text = "⚠"
    notifBtn.TextColor3 = Color3.new(1, 1, 1)
    notifBtn.TextSize = 17
    notifBtn.Font = Enum.Font.GothamBold
    notifBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    notifBtn.BorderSizePixel = 0
    notifBtn.Size = UDim2.fromOffset(30, 30)
    notifBtn.Position = UDim2.new(1, -33, 0.5, -15)
    notifBtn.AutoButtonColor = false
    notifBtn.Parent = footer

    Instance.new("UICorner", notifBtn).CornerRadius = UDim.new(0, 7)

    --==================================================
    -- ERROR HELPERS
    --==================================================

    local function addError(action, message)

        warn(
            "[ActionGui] " ..
            tostring(action) ..
            ":\n" ..
            tostring(message)
        )

        if ErrorPanel then
            pcall(function()
                ErrorPanel:Add(action, message)
            end)
        end
    end

    local function notifyFailure(action, message)

        footerLabel.Text = tostring(action) .. " failed"
        notifBtn.Text = "⚠"

        addError(action, message)
    end

    local function notifySuccess(action)

        footerLabel.Text = tostring(action) .. " completed"
        notifBtn.Text = "✓"
    end

    notifBtn.MouseEnter:Connect(function()
        notifBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    end)

    notifBtn.MouseLeave:Connect(function()
        notifBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end)

    notifBtn.MouseButton1Click:Connect(function()

        if ErrorPanel then
            pcall(function()
                ErrorPanel:Toggle()
            end)
        end

    end)

    if ErrorPanel then
        pcall(function()
            ErrorPanel:Init(gui)
        end)
    end

    --==================================================
    -- RUN ACTION
    --==================================================

    local function runAction(name, callback)

        local ok, result = xpcall(
            callback,
            function(e)
                return debug.traceback(tostring(e), 2)
            end
        )

        if ok then
            notifySuccess(name)
            return true
        end

        notifyFailure(name, result)

        return false
    end

    --==================================================
    -- CREATE ROW
    --==================================================

    local function createRow(name, order, height)

        local row = Instance.new("Frame")
        row.Name = name .. "Row"
        row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, 0, 0, height or 40)
        row.LayoutOrder = order
        row.Parent = btnFrame

        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        return row
    end

    --==================================================
    -- CREATE BUTTON
    --==================================================

    local function makeButton(parent, text, x, y, w, h, bg, callback)

        local normalColor = bg or Color3.fromRGB(65, 65, 65)

        local button = Instance.new("TextButton")
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 11
        button.Font = Enum.Font.GothamBold
        button.BackgroundColor3 = normalColor
        button.BorderSizePixel = 0
        button.Size = UDim2.fromOffset(w or 30, h or 30)
        button.Position = UDim2.fromOffset(x or 0, y or 0)
        button.AutoButtonColor = false
        button.Parent = parent

        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = normalColor
        end)

        button.MouseButton1Down:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)

        button.MouseButton1Up:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)

        if callback then
            button.MouseButton1Click:Connect(callback)
        end

        return button
    end

    --==================================================
    -- SPEED
    --==================================================

    local speedRow = createRow("Speed", 0)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "Label"
    speedLabel.Text = "Speed"
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.BackgroundTransparency = 1
    speedLabel.Size = UDim2.new(1, -150, 1, 0)
    speedLabel.Position = UDim2.fromOffset(10, 0)
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedRow

    local speedInput = Instance.new("TextBox")
    speedInput.Name = "SpeedInput"
    speedInput.Text = "16"
    speedInput.PlaceholderText = "Speed"
    speedInput.TextColor3 = Color3.new(1, 1, 1)
    speedInput.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
    speedInput.TextSize = 13
    speedInput.Font = Enum.Font.Gotham
    speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    speedInput.BorderSizePixel = 0
    speedInput.Size = UDim2.fromOffset(60, 30)
    speedInput.Position = UDim2.new(1, -135, 0.5, -15)
    speedInput.ClearTextOnFocus = false
    speedInput.Parent = speedRow

    Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 5)

    local speedBtn = makeButton(
        speedRow,
        "Set",
        0,
        0,
        55,
        30,
        Color3.fromRGB(65, 65, 65),
        function()

            runAction("Set Speed", function()

                local character = player.Character

                if not character then
                    error("No character")
                end

                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if not humanoid then
                    error("No humanoid")
                end

                local speed = tonumber(speedInput.Text)

                if not speed or speed < 0 then
                    error("Invalid speed")
                end

                humanoid.WalkSpeed = speed

            end)
        end
    )

    speedBtn.Position = UDim2.new(1, -68, 0.5, -15)

    --==================================================
    -- AUTO INSERT
    --==================================================

    local autoInsertEnabled = false
    local autoInsertChoice = "Left"

    local autoRow = createRow("AutoInsert", 1)

    local autoCheck = Instance.new("TextButton")
    autoCheck.Name = "CheckBox"
    autoCheck.Text = "☐"
    autoCheck.TextColor3 = Color3.new(1, 1, 1)
    autoCheck.TextSize = 20
    autoCheck.Font = Enum.Font.GothamBold
    autoCheck.BackgroundTransparency = 1
    autoCheck.Size = UDim2.fromOffset(30, 40)
    autoCheck.Position = UDim2.fromOffset(5, 0)
    autoCheck.AutoButtonColor = false
    autoCheck.Parent = autoRow

    local autoLabel = Instance.new("TextLabel")
    autoLabel.Name = "Label"
    autoLabel.Text = "Auto Insert"
    autoLabel.TextColor3 = Color3.new(1, 1, 1)
    autoLabel.TextSize = 13
    autoLabel.Font = Enum.Font.Gotham
    autoLabel.BackgroundTransparency = 1
    autoLabel.Size = UDim2.fromOffset(100, 40)
    autoLabel.Position = UDim2.fromOffset(32, 0)
    autoLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoLabel.Parent = autoRow

    local dropdown = Instance.new("TextButton")
    dropdown.Name = "Dropdown"
    dropdown.Text = "Left ▼"
    dropdown.TextColor3 = Color3.new(1, 1, 1)
    dropdown.TextSize = 11
    dropdown.Font = Enum.Font.Gotham
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropdown.BorderSizePixel = 0
    dropdown.Size = UDim2.fromOffset(90, 30)
    dropdown.Position = UDim2.new(1, -100, 0.5, -15)
    dropdown.AutoButtonColor = false
    dropdown.Parent = autoRow

    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 5)

    local optFrame = Instance.new("Frame")
    optFrame.Name = "Options"
    optFrame.Visible = false
    optFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    optFrame.BorderSizePixel = 0
    optFrame.Size = UDim2.fromOffset(90, 84)
    optFrame.Position = UDim2.new(1, -100, 1, 3)
    optFrame.ZIndex = 50
    optFrame.Parent = autoRow

    local optLayout = Instance.new("UIListLayout")
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optLayout.Parent = optFrame

    for _, option in ipairs({"Left", "Middle", "Right"}) do

        local optionButton = Instance.new("TextButton")
        optionButton.Name = option
        optionButton.Text = "☐ " .. option
        optionButton.TextColor3 = Color3.new(1, 1, 1)
        optionButton.TextSize = 11
        optionButton.Font = Enum.Font.Gotham
        optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        optionButton.BorderSizePixel = 0
        optionButton.Size = UDim2.new(1, 0, 0, 28)
        optionButton.ZIndex = 51
        optionButton.Parent = optFrame

        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)

        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end)

        optionButton.MouseButton1Click:Connect(function()

            autoInsertChoice = option
            dropdown.Text = option .. " ▼"
            optFrame.Visible = false

        end)
    end

    autoCheck.MouseButton1Click:Connect(function()

        autoInsertEnabled = not autoInsertEnabled

        autoCheck.Text = autoInsertEnabled and "☑" or "☐"

        if autoInsertEnabled then
            footerLabel.Text = "Auto Insert: " .. autoInsertChoice
        else
            footerLabel.Text = "Auto Insert disabled"
        end

    end)

    dropdown.MouseButton1Click:Connect(function()
        optFrame.Visible = not optFrame.Visible
    end)

    --==================================================
    -- FISH REQUIREMENTS
    --==================================================

    local dispNames = {
        [1] = "Left",
        [2] = "Middle",
        [3] = "Right"
    }

    local fishReq = {
        [1] = {"-", "-"},
        [2] = {"-", "-"},
        [3] = {"-", "-"}
    }

    local reqLabels = {}
    local statusLabels = {}
    local lastAvail = {
        [1] = -1,
        [2] = -1,
        [3] = -1
    }

    --==================================================
    -- INVENTORY
    --==================================================

    local function findInv()

        local names = {
            "Inventory",
            "Items",
            "ItemInventory",
            "PlayerData",
            "Data",
            "Backpack"
        }

        for _, name in ipairs(names) do

            local container = player:FindFirstChild(name)

            if container then
                return container
            end
        end

        -- Also check Backpack service
        if player:FindFirstChildOfClass("Backpack") then
            return player:FindFirstChildOfClass("Backpack")
        end

        return nil
    end

    local function itemExists(container, name)

        if not container then
            return false
        end

        if not name or name == "-" then
            return false
        end

        -- Direct object
        local direct = container:FindFirstChild(name)

        if direct then

            if direct:IsA("IntValue")
                or direct:IsA("NumberValue") then

                return direct.Value > 0
            end

            return true
        end

        -- Descendants
        for _, object in ipairs(container:GetDescendants()) do

            if object.Name == name then

                if object:IsA("IntValue")
                    or object:IsA("NumberValue") then

                    return object.Value > 0
                end

                return true
            end
        end

        return false
    end

    local function checkReq(id)

        local req = fishReq[id]

        if not req then
            error("No requirement for dispenser " .. tostring(id))
        end

        local inv = findInv()

        if not inv then
            error("Inventory not found")
        end

        local f1 = req[1]
        local f2 = req[2]

        local h1 = itemExists(inv, f1)
        local h2 = itemExists(inv, f2)

        local avail = 0

        if h1 then
            avail += 1
        end

        if h2 then
            avail += 1
        end

        return h1, h2, avail
    end

    --==================================================
    -- DISPLAY
    --==================================================

    local function updateDisplay(id)

        local label = reqLabels[id]
        local status = statusLabels[id]

        if not label or not status then
            error("GUI missing for " .. tostring(id))
        end

        local req = fishReq[id]

        if not req then
            error("Requirement missing for " .. tostring(id))
        end

        local h1, h2, avail = checkReq(id)

        local f1 = req[1]
        local f2 = req[2]

        label.Text =
            dispNames[id] ..
            " Req: " ..
            (h1 and "✓" or "✗") ..
            " " ..
            f1 ..
            " / " ..
            (h2 and "✓" or "✗") ..
            " " ..
            f2

        status.Text = "Available [" .. avail .. "/2]"
        status.TextColor3 = Color3.fromRGB(180, 180, 180)

        return avail
    end

    local function safeUpdate(id)

        local ok, result = xpcall(
            function()
                return updateDisplay(id)
            end,
            function(e)
                return debug.traceback(tostring(e), 2)
            end
        )

        if not ok then
            return nil, result
        end

        return result
    end

    --==================================================
    -- INSERT ROW
    --==================================================

    local function createInsertRow(name, order, id)

        local row = createRow(name, order, 75)

        local reqLbl = Instance.new("TextLabel")
        reqLbl.Name = "Requirement"
        reqLbl.Text = name .. " Req: ✗ - / ✗ -"
        reqLbl.TextColor3 = Color3.new(1, 1, 1)
        reqLbl.TextSize = 11
        reqLbl.Font = Enum.Font.Gotham
        reqLbl.BackgroundTransparency = 1
        reqLbl.Size = UDim2.new(1, -10, 0, 25)
        reqLbl.Position = UDim2.fromOffset(5, 3)
        reqLbl.TextXAlignment = Enum.TextXAlignment.Left
        reqLbl.TextTruncate = Enum.TextTruncate.AtEnd
        reqLbl.Parent = row

        local insBtn = makeButton(
            row,
            "Insert",
            5,
            31,
            70,
            28,
            Color3.fromRGB(65, 65, 65)
        )

        local stat = Instance.new("TextLabel")
        stat.Name = "Status"
        stat.Text = "Available [0/2]"
        stat.TextColor3 = Color3.fromRGB(180, 180, 180)
        stat.TextSize = 10
        stat.Font = Enum.Font.GothamBold
        stat.BackgroundTransparency = 1
        stat.Size = UDim2.new(1, -85, 0, 20)
        stat.Position = UDim2.fromOffset(82, 34)
        stat.TextXAlignment = Enum.TextXAlignment.Left
        stat.Parent = row

        local actStat = Instance.new("TextLabel")
        actStat.Name = "ActionStatus"
        actStat.Text = ""
        actStat.TextColor3 = Color3.fromRGB(220, 70, 70)
        actStat.TextSize = 10
        actStat.Font = Enum.Font.GothamBold
        actStat.BackgroundTransparency = 1
        actStat.Size = UDim2.new(1, -10, 0, 18)
        actStat.Position = UDim2.fromOffset(5, 54)
        actStat.TextXAlignment = Enum.TextXAlignment.Left
        actStat.Parent = row

        reqLabels[id] = reqLbl
        statusLabels[id] = stat

        insBtn.MouseButton1Click:Connect(function()

            actStat.Text = ""

            local ok = runAction(
                "Insert <" .. name .. ">",
                function()

                    local _, _, avail = checkReq(id)

                    if avail < 2 then

                        actStat.Text = "Not Inserted"
                        actStat.TextColor3 =
                            Color3.fromRGB(220, 70, 70)

                        footerLabel.Text =
                            name .. ": Not Inserted"

                        notifBtn.Text = "⚠"

                        error(
                            "Requirements not fulfilled. Available [" ..
                            avail ..
                            "/2]"
                        )
                    end

                    local event =
                        getRemote("bee.submitToDispenser")

                    if not event then
                        error("bee.submitToDispenser event missing")
                    end

                    if typeof(event.FireServer) ~= "function" then
                        error("bee.submitToDispenser is not FireServer-capable")
                    end

                    event:FireServer(id)

                    actStat.Text = "Inserted"
                    actStat.TextColor3 =
                        Color3.fromRGB(100, 220, 100)

                end
            )

            if not ok then
                actStat.Text = "Not Inserted"
                actStat.TextColor3 =
                    Color3.fromRGB(220, 70, 70)
            end

        end)

        return row
    end

    createInsertRow("Left", 2, 1)
    createInsertRow("Middle", 3, 2)
    createInsertRow("Right", 4, 3)

    --==================================================
    -- BEE FILLING EVENT
    --==================================================

    local BeeFilling = getRemote("bee.fillingStarted")

    if BeeFilling and BeeFilling:IsA("RemoteEvent") then

        BeeFilling.OnClientEvent:Connect(function(id, data)

            local ok, err = xpcall(function()

                -- Accept numeric or string IDs
                id = tonumber(id) or id

                if not dispNames[id] then
                    error("Invalid dispenser ID: " .. tostring(id))
                end

                if type(data) ~= "table" then
                    error("Bee filling data is not a table")
                end

                if type(data.fishes) ~= "table" then
                    error("Bee filling data.fishes missing")
                end

                local f1 = data.fishes[1]
                local f2 = data.fishes[2]

                if not f1 or not f2 then
                    error("Bee filling event missing fish requirements")
                end

                fishReq[id] = {
                    tostring(f1),
                    tostring(f2)
                }

                local avail, updateError = safeUpdate(id)

                if avail == nil then
                    error(updateError or "Display update failed")
                end

            end, function(e)
                return debug.traceback(tostring(e), 2)
            end)

            if not ok then
                notifyFailure("Bee Req Update", err)
            end

        end)

    else

        warn(
            "[ActionGui] bee.fillingStarted missing or is not a RemoteEvent"
        )

    end

    --==================================================
    -- STATE SYNC
    --==================================================

    local StateSync = getRemote("state.sync")

    if StateSync and StateSync:IsA("RemoteEvent") then

        StateSync.OnClientEvent:Connect(function(data)

            local ok, err = xpcall(function()

                if type(data) ~= "table" then
                    return
                end

                if data.type ~= "patch" then
                    return
                end

                if type(data.data) ~= "table" then
                    return
                end

                local playersData =
                    data.data["playerData/players"]

                if type(playersData) ~= "table" then
                    return
                end

                local pData =
                    playersData[tostring(player.UserId)]

                if type(pData) ~= "table" then
                    return
                end

                if type(pData.events) ~= "table" then
                    return
                end

                local bee = pData.events.Bee

                if type(bee) ~= "table" then
                    return
                end

                local recipes = bee.recipes

                if type(recipes) ~= "table" then
                    return
                end

                for id, recipe in pairs(recipes) do

                    -- Important:
                    -- state data may use string IDs
                    local numericId = tonumber(id) or id

                    if dispNames[numericId]
                        and type(recipe) == "table"
                        and type(recipe.fishes) == "table" then

                        local f1 = recipe.fishes[1]
                        local f2 = recipe.fishes[2]

                        if f1 and f2 then

                            fishReq[numericId] = {
                                tostring(f1),
                                tostring(f2)
                            }

                        end
                    end
                end

                for id = 1, 3 do

                    local _, updateError = safeUpdate(id)

                    if updateError then
                        warn(
                            "[ActionGui] State display error <" ..
                            dispNames[id] ..
                            ">:\n" ..
                            tostring(updateError)
                        )
                    end

                end

            end, function(e)
                return debug.traceback(tostring(e), 2)
            end)

            if not ok then
                notifyFailure("State Sync", err)
            end

        end)

    else

        warn(
            "[ActionGui] state.sync missing or is not a RemoteEvent"
        )

    end

    --==================================================
    -- AUTO INSERT
    --==================================================

    local autoBusy = false

    local function getSelectedDispenser()

        if autoInsertChoice == "Left" then
            return 1
        elseif autoInsertChoice == "Middle" then
            return 2
        elseif autoInsertChoice == "Right" then
            return 3
        end

        return nil
    end

    local function tryAutoInsert()

        if not autoInsertEnabled then
            return
        end

        if autoBusy then
            return
        end

        local id = getSelectedDispenser()

        if not id then
            return
        end

        autoBusy = true

        local ok, err = xpcall(function()

            local _, _, avail = checkReq(id)

            if avail < 2 then
                return
            end

            local event =
                getRemote("bee.submitToDispenser")

            if not event then
                error("bee.submitToDispenser event missing")
            end

            if typeof(event.FireServer) ~= "function" then
                error("bee.submitToDispenser is not FireServer-capable")
            end

            event:FireServer(id)

            local status = statusLabels[id]

            if status then
                status.Text = "Available [2/2]"
            end

            footerLabel.Text =
                dispNames[id] .. ": Inserted"

            notifBtn.Text = "✓"

        end, function(e)
            return debug.traceback(tostring(e), 2)
        end)

        if not ok then

            notifyFailure(
                "Auto Insert <" ..
                dispNames[id] ..
                ">",
                err
            )

            local row =
                btnFrame:FindFirstChild(
                    dispNames[id] .. "Row"
                )

            local actionStatus =
                row and row:FindFirstChild("ActionStatus")

            if actionStatus then
                actionStatus.Text = "Not Inserted"
                actionStatus.TextColor3 =
                    Color3.fromRGB(220, 70, 70)
            end

        end

        -- Small debounce instead of immediately allowing another
        -- request in the same Heartbeat cycle.
        task.delay(0.15, function()
            autoBusy = false
        end)
    end

    --==================================================
    -- INVENTORY MONITOR
    --==================================================

    local elapsed = 0
    local inventoryErrorShown = false

    RS.Heartbeat:Connect(function(dt)

        if not gui.Parent then
            return
        end

        elapsed += dt

        if elapsed < INV_CHECK then
            return
        end

        elapsed = 0

        for id = 1, 3 do

            local ok, result = xpcall(
                function()
                    return updateDisplay(id)
                end,
                function(e)
                    return debug.traceback(tostring(e), 2)
                end
            )

            if ok then

                local avail = result

                if lastAvail[id] ~= avail then
                    lastAvail[id] = avail
                end

                inventoryErrorShown = false

            else

                -- Avoid flooding ErrorPanel every 0.5 seconds.
                if not inventoryErrorShown then

                    inventoryErrorShown = true

                    notifyFailure(
                        "Inventory Update <" ..
                        dispNames[id] ..
                        ">",
                        result
                    )
                end
            end
        end

        tryAutoInsert()

    end)

    --==================================================
    -- FEED KING BEE
    --==================================================

    local rowFeed = createRow("Feed King Bee", 5)

    local lblFeed = Instance.new("TextLabel")
    lblFeed.Name = "Label"
    lblFeed.Text = "Feed King Bee"
    lblFeed.TextColor3 = Color3.new(1, 1, 1)
    lblFeed.TextSize = 14
    lblFeed.Font = Enum.Font.Gotham
    lblFeed.BackgroundTransparency = 1
    lblFeed.Size = UDim2.new(1, -55, 1, 0)
    lblFeed.Position = UDim2.fromOffset(10, 0)
    lblFeed.TextXAlignment = Enum.TextXAlignment.Left
    lblFeed.Parent = rowFeed

    local btnFeed = makeButton(
        rowFeed,
        ">",
        0,
        0,
        30,
        30,
        Color3.fromRGB(65, 65, 65),
        function()

            runAction("Feed King Bee", function()

                local e1 =
                    getRemote("npc.dialogueCompleted")

                local e2 =
                    getRemote("bee.feedKingBeeAll")

                if not e1 then
                    error("npc.dialogueCompleted missing")
                end

                if not e2 then
                    error("bee.feedKingBeeAll missing")
                end

                if typeof(e1.FireServer) ~= "function" then
                    error("npc.dialogueCompleted cannot FireServer")
                end

                if typeof(e2.FireServer) ~= "function" then
                    error("bee.feedKingBeeAll cannot FireServer")
                end

                -- First event
                e1:FireServer("KingBee")

                -- Then feed
                e2:FireServer()

            end)

        end
    )

    btnFeed.Position = UDim2.new(1, -38, 0.5, -15)

    --==================================================
    -- INITIAL DISPLAY
    --==================================================

    for id = 1, 3 do

        local ok, result = xpcall(
            function()
                return updateDisplay(id)
            end,
            function(e)
                return debug.traceback(tostring(e), 2)
            end
        )

        if not ok then
            warn(
                "[ActionGui] Initial update <" ..
                dispNames[id] ..
                "> failed:\n" ..
                tostring(result)
            )
        end
    end

    --==================================================
    -- LOCAL FALLBACK DATA
    --==================================================
    --
    -- The old version attempted:
    --
    -- bee.fillingStarted:FireServer(...)
    --
    -- and:
    --
    -- state.sync:FireServer(...)
    --
    -- That does NOT invoke OnClientEvent locally.
    --
    -- These defaults simply populate the GUI if the game has
    -- not sent the real recipe information yet.
    --
    -- Remove/change these values if you don't want defaults.
    --==================================================

    local fallbackRecipes = {
        [1] = {
            "BlueSpottedPuffer",
            "PufferFish"
        },

        [2] = {
            "GoldenJellyfish",
            "MauveStinger"
        },

        [3] = {
            "PufferFish",
            "BlueSpottedPuffer"
        }
    }

    for id = 1, 3 do

        if fishReq[id][1] == "-"
            and fishReq[id][2] == "-" then

            fishReq[id] = {
                fallbackRecipes[id][1],
                fallbackRecipes[id][2]
            }

        end

    end

    -- Update after fallback values
    for id = 1, 3 do
        pcall(function()
            updateDisplay(id)
        end)
    end

    --==================================================
    -- DYNAMIC HEIGHT
    --==================================================

    local function updateHeight()

        if not frame.Parent then
            return
        end

        local height =
            math.clamp(
                layout.AbsoluteContentSize.Y + 105,
                MIN_H,
                MAX_H
            )

        frame.Size =
            UDim2.fromOffset(FRAME_W, height)
    end

    layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(updateHeight)

    updateHeight()

    --==================================================
    -- CLOSE
    --==================================================

    close.MouseButton1Click:Connect(function()

        if gui then
            gui:Destroy()
        end

    end)

    --==================================================
    -- TOGGLE
    --==================================================

    toggle.MouseButton1Click:Connect(function()

        if iconMoved then
            iconMoved = false
            return
        end

        frame.Visible = not frame.Visible

    end)

    --==================================================
    -- MAIN FRAME DRAG
    --==================================================

    local drag = false
    local dragStart = nil
    local startPos = nil

    title.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            drag = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()

                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                end

            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)

        if not drag then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

    end)

    --==================================================
    -- READY
    --==================================================

    footerLabel.Text = "Ready"
    notifBtn.Text = "✓"

end, function(e)

    return debug.traceback(tostring(e), 2)

end)

--==================================================
-- STARTUP ERROR
--==================================================

if not startupSuccess then

    warn(
        "[ActionGui] Script stopped:\n" ..
        tostring(startupError)
    )

    if ErrorPanel then

        pcall(function()
            ErrorPanel:Add(
                "Main.lua Startup",
                startupError
            )
        end)

    end
end
