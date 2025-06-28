-- Ждём, пока мяч появится в игре
repeat wait() until workspace:FindFirstChild("Ball")

-- Получаем сервисы
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")

-- Получаем LocalPlayer
local PLAYER = Players.LocalPlayer
local CC = workspace.CurrentCamera

-- Ожидаем появления персонажа
local character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Погрешность
local TOLERATE = 1

-- Зона для проверки (позиция и размеры)
local ZONE_POSITION = Vector3.new(0, 0.5, 0)
local ZONE_SIZE = Vector3.new(48, 0.2, 95)

-- Создаём маркер (невидимый)
local Marker = Instance.new("Part")
Marker.Name = "Marker"
Marker.Size = Vector3.new(2, 2, 2)
Marker.Shape = Enum.PartType.Ball
Marker.BrickColor = BrickColor.new("Bright violet")
Marker.CanCollide = false
Marker.Anchored = true
Marker.Parent = workspace
Marker.Transparency = 1
Marker.Material = Enum.Material.Neon

-- Создаём UI переключатель
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoDiveUI"
ScreenGui.Parent = PLAYER:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 210) -- Увеличили высоту для вкладок
MainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Создаем контейнер для кнопок вкладок
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
TabButtonsFrame.BackgroundTransparency = 1
TabButtonsFrame.Parent = MainFrame

-- Кнопка вкладки Main
local MainTabButton = Instance.new("TextButton")
MainTabButton.Name = "MainTab"
MainTabButton.Size = UDim2.new(0.5, -5, 1, 0)
MainTabButton.Position = UDim2.new(0, 0, 0, 0)
MainTabButton.Text = "Main"
MainTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MainTabButton.BorderSizePixel = 0
MainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabButton.Parent = TabButtonsFrame

-- Кнопка вкладки Binds
local BindsTabButton = Instance.new("TextButton")
BindsTabButton.Name = "BindsTab"
BindsTabButton.Size = UDim2.new(0.5, -5, 1, 0)
BindsTabButton.Position = UDim2.new(0.5, 5, 0, 0)
BindsTabButton.Text = "Binds"
BindsTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BindsTabButton.BorderSizePixel = 0
BindsTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
BindsTabButton.Parent = TabButtonsFrame

-- Основные элементы (находятся во вкладке Main)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0) -- Сдвинуто вниз для вкладок
ToggleButton.Text = "AutoDive: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Parent = MainFrame

local PanicButton = Instance.new("TextButton")
PanicButton.Size = UDim2.new(0, 200, 0, 40)
PanicButton.Position = UDim2.new(0.05, 0, 0.4, 0) -- Сдвинуто вниз для вкладок
PanicButton.Text = "PANIC BUTTON"
PanicButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
PanicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PanicButton.Parent = MainFrame

-- Слайдер задержки
local SliderContainer = Instance.new("Frame")
SliderContainer.Size = UDim2.new(0.9, 0, 0, 60)
SliderContainer.Position = UDim2.new(0.05, 0, 0.6, 0) -- Сдвинуто вниз для вкладок
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = MainFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.Position = UDim2.new(0, 0, 0, 0)
SliderLabel.Text = "Dive Delay: 1ms"
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = SliderContainer

local SliderTrack = Instance.new("Frame")
SliderTrack.Name = "Track"
SliderTrack.Size = UDim2.new(0.7, 0, 0, 6)
SliderTrack.Position = UDim2.new(0, 0, 0.5, -3)
SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = SliderContainer

local SliderFill = Instance.new("Frame")
SliderFill.Name = "Fill"
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local SliderButton = Instance.new("TextButton")
SliderButton.Name = "Thumb"
SliderButton.Size = UDim2.new(0, 24, 0, 24)
SliderButton.Position = UDim2.new(0, -12, 0.5, -12)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.BorderSizePixel = 0
SliderButton.Text = ""
SliderButton.Parent = SliderContainer

