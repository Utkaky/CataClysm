local cloneref = (typeof(cloneref) == "function" and cloneref) or function(instance)
	return instance
end

local function GetService(name)
	return cloneref(game:GetService(name))
end

local Players = GetService("Players")
local UserInputService = GetService("UserInputService")
local RunService = GetService("RunService")
local TweenService = GetService("TweenService")
local Lighting = GetService("Lighting")
local Debris = GetService("Debris")
local HttpService = GetService("HttpService")
local SoundService = GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local Library = {
	Version = "1.0.5",
	Toggles = {},        
	ToggleStates = {},   
	Flags = {},          
	Windows = {},
	Icons = {},          
	CustomIcons = {},    
	IconsURL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
	Theme = {
		Background = Color3.fromRGB(8, 8, 10),
		BackgroundTransparency = 0.12,
		Accent = Color3.fromRGB(255, 45, 60),      
		Primary = Color3.fromRGB(124, 77, 255),    
		TabBar = Color3.fromRGB(84, 24, 230),      
		Element = Color3.fromRGB(22, 22, 28),
		ElementHover = Color3.fromRGB(36, 36, 46),
		ElementPress = Color3.fromRGB(16, 16, 20),
		ElementTransparency = 0.25,
		ToggleOff = Color3.fromRGB(52, 52, 64),
		SliderTrack = Color3.fromRGB(48, 48, 60),
		Text = Color3.fromRGB(240, 240, 246),
		SubText = Color3.fromRGB(150, 150, 168),
		Stroke = Color3.fromRGB(255, 255, 255),
		StrokeTransparency = 0.9,
		Danger = Color3.fromRGB(255, 60, 70),
	},
	_binds = {},
	_connections = {},
	_pendingToggleChanges = {},
	_capture = nil,
	_gui = nil,
	_notifyHolder = nil,
	_notifyOrder = 0,
}

do
	local ok, env = pcall(function()
		return (typeof(getgenv) == "function" and getgenv()) or _G
	end)
	if ok and type(env) == "table" then
		local previous = env.__VetorLibrary
		if type(previous) == "table" and type(previous.Destroy) == "function" then
			pcall(previous.Destroy, previous)
		end
		pcall(function()
			env.__VetorLibrary = Library
		end)
	end
end

local HEADER_HEIGHT = 52
local HEADER_TOTAL = HEADER_HEIGHT + 2 
local DEFAULT_WINDOW_ICON = "sparkles"
local DEFAULT_TAB_ICON = "layout-grid"
local DEFAULT_NOTIFY_ICON = "bell"

local function RandomName()
	local chars = {}
	for index = 1, 12 do
		chars[index] = string.char(math.random(97, 122))
	end
	return table.concat(chars)
end

local function Config(cfg, fallbackName)
	if type(cfg) == "string" then
		return { Name = cfg }
	end
	if type(cfg) ~= "table" then
		return { Name = fallbackName }
	end
	return cfg
end

local function Tween(instance, props, duration, style, direction)
	duration = duration or 0.25
	if duration <= 0 then
		for property, value in pairs(props) do
			instance[property] = value
		end
		return nil
	end
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
		props
	)
	tween:Play()
	return tween
end

local DEFAULTS = {
	Frame = { BorderSizePixel = 0 },
	CanvasGroup = { BorderSizePixel = 0 },
	ScrollingFrame = { BorderSizePixel = 0 },
	ImageLabel = { BorderSizePixel = 0, BackgroundTransparency = 1 },
	ImageButton = { BorderSizePixel = 0, BackgroundTransparency = 1, AutoButtonColor = false },
	TextLabel = {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
	},
	TextButton = {
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
	},
	TextBox = {
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
	},
}

local function Create(className, props, children)
	local instance = Instance.new(className)
	local defaults = DEFAULTS[className]
	if defaults then
		for property, value in pairs(defaults) do
			instance[property] = value
		end
	end
	local parent
	for property, value in pairs(props or {}) do
		if property == "Parent" then
			parent = value
		else
			instance[property] = value
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end
	instance.Parent = parent
	return instance
end


-- Ui Custumization (v4)
function Library:setBackgroundTransparency(value)
	value = math.clamp(value, 0, 1)
    Library.Theme.BackgroundTransparency = value

	for _, window in ipairs(Library.Windows) do
		window.Theme.BackgroundTransparency = value
        window.Main.BackgroundTransparency = value
	end
end


local function Corner(radius)
	return Create("UICorner", { CornerRadius = radius or UDim.new(0, 8) })
end

local PILL = UDim.new(1, 0)

local function Stroke(theme, color, transparency, thickness)
	return Create("UIStroke", {
		Color = color or theme.Stroke,
		Transparency = transparency or theme.StrokeTransparency,
		Thickness = thickness or 1,
	})
end

local function Padding(left, right, top, bottom)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	})
end

local function ListLayout(padding)
	return Create("UIListLayout", {
		Padding = UDim.new(0, padding or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

local function CountDecimals(number)
	local text = string.format("%.6f", number)
	text = text:gsub("0+$", "")
	local dot = text:find("%.")
	if not dot then
		return 0
	end
	return #text - dot
end

local Connection = {}
Connection.__index = Connection

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false
	local list = self._signal and self._signal._list
	if list then
		local index = table.find(list, self)
		if index then
			table.remove(list, index)
		end
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _list = {} }, Signal)
end

function Signal:Connect(callback)
	assert(type(callback) == "function", "[Vetor] Need To be a Function")
	local connection = setmetatable({ Fn = callback, Connected = true, _signal = self }, Connection)
	table.insert(self._list, connection)
	return connection
end

function Signal:OnChange(callback)
	return self:Connect(callback)
end

function Signal:Fire(...)
	for _, connection in ipairs(table.clone(self._list)) do
		if connection.Connected then
			task.spawn(connection.Fn, ...)
		end
	end
end

function Signal:Destroy()
	for _, connection in ipairs(self._list) do
		connection.Connected = false
	end
	table.clear(self._list)
end

setmetatable(Library.Toggles, {
	__index = function(_, flag)
		if type(flag) ~= "string" then
			return nil
		end
		local pending = Library._pendingToggleChanges[flag]
		if not pending then
			pending = Signal.new()
			Library._pendingToggleChanges[flag] = pending
		end
		return pending
	end,
})

local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _items = {} }, Maid)
end

function Maid:Add(item)
	table.insert(self._items, item)
	return item
end

function Maid:Clean()
	local items = self._items
	self._items = {}
	for _, item in ipairs(items) do
		local kind = typeof(item)
		if kind == "RBXScriptConnection" then
			item:Disconnect()
		elseif kind == "Instance" then
			item:Destroy()
		elseif kind == "function" then
			pcall(item)
		elseif kind == "table" then
			if type(item.Disconnect) == "function" then
				item:Disconnect()
			elseif type(item.Destroy) == "function" then
				item:Destroy()
			end
		end
	end
end

local lucideState = "idle"

local function HttpGet(url)
	local ok, result = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(result) == "string" and #result > 0 then
		return result
	end
	local requestFunction = request or http_request or (syn and syn.request)
	if type(requestFunction) == "function" then
		local okRequest, response = pcall(requestFunction, { Url = url, Method = "GET" })
		if okRequest and type(response) == "table" and type(response.Body) == "string" then
			return response.Body
		end
	end
	local okAsync, body = pcall(function()
		return HttpService:GetAsync(url)
	end)
	if okAsync and type(body) == "string" then
		return body
	end
	error("HTTP indisponível neste ambiente")
end

local function LoadLucide()
	if lucideState ~= "idle" then
		return
	end
	lucideState = "loading"
	local ok, result = pcall(function()
		local source = HttpGet(Library.IconsURL)
		return loadstring(source)()
	end)
	if ok and type(result) == "table" then
		Library.Icons = result
		lucideState = "loaded"
	else
		lucideState = "failed"
		warn("[Vetor] Failed To Load Lucide Icons (" .. tostring(result) .. "). Icons Has Been Disabled in Instance.")
	end
end

local function ResolveIcon(icon)
	if icon == nil or icon == false or icon == "" then
		return nil, false
	end
	if type(icon) == "number" then
		return "rbxassetid://" .. tostring(math.floor(icon)), false
	end
	if type(icon) ~= "string" then
		return nil, false
	end
	if icon:find("^rbx") or icon:find("^https?://") then
		return icon, false
	end
	if icon:match("^%d+$") then
		return "rbxassetid://" .. icon, false
	end
	local name = (icon:gsub("^lucide:", ""))
	local custom = Library.CustomIcons[name]
	if custom then
		return custom, true
	end
	LoadLucide()
	local asset = Library.Icons[name]
	if asset then
		return asset, true
	end
	return nil, false
