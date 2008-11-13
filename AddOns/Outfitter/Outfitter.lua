gOutfitter_Settings = nil;
--GetItemInfo(ItemLink) 
Outfitter =
{
	Initialized = false,
	Suspended = false,
	-- Outfit state
	
	OutfitStack = {},
	lastToolTip = nil,
	CurrentOutfit = nil,
	ExpectedOutfit = nil,
	CurrentInventoryOutfit = nil,
	
	EquippedNeedsUpdate = false,
	WeaponsNeedUpdate = false,
	LastEquipmentUpdateTime = 0,
	
	SpecialState = {}, -- The current state as determined by the engine, not necessarily the state of the outfit itself
	
	OutfitScriptEvents = {},

	-- Player state
	
	CurrentZone = "",
	
	InCombat = false,
	MaybeInCombat = false,
	
	IsDead = false,
	IsFeigning = false,
	
	BankFrameOpened = false,
	
	-- UI
	
	CurrentPanel = 0,
	Collapsed = {},
	SelectedOutfit = nil,
	DisplayIsDirty = true,

	PriorityLayerLevel = {}, -- array, not object
-- modified by jtbalogh
};

local PriorityLayerLevelMax = 9
-- modified by jtbalogh

local Outfitter_cMinEquipmentUpdateInterval = 1.5;
local DebugData = {};

gOutfit_OutfitName = nil;
gOutfitter_OrigGameTooltipOnShow = nil;
gOutfitter_OrigGameTooltipOnHide = nil;

local	Outfitter_cInitializationEvents =
{
	["PLAYER_ENTERING_WORLD"] = true,
	["BAG_UPDATE"] = true,
	["UNIT_INVENTORY_CHANGED"] = true,
	["ZONE_CHANGED_NEW_AREA"] = true,
	["PLAYER_ALIVE"] = true,
};

local	BANKED_FONT_COLOR = {r = 0.25, g = 0.2, b = 1.0};
local	BANKED_FONT_COLOR_CODE = "|cff4033ff";
local	OUTFIT_MESSAGE_COLOR = {r = 0.2, g = 0.75, b = 0.3};
local OUTFIT_InDining = false;
local OUTFIT_HasEngineeringBag = false;

local	Outfitter_cItemLinkFormat = "|(%x+)|Hitem:(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+):(-?%d+)|h%[([^%]]+)%]|h|r";

local	gOutfitter_LastManaCall = -1;
local gOutfitter_currMana;
local	gOutfitter_PresetScripts =
{
	{
		Name = Outfitter_cHerbalismOutfit,
		ID = "HERBALISM",
		Events = "GAMETOOLTIP_SHOW GAMETOOLTIP_HIDE",
		Script = "-- $DESC Equips the outfit whenever your cursor is over an herb node that is orange or red to you\nif event==\"GAMETOOLTIP_SHOW\" then\n    local hasText,isDifficult = Outfitter_TooltipContainsLine(GameTooltip, UNIT_SKINNABLE_HERB);\n    if hasText then\n        if isDifficult then equip=true end\n    end\nelseif didEquip then\n    equip=false; delay=1\nend",
	},
	{
		Name = Outfitter_cMiningOutfit,
		ID = "MINING",
		Events = "GAMETOOLTIP_SHOW GAMETOOLTIP_HIDE",
		Script = "-- $DESC Equips the outfit whenever your cursor is over a mining node that is orange or red to you\nif event==\"GAMETOOLTIP_SHOW\" then\n    local hasText,isDifficult = Outfitter_TooltipContainsLine(GameTooltip, UNIT_SKINNABLE_ROCK);\n    if hasText then\n        if isDifficult then equip=true end\n    end\nelseif didEquip then\n    equip=false; delay=1\nend",
	},
	{
		Name = Outfitter_cSkinningOutfit,
		ID = "SKINNING",
		Events = "GAMETOOLTIP_SHOW GAMETOOLTIP_HIDE",
		Script = "-- $DESC Equips the outfit whenever your cursor is over a skinnable creature that is orange or red to you\nif event==\"GAMETOOLTIP_SHOW\" then\n    local hasText,isDifficult = Outfitter_TooltipContainsLine(GameTooltip, UNIT_SKINNABLE_LEATHER);\n    if hasText then\n        if isDifficult then equip=true end\n    end\nelseif didEquip then\n    equip=false; delay=1\nend",
	},
	{
		Name = "Low Health",
		ID = "LOW_HEALTH",
		Events = "UNIT_HEALTH",
		Script = "-- $DESC The outfit will be equipped when your health goes below the specified percentage\n-- $SETTING Health=\"Number\"\n\nif arg1==\"player\"\nand UnitHealth(arg1) / UnitHealthMax(arg1) < setting.Health then\n    equip = true\nelseif didEquip then\n    equp = false\nend",
	},
	{
		Name = "Low Mana",
		ID = "LOW_MANA",
		Events = "UNIT_MANA",
		Script = "-- $DESC The outfit will be equipped when your mana goes below the specified percentage\n-- $SETTING Mana=\"Number\"\n\nif arg1==\"player\"\nand UnitMana(arg1) / UnitManaMax(arg1) < setting.Mana then\n    equip = true\nelseif didEquip then\n    equp = false\nend",
	},
	{
		Name = "Nefarian's Lair",
		ID = "NEFS_LAIR",
		Events = "ZONE_CHANGED_INDOORS",
		Script = "-- $DESC Equips the outfit whenever you enter Nefarian's Lair and unequips it when you leave\nif string.find(GetMinimapZoneText(), \"Nefarian\239\191\189s Lair\") then\n    equip=true\nelseif didEquip then\n    equip=false\nend",
	},
	{
		Name = "Trinket Checker",
		ID = "TRINKET_CHECKER",
		Events = "UNIT_SPELLCAST_SENT",
		Script = "-- $SETTING Trinkets=\"StringTable\"\n-- $DESC Checking is trinket has been clicked.\nlocal bFound1 = false;\nlocal bFound2 = false;\nlocal sName ;\n\n-- This is the trinket I check for\nlocal sTrinketName = \"Glowing Crystal Insignia\";\n\n-- get the Links for Trinket 1 and 2\nlocal sItemLink1 = GetInventoryItemLink(\"player\", 13);\nlocal sItemLink2 = GetInventoryItemLink(\"player\", 14);\n\nif arg4 ~= \"\" and arg4 ~= \"PLANYERS_NAME\" then\n\n   -- Make sure we have a Trinket in Slot 1 \n   for _, itemName in ipairs(setting.Trinkets) do\n      if sItemLink1 then\n         sName, _  = GetItemInfo(sItemLink1);\n         if sName == itemName then\n            bFound1 = true;\n         end\n      end\n\n   -- Make sure we have a trinket in slot two\n   if sItemLink2 then\n      sName, _ =  GetItemInfo(sItemLink2);\n      if sName == itemName then\n         bFound2 = true;\n      end\n   end\n\n   local startTime, duration, enable = GetItemCooldown(sTrinketName)\n\n      if  not bFound1 and not bFound2 then\n         -- DEFAULT_CHAT_FRAME:AddMessage(sTrinketName ..\" is not Equip'd\");\n \n      else\n         if duration == 0 then\n            local sMessage = \"Why have \\\"\"..itemName..\"\\\" on is your not going to use it?\";\n            SCT:CmdDisplay(\"'\"..sMessage..\"' 10 0 0\")\n         end\n      end\n   end\nend\n",
	},
	{
		Name = "Trinket Queue",
		ID = "TRINKET_QUEUE",
		Events = "TIMER",
		Script = "-- $SETTING Trinkets=\"StringTable\"\n-- $DESC List your trinkets below.  The trinket highest on the list that isn't on cooldown will automatically be equipped for you.Open the script tab and change \"Trinket Slot\" to 2 to use the second trinket slot.\n\nTrinketSlot=1;\nif isEquipped and not Outfitter.InCombat and not Outfitter.IsDead then\n    for _, itemName in ipairs(setting.Trinkets) do\n        local startTime, duration, enable = GetItemCooldown(itemName)\n    \n        if duration<=30 then\n              if TrinketSlot == 2 then\n              EquipItemByName(itemName, 14)\n              else\n              EquipItemByName(itemName)\n              end\n            break\n        end\n    end\nend",
	},
	{
		Name = "In Zones",
		ID = "IN_ZONES",
		Events = "ZONE_CHANGED_INDOORS ZONE_CHANGED ZONE_CHANGED_NEW_AREA",
		Script = "-- $DESC The outfit will be equipped whenever you are in one of the zones listed below\n-- $SETTING zoneList={Type=\"ZoneList\", Label=\"Zones\"}\n\nlocal    currentZone = GetZoneText();\n\nfor _, zoneName in ipairs(setting.zoneList) do\n     if zoneName == currentZone then\n        equip = true\n    end\nend\n\nif didEquip and equip == nil then\n    equip = false\nend",
	},
	{
		Name = "In Minimap Zones",
		ID = "IN_MINI_ZONES",
		Events = "ZONE_CHANGED_INDOORS ZONE_CHANGED ZONE_CHANGED_NEW_AREA",
		Script = "-- $DESC The outfit will be equipped whenever you are in one of the minimap zones listed below.  Minimap zones are useful for specific areas inside of dungeons.\n-- $SETTING zoneList={Type=\"ZoneList\", ZoneType=\"MinimapZone\", Label=\"Zones\"}\n\nlocal    currentZone = GetMinimapZoneText();\n\nfor _, zoneName in ipairs(setting.zoneList) do\n     if zoneName == currentZone then\n        equip = true\n    end\nend\n\nif didEquip and equip == nil then\n    equip = false\nend",
	},
	{
		Name = Outfitter_cRidingOutfit,
		ID = "RIDING",
		Events = "MOUNTED NOT_MOUNTED",
		Script = "if event == \"MOUNTED\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
	},
	{
		Name = "Swimming",
		ID = "SWIMMING",
		Events = "SWIMMING NOT_SWIMMING",
		Script = "if event == \"SWIMMING\" then\n    equip = true\nelseif didEquip then\n    equip = false\n    delay = 2\nend\n",
	},
	{
		Name = Outfitter_cDiningOutfit,
		ID = "DINING",
		Events = "DINING NOT_DINING",
		Script = "if event == \"DINING\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
	},
	{
		Name = Outfitter_cCityOutfit,
		ID = "CITY",
		Events = "CITY NOT_CITY",
		Script = "if event == \"CITY\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
	},
	{
		Name = "Five Second Rule",
		ID = "FIVESECONDRULE",
		Events = "STARTFIVESECONDRULE OUTOFFIVESECONDRULE",
		Script = "if event == \"STARTFIVESECONDRULE\" then\n    equip = true\nelseif event == \"OUTOFFIVESECONDRULE\" then\n    equip = false\nend\n",
	},

	{
		Name = Outfitter_cWarriorBattleStance,
		ID = "BATTLE",
		Events = "BATTLE_STANCE NOT_BATTLE_STANCE",
		Script = "if event == \"BATTLE_STANCE\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "WARRIOR",
	},
	{
		Name = Outfitter_cWarriorDefensiveStance,
		ID = "DEFENSIVE",
		Events = "DEFENSIVE_STANCE NOT_DEFENSIVE_STANCE",
		Script = "if event == \"DEFENSIVE_STANCE\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "WARRIOR",
	},
	{
		Name = Outfitter_cWarriorBerserkerStance,
		ID = "BERSERKER",
		Events = "BERSERKER_STANCE NOT_BERSERKER_STANCE",
		Script = "if event == \"BERSERKER_STANCE\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "WARRIOR",
	},
	{
		Name = Outfitter_cDruidBearForm,
		ID = "BEAR_FORM",
		Events = "BEAR_FORM NOT_BEAR_FORM",
		Script = "if event == \"BEAR_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\n    delay = 2\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidCatForm,
		ID = "CAT_FORM",
		Events = "CAT_FORM NOT_CAT_FORM",
		Script = "if event == \"CAT_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\n    delay = 2\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidAquaticForm,
		ID = "AQUATIC_FORM",
		Events = "AQUATIC_FORM NOT_AQUATIC_FORM",
		Script = "if event == \"AQUATIC_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidFlightForm,
		ID = "FLIGHT_FORM",
		Events = "FLIGHT_FORM NOT_FLIGHT_FORM",
		Script = "if event == \"FLIGHT_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidSwiftFlightForm,
		ID = "SWIFT_FLIGHT_FORM",
		Events = "SWIFT_FLIGHT_FORM NOT_SWIFT_FLIGHT_FORM",
		Script = "if event == \"SWIFT_FLIGHT_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidTravelForm,
		ID = "TRAVEL_FORM",
		Events = "TRAVEL_FORM NOT_TRAVEL_FORM",
		Script = "if event == \"TRAVEL_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidMoonkinForm,
		ID = "MOONKIN_FORM",
		Events = "MOONKIN_FORM NOT_MOONKIN_FORM",
		Script = "if event == \"MOONKIN_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\n    delay = 2\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidTreeOfLifeForm,
		ID = "TREE_FORM",
		Events = "TREE_FORM NOT_TREE_FORM",
		Script = "if event == \"TREE_FORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\n    delay = 2\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cDruidProwl,
		ID = "PROWL",
		Events = "STEALTH NOT_STEALTH",
		Script = "if event == \"STEALTH\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "DRUID",
	},
	{
		Name = Outfitter_cRogueStealth,
		ID = "STEALTH",
		Events = "STEALTH NOT_STEALTH",
		Script = "if event == \"STEALTH\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "ROGUE",
	},
	
	{
		Name = Outfitter_cPriestShadowform,
		ID = "SHADOWFORM",
		Events = "SHADOWFORM NOT_SHADOWFORM",
		Script = "if event == \"SHADOWFORM\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "PRIEST",
	},
	{
		Name = Outfitter_cShamanGhostWolf,
		ID = "GHOST_WOLF",
		Events = "GHOST_WOLF NOT_GHOST_WOLF",
		Script = "if event == \"GHOST_WOLF\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "SHAMAN",
	},
	{
		Name = Outfitter_cHunterMonkey,
		ID = "MONKEY_ASPECT",
		Events = "MONKEY_ASPECT NOT_MONKEY_ASPECT",
		Script = "if event == \"MONKEY_ASPECT\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	{
		Name = Outfitter_cHunterHawk,
		ID = "HAWK_ASPECT",
		Events = "HAWK_ASPECT NOT_HAWK_ASPECT",
		Script = "if event == \"HAWK_ASPECT\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	{
		Name = Outfitter_cHunterCheetah,
		ID = "CHEETAH_ASPECT",
		Events = "CHEETAH_ASPECT NOT_CHEETAH_ASPECT",
		Script = "if event == \"CHEETAH_ASPECT\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	{
		Name = Outfitter_cHunterPack,
		ID = "PACK_ASPECT",
		Events = "PACK_ASPECT NOT_PACK_ASPECT",
		Script = "if event == \"PACK_ASPECT\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	{
		Name = Outfitter_cHunterBeast,
		ID = "BEAST_ASPECT",
		Events = "BEAST_ASPECT NOT_BEAST_ASPECT",
		Script = "if event == \"BEAST_ASPECT\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	{
		Name = Outfitter_cHunterWild,
		ID = "WILD_ASPECT",
		Events = "WILD_ASPECT NOT_WILD_ASPECT",
		Script = "if event == \"WILD_ASPECT\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	{
		Name = Outfitter_cHunterViper,
		ID = "VIPER_ASPECT",
		Events = "VIPER_ASPECT NOT_VIPER_ASPECT",
		Script = "if event == \"VIPER_ASPECT\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	{
		Name = "Hunter: Feign Death",
		ID = "FEIGN_DEATH",
		Events = "FEIGN_DEATH NOT_FEIGN_DEATH",
		Script = "if event == \"FEIGN_DEATH\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "HUNTER",
	},
	
	{
		Name = Outfitter_cMageEvocate,
		ID = "EVOCATE",
		Events = "EVOCATE NOT_EVOCATE",
		Script = "if event == \"EVOCATE\" then\n    equip = true\nelseif didEquip then\n    equip = false\nend\n",
		Class = "MAGE",
	},
};

local Outfitter_cSlotNames =
{
	-- First priority goes to armor
	
	"HeadSlot",
	"ShoulderSlot",
	"ChestSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	
	-- Second priority goes to weapons
	
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot",
	"AmmoSlot",
	
	-- Last priority goes to items with no durability
	
	"BackSlot",
	"NeckSlot",
	"ShirtSlot",
	"TabardSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
};

local Outfitter_cSlotIDs;
local Outfitter_cSlotIDToInventorySlot;

local Outfitter_cSlotDisplayNames =
{
	HeadSlot = HEADSLOT,
	NeckSlot = NECKSLOT,
	ShoulderSlot = SHOULDERSLOT,
	BackSlot = BACKSLOT,
	ChestSlot = CHESTSLOT,
	ShirtSlot = SHIRTSLOT,
	TabardSlot = TABARDSLOT,
	WristSlot = WRISTSLOT,
	HandsSlot = HANDSSLOT,
	WaistSlot = WAISTSLOT,
	LegsSlot = LEGSSLOT,
	FeetSlot = FEETSLOT,
	Finger0Slot = Outfitter_cFinger0SlotName,
	Finger1Slot = Outfitter_cFinger1SlotName,
	Trinket0Slot = Outfitter_cTrinket0SlotName,
	Trinket1Slot = Outfitter_cTrinket1SlotName,
	MainHandSlot = MAINHANDSLOT,
	SecondaryHandSlot = SECONDARYHANDSLOT,
	RangedSlot = RANGEDSLOT,
	AmmoSlot = AMMOSLOT,
};

local Outfitter_cInvTypeToSlotName =
{
	INVTYPE_2HWEAPON = {SlotName = "MainHandSlot", MetaSlotName = "TwoHandSlot"},
	INVTYPE_BAG = {SlotName = "Bag"},
	INVTYPE_BODY = {SlotName = "ShirtSlot"},
	INVTYPE_CHEST = {SlotName = "ChestSlot"},
	INVTYPE_CLOAK = {SlotName = "BackSlot"},
	INVTYPE_FEET = {SlotName = "FeetSlot"},
	INVTYPE_FINGER = {SlotName = "Finger0Slot"},
	INVTYPE_HAND = {SlotName = "HandsSlot"},
	INVTYPE_HEAD = {SlotName = "HeadSlot"},
	INVTYPE_HOLDABLE = {SlotName = "SecondaryHandSlot"},
	INVTYPE_LEGS = {SlotName = "LegsSlot"},
	INVTYPE_NECK = {SlotName = "NeckSlot"},
	INVTYPE_RANGED = {SlotName = "RangedSlot"},
	INVTYPE_ROBE = {SlotName = "ChestSlot"},
	INVTYPE_SHIELD = {SlotName = "SecondaryHandSlot"},
	INVTYPE_SHOULDER = {SlotName = "ShoulderSlot"},
	INVTYPE_TABARD = {SlotName = "TabardSlot"},
	INVTYPE_TRINKET = {SlotName = "Trinket0Slot"},
	INVTYPE_WAIST = {SlotName = "WaistSlot"},
	INVTYPE_WEAPON = {SlotName = "MainHandSlot", MetaSlotName = "Weapon0Slot"},
	INVTYPE_WEAPONMAINHAND = {SlotName = "MainHandSlot"},
	INVTYPE_WEAPONOFFHAND = {SlotName = "SecondaryHandSlot"},
	INVTYPE_WRIST = {SlotName = "WristSlot"},
	INVTYPE_RANGEDRIGHT = {SlotName = "RangedSlot"},
	INVTYPE_AMMO = {SlotName = "AmmoSlot"},
	INVTYPE_THROWN = {SlotName = "RangedSlot"},
	INVTYPE_RELIC = {SlotName = "RangedSlot"},
};

local Outfitter_cHalfAlternateStatSlot =
{
	Trinket0Slot = "Trinket1Slot",
	Finger0Slot = "Finger1Slot",
	Weapon0Slot = "Weapon1Slot",
};

local Outfitter_cFullAlternateStatSlot =
{
	Trinket0Slot = "Trinket1Slot",
	Trinket1Slot = "Trinket0Slot",
	Finger0Slot = "Finger1Slot",
	Finger1Slot = "Finger0Slot",
	Weapon0Slot = "Weapon1Slot",
	Weapon1Slot = "Weapon0Slot",
};

local gOutfitter_cCategoryOrder =
{
	"Complete",
	"Partial",
	"Accessory",
	"Special"
};

local Outfitter_cItemAliases =
{
	[18608] = 18609,	-- Benediction -> Anathema
	[18609] = 18608,	-- Anathema -> Benediction
	[17223] = 17074,	-- Thunderstrike -> Shadowstrike
	[17074] = 17223,	-- Shadowstrike -> Thunderstrike
};

local Outfitter_cFishingPoles =
{
	{Code = 25978, SubCode = 0}, -- Seth's Graphite Fishing Pole
	{Code = 19970, SubCode = 0}, -- Arcanite Fishing Pole
	{Code = 19022, SubCode = 0}, -- Nat Pagles Fishing Pole
	{Code = 12224, SubCode = 0}, -- Blump Family Fishing Pole
	{Code = 6367, SubCode = 0}, -- Big Iron Fishing Pole
	{Code = 6365, SubCode = 0}, -- Strong Fishing Pole
	{Code = 6256, SubCode = 0}, -- Fishing Pole
};

local Outfitter_cRidingItems =
{
	{Code = 11122, SubCode = 0}, -- Carrot on a Stick
	{Code = 25653, SubCode = 0}, -- Riding Crop
};

local Outfitter_cArgentDawnTrinkets = 
{
	{Code = 13209, SubCode = 0}, -- Seal of the Dawn
	{Code = 19812, SubCode = 0}, -- Rune of the Dawn
	{Code = 12846, SubCode = 0}, -- Argent Dawn Commission
};

local Outfitter_cStatIDItems =
{
	Fishing = Outfitter_cFishingPoles,
	Riding = Outfitter_cRidingItems,
	ArgentDawn = Outfitter_cArgentDawnTrinkets,
};

local Outfitter_cIgnoredUnusedItems = 
{
	[2901] = "Mining Pick",
	[5956] = "Blacksmith hammer",
	[6219] = "Arclight Spanner",
	[7005] = "Skinning Knife",
	[7297] = "Morbent's Bane",
	[10696] = "Enchanted Azsharite Felbane Sword",
	[10697] = "Enchanted Azsharite Felbane Dagger",
	[10698] = "Enchanted Azsharite Felbane Staff",
	[20406] = "Twilight Cultist Mantle",
	[20407] = "Twilight Cultist Robe",
	[20408] = "Twilight Cultist Cowl",
};

local Outfitter_cSmartOutfits =
{
	{Name = Outfitter_cFishingOutfit, StatID = "Fishing", IsAccessory = true},
	{Name = Outfitter_cHerbalismOutfit, StatID = "Herbalism", IsAccessory = true},
	{Name = Outfitter_cMiningOutfit, StatID = "Mining", IsAccessory = true},
	{Name = Outfitter_cSkinningOutfit, StatID = "Skinning", IsAccessory = true},
	{Name = Outfitter_cFireResistOutfit, StatID = "FireResist"},
	{Name = Outfitter_cNatureResistOutfit, StatID = "NatureResist"},
	{Name = Outfitter_cShadowResistOutfit, StatID = "ShadowResist"},
	{Name = Outfitter_cArcaneResistOutfit, StatID = "ArcaneResist"},
	{Name = Outfitter_cFrostResistOutfit, StatID = "FrostResist"},
};

local Outfitter_cStatCategoryInfo =
{
	{Category = "Stat", Name = Outfitter_cStatsCategory},
	{Category = "Melee", Name = Outfitter_cMeleeCategory},
	{Category = "Spell", Name = Outfitter_cSpellsCategory},
	{Category = "Regen", Name = Outfitter_cRegenCategory},
	{Category = "Resist", Name = Outfitter_cResistCategory},
	{Category = "Trade", Name = Outfitter_cTradeCategory},
};

local Outfitter_cItemStatInfo =
{
	{ID = "Agility", Name = Outfitter_cAgilityStatName, Category = "Stat"},
	{ID = "Armor", Name = Outfitter_cArmorStatName, Category = "Stat"},
	{ID = "Defense", Name = Outfitter_cDefenseStatName, Category = "Stat"},
	{ID = "Intellect", Name = Outfitter_cIntellectStatName, Category = "Stat"},
	{ID = "Spirit", Name = Outfitter_cSpiritStatName, Category = "Stat"},
	{ID = "Stamina", Name = Outfitter_cStaminaStatName, Category = "Stat"},
	{ID = "Strength", Name = Outfitter_cStrengthStatName, Category = "Stat"},
	{ID = "TotalStats", Name = Outfitter_cTotalStatsName, Category = "Stat"},
	
	{ID = "ManaRegen", Name = Outfitter_cManaRegenStatName, Category = "Regen"},
	{ID = "HealthRegen", Name = Outfitter_cHealthRegenStatName, Category = "Regen"},
	
	{ID = "SpellCrit", Name = Outfitter_cSpellCritStatName, Category = "Spell"},
	{ID = "SpellHit", Name = Outfitter_cSpellHitStatName, Category = "Spell"},
	{ID = "SpellDmg", Name = Outfitter_cSpellDmgStatName, Category = "Spell"},
	{ID = "FrostDmg", Name = Outfitter_cFrostDmgStatName, Category = "Spell"},
	{ID = "FireDmg", Name = Outfitter_cFireDmgStatName, Category = "Spell"},
	{ID = "ArcaneDmg", Name = Outfitter_cArcaneDmgStatName, Category = "Spell"},
	{ID = "ShadowDmg", Name = Outfitter_cShadowDmgStatName, Category = "Spell"},
	{ID = "NatureDmg", Name = Outfitter_cNatureDmgStatName, Category = "Spell"},
	{ID = "Healing", Name = Outfitter_cHealingStatName, Category = "Spell"},
	
	{ID = "MeleeCrit", Name = Outfitter_cMeleeCritStatName, Category = "Melee"},
	{ID = "MeleeHit", Name = Outfitter_cMeleeHitStatName, Category = "Melee"},
	{ID = "MeleeDmg", Name = Outfitter_cMeleeDmgStatName, Category = "Melee"},
	{ID = "Dodge", Name = Outfitter_cDodgeStatName, Category = "Melee"},
	{ID = "Attack", Name = Outfitter_cAttackStatName, Category = "Melee"},
	{ID = "RangedAttack", Name = Outfitter_cRangedAttackStatName, Category = "Melee"},
	
	{ID = "ArcaneResist", Name = Outfitter_cArcaneResistStatName, Category = "Resist"},
	{ID = "FireResist", Name = Outfitter_cFireResistStatName, Category = "Resist"},
	{ID = "FrostResist", Name = Outfitter_cFrostResistStatName, Category = "Resist"},
	{ID = "NatureResist", Name = Outfitter_cNatureResistStatName, Category = "Resist"},
	{ID = "ShadowResist", Name = Outfitter_cShadowResistStatName, Category = "Resist"},
	
	{ID = "Fishing", Name = Outfitter_cFishingStatName, Category = "Trade"},
	{ID = "Herbalism", Name = Outfitter_cHerbalismStatName, Category = "Trade"},
	{ID = "Mining", Name = Outfitter_cMiningStatName, Category = "Trade"},
	{ID = "Skinning", Name = Outfitter_cSkinningStatName, Category = "Trade"},
};

local Outfitter_cNormalizedClassName =
{
	[Outfitter_cDruidClassName] = "Druid",
	[Outfitter_cHunterClassName] = "Hunter",
	[Outfitter_cMageClassName] = "Mage",
	[Outfitter_cPaladinClassName] = "Paladin",
	[Outfitter_cPriestClassName] = "Priest",
	[Outfitter_cRogueClassName] = "Rogue",
	[Outfitter_cShamanClassName] = "Shaman",
	[Outfitter_cWarlockClassName] = "Warlock",
	[Outfitter_cWarriorClassName] = "Warrior",
};

local Outfitter_cSpecialIDEvents =
{
	Battle = {Equip = "BATTLE_STANCE", Unequip = "NO_BATTLE_STANCE"},
	Defensive = {Equip = "DEFENSIVE_STANCE", Unequip = "NO_DEFENSIVE_STANCE"},
	Berserker = {Equip = "BERSERKER_STANCE", Unequip = "NO_BERSERKER_STANCE"},
	
	Bear = {Equip = "BEAR_FORM", Unequip = "NO_BEAR_FORM"},
	Cat = {Equip = "CAT_FORM", Unequip = "NO_CAT_FORM"},
	Aquatic = {Equip = "AQUATIC_FORM", Unequip = "NO_AQUATIC_FORM"},
	Travel = {Equip = "TRAVEL_FORM", Unequip = "NO_TRAVEL_FORM"},
	Moonkin = {Equip = "MOONKIN_FORM", Unequip = "NO_MOONKIN_FORM"},
	Tree = {Equip = "TREE_FORM", Unequip = "NO_TREE_FORM"},
	Prowl = {Equip = "STEALTH", Unequip = "NO_STEALTH"},
	Flight = {Equip = "FLIGHT_FORM", Unequip = "NO_FLIGHT_FORM"},
	SwiftFlight = {Equip = "SWIFT_FLIGHT_FORM", Unequip = "NO_SWIFT_FLIGHT_FORM"},

	Shadowform = {Equip = "SHADOWFORM", Unequip = "NO_SHADOWFORM"},

	Stealth = {Equip = "STEALTH", Unequip = "NO_STEALTH"},

	GhostWolf = {Equip = "GHOST_WOLF", Unequip = "NO_GHOST_WOLF"},

	Monkey = {Equip = "MONKEY_ASPECT", Unequip = "NO_MONKEY_ASPECT"},
	Hawk = {Equip = "HAWK_ASPECT", Unequip = "NO_HAWK_ASPECT"},
	Cheetah = {Equip = "CHEETAH_ASPECT", Unequip = "NO_CHEETAH_ASPECT"},
	Pack = {Equip = "PACK_ASPECT", Unequip = "NO_PACK_ASPECT"},
	Beast = {Equip = "BEAST_ASPECT", Unequip = "NO_BEAST_ASPECT"},
	Wild = {Equip = "WILD_ASPECT", Unequip = "NO_WILD_ASPECT"},
	Viper = {Equip = "VIPER_ASPECT", Unequip = "NO_VIPER_ASPECT"},
	Feigning = {Equip = "FEIGN_DEATH", Unequip = "NO_FEIGN_DEATH"},
	
	Evocate = {Equip = "EVOCATE", Unequip = "NO_EVOCATE"},
	
	Dining = {Equip = "DINING", Unequip = "NO_DINING"},
	City = {Equip = "CITY", Unequip = "NO_CITY"},
};

local Outfitter_cClassSpecialOutfits =
{
	Warrior =
	{
		{Name = Outfitter_cWarriorBattleStance, SpecialID = "Battle"},
		{Name = Outfitter_cWarriorDefensiveStance, SpecialID = "Defensive"},
		{Name = Outfitter_cWarriorBerserkerStance, SpecialID = "Berserker"},
	},
	
	Druid =
	{
		{Name = Outfitter_cDruidBearForm, SpecialID = "Bear"},
		{Name = Outfitter_cDruidCatForm, SpecialID = "Cat"},
		{Name = Outfitter_cDruidAquaticForm, SpecialID = "Aquatic"},
		{Name = Outfitter_cDruidTravelForm, SpecialID = "Travel"},
		{Name = Outfitter_cDruidMoonkinForm, SpecialID = "Moonkin"},
		{Name = Outfitter_cDruidTreeOfLifeForm, SpecialID = "Tree"},
		{Name = Outfitter_cDruidProwl, SpecialID = "Prowl"},
		{Name = Outfitter_cDruidFlightForm, SpecialID = "Flight"},
		{Name = Outfitter_cDruidSwiftFlightForm, SpecialID = "SwiftFlight"},
	},
	
	Priest =
	{
		{Name = Outfitter_cPriestShadowform, SpecialID = "Shadowform"},
	},
	
	Rogue =
	{
		{Name = Outfitter_cRogueStealth, SpecialID = "Stealth"},
	},
	
	Shaman =
	{
		{Name = Outfitter_cShamanGhostWolf, SpecialID = "GhostWolf"},
	},
	
	Hunter =
	{
		{Name = Outfitter_cHunterMonkey, SpecialID = "Monkey"},
		{Name = Outfitter_cHunterHawk, SpecialID = "Hawk"},
		{Name = Outfitter_cHunterCheetah, SpecialID = "Cheetah"},
		{Name = Outfitter_cHunterPack, SpecialID = "Pack"},
		{Name = Outfitter_cHunterBeast, SpecialID = "Beast"},
		{Name = Outfitter_cHunterWild, SpecialID = "Wild"},
		{Name = Outfitter_cHunterViper, SpecialID = "Viper"},
	},
	
	Mage =
	{
		{Name = Outfitter_cMageEvocate, SpecialID = "Evocate"},
	},
};

local	gOutfitter_SpellNameSpecialID =
{
	[Outfitter_cAspectOfTheCheetah] = "Cheetah",
	[Outfitter_cAspectOfThePack] = "Pack",
	[Outfitter_cAspectOfTheBeast] = "Beast",
	[Outfitter_cAspectOfTheWild] = "Wild",
	[Outfitter_cAspectOfTheViper] = "Viper",
	[Outfitter_cEvocate] = "Evocate",
};

local	gOutfitter_AuraIconSpecialID =
{
	["INV_Misc_Fork&Knife"] = "Dining",
	["Spell_Shadow_Shadowform"] = "Shadowform",
	["Spell_Nature_SpiritWolf"] = "GhostWolf",
	["Ability_Rogue_FeignDeath"] = "Feigning",
	["Ability_Hunter_AspectOfTheMonkey"] = "Monkey",
	["Spell_Nature_RavenForm"] = "Hawk",
	[Outfitter_cProwl] = "Prowl",
};

local Outfitter_cSpecialOutfitDescriptions =
{
	ArgentDawn = Outfitter_cArgentDawnOutfitDescription,
	Riding = Outfitter_cRidingOutfitDescription,
	Dining = Outfitter_cDiningOutfitDescription,
	Battleground = Outfitter_cBattlegroundOutfitDescription,
	AB = Outfitter_cArathiBasinOutfitDescription,
	AV = Outfitter_cAlteracValleyOutfitDescription,
	WSG = Outfitter_cWarsongGulchOutfitDescription,
	EotS = Outfitter_cEotSOutfitDescription,
	City = Outfitter_cCityOutfitDescription,
	Swimming = Outfitter_cSwimmingOutfitDescription,
};

-- Note that zone special outfits will be worn in the order
-- the are listed here, with later outfits being worn over
-- earlier outfits (when they're being applied at the same time)
-- This allows BG-specific outfits to take priority over the generic
-- BG outfit

local Outfitter_cZoneSpecialIDs =
{
	"ArgentDawn",
	"City",
	"Battleground",
	"AV",
	"AB",
	"WSG",
	"Arena",
	"EotS",
};

local Outfitter_cZoneSpecialIDMap =
{
	[Outfitter_cWesternPlaguelands] = {"ArgentDawn"},
	[Outfitter_cEasternPlaguelands] = {"ArgentDawn"},
	[Outfitter_cStratholme] = {"ArgentDawn"},
	[Outfitter_cScholomance] = {"ArgentDawn"},
	[Outfitter_cNaxxramas] = {"ArgentDawn", "Naxx"},
	[Outfitter_cAlteracValley] = {"Battleground", "AV"},
	[Outfitter_cArathiBasin] = {"Battleground", "AB"},
	[Outfitter_cWarsongGulch] = {"Battleground", "WSG"},
	[Outfitter_cEotS] = {"Battleground", "EotS"},
	[Outfitter_cIronforge] = {"City"},
	[Outfitter_cCityOfIronforge] = {"City"},
	[Outfitter_cDarnassus] = {"City"},
	[Outfitter_cStormwind] = {"City"},
	[Outfitter_cOrgrimmar] = {"City"},
	[Outfitter_cThunderBluff] = {"City"},
	[Outfitter_cUndercity] = {"City"},
	[Outfitter_cSilvermoon] = {"City"},
	[Outfitter_cExodar] = {"City"},
	[Outfitter_cShattrath] = {"City"},
};

local gOutfitter_StatDistribution =
{
	DRUID =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 20}, Attack = {Coeff = 1}, MeleeCrit = {Coeff = 1 / 20}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, SpellCrit = {Coeff = 1 / 30}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, Attack = {Coeff = 2}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	HUNTER =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 26.5}, RangedAttack = {Coeff = 1}, Attack = {Coeff = 1}, MeleeCrit = {Coeff = 1 / 53}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, Attack = {Coeff = 1}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	MAGE =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 20}, MeleeCrit = {Coeff = 1 / 20}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, SpellCrit = {Coeff = 1.0 / 59.5}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	PALADIN =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 20}, MeleeCrit = {Coeff = 1 / 20}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, SpellCrit = {Coeff = 1.0 / 20}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, Attack = {Coeff = 2}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	PRIEST =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 20}, MeleeCrit = {Coeff = 1 / 20}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, SpellCrit = {Coeff = 1.0 / 30}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	ROGUE =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 14.5}, Attack = {Coeff = 1}, RangedAttack = {Coeff = 2}, MeleeCrit = {Coeff = 1 / 29}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, Attack = {Coeff = 1}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	SHAMAN =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 20}, MeleeCrit = {Coeff = 1 / 20}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, SpellCrit = {Coeff = 1.0 / 20}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, Attack = {Coeff = 2}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	WARLOCK =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 20}, MeleeCrit = {Coeff = 1 / 20}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, SpellCrit = {Coeff = 1.0 / 30}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
	
	WARRIOR =
	{
		Agility = {Armor = {Coeff = 2}, Dodge = {Coeff = 1 / 20}, MeleeCrit = {Coeff = 1 / 20}, TotalStats = {Coeff = 1}},
		Stamina = {Health = {Coeff = 10}, TotalStats = {Coeff = 1}},
		Intellect = {Mana = {Coeff = 15}, TotalStats = {Coeff = 1}},
		Spirit = {ManaRegen = {Coeff = 0.25 * 2.5}, TotalStats = {Coeff = 1}}, -- * 2.5 to convert from ticks to per-five-seconds
		Strength = {BlockAmount = {Coeff = 1 / 22}, Attack = {Coeff = 2}, TotalStats = {Coeff = 1}},
		Defense = {Dodge = {Coeff = 0.05}, Parry = {Coeff = 0.05}, Block = {Coeff = 0.05}},
	},
};

local Outfitter_cCombatEquipmentSlots =
{
	MainHandSlot = true,
	SecondaryHandSlot = true,
	RangedSlot = true,
	AmmoSlot = true,
};

gOutfitter_EquippableItems = nil;

local Outfitter_cMaxDisplayedItems = 14;

local gOutfitter_PanelFrames =
{
	"OutfitterMainFrame",
	"OutfitterOptionsFrame",
	"OutfitterAboutFrame",
};

local	Outfitter_cShapeshiftSpecialIDs =
{
	-- Warriors
	
	[Outfitter_cBattleStance] = {ID = "Battle", Type = "WARSTANCE"},
	[Outfitter_cDefensiveStance] = {ID = "Defensive", Type = "WARSTANCE"},
	[Outfitter_cBerserkerStance] = {ID = "Berserker", Type = "WARSTANCE"},
	
	-- Druids
	
	[Outfitter_cBearForm] = {ID = "Bear", Type = "DRUIDFORM", MaybeInCombat = true},
	[Outfitter_cCatForm] = {ID = "Cat", Type = "DRUIDFORM"},
	[Outfitter_cAquaticForm] = {ID = "Aquatic", Type = "DRUIDFORM"},
	[Outfitter_cTravelForm] = {ID = "Travel", Type = "DRUIDFORM"},
	[Outfitter_cDireBearForm] = {ID = "Bear", Type = "DRUIDFORM"},
	[Outfitter_cMoonkinForm] = {ID = "Moonkin", Type = "DRUIDFORM"},
	[Outfitter_cTreeOfLifeForm] = {ID = "Tree", Type = "DRUIDFORM"},
	[Outfitter_cFlightForm] = {ID = "Flight", Type = "DRUIDFORM"},
	[Outfitter_cSwiftFlightForm] = {ID = "SwiftFlight", Type = "DRUIDFORM"},
	
	-- Rogues
	
	[Outfitter_cStealth] = {ID = "Stealth"},
};

local	Outfitter_cShapeshiftTypes =
{
	Battle = "WARSTANCE",
	Defensive = "WARSTANCE",
	Berserker = "WARSTANCE",

	Bear = "DRUIDFORM",
	Cat = "DRUIDFORM",
	Aquatic = "DRUIDFORM",
	Travel = "DRUIDFORM",
	Bear = "DRUIDFORM",
	Moonkin = "DRUIDFORM",
	Tree = "DRUIDFORM",
	Flight = "DRUIDFORM",
  SwiftFlight = "DRUIDFORM",
};

StaticPopupDialogs["OUTFITTER_CONFIRM_DELETE"] =
{
	text = TEXT(Outfitter_cConfirmDeleteMsg),
	button1 = TEXT(DELETE),
	button2 = TEXT(CANCEL),
	OnAccept = function() Outfitter_DeleteSelectedOutfit(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["OUTFITTER_CONFIRM_REBUILD"] =
{
	text = TEXT(Outfitter_cConfirmRebuildMsg),
	button1 = TEXT(Outfitter_cRebuild),
	button2 = TEXT(CANCEL),
	OnAccept = function() Outfitter_RebuildSelectedOutfit(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["OUTFITTER_CONFIRM_SET_CURRENT"] =
{
	text = TEXT(Outfitter_cConfirmSetCurrentMsg),
	button1 = TEXT(Outfitter_cSetCurrent),
	button2 = TEXT(CANCEL),
	OnAccept = function() Outfitter_SetOutfitToCurrent(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

function Outfitter_ToggleOutfitterFrame()
	debugmessage("Toggle Outfitter Frame", 1);
	if Outfitter_IsOpen() then
		OutfitterFrame:Hide();
	else
		OutfitterFrame:Show();
		if gOutfitter_Settings.Options.Debug then
			OutfitterDebug:Show();
		else
			OutfitterDebug:Hide();
		end 
	end
end

function Outfitter_IsOpen()
	if Outfitter.Initialized then
		debugmessage("Is Open?", 1);
	end

	return OutfitterFrame:IsVisible();
end

function Outfitter_OnLoad()
	Outfitter_RegisterEvent(this, "PLAYER_ENTERING_WORLD", Outfitter_PlayerEnteringWorld);
	Outfitter_RegisterEvent(this, "PLAYER_LEAVING_WORLD", Outfitter_PlayerLeavingWorld);
	Outfitter_RegisterEvent(this, "VARIABLES_LOADED", Outfitter_VariablesLoaded);

	-- For monitoring mounted, dining and shadowform states
	
	Outfitter_RegisterEvent(this, "PLAYER_AURAS_CHANGED", Outfitter_UpdateAuraStates);
	
	-- For monitoring plaguelands and battlegrounds
	
	Outfitter_RegisterEvent(this, "ZONE_CHANGED_NEW_AREA", Outfitter_UpdateZone);
	
	-- For monitoring player combat state
	
	Outfitter_RegisterEvent(this, "PLAYER_REGEN_ENABLED", Outfitter_RegenEnabled);
	Outfitter_RegisterEvent(this, "PLAYER_REGEN_DISABLED", Outfitter_RegenDisabled);
	
	-- For monitoring player dead/alive stat
	
	Outfitter_RegisterEvent(this, "PLAYER_DEAD", Outfitter_PlayerDead);
	Outfitter_RegisterEvent(this, "PLAYER_ALIVE", Outfitter_PlayerAlive);
	Outfitter_RegisterEvent(this, "PLAYER_UNGHOST", Outfitter_PlayerAlive);
	
	Outfitter_RegisterEvent(this, "UNIT_INVENTORY_CHANGED", Outfitter_UnitInventoryChanged);

	Outfitter_RegisterEvent(this, "UNIT_SPELLCAST_SENT", Outfitter_SpellSent);
	Outfitter_RegisterEvent(this, "UNIT_SPELLCAST_STOP", Outfitter_SpellStop);
	
	-- For indicating which outfits are missing items
	
	Outfitter_RegisterEvent(this, "BAG_UPDATE", Outfitter_BagUpdate);
	Outfitter_RegisterEvent(this, "PLAYERBANKSLOTS_CHANGED", Outfitter_BankSlotsChanged);
	
	-- For monitoring bank bags
	
	Outfitter_RegisterEvent(this, "BANKFRAME_OPENED", Outfitter_BankFrameOpened);
	Outfitter_RegisterEvent(this, "BANKFRAME_CLOSED", Outfitter_BankFrameClosed);
	
	-- For unequipping the dining outfit
	
	Outfitter_RegisterEvent(this, "UNIT_HEALTH", Outfitter_UnitHealthOrManaChanged);
	Outfitter_RegisterEvent(this, "UNIT_MANA", Outfitter_UnitHealthOrManaChanged);

	Outfitter_SuspendEvent(this, "UNIT_HEALTH"); -- Don't actually care until the dining outfit equips
	OUTFIT_InDining = false;
	--Outfitter_SuspendEvent(this, "UNIT_MANA");
	
	-- Tabs
	
	PanelTemplates_SetNumTabs(this, #gOutfitter_PanelFrames);
	OutfitterFrame.selectedTab = Outfitter.CurrentPanel;
	PanelTemplates_UpdateTabs(this);
	
	-- Install the /outfit command handler

	SlashCmdList["OUTFITTER"] = Outfitter_ExecuteCommand;
	
	SLASH_OUTFITTER1 = "/outfitter";
	
	-- Fake a leaving world event to suspend inventory/bag
	-- updating until loading is completed
	
	Outfitter_PlayerLeavingWorld();
	
	-- Patch GameTooltip so we can monitor hide/show events
	gOutfitter_OrigGameTooltipOnShow = GameTooltip:GetScript("OnShow");
	GameTooltip:SetScript("OnShow", Outfitter_GameToolTip_OnShow);
	
	gOutfitter_OrigGameTooltipOnHide = GameTooltip:GetScript("OnHide");
	GameTooltip:SetScript("OnHide", Outfitter_GameToolTip_OnHide);
end

function Outfitter_OnShow()
	if Outfitter.Initialized then
		debugmessage("On Show", 1);
	end
	
	Outfitter_ShowPanel(1); -- Always switch to the main view when showing the window

	if Outfitter.Initialized then
			debugmessage("Exit On Show", 2);
	end
end

function Outfitter_OnHide()
	if Outfitter.Initialized then
		debugmessage("On Hide", 1);
	end
	
	Outfitter_ClearSelection();
	OutfitterQuickSlots_Close();
	OutfitterFrame:Hide(); -- This seems redundant, but the OnHide handler gets called
	                       -- in response to the parent being hidden (the character window)
	                       -- so calling Hide() on the frame here ensures that when the
	                       -- character window is hidden then Outfitter won't be displayed
	                       -- next time it's opened
end

function Outfitter_OnEvent(pEvent)
	debugmessage("On Event -- "..pEvent, 1);
	-- Ignore all events except for entering world until initialization is
	-- completed
	
	local	vStartTime = GetTime();
	
	if not Outfitter.Initialized
	and pEvent ~= "VARIABLES_LOADED" then
		if not Outfitter_cInitializationEvents[pEvent] then
			return;
		end
		
		if not gOutfitter_Settings then
			MCSchedulerLib:UnscheduleTask(Outfitter_Initialize); -- Reset the initialization if another startup-related event comes in
			MCSchedulerLib:ScheduleUniqueTask(1, Outfitter_Initialize); -- First time schedule initialization after a delay
			return;
		end
		
		Outfitter_Initialize();
	end
	
	--
	
	Outfitter_DispatchEvent(this, pEvent);
	
	if Outfitter.Initialized then
		Outfitter_Update(false);
	end

	-- MCDebugLib:TestMessage("Outfitter: "..pEvent.." ("..(GetTime() - vStartTime).."s)");
end

function Outfitter_PlayerLeavingWorld()
	-- To improve load screen performance, suspend events which are
	-- fired repeatedly and rapidly during zoning
	if Outfitter.Initialized then
		debugmessage("Player Leaving World", 1);
	end

	Outfitter.Suspended = true;
	
	Outfitter_SuspendEvent(OutfitterFrame, "BAG_UPDATE");
	Outfitter_SuspendEvent(OutfitterFrame, "UNIT_INVENTORY_CHANGED");
	Outfitter_SuspendEvent(OutfitterFrame, "UPDATE_INVENTORY_ALERTS");
	Outfitter_SuspendEvent(OutfitterFrame, "SPELLS_CHANGED");
	Outfitter_SuspendEvent(OutfitterFrame, "PLAYER_AURAS_CHANGED");
	Outfitter_SuspendEvent(OutfitterFrame, "PLAYERBANKSLOTS_CHANGED");
end

function Outfitter_PlayerEnteringWorld()
	if Outfitter.Initialized then
		debugmessage("Player Entering World", 1);
	end
		
	OutfitterItemList_FlushEquippableItems();
	
	Outfitter_RegenEnabled();
	Outfitter_UpdateAuraStates();
	
	Outfitter_SetSpecialOutfitEnabled("Riding", false);
	
	Outfitter_UpdateZone();
	
	gOutfitter_currMana = UnitManaMax("player");

	Outfitter_ResumeLoadScreenEvents();
end

function Outfitter_ResumeLoadScreenEvents()
	debugmessage("Resume Load Screen Events", 1);
	if Outfitter.Suspended then
		-- To improve load screen performance, suspend events which are
		-- fired repeatedly and rapidly during zoning
		
		Outfitter.Suspended = false;

		Outfitter_ResumeEvent(OutfitterFrame, "BAG_UPDATE");
		Outfitter_ResumeEvent(OutfitterFrame, "UNIT_INVENTORY_CHANGED");
		Outfitter_ResumeEvent(OutfitterFrame, "UPDATE_INVENTORY_ALERTS");
		Outfitter_ResumeEvent(OutfitterFrame, "SPELLS_CHANGED");
		Outfitter_ResumeEvent(OutfitterFrame, "PLAYER_AURAS_CHANGED");
		Outfitter_ResumeEvent(OutfitterFrame, "PLAYERBANKSLOTS_CHANGED");
		
		Outfitter_ScheduleSynch();
	end
end

function Outfitter_VariablesLoaded()
	if Outfitter.Initialized then
		debugmessage("Variables Loaded", 1);
	end

	gOutfitter_OriginalStaticPopup_EscapePressed = StaticPopup_EscapePressed;
	StaticPopup_EscapePressed = Outfitter_StaticPopup_EscapePressed;
end

function Outfitter_BankSlotsChanged()
	if Outfitter.Initialized then
		debugmessage("Bank Slots Changed", 2);
	end

	Outfitter_ScheduleSynch();
end

function Outfitter_BagUpdate()
	local	vBagIndex = arg1;

	if Outfitter.Initialized then
		debugmessage("Bag Update", 2);
	end
	
	Outfitter_ScheduleSynch();

	-- This is a messy hack to ensure the database gets updated properly
	-- after an upgrade.  WoW doesn't always have the players items
	-- loaded on PLAYER_ENTERING_WORLD so once the bag update fires
	-- we check the databases again if necessary
	
	if gOutfitter_NeedItemCodesUpdated then
		gOutfitter_NeedItemCodesUpdated = gOutfitter_NeedItemCodesUpdated - 1;
		
		if gOutfitter_NeedItemCodesUpdated == 0 then
			gOutfitter_NeedItemCodesUpdated = nil;
		end
		
		if Outfitter_UpdateDatabaseItemCodes() then
			gOutfitter_NeedItemCodesUpdated = nil;
		end
	end
end

local	gOutfitter_OutfitEvents = {};

function Outfitter_RegisterOutfitEvent(pEvent, pFunction)
	debugmessage("Register Outfit Event -- "..pEvent, 1);
	local	vHandlers = gOutfitter_OutfitEvents[pEvent];
	
	if not vHandlers then
		vHandlers = {};
		gOutfitter_OutfitEvents[pEvent] = vHandlers;
	end
	
	table.insert(vHandlers, pFunction);
end

function Outfitter_UnregisterOutfitEvent(pEvent, pFunction)
	debugmessage("Unregister Outfit Event -- "..pEvent, 1);
	local	vHandlers = gOutfitter_OutfitEvents[pEvent];
	
	if not vHandlers then
		return;
	end
	
	for vIndex, vFunction in ipairs(vHandlers) do
		if vFunction == pFunction then
			table.remove(vHandlers, vIndex);
			return;
		end
	end
end

function Outfitter_DispatchOutfitEvent(pEvent, pParameter1, pParameter2)
	debugmessage("Outfitter_DispatchOutfitEvent -- "..pEvent,1);
	
	-- Don't send out events until we're initialized
	if not Outfitter.Initialized then
		return;
	end

	
	-- Post a message
	debugmessage("Dispatch Outfit Event", 2);
	
	OutfitterMinimapDropDown_OutfitEvent(pEvent, pParameter1, pParameter2);
	
	local	vHandlers = gOutfitter_OutfitEvents[pEvent];
	
	if vHandlers then
	
	-- Post a message
	debugmessage("Run through handlers", 2);
	
		for _, vFunction in ipairs(vHandlers) do
			-- Call in protected mode so that if they fail it doesn't
			-- screw up Outfitter or other addons wishing to be notified
			
			pcall(vFunction, pEvent, pParameter1, pParameter2);
		end

		-- Post a message
		-- debugmessage("no handlers Exit", 2);
		-- return;
	end
	
	local	vEventID;
	
	if pEvent == "WEAR_OUTFIT" then
		vEventID = "OUTFIT_EQUIP";
	elseif pEvent == "UNWEAR_OUTFIT" then
		vEventID = "OUTFIT_UNEQUIP";
	end
	 
	local	vOutfits = Outfitter.OutfitScriptEvents[vEventID];
	
	if vOutfits and vOutfits[pParameter2] then
		--debugmessage("Dispatch Call: "..Outfitter.InCombat,2);
		vOutfits[pParameter2](pParameter2, vEventID);
	end

	-- Post a message
	debugmessage("Called all Scripts", 2);

	debugmessage("Calling Wear:Unwear events", 3);

	if pParameter1 then
		if pEvent == "WEAR_OUTFIT" then
				-- Call Wear Outfit.
				debugmessage("Dispatch WearOutfit "..pParameter1, 2);
				gOutfit_OutfitName = pParameter1;
				MCEventLib:DispatchEvent("WEAROUTFIT");
		elseif pEvent == "UNWEAR_OUTFIT" then
			-- Call Unwear Outfit.
				debugmessage("Dispatch UnwearOutfit "..pParameter1, 2);
				gOutfit_OutfitName = pParameter1;
				MCEventLib:DispatchEvent("UNWEAROUTFIT");
		end
	else
				debugmessage("Dispatch WearOutfit but there is no Outfit name", 2);		
	end

	-- Now set the correct Helm and Cloak settings.
	debugmessage("Outfitter: Calling Check Helm and Cloak",3);
	Outfitter_CheckHelmAndCloak();		
	
end

function Outfitter_BankFrameOpened()
	debugmessage("Bank Frame Opened", 1);

	Outfitter.BankFrameOpened = true;
	Outfitter_BankSlotsChanged();
end

function Outfitter_BankFrameClosed()
	debugmessage("Bank Frame Closed", 1);

	Outfitter.BankFrameOpened = false;
	Outfitter_BankSlotsChanged();
end

function Outfitter_RegenEnabled(pEvent)
	debugmessage("Comming out of Combat", 2);

	Outfitter.InCombat = false;
end

function Outfitter_RegenDisabled(pEvent)
	debugmessage("Going into Combat", 2);

	Outfitter.InCombat = true;
end

function Outfitter_PlayerDead(pEvent)
	debugmessage("Is Dead", 2);
	Outfitter.IsDead = true;
end

function Outfitter_PlayerAlive(pEvent)
	if not UnitIsDeadOrGhost("player") then
		debugmessage("Is Alive", 1);
		Outfitter.IsDead = false;
	end
end

function Outfitter_UnitHealthOrManaChanged()
	debugmessage("Health or Mana Changed", 1);

	if arg1 ~= "player" then
		return;
	end

	if gOutfitter_LastManaCall == nil then
		gOutfitter_LastManaCall = -1;
	end

	--#########################################################
	-- This is to tell us if we're in the Five Sec rule
	--#########################################################

	if ( UnitPowerType("player") == 0 ) then
		local currMana = UnitMana("player")
		if gOutfitter_currMana == nil then
			gOutfitter_currMana = currMana;
		end
		
		if ( currMana < gOutfitter_currMana) then
			if gOutfitter_LastManaCall == -1 then
				gOutfitter_LastManaCall = GetTime();
				MCEventLib:DispatchEvent("STARTFIVESECONDRULE");
			else
				gOutfitter_LastManaCall = GetTime();			
			end
			
			if Outfitter.Initialized then
				debugmessage("we have cast", 2);
			end
		end
		gOutfitter_currMana = currMana
	end

	if not OUTFIT_InDining then
		return;
	end
	
	--#########################################################
	-- Only Continue if we are in Dining Mode
	--#########################################################
	
	local	vHealth = UnitHealth("player");
	local	vMaxHealth = UnitHealthMax("player");
	local	vFullHealth = false;
	local	vFullMana = false;
	
	if vHealth > (vMaxHealth * 0.99) then
		vFullHealth = true;
	end
	
	if UnitPowerType("player") == 0 then
		local	vMana = UnitMana("player");
		local	vMaxMana = UnitManaMax("player");
		
		if vMana > (vMaxMana * 0.99) then
			vFullMana = true;
		end
	else
		vFullMana = true;
	end
	
	if vFullHealth and vFullMana then
		--if not gOutfitter_Settings.DisableDining then
			Outfitter_SetSpecialOutfitEnabled("Dining", false);
		--end if
	end
end

function Outfitter_UnitInventoryChanged(pEvent)
	debugmessage("Unit Inventory Changed", 1);

	if arg1 == "player" then
		--MCDebugLib:NoteMessage("Outfitter: " .. pEvent);
		Outfitter_ScheduleSynch();
	end
end

function Outfitter_ScheduleSynch()
	debugmessage("Schedule Synch", 1);
	MCSchedulerLib:ScheduleUniqueTask(0.1, Outfitter_Synchronize);
end

function Outfitter_InventoryChanged()
	debugmessage("Inventory Changed", 1);

	Outfitter.DisplayIsDirty = true; -- Update the list so the checkboxes reflect the current state
	
	local	vNewItemsOutfit, vCurrentOutfit = Outfitter_GetNewItemsOutfit(Outfitter.CurrentOutfit);
	
	if vNewItemsOutfit then
		-- Save the new outfit
		
		Outfitter.CurrentOutfit = vCurrentOutfit;
		
		-- Close QuickSlots if there's an inventory change (except if the only
		-- change is with the ammo slots)
		
		if OutfitterQuickSlots.SlotName ~= "AmmoSlot"
		or not Outfitter_OutfitIsAmmoOnly(vNewItemsOutfit) then
			OutfitterQuickSlots_Close();
		end
		
		-- Update the selected outfit or temporary outfit
		
		Outfitter_SubtractOutfit(vNewItemsOutfit, Outfitter.ExpectedOutfit);
		
		if Outfitter.SelectedOutfit then
			Outfitter_UpdateOutfitFromInventory(Outfitter.SelectedOutfit, vNewItemsOutfit);
		else
			Outfitter_UpdateTemporaryOutfit(vNewItemsOutfit);
		end
	end
	
	Outfitter_Update(true);
end

function Outfitter_OutfitIsAmmoOnly(pOutfit)
	debugmessage("Outfit Is Ammo Only", 1);
	local	vHasAmmoItem = false;
	
	for vInventorySlot, vItem in pairs(pOutfit.Items) do
		if vInventorySlot ~= "AmmoSlot" then
			return false;
		else
			vHasAmmoItem = true;
		end
	end
	
	return vHasAmmoItem;
end

function Outfitter_ExecuteCommand(pCommand)
	debugmessage("Execute Command -- "..pCommand, 1);

	vCommands =
	{
		wear = {useOutfit = true, func = Outfitter_WearOutfit},
		unwear = {useOutfit = true, func = Outfitter_RemoveOutfit},
		toggle = {useOutfit = true, func = Outfitter_ToggleOutfit},
		summary = {useOutfit = false, func = Outfitter_OutfitSummary},
		rating = {useOutfit = false, func = Outfitter_RatingSummary},
		debug = {useOutfit = false, func = Outfitter_ToggleDebug},
		debuglevel = {useOutfit = false, func = Outfitter_ToggleDebugLevel},
		debugshow = {useOutfit = false, func = Outfitter_ToggleDebugFrame},
	}

	local	vStartIndex, vEndIndex, vCommand, vParameter = string.find(pCommand, "(%w+) ?(.*)");
	
	if not vCommand then
		MCDebugLib:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter wear <outfit name>"..NORMAL_FONT_COLOR_CODE..": Wear an outfit");
		MCDebugLib:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter unwear <outfit name>"..NORMAL_FONT_COLOR_CODE..": Remove an outfit");
		MCDebugLib:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/outfitter toggle <outfit name>"..NORMAL_FONT_COLOR_CODE..": Wears or removes an outfit");
		return;
	end
	
	vCommand = strlower(vCommand);
	
	local	vCommandInfo = vCommands[vCommand];
	
	if not vCommandInfo then
		MCDebugLib:ErrorMessage("Outfitter: Expected command");
		return;
	end
	
	local	vOutfit = nil;
	local	vCategoryID = nil;
	
	if vCommandInfo.useOutfit then
		if not vParameter then
			MCDebugLib:ErrorMessage("Outfitter: Expected outfit name for "..vCommand.." command");
			return;
		end
		
		vOutfit, vCategoryID = Outfitter_FindOutfitByName(vParameter);
		
		if not vOutfit then
			MCDebugLib:ErrorMessage("Outfitter: Couldn't find outfit named "..vParameter);
			return;
		end
		
		vCommandInfo.func(vOutfit, vCategoryID);
	else
		vCommandInfo.func(vParameter);
	end
end

function Outfitter_AskRebuildOutfit(pOutfit, pCategoryID)
	debugmessage("Ask Rebuild Outfit", 1);
	gOutfitter_OutfitToRebuild = pOutfit;
	gOutfitter_OutfitCategoryToRebuild = pCategoryID;
	
	StaticPopup_Show("OUTFITTER_CONFIRM_REBUILD", gOutfitter_OutfitToRebuild.Name);
end

function Outfitter_AskSetCurrent(pOutfit, pCategoryID)
	debugmessage("Ask Set Current", 1);
	gOutfitter_OutfitToRebuild = pOutfit;
	gOutfitter_OutfitCategoryToRebuild = pCategoryID;
	
	StaticPopup_Show("OUTFITTER_CONFIRM_SET_CURRENT", gOutfitter_OutfitToRebuild.Name);
end

function Outfitter_RebuildSelectedOutfit()
	debugmessage("Rebuild Selected Outfit", 1);
	if not gOutfitter_OutfitToRebuild then
		return;
	end
	
	local	vOutfit = Outfitter_GenerateSmartOutfit("temp", gOutfitter_OutfitToRebuild.StatID, OutfitterItemList_GetEquippableItems(true));
	
	if vOutfit then
		gOutfitter_OutfitToRebuild.Items = vOutfit.Items;
		Outfitter_UpdateOutfitCategory(gOutfitter_OutfitToRebuild);
		Outfitter_WearOutfit(gOutfitter_OutfitToRebuild, gOutfitter_OutfitCategoryToRebuild);
		Outfitter_Update(true);
	end
	
	gOutfitter_OutfitToRebuild = nil;
	gOutfitter_OutfitCategoryToRebuild = nil;
end

function Outfitter_SetOutfitToCurrent()
	debugmessage("Set Outfit to Current", 1);
	if not gOutfitter_OutfitToRebuild then
		return;
	end
	
	for vSlotName in pairs(gOutfitter_OutfitToRebuild.Items) do
		Outfitter_SetInventoryItem(gOutfitter_OutfitToRebuild, vSlotName);
	end

	
	Outfitter_UpdateOutfitCategory(gOutfitter_OutfitToRebuild);
	Outfitter_WearOutfit(gOutfitter_OutfitToRebuild, gOutfitter_OutfitCategoryToRebuild);
	
	gOutfitter_OutfitToRebuild = nil;
	gOutfitter_OutfitCategoryToRebuild = nil;

	Outfitter_Update(true);
end

function Outfitter_AskDeleteOutfit(pOutfit)
	debugmessage("Ask Delete Outfit", 1);
	gOutfitter_OutfitToDelete = pOutfit;
	StaticPopup_Show("OUTFITTER_CONFIRM_DELETE", gOutfitter_OutfitToDelete.Name);
end

function Outfitter_DeleteSelectedOutfit()
	debugmessage("Delete Selected Outfit", 1);
	if not gOutfitter_OutfitToDelete then
		return;
	end
	
	Outfitter_DeleteOutfit(gOutfitter_OutfitToDelete);
	
	Outfitter_Update(true);
end

function Outfitter_LoadString(pString)
	debugmessage("Load String", 1);
	assert(loadstring(pString, "Outfit Script"))();
end

local	Outfitter_cScriptPrefix = "OutfitScriptFunc = function (outfit, event) local equip, delay, didEquip, isEquipped, time, setting, FiveSecRule, OutfitName, arg1, arg2, arg3, arg4 = nil, nil, outfit.didEquip, Outfitter_WearingOutfit(outfit), GetTime(), outfit.ScriptSettings, Outfitter_CheckFiveSecRule(), gOutfit_OutfitName, arg1, arg2, arg3, arg4;";
local	Outfitter_cScriptSuffix = " Outfitter_PostProcessScript(outfit, equip, delay, time) end";
local	Outfitter_cInputPrefix = "gOutfitterScriptInputs={";
local	Outfitter_cInputSuffix = "}";

function Outfitter_LoadScript(pScript)
	debugmessage("Load Script", 1);
	local	vSucceeded, vMessage = pcall(Outfitter_LoadString, pScript);
	
	if vMessage then
		local	_, _, vLine, vMessage2 = string.find(vMessage, Outfitter_cExtractErrorFormat);
		
		if vLine then
			vMessage = string.format(Outfitter_cScriptErrorFormat, vLine, vMessage2);
		end
	end
	
	return vSucceeded, vMessage;
end

function Outfitter_ParseScriptFields(pScript)
	debugmessage("Parse Script Fields", 1);
	local	vSettings = {};
	local	vMessage;
	
	for vSetting, vValue in string.gmatch(pScript, "-- $(%w+) ([^\r\n]*)") do
		vSetting = string.upper(vSetting);
		
		if vSetting == "DESC" then
			vSettings.Description = vValue;
		
		elseif vSetting == "SETTING" then
			local	vScript = Outfitter_cInputPrefix..vValue..Outfitter_cInputSuffix;
			local	vSucceeded;
			
			-- MCDebugLib:TestMessage(vScript);
			
			vSucceeded, vMessage = Outfitter_LoadScript(vScript);
			
			if not vSucceeded then
				return nil, vMessage;
			end
			
			if gOutfitterScriptInputs then
				if not vSettings.Inputs then
					vSettings.Inputs = {};
				end
				
				for vKey, vValue in pairs(gOutfitterScriptInputs) do
					if type(vValue) == "string" then
						vValue = {Type = vValue, Label = vKey};
					end
					
					vValue.Field = vKey;
					table.insert(vSettings.Inputs, vValue);
				end
				
				gOutfitterScriptInputs = nil;
			end
		end
	end
	
	return vSettings;
end

function Outfitter_LoadOutfitScript(pScript)
	debugmessage("Load Outfit Script", 1);
	local	vOldScriptFunc = OutfitScriptFunc;
	
	OutfitScriptFunc = nil;
	
	local	vScript = Outfitter_cScriptPrefix..pScript..Outfitter_cScriptSuffix;
	local	vSucceeded, vMessage = Outfitter_LoadScript(vScript);
	
	local	vScriptFunc = OutfitScriptFunc;
	
	OutfitScriptFunc = vOldScriptFunc;
	
	return vScriptFunc, vMessage;
end

function Outfitter_CheckFiveSecRule()
	debugmessage("Check Five Sec Rule", 1);

	-- lets check if we are in the Five Sec Cool down
	if gOutfitter_LastManaCall > -1 then
		return true;
	else
		return nil;
	end
end

function Outfitter_PostProcessScript(pOutfit, pEquip, pDelay, pStartTime)
	debugmessage("Post Process Script", 1);
	
	-- If the script took a long time to run and it hasn't been very long since
	-- the last time we'll increment a counter.  If that counters gets too high
	-- we can assume the script is misbehaving and shut it down
	
	local	vTime = GetTime();
	
	if vTime - pStartTime > 0.1
	and pOutfit.LastScriptTime
	and pStartTime - pOutfit.LastScriptTime < 0.5 then
		if not pOutfit.ScriptLockupCount then
			pOutfit.ScriptLockupCount = 1;
		else
			pOutfit.ScriptLockupCount = pOutfit.ScriptLockupCount + 1;
			
			if pOutfit.ScriptLockupCount > 20 then
				Outfitter_DeactivateScript(pOutfit);
			end
		end
	else
		pOutfit.ScriptLockupCount = 0;
	end
	
	pOutfit.LastScriptTime = pStartTime;
	
	if pEquip ~= nil then
		local	vChanged;
		
		Outfitter_BeginEquipmentUpdate();
				
		if pEquip then
			pOutfit.didEquip = true;
			if not Outfitter_WearingOutfit(pOutfit) then
				Outfitter_WearOutfit(pOutfit);
				vChanged = true;
			end
		else
			pOutfit.didEquip = false;
			if Outfitter_WearingOutfit(pOutfit) then
				Outfitter_RemoveOutfit(pOutfit);
				vChanged = true;
			end
		end
		
		-- Adjust the last equipped time to cause a delay if requested
		
		if vChanged and pDelay then
			local	vUpdateTime = pStartTime + (pDelay - Outfitter_cMinEquipmentUpdateInterval);
			
			if vUpdateTime > Outfitter.LastEquipmentUpdateTime then
				Outfitter.LastEquipmentUpdateTime = vUpdateTime;
			end
		end
		
		Outfitter_EndEquipmentUpdate();
	end

end

local	gOutfitter_DefaultSettingValues =
{
	String = "",
	Number = 0,
	StringTable = {},
	ZoneList = {},
};

function Outfitter_ActivateScript(pOutfit)
	debugmessage("Activate Script", 1);
	local	vScript, vScriptEvents = Outfitter_GetScript(pOutfit);
	
	if pOutfit.Disabled
	or pOutfit.DisableScript
	or not vScript
	or not vScriptEvents then
		return;
	end
	
	local	vScriptFields = Outfitter_ParseScriptFields(vScript);
	local	vScriptSettings = {};
	
	if not vScriptFields then
		return;
	end
	
	if vScriptFields.Inputs then
		for _, vDescriptor in ipairs(vScriptFields.Inputs) do
			vScriptSettings[vDescriptor.Field] = gOutfitter_DefaultSettingValues[vDescriptor.Type];
		end
	end
	
	if pOutfit.ScriptSettings then
		for vField, vValue in pairs(pOutfit.ScriptSettings) do
			if vScriptSettings[vField] ~= nil
			and type(vScriptSettings[vField]) == type(vValue) then
				vScriptSettings[vField] = vValue;
			end
		end
	end
	
	pOutfit.ScriptSettings = vScriptSettings;
	
	local	vScriptFunc = Outfitter_LoadOutfitScript(vScript);
	
	if not vScriptFunc then
		return;
	end
	
	for vEventID in string.gmatch(vScriptEvents, "([%w_]+)") do
		if vEventID == "WEAR_OUTFIT"
		or vEventID == "UNWEAR_OUTFIT" then
			if not Outfitter.OutfitScriptEvents[vEventID] then
				Outfitter.OutfitScriptEvents[vEventID] = {};
			end
			
			Outfitter.OutfitScriptEvents[vEventID][pOutfit] = vScriptFunc;
		else
			MCEventLib:RegisterEvent(vEventID, vScriptFunc, pOutfit);
		end
	end
end

function Outfitter_DeactivateScript(pOutfit)
	debugmessage("Deactivate Script", 1);
	for vEventID, vOutfits in pairs(Outfitter.OutfitScriptEvents) do
		vOutfits[pOutfit] = nil;
	end
	
	MCEventLib:UnregisterAllEvents(nil, pOutfit);
end

function Outfitter_SetScript(pOutfit, pEvents, pScript)
	debugmessage("Set Script", 1);
	Outfitter_DeactivateScript(pOutfit);
	
	if pEvents == "" then
		pEvents = nil;
	end
	
	if pScript == "" then
		pScript = nil;
	end
	
	pOutfit.ScriptEvents = pEvents;
	pOutfit.Script = pScript;
	pOutfit.ScriptID = nil;
	
	Outfitter_ActivateScript(pOutfit);
end

function Outfitter_SetScriptID(pOutfit, pScriptID)
	debugmessage("Set Script ID", 1);
	Outfitter_DeactivateScript(pOutfit);
	
	if pScriptID == "" then
		pScriptID = nil;
	end
	
	pOutfit.ScriptEvents = nil;
	pOutfit.Script = nil;
	pOutfit.ScriptID = pScriptID;
	
	Outfitter_ActivateScript(pOutfit);
end

function Outfitter_GetScript(pOutfit)
	debugmessage("Get Script", 1);
	if pOutfit.ScriptID then
		local	vPresetScript = Outfitter_GetPresetScriptByID(pOutfit.ScriptID);
		
		if vPresetScript then
			return vPresetScript.Script, vPresetScript.Events, pOutfit.ScriptID;
		end
	else
		return pOutfit.Script, pOutfit.ScriptEvents;
	end
end

function Outfitter_ShowPanel(pPanelIndex)
	debugmessage("Show Panel"..pPanelIndex, 1);

	Outfitter_CancelDialogs(); -- Force any dialogs to close if they're open
	
	if Outfitter.CurrentPanel > 0
	and Outfitter.CurrentPanel ~= pPanelIndex then
		Outfitter_HidePanel(Outfitter.CurrentPanel);
	end
	
	-- NOTE: Don't check for redundant calls since this function
	-- will be called to reset the field values as well as to 
	-- actually show the panel when it's hidden
	
	Outfitter.CurrentPanel = pPanelIndex;
	
	if Outfitter.Initialized then
		debugmessage("Show Panel"..gOutfitter_PanelFrames[pPanelIndex], 2);
	end

	getglobal(gOutfitter_PanelFrames[pPanelIndex]):Show();

	if Outfitter.Initialized then
		debugmessage("Panel"..gOutfitter_PanelFrames[pPanelIndex].." Shown",2);
	end
	
	PanelTemplates_SetTab(OutfitterFrame, pPanelIndex);

	if Outfitter.Initialized then
		debugmessage("Panel"..gOutfitter_PanelFrames[pPanelIndex].." Set",2);
	end
	
	-- Update the control values
	
	if pPanelIndex == 1 then
		-- Main panel
		
	elseif pPanelIndex == 2 then
		-- Options panel
		
	elseif pPanelIndex == 3 then
		-- About panel
		
	else
		MCDebugLib:ErrorMessage("Outfitter: Unknown index ("..pPanelIndex..") in ShowPanel()");
	end
	
	Outfitter_Update(false);

	if Outfitter.Initialized then
		debugmessage("Exit Show Panel", 2);
	end

end

function Outfitter_HidePanel(pPanelIndex)
	debugmessage("Hide Panel", 1);
	if Outfitter.CurrentPanel ~= pPanelIndex then
		return;
	end
	
	getglobal(gOutfitter_PanelFrames[pPanelIndex]):Hide();
	Outfitter.CurrentPanel = 0;
end

function Outfitter_CancelDialogs()
	debugmessage("Cancel Dialogs", 1);
end

function OutfitterItemDropDown_OnLoad()
	debugmessage("Item Dropdown OnLoad", 1);
	UIDropDownMenu_SetAnchor(0, 0, this, "TOPLEFT", this:GetName(), "CENTER");
	UIDropDownMenu_Initialize(this, OutfitterItemDropDown_Initialize);
	--UIDropDownMenu_Refresh(this); -- Don't refresh on menus which don't have a text portion
	
	this:SetHeight(this.SavedHeight);
end

function Outfitter_AddDividerMenuItem()
	debugmessage("Add Divider Menuitem", 1);
	UIDropDownMenu_AddButton({text = " ", notCheckable = true, notClickable = true});
end

function Outfitter_AddCategoryMenuItem(pName)
	debugmessage("Add Category Menuitem: "..pName, 1);
	UIDropDownMenu_AddButton({text = pName, notCheckable = true, notClickable = true});
end

function Outfitter_AddMenuItem(pFrame, pName, pValue, pChecked, pLevel, pColor, pDisabled)
	debugmessage("Add Menu Item", 1);
	if not pColor then
		pColor = NORMAL_FONT_COLOR;
	end
	
	UIDropDownMenu_AddButton({text = pName, value = pValue, owner = pFrame, checked = pChecked, func = OutfitterDropDown_OnClick2, textR = pColor.r, textG = pColor.g, textB = pColor.b, disabled = pDisabled}, pLevel);
end

function Outfitter_AddSubmenuItem(pFrame, pName, pValue)
	debugmessage("Add Submenu Item", 1);
	UIDropDownMenu_AddButton({text = pName, owner = pFrame, hasArrow = 1, value = pValue, textR = NORMAL_FONT_COLOR.r, textG = NORMAL_FONT_COLOR.g, textB = NORMAL_FONT_COLOR.b});
end

function Outfitter_AddSpecialToMenu(vFrame)
	debugmessage("Add Special To Menu", 1);
	-- Argent Dawn 
	Outfitter_AddMenuItem(vFrame, Outfitter_cArgentDawnOutfit, "ArgentDawn", not gOutfitter_Settings.DisableArgentDawn)
	
	-- Standard 
	Outfitter_AddMenuItem(vFrame, Outfitter_cRidingOutfit, "Riding", not gOutfitter_Settings.DisableRiding)
	Outfitter_AddMenuItem(vFrame, Outfitter_cDiningOutfit, "Dining", not gOutfitter_Settings.DisableDining)
	Outfitter_AddMenuItem(vFrame, Outfitter_cSwimmingOutfit, "Swimming", not gOutfitter_Settings.DisableSwimming)
	Outfitter_AddMenuItem(vFrame, Outfitter_cCityOutfit, "City", not gOutfitter_Settings.DisableCity)

	-- The Battle Grounds/Arena
	Outfitter_AddMenuItem(vFrame, Outfitter_cBattlegroundOutfit, "Battleground", not gOutfitter_Settings.DisableBattleground)
	Outfitter_AddMenuItem(vFrame, Outfitter_cABOutfit, "AB", not gOutfitter_Settings.DisableAB)
	Outfitter_AddMenuItem(vFrame, Outfitter_cAVOutfit, "AV", not gOutfitter_Settings.DisableAV)
	Outfitter_AddMenuItem(vFrame, Outfitter_cWSGOutfit, "WSG", not gOutfitter_Settings.DisableWSG)
	Outfitter_AddMenuItem(vFrame, Outfitter_cEotSOutfit, "EotS", not gOutfitter_Settings.DisableEotS)
	Outfitter_AddMenuItem(vFrame, Outfitter_cArenaOutfit, "Arena", not gOutfitter_Settings.DisableArena)

	-- Now add the Class Spercific Outfits to the list.
	local	vClassName = Outfitter_cNormalizedClassName[UnitClass("player")];

	if vClassName == "Warrior" then
		Outfitter_AddMenuItem(vFrame, Outfitter_cWarriorBattleStance, "Battle", not gOutfitter_Settings.DisableWarriorBattle)
		Outfitter_AddMenuItem(vFrame, Outfitter_cWarriorDefensiveStance, "Defensive", not gOutfitter_Settings.DisableWarriorDefensive)
		Outfitter_AddMenuItem(vFrame, Outfitter_cWarriorBerserkerStance, "Berserker", not gOutfitter_Settings.DisableWarriorBerserker)		
	end
	
	if vClassName == "Druid" then
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidBearForm, "Bear", not gOutfitter_Settings.DisableDruidBear)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidCatForm, "Cat", not gOutfitter_Settings.DisableDruidCat)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidAquaticForm, "Aquatic", not gOutfitter_Settings.DisableDruidAquatic)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidTravelForm, "Travel", not gOutfitter_Settings.DisableDruidTravel)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidMoonkinForm, "Moonkin", not gOutfitter_Settings.DisableDruidMoonkin)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidTreeOfLifeForm, "Tree", not gOutfitter_Settings.DisableDruidTree)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidProwl, "Prowl", not gOutfitter_Settings.DisableDruidProwl)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidFlightForm, "Flight", not gOutfitter_Settings.DisableDruidFlight)
		Outfitter_AddMenuItem(vFrame, Outfitter_cDruidSwiftFlightForm, "SwiftFlight", not gOutfitter_Settings.DisableDruidSwiftFlight)
	end
	
	if vClassName == "Priest" then
		Outfitter_AddMenuItem(vFrame, Outfitter_cPriestShadowform, "Shadowform", not gOutfitter_Settings.DisablePriestShadowform)
	end
	
	if vClassName == "Rogue" then
		Outfitter_AddMenuItem(vFrame, Outfitter_cRogueStealth, "Stealth", not gOutfitter_Settings.DisableRogueStealth)
	end
	
	if vClassName == "Shaman" then
		Outfitter_AddMenuItem(vFrame, Outfitter_cShamanGhostWolf, "GhostWolf", not gOutfitter_Settings.DisableShamanGhostWolf)
	end
	
	if vClassName == "Hunter" then
		Outfitter_AddMenuItem(vFrame, Outfitter_cHunterMonkey, "Monkey", not gOutfitter_Settings.DisableHunterMonkey)
		Outfitter_AddMenuItem(vFrame, Outfitter_cHunterHawk, "Hawk", not gOutfitter_Settings.DisableHunterHawk)
		Outfitter_AddMenuItem(vFrame, Outfitter_cHunterCheetah, "Cheetah", not gOutfitter_Settings.DisableHunterCheetah)
		Outfitter_AddMenuItem(vFrame, Outfitter_cHunterPack, "Pack", not gOutfitter_Settings.DisableHunterPack)
		Outfitter_AddMenuItem(vFrame, Outfitter_cHunterBeast, "Beast", not gOutfitter_Settings.DisableHunterBeast)
		Outfitter_AddMenuItem(vFrame, Outfitter_cHunterWild, "Wild", not gOutfitter_Settings.DisableHunterWild)
		Outfitter_AddMenuItem(vFrame, Outfitter_cHunterViper, "Viper", not gOutfitter_Settings.DisableHunterViper)
	end

	if vClassName == "Mage" then
		Outfitter_AddMenuItem(vFrame, Outfitter_cMageEvocate, "Evocate", not gOutfitter_Settings.DisableMageEvocate)
	end

end

function OutfitterItemDropDown_Initialize()
	local	vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local	vItem = vFrame:GetParent():GetParent();
	local	vOutfit, vCategoryID = Outfitter_GetOutfitFromListItem(vItem);

	debugmessage("Item DropDown Initialize", 1);
		
	-- Add the "Global Display"
--	Outfitter_AddCategoryMenuItem(getglobal("Outfitter_cGlobalCategory"));
	
	-- Add the dropdown menu for the displaying outfits)
--	UIDropDownMenu_AddButton({text = "Show outfits", 
--														value = pValue, 
--														owner = vFrame, 
--														checked = {-99 ,nil}, 
--														func = OutfitterDropDown_OnClick2, 
--														textR = NORMAL_FONT_COLOR.r, 
--														textG = NORMAL_FONT_COLOR.g, 
--														textB = NORMAL_FONT_COLOR.b, 
--														disabled = nil}, 
--														nil);


	if vItem.categoryID == -99 then
		debugmessage("Opening 'Display Outfits'", 1);
		
		if UIDROPDOWNMENU_MENU_LEVEL == 1 then
			Outfitter_AddSpecialToMenu(vFame);
		end
		
		return;
	end
	
	if not vOutfit then
		return;
	end

	-- A dropdown menu 
	-- Outfitter_AddCategoryMenuItem("Auto Outfits");
	
	
	debugmessage("Item Menu Level: "..UIDROPDOWNMENU_MENU_LEVEL, 2);

	if UIDROPDOWNMENU_MENU_LEVEL == 1 then
		local	vIsSpecialOutfit = vCategoryID == "Special";
		
		Outfitter_AddCategoryMenuItem(vOutfit.Name);
		
		Outfitter_AddSubmenuItem(vFrame, Outfitter_cRememberVisibility, "HELMCLOAK");
		Outfitter_AddMenuItem(vFrame, Outfitter_cEnableSlotPriority, "ITEMLISTBOX", vOutfit.Enabled);
		
		if vIsSpecialOutfit then
			Outfitter_AddMenuItem(vFrame, Outfitter_cDisableOutfit, "DISABLE", vOutfit.Disabled);
			
			if vOutfit.SpecialID == "Riding" then
				Outfitter_AddMenuItem(vFrame, Outfitter_cDisableOutfitInBG, "BGDISABLE", vOutfit.BGDisabled)
				Outfitter_AddMenuItem(vFrame, Outfitter_cDisableOutfitInAQ40, "AQDISABLE", vOutfit.AQDisabled);
			end
			
			if vOutfit.SpecialID == "ArgentDawn" then
				Outfitter_AddMenuItem(vFrame, Outfitter_cDisableOutfitInNaxx, "NAXXDISABLE", vOutfit.NaxxDisabled);
			end
			
			Outfitter_AddMenuItem(vFrame, Outfitter_cDisableOutfitInCombat, "COMBATDISABLE", vOutfit.CombatDisabled);
		else
			Outfitter_AddMenuItem(vFrame, PET_RENAME, "RENAME");
		end
		
		if not vIsSpecialOutfit
		and vOutfit.StatID then
			local	vStatName = Outfitter_GetStatIDName(vOutfit.StatID);
			
			if vStatName then
				Outfitter_AddMenuItem(vFrame, format(Outfitter_cRebuildOutfitFormat, vStatName), "REBUILD");
			end
		end
		
		Outfitter_AddSubmenuItem(vFrame, Outfitter_cKeyBinding, "BINDING");
		
		Outfitter_AddMenuItem(vFrame, Outfitter_cSetCurrentItems, "SET_CURRENT");
		
		if not vIsSpecialOutfit then
			Outfitter_AddMenuItem(vFrame, DELETE, "DELETE");
		end
		
		Outfitter_AddCategoryMenuItem(Outfitter_cBankCategoryTitle);
		Outfitter_AddMenuItem(vFrame, Outfitter_cDepositToBank, "DEPOSIT", nil, nil, nil, not Outfitter.BankFrameOpened);
		Outfitter_AddMenuItem(vFrame, Outfitter_cDepositUniqueToBank, "DEPOSITUNIQUE", nil, nil, nil, not Outfitter.BankFrameOpened);
		Outfitter_AddMenuItem(vFrame, Outfitter_cWithdrawFromBank, "WITHDRAW", nil, nil, nil, not Outfitter.BankFrameOpened);
		
		if not vIsSpecialOutfit
		and vCategoryID ~= "Complete" then
			Outfitter_AddCategoryMenuItem(Outfitter_cOutfitCategoryTitle);
			Outfitter_AddMenuItem(vFrame, Outfitter_cPartialOutfits, "PARTIAL", vCategoryID == "Partial");
			Outfitter_AddMenuItem(vFrame, Outfitter_cAccessoryOutfits, "ACCESSORY", vCategoryID == "Accessory");
		end
		
		if not vIsSpecialOutfit or gOutfitter_Settings.Options.Debug then
			Outfitter_AddCategoryMenuItem(Outfitter_cScript);
			Outfitter_AddMenuItem(vFrame, Outfitter_cEditScriptEllide, "EDIT_SCRIPT");
			Outfitter_AddMenuItem(vFrame, Outfitter_cDisableScript, "DISABLE_SCRIPT", vOutfit.DisableScript);
		end

	elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "BINDING" then
			Outfitter_AddMenuItem(vFrame, Outfitter_cNone, "BINDING_NONE", not vOutfit.BindingIndex, UIDROPDOWNMENU_MENU_LEVEL);
			
			for vIndex = 1, 10 do
				Outfitter_AddMenuItem(vFrame, getglobal("BINDING_NAME_OUTFITTER_OUTFIT"..vIndex), "BINDING_"..vIndex, vOutfit.BindingIndex == vIndex, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
		if UIDROPDOWNMENU_MENU_VALUE == "HELMCLOAK" then
			Outfitter_AddMenuItem(vFrame, Outfitter_cShowHelm, "SHOWHELM", vOutfit.ShowHelm,UIDROPDOWNMENU_MENU_LEVEL);
			Outfitter_AddMenuItem(vFrame, Outfitter_cHideHelm, "HIDEHELM", vOutfit.HideHelm,UIDROPDOWNMENU_MENU_LEVEL);
			Outfitter_AddMenuItem(vFrame, Outfitter_cShowCloak, "SHOWCLOAK", vOutfit.ShowCloak,UIDROPDOWNMENU_MENU_LEVEL);
			Outfitter_AddMenuItem(vFrame, Outfitter_cHideCloak, "HIDECLOAK", vOutfit.HideCloak,UIDROPDOWNMENU_MENU_LEVEL);
		end
	end
	
	vFrame:SetHeight(vFrame.SavedHeight);
end

function Outfitter_SetAutoSwitch(pAutoSwitch)
	debugmessage("Outfitter_SetAutoSwitch",1);
	gOutfitter_Settings.Options.DisableAutoSwitch = not pAutoSwitch;
	
	Outfitter_Update(false);
end

function Outfitter_SetTooltipInfo(pTooltip)
	debugmessage("Outfitter_SetTooltipInfo",1);
	gOutfitter_Settings.Options.DisableToolTipInfo = not pTooltip;

	-- if we're disabling the Tooltip show then set it back so it doesn't even go through us
	if gOutfitter_Settings.Options.DisableToolTipInfo then
		GameTooltip.SetBagItem = GameTooltip.Outfitter_OrigSetBagItem;
		GameTooltip.SetInventoryItem = GameTooltip.Outfitter_OrigSetInventoryItem;
				
	else -- Letit bounce through us.
		GameTooltip.Outfitter_OrigSetBagItem = GameTooltip.SetBagItem;
		GameTooltip.SetBagItem = Outfitter_GameTooltip_SetBagItem;
		
		GameTooltip.Outfitter_OrigSetInventoryItem = GameTooltip.SetInventoryItem;
		GameTooltip.SetInventoryItem = Outfitter_GameTooltip_SetInventoryItem;	
	end
	
	Outfitter_Update(false);
end 

function Outfitter_ToggleDebugFrame()
	if Outfitter_DebugFrame:IsShown() then
	 Outfitter_DebugFrame:Hide();
	else
	 Outfitter_DebugFrame:Hide();
	end
		
end

function Outfitter_ToggleDebugLevel(level)
	if level then 
 		gOutfitter_Settings.DebugLevel = tonumber(level);
 	end
 	
end

function Outfitter_ToggleDebug()
	debugmessage("Outfitter_ToggleDebug",1);
	if gOutfitter_Settings.Options.Debug then
		gOutfitter_Settings.Options.Debug = false;
	else
		gOutfitter_Settings.Options.Debug = true;
	end 
end

function Outfitter_SetDebug(pDebug)
	debugmessage("Outfitter_SetDebug",1);
	gOutfitter_Settings.Options.Debug = pDebug;
	Outfitter_Update(false);
end 

function Outfitter_SetShowMinimapButton(pShowButton)
	debugmessage("Outfitter_SetShowMinimapButton",1);
	gOutfitter_Settings.Options.HideMinimapButton = not pShowButton;
	
	if gOutfitter_Settings.Options.HideMinimapButton then
		OutfitterMinimapButton:Hide();
	else
		OutfitterMinimapButton:Show();
	end
	
	Outfitter_Update(false);
end

function Outfitter_SetRememberVisibility(pRememberVisibility)
	debugmessage("Outfitter_SetRememberVisibility",1);
	gOutfitter_Settings.Options.DisableAutoVisibility = not pRememberVisibility;
	
	Outfitter_Update(false);
end

function Outfitter_SetShowHotkeyMessages(pShowHotkeyMessages)
	debugmessage("Outfitter_SetShowHotkeyMessages",1);
	gOutfitter_Settings.Options.DisableHotkeyMessages = not pShowHotkeyMessages;
	
	Outfitter_Update(false);
end

function OutfitterMinimapDropDown_OnLoad()
	debugmessage("OutfitterMinimapDropDown_OnLoad",1);
	UIDropDownMenu_SetAnchor(3, -7, this, "TOPRIGHT", this:GetName(), "TOPLEFT");
	UIDropDownMenu_Initialize(this, OutfitterMinimapDropDown_Initialize);
	--UIDropDownMenu_Refresh(this); -- Don't refresh on menus which don't have a text portion
	
	Outfitter_RegisterOutfitEvent("WEAR_OUTFIT", OutfitterMinimapDropDown_OutfitEvent);
	Outfitter_RegisterOutfitEvent("UNWEAR_OUTFIT", OutfitterMinimapDropDown_OutfitEvent);
end

function OutfitterMinimapDropDown_OutfitEvent(pEvent, pParameter1, pParameter2)
	debugmessage("OutfitterMinimapDropDown_OutfitEvent",1);
	if UIDROPDOWNMENU_OPEN_MENU ~= "OutfitterMinimapButton" then
		return;
	end
	
	UIDropDownMenu_Initialize(OutfitterMinimapButton, OutfitterMinimapDropDown_Initialize);
end

function OutfitterMinimapDropDown_AdjustScreenPosition(pMenu)
	debugmessage("OutfitterMinimapDropDown_AdjustScreenPosition",1);
	local	vListFrame = getglobal("DropDownList1");
	
	if not vListFrame:IsVisible() then
		return;
	end
	
	local	vCenterX, vCenterY = pMenu:GetCenter();
	local	vScreenWidth, vScreenHeight = GetScreenWidth(), GetScreenHeight();
	
	local	vAnchor;
	local	vOffsetX, vOffsetY;
	
	if vCenterY < vScreenHeight / 2 then
		vAnchor = "BOTTOM";
		vOffsetY = -8;
	else
		vAnchor = "TOP";
		vOffsetY = -17;
	end
	
	if vCenterX < vScreenWidth / 2 then
		vAnchor = vAnchor.."LEFT";
		vOffsetX = 21;
	else
		vAnchor = vAnchor.."RIGHT";
		vOffsetX = 3;
	end
	
	vListFrame:ClearAllPoints();
	vListFrame:SetPoint(vAnchor, pMenu.relativeTo, pMenu.relativePoint, vOffsetX, vOffsetY);
end

function Outfitter_OutfitIsVisible(pOutfit)
	debugmessage("Outfitter_OutfitIsVisible",1);
	return not pOutfit.Disabled
	   and not Outfitter_IsEmptyOutfit(pOutfit);
end

function Outfitter_HasVisibleOutfits(pOutfits)
	debugmessage("Outfitter_HasVisibleOutfits",1);
	if not pOutfits then
		return false;
	end
	
	for vIndex, vOutfit in pairs(pOutfits) do
		if Outfitter_OutfitIsVisible(vOutfit) then	
			return true;
		end
	end
	
	return false;
end

function OutfitterMinimapDropDown_Initialize()
	debugmessage("OutfitterMinimapDropDown_Initialize",1);
	-- Just return if not initialized yet
	
	if not Outfitter.Initialized then
		return;
	end
	
	--
	
	local	vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	
	Outfitter_AddCategoryMenuItem(Outfitter_cTitleVersion);
	Outfitter_AddMenuItem(vFrame, Outfitter_cOpenOutfitter, 0);
	Outfitter_AddMenuItem(vFrame, Outfitter_cAutoSwitch, -1, not gOutfitter_Settings.Options.DisableAutoSwitch);
	
	OutfitterMinimapDropDown_InitializeOutfitList();
end

function Outfitter_GetCategoryOrder()
	debugmessage("Outfitter_GetCategoryOrder",1);
	return gOutfitter_cCategoryOrder;
end

function Outfitter_GetOutfitsByCategoryID(pCategoryID)
	debugmessage("Outfitter_GetOutfitsByCategoryID",1);
	return gOutfitter_Settings.Outfits[pCategoryID];
end

function OutfitterMinimapDropDown_InitializeOutfitList()
	debugmessage("OutfitterMinimapDropDown_InitializeOutfitList",1);
	-- Just return if not initialized yet
	
	if not Outfitter.Initialized then
		return;
	end
	
	local	vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	local	vCategoryOrder = Outfitter_GetCategoryOrder();
		
	-- Add the "Global Display"
	--Outfitter_AddCategoryMenuItem(getglobal("Outfitter_cGlobalCategory"));
	
	-- Add the dropdown menu for the displaying outfits)
	--UIDropDownMenu_AddButton({text = "Show outfits", 
	--													value = pValue, 
	--													owner = vFrame, 
	--													checked = {-99 ,nil}, 
	--													func = OutfitterDropDown_OnClick2, 
	--													textR = NORMAL_FONT_COLOR.r, 
	--													textG = NORMAL_FONT_COLOR.g, 
	--													textB = NORMAL_FONT_COLOR.b, 
	--													disabled = nil}, 
	--													nil);

	for vCategoryIndex, vCategoryID in ipairs(vCategoryOrder) do
		local	vCategoryName = getglobal("Outfitter_c"..vCategoryID.."Outfits");
		local	vOutfits = Outfitter_GetOutfitsByCategoryID(vCategoryID);

		debugmessage("Adding Category: "..vCategoryName, 2);
		
		if Outfitter_HasVisibleOutfits(vOutfits) then
			Outfitter_AddCategoryMenuItem(vCategoryName);
			
			for vIndex, vOutfit in ipairs(vOutfits) do
				if Outfitter_OutfitIsVisible(vOutfit) then
					local	vWearingOutfit = Outfitter_WearingOutfit(vOutfit);
					local	vMissingItems, vBankedItems = OutfitterItemList_GetMissingItems(vEquippableItems, vOutfit);
					local	vItemColor = NORMAL_FONT_COLOR;
					
					if vMissingItems then
						vItemColor = RED_FONT_COLOR;
					elseif vBankedItems then
						vItemColor = BANKED_FONT_COLOR;
					end
					
					Outfitter_AddMenuItem(vFrame, vOutfit.Name, {CategoryID = vCategoryID, Index = vIndex}, vWearingOutfit, nil, vItemColor);
				end
			end
		end
	end
end

function OutfitterDropDown_OnClick()
	debugmessage("OutfitterDropDown_OnClick",2);
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);
	OutfitterDropDown_OnClick2();
end

function OutfitterDropDown_OnClick2()
	debugmessage("OutfitterDropDown_OnClick2",2);
	if this.owner.ChangedValueFunc then
		this.owner.ChangedValueFunc(this.owner, this.value);
	end
	
	CloseDropDownMenus();
end

function OutfitterItem_SetTextColor(pItem, pRed, pGreen, pBlue)
	debugmessage("OutfitterItem_SetTextColor",1);
	local	vItemNameField;
	
	if pItem.isCategory then
		vItemNameField = getglobal(pItem:GetName().."CategoryName");
	else
		vItemNameField = getglobal(pItem:GetName().."OutfitName");
	end
	
	vItemNameField:SetTextColor(pRed, pGreen, pBlue);
end

Outfitter_cCategoryDescriptions =
{
	Complete = Outfitter_cCompleteCategoryDescripton,
	Partial = Outfitter_cPartialCategoryDescription,
	Accessory = Outfitter_cAccessoryCategoryDescription,
	Special = Outfitter_cSpecialCategoryDescription,
	OddsNEnds = Outfitter_cOddsNEndsCategoryDescription,
};

Outfitter_cMissingItemsSeparator = ", ";

function Outfitter_GenerateItemListString(pLabel, pListColorCode, pItems)
	debugmessage("Outfitter_GenerateItemListString",1);
	local	vItemList = nil;

	for vIndex, vOutfitItem in ipairs(pItems) do
		if not vItemList then
			vItemList = HIGHLIGHT_FONT_COLOR_CODE..pLabel..pListColorCode..vOutfitItem.Name;
		else
			vItemList = vItemList..Outfitter_cMissingItemsSeparator..vOutfitItem.Name;
		end
	end
	
	return vItemList;
end

function OutfitterItem_OnEnter(pItem)
	debugmessage("OutfitterItem_OnEnter",1);
	OutfitterItem_SetTextColor(pItem, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	if Outfitter.Initialized then
		debugmessage("Item On Enter", 3);
	end

	if pItem.isCategory then
		local	vDescription = Outfitter_cCategoryDescriptions[pItem.categoryID];
		
		if vDescription then
			local	vCategoryName = getglobal("Outfitter_c"..pItem.categoryID.."Outfits");
			
			GameTooltip_AddNewbieTip(vCategoryName, 1.0, 1.0, 1.0, vDescription, 1);
		end
		
		ResetCursor();
	elseif pItem.isOutfitItem then
		local	vHasCooldown, vRepairCost;
		
		GameTooltip:SetOwner(pItem, "ANCHOR_TOP");
		
		if pItem.outfitItem.Location.SlotName then
			if not pItem.outfitItem.Location.SlotID then
				pItem.outfitItem.Location.SlotID = Outfitter_cSlotIDs[pItem.outfitItem.Location.SlotName];
			end
			
			GameTooltip:SetInventoryItem("player", pItem.outfitItem.Location.SlotID);
		else
			vHasCooldown, vRepairCost = GameTooltip:SetBagItem(pItem.outfitItem.Location.BagIndex, pItem.outfitItem.Location.BagSlotIndex);
		end
		
		GameTooltip:Show();

		if InRepairMode() and (vRepairCost and vRepairCost > 0) then
			GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
			SetTooltipMoney(GameTooltip, vRepairCost);
			GameTooltip:Show();
		elseif MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 then
			if pItem.outfitItem.Location.BagIndex then
				ShowContainerSellCursor(pItem.outfitItem.Location.BagIndex, pItem.outfitItem.Location.BagSlotIndex);
			end
		else
			ResetCursor();
		end
	else
		local	vOutfit = Outfitter_GetOutfitFromListItem(pItem);
		
		if pItem.MissingItems
		or pItem.BankedItems then
			GameTooltip:SetOwner(pItem, "ANCHOR_LEFT");
			
			GameTooltip:AddLine(vOutfit.Name);
			
			if pItem.MissingItems then
				local	vItemList = Outfitter_GenerateItemListString(Outfitter_cMissingItemsLabel, RED_FONT_COLOR_CODE, pItem.MissingItems);
				GameTooltip:AddLine(vItemList, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			end
			
			if pItem.BankedItems then
				local	vItemList = Outfitter_GenerateItemListString(Outfitter_cBankedItemsLabel, BANKED_FONT_COLOR_CODE, pItem.BankedItems);
				GameTooltip:AddLine(vItemList, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			end
			
			GameTooltip:Show();
		elseif vOutfit.SpecialID then
			local	vDescription = Outfitter_cSpecialOutfitDescriptions[vOutfit.SpecialID];
			
			if vDescription then
				GameTooltip_AddNewbieTip(vOutfit.Name, 1.0, 1.0, 1.0, vDescription, 1);
			end
		end
		
		ResetCursor();
	end
end

function OutfitterItem_OnLeave(pItem)
	debugmessage("OutfitterItem_OnLeave",1);
	if pItem.isCategory then
		OutfitterItem_SetTextColor(pItem, 1, 1, 1);
	else
		OutfitterItem_SetTextColor(pItem, pItem.DefaultColor.r, pItem.DefaultColor.g, pItem.DefaultColor.b);
	end
	
	GameTooltip:Hide();
end

function OutfitterItem_OnClick(pItem, pButton, pIgnoreModifiers)
	debugmessage("OutfitterItem_OnClick",1);
	--MCDebugLib:ErrorMessage("Outfitter: Item Click");

	if pItem.isCategory then
		local	vCategoryOutfits = gOutfitter_Settings.Outfits[pItem.categoryID];
		
		Outfitter.Collapsed[pItem.categoryID] = not Outfitter.Collapsed[pItem.categoryID];
		Outfitter.DisplayIsDirty = true;
	elseif pItem.isOutfitItem then
		if pButton == "LeftButton" then
			Outfitter_PickupItemLocation(pItem.outfitItem.Location);
			StackSplitFrame:Hide();
		else
			if MerchantFrame:IsShown() and MerchantFrame.selectedTab == 2 then
				-- Don't sell the item if the buyback tab is selected
				return;
			else
				if pItem.outfitItem.Location.BagIndex then
					UseContainerItem(pItem.outfitItem.Location.BagIndex, pItem.outfitItem.Location.BagSlotIndex);
					StackSplitFrame:Hide();
				end
			end
		end
	else
		local	vOutfit = Outfitter_GetOutfitFromListItem(pItem);
		
		if not vOutfit then
			-- Error: outfit not found
			return;
		end

		debugmessage("Outfitter: Checking Outfit Level.",3);
		if vOutfit.Enabled then
			Outfitter_Arrange_ListBoxOuterFrame:Show()
			Outfitter_Arrange_ListBox:Show()
			Outfitter_Arrange_ButtonUp:Show()
			Outfitter_Arrange_ButtonDown:Show()
			Outfitter_Arrange_ButtonReset:Show()
		else
			Outfitter_Arrange_ListBoxOuterFrame:Hide()
			Outfitter_Arrange_ListBox:Hide()
			Outfitter_Arrange_ButtonUp:Hide()
			Outfitter_Arrange_ButtonDown:Hide()
			Outfitter_Arrange_ButtonReset:Hide()
		end	

		vOutfit.Disabled = nil;
		Outfitter_WearOutfit(vOutfit, pItem.categoryID);
	end

	-- Show or HIDE the Listbox stuff.	
	Outfitter_Update(true);
end

function OutfitterItem_CheckboxClicked(pItem)
	debugmessage("OutfitterItem_CheckboxClicked",1);
	if pItem.isCategory then
		return;
	end
	
	local	vOutfits = gOutfitter_Settings.Outfits[pItem.categoryID];
	
	if not vOutfits then
		-- Error: outfit category not found
		return;
	end
	
	local	vOutfit = vOutfits[pItem.outfitIndex];
	
	if not vOutfit then
		-- Error: outfit not found
		return;
	end
	
	local	vCheckbox = getglobal(pItem:GetName().."OutfitSelected");
	
	if vCheckbox:GetChecked() then
		vOutfit.Disabled = nil;
		Outfitter_WearOutfit(vOutfit, pItem.categoryID);
	else
		Outfitter_RemoveOutfit(vOutfit);
	end
	
	Outfitter_Update(true);
end

function OutfitterItem_SetToOutfit(pItemIndex, pOutfit, pCategoryID, pOutfitIndex, pEquippableItems)
	debugmessage("OutfitterItem_SetToOutfit",1);
	local	vItemName = "OutfitterItem"..pItemIndex;
	local	vItem = getglobal(vItemName);
	local	vOutfitFrameName = vItemName.."Outfit";
	local	vOutfitFrame = getglobal(vOutfitFrameName);
	local	vItemFrame = getglobal(vItemName.."Item");
	local	vCategoryFrame = getglobal(vItemName.."Category");
	local	vMissingItems, vBankedItems = OutfitterItemList_GetMissingItems(pEquippableItems, pOutfit);

	if Outfitter.Initialized then
		debugmessage("SetToOutfit -- Item Name: "..vItemName..", Frame: "..vOutfitFrameName, 1);
	end

	
	vOutfitFrame:Show();
	vCategoryFrame:Hide();
	vItemFrame:Hide();
	
	local	vItemSelectedCheckmark = getglobal(vOutfitFrameName.."Selected");
	local	vItemNameField = getglobal(vOutfitFrameName.."Name");
	local	vItemMenu = getglobal(vOutfitFrameName.."Menu");
	
	vItemSelectedCheckmark:Show();
	
	if Outfitter_WearingOutfit(pOutfit) then
		vItemSelectedCheckmark:SetChecked(true);
	else
		vItemSelectedCheckmark:SetChecked(nil);
	end
	
	vItem.MissingItems = vMissingItems;
	vItem.BankedItems = vBankedItems;
	
	if pOutfit.Disabled then
		vItemNameField:SetText(format(Outfitter_cDisabledOutfitName, pOutfit.Name));
		vItem.DefaultColor = GRAY_FONT_COLOR;
	else
		vItemNameField:SetText(pOutfit.Name);
		if vMissingItems then
			vItem.DefaultColor = RED_FONT_COLOR;
		elseif vBankedItems then
			vItem.DefaultColor = BANKED_FONT_COLOR;
		else
			vItem.DefaultColor = NORMAL_FONT_COLOR;
		end
	end
	
	vItemNameField:SetTextColor(vItem.DefaultColor.r, vItem.DefaultColor.g, vItem.DefaultColor.b);
	
	vItemMenu:Show();
	
	vItem.isCategory = false;
	vItem.isOutfitItem = false;
	vItem.outfitItem = nil;
	vItem.categoryID = pCategoryID;
	vItem.outfitIndex = pOutfitIndex;
	
	vItem:Show();
	
	-- Update the highlighting
	
	if Outfitter.SelectedOutfit == pOutfit then
		OutfitterMainFrameHighlight:SetPoint("TOPLEFT", vItem, "TOPLEFT", 0, 0);
		OutfitterMainFrameHighlight:Show();
	end
end

function OutfitterItem_SetToItem(pItemIndex, pOutfitItem)
	local	vItemName = "OutfitterItem"..pItemIndex;
	local	vItem = getglobal(vItemName);
	local	vCategoryFrameName = vItemName.."Category";
	local	vItemFrameName = vItemName.."Item";
	local	vItemFrame = getglobal(vItemFrameName);
	local	vOutfitFrame = getglobal(vItemName.."Outfit");
	local	vCategoryFrame = getglobal(vCategoryFrameName);
	
	vItem.isOutfitItem = true;
	vItem.isCategory = false;
	vItem.outfitItem = pOutfitItem;
	
	vItemFrame:Show();
	vOutfitFrame:Hide();
	vCategoryFrame:Hide();

	local	vItemNameField = getglobal(vItemFrameName.."Name");
	local	vItemIcon = getglobal(vItemFrameName.."Icon");
	
	vItemNameField:SetText(pOutfitItem.Name);
	
	if pOutfitItem.Quality then
		vItem.DefaultColor = ITEM_QUALITY_COLORS[pOutfitItem.Quality];
	else
		vItem.DefaultColor = GRAY_FONT_COLOR;
	end
	
	if pOutfitItem.Texture then
		vItemIcon:SetTexture(pOutfitItem.Texture);
		vItemIcon:Show();
	else
		vItemIcon:Hide();
	end
	
	vItemNameField:SetTextColor(vItem.DefaultColor.r, vItem.DefaultColor.g, vItem.DefaultColor.b);
	
	vItem:Show();
end

function OutfitterItem_SetToCategory(pItemIndex, pCategoryID)
	debugmessage("Set To Category "..pItemIndex.." - "..pCategoryID, 1);

	local	vCategoryName = getglobal("Outfitter_c"..pCategoryID.."Outfits");
	local	vItemName = "OutfitterItem"..pItemIndex;
	local	vItem = getglobal(vItemName);
	local	vCategoryFrameName = vItemName.."Category";
	local	vOutfitFrame = getglobal(vItemName.."Outfit");
	local	vItemFrame = getglobal(vItemName.."Item");
	local	vCategoryFrame = getglobal(vCategoryFrameName);

	debugmessage("Category : "..vCategoryName..", Frame Name: "..vCategoryFrameName, 2);
	
	vOutfitFrame:Hide();
	vCategoryFrame:Show();
	vItemFrame:Hide();
	
	local	vItemNameField = getglobal(vCategoryFrameName.."Name");
	local	vExpandButton = getglobal(vCategoryFrameName.."Expand");
	
	vItem.MissingItems = nil;
	vItem.BankedItems = nil;
	
	if Outfitter.Collapsed[pCategoryID] then
		vExpandButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up"); 
	else
		vExpandButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	end
	
	vItemNameField:SetText(vCategoryName);
	
	vItem.isCategory = true;
	vItem.isOutfitItem = false;
	vItem.outfitItem = nil;
	vItem.categoryID = pCategoryID;
	
	vItem:Show();
end

function Outfitter_AddOutfitsToList(pOutfits, pCategoryID, pItemIndex, pFirstItemIndex, pEquippableItems)
	local	vOutfits = pOutfits[pCategoryID];
	local	vItemIndex = pItemIndex;
	local	vFirstItemIndex = pFirstItemIndex;
	debugmessage("Add 'Outfits' to List", 1);
	
	if vFirstItemIndex == 0 then
		OutfitterItem_SetToCategory(vItemIndex, pCategoryID, false);
		vItemIndex = vItemIndex + 1;
	else
		vFirstItemIndex = vFirstItemIndex - 1;
	end

	if vItemIndex >= Outfitter_cMaxDisplayedItems then
		return vItemIndex, vFirstItemIndex;
	end

	if not Outfitter.Collapsed[pCategoryID]
	and vOutfits then
		for vIndex, vOutfit in ipairs(vOutfits) do
			if vFirstItemIndex == 0 then
				OutfitterItem_SetToOutfit(vItemIndex, vOutfit, pCategoryID, vIndex, pEquippableItems);
				vItemIndex = vItemIndex + 1;
				
				if vItemIndex >= Outfitter_cMaxDisplayedItems then
					return vItemIndex, vFirstItemIndex;
				end
			else
				vFirstItemIndex = vFirstItemIndex - 1;
			end
		end
	end
	
	return vItemIndex, vFirstItemIndex;
end

function Outfitter_AddOutfitItemsToList(pOutfitItems, pCategoryID, pItemIndex, pFirstItemIndex)
	debugmessage("Add Outfit Items To List", 1);

	local	vItemIndex = pItemIndex;
	local	vFirstItemIndex = pFirstItemIndex;
	
	if vFirstItemIndex == 0 then
		OutfitterItem_SetToCategory(vItemIndex, pCategoryID, false);
		vItemIndex = vItemIndex + 1;
	else
		vFirstItemIndex = vFirstItemIndex - 1;
	end

	if vItemIndex >= Outfitter_cMaxDisplayedItems then
		return vItemIndex, vFirstItemIndex;
	end

	if not Outfitter.Collapsed[pCategoryID] then
		for vIndex, vOutfitItem in ipairs(pOutfitItems) do
			if vFirstItemIndex == 0 then
				OutfitterItem_SetToItem(vItemIndex, vOutfitItem);
				vItemIndex = vItemIndex + 1;
				
				if vItemIndex >= Outfitter_cMaxDisplayedItems then
					return vItemIndex, vFirstItemIndex;
				end
			else
				vFirstItemIndex = vFirstItemIndex - 1;
			end
		end
	end
	
	return vItemIndex, vFirstItemIndex;
end

function Outfitter_SortOutfits()
	debugmessage("Outfitter_SortOutfits",1);
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		table.sort(vOutfits, Outfiter_CompareOutfitNames);
	end
end

function Outfiter_CompareOutfitNames(pOutfit1, pOutfit2)
	debugmessage("Outfiter_CompareOutfitNames",1);
	return pOutfit1.Name < pOutfit2.Name;
end

function Outfitter_Update(pUpdateSlotEnables)
	if not OutfitterFrame:IsVisible() then
		return;
	end
	debugmessage("Update",1);
	
	if Outfitter.CurrentPanel == 1 then
		-- Main panel
		
		if not Outfitter.DisplayIsDirty then
			return;
		end
		
		Outfitter.DisplayIsDirty = false;
		
		-- Sort the outfits
		
		Outfitter_SortOutfits();
		
		-- Get the equippable items so outfits can be marked if they're missing anything
		
		local	vEquippableItems = OutfitterItemList_GetEquippableItems();
		
		-- Update the slot enables if they're shown
		
		if pUpdateSlotEnables
		and OutfitterSlotEnables:IsVisible() then
			Outfitter_UpdateSlotEnables(Outfitter.SelectedOutfit, vEquippableItems);
		end
		
		OutfitterItemList_CompiledUnusedItemsList(vEquippableItems);
		
		-- Update the list
		
		OutfitterMainFrameHighlight:Hide();

		--- This sets the Correct List Menu.

		local	vFirstItemIndex = FauxScrollFrame_GetOffset(OutfitterMainFrameScrollFrame);
		local	vItemIndex = 0;
		
		OutfitterItemList_ResetIgnoreItemFlags(vEquippableItems);
		
		for vCategoryIndex, vCategoryID in ipairs(gOutfitter_cCategoryOrder) do
			--MCDebugLib:ErrorMessage("Outfitter - Building List: "..vCategoryID);
			debugmessage("Building List for "..vCategoryID,1);
			vItemIndex, vFirstItemIndex = Outfitter_AddOutfitsToList(gOutfitter_Settings.Outfits, vCategoryID, vItemIndex, vFirstItemIndex, vEquippableItems);

			if vItemIndex >= Outfitter_cMaxDisplayedItems then
				break;
			end
		end
		
		if vItemIndex < Outfitter_cMaxDisplayedItems
		and vEquippableItems.UnusedItems then
			debugmessage("Odds N Ends",1);
			vItemIndex, vFirstItemIndex = Outfitter_AddOutfitItemsToList(vEquippableItems.UnusedItems, "OddsNEnds", vItemIndex, vFirstItemIndex);
		end
		
		-- Hide any unused items
		
		for vItemIndex2 = vItemIndex, (Outfitter_cMaxDisplayedItems - 1) do
			local	vItemName = "OutfitterItem"..vItemIndex2;
			local	vItem = getglobal(vItemName);
			
			vItem:Hide();
		end
		
		local	vTotalNumItems = 0;
		
		for vCategoryIndex, vCategoryID in ipairs(gOutfitter_cCategoryOrder) do
			vTotalNumItems = vTotalNumItems + 1;
			
			local	vOutfits = gOutfitter_Settings.Outfits[vCategoryID];
			
			if not Outfitter.Collapsed[vCategoryID]
			and vOutfits then
				vTotalNumItems = vTotalNumItems + #vOutfits;
			end
		end
		
		if vEquippableItems.UnusedItems then
			vTotalNumItems = vTotalNumItems + 1;
			
			if not Outfitter.Collapsed["OddsNEnds"] then
				vTotalNumItems = vTotalNumItems + #vEquippableItems.UnusedItems;
			end
		end
		
		FauxScrollFrame_Update(
				OutfitterMainFrameScrollFrame,
				vTotalNumItems,                 -- numItems
				Outfitter_cMaxDisplayedItems,   -- numToDisplay
				18,                             -- valueStep
				nil, nil, nil,                  -- button, smallWidth, bigWidth
				nil,                            -- highlightFrame
				0, 0);                          -- smallHighlightWidth, bigHighlightWidth

	elseif Outfitter.CurrentPanel == 2 then -- Options panel
		OutfitterAutoSwitch:SetChecked(not gOutfitter_Settings.Options.DisableAutoSwitch);
		OutfitterShowMinimapButton:SetChecked(not gOutfitter_Settings.Options.HideMinimapButton);
		OutfitterTooltipInfo:SetChecked(not gOutfitter_Settings.Options.DisableToolTipInfo);
		OutfitterDebug:SetChecked(gOutfitter_Settings.Options.Debug);
		OutfitterShowHotkeyMessages:SetChecked(not gOutfitter_Settings.Options.DisableHotkeyMessages);

		-- OutfitterRememberVisibility:SetChecked(not gOutfitter_Settings.Options.DisableAutoVisibility);
	end
end

function Outfitter_OnVerticalScroll()
	debugmessage("Outfitter_OnVerticalScroll",1);
	Outfitter.DisplayIsDirty = true;
	Outfitter_Update(false);
end

function Outfitter_SelectOutfit(pOutfit, pCategoryID)
	debugmessage("Outfitter_SelectOutfit",1);
	if not Outfitter_IsOpen() then
		return;
	end
	
	Outfitter.SelectedOutfit = pOutfit;
	
	-- Get the equippable items so outfits can be marked if they're missing anything
	
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	
	-- Update the slot enables
	
	Outfitter_UpdateSlotEnables(pOutfit, vEquippableItems);
	OutfitterSlotEnables:Show();
	
	-- Done, rebuild the list
	
	Outfitter.DisplayIsDirty = true;
end

function Outfitter_UpdateSlotEnables(pOutfit, pEquippableItems)
	debugmessage("Outfitter_UpdateSlotEnables",1);
	if UnitHasRelicSlot("player") then
		OutfitterEnableAmmoSlot:Hide();
	else
		OutfitterEnableAmmoSlot:Show();
	end
	
	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do

		local	vOutfitItem = pOutfit.Items[vInventorySlot];
		local	vCheckbox = getglobal("OutfitterEnable"..vInventorySlot);
		
		if not vOutfitItem then
			vCheckbox:SetChecked(false);
		else
			if OutfitterItemList_InventorySlotContainsItem(pEquippableItems, vInventorySlot, vOutfitItem) then
				vCheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
				vCheckbox.IsUnknown = false;
			else
				vCheckbox:SetCheckedTexture("Interface\\Addons\\Outfitter\\Textures\\CheckboxUnknown");
				vCheckbox.IsUnknown = true;
			end
			
			vCheckbox:SetChecked(true);
		end
	end
end

function Outfitter_ClearSelection()
	debugmessage("Outfitter_ClearSelection",1);
	Outfitter.SelectedOutfit = nil;
	Outfitter.DisplayIsDirty = true;
	OutfitterSlotEnables:Hide();
end

function Outfitter_FindOutfitItemIndex(pOutfit)
	debugmessage("Outfitter_FindOutfitItemIndex",1);
	local	vOutfitCategoryID, vOutfitIndex = Outfitter_FindOutfit(pOutfit);
	
	if not vOutfitCategoryID then
		return nil;
	end
	
	local	vItemIndex = 0;
	
	for vCategoryIndex, vCategoryID in ipairs(gOutfitter_cCategoryOrder) do
		vItemIndex = vItemIndex + 1;
		
		if not Outfitter.Collapsed[vCategoryID] then
			if vOutfitCategoryID == vCategoryID then
				return vItemIndex + vOutfitIndex - 1;
			else
				vItemIndex = vItemIndex + #gOutfitter_Settings.Outfits[vCategoryID];
			end
		end
	end
	
	return nil;
end

function OutfitterStack_FindOutfit(pOutfit)
	debugmessage("OutfitterStack_FindOutfit",1);
	for vIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		if vOutfit == pOutfit then
			return true, vIndex;
		end
	end
	
	return false, nil;
end

function OutfitterStack_FindOutfitByCategory(pCategoryID)
	debugmessage("OutfitterStack_FindOutfitByCategory",1);
	for vIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		if vOutfit.CategoryID == pCategoryID then
			return true, vIndex;
		end
	end
	
	return false, nil;
end

function OutfitterStack_Clear()
	debugmessage("OutfitterStack_Clear",1);
	for vIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		Outfitter_DispatchOutfitEvent("UNWEAR_OUTFIT", vOutfit.Name, vOutfit)
	end
	
	Outfitter.OutfitStack = {};
	gOutfitter_Settings.LastOutfitStack = {};
	Outfitter.DisplayIsDirty = true;
	
	if gOutfitter_Settings.Options.ShowStackContents then
		MCDebugLib:debugmessage("Outfitter stack cleared");
	end
end

function OutfitterStack_ClearCategory(pCategoryID)
	debugmessage("OutfitterStack_ClearCategory",1);
	local	vIndex = 1;
	local	vStackLength = #Outfitter.OutfitStack;
	local	vChanged = false;
	
	while vIndex <= vStackLength do
		local	vOutfit = Outfitter.OutfitStack[vIndex];
		
		if vOutfit
		and vOutfit.CategoryID == pCategoryID then
			Outfitter_DispatchOutfitEvent("UNWEAR_OUTFIT", vOutfit.Name, vOutfit)
			
			table.remove(Outfitter.OutfitStack, vIndex);
			table.remove(gOutfitter_Settings.LastOutfitStack, vIndex);
			
			vStackLength = vStackLength - 1;
			vChanged = true;
		else
			vIndex = vIndex + 1;
		end
	end
	
	OutfitterStack_CollapseTemporaryOutfits();
	
	if vChanged then
		if gOutfitter_Settings.Options.ShowStackContents then
			OutfitterStack_DumpStackContents("Clear category "..pCategoryID);
		end
		
		Outfitter.DisplayIsDirty = true;
	end
end

function OutfitterStack_GetTemporaryOutfit()
	debugmessage("OutfitterStack_GetTemporaryOutfit",1);
	local	vStackSize = #Outfitter.OutfitStack;
	
	if vStackSize == 0 then
		return nil;
	end
	
	local	vOutfit = Outfitter.OutfitStack[vStackSize];
	
	if vOutfit.Name then
		return nil;
	end
	
	return vOutfit;
end

function OutfitterStack_CollapseTemporaryOutfits()
	debugmessage("OutfitterStack_CollapseTemporaryOutfits",1);
	local	vIndex = 1;
	local	vStackLength = #Outfitter.OutfitStack;
	local	vTemporaryOutfit1 = nil;
	
	while vIndex <= vStackLength do
		local	vOutfit = Outfitter.OutfitStack[vIndex];
		
		if vOutfit
		and vOutfit.Name == nil then
			if vTemporaryOutfit1 then
				-- Copy the items up
				
				for vInventorySlot, vItem in pairs(vTemporaryOutfit1.Items) do
					if not vOutfit.Items[vInventorySlot] then
						vOutfit.Items[vInventorySlot] = vItem;
					end
				end
				
				-- Remove the lower temp outfit
				
				table.remove(Outfitter.OutfitStack, vIndex - 1);
				vStackLength = vStackLength - 1;
			else
				vIndex = vIndex + 1;
			end
			
			vTemporaryOutfit1 = vOutfit;
		else
			vTemporaryOutfit1 = nil;
			vIndex = vIndex + 1;
		end
	end
end

function OutfitterStack_IsTopmostOutfit(pOutfit)
	debugmessage("OutfitterStack_IsTopmostOutfit",1);
	local	vStackLength = #Outfitter.OutfitStack;
	
	if vStackLength == 0 then
		return false;
	end
	
	return Outfitter.OutfitStack[vStackLength] == pOutfit;
end

function OutfitterStack_AddOutfit(pOutfit, pBelowOutfit)
	debugmessage("OutfitterStack_AddOutfit",1);
	local	vFound, vIndex = OutfitterStack_FindOutfit(pOutfit);
	
	-- If it's already on then remove it from the stack
	-- so it can be added to the end
	
	if vFound then
		table.remove(Outfitter.OutfitStack, vIndex);
		table.remove(gOutfitter_Settings.LastOutfitStack, vIndex);
		Outfitter_DispatchOutfitEvent("UNWEAR_OUTFIT", pOutfit.Name, pOutfit);
	end
	
	-- Figure out the position to insert at
	
	local	vStackLength = #Outfitter.OutfitStack;
	local	vInsertIndex = vStackLength + 1;
	
	if pBelowOutfit then
		local	vFound2, vIndex = OutfitterStack_FindOutfit(pBelowOutfit);
		
		if vFound2 then
			vInsertIndex = vIndex;
		end
	end
	
	--[[ Always insert below the temporary outfit
	
	local	vTemporaryOutfit;
	
	if vStackLength > 0 then
		vTemporaryOutfit = Outfitter.OutfitStack[vStackLength];
	end
	
	if vTemporaryOutfit and vTemporaryOutfit.Name == nil then
		-- Knock out any slots used by the new outfit if it's being inserted at the top
		
		if vInsertIndex >= vStackLength then
			for vInventorySlot, vItem in pairs(pOutfit.Items) do
				vTemporaryOutfit.Items[vInventorySlot] = nil;
			end
			
			-- Remove the temporary outfit if it's empty now
			
			if Outfitter_IsEmptyOutfit(vTemporaryOutfit) then
				table.remove(Outfitter.OutfitStack, vStackLength);
				table.remove(gOutfitter_Settings.LastOutfitStack, vStackLength);
				
				vInsertIndex = vStackLength;
				vStackLength = vStackLength - 1;
			else
				vInsertIndex = vStackLength;
			end
		end
	end
	
	]]--
	
	-- Add the outfit
	
	table.insert(Outfitter.OutfitStack, vInsertIndex, pOutfit);
	
	if pOutfit.Name then
		table.insert(gOutfitter_Settings.LastOutfitStack, vInsertIndex, {Name = pOutfit.Name});
	else
		table.insert(gOutfitter_Settings.LastOutfitStack, vInsertIndex, pOutfit);
	end
	
	Outfitter.DisplayIsDirty = true;
	
	if gOutfitter_Settings.Options.ShowStackContents then
		OutfitterStack_DumpStackContents("Add outfit");
	end
	
	if vFound then
		OutfitterStack_CollapseTemporaryOutfits();
	end
	
	Outfitter_DispatchOutfitEvent("WEAR_OUTFIT", pOutfit.Name, pOutfit);
end

function OutfitterStack_RemoveOutfit(pOutfit)
	debugmessage("OutfitterStack_RemoveOutfit",1);
	local	vFound, vIndex = OutfitterStack_FindOutfit(pOutfit);
	
	if not vFound then
		return false;
	end
	
	-- Remove the outfit
	
	table.remove(Outfitter.OutfitStack, vIndex);
	table.remove(gOutfitter_Settings.LastOutfitStack, vIndex);
	
	OutfitterStack_CollapseTemporaryOutfits();
	
	Outfitter.DisplayIsDirty = true;
	
	if gOutfitter_Settings.Options.ShowStackContents then
		OutfitterStack_DumpStackContents("Remove outfit");
	end
	
	return true;
end

function OutfitterStack_RestoreSavedStack()
	debugmessage("OutfitterStack_RestoreSavedStack",1);
	if not gOutfitter_Settings.LastOutfitStack then
		gOutfitter_Settings.LastOutfitStack = {};
	end
	
	for vIndex, vOutfit in ipairs(gOutfitter_Settings.LastOutfitStack) do
		if vOutfit.Name then
			vOutfit = Outfitter_FindOutfitByName(vOutfit.Name);
		end
		
		if vOutfit then
			table.insert(Outfitter.OutfitStack, vOutfit);
		end
	end
	
	Outfitter.ExpectedOutfit = Outfitter_GetCompiledOutfit();
	
	Outfitter_UpdateTemporaryOutfit(Outfitter_GetNewItemsOutfit(Outfitter.ExpectedOutfit));
	
	if gOutfitter_Settings.Options.ShowStackContents then
		OutfitterStack_DumpStackContents("Restore saved stack");
	end
end

function OutfitterStack_DumpStackContents(pOperation)
	debugmessage("OutfitterStack_DumpStackContents: "..pOperation,1);
	MCDebugLib:debugmessage("Outfitter Stack Contents: "..pOperation);
	
	for vIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		if vOutfit.Name then
			MCDebugLib:debugmessage("Slot "..vIndex..": "..vOutfit.Name);
		else
			MCDebugLib:debugmessage("Slot "..vIndex..": Temporaray outfit");
		end
	end
end

function Outfitter_WearOutfit(pOutfit, pCategoryID, pWearBelowOutfit)
	debugmessage("Outfitter_WearOutfit",1);

	if pOutfit.Disabled then
		return;
	end

	if not pCategoryID then
		pCategoryID = Outfitter_GetOutfitCategoryID(pOutfit);
	end

	Outfitter_BeginEquipmentUpdate();
	
	if pCategoryID == "Complete" then
		OutfitterStack_Clear();
	elseif pCategoryID == "Partial" then
		OutfitterStack_ClearCategory(pCategoryID);
		OutfitterStack_ClearCategory("Accessory");
	end
	
	OutfitterStack_AddOutfit(pOutfit, pWearBelowOutfit);
	
	-- If outfitter is open then also select the outfit
	
	if Outfitter_IsOpen() then
		if OutfitterStack_IsTopmostOutfit(pOutfit) then
			Outfitter_SelectOutfit(pOutfit, pCategoryID);
		else
			Outfitter_ClearSelection();
		end
	end

	-- Select slot priority

--	if not pOutfit.Enabled then -- ignore this outfit
-- modified by jtbalogh

--	else
		if pOutfit.Enabled then
			if OutfitterStack_IsTopmostOutfit(pOutfit) then
				--if Outfitter.PriorityLayerLevel[1] == pOutfit then -- ignore duplicate
				--else
				if not Outfitter.PriorityLayerLevel[1] == pOutfit then -- ignore duplicate
						-- push, shift (save recent layer)
					for n = PriorityLayerLevelMax, 2, -1 do
						Outfitter.PriorityLayerLevel[n] = Outfitter.PriorityLayerLevel[n-1]
					end
					Outfitter.PriorityLayerLevel[1] = pOutfit
	
					--Outfitter.PriorityLayerLevel[9] = Outfitter.PriorityLayerLevel[8]
					--Outfitter.PriorityLayerLevel[8] = Outfitter.PriorityLayerLevel[7]
					--Outfitter.PriorityLayerLevel[7] = Outfitter.PriorityLayerLevel[6]
					--Outfitter.PriorityLayerLevel[6] = Outfitter.PriorityLayerLevel[5]
					--Outfitter.PriorityLayerLevel[5] = Outfitter.PriorityLayerLevel[4]
					--Outfitter.PriorityLayerLevel[4] = Outfitter.PriorityLayerLevel[3]
					--Outfitter.PriorityLayerLevel[3] = Outfitter.PriorityLayerLevel[2]
					--Outfitter.PriorityLayerLevel[2] = Outfitter.PriorityLayerLevel[1]
					--Outfitter.PriorityLayerLevel[1] = pOutfit
					-- (no longer implemented, alternative)
				end

			else
				if Outfitter.PriorityLayerLevel[1] == pOutfit then -- ignore duplicate
					-- pull, shift (remove recent layer)
					for n = 1, PriorityLayerLevelMax-1, 1 do
						Outfitter.PriorityLayerLevel[n] = Outfitter.PriorityLayerLevel[n+1]
					end
					Outfitter.PriorityLayerLevel[9] = nil	
				end
			end

			-- pull at layer, shift (remove layer in middle)
			local layerlevel = 0
			if Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[2] then
				layerlevel = 2
			elseif Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[3] then
				layerlevel = 3
			elseif Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[4] then
				layerlevel = 4
			elseif Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[5] then
				layerlevel = 5
			elseif Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[6] then
				layerlevel = 6
			elseif Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[7] then
				layerlevel = 7
			elseif Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[8] then
				layerlevel = 8
			elseif Outfitter.PriorityLayerLevel[1] == Outfitter.PriorityLayerLevel[9] then
				layerlevel = 9
			end
			if layerlevel > 0 then
				for n = layerlevel, PriorityLayerLevelMax-1, 1 do
					Outfitter.PriorityLayerLevel[n] = Outfitter.PriorityLayerLevel[n+1]
				end
				Outfitter.PriorityLayerLevel[9] = nil
			end
	
			if gOutfitter_Settings.Options.Debug then
				local temp1 = ""
				if Outfitter.PriorityLayerLevel[1] then
					temp1 = "Layer 1:" ..Outfitter.PriorityLayerLevel[1].Name
				end
				if Outfitter.PriorityLayerLevel[2] then
					temp1 = temp1 ..", " .."2:" ..Outfitter.PriorityLayerLevel[2].Name
				end
				if Outfitter.PriorityLayerLevel[3] then
					temp1 = temp1 ..", " .."3:" ..Outfitter.PriorityLayerLevel[3].Name
				end
				if Outfitter.PriorityLayerLevel[4] then
					temp1 = temp1 ..", " .."4:" ..Outfitter.PriorityLayerLevel[4].Name
				end
				if strlen(temp1) == 0 then
					DEFAULT_CHAT_FRAME:AddMessage("no layer")
				else
					DEFAULT_CHAT_FRAME:AddMessage(temp1)
				end
			end
	end -- pOutfit.Enabled
	
	-- Update the equipment
	
	Outfitter.EquippedNeedsUpdate = true;
	Outfitter.WeaponsNeedUpdate = true;
	
	Outfitter_EndEquipmentUpdate("Outfitter_WearOutfit");

	-- Update priority if visible
	-- modified by jtbalogh
	--if OutfitterEnableListbox and OutfitterEnableListbox:IsVisible() then
	--	OutfitterEnableListbox:Hide()
	--	OutfitterEnableListbox:Show()
	--end

	if pOutfit.Enabled and Outfitter_Arrange_ListBox and Outfitter_Arrange_ListBox:IsVisible() then
		Outfitter_Arrange_ListBox:Hide()
		Outfitter_Arrange_ListBox:Show()
	end
end

function Outfitter_CheckHelmAndCloak()
	debugmessage("Outfitter_CheckHelmAndCloak",1);
	local	gDisplayCloak = -1;
	local	gDisplayHelm = -1;
	
	-- Step through the Applied Outfits and check their Settings.
	for vIndex, vOutfit in ipairs(Outfitter.OutfitStack) do

		-- Do we have a head slot?
		--if vOutfit.Items.HeadSlot then
				-- Show/Hide the Helm		
				if vOutfit.ShowHelm ~= nil and
					vOutfit.ShowHelm == true then
					gDisplayHelm = 1;
				elseif vOutfit.HideHelm ~= nil and 
					vOutfit.HideHelm == true then
					gDisplayHelm = 2;
				end 
				
		--end --vOutfit.Items.HeadSlot

		-- Do we have a back item in this setting?
		--if vOutfit.Items.BackSlot then

			-- Show/Hide the Cloak
				if vOutfit.ShowCloak ~= nil and
				 vOutfit.ShowCloak == true then
					gDisplayCloak = 1;
				elseif vOutfit.HideCloak ~= nil and
					vOutfit.HideCloak == true then
					gDisplayCloak = 2;
				end

		--end -- vOutfit.Items.BackSlot
		
		--MCDebugLib:ErrorMessage("Outfitter: We do not have a Cloakslot");
	end -- for
	
		-- Set the Helm based on the result
	if gDisplayHelm == 1 then
		debugmessage("Outfitter: Showing Helm",3);
		ShowHelm(1);
	elseif gDisplayHelm == 2 then
		debugmessage("Outfitter: Hiding Helm",3);
		ShowHelm(0);
	else
		debugmessage("Outfitter: Helm "..gDisplayHelm,3);		
	end

	-- Set the Helm based on the result
	if gDisplayCloak == 1 then
		debugmessage("Outfitter: Showing Cloak",3);
		ShowCloak(1);
	elseif gDisplayCloak == 2 then
		debugmessage("Outfitter: Hiding Cloak",3);
		ShowCloak(0);
	else
		debugmessage("Outfitter: Cloak "..gDisplayCloak,3);		
	end

end

function Outfitter_SetOutfitBindingIndex(pOutfit, pBindingIndex)
	debugmessage("Outfitter_SetOutfitBindingIndex",1);
	if pBindingIndex then
		for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
			for vOutfitIndex, vOutfit in ipairs(vOutfits) do
				if vOutfit.BindingIndex == pBindingIndex then
					vOutfit.BindingIndex = nil;
				end
			end
		end
	end
	
	pOutfit.BindingIndex = pBindingIndex;
end

local	gOutfitter_LastBindingIndex = nil;
local	gOutfitter_LastBindingTime = nil;
local	Outfitter_cMinBindingTime = 0.75;

function Outfitter_WearBoundOutfit(pBindingIndex)
	debugmessage("Outfitter_WearBoundOutfit",1);

	-- Check for the user spamming the button so prevent the outfit from
	-- toggling if they're panicking
	
	local	vTime = GetTime();
	
	if gOutfitter_LastBindingIndex == pBindingIndex then
		local	vElapsed = vTime - gOutfitter_LastBindingTime;
		
		if vElapsed < Outfitter_cMinBindingTime then
			gOutfitter_LastBindingTime = vTime;
			return;
		end
	end
	
	--
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit.BindingIndex == pBindingIndex then
				vOutfit.Disabled = nil;
				if vCategoryID == "Complete" then
					Outfitter_WearOutfit(vOutfit, vCategoryID);
					if not gOutfitter_Settings.Options.DisableHotkeyMessages then
						UIErrorsFrame:AddMessage(format(Outfitter_cEquipOutfitMessageFormat, vOutfit.Name), OUTFIT_MESSAGE_COLOR.r, OUTFIT_MESSAGE_COLOR.g, OUTFIT_MESSAGE_COLOR.b);
					end
				else
					local	vEquipped = Outfitter_ToggleOutfit(vOutfit, vCategoryID);
					
					if not gOutfitter_Settings.Options.DisableHotkeyMessages then
						if vEquipped then
							UIErrorsFrame:AddMessage(format(Outfitter_cEquipOutfitMessageFormat, vOutfit.Name), OUTFIT_MESSAGE_COLOR.r, OUTFIT_MESSAGE_COLOR.g, OUTFIT_MESSAGE_COLOR.b);
						else
							UIErrorsFrame:AddMessage(format(Outfitter_cUnequipOutfitMessageFormat, vOutfit.Name), OUTFIT_MESSAGE_COLOR.r, OUTFIT_MESSAGE_COLOR.g, OUTFIT_MESSAGE_COLOR.b);
						end
					end

				end
				
				-- Remember the binding used to filter for button spam
				
				gOutfitter_LastBindingIndex = pBindingIndex;
				gOutfitter_LastBindingTime = vTime;
				
				return;
			end
		end
	end
end

function Outfitter_FindOutfit(pOutfit)
	debugmessage("Outfitter_FindOutfit",1);
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit == pOutfit then
				return vCategoryID, vOutfitIndex;
			end
		end
	end
	
	return nil, nil;
end

function Outfitter_FindOutfitByName(pName)
	if not pName
	or pName == "" then
		return nil;
	end
	debugmessage("Outfitter_FindOutfitByName: "..pName,1);
	
	local	vLowerName = strlower(pName);
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if strlower(vOutfit.Name) == vLowerName then
				return vOutfit, vCategoryID, vOutfitIndex;
			end
		end
	end
	
	return nil, nil;
end

function Outfitter_GetOutfitCategoryID(pOutfit)
	debugmessage("Outfitter_GetOutfitCategoryID",1);
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit == pOutfit then
				return vCategoryID, vOutfitIndex;
			end
		end
	end
end

-- Outfitter doesn't use this function, but other addons such as
-- Fishing Buddy might use it to locate specific generated outfits

function Outfitter_FindOutfitByStatID(pStatID)
	if not pStatID or pStatID == "" then
		return nil;
	end
	debugmessage("Outfitter_FindOutfitByStatID",1);

	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if vOutfit.StatID and vOutfit.StatID == pStatID then
				return vOutfit, vCategoryID, vOutfitIndex;
			end
		end
	end
	
	return nil;
end

function Outfitter_RemoveOutfit(pOutfit)
	debugmessage("Outfitter_RemoveOutfit",1);
	if not OutfitterStack_RemoveOutfit(pOutfit) then
		debugmessage("Not OutfitterStack_RemoveOutfit Exiting",2);
		return;
	end
	
	-- Stop monitoring health and mana if it's the dining outfit
	
	if pOutfit.SpecialID == "Dining" then
		Outfitter_SuspendEvent(OutfitterFrame, "UNIT_HEALTH");
		--Outfitter_SuspendEvent(OutfitterFrame, "UNIT_MANA");
		OUTFIT_InDining = false;
	end
	
	--
	
	Outfitter_BeginEquipmentUpdate();
	
	-- Clear the selection if the outfit being removed
	-- is selected too
	
	if Outfitter.SelectedOutfit == pOutfit then
		Outfitter_ClearSelection();
	end

	-- Check slot priority
	-- pull at layer, shift (remove layer)
	local layerlevel = 0
	if pOutfit == Outfitter.PriorityLayerLevel[1] then
		layerlevel = 1
	elseif pOutfit == Outfitter.PriorityLayerLevel[2] then
		layerlevel = 2
	elseif pOutfit == Outfitter.PriorityLayerLevel[3] then
		layerlevel = 3
	elseif pOutfit == Outfitter.PriorityLayerLevel[4] then
		layerlevel = 4
	elseif pOutfit == Outfitter.PriorityLayerLevel[5] then
		layerlevel = 5
	elseif pOutfit == Outfitter.PriorityLayerLevel[6] then
		layerlevel = 6
	elseif pOutfit == Outfitter.PriorityLayerLevel[7] then
		layerlevel = 7
	elseif pOutfit == Outfitter.PriorityLayerLevel[8] then
		layerlevel = 8
	elseif pOutfit == Outfitter.PriorityLayerLevel[9] then
		layerlevel = 9
	else
		-- ignore unknown outfit
		-- or, unwear again but outfit already unequipped (sometimes again when scripts also unequip)
	end
	if layerlevel > 0 then
		for n = layerlevel, PriorityLayerLevelMax-1, 1 do
			Outfitter.PriorityLayerLevel[n] = Outfitter.PriorityLayerLevel[n+1]
		end
		Outfitter.PriorityLayerLevel[9] = nil
	end

	if gOutfitter_Settings.Options.Debug then
		local temp1 = ""
		if Outfitter.PriorityLayerLevel[1] then
			temp1 = "Layer 1:" ..Outfitter.PriorityLayerLevel[1].Name
		end
		if Outfitter.PriorityLayerLevel[2] then
			temp1 = temp1 ..", " .."2:" ..Outfitter.PriorityLayerLevel[2].Name
		end
		if Outfitter.PriorityLayerLevel[3] then
			temp1 = temp1 ..", " .."3:" ..Outfitter.PriorityLayerLevel[3].Name
		end
		if Outfitter.PriorityLayerLevel[4] then
			temp1 = temp1 ..", " .."4:" ..Outfitter.PriorityLayerLevel[4].Name
		end
		if strlen(temp1) == 0 then
			DEFAULT_CHAT_FRAME:AddMessage("no layer")
		else
			DEFAULT_CHAT_FRAME:AddMessage(temp1)
		end
	end
	
	-- Update the list
	
	Outfitter.EquippedNeedsUpdate = true;
	Outfitter.WeaponsNeedUpdate = true;
	
	Outfitter_EndEquipmentUpdate("Outfitter_RemoveOutfit");
	
	--debugmessage("throw Unwear_Outfit: "..pOutfit.Name,2);
	Outfitter_DispatchOutfitEvent("UNWEAR_OUTFIT", pOutfit.Name, pOutfit);
end

function Outfitter_ToggleOutfit(pOutfit, pCategoryID)
	debugmessage("Outfitter_ToggleOutfit",1);

	if Outfitter_WearingOutfit(pOutfit) then
		Outfitter_RemoveOutfit(pOutfit);
		return false;
	else
		Outfitter_WearOutfit(pOutfit, pCategoryID);
		return true;
	end
end

function Outfitter_GetPlayerStatDistribution()
	debugmessage("Outfitter_GetPlayerStatDistribution",1);
	local	_, vPlayerClass = UnitClass("player");
	local	vStatDistribution = gOutfitter_StatDistribution[vPlayerClass];
	
	return vStatDistribution;
end

local	gOutfitter_RatingStatDistribution;
local	gOutfitter_RatingStatDistributionLevel;

--[[
Level 61:

Defense: 1.5569620132446
Dodge: 12.455697059631
Parry: 20.759494781494
Block: 5.1898741722107
Melee Crit: 14.531646728516
Ranged Crit: 14.531646728516
]]--

function Outfitter_GetPlayerRatingStatDistribution()
	debugmessage("Outfitter_GetPlayerRatingStatDistribution",1);
	local	vLevel = UnitLevel("player");
	
	if gOutfitter_RatingStatDistribution
	and gOutfitter_RatingStatDistributionLevel == vLevel then
		return gOutfitter_RatingStatDistribution;
	end
	
	local	vLevelFactor = (vLevel - 1) / 69;
	
	local	vDodgeRating = 17.9 * vLevelFactor ^ 3.11 + 1;
	local	vWeaponSkillRating = 2.9 * vLevelFactor ^ 4.21 + 1;
	local	vMeleeHitRating = 14.8 * vLevelFactor ^ 3.18 + 1;
	local	vSpellHitRating = 11.6 * vLevelFactor ^ 3.23 + 1;
	local	vMeleeCritRating = 21.1 * vLevelFactor ^ 3.09 + 1;
	local	vSpellCritRating = 21.1 * vLevelFactor ^ 3.09 + 1;
	local	vMeleeHasteRating = 14.8 * vLevelFactor ^ 3.18 + 1;
	local	vSpellHasteRating = 14.8 * vLevelFactor ^ 3.18 + 1;
	local	vDefenseRating = 1.4 * vLevelFactor ^ 6.58 + 1;
	local	vParryRating = 30.5 * vLevelFactor ^ 3.02 + 1;
	local	vBlockRating = 6.9 * vLevelFactor ^ 3.48 + 1;
	local	vResilienceRating = 38.4 * vLevelFactor ^ 3.00 + 1;
	
	gOutfitter_RatingStatDistribution =
	{
		DodgeRating = {Dodge = {Coeff = 1 / vDodgeRating}};
		WeaponSkillRating = {WeaponSkill = {Coeff = 1 / vWeaponSkillRating}};
		MeleeHitRating = {MeleeHit = {Coeff = 1 / vMeleeHitRating}};
		SpellHitRating = {SpellHit = {Coeff = 1 / vSpellHitRating}};
		MeleeCritRating = {MeleeCrit = {Coeff = 1 / vMeleeCritRating}};
		SpellCritRating = {SpellCrit = {Coeff = 1 / vSpellCritRating}};
		MeleeHasteRating = {MeleeHaste = {Coeff = 1 / vMeleeHasteRating}};
		SpellHasteRating = {SpellHaste = {Coeff = 1 / vSpellHasteRating}};
		DefenseRating = {Defense = {Coeff = 1 / vDefenseRating}};
		ParryRating = {Parry = {Coeff = 1 / vParryRating}};
		BlockRating = {Block = {Coeff = 1 / vBlockRating}};
		ResilienceRating = {Resilience = {Coeff = 1 / vResilienceRating}};
	};
	
	return gOutfitter_RatingStatDistribution;
end
	
function Outfitter_OutfitSummary()
	debugmessage("Outfitter_OutfitSummary",1);
	local	vStatDistribution = Outfitter_GetPlayerStatDistribution();
	local	vCurrentOutfitStats = OutfitterTankPoints_GetCurrentOutfitStats(vStatDistribution);
	
	MCDebugLib:DumpArray("Current Stats", vCurrentOutfitStats);
end

function Outfitter_RatingSummary()
	debugmessage("Outfitter_RatingSummary",1);
	local	vRatingIDs =
	{
		"Weapon",
		"Defense",
		"Dodge",
		"Parry",
		"Block",
		"Melee Hit",
		"Ranged Hit",
		"Spell Hit",
		"Melee Crit",
		"Ranged Crit",
		"Spell Crit",
		"Melee Hit Taken",
		"Ranged Hit Taken",
		"Spell Hit Taken",
		"Melee Crit Taken",
		"Ranged Crit Taken",
		"Spell Crit Taken",
		"Melee Haste",
		"Ranged Haste",
		"Spell Haste",
	};
	
	for vRatingID, vRatingName in ipairs(vRatingIDs) do
		local	vRating = GetCombatRating(vRatingID);
		local	vRatingBonus = GetCombatRatingBonus(vRatingID);
		
		if vRatingBonus > 0 then
			MCDebugLib:NoteMessage(vRatingName..": "..(vRating / vRatingBonus));
		end
	end
end

function Outfitter_GetCompiledOutfit()
	debugmessage("Outfitter_GetCompiledOutfit",1);
	local	vCompiledOutfit = Outfitter_NewEmptyOutfit();
	
	vCompiledOutfit.SourceOutfit = {};
	
	for vStackIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
			vCompiledOutfit.Items[vInventorySlot] = vOutfitItem;
			vCompiledOutfit.SourceOutfit[vInventorySlot] = vOutfit.Name;
		end
	end
	
	return vCompiledOutfit;
end

function Outfitter_GetExpectedOutfit(pExcludeOutfit)
	debugmessage("Outfitter_GetExpectedOutfit",1);
	local	vCompiledOutfit = Outfitter_NewEmptyOutfit();
	
	vCompiledOutfit.SourceOutfit = {};
	
	for vStackIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		if vOutfit ~= pExcludeOutfit then
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				vCompiledOutfit.Items[vInventorySlot] = vOutfitItem;
				vCompiledOutfit.SourceOutfit[vInventorySlot] = vOutfit.Name;
			end
		end
	end
	
	return vCompiledOutfit;
end

function Outfitter_GetEmptyBagSlot(pStartBagIndex, pStartBagSlotIndex, pIncludeBank)
	debugmessage("Outfitter_GetEmptyBagSlot",1);
	local	vStartBagIndex = pStartBagIndex;
	local	vStartBagSlotIndex = pStartBagSlotIndex;
	
	if not vStartBagIndex then
		vStartBagIndex = NUM_BAG_SLOTS;
	end
	
	if not vStartBagSlotIndex then
		vStartBagSlotIndex = 1;
	end
	
	local	vEndBagIndex = 0;
	
	if pIncludeBank then
		vEndBagIndex = -1;
	end
	
	for vBagIndex = vStartBagIndex, vEndBagIndex, -1 do
		-- Skip the bag if it's a specialty bag (ammo pouch, quiver, shard bag)
		
		local	vSkipBag = false;
		
		if vBagIndex > 0 then -- Don't worry about the backpack
			local	vItemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(vBagIndex));
			local	vItemInfo = Outfitter_GetItemInfoFromLink(vItemLink);
			
			if vItemInfo
			and vItemInfo.SubType ~= Outfitter_cContainerBagSubType then
				vSkipBag = true;
			end
		end
		
		-- Search the bag for empty slots
		
		if not vSkipBag then
			local	vNumBagSlots = GetContainerNumSlots(vBagIndex);
			
			if vNumBagSlots > 0 then
				for vSlotIndex = vStartBagSlotIndex, vNumBagSlots do
					local	vItemInfo = Outfitter_GetBagItemInfo(vBagIndex, vSlotIndex);
					
					if not vItemInfo then
						return {BagIndex = vBagIndex, BagSlotIndex = vSlotIndex};
					end
				end
			end
		end
		
		vStartBagSlotIndex = 1;
	end
	
	return nil;
end

function Outfitter_GetEmptyEngineeringBagSlot()
	debugmessage("Outfitter_GetEmptyEngineeringBagSlot",1);
	local	vStartBagIndex = 4;
	local	vStartBagSlotIndex = 1;
	local vEndBagIndex = 0;
		
	for vBagIndex = vStartBagIndex, vEndBagIndex, -1 do
		local	vSkipBag = false;
		
		if vBagIndex > 0 then -- Don't worry about the backpack
			local	vItemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(vBagIndex));
			local	vItemInfo = Outfitter_GetItemInfoFromLink(vItemLink);
			
			if vItemInfo
			and vItemInfo.SubType ~= Outfitter_cContainerEngineeringBagSubType then
				vSkipBag = true;
			end
		end
		
		-- Search the bag for empty slots
		
		if not vSkipBag then
			local	vNumBagSlots = GetContainerNumSlots(vBagIndex);
			debugmessage("Outfitter_GetEmptyEngineeringBagSlot: Checking Bag Slots",3);

			
			if vNumBagSlots > 0 then
				for vSlotIndex = vStartBagSlotIndex, vNumBagSlots do
					local	vItemInfo = Outfitter_GetBagItemInfo(vBagIndex, vSlotIndex);
					
					if not vItemInfo then
						debugmessage("Outfitter_GetEmptyEngineeringBagSlot: Return Slot numbers",3);
						return {BagIndex = vBagIndex, BagSlotIndex = vSlotIndex};
					end
				end
			end
		end
		
		vStartBagSlotIndex = 1;
	end
	
	debugmessage("Outfitter_GetEmptyEngineeringBagSlot: Out we go.. Nothing found.",3);
	return nil;
end

function Outfitter_GetEmptyBagSlotList()
	debugmessage("Outfitter_GetEmptyBagSlotList",1);
	local	vEmptyBagSlots = {};
	
	local	vBagIndex = NUM_BAG_SLOTS;
	local	vBagSlotIndex = 1;
	
	while true do
		local	vBagSlotInfo = Outfitter_GetEmptyBagSlot(vBagIndex, vBagSlotIndex);
		
		if not vBagSlotInfo then
			return vEmptyBagSlots;
		end
		
		table.insert(vEmptyBagSlots, vBagSlotInfo);
		
		vBagIndex = vBagSlotInfo.BagIndex;
		vBagSlotIndex = vBagSlotInfo.BagSlotIndex + 1;
	end
end

function Outfitter_GetEmptyBankSlotList()
	debugmessage("Outfitter_GetEmptyBankSlotList",1);
	local	vEmptyBagSlots = {};
	
	local	vBagIndex = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
	local	vBagSlotIndex = 1;
	
	while true do
		local	vBagSlotInfo = Outfitter_GetEmptyBagSlot(vBagIndex, vBagSlotIndex, true);
		
		if not vBagSlotInfo then
			return vEmptyBagSlots;
		
		elseif vBagSlotInfo.BagIndex > NUM_BAG_SLOTS
		or vBagSlotInfo.BagIndex < 0 then
			table.insert(vEmptyBagSlots, vBagSlotInfo);
		end
		
		vBagIndex = vBagSlotInfo.BagIndex;
		vBagSlotIndex = vBagSlotInfo.BagSlotIndex + 1;
	end
end

function Outfitter_FindItemsInBagsForSlot(pSlotName)
	debugmessage("Outfitter_FindItemsInBagsForSlot",1);
	local	vInventorySlot = pSlotName;
	
	-- Alias the slot names down for finger and trinket
	
	if vInventorySlot == "Finger1Slot" then
		vInventorySlot = "Finger0Slot";
	elseif vInventorySlot == "Trinket1Slot" then
		vInventorySlot = "Trinket0Slot";
	end
	
	--
	
	local	vItems = {};
	local	vNumBags, vFirstBagIndex = Outfitter_GetNumBags();
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local	vNumBagSlots = GetContainerNumSlots(vBagIndex);
		
		if vNumBagSlots > 0 then
			for vSlotIndex = 1, vNumBagSlots do
				local	vItemInfo = Outfitter_GetBagItemInfo(vBagIndex, vSlotIndex);
				
				if vItemInfo then
					local	vItemSlotName = vItemInfo.ItemSlotName;
					
					if vItemInfo.MetaSlotName then
						vItemSlotName = vItemInfo.MetaSlotName;
					end
					
					if vItemSlotName == "TwoHandSlot" then
						vItemSlotName = "MainHandSlot";
					elseif vItemSlotName == "Weapon0Slot" then
						if vInventorySlot == "MainHandSlot"
						or vInventorySlot == "SecondaryHandSlot" then
							vItemSlotName = vInventorySlot;
						end
					end
					
					if vItemSlotName == vInventorySlot then
						table.insert(vItems, {BagIndex = vBagIndex, BagSlotIndex = vSlotIndex, Code = vItemInfo.Code, Name = vItemInfo.Name});
					end
				end
			end
		end
	end
	
	if #vItems == 0 then	
		return nil;
	end
	
	return vItems;
end

function Outfitter_PickupItemLocation(pItemLocation)
	debugmessage("Outfitter_PickupItemLocation",1);
	if pItemLocation == nil then
		MCDebugLib:ErrorMessage("Outfitter: nil location in PickupItemLocation");
		return;
	end
	
	if pItemLocation.BagIndex then
		if CT_oldPickupContainerItem then
			CT_oldPickupContainerItem(pItemLocation.BagIndex, pItemLocation.BagSlotIndex);
		else
			PickupContainerItem(pItemLocation.BagIndex, pItemLocation.BagSlotIndex);
		end
	elseif pItemLocation.SlotName then
		PickupInventoryItem(Outfitter_cSlotIDs[pItemLocation.SlotName]);
	else
		MCDebugLib:ErrorMessage("Outfitter: Unknown location in PickupItemLocation");
		return;
	end
end

function Outfitter_BuildUnequipChangeList(pOutfit, pEquippableItems)
	debugmessage("Outfitter_BuildUnequipChangeList",1);
	local	vEquipmentChangeList = {};

	for vInventorySlot, vOutfitItem in pairs(pOutfit.Items) do
		local	vItem, vIgnoredItem = OutfitterItemList_FindItemOrAlt(pEquippableItems, vOutfitItem, true);
		
		if vItem then
			table.insert(vEquipmentChangeList, {FromLocation = vItem.Location, Item = vItem, ToLocation = nil});
		end
	end -- for
	
	return vEquipmentChangeList;
end

function Outfitter_BuildEquipmentChangeList(pOutfit, pEquippableItems)
	debugmessage("Outfitter_BuildEquipmentChangeList",1);
	local	vEquipmentChangeList = {};
	
	OutfitterItemList_ResetIgnoreItemFlags(pEquippableItems);
	
	-- Remove items which are already in the correct slot from the outfit and from the
	-- equippable items list
	
	for vInventorySlot, vOutfitItem in pairs(pOutfit.Items) do
		local	vContainsItem, vItem = OutfitterItemList_InventorySlotContainsItem(pEquippableItems, vInventorySlot, vOutfitItem);
		
		if vContainsItem then
			pOutfit.Items[vInventorySlot] = nil;
			
			if vItem then
				vItem.IgnoreItem = true;
			end
		end
	end
	
	-- Scan the outfit using the Outfitter_cSlotNames array as an index so that changes
	-- are executed in the specified order
	
	local Outfitter_cSlotNamestemp = Outfitter_cSlotNames
	if not Outfitter.PriorityLayerLevel[1] then -- no outfit selected after login, or not available during login
	elseif not Outfitter.PriorityLayerLevel[1].SlotPriority then -- no listbox in layer
	else
		Outfitter_cSlotNamestemp = Outfitter.PriorityLayerLevel[1].SlotPriority
		-- listbox of latest outfit, assuming outfits are removed in the order they were put on
		-- (not yet implemented, use listbox in the layer after the outfit that was removed
	end
	for _, vInventorySlot in ipairs(Outfitter_cSlotNamestemp) do
		local	vOutfitItem = pOutfit.Items[vInventorySlot];
		
		if vOutfitItem then
			local	vSlotID = Outfitter_cSlotIDs[vInventorySlot];
			local	vCurrentItemInfo = Outfitter_GetInventoryItemInfo(vInventorySlot);
			
			-- Empty the slot if it's supposed to be blank
			
			if vOutfitItem.Code == 0 then
				if vCurrentItemInfo then
					table.insert(vEquipmentChangeList, {SlotName = vInventorySlot, SlotID = vSlotID, ItemName = vOutfitItem.Name, ItemLocation = nil});
				end

			else
				-- Find the item
				
				local	vItem, vIgnoredItem = OutfitterItemList_FindItemOrAlt(pEquippableItems, vOutfitItem, true);
				
				-- If the item wasn't found then show an appropriate error message
				
				if not vItem then
					if vOutfitItem.Name then
						if vIgnoredItem then
							local	vSlotDisplayName = Outfitter_cSlotDisplayNames[vInventorySlot];
							
							if not vSlotDisplayName then
								vSlotDisplayName = vInventorySlot;
							end
							
							MCDebugLib:ErrorMessage(format(Outfitter_cItemAlreadyUsedError, vOutfitItem.Name, vSlotDisplayName));
						else
							MCDebugLib:ErrorMessage(format(Outfitter_cItemNotFoundError, vOutfitItem.Name));
						end
					else
						MCDebugLib:ErrorMessage(format(Outfitter_cItemNotFoundError, "unknown"));
					end
				
				-- Generate a change to move the item from its present location to the correct slot
				
				else
					pOutfit.Items[vInventorySlot].MetaSlotName = vItem.MetaSlotName;
					table.insert(vEquipmentChangeList, {SlotName = vInventorySlot, SlotID = vSlotID, ItemName = vOutfitItem.Name, ItemMetaSlotName = vItem.MetaSlotName, ItemLocation = vItem});
				end
			end
		end -- if
	end -- for
	
	if #vEquipmentChangeList == 0 then
		return nil;
	end
	
	Outfitter_OptimizeEquipmentChangeList(vEquipmentChangeList);
	
	return vEquipmentChangeList;
end

function Outfitter_FindEquipmentChangeForSlot(pEquipmentChangeList, pSlotName)
	debugmessage("Outfitter_FindEquipmentChangeForSlot",1);
	for vChangeIndex, vEquipmentChange in ipairs(pEquipmentChangeList) do
		if vEquipmentChange.SlotName == pSlotName then
			return vChangeIndex, vEquipmentChange;
		end
	end
	
	return nil, nil;
end

function Outfitter_FixSlotSwapChange(pEquipmentList, pChangeIndex1, pEquipmentChange1, pSlotName1, pChangeIndex2, pEquipmentChange2, pSlotName2)
	debugmessage("Outfitter_FixSlotSwapChange",1);
	-- No problem if both slots will be emptied
	
	if not pEquipmentChange1.ItemLocation
	and not pEquipmentChange2.ItemLocation then
		return;
	end
	
	-- No problem if neither slot is being moved to the other one
	
	local	vSlot2ToSlot1 = pEquipmentChange1.ItemLocation ~= nil
			            and pEquipmentChange1.ItemLocation.SlotName == pSlotName2;
	
	local	vSlot1ToSlot2 = pEquipmentChange2.ItemLocation ~= nil
			            and pEquipmentChange2.ItemLocation.SlotName == pSlotName1;
	
	-- No problem if the slots are swapping with each other
	-- or not moving between each other at all
	
	if vSlot2ToSlot1 == vSlot1ToSlot2 then
		return;
	end
	
	-- Slot 1 is moving to slot 2
	
	if vSlot1ToSlot2 then
		
		if pEquipmentChange1.ItemLocation then
			-- Swap change 1 and change 2 around
			
			pEquipmentList[pChangeIndex1] = pEquipmentChange2;
			pEquipmentList[pChangeIndex2] = pEquipmentChange1;
			
			-- Insert a change to empty slot 2
			
			table.insert(pEquipmentList, pChangeIndex1, {SlotName = pEquipmentChange2.SlotName, SlotID = pEquipmentChange2.SlotID, ItemLocation = nil});
		else
			-- Slot 1 is going to be empty, so empty slot 2 instead
			-- and then when slot 1 is moved it'll swap the empty space
			
			pEquipmentChange1.SlotName = pSlotName2;
			pEquipmentChange1.SlotID = pEquipmentChange2.SlotID;
			pEquipmentChange1.ItemLocation = nil;
		end
		
	-- Slot 2 is moving to slot 1
	
	else
		if pEquipmentChange2.ItemLocation then
			-- Insert a change to empty slot 1 first
			
			table.insert(pEquipmentList, pChangeIndex1, {SlotName = pEquipmentChange1.SlotName, SlotID = pEquipmentChange1.SlotID, ItemLocation = nil});
		else
			-- Slot 2 is going to be empty, so empty slot 1 instead
			-- and then when slot 2 is moved it'll swap the empty space
			
			pEquipmentChange2.SlotName = pSlotName1;
			pEquipmentChange2.SlotID = pEquipmentChange1.SlotID;
			pEquipmentChange2.ItemLocation = nil;
			
			-- Change the order so that slot 1 gets emptied before the move
			
			pEquipmentList[pChangeIndex1] = pEquipmentChange2;
			pEquipmentList[pChangeIndex2] = pEquipmentChange1;
		end
	end
end

function Outfitter_OptimizeEquipmentChangeList(pEquipmentChangeList)
	debugmessage("Outfitter_OptimizeEquipmentChangeList",1);
	local	vSwapList =
	{
		{Slot1 = "Finger0Slot", Slot2 = "Finger1Slot"},
		{Slot1 = "Trinket0Slot", Slot2 = "Trinket1Slot"},
		{Slot1 = "MainHandSlot", Slot2 = "SecondaryHandSlot"},
	};
	
	local	vDidSlot = {};
	
	local	vChangeIndex = 1;
	local	vNumChanges = #pEquipmentChangeList;
	
	while vChangeIndex <= vNumChanges do
		local	vEquipmentChange = pEquipmentChangeList[vChangeIndex];
		
		-- If a two-hand weapon is being equipped, remove the change event
		-- for removing the offhand slot
		
		if vEquipmentChange.ItemMetaSlotName == "TwoHandSlot" then
			local	vChangeIndex2, vEquipmentChange2 = Outfitter_FindEquipmentChangeForSlot(pEquipmentChangeList, "SecondaryHandSlot");
			
			-- If there's a change for the offhand slot, remove it
			
			if vChangeIndex2 then
				table.remove(pEquipmentChangeList, vChangeIndex2);
				
				if vChangeIndex2 < vChangeIndex then
					vChangeIndex = vChangeIndex - 1;
				end
				
				vNumChanges = vNumChanges - 1;
			end
			
			-- Insert a new change for the offhand slot to empty it ahead
			-- of equipping the two-hand item
			
			local	vSlotID = Outfitter_cSlotIDs.SecondaryHandSlot;
			
			table.insert(pEquipmentChangeList, vChangeIndex, {SlotName = "SecondaryHandSlot", SlotID = vSlotID, ItemLocation = nil});
			
		-- Otherwise see if the change needs to be re-arranged so that slot
		-- swapping works correctly
		
		else
			for vSwapListIndex, vSwapSlotInfo in ipairs(vSwapList) do
				if vEquipmentChange.SlotName == vSwapSlotInfo.Slot1
				and not vDidSlot[vEquipmentChange.SlotName] then
					local	vChangeIndex2, vEquipmentChange2 = Outfitter_FindEquipmentChangeForSlot(pEquipmentChangeList, vSwapSlotInfo.Slot2);
					
					if vChangeIndex2 then
						Outfitter_FixSlotSwapChange(pEquipmentChangeList, vChangeIndex, vEquipmentChange, vSwapSlotInfo.Slot1, vChangeIndex2, vEquipmentChange2, vSwapSlotInfo.Slot2);
					end
					
					vDidSlot[vEquipmentChange.SlotName] = true;
					
					vNumChanges = #pEquipmentChangeList;
				end
			end
		end
		
		vChangeIndex = vChangeIndex + 1;
	end
end

function Outfitter_ExecuteEquipmentChangeList(pEquipmentChangeList, pEmptyBagSlots, pExpectedEquippableItems)
	debugmessage("Outfitter_ExecuteEquipmentChangeList",1);
	for vChangeIndex, vEquipmentChange in ipairs(pEquipmentChangeList) do
		if vEquipmentChange.ItemLocation then
			Outfitter_PickupItemLocation(vEquipmentChange.ItemLocation);
			EquipCursorItem(vEquipmentChange.SlotID);
			
			if pExpectedEquippableItems then
				OutfitterItemList_SwapLocationWithInventorySlot(pExpectedEquippableItems, vEquipmentChange.ItemLocation, vEquipmentChange.SlotName);
			end
		else
				-- Remove the item
				if OUTFIT_HasEngineeringBag and 1 == 2 then
					debugmessage("Outfitter_OptimizeEquipmentChangeList: True",4);
					PickupInventoryItem(vEquipmentChange.SlotID);
					
					local	vBagSlotInfo = Outfitter_GetEmptyEngineeringBagSlot();
					local	vBagIndex = vBagSlotInfo.BagIndex
					local vBagSlotIndex = vBagSlotInfo.BagSlotIndex;
					debugmessage("Outfitter_OptimizeEquipmentChangeList: "..vBagIndex.." "..vBagSlotIndex,4);
					
					if vBagIndex and vBagSlotIndex then
						debugmessage("Outfitter_OptimizeEquipmentChangeList: Get the Slot Placement",4);
						PickupContainerItem(vBagIndex, vBagSlotIndex);
				  
						if pExpectedEquippableItems then
							OutfitterItemList_SwapBagSlotWithInventorySlot(pExpectedEquippableItems, vBagIndex, vBagSlotIndex, vEquipmentChange.SlotName);
						end
					else
						if not pEmptyBagSlots
						or #pEmptyBagSlots == 0 then
							local	vItemInfo = Outfitter_GetInventoryItemInfo(vEquipmentChange.SlotName);
							
							if not vItemInfo then
								MCDebugLib:ErrorMessage("Outfitter internal error: Can't empty slot "..vEquipmentChange.SlotName.." because bags are full but slot is empty");
							else
								MCDebugLib:ErrorMessage(format(Outfitter_cBagsFullError, vItemInfo.Name));
							end
						else
							local	vBagIndex = pEmptyBagSlots[1].BagIndex;
							local	vBagSlotIndex = pEmptyBagSlots[1].BagSlotIndex;
							
							table.remove(pEmptyBagSlots, 1);
						
							if CT_oldPickupContainerItem then
								CT_oldPickupContainerItem(vBagIndex, vBagSlotIndex);
							else
								PickupContainerItem(vBagIndex, vBagSlotIndex);
							end
						
							if pExpectedEquippableItems then
								OutfitterItemList_SwapBagSlotWithInventorySlot(pExpectedEquippableItems, vBagIndex, vBagSlotIndex, vEquipmentChange.SlotName);
							end
						end
					end					
				else
					debugmessage("Outfitter_OptimizeEquipmentChangeList: False",4);
					PickupInventoryItem(vEquipmentChange.SlotID);
					if not pEmptyBagSlots
					or #pEmptyBagSlots == 0 then
						local	vItemInfo = Outfitter_GetInventoryItemInfo(vEquipmentChange.SlotName);
						
						if not vItemInfo then
							MCDebugLib:ErrorMessage("Outfitter internal error: Can't empty slot "..vEquipmentChange.SlotName.." because bags are full but slot is empty");
						else
							MCDebugLib:ErrorMessage(format(Outfitter_cBagsFullError, vItemInfo.Name));
						end
					else
						local	vBagIndex = pEmptyBagSlots[1].BagIndex;
						local	vBagSlotIndex = pEmptyBagSlots[1].BagSlotIndex;
						
						table.remove(pEmptyBagSlots, 1);
						
						if CT_oldPickupContainerItem then
							CT_oldPickupContainerItem(vBagIndex, vBagSlotIndex);
						else
							PickupContainerItem(vBagIndex, vBagSlotIndex);
						end
						
						if pExpectedEquippableItems then
							OutfitterItemList_SwapBagSlotWithInventorySlot(pExpectedEquippableItems, vBagIndex, vBagSlotIndex, vEquipmentChange.SlotName);
						end
					end -- pEmptyBagSlots
			end -- OUTFIT_HasEngineeringBag
		end -- vEquipmentChange.ItemLocation
	end -- for
end -- function

function Outfitter_ExecuteEquipmentChangeList2(pEquipmentChangeList, pEmptySlots, pBagsFullErrorFormat, pExpectedEquippableItems)
	debugmessage("Outfitter_ExecuteEquipmentChangeList2",1);
	for vChangeIndex, vEquipmentChange in ipairs(pEquipmentChangeList) do
		if vEquipmentChange.ToLocation then
			Outfitter_PickupItemLocation(vEquipmentChange.FromLocation);
			EquipCursorItem(vEquipmentChange.SlotID);
			
			if pExpectedEquippableItems then
				OutfitterItemList_SwapLocationWithInventorySlot(pExpectedEquippableItems, vEquipmentChange.ToLocation, vEquipmentChange.SlotName);
			end
		else
			-- Remove the item
			
			if OUTFIT_HasEngineeringBag and 1 == 2 then
				debugmessage("Outfitter_ExecuteEquipmentChangeList2: True",4);
				local	vBagSlotInfo = Outfitter_GetEmptyEngineeringBagSlot();
				debugmessage("Outfitter_ExecuteEquipmentChangeList2: "..vBagIndex.." "..vBagSlotIndex,4);

				if vBagSlotInfo.BagIndex and vBagSlotInfo.BagSlotIndex then
					local	vToLocation = {BagIndex = vBagSlotInfo.BagIndex, BagSlotIndex = vBagSlotInfo.BagSlotIndex};
					Outfitter_PickupItemLocation(vEquipmentChange.FromLocation);
					Outfitter_PickupItemLocation(vToLocation);

				else
					if not pEmptySlots
					or #pEmptySlots == 0 then
						MCDebugLib:ErrorMessage(format(pBagsFullErrorFormat, vEquipmentChange.Item.Name));
					else
						local	vToLocation = {BagIndex = pEmptySlots[1].BagIndex, BagSlotIndex = pEmptySlots[1].BagSlotIndex};
						
						table.remove(pEmptySlots, 1);
						
						Outfitter_PickupItemLocation(vEquipmentChange.FromLocation);
						Outfitter_PickupItemLocation(vToLocation);
						
						if pExpectedEquippableItems then
							OutfitterItemList_SwapLocations(pExpectedEquippableItems, vEquipmentChange.FromLocation, vToLocation);
						end
					end
				end

			else			
				if not pEmptySlots
				or #pEmptySlots == 0 then
					MCDebugLib:ErrorMessage(format(pBagsFullErrorFormat, vEquipmentChange.Item.Name));
				else
					local	vToLocation = {BagIndex = pEmptySlots[1].BagIndex, BagSlotIndex = pEmptySlots[1].BagSlotIndex};
					
					table.remove(pEmptySlots, 1);
					
					Outfitter_PickupItemLocation(vEquipmentChange.FromLocation);
					Outfitter_PickupItemLocation(vToLocation);
					
					if pExpectedEquippableItems then
						OutfitterItemList_SwapLocations(pExpectedEquippableItems, vEquipmentChange.FromLocation, vToLocation);
					end
				end
			end
		end
	end
end

function Outfitter_OutfitHasCombatEquipmentSlots(pOutfit)
	debugmessage("Outfitter_OutfitHasCombatEquipmentSlots",1);
	for vEquipmentSlot, _ in pairs(Outfitter_cCombatEquipmentSlots) do
		if pOutfit.Items[vEquipmentSlot] then
			return true;
		end
	end
	
	return false;
end

function Outfitter_OutfitOnlyHasCombatEquipmentSlots(pOutfit)
	debugmessage("Outfitter_OutfitOnlyHasCombatEquipmentSlots",1);
	for vEquipmentSlot, _ in pairs(pOutfit.Items) do
		if not Outfitter_cCombatEquipmentSlots[vEquipmentSlot] then
			return false;
		end
	end
	
	return true;
end

local	gOutfitter_EquipmentUpdateCount = 0;

function Outfitter_BeginEquipmentUpdate()
	debugmessage("Outfitter_BeginEquipmentUpdate",1);
	gOutfitter_EquipmentUpdateCount = gOutfitter_EquipmentUpdateCount + 1;
end

function Outfitter_EndEquipmentUpdate(pCallerName)
	debugmessage("Outfitter_EndEquipmentUpdate",1);

	gOutfitter_EquipmentUpdateCount = gOutfitter_EquipmentUpdateCount - 1;
	
	if gOutfitter_EquipmentUpdateCount == 0 then

		-- To help FIND schedule 			
		Outfitter_ScheduleEquipmentUpdate();
		Outfitter_Update(false);
	end

	-- Now set the correct Helm and Cloak settings.
	-- debugmessage("Outfitter: Calling Check Helm and Cloak",3);
	-- Outfitter_CheckHelmAndCloak();		

	-- Added For Debugging
	-- MCDebugLib:NoteMessage("Outfitter: Outfitter_EndEquipmentUpdate");
end

function Outfitter_UpdateEquippedItems()
	if Outfitter.Initialized then
		debugmessage("Update Equiped Items", 1);
	end

	if not Outfitter.EquippedNeedsUpdate
	and not Outfitter.WeaponsNeedUpdate then
		return;
	end
	
	-- Delay all changes until they're alive
	
	if Outfitter.IsDead then
		return;
	end
	
	local	vCurrentTime = GetTime();
	
	if vCurrentTime - Outfitter.LastEquipmentUpdateTime < Outfitter_cMinEquipmentUpdateInterval then

		-- To help FIND schedule 			
		Outfitter_ScheduleEquipmentUpdate();
		return;
	end
	
	Outfitter.LastEquipmentUpdateTime = vCurrentTime;
	
	local	vWeaponsNeedUpdate = Outfitter.WeaponsNeedUpdate;
	
	Outfitter.EquippedNeedsUpdate = false;
	Outfitter.WeaponsNeedUpdate = false;
	
	-- Compile the outfit
	
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	local	vCompiledOutfit = Outfitter_GetCompiledOutfit();
	
	-- If the outfit contains non-weapon changes then
	-- delay the change until they're out of combat but go
	-- ahead and swap the weapon slots if there are any
	
	if Outfitter.InCombat or Outfitter.MaybeInCombat then
		if vWeaponsNeedUpdate
		and Outfitter_OutfitHasCombatEquipmentSlots(vCompiledOutfit) then
			
			-- Allow the weapon change to proceed but defer the rest
			-- until they're out of combat
			
			local	vWeaponOutfit = Outfitter_NewEmptyOutfit();
			
			for vEquipmentSlot, _ in pairs(Outfitter_cCombatEquipmentSlots) do
				vWeaponOutfit.Items[vEquipmentSlot] = vCompiledOutfit.Items[vEquipmentSlot];
			end
			
			-- Still need to update the rest once they exit combat
			-- if there are non-equipment slot items
			
			if not Outfitter_OutfitOnlyHasCombatEquipmentSlots(vCompiledOutfit) then
				Outfitter.EquippedNeedsUpdate = true;
			end
			
			-- Switch to the weapons-only part

			-- To help FIND schedule 			
			vCompiledOutfit = vWeaponOutfit;
		else
			-- No weapon changes, just defer the whole outfit change
			
			Outfitter.EquippedNeedsUpdate = true;

			-- To help FIND schedule 			
			Outfitter_ScheduleEquipmentUpdate();

			return;
		end
	end
	
	-- Equip it
	
	local	vEquipmentChangeList = Outfitter_BuildEquipmentChangeList(vCompiledOutfit, vEquippableItems);
	
	if vEquipmentChangeList then
		-- local	vExpectedEquippableItems = OutfitterItemList_New();
	
		Outfitter_ExecuteEquipmentChangeList(vEquipmentChangeList, Outfitter_GetEmptyBagSlotList(), vExpectedEquippableItems);
		
		-- MCDebugLib:DumpArray("ExpectedEquippableItems", vExpectedEquippableItems);
	end
	
	-- Update the outfit we're expecting to see on the player
	
	for vInventorySlot, vItem in pairs(vCompiledOutfit.Items) do
		Outfitter.ExpectedOutfit.Items[vInventorySlot] = vCompiledOutfit.Items[vInventorySlot];
	end
	
	Outfitter.MaybeInCombat = false;
	

	-- To help FIND schedule 			
	Outfitter_ScheduleEquipmentUpdate();
	
	-- MCDebugLib:TestMessage("Outfitter_UpdateEquippedItems: "..(GetTime() - vCurrentTime).."s");
end

function Outfitter_InventorySlotIsEmpty(pInventorySlot)
	debugmessage("Outfitter_InventorySlotIsEmpty",1);
	return Outfitter_GetInventoryItemInfo(pInventorySlot) == nil;
end

function Outfitter_GetBagItemInfo(pBagIndex, pSlotIndex)
	debugmessage("Outfitter_GetBagItemInfo",1);
	local	vItemLink = GetContainerItemLink(pBagIndex, pSlotIndex);
	local	vItemInfo = Outfitter_GetItemInfoFromLink(vItemLink);
	
	if not vItemInfo then
		return nil;
	end
	
	vItemInfo.Texture, _, _, vItemInfo.Quality, _ = GetContainerItemInfo(pBagIndex, pSlotIndex);
	
	return vItemInfo;
end

local	gOutfitter_AmmoSlotInfoCache = nil;

function Outfitter_FindAmmoSlotItemLink(pName, pTexture)
	debugmessage("Outfitter_FindAmmoSlotItemLink",1);
	if gOutfitter_AmmoSlotInfoCache
	and gOutfitter_AmmoSlotInfoCache.Name == pName
	and gOutfitter_AmmoSlotInfoCache.Texture == pTexture then
		return gOutfitter_AmmoSlotInfoCache.ItemLink;
	end
		
	for vBagIndex = 0, NUM_BAG_SLOTS do
		local	vNumBagSlots = GetContainerNumSlots(vBagIndex);
		
		if vNumBagSlots > 0 then
			for vBagSlotIndex = 1, vNumBagSlots do
				local	vTexture = GetContainerItemInfo(vBagIndex, vBagSlotIndex);
				
				if vTexture == pTexture then
					local	vItemLink = GetContainerItemLink(vBagIndex, vBagSlotIndex);
					
					if vItemLink and string.find(vItemLink, pName) then
						if not gOutfitter_AmmoSlotInfoCache then
							gOutfitter_AmmoSlotInfoCache = {};
						end
						
						gOutfitter_AmmoSlotInfoCache.Name = pName;
						gOutfitter_AmmoSlotInfoCache.Texture = pTexture;
						gOutfitter_AmmoSlotInfoCache.ItemLink = vItemLink;
						
						return gOutfitter_AmmoSlotInfoCache.ItemLink;
					end
				end
			end -- for vBagSlotIndex
		end -- if vNumBagSlots
	end -- for vBagIndex
	
	return nil;
end

function Outfitter_GetAmmotSlotItemName()
	debugmessage("Outfitter_GetAmmotSlotItemName",1);
	local	vSlotID = Outfitter_cSlotIDs.AmmoSlot;
	
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0);
	OutfitterTooltip:SetInventoryItem("player", vSlotID);
	
	if not OutfitterTooltipTextLeft1:IsShown() then
		OutfitterTooltip:Hide();
		return nil;
	end
	
	local	vAmmoItemName = OutfitterTooltipTextLeft1:GetText();
	
	OutfitterTooltip:Hide();
	
	local	vAmmoItemTexture = GetInventoryItemTexture("player", vSlotID);
	
	return vAmmoItemName, vAmmoItemTexture;
end

function Outfitter_GetAmmotSlotItemLink()
	debugmessage("Outfitter_GetAmmotSlotItemLink",1);
	return Outfitter_FindAmmoSlotItemLink(Outfitter_GetAmmotSlotItemName());
end

function Outfitter_GetInventoryItemInfo(pInventorySlot)
	debugmessage("Outfitter_GetInventoryItemInfo",1);
	local	vSlotID = Outfitter_cSlotIDs[pInventorySlot];
	local	vItemLink = Outfitter_GetInventorySlotIDLink(vSlotID);
	local	vItemInfo = Outfitter_GetItemInfoFromLink(vItemLink);
	
	if not vItemInfo then
		return nil;
	end
	
	vItemInfo.Quality = GetInventoryItemQuality("player", vSlotID);
	vItemInfo.Texture = GetInventoryItemTexture("player", vSlotID);
	
	return vItemInfo;
end

function Outfitter_GetItemInfoFromLink(pItemLink)
	debugmessage("Outfitter_GetItemInfoFromLink",1);
	if not pItemLink then
		return nil;
	end
	
	-- |cff1eff00|Hitem:1465:803:0:0:0:0:0:0|h[Tigerbane]|h|r
	-- |(hex code for item color)|Hitem:(item ID code):(enchant code):(added stats code):0|h[(item name)]|h|r
	
	local	vStartIndex,
			vEndIndex,
			vLinkColor,
			vItemCode,
			vItemEnchantCode,
			vItemJewelCode1,
			vItemJewelCode2,
			vItemJewelCode3,
			vItemJewelCode4,
			vItemSubCode,
			vUnknownCode5,
			vItemName = strfind(pItemLink, Outfitter_cItemLinkFormat);
	
	if not vStartIndex then
		return nil;
	end
	
	if vItemName then
		--MCDebugLib:TestMessage(string.format("Item %s:%d:%d:%d:%d:%d:%d:%d:%d", vItemName, vItemCode, vItemEnchantCode, vItemSubCode, vItemJewelCode1, vItemJewelCode2,vItemJewelCode3, vItemJewelCode4, vUnknownCode5));
	end
	
	vItemCode = tonumber(vItemCode);
	vItemSubCode = tonumber(vItemSubCode);
	vItemEnchantCode = tonumber(vItemEnchantCode);
	vItemJewelCode1 = tonumber(vItemJewelCode1);
	vItemJewelCode2 = tonumber(vItemJewelCode2);
	vItemJewelCode3 = tonumber(vItemJewelCode3);
	vItemJewelCode4 = tonumber(vItemJewelCode4);
	
	local	vItemFamilyName,
			vItemLink,
			vItemQuality,
			vItemLevel,
			vItemMinLevel,
			vItemType,
			vItemSubType,
			vItemCount,
			vItemInvType;
	
	vItemFamilyName, vItemLink, vItemQuality, vItemLevel, vItemMinLevel, vItemType, vItemSubType, vItemCount, vItemInvType = GetItemInfo(vItemCode);
	
	local	vItemInfo =
	{
		Code = vItemCode,
		SubCode = vItemSubCode,
		Name = vItemName,
		EnchantCode = vItemEnchantCode,
		Level = vItemMinLevel,
		Type = vItemType,
		SubType = vItemSubType,
		JewelCode1 = vItemJewelCode1,
		JewelCode2 = vItemJewelCode2,
		JewelCode3 = vItemJewelCode3,
		JewelCode4 = vItemJewelCode4,		
	};
	
	-- Just return if there's no inventory type
	
	if not vItemInvType
	or vItemInvType == "" then
		return vItemInfo;
	end
	
	-- Just return if we don't know anything about the inventory type
	
	local	vInvTypeInfo = Outfitter_cInvTypeToSlotName[vItemInvType];
	
	if not vInvTypeInfo then
		MCDebugLib:ErrorMessage("Outfitter error: Unknown slot type "..vItemInvType.." for item "..vItemName);
		return vItemInfo;
	end
	
	-- Get the slot name
	
	if not vInvTypeInfo.SlotName then
		MCDebugLib:ErrorMessage("Unknown slot name for inventory type "..vItemInvType);
		return vItemInfo;
	end
	
	vItemInfo.ItemSlotName = vInvTypeInfo.SlotName;
	vItemInfo.MetaSlotName = vInvTypeInfo.MetaSlotName;
	
	-- Return the info
	
	return vItemInfo;
end

function Outfitter_CreateNewOutfit()
	debugmessage("Outfitter_CreateNewOutfit",1);
	OutfitterNameOutfit_Open(nil);
end

function Outfitter_NewEmptyOutfit(pName)
	debugmessage("Outfitter_NewEmptyOutfit",1);
	return {Name = pName, Items = {}};
end

function Outfitter_IsEmptyOutfit(pOutfit)
	debugmessage("Outfitter_IsEmptyOutfit",1);
	return Outfitter_ArrayIsEmpty(pOutfit.Items);
end

function Outfitter_NewNakedOutfit(pName)
	debugmessage("Outfitter_NewNakedOutfit",1);
	local	vOutfit = Outfitter_NewEmptyOutfit(pName);

	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do

		Outfitter_AddOutfitItem(vOutfit, vInventorySlot, 0, 0, "", 0);
	end
	
	return vOutfit;
end

function Outfitter_AddOutfitItem(pOutfit, pSlotName, pItemCode, pItemSubCode, pItemName, pItemEnchantCode,pItemJewelCode1,pItemJewelCode2,pItemJewelCode3,pItemJewelCode4)
	debugmessage("Outfitter_AddOutfitItem",1);
	pOutfit.Items[pSlotName] = {Code = pItemCode, SubCode = pItemSubCode, Name = pItemName, EnchantCode = pItemEnchantCode,JewelCode1 = pItemJewelCode1,JewelCode2 = pItemJewelCode2,JewelCode3 = pItemJewelCode3,JewelCode4 = pItemJewelCode4};
end

function Outfitter_AddOutfitStatItem(pOutfit, pSlotName, pItemCode, pItemSubCode, pItemName, pItemEnchantCode, pItemJewelCode1,pItemJewelCode2,pItemJewelCode3,pItemJewelCode4, pStatID, pStatValue)
	debugmessage("Outfitter_AddOutfitStatItem",1);
	if not pSlotName then
		MCDebugLib:ErrorMessage("AddOutfitStatItem: SlotName is nil for "..pItemName);
		return;
	end
	
	if not pStatID then
		MCDebugLib:ErrorMessage("AddOutfitStatItem: StatID is nil for "..pItemName);
		return;
	end
	
	Outfitter_AddOutfitItem(pOutfit, pSlotName, pItemCode, pItemSubCode, pItemName, pItemEnchantCode,pItemJewelCode1,pItemJewelCode2,pItemJewelCode3,pItemJewelCode4);
	pOutfit.Items[pSlotName][pStatID] = pStatValue;
end

function Outfitter_AddOutfitStatItemIfBetter(pOutfit, pSlotName, pItemCode, pItemSubCode, pItemName, pItemEnchantCode, pItemJewelCode1, pItemJewelCode2, pItemJewelCode3, pItemJewelCode4, pStatID, pStatValue)
	debugmessage("Outfitter_AddOutfitStatItemIfBetter",1);
	local	vCurrentItem = pOutfit.Items[pSlotName];
	local	vAlternateSlotName = Outfitter_cHalfAlternateStatSlot[pSlotName];
	
	if not vCurrentItem
	or not vCurrentItem[pStatID]
	or vCurrentItem[pStatID] < pStatValue then
		-- If we're bumping the current item, see if it should be moved to the alternate slot
		
		if vCurrentItem
		and vCurrentItem[pStatID]
		and vAlternateSlotName then
			Outfitter_AddOutfitStatItemIfBetter(pOutfit, vAlternateSlotName, vCurrentItem.Code, vCurrentItem.SubCode, vCurrentItem.Name, vCurrentItem.EnchantCode, vCurrentItem.JewelCode1,vCurrentItem.JewelCode2,vCurrentItem.JewelCode3,vCurrentItem.JewelCode4, pStatID, vCurrentItem[pStatID])
		end
		
		Outfitter_AddOutfitStatItem(pOutfit, pSlotName, pItemCode, pItemSubCode, pItemName, pItemEnchantCode, pItemJewelCode1,pItemJewelCode2,pItemJewelCode3,pItemJewelCode4,pStatID, pStatValue);
	else
		if not vAlternateSlotName then
			return;
		end
		
		return Outfitter_AddOutfitStatItemIfBetter(pOutfit, vAlternateSlotName, pItemCode, pItemSubCode, pItemName, pItemEnchantCode, pItemJewelCode1,pItemJewelCode2,pItemJewelCode3,pItemJewelCode4, pStatID, pStatValue);
	end
end

function Outfitter_AddStats(pItem1, pItem2, pStatID)
	debugmessage("Outfitter_AddStats",1);
	local	vStat = 0;
	
	if pItem1
	and pItem1[pStatID] then
		vStat = pItem1[pStatID];
	end
	
	if pItem2
	and pItem2[pStatID] then
		vStat = vStat + pItem2[pStatID];
	end
	
	return vStat;
end

function Outfitter_CollapseMetaSlotsIfBetter(pOutfit, pStatID)
	debugmessage("Outfitter_CollapseMetaSlotsIfBetter",1);
	-- Compare the weapon slot with the 1H/OH slots
	
	local	vWeapon0Item = pOutfit.Items.Weapon0Slot;
	local	vWeapon1Item = pOutfit.Items.Weapon1Slot;
	
	if vWeapon0Item or vWeapon1Item then
		-- Try the various combinations of MH/OH/W0/W1
		
		local	v1HItem = pOutfit.Items.MainHandSlot;
		local	vOHItem = pOutfit.Items.SecondaryHandSlot;
		
		local	vCombinations =
		{
			{MainHand = v1HItem, SecondaryHand = vOHItem, AllowEmptyMainHand = true},
			{MainHand = v1HItem, SecondaryHand = vWeapon0Item, AllowEmptyMainHand = false},
			{MainHand = v1HItem, SecondaryHand = vWeapon1Item, AllowEmptyMainHand = false},
			{MainHand = vWeapon0Item, SecondaryHand = vOHItem, AllowEmptyMainHand = true},
			{MainHand = vWeapon1Item, SecondaryHand = vOHItem, AllowEmptyMainHand = true},
			{MainHand = vWeapon0Item, SecondaryHand = vWeapon1Item, AllowEmptyMainHand = false},
		};
		
		local	vBestCombinationIndex = nil;
		local	vBestCombinationValue = nil;
		
		for vIndex = 1, 6 do
			local	vCombination = vCombinations[vIndex];
			
			-- Ignore combinations where the main hand is empty if
			-- that's not allowed in this combinations
			
			if vCombination.AllowEmptyMainHand
			or vCombination.MainHand then
				local	vCombinationValue = Outfitter_AddStats(vCombination.MainHand, vCombination.SecondaryHand, pStatID);
				
				if not vBestCombinationIndex
				or vCombinationValue > vBestCombinationValue then
					vBestCombinationIndex = vIndex;
					vBestCombinationValue = vCombinationValue;
				end
			end
		end
		
		if vBestCombinationIndex then
			local	vCombination = vCombinations[vBestCombinationIndex];
			
			pOutfit.Items.MainHandSlot = vCombination.MainHand;
			pOutfit.Items.SecondaryHandSlot = vCombination.SecondaryHand;
		end
		
		pOutfit.Items.Weapon0Slot = nil;
		pOutfit.Items.Weapon1Slot = nil;
	end
	
	-- Compare the 2H slot with the 1H/OH slots
	
	local	v2HItem = pOutfit.Items.TwoHandSlot;
	
	if v2HItem then
		local	v1HItem = pOutfit.Items.MainHandSlot;
		local	vOHItem = pOutfit.Items.SecondaryHandSlot;
		local	v1HOHTotalStat = Outfitter_AddStats(v1HItem, vOHItem, pStatID);
		
		if v2HItem[pStatID]
		and v2HItem[pStatID] > v1HOHTotalStat then
			pOutfit.Items.MainHandSlot = v2HItem;
			pOutfit.Items.SecondaryHandSlot = nil;
		end
		
		pOutfit.Items.TwoHandSlot = nil;
	end
end

function Outfitter_RemoveOutfitItem(pOutfit, pSlotName)
	debugmessage("Outfitter_RemoveOutfitItem",1);
	pOutfit.Items[pSlotName] = nil;
end

function Outfitter_GetInventoryOutfit(pName, pOutfit)
	debugmessage("Outfitter_GetInventoryOutfit",1);
	local	vOutfit;
	
	if pOutfit then
		vOutfit = pOutfit;
	else
		vOutfit = Outfitter_NewEmptyOutfit(pName);
	end
	
	local Outfitter_cSlotNamestemp = Outfitter_cSlotNames
	if not Outfitter.PriorityLayerLevel[1] then -- no outfit selected after login, or not available during login
	elseif not Outfitter.PriorityLayerLevel[1].SlotPriority then -- no listbox in layer
	else
		Outfitter_cSlotNamestemp = Outfitter.PriorityLayerLevel[1].SlotPriority
		-- listbox of latest outfit, assuming outfits are removed in the order they were put on
		-- (not yet implemented, use listbox in the layer after the outfit that was removed
	end
	for _, vInventorySlot in ipairs(Outfitter_cSlotNamestemp) do
-- modified by jtbalogh

		local	vItemInfo = Outfitter_GetInventoryItemInfo(vInventorySlot);
		
		-- To avoid extra memory operations, only update the item if it's different
		
		local	vExistingItem = vOutfit.Items[vInventorySlot];
		
		if not vItemInfo then
			if not vExistingItem
			or vExistingItem.Code ~= 0 then
				Outfitter_AddOutfitItem(vOutfit, vInventorySlot, 0, 0, "", 0);
			end
		else
			if not vExistingItem
			or vExistingItem.Code ~= vItemInfo.Code
			or vExistingItem.SubCode ~= vItemInfo.SubCode
			or vExistingItem.EnchantCode ~= vItemInfo.EnchantCode 
			or vExistingItem.JewelCode1 ~= vItemInfo.JewelCode1
			or vExistingItem.JewelCode2 ~= vItemInfo.JewelCode2
			or vExistingItem.JewelCode3 ~= vItemInfo.JewelCode3
			or vExistingItem.JewelCode4 ~= vItemInfo.JewelCode4	then
				Outfitter_AddOutfitItem(vOutfit, vInventorySlot, vItemInfo.Code, vItemInfo.SubCode, vItemInfo.Name, vItemInfo.EnchantCode,vItemInfo.JewelCode1,vItemInfo.JewelCode2,vItemInfo.JewelCode3,vItemInfo.JewelCode4);
			end
		end
	end
	
	return vOutfit;
end

function Outfitter_UpdateOutfitFromInventory(pOutfit, pNewItemsOutfit)
	debugmessage("Outfitter_UpdateOutfitFromInventory",1);
	if not pNewItemsOutfit then
		return;
	end
	
	for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
		-- Only update slots which aren't in an unknown state
		
		local	vCheckbox = getglobal("OutfitterEnable"..vInventorySlot);
		
		if not vCheckbox:GetChecked()
		or not vCheckbox.IsUnknown then
			pOutfit.Items[vInventorySlot] = vItem;
			MCDebugLib:NoteMessage(format(Outfitter_cAddingItem, vItem.Name, pOutfit.Name));
			Outfitter_UpdateOutfitCategory(pOutfit);
		end
	end
	
	-- Add the new items to the current compiled outfit
	
	for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
		Outfitter.ExpectedOutfit.Items[vInventorySlot] = pNewItemsOutfit.Items[vInventorySlot];
	end
	
	Outfitter.DisplayIsDirty = true;
end

function Outfitter_SubtractOutfit(pOutfit1, pOutfit2, pCheckAlternateSlots)
	debugmessage("Outfitter_SubtractOutfit",1);
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	
	-- Remove items from pOutfit1 if they match the item in pOutfit2
	
	local Outfitter_cSlotNamestemp = Outfitter_cSlotNames
	if Outfitter.PriorityLayerLevel[1] and Outfitter.PriorityLayerLevel[1].SlotPriority then -- no listbox in layer
		Outfitter_cSlotNamestemp = Outfitter.PriorityLayerLevel[1].SlotPriority
		-- listbox of latest outfit, assuming outfits are removed in the order they were put on
		-- (not yet implemented, use listbox in the layer after the outfit that was removed
	end
 
 -- This would be where I want the Get Info Calls to check the priority Calls
 
	for _, vInventorySlot in ipairs(Outfitter_cSlotNamestemp) do
-- modified by jtbalogh

		local	vItem1 = pOutfit1.Items[vInventorySlot];
		local	vItem2 = pOutfit2.Items[vInventorySlot];
		
		if OutfitterItemList_ItemsAreSame(vEquippableItems, vItem1, vItem2) then
			pOutfit1.Items[vInventorySlot] = nil;
		elseif pCheckAlternateSlots then
			local	vAlternateSlotName = Outfitter_cFullAlternateStatSlot[vInventorySlot];
			
			vItem2 = pOutfit2.Items[vAlternateSlotName];
			
			if OutfitterItemList_ItemsAreSame(vEquippableItems, vItem1, vItem2) then
				pOutfit1.Items[vInventorySlot] = nil;
			end
		end
	end
end

function Outfitter_GetNewItemsOutfit(pPreviousOutfit)
	debugmessage("Outfitter_GetNewItemsOutfit",1);
	-- Get the current outfit and the list
	-- of equippable items
	
	Outfitter.CurrentInventoryOutfit = Outfitter_GetInventoryOutfit(Outfitter.CurrentInventoryOutfit);
	
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	
	-- Create a temporary outfit from the differences
	
	local	vNewItemsOutfit = Outfitter_NewEmptyOutfit();
	local	vOutfitHasItems = false;
	
	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do
-- modified by jtbalogh

		local	vCurrentItem = Outfitter.CurrentInventoryOutfit.Items[vInventorySlot];
		local	vPreviousItem = pPreviousOutfit.Items[vInventorySlot];
		local	vSkipSlot = false;
		
		if vInventorySlot == "SecondaryHandSlot" then
			local	vMainHandItem = pPreviousOutfit.Items["MainHandSlot"];
			
			if vMainHandItem
			and vMainHandItem.MetaSlotName == "TwoHandSlot" then
				vSkipSlot = true;
			end
		elseif vInventorySlot == "AmmoSlot"
		and (not vCurrentItem or vCurrentItem.Code == 0) then
			vSkipSlot = true;
		end
		
		if not vSkipSlot
		and not OutfitterItemList_InventorySlotContainsItem(vEquippableItems, vInventorySlot, vPreviousItem) then
			vNewItemsOutfit.Items[vInventorySlot] = vCurrentItem;
			vOutfitHasItems = true;
		end
	end
	
	if not vOutfitHasItems then
		return nil;
	end
	
	return vNewItemsOutfit, Outfitter.CurrentInventoryOutfit;
end

function Outfitter_UpdateTemporaryOutfit(pNewItemsOutfit)
	debugmessage("Outfitter_UpdateTemporaryOutfit",1);
	-- Just return if nothing has changed
	
	if not pNewItemsOutfit then
		return;
	end
	
	-- Merge the new items with an existing temporary outfit
	
	local	vTemporaryOutfit = OutfitterStack_GetTemporaryOutfit();
	local	vUsingExistingTempOutfit = false;
	
	if vTemporaryOutfit then
	
		for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
			vTemporaryOutfit.Items[vInventorySlot] = vItem;
		end
		
		vUsingExistingTempOutfit = true;
	
	-- Otherwise add the new items as the temporary outfit
	
	else
		vTemporaryOutfit = pNewItemsOutfit;
	end
	
	-- Subtract out items which are expected to be in the outfit
	
	local	vExpectedOutfit = Outfitter_GetExpectedOutfit(vTemporaryOutfit);
	
	Outfitter_SubtractOutfit(vTemporaryOutfit, vExpectedOutfit);
	
	if Outfitter_IsEmptyOutfit(vTemporaryOutfit) then
		if vUsingExistingTempOutfit then
			Outfitter_RemoveOutfit(vTemporaryOutfit);
		end
	else
		if not vUsingExistingTempOutfit then
			OutfitterStack_AddOutfit(vTemporaryOutfit);
		end
	end
	
	-- Add the new items to the current compiled outfit
	
	for vInventorySlot, vItem in pairs(pNewItemsOutfit.Items) do
		Outfitter.ExpectedOutfit.Items[vInventorySlot] = vItem;
	end
end

function Outfitter_SetSlotEnable(pSlotName, pEnable)
	debugmessage("Outfitter_SetSlotEnable",1);
	if not Outfitter.SelectedOutfit then
		return;
	end
	
	if pEnable then
		Outfitter_SetInventoryItem(Outfitter.SelectedOutfit, pSlotName);
	else
		Outfitter.SelectedOutfit.Items[pSlotName] = nil;
	end
	
	Outfitter.DisplayIsDirty = true;
end

function Outfitter_SetInventoryItem(pOutfit, pSlotName)
	debugmessage("Outfitter_SetInventoryItem",1);
	if not pOutfit then
		return;
	end

	local	vItemInfo = Outfitter_GetInventoryItemInfo(pSlotName);
	
	if vItemInfo then
		pOutfit.Items[pSlotName] = {Code = vItemInfo.Code, SubCode = vItemInfo.SubCode, Name = vItemInfo.Name, EnchantCode = vItemInfo.EnchantCode, JewelCode1 = vItemInfo.JewelCode1, JewelCode2 = vItemInfo.JewelCode2, JewelCode3 = vItemInfo.JewelCode3, JewelCode4 = vItemInfo.JewelCode4};
	else
		pOutfit.Items[pSlotName] = {Code = 0, SubCode = 0, Name = "", EnchantCode = 0,JewelCode1 = 0,JewelCode2 = 0,JewelCode3 = 0,JewelCode4 = 0};
	end
	
	Outfitter.DisplayIsDirty = true;
end

function Outfitter_GetSpecialOutfit(pSpecialID)
	debugmessage("Outfitter_GetSpecialOutfit",1);
	for vOutfitIndex, vOutfit in pairs(gOutfitter_Settings.Outfits.Special) do
		if vOutfit.SpecialID == pSpecialID then
			return vOutfit;
		end
	end
	
	return nil;
end

function Outfitter_GetPlayerAuraStates()
	debugmessage("Outfitter_GetPlayerAuraStates",1);
	local		vAuraStates =
	{
		Dining = false,
		Shadowform = false,
		GhostWolf = false,
		Feigning = false,
		Evocate = false,
		Monkey = false,
		Hawk = false,
		Cheetah = false,
		Pack = false,
		Beast = false,
		Wild = false,
		Viper = false,
		Prowl = false,
	};
	
	local		vBuffIndex = 1;
	
	while true do
		local	vName, _, vTexture = UnitBuff("player", vBuffIndex);
		
		if not vTexture then
			return vAuraStates;
		end
		
		local	vStartIndex, vEndIndex, vTextureName = string.find(vTexture, "([^%\\]*)$");
		
		--
		
		local	vSpecialID = gOutfitter_AuraIconSpecialID[vName];
		
		if not vSpecialID then
			vSpecialID = gOutfitter_AuraIconSpecialID[vTextureName];
		end
		
		if vSpecialID then
			vAuraStates[vSpecialID] = true;
		
		--
		
		elseif not vAuraStates.Dining
		and string.find(vTextureName, "INV_Drink") then
			vAuraStates.Dining = true;
		
		--
		
		else
			local	vTextLine1, vTextLine2 = Outfitter_GetBuffTooltipText(vBuffIndex);
			
			if vTextLine1 then
				local	vSpecialID = gOutfitter_SpellNameSpecialID[vTextLine1];
				
				if vSpecialID then
					vAuraStates[vSpecialID] = true;
				end
			end
		end
		
		vBuffIndex = vBuffIndex + 1;
	end
end

function Outfitter_GetBuffTooltipText(pBuffIndex)
	debugmessage("Outfitter_GetBuffTooltipText",1);
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0);
	OutfitterTooltip:SetUnitBuff("player", pBuffIndex);
	
	local	vText1, vText2;
	
	if OutfitterTooltipTextLeft1:IsShown() then
		vText1 = OutfitterTooltipTextLeft1:GetText();
	end -- if IsShown

	if OutfitterTooltipTextLeft2:IsShown() then
		vText2 = OutfitterTooltipTextLeft2:GetText();
	end -- if IsShown

	OutfitterTooltip:Hide();
	
	return vText1, vText2;
end

function Outfitter_UpdateSwimming()
	--debugmessage("Outfitter_UpdateSwimming",1);
	MCEventLib:DispatchEvent("TIMER");
	
	Outfitter_UpdateMountedState();
	
	local	vSwimming = false;
	
	if IsSwimming() then
		vSwimming = true;
	end
	
	if not Outfitter.SpecialState.Swimming then
		Outfitter.SpecialState.Swimming = false;
	end
	
	if Outfitter.SpecialState.Swimming ~= vSwimming then
		local	vEquipDelay;
		
		if not vSwimming then
			vEquipDelay = 2;
		end
		
		if vRiding then
			MCEventLib:DispatchEvent("SWIMMING");
		else
			MCEventLib:DispatchEvent("NOT_SWIMMING");
		end
		
		Outfitter_SetSpecialOutfitEnabled("Swimming", vSwimming, nil, vEquipDelay);
	end
end

function Outfitter_UpdateAuraStates()
	debugmessage("Update Aura States", 1);


	-- We do nothing if AutoSwitching is off
	if gOutfitter_Settings.Options.DisableAutoSwitch then
		return;
	end
	
	-- Check for special aura outfits

	local	vAuraStates = Outfitter_GetPlayerAuraStates();
	
	for vSpecialID, vIsActive in pairs(vAuraStates) do
		if vSpecialID == "Feigning" then
			Outfitter.IsFeigning = vIsActive;
		end
		
		if not Outfitter.SpecialState[vSpecialID] then
			Outfitter.SpecialState[vSpecialID] = false;
		end
		
		if Outfitter.SpecialState[vSpecialID] ~= vIsActive then
			Outfitter_SetSpecialOutfitEnabled(vSpecialID, vIsActive);
		end
	end
	
	-- As of 1.12 aura changes are the only way to detect shapeshifts, so update those too
	
	Outfitter_UpdateShapeshiftState();
end

-- We need to check if the spell is an Attack spell.. If so we need to know if its instant.
function Outfitter_SpellStop()
	debugmessage("Outfitter_SpellStop",2);

	if Outfitter.SpecialState.Riding then	
		debugmessage("Outfitter_SpellStop We're riding",2);
		Outfitter.MaybeInCombat = true;
	end

end

-- This function is used to remove the Riding Outfit when we start to cast.
function Outfitter_SpellSent()
	
-- arg1 == Unit
-- arg2 == Spell Name
-- arg3 == Rank	
-- arg4 == Target
	if Outfitter.SpecialState.Riding then	
		Outftter_SpellSentTime = GetTime();
	else
		Outftter_SpellSentTime = nil;
	end
end

function Outfitter_UpdateMountedState()
	--debugmessage("Outfitter_UpdateMountedState",1);
	local	vRiding;

	-- have to check if the user is currently Mounted and is Dismounting
	if Outftter_SpellSentTime then
		local vTime = GetTime() - Outftter_SpellSentTime;
	
		if vTime < .5 then
			return;
		end
	end

	-- We do nothing if AutoSwitching is off
	if gOutfitter_Settings.Options.DisableAutoSwitch then
		return;
	end	

	if IsMounted() and not UnitOnTaxi("player") then
		vRiding = true;
	else
		vRiding = false;
	end

	if Outfitter.SpecialState.Riding ~= vRiding then
		Outfitter.SpecialState.Riding = vRiding;
		--if InCombatLockdown() then
		--	debugmessage("In Combat Lock Down",2);
		--else
		--	debugmessage("NOT in Combat Lock Down",2);
		--end

		--if Outfitter.InCombat then
		--	debugmessage("In Combat",2);
		--else
		-- debugmessage("NOT in Combat",2);
		--end
		
		if vRiding then
			MCEventLib:DispatchEvent("MOUNTED");
		else
			MCEventLib:DispatchEvent("NOT_MOUNTED");
		end
		
		--debugmessage("Updating Mounted State",2);
		Outfitter_SetSpecialOutfitEnabled("Riding", vRiding);
	end
end

function Outfitter_UpdateShapeshiftState()
	if Outfitter.Initialized then
		debugmessage("Update Shapeshift State", 1);
	end

	local	vNumForms = GetNumShapeshiftForms();
	local	vWearBelowOutfitByType = {};
	
	for vIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		if vOutfit.SpecialID then
			local	vType = Outfitter_cShapeshiftTypes[vOutfit.SpecialID];
			
			if vType then
				vWearBelowOutfitByType[vType] = Outfitter.OutfitStack[vIndex + 1];
			end
		end
	end
	
	for vIndex = 1, vNumForms do
		local	vTexture, vName, vIsActive, vIsCastable = GetShapeshiftFormInfo(vIndex);
		local	vSpecialID = Outfitter_cShapeshiftSpecialIDs[vName];
		
		if vSpecialID then
			if not vIsActive then
				vIsActive = false;
			end
			
			if Outfitter.SpecialState[vSpecialID.ID] == nil then
				Outfitter.SpecialState[vSpecialID.ID] = Outfitter_WearingSpecialOutfit(vSpecialID.ID);
			end
			
			if Outfitter.SpecialState[vSpecialID.ID] ~= vIsActive then
				if vIsActive and vSpecialID.MaybeInCombat then
					Outfitter.MaybeInCombat = true;
				end
				
				local	vEquipDelay;
				
				-- Delay outfit changes for druids shifting into caster form for 2 seconds
				-- to allow them to start casting a heal before the global cooldown is triggered
				
				if not vIsActive
				and Outfitter.InCombat
				and vSpecialID.Type == "DRUIDFORM" then
					vEquipDelay = 2;
				end
				
				--
				
				Outfitter_SetSpecialOutfitEnabled(vSpecialID.ID, vIsActive, vWearBelowOutfitByType[vSpecialID.Type], vEquipDelay);
			end
		end
	end
end

function Outfitter_SetSpecialOutfitEnabled(pSpecialID, pEnable, pWearBelowOutfit, pEquipDelay)
		if Outfitter.Initialized then
			debugmessage("Set Special Outfit Enabled", 1);
		end

	if pEnable == nil then
		pEnable = false;
	end
	
	-- Dispatch the special ID events
	
	local	vEvents = Outfitter_cSpecialIDEvents[pSpecialID];
	
	if vEvents then
		if pEnable then
			MCEventLib:DispatchEvent(vEvents.Equip);
		else
			MCEventLib:DispatchEvent(vEvents.Unequip);
		end
	end
	
	--
	
	Outfitter.SpecialState[pSpecialID] = pEnable;
	
	local	vOutfit = Outfitter_GetSpecialOutfit(pSpecialID);
	
	if not vOutfit
	or vOutfit.Disabled then
		return;
	end
	
	-- BG and AQ disabled outfits only disable equipping, not unequipping
	
	if pEnable then
		if vOutfit.BGDisabled and Outfitter_InBattlegroundZone() then
			return;
		end
		
		if vOutfit.AQDisabled and Outfitter.CurrentZone == Outfitter_cAQ40 then
			return;
		end
	end
		
	-- Disallow both equip and unequip for combat-disabled outfits
	if vOutfit.CombatDisabled and Outfitter.InCombat then
		--debugmessage("Outfitter: In Combat and not Changing",2);
		return;
	end
	
	-- Adjust the last equipped time to cause a delay if requested
	
	if pEquipDelay then
		local	vUpdateTime = GetTime() + (pEquipDelay - Outfitter_cMinEquipmentUpdateInterval);
		
		if vUpdateTime > Outfitter.LastEquipmentUpdateTime then
			Outfitter.LastEquipmentUpdateTime = vUpdateTime;
		end
	end
	
	--
	-- Don't equip dining outfit if health and mana are almost topped up

	if pSpecialID == "Dining" and pEnable then

		local	vFullHealth = false;
		local	vFullMana = false;
		
		if UnitHealth("player") > (UnitHealthMax("player") * 0.85) then
			vFullHealth = true;
		end
		
		if UnitPowerType("player") == 0 then
			if UnitMana("player") > (UnitManaMax("player") * 0.85) then
				vFullMana = true;
			end
		else
			vFullMana = true;
		end
		
		if vFullHealth and vFullMana then
			return;
		end
	end
	
	if pEnable then
		-- Start monitoring health and mana if it's the dining outfit
		
		if pSpecialID == "Dining" then
			Outfitter_ResumeEvent(OutfitterFrame, "UNIT_HEALTH");
			--Outfitter_ResumeEvent(OutfitterFrame, "UNIT_MANA");
			OUTFIT_InDining = true;
		end
		
		--
		
		local	vWearBelowOutfit = nil;
		
		-- If it's the ArgentDawn outfit, wear it below the
		-- riding outfit.  Once the player dismounts then
		-- overlapping items from the ArgentDawn outfit will equip.
		-- This prevents the Argent Dawn trinket from interfering
		-- with the carrot trinket when riding into the plaguelands
		
		if pSpecialID == "ArgentDawn" then
			vWearBelowOutfit = Outfitter_GetSpecialOutfit("Riding");
		else
			vWearBelowOutfit = pWearBelowOutfit;
		end
		
		--
		
		Outfitter_WearOutfit(vOutfit, "Special", vWearBelowOutfit);
	else
		--debugmessage("Call Remove Outfit",2);
		Outfitter_RemoveOutfit(vOutfit);
	end
end

function Outfitter_WearingSpecialOutfit(pSpecialID)
		debugmessage("Outfitter_WearingSpecialOutfit",1);
	for vIndex, vOutfit in ipairs(Outfitter.OutfitStack) do
		if vOutfit.SpecialID == pSpecialID then
			return true, vIndex;
		end
	end
end

function Outfitter_UpdateZone()
	local	vCurrentZone = GetZoneText();
	local	vPVPType, vIsArena, vFactionName = GetZonePVPInfo();

	debugmessage("Update Zone", 1);

	-- We do nothing if AutoSwitching is off
	if gOutfitter_Settings.Options.DisableAutoSwitch then
		return;
	end	
	
	-- If this set we have is for this area then don't change.
	if vCurrentZone == Outfitter.CurrentZone then
		return;
	end
	
	Outfitter.CurrentZone = vCurrentZone;
	
	local	vZoneSpecialIDMap = Outfitter_cZoneSpecialIDMap[vCurrentZone];
	local	vSpecialZoneStates = {};
	
	if vZoneSpecialIDMap then
		for _, vZoneSpecialID in ipairs(vZoneSpecialIDMap) do
			if vZoneSpecialID ~= "City" or vPVPType ~= "hostile" then
				vSpecialZoneStates[vZoneSpecialID] = true;
			end
		end
	end
	
	if IsActiveBattlefieldArena() then
		vSpecialZoneStates.Arena = true;
	else
		vSpecialZoneStates.Arena = false;
	end
	
	for _, vSpecialID in ipairs(Outfitter_cZoneSpecialIDs) do
		local	vIsActive = vSpecialZoneStates[vSpecialID];
		
		if vIsActive == nil then
			vIsActive = false;
		end
		
		-- Disable Argent Dawn in Naxxramas if requested
		
		if vSpecialID == "ArgentDawn" then
			local	vOutfit = Outfitter_GetSpecialOutfit(vSpecialID);
			
			if vOutfit.NaxxDisabled
			and Outfitter_InZoneType("Naxx") then
				vIsActive = false;
			end
		end
		
		--
		
		local	vCurrentIsActive = Outfitter.SpecialState[vSpecialID];
		
		if vCurrentIsActive == nil then
			vCurrentIsActive = Outfitter_WearingSpecialOutfit(vSpecialID);
			Outfitter.SpecialState[vSpecialID] = vCurrentIsActive;
		end
		
		if vCurrentIsActive ~= vIsActive then
			Outfitter_SetSpecialOutfitEnabled(vSpecialID, vIsActive);
		end
	end
end

function Outfitter_InZoneType(pZoneType)
	debugmessage("Outfitter_InZoneType",1);
	local	vZoneSpecialIDMap = Outfitter_cZoneSpecialIDMap[Outfitter.CurrentZone];
	
	if not vZoneSpecialIDMap then
		return false;
	end
	
	for _, vZoneType in pairs(vZoneSpecialIDMap) do
		if vZoneType == pZoneType then
			return true;
		end
	end
	
	return false;
end

function Outfitter_InBattlegroundZone()
	debugmessage("Outfitter_InBattlegroundZone",1);
	return IsActiveBattlefieldArena() or Outfitter_InZoneType("Battleground");
end

function Outfitter_SetAllSlotEnables(pEnable)
	debugmessage("Outfitter_SetAllSlotEnables",1);
	--MCDebugLib:ErrorMessage("Outfitter: Set All Slot");

	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do
		Outfitter_SetSlotEnable(vInventorySlot, pEnable);
	end
	
	Outfitter_UpdateOutfitCategory(Outfitter.SelectedOutfit);
	Outfitter_Update(true);
end

function Outfitter_OutfitIsComplete(pOutfit, pIgnoreAmmoSlot)
	debugmessage("Outfitter_OutfitIsComplete",1);

	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do

		if not pOutfit.Items[vInventorySlot]
		and (not pIgnoreAmmoSlot or vInventorySlot ~= "AmmoSlot") then
			return false;
		end
	end
	
	return true;
end

function Outfitter_CalculateOutfitCategory(pOutfit)
	debugmessage("Outfitter_CalculateOutfitCategory",1);
	local	vIgnoreAmmoSlot = UnitHasRelicSlot("player");

	if Outfitter_OutfitIsComplete(pOutfit, vIgnoreAmmoSlot) then
		return "Complete";
	elseif pOutfit.IsAccessory == nil
	or pOutfit.IsAccessory then
		return "Accessory";
	else
		return "Partial";
	end
end

function Outfitter_UpdateOutfitCategory(pOutfit)
	debugmessage("Outfitter_UpdateOutfitCategory",1);
	if not pOutfit then
		return;
	end
	
	local	vTargetCategoryID = Outfitter_CalculateOutfitCategory(pOutfit);
	local	vOutfitCategoryID, vOutfitIndex = Outfitter_FindOutfit(pOutfit);
	
	-- Don't move special outfits around
	
	if vOutfitCategoryID == "Special" then
		return;
	end
	
	-- Move the outfit if necessary
	
	if vTargetCategoryID ~= vOutfitCategoryID then
		table.remove(gOutfitter_Settings.Outfits[vOutfitCategoryID], vOutfitIndex);
		Outfitter_AddOutfit(pOutfit);
	end
end

function Outfitter_DeleteOutfit(pOutfit)
	debugmessage("Outfitter_DeleteOutfit",1);
	local	vWearingOutfit = Outfitter_WearingOutfit(pOutfit);
	local	vOutfitCategoryID, vOutfitIndex = Outfitter_FindOutfit(pOutfit);
	
	if not vOutfitCategoryID then
		return;
	end
	
	Outfitter_DeactivateScript(pOutfit);
	
	-- Delete the outfit
	
	table.remove(gOutfitter_Settings.Outfits[vOutfitCategoryID], vOutfitIndex);
	
	-- Deselect the outfit
	
	if pOutfit == Outfitter.SelectedOutfit then
		Outfitter_ClearSelection();
	end
	
	-- Remove the outfit if it's being worn
	
	Outfitter_RemoveOutfit(pOutfit);
	
	--
	
	Outfitter.DisplayIsDirty = true;
end

function Outfitter_AddOutfit(pOutfit)
	debugmessage("Outfitter_AddOutfit",1);
	local	vCategoryID;
	
	if pOutfit.SpecialID then
		vCategoryID = "Special"
	else
		vCategoryID = Outfitter_CalculateOutfitCategory(pOutfit);
	end
	
	if not gOutfitter_Settings.Outfits then
		gOutfitter_Settings.Outfits = {};
	end
	
	if not gOutfitter_Settings.Outfits[vCategoryID] then
		gOutfitter_Settings.Outfits[vCategoryID] = {};
	end
	
	table.insert(gOutfitter_Settings.Outfits[vCategoryID], pOutfit);
	pOutfit.CategoryID = vCategoryID;
	
	Outfitter.DisplayIsDirty = true;
	
	return vCategoryID;
end

function Outfitter_SlotEnableClicked(pCheckbox, pButton)
	debugmessage("Outfitter_SlotEnableClicked",1);
	-- If the user is attempting to drop an item put it in the slot for them
	
	if CursorHasItem() then
		PickupInventoryItem(Outfitter_cSlotIDs[pCheckbox.SlotName]);
		return;
	end
	
	--
	
	local	vChecked = pCheckbox:GetChecked();
	
	if pCheckbox.IsUnknown then
		pCheckbox.IsUnknown = false;
		pCheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		vChecked = true;
	end
	
	Outfitter_SetSlotEnable(pCheckbox.SlotName, vChecked);
	Outfitter_UpdateOutfitCategory(Outfitter.SelectedOutfit);
	Outfitter_Update(true);
end

function Outfitter_FindMultipleItemLocation(pItems, pEquippableItems)
	debugmessage("Outfitter_FindMultipleItemLocation",1);
	for vListIndex, vListItem in ipairs(pItems) do
		local	vItem = OutfitterItemList_FindItemOrAlt(pEquippableItems, vListItem);
		
		if vItem then
			return vItem, vListItem;
		end
	end
	
	return nil, nil;
end

function Outfitter_FindAndAddItemsToOutfit(pOutfit, pSlotName, pItems, pEquippableItems)
	debugmessage("Outfitter_FindAndAddItemsToOutfit",1);
	vItemLocation, vItem = Outfitter_FindMultipleItemLocation(pItems, pEquippableItems);
	
	if vItemLocation then
		local	vInventorySlot = pSlotName;
		
		if not vInventorySlot then
			vInventorySlot = vItemLocation.ItemSlotName;
		end
		
		Outfitter_AddOutfitItem(pOutfit, vInventorySlot, vItem.Code, vItem.SubCode, vItem.Name, vItem.EnchantCode, vItem.JewelCode1,vItem.JewelCode2,vItem.JewelCode3,vItem.JewelCode4);
	end
end

function Outfitter_AddItemsWithStatToOutfit(pOutfit, pStatID, pEquippableItems)
	debugmessage("Outfitter_AddItemsWithStatToOutfit",1);
	local	vItemStats;
	
	if not pEquippableItems then
		return;
	end
	
	for vInventorySlot, vItems in pairs(pEquippableItems.ItemsBySlot) do
		for vIndex, vItem in ipairs(vItems) do
			local	vStatValue = vItem.Stats[pStatID];
			
			if vStatValue then
				local	vSlotName = vItem.MetaSlotName;
				
				if not vSlotName then
					vSlotName = vItem.ItemSlotName;
				end
				
				Outfitter_AddOutfitStatItemIfBetter(pOutfit, vSlotName, vItem.Code, vItem.SubCode, vItem.Name, vItem.EnchantCode, vItem.JewelCode1,vItem.JewelCode2,vItem.JewelCode3,vItem.JewelCode4,pStatID, vStatValue);
			end
		end
	end
	
	-- Collapse the meta slots (currently just 2H vs. 1H/OH)
	
	Outfitter_CollapseMetaSlotsIfBetter(pOutfit, pStatID);
end

function Outfitter_IsInitialized()
	debugmessage("Outfitter_IsInitialized",1);
	return Outfitter.Initialized;
end

function Outfitter_Initialize()
	debugmessage("Outfitter_Initialize",1);
	if Outfitter.Initialized then
		return;
	end
	
	-- Build the default Outfitter values at this point.
	
	if not gOutfitter_Settings then
		gOutfitter_Settings = {};
		gOutfitter_Settings.Version = 8;
		gOutfitter_Settings.Options = {};
		gOutfitter_Settings.LastOutfitStack = {};
		gOutfitter_Settings.DebugLevel = 1;
		gOutfitter_Settings.Options.Debug = nil;
	end
	
	-- Initialize the slot ID map
	
	Outfitter_cSlotIDs = {};
	Outfitter_cSlotIDToInventorySlot = {};
		
	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do
		local	vSlotID = GetInventorySlotInfo(vInventorySlot);
		
		Outfitter_cSlotIDs[vInventorySlot] = vSlotID;
		Outfitter_cSlotIDToInventorySlot[vSlotID] = vInventorySlot;
	end
	
	-- Initialize the outfits and outfit stack
	
	Outfitter.CurrentOutfit = Outfitter_GetInventoryOutfit();
	
	if not gOutfitter_Settings.Outfits then
		Outfitter_InitializeOutfits();
	end
	
	Outfitter_CheckDatabase();
	
	Outfitter_InitializeSpecialOccasionOutfits(); -- Make sure the special occasion outfits are intact
	                                               -- since the user has no way of creating them himself
	OutfitterStack_RestoreSavedStack();
	
	-- Set the minimap button
	
	if gOutfitter_Settings.Options.HideMinimapButton then
		OutfitterMinimapButton:Hide();
	else
		OutfitterMinimapButton:Show();
	end
	
	if not gOutfitter_Settings.Options.MinimapButtonAngle then
		gOutfitter_Settings.Options.MinimapButtonAngle = -1.5708;
	end
	
	OutfitterMinimapButton_SetPositionAngle(gOutfitter_Settings.Options.MinimapButtonX,  gOutfitter_Settings.Options.MinimapButtonY);
	
	-- Hook QuickSlots into the paper doll frame
	
	Outfitter_HookPaperDollFrame();
	
	-- Done initializing
	
	Outfitter.Initialized = true;

	-- Make sure the outfit state is good
	
	Outfitter_SetSpecialOutfitEnabled("Riding", false);
	Outfitter_SetSpecialOutfitEnabled("Spirit", false);
	Outfitter_UpdateAuraStates();
	
	Outfitter_ResumeLoadScreenEvents();
	
	Outfitter_DispatchOutfitEvent("OUTFITTER_INIT")
	
	MCSchedulerLib:ScheduleUniqueRepeatingTask(0.5, Outfitter_UpdateSwimming);	
	MCSchedulerLib:ScheduleUniqueRepeatingTask(0.5, Outfitter_FiveSecondRule);
	
	-- Activate all outfit scripts
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			vOutfit.LastScriptTime = nil;
			vOutfit.ScriptLockupCount = 0;
			Outfitter_ActivateScript(vOutfit);
		end
	end
	
	-- Do we have engineering?
	for n = 0, 4, 1 do
		local bagName = GetBagName(n);
		if bagName then
			local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(bagName);
			if sSubType == Outfitter_cContainerEngineeringBagSubType then
				--message(sName..","..iRarity..","..sType..","..sSubType);
				OUTFIT_HasEngineeringBag = true;
				break;
			end
		end
	end
	


	-- This ties in the Mouse Over Tooltip
	if not gOutfitter_Settings.Options.DisableToolTipInfo then
		-- The orginal locations.
		GameTooltip.Outfitter_OrigSetBagItem = GameTooltip.SetBagItem;
		GameTooltip.Outfitter_OrigSetInventoryItem = GameTooltip.SetInventoryItem;

		-- Set the new locations
		GameTooltip.SetBagItem = Outfitter_GameTooltip_SetBagItem;		
		GameTooltip.SetInventoryItem = Outfitter_GameTooltip_SetInventoryItem;
	end 
end

function Outfitter_InitializeOutfits()
	debugmessage("Outfitter_InitializeOutfits",1);
	local	vOutfit, vItemLocation, vItem;
	local	vEquippableItems = OutfitterItemList_GetEquippableItems(true);
	
	-- Create the outfit categories
	
	gOutfitter_Settings.Outfits = {};
	
	for vCategoryIndex, vCategoryID in ipairs(gOutfitter_cCategoryOrder) do
		gOutfitter_Settings.Outfits[vCategoryID] = {};
	end

	-- Create the normal outfit using the current
	-- inventory and set it as the currently equipped outfit
	
	vOutfit = Outfitter_GetInventoryOutfit(Outfitter_cNormalOutfit);
	Outfitter_AddOutfit(vOutfit);
	gOutfitter_Settings.LastOutfitStack = {{Name = Outfitter_cNormalOutfit}};
	Outfitter.OutfitStack = {vOutfit};
	
	-- Create the naked outfit
	
	vOutfit = Outfitter_NewNakedOutfit(Outfitter_cNakedOutfit);
	Outfitter_AddOutfit(vOutfit);
	
	-- Generate the smart outfits
	
	for vSmartIndex, vSmartOutfit in ipairs(Outfitter_cSmartOutfits) do
		vOutfit = Outfitter_GenerateSmartOutfit(vSmartOutfit.Name, vSmartOutfit.StatID, vEquippableItems);
		
		if vOutfit then
			vOutfit.IsAccessory = vSmartOutfit.IsAccessory;
			Outfitter_AddOutfit(vOutfit);
		end
	end
	
	Outfitter_InitializeSpecialOccasionOutfits();
end

function Outfitter_CreateEmptySpecialOccasionOutfit(pSpecialID, pName)
	debugmessage("Outfitter_CreateEmptySpecialOccasionOutfit",1);
	vOutfit = Outfitter_GetSpecialOutfit(pSpecialID);
	
	if not vOutfit then
		vOutfit = Outfitter_NewEmptyOutfit(pName);
		vOutfit.SpecialID = pSpecialID;
		
		Outfitter_AddOutfit(vOutfit);
	end
end

function Outfitter_InitializeSpecialOccasionOutfits()
	debugmessage("Outfitter_InitializeSpecialOccasionOutfits",1);
	local	vEquippableItems = OutfitterItemList_GetEquippableItems(true);
	local	vOutfit;
	
	-- Find an argent dawn trinket and set the argent dawn outfit
	
	vOutfit = Outfitter_GetSpecialOutfit("ArgentDawn");
	
	if not vOutfit and not gOutfitter_Settings.DisableArgentDawn then
		vOutfit = Outfitter_GenerateSmartOutfit(Outfitter_cArgentDawnOutfit, "ArgentDawn", vEquippableItems, true);
		vOutfit.SpecialID = "ArgentDawn";
		Outfitter_AddOutfit(vOutfit);
	end
	
	-- Find riding items
	
	vOutfit = Outfitter_GetSpecialOutfit("Riding");

	if not vOutfit and not gOutfitter_Settings.DisableRiding then
		vOutfit = Outfitter_GenerateSmartOutfit(Outfitter_cRidingOutfit, "Riding", vEquippableItems, true);
		vOutfit.SpecialID = "Riding";
		vOutfit.BGDisabled = true;
		Outfitter_AddOutfit(vOutfit);
	end
	
	-- Create the dining outfit
	if not gOutfitter_Settings.DisableDining then
		Outfitter_CreateEmptySpecialOccasionOutfit("Dining", Outfitter_cDiningOutfit);
	end
	-- Create the Battlegrounds outfits
	
	if not gOutfitter_Settings.DisableBattleground then Outfitter_CreateEmptySpecialOccasionOutfit("Battleground", Outfitter_cBattlegroundOutfit); end
	if not gOutfitter_Settings.DisableAB then Outfitter_CreateEmptySpecialOccasionOutfit("AB", Outfitter_cABOutfit); end
	if not gOutfitter_Settings.DisableAV then Outfitter_CreateEmptySpecialOccasionOutfit("AV", Outfitter_cAVOutfit); end
	if not gOutfitter_Settings.DisableWSG then Outfitter_CreateEmptySpecialOccasionOutfit("WSG", Outfitter_cWSGOutfit); end
	if not gOutfitter_Settings.DisableArena then Outfitter_CreateEmptySpecialOccasionOutfit("Arena", Outfitter_cArenaOutfit); end
	if not gOutfitter_Settings.DisableEotS then Outfitter_CreateEmptySpecialOccasionOutfit("EotS", Outfitter_cEotSOutfit); end
	
	-- Create the city outfit
	
	if not gOutfitter_Settings.DisableCity then Outfitter_CreateEmptySpecialOccasionOutfit("City", Outfitter_cCityOutfit); end
	
	-- Create the swimming outfit
	
	if not gOutfitter_Settings.DisableSwimming then Outfitter_CreateEmptySpecialOccasionOutfit("Swimming", Outfitter_cSwimmingOutfit); end
	
	-- Create class-specific outfits
	
	Outfitter_InitializeClassOutfits();
end

function Outfitter_InitializeClassOutfits()
	debugmessage("Outfitter_InitializeClassOutfits",1);
	local	vClassName = Outfitter_cNormalizedClassName[UnitClass("player")];
	local	vOutfits = Outfitter_cClassSpecialOutfits[vClassName];
	
	if not vOutfits then
		return;
	end
	
	for vIndex, vOutfitInfo in ipairs(vOutfits) do
		Outfitter_CreateEmptySpecialOccasionOutfit(vOutfitInfo.SpecialID, vOutfitInfo.Name);
	end
	
	-- Dsable any outfits we no longer want.
	Outfitter_DisableClassOutfits();
end

function Outfitter_IsStatText(pText)
	debugmessage("Outfitter_IsStatText",1);
	for vStatIndex, vStatInfo in ipairs(Outfitter_cItemStatFormats) do
		local	vStartIndex, vEndIndex, vValue = string.find(pText, vStatInfo.Format);
		
		if vStartIndex then
			vValue = tonumber(vValue);
			
			if not vValue then
				vValue = vStatInfo.Value;
			end
			
			if not vValue then
				vValue = 0;
			end
			
			return vStatInfo.Types, vValue;
		end
	end
	
	return nil, nil;
end

function Outfitter_GetItemStatsFromTooltip(pTooltip, pDistribution)
	debugmessage("Outfitter_GetItemStatsFromTooltip",1);
	local	vStats = {};
	local	vTooltipName = pTooltip:GetName();
	local LineCount = pTooltip:NumLines();

	for vLineIndex = 1, LineCount do
		local	vLeftTextFrame = getglobal(vTooltipName.."TextLeft"..vLineIndex);
		
		if not vLeftTextFrame then
			break;
		end
		
		local	vLeftText = vLeftTextFrame:GetText();
		-- local	vRightText = getglobal(vTooltipName.."TextRight"..vLineIndex):GetText();
		
		if vLeftText then
			-- Check for the start of the set bonus section
			
			local	vStartIndex, vEndIndex, vValue = string.find(vLeftText, "%(%d/%d%)");
			
			if vStartIndex then
				break;
			end
			
			--
			
			for vStatString in string.gmatch(vLeftText, "([^/]+)") do
				local	vStatIDs, vValue = Outfitter_IsStatText(vStatString);
				
				if vStatIDs then
					for vStatIDIndex, vStatID in ipairs(vStatIDs) do
						OutfitterStats_AddStatValue(vStats, vStatID, vValue, pDistribution);
					end
				end
			end
		end
	end -- for vLineIndex
	
	return vStats;
end

function Outfitter_TooltipContainsText(pTooltip, pText)
	debugmessage("Outfitter_TooltipContainsText",1);
	local	vTooltipName = pTooltip:GetName();
	
	for vLineIndex = 1, 100 do
		local	vLeftTextFrame = getglobal(vTooltipName.."TextLeft"..vLineIndex);
		
		if not vLeftTextFrame then
			break;
		end
		
		local	vLeftText = vLeftTextFrame:GetText();
		
		if vLeftText
		and string.find(vLeftText, pText) then
			return true;
		end
	end -- for vLineIndex
	
	return false;
end

function Outfitter_CanEquipBagItem(pBagIndex, pBagSlotIndex)
	debugmessage("Outfitter_CanEquipBagItem",1);
	local	vItemInfo = Outfitter_GetBagItemInfo(pBagIndex, pBagSlotIndex);
	
	if vItemInfo
	and vItemInfo.Level
	and UnitLevel("player") < vItemInfo.Level then
		return false;
	end
	
	return true;
end

function Outfitter_BagItemWillBind(pBagIndex, pBagSlotIndex)
	debugmessage("Outfitter_BagItemWillBind",1);
	local	vItemLink = GetContainerItemLink(pBagIndex, pBagSlotIndex);
	
	if not vItemLink then
		return nil;
	end
	
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0);
	OutfitterTooltip:SetBagItem(pBagIndex, pBagSlotIndex);
	
	local	vIsBOE = Outfitter_TooltipContainsText(OutfitterTooltip, ITEM_BIND_ON_EQUIP);
	
	OutfitterTooltip:Hide();
	
	return vIsBOE;
end

function Outfitter_GenerateSmartOutfit(pName, pStatID, pEquippableItems, pAllowEmptyOutfit)
	debugmessage("Outfitter_GenerateSmartOutfit",1);
	local	vOutfit = Outfitter_NewEmptyOutfit(pName);
	
	if pStatID == "TANKPOINTS" then
		return;
	end
	
	local	vItems = Outfitter_cStatIDItems[pStatID];
	
	OutfitterItemList_ResetIgnoreItemFlags(pEquippableItems);
	
	if vItems then
		Outfitter_FindAndAddItemsToOutfit(vOutfit, nil, vItems, pEquippableItems);
	end
	
	--MCDebugLib:ErrorMessage("Outfitter Calling Best Fit: "..pStatID..".");
	Outfitter_AddItemsWithStatToOutfit(vOutfit, pStatID, pEquippableItems);
	
	if not pAllowEmptyOutfit
	and Outfitter_IsEmptyOutfit(vOutfit) then
		return nil;
	end
	
	vOutfit.StatID = pStatID;
	
	return vOutfit;
end

function Outfitter_ArrayIsEmpty(pArray)
	debugmessage("Outfitter_ArrayIsEmpty",1);
	if not pArray then
		return true;
	end
	
	return next(pArray) == nil;
end

function OutfitterNameOutfit_Open(pOutfit)
	debugmessage("OutfitterNameOutfit_Open",3);
	gOutfitter_OutfitToRename = pOutfit;
	
	if gOutfitter_OutfitToRename then
		OutfitterNameOutfitDialogTitle:SetText(Outfitter_cRenameOutfit);
		OutfitterNameOutfitDialogName:SetText(gOutfitter_OutfitToRename.Name);
		OutfitterNameOutfitDialogCreateUsing:Hide();
		OutfitterNameOutfitDialog:SetHeight(OutfitterNameOutfitDialog.baseHeight - 35);
	else
		OutfitterNameOutfitDialogTitle:SetText(Outfitter_cNewOutfit);
		OutfitterNameOutfitDialogName:SetText("");
		OutfitterDropDown_SetSelectedValue(OutfitterNameOutfitDialogCreateUsing, 0);
		OutfitterNameOutfitDialogCreateUsing:Show();
		OutfitterNameOutfitDialog:SetHeight(OutfitterNameOutfitDialog.baseHeight);
		OutfitterNameOutfitDialogCreateUsing.ChangedValueFunc = OutfitterNameOutfit_CheckForStatOutfit;
	end
	
	OutfitterNameOutfitDialog:Show();
	OutfitterNameOutfitDialogName:SetFocus();
end

function OutfitterNameOutfit_CheckForStatOutfit(pMenu, pValue)
	debugmessage("OutfitterNameOutfit_CheckForStatOutfit",1);
	OutfitterNameOutfit_Update(true);
end

function OutfitterNameOutfit_Done()
	local	vName = OutfitterNameOutfitDialogName:GetText();
	debugmessage("Name Outfit Done",1);
	
	if vName
	and vName ~= "" then
		if gOutfitter_OutfitToRename then
			local	vWearingOutfit = Outfitter_WearingOutfit(gOutfitter_OutfitToRename);
			
			if vWearingOutfit then
				Outfitter_DispatchOutfitEvent("UNWEAR_OUTFIT", gOutfitter_OutfitToRename.Name, gOutfitter_OutfitToRename)
			end
			
			gOutfitter_OutfitToRename.Name = vName;
			Outfitter.DisplayIsDirty = true;

			if vWearingOutfit then
				Outfitter_DispatchOutfitEvent("WEAR_OUTFIT", gOutfitter_OutfitToRename.Name, gOutfitter_OutfitToRename)
			end
		else
			-- New outift
			
			local	vStatID = UIDropDownMenu_GetSelectedValue(OutfitterNameOutfitDialogCreateUsing);
			local	vOutfit;
			
			if not vStatID
			or vStatID == 0 then
				vOutfit = Outfitter_GetInventoryOutfit(vName);
			elseif vStatID == "EMPTY" then
				vOutfit = Outfitter_NewEmptyOutfit(vName);
			else
				vOutfit = Outfitter_GenerateSmartOutfit(vName, vStatID, OutfitterItemList_GetEquippableItems(true));
			end
			
			if not vOutfit then
				vOutfit = Outfitter_NewEmptyOutfit(vName);
			end
			
			local	vCategoryID = Outfitter_AddOutfit(vOutfit);

			vOutfit.SlotPriority = Outfitter_cSlotNames
			-- (not yet implemented, should copy from existing outfit)
			-- modified by jtbalogh
			
			Outfitter_WearOutfit(vOutfit, vCategoryID);
		end
	end
	
	OutfitterNameOutfitDialog:Hide();
	
	Outfitter_Update(true);
end

function OutfitterNameOutfit_Cancel()
	debugmessage("OutfitterNameOutfit_Cancel",1);
	OutfitterNameOutfitDialog:Hide();
end

function OutfitterNameOutfit_Update(pCheckForStatOutfit)
	debugmessage("OutfitterNameOutfit_Update",1);
	local	vEnableDoneButton = true;
	local	vErrorMessage = nil;
	
	-- If there's no name entered then disable the okay button
	
	local	vName = OutfitterNameOutfitDialogName:GetText();
	
	if not vName
	or vName == "" then
		vEnableDoneButton = false;
	else
		local	vOutfit = Outfitter_FindOutfitByName(vName);
		
		if vOutfit
		and vOutfit ~= gOutfitter_OutfitToRename then
			vErrorMessage = Outfitter_cNameAlreadyUsedError;
			vEnableDoneButton = false;
		end
	end
	
	-- 
	
	if not vErrorMessage
	and pCheckForStatOutfit then
		local	vStatID = UIDropDownMenu_GetSelectedValue(OutfitterNameOutfitDialogCreateUsing);
		
		if vStatID
		and vStatID ~= 0
		and vStatID ~= "EMPTY" then
			local	vOutfit = Outfitter_GenerateSmartOutfit("temp outfit", vStatID, OutfitterItemList_GetEquippableItems(true));
			
			if not vOutfit
			or Outfitter_IsEmptyOutfit(vOutfit) then
				vErrorMessage = Outfitter_cNoItemsWithStatError;
			end
		end
	end
	
	if vErrorMessage then
		OutfitterNameOutfitDialogError:SetText(vErrorMessage);
		OutfitterNameOutfitDialogError:Show();
	else
		OutfitterNameOutfitDialogError:Hide();
	end
	
	Outfitter_SetButtonEnable(OutfitterNameOutfitDialogDoneButton, vEnableDoneButton);
end

function Outfitter_SetButtonEnable(pButton, pEnabled)
	debugmessage("Outfitter_SetButtonEnable",1);
	if pEnabled then
		pButton:Enable();
		pButton:SetAlpha(1.0);
		pButton:EnableMouse(true);
		--getglobal(pButton:GetName().."Text"):SetAlpha(1.0);
	else
		pButton:Disable();
		pButton:SetAlpha(0.7);
		pButton:EnableMouse(false);
		--getglobal(pButton:GetName().."Text"):SetAlpha(0.7);
	end
end

function Outfitter_GetOutfitFromListItem(pItem)
	debugmessage("Outfitter_GetOutfitFromListItem",1);
	if pItem.isCategory then
		return nil;
	end
	
	if not gOutfitter_Settings.Outfits then
		return nil;
	end
	
	local	vOutfits = gOutfitter_Settings.Outfits[pItem.categoryID];
	
	if not vOutfits then
		-- Error: outfit category not found
		return nil;
	end
	
	return vOutfits[pItem.outfitIndex], pItem.categoryID;
end

-- Fired At Logon to Remove any class spercific Outfits remove previosuly
function Outfitter_DisableClassOutfits()
	debugmessage("Outfitter_DisableClassOutfits",1);
	local EffectedOutfit = nil;
	local	vClassName = Outfitter_cNormalizedClassName[UnitClass("player")];

	debugmessage("Disable Class Outfits, Class: "..vClassName, 1);

	if vClassName == "Warrior" then
		if gOutfitter_Settings.DisableWarriorBattle then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Battle");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		
		if gOutfitter_Settings.DisableWarriorDefensive then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Defensive");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableWarriorBerserker then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Berserker");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
	end
	
	if vClassName == "Druid" then
		if gOutfitter_Settings.DisableDruidBear then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Bear");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidCat then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Cat");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidAquatic then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Aquatic");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidTravel then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Travel");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidMoonkin then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Moonkin");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidTree then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Tree");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidProwl then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Prowl");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidFlight then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Flight");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableDruidSwiftFlight then
				EffectedOutfit = Outfitter_GetSpecialOutfit("SwiftFlight");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
	end
	
	if vClassName == "Priest" then
		if gOutfitter_Settings.DisablePriestShadowform then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Shadowform");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
	end
	
	if vClassName == "Rogue" then
		if gOutfitter_Settings.DisableRogueStealth then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Stealth");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
	end
	
	if vClassName == "Shaman" then
		if gOutfitter_Settings.DisableShamanGhostWolf then
				EffectedOutfit = Outfitter_GetSpecialOutfit("GhostWolf");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
	end
	
	if vClassName == "Hunter" then
		if gOutfitter_Settings.DisableHunterMonkey then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Monkey");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableHunterHawk then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Hawk");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableHunterCheetah then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Cheetah");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableHunterPack then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Pack");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableHunterBeast then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Beast");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableHunterWild then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Wild");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
		if gOutfitter_Settings.DisableHunterViper then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Viper");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
	end

	if vClassName == "Mage" then
		if gOutfitter_Settings.DisableMageEvocate then
				EffectedOutfit = Outfitter_GetSpecialOutfit("Evocate");
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
		end
	end
end


-- Fired when a user click on the "Menu Item" under the "Display Outfits" category.
-- it switched the flag (Disabled or Enabled) and then Removes or Re-creates the Outfit.
function Outfitter_DisableOutfitsCheck(pValue)
		debugmessage("Outfitter_DisableOutfitsCheck",1);
		local	vEquippableItems = OutfitterItemList_GetEquippableItems();
		local EffectedOutfit = Outfitter_GetSpecialOutfit(pValue);
		
		debugmessage("Disable Outfits Check, Value: "..pValue, 1);

		-- Argent Dawn 
		if pValue == "ArgentDawn" then
			gOutfitter_Settings.DisableArgentDawn = not gOutfitter_Settings.DisableArgentDawn;

			if gOutfitter_Settings.DisableArgentDawn then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			-- Remove the Outfit
			else
				if not EffectedOutfit then
					EffectedOutfit = Outfitter_GenerateSmartOutfit(Outfitter_cArgentDawnOutfit, "ArgentDawn", vEquippableItems, true);
					EffectedOutfit.SpecialID = "ArgentDawn";
					Outfitter_AddOutfit(EffectedOutfit);
				end
			end
			
		-- Standard
		elseif pValue == "Riding" then
			gOutfitter_Settings.DisableRiding = not gOutfitter_Settings.DisableRiding;
			 
			-- Remove the Outfit
			if gOutfitter_Settings.DisableRiding then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
			-- Create the Outfit
				if not EffectedOutfit then
					EffectedOutfit = Outfitter_GenerateSmartOutfit(Outfitter_cRidingOutfit, "Riding", vEquippableItems, true);
					EffectedOutfit.SpecialID = "Riding";
					EffectedOutfit.BGDisabled = true;
					Outfitter_AddOutfit(EffectedOutfit);
				end
			end 
			
		elseif pValue == "Dining" then
			gOutfitter_Settings.DisableDining = not gOutfitter_Settings.DisableDining;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableDining then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Dining", Outfitter_cDiningOutfit);
				end
			end	
			
		elseif pValue == "Swimming" then
			gOutfitter_Settings.DisableSwimming = not gOutfitter_Settings.DisableSwimming;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableSwimming then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Swimming", Outfitter_cSwimmingOutfit);
				end
			end	
	
		elseif pValue == "City" then
			gOutfitter_Settings.DisableCity = not gOutfitter_Settings.DisableCity;
	
			-- Remove the Outfit
			if gOutfitter_Settings.DisableCity then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("City", Outfitter_cCityOutfit);
				end
			end	

		-- The Battle Grounds/Arena
		elseif pValue == "Battleground" then
			gOutfitter_Settings.DisableBattleground = not gOutfitter_Settings.DisableBattleground;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableBattleground then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Battleground", Outfitter_cBattlegroundOutfit);
				end
			end	
			
		elseif pValue == "AB" then
			gOutfitter_Settings.DisableAB = not gOutfitter_Settings.DisableAB;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableAB then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("AB", Outfitter_cABOutfit);
				end
			end	
			
		elseif pValue == "AV" then
			gOutfitter_Settings.DisableAV = not gOutfitter_Settings.DisableAV;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableAV then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("AV", Outfitter_cAVOutfit);
				end
			end	
			
		elseif pValue == "WSG" then
			gOutfitter_Settings.DisableWSG = not gOutfitter_Settings.DisableWSG;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableWSG then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("WSG", Outfitter_cWSGOutfit);
				end
			end	
			
		elseif pValue == "EotS" then
			gOutfitter_Settings.DisableEotS = not gOutfitter_Settings.DisableEotS;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableEotS then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("EotS", Outfitter_cEotSOutfit);
				end
			end	
			
		elseif pValue == "Arena" then
			gOutfitter_Settings.DisableArena = not gOutfitter_Settings.DisableArena;

			-- Remove the Outfit
			if gOutfitter_Settings.DisableArena then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);

			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Arena", Outfitter_cArenaOutfit);
				end
			end	
			
		elseif pValue == "Battle" then
			gOutfitter_Settings.DisableWarriorBattle = not gOutfitter_Settings.DisableWarriorBattle;

			-- Remove the Outfit
			if DisableWarriorBattle then
					Outfitter_DeleteOutfit(EffectedOutfit);	
					Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Battle", Outfitter_cWarriorBattleStance);
				end
			end
		
		elseif pValue == "Defensive" then
			gOutfitter_Settings.DisableWarriorDefensive = not gOutfitter_Settings.DisableWarriorDefensive;

			-- Remove the Outfit
			if DisableWarriorDefensive then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Defensive", Outfitter_cWarriorDefensiveStance);
				end
			end
		
		elseif pValue == "Berserker" then
			gOutfitter_Settings.DisableWarriorBerserker = not gOutfitter_Settings.DisableWarriorBerserker;

			-- Remove the Outfit
			if DisableWarriorBerserker then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Berserker", Outfitter_cWarriorBerserkerStance);
				end
			end
		
		elseif pValue == "Bear" then
			gOutfitter_Settings.DisableDruidBear = not gOutfitter_Settings.DisableDruidBear;

			-- Remove the Outfit
			if DisableDruidBear then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Bear", Outfitter_cDruideBearForm);
				end
			end
		
		elseif pValue == "Cat" then
			gOutfitter_Settings.DisableDruidCat = not gOutfitter_Settings.DisableDruidCat;

			-- Remove the Outfit
			if DisableDruidCat then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Cat", Outfitter_cDruidCatForm);
				end
			end
		
		elseif pValue == "Aquatic" then
			gOutfitter_Settings.DisableDruidAquatic = not gOutfitter_Settings.DisableDruidAquatic;

			-- Remove the Outfit
			if DisableDruidAquatic then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Aquatic", Outfitter_cDruidAquaticForm);
				end
			end
		
		elseif pValue == "Travel" then
			gOutfitter_Settings.DisableDruidTravel = not gOutfitter_Settings.DisableDruidTravel;

			-- Remove the Outfit
			if DisableDruidTravel then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Travel", Outfitter_cDruidTravelForm);
				end
			end
		
		elseif pValue == "Moonkin" then
			gOutfitter_Settings.DisableDruidMoonkin = not gOutfitter_Settings.DisableDruidMoonkin;

			-- Remove the Outfit
			if DisableDruidMoonkin then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Moonkin", Outfitter_cDruidMoonkinForm);
				end
			end
		
		elseif pValue == "Tree" then
			gOutfitter_Settings.DisableDruidTree = not gOutfitter_Settings.DisableDruidTree;

			-- Remove the Outfit
			if DisableDruidTree then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Tree", Outfitter_cDruidTreeForm);
				end
			end
		
		elseif pValue == "Prowl" then
			gOutfitter_Settings.DisableDruidProwl = not gOutfitter_Settings.DisableDruidProwl;

			-- Remove the Outfit
			if DisableDruidProwl then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Prowl", Outfitter_cDruidProwl);
				end
			end
		
		elseif pValue == "Flight" then
			gOutfitter_Settings.DisableDruidFlight = not gOutfitter_Settings.DisableDruidFlight;

			-- Remove the Outfit
			if DisableDruidFlight then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Flight", Outfitter_cDruidFlightForm);
				end
			end
		
		elseif pValue == "SwiftFlight" then
			gOutfitter_Settings.DisableDruidSwiftFlight = not gOutfitter_Settings.DisableDruidSwiftFlight;

			-- Remove the Outfit
			if DisableDruidSwiftFlight then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("SwiftFlight", Outfitter_cDruidSwiftFlightForm);
				end
			end
		
		elseif pValue == "Shadowform" then
			gOutfitter_Settings.DisablePriestShadowform = not gOutfitter_Settings.DisablePriestShadowform;

			-- Remove the Outfit
			if DisablePriestShadowform then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Shadowform", Outfitter_cPriestShadowform);
				end
			end
		
		elseif pValue == "Stealth" then
			gOutfitter_Settings.DisableRogueStealth = not gOutfitter_Settings.DisableRogueStealth;

			-- Remove the Outfit
			if DisableRogueStealth then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Stealth", Outfitter_cRogueStealth);
				end
			end
		
		elseif pValue == "GhostWolf" then
			gOutfitter_Settings.DisableShamanGhostWolf = not gOutfitter_Settings.DisableShamanGhostWolf;

			-- Remove the Outfit
			if DisableShamanGhostWolf then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("GhostWolf", Outfitter_cShamanGhostWolf);
				end
			end
		
		elseif pValue == "Monkey" then
			gOutfitter_Settings.DisableHunterMonkey = not gOutfitter_Settings.DisableHunterMonkey;

			-- Remove the Outfit
			if DisableHunterMonkey then 
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Monkey", Outfitter_cHunterMonkey);
				end
			end
		
		elseif pValue == "Hawk" then
			gOutfitter_Settings.DisableHunterHawk = not gOutfitter_Settings.DisableHunterHawk;

			-- Remove the Outfit
			if DisableHunterHawk then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Hawk", Outfitter_cHunterHawk);
				end
			end
		
		elseif pValue == "Cheetah" then
			gOutfitter_Settings.DisableHunterCheetah = not gOutfitter_Settings.DisableHunterCheetah;

			-- Remove the Outfit
			if DisableHunterCheetah then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Cheetah", Outfitter_cHunterCheetah);
				end
			end
		
		elseif pValue == "Pack" then
			gOutfitter_Settings.DisableHunterPack = not gOutfitter_Settings.DisableHunterPack;

			-- Remove the Outfit
			if DisableHunterPack then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Pack", Outfitter_cHunterPack);
				end
			end
		
		elseif pValue == "Beast" then
			gOutfitter_Settings.DisableHunterBeast = not gOutfitter_Settings.DisableHunterBeast;

			-- Remove the Outfit
			if DisableHunterBeast then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Beast", Outfitter_cHunterBeast);
				end
			end
		
		elseif pValue == "Wild" then
			gOutfitter_Settings.DisableHunterWild = not gOutfitter_Settings.DisableHunterWild;

			-- Remove the Outfit
			if DisableHunterWild then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Wild", Outfitter_cHunterWild);
				end
			end
		
		elseif pValue == "Viper" then
			gOutfitter_Settings.DisableHunterViper = not gOutfitter_Settings.DisableHunterViper;

			-- Remove the Outfit
			if DisableHunterViper then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Viper", Outfitter_cHunterViper);
				end
			end
		
		elseif pValue == "Evocate" then
			gOutfitter_Settings.DisableMageEvocate = not gOutfitter_Settings.DisableMageEvocate;

			-- Remove the Outfit
			if DisableMageEvocate then
				Outfitter_DeleteOutfit(EffectedOutfit);	
				Outfitter_Update(true);
			else
				-- Create the Outfit
				if not EffectedOutfit then
					Outfitter_CreateEmptySpecialOccasionOutfit("Evocate", Outfitter_cMageEvocate);
				end
			end
			
		end -- Ends the Main IF tree.
					
end -- ends the function

function Outfitter_OutfitItemSelected(pMenu, pValue)
	debugmessage("Outfitter_OutfitItemSelected",1);
	local	vItem = pMenu:GetParent():GetParent();
	local	vOutfit, vCategoryID = Outfitter_GetOutfitFromListItem(vItem);

	debugmessage("Outfit Item Selected Category Id: "..vItem.categoryID, 1);
	
	if(vItem.categoryID == -99) then
		debugmessage("Selected Display/Disable Special Outfit.", 1);
		
		Outfitter_DisableOutfitsCheck(pValue)

		return;
	end

	if not vOutfit then
		MCDebugLib:ErrorMessage("Outfitter Error: Outfit for menu item "..vItem:GetName().." not found");
		return;
	end

	-- Perform the selected action	
	if pValue == "DELETE" then
		Outfitter_AskDeleteOutfit(vOutfit);
	elseif pValue == "RENAME" then
		OutfitterNameOutfit_Open(vOutfit);
	elseif pValue == "EDIT_SCRIPT" then
		OutfitterEditScriptDialog:Open(vOutfit);
	elseif pValue == "DISABLE_SCRIPT" then
		vOutfit.DisableScript = not vOutfit.DisableScript;
		if vOutfit.DisableScript then
			Outfitter_DeactivateScript(vOutfit);
		else
			Outfitter_ActivateScript(vOutfit);
		end
	elseif pValue == "DISABLE" then
		if vOutfit.Disabled then
			vOutfit.Disabled = nil;
			Outfitter_ActivateScript(vOutfit);
		else
			vOutfit.Disabled = true;
			Outfitter_DeactivateScript(vOutfit);
		end
		Outfitter.DisplayIsDirty = true;
		
	elseif pValue == "ITEMLISTBOX" then
		if vOutfit.Enabled ~= nil then
			vOutfit.Enabled = nil;
		else
			vOutfit.Enabled = true;
		end
		
		-- Show or HIDE the Listbox stuff.
		if vOutfit.Enabled then
			Outfitter_Arrange_ListBoxOuterFrame:Show()
			Outfitter_Arrange_ListBox:Show()
			Outfitter_Arrange_ButtonUp:Show()
			Outfitter_Arrange_ButtonDown:Show()
			Outfitter_Arrange_ButtonReset:Show()
		else
			Outfitter_Arrange_ListBoxOuterFrame:Hide()
			Outfitter_Arrange_ListBox:Hide()
			Outfitter_Arrange_ButtonUp:Hide()
			Outfitter_Arrange_ButtonDown:Hide()
			Outfitter_Arrange_ButtonReset:Hide()
		end
		
		-- Repaint the options.
		Outfitter.DisplayIsDirty = true;
		
	elseif pValue == "SHOWHELM" then
		if vOutfit.ShowHelm ~= nil then
			vOutfit.ShowHelm = nil;
			vOutfit.HideHelm = nil;
		else
			vOutfit.ShowHelm = true;
			vOutfit.HideHelm = nil;
		end

		-- Now set the correct Helm and Cloak settings.
		Outfitter_CheckHelmAndCloak();
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "HIDEHELM" then
		if vOutfit.HideHelm ~= nil then
			vOutfit.ShowHelm = nil;
			vOutfit.HideHelm = nil;
		else
			vOutfit.HideHelm = true;
			vOutfit.ShowHelm = nil;
		end

		-- Now set the correct Helm and Cloak settings.
		Outfitter_CheckHelmAndCloak();
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "SHOWCLOAK" then
		if vOutfit.ShowCloak ~= nil then
			vOutfit.ShowCloak = nil;
			vOutfit.HideCloak = nil;		
		else
			vOutfit.ShowCloak = true;
			vOutfit.HideCloak = nil;		
		end
		
		-- Now set the correct Helm and Cloak settings.
		Outfitter_CheckHelmAndCloak();
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "HIDECLOAK" then
		if vOutfit.HideCloak ~= nil then
			vOutfit.ShowCloak = nil;
			vOutfit.HideCloak = nil;		
		else
			vOutfit.HideCloak = true;		
			vOutfit.ShowCloak = nil;
		end

		-- Now set the correct Helm and Cloak settings.
		Outfitter_CheckHelmAndCloak();
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "BGDISABLE" then
		if vOutfit.BGDisabled then
			vOutfit.BGDisabled = nil;
		else
			vOutfit.BGDisabled = true;
		end
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "AQDISABLE" then
		if vOutfit.AQDisabled then
			vOutfit.AQDisabled = nil;
		else
			vOutfit.AQDisabled = true;
		end
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "NAXXDISABLE" then
		if vOutfit.NaxxDisabled then
			vOutfit.NaxxDisabled = nil;
		else
			vOutfit.NaxxDisabled = true;
		end
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "COMBATDISABLE" then
		if vOutfit.CombatDisabled then
			vOutfit.CombatDisabled = nil;
		else
			vOutfit.CombatDisabled = true;
		end
		Outfitter.DisplayIsDirty = true;
	elseif pValue == "ACCESSORY" then
		vOutfit.IsAccessory = true;
		Outfitter_UpdateOutfitCategory(vOutfit);
	elseif pValue == "PARTIAL" then
		vOutfit.IsAccessory = false;
		Outfitter_UpdateOutfitCategory(vOutfit);
	elseif string.sub(pValue, 1, 8) == "BINDING_" then
		local	vBindingIndex = string.sub(pValue, 9);
		
		if vBindingIndex == "NONE" then
			Outfitter_SetOutfitBindingIndex(vOutfit, nil);
		else
			Outfitter_SetOutfitBindingIndex(vOutfit, tonumber(vBindingIndex));
		end
	elseif pValue == "REBUILD" then
		Outfitter_AskRebuildOutfit(vOutfit, vCategoryID);
	elseif pValue == "SET_CURRENT" then
		Outfitter_AskSetCurrent(vOutfit, vCategoryID);
	elseif pValue == "DEPOSIT" then
		Outfitter_DepositOutfit(vOutfit);
	elseif pValue == "DEPOSITUNIQUE" then
		Outfitter_DepositOutfit(vOutfit, true);
	elseif pValue == "WITHDRAW" then
		Outfitter_WithdrawOutfit(vOutfit);
	end
	
	Outfitter_Update(true);
end

function OutfitterPresetScriptDropdown_OnLoad()
	debugmessage("OutfitterPresetScriptDropdown_OnLoad",1);
	UIDropDownMenu_Initialize(this, OutfitterPresetScriptDropdown_Initialize);
	UIDropDownMenu_SetWidth(150);
	UIDropDownMenu_Refresh(this);

	this.ChangedValueFunc = OutfitterPresetScriptDropdown_ChangedValue;
end

function OutfitterPresetScriptDropdown_ChangedValue(pFrame, pValue)
	debugmessage("OutfitterPresetScriptDropdown_ChangedValue",1);
	pFrame.Dialog:SetPresetScriptID(pValue);
end

function OutfitterPresetScriptDropdown_Initialize()
	debugmessage("OutfitterPresetScriptDropdown_Initialize",1);
	local	vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	
	UIDropDownMenu_AddButton({
		text = Outfitter_cCustomScript,
		value = "CUSTOM",
		owner = vFrame,
		func = OutfitterDropDown_OnClick
	}, UIDROPDOWNMENU_MENU_LEVEL);
	
	local	_, vPlayerClass = UnitClass("player");
	
	for _, vPresetScript in ipairs(gOutfitter_PresetScripts) do
		if not vPresetScript.Class
		or vPresetScript.Class == vPlayerClass then
			UIDropDownMenu_AddButton({
				text = vPresetScript.Name,
				value = vPresetScript.ID,
				owner = vFrame,
				func = OutfitterDropDown_OnClick
			}, UIDROPDOWNMENU_MENU_LEVEL);
		end
	end
end

function OutfitterEditScriptDialog_OnLoad(pDialog)
	debugmessage("OutfitterEditScriptDialog_OnLoad",1);
	Outfitter_InitializeFrameMethods(pDialog,
	{
		Open = OutfitterEditScriptDialog_Open,
		Close = OutfitterEditScriptDialog_Close,
		Done = OutfitterEditScriptDialog_Done,
		Cancel = OutfitterEditScriptDialog_Close,
		CheckScriptErrors = OutfitterEditScriptDialog_CheckScriptErrors,
		SetPresetScriptID = OutfitterEditScriptDialog_SetPresetScriptID,
		SetPanelIndex = OutfitterEditScriptDialog_SetPanelIndex,
		ConstructSettingsFields = OutfitterEditScriptDialog_ConstructSettingsFields,
		GetScriptSettings = OutfitterEditScriptDialog_GetScriptSettings,
		SetScriptSettings = OutfitterEditScriptDialog_SetScriptSettings,
	});
	
	Outfitter_InitializeFrameWidgets(pDialog,
	{
		"Title",
		"Source",
		"Settings",
		"SourceEvents",
		"SettingsDescription",
		"SourceScriptEditBox",
		"SourceStatusMessage",
		"PresetScript",
	});
	
	pDialog.SourceScriptEditBox.Dialog = pDialog;
	pDialog.SourceScriptEditBox.TextChanged = OutfitterEditorScript_TextChanged;
	
	pDialog.PresetScript.Dialog = pDialog;

	-- Tabs
	
	PanelTemplates_SetNumTabs(pDialog, 2);
	pDialog.selectedTab = 1;
	PanelTemplates_UpdateTabs(this);
	
	-- Setting frames
	
	pDialog.FrameCache = {};
end

function OutfitterEditScriptDialog_Open(pDialog, pOutfit)
	debugmessage("OutfitterEditScriptDialog_Open",1);
	pDialog.Outfit = pOutfit;
	
	pDialog.Title:SetText(string.format(Outfitter_cEditScriptTitle, pOutfit.Name));
	
	local	vScript, vScriptEvents = Outfitter_GetScript(pOutfit);
	
	if vScriptEvents then
		pDialog.SourceEvents:SetText(vScriptEvents);
	else
		pDialog.SourceEvents:SetText("");
	end
	
	if vScript then
		pDialog.SourceScriptEditBox:SetText(vScript);
	else
		pDialog.SourceScriptEditBox:SetText("");
	end
	
	-- Copy the script values
	
	pDialog.ScriptSettings = {};
	
	if pDialog.Outfit.ScriptSettings then
		for vKey, vValue in pairs(pDialog.Outfit.ScriptSettings) do
			pDialog.ScriptSettings[vKey] = vValue;
		end
	end
	
	pDialog:SetPresetScriptID(Outfitter_FindMatchingPresetScriptID(vScriptEvents, vScript));
	
	--
	
	pDialog:SetPanelIndex(1); -- Show the settings panel
	
	pDialog:Show();
	
	Outfitter_DialogOpened(pDialog);
end

function OutfitterEditScriptDialog_Close(pDialog)
	debugmessage("OutfitterEditScriptDialog_Close",1);
	MCSchedulerLib:UnscheduleTask(pDialog.CheckScriptErrors, pDialog);
	
	pDialog.Outfit = nil;
	pDialog:Hide();
	
	Outfitter_DialogClosed(pDialog);
end

function OutfitterEditScriptDialog_Done(pDialog)
	debugmessage("OutfitterEditScriptDialog_Done",1);
	-- Save the script
	
	local	vEvents = string.upper(pDialog.SourceEvents:GetText());
	local	vScript = pDialog.SourceScriptEditBox:GetText();
	local	vScriptID = Outfitter_FindMatchingPresetScriptID(vEvents, vScript);
	
	if vScriptID then
		Outfitter_SetScriptID(pDialog.Outfit, vScriptID);
	else
		Outfitter_SetScript(pDialog.Outfit, vEvents, vScript);
	end
	
	-- Save the settings
	
	pDialog.Outfit.ScriptSettings = pDialog:GetScriptSettings();
	
	--
	
	pDialog:Close();
end

function OutfitterEditScriptDialog_CheckScriptErrors(pDialog)
	debugmessage("OutfitterEditScriptDialog_CheckScriptErrors",1);
	local	vEvents = string.upper(pDialog.SourceEvents:GetText());
	local	vScript = pDialog.SourceScriptEditBox:GetText();
	
	local	vScriptFields, vMessage = Outfitter_ParseScriptFields(vScript);
	
	if not vMessage then
		_, vMessage = Outfitter_LoadOutfitScript(vScript);
	end
	
	if vMessage then
		pDialog.SourceStatusMessage:SetText(vMessage);
	else
		pDialog.SourceStatusMessage:SetText("OK");
	end
	
	pDialog:SetPresetScriptID(Outfitter_FindMatchingPresetScriptID(vEvents, vScript));
end

function OutfitterEditScriptDialog_SetPresetScriptID(pDialog, pID)
	debugmessage("OutfitterEditScriptDialog_SetPresetScriptID",1);
	local	vPresetScript = Outfitter_GetPresetScriptByID(pID);
	
	if not vPresetScript then
		OutfitterDropDown_SetSelectedValue(pDialog.PresetScript, "CUSTOM");
		return;
	end
	
	OutfitterDropDown_SetSelectedValue(pDialog.PresetScript, pID);
	
	pDialog.SourceEvents:SetText(vPresetScript.Events);
	pDialog.SourceScriptEditBox:SetText(vPresetScript.Script);

	local	vScriptFields, vMessage = Outfitter_ParseScriptFields(vPresetScript.Script);
	
	if vScriptFields then
		pDialog:ConstructSettingsFields(vScriptFields);
	end
end

function OutfitterEditScriptDialog_SetPanelIndex(pDialog, pIndex)
	debugmessage("OutfitterEditScriptDialog_SetPanelIndex",1);
	if pIndex == 1 then
		local	vScript = pDialog.SourceScriptEditBox:GetText();
		local	vScriptFields, vMessage = Outfitter_ParseScriptFields(vScript);
		
		if not vMessage then
			pDialog:ConstructSettingsFields(vScriptFields);
		end
		
		pDialog.Settings:Show();
		pDialog.Source:Hide();
	else
		pDialog.ScriptSettings = pDialog:GetScriptSettings();
		
		pDialog.Settings:Hide();
		pDialog.Source:Show();
	end
	
	PanelTemplates_SetTab(pDialog, pIndex);
end

function OutfitterEditScriptDialog_ConstructSettingsFields(pDialog, pSettings)
	debugmessage("OutfitterEditScriptDialog_ConstructSettingsFields",1);
	-- MCDebugLib:DumpArray("ConstructSettingsFields", pSettings);
	
	local	vNumFramesUsed = {};
	
	pDialog.SettingsFrames = {};
	
	-- Hide and de-anchor all frames
	
	for vFrameType, vFrames in pairs(pDialog.FrameCache) do
		for _, vFrame in ipairs(vFrames) do
			vFrame:ClearAllPoints();
			vFrame:Hide();
		end
		
		vNumFramesUsed[vFrameType] = 0;
	end
	
	--
	
	local	vPreviousFrame = nil;
	
	local	vFrameTypes =
	{
		StringTable = "ScrollableEditBox",
		String = "EditBox",
		Number = "EditBox",
		ZoneList = "ZoneListEditBox",
	};
	
	pDialog.SettingsDescription:SetText(pSettings.Description or "");
	
	if pSettings.Inputs then
		for _, vDescriptor in ipairs(pSettings.Inputs) do
			local	vFrameType = vFrameTypes[vDescriptor.Type];
			
			if not vFrameType then
				MCDebugLib:ErrorMessage("No frame type found for input type "..vDescriptor.Type);
				break;
			end
			
			if not vNumFramesUsed[vFrameType] then
				vNumFramesUsed[vFrameType] = 0;
			end
			
			local	vFrameIndex = vNumFramesUsed[vFrameType] + 1;
			local	vFrame;
			
			-- Create a new frame if needed
			
			local	vFrameCache = pDialog.FrameCache[vFrameType];
			
			if not vFrameCache then
				vFrameCache = {};
				pDialog.FrameCache[vFrameType] = vFrameCache;
			end
			
			vFrame = vFrameCache[vFrameIndex];
			
			if not vFrame then
				local	vFrameName = pDialog.Settings:GetName()..vFrameType..vFrameIndex;
				
				-- MCDebugLib:TestMessage("Creating frame "..vFrameName);
				
				if vFrameType == "ScrollableEditBox" then
					vFrame = CreateFrame("ScrollFrame", vFrameName, pDialog.Settings, "OutfitterScrollableEditBox");
					vFrame:SetWidth(300);
					vFrame:SetHeight(80);
				elseif vFrameType == "EditBox" then
					vFrame = CreateFrame("EditBox", vFrameName, pDialog.Settings, "OutfitterInputBoxTemplate");
					vFrame:SetWidth(300);
					vFrame:SetHeight(18);
				elseif vFrameType == "ZoneListEditBox" then
					vFrame = CreateFrame("ScrollFrame", vFrameName, pDialog.Settings, "OutfitterZoneListEditBox");
					vFrame:SetWidth(180);
					vFrame:SetHeight(80);
				end
				
				if vFrame then
					vFrameCache[vFrameIndex] = vFrame;
				end
			end
			
			if vFrame then
				table.insert(pDialog.SettingsFrames, vFrame);
				
				vFrame.Descriptor = vDescriptor;
				
				-- Position the frame
				
				if not vPreviousFrame then
					vFrame:SetPoint("TOPLEFT", pDialog.SettingsDescription, "BOTTOMLEFT", 0, -15);
				else
					vFrame:SetPoint("TOPLEFT", vPreviousFrame, "BOTTOMLEFT", 0, -15);
				end
				
				vPreviousFrame = vFrame;
				vNumFramesUsed[vFrameType] = vFrameIndex;
				
				-- Set the label
				
				local	vLabelText = getglobal(vFrame:GetName().."Label");
				
				vLabelText:SetText(vDescriptor.Label..":");
				
				-- Set the zone type if it's a zone list
				
				if vFrameType == "ZoneListEditBox" then
					local	vType = vDescriptor.ZoneType;
					
					if not vType then
						vType = "Zone";
					end
					
					local	vZoneButton = getglobal(vFrame:GetName().."ZoneButton");
					
					vZoneButton.GetTextFunc = getglobal("Get"..vType.."Text");
					vZoneButton:SetText(string.format(Outfitter_cInsertFormat, vZoneButton.GetTextFunc()));
				end
				
				-- Show it
				
				vFrame:Show();
			end
		end
	end
	
	pDialog:SetScriptSettings();
end

function OutfitterEditScriptDialog_GetScriptSettings(pDialog)
	debugmessage("OutfitterEditScriptDialog_GetScriptSettings",1);
	local	vSettings = {};
	
	if pDialog.SettingsFrames then
		for _, vFrame in ipairs(pDialog.SettingsFrames) do
			local	vValue;
			
			if vFrame.Descriptor.Type == "String" then
				vValue = vFrame:GetText();
			
			elseif vFrame.Descriptor.Type == "Number" then
				vValue = tonumber(vFrame:GetText());
			
			elseif vFrame.Descriptor.Type == "StringTable"
			or vFrame.Descriptor.Type == "ZoneList" then
				local	vEditBox = getglobal(vFrame:GetName().."EditBox");
				
				vValue = {};
				
				for vLine in string.gmatch(vEditBox:GetText(), "([^\r\n]*)") do
					if string.len(vLine) > 0 then
						table.insert(vValue, vLine);
					end
				end
			end
			
			vSettings[vFrame.Descriptor.Field] = vValue;
		end
	end
	
	-- MCDebugLib:DumpArray("GetScriptSettings", vSettings);
	
	return vSettings;
end

function OutfitterEditScriptDialog_SetScriptSettings(pDialog)
	debugmessage("OutfitterEditScriptDialog_SetScriptSettings",1);
	if not pDialog.SettingsFrames then
		return;
	end
	
	-- MCDebugLib:DumpArray("SetScriptSettings", pDialog.ScriptSettings);
	-- MCDebugLib:DumpArray("SettingsFrames", pDialog.SettingsFrames);
	
	for _, vFrame in ipairs(pDialog.SettingsFrames) do
		local	vValue = pDialog.ScriptSettings[vFrame.Descriptor.Field];
		
		if vFrame.Descriptor.Type == "String"
		or vFrame.Descriptor.Type == "Number" then
			if vValue ~= nil then
				vFrame:SetText(vValue);
			else
				vFrame:SetText(gOutfitter_DefaultSettingValues[vFrame.Descriptor.Type]);
			end
		
		elseif vFrame.Descriptor.Type == "StringTable"
		or vFrame.Descriptor.Type == "ZoneList" then
			local	vEditBox = getglobal(vFrame:GetName().."EditBox");
			
			if type(vValue) == "table" then
				vEditBox:SetText(table.concat(vValue, "\n"));
			else
				vEditBox:SetText("");
			end
		end
	end
end

function Outfitter_GetPresetScriptByID(pID)
	debugmessage("Outfitter_GetPresetScriptByID",1);
	for _, vPresetScript in ipairs(gOutfitter_PresetScripts) do
		if vPresetScript.ID == pID then
			return vPresetScript;
		end
	end
end

function Outfitter_FindMatchingPresetScriptID(pEvents, pScript)
	debugmessage("Outfitter_FindMatchingPresetScriptID",1);
	for _, vPresetScript in ipairs(gOutfitter_PresetScripts) do
		if vPresetScript.Events == pEvents
		and vPresetScript.Script == pScript then
			return vPresetScript.ID;
		end
	end
end

function OutfitterEditorScript_TextChanged(pEditBox)
	debugmessage("OutfitterEditorScript_TextChanged",1);
	local	vDialog = pEditBox.Dialog;
	
	vDialog.SourceStatusMessage:SetText(Outfitter_cTyping);
	
	MCSchedulerLib:UnscheduleTask(vDialog.CheckScriptErrors, vDialog);
	MCSchedulerLib:ScheduleTask(1, vDialog.CheckScriptErrors, vDialog);
end

function OutfitterStatDropdown_OnLoad()
	debugmessage("OutfitterStatDropdown_OnLoad",1);
	UIDropDownMenu_Initialize(this, OutfitterStatDropdown_Initialize);
	UIDropDownMenu_SetWidth(150);
	UIDropDownMenu_Refresh(this);
end

function Outfitter_GetStatIDName(pStatID)
	debugmessage("Outfitter_GetStatIDName",1);
	for vStatIndex, vStatInfo in ipairs(Outfitter_cItemStatInfo) do
		if vStatInfo.ID == pStatID then
			return vStatInfo.Name;
		end
	end
	
	return nil;
end

function OutfitterStatDropdown_Initialize()
	debugmessage("OutfitterStatDropdown_Initialize",1);
	local	vFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	
	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		for vStatIndex, vStatInfo in ipairs(Outfitter_cItemStatInfo) do
			if vStatInfo.Category == UIDROPDOWNMENU_MENU_VALUE then
				UIDropDownMenu_AddButton({text = vStatInfo.Name, value = vStatInfo.ID, owner = vFrame, func = OutfitterDropDown_OnClick}, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	else
		UIDropDownMenu_AddButton({text = Outfitter_cUseCurrentOutfit, value = 0, owner = vFrame, func = OutfitterDropDown_OnClick});
		UIDropDownMenu_AddButton({text = Outfitter_cUseEmptyOutfit, value = "EMPTY", owner = vFrame, func = OutfitterDropDown_OnClick});
		
		UIDropDownMenu_AddButton({text = " ", notCheckable = true, notClickable = true});
		
		for vCategoryIndex, vCategoryInfo in ipairs(Outfitter_cStatCategoryInfo) do
			UIDropDownMenu_AddButton({text = vCategoryInfo.Name, owner = vFrame, hasArrow = 1, value = vCategoryInfo.Category});
		end
		
		if false and IsAddOnLoaded("TankPoints") then
			UIDropDownMenu_AddButton({text = " ", notCheckable = true, notClickable = true});
			UIDropDownMenu_AddButton({text = Outfitter_cTankPoints, value="TANKPOINTS", owner = vFrame, func = OutfitterDropDown_OnClick});
		end
	end
end

function OutfitterDropDown_SetSelectedValue(pDropDown, pValue)
	debugmessage("OutfitterDropDown_SetSelectedValue",1);
	UIDropDownMenu_SetText("", pDropDown); -- Set to empty in case the selected value isn't there

	UIDropDownMenu_Initialize(pDropDown, pDropDown.initialize);
	UIDropDownMenu_SetSelectedValue(pDropDown, pValue);
	
	-- All done if the item text got set successfully
	
	local	vItemText = UIDropDownMenu_GetText(pDropDown);
	
	if vItemText and vItemText ~= "" then
		return;
	end
	
	-- Scan for submenus
	
	local	vRootListFrameName = "DropDownList1";
	local	vRootListFrame = getglobal(vRootListFrameName);
	local	vRootNumItems = vRootListFrame.numButtons;
	
	for vRootItemIndex = 1, vRootNumItems do
		local	vItem = getglobal(vRootListFrameName.."Button"..vRootItemIndex);
		
		if vItem.hasArrow then
			local	vSubMenuFrame = getglobal("DropDownList2");
			
			UIDROPDOWNMENU_OPEN_MENU = pDropDown:GetName();
			UIDROPDOWNMENU_MENU_VALUE = vItem.value;
			UIDROPDOWNMENU_MENU_LEVEL = 2;
			
			UIDropDownMenu_Initialize(pDropDown, pDropDown.initialize, nil, 2);
			UIDropDownMenu_SetSelectedValue(pDropDown, pValue);
			
			-- All done if the item text got set successfully
			
			local	vItemText = UIDropDownMenu_GetText(pDropDown);
			
			if vItemText and vItemText ~= "" then
				return;
			end
			
			-- Switch back to the root menu
			
			UIDROPDOWNMENU_OPEN_MENU = nil;
			UIDropDownMenu_Initialize(pDropDown, pDropDown.initialize, nil, 1);
		end
	end
end

function OutfitterScrollbarTrench_SizeChanged(pScrollbarTrench)
	debugmessage("OutfitterScrollbarTrench_SizeChanged",1);
	local	vScrollbarTrenchName = pScrollbarTrench:GetName();
	local	vScrollbarTrenchMiddle = getglobal(vScrollbarTrenchName.."Middle");
	
	local	vMiddleHeight= pScrollbarTrench:GetHeight() - 51;
	vScrollbarTrenchMiddle:SetHeight(vMiddleHeight);
end

function OutfitterInputBox_OnLoad(pChildDepth)
	debugmessage("OutfitterInputBox_OnLoad",1);
	if not pChildDepth then
		pChildDepth = 0;
	end
	
	local	vParent = this:GetParent();
	
	for vDepthIndex = 1, pChildDepth do
		vParent = vParent:GetParent();
	end
	
	if vParent.lastEditBox then
		this.prevEditBox = vParent.lastEditBox;
		this.nextEditBox = vParent.lastEditBox.nextEditBox;
		
		this.prevEditBox.nextEditBox = this;
		this.nextEditBox.prevEditBox = this;
	else
		this.prevEditBox = this;
		this.nextEditBox = this;
	end

	vParent.lastEditBox = this;
end

function OutfitterInputBox_TabPressed()
	debugmessage("OutfitterInputBox_TabPressed",1);
	local		vReverse = IsShiftKeyDown();
	local		vEditBox = this;
	
	for vIndex = 1, 50 do
		local	vNextEditBox;
			
		if vReverse then
			vNextEditBox = vEditBox.prevEditBox;
		else
			vNextEditBox = vEditBox.nextEditBox;
		end
		
		if vNextEditBox:IsVisible()
		and not vNextEditBox.isDisabled then
			vNextEditBox:SetFocus();
			return;
		end
		
		vEditBox = vNextEditBox;
	end
end

-- Schedules The update of an outfit.
function Outfitter_ScheduleEquipmentUpdate()
	debugmessage("Outfitter_ScheduleEquipmentUpdate",1);
	if not Outfitter.EquippedNeedsUpdate
	and not Outfitter.WeaponsNeedUpdate then
		return;
	end
	
	local	vDelay = Outfitter_cMinEquipmentUpdateInterval - (GetTime() - Outfitter.LastEquipmentUpdateTime);
	
	 if vDelay < 0.1 then
		vDelay = 0.1;
	end
	

	-- To help FIND schedule 			
	MCSchedulerLib:ScheduleUniqueTask(vDelay, Outfitter_UpdateEquippedItems);
end

function OutfitterMinimapButton_MouseDown()
	debugmessage("OutfitterMinimapButton_MouseDown",1);
	-- Remember where the cursor was in case the user drags
	
	local	vCursorX, vCursorY = GetCursorPosition();
	
	vCursorX = vCursorX / this:GetEffectiveScale();
	vCursorY = vCursorY / this:GetEffectiveScale();
	
	OutfitterMinimapButton.CursorStartX = vCursorX;
	OutfitterMinimapButton.CursorStartY = vCursorY;
	
	local	vCenterX, vCenterY = OutfitterMinimapButton:GetCenter();
	local	vMinimapCenterX, vMinimapCenterY = Minimap:GetCenter();
	
	OutfitterMinimapButton.CenterStartX = vCenterX - vMinimapCenterX;
	OutfitterMinimapButton.CenterStartY = vCenterY - vMinimapCenterY;
end

function OutfitterMinimapButton_DragStart()
	debugmessage("OutfitterMinimapButton_DragStart",1);
	MCSchedulerLib:ScheduleUniqueRepeatingTask(0, OutfitterMinimapButton_UpdateDragPosition);
end

function OutfitterMinimapButton_DragEnd()
	debugmessage("OutfitterMinimapButton_DragEnd",1);
	MCSchedulerLib:UnscheduleTask(OutfitterMinimapButton_UpdateDragPosition);
end

function OutfitterMinimapButton_UpdateDragPosition()
	debugmessage("OutfitterMinimapButton_UpdateDragPosition",1);
	-- Remember where the cursor was in case the user drags
	
	local	vCursorX, vCursorY = GetCursorPosition();
	
	vCursorX = vCursorX / this:GetEffectiveScale();
	vCursorY = vCursorY / this:GetEffectiveScale();
	
	local	vCursorDeltaX = vCursorX - OutfitterMinimapButton.CursorStartX;
	local	vCursorDeltaY = vCursorY - OutfitterMinimapButton.CursorStartY;
	
	--
	
	local	vCenterX = OutfitterMinimapButton.CenterStartX + vCursorDeltaX;
	local	vCenterY = OutfitterMinimapButton.CenterStartY + vCursorDeltaY;
	
	-- Calculate the angle
	
	-- local	vAngle = math.atan2(vCenterX, vCenterY);
	
	-- Set the new position

	OutfitterMinimapButton_SetPositionAngle(vCenterX, vCenterY);
end

function Outfitter_RestrictAngle(pAngle, pRestrictStart, pRestrictEnd)
	debugmessage("Outfitter_RestrictAngle",1);
	if pAngle <= pRestrictStart
	or pAngle >= pRestrictEnd then
		return pAngle;
	end
	
	local	vDistance = (pAngle - pRestrictStart) / (pRestrictEnd - pRestrictStart);
	
	if vDistance > 0.5 then
		return pRestrictEnd;
	else
		return pRestrictStart;
	end
end

function OutfitterMinimapButton_SetPositionAngle(vCenterX, vCenterY)
	debugmessage("OutfitterMinimapButton_SetPositionAngle",1);
	
	if (vCenterX == nil) or (vCenterY == nil) then
			vCenterX = -80;
			vCenterY = 80;
	end

	gOutfitter_Settings.Options.MinimapButtonX = vCenterX;
	gOutfitter_Settings.Options.MinimapButtonY = vCenterY;
	OutfitterMinimapButton:SetPoint("CENTER", "Minimap", "CENTER", vCenterX, vCenterY);

end

function OutfitterMinimapButton_ItemSelected(pMenu, pValue)
	debugmessage("OutfitterMinimapButton_ItemSelected",1);
	local	vType = type(pValue);

	if vType == "table" then
		local	vCategoryID = pValue.CategoryID;
		local	vIndex = pValue.Index;
		local	vOutfit = gOutfitter_Settings.Outfits[vCategoryID][vIndex];
		local	vDoToggle = vCategoryID ~= "Complete";
		
		if vDoToggle
		and Outfitter_WearingOutfit(vOutfit) then
			Outfitter_RemoveOutfit(vOutfit);
		else
			Outfitter_WearOutfit(vOutfit, vCategoryID);
		end
		
		if vDoToggle then
			return true;
		end
	else
		if pValue == 0 then -- Open Outfitter
			ShowUIPanel(CharacterFrame);
			CharacterFrame_ShowSubFrame("PaperDollFrame");
			OutfitterFrame:Show();
		end
		if pValue == -1 then -- Change AutoSwitch Value.
			--MCDebugLib:NoteMessage(HIGHLIGHT_FONT_COLOR_CODE.."/Outfitter: "..pEvent);	
			gOutfitter_Settings.Options.DisableAutoSwitch = not gOutfitter_Settings.Options.DisableAutoSwitch;
			return true;
		end
	end

	return false;
end

function ShowFrame()
		debugmessage("ShowFrame",1);
		ShowUIPanel(CharacterFrame);
		CharacterFrame_ShowSubFrame("PaperDollFrame");
		OutfitterFrame:Show();
end

function Outfitter_WearingOutfitName(pOutfitName)
	debugmessage("Outfitter_WearingOutfitName",1);
	local	vOutfit = Outfitter_FindOutfitByName(pOutfitName);
	
	return vOutfit and Outfitter_WearingOutfit(vOutfit);
end

function Outfitter_WearingOutfit(pOutfit)
	debugmessage("Outfitter_WearingOutfit",1);
	return OutfitterStack_FindOutfit(pOutfit);
end

function Outfitter_GetCurrentOutfitInfo()
	debugmessage("Outfitter_GetCurrentOutfitInfo",1);
	if not Outfitter.Initialized then
		return "", nil;
	end
	
	local	vStackLength = #Outfitter.OutfitStack;
	
	if vStackLength == 0 then
		return "", nil;
	end
	
	local	vOutfit = Outfitter.OutfitStack[vStackLength];
	
	if vOutfit and vOutfit.Name then
		return vOutfit.Name, vOutfit;
	else
		return Outfitter_cCustom, vOutfit;
	end
end

function Outfitter_CheckDatabase()
	debugmessage("Outfitter_CheckDatabase",1);
	local	vOutfit;
	
	if not gOutfitter_Settings.Version then
		local	vOutfits = gOutfitter_Settings.Outfits[vCategoryID];
		
		if gOutfitter_Settings.Outfits then
			for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
				for vIndex, vOutfit in ipairs(vOutfits) do
					if Outfitter_OutfitIsComplete(vOutfit, true) then
						Outfitter_AddOutfitItem(vOutfit, "AmmoSlot", 0, 0, "", 0);
					end
				end
			end
		end
		
		gOutfitter_Settings.Version = 1;
	end
	
	-- Versions 1 and 2 both simply add class outfits
	-- so just reinitialize those
	
	if gOutfitter_Settings.Version < 3 then
		Outfitter_InitializeClassOutfits();
		gOutfitter_Settings.Version = 3;
	end
	
	-- Version 4 sets the BGDisabled flag for the mounted outfit
	
	if gOutfitter_Settings.Version < 4 then
		local	vRidingOutfit = Outfitter_GetSpecialOutfit("Riding");
		
		if vRidingOutfit then
			vRidingOutfit.BGDisabled = true;
		end
		
		gOutfitter_Settings.Version = 4;
	end
	
	-- Version 5 adds moonkin form, just reinitialize class outfits

	if gOutfitter_Settings.Version < 5 then
		Outfitter_InitializeClassOutfits();
		gOutfitter_Settings.Version = 5;
	end
	
	-- Make sure all outfits have an associated category ID
	
	if gOutfitter_Settings.Outfits then
		for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
			for vIndex, vOutfit in ipairs(vOutfits) do
				vOutfit.CategoryID = vCategoryID;
			end
		end
	end
	
	-- Version 6 and 7 adds item sub-code and enchantment codes
	-- (7 tries to clean up failed updates from 6)
	
	if gOutfitter_Settings.Version < 7 then
		if not Outfitter_UpdateDatabaseItemCodes() then
			gOutfitter_NeedItemCodesUpdated = 5; -- Do up to five attempts at updated the item codes
		end
		
		gOutfitter_Settings.Version = 7;
	end

	-- Scan the outfits and make sure everything is in order
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vIndex, vOutfit in ipairs(vOutfits) do
			Outfitter_CheckOutfit(vOutfit);
		end
	end
	
	-- Version 7 to 8 adds Attempts to clean up HideHelm and ShowHelm Variables in the Guts.	
	if gOutfitter_Settings.Version < 8 then
		Outfitter_UpdateToVersionEight();
	end
	
end

-- Make sure our config file is up to date.
function Outfitter_UpdateToVersionEight()
	local gUpdated_Outfitter_Settings = {};

	-- Copy the relevant 
	gUpdated_Outfitter_Settings.Version 				= 8;
	gUpdated_Outfitter_Settings.Options 				= gOutfitter_Settings.Options;
	gUpdated_Outfitter_Settings.LastOutfitStack = gOutfitter_Settings.LastOutfitStack;
	gUpdated_Outfitter_Settings.DebugLevel			= gOutfitter_Settings.DebugLevel;
	gUpdated_Outfitter_Settings.Options.Debug		= gOutfitter_Settings.Options.Debug;
	gUpdated_Outfitter_Settings.Outfits					= gOutfitter_Settings.Outfits;

	-- Make sure we're up to date.
	gOutfitter_Settings = gUpdated_Outfitter_Settings;
end

function Outfitter_CheckOutfit(pOutfit)
	debugmessage("Outfitter_CheckOutfit",1);
	if not pOutfit.Name then
		pOutfit.Name = "Damaged outfit";
	end
	
	if not pOutfit.Items then
		pOutfit.Items = {};
	end
	
	for vInventorySlot, vItem in pairs(pOutfit.Items) do
		if not vItem.Code then
			vItem.Code = 0;
		end
		
		if not vItem.SubCode then
			vItem.SubCode = 0;
		end
		
		if not vItem.Name then
			vItem.Name = "";
		end
		
		if not vItem.EnchantCode then
			vItem.EnchantCode = 0;
		end
		
		if not vItem.JewelCode1 then
			vItem.JewelCode1 = 0;
		end	

		if not vItem.JewelCode2 then
			vItem.JewelCode2 = 0;
		end	
		
		if not vItem.JewelCode3 then
			vItem.JewelCode3 = 0;
		end	
		
		if not vItem.JewelCode4 then
			vItem.JewelCode4 = 0;
		end	
	end

	if not pOutfit.SlotPriority then
		pOutfit.SlotPriority = Outfitter_cSlotNames
	end
-- modified by jtbalogh
end

function Outfitter_UpdateDatabaseItemCodes()
	debugmessage("Outfitter_UpdateDatabaseItemCodes",1);
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	local	vResult = true;
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vIndex, vOutfit in ipairs(vOutfits) do
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				if vOutfitItem.Code ~= 0 then
					local	vItem = OutfitterItemList_FindItemOrAlt(vEquippableItems, vOutfitItem, false, true);
					
					if vItem then
						vOutfitItem.SubCode = vItem.SubCode;
						vOutfitItem.Name = vItem.Name;
						vOutfitItem.EnchantCode = vItem.EnchantCode;
						vOutfitItem.JewelCode1 = vItem.JewelCode1;
						vOutfitItem.JewelCode2 = vItem.JewelCode2;
						vOutfitItem.JewelCode3 = vItem.JewelCode3;
						vOutfitItem.JewelCode4 = vItem.JewelCode4;
						vOutfitItem.Checksum = nil;
					else
						vResult = false;
					end
				end
			end
		end
	end
	
	return vResult;
end

function Outfitter_HookPaperDollFrame()
	debugmessage("Outfitter_HookPaperDollFrame",1);

	for _, vSlotName in ipairs(Outfitter_cSlotNames) do
		local	vSlotButton = getglobal("Character"..vSlotName);
		
		vSlotButton.Outfitter_SavedPreClick = vSlotButton:GetScript("PreClick");
		vSlotButton:SetScript("PreClick", Outfitter_PaperDollItemSlotButton_PreClick);
		
		vSlotButton.Outfitter_SavedPostClick = vSlotButton:GetScript("PostClick");
		vSlotButton:SetScript("PostClick", Outfitter_PaperDollItemSlotButton_PostClick);
		
		vSlotButton.Outfitter_SavedOnDragStart = vSlotButton:GetScript("OnDragStart");
		vSlotButton:SetScript("OnDragStart", Outfitter_PaperDollItemSlotButton_OnDragStart);
		
		vSlotButton.Outfitter_SavedOnDragStop = vSlotButton:GetScript("OnDragStop");
		vSlotButton:SetScript("OnDragStop", Outfitter_PaperDollItemSlotButton_OnDragStop);
	end
end

local	Outfitter_cMaxNumQuickSlots = 9;

local	gOutfitter_PaperDoll_InventorySlot;
local	gOutfitter_PaperDoll_SlotIsEmpty;

function Outfitter_PaperDollItemSlotButton_PreClick(self, pButton, pDown)
	debugmessage("Outfitter_PaperDollItemSlotButton_PreClick",1);
	if self.Outfitter_SavedPreClick then
		self:Outfitter_SavedPreClick(pButton, pDown);
	end
	
	--
	
	gOutfitter_PaperDoll_InventorySlot = Outfitter_cSlotIDToInventorySlot[self:GetID()];
	gOutfitter_PaperDoll_SlotIsEmpty = GetInventoryItemLink("player", self:GetID()) == nil;
end

function Outfitter_PaperDollItemSlotButton_PostClick(self, pButton, pDown)
	debugmessage("Outfitter_PaperDollItemSlotButton_PostClick",1);
	if self.Outfitter_SavedPostClick then
		self:Outfitter_SavedPostClick(pButton, pDown);
	end
	
	-- If there's an item on the cursor then open the slots otherwise
	-- make sure they're closed
	
	if not OutfitterQuickSlots:IsVisible()
	and (CursorHasItem() or gOutfitter_PaperDoll_SlotIsEmpty) then
		-- Hide the tooltip so that it isn't in the way
		
		GameTooltip:Hide();
		
		-- Open QuickSlots
		
		OutfitterQuickSlots_Open(gOutfitter_PaperDoll_InventorySlot);
	else
		OutfitterQuickSlots_Close();
	end
end

function Outfitter_PaperDollItemSlotButton_OnDragStart(self)
	debugmessage("Outfitter_PaperDollItemSlotButton_OnDragStart",1);
	-- MCDebugLib:TestMessage("OnDragStart");
	
	if self.Outfitter_SavedOnDragStart then
		self:Outfitter_SavedOnDragStart();
	end
	
	--
	
	gOutfitter_PaperDoll_InventorySlot = Outfitter_cSlotIDToInventorySlot[self:GetID()];
	gOutfitter_PaperDoll_SlotIsEmpty = false;

	-- Open the QuickSlots
	
	OutfitterQuickSlots_Open(gOutfitter_PaperDoll_InventorySlot);
end

function Outfitter_PaperDollItemSlotButton_OnDragStop(self)
	debugmessage("Outfitter_PaperDollItemSlotButton_OnDragStop",1);
	if self.Outfitter_SavedOnDragStop then
		self:Outfitter_SavedOnDragStop(pButton, pDown);
	end
	
	OutfitterQuickSlots_Close();
end

function OutfitterItemList_AddItem(pItemList, pItem)
	debugmessage("OutfitterItemList_AddItem",1);
	-- Add the item to the code list

	local	vItemFamily = pItemList.ItemsByCode[pItem.Code];

	if not vItemFamily then
		vItemFamily = {};
		pItemList.ItemsByCode[pItem.Code] = vItemFamily;
	end
	
	table.insert(vItemFamily, pItem);
	
	-- Add the item to the slot list
	
	local	vItemSlot = pItemList.ItemsBySlot[pItem.ItemSlotName];
	
	if not vItemSlot then
		vItemSlot = {};
		pItemList.ItemsBySlot[pItem.ItemSlotName] = vItemSlot;
	end
	
	table.insert(vItemSlot, pItem);
	
	-- Add the item to the bags
	
	if pItem.Location.BagIndex then
		local	vBagItems = pItemList.BagItems[pItem.Location.BagIndex];
		
		if not vBagItems then
			vBagItems = {};
			pItemList.BagItems[pItem.Location.BagIndex] = vBagItems;
		end
		
		vBagItems[pItem.Location.BagSlotIndex] = pItem;
		
	-- Add the item to the inventory
	
	elseif pItem.Location.SlotName then
		pItemList.InventoryItems[pItem.Location.SlotName] = pItem;
	end
end

function Outfitter_GetNumBags()
	debugmessage("Outfitter_GetNumBags",1);
	if Outfitter.BankFrameOpened then
		return NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, -1;
	else
		return NUM_BAG_SLOTS, 0;
	end
end

function Outfitter_GetInventorySlotIDLink(pSlotID)
	debugmessage("Outfitter_GetInventorySlotIDLink",1);
	if pSlotID == 0 then -- AmmoSlot
		return Outfitter_GetAmmotSlotItemLink();
	else
		return GetInventoryItemLink("player", pSlotID);
	end
end

local	gOutfitter_LinkCache =
{
	Inventory = {},
	FirstBagIndex = 0,
	NumBags = 0,
	Bags = {},
};

function Outfitter_Synchronize()
	local	vBagsChanged, vInventoryChanged = false, false;
	debugmessage("Synchronize",1);

	-- Synchronize bag links
	
	local	vNumBags, vFirstBagIndex = Outfitter_GetNumBags();
	
	-- MCDebugLib:TestMessage(vFirstBagIndex.." - "..vNumBags);
	
	if gOutfitter_LinkCache.FirstBagIndex ~= vFirstBagIndex
	or gOutfitter_LinkCache.NumBags ~= vNumBags then
		
		gOutfitter_LinkCache.FirstBagIndex = vFirstBagIndex;
		gOutfitter_LinkCache.NumBags = vNumBags;
		
		vBagsChanged = true;
	end
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local	vBag = gOutfitter_LinkCache.Bags[vBagIndex];
		local	vBagChanged = false;
		
		if not vBag then
			vBag = {};
			gOutfitter_LinkCache.Bags[vBagIndex] = vBag;
		end
		
		local	vNumBagSlots = GetContainerNumSlots(vBagIndex);
		
		if #vBag ~= vNumBagSlots then
			Outfitter_EraseTable(vBag);
			vBagChanged = true;
		end
		
		for vSlotIndex = 1, vNumBagSlots do
			local	vItemLink = GetContainerItemLink(vBagIndex, vSlotIndex) or "";
			
			if vBag[vSlotIndex] ~= vItemLink then
				vBag[vSlotIndex] = vItemLink;
				vBagChanged = true;
			end
		end
		
		if vBagChanged then
			OutfitterItemList_FlushBagFromEquippableItems(vBagIndex);
			vBagsChanged = true;
		end
	end
	
	-- Synchronize inventory links
	
	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do

		local	vItemLink;
		
		if vInventorySlot == "AmmoSlot" then
			local	vName, vTexture = Outfitter_GetAmmotSlotItemName();
			
			if vName then
				vItemLink = vName.."|"..vTexture; -- Not an item link, just a unique reference to the contents
			end
			
			GetInventoryItemLink("player", pSlotID);
		else
			vItemLink = GetInventoryItemLink("player", Outfitter_cSlotIDs[vInventorySlot]);
		end
		
		if gOutfitter_LinkCache.Inventory[vInventorySlot] ~= vItemLink then
			gOutfitter_LinkCache.Inventory[vInventorySlot] = vItemLink;
			vInventoryChanged = true;
		end
	end
	
	if vInventoryChanged then
		OutfitterItemList_FlushInventoryFromEquippableItems();
		Outfitter_InventoryChanged();
	end
	
	-- Done
	
	if vBagsChanged or vInventoryChanged then
		Outfitter.DisplayIsDirty = true;
		Outfitter_Update(false);
	end
	
	return vBagsChanged or vInventoryChanged, vInventoryChanged, vBagsChanged;
end

function Outfitter_GetInventorySlotItemCode(pInventorySlot)
	local	vItemLink = Outfitter_GetInventorySlotIDLink(Outfitter_cSlotIDs[pInventorySlot]);
	debugmessage("Get Inventory Change",1);

	if not vItemLink then
		return;
	end
	
	local	vStartIndex, vEndIndex,
			vLinkColor,
			vItemCode,
			vItemEnchantCode,
			vItemJewelCode1,
			vItemJewelCode2,
			vItemJewelCode3,
			vItemJewelCode4,
			vItemSubCode,
			vUnknownCode5,
			vItemName = strfind(vItemLink, Outfitter_cItemLinkFormat);
	
	vItemCode = tonumber(vItemCode);
	vItemSubCode = tonumber(vItemSubCode);
	vItemEnchantCode = tonumber(vItemEnchantCode);
	vItemJewelCode1 = tonumber(vItemJewelCode1);
	vItemJewelCode2 = tonumber(vItemJewelCode2);
	vItemJewelCode3 = tonumber(vItemJewelCode3);
	vItemJewelCode4 = tonumber(vItemJewelCode4);	
	
	if vItemName then
		-- MCDebugLib:TestMessage(string.format("Item %s:%d:%d:%d:%d:%d:%d:%d:%d", vItemName, vItemCode, vItemEnchantCode, vItemSubCode, vUnknownCode1, vUnknownCode2, vUnknownCode3, vUnknownCode4, vUnknownCode5));
	end
	
	return vItemCode, vItemEnchantCode, vItemSubCode,vItemJewelCode1,vItemJewelCode2,vItemJewelCode3,vItemJewelCode4;
end

function OutfitterItemList_FlushChangedItems()
	if not gOutfitter_EquippableItems then
		return;
	end
	debugmessage("Flush Changed Items",1);
	
	-- Check inventory
	
	local	vFlushInventory = false;

	for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do

		local	vItemCode, vItemEnchantCode, vItemSubCode, vItemJewelCode1, vItemJewelCode2, vItemJewelCode3, vItemJewelCode4 = Outfitter_GetInventorySlotItemCode(vInventorySlot);
		local	vItemInfo = gOutfitter_EquippableItems.InventoryItems[vInventorySlot];
		
		if (vItemCode ~= nil) ~= (vItemInfo ~= nil) then
			vFlushInventory = true;
			break;
		end
		
		if vItemInfo
		and (vItemInfo.Code ~= vItemCode
		  or vItemInfo.SubCode ~= vItemSubCode
		  or vItemInfo.EnchantCode ~= vItemEnchantCode 
		  or vItemInfo.JewelCode1 ~= vItemJewelCode1 
		  or vItemInfo.JewelCode2 ~= vItemJewelCode2 
		  or vItemInfo.JewelCode3 ~= vItemJewelCode3 
		  or vItemInfo.JewelCode4 ~= vItemJewelCode4) then
			vFlushInventory = true;
			break;
		end
	end
	
	-- Have to flush bags too since inventory event changes probably
	-- also have bag event changes and not flushing the bag can result
	-- in a strange state where an item appears to be in two places at once
	
	if vFlushInventory then
		OutfitterItemList_FlushEquippableItems();
	end
end

function OutfitterItemList_FindItemInfoByCode(pItemList, pItemInfo)
	local	vItems = pItemList.ItemsByCode[pItemInfo.Code];
	debugmessage("OutfitterItemList_FindItemInfoByCode",1);
	
	for _, vItemInfo in ipairs(vItems) do
		if pItemInfo == vItemInfo then
			return true;
		end
	end
	
	return false;
end

function OutfitterItemList_FindItemInfoBySlot(pItemList, pItemInfo)
	local	vItems = pItemList.ItemsBySlot[pItemInfo.ItemSlotName];
	debugmessage("OutfitterItemList_FindItemInfoBySlot",1);

	for _, vItemInfo in ipairs(vItems) do
		if pItemInfo == vItemInfo then
			return true;
		end
	end
	
	return false;
end

function OutfitterItemList_VerifyItems(pItemList)
	-- Check that all the inventory items are accounted for
	debugmessage("OutfitterItemList_VerifyItems",1);
	
	for vInventorySlot, vItemInfo in pairs(pItemList.InventoryItems) do
		-- Verify the item in the code list
		
		if not OutfitterItemList_FindItemInfoByCode(pItemList, vItemInfo) then
			MCDebugLib:TestMessage("Didn't find item "..vItemInfo.Name.." by code");
		end
		
		-- Check the item in the slot list
		
		if not OutfitterItemList_FindItemInfoBySlot(pItemList, vItemInfo) then
			MCDebugLib:TestMessage("Didn't find item "..vItemInfo.Name.." by slot");
		end
	end
	
	-- Check that all bag items are accounted for
	
	for _, vBagItems in pairs(pItemList.BagItems) do
		for _, vItemInfo in pairs(vBagItems) do
			-- Verify the item in the code list
			
			if not OutfitterItemList_FindItemInfoByCode(pItemList, vItemInfo) then
				MCDebugLib:TestMessage("Didn't find item "..vItemInfo.Name.." by code");
			end
			
			-- Check the item in the slot list
			
			if not OutfitterItemList_FindItemInfoBySlot(pItemList, vItemInfo) then
				MCDebugLib:TestMessage("Didn't find item "..vItemInfo.Name.." by slot");
			end
		end
	end
end

function OutfitterItemList_FlushEquippableItems()
	-- MCDebugLib:TestMessage("OutfitterItemList_FlushEquippableItems");
		debugmessage("OutfitterItemList_FlushEquippableItems",1);
	gOutfitter_EquippableItems = nil;
end

function OutfitterItemList_FlushBagFromEquippableItems(pBagIndex)
	-- MCDebugLib:TestMessage("OutfitterItemList_FlushBagFromEquippableItems: "..pBagIndex);
	debugmessage("OutfitterItemList_FlushBagFromEquippableItems",1);
	
	if gOutfitter_EquippableItems
	and gOutfitter_EquippableItems.BagItems[pBagIndex] then
		for vBagSlotIndex, vItem in pairs(gOutfitter_EquippableItems.BagItems[pBagIndex]) do
			OutfitterItemList_RemoveItem(gOutfitter_EquippableItems, vItem);
		end
		
		gOutfitter_EquippableItems.NeedsUpdate = true;
		gOutfitter_EquippableItems.BagItems[pBagIndex] = nil;
	end
end

function OutfitterItemList_FlushInventoryFromEquippableItems()
	debugmessage("OutfitterItemList_FlushInventoryFromEquippableItems",1);
	if gOutfitter_EquippableItems then
		for vInventorySlot, vItem in pairs(gOutfitter_EquippableItems.InventoryItems) do
			OutfitterItemList_RemoveItem(gOutfitter_EquippableItems, vItem);
		end
		
		gOutfitter_EquippableItems.NeedsUpdate = true;
		gOutfitter_EquippableItems.InventoryItems = nil;
	end
end

function OutfitterItemList_New()
		debugmessage("OutfitterItemList_New",1);
	return {ItemsByCode = {}, ItemsBySlot = {}, InventoryItems = nil, BagItems = {}};
end

function OutfitterItemList_RemoveItem(pItemList, pItem)
		debugmessage("OutfitterItemList_RemoveItem",1);
	-- Remove the item from the code list
	
	local	vItems = pItemList.ItemsByCode[pItem.Code];
	
	for vIndex, vItem in ipairs(vItems) do
		if vItem == pItem then
			table.remove(vItems, vIndex);
			break;
		end
	end

	-- Remove the item from the slot list
	
	local	vItemSlot = pItemList.ItemsBySlot[pItem.ItemSlotName];
	
	if vItemSlot then
		for vIndex, vItem in ipairs(vItemSlot) do
			if vItem == pItem then
				table.remove(vItemSlot, vIndex);
				break;
			end
		end
	end
	
	-- Remove the item from the bags list
	
	if pItem.Location.BagIndex then
		local	vBagItems = pItemList.BagItems[pItem.Location.BagIndex];
		
		if vBagItems then
			vBagItems[pItem.Location.BagSlotIndex] = nil;
		end
		
	-- Remove the item from the inventory list
	
	elseif pItem.Location.SlotName then
		pItemList.InventoryItems[pItem.Location.SlotName] = nil;
	end
end

function OutfitterItemList_GetInventoryOutfit(pEquippableItems)
		debugmessage("OutfitterItemList_GetInventoryOutfit",1);
	return pEquippableItems.InventoryItems;
end

function OutfitterItemList_ResetIgnoreItemFlags(pItemList)
		debugmessage("OutfitterItemList_ResetIgnoreItemFlags",1);
	for vItemCode, vItemFamily in pairs(pItemList.ItemsByCode) do
		for _, vItem in ipairs(vItemFamily) do
			vItem.IgnoreItem = nil;
		end
	end
end

function OutfitterItemList_GetEquippableItems(pIncludeItemStats)
		debugmessage("OutfitterItemList_GetEquippableItems",1);
	-- Check for a change in the number of bags
	
	local	vNumBags, vFirstBagIndex = Outfitter_GetNumBags();
	
	if gOutfitter_EquippableItems
	and (gOutfitter_EquippableItems.FirstBagIndex ~= vFirstBagIndex
	or gOutfitter_EquippableItems.NumBags ~= vNumBags) then
		for vBagIndex = gOutfitter_EquippableItems.FirstBagIndex, vFirstBagIndex - 1 do
			OutfitterItemList_FlushBagFromEquippableItems(vBagIndex);
		end
		
		for vBagIndex = vNumBags + 1, gOutfitter_EquippableItems.NumBags do
			OutfitterItemList_FlushBagFromEquippableItems(vBagIndex);
		end
		
		gOutfitter_EquippableItems.NeedsUpdate = true;
	end
	
	-- If there's a cached copy just clear the IgnoreItem flags and return it
	-- (never used cached copy if the caller wants stats)
	
	if gOutfitter_EquippableItems
	and not gOutfitter_EquippableItems.NeedsUpdate
	and not pIncludeItemStats then
		-- MCDebugLib:TestMessage("OutfitterItemList_GetEquippableItems: Using cached list");
		OutfitterItemList_ResetIgnoreItemFlags(gOutfitter_EquippableItems);
		
		return gOutfitter_EquippableItems;
	end
	
	if not gOutfitter_EquippableItems
	or pIncludeItemStats then
		gOutfitter_EquippableItems = OutfitterItemList_New();
	end
	
	local	_, vPlayerClass = UnitClass("player");
	local	vStatDistribution = Outfitter_GetPlayerStatDistribution();
	
	if not gOutfitter_EquippableItems.InventoryItems
	or pIncludeItemStats then
		-- MCDebugLib:TestMessage("OutfitterItemList_GetEquippableItems: Rebuilding inventory items");
		
		gOutfitter_EquippableItems.InventoryItems = {};
		
		for _, vInventorySlot in ipairs(Outfitter_cSlotNames) do
			local	vItemInfo = Outfitter_GetInventoryItemInfo(vInventorySlot);
			
			if vItemInfo
			and vItemInfo.ItemSlotName
			and vItemInfo.Code ~= 0 then
				vItemInfo.SlotName = vInventorySlot;
				vItemInfo.Location = {SlotName = vInventorySlot};
				
				if pIncludeItemStats then	
					OutfitterItemList_GetItemStats(vItemInfo, vStatDistribution);
				end
				
				OutfitterItemList_AddItem(gOutfitter_EquippableItems, vItemInfo);
			end
		end
	else
		for vInventorySlot, vItem in pairs(gOutfitter_EquippableItems.InventoryItems) do
			vItem.IgnoreItem = nil;
		end
	end
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local		vBagItems = gOutfitter_EquippableItems.BagItems[vBagIndex];
		
		if not vBagItems
		or pIncludeItemStats then
			gOutfitter_EquippableItems.BagItems[vBagIndex] = {};
			
			local	vNumBagSlots = GetContainerNumSlots(vBagIndex);
			
			if vNumBagSlots > 0 then
				-- MCDebugLib:TestMessage("OutfitterItemList_GetEquippableItems: Rebuilding bag "..vBagIndex);
				
				for vBagSlotIndex = 1, vNumBagSlots do
					local	vItemInfo = Outfitter_GetBagItemInfo(vBagIndex, vBagSlotIndex);
					
					if vItemInfo
					and vItemInfo.Code ~= 0
					and vItemInfo.ItemSlotName
					and Outfitter_CanEquipBagItem(vBagIndex, vBagSlotIndex)
					and not Outfitter_BagItemWillBind(vBagIndex, vBagSlotIndex) then
						vItemInfo.BagIndex = vBagIndex;
						vItemInfo.BagSlotIndex = vBagSlotIndex;
						vItemInfo.Location = {BagIndex = vBagIndex, BagSlotIndex = vBagSlotIndex};
						
						if pIncludeItemStats then	
							OutfitterItemList_GetItemStats(vItemInfo, vStatDistribution);
						end
						
						OutfitterItemList_AddItem(gOutfitter_EquippableItems, vItemInfo);
					end
				end -- for vBagSlotIndex
			end -- if vNumBagSlots > 0
		else -- if not BagItems
			for vBagSlotIndex, vItem in pairs(vBagItems) do
				vItem.IgnoreItem = nil;
			end
		end -- if not BagItems
	end -- for vBagIndex
	
	gOutfitter_EquippableItems.FirstBagIndex = vFirstBagIndex;
	gOutfitter_EquippableItems.NumBags = vNumBags;
	
	gOutfitter_EquippableItems.NeedsUpdate = false;
	
	return gOutfitter_EquippableItems;
end

function OutfitterItemList_SwapLocations(pItemList, pLocation1, pLocation2)
		debugmessage("OutfitterItemList_SwapLocations",1);
	-- if pLocation1.BagIndex then
	-- 	MCDebugLib:TestMessage("OutfitterItemList_SwapLocations: Swapping bag "..pLocation1.BagIndex..", "..pLocation1.BagSlotIndex);
	-- elseif pLocation1.SlotName then
	-- 	MCDebugLib:TestMessage("OutfitterItemList_SwapLocations: Swapping slot "..pLocation1.SlotName);
	-- end
	-- if pLocation2.BagIndex then
	-- 	MCDebugLib:TestMessage("OutfitterItemList_SwapLocations: with bag "..pLocation2.BagIndex..", "..pLocation2.BagSlotIndex);
	-- elseif pLocation2.SlotName then
	-- 	MCDebugLib:TestMessage("OutfitterItemList_SwapLocations: with slot "..pLocation2.SlotName);
	-- end
end

function OutfitterItemList_SwapLocationWithInventorySlot(pItemList, pLocation, pSlotName)
		debugmessage("OutfitterItemList_SwapLocationWithInventorySlot",1);
	-- if pLocation.BagIndex then
	-- 	MCDebugLib:TestMessage("OutfitterItemList_SwapLocationWithInventorySlot: Swapping bag "..pLocation.BagIndex..", "..pLocation.BagSlotIndex.." with slot "..pSlotName);
	-- elseif pLocation.SlotName then
	-- 	MCDebugLib:TestMessage("OutfitterItemList_SwapLocationWithInventorySlot: Swapping slot "..pLocation.SlotName.." with slot "..pSlotName);
	-- end
end

function OutfitterItemList_SwapBagSlotWithInventorySlot(pItemList, pBagIndex, pBagSlotIndex, pSlotName)
		debugmessage("OutfitterItemList_SwapBagSlotWithInventorySlot",1);
	-- MCDebugLib:TestMessage("OutfitterItemList_SwapBagSlotWithInventorySlot: Swapping bag "..pBagIndex..", "..pBagSlotIndex.." with slot "..pSlotName);
end

function OutfitterItemList_FindItemOrAlt(pItemList, pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
		debugmessage("OutfitterItemList_FindItemOrAlt",1);
	local	vItem, vIgnoredItem = OutfitterItemList_FindItem(pItemList, pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard);
	
	if vItem then
		return vItem;
	end
	
	-- See if there's an alias for the item if it wasn't found
	
	local	vAltCode = Outfitter_cItemAliases[pOutfitItem.Code];
	
	if not vAltCode then
		return nil, vIgnoredItem;
	end
	
	return OutfitterItemList_FindItem(pItemList, {Code = vAltCode}, pMarkAsInUse, true);
end

function OutfitterItemList_FindItem(pItemList, pOutfitItem, pMarkAsInUse, pAllowSubCodeWildcard)
		debugmessage("OutfitterItemList_FindItem",1);
	local	vItem, vIndex, vItemFamily, vIgnoredItem = OutfitterItemList_FindItemIndex(pItemList, pOutfitItem, pAllowSubCodeWildcard);
	
	if not vItem then
		return nil, vIgnoredItem;
	end
	
	if pMarkAsInUse then
		vItem.IgnoreItem = true;
	end
	
	return vItem;
end

function OutfitterItemList_FindAllItemsOrAlt(pItemList, pOutfitItem, pAllowSubCodeWildcard, rItems)
		debugmessage("OutfitterItemList_FindAllItemsOrAlt",1);
	local	vNumItems = OutfitterItemList_FindAllItems(pItemList, pOutfitItem, pAllowSubCodeWildcard, rItems);
	local	vAltCode = Outfitter_cItemAliases[pOutfitItem.Code];
	
	if vAltCode then
		vNumItems = vNumItems + OutfitterItemList_FindAllItems(pItemList, {Code = vAltCode}, true, rItems);
	end
	
	return vNumItems;
end

function OutfitterItemList_FindAllItems(pItemList, pOutfitItem, pAllowSubCodeWildcard, rItems)
		debugmessage("OutfitterItemList_FindAllItems",1);
	if not pItemList then
		return 0;
	end
	
	local	vItemFamily = pItemList.ItemsByCode[pOutfitItem.Code];
	
	if not vItemFamily then
		return 0;
	end
	
	local	vNumItemsFound = 0;
	
	for vIndex, vItem in ipairs(vItemFamily) do
		if (pAllowSubCodeWildcard and not pOutfitItem.SubCode)
		or vItem.SubCode == pOutfitItem.SubCode then
			table.insert(rItems, vItem);
			vNumItemsFound = vNumItemsFound + 1;
		end
	end
	
	return vNumItemsFound;
end


-- JewelCode TODO! !
function OutfitterItemList_FindItemIndex(pItemList, pOutfitItem, pAllowSubCodeWildcard)
		debugmessage("OutfitterItemList_FindItemIndex",1);
	if not pItemList then
		return nil, nil, nil, nil;
	end
	
	local	vItemFamily = pItemList.ItemsByCode[pOutfitItem.Code];
	
	if not vItemFamily then
		return nil, nil, nil, nil;
	end
	
	local	vBestMatch = nil;
	local	vBestMatchIndex = nil;
	local	vNumItemsFound = 0;
	local	vFoundIgnoredItem = nil;
	
	for vIndex, vItem in ipairs(vItemFamily) do
		if pAllowSubCodeWildcard
		and not pOutfitItem.SubCode then
			if vItem.IgnoreItem then
				vFoundIgnoredItem = vItem;
			else
				return vItem, vIndex, vItemFamily, nil;
			end
		
		--  If the subcode matches then check for an enchant match
		
		elseif vItem.SubCode == pOutfitItem.SubCode then
			-- If the enchant matches then we're all done
			
			if (vItem.EnchantCode == pOutfitItem.EnchantCode 
				and vItem.JewelCode1 == pOutfitItem.JewelCode1 
				and vItem.JewelCode2 == pOutfitItem.JewelCode2
				and vItem.JewelCode3 == pOutfitItem.JewelCode3 
				and vItem.JewelCode4 == pOutfitItem.JewelCode4)	then
				if vItem.IgnoreItem then
					vFoundIgnoredItem = vItem;
				else
					return vItem, vIndex, vItemFamily;
				end
			
			-- Otherwise save the match in case a better one can
			-- be found
			
			else
				if vItem.IgnoreItem then
					if not vFoundIgnoredItem then
						vFoundIgnoredItem = vItem;
					end
				else
					vBestMatch = vItem;
					vBestMatchIndex = vIndex;
					vNumItemsFound = vNumItemsFound + 1;
				end
			end
		end
	end
	
	-- Return the match if only one item was found
	
	if vNumItemsFound == 1
	and not vBestMatch.IgnoreItem then
		return vBestMatch, vBestMatchIndex, vItemFamily, nil;
	end
	
	return nil, nil, nil, vFoundIgnoredItem;
end


function OutfitterItemStats(SlotNumber)
--//local link = GetContainerItemLink(1,1)
--//-- This expression extracts the name from the link (if you just need name)
--//local justName = string.gsub((link,"^.-%[(.*)%].*", "%1")
--//-- This expression extracts the item ID from the link
--//local justItemId = string.gsub(link,".-\124H([^\124]*)\124h.*", "%1");
--//-- Then get info from link (NOTE: will return nil if item is not in local cache)
--//local itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType,
--//      itemStackCount, itemEquipLoc = GetItemInfo(justItemId);

	local	vHasItem = OutfitterTooltip:SetInventoryItem("player", SlotNumber);

	local	vStats = {};
	local	vTooltipName = OutfitterTooltip:GetName();
	local LineCount = OutfitterTooltip:NumLines();

	if not vHasItem then
	 debugmessage("No Item", 4);
		OutfitterTooltip:Hide();
		return nil;
	end


	debugmessage("Starting Stats Loop: "..vTooltipName..", Lines: "..LineCount, 4);
	for vLineIndex = 1, LineCount do
		local	vLeftTextFrame = getglobal(vTooltipName.."TextLeft"..vLineIndex);
		
		if not vLeftTextFrame then
			break;
		end
		
		local	vLeftText = vLeftTextFrame:GetText();
		--local	vRightText = getglobal(vTooltipName.."TextRight"..vLineIndex):GetText();

		debugmessage("Left Text: "..vLeftText, 4);
		
		if vLeftText then
			-- Check for the start of the set bonus section
			
			local	vStartIndex, vEndIndex, vValue = string.find(vLeftText, "Requires Engineering");
			debugmessage("Post Message", 4);
			debugmessage(vStartIndex..", "..vEndIndex..", "..vValue, 4);
			
			if vStartIndex then
				break;
			end
			
			--
			
			--for vStatString in string.gmatch(vLeftText, "([^/]+)") do
			--	local	vStatIDs, vValue = Outfitter_IsStatText(vStatString);
				
			--	if vStatIDs then
			--		for vStatIDIndex, vStatID in ipairs(vStatIDs) do
			--			OutfitterStats_AddStatValue(vStats, vStatID, vValue, pDistribution);
			--		end
			--	end
			--end
			
		end
	end -- for vLineIndex
	
	return vStats;
end

		
function OutfitterItemList_GetItemStats(pItem, pDistribution)
		debugmessage("OutfitterItemList_GetItemStats",1);
	if pItem.Stats then
		return pItem.Stats;
	end
	
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0);
	
	if pItem.SlotName then
		local	vHasItem = OutfitterTooltip:SetInventoryItem("player", Outfitter_cSlotIDs[pItem.SlotName]);
		
		if not vHasItem then
			OutfitterTooltip:Hide();
			return nil;
		end
	elseif pItem.BagIndex == -1 then
		OutfitterTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(pItem.BagSlotIndex));
	else
		OutfitterTooltip:SetBagItem(pItem.BagIndex, pItem.BagSlotIndex);
	end
	
	local	vStats = Outfitter_GetItemStatsFromTooltip(OutfitterTooltip, pDistribution);
	
	OutfitterTooltip:Hide();
	
	if not vStats then
		return nil;
	end
	
	pItem.Stats = vStats;
	
	return vStats;
end

function Outfitter_IsBankBagIndex(pBagIndex)
		debugmessage("Outfitter_IsBankBagIndex",1);
	return pBagIndex and (pBagIndex > NUM_BAG_SLOTS or pBagIndex < 0);
end

function OutfitterItemList_GetMissingItems(pEquippableItems, pOutfit)
		debugmessage("OutfitterItemList_GetMissingItems",1);
	local	vMissingItems = nil;
	local	vBankedItems = nil;
	
	for vInventorySlot, vOutfitItem in pairs(pOutfit.Items) do
		if vOutfitItem.Code ~= 0 then
			local	vItem = OutfitterItemList_FindItemOrAlt(pEquippableItems, vOutfitItem);
			
			if not vItem then
				if not vMissingItems then
					vMissingItems = {};
				end
				
				table.insert(vMissingItems, vOutfitItem);
			elseif Outfitter_IsBankBagIndex(vItem.Location.BagIndex) then
				if not vBankedItems then
					vBankedItems = {};
				end
				
				table.insert(vBankedItems, vOutfitItem);
			end
		end
	end
	
	return vMissingItems, vBankedItems;
end

function OutfitterItemList_CompiledUnusedItemsList(pEquippableItems)
		debugmessage("OutfitterItemList_CompiledUnusedItemsList",1);
	OutfitterItemList_ResetIgnoreItemFlags(pEquippableItems);
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			for vInventorySlot, vOutfitItem in pairs(vOutfit.Items) do
				if vOutfitItem.Code ~= 0 then
					local	vItem = OutfitterItemList_FindItemOrAlt(pEquippableItems, vOutfitItem, true);
					
					if vItem then
						vItem.UsedInOutfit = true;
					end
				end
			end
		end
	end
	
	local	vUnusedItems = nil;
	
	for vCode, vFamilyItems in pairs(pEquippableItems.ItemsByCode) do
		for vIndex, vOutfitItem in ipairs(vFamilyItems) do
			if not vOutfitItem.UsedInOutfit
			and vOutfitItem.ItemSlotName ~= "AmmoSlot"
			and Outfitter_cIgnoredUnusedItems[vOutfitItem.Code] == nil then
				if not vUnusedItems then
					vUnusedItems = {};
				end
				
				table.insert(vUnusedItems, vOutfitItem);
			end
		end
	end
	
	pEquippableItems.UnusedItems = vUnusedItems;
end

--JewelCode TODO
function OutfitterItemList_ItemsAreSame(pEquippableItems, pItem1, pItem2)
		debugmessage("OutfitterItemList_ItemsAreSame",1);
	if not pItem1 then
		return pItem2 == nil;
	end
	
	if not pItem2 then
		return false;
	end
	
	if pItem1.Code == 0 then
		return pItem2.Code == 0;
	end
	
	if pItem1.Code ~= pItem2.Code
	or pItem1.SubCode ~= pItem2.SubCode then
		return false;
	end
	
	local	vItems = {};
	local	vNumItems = OutfitterItemList_FindAllItemsOrAlt(pEquippableItems, pItem1, nil, vItems);
	
	if vNumItems == 0 then
		-- Shouldn't ever get here
		
		MCDebugLib:TestMessage("OutfitterItemList_ItemsAreSame: Item not found");
		MCDebugLib:DumpArray("Item", pItem1);
		
		return false;
	elseif vNumItems == 1 then
		-- If there's only one of that item then the enchant code
		-- is disregarded so just make sure it's the same
		
		return true;
	else
		--check if enchants and jewels matches
		if (pItem1.EnchantCode == pItem2.EnchantCode
		   and pItem1.JewelCode1 == pItem2.JewelCode1
		   and pItem1.JewelCode2 == pItem2.JewelCode2
		   and pItem1.JewelCode3 == pItem2.JewelCode3
		   and pItem1.JewelCode4 == pItem2.JewelCode4)	then
			return true;
		else
			return false;
		end
	end
end

function OutfitterItemList_InventorySlotContainsItem(pEquippableItems, pInventorySlot, pOutfitItem)
		debugmessage("OutfitterItemList_InventorySlotContainsItem",1);
	-- Nil items are supposed to be ignored, so never claim the slot contains them
	
	if pOutfitItem == nil then
		return false, nil;
	end
	
	-- If the item specifies an empty slot check to see if the slot is actually empty
	
	if pOutfitItem.Code == 0 then
		return pEquippableItems.InventoryItems[pInventorySlot] == nil;
	end
	
	local	vItems = {};
	local	vNumItems = OutfitterItemList_FindAllItemsOrAlt(pEquippableItems, pOutfitItem, nil, vItems);
	
	if vNumItems == 0 then
		return false;
	elseif vNumItems == 1 then
		-- If there's only one of that item then the enchant code
		-- is disregarded so just make sure it's in the slot
		
		return vItems[1].SlotName == pInventorySlot, vItems[1];
	else
		-- See if one of the items is in the slot
		
		for vIndex, vItem in ipairs(vItems) do
			if vItem.SlotName == pInventorySlot then
				-- Must match the enchant code if there are multiple items
				-- in order to be considered a perfect match
				
				--check if enchants and jewels matches
				if (vItem.EnchantCode == pOutfitItem.EnchantCode
				   and vItem.JewelCode1 == pOutfitItem.JewelCode1
				   and vItem.JewelCode2 == pOutfitItem.JewelCode2
				   and vItem.JewelCode3 == pOutfitItem.JewelCode3
				   and vItem.JewelCode4 == pOutfitItem.JewelCode4)	then
					return true,vItem;
				else
					return false,vItem;
				end
			end
		end
		
		-- No items in the slot
		
		return false, nil;
	end
end

function OutfitterQuickSlots_Open(pSlotName)
		debugmessage("OutfitterQuickSlots_Open",1);
	local	vPaperDollSlotName = "Character"..pSlotName;
	
	-- Hide the tooltip so that it isn't in the way
	
	GameTooltip:Hide();
	
	-- Position the window
	
	if pSlotName == "MainHandSlot"
	or pSlotName == "SecondaryHandSlot"
	or pSlotName == "RangedSlot"
	or pSlotName == "AmmoSlot" then
		OutfitterQuickSlots:SetPoint("TOPLEFT", vPaperDollSlotName, "BOTTOMLEFT", 0, 0);
	else
		OutfitterQuickSlots:SetPoint("TOPLEFT", vPaperDollSlotName, "TOPRIGHT", 5, 6);
	end
	
	OutfitterQuickSlots.SlotName = pSlotName;
	
	-- Populate the items
	
	local	vItems = Outfitter_FindItemsInBagsForSlot(pSlotName);
	local	vNumSlots = 0;
	
	if vItems then
		for vItemInfoIndex, vItemInfo in ipairs(vItems) do
			if vNumSlots >= Outfitter_cMaxNumQuickSlots then
				break;
			end
			
			vNumSlots = vNumSlots + 1;
			OutfitterQuickSlots_SetSlotToBag(vNumSlots, vItemInfo.BagIndex, vItemInfo.BagSlotIndex);
		end
	end
	
	-- If the slot isn't empty, offer an empty slot to put the item in
	
	if vNumSlots < Outfitter_cMaxNumQuickSlots
	and not Outfitter_InventorySlotIsEmpty(pSlotName) then
		local	vBagSlotInfo = Outfitter_GetEmptyBagSlot();
		
		if vBagSlotInfo then
			vNumSlots = vNumSlots + 1;
			OutfitterQuickSlots_SetSlotToBag(vNumSlots, vBagSlotInfo.BagIndex, vBagSlotInfo.BagSlotIndex);
		end
	end
	
	-- Resize the window and show it
	
	OutfitterQuickSlots_SetNumSlots(vNumSlots);
	
	if vNumSlots == 0 then
		OutfitterQuickSlots:Hide();
	else
		OutfitterQuickSlots:Show();
	end
end

function OutfitterQuickSlots_Close()
		debugmessage("OutfitterQuickSlots_Close",1);
	OutfitterQuickSlots:Hide();
end

function OutfitterQuickSlots_OnLoad()
		debugmessage("OutfitterQuickSlots_OnLoad",1);
	table.insert(UIMenus, this:GetName());
end

function OutfitterQuickSlots_OnShow()
	debugmessage("OutfitterQuickSlots_OnShow",1);
end

function OutfitterQuickSlots_OnHide()
	debugmessage("OutfitterQuickSlots_OnHide",1);
end

function OutfitterQuickSlots_OnEvent(pEvent)
	debugmessage("OutfitterQuickSlots_OnEvent",1);
end

function OutfitterQuickSlotItem_OnEvent()
	debugmessage("OutfitterQuickSlotItem_OnEvent",1);
	-- ContainerFrame_OnEvent();
end

function OutfitterQuickSlotItem_OnLoad()
		debugmessage("OutfitterQuickSlotItem_OnLoad",1);
	this.size = 1; -- one-slot container
end

function OutfitterQuickSlotItem_OnShow()
		debugmessage("OutfitterQuickSlotItem_OnShow",1);
	this:RegisterEvent("BAG_UPDATE");
	this:RegisterEvent("BAG_UPDATE_COOLDOWN");
	this:RegisterEvent("ITEM_LOCK_CHANGED");
	this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
end

function OutfitterQuickSlotItem_OnHide()
		debugmessage("OutfitterQuickSlotItem_OnHide",1);
	this:UnregisterEvent("BAG_UPDATE");
	this:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	this:UnregisterEvent("ITEM_LOCK_CHANGED");
	this:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
end

function OutfitterQuickSlotItemButton_OnEnter(button)
		debugmessage("OutfitterQuickSlotItemButton_OnEnter",1);
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	
	local	vBagIndex = button:GetParent():GetID();
	local	vBagSlotIndex = button:GetID();
	
	local	hasItem, hasCooldown, repairCost;
	
	if vBagIndex == -1 then
		hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(vBagSlotIndex));
	else
		hasCooldown, repairCost = GameTooltip:SetBagItem(vBagIndex, vBagSlotIndex);
	end
	
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( this.readable or (IsControlKeyDown() and button.hasItem) ) then
		ShowInspectCursor();
	elseif ( MerchantFrame:IsVisible() and MerchantFrame.selectedTab == 1 ) then
		ShowContainerSellCursor(button:GetParent():GetID(),button:GetID());
	else
		ResetCursor();
	end
end

function OutfitterQuickSlots_SetNumSlots(pNumSlots)
		debugmessage("OutfitterQuickSlots_SetNumSlots",1);
	if pNumSlots > Outfitter_cMaxNumQuickSlots then
		pNumSlots = Outfitter_cMaxNumQuickSlots;
	end
	
	local	vBaseWidth = 11;
	local	vSlotWidth = 42;
	
	for vIndex = 1, pNumSlots do
		local	vSlotItem = getglobal("OutfitterQuickSlotsItem"..vIndex);
		
		vSlotItem:ClearAllPoints();
		
		if vIndex == 1 then
			vSlotItem:SetPoint("TOPLEFT", "OutfitterQuickSlots", "TOPLEFT", 6, -6);
		else
			vSlotItem:SetPoint("TOPLEFT", "OutfitterQuickSlotsItem"..(vIndex - 1), "TOPLEFT", vSlotWidth, 0);
		end
		
		vSlotItem:Show();
	end
	
	-- Hide the unused slots
	
	for vIndex = pNumSlots + 1, Outfitter_cMaxNumQuickSlots do
		local	vSlotItem = getglobal("OutfitterQuickSlotsItem"..vIndex);
		
		vSlotItem:Hide();
	end
	
	-- Size the frame
	
	OutfitterQuickSlots:SetWidth(vBaseWidth + vSlotWidth * pNumSlots);
	
	-- Fix the background
	
	if pNumSlots > 0 then
		for vIndex = 1, pNumSlots - 1 do
			getglobal("OutfitterQuickSlotsBack"..vIndex):Show();
		end
		
		for vIndex = pNumSlots, Outfitter_cMaxNumQuickSlots - 1 do
			getglobal("OutfitterQuickSlotsBack"..vIndex):Hide();
		end
		
		OutfitterQuickSlotsBackEnd:SetPoint("LEFT", "OutfitterQuickSlotsBack"..(pNumSlots - 1), "RIGHT", 0, 0);
	end
end

function OutfitterQuickSlots_SetSlotToBag(pQuickSlotIndex, pBagIndex, pBagSlotIndex)
		debugmessage("OutfitterQuickSlots_SetSlotToBag",1);
	local	vQuickSlotItem = getglobal("OutfitterQuickSlotsItem"..pQuickSlotIndex);
	local	vQuickSlotItemButton = getglobal("OutfitterQuickSlotsItem"..pQuickSlotIndex.."Item1");
	
	vQuickSlotItem:SetID(pBagIndex);
	vQuickSlotItemButton:SetID(pBagSlotIndex);
	
	ContainerFrame_Update(vQuickSlotItem);
end

function Outfitter_RegisterEvent(pFrame, pEvent, pHandler)
		debugmessage("Outfitter_RegisterEvent",1);
	if not pFrame.EventHandlers then
		pFrame.EventHandlers = {};
	end
	
	pFrame.EventHandlers[pEvent] = pHandler;
	pFrame:RegisterEvent(pEvent);
end

function Outfitter_UnregisterEvent(pFrame, pEvent)
		debugmessage("Outfitter_UnregisterEvent",1);
	if pFrame.EventHandlers then
		pFrame.EventHandlers[pEvent] = nil;
	end
	
	pFrame:UnregisterEvent(pEvent);
end

function Outfitter_SuspendEvent(pFrame, pEvent)
		debugmessage("Outfitter_SuspendEvent",1);
	if not pFrame.EventHandlers
	or not pFrame.EventHandlers[pEvent] then
		return;
	end

	pFrame:UnregisterEvent(pEvent);
end

function Outfitter_ResumeEvent(pFrame, pEvent)
		debugmessage("Outfitter_ResumeEvent",1);
	if not pFrame.EventHandlers
	or not pFrame.EventHandlers[pEvent] then
		return;
	end

	pFrame:RegisterEvent(pEvent);
end

function Outfitter_DispatchEvent(pFrame, pEvent)
		debugmessage("Outfitter_DispatchEvent",1);
	if not pFrame.EventHandlers then	
		return false;
	end
	
	local	vEventHandler = pFrame.EventHandlers[pEvent];
	
	if not vEventHandler then
		return false;
	end
	
	Outfitter_BeginEquipmentUpdate();
	vEventHandler(pEvent);
	Outfitter_EndEquipmentUpdate("Outfitter_DispatchEvent("..pEvent..")");
	
	return true;
end

function Outfitter_GetPlayerStat(pStatIndex)
		debugmessage("Outfitter_GetPlayerStat",1);
	local	_, vEffectiveValue, vPosValue, vNegValue = UnitStat("player", pStatIndex);
	
	return vEffectiveValue - vPosValue - vNegValue, vPosValue + vNegValue;
end

function Outfitter_DepositOutfit(pOutfit, pUniqueItemsOnly)
		debugmessage("Outfitter_DepositOutfit",1);
	-- Deselect any outfits to avoid them from being updated when
	-- items get put away
	
	Outfitter_ClearSelection();
	
	-- Build a list of items for the outfit
	
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	
	OutfitterItemList_ResetIgnoreItemFlags(vEquippableItems);
	
	-- Make a copy of the outfit
	
	local	vUnequipOutfit = Outfitter_NewEmptyOutfit();
	
	for vInventorySlot, vItem in pairs(pOutfit.Items) do
		vUnequipOutfit.Items[vInventorySlot] = vItem;
	end
	
	-- Subtract out items from other outfits if unique is specified
	
	if pUniqueItemsOnly then
		for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
			for vOutfitIndex, vOutfit in ipairs(vOutfits) do
				if vOutfit ~= pOutfit then
					local	vMissingItems, vBankedItems = OutfitterItemList_GetMissingItems(vEquippableItems, vOutfit);
					
					-- Only subtract out items from outfits which aren't themselves partialy banked
					
					if vBankedItems == nil then
						Outfitter_SubtractOutfit(vUnequipOutfit, vOutfit, true);
					end
				end -- if vOutfit
			end -- for vOutfitIndex
		end -- for vCategoryID
	end -- if pUniqueItemsOnly
	
	-- Build the change list
	
	OutfitterItemList_ResetIgnoreItemFlags(vEquippableItems);
	
	local	vEquipmentChangeList = Outfitter_BuildUnequipChangeList(vUnequipOutfit, vEquippableItems);
	
	if not vEquipmentChangeList then
		return;
	end
	
	-- Eliminate items which are already banked
	
	local	vChangeIndex = 1;
	local	vNumChanges = #vEquipmentChangeList;
	
	while vChangeIndex <= vNumChanges do
		vEquipmentChange = vEquipmentChangeList[vChangeIndex];
		
		if Outfitter_IsBankBagIndex(vEquipmentChange.FromLocation.BagIndex) then
			table.remove(vEquipmentChangeList, vChangeIndex);
			vNumChanges = vNumChanges - 1;
		else
			vChangeIndex = vChangeIndex + 1;
		end
	end
	
	-- Get the list of empty bank slots
	
	local	vEmptyBankSlots = Outfitter_GetEmptyBankSlotList();
	
	-- Execute the changes
	
	Outfitter_ExecuteEquipmentChangeList2(vEquipmentChangeList, vEmptyBankSlots, Outfitter_cDepositBagsFullError, vExpectedEquippableItems);
end

function Outfitter_WithdrawOutfit(pOutfit)
		debugmessage("Outfitter_WithdrawOutfit",1);
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	
	-- Build a list of items for the outfit
	
	OutfitterItemList_ResetIgnoreItemFlags(vEquippableItems);
	
	local	vEquipmentChangeList = Outfitter_BuildUnequipChangeList(pOutfit, vEquippableItems);
	
	if not vEquipmentChangeList then
		return;
	end
	
	-- Eliminate items which aren't in the bank
	
	local	vChangeIndex = 1;
	local	vNumChanges = #vEquipmentChangeList;
	
	while vChangeIndex <= vNumChanges do
		vEquipmentChange = vEquipmentChangeList[vChangeIndex];
		
		if not Outfitter_IsBankBagIndex(vEquipmentChange.FromLocation.BagIndex) then
			table.remove(vEquipmentChangeList, vChangeIndex);
			vNumChanges = vNumChanges - 1;
		else
			vChangeIndex = vChangeIndex + 1;
		end
	end
	
	-- Get the list of empty bag slots

	local	vEmptyBagSlots = Outfitter_GetEmptyBagSlotList();
	
	-- Execute the changes
	
	Outfitter_ExecuteEquipmentChangeList2(vEquipmentChangeList, vEmptyBagSlots, Outfitter_cWithdrawBagsFullError, vExpectedEquippableItems);
end

function Outfitter_TestOutfitCombinations()
		debugmessage("Outfitter_TestOutfitCombinations",1);
	local	vEquippableItems = OutfitterItemList_GetEquippableItems(true);
	local	vFilterStats = {FireResist = true};
	local	vOutfit = Outfitter_FindOutfitCombination(vEquippableItems, vFilterStats, Outfitter_OutfitTestEval, {});
end

function Outfitter_OutfitTestEval(pOpcode, pParams, pOutfit1, pOutfit2)
		debugmessage("Outfitter_OutfitTestEval",1);
	if pOpcode == "INIT" then
		MCDebugLib:TestMessage("Outfitter_OutfitTestEval: INIT");
	elseif pOpcode == "COMPARE" then
		MCDebugLib:TestMessage("Outfitter_OutfitTestEval: COMPARE");
	end
end

function Outfitter_FindOutfitCombination(pEquippableItems, pFilterStats, pOutfitEvalFunc, pOutfitEvalParams)
		debugmessage("Outfitter_FindOutfitCombination",1);
	local	vSlotIterators = OutfitterSlotIterators_New(pEquippableItems, pFilterStats);
	
	MCDebugLib:DumpArray("vSlotIterators", vSlotIterators);
	
	local	vBestOutfit = nil;
	local	vNumIterations = 0;
	
	pOutfitEvalFunc("INIT", pOutfitEvalParams);
	
	while vSlotIterators:Increment() do
		local	vOutfit = vSlotIterators:GetOutfit();
		
		if pOutfitEvalFunc("COMPARE", pOutfitEvalParams, vBestOutfit, vOutfit) then
			vBestOutfit = vOutfit;
		end
		
		vNumIterations = vNumIterations + 1;
		
		if vNumIterations > 20 then
			return vBestOutfit;
		end
	end
	
	return vBestOutfit;
end

function Outfitter_ItemContainsStats(pItem, pFilterStats)
		debugmessage("Outfitter_ItemContainsStats",1);
	for vStatID, _ in pairs(pFilterStats) do
		if pItem.Stats[vStatID] then
			return true;
		end
	end
	
	return false;
end

function OutfitterSlotIterators_New(pEquippableItems, pFilterStats)
		debugmessage("OutfitterSlotIterators_New",1);
	local	vSlotIterators = {Slots = {}};
	local	vNumCombinations = 1;
	
	for vInventorySlot, vItems in pairs(pEquippableItems.ItemsBySlot) do
		local	vNumItems = #vItems;
		
		if vInventorySlot ~= "AmmoSlot"
		and vNumItems > 0 then
			-- Filter the items by stat
			
			local	vFilteredItems = nil;
			
			if pFilterStats then
				vNumItems = 0;
				
				for vItemIndex, vItem in ipairs(vItems) do
					if Outfitter_ItemContainsStats(vItem, pFilterStats) then
						if not vFilteredItems then
							vFilteredItems = {};
						end
						
						table.insert(vFilteredItems, vItem);
						vNumItems = vNumItems + 1;
					end
				end
			else
				vFilteredItems = vItems;
			end
			
			-- Add the filtered list
			
			if vFilteredItems then
				table.insert(vSlotIterators.Slots, {ItemSlotName = vInventorySlot, Items = vFilteredItems, Index = 0, MaxIndex = vNumItems});
				
				vNumCombinations = vNumCombinations * (vNumItems + 1);
				
				MCDebugLib:TestMessage("OutfitterSlotIterators_New: "..vInventorySlot.." has "..vNumItems.." items. Combinations "..vNumCombinations);
			end
		end
	end
	
	vSlotIterators.Increment = OutfitterSlotIterators_Increment;
	vSlotIterators.GetOutfit = OutfitterSlotIterators_GetOutfit;
	vSlotIterators.SortItemsByStat = OutfitterSlotIterators_SortItemsByStat;
	vSlotIterators.CalcMinNumSlotsByStat = OutfitterSlotIterators_CalcMinNumSlotsByStat;
	
	vSlotIterators.NumCombinations = vNumCombinations;
	
	MCDebugLib:TestMessage("OutfitterSlotIterators_New: Total combinations "..vNumCombinations);
	
	return vSlotIterators;
end

function OutfitterSlotIterators_Increment(pSlotIterators)
		debugmessage("OutfitterSlotIterators_Increment",1);
	for vSlotIndex, vSlotIterator in ipairs(pSlotIterators.Slots) do
		vSlotIterator.Index = vSlotIterator.Index + 1;
		
		if vSlotIterator.Index <= vSlotIterator.MaxIndex then
			return true;
		end
		
		vSlotIterator.Index = 0;
	end
	
	return false; -- Couldn't increment
end

function OutfitterSlotIterators_GetOutfit(pSlotIterators)
		debugmessage("OutfitterSlotIterators_GetOutfit",1);
	local	vOutfit = Outfitter_NewEmptyOutfit();

	for _, vItems in ipairs(pSlotIterators.Slots) do
		-- if vItems.Index > 0 then
		-- 	local	vItem = vItems.Items[vItems.Index];
		-- 	
		-- 	Outfitter_AddOutfitItem(vOutfit, vItems.ItemSlotName, vItem.Code, vItem.SubCode, vItem.Name, vItem.EnchantCode);
		-- end
	end
	
	return vOutfit;
end

local	gOutfitter_CompareStat;

function OutfitterSlotIterators_SortItemsByStat(pIterator, pStat)
		debugmessage("OutfitterSlotIterators_SortItemsByStat",1);
	gOutfitter_CompareStat = pStat;
	
	for _, vSlotInfo in ipairs(pIterator.Slots) do
		table.sort(vSlotInfo.Items,
			function (pItem1, pItem2)
					debugmessage("(",1);
				local	vStat1, vStat2 = pItem1[gOutfitter_CompareStat], pItem2[gOutfitter_CompareStat];
				
				if vStat1 == nil then
					return vStat2 ~= nil;
				elseif not vStat2 then
					return false;
				else
					return vStat1 < vStat2;
				end
			end
		);
	end
end

function OutfitterSlotIterators_CalcMinNumSlotsByStat(pIterator, pStat, pMinValue)
		debugmessage("OutfitterSlotIterators_CalcMinNumSlotsByStat",1);
	local	vStatValues = {};

	for _, vSlotInfo in ipairs(pIterator.Slots) do
		local	vNumItems = #vSlotInfo.Items;
		
		if vNumItems > 0 then
			local	vValue = vSlotInfo.Items[1].Stats[pStat];
			
			if vValue then
				table.insert(vStatValues, vValue);
			end

			if vNumItems > 1
			and (vSlotInfo.ItemSlotName == "Trinket0Slot"
			or vSlotInfo.ItemSlotName == "Finger0Slot"
			or vSlotInfo.ItemSlotName == "WeaponSlot") then
				local	vValue = vSlotInfo.Items[2].Stats[pStat];
				
				if vValue then
					table.insert(vStatValues, vValue);
				end
			end
		end
	end
	
	table.sort(vStatValues, function (pValue1, pValue2) return pValue1 > pValue2 end);
	debugmessage("(",1);
	
	local	vTotal = 0;
	
	for vIndex, vValue in ipairs(vStatValues) do
		vTotal = vTotal + vValue;
		
		if vTotal >= pMinValue then
			return vIndex;
		end
	end
	
	return #vStatValues;
end

function OutfitterStats_AddStatValue(pStats, pStat, pValue, pDistribution)
		debugmessage("OutfitterStats_AddStatValue",1);
	if not pStats[pStat] then
		pStats[pStat] = pValue;
	else
		pStats[pStat] = pStats[pStat] + pValue;
	end
	
	--
	
	local	vRatingDistribution = Outfitter_GetPlayerRatingStatDistribution();
	local	vStatDistribution = vRatingDistribution[pStat];
	
	if vStatDistribution then
		for vSecondaryStat, vFactors in pairs(vStatDistribution) do
			local	vSecondaryValue = pValue * vFactors.Coeff;
			
			if vFactors.Const then
				vSecondaryValue = vSecondaryValue + vFactors.Const;
			end
			
			OutfitterStats_AddStatValue(pStats, vSecondaryStat, vSecondaryValue, pDistribution);
		end
	end

	if not pDistribution then
		return;
	end
	
	vStatDistribution = pDistribution[pStat];
	
	if not vStatDistribution then
		return;
	end
	
	for vSecondaryStat, vFactors in pairs(vStatDistribution) do
		local	vSecondaryValue = pValue * vFactors.Coeff;
		
		if vFactors.Const then
			vSecondaryValue = vSecondaryValue + vFactors.Const;
		end
		
		if pStats[vSecondaryStat] then
			pStats[vSecondaryStat] = pStats[vSecondaryStat] + vSecondaryValue;
		else
			pStats[vSecondaryStat] = vSecondaryValue;
		end
	end
end

function OutfitterStats_SubtractStats(pStats, pStats2)
		debugmessage("OutfitterStats_SubtractStats",1);
	for vStat, vValue in pairs(pStats2) do
		if pStats[vStat] then
			pStats[vStat] = pStats[vStat] - vValue;
		end
	end
end

function OutfitterStats_AddStats(pStats, pStats2)
		debugmessage("OutfitterStats_AddStats",1);
	for vStat, vValue in pairs(pStats2) do
		if pStats[vStat] then
			pStats[vStat] = pStats[vStat] + vValue;
		else
			pStats[vStat] = vValue;
		end
	end
end

function OutfitterTankPoints_New()
		debugmessage("OutfitterTankPoints_New",1);
	local	vTankPointData = {};
	local	_, vPlayerClass = UnitClass("player");
	local	vStatDistribution = Outfitter_GetPlayerStatDistribution();
	
	if not vStatDistribution then
		MCDebugLib:ErrorMessage("Outfitter: Missing stat distribution data for "..vPlayerClass);
		return;
	end
	
	vTankPointData.PlayerLevel = UnitLevel("player");
	vTankPointData.StaminaFactor = 1.0; -- Warlocks with demonic embrace = 1.15
	
	-- Get the base stats
	
	vTankPointData.BaseStats = {};
	
	OutfitterStats_AddStatValue(vTankPointData.BaseStats, "Strength", UnitStat("player", 1), vStatDistribution);
	OutfitterStats_AddStatValue(vTankPointData.BaseStats, "Agility", UnitStat("player", 2), vStatDistribution);
	OutfitterStats_AddStatValue(vTankPointData.BaseStats, "Stamina", UnitStat("player", 3), vStatDistribution);
	OutfitterStats_AddStatValue(vTankPointData.BaseStats, "Intellect", UnitStat("player", 4), vStatDistribution);
	OutfitterStats_AddStatValue(vTankPointData.BaseStats, "Spirit", UnitStat("player", 5), vStatDistribution);
	
	OutfitterStats_AddStatValue(vTankPointData.BaseStats, "Health", UnitHealthMax("player"), vStatDistribution);
	
	vTankPointData.BaseStats.Health = vTankPointData.BaseStats.Health - vTankPointData.BaseStats.Stamina * 10;
	
	vTankPointData.BaseStats.Dodge = GetDodgeChance();
	vTankPointData.BaseStats.Parry = GetParryChance();
	vTankPointData.BaseStats.Block = GetBlockChance();
	
	local	vBaseDefense, vBuffDefense = UnitDefense("player");
	OutfitterStats_AddStatValue(vTankPointData.BaseStats, "Defense", vBaseDefense + vBuffDefense, vStatDistribution);
	
	-- Replace the armor with the current value since that already includes various factors
	
	local	vBaseArmor, vEffectiveArmor, vArmor, vArmorPosBuff, vArmorNegBuff = UnitArmor("player");
	vTankPointData.BaseStats.Armor = vEffectiveArmor;
	
	MCDebugLib:TestMessage("------------------------------------------");
	MCDebugLib:DumpArray("vTankPointData", vTankPointData);
	
	-- Subtract out the current outfit
	
	local	vCurrentOutfitStats = OutfitterTankPoints_GetCurrentOutfitStats(vStatDistribution);
	
	MCDebugLib:TestMessage("------------------------------------------");
	MCDebugLib:DumpArray("vCurrentOutfitStats", vCurrentOutfitStats);
	
	OutfitterStats_SubtractStats(vTankPointData.BaseStats, vCurrentOutfitStats);
	
	-- Calculate the buff stats (stuff from auras/spell buffs/whatever)
	
	vTankPointData.BuffStats = {};
	
	-- Reset the cumulative values
	
	OutfitterTankPoints_Reset(vTankPointData);
	
	MCDebugLib:TestMessage("------------------------------------------");
	MCDebugLib:DumpArray("vTankPointData", vTankPointData);
	
	MCDebugLib:TestMessage("------------------------------------------");
	return vTankPointData;
end

function OutfitterTankPoints_Reset(pTankPointData)
		debugmessage("OutfitterTankPoints_Reset",1);
	pTankPointData.AdditionalStats = {};
end

function OutfitterTankPoints_GetTotalStat(pTankPointData, pStat)
		debugmessage("OutfitterTankPoints_GetTotalStat",1);
	local	vTotalStat = pTankPointData.BaseStats[pStat];
	
	if not vTotalStat then
		vTotalStat = 0;
	end
	
	local	vAdditionalStat = pTankPointData.AdditionalStats[pStat];
	
	if vAdditionalStat then
		vTotalStat = vTotalStat + vAdditionalStat;
	end
	
	local	vBuffStat = pTankPointData.BuffStats[pStat];
	
	if vBuffStat then
		vTotalStat = vTotalStat + vBuffStat;
	end
	
	--
	
	return vTotalStat;
end

function OutfitterTankPoints_CalcTankPoints(pTankPointData, pStanceModifier)
		debugmessage("OutfitterTankPoints_CalcTankPoints",1);
	if not pStanceModifier then
		pStanceModifier = 1;
	end
	
	MCDebugLib:DumpArray("pTankPointData", pTankPointData);
	
	local	vEffectiveArmor = OutfitterTankPoints_GetTotalStat(pTankPointData, "Armor");
	
	MCDebugLib:TestMessage("Armor: "..vEffectiveArmor);
	
	local	vArmorReduction = vEffectiveArmor / ((85 * pTankPointData.PlayerLevel) + 400);
	
	vArmorReduction = vArmorReduction / (vArmorReduction + 1);
	
	local	vEffectiveHealth = OutfitterTankPoints_GetTotalStat(pTankPointData, "Health");
	
	MCDebugLib:TestMessage("Health: "..vEffectiveHealth);
	
	MCDebugLib:TestMessage("Stamina: "..OutfitterTankPoints_GetTotalStat(pTankPointData, "Stamina"));
	
	--
	
	local	vEffectiveDodge = OutfitterTankPoints_GetTotalStat(pTankPointData, "Dodge") * 0.01;
	local	vEffectiveParry = OutfitterTankPoints_GetTotalStat(pTankPointData, "Parry") * 0.01;
	local	vEffectiveBlock = OutfitterTankPoints_GetTotalStat(pTankPointData, "Block") * 0.01;
	local	vEffectiveDefense = OutfitterTankPoints_GetTotalStat(pTankPointData, "Defense");
	
	-- Add agility and defense to dodge
	
	-- defenseInputBox:GetNumber() * 0.04 + agiInputBox:GetNumber() * 0.05

	MCDebugLib:TestMessage("Dodge: "..vEffectiveDodge);
	MCDebugLib:TestMessage("Parry: "..vEffectiveParry);
	MCDebugLib:TestMessage("Block: "..vEffectiveBlock);
	MCDebugLib:TestMessage("Defense: "..vEffectiveDefense);
	
	local	vDefenseModifier = (vEffectiveDefense - pTankPointData.PlayerLevel * 5) * 0.04 * 0.01;
	
	MCDebugLib:TestMessage("Crit reduction: "..vDefenseModifier);
	
	local	vMobCrit = max(0, 0.05 - vDefenseModifier);
	local	vMobMiss = 0.05 + vDefenseModifier;
	local	vMobDPS = 1;
	
	local	vTotalReduction = 1 - (vMobCrit * 2 + (1 - vMobCrit - vMobMiss - vEffectiveDodge - vEffectiveParry)) * (1 - vArmorReduction) * pStanceModifier;
	
	MCDebugLib:TestMessage("Total reduction: "..vTotalReduction);
	
	local	vTankPoints = vEffectiveHealth / (vMobDPS * (1 - vTotalReduction));
	
	return vTankPoints;
	
	--[[
	Stats used in TankPoints calculation:
		Health
		Dodge
		Parry
		Block
		Defense
		Armor
	]]--
end

function OutfitterTankPoints_GetCurrentOutfitStats(pStatDistribution)
		debugmessage("OutfitterTankPoints_GetCurrentOutfitStats",1);
	local	vTotalStats = {};
	
	for _, vSlotName in ipairs(Outfitter_cSlotNames) do
		local	vStats = OutfitterItemList_GetItemStats({SlotName = vSlotName});
		
		if vStats then
			for vStat, vValue in pairs(vStats) do
				OutfitterStats_AddStatValue(vTotalStats, vStat, vValue, pStatDistribution);
			end
		end
	end
	
	return vTotalStats;
end

function OutfitterTankPoints_Test()
		debugmessage("OutfitterTankPoints_Test",1);
	local	_, vPlayerClass = UnitClass("player");
	local	vStatDistribution = Outfitter_GetPlayerStatDistribution();
	
	local	vTankPointData = OutfitterTankPoints_New();
	local	vStats = OutfitterTankPoints_GetCurrentOutfitStats(vStatDistribution);
	
	OutfitterStats_AddStats(vTankPointData.AdditionalStats, vStats);
	
	local	vTankPoints = OutfitterTankPoints_CalcTankPoints(vTankPointData);
	
	MCDebugLib:TestMessage("TankPoints = "..vTankPoints);
end

function Outfitter_TestAmmoSlot()
		debugmessage("Outfitter_TestAmmoSlot",1);
	local	vItemInfo = Outfitter_GetInventoryItemInfo("AmmoSlot");
	local	vSlotID = Outfitter_cSlotIDs.AmmoSlot;
	local	vItemLink = GetInventoryItemLink("player", vSlotID);
	
	MCDebugLib:DumpArray("vItemInfo", vItemInfo);
	
	MCDebugLib:TestMessage("SlotID: "..vSlotID);
	MCDebugLib:TestMessage("ItemLink: "..vItemLink);
end

function Outfitter_GameToolTip_OnShow(...)
		debugmessage("Outfitter_GameToolTip_OnShow",1);
	if gOutfitter_OrigGameTooltipOnShow then
		gOutfitter_OrigGameTooltipOnShow(...);
	end
	
--	if gOutfitter_Settings.Options.Debug then
--		MCDebugLib:NoteMessage("Outfitter: Tooltip Show");
--	end
	
	MCEventLib:DispatchEvent("GAMETOOLTIP_SHOW");
end

function Outfitter_OutfitUsesItem(pOutfit, pItemInfo)
		debugmessage("Outfitter_OutfitUsesItem",1);
	local	vEquippableItems = OutfitterItemList_GetEquippableItems(false);
	local	vItemInfo, vItemInfo2;
	
	if pItemInfo.ItemSlotName == "Finger0Slot" then
		vItemInfo = pOutfit.Items.Finger0Slot;
		vItemInfo2 = pOutfit.Items.Finger1Slot;
	elseif pItemInfo.ItemSlotName == "Trinket0Slot" then
		vItemInfo = pOutfit.Items.Trinket0Slot;
		vItemInfo2 = pOutfit.Items.Trinket1Slot;
	elseif pItemInfo.MetaSlotName == "Weapon0Slot" then
		vItemInfo = pOutfit.Items.MainHandSlot;
		vItemInfo2 = pOutfit.Items.SecondaryHandSlot;
	else
		vItemInfo = pOutfit.Items[pItemInfo.ItemSlotName];
	end
	
	return (vItemInfo and OutfitterItemList_ItemsAreSame(vEquippableItems, vItemInfo, pItemInfo))
	    or (vItemInfo2 and OutfitterItemList_ItemsAreSame(vEquippableItems, vItemInfo2, pItemInfo));
end

function Outfitter_GetOutfitsUsingItem(pItemInfo)
		debugmessage("Outfitter_GetOutfitsUsingItem",1);
	local	vOutfitsUsingItem;
	
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			if Outfitter_OutfitUsesItem(vOutfit, pItemInfo) then
				if not vOutfitsUsingItem then
					vOutfitsUsingItem = {};
				end
				
				table.insert(vOutfitsUsingItem, vOutfit);
			end
		end
	end
	
	return vOutfitsUsingItem;
end

function Outfitter_AddOutfitsToTooltip(pTooltip, pPrefix, pOutfits)
	debugmessage("Outfitter_AddOutfitsToTooltip",1);
	if not pOutfits
	or not next(pOutfits) then
		Outfitter.lastToolTip = nil;
		return;
	end
	
	local	vEquippableItems = OutfitterItemList_GetEquippableItems();
	local	vNames = nil;
	
	for _, vOutfit in ipairs(pOutfits) do
		local	vMissingItems, vBankedItems = OutfitterItemList_GetMissingItems(vEquippableItems, vOutfit);
		local	vName;
		
		if vOutfit.Disabled then
			vName = GRAY_FONT_COLOR_CODE;
		elseif vMissingItems then
			vName = RED_FONT_COLOR_CODE;
		elseif vBankedItems then
			vName = BANKED_FONT_COLOR_CODE;
		else
			vName = NORMAL_FONT_COLOR_CODE;
		end

		 vName = vName..vOutfit.Name..FONT_COLOR_CODE_CLOSE;
		
		if vNames then
			vNames = vNames..", "..vName;
		else
			vNames = vName;
		end
	end
	
	Outfitter.lastToolTip = pPrefix..vNames;
	GameTooltip:AddLine(pPrefix..vNames, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
	GameTooltip:Show();
end

function Outfitter_AddOutfitsUsingItemToTooltip(pTooltip, pPrefix, pItemInfo)
	debugmessage("Outfitter_AddOutfitsUsingItemToTooltip",1);
	local	vOutfits = Outfitter_GetOutfitsUsingItem(pItemInfo);
	
	if not vOutfits then
		-- just opt out if we have nothing to add
		Outfitter.lastToolTip = nil

		return;
	end
	
	Outfitter_AddOutfitsToTooltip(pTooltip, pPrefix, vOutfits);
end

function Outfitter_GameToolTip_OnHide(...)
	debugmessage("Outfitter_GameToolTip_OnHide",1);
	if gOutfitter_OrigGameTooltipOnHide then
		gOutfitter_OrigGameTooltipOnHide(...);
	end

--	if gOutfitter_Settings.Options.Debug then
--		MCDebugLib:NoteMessage("Outfitter: Tooltip hide");
--	end
	
	MCEventLib:DispatchEvent("GAMETOOLTIP_HIDE");
end

local	gOutfitter_LastToolTip = nil;
local	gOutfitter_LastToolTipTime = nil;
local	Outfitter_cMinToolTipTime = 0.75;
local	Outfitter_cLastToolTipResult = nil;
local Outftter_SpellSentTime = nil;

function Outfitter_GameTooltip_SetBagItem(pTooltip, pBag, pSlot, ...)
	debugmessage("Outfitter_GameTooltip_SetBagItem",1);
	local	vResult = {pTooltip:Outfitter_OrigSetBagItem(pBag, pSlot, ...)};

	local	vTime = GetTime();
	
	if gOutfitter_LastToolTip == pSlot then
		local	vElapsed = vTime - gOutfitter_LastToolTipTime;
		
		--if gOutfitter_Settings.Options.Debug then
		--	MCDebugLib:NoteMessage("Outfitter: Bag:"..pBag.." Slot:"..pSlot);
		--end

		if vElapsed < Outfitter_cMinToolTipTime then
			Outfitter_cMinToolTipTime = vTime

			-- just opt out if we havenothing to add
			if Outfitter.lastToolTip == nil then
				return unpack(vResult);
			end
			
			GameTooltip:AddLine(Outfitter.lastToolTip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			GameTooltip:Show();
			return unpack(vResult);
		end
	end
	
	-- remove the last known information.
	Outfitter.lastToolTip = nil;
	
	-- Set the values
	gOutfitter_LastToolTip = pSlot
	gOutfitter_LastToolTipTime = vTime

	debugmessage("Setting Bag Item Tooltip", 2);

	-- Install the "Used by outfits" tooltip feature
	local	vItemInfo = Outfitter_GetBagItemInfo(pBag, pSlot);
	
	if vItemInfo then
		Outfitter_AddOutfitsUsingItemToTooltip(pTooltip, Outfitter_cUsedByPrefix, vItemInfo);
	end
	
	return unpack(vResult);
end

function Outfitter_GameTooltip_SetInventoryItem(pTooltip, pUnit, pSlot, pNameOnly, ...)
	debugmessage("Outfitter_GameTooltip_SetInventoryItem",1);

	-- Start the Gather information session.
	local	vResult = {pTooltip:Outfitter_OrigSetInventoryItem(pUnit, pSlot, pNameOnly, ...)};
	
	local	vTime = GetTime();
	
	if gOutfitter_LastToolTip == pSlot then
		local	vElapsed = vTime - gOutfitter_LastToolTipTime;
		
		if vElapsed < Outfitter_cMinToolTipTime then
			Outfitter_cMinToolTipTime = vTime;
	
			-- just opt out if we have nothing to add
			if Outfitter.lastToolTip == nil then
				return unpack(vResult);
			end
	
			GameTooltip:AddLine(Outfitter.lastToolTip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			GameTooltip:Show();
			return unpack(vResult);
		end
	end
	
	-- Set the values
	Outfitter.lastToolTip = nil;
	gOutfitter_LastToolTip = pSlot
	gOutfitter_LastToolTipTime = vTime
	

	debugmessage("Setting Inventory Item Tooltip", 2);

	-- Add the list of outfits the item is used by
	
	if UnitIsUnit(pUnit, "player") then
	
	-- Install the "Used by outfits" tooltip feature

		local	vItemLink = Outfitter_GetInventorySlotIDLink(pSlot);
		local	vItemInfo = Outfitter_GetItemInfoFromLink(vItemLink);
		
		if vItemInfo then
			Outfitter_AddOutfitsUsingItemToTooltip(pTooltip, Outfitter_cUsedByPrefix, vItemInfo);
		end
	end
	
	return unpack(vResult);
end

function Outfitter_InitializeFrameMethods(pFrame, pMethods)
	debugmessage("Outfitter_InitializeFrameMethods",1);
	if pMethods then
		for vMethodField, vMethodFunction in pairs(pMethods) do
			pFrame[vMethodField] = vMethodFunction;
		end
	end
end

function Outfitter_InitializeFrameWidgets(pFrame, pWidgets)
	debugmessage("Outfitter_InitializeFrameWidgets",1);
	if pWidgets then
		local	vFrameName = pFrame:GetName();
		
		for _, vWidgetName in pairs(pWidgets) do
			if string.sub(vWidgetName, -1) == "*" then
				vWidgetName = string.sub(vWidgetName, 1, -2);
				
				pFrame[vWidgetName] = {ParentFrame = getglobal(vFrameName..vWidgetName)};
				
				local	vIndex = 1;
				
				while true do
					local	vWidget = getglobal(vFrameName..vWidgetName..vIndex);
					
					if not vWidget then
						break;
					end
					
					vWidget:SetID(vIndex);
					table.insert(pFrame[vWidgetName], vWidget);
					
					vIndex = vIndex + 1;
				end
			else
				pFrame[vWidgetName] = getglobal(vFrameName..vWidgetName);
			end
		end
	end
end

function Outfitter_MultiStatTest()
	debugmessage("Outfitter_MultiStatTest",1);
	local	vStat = "Intellect";
	local	vMinValue = 100;
	local	vStat2 = "FireResist";
	local	vEquippableItems = OutfitterItemList_GetEquippableItems(true);
	
	local	vIterator = OutfitterSlotIterators_New(vEquippableItems, {[vStat] = true});
	
	vIterator:SortItemsByStat(vStat);
	
	local	vMinNumSlots = vIterator:CalcMinNumSlotsByStat(vStat, vMinValue);
	
	MCDebugLib:DumpArray("Iterator", vIterator);
	MCDebugLib:TestMessage(vMinNumSlots.." needed for "..vMinValue.." "..vStat);
end

local	gOutfitter_OpenDialogs = {};

function Outfitter_DialogOpened(pDialog)
	debugmessage("Outfitter_DialogOpened",1);
	
	-- Make sure it isn't already open
	for _, vDialog in ipairs(gOutfitter_OpenDialogs) do
		if vDialog == pDialog then
			return;
		end
	end
	
	table.insert(gOutfitter_OpenDialogs, pDialog);
end

function Outfitter_DialogClosed(pDialog)
		debugmessage("Outfitter_DialogClosed",1);
	debugmessage("Dialog Closed", 1);
	for vIndex, vDialog in ipairs(gOutfitter_OpenDialogs) do
		if vDialog == pDialog then
			table.remove(gOutfitter_OpenDialogs, vIndex);
			return;
		end
	end
	
	MCDebugLib:ErrorMessage("Outfitter_DialogClosed called on an unknown dialog: "..pDialog:GetName());
end

function Outfitter_StaticPopup_EscapePressed()
	debugmessage("Outfitter_StaticPopup_EscapePressed",1);

	local	vClosed = gOutfitter_OriginalStaticPopup_EscapePressed();
	local	vNumDialogs = #gOutfitter_OpenDialogs;
	
	for vIndex = 1, vNumDialogs do
		local	vDialog = gOutfitter_OpenDialogs[1];
		vDialog.Cancel(vDialog);
		vClosed = 1;
	end
	
	return vClosed;
end

function Outfitter_TooltipContainsLine(pTooltip, pText)
	debugmessage("Outfitter_TooltipContainsLine",1);
	local	vTooltipName = pTooltip:GetName();
	
	for vLine = 1, 30 do
		local	vText = getglobal(vTooltipName.."TextLeft"..vLine);
		
		if not vText then
			return false;
		end
		
		if vText:GetText() == pText then
			local	vColor = {};
			
			vColor.r, vColor.g, vColor.b = vText:GetTextColor();
			
			local	vHSVColor = Outfitter_RGBToHSV(vColor);
			
			return true, vHSVColor.s > 0.2 and vHSVColor.v > 0.2 and (vHSVColor.h < 50 or vHSVColor.h > 150);
		end
	end
end

function Outfitter_RecycleTable(pTable)
	debugmessage("Outfitter_RecycleTable",1);
	if not pTable then
		return {};
	else
		Outfitter_EraseTable(pTable);
		return pTable;
	end
end

function Outfitter_EraseTable(pTable)
	debugmessage("Outfitter_EraseTable",1);
	for vKey in pairs(pTable) do
		pTable[vKey] = nil;
	end
end

function Outfitter_RGBToHSV(pRGBColor)
	debugmessage("RGB To HSV", 1);
	local	vHSVColor = {};
	local	vBaseAngle;
	local	vHueColor;
	
	if not pRGBColor.r
	or not pRGBColor.g
	or not pRGBColor.b then
		vHSVColor.h = 0;
		vHSVColor.s = 0;
		vHSVColor.v = 1;
		
		return vHSVColor;
	end
	
	if pRGBColor.r >= pRGBColor.g
	and pRGBColor.r >= pRGBColor.b then
		-- Red is dominant
		
		vHSVColor.v = pRGBColor.r;
		
		vBaseAngle = 0;
		
		if pRGBColor.g >= pRGBColor.b then
			vHSVColor.s = 1 - pRGBColor.b;
			vHueColor = pRGBColor.g;
		else
			vHSVColor.s = 1 - pRGBColor.g;
			vHueColor = -pRGBColor.b;
		end
	elseif pRGBColor.g >= pRGBColor.b then
		-- Green is dominant

		vHSVColor.v = pRGBColor.g;

		vBaseAngle = 120;
		
		if pRGBColor.r >= pRGBColor.b then
			vHSVColor.s = 1 - pRGBColor.b;
			vHueColor = -pRGBColor.r;
		else
			vHSVColor.s = 1 - pRGBColor.r;
			vHueColor = pRGBColor.b;
		end
	else
		-- Blue is dominant
		
		vHSVColor.v = pRGBColor.b;

		vBaseAngle = 240;
		
		if pRGBColor.r >= pRGBColor.g then
			vHSVColor.s = 1 - pRGBColor.g;
			vHueColor = pRGBColor.r;
		else
			vHSVColor.s = 1 - pRGBColor.r;
			vHueColor = -pRGBColor.g;
		end
	end
	
	vHSVColor.h = vBaseAngle + (vHueColor / vHSVColor.v) * 60;
	
	if vHSVColor.h < 0 then
		vHSVColor.h = vHSVColor.h + 360;
	end
	
	return vHSVColor;
end

function Outfitter_FiveSecondRule()
	-- lets check if we are in the Five Sec Cool down
	if gOutfitter_LastManaCall > -1 then
		local	vElapsed = GetTime() - gOutfitter_LastManaCall;
		if (vElapsed > 4.99) then
			gOutfitter_LastManaCall	 = -1;
			MCEventLib:DispatchEvent("OUTOFFIVESECONDRULE");		
		end
	end
end

function OutfitterScrollBarUpdate()
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  
  FauxScrollFrame_Update(OutfitterDebugFrameScrollBar,getn(DebugData),5,16);
  
  for line=1,5 do
    lineplusoffset = line + FauxScrollFrame_GetOffset(Outfitter_DebugFrame_ScrollBar);
    if lineplusoffset < getn(DebugData) then
      getglobal("OutfitterDebugFrameScrollBarEntry"..line):SetText(DebugData[lineplusoffset]);
      getglobal("OutfitterDebugFrameScrollBarEntry"..line):Show();
    else
      getglobal("OutfitterDebugFrameScrollBarEntry"..line):Hide();
    end
  end
  
end

function debugmessage(message, level)
	--local tablesize = getn(DebugData);
	--DebugData[tablesize + 1] = message;

	if gOutfitter_Settings then

		if not gOutfitter_Settings.DebugLevel then 
			gOutfitter_Settings.DebugLevel = 1;
		end

		if gOutfitter_Settings.Options.Debug then
			if level >= gOutfitter_Settings.DebugLevel then
				if gOutfitter_Settings.DebugLevel == 1 then
					MCDebugLib:NoteMessage("Outfitter: "..message);
				else
					MCDebugLib:ErrorMessage("Outfitter: "..message);
				end
			end
		end
	--else
	--	MCDebugLib:NoteMessage("Outfitter: "..message);
	end
end

---------------------------------------------------------------------------
-- modified by jtbalogh

-- Listbox
-- from Auto-Bag adopted v1800-2, Author: VincentGdG

-- (not generic to work on more than one listbox)
-- size and number of buttons are defined in xml
-- local variables below save for one box
-- global array in variable, 
-- size of table defined by Outfitter_cSlotNames
-- etc.

local Outfitter_Arrange_Selected1 = 0
local Outfitter_Arrange_SelName1 = ""
local Outfitter_buttonTotal1 = 10

--Outfitter.SelectedOutfit.SlotPriority contains list
--Outfitter.PriorityLayerLevel.SlotPriority not applicable because listbox only uses selected outfit
--Outfitter_getnkey(Outfitter.SelectedOutfit.SlotPriority) to access size of table
--Outfitter_Arrange_SelName1 is the text of any keyword in the list

function Outfitter_UpdateListBox()
	local NumSaves = Outfitter_getnkey(Outfitter.SelectedOutfit.SlotPriority)
	--local NumSaves = getn(Outfitter.SelectedOutfit.SlotPriority) -- not applicable
	-- WARNING, crashes if saved variable is not loaded yet

	local scrollbar = getglobal("Outfitter_Arrange_ListBoxScrollFrameScrollBar")
	if NumSaves < Outfitter_buttonTotal1 then
		scrollbar:SetMinMaxValues(0, 0)
		scrollbar:SetValue(0)
	else
		scrollbar:SetMinMaxValues(0, NumSaves - Outfitter_buttonTotal1)
		scrollbar:SetValue(0)
	end

	Outfitter_OnScroll(getglobal("Outfitter_Arrange_ListBoxScrollFrame"))
end

function Outfitter_getnkey(listbox)
	local i = 0
	if not listbox then
	else
		for key, value in pairs(listbox) do
			i = i + 1
		end
	end

	-- Alternative
	-- fails, because getn() not valid and returns zero for tables with keys as the index
	-- and crashes if table is nil
	--i = getn(listbox)
	--i = getn(Outfitter.SelectedOutfit.SlotPriority)

	return i
end

function Outfitter_Arrange_OnClick(button)
	Outfitter_Arrange_Selected1 = button.Number
	Outfitter_Arrange_Selected1 = Outfitter_Arrange_Selected1 + getglobal(button:GetParent():GetName().."ScrollFrameScrollBar"):GetValue()
	Outfitter_Arrange_SelName1 = getglobal(button:GetName().."Text")
	Outfitter_Arrange_SelName1 = Outfitter_Arrange_SelName1:GetText()
end

function Outfitter_ListButton_OnClick(button)
	local highlight = getglobal(button:GetParent():GetName().."Highlight")
	
	if not getglobal(button:GetName().."Text"):GetText() then return end

	highlight:Show()
	highlight:ClearAllPoints()
	highlight:SetPoint("TOPLEFT", button:GetName(), "TOPLEFT", 0, 0)
	
	if string.find( button:GetName(), "Outfitter_Arrange_ListBox" ) then
		Outfitter_Arrange_OnClick(button)
	end
end

function Outfitter_ListButton_OnEnter(this)
	-- Optional, show item for current slot in tooltip for easy reference
	local text = ""
	local slotname = getglobal(this:GetName().."Text"):GetText()
	if not slotname then return end

	--text = ...
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText(text, nil, nil, nil, nil, 1)
end

function Outfitter_ListButton_OnLeave(this)
	GameTooltip:Hide()
end

function Outfitter_Arrange_OnScroll(scroll)
	local n = getglobal(scroll:GetName().."ScrollBar"):GetValue()
	local buttonNo = 1

	for i = 1, Outfitter_buttonTotal1, 1 do
		getglobal("Outfitter_Arrange_ListBoxButton"..i.."Text"):SetText("")
	end

	-- Setup highlight
	local temp = Outfitter_Arrange_Selected1 - n
	if temp < 1 or temp > Outfitter_buttonTotal1 then
	--if temp <= 0 or temp >= 6 then
		getglobal(scroll:GetParent():GetName().."Highlight"):Hide()
	else
		local highlight = getglobal(scroll:GetParent():GetName().."Highlight")
		highlight:Show()
		highlight:ClearAllPoints()
		highlight:SetPoint("TOPLEFT", scroll:GetParent():GetName().."Button"..temp, "TOPLEFT", 0, 0)
	end

	-- Display list in window
	for key, value in pairs(Outfitter.SelectedOutfit.SlotPriority) do
		if n == 0 then
			if buttonNo > Outfitter_buttonTotal1 then
				getglobal(scroll:GetName().."ScrollBarScrollDownButton"):Enable()
				--getglobal("Outfitter_Arrange_ListBoxScrollFrameScrollBarScrollDownButton"):Enable()
				return
			end
			getglobal("Outfitter_Arrange_ListBoxButton"..buttonNo.."Text"):SetText(value)
			buttonNo = buttonNo + 1
		else
			n = n - 1
		end
	end
	getglobal(scroll:GetName().."ScrollBarScrollDownButton"):Disable()
end

function Outfitter_OnScroll(scroll)
	if string.find( scroll:GetName(), "Outfitter_Arrange_ListBox" ) then
		Outfitter_Arrange_OnScroll(scroll)
	end
end

function Outfitter_ListBox_OnLoad(ListBox)
end

function Outfitter_ListBox_OnShow(ListBox)
	Outfitter_ListBox_Reset()
	Outfitter_OnScroll(getglobal(this:GetName().."ScrollFrame"))
end

function Outfitter_ListBox_ResetHighlight()
	getglobal("Outfitter_Arrange_ListBoxHighlight"):Hide()
	Outfitter_Arrange_Selected1 = 0
	Outfitter_Arrange_SelName1 = nil
end

function Outfitter_ListBox_Reset()
	Outfitter_UpdateListBox()
	Outfitter_ListBox_ResetHighlight()
end

function Outfitter_ListButtonUp_OnClick()
	local n = Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue()
	local SlotPrioritytemp = {}

	local isFirst = nil
	if Outfitter_Arrange_Selected1 == 1 then
		isFirst = 1
	end

	if not Outfitter_Arrange_SelName1 then -- nothing highlighted
	elseif isFirst then
	else
		-- Rebuild array
		local keybackup = nil
		local valuebackup = nil
		local row = 0
		for key, value in pairs(Outfitter.SelectedOutfit.SlotPriority) do
			row = row + 1
			if strlower(value) == strlower(Outfitter_Arrange_SelName1) then
				-- add entry prior
--				if row == 1 then -- already first
--					isFirst = 1
--					break
--				end
-- (no longer implemented, already detected

				-- Swap
				SlotPrioritytemp[keybackup] = value
				SlotPrioritytemp[key] = valuebackup
				keybackup = nil -- not needed anymore
				valuebackup = nil

			else
				SlotPrioritytemp[key] = value -- add entry
				keybackup = key
				valuebackup = value
			end
		end
		Outfitter.SelectedOutfit.SlotPriority = SlotPrioritytemp

		-- Scroll fixed so highlight remains fixed and not at edge
		Outfitter_Arrange_ListBoxScrollFrameScrollBar:SetValue(n - 1)
		Outfitter_Arrange_Selected1 = Outfitter_Arrange_Selected1 - 1

		-- Scroll adjusted so highlight moves to middle so easier to see
		if Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue() <= 1 then
		elseif (Outfitter_Arrange_Selected1 - Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue()) == (Outfitter_buttonTotal1 /2) then
		elseif (Outfitter_Arrange_Selected1 - Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue()) < (Outfitter_buttonTotal1 /2) then
			Outfitter_Arrange_ListBoxScrollFrameScrollBar:SetValue(Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue() - 1)
		else
			Outfitter_Arrange_ListBoxScrollFrameScrollBar:SetValue(Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue() + 1)
		end

		Outfitter_OnScroll(Outfitter_Arrange_ListBoxScrollFrame)
	end
end

function Outfitter_ListButtonDown_OnClick()
	local n = Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue()
	local SlotPrioritytemp = {}

	local isLast = nil
	if Outfitter_Arrange_Selected1 == Outfitter_getnkey(Outfitter.SelectedOutfit.SlotPriority) then
		isLast = 1
	end

	if not Outfitter_Arrange_SelName1 then -- nothing highlighted
	elseif isLast then
	else
		-- Rebuild array
		local keyoffset = 0
		local keybackup = nil
		local valuebackup = nil
		for key, value in pairs(Outfitter.SelectedOutfit.SlotPriority) do
			if strlower(value) == strlower(Outfitter_Arrange_SelName1) then
				-- add entry after next
				keyoffset = -1
				keybackup = key
				valuebackup = value
			else
				-- Swap if offset
				SlotPrioritytemp[key +keyoffset] = value -- add entry
				if valuebackup then
					SlotPrioritytemp[key] = valuebackup -- add entry
					keyoffset = 0 -- not needed anymore
					keybackup = nil
					valuebackup = nil
				end
			end
		end
--		if valuebackup then -- already last
--			SlotPrioritytemp[keybackup] = valuebackup -- add entry
--		end
-- (no longer implemented, already detected
		Outfitter.SelectedOutfit.SlotPriority = SlotPrioritytemp

		-- Scroll fixed so highlight remains fixed and not at edge
		Outfitter_Arrange_ListBoxScrollFrameScrollBar:SetValue(n + 1)
		Outfitter_Arrange_Selected1 = Outfitter_Arrange_Selected1 + 1

		-- Scroll adjusted so highlight moves to middle so easier to see
		if Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue() >= Outfitter_getnkey(Outfitter.SelectedOutfit.SlotPriority) then
		elseif (Outfitter_Arrange_Selected1 - Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue()) == (Outfitter_buttonTotal1 /2) then
		elseif (Outfitter_Arrange_Selected1 - Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue()) < (Outfitter_buttonTotal1 /2) then
			Outfitter_Arrange_ListBoxScrollFrameScrollBar:SetValue(Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue() - 1)
		else
			Outfitter_Arrange_ListBoxScrollFrameScrollBar:SetValue(Outfitter_Arrange_ListBoxScrollFrameScrollBar:GetValue() + 1)
		end

		Outfitter_OnScroll(Outfitter_Arrange_ListBoxScrollFrame)
	end
end

function Outfitter_ListButtonReset_OnClick()
	Outfitter.SelectedOutfit.SlotPriority = Outfitter_cSlotNames
	Outfitter_ListBox_Reset()
end