local TextBox = Instance.new("TextBox")
TextBox.Name = "DelayInput"
TextBox.Size = UDim2.new(0.25, 0, 0, 30)
TextBox.Position = UDim2.new(0.75, 5, 0.5, -15)
TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Text = "1"
TextBox.PlaceholderText = "1-1000"
TextBox.ClearTextOnFocus = false
TextBox.Parent = SliderContainer

-- Создаем фрейм для вкладки Binds (изначально скрыт)
local BindsFrame = Instance.new("Frame")
BindsFrame.Size = UDim2.new(0, 200, 0, 150)
BindsFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
BindsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BindsFrame.BorderSizePixel = 0
BindsFrame.Visible = false
BindsFrame.Parent = MainFrame

-- Создаем элементы для биндов
local BindToggles = {}

-- Функция для создания элементов биндов
local function createBindElements()
    -- Очищаем предыдущие элементы
    for _, v in pairs(BindsFrame:GetChildren()) do
        if v:IsA("Frame") then
            v:Destroy()
        end
    end
    
    -- Бинд для переключения AutoDive
    local toggleBindFrame = Instance.new("Frame")
    toggleBindFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleBindFrame.Position = UDim2.new(0, 0, 0, 0)
    toggleBindFrame.BackgroundTransparency = 1
    toggleBindFrame.Parent = BindsFrame
    
    local toggleBindLabel = Instance.new("TextLabel")
    toggleBindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    toggleBindLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleBindLabel.Text = "Toggle AutoDive:"
    toggleBindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBindLabel.BackgroundTransparency = 1
    toggleBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleBindLabel.Parent = toggleBindFrame
    
    local toggleBindButton = Instance.new("TextButton")
    toggleBindButton.Name = "BindButton"
    toggleBindButton.Size = UDim2.new(0.35, 0, 0.8, 0)
    toggleBindButton.Position = UDim2.new(0.65, 0, 0.1, 0)
    toggleBindButton.Text = "V"
    toggleBindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBindButton.Parent = toggleBindFrame
    
    -- Бинд для показа/скрытия UI
    local uiBindFrame = Instance.new("Frame")
    uiBindFrame.Size = UDim2.new(1, 0, 0, 40)
    uiBindFrame.Position = UDim2.new(0, 0, 0, 50)
    uiBindFrame.BackgroundTransparency = 1
    uiBindFrame.Parent = BindsFrame
    
    local uiBindLabel = Instance.new("TextLabel")
    uiBindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    uiBindLabel.Position = UDim2.new(0, 0, 0, 0)
    uiBindLabel.Text = "Toggle UI:"
    uiBindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiBindLabel.BackgroundTransparency = 1
    uiBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    uiBindLabel.Parent = uiBindFrame
    
    local uiBindButton = Instance.new("TextButton")
    uiBindButton.Name = "BindButton"
    uiBindButton.Size = UDim2.new(0.35, 0, 0.8, 0)
    uiBindButton.Position = UDim2.new(0.65, 0, 0.1, 0)
    uiBindButton.Text = "F1"
    uiBindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    uiBindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiBindButton.Parent = uiBindFrame
    
    -- Сохраняем кнопки биндов для дальнейшего использования
    BindToggles["AutoDive"] = toggleBindButton
    BindToggles["ToggleUI"] = uiBindButton
    
    -- Текст инструкции
    local instructionLabel = Instance.new("TextLabel")
    instructionLabel.Size = UDim2.new(1, 0, 0, 40)
    instructionLabel.Position = UDim2.new(0, 0, 0, 100)
    instructionLabel.Text = "Click on bind button and press any key to rebind"
    instructionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    instructionLabel.TextSize = 12
    instructionLabel.TextWrapped = true
    instructionLabel.BackgroundTransparency = 1
    instructionLabel.Parent = BindsFrame
end

-- Создаем элементы биндов
createBindElements()

