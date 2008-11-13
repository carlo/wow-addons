--
-- AutoBarProfile
-- Copyright 2006+ Toadkiller of Proudmoore.
--
-- Profile System for AutoBar
-- http://code.google.com/p/autobar/
--

-- Data Structure Example for Toadkiller:
--		AutoBar = {
--			buttons = {AutoBarProfile.basic + AutoBarProfile.<CLASS> + AutoBar_Config["_SHARED1"].buttons + AutoBar_Config["Toadkiller - Proudmoore"].buttons},
--			display = {AutoBar_Config["Toadkiller - Proudmoore"].display or AutoBar_Config["_SHARED1"].display},
--		};
--		AutoBar_Config["Toadkiller - Proudmoore"] = {
--			buttons = {AutoBarProfile.basic + AutoBarProfile.<CLASS> + AutoBar_Config["_SHARED1"].buttons},
--			display = {},
--			profile = {},
--		};
--		AutoBar_Config["_SHARED1"] = {
--			buttons = {},
--			display = {},
--		};
--		AutoBar_Config["_DRUID"] = {
--			buttons = {AutoBarProfile.DRUID},
--			display = {},
--		};
--		AutoBar_Config["_BASIC"] = {
--			buttons = {AutoBarProfile.basic},
--			display = {},
--		};
--		AutoBarProfile.<CLASS>
--		AutoBarProfile.basic

AutoBarProfile = {}
AutoBarProfile.MAX_SHARED_PROFILES = 4
AutoBarProfile.version = 1	-- Simple monotonically ascending number

local HEARTHSTONE = 1
local HEALSLOT = 4;
local POTIONSLOT = 5;
local BUFFSLOT1 = 7;
local BUFFSLOT2 = 8;
local FOODSLOT = 9;
local FOODBUFFSLOT = 10;
local BUFFSLOT = 12;
local WEAPONBUFFSLOT1 = 13;
local WEAPONBUFFSLOT2 = 14;
local PETFOOD = 24;
local MOUNTSLOT = 2;

local L = AceLibrary("AceLocale-2.2"):new("AutoBar");
local BS = AceLibrary:GetInstance("Babble-Spell-2.2");

-- Set up Basic Defaults
function AutoBarProfile.InitializeBasic()
	AutoBarProfile.basic = {}
	AutoBarProfile.basic[HEARTHSTONE] = { "HEARTHSTONE" }

	AutoBarProfile.basic[MOUNTSLOT] = { "MOUNTS", "MOUNTS_FLYING", "MOUNTS_QIRAJI" };
	AutoBarProfile.basic[MOUNTSLOT].arrangeOnUse = true;

	AutoBarProfile.basic[3] = { "BANDAGES", "ALTERAC_BANDAGES", "WARSONG_BANDAGES", "ARATHI_BANDAGES" };
	AutoBarProfile.basic[HEALSLOT] = { "HEALPOTIONS", "REJUVENATION_POTIONS", "HEALPOTIONS_BG", "HEALTHSTONE", "Consumable.Potion.Recovery.Healing.Coilfang", "Consumable.Potion.Recovery.Healing.Tempest Keep", "Consumable.Potion.Recovery.Healing.Blades Edge" };
	AutoBarProfile.basic[POTIONSLOT] = {};

	AutoBarProfile.basic[6] = {};
	AutoBarProfile.basic[7] = {};
	AutoBarProfile.basic[8] = {};
	AutoBarProfile.basic[9] = {};
	AutoBarProfile.basic[FOODSLOT] = { "FOOD_PERCENT", "FOOD", "FOOD_CONJURED" };
	AutoBarProfile.basic[11] = { "FOOD_PERCENT_COMBO", "FOOD_COMBO", "FOOD_ARATHI", "FOOD_WARSONG" };
	AutoBarProfile.basic[12] = {};
	AutoBarProfile.basic[WEAPONBUFFSLOT1] = { "BUFF_WEAPON" };
	AutoBarProfile.basic[WEAPONBUFFSLOT1].arrangeOnUse = true;
	AutoBarProfile.basic[WEAPONBUFFSLOT2] = {};
	AutoBarProfile.basic[15] = { "Consumable.Buff.Speed" };
	AutoBarProfile.basic[16] = { "Consumable.Buff.Free Action" };
	AutoBarProfile.basic[17] = { "EXPLOSIVES" };
	AutoBarProfile.basic[18] = { "Tradeskill.Tool.Fishing.Lure", "Tradeskill.Tool.Fishing.Gear", "Tradeskill.Tool.Fishing.Tool" };
	AutoBarProfile.basic[19] = { "BATTLE_STANDARD", "BATTLE_STANDARD_AV" };
	AutoBarProfile.basic[20] = { "MINI_PET", "MINI_PET_HOLIDAY" };
	AutoBarProfile.basic[21] = {};
	AutoBarProfile.basic[22] = {};
	AutoBarProfile.basic[23] = {};
	AutoBarProfile.basic[24] = { "QUEST_ITEMS" };
	AutoBarProfile.basic[24].arrangeOnUse = true;

