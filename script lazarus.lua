local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- TECLAS CONFIGURABLES
local HideMenuKey = Enum.KeyCode.M
local AimAssistKey = Enum.KeyCode.E -- Cambiado a 'E' por defecto

-- ESTADOS
local MenuVisible = true
local AimAssistEnabled = false
local ESPEnabled = false
local ShowFOVEnabled = true -- Variable para controlar la visibilidad del círculo FOV
local AimAssistStrength = 0.25
local MaxDistance = 70
local AimPartName = "Head"
local RightMouseDown = false
local AimAssistKeyDown = false

-- CONFIGURACIÓN DE DISEÑO
local GRID = {
    MARGIN = 15,        -- Margen general
    SPACING = 10,       -- Espacio entre elementos
    ROW_HEIGHT = 30,    -- Altura de cada fila
    COLUMN_WIDTH = 160  -- Ancho de columnas
}

-- GUI MODERNA Y MINIMALISTA MEJORADA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 380, 0, 50)
Frame.Position = UDim2.new(0.5, 0, 0, 40)
Frame.AnchorPoint = Vector2.new(0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.BackgroundTransparency = 0.08
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = Frame

-- Flecha desplegable
local Arrow = Instance.new("TextButton")
Arrow.Size = UDim2.new(0, 32, 0, 32)
Arrow.Position = UDim2.new(1, -38, 0, 9)
Arrow.BackgroundTransparency = 1
Arrow.Text = "▼"
Arrow.TextColor3 = Color3.fromRGB(200, 200, 210)
Arrow.Font = Enum.Font.GothamBold
Arrow.TextSize = 20
Arrow.Parent = Frame

-- Título (área para arrastrar)
local Title = Instance.new("TextButton")
Title.Size = UDim2.new(1, -50, 0, 32)
Title.Position = UDim2.new(0, 15, 0, 9)
Title.BackgroundTransparency = 1
Title.Text = "PKRL MENU - PROJECT LAZARUS v1.0"
Title.TextColor3 = Color3.fromRGB(200, 200, 210)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextWrapped = true
Title.ClipsDescendants = true
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- Contenedor del contenido desplegable
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -GRID.MARGIN*2, 0, 180)
Content.Position = UDim2.new(0, GRID.MARGIN, 0, 50)
Content.BackgroundTransparency = 1
Content.Visible = false
Content.Parent = Frame

-- Layout automático para los elementos
local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, GRID.SPACING)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- Variables para el movimiento del menú
local dragging = false
local dragInput, dragStart, startPos

-- Función para limitar la posición dentro de la pantalla
local function clampPosition(position, frameSize)
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return Vector2.new(
        math.clamp(position.X, frameSize.X/2, viewportSize.X - frameSize.X/2),
        math.clamp(position.Y, frameSize.Y/2, viewportSize.Y - frameSize.Y/2)
    )
end

-- Conexión de eventos para mover el menú
local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function onInputChanged(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end

Title.InputBegan:Connect(onInputBegan)
Title.InputChanged:Connect(onInputChanged)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )

        -- Convertir UDim2 a píxeles para el clamping
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local frameSize = Frame.AbsoluteSize
        local anchor = Frame.AnchorPoint

        -- Calcular la posición del centro superior (por AnchorPoint 0.5, 0)
        local absolutePosition = Vector2.new(
            newPosition.X.Offset + (newPosition.X.Scale * viewportSize.X),
            newPosition.Y.Offset + (newPosition.Y.Scale * viewportSize.Y)
        )

        -- Aplicar límites de pantalla considerando el AnchorPoint original (0.5, 0)
        local clampedX = math.clamp(
            absolutePosition.X,
            frameSize.X * anchor.X,
            viewportSize.X - frameSize.X * (1 - anchor.X)
        )
        local clampedY = math.clamp(
            absolutePosition.Y,
            0,
            viewportSize.Y - frameSize.Y
        )

        Frame.Position = UDim2.new(
            0, clampedX,
            0, clampedY
        )
        Frame.AnchorPoint = Vector2.new(0.5, 0)
    end
end)