-- Таблица для хранения текущих биндов
local CurrentBinds = {
    AutoDive = Enum.KeyCode.V,
    ToggleUI = Enum.KeyCode.F1
}

-- Функция для получения имени клавиши
local function getKeyName(keyCode)
    local name = tostring(keyCode)
    return name:gsub("Enum.KeyCode.", "")
end

-- Функция для обновления текста кнопок биндов
local function updateBindButtons()
    for bindName, button in pairs(BindToggles) do
        if CurrentBinds[bindName] then
            button.Text = getKeyName(CurrentBinds[bindName])
        end
    end
end

-- Обновляем кнопки при старте
updateBindButtons()

-- Переменная для отслеживания изменения бинда
local rebinding = nil

-- Функция для обработки изменения биндов
local function handleBindChange(input, gameProcessed)
    if not rebinding or gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- Сохраняем новый бинд
        CurrentBinds[rebinding] = input.KeyCode
        
        -- Обновляем текст кнопки
        if BindToggles[rebinding] then
            BindToggles[rebinding].Text = getKeyName(input.KeyCode)
        end
        
        -- Сбрасываем состояние
        rebinding = nil
    end
end

-- Подключаем обработчик ввода
UserInputService.InputBegan:Connect(handleBindChange)

-- Функция для настройки обработчиков кнопок биндов
local function setupBindButtons()
    for bindName, button in pairs(BindToggles) do
        button.MouseButton1Click:Connect(function()
            rebinding = bindName
            button.Text = "..."
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            
            -- Таймер для сброса, если ничего не выбрано
            delay(3, function()
                if rebinding == bindName then
                    rebinding = nil
                    button.Text = getKeyName(CurrentBinds[bindName])
                    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end
            end)
        end)
    end
end

-- Настраиваем кнопки биндов
setupBindButtons()

-- Функция переключения вкладок
local function switchToTab(tabName)
    if tabName == "Main" then
        MainTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        BindsTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        MainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        BindsTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        -- Показываем элементы Main
        ToggleButton.Visible = true
        PanicButton.Visible = true
        SliderContainer.Visible = true
        
        -- Скрываем Binds
        BindsFrame.Visible = false
    elseif tabName == "Binds" then
        BindsTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        MainTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        BindsTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MainTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        -- Скрываем элементы Main
        ToggleButton.Visible = false
        PanicButton.Visible = false
        SliderContainer.Visible = false
        
        -- Показываем Binds
        BindsFrame.Visible = true
    end
end

-- Обработчики кликов по вкладкам
MainTabButton.MouseButton1Click:Connect(function()
    switchToTab("Main")
end)

BindsTabButton.MouseButton1Click:Connect(function()
    switchToTab("Binds")
end)

-- Инициализация - показываем Main по умолчанию
switchToTab("Main")

-- Настройки слайдера задержки
local minValue = 1    -- мин 1ms
local maxValue = 1000  -- макс 1000ms (1 секунда)
local isDragging = false
local currentDiveDelay = 0.001 -- начальное значение (в секундах)

-- Функция обновления значения задержки
local function updateValue(newValue)
    -- Ограничиваем значение и обновляем интерфейс
    newValue = math.clamp(newValue, minValue, maxValue)
    currentDiveDelay = newValue / 1000 -- Конвертируем в секунды
    
    local percent = (newValue - minValue) / (maxValue - minValue)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderButton.Position = UDim2.new(percent, -12, 0.5, -12)
    SliderLabel.Text = string.format("Dive Delay: %dms", math.floor(newValue))
    
    TextBox.Text = tostring(math.floor(newValue))
end

-- Обработчики слайдера
TextBox.FocusLost:Connect(function(enterPressed)
    local text = TextBox.Text
    local number = tonumber(text)
    
    if number then
        updateValue(number)
    else
        TextBox.Text = tostring(math.floor(currentDiveDelay * 1000))
    end
end)

