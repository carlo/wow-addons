local playerClass = select(2,UnitClass("player"))
local playerHealer, playerCaster, playerMelee, playerHybrid
if playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "DRUID" then playerHealer = true end
if playerClass == "MAGE" or playerClass == "PRIEST" or playerClass == "WARLOCK" then playerCaster = true end
if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "SHAMAN" then playerHybrid = true end
if playerClass == "ROGUE" or playerClass == "WARRIOR" or playerClass == "HUNTER" then playerMelee = true end

local L = AceLibrary("AceLocale-2.2"):new("DrDamage")
local GT = AceLibrary("Gratuity-2.0")
local Deformat = AceLibrary("Deformat-2.0")
local BS
if GetLocale() ~= "enUS" then 
	BS = AceLibrary("Babble-Spell-2.2") 
end

--LOCAL COPIES OF FUNCTIONS
--General
local settings
local type = type
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local math_floor = math.floor
local math_max = math.max
local string_match = string.match
local select = select
local GetSpellName = GetSpellName
local UnitLevel = UnitLevel
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local Mana_Cost = MANA_COST
local UnitMana = UnitMana

--Core
local _G = getfenv(0)
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local GetSpellName = GetSpellName
local GetActionInfo = GetActionInfo
local HasAction = HasAction
local IsEquippedItem = IsEquippedItem
local DrD_Font = GameFontNormal:GetFont()
local playerCompatible
local updatingSpell, updateSetItems
local GetTime = GetTime
local dmgMod
local loadedTalents
DrDamage.visualChange = true

local function DrD_ClearTable( table )
	for k in pairs( table ) do
		table[k] = nil
	end
end

local function DrD_Round(x, y)
	return math_floor( x * 10 ^ y + 0.5 ) / 10 ^ y
end

local function DrD_MatchData( data, ... )
	if not data or not ... then
		return false
	end

	if type( data ) == "table" then
		for _, dataName in ipairs( data ) do
			for i = 1, select('#', ...) do
				if dataName == select(i, ...) then
					return true
				end
			end
		end
	else	
		for i = 1, select('#', ...) do
			if data == select(i, ...) then
				return true
			end
		end
	end
	
	return false
end

local function DrD_GetTextFrame( hide, ... )
	for i = 1, select('#', ...) do
		local frame = select(i, ...)
		if frame and frame:GetName() == "DrDamageText" and frame.text then
			if hide then frame.text:Hide() end
			return frame
		end
	end
end

local function DrD_Set( n, v, setOnly )
	return function(v) 
		settings[n] = v
		if not setOnly and not DrDamage:IsEventScheduled("UpdatingAB") then
			DrDamage:ScheduleEvent("UpdatingAB", DrDamage.UpdateAB, 1.0, DrDamage)
		end
	end
end

local ABstop, ABdefault, ABtable, ABgetID, ABglobalbutton, CTBar, ABdisable
local defaultBars = { "MultiBarBottomLeftButton", "MultiBarBottomRightButton","MultiBarRightButton", "MultiBarLeftButton" }
local function DrD_DetermineAB()
	if IsAddOnLoaded("Bartender3") then
		ABglobalbutton = "BT3Button"
		ABtable = Bartender3.actionbuttons
		ABgetID = function( button, index, ABtable )
					if ABtable[index] and ABtable[index].state == "used" then
						return ABtable[index].object:PagedID()
					end
		end	
	elseif IsAddOnLoaded( "Bongos2" ) then
		ABglobalbutton = "BongosActionButton"
		ABgetID = function( button ) return SecureButton_GetModifiedAttribute(button,"action",SecureStateChild_GetEffectiveButton(button)) end
	elseif IsAddOnLoaded( "Bongos" ) then
		ABglobalbutton = "BActionButton"
		ABgetID = function( button ) return SecureButton_GetModifiedAttribute(button,"action",SecureStateChild_GetEffectiveButton(button)) end
	elseif IsAddOnLoaded( "CogsBar" ) then
		ABglobalbutton = "CogsBarButton"
		ABgetID = function( button ) return SecureButton_GetModifiedAttribute(button,"action",SecureStateChild_GetEffectiveButton(button)) end
	elseif IsAddOnLoaded("TrinityBars") or IsAddOnLoaded("TrinityBars2") then
		ABglobalbutton = "TrinityActionButton"
		ABgetID = function( button ) return SecureButton_GetModifiedAttribute(button,"action",SecureStateChild_GetEffectiveButton(button)) end
	elseif IsAddOnLoaded("idActionbar") then
		ABglobalbutton = "idButton"
		ABgetID = function( button ) return SecureButton_GetModifiedAttribute(button,"action",SecureStateChild_GetEffectiveButton(button)) end
	elseif IsAddOnLoaded( "InfiniBar" ) or IsAddOnLoaded( "FlexBar2" ) then
		ABstop = true
	elseif IsAddOnLoaded("DiscordActionBars") then
		ABglobalbutton = "DAB_ActionButton_"
		ABgetID = function( button ) return button:GetActionID() end
	elseif IsAddOnLoaded("Nurfed") then
		ABglobalbutton = "Nurfed_Button"
		ABgetID = function( button )
			if button.type == "spell" and button.spell then
				local pos = string.find( button.spell, "[^%s][%(]" )
				if not pos then pos = string.len( button.spell ) end
				return nil, string.sub( button.spell, 1, pos ), string_match(button.spell,"%d+")
			elseif button.type == "macro" and button.spell then
				local action, rank = GetMacroSpell(button.spell)
				local pid
				if action and not GetMacroItem(button.spell) then
					pid = Nurfed:getspell(action) 
				end
				if pid then 
					return nil, action, rank 
				end
			end
		end	
	elseif IsAddOnLoaded("CT_BarMod") then
		CTBar = true
		ABtable = CT_BarMod.actionButtonList
		ABgetID = function( button, index, ABtable )
			if ABtable[index] and ABtable[index].hasAction then return index end
		end		
	else
		ABdefault = true
	end
