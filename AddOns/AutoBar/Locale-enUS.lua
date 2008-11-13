--
-- AutoBar
-- http://code.google.com/p/autobar/
-- Various Artists
--

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

L:RegisterTranslations("enUS", function() return {
		["AUTOBAR"] = "AutoBar",
		["CONFIG_WINDOW"] = "Configuration Window",
		["SLASHCMD_LONG"] = "/autobar",
		["SLASHCMD_SHORT"] = "/atb",
		["BUTTON"] = "Button",
		["EDITSLOT"] = "Edit Slot",
		["VIEWSLOT"] = "View Slot",
		["LOAD_ERROR"] = "|cff00ff00Error Loading the AutoBarConfig mod. Make sure you download and enable it.|r Error: ",
		["Toggle the config panel"] = true,
		["Empty"] = true,

		--  AutoBarConfig.lua
		["EMPTY"] = "Empty"; --AUTOBAR_CONFIG_EMPTY
		["STYLE"] = "Style",
		["STYLE_TIP"] = "Change the style of the bar.",
		["DEFAULT"] = "Default",
		["ZOOMED"] = "Zoomed",
		["DREAMLAYOUT"] = "Dreamlayout",
		["AUTOBAR_CONFIG_DISABLERIGHTCLICKSELFCAST"] = "Disable Right Click Self Cast";
		["AUTOBAR_CONFIG_REMOVECAT"] = "Delete Current Category";
		["AUTOBAR_CONFIG_ROW"] = "Rows";
		["AUTOBAR_CONFIG_COLUMN"] = "Columns";
		["AUTOBAR_CONFIG_GAPPING"] = "Icon Gapping";
		["AUTOBAR_CONFIG_ALPHA"] = "Icon Alpha";
		["AUTOBAR_CONFIG_BUTTONWIDTH"] = "Button Width";
		["AUTOBAR_CONFIG_BUTTONHEIGHT"] = "Button Height";
		["AUTOBAR_CONFIG_DOCKSHIFTX"] = "Shift Dock Left/Right";
		["AUTOBAR_CONFIG_DOCKSHIFTY"] = "Shift Dock Up/Down";
		["AUTOBAR_CONFIG_WIDTHHEIGHTUNLOCKED"] = "Button Height\nand Width Unlocked";
		["AUTOBAR_CONFIG_HIDEKEYBINDING"] = "Hide Keybinding Text";
		["AUTOBAR_CONFIG_HIDECOUNT"] = "Hide Count Text";
		["AUTOBAR_CONFIG_SHOWEMPTY"] = "Show Empty Buttons";
		["AUTOBAR_CONFIG_SHOWCATEGORYICON"] = "Show Category Icons";
		["AUTOBAR_CONFIG_HIDETOOLTIP"] = "Hide Tooltips";
		["AUTOBAR_CONFIG_POPUPDIRECTION"] = "Popup\nButtons\nDirection";
		["AUTOBAR_CONFIG_POPUPONSHIFT"] = "Popup on Shift Key";
		["AUTOBAR_CONFIG_HIDEDRAGHANDLE"] = "Hide Drag Handle";
		["AUTOBAR_CONFIG_FRAMESTRATA"] = "High Frame Strata";
		["AUTOBAR_CONFIG_CTRLSHOWSDRAGHANDLE"] = "Ctrl Key Shows Drag Handle";
		["AUTOBAR_CONFIG_LOCKACTIONBARS"] = "Lock Action Bars\nwhen locking AutoBar";
		["AUTOBAR_CONFIG_PLAINBUTTONS"] = "Plain Buttons";
		["AUTOBAR_CONFIG_NOPOPUP"] = "No Popup";
		["AUTOBAR_CONFIG_ARRANGEONUSE"] = "Rearrange Order on Use";
		["AUTOBAR_CONFIG_RIGHTCLICKTARGETSPET"] = "Right Click Targets Pet";
		["AUTOBAR_CONFIG_DOCKTONONE"] = "None";
		["AUTOBAR_CONFIG_BT3BAR"] = "BarTender3 Bar";
		["AUTOBAR_CONFIG_DOCKTOMAIN"] = "Main Menu";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAME"] = "Chat Frame";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"] = "Chat Frame Menu";
		["AUTOBAR_CONFIG_DOCKTOACTIONBAR"] = "Action Bar";
		["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"] = "Menu Buttons";
		["AUTOBAR_CONFIG_ALIGN"] = "Align Buttons";
		["AUTOBAR_CONFIG_NOTFOUND"] = "(Not Found: Item ";
		["AUTOBAR_CONFIG_SLOTEDITTEXT"] = " Layer (click to edit)";
		["AUTOBAR_CONFIG_CHARACTER"] = "Character";
		["AUTOBAR_CONFIG_SHARED"] = "Shared";
		["AUTOBAR_CONFIG_CLASS"] = "Class";
		["AUTOBAR_CONFIG_BASIC"] = "Basic";
		["AUTOBAR_CONFIG_USECHARACTER"] = "Use Character Layer";
		["AUTOBAR_CONFIG_USESHARED"] = "Use Shared Layer";
		["AUTOBAR_CONFIG_USECLASS"] = "Use Class Layer";
		["AUTOBAR_CONFIG_USEBASIC"] = "Use Basic Layer";
		["AUTOBAR_CONFIG_HIDECONFIGTOOLTIPS"] = "Hide Config Tooltips";
		["AUTOBAR_CONFIG_OSKIN"] = "Use oSkin";
		["AUTOBAR_CONFIG_PERFORMANCE"] = "Log Performance";
		["AUTOBAR_CONFIG_CHARACTERLAYOUT"] = "Character Layout";
		["AUTOBAR_CONFIG_SHAREDLAYOUT"] = "Shared Layout";
		["AUTOBAR_CONFIG_SHARED1"] = "Shared 1";
		["AUTOBAR_CONFIG_SHARED2"] = "Shared 2";
		["AUTOBAR_CONFIG_SHARED3"] = "Shared 3";
		["AUTOBAR_CONFIG_SHARED4"] = "Shared 4";
		["AUTOBAR_CONFIG_EDITCHARACTER"] = "Edit Character Layer";
		["AUTOBAR_CONFIG_EDITSHARED"] = "Edit Shared Layer";
		["AUTOBAR_CONFIG_EDITCLASS"] = "Edit Class Layer";
		["AUTOBAR_CONFIG_EDITBASIC"] = "Edit Basic Layer";

		-- AutoBarCategory
		["Misc.Engineering.Fireworks"] = "Fireworks",
		["Tradeskill.Tool.Fishing.Lure"] = "Fishing Lures",
		["Tradeskill.Tool.Fishing.Gear"] = "Fishing Gear",
		["Tradeskill.Tool.Fishing.Tool"] = "Fishing Poles",

		["Consumable.Food.Bonus"] = "Food: All Bonus Foods";
		["Consumable.Food.Buff.Strength"] = "Food: Strength Bonus";
		["Consumable.Food.Buff.Agility"] = "Food: Agility Bonus";
		["Consumable.Food.Buff.Attack Power"] = "Food: Attack Power Bonus";
		["Consumable.Food.Buff.Healing"] = "Food: Healing Bonus";
		["Consumable.Food.Buff.Spell Damage"] = "Food: Spell Damage Bonus";
		["Consumable.Food.Buff.Stamina"] = "Food: Stamina Bonus";
		["Consumable.Food.Buff.Intellect"] = "Food: Intelligence Bonus";
		["Consumable.Food.Buff.Spirit"] = "Food: Spirit Bonus";
		["Consumable.Food.Buff.Mana Regen"] = "Food: Mana Regen Bonus";
		["Consumable.Food.Buff.HP Regen"] = "Food: HP Regen Bonus";
		["Consumable.Food.Buff.Other"] = "Food: Other";

		["Consumable.Buff.Health"] = "Buff: Health";
		["Consumable.Buff.Armor"] = "Buff: Armor";
		["Consumable.Buff.Regen Health"] = "Buff: Regen Health";
		["Consumable.Buff.Agility"] = "Buff: Agility";
		["Consumable.Buff.Intellect"] = "Buff: Intellect";
		["Consumable.Buff.Protection"] = "Buff: Protection";
		["Consumable.Buff.Spirit"] = "Buff: Spirit";
		["Consumable.Buff.Stamina"] = "Buff: Stamina";
		["Consumable.Buff.Strength"] = "Buff: Strength";
		["Consumable.Buff.Attack Power"] = "Buff: Attack Power";
		["Consumable.Buff.Attack Speed"] = "Buff: Attack Speed";
		["Consumable.Buff.Dodge"] = "Buff: Dodge";
		["Consumable.Buff.Resistance"] = "Buff: Resistance";

		["Consumable.Buff Group.General.Self"] = "Buff: General";
		["Consumable.Buff Group.General.Target"] = "Buff: General Target";
		["Consumable.Buff Group.Caster.Self"] = "Buff: Caster";
		["Consumable.Buff Group.Caster.Target"] = "Buff: Caster Target";
		["Consumable.Buff Group.Melee.Self"] = "Buff: Melee";
		["Consumable.Buff Group.Melee.Target"] = "Buff: Melee Target";
		["Consumable.Buff.Other.Self"] = "Buff: Other";
		["Consumable.Buff.Other.Target"] = "Buff: Other Target";
		["Consumable.Buff.Chest"] = "Buff: Chest";
		["Consumable.Buff.Shield"] = "Buff: Shield";
		["Consumable.Weapon Buff"] = "Buff: Weapon";

		["Consumable.Quest.Usable"] = "Quest Items";

		["Consumable.Potion.Recovery.Healing.Basic"] = "Heal Potions";
		["Consumable.Potion.Recovery.Healing.Blades Edge"] = "Heal Potions: Blades Edge";
		["Consumable.Potion.Recovery.Healing.Coilfang"] = "Heal Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Healing.PvP"] = "Heal Potions: Battleground";
		["Consumable.Potion.Recovery.Healing.Tempest Keep"] = "Heal Potions: Tempest Keep";
		["Consumable.Potion.Recovery.Mana.Basic"] = "Mana Potions";
		["Consumable.Potion.Recovery.Mana.Blades Edge"] = "Mana Potions: Blades Edge";
		["Consumable.Potion.Recovery.Mana.Coilfang"] = "Mana Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Mana.Pvp"] = "Mana Potions: Battleground";
		["Consumable.Potion.Recovery.Mana.Tempest Keep"] = "Mana Potions: Tempest Keep";

		["Consumable.Weapon Buff.Poison.Crippling"] = "Crippling Poison";
		["Consumable.Weapon Buff.Poison.Deadly"] = "Deadly Poison";
		["Consumable.Weapon Buff.Poison.Instant"] = "Instant Poison";
		["Consumable.Weapon Buff.Poison.Mind Numbing"] = "Mind-Numbing Poison";
		["Consumable.Weapon Buff.Poison.Wound"] = "Wounding Poison";
		["Consumable.Weapon Buff.Oil.Mana"] = "Mana Oil";
		["Consumable.Weapon Buff.Oil.Wizard"] = "Wizard Oil";
		["Consumable.Weapon Buff.Stone.Sharpening Stone"] = "Sharpening Stone";
		["Consumable.Weapon Buff.Stone.Weight Stone"] = "Weight Stone";

		["Consumable.Bandage.Basic"] = "Bandages";
		["Consumable.Bandage.Battleground.Alterac Valley"] = "Alterac Bandages";
		["Consumable.Bandage.Battleground.Warsong Gulch"] = "Warsong Bandages";
		["Consumable.Bandage.Battleground.Arathi Basin"] = "Arathi Bandages";

		["Consumable.Food.Edible.Basic.Non-Conjured"] = "Food: No Bonus";
		["Consumable.Food.Percent.Basic"] = "Food: % health gain";
		["Consumable.Food.Percent.Bonus"] = "Food: % HP Regen (well fed buff)";
		["Consumable.Food.Combo Percent"] = "Food: % health & mana gain";
		["Consumable.Food.Combo Health"] = "Food & Water Combo";
		["Consumable.Food.Edible.Bread.Conjured"] = "Food: Mage Conjured";
		["Consumable.Food.Conjure"] = "Conjure Food";
		["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = "Food: Arathi Basin";
		["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = "Food: Warsong Gulch";

		["Consumable.Food.Pet.Bread"] = "Food: Pet Bread";
		["Consumable.Food.Pet.Cheese"] = "Food: Pet Cheese";
		["Consumable.Food.Pet.Fish"] = "Food: Pet Fish";
		["Consumable.Food.Pet.Fruit"] = "Food: Pet Fruit";
		["Consumable.Food.Pet.Fungus"] = "Food: Pet Fungus";
		["Consumable.Food.Pet.Meat"] = "Food: Pet Meat";

		["AUTOBAR_CLASS_CUSTOM"] = "Custom";
		["Misc.Minipet.Normal"] = "Pet";
		["Misc.Minipet.Snowball"] = "Holiday Pet";
		["AUTOBAR_CLASS_CLEAR"] = "Clear this Slot";
		["AUTOBAR_CLASS_UNGORORESTORE"] = "Un'Goro: Crystal Restore";

		["Consumable.Anti-Venom"] = "Anti-Venom";

		["Consumable.Warlock.Healthstone"] = "Healthstones";
		["Consumable.Warlock.Create Healthstone"] = "Create Healthstone";
		["Consumable.Mage.Mana Stone"] = "Manastones";
		["Consumable.Mage.Conjure Mana Stone"] = "Conjure Manastones";
		["Consumable.Potion.Recovery.Dreamless Sleep"] = "Dreamless Sleep";
		["Consumable.Potion.Recovery.Rejuvenation"] = "Rejuvenation Potions";
		["Consumable.Jeweler.Statue"] = "Stone Statues";

		["Misc.Battle Standard.Battleground"] = "Battle Standard";
		["Misc.Battle Standard.Alterac Valley"] = "Battle Standard AV";
		["Consumable.Recovery.Rune"] = "Demonic and Dark Runes";
		["AUTOBAR_CLASS_ARCANE_PROTECTION"] = "Arcane Protection";
		["AUTOBAR_CLASS_FIRE_PROTECTION"] = "Fire Protection";
		["AUTOBAR_CLASS_FROST_PROTECTION"] = "Frost Protection";
		["AUTOBAR_CLASS_NATURE_PROTECTION"] = "Nature Protection";
		["AUTOBAR_CLASS_SHADOW_PROTECTION"] = "Shadow Protection";
		["AUTOBAR_CLASS_SPELL_REFLECTION"] = "Spell Protection";
		["AUTOBAR_CLASS_HOLY_PROTECTION"] = "Holy Protection";
		["AUTOBAR_CLASS_INVULNERABILITY_POTIONS"] = "Invulnerability Potions";
		["Consumable.Buff.Free Action"] = "Buff: Free Action";

		["AUTOBAR_CLASS_PORTALS"] = "Portals and Teleports";
		["Misc.Hearth"] = "Hearthstone";
		["Misc.Booze"] = "Booze";
		["Consumable.Water.Basic"] = "Water";
		["Consumable.Water.Percentage"] = "Water: % mana gain";
		["AUTOBAR_CLASS_WATER_CONJURED"] = "Water: Mage Conjured";
		["AUTOBAR_CLASS_WATER_CONJURE"] = "Conjure Water";
		["Consumable.Water.Buff.Spirit"] = "Water: Spirit Bonus";
		["Consumable.Buff.Rage.Self"] = "Rage Potions";
		["Consumable.Buff.Energy.Self"] = "Energy Potions";
		["Consumable.Buff.Speed"] = "Buff: Swiftness";
		["AUTOBAR_CLASS_SOULSHARDS"] = "Soul Shards";
		["Reagent.Ammo.Arrow"] = "Arrows";
		["Reagent.Ammo.Bullet"] = "Bullets";
		["Reagent.Ammo.Thrown"] = "Thrown Weapons";
		["Misc.Engineering.Explosives"] = "Engineering Explosives";
		["Misc.Mount.Normal"] = "Mounts";
		["Misc.Mount.Summoned"] = "Mounts: Summoned";
		["Misc.Mount.Ahn'Qiraj"] = "Mounts: Qiraji";
		["Misc.Mount.Flying"] = "Mounts: Flying";

	}
end);