end

-- Set up Class Defaults
function AutoBarProfile.InitializeClass()
	AutoBarProfile.ROGUE = {};
	AutoBarProfile.ROGUE[POTIONSLOT] = { "ENERGYPOTIONS" };
	AutoBarProfile.ROGUE[FOODBUFFSLOT] = { "Consumable.Food.Buff.Strength", "FOOD_AGILITY", "FOOD_ATTACK_POWER", "FOOD_STAMINA", "FOOD_SPIRIT", "FOOD_HPREGEN", "FOOD_PERCENT_BONUS", "Consumable.Food.Buff.Other" };
	AutoBarProfile.ROGUE[WEAPONBUFFSLOT2] = { "BUFF_WEAPON" };
	AutoBarProfile.ROGUE[WEAPONBUFFSLOT2].arrangeOnUse = true;
	AutoBarProfile.ROGUE[BUFFSLOT] = { "BUFF_OTHER_TARGET", "BUFF_OTHER", "BUFF_GENERAL_TARGET", "BUFF_GENERAL", "BUFF_MELEE_TARGET", "BUFF_MELEE" };

	AutoBarProfile.WARRIOR = {};
	AutoBarProfile.WARRIOR[POTIONSLOT] = { "RAGEPOTIONS" };
	AutoBarProfile.WARRIOR[FOODBUFFSLOT] = AutoBarProfile.ROGUE[FOODBUFFSLOT];
	AutoBarProfile.WARRIOR[WEAPONBUFFSLOT2] = AutoBarProfile.ROGUE[WEAPONBUFFSLOT2];
	AutoBarProfile.WARRIOR[BUFFSLOT] = AutoBarProfile.ROGUE[BUFFSLOT];

	AutoBarProfile.DRUID = {};
	AutoBarProfile.DRUID[HEARTHSTONE] = { "PORTALS", "HEARTHSTONE" }
	AutoBarProfile.DRUID[MOUNTSLOT] = { "MOUNTS", "MOUNTS_SUMMONED", "MOUNTS_FLYING", "MOUNTS_QIRAJI" };
	AutoBarProfile.DRUID[MOUNTSLOT].arrangeOnUse = true;
	AutoBarProfile.DRUID[POTIONSLOT] = { "RUNES", "MANAPOTIONS", "REJUVENATION_POTIONS", "MANAPOTIONS_BG", "Consumable.Potion.Recovery.Mana.Coilfang", "Consumable.Potion.Recovery.Mana.Tempest Keep", "Consumable.Potion.Recovery.Mana.Blades Edge" };
	AutoBarProfile.DRUID[BUFFSLOT1] = { "WATER_PERCENT", "WATER" };
	AutoBarProfile.DRUID[BUFFSLOT2] = { "WATER_SPIRIT" };
	AutoBarProfile.DRUID[FOODBUFFSLOT] = { "Consumable.Food.Buff.Strength", "FOOD_AGILITY", "FOOD_STAMINA", "FOOD_HEALING", "FOOD_INTELLECT", "FOOD_SPIRIT", "FOOD_HPREGEN", "FOOD_MANAREGEN", "FOOD_PERCENT_BONUS", "Consumable.Food.Buff.Other", "FOOD_SPELL_DAMAGE" };
	AutoBarProfile.DRUID[BUFFSLOT] = { "BUFF_OTHER_TARGET", "BUFF_OTHER", "BUFF_GENERAL_TARGET", "BUFF_GENERAL", "BUFF_MELEE_TARGET", "BUFF_MELEE", "BUFF_CASTER_TARGET", "BUFF_CASTER" };

	AutoBarProfile.HUNTER = {};
	AutoBarProfile.HUNTER[POTIONSLOT] = AutoBarProfile.DRUID[POTIONSLOT];
	AutoBarProfile.HUNTER[BUFFSLOT1] = AutoBarProfile.DRUID[BUFFSLOT1];
	AutoBarProfile.HUNTER[BUFFSLOT2] = AutoBarProfile.DRUID[BUFFSLOT2];
	AutoBarProfile.HUNTER[FOODBUFFSLOT] = AutoBarProfile.DRUID[FOODBUFFSLOT];
	AutoBarProfile.HUNTER[PETFOOD] = { "FOOD_PET_BREAD", "FOOD_PET_CHEESE", "FOOD_PET_FISH", "FOOD_PET_FRUIT", "FOOD_PET_FUNGUS", "FOOD_PET_MEAT" };
	AutoBarProfile.HUNTER[PETFOOD].arrangeOnUse = true;
	AutoBarProfile.HUNTER[PETFOOD].rightClickTargetsPet = true;
	AutoBarProfile.HUNTER[BUFFSLOT] = AutoBarProfile.DRUID[BUFFSLOT];

	AutoBarProfile.MAGE = {};
	AutoBarProfile.MAGE[HEARTHSTONE] = { "PORTALS", "HEARTHSTONE" }
	AutoBarProfile.MAGE[POTIONSLOT] = { "RUNES", "MANAPOTIONS", "REJUVENATION_POTIONS", "MANAPOTIONS_BG", "MANASTONE", "Consumable.Potion.Recovery.Mana.Coilfang", "Consumable.Potion.Recovery.Mana.Tempest Keep", "Consumable.Potion.Recovery.Mana.Blades Edge" };
	AutoBarProfile.MAGE[BUFFSLOT1] = { "WATER_CONJURE", "WATER_PERCENT", "WATER" };
	AutoBarProfile.MAGE[BUFFSLOT2] = AutoBarProfile.DRUID[BUFFSLOT2];
	AutoBarProfile.MAGE[FOODSLOT] = { "FOOD_CONJURE", "FOOD_PERCENT", "FOOD", "FOOD_CONJURED" };
	AutoBarProfile.MAGE[FOODBUFFSLOT] = { "FOOD_STAMINA", "FOOD_INTELLECT", "FOOD_HPREGEN", "FOOD_MANAREGEN", "FOOD_SPELL_DAMAGE" };
	AutoBarProfile.MAGE[BUFFSLOT] = { "BUFF_OTHER_TARGET", "BUFF_OTHER", "BUFF_GENERAL_TARGET", "BUFF_GENERAL", "BUFF_CASTER_TARGET", "BUFF_CASTER" };
	AutoBarProfile.MAGE[23] = { "MANASTONE_CONJURE" };

	AutoBarProfile.PALADIN = {};
	AutoBarProfile.PALADIN[MOUNTSLOT] = { "MOUNTS", "MOUNTS_SUMMONED", "MOUNTS_FLYING", "MOUNTS_QIRAJI" };
	AutoBarProfile.PALADIN[MOUNTSLOT].arrangeOnUse = true;
	AutoBarProfile.PALADIN[POTIONSLOT] = AutoBarProfile.DRUID[POTIONSLOT];
	AutoBarProfile.PALADIN[BUFFSLOT1] = AutoBarProfile.DRUID[BUFFSLOT1];
	AutoBarProfile.PALADIN[BUFFSLOT2] = AutoBarProfile.DRUID[BUFFSLOT2];
	AutoBarProfile.PALADIN[FOODBUFFSLOT] = AutoBarProfile.DRUID[FOODBUFFSLOT];
	AutoBarProfile.PALADIN[BUFFSLOT] = AutoBarProfile.DRUID[BUFFSLOT];

	AutoBarProfile.PRIEST = {};
	AutoBarProfile.PRIEST[POTIONSLOT] = AutoBarProfile.DRUID[POTIONSLOT];
	AutoBarProfile.PRIEST[BUFFSLOT1] = AutoBarProfile.DRUID[BUFFSLOT1];
	AutoBarProfile.PRIEST[BUFFSLOT2] = AutoBarProfile.DRUID[BUFFSLOT2];
	AutoBarProfile.PRIEST[FOODBUFFSLOT] = AutoBarProfile.MAGE[FOODBUFFSLOT];
	AutoBarProfile.PRIEST[BUFFSLOT] = AutoBarProfile.MAGE[BUFFSLOT];

	AutoBarProfile.SHAMAN = {};
	AutoBarProfile.SHAMAN[HEARTHSTONE] = { "PORTALS", "HEARTHSTONE" }
	AutoBarProfile.SHAMAN[MOUNTSLOT] = { "MOUNTS", "MOUNTS_SUMMONED", "MOUNTS_FLYING", "MOUNTS_QIRAJI" };
	AutoBarProfile.SHAMAN[MOUNTSLOT].arrangeOnUse = true;
	AutoBarProfile.SHAMAN[POTIONSLOT] = AutoBarProfile.DRUID[POTIONSLOT];
	AutoBarProfile.SHAMAN[BUFFSLOT1] = AutoBarProfile.DRUID[BUFFSLOT1];
	AutoBarProfile.SHAMAN[BUFFSLOT2] = AutoBarProfile.DRUID[BUFFSLOT2];
	AutoBarProfile.SHAMAN[FOODBUFFSLOT] = AutoBarProfile.DRUID[FOODBUFFSLOT];
	AutoBarProfile.SHAMAN[WEAPONBUFFSLOT2] = AutoBarProfile.ROGUE[WEAPONBUFFSLOT2];
	AutoBarProfile.SHAMAN[BUFFSLOT] = AutoBarProfile.DRUID[BUFFSLOT];

	AutoBarProfile.WARLOCK = {};
	AutoBarProfile.WARLOCK[HEARTHSTONE] = { "PORTALS", "HEARTHSTONE" }
	AutoBarProfile.WARLOCK[MOUNTSLOT] = { "MOUNTS", "MOUNTS_SUMMONED", "MOUNTS_FLYING", "MOUNTS_QIRAJI" };
	AutoBarProfile.WARLOCK[MOUNTSLOT].arrangeOnUse = true;
	AutoBarProfile.WARLOCK[POTIONSLOT] = AutoBarProfile.DRUID[POTIONSLOT];
	AutoBarProfile.WARLOCK[BUFFSLOT1] = AutoBarProfile.DRUID[BUFFSLOT1];
	AutoBarProfile.WARLOCK[BUFFSLOT2] = AutoBarProfile.DRUID[BUFFSLOT2];
	AutoBarProfile.WARLOCK[FOODBUFFSLOT] = AutoBarProfile.MAGE[FOODBUFFSLOT];
	AutoBarProfile.WARLOCK[BUFFSLOT] = AutoBarProfile.MAGE[BUFFSLOT];
	AutoBarProfile.WARLOCK[23] = { "HEALTHSTONE_CONJURE" };

	for buttonIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		if (not AutoBarProfile[AutoBar.CLASS][buttonIndex]) then
			AutoBarProfile[AutoBar.CLASS][buttonIndex] = {};
		end
	end
	AutoBarProfile[AutoBar.CLASS][FOODBUFFSLOT].arrangeOnUse = true;


