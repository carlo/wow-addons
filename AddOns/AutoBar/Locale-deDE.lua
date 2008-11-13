--
-- AutoBar
-- http://code.google.com/p/autobar/
-- Courtesy of Teodred
--

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

L:RegisterTranslations("deDE", function() return {
	    ["AUTOBAR"] = "AutoBar",
	    ["CONFIG_WINDOW"] = "Einstellungen",
	    ["SLASHCMD_LONG"] = "/autobar",
	    ["SLASHCMD_SHORT"] = "/atb",
	    ["BUTTON"] = "Feld",
	    ["EDITSLOT"] = "Bearbeiten",
	    ["VIEWSLOT"] = "Blick",
		["LOAD_ERROR"] = "|cff00ff00Error Loading AutoBarConfig. Make sure you have it and it is enabled.|r Error: ",
		["Toggle the config panel"] = "Toggle the config panel",

		--  AutoBar_Config.lua
		["EMPTY"] = "Leer";
		["STYLE"] = "Design",
		["STYLE_TIP"] = "Das Design der Leiste ändern.",
		["DEFAULT"] = "Vorgabe",
		["ZOOMED"] = "Gezoomt",
		["DREAMLAYOUT"] = "Dreamlayout",
		["AUTOBAR_CONFIG_DISABLERIGHTCLICKSELFCAST"] = "Nein Right Click Selbstanwendung";
		["AUTOBAR_CONFIG_REMOVECAT"] = "Aktuelle Kategorie l\195\182schen";
		["AUTOBAR_CONFIG_ROW"] = "Zeilen";
		["AUTOBAR_CONFIG_COLUMN"] = "Spalten";
		["AUTOBAR_CONFIG_GAPPING"] = "Symbolabstand";
		["AUTOBAR_CONFIG_ALPHA"] = "Symboltranparenz";
		["AUTOBAR_CONFIG_BUTTONWIDTH"] = "Feldbreite";
		["AUTOBAR_CONFIG_BUTTONHEIGHT"] = "Feldh\195\182he";
		["AUTOBAR_CONFIG_DOCKSHIFTX"] = "Verankern: rechts/links";
		["AUTOBAR_CONFIG_DOCKSHIFTY"] = "Verankern: oben/unten";
		["AUTOBAR_CONFIG_WIDTHHEIGHTUNLOCKED"] = "Feldbreite/Feldh\195\182he gleichsetzen";
		["AUTOBAR_CONFIG_HIDEKEYBINDING"] = "Tastenbelegung verbergen";
		["AUTOBAR_CONFIG_HIDECOUNT"] = "Anzahl verbergen";
		["AUTOBAR_CONFIG_SHOWEMPTY"] = "Leere Felder anzeigen";
		["AUTOBAR_CONFIG_SHOWCATEGORYICON"] = "Show Category Icons";
		["AUTOBAR_CONFIG_HIDETOOLTIP"] = "InfoFenster verbergen";
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
	 	["AUTOBAR_CONFIG_DOCKTOMAIN"] = "Verankern am Men\195\188";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAME"] = "Chat Frame";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"] = "Chat Frame Menu";
		["AUTOBAR_CONFIG_DOCKTOACTIONBAR"] = "Action Bar";
		["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"] = "Menu Buttons";
		["AUTOBAR_CONFIG_ALIGN"] = "Align Buttons";
	 	["AUTOBAR_CONFIG_NOTFOUND"] = "(Nicht gefunden: Gegenstand ";
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

		["Consumable.Food.Bonus"] = "Nahrung: Alle Bonus";
		["Consumable.Food.Buff.Strength"] = "Nahrung: St\195\164rke Bonus";
		["Consumable.Food.Buff.Agility"] = "Nahrung: Beweglichkeit Bonus";
		["Consumable.Food.Buff.Attack Power"] = "Food: Attack Power Bonus";
		["Consumable.Food.Buff.Healing"] = "Food: Healing Bonus";
		["Consumable.Food.Buff.Spell Damage"] = "Food: Spell Damage Bonus";
		["Consumable.Food.Buff.Stamina"] = "Nahrung: Ausdauer Bonus";
		["Consumable.Food.Buff.Intellect"] = "Nahrung: Intelligenz Bonus";
		["Consumable.Food.Buff.Spirit"] = "Nahrung: Spirit Bonus";
		["Consumable.Food.Buff.Mana Regen"] = "Nahrung: Mana Wiederherstellungsbonus";
		["Consumable.Food.Buff.HP Regen"] = "Nahrung: Gesundheits-Wiederherstellungsbonus";
		["Consumable.Food.Buff.Other"] = "Nahrung: Other";

		["Consumable.Buff.Health"] = "Buff Health";
		["Consumable.Buff.Armor"] = "Buff Armor";
		["Consumable.Buff.Regen Health"] = "Buff Regen Health";
		["Consumable.Buff.Agility"] = "Buff of Agility";
		["Consumable.Buff.Intellect"] = "Buff of Intellect";
		["Consumable.Buff.Protection"] = "Buff of Protection";
		["Consumable.Buff.Spirit"] = "Buff of Spirit";
		["Consumable.Buff.Stamina"] = "Buff of Stamina";
		["Consumable.Buff.Strength"] = "Buff of Strength";
		["Consumable.Buff.Attack Power"] = "Buff Attack Power";
		["Consumable.Buff.Attack Speed"] = "Buff Attack Speed";
		["Consumable.Buff.Dodge"] = "Buff Dodge";
		["Consumable.Buff.Resistance"] = "Buff Resistance";

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

		["Consumable.Potion.Recovery.Healing.Basic"] = "Heiltr\195\164nke";
		["Consumable.Potion.Recovery.Healing.Blades Edge"] = "Heal Potions: Blades Edge";
		["Consumable.Potion.Recovery.Healing.Coilfang"] = "Heal Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Healing.PvP"] = "Schlachtfeld-Heiltr\195\164nke";
		["Consumable.Potion.Recovery.Healing.Tempest Keep"] = "Heal Potions: Tempest Keep";
		["Consumable.Potion.Recovery.Mana.Basic"] = "Mana Tr\195\164nke";
		["Consumable.Potion.Recovery.Mana.Blades Edge"] = "Mana Potions: Blades Edge";
		["Consumable.Potion.Recovery.Mana.Coilfang"] = "Mana Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Mana.Pvp"] = "Schlachtfeld Mana Tr\195\164nke";
		["Consumable.Potion.Recovery.Mana.Tempest Keep"] = "Mana Potions: Tempest Keep";

		["Consumable.Weapon Buff.Poison.Crippling"] = "Verkr\195\188ppelndes Gift";
		["Consumable.Weapon Buff.Poison.Deadly"] = "T\195\182dliches Gift";
		["Consumable.Weapon Buff.Poison.Instant"] = "Sofortwirkendes Gift";
		["Consumable.Weapon Buff.Poison.Mind Numbing"] = "Gedankenbenebelndes Gift";
		["Consumable.Weapon Buff.Poison.Wound"] = "Verwundendes Gift";
		["Consumable.Weapon Buff.Oil.Mana"] = "Zauber\195\182le: Mana Regeneration";
		["Consumable.Weapon Buff.Oil.Wizard"] = "Zauber\195\182le: Schaden/Heilung";
		["Consumable.Weapon Buff.Stone.Sharpening Stone"] = "Hergestellte Wetzsteine";
		["Consumable.Weapon Buff.Stone.Weight Stone"] = "Hergestellte Gewichtssteine";

		["Consumable.Bandage.Basic"] = "Verb\195\164nde";
		["Consumable.Bandage.Battleground.Alterac Valley"] = "Alterac Verb\195\164nde";
		["Consumable.Bandage.Battleground.Warsong Gulch"] = "Warsong Verb\195\164nde";
		["Consumable.Bandage.Battleground.Arathi Basin"] = "Arathi Verb\195\164nde";

		["Consumable.Food.Edible.Basic.Non-Conjured"] = "Nahrung: kein Bonus";
		["Consumable.Food.Percent.Basic"] = "Food: % health gain";
		["Consumable.Food.Percent.Bonus"] = "Food: % HP Regen (well fed buff)";
		["Consumable.Food.Combo Percent"] = "Food: % health & mana gain";
		["Consumable.Food.Combo Health"] = "Wasser & Nahrungskombination";
		["Consumable.Food.Edible.Bread.Conjured"] = "Nahrung: herbeigezaubert";
		["Consumable.Food.Conjure"] = "Conjure Food";
		["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = "Nahrung: Arathibecken";
		["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = "Nahrung: Warsongschlucht";

		["Consumable.Food.Pet.Bread"] = "Nahrung: Begleiter Brot";
		["Consumable.Food.Pet.Cheese"] = "Nahrung: Begleiter K\195\164se";
		["Consumable.Food.Pet.Fish"] = "Nahrung: Begleiter Fisch";
		["Consumable.Food.Pet.Fruit"] = "Nahrung: Begleiter Fr\195\188chte";
		["Consumable.Food.Pet.Fungus"] = "Nahrung: Begleiter Pilze";
		["Consumable.Food.Pet.Meat"] = "Nahrung: Begleiter Fleisch";

		["AUTOBAR_CLASS_CUSTOM"] = "Benutzerdefiniert";
		["Misc.Minipet.Normal"] = "Pet";
		["Misc.Minipet.Snowball"] = "Holiday Pet";
		["AUTOBAR_CLASS_CLEAR"] = "Clear this Slot";
		["AUTOBAR_CLASS_UNGORORESTORE"] = "Un'Goro: Kristallflicker";

		["Consumable.Anti-Venom"] = "Gegengift";

		["Consumable.Warlock.Healthstone"] = "Gesundheitssteine";
		["Consumable.Warlock.Create Healthstone"] = "Create Healthstone";
		["Consumable.Mage.Mana Stone"] = "Mana Edelsteine";
		["Consumable.Mage.Conjure Mana Stone"] = "Conjure Manastones";
		["Consumable.Potion.Recovery.Dreamless Sleep"] = "Traumloser Schlaf";
		["Consumable.Potion.Recovery.Rejuvenation"] = "Verj\195\188ngungstr\195\164nke";
		["Consumable.Jeweler.Statue"] = "Stone Statues";

		["Misc.Battle Standard.Battleground"] = "Schlachtstandarte";
		["Misc.Battle Standard.Alterac Valley"] = "Schlachtstandarte Alteractal";
		["Consumable.Recovery.Rune"] = "D\195\164monische und Dunkle Runen";
		["AUTOBAR_CLASS_ARCANE_PROTECTION"] = "Arkanschutz";
		["AUTOBAR_CLASS_FIRE_PROTECTION"] = "Feuerschutz";
		["AUTOBAR_CLASS_FROST_PROTECTION"] = "Frostschutz";
		["AUTOBAR_CLASS_NATURE_PROTECTION"] = "Naturschutz";
		["AUTOBAR_CLASS_SHADOW_PROTECTION"] = "Schattenschutz";
		["AUTOBAR_CLASS_SPELL_REFLECTION"] = "Zauberschutz";
		["AUTOBAR_CLASS_HOLY_PROTECTION"] = "Heiligschutz";
		["AUTOBAR_CLASS_INVULNERABILITY_POTIONS"] = "Unverwundbarkeitstr\195\164nke";
		["Consumable.Buff.Free Action"] = "Bewegungsbefreiende Tr\195\164nke";

		["AUTOBAR_CLASS_PORTALS"] = "Portals and Teleports";
		["Misc.Hearth"] = "Ruhestein";
		["Misc.Booze"] = "Booze";
		["Consumable.Water.Basic"] = "Wasser";
		["Consumable.Water.Percentage"] = "Water: % mana gain";
		["AUTOBAR_CLASS_WATER_CONJURED"] = "Wasser: herbeigezaubert";
		["AUTOBAR_CLASS_WATER_CONJURE"] = "Conjure Water";
		["Consumable.Water.Buff.Spirit"] = "Wasser: Willenskraftbonus";
		["Consumable.Buff.Rage.Self"] = "Wut Tr\195\164nke";
		["Consumable.Buff.Energy.Self"] = "Energie Tr\195\164nke";
		["Consumable.Buff.Speed"] = "Beweglichkeits Tr\195\164nke";
		["AUTOBAR_CLASS_SOULSHARDS"] = "seelensteine";
		["Reagent.Ammo.Arrow"] = "Pfeile";
		["Reagent.Ammo.Bullet"] = "Patronen";
		["Reagent.Ammo.Thrown"] = "Wurfwaffen";
		["Misc.Engineering.Explosives"] = "Ingenieurssprengstoffe";
		["Misc.Mount.Normal"] = "Reittier";
		["Misc.Mount.Summoned"] = "Reittier： Summoned";
		["Misc.Mount.Ahn'Qiraj"] = "Reittier: Qiraji";
		["Misc.Mount.Flying"] = "Reittier: Flying";

	}
end);