if (true) then

AUTOBAR_CHAT_MESSAGE1 = "Config for this character is old version. Clearing. No attempt to upgrade config is being done.";
AUTOBAR_CHAT_MESSAGE2 = "Updating multi item button #%d item #%d to use itemid instead of item name.";
AUTOBAR_CHAT_MESSAGE3 = "Updating single item button #%d to use itemid instead of item name.";

--  AutoBar_Config.xml
AUTOBAR_CONFIG_VIEWTEXT = "To edit a slot select it from the Slot edit section\nat the bottom of the Slots tab.";
AUTOBAR_CONFIG_SLOTVIEWTEXT = "Combined Layer View (not editable)";
AUTOBAR_CONFIG_RESET = "Reset";
AUTOBAR_CONFIG_REVERT = "Revert";
AUTOBAR_CONFIG_DONE = "Done";
AUTOBAR_CONFIG_DETAIL_CATEGORIES = "(Shift Click to explore Category)";
AUTOBAR_CONFIG_DRAGHANDLE = "Left Mouse Drag to move AutoBar\nLeft Click to Lock / Unlock\nRight Click for options";
AUTOBAR_CONFIG_EMPTYSLOT = "Empty Slot";
AUTOBAR_CONFIG_CLEARSLOT = "Clear Slot";
AUTOBAR_CONFIG_SETSHARED = "Shared Profile:";
AUTOBAR_CONFIG_SETSHAREDTIP = "Select the shared profile for this Character to use.\nChanges to a shared profile affect all Characters using it";