end

--Defaults
local defaults = DrDamage.defaults
defaults.ABText = true
defaults.FontEffect = "OUTLINE"
defaults.FontSize = 10
defaults.FontXPosition = 0
defaults.FontYPosition = 0
defaults.FontColorDmg = { r = 1, g = 1, b = 0.2 }
defaults.FontColorHeal = { r = 0.4, g = 1.0, b = 0.3 }
defaults.UpdateShift = false
defaults.UpdateAlt = false
defaults.UpdateCtrl = false
defaults.BlizzardAB = false
defaults.AlwaysTooltip = true
defaults.NeverTooltip = false
defaults.AltTooltip = false
defaults.CtrlTooltip = false
defaults.ShiftTooltip = false
defaults.DefaultColor = false
DrDamage:RegisterDB("DrDamageDB");
DrDamage:RegisterDefaults("profile", defaults)

--FuBar options
DrDamage.name = "DrDamage"
DrDamage.title = "Dr. Damage"
DrDamage.hasNoColor = true
DrDamage.hasNoText = true
DrDamage.cannotDetachTooltip = true
DrDamage.hideWithoutStandby = true
DrDamage.independentProfile = true
DrDamage.blizzardTooltip = true
if playerMelee then DrDamage.hasIcon = "Interface\\Icons\\Ability_DualWield"
else DrDamage.hasIcon = "Interface\\Icons\\Spell_Holy_SearingLightPriest" end

function DrDamage:OnTooltipUpdate()
	GameTooltip:AddLine( "          Dr. Damage" )
	GameTooltip:AddLine( "Hint: Right-Click for options", 0, 1, 0, true )
end

function DrDamage:OnInitialize()
	settings = self.db.profile	

	self.options = { type='group', args = {} }
	self:RegisterChatCommand({ "/drdmg", "/drdamage" }, self.options)
	self.OnMenuRequest = self.options		

	if IsAddOnLoaded( "InfiniBar" ) then
		InfiniBar:RegisterTextSub("drd", "DrDamage_Update",
		function( bar, btn, options, updateSpells )
			if not playerCompatible then return false end
			local spellName, spellRank = bar:GetSpellNameAndRank( btn )
			if spellName and spellRank then
				if not updateSpells or DrD_MatchData( updateSpells, spellName ) then
					return self:CheckAction( nil, nil, nil, nil, spellName, spellRank )
				end
			end
			return false
		end)
	end
	
	-- data conversion for older options
	if settings["Display"] == true then
		settings["AlwaysTooltip"] = not settings["ShiftTooltip"]
		settings["Display"] = nil
	elseif settings["Display"] == false then
		settings["AlwaysTooltip"] = false
		settings["NeverTooltip"] = true
		settings["Display"] = nil
	end
end

function DrDamage:OnEnable()
	if IsAddOnLoaded("FlexBar2") and FlexBar2:HasModule("TextSubs") then
		FlexBar2:GetModule("TextSubs"):RegisterTextSub("drd", 
			function( Button)
				if not playerCompatible then return false end
				local Spell = Button:GetModifiedAttribute("spell");
				if(Spell and Spell ~= "") then
					-- Run the spell through GetSpellName to seperate Name & Rank and get the rank if its not specified
					local SpellName, SpellRank = GetSpellName(Spell);
					if(SpellRank) then
						_, _, SpellRank = string.find(SpellRank, "^.* (%d+)$");
						SpellRank = tonumber(SpellRank);
					end
					return self:CheckAction(nil, nil, nil, nil, SpellName, SpellRank);
				end
			end);		
	end

	if self.PlayerData then
		self.ClassSpecials = {}
		self.Calculation = {}
		self.DmgCalculation = {}
		self.FinalCalculation = {}
		self.SetBonuses = {}
		self.RelicSlot = {}
		self.talents = {}
		self:PlayerData()
		self.PlayerData = nil
	elseif not self.spellInfo and not self.talentInfo then
		return
	end
	
	self:OnProfileEnable()
	
	if self.GeneralOptions then
		self:GeneralOptions()
		self.GeneralOptions = nil
	end
	
	dmgMod = select(7, UnitDamage("player"))
	self.globalMod = dmgMod	
	
    	self:RegisterEvent("AceDB20_ResetDB")
    	self:RegisterEvent("AceEvent_FullyInitialized")
  	
  	if AceLibrary("AceEvent-2.0"):IsFullyInitialized() then
  		self:AceEvent_FullyInitialized()
  	end
end