end


local function clone(o)
	local new_o = {};	-- creates a new object
	for i, v in pairs(o) do
		if (type(v) == "table") then
			new_o[i] = clone(v);			-- store them in new table
		else
			new_o[i] = v;
		end
	end
	return new_o;
end


-- Clone the given profile, returning the clone
function AutoBarProfile.CloneUserProfile()
	if (AutoBarProfile:GetProfile()) then
		return clone(AutoBarProfile:GetProfile());
	else
		return nil;
	end
end


-- Clone the given profile, returning the clone
function AutoBarProfile.CloneProfile(profileName)
	if (AutoBar_Config[profileName]) then
		return clone(AutoBar_Config[profileName]);
	else
		return nil;
	end
end


-- Clone all profiles, return them in a table
function AutoBarProfile.CloneProfiles()
	local profilesClone = {};
	profilesClone[AutoBar.currentPlayer] = AutoBarProfile.CloneProfile(AutoBar.currentPlayer);
	for index = 1, AutoBarProfile.MAX_SHARED_PROFILES, 1 do
		local sharedName = "_SHARED"..index;
		profilesClone[sharedName] = AutoBarProfile.CloneProfile(sharedName);
	end
	if (AutoBar_Config[AutoBar.CLASSPROFILE]) then
		profilesClone[AutoBar.CLASSPROFILE] = AutoBarProfile.CloneProfile(AutoBar.CLASSPROFILE);
	end
	if (AutoBar_Config["_BASIC"]) then
		profilesClone["_BASIC"] = AutoBarProfile.CloneProfile("_BASIC");
	end
	return profilesClone;