if (GetLocale() == "deDE") then

AUTOBAR_CHAT_MESSAGE1 = "Veraltete Einstellungen wurden gefunden und gel\195\182scht. Standardeinstellungen werden wieder hergestellt.";
AUTOBAR_CHAT_MESSAGE2 = "Benutze im Mehrfachfeld #%d f\195\188r den Gegenstand #%d die zugeh\195\182rige ItemID anstelle den Namen.";
AUTOBAR_CHAT_MESSAGE3 = "Benutze f\195\188r den Gegenstand #%d die zugeh\195\182rige ItemID anstelle den Namen.";

--  AutoBar_Config.xml
AUTOBAR_CONFIG_VIEWTEXT = "To edit a slot select it from the Slot edit section\nat the bottom of the Slots tab.";
AUTOBAR_CONFIG_SLOTVIEWTEXT = "Combined Layer View (not editable)";
AUTOBAR_CONFIG_RESET = "Zur\195\188cksetzen";
AUTOBAR_CONFIG_REVERT = "Revert";
AUTOBAR_CONFIG_DONE = "Fertig";
AUTOBAR_CONFIG_DETAIL_CATEGORIES = "(Gro\195\159schreiben+Links-Klick um Kategorien zu durchsuchen)";
AUTOBAR_CONFIG_DRAGHANDLE = "Left Mouse Drag to move AutoBar\nLeft Click to Lock / Unlock\nRight Click for options";
AUTOBAR_CONFIG_EMPTYSLOT = "Empty Slot";
AUTOBAR_CONFIG_CLEARSLOT = "Clear Slot";
AUTOBAR_CONFIG_SETSHARED = "Shared Profile:";
AUTOBAR_CONFIG_SETSHAREDTIP = "Select the shared profile for this Character to use.\nChanges to a shared profile affect all Characters using it";