function DrDamage:AceEvent_FullyInitialized()
	if self.Caster_OnEnable then
		self:Caster_OnEnable()
	end
	if self.Melee_OnEnable then
		self:Melee_OnEnable()
	end
	if DrD_DetermineAB then 
		DrD_DetermineAB()
		DrD_DetermineAB = nil
	end
	if self.Caster_InventoryChanged then
		self:Caster_InventoryChanged()
	end
	if self.Melee_InventoryChanged then
		self:Melee_InventoryChanged()
	end
	
	playerCompatible = true
	
	if not loadedTalents then
    		self:UpdateTalents()
    	else
    		self:UpdateAB()
    	end
	
	self:Hook(GameTooltip, "SetAction", true)
	self:SecureHook(GameTooltip, "SetSpell")   	
   	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
    	self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	
    	if settings.DisplayType == "Off" then
    		settings.ABText = false
    		settings.DisplayType = "Avg"
    	end

	if settings.UpdateAlt or settings.UpdateCtrl or settings.UpdateShift then
		self:RegisterEvent( "MODIFIER_STATE_CHANGED" )
	end    	

	if settings.ABText then
    		self:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
    		self:RegisterEvent("ACTIONBAR_HIDEGRID")
    		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    		self:RegisterEvent("PLAYER_TARGET_CHANGED")
    		self:RegisterEvent("UPDATE_MACROS")    	
		self:RegisterEvent( "SpecialEvents_PlayerBuffGained", "PlayerAuraUpdate" )
		self:RegisterEvent( "SpecialEvents_PlayerBuffCountChanged", "PlayerAuraUpdate" )
		self:RegisterEvent( "SpecialEvents_PlayerBuffLost", "PlayerAuraUpdate" )
		self:RegisterEvent( "SpecialEvents_PlayerDebuffGained", "PlayerAuraUpdate" )
		self:RegisterEvent( "SpecialEvents_PlayerDebuffCountChanged", "PlayerAuraUpdate" )
		self:RegisterEvent( "SpecialEvents_PlayerDebuffLost", "PlayerAuraUpdate" )
		
    		if playerHealer and self.HealingBuffs then
    			self:RegisterEvent( "SpecialEvents_UnitBuffGained", "TargetBuffUpdate" )
    			self:RegisterEvent( "SpecialEvents_UnitBuffCountChanged", "TargetBuffUpdate" )
    			self:RegisterEvent( "SpecialEvents_UnitBuffLost", "TargetBuffUpdate" )
    		end
    		if self.Debuffs then
    			self:RegisterEvent( "SpecialEvents_UnitDebuffGained", "TargetDebuffUpdate" )
    			self:RegisterEvent( "SpecialEvents_UnitDebuffCountChanged", "TargetDebuffUpdate" )
    			self:RegisterEvent( "SpecialEvents_UnitDebuffLost", "TargetDebuffUpdate" )
    		end
    	end
end

function DrDamage:OnDisable()
	if playerCompatible then
		local tempType = settings.ABText
		settings.ABText = false
		self:UpdateAB()
		settings.ABText = tempType
	end	
end

function DrDamage:OnProfileEnable()
	if self.Caster_OnProfileEnable then self:Caster_OnProfileEnable() end
	if self.Melee_OnProfileEnable then self:Melee_OnProfileEnable() end
	settings = self.db.profile
end

