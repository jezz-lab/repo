local ErrorPanel = {}

--==================================================
-- SETTINGS
--==================================================

local MAX_ERRORS = 5

--==================================================
-- STATE
--==================================================

local gui
local panel
local listFrame
local listLayout
local countLabel

local errors = {}
local rowData = {}

--==================================================
-- HELPERS
--==================================================

local function create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent

	return object
end

local function updateCanvas()
	if not listFrame or not listLayout then
		return
	end

	listFrame.CanvasSize = UDim2.fromOffset(
		0,
		listLayout.AbsoluteContentSize.Y + 10
	)
end

local function updateCount()
	if countLabel then
		countLabel.Text = "Errors: " .. tostring(#errors)
	end
end

--==================================================
-- REMOVE ERROR ROW
--==================================================

local function removeRow(index)
	local data = rowData[index]

	if data and data.Row then
		data.Row:Destroy()
	end

	table.remove(rowData, index)
end

--==================================================
-- CLEAR ALL
--==================================================

function ErrorPanel:Clear()
	for _, data in ipairs(rowData) do
		if data.Row then
			data.Row:Destroy()
		end
	end

	table.clear(rowData)
	table.clear(errors)

	updateCount()
	updateCanvas()
end

--==================================================
-- CREATE ERROR ROW
--==================================================

local function createErrorRow(index, errorData)
	if not listFrame then
		return
	end

	local row = create("Frame", {
		Name = "Error_" .. tostring(index),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -10, 0, 40),
		LayoutOrder = index
	}, listFrame)

	create("UICorner", {
		CornerRadius = UDim.new(0, 6)
	}, row)

	--==================================================
	-- HEADER BUTTON
	--==================================================

	local header = create("TextButton", {
		Name = "Header",
		Text = "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		AutoButtonColor = false
	}, row)

	local statusIcon = create("TextLabel", {
		Name = "StatusIcon",
		Text = "⚠",
		TextColor3 = Color3.fromRGB(255, 190, 70),
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(25, 40),
		Position = UDim2.fromOffset(5, 0),
		TextXAlignment = Enum.TextXAlignment.Center
	}, header)

	local title = create("TextLabel", {
		Name = "Title",
		Text = tostring(errorData.Name) .. " failed",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 13,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -65, 1, 0),
		Position = UDim2.fromOffset(32, 0),
		TextXAlignment = Enum.TextXAlignment.Left
	}, header)

	local arrow = create("TextLabel", {
		Name = "Arrow",
		Text = ">",
		TextColor3 = Color3.fromRGB(190, 190, 190),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(25, 40),
		Position = UDim2.new(1, -30, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Center
	}, header)

	--==================================================
	-- DETAILS
	--==================================================

	local details = create("TextLabel", {
		Name = "Details",
		Text = tostring(errorData.Message),
		TextColor3 = Color3.fromRGB(210, 210, 210),
		TextSize = 11,
		Font = Enum.Font.Code,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 43),
		Size = UDim2.new(1, -16, 0, 100),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Visible = false
	}, row)

	create("UICorner", {
		CornerRadius = UDim.new(0, 5)
	}, details)

	--==================================================
	-- ROW DATA
	--==================================================

	local data = {
		Row = row,
		Header = header,
		Details = details,
		Arrow = arrow,
		Expanded = false
	}

	rowData[index] = data

	--==================================================
	-- EXPAND / COLLAPSE
	--==================================================

	header.MouseEnter:Connect(function()
		header.BackgroundTransparency = 0.9
	end)

	header.MouseLeave:Connect(function()
		header.BackgroundTransparency = 1
	end)

	header.MouseButton1Click:Connect(function()
		data.Expanded = not data.Expanded

		if data.Expanded then
			data.Details.Visible = true
			data.Arrow.Text = "v"
			row.Size = UDim2.new(1, -10, 0, 150)
		else
			data.Details.Visible = false
			data.Arrow.Text = ">"
			row.Size = UDim2.new(1, -10, 0, 40)
		end

		updateCanvas()
	end)