end


-- Revert all profiles from the cloned table
function AutoBarProfile.RevertProfiles(profilesClone)
	AutoBar_Config[AutoBar.currentPlayer] = profilesClone[AutoBar.currentPlayer];
	for index = 1, AutoBarProfile.MAX_SHARED_PROFILES, 1 do
		local sharedName = "_SHARED"..index;
		AutoBar_Config[sharedName] = profilesClone[sharedName];
	end
	if (profilesClone[AutoBar.CLASSPROFILE]) then
		AutoBar_Config[AutoBar.CLASSPROFILE] = profilesClone[AutoBar.CLASSPROFILE];
	end
	if (profilesClone["_BASIC"]) then
		AutoBar_Config["_BASIC"] = profilesClone["_BASIC"];
	end
end


-- Set up space by profileName
function AutoBarProfile.InitializeProfile(profileName)
	if (not AutoBar_Config[profileName]) then
		AutoBar_Config[profileName] = {};
	end
	if (not AutoBar_Config[profileName].buttons) then
		AutoBar_Config[profileName].buttons = {};
	end
	if (not AutoBar_Config[profileName].display) then
		AutoBar_Config[profileName].display = {};
	end

	local display = AutoBar_Config[profileName].display;
	if (not display.rows) then
		display.rows = 1;
	end
	if (not display.columns) then
		display.columns = AUTOBAR_MAXBUTTONS;
	end
	if (not display.gapping) then
		display.gapping = 0;
	end
	if (not display.alpha) then
		display.alpha = 10;
	end
	if (not display.buttonWidth) then
		display.buttonWidth = 36;
	end
	if (not display.buttonHeight) then
		display.buttonHeight = 36;
	end
	if (not display.dockShiftX) then
		display.dockShiftX = 0;
	end
	if (not display.dockShiftY) then
		display.dockShiftY = 0;
	end
	if (not (display.popupToTop or display.popupToLeft or display.popupToRight or display.popupToBottom)) then
		display.popupToTop = true;
	end
	if (not display.style) then
		display.style = 3;
	end
