--==================================================
-- FARM A FISH | BEE EVENT
-- Main.lua
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local BASE_URL =
	"https://raw.githubusercontent.com/USERNAME/REPOSITORY/main/"

local ERROR_PANEL_URL = BASE_URL .. "ErrorPanel.lua"

local FRAME_WIDTH = 240
local MIN_HEIGHT = 150
local MAX_HEIGHT = 500

--==================================================
-- REMOVE OLD GUI
--==================================================

local oldGui = playerGui:FindFirstChild("ActionGui")
if oldGui then
	oldGui:Destroy()
end

--==================================================
-- ERROR PANEL
--==================================================

local ErrorPanel

local panelLoaded, panelResult = xpcall(function()
	local source = game:HttpGet(ERROR_PANEL_URL)

	if not source or source == "" then
		error("ErrorPanel.lua returned empty content")
	end

	local loader = loadstring(source)

	if not loader then
		error("Could not compile ErrorPanel.lua")
	end

	local module = loader()

	if type(module) ~= "table" then
		error("ErrorPanel.lua must return a table")
	end

	if type(module.Init) ~= "function" then
		error("ErrorPanel.lua is missing Init()")
	end

	if type(module.Add) ~= "function" then
		error("ErrorPanel.lua is missing Add()")
	end

	if type(module.Toggle) ~= "function" then
		error("ErrorPanel.lua is missing Toggle()")
	end

	return module
end, function(err)
	return debug.traceback(tostring(err), 2)
end)

if panelLoaded then
	ErrorPanel = panelResult
else
	warn("[ActionGui] Failed to load ErrorPanel.lua:")
	warn(panelResult)
end

--==================================================
-- MAIN GUI
--==================================================