AUTOBAR_CONFIG_TAB_SLOTS = "Slots";
AUTOBAR_CONFIG_TAB_BAR = "Bar";
AUTOBAR_CONFIG_TAB_BUTTONS = "Buttons";
AUTOBAR_CONFIG_TAB_POPUP = "Popup";
AUTOBAR_CONFIG_TAB_PROFILE = "Profile";
AUTOBAR_CONFIG_TAB_KEYS = "Keys";

AUTOBAR_TOOLTIP1 = " (Count: ";
AUTOBAR_TOOLTIP2 = " [Custom Item]";
AUTOBAR_TOOLTIP4 = " [Battlegrounds only]";
AUTOBAR_TOOLTIP5 = " [Non Combat Only]";
AUTOBAR_TOOLTIP6 = " [Limited Usage]";
AUTOBAR_TOOLTIP7 = " [Cooldown]";
AUTOBAR_TOOLTIP8 = "\n(Left Click to apply to Main Hand weapon\nRight Click to apply to OffHand weapon)";

AUTOBAR_CONFIG_DOCKTO = "Docked to:";
AUTOBAR_CONFIG_USECHARACTERTIP = "Character Layer items are specific to this Character.";
AUTOBAR_CONFIG_USESHAREDTIP = "Shared Layer items are shared by other Characters that use the same Shared Layer.\nThe specific layer can be chosen on the Profile Tab.";
AUTOBAR_CONFIG_USECLASSTIP = "Class Layer items are shared by all Characters of the same class that use the Class Layer.";
AUTOBAR_CONFIG_USEBASICTIP = "Basic Layer items are shared by all Characters using the Basic Layer.";
AUTOBAR_CONFIG_CHARACTERLAYOUTTIP = "Changes to visual layout only affect this Character.";
AUTOBAR_CONFIG_SHAREDLAYOUTTIP = "Changes to visual layout affect all Characters using the same shared profile.";
AUTOBAR_CONFIG_TIPOVERRIDE = "Items in a slot on this layer override items in that slot on lower layers.\n";
AUTOBAR_CONFIG_TIPOVERRIDDEN = "Items in a slot on this layer are overidden by items on higher layers.\n";
AUTOBAR_CONFIG_TIPAFFECTSCHARACTER = "Changes affect only this Character.";
AUTOBAR_CONFIG_TIPAFFECTSALL = "Changes affect all Characters.";
AUTOBAR_CONFIG_SETUPSINGLE = "Single (Classic) Setup";
AUTOBAR_CONFIG_SETUPSHARED = "Shared Setup";
AUTOBAR_CONFIG_SETUPSTANDARD = "Standard Setup";
AUTOBAR_CONFIG_SETUPBLANKSLATE = "Blank Slate";
AUTOBAR_CONFIG_SETUPSINGLETIP = "Click for Single Character settings similar to the classic AutoBar.";
AUTOBAR_CONFIG_SETUPSHAREDTIP = "Click for shared settings.\nEnables the character specific as well as shared layers.";
AUTOBAR_CONFIG_SETUPSTANDARDTIP = "Enable editing and use of all layers.";
AUTOBAR_CONFIG_SETUPBLANKSLATETIP = "Clear out all character and shared slots.";
AUTOBAR_CONFIG_RESETSINGLETIP = "Click to reset to the Single Character defaults.";
AUTOBAR_CONFIG_RESETSHAREDTIP = "Click to reset to the Shared Character defaults.\nClass specific slots are copied to the Character layer.\nDefault slots are copied to the Shared layer.";
AUTOBAR_CONFIG_RESETSTANDARDTIP = "Click to reset to the standard defaults.\nClass specific slots are in the Class layer.\nDefault slots are in the Basic layer.\nShared and Character layers are cleared.";