end



-- Convert all slots to use tables and not single items
function AutoBarProfile.ConvertSlots(profileName)
	if (not AutoBar_Config[profileName]) then
		return;
	end
	if (not AutoBar_Config[profileName].buttons) then
		return;
	end
	local temp;
	local buttons = AutoBar_Config[profileName].buttons;
	for buttonIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		if (buttons[buttonIndex] and type(buttons[buttonIndex]) ~= "table") then
			temp = buttons[buttonIndex];
			buttons[buttonIndex] = { temp };
		elseif (not buttons[buttonIndex]) then
			buttons[buttonIndex] = {};
		end

		local categoryMap = {
			["FISHINGITEMS"] = "Tradeskill.Tool.Fishing.Lure",
			["FOOD_INTELLIGENCE"] = "FOOD_INTELLECT",
			["FOOD_WATER"] = "FOOD_COMBO",
			["MOUNTS_TROLL"] = "MOUNTS",
			["MOUNTS_ORC"] = "MOUNTS",
			["MOUNTS_UNDEAD"] = "MOUNTS",
			["MOUNTS_TAUREN"] = "MOUNTS",
			["MOUNTS_HUMAN"] = "MOUNTS",
			["MOUNTS_NIGHTELF"] = "MOUNTS",
			["MOUNTS_DWARF"] = "MOUNTS",
			["MOUNTS_GNOME"] = "MOUNTS",
			["ALTERAC_HEAL"] = "AAACLEAR",
			["ALTERAC_MANA"] = "AAACLEAR",
			["NIGHT_DRAGONS_BREATH"] = "AAACLEAR",
			["WHIPPER_ROOT"] = "AAACLEAR",
			["WEIGHTSTONE"] = "WEIGHTSTONES",
			["MANA_OIL"] = "OIL_MANA",
			["WIZARD_OIL"] = "OIL_WIZARD",

			["PROTECTION_ARCANE"] = "AAACLEAR",
			["PROTECTION_FIRE"] = "AAACLEAR",
			["PROTECTION_FROST"] = "AAACLEAR",
			["PROTECTION_NATURE"] = "AAACLEAR",
			["PROTECTION_SHADOW"] = "AAACLEAR",
			["PROTECTION_SPELLS"] = "AAACLEAR",
			["PROTECTION_HOLY"] = "AAACLEAR",
			["PROTECTION_DAMAGE"] = "AAACLEAR",
			["SOULSHARDS"] = "AAACLEAR",
			["HOURGLASS_SAND"] = "AAACLEAR",

			["SWIFTNESSPOTIONS"] = "Consumable.Buff.Speed",
			["ACTION_POTIONS"] = "Consumable.Buff.Free Action",
			["FIREWORKS"] = "Misc.Engineering.Fireworks",
			["FISHING_GEAR"] = "Tradeskill.Tool.Fishing.Gear",
			["FISHING_LURES"] = "Tradeskill.Tool.Fishing.Lure",
			["FISHING_POLES"] = "Tradeskill.Tool.Fishing.Tool",

			["FOOD_OTHER"] = "Consumable.Food.Buff.Other",
			["FOOD_STRENGTH"] = "Consumable.Food.Buff.Strength",

			["POTION_AGILITY"] = "BUFF_MELEE",
			["POTION_STRENGTH"] = "BUFF_MELEE",
			["POTION_FORTITUDE"] = "BUFF_ALL",
			["POTION_INTELLECT"] = "BUFF_CASTER",
			["POTION_WISDOM"] = "AAACLEAR",
			["POTION_DEFENSE"] = "BUFF_MELEE",
			["POTION_TROLL"] = "BUFF_ALL",
			["SCROLL_AGILITY"] = "BUFF_MELEE",
			["SCROLL_INTELLECT"] = "BUFF_CASTER",
			["SCROLL_PROTECTION"] = "BUFF_ALL",
			["SCROLL_SPIRIT"] = "BUFF_ALL",
			["SCROLL_STAMINA"] = "BUFF_ALL",
			["SCROLL_STRENGTH"] = "BUFF_MELEE",
			["BUFF_FROST"] = "BUFF_RESISTANCE",
			["BUFF_FIRE"] = "BUFF_RESISTANCE",

			["FOOD_WELL_FED"] = "Consumable.Food.Bonus",
			["FOOD_BUFF"] = "Consumable.Food.Bonus",
		};
		local slotInfo = buttons[buttonIndex];
		for i = 1, # slotInfo, 1 do
			if (categoryMap[slotInfo[i]]) then
				slotInfo[i] = categoryMap[slotInfo[i]];
			end
		end

		-- Delete all adjacent duplicates (mostly mounts + the occasional user error)
		local i = 2;
		while (slotInfo[i]) do
			if (slotInfo[i] == slotInfo[i - 1]) then
				table.remove(slotInfo, i);
			else
				i = i + 1;
			end
		end
	end