AUTOBAR_CONFIG_TAB_SLOTS = "Schlitze";
AUTOBAR_CONFIG_TAB_BAR = "Balken";
AUTOBAR_CONFIG_TAB_BUTTONS = "Felder";
AUTOBAR_CONFIG_TAB_POPUP = "Popup";
AUTOBAR_CONFIG_TAB_PROFILE = "Profil";
AUTOBAR_CONFIG_TAB_KEYS = "Keys";

AUTOBAR_TOOLTIP1 = " (Anzahl: ";
AUTOBAR_TOOLTIP2 = " [Benutzerdefiniertes Objekt]";
AUTOBAR_TOOLTIP4 = " [Nur in Schlachtfeldern]";
AUTOBAR_TOOLTIP5 = " [Nur au\195\159erhalb Kampf]";
AUTOBAR_TOOLTIP6 = " [Begrenzte Verwendung]";
AUTOBAR_TOOLTIP7 = " [Abklingzeit]";
AUTOBAR_TOOLTIP8 = "\n(Links-Klick f\195\188r Waffenhand.\nRechts-Klick f\195\188r Schildhand)";

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
AUTOBAR_CONFIG_SETUPSINGLE = "Single Setup";
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

--  AutoBar_Config.lua
AUTOBAR_TOOLTIP9 = "Mehrfachfeld\n";
AUTOBAR_TOOLTIP10 = " (Benutzerdefinifierter Gegenstand aus ItemID)";
AUTOBAR_TOOLTIP11 = "\n(ItemID nicht erkannt)";
AUTOBAR_TOOLTIP12 = " (Benutzerdefinifierter Gegenstand aus Name)";
AUTOBAR_TOOLTIP13 = "Einzelfeld\n\n";
AUTOBAR_TOOLTIP14 = "\nNicht direkt verwendbar.";
AUTOBAR_TOOLTIP15 = "\nWaffenziel\n(Links-Klick f\195\188r Waffenhand.\nRechts-Klick f\195\188r Schildhand)";
AUTOBAR_TOOLTIP16 = "\nZiel ausgew\195\164hlt.";
AUTOBAR_TOOLTIP17 = "\nNur au\195\159erhalb Kampf.";
AUTOBAR_TOOLTIP18 = "\nNur in Kampf.";
AUTOBAR_TOOLTIP19 = "\nPosition: ";
AUTOBAR_TOOLTIP20 = "\nBegrenzte Verwendung: "
AUTOBAR_TOOLTIP21 = "Einsatz bei fehlender Gesundheit";
AUTOBAR_TOOLTIP22 = "Einsatz bei fehlendem Mana";
AUTOBAR_TOOLTIP23 = "Einzelfeld\n\n";

--  AutoBar_ItemList.lua
--AUTOBAR_ALTERACVALLEY = "Alteractal";
--AUTOBAR_WARSONGGULCH = "Warsongschlucht";
--AUTOBAR_ARATHIBASIN = "Arathibecken";
--AUTOBAR_AHN_QIRAJ = "Ahn'Qiraj";

end