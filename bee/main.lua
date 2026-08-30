--==================================================
-- FARM A FISH | BEE EVENT
-- Main.lua
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local BASE_URL =
	"https://raw.githubusercontent.com/jezz-lab/repo/main/bee/"

local ERROR_PANEL_URL = BASE_URL .. "ErrorPanel.lua"

local FRAME_WIDTH = 300
local MIN_HEIGHT = 200
local MAX_HEIGHT = 520

local INVENTORY_CHECK_INTERVAL = 0.5

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
-- MAIN STARTUP
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

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = close

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
	notificationButton.Text = "⚠"
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
	-- ERROR HELPERS
	--==================================================

	local function addError(actionName, message)
		warn(
			"[ActionGui] "
				.. tostring(actionName)
				.. ":\n"
				.. tostring(message)
		)

		if ErrorPanel then
			pcall(function()
				ErrorPanel:Add(actionName, message)
			end)
		end
	end

	local function notifyFailure(actionName, message)
		footerLabel.Text =
			tostring(actionName) .. " failed"

		notificationButton.Text = "⚠"

		addError(actionName, message)
	end

	local function notifySuccess(actionName)
		footerLabel.Text =
			tostring(actionName) .. " completed"

		notificationButton.Text = "✓"
	end

	--==================================================
	-- ERROR PANEL BUTTON
	--==================================================

	notificationButton.MouseEnter:Connect(function()
		notificationButton.BackgroundColor3 =
			Color3.fromRGB(75, 75, 75)
	end)

	notificationButton.MouseLeave:Connect(function()
		notificationButton.BackgroundColor3 =
			Color3.fromRGB(55, 55, 55)
	end)

	notificationButton.MouseButton1Click:Connect(function()
		if not ErrorPanel then
			return
		end

		local success, err = pcall(function()
			ErrorPanel:Toggle()
		end)

		if not success then
			warn("[ActionGui] ErrorPanel toggle failed:")
			warn(err)
		end
	end)

	--==================================================
	-- ERROR PANEL INIT
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

	local function runAction(actionName, callback)
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
			notifySuccess(actionName)
			return true
		end

		notifyFailure(actionName, result)
		return false
	end

	--==================================================
	-- GENERIC ACTION CREATOR
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
			actionButton.BackgroundColor3 =
				Color3.fromRGB(80, 80, 80)
		end)

		actionButton.MouseLeave:Connect(function()
			actionButton.BackgroundColor3 =
				Color3.fromRGB(65, 65, 65)
		end)

		actionButton.MouseButton1Down:Connect(function()
			actionButton.BackgroundColor3 =
				Color3.fromRGB(40, 40, 40)
		end)

		actionButton.MouseButton1Up:Connect(function()
			actionButton.BackgroundColor3 =
				Color3.fromRGB(80, 80, 80)
		end)

		actionButton.MouseButton1Click:Connect(function()
			runAction(name, callback)
		end)

		return row
	end

	--==================================================
	-- SPEED
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
	speedInput.PlaceholderColor3 =
		Color3.fromRGB(170, 170, 170)
	speedInput.TextSize = 13
	speedInput.Font = Enum.Font.Gotham
	speedInput.BackgroundColor3 =
		Color3.fromRGB(30, 30, 30)
	speedInput.BorderSizePixel = 0
	speedInput.Size = UDim2.fromOffset(60, 30)
	speedInput.Position = UDim2.new(1, -135, 0.5, -15)
	speedInput.ClearTextOnFocus = false
	speedInput.Parent = speedRow

	local speedInputCorner = Instance.new("UICorner")
	speedInputCorner.CornerRadius = UDim.new(0, 5)
	speedInputCorner.Parent = speedInput

	local speedButton = Instance.new("TextButton")
	speedButton.Name = "SetSpeed"
	speedButton.Text = "Set"
	speedButton.TextColor3 = Color3.new(1, 1, 1)
	speedButton.TextSize = 11
	speedButton.Font = Enum.Font.GothamBold
	speedButton.BackgroundColor3 =
		Color3.fromRGB(65, 65, 65)
	speedButton.BorderSizePixel = 0
	speedButton.Size = UDim2.fromOffset(55, 30)
	speedButton.Position = UDim2.new(1, -68, 0.5, -15)
	speedButton.AutoButtonColor = false
	speedButton.Parent = speedRow

	local speedButtonCorner = Instance.new("UICorner")
	speedButtonCorner.CornerRadius = UDim.new(0, 6)
	speedButtonCorner.Parent = speedButton

	speedButton.MouseEnter:Connect(function()
		speedButton.BackgroundColor3 =
			Color3.fromRGB(80, 80, 80)
	end)

	speedButton.MouseLeave:Connect(function()
		speedButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 65)
	end)

	speedButton.MouseButton1Click:Connect(function()
		runAction("Set Speed", function()
			local character = player.Character

			if not character then
				error("Character not found")
			end

			local humanoid =
				character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				error("Humanoid not found")
			end

			local speed = tonumber(speedInput.Text)

			if not speed then
				error("Invalid speed value")
			end

			if speed < 0 then
				error("Speed cannot be negative")
			end

			humanoid.WalkSpeed = speed
		end)
	end)

	--==================================================
	-- AUTO INSERT
	--==================================================

	local autoInsertEnabled = false
	local autoInsertChoice = "Left"

	local autoInsertRow = Instance.new("Frame")
	autoInsertRow.Name = "AutoInsertRow"
	autoInsertRow.BackgroundColor3 =
		Color3.fromRGB(45, 45, 45)
	autoInsertRow.BorderSizePixel = 0
	autoInsertRow.Size = UDim2.new(1, 0, 0, 40)
	autoInsertRow.LayoutOrder = 1
	autoInsertRow.Parent = buttonFrame

	local autoInsertCorner = Instance.new("UICorner")
	autoInsertCorner.CornerRadius = UDim.new(0, 6)
	autoInsertCorner.Parent = autoInsertRow

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
	autoCheck.Parent = autoInsertRow

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
	autoLabel.Parent = autoInsertRow

	local dropdown = Instance.new("TextButton")
	dropdown.Name = "Dropdown"
	dropdown.Text = "Left ▼"
	dropdown.TextColor3 = Color3.new(1, 1, 1)
	dropdown.TextSize = 11
	dropdown.Font = Enum.Font.Gotham
	dropdown.BackgroundColor3 =
		Color3.fromRGB(30, 30, 30)
	dropdown.BorderSizePixel = 0
	dropdown.Size = UDim2.fromOffset(90, 30)
	dropdown.Position = UDim2.new(1, -100, 0.5, -15)
	dropdown.AutoButtonColor = false
	dropdown.Parent = autoInsertRow

	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, 5)
	dropdownCorner.Parent = dropdown

	local optionsFrame = Instance.new("Frame")
	optionsFrame.Name = "Options"
	optionsFrame.Visible = false
	optionsFrame.BackgroundColor3 =
		Color3.fromRGB(35, 35, 35)
	optionsFrame.BorderSizePixel = 0
	optionsFrame.Size = UDim2.fromOffset(90, 84)
	optionsFrame.Position = UDim2.new(1, -100, 1, 3)
	optionsFrame.ZIndex = 50
	optionsFrame.Parent = autoInsertRow

	local optionsLayout = Instance.new("UIListLayout")
	optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optionsLayout.Parent = optionsFrame

	local options = {
		"Left",
		"Middle",
		"Right"
	}

	for index, option in ipairs(options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Name = option
		optionButton.Text = "☐ " .. option
		optionButton.TextColor3 =
			Color3.new(1, 1, 1)
		optionButton.TextSize = 11
		optionButton.Font = Enum.Font.Gotham
		optionButton.BackgroundColor3 =
			Color3.fromRGB(45, 45, 45)
		optionButton.BorderSizePixel = 0
		optionButton.Size = UDim2.new(1, 0, 0, 28)
		optionButton.LayoutOrder = index
		optionButton.ZIndex = 51
		optionButton.Parent = optionsFrame

		optionButton.MouseEnter:Connect(function()
			optionButton.BackgroundColor3 =
				Color3.fromRGB(60, 60, 60)
		end)

		optionButton.MouseLeave:Connect(function()
			optionButton.BackgroundColor3 =
				Color3.fromRGB(45, 45, 45)
		end)

		optionButton.MouseButton1Click:Connect(function()
			autoInsertChoice = option
			dropdown.Text = option .. " ▼"
			optionsFrame.Visible = false
		end)
	end

	autoCheck.MouseButton1Click:Connect(function()
		autoInsertEnabled = not autoInsertEnabled

		if autoInsertEnabled then
			autoCheck.Text = "☑"
		else
			autoCheck.Text = "☐"
		end
	end)

	dropdown.MouseButton1Click:Connect(function()
		optionsFrame.Visible = not optionsFrame.Visible
	end)

	--==================================================
	-- FISH REQUIREMENTS
	--==================================================

	local dispenserNames = {
		[1] = "Left",
		[2] = "Middle",
		[3] = "Right"
	}

	local fishRequirements = {
		[1] = {"-", "-"},
		[2] = {"-", "-"},
		[3] = {"-", "-"}
	}

	local requirementLabels = {}
	local statusLabels = {}

	local lastAvailable = {
		[1] = -1,
		[2] = -1,
		[3] = -1
	}

	--==================================================
	-- GENERAL INVENTORY
	--==================================================

	local function findGeneralInventory()
		local candidates = {
			player:FindFirstChild("Inventory"),
			player:FindFirstChild("Items"),
			player:FindFirstChild("ItemInventory"),
			player:FindFirstChild("PlayerData"),
			player:FindFirstChild("Data"),
			player:FindFirstChild("Backpack"),
		}

		for _, container in ipairs(candidates) do
			if container then
				return container
			end
		end

		return nil
	end

	local function itemExists(container, itemName)
		if not container then
			error("General inventory not found")
		end

		if not itemName or itemName == "-" then
			return false
		end

		local direct = container:FindFirstChild(itemName)

		if direct then
			if direct:IsA("IntValue")
				or direct:IsA("NumberValue") then

				return direct.Value > 0
			end

			return true
		end

		for _, object in ipairs(container:GetDescendants()) do
			if object.Name == itemName then
				if object:IsA("IntValue")
					or object:IsA("NumberValue") then

					if object.Value > 0 then
						return true
					end
				else
					return true
				end
			end
		end

		return false
	end

	--==================================================
	-- REQUIREMENT CHECK
	--==================================================

	local function checkRequirements(dispenserId)
		local requirements = fishRequirements[dispenserId]

		if not requirements then
			error(
				"No requirements for dispenser "
					.. tostring(dispenserId)
			)
		end

		local inventory = findGeneralInventory()

		if not inventory then
			error("General inventory not found")
		end

		local fish1 = requirements[1]
		local fish2 = requirements[2]

		local hasFish1 =
			itemExists(inventory, fish1)

		local hasFish2 =
			itemExists(inventory, fish2)

		local available = 0

		if hasFish1 then
			available += 1
		end

		if hasFish2 then
			available += 1
		end

		return hasFish1, hasFish2, available
	end

	--==================================================
	-- REQUIREMENT DISPLAY
	--==================================================

	local function updateRequirementDisplay(dispenserId)
		local label = requirementLabels[dispenserId]
		local status = statusLabels[dispenserId]

		if not label or not status then
			error(
				"Requirement GUI not initialized for "
					.. tostring(dispenserId)
			)
		end

		local requirements =
			fishRequirements[dispenserId]

		if not requirements then
			error(
				"Requirements missing for "
					.. tostring(dispenserId)
			)
		end

		local hasFish1, hasFish2, available =
			checkRequirements(dispenserId)

		local fish1 = requirements[1]
		local fish2 = requirements[2]

		local mark1 =
			hasFish1 and "✓" or "✗"

		local mark2 =
			hasFish2 and "✓" or "✗"

		label.Text =
			dispenserNames[dispenserId]
			.. " Req: "
			.. mark1
			.. " "
			.. fish1
			.. " / "
			.. mark2
			.. " "
			.. fish2

		status.Text =
			"Available ["
			.. tostring(available)
			.. "/2]"

		status.TextColor3 =
			Color3.fromRGB(180, 180, 180)

		return available
	end

	--==================================================
	-- SAFE REQUIREMENT UPDATE
	--==================================================

	local function safeUpdateRequirement(dispenserId)
		local success, result = xpcall(
			function()
				return updateRequirementDisplay(
					dispenserId
				)
			end,
			function(err)
				return debug.traceback(
					tostring(err),
					2
				)
			end
		)

		if not success then
			notifyFailure(
				"Requirement Update <"
					.. tostring(
						dispenserNames[dispenserId]
					)
					.. ">",
				result
			)

			return nil
		end

		return result
	end

	--==================================================
	-- INSERT ROW
	--==================================================

	local function createInsertRow(
		name,
		order,
		dispenserId
	)

		local row = Instance.new("Frame")
		row.Name = name .. "Row"
		row.BackgroundColor3 =
			Color3.fromRGB(45, 45, 45)
		row.BorderSizePixel = 0

		-- Requirement + button + status
		row.Size = UDim2.new(1, 0, 0, 75)

		row.LayoutOrder = order
		row.Parent = buttonFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = row

		--==================================================
		-- REQUIREMENT LABEL
		--==================================================

		local requirement = Instance.new("TextLabel")
		requirement.Name = "Requirement"
		requirement.Text =
			name .. " Req: ✗ - / ✗ -"

		requirement.TextColor3 =
			Color3.new(1, 1, 1)

		requirement.TextSize = 11
		requirement.Font = Enum.Font.Gotham
		requirement.BackgroundTransparency = 1
		requirement.Size =
			UDim2.new(1, -10, 0, 25)

		requirement.Position =
			UDim2.fromOffset(5, 3)

		requirement.TextXAlignment =
			Enum.TextXAlignment.Left

		requirement.TextTruncate =
			Enum.TextTruncate.AtEnd

		requirement.Parent = row

		--==================================================
		-- INSERT BUTTON
		--==================================================

		local insertButton = Instance.new("TextButton")
		insertButton.Name = "InsertButton"
		insertButton.Text = "Insert"
		insertButton.TextColor3 =
			Color3.new(1, 1, 1)

		insertButton.TextSize = 11
		insertButton.Font =
			Enum.Font.GothamBold

		insertButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 65)

		insertButton.BorderSizePixel = 0

		insertButton.Size =
			UDim2.fromOffset(70, 28)

		insertButton.Position =
			UDim2.fromOffset(5, 31)

		insertButton.AutoButtonColor = false
		insertButton.Parent = row

		local insertCorner = Instance.new("UICorner")
		insertCorner.CornerRadius =
			UDim.new(0, 6)

		insertCorner.Parent = insertButton

		--==================================================
		-- STATUS
		--==================================================

		local status = Instance.new("TextLabel")
		status.Name = "Status"
		status.Text = "Available [0/2]"
		status.TextColor3 =
			Color3.fromRGB(180, 180, 180)

		status.TextSize = 10
		status.Font = Enum.Font.GothamBold
		status.BackgroundTransparency = 1

		status.Size =
			UDim2.new(1, -85, 0, 20)

		status.Position =
			UDim2.fromOffset(82, 34)

		status.TextXAlignment =
			Enum.TextXAlignment.Left

		status.Parent = row

		--==================================================
		-- LAST ACTION STATUS
		--==================================================

		local actionStatus = Instance.new("TextLabel")
		actionStatus.Name = "ActionStatus"
		actionStatus.Text = ""
		actionStatus.TextColor3 =
			Color3.fromRGB(220, 70, 70)

		actionStatus.TextSize = 10
		actionStatus.Font =
			Enum.Font.GothamBold

		actionStatus.BackgroundTransparency = 1

		actionStatus.Size =
			UDim2.new(1, -10, 0, 18)

		actionStatus.Position =
			UDim2.fromOffset(5, 54)

		actionStatus.TextXAlignment =
			Enum.TextXAlignment.Left

		actionStatus.Parent = row

		requirementLabels[dispenserId] =
			requirement

		statusLabels[dispenserId] =
			status

		--==================================================
		-- HOVER
		--==================================================

		insertButton.MouseEnter:Connect(function()
			insertButton.BackgroundColor3 =
				Color3.fromRGB(80, 80, 80)
		end)

		insertButton.MouseLeave:Connect(function()
			insertButton.BackgroundColor3 =
				Color3.fromRGB(65, 65, 65)
		end)

		insertButton.MouseButton1Down:Connect(function()
			insertButton.BackgroundColor3 =
				Color3.fromRGB(40, 40, 40)
		end)

		insertButton.MouseButton1Up:Connect(function()
			insertButton.BackgroundColor3 =
				Color3.fromRGB(80, 80, 80)
		end)

		--==================================================
		-- INSERT ACTION
		--==================================================

		insertButton.MouseButton1Click:Connect(function()

			actionStatus.Text = ""

			local success = runAction(
				"Insert <" .. name .. ">",
				function()

					local hasFish1
					local hasFish2
					local available

					hasFish1,
						hasFish2,
						available =
						checkRequirements(
							dispenserId
						)

					-- Not enough fish.
					if available < 2 then
						actionStatus.Text =
							"Not Inserted"

						actionStatus.TextColor3 =
							Color3.fromRGB(
								220,
								70,
								70
							)

						footerLabel.Text =
							name
							.. ": Not Inserted"

						notificationButton.Text =
							"⚠"

						-- This is a button failure,
						-- so it goes to ErrorPanel.
						error(
							"Requirements not fulfilled. "
								.. "Available ["
								.. tostring(available)
								.. "/2]"
						)
					end

					local event = ReplicatedStorage
						.rbxts_include
						.node_modules["@rbxts"]
						.remo
						.src
						.container[
							"bee.submitToDispenser"
						]

					if not event then
						error(
							"bee.submitToDispenser "
								.. "RemoteEvent not found"
						)
					end

					if typeof(event.FireServer)
						~= "function" then

						error(
							"bee.submitToDispenser "
								.. "cannot FireServer"
						)
					end

					event:FireServer(
						dispenserId
					)

					actionStatus.Text =
						"Inserted"

					actionStatus.TextColor3 =
						Color3.fromRGB(
							100,
							220,
							100
						)
				end
			)

			if not success then
				actionStatus.Text =
					"Not Inserted"

				actionStatus.TextColor3 =
					Color3.fromRGB(
						220,
						70,
						70
					)
			end
		end)

		return row
	end

	--==================================================
	-- CREATE BEE ROWS
	--==================================================

	createInsertRow("Left", 2, 1)
	createInsertRow("Middle", 3, 2)
	createInsertRow("Right", 4, 3)

	--==================================================
	-- BEE EVENT
	--==================================================

	local BeeFillingStarted = ReplicatedStorage
		.rbxts_include
		.node_modules["@rbxts"]
		.remo
		.src
		.container["bee.fillingStarted"]

	if not BeeFillingStarted then
		error(
			"bee.fillingStarted RemoteEvent not found"
		)
	end

	BeeFillingStarted.OnClientEvent:Connect(
		function(dispenserId, data, arg3)

			local success, err = xpcall(
				function()

					if not dispenserNames[dispenserId] then
						error(
							"Invalid dispenser ID: "
								.. tostring(
									dispenserId
								)
						)
					end

					if type(data) ~= "table" then
						error(
							"Bee event data is not a table"
						)
					end

					if type(data.fishes)
						~= "table" then

						error(
							"Bee event is missing "
								.. "the fishes table"
						)
					end

					local fish1 =
						data.fishes[1]

					local fish2 =
						data.fishes[2]

					if not fish1 or not fish2 then
						error(
							"Bee event does not contain "
								.. "2 fish requirements"
						)
					end

					fishRequirements[
						dispenserId
					] = {
						tostring(fish1),
						tostring(fish2)
					}

					-- This update itself is checked.
					local available =
						safeUpdateRequirement(
							dispenserId
						)

					if available == nil then
						error(
							"Requirement display "
								.. "could not be updated"
						)
					end
				end,
				function(errorMessage)
					return debug.traceback(
						tostring(errorMessage),
						2
					)
				end
			)

			-- Bee event problems are actual
			-- update/analyze problems.
			if not success then
				notifyFailure(
					"Bee Requirement Update",
					err
				)
			end
		end
	)

	--==================================================
	-- AUTO INSERT
	--==================================================

	local autoInsertBusy = false

	local function getSelectedDispenser()
		if autoInsertChoice == "Left" then
			return 1
		end

		if autoInsertChoice == "Middle" then
			return 2
		end

		if autoInsertChoice == "Right" then
			return 3
		end

		return nil
	end

	local function tryAutoInsert()
		if not autoInsertEnabled then
			return
		end

		if autoInsertBusy then
			return
		end

		local dispenserId =
			getSelectedDispenser()

		if not dispenserId then
			return
		end

		local success, err = xpcall(
			function()

				local hasFish1
				local hasFish2
				local available

				hasFish1,
					hasFish2,
					available =
					checkRequirements(
						dispenserId
					)

				-- Normal state. Not an error.
				if available < 2 then
					return
				end

				autoInsertBusy = true

				local event = ReplicatedStorage
					.rbxts_include
					.node_modules["@rbxts"]
					.remo
					.src
					.container[
						"bee.submitToDispenser"
					]

				if not event then
					error(
						"bee.submitToDispenser "
							.. "RemoteEvent not found"
					)
				end

				if typeof(event.FireServer)
					~= "function" then

					error(
						"bee.submitToDispenser "
							.. "cannot FireServer"
					)
				end

				event:FireServer(
					dispenserId
				)

				local status =
					statusLabels[dispenserId]

				if status then
					status.Text =
						"Available [2/2]"
				end

				footerLabel.Text =
					dispenserNames[
						dispenserId
					]
					.. ": Inserted"

				notificationButton.Text =
					"✓"
			end,
			function(errorMessage)
				return debug.traceback(
					tostring(errorMessage),
					2
				)
			end
		)

		autoInsertBusy = false

		if not success then
			notifyFailure(
				"Auto Insert <"
					.. tostring(
						dispenserNames[
							dispenserId
						]
					)
					.. ">",
				err
			)

			local actionStatus

			-- Find the row's action status.
			local row = buttonFrame:FindFirstChild(
				dispenserNames[
					dispenserId
				] .. "Row"
			)

			if row then
				actionStatus =
					row:FindFirstChild(
						"ActionStatus"
					)
			end

			if actionStatus then
				actionStatus.Text =
					"Not Inserted"

				actionStatus.TextColor3 =
					Color3.fromRGB(
						220,
						70,
						70
					)
			end
		end
	end

	--==================================================
	-- INVENTORY MONITOR
	--==================================================

	local elapsed = 0

	RunService.Heartbeat:Connect(function(deltaTime)

		elapsed += deltaTime

		if elapsed < INVENTORY_CHECK_INTERVAL then
			return
		end

		elapsed = 0

		-- Recheck all three requirements.
		for dispenserId = 1, 3 do

			local success, availableOrError =
				xpcall(
					function()
						return updateRequirementDisplay(
							dispenserId
						)
					end,
					function(err)
						return debug.traceback(
							tostring(err),
							2
						)
					end
				)

			if success then

				local available =
					availableOrError

				-- Only update auto insertion when
				-- availability actually changes.
				if lastAvailable[dispenserId]
					~= available then

					lastAvailable[dispenserId] =
						available
				end

			else
				-- Inventory/update failure.
				notifyFailure(
					"Inventory Update <"
						.. dispenserNames[
							dispenserId
						]
						.. ">",
					availableOrError
				)
			end
		end

		-- Auto insert is attempted after
		-- inventory refresh.
		tryAutoInsert()
	end)

	--==================================================
	-- FEED KING BEE
	--==================================================

	createAction("Feed King Bee", 5, function()

		local Event1 = ReplicatedStorage
			.rbxts_include
			.node_modules["@rbxts"]
			.remo
			.src
			.container["npc.dialogueCompleted"]

		if not Event1 then
			error(
				"npc.dialogueCompleted "
					.. "RemoteEvent not found"
			)
		end

		if typeof(Event1.FireServer)
			~= "function" then

			error(
				"npc.dialogueCompleted "
					.. "cannot FireServer"
			)
		end

		local Event2 = ReplicatedStorage
			.rbxts_include
			.node_modules["@rbxts"]
			.remo
			.src
			.container["bee.feedKingBeeAll"]

		if not Event2 then
			error(
				"bee.feedKingBeeAll "
					.. "RemoteEvent not found"
			)
		end

		if typeof(Event2.FireServer)
			~= "function" then

			error(
				"bee.feedKingBeeAll "
					.. "cannot FireServer"
			)
		end

		Event1:FireServer("KingBee")
		Event2:FireServer()
	end)

	--==================================================
	-- INSERT BUTTON ERROR STATE
	--==================================================

	-- Re-check current requirements on startup.
	for dispenserId = 1, 3 do
		local success, err = xpcall(
			function()
				local available =
					updateRequirementDisplay(
						dispenserId
					)

				lastAvailable[
					dispenserId
				] = available
			end,
			function(errorMessage)
				return debug.traceback(
					tostring(errorMessage),
					2
				)
			end
		)

		if not success then
			-- Initial inventory failure is a real
			-- update failure, so report it.
			notifyFailure(
				"Initial Inventory Update <"
					.. dispenserNames[
						dispenserId
					]
					.. ">",
				err
			)
		end
	end

	--==================================================
	-- AUTOMATIC HEIGHT
	--==================================================

	local function updateHeight()
		local contentHeight =
			layout.AbsoluteContentSize.Y

		local newHeight = math.clamp(
			contentHeight + 105,
			MIN_HEIGHT,
			MAX_HEIGHT
		)

		frame.Size =
			UDim2.fromOffset(
				FRAME_WIDTH,
				newHeight
			)
	end

	layout:GetPropertyChangedSignal(
		"AbsoluteContentSize"
	):Connect(updateHeight)

	updateHeight()

	--==================================================
	-- CLOSE
	--==================================================

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	--==================================================
	-- TOGGLE
	--==================================================

	toggleButton.MouseButton1Click:Connect(function()

		if iconMoved then
			iconMoved = false
			return
		end

		frame.Visible =
			not frame.Visible
	end)

	--==================================================
	-- MAIN FRAME DRAGGING
	--==================================================

	local dragging = false
	local dragStart
	local startPosition

	title.InputBegan:Connect(function(input)

		if input.UserInputType
			== Enum.UserInputType.MouseButton1
			or input.UserInputType
			== Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = frame.Position

			input.Changed:Connect(function()

				if input.UserInputState
					== Enum.UserInputState.End then

					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)

		if not dragging then
			return
		end

		if input.UserInputType
			~= Enum.UserInputType.MouseMovement
			and input.UserInputType
			~= Enum.UserInputType.Touch then

			return
		end

		local delta =
			input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	--==================================================
	-- READY
	--==================================================

	footerLabel.Text = "Ready"
	notificationButton.Text = "✓"

end, function(err)
	return debug.traceback(
		tostring(err),
		2
	)
end)

--==================================================
-- STARTUP FAILURE
--==================================================

if not startupSuccess then
	warn("[ActionGui] Script stopped working:")
	warn(startupError)

	if ErrorPanel then
		pcall(function()
			ErrorPanel:Add(
				"Main.lua Startup",
				startupError
			)
		end)
	end
end