end

function Library:GetIcon(name)
	return (ResolveIcon(name))
end

local function MakeIcon(parent, icon, size, color, props, fallbackText)
	local image, isLucide = ResolveIcon(icon)
	local instance
	if image then
		instance = Create("ImageLabel", {
			Name = "Icon",
			Size = UDim2.fromOffset(size, size),
			Image = image,
			ImageColor3 = isLucide and color or Color3.new(1, 1, 1),
		})
	elseif fallbackText then
		instance = Create("TextLabel", {
			Name = "Icon",
			Size = UDim2.fromOffset(size, size),
			Text = fallbackText,
			TextColor3 = color,
			TextSize = math.max(10, size - 4),
			Font = Enum.Font.GothamBold,
		})
	else
		return nil, false
	end
	for property, value in pairs(props or {}) do
		instance[property] = value
	end
	instance.Parent = parent
	return instance, isLucide
end

local function IconTransparencyProperty(icon)
	return icon:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
end

local KEY_ALIASES = {
	LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift",
	LeftAlt = "LAlt", RightAlt = "RAlt", Return = "Enter", Backspace = "Bksp", Escape = "Esc",
	Delete = "Del", Insert = "Ins", PageUp = "PgUp", PageDown = "PgDn",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
	Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
}

local function ParseKey(key)
	if key == nil or key == false or key == true then
		return nil
	end
	if typeof(key) == "EnumItem" then
		if key.EnumType == Enum.KeyCode and key ~= Enum.KeyCode.Unknown then
			return key
		end
		return nil
	end
	if type(key) == "string" then
		local ok, result = pcall(function()
			return Enum.KeyCode[key]
		end)
		if ok and result then
			return result
		end
		warn("[Vetor] Invalid Bind: " .. key)
	end
	return nil
end

local function KeyText(key)
	if not key then
		return "None"
	end
	return KEY_ALIASES[key.Name] or key.Name
end

local BindCore = {}
BindCore.__index = BindCore

function BindCore.new(options)
	local self = setmetatable({
		Key = ParseKey(options.Key),
		Hold = options.Hold == true,
		OnPress = options.OnPress,
		OnRelease = options.OnRelease,
		Active = false,
		KeyChanged = Signal.new(),
	}, BindCore)
	table.insert(Library._binds, self)
	return self
end

function BindCore:SetKey(key)
	key = ParseKey(key)
	if key == self.Key then
		return
	end
	self.Key = key
	self.Active = false
	self.KeyChanged:Fire(key)
end

function BindCore:Destroy()
	local index = table.find(Library._binds, self)
	if index then
		table.remove(Library._binds, index)
	end
	self.KeyChanged:Destroy()
end

local function BeginCapture(onKey, onCancel)
	local previous = Library._capture
	if previous and previous.OnCancel then
		previous.OnCancel()
	end
	Library._capture = { OnKey = onKey, OnCancel = onCancel }
end

local function EndCapture()
	Library._capture = nil
end

local function EnsureInput()
	if #Library._connections > 0 then
		return
	end
	local pressed = {}

	table.insert(Library._connections, UserInputService.InputBegan:Connect(function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local key = input.KeyCode
		if key == Enum.KeyCode.Unknown then
			return
		end

		local capture = Library._capture
		if capture then

			pressed[key] = true
			capture.OnKey(key)
			return
		end

		if processed or UserInputService:GetFocusedTextBox() then
			return
		end
		if pressed[key] then
			return 
		end
		pressed[key] = true

		for _, bind in ipairs(table.clone(Library._binds)) do
			if bind.Key == key then
				bind.Active = true
				if bind.OnPress then
					task.spawn(bind.OnPress, bind)
				end
			end
		end
	end))

	table.insert(Library._connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local key = input.KeyCode
		pressed[key] = nil
		for _, bind in ipairs(table.clone(Library._binds)) do
			if bind.Key == key and bind.Active then
				bind.Active = false
				if bind.OnRelease then
					task.spawn(bind.OnRelease, bind)
				end
			end
		end
	end))

	table.insert(Library._connections, UserInputService.WindowFocusReleased:Connect(function()
		table.clear(pressed)
		for _, bind in ipairs(table.clone(Library._binds)) do
			if bind.Active then
				bind.Active = false
				if bind.OnRelease then
					task.spawn(bind.OnRelease, bind)
				end
			end
		end
	end))
end

local function BuildBindChip(window, parent, core, maid)
	local theme = window.Theme
	local chip = Create("TextButton", {
		Name = "BindChip",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
		BackgroundColor3 = theme.ElementHover,
		BackgroundTransparency = 0.2,
		Text = KeyText(core.Key),
		TextColor3 = theme.Text,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		ZIndex = 3,
		Parent = parent,
	}, {
		Corner(UDim.new(0, 6)),
		Stroke(theme),
		Padding(10, 10, 0, 0),
		Create("UISizeConstraint", { MinSize = Vector2.new(40, 24) }),
	})

	local capturing = false

	local function refresh()
		chip.Text = capturing and "..." or KeyText(core.Key)
		Tween(chip, { TextColor3 = capturing and theme.Accent or theme.Text }, 0.15)
	end

	local function cancel()
		if capturing then
			capturing = false
			EndCapture()
		end
		refresh()
	end

	maid:Add(core.KeyChanged:Connect(refresh))

	maid:Add(chip.MouseButton1Click:Connect(function()
		if capturing then
			cancel()
			return
		end
		capturing = true
		refresh()
		BeginCapture(function(key)
			capturing = false
			EndCapture()
			if key == Enum.KeyCode.Escape then
				refresh()
			elseif key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Delete then
				core:SetKey(nil)
				refresh()
			else
				core:SetKey(key)
				refresh()
			end
		end, function()
			capturing = false
			refresh()
		end)
	end))

	maid:Add(chip.MouseButton2Click:Connect(function()
		cancel()
		core:SetKey(nil)
	end))

	maid:Add(function()
		if capturing then
			capturing = false
			EndCapture()
		end
	end)

	return chip
end

local function BindInteraction(button, target, theme, maid)
	local base = theme.ElementTransparency
	local hoverTransparency = math.max(base - 0.12, 0)
	local function hover()
		Tween(target, { BackgroundColor3 = theme.ElementHover, BackgroundTransparency = hoverTransparency }, 0.15)
	end
	local function normal()
		Tween(target, { BackgroundColor3 = theme.Element, BackgroundTransparency = base }, 0.2)
	end
	maid:Add(button.MouseEnter:Connect(hover))
	maid:Add(button.MouseLeave:Connect(normal))
	maid:Add(button.MouseButton1Down:Connect(function()
		Tween(target, { BackgroundColor3 = theme.ElementPress, BackgroundTransparency = math.max(base - 0.2, 0) }, 0.08)
	end))
	maid:Add(button.MouseButton1Up:Connect(hover))
	maid:Add(button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			normal()
		end
	end))
end

local function TrackDrag(startInput, onMove, onEnd)
	local connections = {}
	local finished = false
	local startType = startInput.UserInputType

	local function finish()
		if finished then
			return
		end
		finished = true
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		if onEnd then
			onEnd()
		end
	end

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			onMove(input.Position)
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == startType then
			finish()
		end
	end))
	return finish
end

local function IsPointerDown(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function ResolveGuiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end
	local okCore, coreGui = pcall(function()
		return GetService("CoreGui")
	end)
	if okCore and coreGui then
		local probe = Instance.new("Folder")
		local writable = pcall(function()
			probe.Parent = coreGui
		end)
		probe:Destroy()
		if writable then
			return coreGui
		end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function GetGui()
	if Library._gui and Library._gui.Parent then
		return Library._gui
	end
	local gui = Create("ScreenGui", {
		Name = RandomName(),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999999,
		IgnoreGuiInset = true,
	})
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	if syn and type(syn.protect_gui) == "function" then
		pcall(syn.protect_gui, gui)
	end
	gui.Parent = ResolveGuiParent()
	Library._gui = gui

	Library._notifyHolder = Create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 320, 1, -32),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		}),
	})
	return gui
end

local function MergeTheme(overrides)
	local theme = table.clone(Library.Theme)
	if type(overrides) == "table" then
		for key, value in pairs(overrides) do
			theme[key] = value
		end
	end
	return theme
end

