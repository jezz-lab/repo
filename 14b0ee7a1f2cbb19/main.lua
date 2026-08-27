-- ============================================
-- FLY & INF. JUMP GUI
-- Optimized / Debugged / Functions Preserved
-- ============================================

--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// PLAYER
local Player = Players.LocalPlayer

--// GUI
local sg = script.Parent

local mf = sg:WaitForChild("MainFrame")
local ti = sg:WaitForChild("ToggleIcon")

local tb = mf:FindFirstChild("TitleBar")
local ft = mf:FindFirstChild("FlyToggle")
local jt = mf:FindFirstChild("JumpToggle")
local si = mf:FindFirstChild("SpeedInput")
local sb = mf:FindFirstChild("SetButton")
local db = mf:FindFirstChild("DefaultButton")
local ht = mf:FindFirstChild("HintText")

-- ============================================
-- CONFIG
-- ============================================

local SIZES = {
	PC = {280, 170},
	TABLET = {350, 210},
	PHONE = {420, 260},
}

local TRANS = {
	INTERACTIVE = 0,
	STATIC = 0.05,
}

local CONFIG = {
	KEY = Enum.KeyCode.F,
	SPEED = 50,
	FLY = false,
	JUMP = false,
	OPEN = true,
	ON = Color3.fromRGB(0, 200, 100),
	OFF = Color3.fromRGB(60, 60, 60),
	BG = Color3.fromRGB(26, 26, 46),
	ACCENT = Color3.fromRGB(233, 69, 96),
	TEXT = Color3.fromRGB(255, 255, 255),
	ERR = Color3.fromRGB(200, 0, 0),
	SUC = Color3.fromRGB(0, 200, 100),
}

local SPEED_LIMITS = {
	MIN = 0,
	MAX = 200,
}

-- ============================================
-- STATE
-- ============================================

local state = {
	flying = CONFIG.FLY,
	jump = CONFIG.JUMP,
	speed = CONFIG.SPEED,
	open = CONFIG.OPEN,
	device = "PC",
}

-- ============================================
-- OPTIMIZED HELPERS
-- ============================================

local function getViewportSize()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function detectDevice()
	local viewport = getViewportSize()
	if viewport.X >= 1280 then return "PC"
	elseif viewport.X >= 768 then return "TABLET"
	else return "PHONE" end
end

local function buildSizes()
	local size = SIZES[state.device] or SIZES.PC
	local w, h = size[1], size[2]
	
	return {
		W = w, H = h,
		TH = math.floor(h * 0.20),
		TS = math.floor(w * 0.055),
		BW = math.floor(w * 0.40),
		BH = math.floor(h * 0.18),
		BF = math.floor(w * 0.05),
		IW = math.floor(w * 0.28),
		IH = math.floor(h * 0.15),
		IF = math.floor(w * 0.05),
		IC = math.floor(w * 0.10),
		IFont = math.floor(w * 0.065),
		P = math.floor(w * 0.035),
		HH = math.floor(h * 0.15),
		HF = math.floor(w * 0.04),
	}
end

-- ============================================
-- CACHED CHARACTER REFERENCES (Optimization)
-- ============================================

local cachedCharacter = nil
local cachedHumanoid = nil
local cachedRoot = nil

local function invalidateCache()
	cachedCharacter = nil
	cachedHumanoid = nil
	cachedRoot = nil
end

local function getCharacter()
	if not cachedCharacter or not cachedCharacter.Parent then
		cachedCharacter = Player.Character
	end
	return cachedCharacter
end

local function getHumanoid()
	if not cachedHumanoid or not cachedHumanoid.Parent then
		local character = getCharacter()
		cachedHumanoid = character and character:FindFirstChildOfClass("Humanoid")
	end
	return cachedHumanoid
end

local function getRootPart()
	if not cachedRoot or not cachedRoot.Parent then
		local character = getCharacter()
		cachedRoot = character and character:FindFirstChild("HumanoidRootPart")
	end
	return cachedRoot
end