function DrDamage:GeneralOptions()
	self.options.args.General = {
		type = "group", 
		desc = L["General Options"], 
		name = L["General"],
		order = 1,
		args = {
			ABText = {
				type = 'toggle',
				name = L["Actionbar text on/off"],
				desc = L["Toggles the actionbar text on/off"],
				order = 70,
				get = function() return settings["ABText"] end,
				set = DrD_Set("ABText"),
			},		
			FontSize = {
				type = 'range',
				name = L["Actionbar font size"],
				desc = L["Set the font size"],
				min = 6,
				max = 20,
				step = 1,
				order = 75,
				get =  function() return settings["FontSize"] end,
				set = 	function(v) 
						settings.FontSize = v
						self.visualChange = true
						self:UpdateAB()
					end,
			},
			FontEffect = {
				type = "text",
				name = L["Actionbar font effect"],
				desc = L["Set the font effect"],
				validate = { L["Outline"], L["ThickOutline"], L["None"] },
				order = 77,
				get =	function()
	
						if settings.FontEffect == "" then
							return L["None"]
						elseif settings.FontEffect == "THICKOUTLINE" then
							return L["ThickOutline"]
						else
							return L["Outline"]
						end
					end,
				set = 	function(v)
						if v == L["None"] then
							settings.FontEffect = ""
						elseif v == L["ThickOutline"] then
							settings.FontEffect = "THICKOUTLINE"
						else
							settings.FontEffect = "OUTLINE"
						end

						self.visualChange = true
						self:UpdateAB()
					end,
			},				
			FontXPosition = {
				type = 'range',
				name = L["Actionbar font horizontal position"],
				desc = L["Set the font horizontal position"],
				min = -5,
				max = 5,
				step = 1,
				order = 80,
				get =  function() return settings["FontXPosition"] end,
				set = 	function(v) 
						settings.FontXPosition = v
						self.visualChange = true
						self:UpdateAB()
					end,
			},
			FontYPosition = {
				type = 'range',
				name = L["Actionbar font vertical position"],
				desc = L["Set the font vertical position"],
				min = -15,
				max = 30,
				step = 1,
				order = 85,
				get =  function() return settings["FontYPosition"] end,
				set = 	function(v) 
						settings.FontYPosition = v
						self.visualChange = true
						self:UpdateAB()
					end,
			},
			FontColorDmg = {
				type = "text",
				name = L["Damage text color"],
				desc = L["Set the actionbar damage text color"],
				usage = L["<r=n, g=n, b=n> where n is 0-1"],
				order = 90,
				get = function()
					return "r="..settings.FontColorDmg.r..", g="..settings.FontColorDmg.g..", b="..settings.FontColorDmg.b
				end,
				set = function(colors)
					for k, v in string.gmatch(string.lower(colors), "([r|g|b])=([%d\.]+)") do
						if tonumber(v) >= 0 and tonumber(v) <= 1 then
							settings.FontColorDmg[k] = v
						end
					end
					self.visualChange = true
					self:UpdateAB()						
				end
			},
			Update = {
				name = L["Update"],
				desc = L["Forces update to actionbar"],
				type = "execute",
				order = 110,
				func = function() self.visualChange = true, self:UpdateAB() end,
			},
			UpdateShift = {
				type = 'toggle',
				name = L["Updates actionbars on shift modifier key."],
	
				desc = L["Toggles updates on modifier key on/off."],
				order = 115,
				get =  function() return settings["UpdateShift"] end,
				set =  function(v)
						settings["UpdateShift"] = v
						if v then
							if not self:IsEventRegistered("MODIFIER_STATE_CHANGED") then
								self:RegisterEvent("MODIFIER_STATE_CHANGED")
							end
						elseif not settings.UpdateAlt and not settings.UpdateCtrl then
							self:UnregisterEvent("MODIFIER_STATE_CHANGED")
						end
					end,				
			},
			UpdateAlt = {
				type = 'toggle',
				name = L["Updates actionbars on alt modifier key."],
				desc = L["Toggles updates on modifier key on/off."],
				order = 120,
				get =  function() return settings["UpdateAlt"] end,
				set =  function(v)
						settings["UpdateAlt"] = v
						if v then
							if not self:IsEventRegistered("MODIFIER_STATE_CHANGED") then
								self:RegisterEvent("MODIFIER_STATE_CHANGED")
							end
						elseif not settings.UpdateCtrl and not settings.UpdateShift then
							self:UnregisterEvent("MODIFIER_STATE_CHANGED")
						end
					end,				
			}, 
			UpdateCtrl = {
				type = 'toggle',
				name = L["Updates actionbars on ctrl modifier key."],
				desc = L["Toggles updates on modifier key on/off."],
				order = 125,
				get =  function() return settings["UpdateCtrl"] end,
				set =  function(v)
						settings["UpdateCtrl"] = v
						if v then
							if not self:IsEventRegistered("MODIFIER_STATE_CHANGED") then
								self:RegisterEvent("MODIFIER_STATE_CHANGED")
							end
						elseif not settings.UpdateAlt and not settings.UpdateShift then
							self:UnregisterEvent("MODIFIER_STATE_CHANGED")
						end
					end,				
			}, 
			BlizzardAB = {
				type = 'toggle',
				name = L["Support for Blizzard AB even with other AB addons running."],
				desc = L["Toggles updating on for the default actionbar."],
				order = 130,
				get =  function() return settings["BlizzardAB"] end,
				set =  DrD_Set("BlizzardAB"),				
			},
			DisplayTooltip = {
				type = 'group',
				name = L["Display tooltip"],
				desc = L["Control when the tooltip is displayed"],
				order = 135,
				args = {
					Always = {
						type = 'toggle',
						name = L["Always"],
						desc = L["Always display the tooltip"],
						order = 101,
						get = function() return settings["AlwaysTooltip"] end,
						set = function(v)
							settings.AlwaysTooltip = v
							settings.NeverTooltip = not v
							settings.ShiftTooltip = false
							settings.CtrlTooltip = false
							settings.AltTooltip = false
	
						end,
					},
					Never = {
						type = 'toggle',
						name = L["Never"],
						desc = L["Never display the tooltip"],
						order = 102,
						get = function() return settings["NeverTooltip"] end,
						set = function(v)
							settings.AlwaysTooltip = not v
							settings.NeverTooltip = v
							settings.ShiftTooltip = false
							settings.CtrlTooltip = false
							settings.AltTooltip = false
						end,
					},
					Alt = {
						type = 'toggle',
						name = L["With Alt"],
						desc = L["Display tooltip when Alt is pressed"],
						order = 111,
						get = function() return settings["AltTooltip"] end,
						set = function(v)
							settings.NeverTooltip = false
							settings.AltTooltip = v
							if v then
								settings.AlwaysTooltip = false
							elseif not settings.CtrlTooltip and not settings.ShiftTooltip then
								settings.AlwaysTooltip = true
							end
						end,
					},
					Ctrl = {
						type = 'toggle',
						name = L["With Ctrl"],
						desc = L["Display tooltip when Ctrl is pressed"],
						order = 112,
						get = function() return settings["CtrlTooltip"] end,
						set = function(v)
							settings.NeverTooltip = false
							settings.CtrlTooltip = v
							if v then
								settings.AlwaysTooltip = false
							elseif not settings.AltTooltip and not settings.ShiftTooltip then
								settings.AlwaysTooltip = true
							end
						end,
					},
					Shift = {
						type = 'toggle',
						name = L["With Shift"],
						desc = L["Display tooltip when Shift is pressed"],
						order = 113,
						get = function() return settings["ShiftTooltip"] end,
						set = function(v)
							settings.NeverTooltip = false
							settings.ShiftTooltip = v
							if v then
								settings.AlwaysTooltip = false
							elseif not settings.CtrlTooltip and not settings.AltTooltip then
								settings.AlwaysTooltip = true
							end
						end,
					},
				},
			},
			DefaultColor = {
				type = 'toggle',
				name = L["Default tooltip colors"],
				desc = L["Toggles the default blizzard tooltip colors on/off"],
				order = 140,
				get = function() return settings["DefaultColor"] end,
				set = DrD_Set("DefaultColor", nil, true),
			},
		},
	}
	if playerHealer then
		self.options.args.General.args.FontColorHeal = {
			type = "text",
			name = L["Heal text color"],
			desc = L["Set the actionbar heal text color"],
			usage = L["<r=n, g=n, b=n> where n is 0-1"],
			order = 95,
			get = function()
				return "r="..settings.FontColorHeal.r..", g="..settings.FontColorHeal.g..", b="..settings.FontColorHeal.b
			end,
			set = function(colors)
				for k, v in string.gmatch(string.lower(colors), "([r|g|b])=([%d\.]+)") do
					if tonumber(v) >= 0 and tonumber(v) <= 1 then
						settings.FontColorHeal[k] = v
					end
				end
				self.visualChange = true 
				self:UpdateAB()
			end
		}
	end
end

--EVENTS:

--REQUIRES DELAY:
function DrDamage:ACTIONBAR_PAGE_CHANGED()
	if not self:IsEventScheduled("UpdatingAB") or updatingSpell then
		self:ScheduleEvent("UpdatingAB", self.UpdateAB, 0.2, self)
		self.visualChange = true
	end
end

function DrDamage:ACTIONBAR_HIDEGRID()
	if (not self:IsEventScheduled("UpdatingAB") or updatingSpell) and (GetCursorInfo() == "spell" or GetCursorInfo() == "macro") then
		self:ScheduleEvent("UpdatingAB", self.UpdateAB, 0.2, self)
		self.visualChange = true
	end
end