end


-- Convert all profile's slots to use tables and not single items
-- Map obsolete categories to new ones
function AutoBarProfile:Upgrade()
	AutoBarProfile.ConvertSlots(AutoBar.currentPlayer);
	AutoBarProfile.ConvertSlots("_SHARED1");
	AutoBarProfile.ConvertSlots("_SHARED2");
	AutoBarProfile.ConvertSlots("_SHARED3");
	AutoBarProfile.ConvertSlots("_SHARED4");
	AutoBarProfile.ConvertSlots(AutoBar.CLASSPROFILE);
	AutoBarProfile.ConvertSlots("_BASIC");

	upgraded = true;
end


local upgraded = false;
-- Set up defaults for the player if required
function AutoBarProfile.Initialize()
	if (not AutoBar_Config) then AutoBar_Config = {}; end

	if (not upgraded) then
		AutoBarProfile.Upgrade();
	end

	if (not AutoBarProfile.basic) then
		AutoBarProfile.InitializeBasic();
	end

	if (not AutoBarProfile[AutoBar.CLASS]) then
		AutoBarProfile.InitializeClass();
	end

	AutoBarProfile.InitializeProfile(AutoBar.currentPlayer);
	for index = 1, AutoBarProfile.MAX_SHARED_PROFILES, 1 do
		local sharedName = "_SHARED"..index;
		AutoBarProfile.InitializeProfile(sharedName);
	end
	if (not AutoBar_Config[AutoBar.CLASSPROFILE]) then
		AutoBarProfile.InitializeProfile(AutoBar.CLASSPROFILE);
		AutoBar_Config[AutoBar.CLASSPROFILE].buttons = clone(AutoBarProfile[AutoBar.CLASS]);
	end
	if (not AutoBar_Config[AutoBar.CLASSPROFILE].buttons) then
		AutoBar_Config[AutoBar.CLASSPROFILE].buttons = clone(AutoBarProfile[AutoBar.CLASS]);
	end
	if (not AutoBar_Config["_BASIC"]) then
		AutoBarProfile.InitializeProfile("_BASIC");
		AutoBar_Config["_BASIC"].buttons = clone(AutoBarProfile.basic);
	end
	if (not AutoBar_Config["_BASIC"].buttons) then
		AutoBar_Config["_BASIC"].buttons = clone(AutoBarProfile.basic);
	end

	if (not AutoBarProfile:GetProfile()) then
		AutoBarProfile:SetDefaults();
	end
	local profile = AutoBarProfile:GetProfile();
	if (not profile.shared) then
		profile.shared = "_SHARED1";
	end
	if (profile.layout == 1) then
		profile.layoutProfile = AutoBar.currentPlayer;
	elseif (profile.layout == 2) then
		profile.layoutProfile = profile.shared;
	else
		profile.layout = 2;
		profile.layoutProfile = profile.shared;
	end
	if (not AutoBar.buttons) then
		AutoBarProfile:ButtonsCopy();
	end

	AutoBarProfile:DisplayCopy()
	AutoBar:LogToggle()
end


