local ScreenGui = Instance.new("ScreenGui")
local MainMenu = Instance.new("Frame")
local UICorner_Main = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local KeyContainer = Instance.new("ScrollingFrame")
local CloseBtn = Instance.new("TextButton")
local MinimizeBtn = Instance.new("TextButton")
local Logo = Instance.new("TextButton")
local UIGridLayout = Instance.new("UIGridLayout")
local VirtualInput = game:GetService("VirtualInputManager")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "RedKid_Ultimate_Keyboard"

-- Menu chính (Bo góc + RGB)
MainMenu.Parent = ScreenGui
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.Position = UDim2.new(0.3, 0, 0.2, 0)
MainMenu.Size = UDim2.new(0, 500, 0, 380)
MainMenu.Active = true
MainMenu.Draggable = true

UICorner_Main.CornerRadius = UDim.new(0, 15)
UICorner_Main.Parent = MainMenu

UIStroke.Parent = MainMenu
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Tiêu đề: Keyboard by RedKid
Title.Parent = MainMenu
Title.Size = UDim2.new(1, -90, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Keyboard by RedKid"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- Nút X (Tắt hẳn)
CloseBtn.Parent = MainMenu
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Nút ẩn (-)
MinimizeBtn.Parent = MainMenu
MinimizeBtn.Position = UDim2.new(1, -80, 0, 10)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

-- Logo đỏ (Dùng để mở lại)
Logo.Parent = ScreenGui
Logo.Size = UDim2.new(0, 55, 0, 55)
Logo.Position = UDim2.new(0.05, 0, 0.4, 0)
Logo.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Logo.Visible = false
Logo.Active = true
Logo.Draggable = true
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)
local LogoStroke = Instance.new("UIStroke", Logo)
LogoStroke.Thickness = 2
LogoStroke.Color = Color3.fromRGB(255, 255, 255)

-- Container chứa phím
KeyContainer.Parent = MainMenu
KeyContainer.Position = UDim2.new(0, 15, 0, 50)
KeyContainer.Size = UDim2.new(1, -30, 0, 220)
KeyContainer.BackgroundTransparency = 1
KeyContainer.CanvasSize = UDim2.new(0, 0, 2.8, 0)
KeyContainer.ScrollBarThickness = 4

UIGridLayout.Parent = KeyContainer
UIGridLayout.CellSize = UDim2.new(0, 42, 0, 42)
UIGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)

-- Danh sách phím chuẩn "Real"
local allKeys = {
    "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero",
    "Plus", "Minus", "Asterisk", "Slash",
    "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
    "A", "S", "D", "F", "G", "H", "J", "K", "L",
    "Z", "X", "C", "V", "B", "N", "M", "Comma", "Period", "Semicolon",
    "LeftShift", "LeftControl", "LeftAlt", "Backspace", "Return", "Up", "Down", "Left", "Right"
}

local buttons = {}

local function createKey(keyName)
    local btn = Instance.new("TextButton")
    btn.Parent = KeyContainer
    
    local display = keyName
    if keyName == "One" then display = "1" elseif keyName == "Two" then display = "2"
    elseif keyName == "Three" then display = "3" elseif keyName == "Four" then display = "4"
    elseif keyName == "Five" then display = "5" elseif keyName == "Six" then display = "6"
    elseif keyName == "Seven" then display = "7" elseif keyName == "Eight" then display = "8"
    elseif keyName == "Nine" then display = "9" elseif keyName == "Zero" then display = "0"
    elseif keyName == "Plus" then display = "+" elseif keyName == "Minus" then display = "-"
    elseif keyName == "Asterisk" then display = "*" elseif keyName == "Slash" then display = "/"
    elseif keyName == "Comma" then display = "," elseif keyName == "Period" then display = "."
    elseif keyName == "LeftShift" then display = "Shft" elseif keyName == "LeftControl" then display = "Ctrl"
    elseif keyName == "Return" then display = "Ent" elseif keyName == "Backspace" then display = "Del"
    end

    btn.Text = display
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Thickness = 1.5

    -- Logic Nhấn Giữ (Dành cho di chuyển/đè phím)
    btn.MouseButton1Down:Connect(function()
        VirtualInput:SendKeyEvent(true, Enum.KeyCode[keyName], false, game)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    btn.MouseButton1Up:Connect(function()
        VirtualInput:SendKeyEvent(false, Enum.KeyCode[keyName], false, game)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    
    table.insert(buttons, {btn, s})
end

for _, k in ipairs(allKeys) do createKey(k) end

-- Space Bar RGB
local SpaceBar = Instance.new("TextButton")
SpaceBar.Parent = MainMenu
SpaceBar.Position = UDim2.new(0.1, 0, 0, 280)
SpaceBar.Size = UDim2.new(0.8, 0, 0, 40)
SpaceBar.Text = "SPACE"
SpaceBar.Font = Enum.Font.GothamBold
SpaceBar.TextColor3 = Color3.fromRGB(255, 255, 255)
SpaceBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", SpaceBar).CornerRadius = UDim.new(0, 10)
local SpaceStroke = Instance.new("UIStroke", SpaceBar)
SpaceStroke.Thickness = 2
table.insert(buttons, {SpaceBar, SpaceStroke})

SpaceBar.MouseButton1Down:Connect(function() VirtualInput:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
SpaceBar.MouseButton1Up:Connect(function() VirtualInput:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)

-- CHUỘT (Trái/Phải)
local function createMouse(name, pos, color, isLeft)
    local btn = Instance.new("TextButton")
    btn.Parent = MainMenu
    btn.Size = UDim2.new(0, 220, 0, 40)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    btn.MouseButton1Down:Connect(function() VirtualInput:SendMouseButtonEvent(0, 0, (isLeft and 0 or 1), true, game, 0) end)
    btn.MouseButton1Up:Connect(function() VirtualInput:SendMouseButtonEvent(0, 0, (isLeft and 0 or 1), false, game, 0) end)
end

createMouse("Chuột Trái", UDim2.new(0, 20, 1, -50), Color3.fromRGB(45, 100, 45), true)
createMouse("Chuột Phải", UDim2.new(1, -240, 1, -50), Color3.fromRGB(100, 45, 45), false)

-- Vòng lặp RGB
spawn(function()
    while task.wait() do
        local hue = tick() % 4 / 4
        local color = Color3.fromHSV(hue, 0.8, 1)
        UIStroke.Color = color
        LogoStroke.Color = color
        for _, item in ipairs(buttons) do
            item[2].Color = color -- Viền phím đổi màu
        end
    end
end)

-- Đóng/Ẩn logic
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinimizeBtn.MouseButton1Click:Connect(function() MainMenu.Visible = false Logo.Visible = true end)
Logo.MouseButton1Click:Connect(function() MainMenu.Visible = true Logo.Visible = false end)