function Library:Notify(cfg)
	cfg = Config(cfg, "Notification")
	local gui = GetGui()
	local lastWindow = self.Windows[#self.Windows]
	local theme = lastWindow and lastWindow.Theme or MergeTheme()
	local duration = math.max(tonumber(cfg.Time) or 5, 0.5)
	local title = tostring(cfg.Name or cfg.Title or "Notification")
	local description = cfg.Desc ~= nil and tostring(cfg.Desc) or ""

	self._notifyOrder += 1
	local holder = Create("Frame", {
		Name = "Notification",
		LayoutOrder = self._notifyOrder,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self._notifyHolder,
	})

	local card = Create("CanvasGroup", {
		Name = "Card",
		Position = UDim2.fromOffset(340, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 0.08,
		GroupTransparency = 1,
		Parent = holder,
	}, { Corner(UDim.new(0, 12)), Stroke(theme) })

	MakeIcon(card, cfg.Icon or DEFAULT_NOTIFY_ICON, 22, theme.Accent, {
		Position = UDim2.fromOffset(14, 13),
	}, "!")

	local body = Create("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(48, 0),
		Size = UDim2.new(1, -48, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = card,
	}, { ListLayout(2), Padding(0, 14, 12, 15) })

	Create("TextLabel", {
		Name = "Title",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = body,
	})
	if description ~= "" then
		Create("TextLabel", {
			Name = "Description",
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = description,
			TextColor3 = theme.SubText,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = body,
		})
	end

	local progress = Create("Frame", {
		Name = "Progress",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = theme.Accent,
		ZIndex = 5,
		Parent = card,
	})

	if cfg.SoundID ~= nil and cfg.SoundID ~= "" then
		local soundId = tostring(cfg.SoundID)
		if soundId:match("^%d+$") then
			soundId = "rbxassetid://" .. soundId
		end
		local ok, sound = pcall(function()
			return Create("Sound", { SoundId = soundId, Volume = tonumber(cfg.Volume) or 0.6, Parent = SoundService })
		end)
		if ok and sound then
			sound:Play()
			Debris:AddItem(sound, 10)
		end
	end

	local handle = { Closed = false }
	function handle:Close()
		if self.Closed then
			return
		end
		self.Closed = true
		Tween(card, { Position = UDim2.fromOffset(340, 0), GroupTransparency = 1 }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.35, function()
			holder:Destroy()
		end)
	end

	Tween(card, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }, 0.4, Enum.EasingStyle.Back)
	Tween(progress, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear)
	task.delay(duration, function()
		handle:Close()
	end)

	card.Active = true
	card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			handle:Close()
		end
	end)

	return handle
end

local Element = {}
Element.__index = Element

local function SetElementVisibility(element, visible)
	assert(type(visible) == "boolean", "[Vetor] SetVisibility expects a boolean")
	if element._destroyed then
		return element
	end
	element.Visible = visible
	element.Frame.Visible = visible
	return element
end

function Element:SetVisibility(visible)
	return SetElementVisibility(self, visible)
end

function Element:OnChange(callback)
	return self.Changed:Connect(callback)
end

function Element:Get()
	return self.Value
end

function Element:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self._maid:Clean()
	self.Changed:Destroy()
	local flag = self.Flag
	if flag then
		if Library.Flags[flag] == self then
			Library.Flags[flag] = nil
		end
		if Library.Toggles[flag] == self then
			Library.Toggles[flag] = nil
			Library.ToggleStates[flag] = nil
		end
	end
	self.Window._elements[self] = nil
	if self.Frame then
		self.Frame:Destroy()
	end
end

local function NewElement(class, kind, window, frame, name, flag)
	local element = setmetatable({
		Kind = kind,
		Name = name,
		Flag = flag,
		Window = window,
		Frame = frame,
		Changed = Signal.new(),
		_maid = Maid.new(),
		_destroyed = false,
	}, class)
	window._elements[element] = true
	return element
end

local function ElementClass()
	local class = setmetatable({}, { __index = Element })
	class.__index = class
	return class
end

local Toggle = ElementClass()
Toggle.__call = function(self)
	return self.Value
end
local Slider = ElementClass()
local Dropdown = ElementClass()
local PlayersDropdown = ElementClass()
local Bind = ElementClass()
local Button = ElementClass()
local Label = ElementClass()
local Paragraph = ElementClass()
local Textbox = ElementClass()

local function RegisterFlag(element, flag)
	if not flag then
		return
	end
	if Library.Flags[flag] and Library.Flags[flag] ~= element then
		warn(string.format("[Vetor] Dual Flag Found '%s': Logs Remake.", flag))
	end
	Library.Flags[flag] = element
end

local Container = {}
Container.__index = Container

function Container:_nextOrder()
	self._order += 1
	return self._order
end

function Container:_row(height)
	local theme = self.Window.Theme
	return Create("Frame", {
		Name = "Element",
		LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Element,
		BackgroundTransparency = theme.ElementTransparency,
		Parent = self.Holder,
	}, { Corner(UDim.new(0, 8)), Stroke(theme) })
end

local function NameLabel(frame, theme, text, widthOffset)
	return Create("TextLabel", {
		Name = "Name",
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -widthOffset, 1, 0),
		Text = text,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		Parent = frame,
	})
end

function Container:AddLabel(cfg)
	cfg = Config(cfg, "Label")
	local theme = self.Window.Theme
	local text = tostring(cfg.Name or cfg.Text or "Label")
	local frame = Create("TextLabel", {
		Name = "Label",
		LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = text,
		TextColor3 = theme.SubText,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Holder,
	}, { Padding(4, 4, 4, 4) })
	local label = NewElement(Label, "Label", self.Window, frame, text, nil)
	label.Value = text
	return label
end

function Label:Set(text)
	self.Value = tostring(text)
	self.Frame.Text = self.Value
end

