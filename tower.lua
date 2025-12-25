local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostHub_Premium"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- ЛОГИКА DRAGGING (Перетаскивание)
local dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ЗАГОЛОВОК
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " GHOST HUB | TOWER OF HELL"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- КНОПКА ЗАКРЫТИЯ (Кружок в углу)
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- КОНТЕЙНЕР ДЛЯ КНОПОК
local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -10, 1, -45)
Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Content.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 7)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК
local function CreateButton(name, color, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 320, 0, 35)
    b.BackgroundColor3 = color
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- --- ФУНКЦИОНАЛ ---

-- 1. ПОЛЕТ С НАСТРОЙКОЙ
local flyActive = false
local flySpeed = 50
local flyBtn = CreateButton("Fly: OFF (Current Speed: 50)", Color3.fromRGB(60, 60, 75), function()
    flyActive = not flyActive
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    if flyActive then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "GhostFly"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        task.spawn(function()
            while flyActive do
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
                RunService.RenderStepped:Wait()
            end
            bv:Destroy()
        end)
    end
end)

-- 2. АНТИ-ЛАЗЕР
CreateButton("Remove Lasers (God Mode)", Color3.fromRGB(46, 204, 113), function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "kills" or v.Name == "Laser" then v:Destroy() end
    end
    game.StarterGui:SetCore("SendNotification", {Title = "Ghost", Text = "Lasers Removed!"})
end)

-- 3. АВТО-ФИНИШ
CreateButton("Instant Win (Auto-Finish)", Color3.fromRGB(150, 80, 255), function()
    local finish = workspace.tower.sections.finish.FinishGlow
    LocalPlayer.Character.HumanoidRootPart.CFrame = finish.CFrame
end)

-- 4. ИЗМЕНЕНИЕ СКОРОСТИ (ПОЛЗУНОК ЗАМЕНЕН НА КНОПКИ ДЛЯ УДОБСТВА DELTA)
CreateButton("Increase Speed (+10)", Color3.fromRGB(50, 150, 250), function()
    flySpeed = flySpeed + 10
    flyBtn.Text = "Fly: "..(flyActive and "ON" or "OFF").." (Speed: "..flySpeed..")"
end)

-- КНОПКА ОТКРЫТИЯ
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 10, 0, 10)
OpenBtn.Text = "👻"
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.TextSize = 20
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
