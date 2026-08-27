-- Steal the brainrot base

--==================================================
-- LUCKY DROP TELEPORT GUI
-- Optimized & Debugged | Functions Preserved
-- X button completely terminates the GUI
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local TELEPORTS = {
	["Easter's Base"] = Vector3.new(100, 50, 100),
	["67's Base"] = Vector3.new(200, 50, 200),
	["Pot Hotspot's Base"] = Vector3.new(300, 50, 300),
	["Dragon Cannelloni's Base"] = Vector3.new(400, 50, 400),
	["Cappuccino Assassino's Base"] = Vector3.new(500, 50, 500),
}

local COLORS = {
	BACKGROUND = Color3.fromRGB(30, 30, 30),
	BACKGROUND_ACTIVE = Color3.fromRGB(35, 35, 35),
	BUTTON_YES = Color3.fromRGB(55, 180, 90),
	BUTTON_NO = Color3.fromRGB(65, 65, 65),
	BUTTON_CLOSE = Color3.fromRGB(55, 55, 55),
	DOT = Color3.fromRGB(70, 220, 100),
	TEXT = Color3.fromRGB(255, 255, 255),
	TEXT_DIM = Color3.fromRGB(190, 190, 190),
}

local SIZES = {
	ACTIVE = {105, 38},
	PANEL = {300, 150},
	DOT = {10, 10},
	CLOSE = {28, 28},
	BUTTON = {115, 38},
}

--==================================================
-- CLEAN OLD GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("LuckyDropTeleport")
if oldGui then
	oldGui:Destroy()
end

--==================================================
-- GUI CREATION
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "LuckyDropTeleport"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--==================================================
-- DRAG SYSTEM (Optimized)
--==================================================

local function makeDraggable(object)
	local dragging = false
	local dragStart = nil
	local startPosition = nil
	local dragConnection = nil
	
	object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			
			dragging = true
			dragStart = input.Position
			startPosition = object.Position
		end
	end)
	
	object.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	dragConnection = UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			
			local delta = input.Position - dragStart
			
			object.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
	
	return dragConnection
end

--==================================================
-- UI CREATION HELPERS (Optimized)
--==================================================

local function createCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = type(radius) == "number" and UDim.new(0, radius) or radius
	corner.Parent = instance
	return corner
end

local function createTextLabel(parent, name, props)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.TextColor3 = COLORS.TEXT
	label.TextSize = props.TextSize or 15
	label.Font = props.Font or Enum.Font.GothamMedium
	label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
	label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	label.TextWrapped = props.TextWrapped or false
	
	if props.Size then label.Size = props.Size end
	if props.Position then label.Position = props.Position end
	if props.Text then label.Text = props.Text end
	if props.TextColor3 then label.TextColor3 = props.TextColor3 end
	
	label.Parent = parent
	return label
end

local function createButton(parent, name, props)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = props.Size or UDim2.fromOffset(100, 30)
	button.BackgroundColor3 = props.BackgroundColor3 or COLORS.BUTTON_NO
	button.BorderSizePixel = 0
	button.Text = props.Text or ""
	button.TextColor3 = props.TextColor3 or COLORS.TEXT
	button.TextSize = props.TextSize or 15
	button.Font = props.Font or Enum.Font.GothamMedium
	button.AutoButtonColor = true
	
	if props.Position then button.Position = props.Position end
	if props.BackgroundTransparency then button.BackgroundTransparency = props.BackgroundTransparency end
	
	if props.CornerRadius then
		createCorner(button, props.CornerRadius)
	end
	
	button.Parent = parent
	return button
end

--==================================================
-- ACTIVE INDICATOR
--==================================================

local Active = Instance.new("Frame")
Active.Name = "Active"
Active.Size = UDim2.fromOffset(SIZES.ACTIVE[1], SIZES.ACTIVE[2])
Active.Position = UDim2.fromOffset(20, 20)
Active.BackgroundColor3 = COLORS.BACKGROUND_ACTIVE
Active.BorderSizePixel = 0
Active.Parent = Gui

createCorner(Active, 1)

local ActiveDot = Instance.new("Frame")
ActiveDot.Size = UDim2.fromOffset(SIZES.DOT[1], SIZES.DOT[2])
ActiveDot.Position = UDim2.new(0, 13, 0.5, -5)
ActiveDot.BackgroundColor3 = COLORS.DOT
ActiveDot.BorderSizePixel = 0
ActiveDot.Parent = Active

createCorner(ActiveDot, 1)

