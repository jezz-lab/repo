--==================================================
-- FARM A FISH | BEE EVENT (Minimized)
--==================================================

local Players, UIS, RS, RepSto = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("ReplicatedStorage")
local player, pGui = Players.LocalPlayer, player:WaitForChild("PlayerGui")
local BASE_URL = "https://raw.githubusercontent.com/jezz-lab/repo/main/bee/"
local ERROR_PANEL_URL = BASE_URL .. "ErrorPanel.lua"
local FRAME_W, MIN_H, MAX_H = 300, 200, 520
local INV_CHECK = 0.5

-- Remove old GUI
local old = pGui:FindFirstChild("ActionGui"); if old then old:Destroy() end

-- Error Panel
local ErrorPanel
local ok, mod = xpcall(function()
	local src = game:HttpGet(ERROR_PANEL_URL)
	if not src or src == "" then error("empty") end
	local fn = loadstring(src)
	if not fn then error("compile") end
	local m = fn()
	if type(m)~="table" or type(m.Init)~="function" or type(m.Add)~="function" or type(m.Toggle)~="function" then error("bad module") end
	return m
end, function(e) return debug.traceback(e,2) end)
if ok then ErrorPanel = mod else warn("[ActionGui] ErrorPanel load failed", mod) end

local startupSuccess, startupError = xpcall(function()

	-- GUI
	local gui = Instance.new("ScreenGui"); gui.Name = "ActionGui"; gui.ResetOnSpawn = false; gui.Parent = pGui
	local frame = Instance.new("Frame"); frame.Name = "MainFrame"; frame.Size = UDim2.fromOffset(FRAME_W, MIN_H); frame.Position = UDim2.fromScale(0.5,0.5); frame.AnchorPoint = Vector2.new(0.5,0.5); frame.BackgroundColor3 = Color3.fromRGB(30,30,30); frame.BorderSizePixel = 0; frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

	-- Toggle Icon
	local toggle = Instance.new("TextButton"); toggle.Name = "ToggleIcon"; toggle.Text = "⚡"; toggle.TextColor3 = Color3.new(1,1,1); toggle.TextSize = 24; toggle.Font = Enum.Font.GothamBold; toggle.BackgroundColor3 = Color3.fromRGB(45,45,45); toggle.BorderSizePixel = 0; toggle.Size = UDim2.fromOffset(45,45); toggle.Position = UDim2.fromOffset(15,100); toggle.AutoButtonColor = false; toggle.Parent = gui
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,10)

	-- Dragging for toggle
	local iconDrag, iconStart, iconMoved = false, nil, nil, false
	toggle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			iconDrag = true; iconMoved = false; iconStart = i.Position; iconStartPos = toggle.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then iconDrag = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not iconDrag or (i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch) then return end
		local d = i.Position - iconStart
		if math.abs(d.X)>5 or math.abs(d.Y)>5 then iconMoved = true end
		toggle.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + d.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + d.Y)
	end)

	-- Title
	local title = Instance.new("TextLabel", frame); title.Name = "Title"; title.Text = "Farm a Fish: Bee Event"; title.TextColor3 = Color3.new(1,1,1); title.TextSize = 10; title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1; title.Size = UDim2.new(1,-60,0,40); title.Position = UDim2.fromOffset(10,0); title.TextXAlignment = Enum.TextXAlignment.Left

	-- Close
	local close = Instance.new("TextButton", frame); close.Name = "CloseButton"; close.Text = "X"; close.TextColor3 = Color3.new(1,1,1); close.TextSize = 18; close.Font = Enum.Font.GothamBold; close.BackgroundColor3 = Color3.fromRGB(200,50,50); close.BorderSizePixel = 0; close.Size = UDim2.fromOffset(40,35); close.Position = UDim2.new(1,-45,0,5); close.AutoButtonColor = false
	Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)

	-- Buttons container
	local btnFrame = Instance.new("Frame", frame); btnFrame.Name = "Buttons"; btnFrame.BackgroundTransparency = 1; btnFrame.Size = UDim2.new(1,-20,1,-95); btnFrame.Position = UDim2.fromOffset(10,45)
	local layout = Instance.new("UIListLayout", btnFrame); layout.Padding = UDim.new(0,5); layout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Footer
	local footer = Instance.new("Frame", frame); footer.Name = "NotificationFooter"; footer.BackgroundColor3 = Color3.fromRGB(38,38,38); footer.BorderSizePixel = 0; footer.Size = UDim2.new(1,-20,0,35); footer.Position = UDim2.new(0,10,1,-45)
	Instance.new("UICorner", footer).CornerRadius = UDim.new(0,6)
	local footerLabel = Instance.new("TextLabel", footer); footerLabel.Name = "FooterLabel"; footerLabel.Text = "Ready"; footerLabel.TextColor3 = Color3.fromRGB(180,180,180); footerLabel.TextSize = 12; footerLabel.Font = Enum.Font.Gotham; footerLabel.BackgroundTransparency = 1; footerLabel.Size = UDim2.new(1,-45,1,0); footerLabel.Position = UDim2.fromOffset(10,0); footerLabel.TextXAlignment = Enum.TextXAlignment.Left
	local notifBtn = Instance.new("TextButton", footer); notifBtn.Name = "NotificationIcon"; notifBtn.Text = "⚠"; notifBtn.TextColor3 = Color3.new(1,1,1); notifBtn.TextSize = 17; notifBtn.Font = Enum.Font.GothamBold; notifBtn.BackgroundColor3 = Color3.fromRGB(55,55,55); notifBtn.BorderSizePixel = 0; notifBtn.Size = UDim2.fromOffset(30,30); notifBtn.Position = UDim2.new(1,-33,0.5,-15); notifBtn.AutoButtonColor = false
	Instance.new("UICorner", notifBtn).CornerRadius = UDim.new(0,7)

	-- Error helpers
	local function addError(a,m) warn("[ActionGui] ",a,":\n",m) if ErrorPanel then pcall(function() ErrorPanel:Add(a,m) end) end end
	local function notifyFailure(a,m) footerLabel.Text = a.." failed"; notifBtn.Text = "⚠"; addError(a,m) end
	local function notifySuccess(a) footerLabel.Text = a.." completed"; notifBtn.Text = "✓" end

	notifBtn.MouseEnter:Connect(function() notifBtn.BackgroundColor3 = Color3.fromRGB(75,75,75) end)
	notifBtn.MouseLeave:Connect(function() notifBtn.BackgroundColor3 = Color3.fromRGB(55,55,55) end)
	notifBtn.MouseButton1Click:Connect(function() if ErrorPanel then pcall(function() ErrorPanel:Toggle() end) end end)
	if ErrorPanel then pcall(function() ErrorPanel:Init(gui) end) end

	local function runAction(name, cb)
		local ok, res = xpcall(cb, function(e) return debug.traceback(e,2) end)
		if ok then notifySuccess(name) return true end
		notifyFailure(name, res); return false
	end

	-- Helper to create a row with a button
	local function createRow(name, order, height)
		local row = Instance.new("Frame", btnFrame); row.Name = name.."Row"; row.BackgroundColor3 = Color3.fromRGB(45,45,45); row.BorderSizePixel = 0; row.Size = UDim2.new(1,0,0,height or 40); row.LayoutOrder = order
		Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
		return row
	end

	local function makeButton(parent, text, x, y, w, h, bg, callback)
		local b = Instance.new("TextButton", parent); b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; b.Font = Enum.Font.GothamBold; b.BackgroundColor3 = bg or Color3.fromRGB(65,65,65); b.BorderSizePixel = 0; b.Size = UDim2.fromOffset(w or 30, h or 30); b.Position = UDim2.fromOffset(x or 0, y or 0); b.AutoButtonColor = false
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
		b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(80,80,80) end)
		b.MouseLeave:Connect(function() b.BackgroundColor3 = bg or Color3.fromRGB(65,65,65) end)
		b.MouseButton1Down:Connect(function() b.BackgroundColor3 = Color3.fromRGB(40,40,40) end)
		b.MouseButton1Up:Connect(function() b.BackgroundColor3 = Color3.fromRGB(80,80,80) end)
		if callback then b.MouseButton1Click:Connect(callback) end
		return b
	end

	-- Speed row
	local speedRow = createRow("Speed", 0)
	local speedLabel = Instance.new("TextLabel", speedRow); speedLabel.Name = "Label"; speedLabel.Text = "Speed"; speedLabel.TextColor3 = Color3.new(1,1,1); speedLabel.TextSize = 14; speedLabel.Font = Enum.Font.Gotham; speedLabel.BackgroundTransparency = 1; speedLabel.Size = UDim2.new(1,-150,1,0); speedLabel.Position = UDim2.fromOffset(10,0); speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	local speedInput = Instance.new("TextBox", speedRow); speedInput.Name = "SpeedInput"; speedInput.Text = "16"; speedInput.PlaceholderText = "Speed"; speedInput.TextColor3 = Color3.new(1,1,1); speedInput.PlaceholderColor3 = Color3.fromRGB(170,170,170); speedInput.TextSize = 13; speedInput.Font = Enum.Font.Gotham; speedInput.BackgroundColor3 = Color3.fromRGB(30,30,30); speedInput.BorderSizePixel = 0; speedInput.Size = UDim2.fromOffset(60,30); speedInput.Position = UDim2.new(1,-135,0.5,-15); speedInput.ClearTextOnFocus = false
	Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0,5)
	local speedBtn = makeButton(speedRow, "Set", 0,0,55,30, Color3.fromRGB(65,65,65), function()
		runAction("Set Speed", function()
			local char = player.Character; if not char then error("No character") end
			local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then error("No humanoid") end
			local s = tonumber(speedInput.Text); if not s or s<0 then error("Invalid speed") end
			hum.WalkSpeed = s
		end)
	end)
	speedBtn.Position = UDim2.new(1,-68,0.5,-15)

	-- Auto Insert
	local autoInsertEnabled = false; local autoInsertChoice = "Left"
	local autoRow = createRow("AutoInsert", 1)
	local autoCheck = Instance.new("TextButton", autoRow); autoCheck.Name = "CheckBox"; autoCheck.Text = "☐"; autoCheck.TextColor3 = Color3.new(1,1,1); autoCheck.TextSize = 20; autoCheck.Font = Enum.Font.GothamBold; autoCheck.BackgroundTransparency = 1; autoCheck.Size = UDim2.fromOffset(30,40); autoCheck.Position = UDim2.fromOffset(5,0); autoCheck.AutoButtonColor = false
	local autoLabel = Instance.new("TextLabel", autoRow); autoLabel.Name = "Label"; autoLabel.Text = "Auto Insert"; autoLabel.TextColor3 = Color3.new(1,1,1); autoLabel.TextSize = 13; autoLabel.Font = Enum.Font.Gotham; autoLabel.BackgroundTransparency = 1; autoLabel.Size = UDim2.fromOffset(100,40); autoLabel.Position = UDim2.fromOffset(32,0); autoLabel.TextXAlignment = Enum.TextXAlignment.Left
	local dropdown = Instance.new("TextButton", autoRow); dropdown.Name = "Dropdown"; dropdown.Text = "Left ▼"; dropdown.TextColor3 = Color3.new(1,1,1); dropdown.TextSize = 11; dropdown.Font = Enum.Font.Gotham; dropdown.BackgroundColor3 = Color3.fromRGB(30,30,30); dropdown.BorderSizePixel = 0; dropdown.Size = UDim2.fromOffset(90,30); dropdown.Position = UDim2.new(1,-100,0.5,-15); dropdown.AutoButtonColor = false
	Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0,5)
	local optFrame = Instance.new("Frame", autoRow); optFrame.Name = "Options"; optFrame.Visible = false; optFrame.BackgroundColor3 = Color3.fromRGB(35,35,35); optFrame.BorderSizePixel = 0; optFrame.Size = UDim2.fromOffset(90,84); optFrame.Position = UDim2.new(1,-100,1,3); optFrame.ZIndex = 50
	local optLayout = Instance.new("UIListLayout", optFrame); optLayout.SortOrder = Enum.SortOrder.LayoutOrder
	for _, opt in ipairs({"Left","Middle","Right"}) do
		local btn = Instance.new("TextButton", optFrame); btn.Name = opt; btn.Text = "☐ "..opt; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 11; btn.Font = Enum.Font.Gotham; btn.BackgroundColor3 = Color3.fromRGB(45,45,45); btn.BorderSizePixel = 0; btn.Size = UDim2.new(1,0,0,28); btn.ZIndex = 51
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60,60,60) end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45,45,45) end)
		btn.MouseButton1Click:Connect(function() autoInsertChoice = opt; dropdown.Text = opt.." ▼"; optFrame.Visible = false end)
	end
	autoCheck.MouseButton1Click:Connect(function() autoInsertEnabled = not autoInsertEnabled; autoCheck.Text = autoInsertEnabled and "☑" or "☐" end)
	dropdown.MouseButton1Click:Connect(function() optFrame.Visible = not optFrame.Visible end)

	-- Fish requirements
	local dispNames = {[1]="Left",[2]="Middle",[3]="Right"}
	local fishReq = {[1]={"-","-"},[2]={"-","-"},[3]={"-","-"}}
	local reqLabels, statusLabels, lastAvail = {}, {}, {[1]=-1,[2]=-1,[3]=-1}

	local function findInv()
		for _, name in ipairs({"Inventory","Items","ItemInventory","PlayerData","Data","Backpack"}) do
			local c = player:FindFirstChild(name); if c then return c end
		end
		return nil
	end
	local function itemExists(container, name)
		if not container or not name or name=="-" then return false end
		local d = container:FindFirstChild(name)
		if d then
			if d:IsA("IntValue") or d:IsA("NumberValue") then return d.Value > 0 end
			return true
		end
		for _, obj in ipairs(container:GetDescendants()) do
			if obj.Name == name then
				if obj:IsA("IntValue") or obj:IsA("NumberValue") then return obj.Value > 0 end
				return true
			end
		end
		return false
	end

	local function checkReq(id)
		local req = fishReq[id]; if not req then error("no req") end
		local inv = findInv(); if not inv then error("no inv") end
		local f1,f2 = req[1], req[2]
		local h1 = itemExists(inv,f1); local h2 = itemExists(inv,f2)
		local avail = (h1 and 1 or 0) + (h2 and 1 or 0)
		return h1, h2, avail
	end

	local function updateDisplay(id)
		local lbl, st = reqLabels[id], statusLabels[id]
		if not lbl or not st then error("GUI missing") end
		local req = fishReq[id]; if not req then error("req missing") end
		local h1,h2,avail = checkReq(id)
		local f1,f2 = req[1], req[2]
		lbl.Text = dispNames[id].." Req: "..(h1 and "✓" or "✗").." "..f1.." / "..(h2 and "✓" or "✗").." "..f2
		st.Text = "Available ["..avail.."/2]"; st.TextColor3 = Color3.fromRGB(180,180,180)
		return avail
	end

	local function safeUpdate(id)
		local ok, res = xpcall(function() return updateDisplay(id) end, function(e) return debug.traceback(e,2) end)
		if not ok then notifyFailure("Req Update <"..dispNames[id]..">", res); return nil end
		return res
	end

	-- Insert rows
	local function createInsertRow(name, order, id)
		local row = createRow(name, order, 75)
		local reqLbl = Instance.new("TextLabel", row); reqLbl.Name = "Requirement"; reqLbl.Text = name.." Req: ✗ - / ✗ -"; reqLbl.TextColor3 = Color3.new(1,1,1); reqLbl.TextSize = 11; reqLbl.Font = Enum.Font.Gotham; reqLbl.BackgroundTransparency = 1; reqLbl.Size = UDim2.new(1,-10,0,25); reqLbl.Position = UDim2.fromOffset(5,3); reqLbl.TextXAlignment = Enum.TextXAlignment.Left; reqLbl.TextTruncate = Enum.TextTruncate.AtEnd
		local insBtn = makeButton(row, "Insert", 5,31,70,28, Color3.fromRGB(65,65,65))
		local stat = Instance.new("TextLabel", row); stat.Name = "Status"; stat.Text = "Available [0/2]"; stat.TextColor3 = Color3.fromRGB(180,180,180); stat.TextSize = 10; stat.Font = Enum.Font.GothamBold; stat.BackgroundTransparency = 1; stat.Size = UDim2.new(1,-85,0,20); stat.Position = UDim2.fromOffset(82,34); stat.TextXAlignment = Enum.TextXAlignment.Left
		local actStat = Instance.new("TextLabel", row); actStat.Name = "ActionStatus"; actStat.Text = ""; actStat.TextColor3 = Color3.fromRGB(220,70,70); actStat.TextSize = 10; actStat.Font = Enum.Font.GothamBold; actStat.BackgroundTransparency = 1; actStat.Size = UDim2.new(1,-10,0,18); actStat.Position = UDim2.fromOffset(5,54); actStat.TextXAlignment = Enum.TextXAlignment.Left
		reqLabels[id], statusLabels[id] = reqLbl, stat

		insBtn.MouseButton1Click:Connect(function()
			actStat.Text = ""
			local ok = runAction("Insert <"..name..">", function()
				local h1,h2,avail = checkReq(id)
				if avail < 2 then
					actStat.Text = "Not Inserted"; actStat.TextColor3 = Color3.fromRGB(220,70,70)
					footerLabel.Text = name..": Not Inserted"; notifBtn.Text = "⚠"
					error("Requirements not fulfilled. Available ["..avail.."/2]")
				end
				local ev = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]
				if not ev or typeof(ev.FireServer)~="function" then error("Event missing") end
				ev:FireServer(id)
				actStat.Text = "Inserted"; actStat.TextColor3 = Color3.fromRGB(100,220,100)
			end)
			if not ok then actStat.Text = "Not Inserted"; actStat.TextColor3 = Color3.fromRGB(220,70,70) end
		end)
		return row
	end

	createInsertRow("Left",2,1); createInsertRow("Middle",3,2); createInsertRow("Right",4,3)

	-- Bee event handlers
	local BeeFilling = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.fillingStarted"]
	if BeeFilling then
		BeeFilling.OnClientEvent:Connect(function(id, data)
			local ok, err = xpcall(function()
				if not dispNames[id] then error("bad id") end
				if type(data)~="table" or type(data.fishes)~="table" then error("bad data") end
				local f1,f2 = data.fishes[1], data.fishes[2]
				if not f1 or not f2 then error("missing fish") end
				fishReq[id] = {tostring(f1), tostring(f2)}
				if safeUpdate(id)==nil then error("display failed") end
			end, function(e) return debug.traceback(e,2) end)
			if not ok then notifyFailure("Bee Req Update", err) end
		end)
	else warn("bee.fillingStarted missing") end

	local StateSync = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["state.sync"]
	if StateSync then
		StateSync.OnClientEvent:Connect(function(data)
			local ok, err = xpcall(function()
				if type(data)~="table" or data.type~="patch" or not data.data then return end
				local players = data.data["playerData/players"]; if not players then return end
				local pData = players[tostring(player.UserId)]; if not pData or not pData.events or not pData.events.Bee or not pData.events.Bee.recipes then return end
				for id, recipe in pairs(pData.events.Bee.recipes) do
					if dispNames[id] and type(recipe.fishes)=="table" then
						local f1,f2 = recipe.fishes[1], recipe.fishes[2]
						if f1 and f2 then fishReq[id] = {tostring(f1), tostring(f2)} end
					end
				end
				for id=1,3 do safeUpdate(id) end
			end, function(e) return debug.traceback(e,2) end)
			if not ok then notifyFailure("State Sync", err) end
		end)
	else warn("state.sync missing") end

	-- Auto insert
	local autoBusy = false
	local function getSelectedDispenser()
		if autoInsertChoice=="Left" then return 1
		elseif autoInsertChoice=="Middle" then return 2
		elseif autoInsertChoice=="Right" then return 3
		else return nil end
	end
	local function tryAutoInsert()
		if not autoInsertEnabled or autoBusy then return end
		local id = getSelectedDispenser()
		if not id then return end
		local ok, err = xpcall(function()
			local _,_,avail = checkReq(id)
			if avail < 2 then return end
			autoBusy = true
			local ev = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.submitToDispenser"]
			if not ev or typeof(ev.FireServer)~="function" then error("Event missing") end
			ev:FireServer(id)
			local st = statusLabels[id]; if st then st.Text = "Available [2/2]" end
			footerLabel.Text = dispNames[id]..": Inserted"; notifBtn.Text = "✓"
		end, function(e) return debug.traceback(e,2) end)
		autoBusy = false
		if not ok then
			notifyFailure("Auto Insert <"..dispNames[id]..">", err)
			local row = btnFrame:FindFirstChild(dispNames[id].."Row")
			local act = row and row:FindFirstChild("ActionStatus")
			if act then act.Text = "Not Inserted"; act.TextColor3 = Color3.fromRGB(220,70,70) end
		end
	end

	-- Inventory monitor
	local elapsed = 0
	RS.Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt
		if elapsed < INV_CHECK then return end
		elapsed = 0
		for id=1,3 do
			local ok, avail = xpcall(function() return updateDisplay(id) end, function(e) return debug.traceback(e,2) end)
			if ok then
				if lastAvail[id] ~= avail then lastAvail[id] = avail end
			else
				notifyFailure("Inventory Update <"..dispNames[id]..">", avail)
			end
		end
		tryAutoInsert()
	end)

	-- Feed King Bee
	local rowFeed = createRow("Feed King Bee", 5)
	local lblFeed = Instance.new("TextLabel", rowFeed); lblFeed.Name = "Label"; lblFeed.Text = "Feed King Bee"; lblFeed.TextColor3 = Color3.new(1,1,1); lblFeed.TextSize = 14; lblFeed.Font = Enum.Font.Gotham; lblFeed.BackgroundTransparency = 1; lblFeed.Size = UDim2.new(1,-55,1,0); lblFeed.Position = UDim2.fromOffset(10,0); lblFeed.TextXAlignment = Enum.TextXAlignment.Left
	local btnFeed = makeButton(rowFeed, ">", 0,0,30,30, Color3.fromRGB(65,65,65), function()
		runAction("Feed King Bee", function()
			local e1 = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["npc.dialogueCompleted"]
			local e2 = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.feedKingBeeAll"]
			if not e1 or typeof(e1.FireServer)~="function" or not e2 or typeof(e2.FireServer)~="function" then error("Events missing") end
			e1:FireServer("KingBee"); e2:FireServer()
		end)
	end)
	btnFeed.Position = UDim2.new(1,-38,0.5,-15)

	-- Initial display update
	for id=1,3 do
		local ok, avail = xpcall(function() return updateDisplay(id) end, function(e) return debug.traceback(e,2) end)
		if not ok then notifyFailure("Init Update <"..dispNames[id]..">", avail) end
	end

	-- Simulate bee filling events (primary for all 3)
	local function simBeeFill()
		local ev = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["bee.fillingStarted"]
		if ev then
			local data = {
				[1] = {fishes={"BlueSpottedPuffer","PufferFish"}},
				[2] = {fishes={"GoldenJellyfish","MauveStinger"}},
				[3] = {fishes={"PufferFish","BlueSpottedPuffer"}}
			}
			for id=1,3 do
				pcall(function() ev:FireServer(id, {expiresAt=1788092607, baitRarity="Epic", reward=29, fishes=data[id].fishes}, 3) end)
			end
		end
	end
	-- Simulate state sync (fallback for all 3)
	local function simStateSync()
		local ev = RepSto.rbxts_include.node_modules["@rbxts"].remo.src.container["state.sync"]
		if ev then
			pcall(function()
				ev:FireServer({
					data = {
						["playerData/players"] = {
							[tostring(player.UserId)] = {
								events = {
									Bee = {
										recipes = {
											[1] = {fishes={"BlueSpottedPuffer","PufferFish"}},
											[2] = {fishes={"GoldenJellyfish","MauveStinger"}},
											[3] = {fishes={"PufferFish","BlueSpottedPuffer"}}
										}
									}
								}
							}
						}
					},
					type = "patch"
				})
			end)
		end
	end
	simBeeFill(); simStateSync()

	-- Dynamic height
	local function updateHeight()
		local h = math.clamp(layout.AbsoluteContentSize.Y + 105, MIN_H, MAX_H)
		frame.Size = UDim2.fromOffset(FRAME_W, h)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight); updateHeight()

	close.MouseButton1Click:Connect(function() gui:Destroy() end)
	toggle.MouseButton1Click:Connect(function()
		if iconMoved then iconMoved = false; return end
		frame.Visible = not frame.Visible
	end)

	-- Dragging main frame
	local drag, dragStart, startPos = false, nil, nil
	title.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true; dragStart = i.Position; startPos = frame.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not drag or (i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch) then return end
		local d = i.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
	end)

	footerLabel.Text = "Ready"; notifBtn.Text = "✓"

end, function(e) return debug.traceback(e,2) end)

if not startupSuccess then
	warn("[ActionGui] Script stopped:", startupError)
	if ErrorPanel then pcall(function() ErrorPanel:Add("Main.lua Startup", startupError) end) end
end