SliderButton.MouseButton1Down:Connect(function()
    isDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sliderPos = SliderTrack.AbsolutePosition.X
        local sliderSize = SliderTrack.AbsoluteSize.X
        local mousePos = input.Position.X
        
        local relativePos = mousePos - sliderPos
        local percent = math.clamp(relativePos / sliderSize, 0, 1)
        local newValue = minValue + (maxValue - minValue) * percent
        
        updateValue(newValue)
    end
end)

-- Инициализация слайдера
updateValue(minValue)

-- Таблица для хранения оригинальных состояний клавиш
local originalKeyStates = {
    [Enum.KeyCode.W] = false,
    [Enum.KeyCode.A] = false,
    [Enum.KeyCode.S] = false,
    [Enum.KeyCode.D] = false,
    [Enum.KeyCode.LeftControl] = false
}

-- Таблица соответствия углов и клавиш
local directionKeys = {
    [0] = {Enum.KeyCode.W},
    [45] = {Enum.KeyCode.W, Enum.KeyCode.D},
    [90] = {Enum.KeyCode.D},
    [135] = {Enum.KeyCode.S, Enum.KeyCode.D},
    [180] = {Enum.KeyCode.S},
    [225] = {Enum.KeyCode.S, Enum.KeyCode.A},
    [270] = {Enum.KeyCode.A},
    [315] = {Enum.KeyCode.W, Enum.KeyCode.A}
}

-- Переменные для управления
local autoDiveEnabled = false
local lastDiveTime = 0
local lastRecTime = 0
local DIVE_COOLDOWN = 1
local REC_COOLDOWN = 0.5
local DIVE_RADIUS = 15
local REC_RADIUS = 9
local MIN_RUN_SPEED = 45  -- Минимальная скорость для режима "бег к мячу"
local MAX_RUN_SPEED = 70  -- Максимальная скорость для режима "бег к мячу"
local DIVE_SPEED = 70     -- Скорость, при которой включается обычное поведение (дайвы и приемы)
local scriptActive = true
local isReceiving = false
local lastDirection = nil
local shouldMove = false
local inputBlocked = false
local originalInputEnabled = true
local reachedBall = false
local isDiving = false

-- Определяем все зоны
local ZONES = {
    {
        position = Vector3.new(0, 0.5, 0),
        size = Vector3.new(54, 0.2, 101)
    },
    {
        position = Vector3.new(-100, 0.5, 0),
        size = Vector3.new(54, 0.2, 101)
    },
    {
        position = Vector3.new(100, 0.5, 0),
        size = Vector3.new(54, 0.2, 101)
    }
}

-- Функция для проверки пересечения зоны с точкой падения мяча
local function isInZone(landingPosition)
    for _, zone in ipairs(ZONES) do
        local zoneMin = zone.position - zone.size/2 - Vector3.new(TOLERATE, TOLERATE, TOLERATE)
        local zoneMax = zone.position + zone.size/2 + Vector3.new(TOLERATE, TOLERATE, TOLERATE)
        
        if landingPosition.X >= zoneMin.X and landingPosition.X <= zoneMax.X and
           landingPosition.Y >= zoneMin.Y and landingPosition.Y <= zoneMax.Y and
           landingPosition.Z >= zoneMin.Z and landingPosition.Z <= zoneMax.Z then
            return true, zone
        end
    end
    return false, nil
end

-- Функция для определения, в какой части корта находится игрок
local function getPlayerCourtSide(playerPosition, zone)
    if not zone then return 0 end
    
    local court1Min = zone.position - Vector3.new(zone.size.X/2, 0, zone.size.Z)
    local court1Max = zone.position + Vector3.new(zone.size.X/2, 0, 0)
    
    local court2Min = zone.position - Vector3.new(zone.size.X/2, 0, 0)
    local court2Max = zone.position + Vector3.new(zone.size.X/2, 0, zone.size.Z)
    
    if playerPosition.X >= court1Min.X and playerPosition.X <= court1Max.X and
       playerPosition.Z >= court1Min.Z and playerPosition.Z <= court1Max.Z then
        return 1 -- Левая часть корта
    elseif playerPosition.X >= court2Min.X and playerPosition.X <= court2Max.X and
           playerPosition.Z >= court2Min.Z and playerPosition.Z <= court2Max.Z then
        return 2 -- Правая часть корта
    else
        return 0 -- Вне корта
    end