-- ============================================
-- OPTIMIZED GUI APPLICATION
-- ============================================

local function applyGui()
	local s = sizes
	
	-- Main frame
	mf.Size = UDim2.fromOffset(s.W, s.H)
	mf.BackgroundTransparency = TRANS.STATIC
	mf.BackgroundColor3 = CONFIG.BG
	mf.BorderSizePixel = 1
	mf.BorderColor3 = CONFIG.ACCENT

	-- Toggle icon
	ti.Size = UDim2.fromOffset(s.IC, s.IC)
	ti.Position = UDim2.new(0.95, -s.IC/2, 0.05, 0)
	ti.BackgroundColor3 = CONFIG.ACCENT
	ti.TextColor3 = CONFIG.TEXT
	ti.TextSize = s.IFont
	ti.Text = state.open and "[≡]" or "[+]"
	ti.BackgroundTransparency = TRANS.INTERACTIVE

	-- Title
	if tb then
		tb.Size = UDim2.new(1, 0, 0, s.TH)
		tb.Position = UDim2.fromOffset(0, 0)
		tb.BackgroundColor3 = CONFIG.ACCENT
		tb.TextColor3 = CONFIG.TEXT
		tb.TextSize = s.TS
		tb.Text = "FLY & INF. JUMP"
		tb.TextXAlignment = Enum.TextXAlignment.Center
		tb.BackgroundTransparency = TRANS.STATIC
	end

	-- Fly button
	if ft then
		ft.Size = UDim2.fromOffset(s.BW, s.BH)
		ft.Position = UDim2.fromOffset(s.P, s.TH + s.P)
		ft.BackgroundColor3 = state.flying and CONFIG.ON or CONFIG.OFF
		ft.TextColor3 = CONFIG.TEXT
		ft.TextSize = s.BF
		ft.Text = state.flying and "FLY : ON" or "FLY : OFF"
		ft.BackgroundTransparency = TRANS.INTERACTIVE
	end

	-- Jump button
	if jt then
		jt.Size = UDim2.fromOffset(s.BW, s.BH)
		jt.Position = UDim2.new(1, -s.BW - s.P, 0, s.TH + s.P)
		jt.BackgroundColor3 = state.jump and CONFIG.ON or CONFIG.OFF
		jt.TextColor3 = CONFIG.TEXT
		jt.TextSize = s.BF
		jt.Text = state.jump and "JUMP : ON" or "JUMP : OFF"
		jt.BackgroundTransparency = TRANS.INTERACTIVE
	end

	-- Speed row
	local speedY = s.TH + s.BH + s.P * 2

	if si then
		si.Size = UDim2.fromOffset(s.IW, s.IH)
		si.Position = UDim2.fromOffset(s.P, speedY)
		si.BackgroundColor3 = Color3.fromRGB(10, 10, 26)
		si.TextColor3 = CONFIG.TEXT
		si.TextSize = s.IF
		si.BackgroundTransparency = TRANS.INTERACTIVE
	end

	local buttonWidth = (s.W - s.IW - s.P * 3) / 2

	if sb then
		sb.Size = UDim2.fromOffset(buttonWidth, s.IH)
		sb.Position = UDim2.fromOffset(s.IW + s.P * 1.5, speedY)
		sb.BackgroundColor3 = CONFIG.OFF
		sb.TextColor3 = CONFIG.TEXT
		sb.TextSize = s.IF
		sb.Text = "SET"
		sb.BackgroundTransparency = TRANS.INTERACTIVE
	end

	if db then
		db.Size = UDim2.fromOffset(buttonWidth, s.IH)
		db.Position = UDim2.new(1, -buttonWidth - s.P, 0, speedY)
		db.BackgroundColor3 = CONFIG.OFF
		db.TextColor3 = CONFIG.TEXT
		db.TextSize = s.IF
		db.Text = "DEFAULT"
		db.BackgroundTransparency = TRANS.INTERACTIVE
	end

	-- Hint
	if ht then
		ht.Size = UDim2.new(1, -s.P * 2, 0, s.HH)
		ht.Position = UDim2.new(0, s.P, 0, s.H - s.HH - 5)
		ht.TextColor3 = CONFIG.TEXT
		ht.TextSize = s.HF
		ht.Text = "─── Click [≡] or press F to toggle ───"
		ht.BackgroundTransparency = TRANS.STATIC
	end

	mf.Visible = state.open