-- Función para crear un switch tipo interruptor mejorado
local function createSwitch(parent, labelText, defaultState)
    local SwitchContainer = Instance.new("Frame")
    SwitchContainer.Size = UDim2.new(1, 0, 0, GRID.ROW_HEIGHT)
    SwitchContainer.BackgroundTransparency = 1
    SwitchContainer.LayoutOrder = #parent:GetChildren()
    SwitchContainer.Parent = parent

    local SwitchFrame = Instance.new("Frame")
    SwitchFrame.Size = UDim2.new(0, 54, 0, 26)
    SwitchFrame.Position = UDim2.new(0, 0, 0.5, -13)
    -- Cambia el color a verde si está ON, rojo si está OFF
    SwitchFrame.BackgroundColor3 = defaultState and Color3.fromRGB(45, 180, 45) or Color3.fromRGB(180, 45, 45)
    SwitchFrame.Parent = SwitchContainer

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchFrame

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 24, 0, 24)
    Knob.Position = defaultState and UDim2.new(1, -25, 0, 1) or UDim2.new(0, 1, 0, 1)
    Knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    Knob.Parent = SwitchFrame

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 200, 0, 26)
    Label.Position = UDim2.new(0, 60, 0.5, -13)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. (defaultState and ": ON" or ": OFF")
    Label.TextColor3 = Color3.fromRGB(220, 255, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SwitchContainer

    return SwitchFrame, Knob, Label
end

-- Función para crear botones de tecla
local function createKeyButton(parent, text, keyName)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, GRID.ROW_HEIGHT)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    button.TextColor3 = Color3.fromRGB(180, 180, 200)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Text = text .. keyName.Name
    button.AutoButtonColor = true
    button.LayoutOrder = #parent:GetChildren()
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    return button
end

-- Creación de elementos de la GUI
local AimSwitch, AimKnob, AimLabel = createSwitch(Content, "AimAssist", false)
local ShowFOVSwitch, ShowFOVKnob, ShowFOVLabel = createSwitch(Content, "Mostrar POV", true)
local ESPSwitch, ESPKnob, ESPLabel = createSwitch(Content, "ESP", false)

local AimKeyButton = createKeyButton(Content, "Tecla activar/desactivar AimAssist: ", AimAssistKey)
local KeyBindButton = createKeyButton(Content, "Tecla ocultar menú: ", HideMenuKey)

-- NOTIFICACIÓN
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 250, 0, 30)
Notification.Position = UDim2.new(0, 30, 1, -45)
Notification.BackgroundTransparency = 0.2
Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Notification.TextColor3 = Color3.fromRGB(220, 255, 220)
Notification.Font = Enum.Font.Gotham
Notification.TextSize = 15
Notification.Text = ""
Notification.Visible = false
Notification.Parent = ScreenGui

local NotificationCorner = Instance.new("UICorner")
NotificationCorner.CornerRadius = UDim.new(0, 8)
NotificationCorner.Parent = Notification

local BipSound = Instance.new("Sound")
BipSound.SoundId = "rbxassetid://9118828567" -- Un BIP simple de Roblox
BipSound.Volume = 1
BipSound.Parent = ScreenGui

local function ShowNotification(text)
    Notification.Text = text
    Notification.Visible = true
    -- Reproducir sonido BIP
    BipSound:Play()
    task.spawn(function()
        wait(2.5)
        Notification.Visible = false
    end)
end

-- Lógica para desplegar/ocultar con animación suave
local desplegado = false

local function actualizarMenu()
    local rowCount = #Content:GetChildren() - 1 -- Restamos 1 por el UIListLayout
    local targetHeight = desplegado and (50 + (rowCount * (GRID.ROW_HEIGHT + GRID.SPACING)) + GRID.MARGIN*2) or 50
    local targetSize = desplegado and UDim2.new(0, 380, 0, targetHeight) or UDim2.new(0, 380, 0, 50)
    
    -- Guardar la posición actual antes de cambiar el tamaño
    local currentPosition = Frame.Position
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(Frame, tweenInfo, {Size = targetSize})
    tween:Play()
    
    -- Asegurarse de que la posición no cambie durante el redimensionamiento
    Frame.Position = currentPosition
    
    Content.Visible = desplegado
    Arrow.Text = desplegado and "▲" or "▼"
end

Arrow.MouseButton1Click:Connect(function()
    desplegado = not desplegado
    actualizarMenu()
end)

Title.MouseButton1Click:Connect(function()
    -- Solo alternar el menú si no estamos arrastrando
    if not dragging then
        desplegado = not desplegado
        actualizarMenu()
    end
end)

