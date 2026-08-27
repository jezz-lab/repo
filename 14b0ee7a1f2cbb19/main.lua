-- fly, inf jump
-- ============================================
-- FLY & INF. JUMP GUI
-- Optimized / Debugged
-- Functions preserved
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
-- CHARACTER HELPERS
-- ============================================

local function getCharacter()
	return Player.Character
end

local function getHumanoid()
	local character = getCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
	local character = getCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- DEVICE / SIZE
-- ============================================

local function getViewportSize()
	local camera = workspace.CurrentCamera

	if camera then
		return camera.ViewportSize
	end

	return Vector2.new(1280, 720)
end

local function detectDevice()
	local viewport = getViewportSize()

	if viewport.X >= 1280 then
		return "PC"
	elseif viewport.X >= 768 then
		return "TABLET"
	else
		return "PHONE"
	end
end

local function buildSizes()
	local size = SIZES[state.device] or SIZES.PC

	local w = size[1]
	local h = size[2]

	return {
		W = w,
		H = h,

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

state.device = detectDevice()

local sizes = buildSizes()

-- ============================================
-- GUI
-- ============================================

local function updateFlyButton()
	if not ft then
		return
	end

	ft.Text = state.flying and "FLY : ON" or "FLY : OFF"
	ft.BackgroundColor3 = state.flying and CONFIG.ON or CONFIG.OFF
end

local function updateJumpButton()
	if not jt then
		return
	end

	jt.Text = state.jump and "JUMP : ON" or "JUMP : OFF"
	jt.BackgroundColor3 = state.jump and CONFIG.ON or CONFIG.OFF
end

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
	ti.Position = UDim2.new(
		0.95,
		-s.IC / 2,
		0.05,
		0
	)

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
		ft.Position = UDim2.fromOffset(
			s.P,
			s.TH + s.P
		)

		ft.TextColor3 = CONFIG.TEXT
		ft.TextSize = s.BF
		ft.BackgroundTransparency = TRANS.INTERACTIVE

		updateFlyButton()
	end

	-- Infinite jump button
	if jt then
		jt.Size = UDim2.fromOffset(s.BW, s.BH)

		jt.Position = UDim2.new(
			1,
			-s.BW - s.P,
			0,
			s.TH + s.P
		)

		jt.TextColor3 = CONFIG.TEXT
		jt.TextSize = s.BF
		jt.BackgroundTransparency = TRANS.INTERACTIVE

		updateJumpButton()
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

	local buttonWidth =
		(s.W - s.IW - s.P * 3) / 2

	if sb then
		sb.Size = UDim2.fromOffset(
			buttonWidth,
			s.IH
		)

		sb.Position = UDim2.fromOffset(
			s.IW + s.P * 1.5,
			speedY
		)

		sb.BackgroundColor3 = CONFIG.OFF
		sb.TextColor3 = CONFIG.TEXT
		sb.TextSize = s.IF
		sb.Text = "SET"
		sb.BackgroundTransparency = TRANS.INTERACTIVE
	end

	if db then
		db.Size = UDim2.fromOffset(
			buttonWidth,
			s.IH
		)

		db.Position = UDim2.new(
			1,
			-buttonWidth - s.P,
			0,
			speedY
		)

		db.BackgroundColor3 = CONFIG.OFF
		db.TextColor3 = CONFIG.TEXT
		db.TextSize = s.IF
		db.Text = "DEFAULT"
		db.BackgroundTransparency = TRANS.INTERACTIVE
	end

	-- Hint
	if ht then
		ht.Size = UDim2.new(
			1,
			-s.P * 2,
			0,
			s.HH
		)

		ht.Position = UDim2.new(
			0,
			s.P,
			0,
			s.H - s.HH - 5
		)

		ht.TextColor3 = CONFIG.TEXT
		ht.TextSize = s.HF
		ht.Text = "─── Click [≡] or press F to toggle ───"
		ht.BackgroundTransparency = TRANS.STATIC
	end

	mf.Visible = state.open
end

-- ============================================
-- FLY
-- ============================================

local flyConnection
local flyVelocity
local flyGyro
local flyHumanoid

local function cleanupFlyObjects()
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

	if flyHumanoid and flyHumanoid.Parent then
		flyHumanoid.PlatformStand = false
	end

	flyHumanoid = nil
end

local function stopFly()
	cleanupFlyObjects()

	local humanoid = getHumanoid()

	if humanoid then
		humanoid.PlatformStand = false
	end
end

local function startFly()
	stopFly()

	local humanoid = getHumanoid()
	local root = getRootPart()

	if not humanoid or not root then
		return
	end

	flyHumanoid = humanoid

	humanoid.PlatformStand = true

	-- ========================================
	-- LinearVelocity
	-- ========================================

	local attachment = root:FindFirstChild("FlyAttachment")

	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "FlyAttachment"
		attachment.Parent = root
	end

	flyVelocity = Instance.new("LinearVelocity")
	flyVelocity.Name = "FlyVelocity"
	flyVelocity.Attachment0 = attachment
	flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	flyVelocity.MaxForce = math.huge
	flyVelocity.VectorVelocity = Vector3.zero
	flyVelocity.Parent = root

	-- ========================================
	-- AlignOrientation
	-- ========================================

	flyGyro = Instance.new("AlignOrientation")
	flyGyro.Name = "FlyGyro"
	flyGyro.Attachment0 = attachment
	flyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
	flyGyro.MaxTorque = math.huge
	flyGyro.Responsiveness = 200
	flyGyro.CFrame = root.CFrame
	flyGyro.Parent = root

	-- ========================================
	-- UPDATE
	-- ========================================

	flyConnection = RunService.RenderStepped:Connect(function()
		if not state.flying then
			return
		end

		if not root.Parent
			or not humanoid.Parent
			or humanoid.Health <= 0 then

			stopFly()
			return
		end

		local camera = workspace.CurrentCamera

		if not camera then
			return
		end

		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude > 0 then
			flyVelocity.VectorVelocity =
				moveDirection.Unit * state.speed
		else
			flyVelocity.VectorVelocity =
				Vector3.zero
		end

		-- Face camera direction while flying
		local lookVector = camera.CFrame.LookVector

		if lookVector.Magnitude > 0 then
			flyGyro.CFrame = CFrame.lookAt(
				Vector3.zero,
				Vector3.new(
					lookVector.X,
					lookVector.Y,
					lookVector.Z
				)
			)
		end
	end)
end

local function applyFly()
	if state.flying then
		startFly()
	else
		stopFly()
	end
end

-- ============================================
-- SPEED
-- ============================================

local function applySpeed()
	local humanoid = getHumanoid()

	if not humanoid then
		return
	end

	humanoid.WalkSpeed = state.speed
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

	if si then
		si.Text = tostring(state.speed)
	end

	updateFlyButton()
	updateJumpButton()

	applySpeed()
	applyFly()
end

-- ============================================
-- INFINITE JUMP
-- ============================================

UserInputService.JumpRequest:Connect(function()
	if not state.jump then
		return
	end

	local humanoid = getHumanoid()

	if not humanoid then
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	-- Don't force jump while sitting
	if humanoid.Sit then
		return
	end

	humanoid:ChangeState(
		Enum.HumanoidStateType.Jumping
	)
end)

-- ============================================
-- DRAG
-- Supports Mouse + Touch
-- ============================================

local function isInsideGui(guiObject, position)
	if not guiObject or not guiObject.Visible then
		return false
	end

	local pos = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize

	return (
		position.X >= pos.X
		and position.X <= pos.X + size.X
		and position.Y >= pos.Y
		and position.Y <= pos.Y + size.Y
	)
end

local function drag(guiObject, exclusions)
	if not guiObject then
		return
	end

	exclusions = exclusions or {}

	local dragging = false
	local dragInput
	local dragStart
	local startPosition

	local dragThreshold = 5
	local moved = false

	guiObject.InputBegan:Connect(function(input)
		local inputType = input.UserInputType

		if inputType ~= Enum.UserInputType.MouseButton1
			and inputType ~= Enum.UserInputType.Touch then
			return
		end

		-- Don't drag when clicking excluded controls
		for _, excluded in ipairs(exclusions) do
			if isInsideGui(excluded, input.Position) then
				return
			end
		end

		dragging = true
		moved = false

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

	local changedConnection

	changedConnection = UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input ~= dragInput then
			return
		end

		local delta = input.Position - dragStart

		if math.abs(delta.X) >= dragThreshold
			or math.abs(delta.Y) >= dragThreshold then

			moved = true
		end

		guiObject.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,

			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if not dragging then
			return
		end

		local inputType = input.UserInputType

		-- FIX:
		-- Only stop the current drag input.
		if input == dragInput
			or input == dragStart
			or inputType == Enum.UserInputType.MouseButton1
			or inputType == Enum.UserInputType.Touch then

			dragging = false
			dragInput = nil
		end
	end)

	return function()
		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end
	end
end

-- ============================================
-- DRAG SETUP
-- ============================================

drag(ti)

drag(mf, {
	ft,
	jt,
	si,
	sb,
	db,
})

-- ============================================
-- KEYBOARD
-- ============================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == CONFIG.KEY then

		toggleGui()
	end
end)