end

-- Функция для блокировки пользовательского ввода
local function blockUserInput()
    if inputBlocked then return end
    inputBlocked = true
    
    for key, _ in pairs(originalKeyStates) do
        originalKeyStates[key] = UserInputService:IsKeyDown(key)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
    end
end

-- Функция для восстановления пользовательского ввода
local function restoreUserInput()
    if not inputBlocked then return end
    inputBlocked = false
    
    for key, state in pairs(originalKeyStates) do
        if state then
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.S, false, game)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, game)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, game)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
        end
    end
end

-- Создаём лучи направлений (невидимые)
local function createDirectionRays()
    local raysFolder = Instance.new("Folder")
    raysFolder.Name = "DirectionRays"
    raysFolder.Parent = character
    
    local rays = {}
    for angle = 0, 315, 45 do
        local rayPart = Instance.new("Part")
        rayPart.Size = Vector3.new(0.2, 0.2, 10)
        rayPart.Anchored = true
        rayPart.CanCollide = false
        rayPart.Transparency = 1
        rayPart.Name = "Ray_"..angle
        rayPart.Parent = raysFolder
        rays[angle] = rayPart
    end
    
    return raysFolder, rays
end

-- Обновляем позиции лучей
local function updateDirectionRays(rays)
    if not rootPart then return end
    
    for angle, ray in pairs(rays) do
        local rad = math.rad(angle)
        local offset = Vector3.new(math.sin(rad), 0, math.cos(rad)) * 5
        local worldOffset = rootPart.CFrame:VectorToWorldSpace(offset)
        ray.CFrame = CFrame.new(rootPart.Position + worldOffset/2, rootPart.Position + worldOffset)
    end
end

-- Инициализация лучей
local raysFolder, rays = createDirectionRays()

-- Получаем необходимые удалённые события
local PlayerAction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerAction")

-- Функция для получения скорости мяча
local function GetBallSpeed(ballModel)
    if ballModel:FindFirstChild("Velocity") then
        return ballModel.Velocity.Value.Magnitude
    end
    return 0
end

local function PHYSICS_STUFF(velocity, position)
    local acceleration = -workspace.Gravity
    local timeToLand = (-velocity.y - math.sqrt(velocity.y * velocity.y - 4 * 0.5 * acceleration * position.y)) / (2 * 0.5 * acceleration)
    
    local horizontalVelocity = Vector3.new(velocity.x, 0, velocity.z)
    local landingPosition = position + horizontalVelocity * timeToLand + Vector3.new(0, -position.y, 0)
    
    return landingPosition
end

-- Функция для определения направления к мячу
local function getBallDirection(ballPosition, playerPosition, playerCFrame)
    local relativePos = ballPosition - playerPosition
    local lookVector = playerCFrame.LookVector * Vector3.new(1, 0, 1)
    local rightVector = playerCFrame.RightVector * Vector3.new(1, 0, 1)
    
    local forwardDot = lookVector:Dot(relativePos.Unit)
    local rightDot = rightVector:Dot(relativePos.Unit)
    
    local angle = math.deg(math.atan2(rightDot, forwardDot))
    if angle < 0 then angle = angle + 360 end
    
    local roundedAngle = math.floor((angle + 22.5) / 45) * 45
    if roundedAngle >= 360 then roundedAngle = 0 end
    
    return roundedAngle
end