function AutoBarProfile:SetDefaults()
	if (not AutoBarProfile:GetProfile()) then
		AutoBar_Config[AutoBar.currentPlayer].profile = {};
	end
	if (AutoBar_Config[AutoBar.currentPlayer].buttons and # AutoBar_Config[AutoBar.currentPlayer].buttons > 0) then
		AutoBarProfile:SetDefaultsSingle();
	else
		AutoBarProfile:SetDefaultsStandard();
	end
end


function AutoBarProfile:SetDefaultsSingle()
	local profile = AutoBarProfile:GetProfile();
	profile.useCharacter = true;
	profile.useShared = false;
	profile.useClass = false;
	profile.useBasic = false;
	profile.edit = 1;
	profile.shared = "_SHARED1";
	profile.layout = 1;
	profile.layoutProfile = AutoBar.currentPlayer;
	profile.style = 3;
end


function AutoBarProfile:SetDefaultsShared()
	local profile = AutoBarProfile:GetProfile();
	profile.useCharacter = true;
	profile.useShared = true;
	profile.useClass = false;
	profile.useBasic = false;
	profile.edit = 2;
	profile.shared = "_SHARED1";
	profile.layout = 2;
	profile.layoutProfile = "_SHARED1";
	profile.style = 3;
end


function AutoBarProfile:SetDefaultsStandard()
	local profile = AutoBarProfile:GetProfile();
	profile.useCharacter = true;
	profile.useShared = true;
	profile.useClass = true;
	profile.useBasic = true;
	profile.edit = 2;
	profile.shared = "_SHARED1";
	profile.layout = 2;
	profile.layoutProfile = "_SHARED1";
	profile.style = 3;
end


function AutoBarProfile:SetDefaultsBlankSlate()
	local profile = AutoBarProfile:GetProfile();
	profile.useCharacter = true;
	profile.useShared = true;
	profile.useClass = false;
	profile.useBasic = false;
	profile.edit = 2;
	profile.shared = "_SHARED1";
	profile.layout = 2;
	profile.layoutProfile = "_SHARED1";
	profile.style = 3;
end


function AutoBarProfile:GetEditPlayer()
	local editPlayer;
	local profile = AutoBarProfile:GetProfile();
	if (profile.edit == 1) then
		editPlayer = AutoBar.currentPlayer;
	elseif (profile.edit == 2) then
		editPlayer = profile.shared;
	elseif (profile.edit == 3) then
		editPlayer = AutoBar.CLASSPROFILE;
	elseif (profile.edit == 4) then
		editPlayer = "_BASIC";
	else
		profile.edit = 1;
		editPlayer = AutoBar.currentPlayer;
	end
	return editPlayer;
end


function AutoBarProfile:ProfileEditingChanged()
	AutoBarConfig.editPlayer = AutoBarProfile:GetEditPlayer();
	AutoBarProfile.Initialize();
	AutoBarProfile:ButtonsCopy();
	AutoBarConfig.OnShow();
	AutoBar.delayReset:Start()
end


function AutoBarProfile:GetProfile()
	return AutoBar_Config[AutoBar.currentPlayer].profile;
end


function AutoBarProfile:InitializeLayoutProfile()
	local profile = AutoBarProfile:GetProfile();
	if (profile.layout == 1) then
		profile.layoutProfile = AutoBar.currentPlayer;
	else
		profile.layoutProfile = profile.shared;
	end
end


function AutoBarProfile:LayoutChanged()
	AutoBarProfile:InitializeLayoutProfile();
	AutoBarProfile:ProfileChanged();
end


function AutoBarProfile:ProfileChanged()
	AutoBarProfile:DisplayCopy();
	AutoBarProfile:ButtonsCopy();
	AutoBarConfig.OnShow();
	AutoBar.delayReset:Start()
end


function AutoBarProfile:DisplayChanged()
	AutoBarProfile:DisplayCopy();
	AutoBar.delayReset:Start()
end


function AutoBarProfile:ButtonsChanged()
--/script DEFAULT_CHAT_FRAME:AddMessage(AutoBarProfile:GetProfile().shared);
	AutoBarProfile:ButtonsCopy();
	AutoBar.delayReset:Start()
	AutoBarConfig:SlotsViewInitialize();
	AutoBarConfig:SlotsInitialize();
end


function AutoBarProfile:DisplayCopy()
	local profile = AutoBarProfile:GetProfile();

	AutoBar.display = nil;
	if (profile.layout == 1) then
		AutoBar.display = AutoBar_Config[AutoBar.currentPlayer].display;
	else
		AutoBar.display = AutoBar_Config[profile.shared].display;
	end

	-- TODO: fix popupOnShift
	AutoBar.display.popupOnShift = false
end


-- Assign buttons from eligible layer with precedence characterButtons > sharedButtons > classButtons > basicButtons
function AutoBarProfile:ButtonsCopy()
	local profile = AutoBarProfile:GetProfile();
	local characterButtons, sharedButtons, classButtons, basicButtons;

	if (profile.useCharacter and AutoBar_Config[AutoBar.currentPlayer].buttons) then
		characterButtons = AutoBar_Config[AutoBar.currentPlayer].buttons;
	end
	if (profile.useShared and profile.shared and AutoBar_Config[profile.shared] and AutoBar_Config[profile.shared].buttons) then
		sharedButtons = AutoBar_Config[profile.shared].buttons;
	end
	if (profile.useClass and AutoBar_Config[AutoBar.CLASSPROFILE] and AutoBar_Config[AutoBar.CLASSPROFILE].buttons) then
		classButtons = AutoBar_Config[AutoBar.CLASSPROFILE].buttons;
	end
	if (profile.useBasic and AutoBar_Config["_BASIC"] and AutoBar_Config["_BASIC"].buttons) then
		basicButtons = AutoBar_Config["_BASIC"].buttons;
	end

	-- Copy the buttons
	if (not AutoBar.buttons) then
		AutoBar.buttons = {};
	end
	for buttonIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		AutoBar.buttons[buttonIndex] = nil;
		if (characterButtons and characterButtons[buttonIndex] and characterButtons[buttonIndex][1]) then
			AutoBar.buttons[buttonIndex] = clone(characterButtons[buttonIndex]);
		elseif (sharedButtons and sharedButtons[buttonIndex] and sharedButtons[buttonIndex][1]) then
			AutoBar.buttons[buttonIndex] = clone(sharedButtons[buttonIndex]);
		elseif (classButtons and classButtons[buttonIndex] and classButtons[buttonIndex][1]) then
			AutoBar.buttons[buttonIndex] = clone(classButtons[buttonIndex]);
		elseif (basicButtons and basicButtons[buttonIndex] and basicButtons[buttonIndex][1]) then
			AutoBar.buttons[buttonIndex] = clone(basicButtons[buttonIndex]);
		else
			AutoBar.buttons[buttonIndex] = {};
		end
	end

--	DEFAULT_CHAT_FRAME:AddMessage("\n\n AutoBarProfile:ButtonsCopy")
--	if (DevTools_Dump) then
--		DevTools_Dump(AutoBar.buttons)
--	end
end


-- Assign buttons from classButtons and basicButtons layer to characterButtons
function AutoBarProfile:ButtonsCopySingle()
	local characterButtons, classButtons, basicButtons;

	characterButtons = AutoBar_Config[AutoBar.currentPlayer].buttons;
	classButtons = AutoBarProfile[AutoBar.CLASS];
	basicButtons = AutoBarProfile.basic;

	-- Copy the buttons
	for buttonIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		characterButtons[buttonIndex] = nil;
		if (classButtons and classButtons[buttonIndex] and classButtons[buttonIndex][1]) then
			characterButtons[buttonIndex] = clone(classButtons[buttonIndex]);
		elseif (basicButtons and basicButtons[buttonIndex] and basicButtons[buttonIndex][1]) then
			characterButtons[buttonIndex] = clone(basicButtons[buttonIndex]);
		else
			characterButtons[buttonIndex] = {};
		end
	end
end


-- Assign buttons from classButtons and basicButtons layers to characterButtons and sharedButtons respectively
function AutoBarProfile:ButtonsCopyShared()
	local profile = AutoBarProfile:GetProfile();
	local characterButtons, sharedButtons, classButtons, basicButtons;

	characterButtons = AutoBar_Config[AutoBar.currentPlayer].buttons;
	sharedButtons = AutoBar_Config[profile.shared].buttons;
	classButtons = AutoBarProfile[AutoBar.CLASS];
	basicButtons = AutoBarProfile.basic;

	-- Copy the buttons
	for buttonIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		characterButtons[buttonIndex] = nil;
		if (classButtons and classButtons[buttonIndex] and classButtons[buttonIndex][1]) then
			characterButtons[buttonIndex] = clone(classButtons[buttonIndex]);
		else
			characterButtons[buttonIndex] = {};
		end
		sharedButtons[buttonIndex] = nil;
		if (basicButtons and basicButtons[buttonIndex] and basicButtons[buttonIndex][1]) then
			sharedButtons[buttonIndex] = clone(basicButtons[buttonIndex]);
		else
			sharedButtons[buttonIndex] = {};
		end
	end
end


-- Reset the defaults and clear out characterButtons and sharedButtons respectively
function AutoBarProfile:ButtonsCopyStandard()
	local profile = AutoBarProfile:GetProfile();
	local characterButtons, sharedButtons, classButtons, basicButtons;
	local classLayerButtons, basicLayerButtons;

	characterButtons = AutoBar_Config[AutoBar.currentPlayer].buttons;
	sharedButtons = AutoBar_Config[profile.shared].buttons;
	classButtons = AutoBarProfile[AutoBar.CLASS];
	basicButtons = AutoBarProfile.basic;
	classLayerButtons = AutoBar_Config[AutoBar.CLASSPROFILE].buttons;
	basicLayerButtons = AutoBar_Config["_BASIC"].buttons;

	-- Copy the buttons
	for buttonIndex = 1, AUTOBAR_MAXBUTTONS, 1 do
		characterButtons[buttonIndex] = {};
		sharedButtons[buttonIndex] = {};
		classLayerButtons[buttonIndex] = nil;
		if (classButtons and classButtons[buttonIndex] and classButtons[buttonIndex][1]) then
			classLayerButtons[buttonIndex] = clone(classButtons[buttonIndex]);
		else
			classLayerButtons[buttonIndex] = {};
		end
		basicLayerButtons[buttonIndex] = nil;
		if (basicButtons and basicButtons[buttonIndex] and basicButtons[buttonIndex][1]) then
			basicLayerButtons[buttonIndex] = clone(basicButtons[buttonIndex]);
		else
			basicLayerButtons[buttonIndex] = {};
		end
	end
end


-- /script DevTools_Dump(AutoBarProfile.MAGE[1])
-- /script DevTools_Dump(AutoBar.buttons[1])
-- /script DEFAULT_CHAT_FRAME:AddMessage(tostring(AutoBarProfile.MAGE[HEARTHSTONE].items))
-- /script DEFAULT_CHAT_FRAME:AddMessage(tostring(AutoBar.buttons[2].castSpell))
