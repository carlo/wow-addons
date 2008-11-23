--[[
	Action Button Template
	
	Note:
	Some IDs produce a special behaviour!
		- Button ID 132 (Last Button in Possess Bar) Creates a Leave Vehicle Button
]]

local specialButtons = {
	[132] = { script = "/script VehicleExit();", icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield", tooltip = LEAVE_VEHICLE}, -- Vehicle Leave Button
}

local Button = CreateFrame("CheckButton")
local Button_MT = {__index = Button}

local onEnter, onLeave, onUpdate, onDragStart, onReceiveDrag

-- upvalues
local _G = _G
local format = string.format
local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange

local LBF = LibStub("LibButtonFacade", true)
local KeyBound = LibStub("LibKeyBound-1.0")

Bartender4.Button = {}
Bartender4.Button.prototype = Button
Button.BT4init = true
function Bartender4.Button:Create(id, parent)
	local absid = (parent.id - 1) * 12 + id
	local name =  ("BT4Button%d"):format(absid)
	local button = setmetatable(CreateFrame("CheckButton", name, parent, "ActionBarButtonTemplate"), Button_MT)
	-- work around for "blocked" message when using /click macros
	GetClickFrame(name)
	
	-- Backwards Compat to pre-4.2.0 button names/layout
	_G[name .. "Secure"] = button
	button.Secure = button
	
	button.rid = id
	button.id = absid
	button.parent = parent
	button.stateactions = {}
	
	button:SetRealNormalTexture("")
	local oldNT = _G[("%sNormalTexture"):format(name)]
	oldNT:Hide()
	
	button.normalTexture = button:CreateTexture(("%sBTNT"):format(name))
	button.normalTexture:SetWidth(66)
	button.normalTexture:SetHeight(66)
	button.normalTexture:ClearAllPoints()
	button.normalTexture:SetPoint("CENTER", 0, -1)
	button.normalTexture:Show()

	
	--button:SetFrameStrata("MEDIUM")
	
	-- overwrite some scripts with out customized versions
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnUpdate", onUpdate)
	button:SetScript("OnDragStart", onDragStart)
	button:SetScript("OnReceiveDrag", onReceiveDrag)
	
	button.icon = _G[("%sIcon"):format(name)]
	button.border = _G[("%sBorder"):format(name)]
	button.cooldown = _G[("%sCooldown"):format(name)]
	button.macroName = _G[("%sName"):format(name)]
	button.hotkey = _G[("%sHotKey"):format(name)]
	button.count = _G[("%sCount"):format(name)]
	button.flash = _G[("%sFlash"):format(name)]
	button.flash:Hide()
	
	button:SetAttribute("type", "action")
	button:SetAttribute("action", absid)
	button:SetAttribute("useparent-unit", nil);
	button:SetAttribute("useparent-actionpage", nil);
	
	button:UpdateSelfCast()
	
	button:SetAttribute('_childupdate-state', [[
		self:SetAttribute("state", message)
		local action = self:GetAttribute("action-" .. message)
		local special = self:GetAttribute("special-" .. tostring(action))
		if special then
			self:SetAttribute("type", "macro")
			self:SetAttribute("macrotext", special)
			if not self:GetAttribute("isSpecial") then
				self:SetAttribute("showgrid", self:GetAttribute("showgrid") + 1)
				self:SetAttribute("isSpecial", true)
			end
		elseif action > 120 and action <= 126 then
			self:SetAttribute("type", "click")
		else
			self:SetAttribute("type", "action")
			if self:GetAttribute("isSpecial") then
				self:SetAttribute("isSpecial", nil)
				self:SetAttribute("showgrid", max(0, self:GetAttribute("showgrid") - 1))
			end
		end
		self:SetAttribute("action", action)
		
		local unit = nil
		-- fix unit on state change
		if action <= 120 then
			if self:GetAttribute("assisttype-"..message) == 1 then
				unit = G_assist_help
			elseif self:GetAttribute("assisttype-"..message) == 2 then
				unit = G_assist_harm
			end
		end
		self:SetAttribute("unit", unit)
		G_state = message
		G_action = action
	]])
	
	button:SetAttribute('_childupdate-assist-help', [[
		if self:GetAttribute("assisttype-"..G_state) == 1 and G_action <= 120 then
			self:SetAttribute("unit", message)
		end
		G_assist_help = message
	]])
	
	button:SetAttribute('_childupdate-assist-harm', [[
		if self:GetAttribute("assisttype-"..G_state) == 2 and G_action <= 120 then
			self:SetAttribute("unit", message)
		end
		G_assist_harm = message
	]])
	
	for k,v in pairs(specialButtons) do
		button:SetAttribute("special-" .. tostring(k), v.script)
	end
	
	if LBF and parent.LBFGroup then
		local group = parent.LBFGroup
		group:AddButton(button)
	end
	
	if button.parent.config.showgrid then
		button:ShowGrid()
	end
	
	--self:UpdateAction(true)
	button:UpdateHotkeys()
	button:UpdateUsable()
	button:UpdateGrid()
	button:ToggleButtonElements()
	
	return button
end

function onDragStart(self)
	if InCombatLockdown() then return end
	if not Bartender4.db.profile.buttonlock or IsModifiedClick("PICKUPACTION") then
		PickupAction(self.action)
		ActionButton_UpdateState(self)
		ActionButton_UpdateFlash(self)
		self:RefreshStateAction()
	end
end

function onReceiveDrag(self)
	if InCombatLockdown() then return end
	PlaceAction(self.action)
	ActionButton_UpdateState(self)
	ActionButton_UpdateFlash(self)
	self:RefreshStateAction()
end

function onEnter(self)
	if not (Bartender4.db.profile.tooltip == "nocombat" and InCombatLockdown()) and Bartender4.db.profile.tooltip ~= "disabled" then
		self:SetTooltip(self)
	end
	KeyBound:Set(self)
end

local oor, oorcolor, oomcolor

function onUpdate(self, elapsed)
	if self.flashing == 1 then
		self.flashtime = self.flashtime - elapsed
		if self.flashtime <= 0 then
			local overtime = -self.flashtime
			if overtime >= ATTACK_BUTTON_FLASH_TIME then
				overtime = 0
			end
			self.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime
			
			local flashTexture = self.flash
			if flashTexture:IsShown() then
				flashTexture:Hide()
			else
				flashTexture:Show()
			end
		end
	end
	
	if self.rangeTimer then
		self.rangeTimer = self.rangeTimer - elapsed
		if self.rangeTimer <= 0 then
			local valid = IsActionInRange(self.action)
			local hotkey = self.hotkey
			local hkshown = (hotkey:GetText() == RANGE_INDICATOR and oor == "hotkey")
			if valid and hkshown then
				hotkey:Show()
			elseif hkshown then
				hotkey:Hide()
			end
			self.outOfRange = (valid == 0)
			self:UpdateUsable()
			self.rangeTimer = TOOLTIP_UPDATE_TIME
		end
	end
end

local function updateIcon(self)
	if self.BT4init and self.action then
		if specialButtons[self.action] then
			self.normalTexture:SetTexCoord(0, 0, 0, 0)
			self.icon:SetTexture(specialButtons[self.action].icon)
			self.icon:Show()
			self:UpdateUsable()
		else
			if GetActionTexture(self.action) then
				self.normalTexture:SetTexCoord(0, 0, 0, 0)
			else
				self.normalTexture:SetTexCoord(-0.15, 1.15, -0.15, 1.17)
			end
		end
	end
end
hooksecurefunc("ActionButton_Update", updateIcon)

Button.SetRealNormalTexture = Button.SetNormalTexture
function Button:SetNormalTexture(...)
	self.normalTexture:SetTexture(...)
end

Button.GetRealNormalTexture = Button.GetNormalTexture
function Button:GetNormalTexture()
	return self.normalTexture
end

function Button:ClearStateAction()
	for state in pairs(self.stateactions) do
		self.stateactions = {}
		for i=0,10 do
			self:SetAttribute("action-" .. i, nil)
		end
	end
end

function Button:SetStateAction(state, action)
	self.stateactions[state] = action
	self:RefreshStateAction(state)
end

function Button:RefreshAllStateActions()
	self.stateconfig = {}
	for state in pairs(self.stateactions) do
		self:RefreshStateAction(state)
	end
end

function Button:RefreshStateAction(state)
	local state = tonumber(state or self:GetAttribute("state") or 0)
	local action = self.stateactions[state]
	self:SetAttribute("action-"..state, action)
	
	if action > 120 and action <= 126 then
		self:SetAttribute("clickbutton", _G["VehicleMenuBarActionButton"..tostring(action-120)])
	end
	
	self:SetAttribute("assisttype-"..state, nil)
	self:SetAttribute("unit", nil)
	if self.parent.config.autoassist then
		local type, id, subtype = GetActionInfo(action)
		if type == "spell" and id > 0 then
			if IsHelpfulSpell(id, subtype) then
				self:SetAttribute("assisttype-"..state, 1)
			elseif IsHarmfulSpell(id, subtype) then
				self:SetAttribute("assisttype-"..state, 2)
			end
		end
	end
	self:UpdateRightClickSelfCast()
end

function Button:UpdateSelfCast()
	self:SetAttribute("checkselfcast", Bartender4.db.profile.selfcastmodifier and true or nil)
	self:SetAttribute("checkfocuscast", Bartender4.db.profile.focuscastmodifier and true or nil)
end

function Button:UpdateRightClickSelfCast()
	self:SetAttribute("unit2", Bartender4.db.profile.selfcastrightclick and "player" or nil)
end

function Button:GetActionID()
	return self.action
end

function Button:Update()
	self:UpdateAction(true)
	self:UpdateHotkeys()
	self:ToggleButtonElements()
end

function Button:UpdateAction(force)
	ActionButton_UpdateAction(self)
end

function Button:ToggleButtonElements()
	if self.parent.config.hidemacrotext then
		self.macroName:Hide()
	else
		self.macroName:Show()
	end
end

orig_ActionButton_UpdateHotkeys = ActionButton_UpdateHotkeys
ActionButton_UpdateHotkeys = function(self, ...)
	local name = self:GetName()
	if name and name:find("^BT4Button") then
		if self.BT4init then
			self:UpdateHotkeys()
		end
	else
		orig_ActionButton_UpdateHotkeys(self, ...)
	end
end

function Button:UpdateHotkeys()
	local key = self:GetHotkey() or ""
	local hotkey = self.hotkey
	
	if key == "" or self.parent.config.hidehotkey then
		hotkey:SetText(RANGE_INDICATOR)
		hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2)
		hotkey:Hide()
	else
		hotkey:SetText(key)
		hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", -2, -2)
		hotkey:Show()
	end