function Container:AddParagraph(cfg, content)
	if type(cfg) == "string" then
		cfg = { Name = cfg, Content = content }
	end
	cfg = Config(cfg, "Paragraph")
	local theme = self.Window.Theme
	local frame = Create("Frame", {
		Name = "Paragraph",
		LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Element,
		BackgroundTransparency = theme.ElementTransparency,
		Parent = self.Holder,
	}, { Corner(UDim.new(0, 8)), Stroke(theme), ListLayout(3), Padding(12, 12, 10, 10) })
	local title = Create("TextLabel", {
		Name = "Title",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = tostring(cfg.Name or "Paragraph"),
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local body = Create("TextLabel", {
		Name = "Content",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = tostring(cfg.Content or cfg.Desc or ""),
		TextColor3 = theme.SubText,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = frame,
	})
	local paragraph = NewElement(Paragraph, "Paragraph", self.Window, frame, title.Text, nil)
	paragraph._title, paragraph._content = title, body
	return paragraph
end

function Paragraph:SetTitle(text)
	self._title.Text = tostring(text)
end

function Paragraph:SetContent(text)
	self._content.Text = tostring(text)
end

function Container:AddButton(cfg)
	cfg = Config(cfg, "Button")
	local theme = self.Window.Theme
	local name = tostring(cfg.Name or "Button")
	local frame = self:_row(38)
	local button = NewElement(Button, "Button", self.Window, frame, name, nil)

	local hit = Create("TextButton", {
		Name = "Hit",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = frame,
	})
	button._label = NameLabel(frame, theme, name, 56)
	MakeIcon(frame, "mouse-pointer-click", 16, theme.SubText, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		ZIndex = 2,
	})

	BindInteraction(hit, frame, theme, button._maid)
	button._maid:Add(hit.MouseButton1Click:Connect(function()
		Tween(frame, { BackgroundColor3 = theme.Primary, BackgroundTransparency = 0.4 }, 0.08)
		task.delay(0.1, function()
			if not button._destroyed then
				Tween(frame, { BackgroundColor3 = theme.ElementHover, BackgroundTransparency = math.max(theme.ElementTransparency - 0.12, 0) }, 0.25)
			end
		end)
		button.Changed:Fire()
	end))
	if cfg.Callback then
		button.Changed:Connect(cfg.Callback)
	end
	return button
end

function Button:SetName(text)
	self.Name = tostring(text)
	self._label.Text = self.Name
end

function Toggle:_render(instant)
	local theme = self.Window.Theme
	local on = self.Value
	local duration = instant and 0 or 0.22
	Tween(self._track, { BackgroundColor3 = on and theme.Primary or theme.ToggleOff }, duration)
	if self.Window.UseCheckbox then
		if self._knob then
			Tween(self._knob, { [IconTransparencyProperty(self._knob)] = on and 0 or 1 }, duration)
		end
	else
		Tween(self._knob, { Position = on and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, duration, Enum.EasingStyle.Back)
	end
	Tween(self._label, { TextColor3 = on and theme.Text or theme.SubText }, duration)
end

function Toggle:Set(value, silent)
	if self._destroyed then
		return
	end
	value = value and true or false
	local changed = value ~= self.Value
	self.Value = value
	if Library.Toggles[self.Flag] == self then
		Library.ToggleStates[self.Flag] = value
	end
	self:_render(false)
	if changed and not silent then
		self.Changed:Fire(value)
	end
end

function Toggle:Toggle()
	self:Set(not self.Value)
end

function Toggle:_ensureBind()
	if self._bindCore then
		return self._bindCore
	end
	local core = BindCore.new({
		Hold = false,
		OnPress = function()
			self:Toggle()
		end,
	})
	self._bindCore = core
	self._maid:Add(function()
		core:Destroy()
	end)
	local chip = BuildBindChip(self.Window, self.Frame, core, self._maid)
	chip.AnchorPoint = Vector2.new(1, 0.5)
	chip.Position = UDim2.new(1, -62, 0.5, 0)
	self._label.Size = UDim2.new(1, -170, 1, 0)
	return core
end

function Toggle:SetKeybind(key)
	self:_ensureBind():SetKey(key)
end

function Toggle:GetKeybind()
	return self._bindCore and self._bindCore.Key or nil
end

function Toggle:ClearKeybind()
	if self._bindCore then
		self._bindCore:SetKey(nil)
	end
end

function Container:AddToggle(cfg)
	cfg = Config(cfg, "Toggle")
	local window, theme = self.Window, self.Window.Theme
	local name = tostring(cfg.Name or "Toggle")
	local flag = tostring(cfg.Flag or name)
	local frame = self:_row(40)
	local toggle = NewElement(Toggle, "Toggle", window, frame, name, flag)
	toggle.Value = false

	local hit = Create("TextButton", {
		Name = "Hit",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = frame,
	})
	toggle._label = NameLabel(frame, theme, name, 70)
	toggle._label.TextColor3 = theme.SubText
	toggle._track = Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = window.UseCheckbox and UDim2.fromOffset(20, 20) or UDim2.fromOffset(38, 20),
		BackgroundColor3 = theme.ToggleOff,
		ZIndex = 2,
		Parent = frame,
	}, {
		Corner(window.UseCheckbox and UDim.new(0, 4) or PILL),
		window.UseCheckbox and Stroke(theme) or nil,
	})
	if window.UseCheckbox then
		toggle._knob = MakeIcon(toggle._track, "check", 14, Color3.new(1, 1, 1), {
			Name = "Check",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = 1,
			ZIndex = 3,
		})
	else
		toggle._knob = Create("Frame", {
			Name = "Knob",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = toggle._track,
		}, { Corner(PILL) })
	end

	BindInteraction(hit, frame, theme, toggle._maid)
	toggle._maid:Add(hit.MouseButton1Click:Connect(function()
		toggle:Toggle()
	end))

	local existingToggle = rawget(Library.Toggles, flag)
	if existingToggle and existingToggle ~= toggle then
		warn(string.format("[Vetor] Flag de toggle duplicada '%s': o registro anterior foi substituído.", flag))
	end
	Library.Toggles[flag] = toggle
	Library.ToggleStates[flag] = false
	Library.Flags[flag] = toggle
	local pendingChanges = Library._pendingToggleChanges[flag]
	if pendingChanges then
		for _, connection in ipairs(table.clone(pendingChanges._list)) do
			if connection.Connected then
				local pendingIndex = table.find(pendingChanges._list, connection)
				if pendingIndex then
					table.remove(pendingChanges._list, pendingIndex)
				end
				connection._signal = toggle.Changed
				table.insert(toggle.Changed._list, connection)
				toggle._maid:Add(connection)
			end
		end
		Library._pendingToggleChanges[flag] = nil
	end

	toggle:_render(true)
	if cfg.Callback then
		toggle:OnChange(cfg.Callback)
	end
	toggle:Set(cfg.Default == true, true) 
	toggle:_render(true)

	if cfg.Keybind ~= nil and cfg.Keybind ~= false then
		toggle:_ensureBind():SetKey(cfg.Keybind)
	end
	return toggle
end

function Slider:_render(duration)
	local range = self.Max - self.Min
	local ratio = range > 0 and (self.Value - self.Min) / range or 0
	Tween(self._fill, { Size = UDim2.new(ratio, 0, 1, 0) }, duration)
	self._valueLabel.Text = string.format("%." .. self._decimals .. "f", self.Value) .. self._suffix
end

function Slider:Set(value, silent, instant)
	if self._destroyed then
		return
	end
	value = tonumber(value)
	if not value then
		return
	end
	value = self._snap(value)
	local changed = value ~= self.Value
	self.Value = value
	self:_render(instant and 0 or (self._dragging and 0.06 or 0.2))
	if changed and not silent then
		self.Changed:Fire(value)
	end
end

function Container:AddSlider(cfg)
	cfg = Config(cfg, "Slider")
	local window, theme = self.Window, self.Window.Theme
	local name = tostring(cfg.Name or "Slider")
	local flag = cfg.Flag and tostring(cfg.Flag) or nil
	local min = tonumber(cfg.Min) or 0
	local max = tonumber(cfg.Max) or 100
	if max <= min then
		warn(string.format("[Vetor] Slider '%s': Max deve ser maior que Min. Ajustando.", name))
		max = min + 1
	end
	local increment = tonumber(cfg.Increment) or 1
	if increment <= 0 then
		increment = 1
	end
	local decimals = math.max(CountDecimals(increment), CountDecimals(min))

	local frame = self:_row(54)
	local slider = NewElement(Slider, "Slider", window, frame, name, flag)
	slider.Min, slider.Max, slider.Increment = min, max, increment
	slider._decimals = decimals
	slider._suffix = cfg.ValueName and (" " .. tostring(cfg.ValueName)) or ""
	slider._dragging = false
	slider._snap = function(value)
		value = math.clamp(value, min, max)
		local steps = math.floor((value - min) / increment + 0.5)
		value = math.clamp(min + steps * increment, min, max)
		return tonumber(string.format("%." .. decimals .. "f", value))
	end

	NameLabel(frame, theme, name, 120).Size = UDim2.new(1, -120, 0, 30)
	slider._valueLabel = Create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(100, 30),
		TextColor3 = theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2,
		Parent = frame,
	})

	local bar = Create("Frame", {
		Name = "Bar",
		Position = UDim2.new(0, 12, 0, 36),
		Size = UDim2.new(1, -24, 0, 6),
		BackgroundColor3 = theme.SliderTrack,
		ZIndex = 2,
		Parent = frame,
	}, { Corner(PILL) })
	slider._fill = Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = theme.Primary,
		Parent = bar,
	}, { Corner(PILL) })
	local knob = Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 3,
		Parent = slider._fill,
	}, { Corner(PILL) })

	local hit = Create("TextButton", {
		Name = "Hit",
		Position = UDim2.new(0, 6, 0, 24),
		Size = UDim2.new(1, -12, 0, 28),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = frame,
	})

	local scroller = self.Scroller
	local function updateFromX(x)
		local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		slider:Set(min + (max - min) * ratio)
	end

	slider._maid:Add(hit.InputBegan:Connect(function(input)
		if not IsPointerDown(input) or slider._dragging then
			return
		end
		slider._dragging = true
		if scroller then
			scroller.ScrollingEnabled = false
		end
		Tween(knob, { Size = UDim2.fromOffset(17, 17) }, 0.15, Enum.EasingStyle.Back)
		updateFromX(input.Position.X)
		slider._dragFinish = TrackDrag(input, function(position)
			updateFromX(position.X)
		end, function()
			slider._dragging = false
			slider._dragFinish = nil
			if scroller then
				scroller.ScrollingEnabled = true
			end
			Tween(knob, { Size = UDim2.fromOffset(12, 12) }, 0.2)
		end)
	end))
	slider._maid:Add(function()
		if slider._dragFinish then
			slider._dragFinish()
		end
	end)

	RegisterFlag(slider, flag)
	if cfg.Callback then
		slider:OnChange(cfg.Callback)
	end
	slider:Set(tonumber(cfg.Default) or min, true, true)
	return slider
end

local DROPDOWN_HEADER = 40
local DROPDOWN_ROW = 30

local function NormalizeOptions(list, iconMap)
	local result, seen = {}, {}
	if type(list) ~= "table" then
		return result
	end
	for _, option in ipairs(list) do
		local entry
		if type(option) == "string" or type(option) == "number" then
			entry = { Name = tostring(option) }
		elseif type(option) == "table" then
			local name = option.Name or option.Value or option[1]
			if name ~= nil then
				entry = {
					Name = tostring(name),
					Display = option.Display ~= nil and tostring(option.Display) or nil,
					Icon = option.Icon or option[2],
				}
			end
		end
		if entry and not seen[entry.Name] then
			seen[entry.Name] = true
			if entry.Icon == nil and iconMap then
				entry.Icon = iconMap[entry.Name]
			end
			table.insert(result, entry)
		end
	end
	return result
end

function Dropdown:_find(name)
	for _, option in ipairs(self._options) do
		if option.Name == name then
			return option
		end
	end
	return nil