function DrDamage:UPDATE_SHAPESHIFT_FORM()
	if not self:IsEventScheduled("UpdatingAB") or updatingSpell then
		self:ScheduleEvent("UpdatingAB", self.UpdateAB, 0.5, self)
		self.visualChange = true
	end
end

--INSTANT FULL UPDATES
function DrDamage:CHARACTER_POINTS_CHANGED()
    	self:UpdateTalents()
end

function DrDamage:AceDB20_ResetDB( name, dab )
	if dab == self.db.name then
		self.visualChange = true
		self:UpdateAB()
	end
end

function DrDamage:UPDATE_MACROS()
	self:CancelScheduledEvent("UpdatingAB")
	self.visualChange = true
	self:UpdateAB()
end

function DrDamage:PLAYER_COMBO_POINTS()
	self:CancelScheduledEvent("UpdatingAB")
	self:UpdateAB()
end

function DrDamage:UNIT_INVENTORY_CHANGED( unit )
	if unit == "player" then
		if self.Caster_InventoryChanged then
			if self:Caster_InventoryChanged() then
				updateSetItems = true
				self:UpdateAB()
				return
			end
		end
		if self.Melee_InventoryChanged then
			if self:Melee_InventoryChanged() then
				updateSetItems = true
				self:UpdateAB()
				return
			end
		end
	end
end

--DELAY FOR EFFICIENCY
function DrDamage:PLAYER_TARGET_CHANGED()
	if not self:IsEventScheduled("UpdatingAB") or updatingSpell then
		self:ScheduleEvent("UpdatingAB", self.UpdateAB, 2, self)
	end
end

function DrDamage:PlayerAuraUpdate( buffName )
	local newDmgMod = select(7, UnitDamage("player"))
	local modUpdate
	
	if newDmgMod ~= dmgMod then
		dmgMod = newDmgMod
		self.globalMod = newDmgMod
		modUpdate  = true
	end
	
	if self:IsEventScheduled("UpdatingAB") and not updatingSpell then
		return
	end
	
	if modUpdate then
		self:UpdateAB()
		return
	end
	
	if self.Caster_CheckBaseStats then
		if self:Caster_CheckBaseStats() then
			self:UpdateAB()
			return
		end
	end
	if self.Melee_CheckBaseStats then
		if self:Melee_CheckBaseStats() then
			self:UpdateAB()
			return
		end
	end
	
	if BS and BS:HasReverseTranslation( buffName ) then
		buffName = BS:GetReverseTranslation( buffName )
	end
				
	if self.PlayerAura[buffName] then
		local updateSpell = self.PlayerAura[buffName].Spell
		
		if updatingSpell and updatingSpell == updateSpell or updateSpell then
			self:ScheduleEvent("UpdatingAB", self.UpdateAB, 0.5, self, updateSpell)
			updatingSpell = updateSpell
		else
			self:ScheduleEvent("UpdatingAB", self.UpdateAB, 0.5, self)
		end
	end
end

function DrDamage:TargetBuffUpdate( unitID, buffName )	
	if unitID == "target" then
		if self:IsEventScheduled("UpdatingAB") and not updatingSpell then
			return
		end
			
		if BS and BS:HasReverseTranslation( buffName ) then
			buffName = BS:GetReverseTranslation( buffName )
		end		
		
		if self.HealingBuffs[buffName] then
			local buff = self.HealingBuffs[buffName]

			if buff.Class and DrD_MatchData( buff.Class, playerClass ) or not buff.Class then
				local updateSpell = buff.Spell
				if updatingSpell and updatingSpell == updateSpell or updateSpell then
					self:ScheduleEvent("UpdatingAB", self.UpdateAB, 0.5, self, updateSpell )
					updatingSpell = updateSpell				
				else
					self:ScheduleEvent("UpdatingAB", self.UpdateAB, 1.0, self)
				end
			end
		end
	end
end

function DrDamage:TargetDebuffUpdate( unitID, buffName )	
	if unitID == "target" then
		if self:IsEventScheduled("UpdatingAB") and not updatingSpell then
			return
		end
			
		if BS and BS:HasReverseTranslation( buffName ) then
			buffName = BS:GetReverseTranslation( buffName )
		end		
		
		if self.Debuffs[buffName] then
			local debuff = self.Debuffs[buffName]
		
			if debuff.Class and DrD_MatchData( debuff.Class, playerClass ) or playerHealer and debuff.School == "Healing" or not debuff.Class and not debuff.School then
				local updateSpell = debuff.Spell
				if updatingSpell and updatingSpell == updateSpell or updateSpell then
					self:ScheduleEvent("UpdatingAB", self.UpdateAB, 0.75, self, updateSpell )
					updatingSpell = updateSpell				
				else
					self:ScheduleEvent("UpdatingAB", self.UpdateAB, 1.5, self)
				end
			end
		end
	end
end

local lastState = GetTime()
function DrDamage:MODIFIER_STATE_CHANGED( state )
	if (state == "LALT" or state == "RALT") and settings.UpdateAlt or (state == "LCTRL" or state == "RCTRL") and settings.UpdateCtrl or (state == "LSHIFT" or state == "RSHIFT") and settings.UpdateShift then
		if GetTime() - lastState < 0.3 then
			if self:IsEventScheduled("Modifier_UpdatingAB") then
				self:CancelScheduledEvent( "Modifier_UpdatingAB" )
				self.visualChange = false
			end
		else
			if not self:IsEventScheduled("Modifier_UpdatingAB") then
				self:ScheduleEvent("Modifier_UpdatingAB", self.UpdateAB, 0.3, self)
			end
			self.visualChange = true
		end
		lastState = GetTime()
	end
end

