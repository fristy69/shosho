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
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleButton.Text = "AutoDive: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Parent = MainFrame

local PanicButton = Instance.new("TextButton")
PanicButton.Size = UDim2.new(0, 200, 0, 40)
PanicButton.Position = UDim2.new(0.05, 0, 0.25, 0)
PanicButton.Text = "PANIC BUTTON"
PanicButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
PanicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PanicButton.Parent = MainFrame

-- слайдер
local SliderContainer = Instance.new("Frame")
SliderContainer.Size = UDim2.new(0.9, 0, 0, 60)
SliderContainer.Position = UDim2.new(0.05, 0, 0.5, 0)
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


local minValue = 1    -- мин 1ms
local maxValue = 1000  -- макс 1000ms (1 секунда)
local isDragging = false
currentDiveDelay = 0.001 -- начальное значение


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
local REC_RADIUS = 8
local TARGET_BALL_SPEED = 43
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
        size = Vector3.new(48, 0.2, 95)
    },
    {
        position = Vector3.new(-100, 0.5, 0),
        size = Vector3.new(48, 0.2, 95)
    },
    {
        position = Vector3.new(100, 0.5, 0),
        size = Vector3.new(48, 0.2, 95)
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

-- Функция для расчёта позиции падения мяча с погрешностью
local function PHYSICS_STUFF(velocity, position)
    local acceleration = -workspace.Gravity
    local timeToLand = (-velocity.y - math.sqrt(velocity.y * velocity.y - 4 * 0.5 * acceleration * position.y)) / (2 * 0.5 * acceleration)
    timeToLand = timeToLand + (TOLERATE * 0.01) -- Добавляем погрешность к времени
    
    local horizontalVelocity = Vector3.new(velocity.x, 0, velocity.z)
    local landingPosition = position + horizontalVelocity * timeToLand + Vector3.new(0, -position.y, 0)
    
    -- Добавляем случайную погрешность к позиции
    landingPosition = landingPosition + Vector3.new(
        (math.random() * 2 - 1) * TOLERATE,
        (math.random() * 2 - 1) * TOLERATE,
        (math.random() * 2 - 1) * TOLERATE
    )
    
    return landingPosition
end

-- Функция для определения направления к мячу с погрешностью
local function getBallDirection(ballPosition, playerPosition, playerCFrame)
    local relativePos = ballPosition - playerPosition
    local lookVector = playerCFrame.LookVector * Vector3.new(1, 0, 1)
    local rightVector = playerCFrame.RightVector * Vector3.new(1, 0, 1)
    
    local forwardDot = lookVector:Dot(relativePos.Unit)
    local rightDot = rightVector:Dot(relativePos.Unit)
    
    local angle = math.deg(math.atan2(rightDot, forwardDot))
    if angle < 0 then angle = angle + 360 end
    
    -- Добавляем погрешность к углу
    angle = angle + (math.random() * 2 - 1) * TOLERATE
    
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

-- Функция для выполнения дайва с управлением WASD
-- Модифицируем функцию performDiveWithMovement
local function performDiveWithMovement(angle)
    local currentTime = tick()
    if currentTime - lastDiveTime >= DIVE_COOLDOWN and not isDiving then
        isDiving = true
        blockUserInput()
        pressDirectionKeys(angle)
        task.wait(currentDiveDelay)
        
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        
        stopMovement()
        restoreUserInput()
        lastDiveTime = currentTime
        
        -- Добавляем небольшую задержку после дайва перед возобновлением проверок
        task.wait(2.5)
        isDiving = false
    end
end

-- Функция для выполнения приёма мяча
local function performReceive()
    local currentTime = tick()
    if currentTime - lastRecTime >= REC_COOLDOWN and not isReceiving then
        isReceiving = true
        blockUserInput()
        
        task.wait(0.2)
        isReceiving = false
        lastRecTime = tick()
        reachedBall = true
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

    local distance = (targetPosition - rootPart.Position).Magnitude

    if distance < 2 then -- Добавляем погрешность к расстоянию
        stopMovement()
    else
        shouldMove = true
        reachedBall = false
        blockUserInput()

        local angle = getBallDirection(targetPosition, rootPart.Position, rootPart.CFrame)
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
            stopMovement()
            restoreUserInput()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F1 and not gameProcessed then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
-- Модифицированный основной цикл
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
                
                -- Проверяем, находится ли точка падения в какой-либо зоне
                local inZone, currentZone = isInZone(landingPosition)
                if inZone then
                    local playerCourt = getPlayerCourtSide(playerPosition, currentZone)
                    local ballCourt = getPlayerCourtSide(landingPosition, currentZone)
                    
                    if ballSpeed > TARGET_BALL_SPEED and playerCourt == ballCourt then
                        if distance <= DIVE_RADIUS and distance > REC_RADIUS and not isDiving then
                            local angle = getBallDirection(landingPosition, playerPosition, rootPart.CFrame)
                            performDiveWithMovement(angle)
                        elseif distance <= REC_RADIUS and not isDiving then
                            if not reachedBall then
                                moveToMarker(landingPosition)
                                REC()
                            end
                        else
                            if shouldMove then
                                stopMovement()
                                restoreUserInput()
                            end
                        end
                    else
                        if shouldMove then
                            stopMovement()
                            restoreUserInput()
                        end
                    end
                else
                    if shouldMove then
                        stopMovement()
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