end

function Dropdown:_listHeight()
	local visible = math.min(math.max(#self._options, 1), self._maxVisible)
	return visible * DROPDOWN_ROW + (visible - 1) * 2
end

function Dropdown:_openHeight()
	return DROPDOWN_HEADER + self:_listHeight() + 8
end

function Dropdown:_styleRow(row, instant)
	local theme = self.Window.Theme
	local duration = instant and 0 or 0.15
	local selected = self.Value == row.Name
	if selected then
		Tween(row.Button, { BackgroundColor3 = theme.Primary, BackgroundTransparency = 0.55 }, duration)
		Tween(row.Label, { TextColor3 = theme.Text }, duration)
		Tween(row.Check, { [IconTransparencyProperty(row.Check)] = 0 }, duration)
	else
		Tween(row.Button, { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = row.Hover and 0.92 or 1 }, duration)
		Tween(row.Label, { TextColor3 = row.Hover and theme.Text or theme.SubText }, duration)
		Tween(row.Check, { [IconTransparencyProperty(row.Check)] = 1 }, duration)
	end
end

function Dropdown:_renderSelection(instant)
	local theme = self.Window.Theme
	local option = self.Value and self:_find(self.Value)
	self._valueLabel.Text = option and (option.Display or option.Name) or self._placeholder
	Tween(self._valueLabel, { TextColor3 = option and theme.Text or theme.SubText }, instant and 0 or 0.15)
	for _, row in pairs(self._rows) do
		self:_styleRow(row, instant)
	end
end

function Dropdown:_buildRows()
	local theme = self.Window.Theme
	for _, row in pairs(self._rows) do
		row.Button:Destroy()
	end
	self._rows = {}
	if self._emptyRow then
		self._emptyRow:Destroy()
		self._emptyRow = nil
	end

	if #self._options == 0 then
		self._emptyRow = Create("TextLabel", {
			Name = "Empty",
			Size = UDim2.new(1, 0, 0, DROPDOWN_ROW),
			Text = self._emptyText,
			TextColor3 = theme.SubText,
			TextSize = 12,
			Parent = self._list,
		})
		return
	end

	for index, option in ipairs(self._options) do
		local button = Create("TextButton", {
			Name = option.Name,
			LayoutOrder = index,
			Size = UDim2.new(1, 0, 0, DROPDOWN_ROW),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Parent = self._list,
		}, { Corner(UDim.new(0, 6)) })

		local textOffset = 10
		if option.Icon ~= nil then
			local icon = MakeIcon(button, option.Icon, 16, theme.Text, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 8, 0.5, 0),
			})
			if icon then
				textOffset = 32
				if icon:IsA("ImageLabel") and tostring(option.Icon):find("^rbxthumb") then
					Create("UICorner", { CornerRadius = PILL, Parent = icon })
				end
			end
		end
		local label = Create("TextLabel", {
			Name = "Text",
			Position = UDim2.fromOffset(textOffset, 0),
			Size = UDim2.new(1, -(textOffset + 30), 1, 0),
			Text = option.Display or option.Name,
			TextColor3 = theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = button,
		})
		local check = MakeIcon(button, "check", 14, theme.Text, {
			Name = "Check",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
		}, "✓")
		check[IconTransparencyProperty(check)] = 1

		local row = { Name = option.Name, Button = button, Label = label, Check = check, Hover = false }
		self._rows[option.Name] = row

		button.MouseEnter:Connect(function()
			row.Hover = true
			self:_styleRow(row)
		end)
		button.MouseLeave:Connect(function()
			row.Hover = false
			self:_styleRow(row)
		end)
		button.MouseButton1Click:Connect(function()
			self:Set(option.Name)
			self:Close()
		end)
	end
end

function Dropdown:_applySize()
	self._list.Size = UDim2.new(1, -12, 0, self:_listHeight())
	if self.IsOpen then
		Tween(self.Frame, { Size = UDim2.new(1, 0, 0, self:_openHeight()) }, 0.25)
	end
end

function Dropdown:Open()
	if self.IsOpen or self._destroyed then
		return
	end
	self.IsOpen = true
	self._token += 1
	self._list.Visible = true
	self._list.Size = UDim2.new(1, -12, 0, self:_listHeight())
	Tween(self.Frame, { Size = UDim2.new(1, 0, 0, self:_openHeight()) }, 0.28)
	Tween(self._arrow, { Rotation = 180 }, 0.25)
end

function Dropdown:Close()
	if not self.IsOpen or self._destroyed then
		return
	end
	self.IsOpen = false
	self._token += 1
	local token = self._token
	Tween(self.Frame, { Size = UDim2.new(1, 0, 0, DROPDOWN_HEADER) }, 0.25)
	Tween(self._arrow, { Rotation = 0 }, 0.25)
	task.delay(0.28, function()
		if not self._destroyed and self._token == token then
			self._list.Visible = false
		end
	end)
end

function Dropdown:Set(value, silent)
	if self._destroyed then
		return
	end
	if value ~= nil then
		value = tostring(value)
		if not self:_find(value) then
			warn(string.format("[Vetor] Dropdown '%s': opção '%s' não existe.", tostring(self.Name), value))
			return
		end
	end
	local changed = value ~= self.Value
	self.Value = value
	self:_renderSelection(false)
	if changed and not silent then
		self.Changed:Fire(value)
	end
end

function Dropdown:GetOptions()
	local names = {}
	for _, option in ipairs(self._options) do
		table.insert(names, option.Name)
	end
	return names
end

function Dropdown:Refresh(options)
	if self._destroyed then
		return
	end
	self._options = NormalizeOptions(options, self._iconMap)
	local stale = self.Value ~= nil and self:_find(self.Value) == nil
	if stale then
		self.Value = nil
	end
	self:_buildRows()
	self:_renderSelection(true)
	self:_applySize()
	if stale then
		self.Changed:Fire(nil)
	end
end

function Dropdown:AddOption(option)
	local list = {}
	for _, existing in ipairs(self._options) do
		table.insert(list, existing)
	end
	table.insert(list, option)
	self:Refresh(list)
end

function Dropdown:RemoveOption(name)
	name = tostring(name)
	local list = {}
	for _, existing in ipairs(self._options) do
		if existing.Name ~= name then
			table.insert(list, existing)
		end
	end
	self:Refresh(list)
end