function DrDamage:UpdateTalents()
	DrD_ClearTable( self.talents )
	
	local talentTable
	
	if not loadedTalents then
		self.options.args.General.args.Talents = { type = "group", name = L["Modify Talents"], desc = L["Modify talents manually. Modified talents are not saved between sessions."], order = 145, args = {} }
		talentTable = self.options.args.General.args.Talents.args
		talentTable.Reset = { type = "execute", name = L["Reset Talents"], desc = L["Reset talents to your current talent configuration."], order = 1, func = function() self:UpdateTalents() end }
		loadedTalents = true
	end

	for t = 1, GetNumTalentTabs() do	
		for i = 1, GetNumTalents(t) do
			local l_nameTalent, _, _, _, currRank, maxRank = GetTalentInfo(t, i)
			local nameTalent
			
			if BS and BS:HasReverseTranslation(l_nameTalent) then
				nameTalent = BS:GetReverseTranslation(l_nameTalent)
			else
				nameTalent = l_nameTalent
			end
			
			if talentTable and self.talentInfo[nameTalent] and (self.talentInfo[nameTalent][1].Locale and DrD_MatchData( self.talentInfo[nameTalent][1].Locale, GetLocale() ) or not self.talentInfo[nameTalent][1].Locale) then
				talentTable[(l_nameTalent:gsub(" +", ""))] = {
						type = 'range',
						name = l_nameTalent,
						desc = L["Modify "] .. l_nameTalent,
						min = 0,
						max = maxRank,
						step = 1,
						order = i + (t-1) * 35,
						get =  function() 
								if self.talents[nameTalent] then
									return self.talents[nameTalent]
								else
									return 0
								end
							end,
						set = 	function(v) 
								if math_floor(v+0.5) == 0 then
									self.talents[nameTalent] = nil
								else
									self.talents[nameTalent] = math_floor(v+0.5)
								end
								self:UpdateAB()
							end,
				}
			end
			if currRank ~= 0 then
				if self.talentInfo[nameTalent] then
					if self.talentInfo[nameTalent][1].Locale then
						if DrD_MatchData( self.talentInfo[nameTalent][1].Locale, GetLocale() ) then
							self.talents[nameTalent] = currRank
						end
					else
						self.talents[nameTalent] = currRank
					end
					--self:Print("Talent name: " .. nameTalent .. " Points: " .. currRank )
				end
			end	    	    
		end
	end
	self:UpdateAB()
end

local SetItems = {}
function DrDamage:GetSetAmount(set)
	if not updateSetItems and SetItems[set] then
		return SetItems[set]
	end
	
	if updateSetItems then
		DrD_ClearTable( SetItems )
		updateSetItems = false
	end
	
	local amount = 0
	local setData = self.SetBonuses[set]
	if setData then
		for _, itemID in ipairs(setData) do
			if IsEquippedItem(itemID) then
				amount = amount + 1
			end
		end
	end
	SetItems[set] = amount
	return amount
end

function DrDamage:SetSpell( frame, slot )
	if settings.NeverTooltip or (not settings.AlwaysTooltip and not (settings.AltTooltip and IsAltKeyDown()) and not (settings.CtrlTooltip and IsControlKeyDown()) and not (settings.ShiftTooltip and IsShiftKeyDown())) then
		do return end
	end
	
	local spellName, spellRank = GetSpellName(slot,BOOKTYPE_SPELL)
	
	if spellRank then 
		spellRank = tonumber(string_match(spellRank, "%d+"))
	end
	if not spellRank then
		spellRank = "None"
	end

	if self.spellInfo[spellName] then
		local baseSpell = self.spellInfo[spellName][0]
		local tableSpell = self.spellInfo[spellName][spellRank] or self.spellInfo[spellName]["None"]
		if type(baseSpell) == "function" then spellName, baseSpell, tableSpell = baseSpell() end

		if tableSpell and not baseSpell.NoTooltip then	
			GT:SetSpell( slot, BOOKTYPE_SPELL )
			if playerCaster or playerHybrid and not baseSpell.Melee then
				self:CasterTooltip( frame, spellName, baseSpell, tableSpell )
			elseif playerMelee or playerHybrid and baseSpell.Melee then
				self:MeleeTooltip( frame, spellName, baseSpell, tableSpell )
			end
		end
	end
end

function DrDamage:SetAction( frame, slot )
	self.hooks[frame].SetAction(frame, slot)
	
	if settings.NeverTooltip or (not settings.AlwaysTooltip and not (settings.AltTooltip and IsAltKeyDown()) and not (settings.CtrlTooltip and IsControlKeyDown()) and not (settings.ShiftTooltip and IsShiftKeyDown())) then
		do return end
	end
	
	local gtype, pid = GetActionInfo(slot)

	if gtype == "spell" or gtype == "macro" then
		local spellName, spellRank
		
		if pid and gtype == "spell" then
			spellName, spellRank = GetSpellName(pid, BOOKTYPE_SPELL)
		else
			spellName, spellRank = frame:GetSpell()
			if not spellName then
				spellName = _G["GameTooltipTextLeft1"]:GetText()
			end
		end
	
		if spellRank then 
			spellRank = tonumber(string_match(spellRank, "%d+"))
		end
		if not spellRank then
			spellRank = "None"
		end
		
		if self.spellInfo[spellName] then
			local baseSpell = self.spellInfo[spellName][0]
			local tableSpell = self.spellInfo[spellName][spellRank] or self.spellInfo[spellName]["None"]
			if type(baseSpell) == "function" then spellName, baseSpell, tableSpell = baseSpell() end

			if tableSpell and not baseSpell.NoTooltip then
				GT:SetAction(slot)
				if playerCaster or playerHybrid and not baseSpell.Melee then
					self:CasterTooltip( frame, spellName, baseSpell, tableSpell )
				elseif playerMelee or playerHybrid and baseSpell.Melee then
					self:MeleeTooltip( frame, spellName, baseSpell, tableSpell )
				end
			end
		end
	end
end