local startupSuccess, startupError = xpcall(function()

	--==================================================
	-- GUI
	--==================================================

	local gui = Instance.new("ScreenGui")
	gui.Name = "ActionGui"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	--==================================================
	-- MAIN FRAME
	--==================================================

	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.fromOffset(FRAME_WIDTH, MIN_HEIGHT)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 8)
	frameCorner.Parent = frame

	--==================================================
	-- TOGGLE ICON
	--==================================================

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleIcon"
	toggleButton.Text = "⚡"
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.TextSize = 24
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	toggleButton.BorderSizePixel = 0
	toggleButton.Size = UDim2.fromOffset(45, 45)
	toggleButton.Position = UDim2.fromOffset(15, 100)
	toggleButton.AutoButtonColor = false
	toggleButton.Parent = gui

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 10)
	toggleCorner.Parent = toggleButton

	--==================================================
	-- ICON DRAGGING
	--==================================================

	local iconDragging = false
	local iconDragStart
	local iconStartPosition
	local iconMoved = false

	toggleButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			iconDragging = true
			iconMoved = false
			iconDragStart = input.Position
			iconStartPosition = toggleButton.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					iconDragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not iconDragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - iconDragStart

		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
			iconMoved = true
		end

		toggleButton.Position = UDim2.new(
			iconStartPosition.X.Scale,
			iconStartPosition.X.Offset + delta.X,
			iconStartPosition.Y.Scale,
			iconStartPosition.Y.Offset + delta.Y
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
	-- CLOSE BUTTON
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

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = close

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	--==================================================
	-- TOGGLE FRAME
	--==================================================

	toggleButton.MouseButton1Click:Connect(function()
		if iconMoved then
			iconMoved = false
			return
		end

		frame.Visible = not frame.Visible
	end)

	--==================================================
	-- MAIN FRAME DRAGGING
	--==================================================

	local dragging = false
	local dragStart
	local startPosition

	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	--==================================================
	-- BUTTON CONTAINER
	--==================================================

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "Buttons"
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Size = UDim2.new(1, -20, 1, -95)
	buttonFrame.Position = UDim2.fromOffset(10, 45)
	buttonFrame.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = buttonFrame

	--==================================================
	-- SPEED INPUT
	--==================================================

	local speedRow = Instance.new("Frame")
	speedRow.Name = "SpeedRow"
	speedRow.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	speedRow.BorderSizePixel = 0
	speedRow.Size = UDim2.new(1, 0, 0, 40)
	speedRow.LayoutOrder = 0
	speedRow.Parent = buttonFrame

	local speedCorner = Instance.new("UICorner")
	speedCorner.CornerRadius = UDim.new(0, 6)
	speedCorner.Parent = speedRow

	local speedLabel = Instance.new("TextLabel")
	speedLabel.Name = "Label"
	speedLabel.Text = "Speed"
	speedLabel.TextColor3 = Color3.new(1, 1, 1)
	speedLabel.TextSize = 15
	speedLabel.Font = Enum.Font.Gotham
	speedLabel.BackgroundTransparency = 1
	speedLabel.Size = UDim2.new(1, -95, 1, 0)
	speedLabel.Position = UDim2.fromOffset(10, 0)
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLabel.Parent = speedRow

	local speedInput = Instance.new("TextBox")
	speedInput.Name = "SpeedInput"
	speedInput.Text = "16"
	speedInput.PlaceholderText = "Enter speed"
	speedInput.TextColor3 = Color3.new(1, 1, 1)
	speedInput.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
	speedInput.TextSize = 14
	speedInput.Font = Enum.Font.Gotham
	speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	speedInput.BorderSizePixel = 0
	speedInput.Size = UDim2.fromOffset(75, 30)
	speedInput.Position = UDim2.new(1, -85, 0.5, -15)
	speedInput.ClearTextOnFocus = false
	speedInput.Parent = speedRow

	local speedInputCorner = Instance.new("UICorner")
	speedInputCorner.CornerRadius = UDim.new(0, 5)
	speedInputCorner.Parent = speedInput

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

	local footerCorner = Instance.new("UICorner")
	footerCorner.CornerRadius = UDim.new(0, 6)
	footerCorner.Parent = footer

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

	local notificationButton = Instance.new("TextButton")
	notificationButton.Name = "NotificationIcon"
	notificationButton.Text = "✓"
	notificationButton.TextColor3 = Color3.new(1, 1, 1)
	notificationButton.TextSize = 17
	notificationButton.Font = Enum.Font.GothamBold
	notificationButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	notificationButton.BorderSizePixel = 0
	notificationButton.Size = UDim2.fromOffset(30, 30)
	notificationButton.Position = UDim2.new(1, -33, 0.5, -15)
	notificationButton.AutoButtonColor = false
	notificationButton.Parent = footer

	local notificationCorner = Instance.new("UICorner")
	notificationCorner.CornerRadius = UDim.new(0, 7)
	notificationCorner.Parent = notificationButton

	--==================================================
	-- NOTIFICATIONS
	--==================================================

	local function notifySuccess(name)
		footerLabel.Text = name .. " completed"
		notificationButton.Text = "✓"
	end

	local function notifyFailure(name, errorMessage)
		footerLabel.Text = name .. " failed"
		notificationButton.Text = "⚠"

		warn(
			"[ActionGui] "
				.. name
				.. " failed:\n"
				.. tostring(errorMessage)
		)

		if ErrorPanel then
			pcall(function()
				ErrorPanel:Add(name, errorMessage)
			end)
		end
	end

	--==================================================
	-- ERROR PANEL BUTTON
	--==================================================

	notificationButton.MouseEnter:Connect(function()
		notificationButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	end)

	notificationButton.MouseLeave:Connect(function()
		notificationButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	end)

	notificationButton.MouseButton1Click:Connect(function()
		if ErrorPanel then
			local success, err = pcall(function()
				ErrorPanel:Toggle()
			end)

			if not success then
				warn("[ActionGui] ErrorPanel toggle failed:")
				warn(err)
			end
		end
	end)

	--==================================================
	-- INITIALIZE ERROR PANEL
	--==================================================

	if ErrorPanel then
		local success, err = pcall(function()
			ErrorPanel:Init(gui)
		end)

		if not success then
			warn("[ActionGui] ErrorPanel initialization failed:")
			warn(err)
			ErrorPanel = nil
		end
	end

	--==================================================
	-- SAFE ACTION RUNNER
	--==================================================

	local function runAction(name, callback)
		local success, result = xpcall(
			callback,
			function(err)
				return debug.traceback(
					tostring(err),
					2
				)
			end
		)

		if success then
			notifySuccess(name)
			return true
		end

		notifyFailure(name, result)
		return false
	end

	--==================================================
	-- ACTION CREATOR
	--==================================================

	local function createAction(name, order, callback)
		local row = Instance.new("Frame")
		row.Name = name .. "Row"
		row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 40)
		row.LayoutOrder = order
		row.Parent = buttonFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = row

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Text = name
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextSize = 14
		label.Font = Enum.Font.Gotham
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, -55, 1, 0)
		label.Position = UDim2.fromOffset(10, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = row

		local actionButton = Instance.new("TextButton")
		actionButton.Name = "ActionButton"

		-- ASCII icon
		actionButton.Text = ">"

		actionButton.TextColor3 = Color3.new(1, 1, 1)
		actionButton.TextSize = 18
		actionButton.Font = Enum.Font.GothamBold
		actionButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
		actionButton.BorderSizePixel = 0
		actionButton.Size = UDim2.fromOffset(30, 30)
		actionButton.Position = UDim2.new(1, -38, 0.5, -15)
		actionButton.AutoButtonColor = false
		actionButton.Parent = row

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 7)
		buttonCorner.Parent = actionButton

		actionButton.MouseEnter:Connect(function()
			actionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end)

		actionButton.MouseLeave:Connect(function()
			actionButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
		end)

		actionButton.MouseButton1Down:Connect(function()
			actionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		end)

		actionButton.MouseButton1Up:Connect(function()
			actionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		end)

		actionButton.MouseButton1Click:Connect(function()
			runAction(name, callback)
		end)

		return row
	end

	--==================================================
	-- SET SPEED
	--==================================================

	createAction("Set Speed", 1, function()
		local character = player.Character

		if not character then
			error("Character not found")
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			error("Humanoid not found")
		end

		local speed = tonumber(speedInput.Text)

		if not speed then
			error("Invalid speed value")
		end

		humanoid.WalkSpeed = speed
	end)

	--==================================================
	-- INSERT LEFT
	--==================================================

	createAction("Insert <Left>", 2, function()
		local Event = game:GetService("ReplicatedStorage")
			.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]

		Event:FireServer(1)
	end)

	--==================================================
	-- INSERT MIDDLE
	--==================================================

	createAction("Insert <Middle>", 3, function()
		local Event = game:GetService("ReplicatedStorage")
			.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]

		Event:FireServer(2)
	end)

	--==================================================
	-- INSERT RIGHT
	--==================================================

	createAction("Insert <Right>", 4, function()
		local Event = game:GetService("ReplicatedStorage")
			.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]

		Event:FireServer(3)
	end)

	--==================================================
	-- FEED KING BEE
	--==================================================

	createAction("Feed King Bee", 5, function()
		local Event1 = game:GetService("ReplicatedStorage")
			.rbxts_include.node_modules["@rbxts"].remo.src.container["npc.dialogueCompleted"]

		local Event2 = game:GetService("ReplicatedStorage")
			.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.feedKingBeeAll"]

		Event1:FireServer("KingBee")
		Event2:FireServer()
	end)

	--==================================================
	-- AUTOMATIC HEIGHT
	--==================================================

	local function updateHeight()
		local contentHeight = layout.AbsoluteContentSize.Y

		local newHeight = math.clamp(
			contentHeight + 105,
			MIN_HEIGHT,
			MAX_HEIGHT
		)

		frame.Size = UDim2.fromOffset(
			FRAME_WIDTH,
			newHeight
		)
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
		updateHeight
	)

	updateHeight()
	notifySuccess("Ready")

end, function(err)
	return debug.traceback(tostring(err), 2)
end)

--==================================================
-- STARTUP FAILURE
--==================================================

if not startupSuccess then
	warn("[ActionGui] Script stopped working:")
	warn(startupError)
end
