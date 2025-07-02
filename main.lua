-- gemlogin tool by TuanHaii

local success, errorMessage = pcall(function()
    
    pcall(function() game:GetService("CoreGui").gemlogin_tool:Destroy() end)
    pcall(function() game:GetService("CoreGui").GemLogin_ErrorLogger:Destroy() end)
    pcall(function() workspace:FindFirstChild("GemLogin_ESP_Container"):Destroy() end)

    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local isNoclipEnabled, isMenuVisible = false, true
    local isTeleporting, targetPlayer, teleportConnection, bodyPosition = false, nil, nil, nil
    local isAutoAttacking, autoAttackTarget, autoAttackConnection, attackBodyPosition = false, nil, nil, nil
    local isAimLockEnabled, aimLockConnection, aimLockTarget = false, nil, nil
    local selectedAimPart = "Head"  -- Mặc định là Head

    local isHighlightEspEnabled, espHighlightConnections = false, { PlayerAdded = nil, PlayerRemoving = nil, CharacterAdded = {} }
    local isLineEspEnabled, isDistanceEspEnabled, isBoxEspEnabled = false, false, false
    local espRenderObjects = {} 
    local espConnections = { Player = {}, Character = {} }
    local espUpdateConnection = nil

    local isPlayerListVisible, isAttackListVisible = false, false

    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "gemlogin_tool"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    
    local ESPContainer = Instance.new("Folder", workspace)
    ESPContainer.Name = "GemLogin_ESP_Container"

    local MainWindow=Instance.new("CanvasGroup",ScreenGui);MainWindow.Name="MainWindow";MainWindow.BackgroundColor3=Color3.fromRGB(28,28,32);MainWindow.Position=UDim2.new(0.5,-160,0.5,-200);MainWindow.Size=UDim2.new(0,320,0,400);Instance.new("UICorner",MainWindow).CornerRadius=UDim.new(0,8);Instance.new("UIStroke",MainWindow).Color=Color3.fromRGB(80,80,90)
    local TitleBar=Instance.new("Frame",MainWindow);TitleBar.Name="TitleBar";TitleBar.BackgroundColor3=Color3.fromRGB(45,45,50);TitleBar.BorderSizePixel=0;TitleBar.Size=UDim2.new(1,0,0,40);Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,8);local TitleLabel=Instance.new("TextLabel",TitleBar);TitleLabel.Name="TitleLabel";TitleLabel.BackgroundTransparency=1;TitleLabel.Position=UDim2.new(0.05,0,0,0);TitleLabel.Size=UDim2.new(0.6,0,1,0);TitleLabel.Font=Enum.Font.GothamSemibold;TitleLabel.Text="gemlogin tool";TitleLabel.TextColor3=Color3.fromRGB(255,255,255);TitleLabel.TextSize=18;TitleLabel.TextXAlignment=Enum.TextXAlignment.Left;local CreatorLabel=Instance.new("TextLabel",TitleBar);CreatorLabel.BackgroundTransparency=1;CreatorLabel.Size=UDim2.new(1,-55,1,0);CreatorLabel.Font=Enum.Font.Gotham;CreatorLabel.Text="by TuanHaii";CreatorLabel.TextColor3=Color3.fromRGB(150,150,150);CreatorLabel.TextSize=12;CreatorLabel.TextXAlignment=Enum.TextXAlignment.Right;local CloseButton=Instance.new("TextButton",TitleBar);CloseButton.Size=UDim2.new(0,30,0,30);CloseButton.Position=UDim2.new(1,-35,0.5,-15);CloseButton.BackgroundTransparency=1;CloseButton.Font=Enum.Font.GothamBold;CloseButton.Text="X";CloseButton.TextColor3=Color3.fromRGB(200,200,200);CloseButton.TextSize=16
    local TabContainer=Instance.new("Frame",MainWindow);TabContainer.Position=UDim2.new(0,0,0,40);TabContainer.Size=UDim2.new(1,0,0,35);TabContainer.BackgroundTransparency=1;TabContainer.BackgroundColor3=Color3.fromRGB(35,35,40);Instance.new("UIListLayout",TabContainer).FillDirection=Enum.FillDirection.Horizontal;Instance.new("UIPadding",TabContainer).PaddingLeft=UDim.new(0,10);local PlayerTabButton=Instance.new("TextButton",TabContainer);PlayerTabButton.Name="PlayerTab";PlayerTabButton.Size=UDim2.new(0,80,1,0);PlayerTabButton.BackgroundColor3=Color3.fromRGB(60,60,70);PlayerTabButton.Text="Player";PlayerTabButton.Font=Enum.Font.GothamSemibold;PlayerTabButton.TextSize=14;PlayerTabButton.TextColor3=Color3.fromRGB(255,255,255);Instance.new("UICorner",PlayerTabButton).CornerRadius=UDim.new(0,5);local ESPTabButton=Instance.new("TextButton",TabContainer);ESPTabButton.Name="ESPTab";ESPTabButton.Size=UDim2.new(0,80,1,0);ESPTabButton.BackgroundColor3=Color3.fromRGB(40,40,45);ESPTabButton.Text="ESP";ESPTabButton.Font=Enum.Font.GothamSemibold;ESPTabButton.TextSize=14;ESPTabButton.TextColor3=Color3.fromRGB(180,180,180);Instance.new("UICorner",ESPTabButton).CornerRadius=UDim.new(0,5)
    local AimTabButton=Instance.new("TextButton",TabContainer);AimTabButton.Name="AimTab";AimTabButton.Size=UDim2.new(0,80,1,0);AimTabButton.BackgroundColor3=Color3.fromRGB(40,40,45);AimTabButton.Text="Aim";AimTabButton.Font=Enum.Font.GothamSemibold;AimTabButton.TextSize=14;AimTabButton.TextColor3=Color3.fromRGB(180,180,180);Instance.new("UICorner",AimTabButton).CornerRadius=UDim.new(0,5)
    local PageContainer=Instance.new("Frame",MainWindow);PageContainer.Position=UDim2.new(0,0,0,75);PageContainer.Size=UDim2.new(1,0,1,-85);PageContainer.BackgroundTransparency=1
    local PlayerPage=Instance.new("ScrollingFrame",PageContainer);PlayerPage.Name="PlayerPage";PlayerPage.Visible=true;PlayerPage.Size=UDim2.new(1,0,1,0);PlayerPage.BackgroundTransparency=1;PlayerPage.BorderSizePixel=0;PlayerPage.ScrollBarImageColor3=Color3.fromRGB(80,80,90);PlayerPage.ScrollBarThickness=5;local P_ListLayout=Instance.new("UIListLayout",PlayerPage);P_ListLayout.Padding=UDim.new(0,10);P_ListLayout.SortOrder=Enum.SortOrder.LayoutOrder;local P_Padding=Instance.new("UIPadding",PlayerPage);P_Padding.PaddingTop=UDim.new(0,5);P_Padding.PaddingBottom=UDim.new(0,15);P_Padding.PaddingLeft=UDim.new(0,15);P_Padding.PaddingRight=UDim.new(0,15)
    local ESPPage=Instance.new("ScrollingFrame",PageContainer);ESPPage.Name="ESPPage";ESPPage.Visible=false;ESPPage.Size=UDim2.new(1,0,1,0);ESPPage.BackgroundTransparency=1;ESPPage.BorderSizePixel=0;ESPPage.ScrollBarImageColor3=Color3.fromRGB(80,80,90);ESPPage.ScrollBarThickness=5;local E_ListLayout=Instance.new("UIListLayout",ESPPage);E_ListLayout.Padding=UDim.new(0,10);E_ListLayout.SortOrder=Enum.SortOrder.LayoutOrder;local E_Padding=Instance.new("UIPadding",ESPPage);E_Padding.PaddingTop=UDim.new(0,5);E_Padding.PaddingBottom=UDim.new(0,15);E_Padding.PaddingLeft=UDim.new(0,15);E_Padding.PaddingRight=UDim.new(0,15)
    local AimPage=Instance.new("ScrollingFrame",PageContainer);AimPage.Name="AimPage";AimPage.Visible=false;AimPage.Size=UDim2.new(1,0,1,0);AimPage.BackgroundTransparency=1;AimPage.BorderSizePixel=0;AimPage.ScrollBarImageColor3=Color3.fromRGB(80,80,90);AimPage.ScrollBarThickness=5;local A_ListLayout=Instance.new("UIListLayout",AimPage);A_ListLayout.Padding=UDim.new(0,10);A_ListLayout.SortOrder=Enum.SortOrder.LayoutOrder;local A_Padding=Instance.new("UIPadding",AimPage);A_Padding.PaddingTop=UDim.new(0,5);A_Padding.PaddingBottom=UDim.new(0,15);A_Padding.PaddingLeft=UDim.new(0,15);A_Padding.PaddingRight=UDim.new(0,15)
    local HighlightESPButtonContainer=Instance.new("TextButton",ESPPage);HighlightESPButtonContainer.LayoutOrder=1;HighlightESPButtonContainer.Name="ESPButtonContainer";HighlightESPButtonContainer.BackgroundColor3=Color3.fromRGB(55,55,60);HighlightESPButtonContainer.Size=UDim2.new(1,0,0,40);HighlightESPButtonContainer.Font=Enum.Font.GothamSemibold;HighlightESPButtonContainer.Text="ESP Players (Fill)";HighlightESPButtonContainer.TextColor3=Color3.fromRGB(225,225,225);HighlightESPButtonContainer.TextSize=15;HighlightESPButtonContainer.TextXAlignment=Enum.TextXAlignment.Left;Instance.new("UIPadding",HighlightESPButtonContainer).PaddingLeft=UDim.new(0,15);Instance.new("UICorner",HighlightESPButtonContainer).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",HighlightESPButtonContainer).Color=Color3.fromRGB(80,80,90);local ESP_ToggleIndicator=Instance.new("Frame",HighlightESPButtonContainer);ESP_ToggleIndicator.BackgroundColor3=Color3.fromRGB(196,70,70);ESP_ToggleIndicator.Position=UDim2.new(1,-55,0.5,-10);ESP_ToggleIndicator.Size=UDim2.new(0,40,0,20);Instance.new("UICorner",ESP_ToggleIndicator).CornerRadius=UDim.new(0,5);local ESP_ToggleCircle=Instance.new("Frame",ESP_ToggleIndicator);ESP_ToggleCircle.BackgroundColor3=Color3.fromRGB(255,255,255);ESP_ToggleCircle.Position=UDim2.new(0,2,0.5,-8);ESP_ToggleCircle.Size=UDim2.new(0,16,0,16);Instance.new("UICorner",ESP_ToggleCircle).CornerRadius=UDim.new(1,0)
    local BoxESPButtonContainer=Instance.new("TextButton",ESPPage);BoxESPButtonContainer.LayoutOrder=2;BoxESPButtonContainer.Name="BoxEspButtonContainer";BoxESPButtonContainer.BackgroundColor3=Color3.fromRGB(55,55,60);BoxESPButtonContainer.Size=UDim2.new(1,0,0,40);BoxESPButtonContainer.Font=Enum.Font.GothamSemibold;BoxESPButtonContainer.Text="Show Box (Corners)";BoxESPButtonContainer.TextColor3=Color3.fromRGB(225,225,225);BoxESPButtonContainer.TextSize=15;BoxESPButtonContainer.TextXAlignment=Enum.TextXAlignment.Left;Instance.new("UIPadding",BoxESPButtonContainer).PaddingLeft=UDim.new(0,15);Instance.new("UICorner",BoxESPButtonContainer).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",BoxESPButtonContainer).Color=Color3.fromRGB(80,80,90);local BoxESP_ToggleIndicator=Instance.new("Frame",BoxESPButtonContainer);BoxESP_ToggleIndicator.BackgroundColor3=Color3.fromRGB(196,70,70);BoxESP_ToggleIndicator.Position=UDim2.new(1,-55,0.5,-10);BoxESP_ToggleIndicator.Size=UDim2.new(0,40,0,20);Instance.new("UICorner",BoxESP_ToggleIndicator).CornerRadius=UDim.new(0,5);local BoxESP_ToggleCircle=Instance.new("Frame",BoxESP_ToggleIndicator);BoxESP_ToggleCircle.BackgroundColor3=Color3.fromRGB(255,255,255);BoxESP_ToggleCircle.Position=UDim2.new(0,2,0.5,-8);BoxESP_ToggleCircle.Size=UDim2.new(0,16,0,16);Instance.new("UICorner",BoxESP_ToggleCircle).CornerRadius=UDim.new(1,0)
    local LineESPButtonContainer=Instance.new("TextButton",ESPPage);LineESPButtonContainer.LayoutOrder=3;LineESPButtonContainer.Name="LineEspButtonContainer";LineESPButtonContainer.BackgroundColor3=Color3.fromRGB(55,55,60);LineESPButtonContainer.Size=UDim2.new(1,0,0,40);LineESPButtonContainer.Font=Enum.Font.GothamSemibold;LineESPButtonContainer.Text="Show Lines";LineESPButtonContainer.TextColor3=Color3.fromRGB(225,225,225);LineESPButtonContainer.TextSize=15;LineESPButtonContainer.TextXAlignment=Enum.TextXAlignment.Left;Instance.new("UIPadding",LineESPButtonContainer).PaddingLeft=UDim.new(0,15);Instance.new("UICorner",LineESPButtonContainer).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",LineESPButtonContainer).Color=Color3.fromRGB(80,80,90);local LineESP_ToggleIndicator=Instance.new("Frame",LineESPButtonContainer);LineESP_ToggleIndicator.BackgroundColor3=Color3.fromRGB(196,70,70);LineESP_ToggleIndicator.Position=UDim2.new(1,-55,0.5,-10);LineESP_ToggleIndicator.Size=UDim2.new(0,40,0,20);Instance.new("UICorner",LineESP_ToggleIndicator).CornerRadius=UDim.new(0,5);local LineESP_ToggleCircle=Instance.new("Frame",LineESP_ToggleIndicator);LineESP_ToggleCircle.BackgroundColor3=Color3.fromRGB(255,255,255);LineESP_ToggleCircle.Position=UDim2.new(0,2,0.5,-8);LineESP_ToggleCircle.Size=UDim2.new(0,16,0,16);Instance.new("UICorner",LineESP_ToggleCircle).CornerRadius=UDim.new(1,0)
    local DistanceESPButtonContainer=Instance.new("TextButton",ESPPage);DistanceESPButtonContainer.LayoutOrder=4;DistanceESPButtonContainer.Name="DistanceEspButtonContainer";DistanceESPButtonContainer.BackgroundColor3=Color3.fromRGB(55,55,60);DistanceESPButtonContainer.Size=UDim2.new(1,0,0,40);DistanceESPButtonContainer.Font=Enum.Font.GothamSemibold;DistanceESPButtonContainer.Text="Show Distance";DistanceESPButtonContainer.TextColor3=Color3.fromRGB(225,225,225);DistanceESPButtonContainer.TextSize=15;DistanceESPButtonContainer.TextXAlignment=Enum.TextXAlignment.Left;Instance.new("UIPadding",DistanceESPButtonContainer).PaddingLeft=UDim.new(0,15);Instance.new("UICorner",DistanceESPButtonContainer).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",DistanceESPButtonContainer).Color=Color3.fromRGB(80,80,90);local DistanceESP_ToggleIndicator=Instance.new("Frame",DistanceESPButtonContainer);DistanceESP_ToggleIndicator.BackgroundColor3=Color3.fromRGB(196,70,70);DistanceESP_ToggleIndicator.Position=UDim2.new(1,-55,0.5,-10);DistanceESP_ToggleIndicator.Size=UDim2.new(0,40,0,20);Instance.new("UICorner",DistanceESP_ToggleIndicator).CornerRadius=UDim.new(0,5);local DistanceESP_ToggleCircle=Instance.new("Frame",DistanceESP_ToggleIndicator);DistanceESP_ToggleCircle.BackgroundColor3=Color3.fromRGB(255,255,255);DistanceESP_ToggleCircle.Position=UDim2.new(0,2,0.5,-8);DistanceESP_ToggleCircle.Size=UDim2.new(0,16,0,16);Instance.new("UICorner",DistanceESP_ToggleCircle).CornerRadius=UDim.new(1,0)
    local AimLockButtonContainer=Instance.new("TextButton",AimPage);AimLockButtonContainer.LayoutOrder=1;AimLockButtonContainer.Name="AimLockButtonContainer";AimLockButtonContainer.BackgroundColor3=Color3.fromRGB(55,55,60);AimLockButtonContainer.Size=UDim2.new(1,0,0,40);AimLockButtonContainer.Font=Enum.Font.GothamSemibold;AimLockButtonContainer.Text="AimLock";AimLockButtonContainer.TextColor3=Color3.fromRGB(225,225,225);AimLockButtonContainer.TextSize=15;AimLockButtonContainer.TextXAlignment=Enum.TextXAlignment.Left;Instance.new("UIPadding",AimLockButtonContainer).PaddingLeft=UDim.new(0,15);Instance.new("UICorner",AimLockButtonContainer).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",AimLockButtonContainer).Color=Color3.fromRGB(80,80,90);local AimLockToggleIndicator=Instance.new("Frame",AimLockButtonContainer);AimLockToggleIndicator.BackgroundColor3=Color3.fromRGB(196,70,70);AimLockToggleIndicator.Position=UDim2.new(1,-55,0.5,-10);AimLockToggleIndicator.Size=UDim2.new(0,40,0,20);Instance.new("UICorner",AimLockToggleIndicator).CornerRadius=UDim.new(0,5);local AimLockToggleCircle=Instance.new("Frame",AimLockToggleIndicator);AimLockToggleCircle.BackgroundColor3=Color3.fromRGB(255,255,255);AimLockToggleCircle.Position=UDim2.new(0,2,0.5,-8);AimLockToggleCircle.Size=UDim2.new(0,16,0,16);Instance.new("UICorner",AimLockToggleCircle).CornerRadius=UDim.new(1,0)
    
    -- Tạo radio buttons cho các bộ phận (Head, Torso, Leg)
    local function createAimPartRadio(parent, text, partName, isSelected)
        local radioBtn = Instance.new("TextButton", parent)
        radioBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
        radioBtn.Size = UDim2.new(1,0,0,35)
        radioBtn.Font = Enum.Font.Gotham
        radioBtn.Text = text
        radioBtn.TextColor3 = isSelected and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,180)
        radioBtn.TextSize = 14
        radioBtn.TextXAlignment = Enum.TextXAlignment.Left
        radioBtn.AutoButtonColor = false
        Instance.new("UIPadding", radioBtn).PaddingLeft = UDim.new(0,15)
        Instance.new("UICorner", radioBtn).CornerRadius = UDim.new(0,5)
        
        local radioIndicator = Instance.new("Frame", radioBtn)
        radioIndicator.Name = "RadioIndicator"
        radioIndicator.BackgroundColor3 = isSelected and Color3.fromRGB(70,196,70) or Color3.fromRGB(100,100,100)
        radioIndicator.Position = UDim2.new(1,-35,0.5,-8)
        radioIndicator.Size = UDim2.new(0,16,0,16)
        Instance.new("UICorner", radioIndicator).CornerRadius = UDim.new(1,0)
        
        return radioBtn, radioIndicator
    end
    
    local HeadRadioBtn, HeadRadioIndicator = createAimPartRadio(AimPage, "Head", "Head", true)
    HeadRadioBtn.LayoutOrder = 2
    local TorsoRadioBtn, TorsoRadioIndicator = createAimPartRadio(AimPage, "Torso", "Torso", false)
    TorsoRadioBtn.LayoutOrder = 3
    local LegRadioBtn, LegRadioIndicator = createAimPartRadio(AimPage, "Leg", "Leg", false)
    LegRadioBtn.LayoutOrder = 4
    
    local NoclipButtonContainer=Instance.new("TextButton",PlayerPage);NoclipButtonContainer.LayoutOrder=1;NoclipButtonContainer.BackgroundColor3=Color3.fromRGB(55,55,60);NoclipButtonContainer.Size=UDim2.new(1,0,0,40);NoclipButtonContainer.Font=Enum.Font.GothamSemibold;NoclipButtonContainer.Text="Noclip";NoclipButtonContainer.TextColor3=Color3.fromRGB(225,225,225);NoclipButtonContainer.TextSize=15;NoclipButtonContainer.TextXAlignment=Enum.TextXAlignment.Left;Instance.new("UIPadding",NoclipButtonContainer).PaddingLeft=UDim.new(0,15);Instance.new("UICorner",NoclipButtonContainer).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",NoclipButtonContainer).Color=Color3.fromRGB(80,80,90);local ToggleIndicator=Instance.new("Frame",NoclipButtonContainer);ToggleIndicator.BackgroundColor3=Color3.fromRGB(196,70,70);ToggleIndicator.Position=UDim2.new(1,-55,0.5,-10);ToggleIndicator.Size=UDim2.new(0,40,0,20);Instance.new("UICorner",ToggleIndicator).CornerRadius=UDim.new(0,5);local ToggleCircle=Instance.new("Frame",ToggleIndicator);ToggleCircle.BackgroundColor3=Color3.fromRGB(255,255,255);ToggleCircle.Position=UDim2.new(0,2,0.5,-8);ToggleCircle.Size=UDim2.new(0,16,0,16);Instance.new("UICorner",ToggleCircle).CornerRadius=UDim.new(1,0)
    local TeleportButton=Instance.new("TextButton",PlayerPage);TeleportButton.LayoutOrder=2;TeleportButton.BackgroundColor3=Color3.fromRGB(55,55,60);TeleportButton.Size=UDim2.new(1,0,0,40);TeleportButton.Font=Enum.Font.GothamSemibold;TeleportButton.Text="Teleport to Player   ▼";TeleportButton.TextColor3=Color3.fromRGB(225,225,225);TeleportButton.TextSize=15;Instance.new("UICorner",TeleportButton).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",TeleportButton).Color=Color3.fromRGB(80,80,90)
    local SettingsButton=Instance.new("TextButton",PlayerPage);SettingsButton.LayoutOrder=3;SettingsButton.BackgroundColor3=Color3.fromRGB(55,55,60);SettingsButton.Size=UDim2.new(1,0,0,40);SettingsButton.Font=Enum.Font.GothamSemibold;SettingsButton.Text="Player Settings";SettingsButton.TextColor3=Color3.fromRGB(225,225,225);SettingsButton.TextSize=15;Instance.new("UICorner",SettingsButton).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",SettingsButton).Color=Color3.fromRGB(80,80,90)
    local AutoAttackButton=Instance.new("TextButton",PlayerPage);AutoAttackButton.LayoutOrder=4;AutoAttackButton.BackgroundColor3=Color3.fromRGB(55,55,60);AutoAttackButton.Size=UDim2.new(1,0,0,40);AutoAttackButton.Font=Enum.Font.GothamSemibold;AutoAttackButton.Text="Auto Attack Player   ▼";AutoAttackButton.TextColor3=Color3.fromRGB(225,225,225);AutoAttackButton.TextSize=15;Instance.new("UICorner",AutoAttackButton).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",AutoAttackButton).Color=Color3.fromRGB(80,80,90)
    local PlayerListFrame=Instance.new("ScrollingFrame",PlayerPage);PlayerListFrame.Name="TeleportPlayerList";PlayerListFrame.LayoutOrder=5;PlayerListFrame.Visible=false;PlayerListFrame.BackgroundTransparency=1;PlayerListFrame.Size=UDim2.new(1,0,0,0);Instance.new("UIListLayout",PlayerListFrame).Padding=UDim.new(0,5);Instance.new("UIPadding",PlayerListFrame).PaddingTop=UDim.new(0,10)
    local AutoAttackPlayerListFrame=Instance.new("ScrollingFrame",PlayerPage);AutoAttackPlayerListFrame.Name="AutoAttackPlayerList";AutoAttackPlayerListFrame.LayoutOrder=5;AutoAttackPlayerListFrame.Visible=false;AutoAttackPlayerListFrame.BackgroundTransparency=1;AutoAttackPlayerListFrame.Size=UDim2.new(1,0,0,0);Instance.new("UIListLayout",AutoAttackPlayerListFrame).Padding=UDim.new(0,5);Instance.new("UIPadding",AutoAttackPlayerListFrame).PaddingTop=UDim.new(0,10)
    local ToggleBubble=Instance.new("TextButton",ScreenGui);ToggleBubble.Name="ToggleBubble";ToggleBubble.BackgroundColor3=Color3.fromRGB(28,28,32);ToggleBubble.Position=UDim2.new(0.05,0,0.5,-25);ToggleBubble.Size=UDim2.new(0,50,0,50);ToggleBubble.Font=Enum.Font.SourceSans;ToggleBubble.Text="💀";ToggleBubble.TextColor3=Color3.fromRGB(255,255,255);ToggleBubble.TextSize=30;ToggleBubble.Visible=false;Instance.new("UICorner",ToggleBubble).CornerRadius=UDim.new(1,0);Instance.new("UIStroke",ToggleBubble).Color=Color3.fromRGB(80,80,90)
    local SettingsOverlay=Instance.new("Frame",ScreenGui);SettingsOverlay.Name="SettingsOverlay";SettingsOverlay.Size=UDim2.new(1,0,1,0);SettingsOverlay.BackgroundColor3=Color3.fromRGB(0,0,0);SettingsOverlay.BackgroundTransparency=1;SettingsOverlay.ZIndex=5;SettingsOverlay.Visible=false
    local SettingsPanel=Instance.new("Frame",SettingsOverlay);SettingsPanel.Size=UDim2.new(0,400,0,250);SettingsPanel.Position=UDim2.new(0.5,-200,0.5,-125);SettingsPanel.BackgroundColor3=Color3.fromRGB(35,35,45);Instance.new("UICorner",SettingsPanel).CornerRadius=UDim.new(0,8);Instance.new("UIStroke",SettingsPanel).Color=Color3.fromRGB(80,80,90)
    local SettingsTitle=Instance.new("TextLabel",SettingsPanel);SettingsTitle.Size=UDim2.new(1,0,0,40);SettingsTitle.Font=Enum.Font.GothamBold;SettingsTitle.Text="Player Settings";SettingsTitle.TextColor3=Color3.fromRGB(255,255,255);SettingsTitle.TextSize=18;SettingsTitle.BackgroundTransparency=1
    local SettingsCloseBtn=Instance.new("TextButton",SettingsPanel);SettingsCloseBtn.Size=UDim2.new(0,30,0,30);SettingsCloseBtn.Position=UDim2.new(1,-35,0,5);SettingsCloseBtn.BackgroundTransparency=1;SettingsCloseBtn.Font=Enum.Font.GothamBold;SettingsCloseBtn.Text="X";SettingsCloseBtn.TextColor3=Color3.fromRGB(200,200,200);SettingsCloseBtn.TextSize=16
    local function createSlider(parent,text,yPos,min,max,valueLabel) local Label=Instance.new("TextLabel",parent);Label.Size=UDim2.new(0.5,0,0,20);Label.Position=UDim2.new(0.05,0,0,yPos);Label.BackgroundTransparency=1;Label.Font=Enum.Font.Gotham;Label.TextColor3=Color3.fromRGB(220,220,220);Label.TextSize=15;Label.Text=text;Label.TextXAlignment=Enum.TextXAlignment.Left;local Value=Instance.new("TextLabel",parent);Value.Size=UDim2.new(0.4,0,0,20);Value.Position=UDim2.new(0.55,0,0,yPos);Value.BackgroundTransparency=1;Value.Font=Enum.Font.GothamBold;Value.TextColor3=Color3.fromRGB(255,255,255);Value.TextSize=15;Value.Text=tostring(valueLabel);Value.TextXAlignment=Enum.TextXAlignment.Right;local Track=Instance.new("TextButton",parent);Track.Text="";Track.AutoButtonColor=false;Track.Size=UDim2.new(0.9,0,0,10);Track.Position=UDim2.new(0.05,0,0,yPos+30);Track.BackgroundColor3=Color3.fromRGB(25,25,30);Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0);local Thumb=Instance.new("Frame",Track);Thumb.Size=UDim2.new(0,16,0,16);Thumb.Position=UDim2.new(0,-8,0.5,-8);Thumb.BackgroundColor3=Color3.fromRGB(100,120,255);Instance.new("UICorner",Thumb).CornerRadius=UDim.new(1,0);Thumb.ZIndex=2;return Track,Thumb,Value end
    local SpeedTrack,SpeedThumb,SpeedValue=createSlider(SettingsPanel,"WalkSpeed",50,16,150,16)
    local JumpTrack,JumpThumb,JumpValue=createSlider(SettingsPanel,"JumpPower",120,50,250,50)
    local SaveButton=Instance.new("TextButton",SettingsPanel);SaveButton.Size=UDim2.new(0.9,0,0,40);SaveButton.Position=UDim2.new(0.05,0,1,-50);SaveButton.BackgroundColor3=Color3.fromRGB(80,160,80);SaveButton.Font=Enum.Font.GothamBold;SaveButton.Text="Save Settings";SaveButton.TextColor3=Color3.fromRGB(255,255,255);SaveButton.TextSize=16;Instance.new("UICorner",SaveButton).CornerRadius=UDim.new(0,6)
    
    local function makeDraggable(guiObject) local isDragging; guiObject.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true; local startPos = input.Position; local guiStartPos = guiObject.Parent.Position; local moveConn = UserInputService.InputChanged:Connect(function(inp) if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and isDragging then local delta = inp.Position - startPos; guiObject.Parent.Position = UDim2.new(guiStartPos.X.Scale, guiStartPos.X.Offset + delta.X, guiStartPos.Y.Scale, guiStartPos.Y.Offset + delta.Y) end end); local endConn = UserInputService.InputEnded:Connect(function(inp) if inp == input then isDragging = false; moveConn:Disconnect(); endConn:Disconnect() end end) end end) end; makeDraggable(TitleBar); makeDraggable(ToggleBubble);local function toggleMenuVisibility() isMenuVisible = not isMenuVisible; local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out); if isMenuVisible then ToggleBubble.Visible = false; MainWindow.Visible = true; TweenService:Create(MainWindow, tweenInfo, {GroupTransparency = 0}):Play() else local tween = TweenService:Create(MainWindow, tweenInfo, {GroupTransparency = 1}); tween:Play(); tween.Completed:Wait(); MainWindow.Visible = false; ToggleBubble.Visible = true end end;local activeTabColor, inactiveTabColor = Color3.fromRGB(60, 60, 70), Color3.fromRGB(40, 40, 45); local activeTextColor, inactiveTextColor = Color3.fromRGB(255,255,255), Color3.fromRGB(180,180,180);local function switchTab(tabButton, pageToShow) for _, btn in pairs(TabContainer:GetChildren()) do if btn:IsA("TextButton") then btn.BackgroundColor3 = inactiveTabColor; btn.TextColor3 = inactiveTextColor end end; for _, page in pairs(PageContainer:GetChildren()) do page.Visible = false end; tabButton.BackgroundColor3 = activeTabColor; tabButton.TextColor3 = activeTextColor; pageToShow.Visible = true end

    local function createCornerBox(player)
        local boxModel = Instance.new("Model", ESPContainer)
        boxModel.Name = "Box_" .. player.Name
        local parts = {}
        for i = 1, 12 do
            local line = Instance.new("Part", boxModel)
            line.Name = "Line" .. i
            line.Anchored = true
            line.CanCollide = false
            line.CastShadow = false
            line.TopSurface = Enum.SurfaceType.Smooth
            line.BottomSurface = Enum.SurfaceType.Smooth
            line.Material = Enum.Material.Neon
            line.Color = Color3.fromRGB(255, 255, 255)
            
            local billboardGui = Instance.new("BillboardGui", line)
            billboardGui.Adornee = line
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.fromOffset(0,0)

            table.insert(parts, line)
        end
        return { model = boxModel, parts = parts }
    end
    
    local function updateCornerBox(character, boxData)
        if not character or not boxData then return end
        
        local boxCFrame, boxSize = character:GetBoundingBox()
        local halfSize = boxSize / 2
        
        local corners = {
            boxCFrame * CFrame.new(halfSize.X, halfSize.Y, halfSize.Z),
            boxCFrame * CFrame.new(halfSize.X, halfSize.Y, -halfSize.Z),
            boxCFrame * CFrame.new(halfSize.X, -halfSize.Y, halfSize.Z),
            boxCFrame * CFrame.new(halfSize.X, -halfSize.Y, -halfSize.Z),
            boxCFrame * CFrame.new(-halfSize.X, halfSize.Y, halfSize.Z),
            boxCFrame * CFrame.new(-halfSize.X, halfSize.Y, -halfSize.Z),
            boxCFrame * CFrame.new(-halfSize.X, -halfSize.Y, halfSize.Z),
            boxCFrame * CFrame.new(-halfSize.X, -halfSize.Y, -halfSize.Z)
        }

        local edges = {
            {1,2}, {1,3}, {1,5}, {2,4}, {2,6}, {3,4},
            {3,7}, {4,8}, {5,6}, {5,7}, {6,8}, {7,8}
        }

        for i, edge in ipairs(edges) do
            local p1 = corners[edge[1]].Position
            local p2 = corners[edge[2]].Position
            local part = boxData.parts[i]
            
            local distance = (p1 - p2).Magnitude
            part.Size = Vector3.new(0.1, 0.1, distance)
            part.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -distance / 2)
        end
    end

    local function setupCharacterVisuals(player)
        if not espRenderObjects[player] then return end
        
        pcall(function() espRenderObjects[player].distance:Destroy() end)
        pcall(function() espRenderObjects[player].box.model:Destroy() end)
        espRenderObjects[player].distance = nil
        espRenderObjects[player].box = nil
        
        local character = player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local distanceGui = Instance.new("BillboardGui", rootPart)
        distanceGui.Name = "GemLogin_DistanceESP"
        distanceGui.AlwaysOnTop = true
        distanceGui.Size = UDim2.new(0, 200, 0, 50)
        distanceGui.StudsOffset = Vector3.new(0, 3, 0)
        distanceGui.Enabled = isDistanceEspEnabled

        local textLabel = Instance.new("TextLabel", distanceGui)
        textLabel.Name = "DistanceLabel"
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Font = Enum.Font.GothamSemibold
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextSize = 20
        espRenderObjects[player].distance = distanceGui
        
        espRenderObjects[player].box = createCornerBox(player)
        espRenderObjects[player].box.model.Parent = isBoxEspEnabled and ESPContainer or nil
    end
    
    local function setupPlayerForEsp(player)
        if player == LocalPlayer or espRenderObjects[player] then return end

        local objects = {}
        
        local line = Instance.new("Part", nil)
        line.Name = "ESP_Line_" .. player.Name
        line.Anchored = true; line.CanCollide = false; line.CastShadow = false
        line.Material = Enum.Material.Neon; line.Color = Color3.fromRGB(0, 255, 120)
        line.Size = Vector3.zero
        objects.line = line

        espRenderObjects[player] = objects

        espConnections.Character[player.UserId] = player.CharacterAdded:Connect(function()
            setupCharacterVisuals(player)
        end)
        
        setupCharacterVisuals(player)
    end

    local function cleanupPlayerFromEsp(player)
        if not espRenderObjects[player] then return end
        
        if espConnections.Character[player.UserId] then
            espConnections.Character[player.UserId]:Disconnect()
            espConnections.Character[player.UserId] = nil
        end
        
        pcall(function() espRenderObjects[player].line:Destroy() end)
        pcall(function() espRenderObjects[player].distance:Destroy() end)
        pcall(function() espRenderObjects[player].box.model:Destroy() end)
        
        espRenderObjects[player] = nil
    end

    local function updateEspVisuals()
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if not myRoot then return end
        local myPos = myRoot.Position
    
        for player, objects in pairs(espRenderObjects) do
            if not objects or not player:IsDescendantOf(Players) then
                cleanupPlayerFromEsp(player)
                continue
            end
            
            local targetChar = player.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and targetChar.Humanoid.Health > 0 then
                local targetPos = targetRoot.Position
                local distance = (myPos - targetPos).Magnitude

                if isLineEspEnabled and objects.line then
                    objects.line.Size = Vector3.new(0.1, 0.1, distance)
                    objects.line.CFrame = CFrame.lookAt(myPos, targetPos) * CFrame.new(0, 0, -distance / 2)
                end

                if isDistanceEspEnabled and objects.distance then
                    local textLabel = objects.distance:FindFirstChild("DistanceLabel")
                    if textLabel then
                        textLabel.Text = tostring(math.floor(distance)) .. " M"
                        textLabel.TextSize = math.clamp(1000 / distance, 12, 30)
                    end
                end
                
                if isBoxEspEnabled and objects.box then
                    updateCornerBox(targetChar, objects.box)
                end
            else
                 if isLineEspEnabled and objects.line then objects.line.Size = Vector3.zero end
                 if isBoxEspEnabled and objects.box and objects.box.model.Parent then objects.box.model.Parent = nil end
            end
        end
    end
    
    local function toggleEspLoop(shouldBeActive)
        if shouldBeActive and not espUpdateConnection then
            espUpdateConnection = RunService.Heartbeat:Connect(updateEspVisuals)
        elseif not shouldBeActive and espUpdateConnection then
            espUpdateConnection:Disconnect()
            espUpdateConnection = nil
        end
    end

    function toggleLineEsp(enabled)
        isLineEspEnabled = enabled
        for _, objects in pairs(espRenderObjects) do
            if objects.line then
                objects.line.Parent = enabled and ESPContainer or nil
            end
        end
        toggleEspLoop(isLineEspEnabled or isDistanceEspEnabled or isBoxEspEnabled)
    end
    
    function toggleDistanceEsp(enabled) 
        isDistanceEspEnabled = enabled
        for _, objects in pairs(espRenderObjects) do
            if objects.distance and objects.distance.Parent then
                objects.distance.Enabled = enabled
            end
        end
        toggleEspLoop(isLineEspEnabled or isDistanceEspEnabled or isBoxEspEnabled)
    end
    
    function toggleBoxEsp(enabled)
        isBoxEspEnabled = enabled
        for _, objects in pairs(espRenderObjects) do
            if objects.box and objects.box.model then
                objects.box.model.Parent = enabled and ESPContainer or nil
            end
        end
        toggleEspLoop(isLineEspEnabled or isDistanceEspEnabled or isBoxEspEnabled)
    end
    
    local function createHighlight(character) if not character or character:FindFirstChild("GemLogin_ESPHighlight") then return end; local h = Instance.new("Highlight", character); h.Name = "GemLogin_ESPHighlight"; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.FillColor = Color3.fromRGB(255, 0, 0); h.FillTransparency = 0.5; h.OutlineColor = Color3.fromRGB(255, 255, 255); h.OutlineTransparency = 0 end; local function destroyHighlight(character) if character then local h = character:FindFirstChild("GemLogin_ESPHighlight"); if h then h:Destroy() end end end; local function setupPlayerForHighlight(player) if player == LocalPlayer then return end; if player.Character then createHighlight(player.Character) end; espHighlightConnections.CharacterAdded[player.UserId] = player.CharacterAdded:Connect(createHighlight) end; local function cleanupPlayerFromHighlight(player) if espHighlightConnections.CharacterAdded[player.UserId] then espHighlightConnections.CharacterAdded[player.UserId]:Disconnect(); espHighlightConnections.CharacterAdded[player.UserId] = nil end; if player.Character then destroyHighlight(player.Character) end end; local function enableHighlightESP() if isHighlightEspEnabled then return end; isHighlightEspEnabled = true; for _, p in pairs(Players:GetPlayers()) do setupPlayerForHighlight(p) end; espHighlightConnections.PlayerAdded = Players.PlayerAdded:Connect(setupPlayerForHighlight); espHighlightConnections.PlayerRemoving = Players.PlayerRemoving:Connect(cleanupPlayerFromHighlight) end; local function disableHighlightESP() if not isHighlightEspEnabled then return end; isHighlightEspEnabled = false; if espHighlightConnections.PlayerAdded then espHighlightConnections.PlayerAdded:Disconnect(); espHighlightConnections.PlayerAdded = nil end; if espHighlightConnections.PlayerRemoving then espHighlightConnections.PlayerRemoving:Disconnect(); espHighlightConnections.PlayerRemoving = nil end; for _, p in pairs(Players:GetPlayers()) do cleanupPlayerFromHighlight(p) end end

    local ATTACK_DISTANCE = 2; function stopAutoAttack() if not isAutoAttacking then return end; if autoAttackConnection then autoAttackConnection:Disconnect(); autoAttackConnection = nil end; if attackBodyPosition and attackBodyPosition.Parent then attackBodyPosition:Destroy(); attackBodyPosition = nil end; isAutoAttacking = false; autoAttackTarget = nil; for _, btn in pairs(AutoAttackPlayerListFrame:GetChildren()) do if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) end end end; function startAutoAttack(player) stopAutoAttack(); isAutoAttacking = true; autoAttackTarget = player; autoAttackConnection = RunService.Heartbeat:Connect(function() local myChar = LocalPlayer.Character; local targetChar = autoAttackTarget and autoAttackTarget.Character; local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid"); local targetHumanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid"); if not isAutoAttacking or not targetHumanoid or targetHumanoid.Health <= 0 or not myHumanoid or myHumanoid.Health <= 0 then stopAutoAttack(); return end; local myRoot = myChar:FindFirstChild("HumanoidRootPart"); local targetRoot = targetChar:FindFirstChild("HumanoidRootPart"); if not myRoot or not targetRoot then stopAutoAttack(); return end; if not attackBodyPosition or not attackBodyPosition.Parent then attackBodyPosition = Instance.new("BodyPosition", myRoot); attackBodyPosition.Name = "AutoAttack_BP"; attackBodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge); attackBodyPosition.P = 50000; attackBodyPosition.D = 1250; end; local posBehindTarget = targetRoot.CFrame * CFrame.new(0, 0, ATTACK_DISTANCE); attackBodyPosition.Position = posBehindTarget.Position; myRoot.CFrame = CFrame.lookAt(myRoot.Position, targetRoot.Position); local tool = myChar:FindFirstChildOfClass("Tool"); if tool then task.spawn(function() tool:Activate() end) end end) end; function updateAutoAttackPlayerList() AutoAttackPlayerListFrame:ClearAllChildren(); Instance.new("UIListLayout", AutoAttackPlayerListFrame).Padding = UDim.new(0, 5); Instance.new("UIPadding", AutoAttackPlayerListFrame).PaddingTop = UDim.new(0, 10); for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then local btn = Instance.new("TextButton", AutoAttackPlayerListFrame); btn.Name = player.Name; btn.Size = UDim2.new(1, -20, 0, 35); btn.AnchorPoint = Vector2.new(0.5,0); btn.Position=UDim2.new(0.5,0,0,0); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50); btn.Font = Enum.Font.Gotham; btn.Text = player.DisplayName; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.TextSize = 14; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); btn.MouseButton1Click:Connect(function() if autoAttackTarget == player and isAutoAttacking then stopAutoAttack() else startAutoAttack(player); btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) end end) end end end
    
    -- ================ AIMLOCK FUNCTIONS ================ --
    local function getClosestTarget()
        local camera = workspace.CurrentCamera
        local viewportCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local closestTarget = nil
        local minDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    local targetPart = nil
                    
                    if selectedAimPart == "Head" then
                        targetPart = character:FindFirstChild("Head")
                    elseif selectedAimPart == "Torso" then
                        targetPart = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                    elseif selectedAimPart == "Leg" then
                        targetPart = character:FindFirstChild("Left Leg") or 
                                      character:FindFirstChild("Right Leg") or
                                      character:FindFirstChild("LeftLowerLeg") or 
                                      character:FindFirstChild("RightLowerLeg")
                    end
                    
                    if targetPart then
                        local screenPos, visible = camera:WorldToScreenPoint(targetPart.Position)
                        if visible then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                            if distance < minDistance then
                                minDistance = distance
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
        
        return closestTarget
    end

    local function startAimLock()
        if aimLockConnection then return end
        
        aimLockConnection = RunService.RenderStepped:Connect(function()
            if not isAimLockEnabled then return end
            
            -- Kiểm tra nếu người dùng đang di chuyển camera
            local cameraMoving = UserInputService:GetMouseDelta().Magnitude > 0.1 or
                               UserInputService:IsKeyDown(Enum.KeyCode.Left) or
                               UserInputService:IsKeyDown(Enum.KeyCode.Right) or
                               UserInputService:IsKeyDown(Enum.KeyCode.Up) or
                               UserInputService:IsKeyDown(Enum.KeyCode.Down)
            
            if cameraMoving then
                aimLockTarget = nil
                return
            end
            
            -- Chỉ lock khi không di chuyển camera
            if not aimLockTarget then
                aimLockTarget = getClosestTarget()
            end
            
            if aimLockTarget then
                local camera = workspace.CurrentCamera
                local targetPos = aimLockTarget.Position
                local currentCF = camera.CFrame
                local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
                
                -- Làm mượt chuyển động camera
                camera.CFrame = currentCF:Lerp(targetCF, 0.3)
            end
        end)
    end

    local function stopAimLock()
        if aimLockConnection then
            aimLockConnection:Disconnect()
            aimLockConnection = nil
        end
        aimLockTarget = nil
    end

    local function toggleAimLock()
        isAimLockEnabled = not isAimLockEnabled
        
        if isAimLockEnabled then
            startAimLock()
            local t = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
            TweenService:Create(AimLockToggleIndicator, t, {BackgroundColor3 = Color3.fromRGB(70,196,70)}):Play()
            TweenService:Create(AimLockToggleCircle, t, {Position = UDim2.new(1,-18,0.5,-8)}):Play()
        else
            stopAimLock()
            local t = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
            TweenService:Create(AimLockToggleIndicator, t, {BackgroundColor3 = Color3.fromRGB(196,70,70)}):Play()
            TweenService:Create(AimLockToggleCircle, t, {Position = UDim2.new(0,2,0.5,-8)}):Play()
        end
    end

    local function selectAimPart(partName)
        selectedAimPart = partName
        
        -- Cập nhật giao diện
        local t = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        
        -- Danh sách các radio button
        local radioButtons = {
            Head = {btn = HeadRadioBtn, indicator = HeadRadioIndicator},
            Torso = {btn = TorsoRadioBtn, indicator = TorsoRadioIndicator},
            Leg = {btn = LegRadioBtn, indicator = LegRadioIndicator}
        }
        
        for part, data in pairs(radioButtons) do
            if part == partName then
                TweenService:Create(data.indicator, t, {BackgroundColor3 = Color3.fromRGB(70,196,70)}):Play()
                data.btn.TextColor3 = Color3.fromRGB(255,255,255)
            else
                TweenService:Create(data.indicator, t, {BackgroundColor3 = Color3.fromRGB(100,100,100)}):Play()
                data.btn.TextColor3 = Color3.fromRGB(180,180,180)
            end
        end
    end
    -- ================ END AIMLOCK FUNCTIONS ================ --
    
    local function createSliderLogic(track, thumb, valueLabel, min, max) local function updateFromInput(input) local trackWidth = track.AbsoluteSize.X; local relativeX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, trackWidth); local percent = relativeX / trackWidth; local newValue = min + (max - min) * percent; thumb.Position = UDim2.new(percent, -8, 0.5, -8); valueLabel.Text = tostring(math.floor(newValue)) end; track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then updateFromInput(input); local dragConn, releaseConn; dragConn = UserInputService.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then updateFromInput(inp) end end); releaseConn = UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragConn:Disconnect(); releaseConn:Disconnect() end end) end end) end; createSliderLogic(SpeedTrack, SpeedThumb, SpeedValue, 16, 150); createSliderLogic(JumpTrack, JumpThumb, JumpValue, 50, 250);function openPlayerSettings() local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if humanoid then local speedPercent = (humanoid.WalkSpeed - 16) / (150 - 16); SpeedThumb.Position = UDim2.new(speedPercent, -8, 0.5, -8); SpeedValue.Text=tostring(math.floor(humanoid.WalkSpeed)); local jumpPercent = (humanoid.JumpPower - 50) / (250 - 50); JumpThumb.Position = UDim2.new(jumpPercent, -8, 0.5, -8); JumpValue.Text=tostring(math.floor(humanoid.JumpPower)) end; SettingsOverlay.Visible = true; MainWindow.GroupTransparency = 0.5; MainWindow.Active = false end; function closePlayerSettings() SettingsOverlay.Visible = false; MainWindow.GroupTransparency = 0; MainWindow.Active = true end;local function stopTeleport() if teleportConnection then teleportConnection:Disconnect(); teleportConnection = nil end; if bodyPosition and bodyPosition.Parent then bodyPosition:Destroy(); bodyPosition = nil end; isTeleporting = false; targetPlayer = nil; for _, v in pairs(PlayerListFrame:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(45, 45, 50) end end end; local function startTeleport(p) local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not myRoot then return end; stopTeleport(); isTeleporting = true; targetPlayer = p; bodyPosition = Instance.new("BodyPosition", myRoot); bodyPosition.Name = "GemLogin_BodyPosition"; bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bodyPosition.P = 50000; bodyPosition.D = 1250; teleportConnection = RunService.Heartbeat:Connect(function() if not isTeleporting or not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") or not bodyPosition or not bodyPosition.Parent then stopTeleport(); return end; local targetRoot = targetPlayer.Character.HumanoidRootPart; local offset = Vector3.new(0, 10, 0); bodyPosition.Position = targetRoot.Position + offset end) end; local function updatePlayerList(listFrame, clickCallback) listFrame:ClearAllChildren(); Instance.new("UIListLayout", listFrame).Padding = UDim.new(0, 5); Instance.new("UIPadding", listFrame).PaddingTop = UDim.new(0, 10); for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then local btn = Instance.new("TextButton", listFrame); btn.Name = player.Name; btn.Size = UDim2.new(1, -20, 0, 35); btn.AnchorPoint=Vector2.new(0.5,0); btn.Position=UDim2.new(0.5,0,0,0); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50); btn.Font = Enum.Font.Gotham; btn.Text = player.DisplayName; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.TextSize = 14; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); btn.MouseButton1Click:Connect(function() clickCallback(player, btn) end) end end end
    
    RunService.Heartbeat:Connect(function() if isNoclipEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running); for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end)

    PlayerTabButton.MouseButton1Click:Connect(function() switchTab(PlayerTabButton, PlayerPage) end)
    ESPTabButton.MouseButton1Click:Connect(function() switchTab(ESPTabButton, ESPPage) end)
    AimTabButton.MouseButton1Click:Connect(function() switchTab(AimTabButton, AimPage) end)
    SettingsButton.MouseButton1Click:Connect(openPlayerSettings)
    SettingsCloseBtn.MouseButton1Click:Connect(closePlayerSettings)
    SaveButton.MouseButton1Click:Connect(function() local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=tonumber(SpeedValue.Text) or 16; h.JumpPower=tonumber(JumpValue.Text) or 50 end; closePlayerSettings() end)
    NoclipButtonContainer.MouseButton1Click:Connect(function() isNoclipEnabled=not isNoclipEnabled;local t=TweenInfo.new(0.2,Enum.EasingStyle.Quad);if isNoclipEnabled then TweenService:Create(ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(70,196,70)}):Play();TweenService:Create(ToggleCircle,t,{Position=UDim2.new(1,-18,0.5,-8)}):Play() else TweenService:Create(ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(196,70,70)}):Play();TweenService:Create(ToggleCircle,t,{Position=UDim2.new(0,2,0.5,-8)}):Play();if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)end end end)
    TeleportButton.MouseButton1Click:Connect(function() local t = TweenInfo.new(0.3,Enum.EasingStyle.Exponential); if isPlayerListVisible then isPlayerListVisible=false; TeleportButton.Text = "Teleport to Player   ▼"; stopTeleport(); TweenService:Create(PlayerListFrame, t, {Size=UDim2.new(1,0,0,0)}):Play(); task.wait(0.3); PlayerListFrame.Visible=false else isPlayerListVisible=true; isAttackListVisible=false; AutoAttackPlayerListFrame.Visible=false; AutoAttackPlayerListFrame.Size=UDim2.new(1,0,0,0); TeleportButton.Text="Teleport to Player   ▲"; updatePlayerList(PlayerListFrame, function(player, btn) if targetPlayer == player and isTeleporting then stopTeleport() else startTeleport(player); btn.BackgroundColor3 = Color3.fromRGB(70, 196, 70) end end); PlayerListFrame.Visible=true; TweenService:Create(PlayerListFrame, t, {Size = UDim2.new(1, 0, 180, 0)}):Play() end end)
    AutoAttackButton.MouseButton1Click:Connect(function() local t = TweenInfo.new(0.3,Enum.EasingStyle.Exponential); if isAttackListVisible then isAttackListVisible=false; AutoAttackButton.Text = "Auto Attack Player   ▼"; stopAutoAttack(); TweenService:Create(AutoAttackPlayerListFrame,t,{Size=UDim2.new(1,0,0,0)}):Play(); task.wait(0.3); AutoAttackPlayerListFrame.Visible=false else isAttackListVisible=true; isPlayerListVisible=false; PlayerListFrame.Visible=false; PlayerListFrame.Size=UDim2.new(1,0,0,0); AutoAttackButton.Text = "Auto Attack Player   ▲"; updatePlayerList(AutoAttackPlayerListFrame, function(player,btn) if autoAttackTarget == player and isAutoAttacking then stopAutoAttack() else startAutoAttack(player); btn.BackgroundColor3 = Color3.fromRGB(200,50,50) end end); AutoAttackPlayerListFrame.Visible=true; TweenService:Create(AutoAttackPlayerListFrame,t,{Size = UDim2.new(1, 0, 180, 0)}):Play() end end)
    
    -- Kết nối sự kiện cho AIMLOCK
    AimLockButtonContainer.MouseButton1Click:Connect(toggleAimLock)
    HeadRadioBtn.MouseButton1Click:Connect(function() selectAimPart("Head") end)
    TorsoRadioBtn.MouseButton1Click:Connect(function() selectAimPart("Torso") end)
    LegRadioBtn.MouseButton1Click:Connect(function() selectAimPart("Leg") end)
    
    HighlightESPButtonContainer.MouseButton1Click:Connect(function() local t=TweenInfo.new(0.2,Enum.EasingStyle.Quad); if not isHighlightEspEnabled then enableHighlightESP(); TweenService:Create(ESP_ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(70,196,70)}):Play(); TweenService:Create(ESP_ToggleCircle,t,{Position=UDim2.new(1,-18,0.5,-8)}):Play() else disableHighlightESP(); TweenService:Create(ESP_ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(196,70,70)}):Play(); TweenService:Create(ESP_ToggleCircle,t,{Position=UDim2.new(0,2,0.5,-8)}):Play() end end)
    BoxESPButtonContainer.MouseButton1Click:Connect(function() 
        local t = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        isBoxEspEnabled = not isBoxEspEnabled
        
        toggleBoxEsp(isBoxEspEnabled)
        
        if isBoxEspEnabled then 
            TweenService:Create(BoxESP_ToggleIndicator, t, {BackgroundColor3 = Color3.fromRGB(70, 196, 70)}):Play()
            TweenService:Create(BoxESP_ToggleCircle, t, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else 
            TweenService:Create(BoxESP_ToggleIndicator, t, {BackgroundColor3 = Color3.fromRGB(196, 70, 70)}):Play()
            TweenService:Create(BoxESP_ToggleCircle, t, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
    end)
    LineESPButtonContainer.MouseButton1Click:Connect(function() local t=TweenInfo.new(0.2,Enum.EasingStyle.Quad); local willBeEnabled = not isLineEspEnabled; toggleLineEsp(willBeEnabled); if willBeEnabled then TweenService:Create(LineESP_ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(70,196,70)}):Play(); TweenService:Create(LineESP_ToggleCircle,t,{Position=UDim2.new(1,-18,0.5,-8)}):Play() else TweenService:Create(LineESP_ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(196,70,70)}):Play(); TweenService:Create(LineESP_ToggleCircle,t,{Position=UDim2.new(0,2,0.5,-8)}):Play() end end)
    DistanceESPButtonContainer.MouseButton1Click:Connect(function() local t=TweenInfo.new(0.2,Enum.EasingStyle.Quad); local willBeEnabled = not isDistanceEspEnabled; toggleDistanceEsp(willBeEnabled); if willBeEnabled then TweenService:Create(DistanceESP_ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(70,196,70)}):Play(); TweenService:Create(DistanceESP_ToggleCircle,t,{Position=UDim2.new(1,-18,0.5,-8)}):Play() else TweenService:Create(DistanceESP_ToggleIndicator,t,{BackgroundColor3=Color3.fromRGB(196,70,70)}):Play(); TweenService:Create(DistanceESP_ToggleCircle,t,{Position=UDim2.new(0,2,0.5,-8)}):Play() end end)
    
    CloseButton.MouseButton1Click:Connect(toggleMenuVisibility); ToggleBubble.MouseButton1Click:Connect(toggleMenuVisibility)
    CloseButton.MouseEnter:Connect(function() CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80) end); CloseButton.MouseLeave:Connect(function() CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200) end)
    
    espConnections.Player.Added = Players.PlayerAdded:Connect(setupPlayerForEsp)
    espConnections.Player.Removing = Players.PlayerRemoving:Connect(cleanupPlayerFromEsp)

    for _, player in pairs(Players:GetPlayers()) do
        setupPlayerForEsp(player)
    end

    game:GetService("CoreGui").gemlogin_tool.Destroying:Connect(function()
        if espUpdateConnection then espUpdateConnection:Disconnect() end
        disableHighlightESP() 
        stopAimLock()
        for _, p in pairs(Players:GetPlayers()) do cleanupPlayerFromEsp(p) end 
        for _, conn in pairs(espConnections.Player) do conn:Disconnect() end
        for _, conn in pairs(espConnections.Character) do conn:Disconnect() end
        pcall(function() workspace:FindFirstChild("GemLogin_ESP_Container"):Destroy() end)
    end)
    
