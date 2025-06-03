-- Ждём, пока мяч появится в игре
repeat wait() until workspace:FindFirstChild("Ball")

-- Получаем сервисы
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Получаем LocalPlayer
local PLAYER = Players.LocalPlayer
local CC = workspace.CurrentCamera

-- Ожидаем появления персонажа
local character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

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
MainFrame.Size = UDim2.new(0, 200, 0, 200) -- Увеличиваем размер для слайдера
MainFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleButton.Text = "AutoDive: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Parent = MainFrame

local PanicButton = Instance.new("TextButton")
PanicButton.Size = UDim2.new(0, 180, 0, 40)
PanicButton.Position = UDim2.new(0.05, 0, 0.3, 0)
PanicButton.Text = "PANIC BUTTON"
PanicButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
PanicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PanicButton.Parent = MainFrame

-- Добавляем слайдер для Dive Delay (теперь он не зависит от перемещения MainFrame)
local DelaySlider = Instance.new("Frame")
DelaySlider.Name = "DelaySlider"
DelaySlider.Size = UDim2.new(0, 180, 0, 50)
DelaySlider.Position = UDim2.new(0.05, 0, 0.55, 0)
DelaySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DelaySlider.BorderSizePixel = 0
DelaySlider.Parent = MainFrame

local DelayText = Instance.new("TextLabel")
DelayText.Name = "DelayText"
DelayText.Size = UDim2.new(1, 0, 0.4, 0)
DelayText.Position = UDim2.new(0, 0, 0, 0)
DelayText.Text = "Dive Delay: 100ms"
DelayText.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayText.BackgroundTransparency = 1
DelayText.Parent = DelaySlider

local SliderTrack = Instance.new("Frame")
SliderTrack.Name = "SliderTrack"
SliderTrack.Size = UDim2.new(0.9, 0, 0.2, 0)
SliderTrack.Position = UDim2.new(0.05, 0, 0.6, 0)
SliderTrack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = DelaySlider

local SliderThumb = Instance.new("Frame")
SliderThumb.Name = "SliderThumb"
SliderThumb.Size = UDim2.new(0, 10, 1.5, 0)
SliderThumb.Position = UDim2.new(0.1, -5, 0.25, 0) -- Начальное положение (100ms)
SliderThumb.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
SliderThumb.BorderSizePixel = 0
SliderThumb.ZIndex = 2 -- Чтобы ползунок был поверх трека
SliderThumb.Parent = SliderTrack

-- ============= ВСТАВЛЯЕМ ИСПРАВЛЕННЫЙ КОД СЛАЙДЕРА ЗДЕСЬ =============
-- Обработчик слайдера
local sliding = false
local sliderOffset = 0

-- Функция для обновления положения ползунка
local function updateSliderPosition()
    local percentage = currentDiveDelay -- 0.0 до 1.0
    SliderThumb.Position = UDim2.new(percentage, -5, 0.25, 0)
end

-- Функция для обновления текста задержки
local function updateDelayText()
    DelayText.Text = string.format("Dive Delay: %dms", math.floor(currentDiveDelay * 1000))
end

-- Обработка перемещения ползунка
local function handleSliderInput()
    if sliding then
        local mouseX = UserInputService:GetMouseLocation().X
        local trackAbsolutePos = SliderTrack.AbsolutePosition.X
        local trackAbsoluteSize = SliderTrack.AbsoluteSize.X
        
        -- Вычисляем относительное положение (0-1)
        local relativePos = math.clamp((mouseX - trackAbsolutePos - sliderOffset) / trackAbsoluteSize, 0, 1)
        
        -- Обновляем задержку
        currentDiveDelay = relativePos
        updateDelayText()
        updateSliderPosition()
    end
end

-- Обработчики событий слайдера
SliderThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = true
        -- Запоминаем смещение курсора относительно центра ползунка
        local thumbAbsolutePos = SliderThumb.AbsolutePosition.X + SliderThumb.AbsoluteSize.X/2
        sliderOffset = thumbAbsolutePos - SliderTrack.AbsolutePosition.X
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = false
    end
end)

-- Добавляем обработку ввода для всего трека
SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = true
        sliderOffset = 0 -- При клике на треке смещение не нужно
        handleSliderInput() -- Немедленно обновляем позицию
    end
end)

-- Инициализация слайдера
currentDiveDelay = 0.1 -- Начальное значение (100ms)
updateDelayText()
updateSliderPosition()
-- ============= КОНЕЦ ВСТАВКИ ИСПРАВЛЕННОГО КОДА =============

-- Переменные для управления
local autoDiveEnabled = false
local lastDiveTime = 0
local lastRecTime = 0
local DIVE_COOLDOWN = 1
local REC_COOLDOWN = 0.5
local DIVE_RADIUS = 15
local REC_RADIUS = 8
local TARGET_BALL_SPEED = 43
local scriptActive = true
local isReceiving = false
local lastDirection = nil
local shouldMove = false
local inputBlocked = false
local originalInputEnabled = true
local reachedBall = false

