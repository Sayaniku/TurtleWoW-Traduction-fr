local _G, _ = _G or getfenv()
local EBC_Frame = CreateFrame("Frame")
EBC_Frame:RegisterEvent("VARIABLES_LOADED")

EBC_Frame:SetScript("OnEvent", function()
	if event == "VARIABLES_LOADED" then
		StopMusic()
		EBC_CreateFrame()
	end
end)

function ShowEBCMinimapDropdown()
    if EBCMinimapDropdown:IsShown() then
		EBCMinimapDropdown:Hide()
	else
		EBCMinimapDropdown:Show()
	end
end

function EBCMinimapDropdown_OnUpdate(elapsed)
	if not this.timer then
		return
	end
	if MouseIsOver(this) then
		this.timer = UIDROPDOWNMENU_SHOW_TIME
	else
		this.timer = this.timer - elapsed
	end
	if this.timer <= 0 then
		this.timer = nil
		this:Hide()
	end
end

function EBC_TuneIn(station)
	station = station or this:GetID()
	local s1 = EBCMinimapDropdown.CheckButton1:GetChecked()
	local s2 = EBCMinimapDropdown.CheckButton2:GetChecked()

	if not s1 and not s2 then
		EBC_SELECTED_STATION = nil
		UIErrorsFrame:AddMessage(format(EBC_STOPPED, EBC_TITLE), 1, 1, 0)
		StopMusic()
		return
	end
	EBC_SELECTED_STATION = station
	EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Up",})
	SetCVar("EnableMusic", 1)
	SendChatMessage(".radio "..station)
	UIErrorsFrame:AddMessage(format(EBC_TUNEDINTO, _G["EBC_STATION"..station]), 1, 1, 0)
end

function EBC_Alert(txt)
	UIErrorsFrame:AddMessage(txt,1, 1, 1, 1,4);
	DEFAULT_CHAT_FRAME:AddMessage(txt);
end

function EBC_CreateURLFrame()
    -- Create the main popup background
    local urlFrame = CreateFrame("Frame", "EBCURLFrame", UIParent)
    urlFrame:SetWidth(300)
    urlFrame:SetHeight(100)
    -- Fully qualified SetPoint for 1.12
    urlFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    urlFrame:SetFrameStrata("DIALOG")
    urlFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    urlFrame:Hide()

    -- Title text
    local title = urlFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- Anchored strictly to the urlFrame
    title:SetPoint("TOP", urlFrame, "TOP", 0, -20)
    title:SetText("Press Ctrl+C to copy the URL:")

    -- The input box where the URL will sit
    local editBox = CreateFrame("EditBox", "EBCURLEditBox", urlFrame, "InputBoxTemplate")
    editBox:SetWidth(240)
    editBox:SetHeight(30)
    -- Anchored strictly to the urlFrame
    editBox:SetPoint("CENTER", urlFrame, "CENTER", 0, -5)
    editBox:SetAutoFocus(true)
    
    -- Prevent users from deleting the text accidentally and close on Escape
    editBox:SetScript("OnEscapePressed", function() urlFrame:Hide() end)
    editBox:SetScript("OnTextChanged", function()
        if this.currentURL and this:GetText() ~= this.currentURL then
            this:SetText(this.currentURL)
        end
        this:HighlightText()
	end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, urlFrame, "UIPanelButtonTemplate")
    closeBtn:SetWidth(80)
    closeBtn:SetHeight(22)
    -- Anchored strictly to the urlFrame
    closeBtn:SetPoint("BOTTOM", urlFrame, "BOTTOM", 0, 15)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() urlFrame:Hide() end)
end

function EBC_ShowURL(url)
    if not EBCURLFrame then 
        EBC_CreateURLFrame() 
    end
    EBCURLFrame:Show()
    -- Save the URL to our custom property so OnTextChanged can enforce it
    EBCURLEditBox.currentURL = url
    EBCURLEditBox:SetText(url)
    EBCURLEditBox:HighlightText()
end