end)

if not success then
    local ErrorLoggerGUI=nil;pcall(function() local UserInputService = game:GetService("UserInputService") end);local function logErrorOnScreen(err)if not ErrorLoggerGUI then ErrorLoggerGUI=Instance.new("ScreenGui",game:GetService("CoreGui"));ErrorLoggerGUI.Name="GemLogin_ErrorLogger";ErrorLoggerGUI.ZIndexBehavior=Enum.ZIndexBehavior.Global;ErrorLoggerGUI.ResetOnSpawn=false;local ErrorPanel=Instance.new("Frame",ErrorLoggerGUI);ErrorPanel.Size=UDim2.new(0,450,0,200);ErrorPanel.Position=UDim2.new(0.5,-225,0.5,-100);ErrorPanel.BackgroundColor3=Color3.fromRGB(45,35,35);ErrorPanel.BorderColor3=Color3.fromRGB(200,50,50);ErrorPanel.BorderSizePixel=2;Instance.new("UICorner",ErrorPanel).CornerRadius=UDim.new(0,8);local isDragging;ErrorPanel.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then isDragging=true;local startPos=input.Position;local guiStartPos=ErrorPanel.Position;local moveConn=UserInputService.InputChanged:Connect(function(inp)if(inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch)and isDragging then local delta=inp.Position-startPos;ErrorPanel.Position=UDim2.new(guiStartPos.X.Scale,guiStartPos.X.Offset+delta.X,guiStartPos.Y.Scale,guiStartPos.Y.Offset+delta.Y)end end);local endConn=UserInputService.InputEnded:Connect(function(inp)if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then isDragging=false;moveConn:Disconnect();endConn:Disconnect()end end)end end);local Title=Instance.new("TextLabel",ErrorPanel);Title.Size=UDim2.new(1,0,0,30);Title.BackgroundColor3=Color3.fromRGB(200,50,50);Title.Font=Enum.Font.GothamBold;Title.Text="GEMLOGIN TOOL - SCRIPT ERROR";Title.TextColor3=Color3.fromRGB(255,255,255);Title.TextSize=16;Instance.new("UICorner",Title).CornerRadius=UDim.new(0,6);local CloseBtn=Instance.new("TextButton",Title);CloseBtn.Size=UDim2.new(0,25,0,25);CloseBtn.Position=UDim2.new(1,-30,0.5,-12.5);CloseBtn.BackgroundTransparency=1;CloseBtn.Font=Enum.Font.GothamBold;CloseBtn.Text="X";CloseBtn.TextColor3=Color3.fromRGB(255,255,255);CloseBtn.TextSize=14;CloseBtn.MouseButton1Click:Connect(function()ErrorLoggerGUI:Destroy();ErrorLoggerGUI=nil end);local ErrorMessageLabel=Instance.new("TextLabel",ErrorPanel);ErrorMessageLabel.Name="ErrorMessage";ErrorMessageLabel.Size=UDim2.new(1,-20,1,-40);ErrorMessageLabel.Position=UDim2.new(0,10,0,30);ErrorMessageLabel.BackgroundTransparency=1;ErrorMessageLabel.Font=Enum.Font.Code;ErrorMessageLabel.TextWrapped=true;ErrorMessageLabel.TextXAlignment=Enum.TextXAlignment.Left;ErrorMessageLabel.TextYAlignment=Enum.TextYAlignment.Top;ErrorMessageLabel.TextColor3=Color3.fromRGB(255,180,180);ErrorMessageLabel.TextSize=13 end;local msgLabel=ErrorLoggerGUI:FindFirstChild("ErrorPanel",true):FindFirstChild("ErrorMessage");if msgLabel then msgLabel.Text="Lỗi nghiêm trọng đã xảy ra:\n\n"..tostring(err)end;ErrorLoggerGUI.Enabled=true end
    logErrorOnScreen(errorMessage)
else
    print("gemlogin tool by TuanHaii (v10.6 - Corner Box ESP + AimLock) đã được tải thành công!")
end