-- Функция для обновления текста задержки
local function updateDelayText()
    DelayText.Text = string.format("Dive Delay: %dms", currentDiveDelay * 1000)
end

-- Обработчик слайдера
local sliding = false
local sliderOffset = 0

-- Функция для обновления положения ползунка
local function updateSliderPosition()
    local percentage = currentDiveDelay -- 0.0 до 1.0
    SliderThumb.Position = UDim2.new(percentage, -5, 0.25, 0)
end

SliderThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = true
        -- Запоминаем смещение курсора относительно центра ползунка
        local sliderAbsolutePos = SliderThumb.AbsolutePosition.X + SliderThumb.AbsoluteSize.X/2
        sliderOffset = UserInputService:GetMouseLocation().X - sliderAbsolutePos
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = false
    end
end)

-- Обработка перемещения ползунка
local function handleSliderInput()
    if sliding then
        local mouseX = UserInputService:GetMouseLocation().X - sliderOffset
        local trackAbsolutePos = SliderTrack.AbsolutePosition.X
        local trackAbsoluteSize = SliderTrack.AbsoluteSize.X
        
        -- Вычисляем относительное положение (0-1)
        local relativePos = math.clamp((mouseX - trackAbsolutePos) / trackAbsoluteSize, 0, 1)
        
        -- Обновляем задержку
        currentDiveDelay = relativePos
        updateDelayText()
        updateSliderPosition()
    end
end


-- Таблица для хранения оригинальных состояний клавиш
local originalKeyStates = {
    [Enum.KeyCode.W] = false,
    [Enum.KeyCode.A] = false,
    [Enum.KeyCode.S] = false,
    [Enum.KeyCode.D] = false,
    [Enum.KeyCode.LeftControl] = false
}

-- Таблица соответствия углов и клавиш (относительно взгляда игрока)
local directionKeys = {
    [0] = {Enum.KeyCode.W},       -- Вперёд
    [45] = {Enum.KeyCode.W, Enum.KeyCode.D},  -- Вперёд-вправо
    [90] = {Enum.KeyCode.D},      -- Вправо
    [135] = {Enum.KeyCode.S, Enum.KeyCode.D}, -- Назад-вправо
    [180] = {Enum.KeyCode.S},     -- Назад
    [225] = {Enum.KeyCode.S, Enum.KeyCode.A}, -- Назад-влево
    [270] = {Enum.KeyCode.A},     -- Влево
    [315] = {Enum.KeyCode.W, Enum.KeyCode.A}  -- Вперёд-влево
}

-- Функция для блокировки пользовательского ввода
local function blockUserInput()
    if inputBlocked then return end
    inputBlocked = true
    
    -- Сохраняем текущие состояния клавиш
    for key, _ in pairs(originalKeyStates) do
        originalKeyStates[key] = UserInputService:IsKeyDown(key)
    end
    
    -- Отпускаем все клавиши
    for key, _ in pairs(originalKeyStates) do
        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
    end
end

-- Функция для восстановления пользовательского ввода
local function restoreUserInput()
    if not inputBlocked then return end
    inputBlocked = false
    
    -- Восстанавливаем оригинальные состояния клавиш
    for key, state in pairs(originalKeyStates) do
        if state then
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
        rayPart.Transparency = 1 -- Полностью невидимые
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

-- Функция для расчёта позиции падения мяча
local function PHYSICS_STUFF(velocity, position)
    local acceleration = -workspace.Gravity
    local timeToLand = (-velocity.y - math.sqrt(velocity.y * velocity.y - 4 * 0.5 * acceleration * position.y)) / (2 * 0.5 * acceleration)
    local horizontalVelocity = Vector3.new(velocity.x, 0, velocity.z)
    local landingPosition = position + horizontalVelocity * timeToLand + Vector3.new(0, -position.y, 0)
    return landingPosition
end

-- Функция для определения направления к мячу (относительно взгляда игрока)
local function getBallDirection(ballPosition, playerPosition, playerCFrame)
    local relativePos = ballPosition - playerPosition
    local lookVector = playerCFrame.LookVector * Vector3.new(1, 0, 1)
    local rightVector = playerCFrame.RightVector * Vector3.new(1, 0, 1)
    
    local forwardDot = lookVector:Dot(relativePos.Unit)
    local rightDot = rightVector:Dot(relativePos.Unit)
    
    local angle = math.deg(math.atan2(rightDot, forwardDot))
    if angle < 0 then angle = angle + 360 end
    
    -- Округляем до ближайших 45 градусов
    local roundedAngle = math.floor((angle + 22.5) / 45) * 45
    if roundedAngle >= 360 then roundedAngle = 0 end
    
    return roundedAngle
end

-- Функция для нажатия клавиш направления
local function pressDirectionKeys(angle)
    -- Отпускаем предыдущие клавиши
    if lastDirection then
        for _, key in ipairs(directionKeys[lastDirection]) do
            game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
        end
    end
    
    -- Нажимаем новые клавиши
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