end

function Button:GetHotkey()
	local key = ((self.id <= 12) and GetBindingKey(format("ACTIONBUTTON%d", self.id))) or GetBindingKey("CLICK "..self:GetName()..":LeftButton")
	return key and KeyBound:ToShortKey(key)
end

function Button:GetBindings()
	local keys, binding = ""
	
	if self.id <= 12 then
		binding = format("ACTIONBUTTON%d", self.id)
		for i = 1, select('#', GetBindingKey(binding)) do
			local hotKey = select(i, GetBindingKey(binding))
			if keys ~= "" then
				keys = keys .. ', '
			end
			keys = keys .. GetBindingText(hotKey,'KEY_')
		end
	end
	
	binding = "CLICK "..self:GetName()..":LeftButton"
	for i = 1, select('#', GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ', '
		end
		keys = keys .. GetBindingText(hotKey,'KEY_')
	end

	return keys
end

function Button:SetKey(key)
	if self.id <= 12 then
		SetBinding(key, format("ACTIONBUTTON%d", self.id))
	else
		SetBindingClick(key, self:GetName(), 'LeftButton')
	end
end

function Button:ClearBindings()
	if self.id <= 12 then
		local binding = format("ACTIONBUTTON%d", self.id)
		while GetBindingKey(binding) do
			SetBinding(GetBindingKey(binding), nil)
		end
	end
	local binding = "CLICK "..self:GetName()..":LeftButton"
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

local actionTmpl = "BT4 Bar %d Button %d"
function Button:GetActionName()
	return format(actionTmpl, self.parent.id, self.rid)
end

hooksecurefunc("ActionButton_UpdateUsable", function(self)
	if self.BT4init then
		self:UpdateUsable()
	end
end)

function Button:UpdateUsable(force)
	local isUsable, notEnoughMana = IsUsableAction(self.action)
	local icon, hotkey = self.icon, self.hotkey
	if force or not oor then
		oor = Bartender4.db.profile.outofrange
		oorcolor, oomcolor = Bartender4.db.profile.colors.range, Bartender4.db.profile.colors.mana
	end
	
	if oor == "button" and self.outOfRange then
		icon:SetVertexColor(oorcolor.r, oorcolor.g, oorcolor.b)
		hotkey:SetVertexColor(1.0, 1.0, 1.0)
	else
		if oor == "hotkey" and self.outOfRange then
			hotkey:SetVertexColor(oorcolor.r, oorcolor.g, oorcolor.b)
		else
			hotkey:SetVertexColor(1.0, 1.0, 1.0)
		end
		
		if isUsable or specialButtons[self.action] then
			icon:SetVertexColor(1.0, 1.0, 1.0)
		elseif notEnoughMana then
			icon:SetVertexColor(oomcolor.r, oomcolor.g, oomcolor.b)
		else
			icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	end
end

function Button:SetTooltip()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	
	if specialButtons[self.action] then
		GameTooltip:SetText(specialButtons[self.action].tooltip)
		self.UpdateTooltip = self.SetTooltip
	else
		if ( GameTooltip:SetAction(self.action) ) then
			self.UpdateTooltip = self.SetTooltip
		else
			self.UpdateTooltip = nil
		end
	end
end

function Button:UpdateGrid()
	if self:GetAttribute("showgrid") > 0 then
		ActionButton_ShowGrid(self)
	else
		ActionButton_HideGrid(self)
	end
end

function Button:ShowGrid()
	if not self.gridShown then
		self.gridShown = true
		self:SetAttribute("showgrid", self:GetAttribute("showgrid") + 1)
		self:UpdateGrid()
	end
end

function Button:HideGrid()
	if self.gridShown then
		self.gridShown = nil
		self:SetAttribute("showgrid", max(0, self:GetAttribute("showgrid") - 1))
		self:UpdateGrid()
	end
end

function Button:ClearSetPoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end