--  AutoBarConfig.lua
AUTOBAR_TOOLTIP9 = "Multi Category Button\n";
AUTOBAR_TOOLTIP10 = " (Custom Item by ID)";
AUTOBAR_TOOLTIP11 = "\n(Item ID not recognized)";
AUTOBAR_TOOLTIP12 = " (Custom Item by Name)";
AUTOBAR_TOOLTIP13 = "Single Category Button\n\n";
AUTOBAR_TOOLTIP14 = "\nNot directly usable.";
AUTOBAR_TOOLTIP15 = "\nWeapon Target\n(Left click main weapon\nRight click offhand weapon.)";
AUTOBAR_TOOLTIP16 = "\nTargetted.";
AUTOBAR_TOOLTIP17 = "\nNon combat only.";
AUTOBAR_TOOLTIP18 = "\nCombat only.";
AUTOBAR_TOOLTIP19 = "\nLocation: ";
AUTOBAR_TOOLTIP20 = "\nLimited Usage: "
AUTOBAR_TOOLTIP21 = "Require HP restore";
AUTOBAR_TOOLTIP22 = "Require Mana restore";
AUTOBAR_TOOLTIP23 = "Single Item Button\n\n";

--  AutoBarItemList.lua
--AUTOBAR_ALTERACVALLEY = "Alterac Valley";
--AUTOBAR_WARSONGGULCH = "Warsong Gulch";
--AUTOBAR_ARATHIBASIN = "Arathi Basin";
--AUTOBAR_AHN_QIRAJ = "Ahn'Qiraj";

end