-- SWITCH LÓGICA Y ANIMACIÓN SUAVE
local function animateSwitch(knob, on)
    local goal = on and UDim2.new(1, -25, 0, 1) or UDim2.new(0, 1, 0, 1)
    local tween = TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal})
    tween:Play()
end

local function updateSwitch(switch, knob, label, state, labelText)
    -- Verde si ON, rojo si OFF
    switch.BackgroundColor3 = state and Color3.fromRGB(45, 180, 45) or Color3.fromRGB(180, 45, 45)
    animateSwitch(knob, state)
    label.Text = labelText .. (state and ": ON" or ": OFF")
end

AimSwitch.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        AimAssistEnabled = not AimAssistEnabled
        updateSwitch(AimSwitch, AimKnob, AimLabel, AimAssistEnabled, "AimAssist")
        ShowNotification(AimAssistEnabled and "AIMBOT ACTIVADO ✅" or "AIMBOT DESACTIVADO ❌")
    end
end)

ShowFOVSwitch.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ShowFOVEnabled = not ShowFOVEnabled
        updateSwitch(ShowFOVSwitch, ShowFOVKnob, ShowFOVLabel, ShowFOVEnabled, "Mostrar POV")
        ShowNotification(ShowFOVEnabled and "MOSTRAR POV ACTIVADO ✅" or "MOSTRAR POV DESACTIVADO ❌")
    end
end)

ESPSwitch.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ESPEnabled = not ESPEnabled
        updateSwitch(ESPSwitch, ESPKnob, ESPLabel, ESPEnabled, "ESP")
        ShowNotification(ESPEnabled and "ESP ACTIVADO ✅" or "ESP DESACTIVADO ❌")
    end
end)

-- Switch para Tracer
local TracerSwitch, TracerKnob, TracerLabel = createSwitch(Content, "Tracer", false)
local TracerEnabled = false

TracerSwitch.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TracerEnabled = not TracerEnabled
        updateSwitch(TracerSwitch, TracerKnob, TracerLabel, TracerEnabled, "Tracer")
        ShowNotification(TracerEnabled and "TRACER ACTIVADO ✅" or "TRACER DESACTIVADO ❌")
    end
end)

-- ELIMINAR MENU: destruye todo y restaura valores por defecto
local connections = {}

-- Guarda todas las conexiones para desconectarlas luego
local function safeConnect(signal, func)
    local conn = signal:Connect(func)
    table.insert(connections, conn)
    return conn
end

-- Guarda valores originales para restaurar
local originalWalkSpeed = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16
local originalFOV = 70
local originalMenuVisible = true

-- Función para restaurar todo
local function restoreDefaults()
    -- Restaurar velocidad
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = originalWalkSpeed
    end
    -- Restaurar FOV
    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = originalFOV
    end
    -- Restaurar menú visible
    Frame.Visible = originalMenuVisible
    -- Desactivar ESP
    ESPEnabled = false
    ClearESP()
    -- Desactivar AimAssist
    AimAssistEnabled = false
    -- Desactivar Tracer
    TracerEnabled = false
    -- Desactivar MysteryBox ESP
    MysteryBoxESPEnabled = false
    clearMysteryHighlight()
    -- Restaurar contador de zombies
    if ZombieCounter then
        ZombieCounter.Text = "Zombies: 0"
        ZombieCounter.Visible = false
    end    -- Restaurar switches visuales
    updateSwitch(AimSwitch, AimKnob, AimLabel, false, "AimAssist")
    updateSwitch(ShowFOVSwitch, ShowFOVKnob, ShowFOVLabel, true, "Mostrar POV")
    updateSwitch(ESPSwitch, ESPKnob, ESPLabel, false, "ESP")
    updateSwitch(TracerSwitch, TracerKnob, TracerLabel, false, "Tracer")
    updateSwitch(MysteryBoxSwitch, MysteryBoxKnob, MysteryBoxLabel, false, "MysteryBox ESP")
    -- Limpiar líneas de Tracer
    if TracerLines then
        for _, line in ipairs(TracerLines) do
            if typeof(line) == "table" and line.Remove then
                line:Remove()
            elseif typeof(line) == "Instance" then
                line:Destroy()
            end
        end
        TracerLines = {}
    end
    -- Ocultar círculo FOV
    if FOVCircle then
        if Drawing and Drawing.new and typeof(FOVCircle) == "table" and FOVCircle.Remove then
            FOVCircle.Visible = false
        elseif typeof(FOVCircle) == "Instance" then
            FOVCircle.Visible = false
        end
    end
