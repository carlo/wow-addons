--[[
	Menu.lua
		Functions for the Bagnon right click options menu
--]]

local STRATAS = {"LOW", "MEDIUM", "HIGH"}
local MENU_NAME = "BagnonMenu"
local L = BAGNON_LOCALS

local function ToIndex(value, items)
	for i,v in pairs(items) do
		if v == value then return i end
	end
	return 0
end

local function GetRelativeCoords(frame, scale)
	local ratio = frame:GetScale() / scale
	return frame:GetLeft() * ratio, frame:GetTop() * ratio
end


--[[ Slider Template ]]--

local function Slider_OnValueChanged(self, value)
	local parent = self:GetParent()
	local values = self.values

	if not parent.onShow then
		if self.isPercent then
			self.OnChange(parent.anchor, value/100)
		elseif values then
			self.OnChange(parent.anchor, values[value])
		else
			self.OnChange(parent.anchor, value)
		end
	end

	if values then
		getglobal(self:GetName() .. "ValText"):SetText(values[value])
	else
		getglobal(self:GetName() .. "ValText"):SetText(value)
	end
end

local function Slider_Create(parent, suffix, minVal, maxVal, step, title, OnChange, isPercent, values)
	local name = parent:GetName() .. suffix

	local slider = CreateFrame("Slider", name, parent, "GooeySlider")
	slider:SetWidth(216); slider:SetHeight(18)
	slider.OnChange = OnChange
	slider.isPercent = isPercent
	slider.values = values

	slider:SetValueStep(step)
	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetScript("OnValueChanged", Slider_OnValueChanged)

	getglobal(name .. "Text"):SetText(title)
	if values then
		getglobal(name .. "Low"):SetText(values[minVal])
		getglobal(name .. "High"):SetText(values[maxVal])
	else
		getglobal(name .. "Low"):SetText(minVal)
		getglobal(name .. "High"):SetText(maxVal)
	end

	return slider
end


--[[ Color Picker ]]--

local function BGColor_OnColorChange()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local frame = ColorPickerFrame.frame
	local bgSets = frame.sets.bg
	local a = bgSets.a

	bgSets.r = r
	bgSets.g = g
	bgSets.b = b

	frame:SetBackdropColor(r, g, b, a)
	frame:SetBackdropBorderColor(1, 1, 1, a)
	getglobal(MENU_NAME .. "BGColorNormalTexture"):SetVertexColor(r, g, b, a)
end

local function BGColor_OnAlphaChange()
	local frame = ColorPickerFrame.frame
	local alpha = 1 - OpacitySliderFrame:GetValue()
	local bgSets = frame.sets.bg

	bgSets.a = alpha

	frame:SetBackdropColor(bgSets.r, bgSets.g, bgSets.b, alpha)
	frame:SetBackdropBorderColor(1, 1, 1, alpha)
	getglobal(MENU_NAME .. "BGColorNormalTexture"):SetVertexColor(bgSets.r, bgSets.g, bgSets.b, alpha)
end

local function BGColor_CancelChanges()
	local prevValues = ColorPickerFrame.previousValues
	local frame = ColorPickerFrame.frame

	local bgSets = frame.sets.bg
	bgSets.r = prevValues.r
	bgSets.g = prevValues.g
	bgSets.b = prevValues.b
	bgSets.a = prevValues.opacity

	frame:SetBackdropColor(prevValues.r, prevValues.g, prevValues.b, prevValues.opacity)
	frame:SetBackdropBorderColor(1, 1, 1, prevValues.opacity)
	getglobal(MENU_NAME .. "BGColorNormalTexture"):SetVertexColor(prevValues.r, prevValues.g, prevValues.b, prevValues.opacity)
end

local function BGColor_OnClick(frame)
	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:Hide()
	else
		local bgSets = frame.sets.bg

		ColorPickerFrame.frame = frame
		ColorPickerFrame.hasOpacity = 1
		ColorPickerFrame.opacity = 1 - bgSets.a
		ColorPickerFrame.previousValues = {r = bgSets.r, g = bgSets.g, b = bgSets.b, opacity = bgSets.a}

		ColorPickerFrame.func = BGColor_OnColorChange
		ColorPickerFrame.opacityFunc = BGColor_OnAlphaChange
		ColorPickerFrame.cancelFunc = BGColor_CancelChanges

		ColorPickerFrame:SetColorRGB(bgSets.r, bgSets.g, bgSets.b)

		getglobal(MENU_NAME .. "BGColorNormalTexture"):SetVertexColor(bgSets.r, bgSets.g, bgSets.b, bgSets.a)

		ShowUIPanel(ColorPickerFrame)
	end
end


--[[ Config Functions ]]--

local function SetFrameStrata(frame, strata)
	frame.sets.strata = strata
	frame:SetFrameStrata(strata)
end

local function SetFrameColumns(frame, cols)
	frame:Layout(cols)
end

local function SetFrameSpacing(frame, space)
	frame:Layout(frame.cols, space)
end

local function SetFrameAlpha(frame, alpha)
	if not alpha or alpha == 1 then
		frame.sets.alpha = nil
	else
		frame.sets.alpha = alpha
	end
	frame:SetAlpha(alpha)
end

local function SetFrameScale(frame, scale)
	frame.sets.scale = scale

	local x, y = GetRelativeCoords(frame, scale)

	frame:SetScale(scale)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	frame:SavePosition()
end

local function SetFrameLock(frame, enable)
	frame:Lock(enable)
end