end

-- ============================================
-- OPTIMIZED FLY SYSTEM
-- ============================================

local flyConnection = nil
local flyVelocity = nil
local flyGyro = nil

local function cleanupFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	
	if flyVelocity then
		flyVelocity:Destroy()
		flyVelocity = nil
	end
	
	if flyGyro then
		flyGyro:Destroy()
		flyGyro = nil
	end
	
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.PlatformStand = false
	end
end

local function startFly()
	cleanupFly()
	
	local humanoid = getHumanoid()
	local root = getRootPart()
	
	if not humanoid or not root then
		return
	end
	
	humanoid.PlatformStand = true
	
	flyVelocity = Instance.new("BodyVelocity")
	flyVelocity.Name = "FlyVelocity"
	flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyVelocity.Velocity = Vector3.zero
	flyVelocity.Parent = root
	
	flyGyro = Instance.new("BodyGyro")
	flyGyro.Name = "FlyGyro"
	flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	flyGyro.P = 10000
	flyGyro.CFrame = root.CFrame
	flyGyro.Parent = root
	
	local lastMoveDirection = Vector3.zero
	
	flyConnection = RunService.RenderStepped:Connect(function()
		if not state.flying then return end
		
		local root = getRootPart()
		if not root or not root.Parent then
			cleanupFly()
			return
		end
		
		local humanoid = getHumanoid()
		if not humanoid then return end
		
		local camera = workspace.CurrentCamera
		if not camera then return end
		
		local moveDirection = humanoid.MoveDirection
		
		-- Only update velocity if direction changed (optimization)
		if moveDirection.Magnitude > 0.01 then
			if moveDirection ~= lastMoveDirection then
				flyVelocity.Velocity = moveDirection.Unit * state.speed
				lastMoveDirection = moveDirection
			end
		elseif flyVelocity.Velocity ~= Vector3.zero then
			flyVelocity.Velocity = Vector3.zero
			lastMoveDirection = Vector3.zero
		end
		
		-- Update gyro
		flyGyro.CFrame = CFrame.lookAt(
			root.Position,
			root.Position + camera.CFrame.LookVector
		)
	end)
end

local function applyFly()
	if state.flying then
		startFly()
	else
		cleanupFly()
	end
end

-- ============================================
-- OPTIMIZED SPEED
-- ============================================

local function applySpeed()
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.WalkSpeed = state.speed
	end
end

-- ============================================
-- BUTTON UPDATES (Optimized with caching)
-- ============================================

local function updateFlyButton()
	if ft then
		ft.Text = state.flying and "FLY : ON" or "FLY : OFF"
		ft.BackgroundColor3 = state.flying and CONFIG.ON or CONFIG.OFF
	end
end

local function updateJumpButton()
	if jt then
		jt.Text = state.jump and "JUMP : ON" or "JUMP : OFF"
		jt.BackgroundColor3 = state.jump and CONFIG.ON or CONFIG.OFF
	end
end

-- ============================================
-- GUI TOGGLE
-- ============================================

local function toggleGui()
	state.open = not state.open
	mf.Visible = state.open
	ti.Text = state.open and "[≡]" or "[+]"
end

-- ============================================
-- RESET
-- ============================================

local function reset()
	state.flying = CONFIG.FLY
	state.jump = CONFIG.JUMP
	state.speed = CONFIG.SPEED
	
	updateFlyButton()
	updateJumpButton()
	
	if si then
		si.Text = tostring(state.speed)
	end
	
	applySpeed()
	applyFly()
end

-- ============================================
-- OPTIMIZED INFINITE JUMP
-- ============================================