-- Функция для нажатия клавиш направления
local function pressDirectionKeys(angle)
    if lastDirection then
        for _, key in ipairs(directionKeys[lastDirection]) do
            game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
        end
    end
    
    if angle and directionKeys[angle] then
        for _, key in ipairs(directionKeys[angle]) do
            game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
        end
    end
    
    lastDirection = angle
end

-- Функция для остановки движения
local function stopMovement()
    if lastDirection then
        for _, key in ipairs(directionKeys[lastDirection]) do
            game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
        end
        lastDirection = nil
    end
    shouldMove = false
    reachedBall = true
end

-- Функция для получения клавиши дайва из настроек управления
local function GetDiveKey()
    -- Получаем локального игрока
    local player = game:GetService("Players").LocalPlayer
    if not player then return Enum.KeyCode.LeftControl end -- значение по умолчанию
    
    -- Проверяем PlayerGui
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return Enum.KeyCode.LeftControl end
    
    -- Ищем HUD
    local hud = playerGui:FindFirstChild("HUD")
    if not hud then return Enum.KeyCode.LeftControl end
    
    -- Ищем MainFrame
    local mainFrame = hud:FindFirstChild("MainFrame")
    if not mainFrame then return Enum.KeyCode.LeftControl end
    
    -- Ищем MenuDisplay
    local menuDisplay = mainFrame:FindFirstChild("MenuDisplay")
    if not menuDisplay then return Enum.KeyCode.LeftControl end
    
    -- Ищем Keybinds
    local keybinds = menuDisplay:FindFirstChild("Keybinds")
    if not keybinds then return Enum.KeyCode.LeftControl end
    
    -- Ищем KeybindsFrame
    local keybindsFrame = keybinds:FindFirstChild("KeybindsFrame")
    if not keybindsFrame then return Enum.KeyCode.LeftControl end
    
    -- Ищем Keyboard
    local keyboard = keybindsFrame:FindFirstChild("Keyboard")
    if not keyboard then return Enum.KeyCode.LeftControl end
    
    -- Ищем Dive
    local dive = keyboard:FindFirstChild("Dive")
    if not dive then return Enum.KeyCode.LeftControl end
    
    -- Ищем BindSelect
    local bindSelect = dive:FindFirstChild("BindSelect")
    if not bindSelect or not bindSelect:IsA("TextButton") then return Enum.KeyCode.LeftControl end
    
    -- Получаем текст кнопки и преобразуем в KeyCode
    local keyText = bindSelect.Text
    return Enum.KeyCode[keyText] or Enum.KeyCode.LeftControl
end

-- Получаем клавишу дайва при старте
local diveKey = GetDiveKey()

-- Функция для выполнения дайва с управлением WASD
local function performDiveWithMovement(angle)
    local currentTime = tick()
    if currentTime - lastDiveTime >= DIVE_COOLDOWN and not isDiving then
        isDiving = true
        blockUserInput()
        pressDirectionKeys(angle)
        task.wait(currentDiveDelay) -- Используем установленную задержку
        
        -- Используем полученную клавишу дайва
        game:GetService("VirtualInputManager"):SendKeyEvent(true, diveKey, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, diveKey, false, game)
        
        stopMovement()
        restoreUserInput()
        lastDiveTime = currentTime
        
        task.wait(2.5)
        isDiving = false
    end
end

local Recced = false

local function REC()
    Recced = not Recced
    while Recced and task.wait(0.1) do
        VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, false)
        task.wait(0.01)
        VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, false)
        Recced = not Recced
    end
end