local function SetToplevel(frame, enable)
	if enable then
		frame.sets.topLevel = 1
		frame:SetToplevel(true)
	else
		frame.sets.topLevel = nil
		frame:SetToplevel(false)
	end
end

local function SetReverseSort(frame, enable)
	if enable then
		frame.sets.reverseSort = 1
	else
		frame.sets.reverseSort = nil
	end
	frame:SortBags()
	frame:Layout()
end

--[[ Menu Constructor ]]--

local function CreateMenu(name)
	local menu = CreateFrame("Button", name, UIParent, "GooeyPopup")
	menu:SetWidth(230); menu:SetHeight(378)
	menu:SetScript("OnHide", function(self) self.anchor = nil; end)
	menu:SetScript("OnClick", function(self) self:Hide() end)
	menu:RegisterForClicks("anyUp")

	local title = menu:CreateFontString(name .. "Title", "ARTWORK")
	title:SetFontObject("GameFontHighlightLarge")
	title:SetPoint("TOP", menu, "TOP", 0, -8)
	title:SetText(L.FrameSettings)

	local close = CreateFrame("Button", name .. "Close", menu, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -1, -1)

	--checkbuttons
	local lock = CreateFrame("CheckButton", name .. "Lock", menu, "GooeyCheckButton")
	lock:SetPoint("TOPLEFT", menu, "TOPLEFT", 6, -30)
	lock:SetScript("OnClick", function(self) menu.anchor:Lock(self:GetChecked()) end)
	lock:SetText(L.Lock)

	local reverse = CreateFrame("CheckButton", name .. "Reverse", menu, "GooeyCheckButton")
	reverse:SetPoint("TOPLEFT", lock, "BOTTOMLEFT")
	reverse:SetScript("OnClick", function(self) SetReverseSort(menu.anchor, self:GetChecked()) end)
	reverse:SetText(L.ReverseSort)

	local topLevel = CreateFrame("CheckButton", name .. "TopLevel", menu, "GooeyCheckButton")
	topLevel:SetPoint("TOPLEFT", reverse, "BOTTOMLEFT")
	topLevel:SetScript("OnClick", function(self) SetToplevel(menu.anchor, self:GetChecked()) end)
	topLevel:SetText(L.Toplevel)

	local colorPicker = CreateFrame("Button", name .. "BGColor", menu, "GooeyColorPicker")
	colorPicker:SetPoint("TOPLEFT", topLevel, "BOTTOMLEFT", 4, 2)
	colorPicker:SetScript("OnClick", function() BGColor_OnClick(menu.anchor) end)
	colorPicker:SetText(L.BackgroundColor)

	--sliders
	local strata = Slider_Create(menu, "Level", 1, 3, 1, L.FrameLevel, SetFrameStrata, nil, STRATAS)
	strata:SetPoint("BOTTOM", menu, "BOTTOM", 0, 20)

	local alpha = Slider_Create(menu, "Opacity", 0, 100, 1, L.Opacity, SetFrameAlpha, true)
	alpha:SetPoint("BOTTOM", strata, "BOTTOM", 0, 40)

	local scale = Slider_Create(menu, "Scale", 50, 150, 1, L.Scale, SetFrameScale, true)
	scale:SetPoint("BOTTOM", alpha, "BOTTOM", 0, 40)

	local space = Slider_Create(menu, "Spacing", 0, 32, 1, L.Spacing, SetFrameSpacing)
	space:SetPoint("BOTTOM", scale, "BOTTOM", 0, 40)

	local cols = Slider_Create(menu, "Cols", 4, 40, 1, L.Cols, SetFrameColumns)
	cols:SetPoint("BOTTOM", space, "BOTTOM", 0, 40)

	return menu
end


--[[ Show Menu ]]--

BagnonMenu = {}

function BagnonMenu:Show(frame)
	if self.frame and self.frame.anchor == frame then
		return
	elseif not self.frame then
		self.frame = CreateMenu(MENU_NAME)
	end

	local menu = self.frame
	menu.anchor = frame

	menu.onShow = 1

	local sets = frame.sets

	--Set values
	getglobal(MENU_NAME .. "Lock"):SetChecked(frame:IsLocked())
	getglobal(MENU_NAME .. "TopLevel"):SetChecked(sets.topLevel)
	getglobal(MENU_NAME .. "Reverse"):SetChecked(sets.reverseSort)

	local r, g, b, a = frame:GetBackgroundColor()
	getglobal(MENU_NAME .. "BGColorNormalTexture"):SetVertexColor(r, g, b, a)

	local cols, spacing = frame:GetLayout()
	getglobal(MENU_NAME .. "Cols"):SetValue(cols)
	getglobal(MENU_NAME .. "Spacing"):SetValue(spacing)
	getglobal(MENU_NAME .. "Scale"):SetValue(frame:GetScale() * 100)
	getglobal(MENU_NAME .. "Opacity"):SetValue(frame:GetAlpha() * 100)
	getglobal(MENU_NAME .. "Level"):SetValue(ToIndex(frame:GetFrameStrata(), STRATAS))

	--place the frame at the player"s cursor
	local x, y = GetCursorPosition()
	x = x / UIParent:GetScale()
	y = y / UIParent:GetScale()

	menu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - 32, y + 48)
	menu:Show()

	menu.onShow = nil
end

function BagnonMenu:Hide()
	if self.frame then
		self.frame.anchor = nil
		self.frame:Hide()
	end
end

function BagnonMenu:GetAnchor()
	if self.frame then
		return self.frame.anchor
	end
end