local DrD_ProcessButton
function DrDamage:UpdateAB(updateSpell, manaUpdate)

	self:TriggerEvent("DrDamage_Update", updateSpell )
	if(IsAddOnLoaded("FlexBar2")) then
		for _, Button in pairs(FlexBar2.Buttons) do
			Button:UpdateTextSub("drd");
		end
	end	

	--[[	Used for debugging updates.
	if updateSpell then
		self:Print( "Update AB: Spell" )
		
		if type( updateSpell ) == "table" then
			for _, gar in ipairs( updateSpell ) do
				self:Print( "Updating: " .. gar )
			end
		else
			self:Print( "Updating: " .. updateSpell )
		end
	else
		self:Print( "Update AB: All" )
	end
	--]]

	if not ABdefault then
		if settings.BlizzardAB then 
			ABdefault = true 
		elseif ABstop then
			updatingSpell = nil
			return
		end
	end
	
	if ABglobalbutton then
		for i = 1, 120 do	
			DrD_ProcessButton(_G[ABglobalbutton..i], i, updateSpell, manaUpdate)
		end
	elseif CTBar then
		for i, list in pairs(ABtable) do
			DrD_ProcessButton(list.button, i, updateSpell, manaUpdate)
		end	
	end
	
	if ABdefault or CTBar then
		if ABdefault then
			if not settings.BlizzardAB and (CTBar or ABglobalbutton) then
				ABdisable = true
				ABdefault = false
			end
			for bar = 1, 4 do
				for i = 1, 12 do
					DrD_ProcessButton(_G[defaultBars[bar]..i], nil, updateSpell, manaUpdate, ABdisable)
				end
			end			
		end
		if _G["BonusActionBarFrame"]:IsVisible() then
			for i = 1, 12 do
				DrD_ProcessButton(_G["BonusActionButton"..i], nil, updateSpell, manaUpdate, ABdisable)
			end
		else
			for i = 1, 12 do		
				DrD_ProcessButton(_G["ActionButton"..i], nil, updateSpell, manaUpdate, ABdisable)
			end
		end
	end
					
	updatingSpell = nil
	self.visualChange = nil
	ABdisable = false
end

DrD_ProcessButton = function( button, index, updateSpell, manaUpdate, ABdisable )
	if not button then do return end end

	local textFrame = DrD_GetTextFrame(not updateSpell,button:GetChildren())
	
	if not settings.ABText or ABdisable then
		do return end
	end

	if button:IsVisible() then
		local id, spellName, spellRank, pid
		
		if not index then 
			id = ActionButton_GetPagedID(button)
		elseif ABgetID then
			id, spellName, spellRank, pid = ABgetID(button, index, ABtable) 
		end

		if id then
			if HasAction(id) then
				DrDamage:CheckAction(id, button, manaUpdate, updateSpell, nil, nil, textFrame)
			end
		elseif spellName and spellRank then
			DrDamage:CheckAction(nil, button, manaUpdate, updateSpell, spellName, spellRank, textFrame, pid)
		end
	end
end

local displayTypeTable = { ["Avg"] = 2, ["DPS"] = 3, ["DPSC"] = 4, ["AvgHit"] = 5, ["Min"] = 6, ["MaxHit"] = 7, ["AvgHitTotal"] = 8, ["Max"] = 9, ["DPM"] = 10, ["ManaCost"] = 11, ["TrueManaCost"] = 12, ["MPS"] = 13 }

function DrDamage:CheckAction(id, button, manaUpdate, updateSpell, spellName, spellRank, textFrame, pid)
	local gtype
	
	if not settings.ABText then return "" end
	
	if id then
		gtype, pid = GetActionInfo(id)

		if gtype == "spell" and pid then
			spellName, spellRank = GetSpellName(pid, BOOKTYPE_SPELL)
		elseif gtype == "macro" then
			GT:SetAction(id)
			spellName = GT:GetLine(1, false)
			spellRank = GT:GetLine(1, true)
		end
	end
	if spellName then
		if updateSpell then
			if not DrD_MatchData(updateSpell, spellName) then return end
			--self:Print( "Spell matched." )
		end	
	
		if self.ClassSpecials[spellName] then
			return self:SpecialSlot(self.ClassSpecials[spellName], spellRank, button, nil, textFrame)
		end
	
		if self.spellInfo[spellName] then
			local baseSpell = self.spellInfo[spellName][0]
			local tableSpell = self.spellInfo[spellName][(spellRank and tonumber(string_match(spellRank,"%d+"))) or "None"]
			if type(baseSpell) == "function" then spellName, baseSpell, tableSpell = baseSpell() end

			if tableSpell then
				if gtype == "macro" and button then
					local macroText = _G[button:GetName().."Name"]
					if macroText then macroText:Hide() end
					if CTBar then if button.name then button.name:SetText("") end end
				end			
			
				local text, healingSpell
				
				if playerCaster or playerHybrid and not baseSpell.Melee then
					healingSpell = baseSpell.Healing or DrD_MatchData(baseSpell.School, "Healing")
					local selector = displayTypeTable[settings.DisplayType] or 2

					if id or pid and not baseSpell.NoDPM then
						local casts
						if settings.CastsLeft and healingSpell or settings.CastsLeftDmg and not healingSpell then
							casts = true
						end
						if selector > 9 or casts then
							if id then GT:SetAction(id)
							else GT:SetSpell(pid, BOOKTYPE_SPELL) end
							if casts then
								local manaCost
								if GT:GetLine(2) and Mana_Cost then
									manaCost = Deformat(GT:GetLine(2), Mana_Cost)
								end
								if manaCost then
									manaCost = tonumber(manaCost)
									if manaCost > 0 then
										if UnitPowerType("player") == 0 then
											text = math.floor( UnitMana("player") / manaCost + 0.5 )
										else
											text = math.floor( self.lastMana / manaCost + 0.5 )
										end
									else
										text = "\226\136\158"
									end
								end
							else
								local values = select(10, self:RawNumbers( tableSpell, spellName, false, true ))
								text = values[settings.DisplayType]
							end
						end
					end
					if not text then
						if manaUpdate then
							return
						else
							if baseSpell.NoDPS and (selector == 3 or selector == 4) then selector = 2 end
							if selector > 9 then selector = 2 end
							text = math.floor((select(selector, self:RawNumbers(tableSpell, spellName)))+0.5)
						end
					else
						if type(text) == "number" then
							text = DrD_Round(text,1)
						end								
					end
				elseif playerMelee or playerHybrid and baseSpell.Melee then
					text = self:MeleeCalc( tableSpell, spellName )
				end

				if button then
					self:CreateABtext(button, text, healingSpell, textFrame)
				else
					if healingSpell then
           					return "|cff".. string.format("%02x%02x%02x", settings.FontColorHeal.r * 255, settings.FontColorHeal.g * 255, settings.FontColorHeal.b * 255).. text .. "|r"
					else
						return "|cff".. string.format("%02x%02x%02x", settings.FontColorDmg.r * 255, settings.FontColorDmg.g * 255, settings.FontColorDmg.b * 255).. text .. "|r"
					end
				end
			end				
		end
	end