local function moveToMarker(targetPosition)
    if not character or not rootPart then return end
    
    -- Получаем хитбокс приема игрока
    local recHitbox = workspace:FindFirstChild(PLAYER.Name) and workspace[PLAYER.Name]:FindFirstChild("RecHitbox")
    if not recHitbox then return end
    
    -- Вычисляем расстояние до цели
    local distance = (targetPosition - rootPart.Position).Magnitude
    
    -- Получаем параметры хитбокса
    local hitboxSize = recHitbox.Size
    local hitboxRadius = math.max(hitboxSize.X, hitboxSize.Y, hitboxSize.Z) / 2
    local hitboxPosition = recHitbox.CFrame.Position
    
    -- Проверяем, находится ли цель в радиусе хитбокса (с небольшой погрешностью)
    local distanceToHitbox = (targetPosition - hitboxPosition).Magnitude
    local inRecRange = distanceToHitbox <= (hitboxRadius) -- +2 как погрешность
    
    -- Если мяч в зоне приема - останавливаемся
    if inRecRange then
        if lastDirection then
            for _, key in ipairs(directionKeys[lastDirection]) do
                VirtualInput:SendKeyEvent(false, key, false, game)
            end
            lastDirection = nil
        end
        return
    end
    
    -- Вычисляем направление к цели
    local relativePos = targetPosition - rootPart.Position
    local lookVector = rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
    local rightVector = rootPart.CFrame.RightVector * Vector3.new(1, 0, 1)
    
    local forwardDot = lookVector:Dot(relativePos.Unit)
    local rightDot = rightVector:Dot(relativePos.Unit)
    
    local angle = math.deg(math.atan2(rightDot, forwardDot))
    if angle < 0 then angle = angle + 360 end
    
    local roundedAngle = math.floor((angle + 22.5) / 45) * 45
    if roundedAngle >= 360 then roundedAngle = 0 end
    
    -- Если направление не изменилось - ничего не делаем
    if lastDirection == roundedAngle then
        return
    end
    
    -- Отпускаем предыдущие клавиши
    if lastDirection then
        for _, key in ipairs(directionKeys[lastDirection]) do
            VirtualInput:SendKeyEvent(false, key, false, game)
        end
    end
    
    -- Нажимаем новые клавиши
    if directionKeys[roundedAngle] then
        for _, key in ipairs(directionKeys[roundedAngle]) do
            VirtualInput:SendKeyEvent(true, key, false, game)
        end
    end
    
    lastDirection = roundedAngle
end

-- Обработчики UI
ToggleButton.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    autoDiveEnabled = not autoDiveEnabled
    if autoDiveEnabled then
        ToggleButton.Text = "AutoDive: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "AutoDive: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        stopMovement()
        restoreUserInput()
    end
end)

PanicButton.MouseButton1Click:Connect(function()
    scriptActive = false
    stopMovement()
    restoreUserInput()
    ScreenGui:Destroy()
    Marker:Destroy()
    if raysFolder then raysFolder:Destroy() end
end)

-- Обработчик горячих клавиш (с использованием биндов)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not scriptActive or gameProcessed then return end
    
    -- Проверяем бинд для переключения AutoDive
    if input.KeyCode == CurrentBinds.AutoDive then
        autoDiveEnabled = not autoDiveEnabled
        if autoDiveEnabled then
            ToggleButton.Text = "AutoDive: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            ToggleButton.Text = "AutoDive: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            stopMovement()
            restoreUserInput()
        end
    end
    
    -- Проверяем бинд для показа/скрытия UI
    if input.KeyCode == CurrentBinds.ToggleUI then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Модифицируем основной цикл