end

-- Cambiar tecla de AimAssist (solo cambia la tecla)
AimKeyButton.MouseButton1Click:Connect(function()
    AimKeyButton.Text = "Presiona una tecla..."
    local conn
    conn = UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
            AimAssistKey = input.KeyCode
            AimKeyButton.Text = "Tecla activar/desactivar AimAssist: " .. AimAssistKey.Name
            conn:Disconnect()
        end
    end)
end)

-- Cambiar tecla de ocultar menú
KeyBindButton.MouseButton1Click:Connect(function()
    KeyBindButton.Text = "Presiona una tecla..."
    local conn
    conn = UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
            HideMenuKey = input.KeyCode
            KeyBindButton.Text = "Tecla ocultar menú: " .. HideMenuKey.Name
            conn:Disconnect()
        end
    end)
end)

actualizarMenu()

-- Mostrar/Ocultar menú
UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == HideMenuKey and not processed then
        MenuVisible = not MenuVisible
        Frame.Visible = MenuVisible
    end
end)

-- Detectar click derecho y tecla de AimAssist
UIS.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = true
    end
    -- Ya no alterna el switch, solo guarda el estado de la tecla
    if input.KeyCode == AimAssistKey then
        AimAssistKeyDown = true
    end
end)

UIS.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = false
    end
    if input.KeyCode == AimAssistKey then
        AimAssistKeyDown = false
    end
end)

-- NUEVO: Variable FOV y configuración
local FOV = 120 -- Valor inicial
local FOV_MIN = 40
local FOV_MAX = 300

-- Barra deslizable para FOV
local FOVContainer = Instance.new("Frame")
FOVContainer.Size = UDim2.new(1, 0, 0, GRID.ROW_HEIGHT)
FOVContainer.BackgroundTransparency = 1
FOVContainer.LayoutOrder = 999
FOVContainer.Parent = Content

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0, 80, 1, 0)
FOVLabel.Position = UDim2.new(0, 0, 0, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. tostring(FOV)
FOVLabel.TextColor3 = Color3.fromRGB(220, 255, 220)
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 14
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = FOVContainer

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0, 140, 0, 8)
SliderBar.Position = UDim2.new(0, 90, 0.5, -4)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SliderBar.Parent = FOVContainer

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 16, 0, 16)
SliderKnob.Position = UDim2.new((FOV-FOV_MIN)/(FOV_MAX-FOV_MIN), -8, 0.5, -8)
SliderKnob.BackgroundColor3 = Color3.fromRGB(120, 200, 120)
SliderKnob.Parent = SliderBar

local SliderKnobCorner = Instance.new("UICorner")
SliderKnobCorner.CornerRadius = UDim.new(1, 0)
SliderKnobCorner.Parent = SliderKnob

local draggingFOV = false

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = UIS:GetMouseLocation().X
        local barAbsPos = SliderBar.AbsolutePosition.X
        local barAbsSize = SliderBar.AbsoluteSize.X
        local percent = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
        FOV = math.floor(FOV_MIN + (FOV_MAX - FOV_MIN) * percent)
        SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
        FOVLabel.Text = "FOV: " .. tostring(FOV)
    end
end)

-- Dibujo del círculo FOV
local FOVCircle = Drawing and Drawing.new and Drawing.new("Circle") or nil
if not FOVCircle then
    -- Si Drawing API no está disponible, usar un BillboardGui
    FOVCircle = Instance.new("Frame")
    FOVCircle.Size = UDim2.new(0, FOV*2, 0, FOV*2)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.BorderSizePixel = 0
    FOVCircle.Parent = ScreenGui
    local circle = Instance.new("ImageLabel")
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.Image = "rbxassetid://3570695787" -- círculo blanco
    circle.ImageColor3 = Color3.fromRGB(120, 200, 120)
    circle.ImageTransparency = 0.7
    circle.Parent = FOVCircle
end

