--[[
Name: AutoBar
Author: Toadkiller of Proudmoore
Credits: Saien the original author.  Sayclub (Korean), PDI175 (Chinese traditional and simplified), Teodred (German), Cinedelle (French), shiftos (Spanish)
Website: http://www.wowace.com/
Description: Dynamic 24 button bar automatically adds potions, water, food and other items you specify into a button for use. Does not use action slots so you can save those for spells and abilities.
]]
local REVISION = tonumber(("$Revision: 38120 $"):match("%d+"))
local DATE = ("$Date: 2007-05-31 17:44:03 -0400 (Thu, 31 May 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
--
-- Copyright 2004, 2005, 2006 original author.
-- New Stuff Copyright 2006+ Toadkiller of Proudmoore.

-- Maintained by Azethoth / Toadkiller of Proudmoore.  Original author Saien of Hyjal
-- http://code.google.com/p/autobar/

-- Coming Attractions:
-- Set operations / calculated categories.
-- Multible bars or individually draggable buttons?
-- Exchange profiles
-- Hide Microbuttons option
-- Indication of when an object being edited is obscured by a higher layer.
-- Named Custom Categories, Named button ranges.
-- Inventory & Instance checks
-- Buff detection: Don't show buff items if buffed already
-- Crafting slots
-- Full Mount support, including stance switching

-- Next Up:
-- AceDB
-- Dragging items to category select inserts first matched category instead of a custom item.

-- Hide slot option
-- OnClick: if slot is empty and more items available move them over.
-- Direct drag slot
-- Food Blend for pets.
-- Popup on Shift
-- Finish spell button conversion
-- Data versioning & verification
-- Shaman Totems by earth air fire water, rearrange on use
-- Split out ItemList as a translation / grouping / priority layer on top of PT3
-- Deal with charges: display them use smaller charged items first.
-- Named Slots
-- FuBar support & Ace db

-- See Changelist.lua for changes


local _G = getfenv(0);
local L = AceLibrary("AceLocale-2.2"):new("AutoBar");
local BS = AceLibrary:GetInstance("Babble-Spell-2.2");
local AceOO = AceLibrary("AceOO-2.0")
local AceEvent = AceLibrary("AceEvent-2.0")

AUTOBAR_MAXBUTTONS = 24;
AUTOBAR_MAXPOPUPBUTTONS = 12;
AUTOBAR_MAXSLOTCATEGORIES = 16;

BINDING_HEADER_AUTOBAR_SEP = L["AUTOBAR"];
BINDING_NAME_AUTOBAR_CONFIG = L["CONFIG_WINDOW"];
BINDING_NAME_AUTOBAR_BUTTON1 = L["BUTTON"] .. " 1";
BINDING_NAME_AUTOBAR_BUTTON2 = L["BUTTON"] .. " 2";
BINDING_NAME_AUTOBAR_BUTTON3 = L["BUTTON"] .. " 3";
BINDING_NAME_AUTOBAR_BUTTON4 = L["BUTTON"] .. " 4";
BINDING_NAME_AUTOBAR_BUTTON5 = L["BUTTON"] .. " 5";
BINDING_NAME_AUTOBAR_BUTTON6 = L["BUTTON"] .. " 6";
BINDING_NAME_AUTOBAR_BUTTON7 = L["BUTTON"] .. " 7";
BINDING_NAME_AUTOBAR_BUTTON8 = L["BUTTON"] .. " 8";
BINDING_NAME_AUTOBAR_BUTTON9 = L["BUTTON"] .. " 9";
BINDING_NAME_AUTOBAR_BUTTON10 = L["BUTTON"] .. " 10";
BINDING_NAME_AUTOBAR_BUTTON11 = L["BUTTON"] .. " 11";
BINDING_NAME_AUTOBAR_BUTTON12 = L["BUTTON"] .. " 12";
BINDING_NAME_AUTOBAR_BUTTON13 = L["BUTTON"] .. " 13";
BINDING_NAME_AUTOBAR_BUTTON14 = L["BUTTON"] .. " 14";
BINDING_NAME_AUTOBAR_BUTTON15 = L["BUTTON"] .. " 15";
BINDING_NAME_AUTOBAR_BUTTON16 = L["BUTTON"] .. " 16";
BINDING_NAME_AUTOBAR_BUTTON17 = L["BUTTON"] .. " 17";
BINDING_NAME_AUTOBAR_BUTTON18 = L["BUTTON"] .. " 18";
BINDING_NAME_AUTOBAR_BUTTON19 = L["BUTTON"] .. " 19";
BINDING_NAME_AUTOBAR_BUTTON20 = L["BUTTON"] .. " 20";
BINDING_NAME_AUTOBAR_BUTTON21 = L["BUTTON"] .. " 21";
BINDING_NAME_AUTOBAR_BUTTON22 = L["BUTTON"] .. " 22";
BINDING_NAME_AUTOBAR_BUTTON23 = L["BUTTON"] .. " 23";
BINDING_NAME_AUTOBAR_BUTTON24 = L["BUTTON"] .. " 24";


function AutoBarConfig_Toggle()
	if (not InCombatLockdown()) then
		local loaded, message = LoadAddOn("AutoBarConfig");
		if (loaded) then
			PlaySound("igMainMenuOpen");
			if (not AutoBarConfig.initialized) then
				AutoBarConfig:TabButtonInitialize();
				AutoBarConfig.initialized = true;
			end

			if (AutoBarConfigFrame:IsVisible()) then
				AutoBarConfigFrame:Hide();
			else
				AutoBarConfigFrame:Show();
			end
		else
			PlaySound("TellMessage");
			-- User most likely does not have the load on demand addon AutoBarConfig installed or not enabled
			DEFAULT_CHAT_FRAME:AddMessage(L["LOAD_ERROR"]..message);
		end
	end
end

local options = {
	type = 'execute',
	desc = L["Toggle the config panel"],
	func = AutoBarConfig_Toggle,
}


-- If the Debug library is available then use it
if AceLibrary:HasInstance("AceDebug-2.0") then
	AutoBar = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1", "AceDebug-2.0");
else
	AutoBar = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1");
end
AutoBar.revision = REVISION
AutoBar.date = DATE


function AutoBar:OnInitialize()
	AutoBar.currentPlayer = UnitName("player") .. " - " .. GetCVar("realmName");
	_, AutoBar.CLASS = UnitClass("player");
	AutoBar.CLASSPROFILE = "_" .. AutoBar.CLASS;

	AutoBar.inWorld = false;
	AutoBar.inCombat = false;	-- For item use restrictions
	AutoBar.inBG = false;		-- For battleground only items

	-- Single parent for key binding overides
	self.keyframe = CreateFrame("Frame", nil, UIParent);
	AutoBar:DelayInitialize()
end


function AutoBar:Initialize()
	self:RegisterChatCommand({L["SLASHCMD_SHORT"], L["SLASHCMD_LONG"]}, options)
	self:RegisterDB("AutoBarDB", "AutoBarDBPC")
	self:RegisterDefaults("char", {
	--		profile = {};
	--		profile.useCharacter = true;
	--		profile.useShared = false;
	--		profile.useClass = false;
	--		profile.useBasic = false;
	--		profile.edit = 1;
	--		profile.shared = "_SHARED1";
	--		profile.layout = 1;
	--		profile.layoutProfile = AutoBar.currentPlayer;
		}
	)

	AutoBarCategoryInitialize()
	AutoBarProfile.Initialize()
	AutoBarSearch:Initialize()
	AutoBar:LayoutInitialize()
end


function AutoBar:OnEnable()
	-- Called when the addon is enabled
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("LEARNED_SPELL_IN_TAB")
--	self:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
	self:RegisterOverrideBindings()
	self:RegisterEvent("UPDATE_BINDINGS")

	-- For item use restrictions
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ALIVE")
	self:RegisterEvent("PLAYER_UNGHOST")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")

--AutoBarSearch:Test()
	AutoBar.delayInitialize:Start()
end


function AutoBar:OnDisable()
	-- Called when the addon is disabled
end

local logItems = {}	-- n = startTime
function AutoBar:LogToggle()
	AutoBar.performance = AutoBarProfile:GetProfile().performance
end

function AutoBar:LogEvent(eventName, arg1)
	if (AutoBar.performance) then
		if (arg1) then
			DEFAULT_CHAT_FRAME:AddMessage(eventName .. " arg1 " .. tostring(arg1) .. " time: " .. GetTime())
		else
			DEFAULT_CHAT_FRAME:AddMessage(eventName .. " time: " .. GetTime())
		end
	end
end

function AutoBar:LogEventStart(eventName)
	if (AutoBar.performance) then
		if (logItems[eventName]) then
			DEFAULT_CHAT_FRAME:AddMessage(eventName .. " restarted before previous completion")
		else
			logItems[eventName] = GetTime()
			DEFAULT_CHAT_FRAME:AddMessage(eventName .. " started time: " .. logItems[eventName])
		end
	end
end

function AutoBar:LogEventEnd(eventName, arg1)
	if (AutoBar.performance) then
		if (logItems[eventName]) then
			local elapsed = GetTime() - logItems[eventName]
			logItems[eventName] = nil
			if (arg1) then
				DEFAULT_CHAT_FRAME:AddMessage(eventName .. " " .. tostring(arg1) .. " time: " .. elapsed)
			else
				DEFAULT_CHAT_FRAME:AddMessage(eventName .. " time: " .. elapsed)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(eventName .. " restarted before previous completion")
		end
	end
end


-- Copied from Bartender3
-- Create Override Bindings from the Blizzard bindings.  These do not clash so all is happy.
-- Will not update if set during combat
function AutoBar:RegisterOverrideBindings()
	if (AutoBar.ssButtons) then
		ClearOverrideBindings(self.keyframe)
		for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
			local button = AutoBar.ssButtons[buttonsIndex];
			local key1, key2 = GetBindingKey("AUTOBAR_BUTTON"..buttonsIndex)
			if key1
				then SetOverrideBindingClick(self.keyframe, false, key1, "AutoBarSAB" .. buttonsIndex)
				button.hotKey:SetText(AutoBarButton:GetHotKeyDisplayText(key1));
			end
			if key2 then
				SetOverrideBindingClick(self.keyframe, false, key2, "AutoBarSAB" .. buttonsIndex)
				button.hotKey:SetText(AutoBarButton:GetHotKeyDisplayText(key2));
			end
		end
	end
end


-- Layered delayed callback objects
-- Timers lower down the list are superceded and cancelled by those higher up
local timerList = {
	{name = "AutoBarInit", timer = nil, runPostCombat = false, callback = nil},
	{name = "AutoBarReset", timer = nil, runPostCombat = false, callback = nil},
	{name = "AutoBarScan", timer = nil, runPostCombat = false, callback = nil},
	{name = "AutoBarLayoutUpdate", timer = nil, runPostCombat = false, callback = nil},
	{name = "AutoBarButtonsUpdate", timer = nil, runPostCombat = false, callback = nil},
}
local IDelayedCallback = AceOO.Interface { Callback = "function" }

local DELAY_TIME = 0.06
local DELAY_TIME_INCREMENTAL = 0.01

local Delayed = AceOO.Class(IDelayedCallback)
Delayed.virtual = true -- this means that it cannot be instantiated. (cannot call :new())
Delayed.prototype.postCombat = false -- Set to true to trigger call after combat
Delayed.prototype.timerList = timerList
Delayed.prototype.timerListIndex = 0
Delayed.prototype.timerInfo = 0
Delayed.prototype.name = "No Name"

function Delayed.prototype:init(timerListIndex)
	Delayed.super.prototype.init(self)
	self.timerListIndex = timerListIndex
	self.timerInfo = timerList[timerListIndex]
	self.name = timerList[timerListIndex].name
--DEFAULT_CHAT_FRAME:AddMessage("Delayed.prototype:init " .. tostring(self.name));
end

function Delayed.prototype:Callback()
	self.timerInfo.timer = nil
end

-- Returns a new or recycled list object
function Delayed.prototype:Start(arg1)
	-- If in combat delay call till after combat
	if (InCombatLockdown()) then
		self.timerInfo.runPostCombat = true
		return
	end

	local currentTime = GetTime()
	local function MyCallback()
		local myself = self
		local arg1 = arg1
--DEFAULT_CHAT_FRAME:AddMessage("   MyCallback "..myself.name.." at  " .. tostring(GetTime()).." arg1  " .. tostring(arg1))
		myself:Callback(arg1)
	end

	if (self.timerInfo.timer) then
--DEFAULT_CHAT_FRAME:AddMessage("   Delayed.prototype:Start "..self.name.." extend timer at " .. currentTime);
		-- Timer not expired, extend it
		if (currentTime - self.timerInfo.timer > DELAY_TIME - DELAY_TIME_INCREMENTAL) then
			-- Almost or already exceeding DELAY_TIME, so use a small incremental delay
			AutoBar:CancelScheduledEvent(self.name)
			AutoBar:ScheduleEvent(self.name, MyCallback, DELAY_TIME_INCREMENTAL)
		else
			-- Still more than DELAY_TIME_INCREMENTAL before the original timer so do not change it
		end
	else
		-- Cancel if higher level timer already in progress
		for i, timerInfo in ipairs(self.timerList) do
			if (i < self.timerListIndex and timerInfo.timer) then
				return
			elseif (i == self.timerListIndex) then
				break
			end
		end

		-- Start new Timer
		self.timerInfo.timer = currentTime;
		AutoBar:ScheduleEvent(self.name, MyCallback, DELAY_TIME)
--DEFAULT_CHAT_FRAME:AddMessage("Delayed.prototype:Start start "..self.name.." delay at " .. currentTime)

		-- Cancel Superceded timers
		for i, timerInfo in ipairs(self.timerList) do
			if (i > self.timerListIndex and timerInfo.timer) then
				AutoBar:CancelScheduledEvent(timerInfo.name)
			end
		end
	end
end


-- Complete reload of Categories, Scan, LayoutUpdate, ButtonsUpdate
local DelayedInitialize = AceOO.Class(Delayed)

function DelayedInitialize.prototype:init(timerListIndex)
	DelayedInitialize.super.prototype.init(self, timerListIndex)
end

function DelayedInitialize.prototype:Callback()
--DEFAULT_CHAT_FRAME:AddMessage("   DelayedInitialize.prototype:Callback  self "..tostring(self))
	DelayedInitialize.super.prototype.Callback(self)
	AutoBar:Initialize()
	AutoBarSearch:Reset()
	AutoBar:LayoutUpdate()
end


-- Complete reload of Categories, Scan, LayoutUpdate, ButtonsUpdate
local DelayedReset = AceOO.Class(Delayed)

function DelayedReset.prototype:init(timerListIndex)
	DelayedReset.super.prototype.init(self, timerListIndex)
end

function DelayedReset.prototype:Callback()
--DEFAULT_CHAT_FRAME:AddMessage("   DelayedReset.prototype:Callback  self "..tostring(self))
	DelayedReset.super.prototype.Callback(self)
	AutoBarSearch:Reset()
	AutoBar:LayoutUpdate()
end


-- Scan, LayoutUpdate, ButtonsUpdate
local DelayedScan = AceOO.Class(Delayed)

function DelayedScan.prototype:init(timerListIndex)
	DelayedScan.super.prototype.init(self, timerListIndex)
end

function DelayedScan.prototype:Callback()
--DEFAULT_CHAT_FRAME:AddMessage("   DelayedScan.prototype:Callback  self "..tostring(self))
	DelayedScan.super.prototype.Callback(self)
	AutoBarSearch.stuff:Scan()
	AutoBarSearch.sorted:Update()
	AutoBar:LayoutUpdate()
	self.timerInfo.timer = nil
end


-- ButtonsUpdate only
local DelayedLayoutUpdate = AceOO.Class(Delayed)

function DelayedLayoutUpdate.prototype:init(timerListIndex)
	DelayedLayoutUpdate.super.prototype.init(self, timerListIndex)
end

function DelayedLayoutUpdate.prototype:Callback()
--DEFAULT_CHAT_FRAME:AddMessage("   DelayedLayoutUpdate.prototype:Callback  self "..tostring(self))
	DelayedLayoutUpdate.super.prototype.Callback(self)
	AutoBar:LayoutUpdate()
end


-- ButtonsUpdate only
local DelayedButtonsUpdate = AceOO.Class(Delayed)

function DelayedButtonsUpdate.prototype:init(timerListIndex)
	DelayedButtonsUpdate.super.prototype.init(self, timerListIndex)
end

function DelayedButtonsUpdate.prototype:Callback()
--DEFAULT_CHAT_FRAME:AddMessage("   DelayedButtonsUpdate.prototype:Callback  self "..tostring(self))
	DelayedButtonsUpdate.super.prototype.Callback(self)
	AutoBar:ButtonsUpdate()
end


function AutoBar:DelayInitialize()
--DEFAULT_CHAT_FRAME:AddMessage("DelayInitialize")
	AutoBar.delayInitialize = DelayedInitialize:new(1)
	AutoBar.delayReset = DelayedReset:new(2)
	AutoBar.delayScan = DelayedScan:new(3)
	AutoBar.delayLayoutUpdate = DelayedLayoutUpdate:new(4)
	AutoBar.delayButtonsUpdate = DelayedButtonsUpdate:new(5)
end


function AutoBar:PostCombat()
	local ran = false
	AutoBar:ButtonsUpdate()

--	for i, timerInfo in ipairs(timerList) do
--		if (timerInfo.runPostCombat and ran == false) then
----			Callback:Callback()
--			ran = true
--		end
--		timerInfo.runPostCombat = false
--	end
end


function AutoBar:PLAYER_ENTERING_WORLD()
	AutoBar.inCombat = false;
	local scanned = false;
	if (not AutoBar.initialized) then
--DEFAULT_CHAT_FRAME:AddMessage("   PLAYER_ENTERING_WORLD")
		AutoBar.delayReset:Start()
		scanned = true;
		AutoBar.initialized = true;
	end

	if (not AutoBar.inWorld) then
		AutoBar.inWorld = true;
--DEFAULT_CHAT_FRAME:AddMessage("   PLAYER_ENTERING_WORLD")
		AutoBar.delayReset:Start()
--		AutoBar.delayScan:Start();
	end
end


function AutoBar:PLAYER_LEAVING_WORLD()
	AutoBar.inWorld = false;
end


function AutoBar:BAG_UPDATE()
	AutoBar:LogEvent("BAG_UPDATE", arg1)
	if (AutoBar.inWorld and arg1 < 5) then
		AutoBarSearch.dirtyBags[arg1] = true
		if (InCombatLockdown()) then
			AutoBar:ButtonsEvent(AutoBarButton.UpdateCount);
		else
			AutoBar.delayScan:Start();
		end
	end
end


function AutoBar:BAG_UPDATE_COOLDOWN()
	AutoBar:LogEvent("BAG_UPDATE_COOLDOWN", arg1)
--DEFAULT_CHAT_FRAME:AddMessage("   BAG_UPDATE_COOLDOWN arg1 " .. tostring(arg1))
	if (InCombatLockdown()) then
		AutoBar:ButtonsEvent(AutoBarButton.UpdateCooldown);
	else
		AutoBar.delayButtonsUpdate:Start()
	end
end


--function AutoBar:ACTIONBAR_UPDATE_USABLE()
--	if (AutoBar.inWorld and arg1 and arg1 < 5) then
--		if (InCombatLockdown()) then
--			AutoBar:ButtonsEvent(AutoBarButton.UpdateUsable);
--			pendingScan = true;
--		else
--			AutoBar.delayScan:Start();
--		end
--	end
--end
--
--
function AutoBar:UPDATE_BINDINGS()
	if (not InCombatLockdown()) then
		self:RegisterOverrideBindings();
		AutoBar.delayButtonsUpdate:Start()
	end
end


function AutoBar:LEARNED_SPELL_IN_TAB()
	AutoBar:LogEvent("LEARNED_SPELL_IN_TAB", arg1)
--	AutoBarSearch.stuff:ScanSpells()
	AutoBarSearch.Reset()
	AutoBar.delayLayoutUpdate:Start()
--	if (not InCombatLockdown()) then
--	end
end


function AutoBar:ZONE_CHANGED_NEW_AREA()
	if (not InCombatLockdown()) then
		AutoBar.delayButtonsUpdate:Start()
	end
end


function AutoBar:PLAYER_CONTROL_GAINED()
	if (not InCombatLockdown()) then
		AutoBar.delayButtonsUpdate:Start()
	end
end


function AutoBar:PLAYER_REGEN_ENABLED()
--DEFAULT_CHAT_FRAME:AddMessage("   PLAYER_REGEN_ENABLED")
	AutoBar.inCombat = false;
	AutoBar:PostCombat()
end


function AutoBar:PLAYER_REGEN_DISABLED()
	AutoBar:LogEvent("PLAYER_REGEN_DISABLED", arg1)
	AutoBar.inCombat = true;
--DEFAULT_CHAT_FRAME:AddMessage("   PLAYER_REGEN_DISABLED")
	if (self:IsEventScheduled("AutoBarScan")) then
		self:CancelScheduledEvent("AutoBarScan");
		AutoBarSearch.stuff:Scan()
	elseif (self:IsEventScheduled("AutoBarButtonsUpdate")) then
		self:CancelScheduledEvent("AutoBarButtonsUpdate");
	end
	AutoBar:ButtonsUpdate()
	if (AutoBarConfigFrame) then
		AutoBarConfigFrame:Hide()
	end
end


--function AutoBar:UNIT_MANA()
--	if (arg1 == "player") then
--		AutoBar:LogEvent("UNIT_MANA", arg1)
--		if (not InCombatLockdown()) then
--			AutoBar.delayButtonsUpdate:Start()
--		end
--	end
--end
--
--
--function AutoBar:UNIT_HEALTH()
--	if (arg1 == "player") then
--		AutoBar:LogEvent("UNIT_HEALTH", arg1)
--		if (not InCombatLockdown()) then
--			AutoBar.delayButtonsUpdate:Start()
--		end
--	end
--end


function AutoBar:PLAYER_ALIVE()
	if (not InCombatLockdown()) then
		AutoBar:LogEvent("PLAYER_ALIVE", arg1)
		AutoBar.delayButtonsUpdate:Start()
	end
end


function AutoBar:PLAYER_UNGHOST()
	if (not InCombatLockdown()) then
		AutoBar:LogEvent("PLAYER_UNGHOST", arg1)
		AutoBar.delayButtonsUpdate:Start()
	end
end


function AutoBar:UPDATE_BATTLEFIELD_STATUS()
	if (AutoBar.inWorld) then
		local bgStatus = false
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status, mapName, instanceID = GetBattlefieldStatus(i);
			if (instanceID ~= 0) then
				bgStatus = true
				break
			end
		end
		if (AutoBar.inBG ~= bgStatus) then
			AutoBar.inBG = bgStatus
			AutoBar.delayButtonsUpdate:Start()
		end
	end
end


-- When dragging, contains { frameName, index }, otherwise nil
AutoBar.dragging = nil;
local draggingData = {};

function AutoBar.GetDraggingIndex(frameName)
	if (AutoBar.dragging and AutoBar.dragging.frameName == frameName) then
		return AutoBar.dragging.index;
	end
	return nil;
end


function AutoBar.SetDraggingIndex(frameName, index)
	draggingData.frameName = frameName;
	draggingData.index = index;
	AutoBar.dragging = draggingData;
end


function AutoBar.LinkDecode(link)
	if (link) then
		local _, _, id, _, _, _, name = string.find(link, "item:(%d+):(%d+):(%d+):(%d+).+%[(.+)%]");
		if (id and name) then
			return name, tonumber(id);
		end
	end
end


-- Handle updates during combat.
function AutoBar:ButtonsEvent(eventHandler)
	-- Update all bar buttons
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		local button = AutoBar.ssButtons[buttonsIndex];
		if (button:GetAttribute("buttonsIndex")) then
			eventHandler(self, button);
		end
	end

	-- Update all popup buttons that were clicked on
	-- This does miss items clicked on some other way
	if (eventHandler == AutoBarButton.UpdateCooldown) then
		AutoBarButton:UpdateCooldownPopup()
	elseif (eventHandler == AutoBarButton.UpdateCount) then
		AutoBarButton:UpdateCountPopup()
	end
end


-- Assign display buttons to active slots and return the number of displayed buttons
function AutoBar:AssignButtons(maxButtons)
	local displayedButtons = 1;

	if (AutoBar.ssButtons) then
		local buttonsIndex, buttonInfo, rankIndex, items;
		for buttonsIndex = 1, AUTOBAR_MAXBUTTONS do
			local button = AutoBar.ssButtons[buttonsIndex];
			local sortedItems = AutoBarSearch.sorted:GetList(buttonsIndex)
			if (maxButtons and displayedButtons > maxButtons) then
				button:SetAttribute("buttonsIndex", nil);
			elseif (AutoBar.display.showEmptyButtons or sortedItems[1]) then
				button:SetAttribute("buttonsIndex", buttonsIndex);
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:AssignButtons CurrentItems -> "..buttonsIndex);
				displayedButtons = displayedButtons + 1;
			elseif (AutoBar.buttons[buttonsIndex] and AutoBar.display.showCategoryIcon) then
				button:SetAttribute("buttonsIndex", buttonsIndex);
				displayedButtons = displayedButtons + 1;
--			elseif (AutoBar.buttons[buttonsIndex] and AutoBar.buttons[buttonsIndex].castSpell) then
--				local usable, noMana = IsUsableSpell(AutoBar.buttons[buttonsIndex].castSpell);
--				if (usable or noMana) then
--					button:SetAttribute("buttonsIndex", buttonsIndex);
----DEFAULT_CHAT_FRAME:AddMessage("AutoBar:AssignButtons " .. tostring(AutoBar.buttons[buttonsIndex].castSpell));
--					displayedButtons = displayedButtons + 1;
--				else
--					button:SetAttribute("buttonsIndex", nil);
--				end
			else
				button:SetAttribute("buttonsIndex", nil);
			end
		end
	end
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:AssignButtons maxButtons " .. maxButtons .. " displayedButtons " .. (displayedButtons - 1));

	return displayedButtons - 1;
end


--	local numReagents = GetTradeSkillNumReagents(id);
--	local totalReagents = 0;
--	for i=1, numReagents, 1 do
--		local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
--		totalReagents = totalReagents + reagentCount;
--	end;

--local numReagents = GetTradeSkillNumReagents(id);
--for i=1, numReagents, 1 do
--	local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
--	SetItemButtonTexture(reagent, reagentTexture);
--	name:SetText(reagentName);
--	-- Grayout items
--	if ( playerReagentCount < reagentCount ) then
--		SetItemButtonTextureVertexColor(reagent, 0.5, 0.5, 0.5);
--		name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
--		creatable = nil;
--	end;
--end;


function AutoBar.ConfigChanged()
	AutoBar.delayReset:Start()
end


AutoBar.dockingFrames = {
	["NONE"] = {
		text = L["AUTOBAR_CONFIG_DOCKTONONE"],
		offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
	},
	["BT3Bar1"] = {
		text = L["AUTOBAR_CONFIG_BT3BAR"]..1,
		offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
	},
	["BT3Bar2"] = {
		text = L["AUTOBAR_CONFIG_BT3BAR"]..2,
		offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
	},
	["BT3Bar3"] = {
		text = L["AUTOBAR_CONFIG_BT3BAR"]..3,
		offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
	},
	["BT3Bar4"] = {
		text = L["AUTOBAR_CONFIG_BT3BAR"]..4,
		offset = { x = 0, y = 0, point = "CENTER", relative = "BOTTOMLEFT" },
	},
	["BT3Bar6"] = {
		text = L["AUTOBAR_CONFIG_BT3BAR"]..6,
		offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
	},
	["BT3Bar10"] = {
		text = L["AUTOBAR_CONFIG_BT3BAR"]..10,
		offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
	},
	["MainMenuBarArtFrame"] = {
		text = L["AUTOBAR_CONFIG_DOCKTOMAIN"],
		offset = { x = 0, y = 0, point = "CENTER", relative = "TOPRIGHT" },
	},
	["ChatFrame1"] = {
		text = L["AUTOBAR_CONFIG_DOCKTOCHATFRAME"],
		offset = { x = 0, y = 25, point = "CENTER", relative = "TOPLEFT" },
	},
	["ChatFrameMenuButton"] = {
		text = L["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"],
		offset = { x = 0, y = 25, point = "CENTER", relative = "TOPLEFT" },
	},
	["MainMenuBar"] = {
		text = L["AUTOBAR_CONFIG_DOCKTOACTIONBAR"],
		offset = { x = 7, y = 40, point = "CENTER", relative = "TOPLEFT" },
	},
	["CharacterMicroButton"] = {
		text = L["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"],
		offset = { x = 0, y = 0, point = "CENTER", relative = "BOTTOMLEFT" },
	},
};


function AutoBar:Test()
	DEFAULT_CHAT_FRAME:AddMessage(    "header state " .. tostring(_G["AutoBarSSHeaderFrame"]:GetAttribute("state")));
	for i = 1, AUTOBAR_MAXBUTTONS, 1 do
		button = AutoBar.ssButtons[i];
		s = AutoBar.ssPopupHeaders[i];
		DEFAULT_CHAT_FRAME:AddMessage("      button ".. i .. tostring(button:GetAttribute("state")).." s " .. tostring(s:GetAttribute("state")));

		local popupButtons = AutoBar.ssPopupButtons[i];
		local popupButton;
		local msg = ""
		for popupButtonIndex = 1, AUTOBAR_MAXPOPUPBUTTONS, 1 do
			popupButton = popupButtons[popupButtonIndex];--AutoBar.ssPopupButtons
			if (popupButton:GetAttribute("showstates") ~= "!*") then
				msg = msg .. tostring(popupButton:GetAttribute("state")).." ";
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage(msg);
	end
end


local AUTOBAR_SHIFTSTATE = AUTOBAR_MAXBUTTONS; -- state offset when shift is held down
local AUTOBAR_SHIFT_ON = AUTOBAR_MAXBUTTONS * 2 + 1; -- ground state when shift is held down
local AUTOBAR_MAXBUTTONS_SHIFT = AUTOBAR_MAXBUTTONS * 2; -- ground state when shift is held down
local AUTOBAR_MIN_RANGE = "1-"..AUTOBAR_MAXBUTTONS;
local AUTOBAR_MAX_RANGE = (AUTOBAR_MAXBUTTONS+1).."-"..(AUTOBAR_MAXBUTTONS * 2);
local AUTOBAR_MAP_SHIFT_UP
local AUTOBAR_MAP_SHIFT_DOWN
local AUTOBAR_MAP_SHIFT_UP_ALL;
local AUTOBAR_MAP_SHIFT_DOWN_ALL;

function AutoBar:StateChanged(newState)
	DEFAULT_CHAT_FRAME:AddMessage(self:GetName().. ": " .. tostring(self:GetAttribute("state")));
end

-- Create the buttons and popups
function AutoBar:LayoutInitialize()
	local buttonWidth, buttonHeight, gapping = AutoBar:GetButtonSize();

	AUTOBAR_MAP_SHIFT_UP = ""
	AUTOBAR_MAP_SHIFT_DOWN = ""
	for i = 1, AUTOBAR_MAXBUTTONS, 1 do
		AUTOBAR_MAP_SHIFT_UP = AUTOBAR_MAP_SHIFT_UP..";"..i..":"..(i+AUTOBAR_SHIFTSTATE)
		AUTOBAR_MAP_SHIFT_DOWN = AUTOBAR_MAP_SHIFT_DOWN..";"..(i+AUTOBAR_SHIFTSTATE)..":"..i
	end
	AUTOBAR_MAP_SHIFT_UP_ALL = AUTOBAR_SHIFT_ON..":0"..AUTOBAR_MAP_SHIFT_UP
	AUTOBAR_MAP_SHIFT_DOWN_ALL = "0:"..AUTOBAR_SHIFT_ON..AUTOBAR_MAP_SHIFT_DOWN

--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:LayoutInitialize gapping " .. tostring(gapping) .. " / " .. tostring(buttonWidth) .. " / " .. tostring(buttonHeight), 1, 0.5, 0);

	-- The main driver.  It's draghandle child allows repositioning
	local p = _G["AutoBarSSHeaderFrame"]
	-- State 0 shows the slot buttons but no popups
	p:SetAttribute("statemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":$input");
	p:SetAttribute("delaystatemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":0");
	p:SetAttribute("delaytimemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":0.2");
	p:SetAttribute("delayhovermap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":true");
	p:SetAttribute("state-popup", "0");
	p:SetAttribute("statemap-popup", "*:0");

--p.StateChanged = AutoBar.StateChanged;
	AutoBar.ssHeader = p;


--local driver = _G["AutoBarSSDriverFrame"]; --CreateFrame("Frame", "StealthBarDriverFrame", UIParent, "SecureStateDriverTemplate")
--driver:SetPoint("CENTER",0,0) driver:SetWidth(2) driver:SetHeight(2)
-- in stealth, set to state 1, out of stealth go to state 1
--driver:SetAttribute("statemap-stealth-0", "0")
--driver:SetAttribute("statemap-stealth-1", "1")

--driver:SetAttribute("statemap-ctrl-0", "0")
--driver:SetAttribute("statemap-ctrl-1", AUTOBAR_SHIFT_ON)
--p = driver;
--p:SetAttribute("statemap-anchor", "0-"..AUTOBAR_SHIFT_ON..":$input");
--p:SetAttribute("delaystatemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":0");
--p:SetAttribute("delaytimemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":0.2");
--p:SetAttribute("delayhovermap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":true");
--p:SetAttribute("ctrl-delaystatemap-anchor", AUTOBAR_MAX_RANGE..":"..AUTOBAR_SHIFT_ON);
--p:SetAttribute("ctrl-delaytimemap-anchor", AUTOBAR_MAX_RANGE..":0.2");
--p:SetAttribute("ctrl-delayhovermap-anchor", AUTOBAR_MAX_RANGE..":true");
--p:SetAttribute("state-popup", "0");
--p:SetAttribute("statemap-popup", "*:0");
--p:SetAttribute("ctrl-statemap-popup", "*:"..AUTOBAR_SHIFT_ON);

	-- Hook up AutoBarFrame components so we can do docking
	AutoBarFrame:SetAttribute("addchild", AutoBarSSHeaderFrame);
	AutoBarFrame:SetAttribute("addchild", AutoBarAnchorFrameHandle);
	AutoBarAnchorFrameHandle:SetAttribute("ofspoint", "*:CENTER");
	AutoBarAnchorFrameHandle:SetAttribute("ofsrelpoint", "*:CENTER");
	AutoBarAnchorFrameHandle:SetAttribute("ofsx", 0);
	AutoBarAnchorFrameHandle:SetAttribute("ofsy", 0);
	AutoBarSSHeaderFrame:SetAttribute("ofspoint", "*:CENTER");
	AutoBarSSHeaderFrame:SetAttribute("ofsrelpoint", "*:CENTER");
	AutoBarSSHeaderFrame:SetAttribute("ofsx", 0);
	AutoBarSSHeaderFrame:SetAttribute("ofsy", 0);

	-- Create the slot buttons
	AutoBar.ssButtons = {};
	for i = 1, AUTOBAR_MAXBUTTONS do
		local button = CreateFrame("CheckButton", "AutoBarSAB" .. i, p, "AutoBarSAButtonTemplate, SecureAnchorEnterTemplate");
		AutoBar.ssButtons[i] = button;

		button:SetAttribute("newstate","0:"..tostring(i)..";"..tostring(i)..":0")
		-- Set 0 second delay before returning to state 0 so keybindings dont open the popup
		button:SetAttribute("delaystate", "0:0")
		button:SetAttribute("delaytime", "0:0.1")
		button:SetAttribute("*childraise*", true);
		AutoBarButton:InitializeVisual(button);

		-- Support selfcast
		button:SetAttribute("checkselfcast", true);
--button:RegisterForDrag("LeftButton", "RightButton")
		p:SetAttribute("addchild", button);
	end

	-- Create the popup buttons and slave headers to control them
	AutoBar.ssPopupHeaders = {};
	AutoBar.ssPopupButtons = {};
	for i = 1, AUTOBAR_MAXBUTTONS do
		local popupHeader = CreateFrame("Frame", "AutoBarSSPopupHeaderFrame"..i, p, "SecureStateHeaderTemplate");
		popupHeader:SetWidth(2);
		popupHeader:SetHeight(2);
		AutoBar.ssPopupHeaders[i] = popupHeader;
		popupHeader:SetAttribute("statemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":$input");
		popupHeader:SetAttribute("delaystatemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":0");
		popupHeader:SetAttribute("delaytimemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":0.2");
		popupHeader:SetAttribute("delayhovermap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":true");

		popupHeader:SetAttribute("state-parent", 0);
		popupHeader:SetAttribute("statemap-parent", "*:"..tostring(i));
popupHeader:SetAttribute("ctrl-statemap-parent", "*:"..tostring(i + AUTOBAR_SHIFTSTATE));
--		popupHeader:SetAttribute("statemap-parent", "1-"..tostring(i)..":"..tostring(i)..";0:0");
--popupHeader:SetAttribute("ctrl-statemap-parent", tostring(i + AUTOBAR_SHIFTSTATE)..":"..tostring(i + AUTOBAR_SHIFTSTATE));

		popupHeader:SetAttribute("exportstate", "popup");

--popupHeader.StateChanged = AutoBar.StateChanged;
		p:SetAttribute("addchild", popupHeader);

		popupHeader:SetAttribute("ofspoint", "*:CENTER");
		popupHeader:SetAttribute("ofsrelpoint", "*:CENTER");
		popupHeader:SetAttribute("ofsx", 0);
		popupHeader:SetAttribute("ofsy", 0);
		popupHeader:SetAttribute("state", 0);
		popupHeader:SetAttribute("showstates", tostring(i));
popupHeader:SetAttribute("showstates", tostring(i)..","..tostring(i + AUTOBAR_SHIFTSTATE));
		AutoBar.ssButtons[i]:SetAttribute("anchorchild", popupHeader);

		AutoBar.ssPopupButtons[i] = {};
		local popupButtons = AutoBar.ssPopupButtons[i];
		for popupButtonIndex = 1, AUTOBAR_MAXPOPUPBUTTONS do
			local popupButton = CreateFrame("CheckButton", "AutoBarSAB" .. i .. "P" .. popupButtonIndex, AutoBar.ssButtons[i], "AutoBarSAPopupButtonTemplate");
			popupButtons[popupButtonIndex] = popupButton;

			popupButton:SetAttribute("newstate", 0);
			popupButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			AutoBarButton:InitializeVisual(popupButton);

			-- Support selfcast
			popupButton:SetAttribute("checkselfcast", true);

			popupHeader:SetAttribute("addchild", popupButton);
		end
	end

	AutoBar.buttonLocations = {};
	for i = 1, AUTOBAR_MAXBUTTONS do
		AutoBar.buttonLocations[i] = {};
	end

	AutoBar:RegisterOverrideBindings()
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:LayoutInitialize ssButtons " .. tostring(AutoBar.ssButtons) .. " / " .. tostring(AutoBar.ssButtons[1]));
end


-- Arrange the buttons using the various settings and alignment options
function AutoBar:LayoutUpdate()
	if (InCombatLockdown()) then
		return;
	end

	-- Postpone the actual style setting to resolve init issue with cyCircled
	if (AutoBar.style) then
		AutoBar.display.style = AutoBar.style
		AutoBar.style = nil
	end

	self:LogEventStart("AutoBar:LayoutUpdate")
	local rows = AutoBar.display.rows;
	local columns = AutoBar.display.columns;
	local buttonWidth, buttonHeight, gapping = AutoBar:GetButtonSize();
	local centerShiftX = 0;
	local centerShiftY = 0;
	local point = "BOTTOMLEFT";
	local x = buttonWidth + gapping;
	local y = buttonHeight + gapping;

	local displayedButtons = AutoBar:AssignButtons(rows * columns);
	local displayedColumns = math.min(displayedButtons, columns);
	local displayedRows = math.floor((displayedButtons - 1) / columns) + 1;
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:LayoutUpdate buttons " .. displayedButtons .. " columns " .. tostring(displayedColumns) .. " Rows " .. tostring(displayedRows));

	if (AutoBar.display.alignButtons == 1) then
		point = "BOTTOMLEFT";
	elseif (AutoBar.display.alignButtons == 2) then
		centerShiftX = -0.5 * displayedColumns * (buttonWidth + gapping) + gapping / 2;
		point = "BOTTOMLEFT";
	elseif (AutoBar.display.alignButtons == 3) then
		x = x * -1;
		point = "BOTTOMRIGHT";
	elseif (AutoBar.display.alignButtons == 4) then
		x = x * -1;
		point = "BOTTOMRIGHT";
		centerShiftY = -0.5 * displayedRows * (buttonHeight + gapping) + gapping / 2;
	elseif (AutoBar.display.alignButtons == 5) then
		point = "BOTTOMLEFT";
		centerShiftX = -0.5 * displayedColumns * (buttonWidth + gapping) + gapping / 2;
		centerShiftY = -0.5 * displayedRows * (buttonHeight + gapping) + gapping / 2;
	elseif (AutoBar.display.alignButtons == 6) then
		point = "BOTTOMLEFT";
		centerShiftY = -0.5 * displayedRows * (buttonHeight + gapping) + gapping / 2;
	elseif (AutoBar.display.alignButtons == 7) then
		x = x * -1;
		y = y * -1;
		point = "TOPRIGHT";
	elseif (AutoBar.display.alignButtons == 8) then
		y = y * -1;
		point = "TOPLEFT";
		centerShiftX = -0.5 * displayedColumns * (buttonWidth + gapping) + gapping / 2;
	elseif (AutoBar.display.alignButtons == 9) then
		y = y * -1;
		point = "TOPLEFT";
	end

	if (AutoBar.display.popupOnShift) then
AutoBar.ssHeader:SetAttribute("statemap-ctrl-0", AUTOBAR_MAP_SHIFT_UP)
AutoBar.ssHeader:SetAttribute("statemap-ctrl-1", AUTOBAR_MAP_SHIFT_DOWN)
	else
		AutoBar.ssHeader:SetAttribute("statemap-ctrl-0", nil)
		AutoBar.ssHeader:SetAttribute("statemap-ctrl-1", nil)
	end

	local i, button, effectiveButton, popupHeader;
	local displayButton = 1;
	for i = 1, AUTOBAR_MAXBUTTONS, 1 do
		button = AutoBar.ssButtons[i];

		AutoBarButton:SetVisual("AutoBarSAB"..i);
		AutoBar.ssPopupHeaders[i]:SetFrameStrata("DIALOG");

		-- Set the relative positions of the buttons
		AutoBar.buttonLocations[i].x = (math.fmod(i - 1, columns) * x + centerShiftX);
		AutoBar.buttonLocations[i].y = math.floor((i - 1) / columns) * y + centerShiftY;
		button:SetAttribute("ofspoint", "*:"..point);
		button:SetAttribute("ofsrelpoint", "*:".."CENTER");

		popupHeader = AutoBar.ssPopupHeaders[i];
		if (AutoBar.display.popupOnShift) then
			button:SetAttribute("newstate","0:"..tostring(i)..";"..tostring(i)..":0")
			button:SetAttribute("ctrl-newstate", AUTOBAR_SHIFTSTATE..":"..tostring(i + AUTOBAR_SHIFTSTATE)..";"..tostring(i + AUTOBAR_SHIFTSTATE)..":"..AUTOBAR_SHIFTSTATE)
--			button:SetAttribute("delaystate", "0:0")
			button:SetAttribute("ctrl-delaystate", "0:"..AUTOBAR_SHIFTSTATE)
			button:SetAttribute("childstate", "^" .. tostring(i));
			button:SetAttribute("ctrl-childstate", "^" .. tostring(i + AUTOBAR_SHIFTSTATE));

			popupHeader:SetAttribute("statemap-anchor", "0-"..AUTOBAR_SHIFT_ON..":$input");
			popupHeader:SetAttribute("delaystatemap-anchor", "0-"..AUTOBAR_MAXBUTTONS..":0");
			popupHeader:SetAttribute("ctrl-delaystatemap-anchor", AUTOBAR_MAX_RANGE..":AUTOBAR_SHIFT_ON");
			popupHeader:SetAttribute("delaytimemap-anchor", "0-"..AUTOBAR_SHIFT_ON..":0.2");
			popupHeader:SetAttribute("delayhovermap-anchor", "0-"..AUTOBAR_SHIFT_ON..":true");

			popupHeader:SetAttribute("state-parent", 0);
--			popupHeader:SetAttribute("statemap-parent", "*:"..tostring(i));
			popupHeader:SetAttribute("ctrl-statemap-parent", "*:"..tostring(i + AUTOBAR_SHIFTSTATE));
--
--			popupHeader:SetAttribute("statemap-ctrl-1", tostring(i)..":"..(tostring(i + AUTOBAR_SHIFTSTATE)));
--			popupHeader:SetAttribute("statemap-ctrl-0", (tostring(i + AUTOBAR_SHIFTSTATE))..":"..tostring(i));
		else
			button:SetAttribute("childstate", "^" .. tostring(i));
			popupHeader:SetAttribute("statemap-ctrl-1", nil);
			popupHeader:SetAttribute("statemap-ctrl-0", nil);
		end

		local popupButtons = AutoBar.ssPopupButtons[i];
		for popupButtonIndex = 1, AUTOBAR_MAXPOPUPBUTTONS do
			local popupButton = popupButtons[popupButtonIndex];

			popupButton:SetAttribute("ofspoint", "*:"..point);
			popupButton:SetAttribute("ofsrelpoint", "*:".."CENTER");
		end
	end

	self:LogEventEnd("AutoBar:LayoutUpdate")

	AutoBar:ButtonsUpdate();
	AutoBar:UpdateAnchor(displayedButtons);
	AutoBar.ssHeader:SetAttribute("state", "0");
end


-- Handle anchor docking / positioning
function AutoBar:UpdateAnchor(displayedButtons)
	local rows = AutoBar.display.rows;
	local columns = AutoBar.display.columns;
	local buttonWidth, buttonHeight, gapping = AutoBar:GetButtonSize();
	local displayedColumns = math.min(displayedButtons, columns);
	local displayedRows = math.floor((displayedButtons - 1) / columns) + 1;
	local autoBarAnchorFrameHandle = _G["AutoBarAnchorFrameHandle"];

	autoBarAnchorFrameHandle:SetChecked(AutoBar.display.frameLocked);

	local dockShiftX = AutoBar.display.dockShiftX;
	local dockShiftY = AutoBar.display.dockShiftY;

	if (AutoBar.display.docking == "CharacterMicroButton") then
		AutoBarSSHeaderFrame:SetFrameStrata("HIGH");
		autoBarAnchorFrameHandle:SetFrameStrata("DIALOG");
	elseif (AutoBar.display.frameStrata) then
		AutoBarSSHeaderFrame:SetFrameStrata("HIGH");
		autoBarAnchorFrameHandle:SetFrameStrata("DIALOG");
	else
		AutoBarSSHeaderFrame:SetFrameStrata("LOW");
		autoBarAnchorFrameHandle:SetFrameStrata("MEDIUM");
	end

	if (AutoBar.display.docking and _G[AutoBar.display.docking]) then
		local offset = AutoBar.dockingFrames[AutoBar.display.docking].offset;
		AutoBarFrame:SetAttribute("headofspoint", "*:"..offset.point);
		AutoBarFrame:SetAttribute("headofsrelpoint", "*:"..offset.relative);
		AutoBarFrame:SetAttribute("headofsx", dockShiftX + offset.x);
		AutoBarFrame:SetAttribute("headofsy", dockShiftY + offset.y);
		AutoBarFrame:SetParent(_G[AutoBar.display.docking]);
	elseif (AutoBar.display.position) then
		AutoBarFrame:SetAttribute("headofspoint", "*:CENTER");
		AutoBarFrame:SetAttribute("headofsrelpoint", "*:screen");
		AutoBarFrame:SetAttribute("headofsx", AutoBar.display.position.x);
		AutoBarFrame:SetAttribute("headofsy", AutoBar.display.position.y);
		AutoBarFrame:SetParent("UIParent");
	else
		AutoBarFrame:SetAttribute("headofspoint", "*:CENTER");
		AutoBarFrame:SetAttribute("headofsrelpoint", "*:screen");
		AutoBarFrame:SetAttribute("headofsx", 300);
		AutoBarFrame:SetAttribute("headofsy", 300);
		AutoBarFrame:SetParent("UIParent");
	end
	AutoBarFrame:Show();
	AutoBarFrame:SetAttribute("state", 0);

	if (AutoBar.display.hideDragHandle) then
		autoBarAnchorFrameHandle:SetAttribute("showstates", "!*");
		autoBarAnchorFrameHandle:Hide();
	else
		autoBarAnchorFrameHandle:SetAttribute("showstates", "*");
		autoBarAnchorFrameHandle:Show();
	end
end

--/dump AutoBar.ssPopupButtons[1][1]:GetAttribute("type")
-- Assign content to the buttons, set count & keybinding texts, visibility, etc.
function AutoBar:ButtonsUpdate()
	if (not AutoBar.inWorld or InCombatLockdown()) then
		return
	end
	self:LogEventStart("AutoBar:ButtonsUpdate")
	AutoBarSearch.sorted:Update()

	local button, bag, slot, count, itemId, category, popupItemId;
	local displayButton = 1;		-- On Screen button, ignores empty slots
	local found = AutoBarSearch.found:GetList()
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:ButtonsUpdate start");
	for buttonsIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
--		if (AutoBarButton.dirtyButton[buttonsIndex]) then
--			AutoBarButton.dirtyButton[buttonsIndex] = false
			button = AutoBar.ssButtons[buttonsIndex];
			local showButton = button:GetAttribute("buttonsIndex");

			local popupButtons = AutoBar.ssPopupButtons[buttonsIndex];
			local popupButton;
			for popupButtonIndex = 1, AUTOBAR_MAXPOPUPBUTTONS, 1 do
				popupButton = popupButtons[popupButtonIndex];
				popupButton:SetAttribute("showstates", "!*");
			end

--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:ButtonsUpdate buttonsIndex " .. buttonsIndex);
			if (showButton) then
				local sortedItems = AutoBarSearch.sorted:GetList(buttonsIndex)
				bag = nil
				slot = nil
				spell = nil
				if (sortedItems[1]) then
					itemId = sortedItems[1].itemId
					if (found[itemId]) then
						bag = found[itemId][1]
						slot = found[itemId][2]
						spell = found[itemId][3]
					end
				end
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:ButtonsUpdate sortedItems " .. tostring(sortedItems) .. " itemId " .. tostring(itemId));
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:ButtonsUpdate buttonsIndex " .. buttonsIndex .. " bag, slot " .. tostring(bag) .. " " .. tostring(slot));
				if (bag or slot or spell) then
					button:SetAttribute("showstates", "*");
					button.x = AutoBar.buttonLocations[displayButton].x;
					button.y = AutoBar.buttonLocations[displayButton].y;
					button:SetAttribute("ofsx", button.x);
					button:SetAttribute("ofsy", button.y);
					if (spell) then
						count = 1
					else
						count = GetItemCount(tonumber(itemId))
					end

					local buttonItems = AutoBarSearch.items:GetList(buttonsIndex)
					local itemData = buttonItems[itemId]
					category = itemData.category;
					AutoBarButton:SetAttributes(button, "AutoBarSAB"..buttonsIndex, bag, slot, spell, count, itemId, category)
--local macroText = "/cancelaura [stance:2] Aquatic Form; [stance:3] Cat Form; [stance:4] Travel Form; [stance:5] Moonkin Form; [stance:6, noflying] Swift Flight Form \n/cast [nostance] Dire Bear Form"
--					AutoBarButton:SetAttributes(button, "AutoBarSAB"..buttonsIndex, nil, nil, nil, nil, nil, nil, nil, nil, macroText)

				-- The popup mostly displays the best to worst choice in order, mostly
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:ButtonsUpdate buttonsIndex " .. tostring(buttonsIndex) .. " itemId " .. tostring(itemId));
					for popupButtonIndex, sortedItemData in ipairs(sortedItems) do
						if (popupButtonIndex > AUTOBAR_MAXPOPUPBUTTONS) then
							break;
						end
						popupItemId = sortedItemData.itemId
						itemData = buttonItems[popupItemId]
						category = itemData.category;
						bag = found[popupItemId][1]
						slot = found[popupItemId][2]
						spell = found[popupItemId][3]
						if (spell) then
							count = 1
						else
							count = GetItemCount(tonumber(popupItemId))
						end
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:ButtonsUpdate popupButtonIndex " .. tostring(popupButtonIndex) .. " popupItemId " .. tostring(popupItemId));

						popupButton = popupButtons[popupButtonIndex];
						AutoBarButton:SetAttributes(popupButton, "AutoBarSAB"..buttonsIndex.."P"..popupButtonIndex, bag, slot, spell, count, popupItemId, category);
						popupButton:SetAttribute("buttonsIndex", buttonsIndex);
						popupButton:SetAttribute("popupButtonIndex", popupButtonIndex);

						if (AutoBar.display.popupOnShift) then
							if (popupButtonIndex == 1) then
--popupButton:SetAttribute("showstates", tostring(buttonsIndex));
								popupButton:SetAttribute("showstates", tostring(buttonsIndex)..","..(tostring(buttonsIndex + AUTOBAR_SHIFTSTATE)));
							else
								popupButton:SetAttribute("showstates", (tostring(buttonsIndex + AUTOBAR_SHIFTSTATE)));
							end
						else
							popupButton:SetAttribute("showstates", tostring(buttonsIndex));
						end

						AutoBarButton:SetVisual("AutoBarSAB"..buttonsIndex.."P"..popupButtonIndex);
					end

					-- Adjust popup positions based on their buttons position
					local buttonWidth, buttonHeight, gapping = AutoBar:GetButtonSize();
					for popupButtonIndex = 1, AUTOBAR_MAXPOPUPBUTTONS do
						local popupButton = popupButtons[popupButtonIndex];
						local buttonDistance = popupButtonIndex - 1;	-- Zero based so first button is on top of its parent

						-- Set the popup direction
						if (AutoBar.display.popupToBottom) then
							popupButton:SetAttribute("ofsx", "*:"..button.x);
							popupButton:SetAttribute("ofsy", "*:"..(button.y - buttonDistance * (buttonHeight + gapping)));
						elseif (AutoBar.display.popupToLeft) then
							popupButton:SetAttribute("ofsx", "*:"..button.x - buttonDistance * (buttonWidth + gapping));
							popupButton:SetAttribute("ofsy", "*:"..(button.y));
						elseif (AutoBar.display.popupToRight) then
							popupButton:SetAttribute("ofsx", "*:"..button.x + buttonDistance * (buttonWidth + gapping));
							popupButton:SetAttribute("ofsy", "*:"..(button.y));
						else
							popupButton:SetAttribute("ofsx", "*:"..button.x);
							popupButton:SetAttribute("ofsy", "*:"..(button.y + buttonDistance * (buttonHeight + gapping)));
						end
					end

					displayButton = displayButton + 1;
				else
--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:ButtonsUpdate buttonsIndex " .. tostring(buttonsIndex).." spell "..tostring(AutoBar.buttons[buttonsIndex].castSpell));
					if (AutoBar.buttons[buttonsIndex] and (AutoBar.display.showCategoryIcon or AutoBar.buttons[buttonsIndex].castSpell)) then
						button:SetAttribute("showstates", "*");
						button.x = AutoBar.buttonLocations[displayButton].x;
						button.y = AutoBar.buttonLocations[displayButton].y;
						button:SetAttribute("ofsx", button.x);
						button:SetAttribute("ofsy", button.y);
					    -- Button is empty so show Category Icon
						local buttonInfo = AutoBar.buttons[buttonsIndex];
						if (buttonInfo and buttonInfo[1]) then
							category = buttonInfo[# buttonInfo]
							AutoBarButton:SetAttributes(button, "AutoBarSAB"..buttonsIndex, nil, nil, nil, 0, nil, category);
							displayButton = displayButton + 1;
						else
							if (AutoBar.display.showEmptyButtons) then
								button:SetAttribute("showstates", "!*");
								displayButton = displayButton + 1;
							end
						end
					else
						button:SetAttribute("showstates", "!*");
					end
				end
			else
				button:SetAttribute("showstates", "!*");
			end
--		end
	end
	self:ButtonsEvent(AutoBarButton.UpdateUsable);
	AutoBar.ssHeader:SetAttribute("state", "0");
	SecureStateHeader_Refresh(AutoBar.ssHeader);
	self:LogEventEnd("AutoBar:ButtonsUpdate")
end


-- Return the display texture of the object
function AutoBar:GetTexture(id)
	if (not id) then
		return "";
	end

	-- Last item has priority so use its icon
	if (type(id) == "table" and id[1]) then
		id = id[# id]
	end

	if (id and AutoBarCategoryList[id]) then
		if (AutoBarCategoryList[id].texture) then
			return "Interface\\Icons\\"..AutoBarCategoryList[id].texture;
		else
			id = AutoBarCategoryList[id].items[# AutoBarCategoryList[id].items];
		end
	end
	if (type(id)=="number" and id > 0) then
		local _,_,_,_,_,_,_,_,_,texture = GetItemInfo(tonumber(id));

		if (texture) then return texture; end
	end
	return "Interface\\Icons\\INV_Misc_Gift_01";
end


--
-- Drag Handle
--

-- Lock & Unlock the frame on left click, and toggle config dialog with right click
function AutoBar:ClickHandle(button)
	local function RelockActionBars()
		self.display.frameLocked = true;
		if (AutoBar.display.lockActionBars) then
			LOCK_ACTIONBAR = "1";
		end
		_G["AutoBarAnchorFrameHandle"]:SetChecked(true);
	end

	if (button == "RightButton") then
		AutoBarConfig_Toggle();
		this:SetChecked(AutoBar.display.frameLocked);
	elseif (button == "LeftButton") then
		AutoBar.display.frameLocked = not AutoBar.display.frameLocked;
		if (AutoBar.display.frameLocked) then
			if (AutoBar.display.lockActionBars) then
				LOCK_ACTIONBAR = "1";
			end
		else
			if (AutoBar.display.lockActionBars) then
				LOCK_ACTIONBAR = "0";
			end
			self:ScheduleEvent("AutoBarTemporaryUnlock", RelockActionBars, 30);
		end
		this:SetChecked(AutoBar.display.frameLocked);
	end
end


-- Start dragging if not locked
function AutoBar:DragStart()
	if (not AutoBar.display.frameLocked) then
		_G["AutoBarFrame"]:StartMoving();
	end
end


-- End dragging
function AutoBar:DragStop()
	_G["AutoBarFrame"]:StopMovingOrSizing();
	AutoBar.display.position = {};
	AutoBar.display.position.x,
	AutoBar.display.position.y = _G["AutoBarAnchorFrameHandle"]:GetCenter();
	AutoBar.display.docking = nil;
end

--DEFAULT_CHAT_FRAME:AddMessage("AutoBar:DragStop" .. frame:GetName() .. "x/y " .. tostring(AutoBar.display.position.x).. "/" ..tostring(AutoBar.display.position.y), 1, 0.5, 0);