RunService.RenderStepped:Connect(function()
    if not scriptActive or not autoDiveEnabled or isDiving then 
        if shouldMove then
            stopMovement()
            restoreUserInput()
            shouldMove = false
        end
        return 
    end
    
    if not character or not rootPart then return end
    
    updateDirectionRays(rays)
    
    local foundBall = false
    
    for _, ballModel in ipairs(workspace:GetChildren()) do
        if ballModel:IsA("Model") and ballModel.Name == "Ball" then
            local ball = ballModel:FindFirstChild("BallPart")
            if ball and ballModel:FindFirstChild("Velocity") then
                foundBall = true
                local initialVelocity = ballModel.Velocity.Value
                local landingPosition = PHYSICS_STUFF(initialVelocity, ball.Position)
                Marker.CFrame = CFrame.new(landingPosition)
                
                local ballSpeed = GetBallSpeed(ballModel)
                local playerPosition = rootPart.Position
                local distance = (landingPosition - playerPosition).Magnitude
                
                -- Определяем направление к мячу
                local angle = getBallDirection(landingPosition, playerPosition, rootPart.CFrame)
                
                -- Проверяем, находится ли точка падения в какой-либо зоне
                local inZone, currentZone = isInZone(landingPosition)
                if inZone then
                    local playerCourt = getPlayerCourtSide(playerPosition, currentZone)
                    local ballCourt = getPlayerCourtSide(landingPosition, currentZone)
                    
                    -- Если мяч приземляется прямо за игроком (180 градусов)
                    if angle == 180 and distance <= DIVE_RADIUS then
                        -- Если мяч за спиной и близко - бежим назад (S)
                        if not inputBlocked then
                            blockUserInput()
                            -- Отпускаем все предыдущие клавиши
                            if lastDirection then
                                for _, key in ipairs(directionKeys[lastDirection]) do
                                    VirtualInput:SendKeyEvent(false, key, false, game)
                                end
                            end
                            -- Нажимаем S
                            VirtualInput:SendKeyEvent(true, Enum.KeyCode.S, false, game)
                            lastDirection = 180 -- Устанавливаем текущее направление
                            REC()
                            shouldMove = true
                            reachedBall = false
                        end
                        
                        -- Если мяч в зоне приема - выполняем прием
                        if distance <= REC_RADIUS then
                            VirtualInput:SendKeyEvent(false, Enum.KeyCode.S, false, game)
                            REC()
                            shouldMove = false
                            reachedBall = true
                            task.wait(2)
                            restoreUserInput()
                        end
                    -- Для всех других направлений - стандартное поведение
                    elseif ballSpeed > DIVE_SPEED and playerCourt == ballCourt then
                        if distance <= DIVE_RADIUS and distance > REC_RADIUS and not isDiving then
                            performDiveWithMovement(angle)
                        elseif distance <= REC_RADIUS and not isDiving then
                            if not reachedBall then
                                moveToMarker(landingPosition, ballSpeed)
                                REC()
                            end
                        else
                            if shouldMove then
                                stopMovement()
                                task.wait(2)
                                restoreUserInput()
                            end
                        end
                    elseif ballSpeed >= MIN_RUN_SPEED and ballSpeed <= MAX_RUN_SPEED and playerCourt == ballCourt and distance <= DIVE_RADIUS then
                        if not reachedBall then
                            moveToMarker(landingPosition, ballSpeed)
                            REC()
                        end
                    else
                        if shouldMove then
                            stopMovement()
                            task.wait(2)
                            restoreUserInput()
                        end
                    end
                else
                    if shouldMove then
                        stopMovement()
                        task.wait(2)
                        restoreUserInput()
                    end
                end
            end
        end
    end
    
    if not foundBall and shouldMove then
        stopMovement()
        restoreUserInput()
    end
    
    if foundBall then
        local ballModel = workspace:FindFirstChild("Ball")
        if ballModel then
            local ball = ballModel:FindFirstChild("BallPart")
            if ball and ballModel:FindFirstChild("Velocity") then
                local initialVelocity = ballModel.Velocity.Value
                local landingPosition = PHYSICS_STUFF(initialVelocity, ball.Position)
                local distance = (landingPosition - rootPart.Position).Magnitude
                
                if distance > REC_RADIUS then
                    reachedBall = false
                end
            end
        end
    end
end)

-- Обработчик смены персонажа
PLAYER.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if raysFolder then raysFolder:Destroy() end
    raysFolder, rays = createDirectionRays()
    
    stopMovement()
    restoreUserInput()
    reachedBall = false
end)
