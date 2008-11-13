--[[
	Menu.lua
		Scripts for creating the main options menu for Bagnon
--]]
local BUTTON_SIZE = 32
local L = BAGNON_OPTIONS_LOCALS

--[[
	A toggle is simply a checkbox that sets a saved variable,
	it may perform an action after being checked
--]]

local function Toggle_OnShow(self)
	self:SetChecked(Bagnon.sets[self.var])
end

local function Toggle_OnClick(self)
	if self:GetChecked() then
		Bagnon.sets[self.var] = 1
	else
		Bagnon.sets[self.var] = nil
	end

	if self.PostClick then
		self:PostClick()
	end
end

local function Toggle_Create(parent, title, var, PostClick, tip)
	local button = CreateFrame('CheckButton', nil, parent, 'GooeyCheckButton')
	button:SetScript('OnShow', Toggle_OnShow)
	button:SetScript('OnClick', Toggle_OnClick)
	if PostClick then
		button:SetScript('PostClick', PostClick)
	end

	button.var = var
	button:SetText(title)
	button:SetChecked(Bagnon.sets[var])

	return button
end


--[[
	An event button has an event, and then a checkbox for the bag and bank frame attached to it
	Its used to determine under what events the bags/bank should automatically show
--]]

local function EventButton_Create(parent, type, isBank)
	local button = CreateFrame('CheckButton', nil, parent, 'GooeyCheckButton')
	button:SetScript('OnShow', Toggle_OnShow)
	button:SetScript('OnClick', Toggle_OnClick)

	if isBank then
		button.var = format('showBankAt%s', type)
	else
		button.var = format('showBagsAt%s', type)
	end
	button:SetChecked(Bagnon.sets[button.var])

	return button
end

local function EventFrame_Create(parent, text, type)
	local frame = CreateFrame('Frame', nil, parent)
	frame.type = type

	local bags = EventButton_Create(frame, type)
	local bank = EventButton_Create(frame, type, true)
	bank:SetPoint('RIGHT')
	bags:SetPoint('RIGHT', bank, 'LEFT', -6, 0)

	local title = frame:CreateFontString('ARTWORK')
	title:SetJustifyH('LEFT')
	title:SetPoint('LEFT')
	title:SetFontObject('GameFontNormalSmall')
	title:SetText(text)

	return frame
end


--[[ Frame Constructor ]]--

local function CreateToggleFrames(parent)
	local frames = {}

	table.insert(frames, Toggle_Create(parent, L.ShowBorders, 'showBorders', function()
		local bags = Bagnon:GetInventory()
		if bags and bags:IsShown() then
			bags:Regenerate()
		end

		local bank = Bagnon:GetBank()
		if bank and bank:IsShown() then
			bank:Regenerate()
		end
	end))

	table.insert(frames, Toggle_Create(parent, L.ReplaceBags, 'replaceBags'))
	table.insert(frames, Toggle_Create(parent, L.ReplaceBank, 'replaceBank'))
	table.insert(frames, Toggle_Create(parent, L.ReuseFrames, 'reuseFrames', ReloadUI))

	return frames
end

local function CreateEventFrames(parent)
	local frames = {}
	table.insert(frames, EventFrame_Create(parent, L.AtBank, 'Bank'))
	table.insert(frames, EventFrame_Create(parent, L.AtVendor, 'Vendor'))
	table.insert(frames, EventFrame_Create(parent, L.AtAH, 'AH'))
	table.insert(frames, EventFrame_Create(parent, L.AtMail, 'Mail'))
	table.insert(frames, EventFrame_Create(parent, L.AtTrade, 'Trade'))
	table.insert(frames, EventFrame_Create(parent, L.AtCraft, 'Craft'))
	return frames
end

local function CreateOptionsMenu(name)
	local frame = CreateFrame('Frame', name, UIParent, 'GooeyFrame')
	frame:EnableMouse(true)

	frame:SetFrameStrata('DIALOG')
	frame:SetMovable(true)
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)

	frame:SetWidth(254)
	frame:SetHeight(416 - 34)
	frame:SetPoint('LEFT')
	local titleRegion = frame:CreateTitleRegion()
	titleRegion:SetAllPoints(frame)

	--title
	local title = frame:CreateFontString('ARTWORK')
	title:SetFontObject('GameFontHighlightLarge')
	title:SetText(L.Title)
	title:SetPoint('TOP', 0, -10)

	--close button
	local close = CreateFrame('Button', name .. 'Close', frame, 'UIPanelCloseButton')
	close:SetPoint('TOPRIGHT', -2, -2)

	--create and layout all the toggle checkbuttons
	local toggles = CreateToggleFrames(frame)
	toggles[1]:SetPoint('TOPLEFT', 6, -32)
	for i = 2, #toggles do
		toggles[i]:SetPoint('TOPLEFT', toggles[i-1], 'BOTTOMLEFT')
	end

	--Create the Show Bags Bank divider
	local show = frame:CreateFontString('ARTWORK')
	show:SetFontObject('GameFontHighlight')
	show:SetText(L.Show)
	show:SetPoint('TOPLEFT', toggles[#toggles], 'BOTTOMLEFT', 6, -8)

	local bank = frame:CreateFontString('ARTWORK')
	bank:SetFontObject('GameFontHighlight')
	bank:SetText(L.Bank)
	bank:SetPoint('RIGHT', show, 'LEFT', frame:GetWidth() - 24, 0)

	local bags = frame:CreateFontString('ARTWORK')
	bags:SetFontObject('GameFontHighlight')
	bags:SetText(L.Bags)
	bags:SetPoint('RIGHT', bank, 'LEFT', -12, 0)

	--create and layout  all the event checkboxes
	local eFrames = CreateEventFrames(frame)
	eFrames[1]:SetPoint('TOPLEFT', show, 'BOTTOMLEFT', 0, -4)
	eFrames[1]:SetPoint('BOTTOMRIGHT', bank, 'BOTTOMRIGHT', 2, -(32 + 4))

	for i = 2, #eFrames do
		eFrames[i]:SetPoint('TOPLEFT', eFrames[i-1], 'BOTTOMLEFT')
		eFrames[i]:SetPoint('BOTTOMRIGHT', eFrames[i-1], 'BOTTOMRIGHT', 0, -32)
	end
end
CreateOptionsMenu('BagnonOptions')