function Container:AddDropdown(cfg)
	cfg = Config(cfg, "Dropdown")
	local window, theme = self.Window, self.Window.Theme
	local name = tostring(cfg.Name or "Dropdown")
	local flag = cfg.Flag and tostring(cfg.Flag) or nil

	local frame = self:_row(DROPDOWN_HEADER)
	frame.ClipsDescendants = true
	local dropdown = NewElement(Dropdown, "Dropdown", window, frame, name, flag)
	dropdown.Value = nil
	dropdown.IsOpen = false
	dropdown._token = 0
	dropdown._rows = {}
	dropdown._iconMap = type(cfg.Icons) == "table" and cfg.Icons or nil
	dropdown._options = NormalizeOptions(cfg.Options, dropdown._iconMap)
	dropdown._placeholder = tostring(cfg.Placeholder or "Select...")
	dropdown._emptyText = tostring(cfg.EmptyText or "No options")
	dropdown._maxVisible = math.max(1, math.floor(tonumber(cfg.MaxVisible) or 5))

	local header = Create("TextButton", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, DROPDOWN_HEADER),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = frame,
	})
	NameLabel(frame, theme, name, 0).Size = UDim2.new(0.5, -12, 0, DROPDOWN_HEADER)
	dropdown._valueLabel = Create("TextLabel", {
		Name = "Selected",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -36, 0, 0),
		Size = UDim2.new(0.5, -44, 0, DROPDOWN_HEADER),
		TextColor3 = theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		Parent = frame,
	})
	dropdown._arrow = MakeIcon(frame, "chevron-down", 16, theme.SubText, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -20, 0, DROPDOWN_HEADER / 2),
		ZIndex = 2,
	}, "v")
	dropdown._list = Create("ScrollingFrame", {
		Name = "List",
		Position = UDim2.new(0, 6, 0, DROPDOWN_HEADER),
		Size = UDim2.new(1, -12, 0, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.Primary,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		ZIndex = 2,
		Parent = frame,
	}, { ListLayout(2) })

	BindInteraction(header, frame, theme, dropdown._maid)
	dropdown._maid:Add(header.MouseButton1Click:Connect(function()
		if dropdown.IsOpen then
			dropdown:Close()
		else
			dropdown:Open()
		end
	end))

	RegisterFlag(dropdown, flag)
	if cfg.Callback then
		dropdown:OnChange(cfg.Callback)
	end
	dropdown:_buildRows()
	if cfg.Default ~= nil and dropdown:_find(tostring(cfg.Default)) then
		dropdown.Value = tostring(cfg.Default)
	end
	dropdown:_renderSelection(true)
	return dropdown
end

PlayersDropdown.__index = function(self, key)
	if key == "Value" then
		return PlayersDropdown.Get(self)
	end
	return PlayersDropdown[key]
end

local function BuildPlayerOptions(includeLocal, leaving)
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= leaving and (includeLocal or player ~= LocalPlayer) then
			local display = player.Name
			if player.DisplayName ~= player.Name then
				display = player.DisplayName .. " (@" .. player.Name .. ")"
			end
			table.insert(list, {
				Name = player.Name,
				Display = display,
				Icon = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48", player.UserId),
			})
		end
	end
	table.sort(list, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)
	return list
end

local function FindPlayer(name)
	if not name then
		return nil
	end
	local player = Players:FindFirstChild(name)
	if player and player:IsA("Player") and player.Parent == Players then
		return player
	end
	return nil
end

function PlayersDropdown:Get()
	local name = self.Dropdown.Value
	if not name then
		return nil
	end
	local player = FindPlayer(name)
	if not player then
		self.Dropdown:Set(nil)
	end
	return player
end

function PlayersDropdown:Set(playerOrName, silent)
	if playerOrName == nil then
		self.Dropdown:Set(nil, silent)
		return
	end
	local name = typeof(playerOrName) == "Instance" and playerOrName.Name or tostring(playerOrName)
	self.Dropdown:Set(name, silent)
end

function PlayersDropdown:Refresh(leaving)
	if self._destroyed then
		return
	end
	self.Dropdown:Refresh(BuildPlayerOptions(self._includeLocal, leaving))
end

function PlayersDropdown:Open()
	self.Dropdown:Open()
end

function PlayersDropdown:Close()
	self.Dropdown:Close()
end

function PlayersDropdown:Destroy()
	if self._destroyed then
		return
	end
	self.Dropdown:Destroy()
	Element.Destroy(self)
end

function Container:AddPlayersDropdown(cfg)
	cfg = Config(cfg, "Players")
	local window = self.Window
	local name = tostring(cfg.Name or "Players")
	local flag = cfg.Flag and tostring(cfg.Flag) or nil
	local includeLocal = cfg.IncludeLocalPlayer == true

	local dropdown = self:AddDropdown({
		Name = name,
		Options = BuildPlayerOptions(includeLocal, nil),
		Placeholder = cfg.Placeholder or "Select a player",
		EmptyText = cfg.EmptyText or "No players available",
		MaxVisible = cfg.MaxVisible,
	})

	local picker = NewElement(PlayersDropdown, "PlayersDropdown", window, dropdown.Frame, name, flag)
	picker.Dropdown = dropdown
	picker._includeLocal = includeLocal

	picker._maid:Add(dropdown.Changed:Connect(function(selectedName)
		picker.Changed:Fire(FindPlayer(selectedName))
	end))
	picker._maid:Add(Players.PlayerAdded:Connect(function()
		picker:Refresh()
	end))
	picker._maid:Add(Players.PlayerRemoving:Connect(function(leaving)
		picker:Refresh(leaving)
	end))

	RegisterFlag(picker, flag)
	if cfg.Callback then
		picker:OnChange(cfg.Callback)
	end

	if cfg.Default ~= nil then
		local defaultName = typeof(cfg.Default) == "Instance" and cfg.Default.Name or tostring(cfg.Default)
		if dropdown:_find(defaultName) then
			dropdown:Set(defaultName, true)
		end
	end
	return picker
end

function Bind:Set(key)
	self._core:SetKey(key)
end

function Bind:Clear()
	self._core:SetKey(nil)
end

function Container:AddBind(cfg)
	cfg = Config(cfg, "Bind")
	local window, theme = self.Window, self.Window.Theme
	local name = tostring(cfg.Name or "Bind")
	local flag = cfg.Flag and tostring(cfg.Flag) or nil

	local frame = self:_row(40)
	local bind = NewElement(Bind, "Bind", window, frame, name, flag)
	bind.Hold = cfg.Hold == true
	bind.Triggered = Signal.new() 
	bind._maid:Add(function()
		bind.Triggered:Destroy()
	end)

	local core = BindCore.new({
		Key = cfg.Default,
		Hold = bind.Hold,
		OnPress = function()
			bind.Triggered:Fire(true)
		end,
		OnRelease = function()
			if bind.Hold then
				bind.Triggered:Fire(false)
			end
		end,
	})
	bind._core = core
	bind.Value = core.Key
	bind._maid:Add(function()
		core:Destroy()
	end)
	bind._maid:Add(core.KeyChanged:Connect(function(key)
		bind.Value = key
		bind.Changed:Fire(key)
	end))

	NameLabel(frame, theme, name, 110)
	local chip = BuildBindChip(window, frame, core, bind._maid)
	chip.AnchorPoint = Vector2.new(1, 0.5)
	chip.Position = UDim2.new(1, -12, 0.5, 0)

	RegisterFlag(bind, flag)
	if cfg.Callback then
		bind.Triggered:Connect(cfg.Callback)
	end
	return bind
end

function Textbox:Set(text, silent)
	text = tostring(text or "")
	local changed = text ~= self.Value
	self.Value = text
	self._input.Text = text
	if changed and not silent then
		self.Changed:Fire(text)
	end
end

function Container:AddTextbox(cfg)
	cfg = Config(cfg, "Textbox")
	local window, theme = self.Window, self.Window.Theme
	local name = tostring(cfg.Name or "Textbox")
	local flag = cfg.Flag and tostring(cfg.Flag) or nil
	local frame = self:_row(40)
	local textbox = NewElement(Textbox, "Textbox", window, frame, name, flag)
	textbox.Value = ""

	NameLabel(frame, theme, name, 160)
	local inputFrame = Create("Frame", {
		Name = "InputFrame",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(136, 26),
		BackgroundColor3 = theme.ElementPress,
		BackgroundTransparency = 0.2,
		ZIndex = 2,
		Parent = frame,
	}, { Corner(UDim.new(0, 6)) })
	local inputStroke = Stroke(theme)
	inputStroke.Parent = inputFrame
	textbox._input = Create("TextBox", {
		Name = "Input",
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = tostring(cfg.Placeholder or ""),
		PlaceholderColor3 = theme.SubText,
		TextColor3 = theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = inputFrame,
	})

	textbox._maid:Add(textbox._input.Focused:Connect(function()
		Tween(inputStroke, { Color = theme.Primary, Transparency = 0.2 }, 0.15)
	end))
	textbox._maid:Add(textbox._input.FocusLost:Connect(function()
		Tween(inputStroke, { Color = theme.Stroke, Transparency = theme.StrokeTransparency }, 0.2)
		textbox:Set(textbox._input.Text)
	end))

	RegisterFlag(textbox, flag)
	if cfg.Callback then
		textbox:OnChange(cfg.Callback)
	end
	if cfg.Default ~= nil then
		textbox:Set(cfg.Default, true)
	end
	return textbox
end

local Section = setmetatable({}, { __index = Container })
Section.__index = Section

local Tab = setmetatable({}, { __index = Container })
Tab.__index = Tab

function Tab:AddSection(cfg)
	cfg = Config(cfg, "Section")
	local theme = self.Window.Theme
	local holder = Create("Frame", {
		Name = "Section",
		LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Holder,
	}, { ListLayout(6) })
	Create("TextLabel", {
		Name = "Title",
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Text = string.upper(tostring(cfg.Name or "Section")),
		TextColor3 = theme.Accent,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	}, { Padding(4, 0, 0, 0) })
	return setmetatable({
		Window = self.Window,
		Frame = holder,
		Holder = holder,
		Scroller = self.Scroller,
		_order = 0,
	}, Section)
end

function Section:SetVisibility(visible)
	return SetElementVisibility(self, visible)
end

function Tab:_setActive(active, instant)
	self._token += 1
	local token = self._token
	local page, button = self.Page, self.Button
	local duration = instant and 0 or 0.25
	if active then
		page.Visible = true
		page.Position = UDim2.fromOffset(0, instant and 0 or 14)
		page.GroupTransparency = instant and 0 or 1
		Tween(page, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }, duration * 1.2)
		Tween(button, { BackgroundTransparency = 0.8 }, duration)
		if self._icon then
			Tween(self._icon, { [IconTransparencyProperty(self._icon)] = 0 }, duration)
		end
	else
		Tween(page, { GroupTransparency = 1 }, 0.12)
		Tween(button, { BackgroundTransparency = 1 }, duration)
		if self._icon then
			Tween(self._icon, { [IconTransparencyProperty(self._icon)] = 0.45 }, duration)
		end
		task.delay(0.14, function()
			if self._token == token and page.Parent then
				page.Visible = false
			end
		end)
	end