-- ============================================
-- TOGGLE ICON
-- ============================================

ti.MouseButton1Click:Connect(function()
	toggleGui()
end)

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
-- INFINITE JUMP BUTTON
-- ============================================

if jt then
	jt.MouseButton1Click:Connect(function()
		state.jump = not state.jump

		updateJumpButton()
	end)
end

-- ============================================
-- BUTTON FEEDBACK
-- ============================================

local function showButtonFeedback(button, text, color)
	if not button then
		return
	end

	button.Text = text
	button.BackgroundColor3 = color

	task.delay(0.2, function()
		if not button or not button.Parent then
			return
		end

		if button == db then
			button.Text = "DEFAULT"
		elseif button == sb then
			button.Text = "SET"
		end

		button.BackgroundColor3 = CONFIG.OFF
	end)
end

-- ============================================
-- SET SPEED
-- ============================================

if sb and si then
	sb.MouseButton1Click:Connect(function()
		local value = tonumber(si.Text)

		if not value then
			si.Text = tostring(state.speed)

			showButtonFeedback(
				sb,
				"✗",
				CONFIG.ERR
			)

			return
		end

		if value < SPEED_LIMITS.MIN
			or value > SPEED_LIMITS.MAX then

			si.Text = tostring(state.speed)

			showButtonFeedback(
				sb,
				"✗",
				CONFIG.ERR
			)

			return
		end

		state.speed = value

		-- Normalize displayed value
		si.Text = tostring(state.speed)

		applySpeed()

		-- Update active fly velocity immediately
		if flyVelocity then
			local humanoid = getHumanoid()

			if humanoid then
				local direction = humanoid.MoveDirection

				if direction.Magnitude > 0 then
					flyVelocity.VectorVelocity =
						direction.Unit * state.speed
				end
			end
		end

		showButtonFeedback(
			sb,
			"✓",
			CONFIG.SUC
		)
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

		showButtonFeedback(
			db,
			"✓",
			CONFIG.SUC
		)
	end)
end

-- ============================================
-- CHARACTER RESPAWN
-- ============================================

Player.CharacterAdded:Connect(function(character)
	-- Clean up anything attached to the old character
	stopFly()

	local humanoid = character:WaitForChild(
		"Humanoid",
		5
	)

	if not humanoid then
		return
	end

	local root = character:WaitForChild(
		"HumanoidRootPart",
		5
	)

	if not root then
		return
	end

	task.wait()

	applySpeed()

	if state.flying then
		applyFly()
	end
end)

-- ============================================
-- RESIZE
-- ============================================

local resizeConnection

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

	if not camera then
		return
	end

	if resizeConnection then
		resizeConnection:Disconnect()
		resizeConnection = nil
	end

	resizeConnection =
		camera:GetPropertyChangedSignal("ViewportSize")
			:Connect(onResize)
end

connectResize()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	connectResize()
end)

-- ============================================
-- INIT
-- ============================================

applyGui()
reset()

print(
	"✅ Fly & Inf. Jump Loaded!"
	.. " | Device: "
	.. state.device
	.. " | Press "
	.. tostring(CONFIG.KEY)
)