-- Encuentra el zombie más cercano con HEAD visible y dentro del FOV
-- MEJORADO: Ahora ignora raycast, detecta a través de paredes/objetos/jugadores, prioriza el más cercano y dentro del FOV
local function FindClosestZombie()
    local closestZombie, closestDist = nil, MaxDistance
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X/2, viewportSize.Y/2)

    for _, zombie in ipairs(workspace.Baddies:GetChildren()) do
        local head = zombie:FindFirstChild(AimPartName)
        local humanoid = zombie:FindFirstChild("Humanoid")

        if head and humanoid and humanoid.Health > 0 then
            local distance = (camera.CFrame.Position - head.Position).Magnitude

            -- Proyección a pantalla
            local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
            local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
            local distToCenter = (screenPos - screenCenter).Magnitude

            -- NO raycast, detecta a través de todo
            if distance < closestDist and distToCenter <= FOV then
                closestZombie = zombie
                closestDist = distance
            end
        end
    end
    return closestZombie
end

-- Suaviza el movimiento hacia la cabeza
local function SmoothAim(targetPos)
    if not targetPos then return end

    local camera = workspace.CurrentCamera
    local targetVector = targetPos - camera.CFrame.Position
    local currentVector = camera.CFrame.LookVector

    local newLook = currentVector:Lerp(targetVector.Unit, AimAssistStrength)
    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + newLook)
end

-- ESP: resalta los zombies con Highlight
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "PKRL_ESP"
ESPFolder.Parent = workspace

local function ClearESP()
    for _, v in ipairs(ESPFolder:GetChildren()) do
        v:Destroy()
    end
end

local function AddESP(zombie)
    if zombie:FindFirstChild("HumanoidRootPart") then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = zombie
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.Parent = ESPFolder
    end
end

-- Bucle para ESP
RunService.RenderStepped:Connect(function()
    ClearESP()
    if ESPEnabled then
        for _, zombie in ipairs(workspace.Baddies:GetChildren()) do
            local humanoid = zombie:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                AddESP(zombie)
            end
        end
    end
end)

-- Bucle para AimAssist (solo si switch está en ON y click derecho está presionado)
RunService.RenderStepped:Connect(function()
    if AimAssistEnabled and RightMouseDown and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local zombie = FindClosestZombie()
        if zombie and zombie:FindFirstChild(AimPartName) then
            SmoothAim(zombie[AimPartName].Position)
        end
    end
end)

-- Bucle para FOV visual
RunService.RenderStepped:Connect(function()
    -- Dibuja el círculo FOV en el centro de la pantalla solo si está habilitado
    if ShowFOVEnabled then
        local camera = workspace.CurrentCamera
        local viewportSize = camera.ViewportSize
        local centerX, centerY = viewportSize.X/2, viewportSize.Y/2

        if Drawing and Drawing.new and typeof(FOVCircle) == "table" and FOVCircle.Radius then
            FOVCircle.Visible = true
            FOVCircle.Position = Vector2.new(centerX, centerY)
            FOVCircle.Radius = FOV
            FOVCircle.Color = Color3.fromRGB(120, 200, 120)
            FOVCircle.Thickness = 2
            FOVCircle.Transparency = 0.7
            FOVCircle.Filled = false
        elseif typeof(FOVCircle) == "Instance" then
            FOVCircle.Visible = true
            FOVCircle.Size = UDim2.new(0, FOV*2, 0, FOV*2)
            FOVCircle.Position = UDim2.new(0, centerX - FOV, 0, centerY - FOV)
        end
    else
        -- Ocultar el círculo FOV cuando está deshabilitado
        if Drawing and Drawing.new and typeof(FOVCircle) == "table" and FOVCircle.Visible then
            FOVCircle.Visible = false
        elseif typeof(FOVCircle) == "Instance" then
            FOVCircle.Visible = false
        end
    end
end)

-- NUEVO: Barra deslizable para velocidad
local DEFAULT_WALKSPEED = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16
local WalkSpeed = DEFAULT_WALKSPEED
local WALKSPEED_MIN = DEFAULT_WALKSPEED
local WALKSPEED_MAX = 100

local SpeedContainer = Instance.new("Frame")
SpeedContainer.Size = UDim2.new(1, 0, 0, GRID.ROW_HEIGHT)
SpeedContainer.BackgroundTransparency = 1
SpeedContainer.LayoutOrder = 998
SpeedContainer.Parent = Content

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 100, 1, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Velocidad: " .. tostring(WalkSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(220, 255, 220)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedContainer

local SpeedSliderBar = Instance.new("Frame")
SpeedSliderBar.Size = UDim2.new(0, 140, 0, 8)
SpeedSliderBar.Position = UDim2.new(0, 110, 0.5, -4)
SpeedSliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SpeedSliderBar.Parent = SpeedContainer