end

local Window = {}
Window.__index = Window

function Window:_viewport()
	local gui = Library._gui
	if gui and gui.AbsoluteSize.X > 0 then
		return gui.AbsoluteSize
	end
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

function Window:_applyLayout()
	local viewport = self:_viewport()
	local width = math.clamp(self._baseSize.X, 260, math.max(260, viewport.X - 24))
	local height = math.clamp(self._baseSize.Y, 200, math.max(200, viewport.Y - 24))
	self._width, self._height = width, height
	self.Body.Size = UDim2.new(1, 0, 0, height - HEADER_TOTAL)
	self.Root.Size = UDim2.fromOffset(width, self.Minimized and HEADER_TOTAL or height)

	local position = self.Root.Position
	if position.X.Scale == 0 and position.Y.Scale == 0 then
		self.Root.Position = UDim2.fromOffset(
			math.clamp(position.X.Offset, 40, math.max(40, viewport.X - 40)),
			math.clamp(position.Y.Offset, 40, math.max(40, viewport.Y - 40))
		)
	end
end

function Window:_animateIn()
	self.Root.Visible = true
	Tween(self._scale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
	Tween(self.Main, { GroupTransparency = 0 }, 0.3)
	self._line.Size = UDim2.new(0, 0, 0, 2)
	Tween(self._line, { Size = UDim2.new(1, 0, 0, 2) }, 0.7)
	if self._blur then
		Tween(self._blur, { Size = self._blurSize }, 0.4)
	end
end

function Window:_animateOut()
	Tween(self._scale, { Scale = 0.92 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	Tween(self.Main, { GroupTransparency = 1 }, 0.22)
	if self._blur then
		Tween(self._blur, { Size = 0 }, 0.25)
	end
end

function Window:_setFreeMouse(enabled)
	if enabled then
		if not self._mouseState then
			self._mouseState = {
				Behavior = UserInputService.MouseBehavior,
				IconEnabled = UserInputService.MouseIconEnabled,
			}
			self._mouseConnection = RunService.RenderStepped:Connect(function()
				if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
					return
				end
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end)
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	elseif self._mouseState then
		if self._mouseConnection then
			self._mouseConnection:Disconnect()
			self._mouseConnection = nil
		end
		local mouseState = self._mouseState
		self._mouseState = nil
		UserInputService.MouseBehavior = mouseState.Behavior
		UserInputService.MouseIconEnabled = mouseState.IconEnabled
	end
end

function Window:SetVisible(state)
	if self._destroyed or state == self.Visible then
		return
	end
	self.Visible = state
	self._visibleToken += 1
	local token = self._visibleToken
	if state and self.FreeMouse then
		self:_setFreeMouse(true)
	else
		self:_setFreeMouse(false)
	end
	if state then
		self:_animateIn()
	else
		self:_animateOut()
		task.delay(0.24, function()
			if not self._destroyed and self._visibleToken == token then
				self.Root.Visible = false
			end
		end)
	end
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:SetMinimized(state)
	if self._destroyed or state == self.Minimized then
		return
	end
	self.Minimized = state
	self._minimizeToken += 1
	local token = self._minimizeToken
	local shift = (self._height - HEADER_TOTAL) / 2
	local position = self.Root.Position
	local active = self.ActiveTab

	if state then
		self._minimizeShift = shift
		if active then
			Tween(active.Page, { GroupTransparency = 1 }, 0.15)
		end
		Tween(self.TabBar, { Position = UDim2.new(0.5, 0, 1, 70) }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		Tween(self.Root, {
			Size = UDim2.fromOffset(self._width, HEADER_TOTAL),
			Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset - shift),
		}, 0.35)
		task.delay(0.36, function()
			if not self._destroyed and self._minimizeToken == token then
				self.Body.Visible = false
			end
		end)
	else
		self.Body.Visible = true
		local restore = self._minimizeShift or shift
		Tween(self.Root, {
			Size = UDim2.fromOffset(self._width, self._height),
			Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + restore),
		}, 0.4, Enum.EasingStyle.Back)
		Tween(self.TabBar, { Position = UDim2.new(0.5, 0, 1, -14) }, 0.4, Enum.EasingStyle.Back)
		if active then
			Tween(active.Page, { GroupTransparency = 0 }, 0.3)
		end
	end
end

function Window:SelectTab(target)
	local tab
	if type(target) == "number" then
		tab = self.Tabs[target]
	elseif type(target) == "string" then
		for _, candidate in ipairs(self.Tabs) do
			if candidate.Name == target then
				tab = candidate
				break
			end
		end
	elseif type(target) == "table" then
		tab = target
	end
	if not tab or tab == self.ActiveTab then
		return
	end
	local previous = self.ActiveTab
	self.ActiveTab = tab
	if previous then
		previous:_setActive(false)
	end
	tab:_setActive(true, self.Minimized)
	self._subtitle.Text = tab.Name
end

function Window:SetTitle(text)
	self._title.Text = tostring(text)
end

function Window:MakeTab(cfg)
	cfg = Config(cfg, "Tab")
	local theme = self.Theme
	local name = tostring(cfg.Name or "Tab")

	local tab = setmetatable({
		Window = self,
		Name = name,
		_order = 0,
		_token = 0,
	}, Tab)

	tab.Page = Create("CanvasGroup", {
		Name = "Page_" .. name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		Parent = self.Pages,
	})
	tab.Scroller = Create("ScrollingFrame", {
		Name = "Scroller",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Primary,
		ScrollBarImageTransparency = 0.3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = tab.Page,
	}, { ListLayout(10), Padding(12, 12, 12, 76) })
	tab.Holder = tab.Scroller

	tab.Button = Create("TextButton", {
		Name = name,
		LayoutOrder = #self.Tabs + 1,
		Size = UDim2.fromOffset(44, 32),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Parent = self.TabBar,
	}, { Corner(PILL) })
	tab._icon = MakeIcon(tab.Button, cfg.Icon or DEFAULT_TAB_ICON, 18, Color3.new(1, 1, 1), {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	}, string.upper(string.sub(name, 1, 1)))
	if tab._icon then
		tab._icon[IconTransparencyProperty(tab._icon)] = 0.45
	end

	self.Maid:Add(tab.Button.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then
			Tween(tab.Button, { BackgroundTransparency = 0.9 }, 0.15)
		end
	end))
	self.Maid:Add(tab.Button.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then
			Tween(tab.Button, { BackgroundTransparency = 1 }, 0.2)
		end
	end))
	self.Maid:Add(tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end))

	table.insert(self.Tabs, tab)
	self.TabBar.Visible = true
	if not self.ActiveTab then
		self:SelectTab(tab)
	end
	return tab
end

function Window:Close()
	if self._destroyed or self._closing then
		return
	end
	self._closing = true
	self:_setFreeMouse(false)
	self:_animateOut()
	task.delay(0.25, function()
		self:Destroy()
	end)
end

function Window:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self:_setFreeMouse(false)
	for element in pairs(table.clone(self._elements)) do
		element:Destroy()
	end
	self.Maid:Clean()
	if self._toggleBind then
		self._toggleBind:Destroy()
	end
	if self._blur then
		self._blur:Destroy()
	end
	self.Root:Destroy()
	local index = table.find(Library.Windows, self)
	if index then
		table.remove(Library.Windows, index)
	end
end