end

--==================================================
-- REFRESH LIST
--==================================================

local function refresh()
	if not listFrame then
		return
	end

	for _, data in ipairs(rowData) do
		if data.Row then
			data.Row:Destroy()
		end
	end

	table.clear(rowData)

	for index, errorData in ipairs(errors) do
		createErrorRow(index, errorData)
	end

	updateCount()
	updateCanvas()
end

--==================================================
-- ADD ERROR
--==================================================

function ErrorPanel:Add(functionName, errorMessage)
	if not functionName then
		functionName = "Unknown function"
	end

	if not errorMessage then
		errorMessage = "Unknown error"
	end

	table.insert(errors, 1, {
		Name = tostring(functionName),
		Message = tostring(errorMessage)
	})

	while #errors > MAX_ERRORS do
		table.remove(errors)
	end

	refresh()
end

--==================================================
-- SHOW
--==================================================

function ErrorPanel:Show()
	if panel then
		panel.Visible = true
	end
end

--==================================================
-- HIDE
--==================================================

function ErrorPanel:Hide()
	if panel then
		panel.Visible = false
	end
end

--==================================================
-- TOGGLE
--==================================================

function ErrorPanel:Toggle()
	if not panel then
		return
	end

	panel.Visible = not panel.Visible
end

--==================================================
-- INIT
--==================================================

function ErrorPanel:Init(parentGui)
	gui = parentGui

	--==================================================
	-- MAIN PANEL
	--==================================================

	panel = create("Frame", {
		Name = "ErrorPanel",
		Size = UDim2.fromOffset(340, 300),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20
	}, gui)

	create("UICorner", {
		CornerRadius = UDim.new(0, 8)
	}, panel)

	--==================================================
	-- TITLE
	--==================================================

	local titleBar = create("Frame", {
		Name = "TitleBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		ZIndex = 21
	}, panel)

	create("TextLabel", {
		Text = "Error Details",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 21
	}, titleBar)

	countLabel = create("TextLabel", {
		Text = "Errors: 0",
		TextColor3 = Color3.fromRGB(160, 160, 160),
		TextSize = 11,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(70, 40),
		Position = UDim2.new(1, -150, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 21
	}, titleBar)

	--==================================================
	-- CLOSE BUTTON
	--==================================================

	local closeButton = create("TextButton", {
		Name = "Close",
		Text = "X",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		BackgroundColor3 = Color3.fromRGB(70, 70, 70),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -35, 0, 5),
		AutoButtonColor = false,
		ZIndex = 21
	}, titleBar)

	create("UICorner", {
		CornerRadius = UDim.new(0, 6)
	}, closeButton)

	closeButton.MouseButton1Click:Connect(function()
		ErrorPanel:Hide()
	end)

	--==================================================
	-- CLEAR ALL
	--==================================================

	local clearButton = create("TextButton", {
		Name = "ClearAll",
		Text = "Clear All",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(65, 28),
		Position = UDim2.new(1, -105, 0, 6),
		AutoButtonColor = false,
		ZIndex = 21
	}, titleBar)

	create("UICorner", {
		CornerRadius = UDim.new(0, 6)
	}, clearButton)

	clearButton.MouseEnter:Connect(function()
		clearButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
	end)

	clearButton.MouseLeave:Connect(function()
		clearButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
	end)

	clearButton.MouseButton1Click:Connect(function()
		ErrorPanel:Clear()
	end)

	--==================================================
	-- ERROR LIST
	--==================================================

	listFrame = create("ScrollingFrame", {
		Name = "ErrorList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(5, 45),
		Size = UDim2.new(1, -10, 1, -50),
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarThickness = 4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 21
	}, panel)

	listLayout = create("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, listFrame)

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

	updateCount()
	updateCanvas()
end

return ErrorPanel