local SpeedSliderBarCorner = Instance.new("UICorner")
SpeedSliderBarCorner.CornerRadius = UDim.new(1, 0)
SpeedSliderBarCorner.Parent = SpeedSliderBar

local SpeedSliderKnob = Instance.new("Frame")
SpeedSliderKnob.Size = UDim2.new(0, 16, 0, 16)
SpeedSliderKnob.Position = UDim2.new((WalkSpeed-WALKSPEED_MIN)/(WALKSPEED_MAX-WALKSPEED_MIN), -8, 0.5, -8)
SpeedSliderKnob.BackgroundColor3 = Color3.fromRGB(120, 200, 120)
SpeedSliderKnob.Parent = SpeedSliderBar

local SpeedSliderKnobCorner = Instance.new("UICorner")
SpeedSliderKnobCorner.CornerRadius = UDim.new(1, 0)
SpeedSliderKnobCorner.Parent = SpeedSliderKnob

local draggingSpeed = false

SpeedSliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if draggingSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = UIS:GetMouseLocation().X
        local barAbsPos = SpeedSliderBar.AbsolutePosition.X
        local barAbsSize = SpeedSliderBar.AbsoluteSize.X
        local percent = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
        WalkSpeed = math.floor(WALKSPEED_MIN + (WALKSPEED_MAX - WALKSPEED_MIN) * percent)
        SpeedSliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
        SpeedLabel.Text = "Velocidad: " .. tostring(WalkSpeed)
    end
end)

-- Bucle para aplicar velocidad al jugador
RunService.RenderStepped:Connect(function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid.WalkSpeed ~= WalkSpeed then
            humanoid.WalkSpeed = WalkSpeed
        end
    end
end)

-- Alternar el switch AimAssist con la tecla configurada
safeConnect(UIS.InputBegan, function(input, processed)
    if input.KeyCode == AimAssistKey and not processed then
        AimAssistEnabled = not AimAssistEnabled
        updateSwitch(AimSwitch, AimKnob, AimLabel, AimAssistEnabled, "AimAssist")
        ShowNotification(AimAssistEnabled and "AIMBOT ACTIVADO ✅" or "AIMBOT DESACTIVADO ❌")
    end
end)

-- TRACER: Dibuja líneas desde el centro de la pantalla a cada zombie
local TracerLines = {}