function Library:MakeWindow(cfg)
	cfg = Config(cfg, "Window")
	EnsureInput()
	local gui = GetGui()
	local theme = MergeTheme(cfg.Theme)
	local name = tostring(cfg.Name or "Window")

	local size = cfg.Size
	local baseSize
	if typeof(size) == "Vector2" then
		baseSize = size
	elseif typeof(size) == "UDim2" then
		baseSize = Vector2.new(size.X.Offset, size.Y.Offset)
	else
		baseSize = Vector2.new(540, 380)
	end

	local window = setmetatable({
		Library = self,
		Theme = theme,
		Name = name,
		Tabs = {},
		ActiveTab = nil,
		Visible = true,
		FreeMouse = cfg.FreeMouse ~= false,
		UseCheckbox = cfg.UseCheckbox == true,
		Minimized = false,
		Maid = Maid.new(),
		_elements = {},
		_baseSize = baseSize,
		_visibleToken = 0,
		_minimizeToken = 0,
	}, Window)

	window.Root = Create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(baseSize.X, baseSize.Y),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	window.Main = Create("CanvasGroup", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = theme.BackgroundTransparency,
		GroupTransparency = 1,
		Parent = window.Root,
	}, {
		Corner(UDim.new(0, 18)),
		Stroke(theme, nil, 0.88),
	})
	window._scale = Create("UIScale", { Scale = 0.9, Parent = window.Main })

	Create("Frame", {
		Name = "Sheen",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = false,
		Parent = window.Main,
	}, {
		Create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.93),
				NumberSequenceKeypoint.new(0.5, 0.98),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	})

	local header = Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		BackgroundTransparency = 1,
		Active = true,
		Parent = window.Main,
	})

	local iconImage, iconIsLucide = ResolveIcon(cfg.Icon)
	if not iconImage then
		iconImage, iconIsLucide = ResolveIcon(DEFAULT_WINDOW_ICON)
	end
	local iconBackground = cfg.IconBackground
	if iconBackground == nil and iconIsLucide then
		iconBackground = theme.Primary
	end
	local iconHolder = Create("Frame", {
		Name = "IconHolder",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = iconBackground or theme.Primary,
		BackgroundTransparency = iconBackground and 0 or 1,
		Parent = header,
	}, { Corner(PILL) })
	if iconImage then
		local inner = iconIsLucide and 18 or 34
		Create("ImageLabel", {
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(inner, inner),
			Image = iconImage,
			ImageColor3 = Color3.new(1, 1, 1),
			Parent = iconHolder,
		}, { not iconIsLucide and Corner(PILL) or nil })
	else
		iconHolder.BackgroundTransparency = 0
		Create("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			Text = string.upper(string.sub(name, 1, 1)),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			Parent = iconHolder,
		})
	end

	window._title = Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(58, 8),
		Size = UDim2.new(1, -170, 0, 20),
		Text = name,
		TextColor3 = theme.Text,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	window._subtitle = Create("TextLabel", {
		Name = "Subtitle",
		Position = UDim2.fromOffset(58, 28),
		Size = UDim2.new(1, -170, 0, 14),
		Text = "",
		TextColor3 = theme.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local closeButton = Create("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Danger,
		BackgroundTransparency = 1,
		Parent = header,
	}, { Corner(PILL), Stroke(theme, Color3.new(1, 1, 1), 0.15, 1.5) })
	MakeIcon(closeButton, "x", 14, Color3.new(1, 1, 1), {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	}, "x")

	local minimizeButton = Create("TextButton", {
		Name = "Minimize",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -50, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Parent = header,
	}, { Corner(PILL) })
	MakeIcon(minimizeButton, "minus", 16, Color3.new(1, 1, 1), {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	}, "-")

	window.Maid:Add(closeButton.MouseEnter:Connect(function()
		Tween(closeButton, { BackgroundTransparency = 0.2 }, 0.15)
	end))
	window.Maid:Add(closeButton.MouseLeave:Connect(function()
		Tween(closeButton, { BackgroundTransparency = 1 }, 0.2)
	end))
	window.Maid:Add(closeButton.MouseButton1Click:Connect(function()
		window:Close()
	end))
	window.Maid:Add(minimizeButton.MouseEnter:Connect(function()
		Tween(minimizeButton, { BackgroundTransparency = 0.85 }, 0.15)
	end))
	window.Maid:Add(minimizeButton.MouseLeave:Connect(function()
		Tween(minimizeButton, { BackgroundTransparency = 1 }, 0.2)
	end))
	window.Maid:Add(minimizeButton.MouseButton1Click:Connect(function()
		window:SetMinimized(not window.Minimized)
	end))

	window._line = Create("Frame", {
		Name = "AccentLine",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, HEADER_HEIGHT),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = theme.Accent,
		Parent = window.Main,
	})

	window.Body = Create("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, HEADER_TOTAL),
		Size = UDim2.new(1, 0, 1, -HEADER_TOTAL),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = window.Main,
	})
	window.Pages = Create("Frame", {
		Name = "Pages",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = window.Body,
	})
	window.TabBar = Create("Frame", {
		Name = "TabBar",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -14),
		Size = UDim2.fromOffset(0, 40),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = theme.TabBar,
		BackgroundTransparency = 0.04,
		Visible = false,
		ZIndex = 5,
		Parent = window.Body,
	}, {
		Corner(PILL),
		Stroke(theme, Color3.new(1, 1, 1), 0.85),
		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		Padding(8, 8, 4, 4),
	})

	local resizeHandle = Create("TextButton", {
		Name = "ResizeHandle",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -6, 1, -6),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Text = "",
		Active = true,
		ZIndex = 10,
		Parent = window.Main,
	})
	for index = 1, 3 do
		Create("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -4 - (index - 1) * 4, 1, -4),
			Size = UDim2.fromOffset(2, 7 + (index - 1) * 3),
			Rotation = 45,
			BackgroundColor3 = theme.SubText,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			ZIndex = 11,
			Parent = resizeHandle,
		})
	end
	window.Maid:Add(resizeHandle.InputBegan:Connect(function(input)
		if not IsPointerDown(input) or window._resizeFinish then
			return
		end
		local startMouse = Vector2.new(input.Position.X, input.Position.Y)
		local startSize = Vector2.new(window._width, window._height)
		local startTopLeft = window.Root.AbsolutePosition
		local startPosition = window.Root.Position
		window._resizeFinish = TrackDrag(input, function(position)
			local viewport = window:_viewport()
			local delta = Vector2.new(position.X, position.Y) - startMouse
			local width = math.clamp(
				startSize.X + delta.X,
				260,
				math.max(260, viewport.X - startTopLeft.X - 12)
			)
			local height = math.clamp(
				startSize.Y + delta.Y,
				200,
				math.max(200, viewport.Y - startTopLeft.Y - 12)
			)
			local sizeDelta = Vector2.new(width, height) - startSize
			window._baseSize = Vector2.new(width, height)
			window._width, window._height = width, height
			window.Body.Size = UDim2.new(1, 0, 0, height - HEADER_TOTAL)
			window.Root.Size = UDim2.fromOffset(width, window.Minimized and HEADER_TOTAL or height)
			window.Root.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + sizeDelta.X / 2,
				startPosition.Y.Scale,
				startPosition.Y.Offset + sizeDelta.Y / 2
			)
		end, function()
			window._resizeFinish = nil
		end)
	end))

	window.Maid:Add(header.InputBegan:Connect(function(input)
		if not IsPointerDown(input) or window._dragFinish then
			return
		end
		local startMouse = Vector2.new(input.Position.X, input.Position.Y)
		local startCenter = window.Root.AbsolutePosition + window.Root.AbsoluteSize / 2
		local startPosition = window.Root.Position
		window._dragFinish = TrackDrag(input, function(position)
			local viewport = window:_viewport()
			local delta = Vector2.new(position.X, position.Y) - startMouse
			local x = math.clamp(startCenter.X + delta.X, 40, math.max(40, viewport.X - 40))
			local y = math.clamp(startCenter.Y + delta.Y, 30, math.max(30, viewport.Y - 30))
			window.Root.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + x - startCenter.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + y - startCenter.Y
			)
		end, function()
			window._dragFinish = nil
		end)
	end))
	window.Maid:Add(function()
		if window._dragFinish then
			window._dragFinish()
		end
		if window._resizeFinish then
			window._resizeFinish()
		end
	end)

	window.Maid:Add(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		window:_applyLayout()
	end))
	window:_applyLayout()

	local toggleKey = cfg.UiBind
	if toggleKey == nil then
		toggleKey = cfg.ToggleKey
	end
	if toggleKey == nil then
		toggleKey = cfg.ToggleKeybind
	end
	if toggleKey == nil then
		toggleKey = Enum.KeyCode.RightShift
	end
	if toggleKey ~= false then
		window._toggleBind = BindCore.new({
			Key = toggleKey,
			OnPress = function()
				window:Toggle()
			end,
		})
	end

	if cfg.Blur then
		local ok, blur = pcall(function()
			return Create("BlurEffect", { Name = RandomName(), Size = 0, Parent = Lighting })
		end)
		if ok then
			window._blur = blur
			window._blurSize = type(cfg.Blur) == "number" and cfg.Blur or 12
		end
	end

	table.insert(self.Windows, window)
	window:_setFreeMouse(window.FreeMouse)
	window:_animateIn()
	return window
end

function Library:Init()
	return self
end

function Library:Destroy()
	for _, window in ipairs(table.clone(self.Windows)) do
		window:Destroy()
	end
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	self._connections = {}
	table.clear(self._binds)
	self._capture = nil
	for _, pending in pairs(self._pendingToggleChanges) do
		pending:Destroy()
	end
	table.clear(self._pendingToggleChanges)
	if self._gui then
		self._gui:Destroy()
		self._gui = nil
		self._notifyHolder = nil
	end
	table.clear(self.Toggles)
	table.clear(self.ToggleStates)
	table.clear(self.Flags)
end

return Library
