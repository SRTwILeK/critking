-- ============================================================
-- Crit King — Interface Options panel
--
-- Registered into the game's AddOns options page and opened with
-- "/ck options". Works on both options systems: the modern Settings API
-- (Settings.RegisterCanvasLayoutCategory) when present, otherwise the
-- legacy InterfaceOptions API (InterfaceOptions_AddCategory) — some Classic
-- clients ship one, some the other.
--
-- All controls write straight into CritKingVars and apply live, so the
-- panel's okay/cancel are no-ops; refresh() re-reads the saved values
-- into the widgets whenever the panel is shown.
-- ============================================================

function CritKing.CreateOptionsPanel()
    if ( CritKing.OptionsPanel ) then return end

    local panel = CreateFrame( "Frame", "CritKingOptionsPanel", UIParent )
    panel.name = "Crit King"

    -- Widgets register a refresher so the panel reflects saved state on show.
    local refreshers = {}

    local title = panel:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" )
    title:SetPoint( "TOPLEFT", 16, -16 )
    title:SetText( "Crit King" )

    local subtitle = panel:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
    subtitle:SetPoint( "TOPLEFT", title, "BOTTOMLEFT", 0, -8 )
    subtitle:SetPoint( "RIGHT", panel, "RIGHT", -32, 0 )
    subtitle:SetJustifyH( "LEFT" )
    subtitle:SetText( "Announcer-style messages and sounds for critical hits and killing blows." )

    -- Section header helper.
    local function Header( text, x, y )
        local fs = panel:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
        fs:SetPoint( "TOPLEFT", x, y )
        fs:SetText( text )
        return fs
    end

    -- Checkbox helper. getter()/setter(value) read and write a saved value.
    local function MakeCheck( label, x, y, getter, setter )
        local cb = CreateFrame( "CheckButton", nil, panel, "UICheckButtonTemplate" )
        cb:SetPoint( "TOPLEFT", x, y )

        local fs = cb:CreateFontString( nil, "OVERLAY", "GameFontHighlight" )
        fs:SetPoint( "LEFT", cb, "RIGHT", 4, 0 )
        fs:SetText( label )

        cb:SetScript( "OnClick", function( self )
            setter( self:GetChecked() and true or false )
        end )

        table.insert( refreshers, function() cb:SetChecked( getter() ) end )
        return cb
    end

    -- ---- Behaviour ------------------------------------------------------
    Header( "Messages & sounds", 16, -70 )

    MakeCheck( "Show on-screen messages", 16, -92,
        function() return CritKingVars.Display end,
        function( v ) CritKingVars.Display = v end )

    MakeCheck( "Reset crit streak on a normal hit", 16, -120,
        function() return CritKingVars.ResetOnNormalHit end,
        function( v ) CritKingVars.ResetOnNormalHit = v end )

    MakeCheck( "Play sound on critical hits", 16, -148,
        function() return CritKingVars.Sound.Crit end,
        function( v ) CritKingVars.Sound.Crit = v end )

    MakeCheck( "Play sound on kills", 16, -176,
        function() return CritKingVars.Sound.Kill end,
        function( v ) CritKingVars.Sound.Kill = v end )

    MakeCheck( "Play sound on crit achievements", 16, -204,
        function() return CritKingVars.Sound.Ach.Crit end,
        function( v ) CritKingVars.Sound.Ach.Crit = v end )

    -- ---- Display frame --------------------------------------------------
    Header( "Display frame", 16, -244 )

    MakeCheck( "Unlock frame (drag to move, position is saved)", 16, -266,
        function() return not CritKingVars.Frame.Locked end,
        function( v )
            CritKingVars.Frame.Locked = not v
            CritKing.Banner.ApplyLock()
        end )

    -- Font dropdown.
    local fontLabel = panel:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
    fontLabel:SetPoint( "TOPLEFT", 16, -300 )
    fontLabel:SetText( "Font" )

    local fontDrop = CreateFrame( "Frame", "CritKingFontDropDown", panel, "UIDropDownMenuTemplate" )
    fontDrop:SetPoint( "TOPLEFT", 0, -318 )
    UIDropDownMenu_SetWidth( fontDrop, 160 )
    UIDropDownMenu_Initialize( fontDrop, function( self, level )
        for _, font in ipairs( CritKing.GetFontList() ) do
            local info = UIDropDownMenu_CreateInfo()
            info.text    = font.name
            info.value   = font.path
            info.checked = ( font.path == CritKingVars.Frame.Font )
            info.func    = function( button )
                CritKingVars.Frame.Font = button.value
                UIDropDownMenu_SetSelectedValue( fontDrop, button.value )
                UIDropDownMenu_SetText( fontDrop, CritKing.FontName( button.value ) )
                CritKing.Banner.ApplyFont()
            end
            UIDropDownMenu_AddButton( info, level )
        end
    end )
    table.insert( refreshers, function()
        UIDropDownMenu_SetSelectedValue( fontDrop, CritKingVars.Frame.Font )
        UIDropDownMenu_SetText( fontDrop, CritKing.FontName( CritKingVars.Frame.Font ) )
    end )

    -- Text color swatch (opens the game's color picker).
    local colorLabel = panel:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
    colorLabel:SetPoint( "TOPLEFT", 300, -300 )
    colorLabel:SetText( "Text color" )

    local swatch = CreateFrame( "Button", nil, panel )
    swatch:SetSize( 24, 24 )
    swatch:SetPoint( "TOPLEFT", 302, -320 )

    local swatchBorder = swatch:CreateTexture( nil, "BACKGROUND" )
    swatchBorder:SetPoint( "TOPLEFT", -1, 1 )
    swatchBorder:SetPoint( "BOTTOMRIGHT", 1, -1 )
    swatchBorder:SetColorTexture( 0, 0, 0 )

    local swatchTex = swatch:CreateTexture( nil, "OVERLAY" )
    swatchTex:SetAllPoints( swatch )
    swatchTex:SetColorTexture( 1, 1, 1 )
    swatch:SetHighlightTexture( "Interface\\Buttons\\ButtonHilight-Square", "ADD" )

    local function UpdateSwatch()
        local c = CritKingVars.Frame.Color
        swatchTex:SetColorTexture( c.r, c.g, c.b )
    end
    table.insert( refreshers, UpdateSwatch )

    swatch:SetScript( "OnClick", function()
        local c = CritKingVars.Frame.Color
        local r, g, b = c.r, c.g, c.b   -- remembered for cancel

        local function apply()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            CritKingVars.Frame.Color.r = nr
            CritKingVars.Frame.Color.g = ng
            CritKingVars.Frame.Color.b = nb
            CritKing.Banner.ApplyColor()
            UpdateSwatch()
        end

        local function cancel()
            CritKingVars.Frame.Color.r = r
            CritKingVars.Frame.Color.g = g
            CritKingVars.Frame.Color.b = b
            CritKing.Banner.ApplyColor()
            UpdateSwatch()
        end

        if ( ColorPickerFrame.SetupColorPickerAndShow ) then
            -- Modern API (single info table).
            ColorPickerFrame:SetupColorPickerAndShow( {
                r = r, g = g, b = b,
                hasOpacity = false,
                swatchFunc = apply,
                cancelFunc = cancel
            } )
        else
            -- Legacy API (fields set directly on the frame).
            ColorPickerFrame.func          = apply
            ColorPickerFrame.cancelFunc    = cancel
            ColorPickerFrame.hasOpacity    = false
            ColorPickerFrame.previousValues = { r = r, g = g, b = b }
            ColorPickerFrame:SetColorRGB( r, g, b )
            ShowUIPanel( ColorPickerFrame )
        end
    end )

    -- Font size slider.
    local sizeSlider = CreateFrame( "Slider", "CritKingFontSizeSlider", panel, "OptionsSliderTemplate" )
    sizeSlider:SetPoint( "TOPLEFT", 20, -372 )
    sizeSlider:SetWidth( 200 )
    sizeSlider:SetMinMaxValues( 8, 64 )
    sizeSlider:SetValueStep( 1 )
    sizeSlider:SetObeyStepOnDrag( true )
    _G[ sizeSlider:GetName() .. "Low" ]:SetText( "8" )
    _G[ sizeSlider:GetName() .. "High" ]:SetText( "64" )
    _G[ sizeSlider:GetName() .. "Text" ]:SetText( "Font size" )
    sizeSlider:SetScript( "OnValueChanged", function( self, value )
        value = math.floor( value + 0.5 )
        CritKingVars.Frame.FontSize = value
        _G[ self:GetName() .. "Text" ]:SetText( "Font size: " .. value )
        CritKing.Banner.ApplyFont()
    end )
    table.insert( refreshers, function()
        sizeSlider:SetValue( CritKingVars.Frame.FontSize )
        _G[ sizeSlider:GetName() .. "Text" ]:SetText( "Font size: " .. CritKingVars.Frame.FontSize )
    end )

    -- Animation dropdown.
    local animLabel = panel:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
    animLabel:SetPoint( "TOPLEFT", 16, -412 )
    animLabel:SetText( "Text animation" )

    local animDrop = CreateFrame( "Frame", "CritKingAnimDropDown", panel, "UIDropDownMenuTemplate" )
    animDrop:SetPoint( "TOPLEFT", 0, -430 )
    UIDropDownMenu_SetWidth( animDrop, 160 )
    UIDropDownMenu_Initialize( animDrop, function( self, level )
        for _, anim in ipairs( CritKing.Animations ) do
            local info = UIDropDownMenu_CreateInfo()
            info.text    = anim.name
            info.value   = anim.key
            info.checked = ( anim.key == CritKingVars.Frame.Animation )
            info.func    = function( button )
                CritKingVars.Frame.Animation = button.value
                UIDropDownMenu_SetSelectedValue( animDrop, button.value )
                UIDropDownMenu_SetText( animDrop, CritKing.AnimName( button.value ) )
            end
            UIDropDownMenu_AddButton( info, level )
        end
    end )
    table.insert( refreshers, function()
        UIDropDownMenu_SetSelectedValue( animDrop, CritKingVars.Frame.Animation )
        UIDropDownMenu_SetText( animDrop, CritKing.AnimName( CritKingVars.Frame.Animation ) )
    end )

    -- Preview button.
    local testBtn = CreateFrame( "Button", nil, panel, "UIPanelButtonTemplate" )
    testBtn:SetSize( 140, 24 )
    testBtn:SetPoint( "TOPLEFT", 16, -484 )
    testBtn:SetText( "Test message" )
    testBtn:SetScript( "OnClick", function() CritKing.Banner.Show( "Head shot!" ) end )

    -- ---- Panel plumbing -------------------------------------------------
    panel.refresh = function()
        for _, fn in ipairs( refreshers ) do fn() end
    end
    -- OnShow also covers the case where the panel is opened directly.
    panel:SetScript( "OnShow", panel.refresh )

    -- Register with whichever options system this client provides. Modern
    -- clients (Settings API) removed InterfaceOptions_AddCategory; older
    -- ones lack the Settings table.
    if ( Settings and Settings.RegisterCanvasLayoutCategory ) then
        local category = Settings.RegisterCanvasLayoutCategory( panel, panel.name )
        Settings.RegisterAddOnCategory( category )
        CritKing.SettingsCategory = category
    else
        InterfaceOptions_AddCategory( panel )
    end

    CritKing.OptionsPanel = panel
end

-- Open the options panel (creating it if the game fired VARIABLES_LOADED
-- before this file registered the panel).
function CritKing.OpenOptions()
    if ( not CritKing.OptionsPanel ) then
        CritKing.CreateOptionsPanel()
    end

    if ( Settings and Settings.OpenToCategory and CritKing.SettingsCategory ) then
        Settings.OpenToCategory( CritKing.SettingsCategory:GetID() )
    elseif ( InterfaceOptionsFrame_OpenToCategory ) then
        -- Legacy API needs calling twice to reliably scroll to and select
        -- the right category.
        InterfaceOptionsFrame_OpenToCategory( CritKing.OptionsPanel )
        InterfaceOptionsFrame_OpenToCategory( CritKing.OptionsPanel )
    end
end