function EBC_CreateFrame()

	local uiScale = GetCVar("uiScale")
	local res = GetCVar("gxResolution")

	-- Create the Drowndown Frame
	local EBCMinimapDropdown = CreateFrame("Frame", "EBCMinimapDropdown", UIParent)
	EBCMinimapDropdown:SetFrameStrata("DIALOG")
	EBCMinimapDropdown:SetPoint("TOPRIGHT", EBC_Minimap, "BOTTOMLEFT", 10, 10)
	EBCMinimapDropdown:SetWidth(215-math.floor(uiScale*10))
	EBCMinimapDropdown:SetHeight(130)
	EBCMinimapDropdown:SetBackdrop({
	  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	  tile = true, tileSize = 16, edgeSize = 16,
	  insets = { left = 4, right = 4, top = 4, bottom = 3 }
	})
	EBCMinimapDropdown:SetClampedToScreen()
	EBCMinimapDropdown:Hide()

	-- Title
	EBCMinimapDropdown.title = CreateFrame("Frame", "EBCMinimapDropdownTitle", EBCMinimapDropdown)
	EBCMinimapDropdown.title:SetPoint("TOPLEFT", EBCMinimapDropdown, "TOPLEFT")
	EBCMinimapDropdown.title:SetWidth(205-math.floor(uiScale*10))
	EBCMinimapDropdown.title:SetHeight(69)

	-- Title Text
	EBCMinimapDropdown.title.text = EBCMinimapDropdown.title:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.title.text:SetText(EBC_TITLE)
	if res == "1280x720" then
		EBCMinimapDropdown.title.text:SetFont("Fonts\\FRIZQT__.TTF", 14)
	elseif res == "1024x768" or res == "1280x600" or "800x600" then
		EBCMinimapDropdown.title.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
	else
		EBCMinimapDropdown.title.text:SetFont("Fonts\\FRIZQT__.TTF", 15)
	end
	EBCMinimapDropdown.title.text:SetPoint("TOPLEFT", 13, -10)

	-- Volume Slider
	EBCMinimapDropdown.slider = CreateFrame("Slider", "EBCMinimapDropdownSlider", EBCMinimapDropdown, "OptionsSliderTemplate")
	EBCMinimapDropdown.slider:SetPoint("BOTTOMLEFT", EBCMinimapDropdown, "BOTTOMLEFT", 10, 34)
	EBCMinimapDropdown.slider:SetWidth(125)
	EBCMinimapDropdown.slider:SetHeight(20)
	EBCMinimapDropdown.slider:SetOrientation('HORIZONTAL')
	EBCMinimapDropdown.slider:SetMinMaxValues(0, 100)
	EBCMinimapDropdown.slider:SetValue(math.floor(GetCVar("MusicVolume")*100))
	EBCMinimapDropdown.slider:SetValueStep(1)
	getglobal(EBCMinimapDropdown.slider:GetName() .. 'Low'):SetText('')
	getglobal(EBCMinimapDropdown.slider:GetName() .. 'High'):SetText('')
	getglobal(EBCMinimapDropdown.slider:GetName() .. 'Text'):SetText('')
	EBCMinimapDropdown.slider:EnableMouseWheel(true)
	EBCMinimapDropdown.slider:SetScript("OnValueChanged",function()
		SetCVar("MusicVolume",EBCMinimapDropdown.slider:GetValue()/100)
		EBCMinimapDropdown.VolText.text:SetText(EBCMinimapDropdown.slider:GetValue())
		PlaySound("igMiniMapZoomIn","SFX")
	end)
	EBCMinimapDropdown.slider:SetScript("OnMouseWheel", function()
		local val = EBCMinimapDropdown.slider:GetValue()
		if arg1 == 1 then
			val=val+10
		else
			val=val-10
		end
		SetCVar("MusicVolume",val/100)
		EBCMinimapDropdown.slider:SetValue(val)
	 end)

	-- Volume Text
	EBCMinimapDropdown.VolText = CreateFrame("Frame", "EBCMinimapDropdownVolText", EBCMinimapDropdown)
	EBCMinimapDropdown.VolText:SetPoint("BOTTOMLEFT", EBCMinimapDropdown, "BOTTOMLEFT", 2,29)
	EBCMinimapDropdown.VolText:SetWidth(8)
	EBCMinimapDropdown.VolText:SetHeight(8)

	EBCMinimapDropdown.VolText.text = EBCMinimapDropdown.VolText:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.VolText.text:SetText(EBCMinimapDropdown.slider:GetValue())
	EBCMinimapDropdown.VolText.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	EBCMinimapDropdown.VolText.text:SetPoint("BOTTOMLEFT", 135, 10)

	-- Mute Button
	EBCMinimapDropdown.MuteButton = CreateFrame("Frame", "EBCMinimapDropdownMuteButton", EBCMinimapDropdown)
	EBCMinimapDropdown.MuteButton:SetWidth(18)
	EBCMinimapDropdown.MuteButton:SetHeight(18)
		if GetCVar("EnableMusic") == "1" then
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Up",})
		else
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled",})
		end
	EBCMinimapDropdown.MuteButton:SetPoint("BOTTOMRIGHT", EBCMinimapDropdown, "BOTTOMRIGHT", -15, 34)

	EBCMinimapDropdown.MuteButton:EnableMouse(true)
	EBCMinimapDropdown.MuteButton:SetScript("OnMouseDown", function()
		if GetCVar("EnableMusic") == "1" then
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Disabled",})
			SetCVar("EnableMusic", 0)
			EBCMinimapDropdown.CheckButton1:SetChecked(0)
			EBCMinimapDropdown.CheckButton2:SetChecked(0)
			StopMusic()
			GameTooltip:SetText("|cffffd000 Enable",1,1,1,1)
		else
			EBCMinimapDropdown.MuteButton:SetBackdrop({bgFile = "Interface\\Buttons\\UI-GuildButton-MOTD-Up",})
			GameTooltip:SetText("|cffffd000 "..EBC_MUTE,1,1,1,1)
			SetCVar("EnableMusic", 1)
		end
	end)
	EBCMinimapDropdown.MuteButton:SetScript("OnEnter", function()
		local state = EBC_UNMUTE
		if GetCVar("EnableMusic") == "1" then state = EBC_MUTE end
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
	end)
	EBCMinimapDropdown.MuteButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- Station Checkbox
	EBCMinimapDropdown.CheckButton1 = CreateFrame("CheckButton", "EBCMinimapDropdownCheckButton", EBCMinimapDropdown.title, "UICheckButtonTemplate")
	EBCMinimapDropdown.CheckButton1:SetPoint("LEFT", 8, -8)
	EBCMinimapDropdown.CheckButton1:SetWidth(30)
	EBCMinimapDropdown.CheckButton1:SetHeight(30)
	
	EBCMinimapDropdown.CheckButton1:SetScript("OnEnter", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
	end)
	EBCMinimapDropdown.CheckButton1:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	EBCMinimapDropdown.CheckButton1:SetScript("OnClick", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
		EBCMinimapDropdown.CheckButton2:SetChecked(0)
		EBC_TuneIn(1)
	end)
	
	-- Station Text
	EBCMinimapDropdown.RaidoText = CreateFrame("Frame", "EBCMinimapDropdownRadio", EBCMinimapDropdown.CheckButton1)
	EBCMinimapDropdown.RaidoText:SetPoint("TOP", EBCMinimapDropdown.CheckButton1, "TOP", 0, 0)
	EBCMinimapDropdown.RaidoText:SetWidth(10)
	EBCMinimapDropdown.RaidoText:SetHeight(10)

	EBCMinimapDropdown.RaidoText.text = EBCMinimapDropdown.RaidoText:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.RaidoText.text:SetText("|cffffffff"..EBC_STATION1)
	if res == "1280x720" or res == "1024x768" or res == "1280x600" then
		EBCMinimapDropdown.RaidoText.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	elseif "800x600" then
		EBCMinimapDropdown.RaidoText.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
	else
		EBCMinimapDropdown.RaidoText.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
	end
	EBCMinimapDropdown.RaidoText.text:SetPoint("LEFT", 23, -9)

	-- Station 2 Checkbox
	EBCMinimapDropdown.CheckButton2 = CreateFrame("CheckButton", "EBCMinimapDropdownCheckButton2", EBCMinimapDropdown.CheckButton1, "UICheckButtonTemplate")
	EBCMinimapDropdown.CheckButton2:SetPoint("LEFT", 0, -22)
	EBCMinimapDropdown.CheckButton2:SetWidth(30)
	EBCMinimapDropdown.CheckButton2:SetHeight(30)
	
	EBCMinimapDropdown.CheckButton2:SetScript("OnEnter", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
	end)
	EBCMinimapDropdown.CheckButton2:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	EBCMinimapDropdown.CheckButton2:SetScript("OnClick", function()
		local state = EBC_TUNEIN
		if this:GetChecked() == 1 then state = EBC_TUNEOUT end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("|cffffd000"..state,1,1,1,1)
		EBCMinimapDropdown.CheckButton1:SetChecked(0)
		EBC_TuneIn(2)
	end)
	
	-- Station 2 Text
	EBCMinimapDropdown.RaidoText2 = CreateFrame("Frame", "EBCMinimapDropdownRadio2", EBCMinimapDropdown.CheckButton2)
	EBCMinimapDropdown.RaidoText2:SetPoint("TOP", EBCMinimapDropdown.CheckButton2, "TOP", 0, 0)
	EBCMinimapDropdown.RaidoText2:SetWidth(10)
	EBCMinimapDropdown.RaidoText2:SetHeight(10)

	EBCMinimapDropdown.RaidoText2.text = EBCMinimapDropdown.RaidoText2:CreateFontString(nil, "HIGH", "GameFontNormal")
	EBCMinimapDropdown.RaidoText2.text:SetText("|cffffffff"..EBC_STATION2)
	if res == "1280x720" or res == "1024x768" or res == "1280x600" then
		EBCMinimapDropdown.RaidoText2.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
	elseif "800x600" then
		EBCMinimapDropdown.RaidoText2.text:SetFont("Fonts\\FRIZQT__.TTF", 11)
	else
		EBCMinimapDropdown.RaidoText2.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
	end
	EBCMinimapDropdown.RaidoText2.text:SetPoint("LEFT", 23, -9)

	-- Discord Menu Button
	EBCMinimapDropdown.discordBtn = CreateFrame("Button", "EBCDiscordBtn", EBCMinimapDropdown, "UIPanelButtonTemplate")
	EBCMinimapDropdown.discordBtn:SetWidth(175)
	EBCMinimapDropdown.discordBtn:SetHeight(22)
	EBCMinimapDropdown.discordBtn:SetPoint("BOTTOM", 0, 10) 
	EBCMinimapDropdown.discordBtn:SetText("Join the Radio Discord!")
	EBCMinimapDropdown.discordBtn:SetScript("OnClick", function()
		EBC_ShowURL("https://tinyurl.com/everlookbroadcasting")
	end)

end