-- Функция для выполнения дайва с управлением WASD
local function performDiveWithMovement(angle)
    local currentTime = tick()
    if currentTime - lastDiveTime >= DIVE_COOLDOWN then
        -- Блокируем пользовательский ввод
        blockUserInput()
        
        -- Нажимаем клавиши направления
        pressDirectionKeys(angle)
        
        -- Ждем перед дайвом (используем установленную задержку)
        task.wait(currentDiveDelay)
        
        -- Выполняем дайв
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        
        -- Отпускаем клавиши после дайва
        stopMovement()
        
        -- Восстанавливаем пользовательский ввод
        restoreUserInput()
        
        lastDiveTime = currentTime
    end
end

-- Функция для выполнения приёма мяча (просто клик ЛКМ)
local function performReceive()
    local currentTime = tick()
    if currentTime - lastRecTime >= REC_COOLDOWN and not isReceiving then
        isReceiving = true
        
        -- Блокируем пользовательский ввод
        blockUserInput()
        
        -- Эмулируем клик левой кнопкой мыши
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LButton, false, game)
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LButton, false, game)
        
        -- Отправляем серверу команду на приём
        PlayerAction:FireServer("Receiving")
        
        -- Восстанавливаем пользовательский ввод
        restoreUserInput()
        
        -- Задержка перед следующим возможным приёмом
        task.wait(0.2)
        isReceiving = false
        lastRecTime = tick()
        reachedBall = true
    end
end

-- Функция для перемещения к маркеру через WASD
local function moveToMarker(targetPosition)
    if not character or not rootPart then return end
    
    -- Проверяем дистанцию
    local distance = (targetPosition - rootPart.Position).Magnitude
    
    if distance < 3 then
        -- Если достаточно близко - принимаем мяч
        stopMovement()
        performReceive()
    else
        -- Если еще не достигли цели, продолжаем движение
        shouldMove = true
        reachedBall = false
        
        -- Блокируем пользовательский ввод
        blockUserInput()
        
        -- Определяем направление относительно взгляда игрока
        local angle = getBallDirection(targetPosition, rootPart.Position, rootPart.CFrame)
        
        -- Нажимаем соответствующие клавиши движения
        pressDirectionKeys(angle)
    end
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
        -- При выключении останавливаем движение и восстанавливаем ввод
        stopMovement()
        restoreUserInput()
    end
end)

PanicButton.MouseButton1Click:Connect(function()
    scriptActive = false
    -- Останавливаем движение перед уничтожением и восстанавливаем ввод
    stopMovement()
    restoreUserInput()
    ScreenGui:Destroy()
    Marker:Destroy()
    if raysFolder then raysFolder:Destroy() end
end)

-- Обработчик горячих клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not scriptActive then return end
    
    if input.KeyCode == Enum.KeyCode.V and not gameProcessed then
        autoDiveEnabled = not autoDiveEnabled
        if autoDiveEnabled then
            ToggleButton.Text = "AutoDive: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            ToggleButton.Text = "AutoDive: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            -- При выключении останавливаем движение и восстанавливаем ввод
            stopMovement()
            restoreUserInput()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F1 and not gameProcessed then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- В основном цикле убедитесь, что вызываете handleSliderInput()
RunService.RenderStepped:Connect(function()
    -- Обрабатываем ввод слайдера
    handleSliderInput()
    
     if not scriptActive or not autoDiveEnabled then 
        if shouldMove then
            stopMovement()
            restoreUserInput()
            shouldMove = false
        end
        return 
    end
    
    if not character or not rootPart then return end
    
    -- Обновляем лучи направлений
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
                
                if ballSpeed > TARGET_BALL_SPEED then
                    if distance <= DIVE_RADIUS and distance > REC_RADIUS then
                        -- Если мяч в радиусе дайва
                        local angle = getBallDirection(landingPosition, playerPosition, rootPart.CFrame)
                        performDiveWithMovement(angle)
                    elseif distance <= REC_RADIUS then
                        -- Если мяч в радиусе приема
                        if not reachedBall then
                            moveToMarker(landingPosition)
                        end
                    else
                        -- Если мяч далеко, останавливаем движение
                        if shouldMove then
                            stopMovement()
                            restoreUserInput()
                        end
                    end
                else
                    -- Если мяч медленный, останавливаем движение
                    if shouldMove then
                        stopMovement()
                        restoreUserInput()
                    end
                end
            end
        end
    end
    
    -- Если мяча нет, останавливаем движение
    if not foundBall and shouldMove then
        stopMovement()
        restoreUserInput()
    end
    
    -- Сбрасываем флаг reachedBall, если мяч снова ушел из радиуса приема
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
    
    -- Пересоздаем лучи для нового персонажа
    if raysFolder then raysFolder:Destroy() end
    raysFolder, rays = createDirectionRays()
    
    -- Останавливаем движение при смене персонажа и восстанавливаем ввод
    stopMovement()
    restoreUserInput()
    reachedBall = false
end)

-- Инициализация текста задержки и положения слайдера
updateDelayText()
updateSliderPosition()
