loadstring([[
    local player = game.Players.LocalPlayer
    if not player then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AttackButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0, 20, 0, 180)
    btn.Text = "⚔️攻击"
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.BorderSizePixel = 0
    btn.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    local event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Attacks") and game:GetService("ReplicatedStorage").Remotes.Attacks:FindFirstChild("BasicAttack")
    btn.MouseButton1Click:Connect(function()
        if event then
            event:FireServer()
        else
            warn("BasicAttack 事件未找到")
        end
    end)
    local function drag(gui)
        local dragging, startPos, dragStart
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
            end
        end)
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        gui.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    drag(btn)
    print("✅ 攻击按钮已加载，点击触发 BasicAttack")
]])()