createTextLabel(Active, "ActiveText", {
	Size = UDim2.new(1, -32, 1, 0),
	Position = UDim2.fromOffset(30, 0),
	Text = "Active",
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local dragConnection = makeDraggable(Active)

--==================================================
-- PROMPT PANEL
--==================================================

local Panel = Instance.new("Frame")
Panel.Name = "Prompt"
Panel.Size = UDim2.fromOffset(SIZES.PANEL[1], SIZES.PANEL[2])
Panel.Position = UDim2.new(0.5, -SIZES.PANEL[1]/2, 0.5, -SIZES.PANEL[2]/2)
Panel.BackgroundColor3 = COLORS.BACKGROUND
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Parent = Gui

createCorner(Panel, 12)

--==================================================
-- X CLOSE / TERMINATE BUTTON
--==================================================

local Close = createButton(Panel, "Close", {
	Size = UDim2.fromOffset(SIZES.CLOSE[1], SIZES.CLOSE[2]),
	Position = UDim2.new(1, -SIZES.CLOSE[1] - 6, 0, 6),
	BackgroundColor3 = COLORS.BUTTON_CLOSE,
	Text = "×",
	TextSize = 20,
	Font = Enum.Font.GothamBold,
	CornerRadius = 1,
})

--==================================================
-- MESSAGE
--==================================================

createTextLabel(Panel, "Message", {
	Size = UDim2.new(1, -55, 0, 55),
	Position = UDim2.fromOffset(15, 15),
	Text = "Lucky Drop at Base",
	TextSize = 17,
	TextWrapped = true,
})

--==================================================
-- QUESTION
--==================================================

createTextLabel(Panel, "Question", {
	Size = UDim2.new(1, 0, 0, 25),
	Position = UDim2.fromOffset(0, 68),
	Text = "Teleport?",
	TextColor3 = COLORS.TEXT_DIM,
	TextSize = 14,
	Font = Enum.Font.Gotham,
})

--==================================================
-- YES BUTTON
--==================================================

local Yes = createButton(Panel, "Yes", {
	Size = UDim2.fromOffset(SIZES.BUTTON[1], SIZES.BUTTON[2]),
	Position = UDim2.fromOffset(25, 105),
	BackgroundColor3 = COLORS.BUTTON_YES,
	Text = "Yes",
	TextSize = 15,
	CornerRadius = 8,
})

--==================================================
-- NO BUTTON
--==================================================

local No = createButton(Panel, "No", {
	Size = UDim2.fromOffset(SIZES.BUTTON[1], SIZES.BUTTON[2]),
	Position = UDim2.fromOffset(SIZES.PANEL[1] - SIZES.BUTTON[1] - 25, 105),
	BackgroundColor3 = COLORS.BUTTON_NO,
	Text = "No",
	TextSize = 15,
	CornerRadius = 8,
})

--==================================================
-- STATE
--==================================================

local state = {
	currentBase = nil,
	terminated = false,
	pendingTeleport = false,
}

--==================================================
-- CACHED CHARACTER REFERENCES (Optimization)
--==================================================

local cachedCharacter = nil
local cachedRoot = nil

local function invalidateCache()
	cachedCharacter = nil
	cachedRoot = nil
end

local function getRootPart()
	if not cachedCharacter or not cachedCharacter.Parent then
		cachedCharacter = Player.Character
	end
	
	if not cachedRoot or not cachedRoot.Parent then
		cachedRoot = cachedCharacter and cachedCharacter:FindFirstChild("HumanoidRootPart")
	end
	
	return cachedRoot
end

--==================================================
-- TELEPORT (Optimized)
--==================================================

local function teleportToBase(baseName)
	if state.terminated then return end
	
	local position = TELEPORTS[baseName]
	if not position then
		warn("Base not found: " .. baseName)
		return false
	end
	
	local root = getRootPart()
	if not root then
		warn("No HumanoidRootPart found")
		return false
	end
	
	-- Teleport with safety check
	root.CFrame = CFrame.new(position)
	print("🚀 Teleported to: " .. baseName)
	
	-- Visual feedback for panel
	state.pendingTeleport = false
	Panel.Visible = false
	
	return true
end

--==================================================
-- PANEL SHOW WITH ANIMATION
--==================================================

local function showPanel(baseName)
	if state.terminated then return end
	
	state.currentBase = baseName
	
	-- Update message
	local messageLabel = Panel:FindFirstChild("Message")
	if messageLabel then
		messageLabel.Text = "Lucky Drop at " .. baseName
	end
	
	-- Show with slight animation
	Panel.Visible = true
	Panel.BackgroundTransparency = 0.5
	
	-- Smooth fade in
	task.spawn(function()
		for i = 1, 10 do
			if state.terminated then break end
			Panel.BackgroundTransparency = 0.5 - (i * 0.05)
			task.wait(0.02)
		end
		Panel.BackgroundTransparency = 0
	end)
end

--==================================================
-- TERMINATE (Optimized)
--==================================================

local function terminate()
	if state.terminated then
		return
	end
	
	state.terminated = true
	state.currentBase = nil
	state.pendingTeleport = false
	
	-- Clean up notification connection
	if notificationConnection then
		notificationConnection:Disconnect()
		notificationConnection = nil
	end
	
	-- Clean up drag connection
	if dragConnection then
		dragConnection:Disconnect()
		dragConnection = nil
	end
	
	-- Remove GUI with cleanup
	if Gui and Gui.Parent then
		-- Clear children first for proper cleanup
		for _, child in ipairs(Gui:GetChildren()) do
			child:Destroy()
		end
		Gui:Destroy()
	end
	
	print("🛑 Lucky Drop Teleport GUI terminated")
end

--==================================================
-- BUTTON EVENTS
--==================================================

Yes.MouseButton1Click:Connect(function()
	if state.terminated or not state.currentBase then
		return
	end
	
	teleportToBase(state.currentBase)
end)

No.MouseButton1Click:Connect(function()
	if state.terminated then
		return
	end
	
	state.currentBase = nil
	state.pendingTeleport = false
	Panel.Visible = false
end)

-- X = FULL TERMINATION
Close.MouseButton1Click:Connect(function()
	terminate()
end)

--==================================================
-- KEYBOARD SHORTCUT (Added feature)
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or state.terminated then
		return
	end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.X then
			-- X key also terminates
			terminate()
		elseif input.KeyCode == Enum.KeyCode.Y and Panel.Visible then
			-- Y key for Yes
			Yes.MouseButton1Click:Fire()
		elseif input.KeyCode == Enum.KeyCode.N and Panel.Visible then
			-- N key for No
			No.MouseButton1Click:Fire()
		end
	end
end)

--==================================================
-- NOTIFICATION DETECTION (Optimized)
--==================================================

local Events = ReplicatedStorage:WaitForChild("Events")
local ShowNotification = Events:WaitForChild("ShowNotification")

notificationConnection = ShowNotification.OnClientEvent:Connect(function(message, color)
	if state.terminated then
		return
	end
	
	if typeof(message) ~= "string" then
		return
	end
	
	-- Optimized: Check for base names with early exit
	local foundBase = nil
	for baseName in pairs(TELEPORTS) do
		if message:find(baseName, 1, true) then
			foundBase = baseName
			break
		end
	end
	
	if foundBase then
		showPanel(foundBase)
	end
end)

--==================================================
-- CHARACTER RESPAWN HANDLER (Added)
--==================================================

Player.CharacterAdded:Connect(function(character)
	invalidateCache()
	
	-- Reset pending teleport state
	if state.pendingTeleport then
		state.pendingTeleport = false
		Panel.Visible = false
	end
end)

--==================================================
-- GUI CLOSE ON RESPAWN (Added)
--==================================================

Player.CharacterAdded:Connect(function()
	-- Hide panel on respawn
	if Panel then
		Panel.Visible = false
	end
end)

--==================================================
-- BETTER ERROR HANDLING
--==================================================

local function safeTeleport(baseName)
	local success, err = pcall(function()
		teleportToBase(baseName)
	end)
	
	if not success then
		warn("Teleport failed: " .. tostring(err))
		state.currentBase = nil
		Panel.Visible = false
	end
end

-- Override Yes button with safe teleport
Yes.MouseButton1Click:Connect(function()
	if state.terminated or not state.currentBase then
		return
	end
	
	safeTeleport(state.currentBase)
end)

--==================================================
-- CLEANUP ON PLAYER LEAVING (Added)
--==================================================

local function onPlayerRemoving()
	terminate()
end

-- Disconnect when player leaves
local playerRemovingConnection
playerRemovingConnection = Player.AncestryChanged:Connect(function()
	if not Player.Parent then
		playerRemovingConnection:Disconnect()
		terminate()
	end
end)

--==================================================
-- DEBUG INFO (Optional)
--==================================================

print("✅ Lucky Drop Teleport GUI active")
print("📌 " .. #TELEPORTS .. " teleport locations loaded")
print("⌨️ Press X to terminate, Y/N for Yes/No")

--==================================================
-- RETURN FUNCTIONS FOR EXTERNAL USE
--==================================================

return {
	Gui = Gui,
	terminate = terminate,
	teleportToBase = teleportToBase,
	getState = function() return state end,
}