end

function DrDamage:CreateABtext( button, text, healingSpell, frame, r, g, b )

	if not frame then
		frame = DrD_GetTextFrame(false,button:GetChildren())
	end
	
	if frame and self.visualChange or not frame then
		if not r then
			if healingSpell then
				local color = settings.FontColorHeal
				r,g,b = color.r, color.g, color.b
			else
				local color = settings.FontColorDmg
				r,g,b = color.r, color.g, color.b
			end
		end
	end		
	
	if frame then
		if self.visualChange then
			frame.text:SetFont(DrD_Font, settings.FontSize, settings.FontEffect)
			frame.text:SetPoint("BOTTOMLEFT", frame ,"BOTTOMLEFT", -10 + settings.FontXPosition, settings.FontYPosition + 5)
			frame.text:SetPoint("BOTTOMRIGHT", frame ,"BOTTOMRIGHT", 10 + settings.FontXPosition, settings.FontYPosition + 5)
			frame.text:SetTextColor(r,g,b)	
		end
		frame.text:SetText(text)
		frame.text:Show()
	else
		local dpsText = CreateFrame("Frame", "DrDamageText", button)
		dpsText:SetAllPoints(button)
		dpsText:SetFrameLevel(dpsText:GetFrameLevel() + 1)
		dpsText.text = dpsText:CreateFontString( nil, "OVERLAY")
		dpsText.text:SetPoint("BOTTOMLEFT", dpsText ,"BOTTOMLEFT", -10 + settings.FontXPosition, settings.FontYPosition + 5)
		dpsText.text:SetPoint("BOTTOMRIGHT", dpsText ,"BOTTOMRIGHT", 10 + settings.FontXPosition, settings.FontYPosition + 5)
		dpsText.text:SetFont(DrD_Font, settings.FontSize, settings.FontEffect)
		dpsText.text:SetJustifyH("CENTER")
		dpsText.text:SetTextColor(r,g,b)
		dpsText.text:SetText(text)
		dpsText.text:Show()
		
		--Fix to properly inherit parent alpha
		if button:GetAlpha() == 0 then
			button:SetAlpha(0.01)
			button:SetAlpha(0)
		end
	end
end

function DrDamage:SpecialSlot( func, rank, button, healingSpell, textFrame )
	if rank then rank = tonumber(string_match(rank,"%d+")) end
	local text, r, g, b = func(rank)
	if type(text) == "number" then text = math_floor(text + 0.5) end
	if button and text then 
		self:CreateABtext(button, text, healingSpell, textFrame, r, g, b)
	elseif text then 
		if r then
			return "|cff".. string.format("%02x%02x%02x", r * 255, g * 255, b * 255) .. text .. "|r"
		else
			return "|cff".. string.format("%02x%02x%02x", settings.FontColorDmg.r * 255, settings.FontColorDmg.g * 255, settings.FontColorDmg.b * 255) .. text .. "|r"
		end
	end
end

--Credits to the author of RatingBuster (Whitetooth) for the formula!
local ratingTypes = { ["Hit"] = 8, ["Crit"] = 14, ["MeleeHit"] = 10 }
function DrDamage:GetRating( rType, convertR, full )
	local playerLevel = UnitLevel("player")
	local base = ratingTypes[rType]
	local rating, value

	if playerLevel <= 60 then
		rating = base * (math.max(10,playerLevel) - 8) / 52
	elseif playerLevel <= 70 then
		rating = base * 82 / (262 - 3 * playerLevel)
	end

	value = convertR and convertR/rating or rating
	value = full and value or DrD_Round(value,2)
	return value
end

function DrDamage:GetLevels()
	local targetLevel = UnitLevel("target")
	local playerLevel = UnitLevel("player")
	
	if targetLevel == -1 then
		if playerLevel >= 60 then 
			targetLevel = 73
		else
			targetLevel = playerLevel + 10
		end
	end
	
	local lvlDiff = math.min(10, targetLevel - playerLevel)
	return lvlDiff, playerLevel, targetLevel
end

local oldRangedItem
function DrDamage:CheckRelicSlot()
	local newRangedItem
	if GetInventoryItemLink("player", GetInventorySlotInfo("RangedSlot")) then
		newRangedItem = GetItemInfo(GetInventoryItemLink("player", GetInventorySlotInfo("RangedSlot")))
	end
	if newRangedItem ~= oldRangedItem then
		oldRangedItem = newRangedItem
		return true
	end
end

function DrDamage:GetSpellInfo( spellName, spellRank )
	if spellName and spellRank then
		if self.spellInfo and self.spellInfo[spellName] then
			return self.spellInfo[spellName][spellRank] or self.spellInfo[spellName]["None"]
		end
	end
end