UserInputService.JumpRequest:Connect(function()
	if state.jump then
		local humanoid = getHumanoid()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- ============================================
-- OPTIMIZED DRAG SYSTEM
-- ============================================

local function isInsideGui(guiObject, position)
	if not guiObject or not guiObject.Visible then
		return false
	end
	
	local pos = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize
	
	return position.X >= pos.X 
		and position.X <= pos.X + size.X
		and position.Y >= pos.Y
		and position.Y <= pos.Y + size.Y
end

local function drag(guiObject, exclusions)
	exclusions = exclusions or {}
	
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPosition = nil
	
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		
		for _, excluded in ipairs(exclusions) do
			if isInsideGui(excluded, input.Position) then
				return
			end
		end
		
		dragging = true
		dragInput = input
		dragStart = input.Position
		startPosition = guiObject.Position
	end)
	
	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= dragInput then
			return
		end
		
		local delta = input.Position - dragStart
		
		guiObject.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input == dragStart
			or input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ============================================
-- DRAG SETUP
-- ============================================

drag(ti)
drag(mf, {ft, jt, si, sb, db})

-- ============================================
-- KEYBOARD SHORTCUT
-- ============================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == CONFIG.KEY then
		toggleGui()
	end
end)

-- ============================================
-- TOGGLE ICON
-- ============================================

ti.MouseButton1Click:Connect(toggleGui)

-- ============================================
-- FLY BUTTON
-- ============================================

if ft then
	ft.MouseButton1Click:Connect(function()
		state.flying = not state.flying
		updateFlyButton()
		applyFly()
	end)
end

-- ============================================
-- JUMP BUTTON
-- ============================================

if jt then
	jt.MouseButton1Click:Connect(function()
		state.jump = not state.jump
		updateJumpButton()
	end)
end

-- ============================================
-- SPEED SET
-- ============================================

local function showButtonFeedback(button, text, color)
	if not button then return end
	
	button.Text = text
	button.BackgroundColor3 = color
	
	task.delay(0.2, function()
		if button and button.Parent then
			button.Text = button == db and "DEFAULT" or "SET"
			button.BackgroundColor3 = CONFIG.OFF
		end
	end)
end

if sb and si then
	sb.MouseButton1Click:Connect(function()
		local value = tonumber(si.Text)
		
		if value 
			and value >= SPEED_LIMITS.MIN 
			and value <= SPEED_LIMITS.MAX then
			
			state.speed = value
			applySpeed()
			showButtonFeedback(sb, "✓", CONFIG.SUC)
		else
			si.Text = tostring(state.speed)
			showButtonFeedback(sb, "✗", CONFIG.ERR)
		end
	end)
end

-- ============================================
-- DEFAULT SPEED
-- ============================================

if db then
	db.MouseButton1Click:Connect(function()
		state.speed = CONFIG.SPEED
		
		if si then
			si.Text = tostring(state.speed)
		end
		
		applySpeed()
		showButtonFeedback(db, "✓", CONFIG.SUC)
	end)
end

-- ============================================
-- CHARACTER RESPAWN
-- ============================================

Player.CharacterAdded:Connect(function(character)
	invalidateCache()
	
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end
	
	task.wait()
	applySpeed()
	applyFly()
end)

-- ============================================
-- OPTIMIZED RESIZE
-- ============================================

local resizeConnection = nil

local function onResize()
	local newDevice = detectDevice()
	
	if newDevice == state.device then
		return
	end
	
	state.device = newDevice
	sizes = buildSizes()
	applyGui()
	
	print("📱 Device: " .. state.device)
end

local function connectResize()
	local camera = workspace.CurrentCamera
	if not camera then return end
	
	if resizeConnection then
		resizeConnection:Disconnect()
	end
	
	resizeConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(onResize)
end

connectResize()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectResize)

-- ============================================
-- INIT
-- ============================================

state.device = detectDevice()
sizes = buildSizes()
applyGui()
reset()

print("✅ Fly & Inf. Jump Loaded! | Device: " .. state.device .. " | Press " .. tostring(CONFIG.KEY))