safeConnect(RunService.RenderStepped, function()
    -- Limpiar líneas anteriores
    for _, line in ipairs(TracerLines) do
        if typeof(line) == "table" and line.Remove then
            line:Remove()
        elseif typeof(line) == "Instance" then
            line:Destroy()
        end
    end
    TracerLines = {}

    if TracerEnabled then
        local camera = workspace.CurrentCamera
        local viewportSize = camera.ViewportSize
        local center = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
        for _, zombie in ipairs(workspace.Baddies:GetChildren()) do
            local head = zombie:FindFirstChild(AimPartName)
            local humanoid = zombie:FindFirstChild("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (camera.CFrame.Position - head.Position).Magnitude
                    local color
                    if dist < 20 then
                        color = Color3.fromRGB(255, 0, 0) -- rojo cerca
                    elseif dist < 40 then
                        color = Color3.fromRGB(255, 255, 0) -- amarillo medio
                    else
                        color = Color3.fromRGB(0, 255, 0) -- verde lejos
                    end
                    -- Drawing API
                    if Drawing and Drawing.new then
                        local line = Drawing.new("Line")
                        line.From = center
                        line.To = Vector2.new(screenPoint.X, screenPoint.Y)
                        line.Color = color
                        line.Thickness = 2
                        line.Transparency = 0.8
                        line.Visible = true
                        table.insert(TracerLines, line)
                    end
                end
            end
        end
    end
end)


-- Contador de zombies vivos (fuente SourceSans)
local ZombieCounter = Instance.new("TextLabel")
ZombieCounter.Size = UDim2.new(0, 180, 0, 26)
ZombieCounter.Position = UDim2.new(0, 30, 1, -80)
ZombieCounter.BackgroundTransparency = 0.2
ZombieCounter.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ZombieCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
ZombieCounter.Font = Enum.Font.SourceSans
ZombieCounter.TextSize = 16
ZombieCounter.Text = "Zombies: 0"
ZombieCounter.Visible = true
ZombieCounter.Parent = ScreenGui

local ZombieCounterCorner = Instance.new("UICorner")
ZombieCounterCorner.CornerRadius = UDim.new(0, 8)
ZombieCounterCorner.Parent = ZombieCounter

RunService.Stepped:Connect(function()
    local count = 0
    for _, z in pairs(workspace.Baddies:GetChildren()) do
        if z:IsA("Model") then
            count = count + 1
        end
    end
    ZombieCounter.Text = "Zombies: " .. count
end)

-- MysteryBox ESP switch (fuente Gotham para el switch, SourceSans para el Highlight)
local MysteryBoxSwitch, MysteryBoxKnob, MysteryBoxLabel = createSwitch(Content, "MysteryBox ESP", false)
local MysteryBoxESPEnabled = false

local mysteryHighlight = nil

local function clearMysteryHighlight()
    if mysteryHighlight then
        mysteryHighlight:Destroy()
        mysteryHighlight = nil
    end
end

local function updateMysteryBoxESP()
    clearMysteryHighlight()
    local interact = workspace:FindFirstChild("Interact")
    if not interact then
        ShowNotification("MysteryBox ESP: Carpeta 'Interact' no encontrada")
        print("MysteryBox ESP Error: Carpeta 'Interact' no encontrada en el workspace.")
        return
    end

    local mysteryBox = interact:FindFirstChild("MysteryBox")
    if not mysteryBox then
        ShowNotification("MysteryBox ESP: Objeto 'MysteryBox' no encontrado")
        print("MysteryBox ESP Error: Objeto 'MysteryBox' no encontrado dentro de 'Interact'.")
        return
    end

    -- Verificar si el objeto es compatible con Highlight
    if not (mysteryBox:IsA("BasePart") or mysteryBox:IsA("Model") or mysteryBox:IsA("Accoutrement") or mysteryBox:IsA("Tool")) then
        ShowNotification("MysteryBox ESP: Objeto no compatible")
        print("MysteryBox ESP Error: El objeto '" .. mysteryBox.Name .. "' de tipo '" .. mysteryBox.ClassName .. "' no es compatible con Highlight.")
        return
    end

    mysteryHighlight = Instance.new("Highlight")
    mysteryHighlight.Adornee = mysteryBox
    mysteryHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop    mysteryHighlight.FillTransparency = 0.6 
    mysteryHighlight.OutlineTransparency = 0.2 
    mysteryHighlight.FillColor = Color3.fromRGB(255, 255, 0)  -- Amarillo brillante
    mysteryHighlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Borde blanco
    mysteryHighlight.Enabled = true
    mysteryHighlight.Parent = game.CoreGui 
    -- La notificación de "ACTIVADO" ya se maneja en el evento del switch
    print("MysteryBox ESP: Highlight configurado para " .. mysteryBox:GetFullName())
end

MysteryBoxSwitch.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MysteryBoxESPEnabled = not MysteryBoxESPEnabled
        updateSwitch(MysteryBoxSwitch, MysteryBoxKnob, MysteryBoxLabel, MysteryBoxESPEnabled, "MysteryBox ESP")
        if MysteryBoxESPEnabled then
            updateMysteryBoxESP()
            ShowNotification("MYSTERYBOX ESP ACTIVADO ✅")
        else
            clearMysteryHighlight()
            ShowNotification("MYSTERYBOX ESP DESACTIVADO ❌")
        end
    end
end)

updateSwitch(MysteryBoxSwitch, MysteryBoxKnob, MysteryBoxLabel, MysteryBoxESPEnabled, "MysteryBox ESP")

createSectionTitle(PlayerContent, "💪 Habilidades")

-- Switch de stamina infinita
-- createSwitch(PlayerContent, "Resistencia Infinita", false, function(enabled)
--     InfiniteStaminaEnabled = enabled
--     ShowNotification(enabled and "RESISTENCIA INFINITA ACTIVADA ✅" or "RESISTENCIA INFINITA DESACTIVADA ❌")
-- end)

-- Switch de no caída
-- createSwitch(PlayerContent, "No Damage por Caída", false, function(enabled)
--     NoFallDamageEnabled = enabled
--     ShowNotification(enabled and "NO FALL DAMAGE ACTIVADO ✅" or "NO FALL DAMAGE DESACTIVADO ❌")
-- end)

-- ================================