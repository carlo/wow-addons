--
-- AutoBar
-- http://code.google.com/p/autobar/
-- Courtesy of Cinedelle
--

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

L:RegisterTranslations("frFR", function() return {
	    ["AUTOBAR"] = "AutoBar",
	    ["CONFIG_WINDOW"] = "Fen\195\170tre de configuration",
	    ["SLASHCMD_LONG"] = "/autobar",
	    ["SLASHCMD_SHORT"] = "/atb",
	    ["BUTTON"] = "Bouton",
	    ["EDITSLOT"] = "Editer l'emplacement",
	    ["VIEWSLOT"] = "Voir l'emplacement",
		["LOAD_ERROR"] = "|cff00ff00Erreur de chargement d'AutoBarConfig. Assurez-vous qu'il soit pr\195\169sent et activ\195\169.|r Error: ",
		["Toggle the config panel"] = "Toggle the config panel",

		--  AutoBarConfig.lua
		["EMPTY"] = "Vide"; --AUTOBAR_CONFIG_EMPTY
		["STYLE"] = "Style",
		["STYLE_TIP"] = "Change le style de la barre",
		["DEFAULT"] = "D\195\169faut",
		["ZOOMED"] = "Zoom\195\169",
		["DREAMLAYOUT"] = "Dreamlayout",
		["AUTOBAR_CONFIG_DISABLERIGHTCLICKSELFCAST"] = "Disable Right Click Self Cast";
		["AUTOBAR_CONFIG_REMOVECAT"] = "Effacer la cat\195\169gorie actuelle";
		["AUTOBAR_CONFIG_ROW"] = "Lignes";
		["AUTOBAR_CONFIG_COLUMN"] = "Colonnes";
		["AUTOBAR_CONFIG_GAPPING"] = "Espacement des icones";
		["AUTOBAR_CONFIG_ALPHA"] = "Transparence dee icones";
		["AUTOBAR_CONFIG_BUTTONWIDTH"] = "Largeur du bouton";
		["AUTOBAR_CONFIG_BUTTONHEIGHT"] = "Hauteur du bouton";
		["AUTOBAR_CONFIG_DOCKSHIFTX"] = "D\195\169calage gauche/droite";
		["AUTOBAR_CONFIG_DOCKSHIFTY"] = "D\195\169calage haut/bas";
		["AUTOBAR_CONFIG_WIDTHHEIGHTUNLOCKED"] = "Hauteur et Largeur \ndes boutons non proportionn\195\169";
		["AUTOBAR_CONFIG_HIDEKEYBINDING"] = "Cacher les raccourcis";
		["AUTOBAR_CONFIG_HIDECOUNT"] = "Cacher la quantit\195\169";
		["AUTOBAR_CONFIG_SHOWEMPTY"] = "Afficher les boutons vide";
		["AUTOBAR_CONFIG_SHOWCATEGORYICON"] = "Afficher les icones de cat\195\169gorie";
		["AUTOBAR_CONFIG_HIDETOOLTIP"] = "Cacher les bulles d'aides";
		["AUTOBAR_CONFIG_POPUPDIRECTION"] = "Orientation du \nd\195\169ploiement \ndes boutons";
		["AUTOBAR_CONFIG_POPUPONSHIFT"] = "D\195\169ploiement uniquement \navec la touche Shift(MAJ)";
		["AUTOBAR_CONFIG_HIDEDRAGHANDLE"] = "cacher la poign\195\169 de d\195\169placement";
		["AUTOBAR_CONFIG_FRAMESTRATA"] = "High Frame Strata";
		["AUTOBAR_CONFIG_PLAINBUTTONS"] = "Sans bordure";
		["AUTOBAR_CONFIG_NOPOPUP"] = "Pas de d\195\169ploiement";
		["AUTOBAR_CONFIG_ARRANGEONUSE"] = "R\195\169organise l'ordre \nlors d'une utilisation";
		["AUTOBAR_CONFIG_RIGHTCLICKTARGETSPET"] = "Clique droit cible le familier";
		["AUTOBAR_CONFIG_DOCKTONONE"] = "Aucun";
		["AUTOBAR_CONFIG_BT3BAR"] = "BarTender3 Bar";
		["AUTOBAR_CONFIG_DOCKTOMAIN"] = "Menu principale";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAME"] = "Fen\195\170tre de chat";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"] = "Menu des fen\195\170tre de chat";
		["AUTOBAR_CONFIG_DOCKTOACTIONBAR"] = "Barre d'action";
		["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"] = "Menu des boutons";
		["AUTOBAR_CONFIG_ALIGN"] = "Alignement des \nboutons";
		["AUTOBAR_CONFIG_NOTFOUND"] = "(Objet : non trouv\195\169 ";
		["AUTOBAR_CONFIG_SLOTEDITTEXT"] = " Set (cliquer pour \195\169diter)";
		["AUTOBAR_CONFIG_CHARACTER"] = "Personnage :";
		["AUTOBAR_CONFIG_SHARED"] = "Partag\195\169";
		["AUTOBAR_CONFIG_CLASS"] = "Classe";
		["AUTOBAR_CONFIG_BASIC"] = "Base";
		["AUTOBAR_CONFIG_USECHARACTER"] = "Utiliser le set personnage";
		["AUTOBAR_CONFIG_USESHARED"] = "Utiliser le set partag\195\169e";
		["AUTOBAR_CONFIG_USECLASS"] = "Utiliser le set de classe";
		["AUTOBAR_CONFIG_USEBASIC"] = "Utiliser le set de base";
		["AUTOBAR_CONFIG_HIDECONFIGTOOLTIPS"] = "Cacher les bulles d'aide \nde configuration";
		["AUTOBAR_CONFIG_OSKIN"] = "Utiliser oSkin";
		["AUTOBAR_CONFIG_PERFORMANCE"] = "Log Performance";
		["AUTOBAR_CONFIG_CHARACTERLAYOUT"] = "Organisation pour le personnage";
		["AUTOBAR_CONFIG_SHAREDLAYOUT"] = "Organisation partag\195\169e";
		["AUTOBAR_CONFIG_SHARED1"] = "Partage 1";
		["AUTOBAR_CONFIG_SHARED2"] = "Partage 2";
		["AUTOBAR_CONFIG_SHARED3"] = "Partage 3";
		["AUTOBAR_CONFIG_SHARED4"] = "Partage 4";
		["AUTOBAR_CONFIG_EDITCHARACTER"] = "Editer le set personnage";
		["AUTOBAR_CONFIG_EDITSHARED"] = "Editer le set partag\195\169e";
		["AUTOBAR_CONFIG_EDITCLASS"] = "Editer le set de classe";
		["AUTOBAR_CONFIG_EDITBASIC"] = "Editer le set de base";

		-- AutoBarCategory
		["Misc.Engineering.Fireworks"] = "Misc.Engineering.Fireworks",
		["Tradeskill.Tool.Fishing.Lure"] = "Leurres de p\195\170che",
		["Tradeskill.Tool.Fishing.Gear"] = "Equipement de p\195\170che",
		["Tradeskill.Tool.Fishing.Tool"] = "Cannes \195\160 p\195\170che",

		["Consumable.Food.Bonus"] = "Nourriture: All Bonus Foods";
		["Consumable.Food.Buff.Strength"] = "Nourriture : Bonus de force";
		["Consumable.Food.Buff.Agility"] = "Nourriture : Bonus d'agilit\195\169";
		["Consumable.Food.Buff.Attack Power"] = "Food: Attack Power Bonus";
		["Consumable.Food.Buff.Healing"] = "Food: Healing Bonus";
		["Consumable.Food.Buff.Spell Damage"] = "Food: Spell Damage Bonus";
		["Consumable.Food.Buff.Stamina"] = "Nourriture : Bonus d'endurance";
		["Consumable.Food.Buff.Intellect"] = "Nourriture : Bonus d'intelligence";
		["Consumable.Food.Buff.Spirit"] = "Food: Spirit Bonus";
		["Consumable.Food.Buff.Mana Regen"] = "Nourriture : Bonus de r\195\169g\195\169n\195\169ration de mana";
		["Consumable.Food.Buff.HP Regen"] = "Nourriture : Bonus de r\195\169g\195\169n\195\169ration de PV";
		["Consumable.Food.Buff.Other"] = "Food: Other";

		["Consumable.Buff.Health"] = "Buff Health";
		["Consumable.Buff.Armor"] = "Buff Armor";
		["Consumable.Buff.Regen Health"] = "Buff Regen Health";
		["Consumable.Buff.Agility"] = "Buff of Agility";
		["Consumable.Buff.Intellect"] = "Buff of Intellect";
		["Consumable.Buff.Protection"] = "Buff of Protection";
		["Consumable.Buff.Spirit"] = "Buff of Spirit";
		["Consumable.Buff.Stamina"] = "Buff of Stamina";
		["Consumable.Buff.Strength"] = "Buff of Strength";
		["Consumable.Buff.Attack Power"] = "Buff de puissance d'attaque";
		["Consumable.Buff.Attack Speed"] = "Buff de vitesse d'attaque";
		["Consumable.Buff.Dodge"] = "Buff d'esquive";
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

		["Consumable.Potion.Recovery.Healing.Basic"] = "Potions de soin";
		["Consumable.Potion.Recovery.Healing.Blades Edge"] = "Heal Potions: Blades Edge";
		["Consumable.Potion.Recovery.Healing.Coilfang"] = "Heal Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Healing.PvP"] = "Potions de soin des champs de bataille";
		["Consumable.Potion.Recovery.Healing.Tempest Keep"] = "Heal Potions: Tempest Keep";
		["Consumable.Potion.Recovery.Mana.Basic"] = "Potions de mana";
		["Consumable.Potion.Recovery.Mana.Blades Edge"] = "Mana Potions: Blades Edge";
		["Consumable.Potion.Recovery.Mana.Coilfang"] = "Mana Potions: Coilfang Reservoir";
		["Consumable.Potion.Recovery.Mana.Pvp"] = "Potions de mana des champs de bataille";
		["Consumable.Potion.Recovery.Mana.Tempest Keep"] = "Mana Potions: Tempest Keep";

		["Consumable.Weapon Buff.Poison.Crippling"] = "Poison affaiblissant";
		["Consumable.Weapon Buff.Poison.Deadly"] = "Poison mortel";
		["Consumable.Weapon Buff.Poison.Instant"] = "Poison instantan\195\169";
		["Consumable.Weapon Buff.Poison.Mind Numbing"] = "Poison de distraction mentale";
		["Consumable.Weapon Buff.Poison.Wound"] = "Poison douloureux";
		["Consumable.Weapon Buff.Oil.Mana"] = "Huile d'enchantement : R\195\169g\195\169n\195\169ration de mana";
		["Consumable.Weapon Buff.Oil.Wizard"] = "Huile d'enchantement : Bonus de Dommage/Soin";
		["Consumable.Weapon Buff.Stone.Sharpening Stone"] = "Pierres \195\160 aiguiser";
		["Consumable.Weapon Buff.Stone.Weight Stone"] = "Contre-poids";

		["Consumable.Bandage.Basic"] = "Bandages";
		["Consumable.Bandage.Battleground.Alterac Valley"] = "Bandages d'Alterac";
		["Consumable.Bandage.Battleground.Warsong Gulch"] = "Bandages de Warsong";
		["Consumable.Bandage.Battleground.Arathi Basin"] = "Bandages d'Arathi";

		["Consumable.Food.Edible.Basic.Non-Conjured"] = "Nourriture : Aucun Bonus";
		["Consumable.Food.Percent.Basic"] = "Nourriture : gain de vie en %";
		["Consumable.Food.Percent.Bonus"] = "Nourriture: % HP Regen (well fed buff)";
		["Consumable.Food.Combo Percent"] = "Nourriture: % health & mana gain";
		["Consumable.Food.Combo Health"] = "Combo Nouriture et eau";
		["Consumable.Food.Edible.Bread.Conjured"] = "Nourriture : Conjur\195\169 par les Mages";
		["Consumable.Food.Conjure"] = "Conjure Food";
		["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = "Nourriture : Bassin d'Arathi";
		["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = "Nourriture : Goulet des Warsong";

		["Consumable.Food.Pet.Bread"] = "Nourriture : Pain pour familier";
		["Consumable.Food.Pet.Cheese"] = "Nourriture : Fromage pour familier";
		["Consumable.Food.Pet.Fish"] = "Nourriture : Poisson pour familier";
		["Consumable.Food.Pet.Fruit"] = "Nourriture : Fruit pour familier";
		["Consumable.Food.Pet.Fungus"] = "Nourriture : Champignon pour familier";
		["Consumable.Food.Pet.Meat"] = "Nourriture : Viande pour familier";

		["AUTOBAR_CLASS_CUSTOM"] = "Personnaliser";
		["AUTOBAR_CLASS_CLEAR"] = "Clear this Slot";
		["AUTOBAR_CLASS_UNGORORESTORE"] = "Cristal de restauration - Un'Goro";

		["Consumable.Anti-Venom"] = "Anti-Venin";

		["Consumable.Warlock.Healthstone"] = "Pierre de soin";
		["Consumable.Warlock.Create Healthstone"] = "Create Healthstone";
		["Consumable.Mage.Mana Stone"] = "Pierres de mana";
		["Consumable.Mage.Conjure Mana Stone"] = "Conjure Manastones";
		["Consumable.Potion.Recovery.Dreamless Sleep"] = "Sommeil sans r\195\170ve";
		["Consumable.Potion.Recovery.Rejuvenation"] = "Potions de r\195\169g\195\169n\195\169ration";
		["Consumable.Jeweler.Statue"] = "Stone Statues";

		["Misc.Battle Standard.Battleground"] = "Etendard de bataille";
		["Misc.Battle Standard.Alterac Valley"] = "Etendard de bataille (VA)";
		["Consumable.Recovery.Rune"] = "Runes d\195\169moniaques et t\195\169n\195\169breuses";
		["AUTOBAR_CLASS_ARCANE_PROTECTION"] = "Protection contre l'arcane";
		["AUTOBAR_CLASS_FIRE_PROTECTION"] = "Protection contre le feu";
		["AUTOBAR_CLASS_FROST_PROTECTION"] = "Protection contre le givre";
		["AUTOBAR_CLASS_NATURE_PROTECTION"] = "Protection contre la nature";
		["AUTOBAR_CLASS_SHADOW_PROTECTION"] = "Protection contre l'ombre";
		["AUTOBAR_CLASS_SPELL_REFLECTION"] = "Protection contre les sorts";
		["AUTOBAR_CLASS_HOLY_PROTECTION"] = "Protection contre le sacr\195\169";
		["AUTOBAR_CLASS_INVULNERABILITY_POTIONS"] = "Potions d'invuln\195\169rabilit\195\169";
		["Consumable.Buff.Free Action"] = "Potions de libre action";

		["AUTOBAR_CLASS_PORTALS"] = "Portals and Teleports";
		["Misc.Hearth"] = "Pierre de foyer";
		["Misc.Booze"] = "Booze";
		["Consumable.Water.Basic"] = "Eau";
		["Consumable.Water.Percentage"] = "Eau : gain de mana en %";
		["AUTOBAR_CLASS_WATER_CONJURED"] = "Eau : Conjur\195\169 par les Mages";
		["AUTOBAR_CLASS_WATER_CONJURE"] = "Conjure Water";
		["Consumable.Water.Buff.Spirit"] = "Eau : Bonus d'esprit";
		["Consumable.Buff.Rage.Self"] = "Potions de Rage";
		["Consumable.Buff.Energy.Self"] = "Potions d'\195\169nergie";
		["Consumable.Buff.Speed"] = "Potions de rapidit\195\169";
		["AUTOBAR_CLASS_SOULSHARDS"] = "Fragment d'\195\162mes";
		["Reagent.Ammo.Arrow"] = "Fl\195\168ches";
		["Reagent.Ammo.Bullet"] = "Balles";
		["Reagent.Ammo.Thrown"] = "Armes de jet";
		["Misc.Engineering.Explosives"] = "Explosifs d'ing\195\169ni\195\169rie";
		["Misc.Mount.Normal"] = "Monture";
		["Misc.Mount.Summoned"] = "Monture： Summoned";
		["Misc.Mount.Ahn'Qiraj"] = "Monture: Qiraji";
		["Misc.Mount.Flying"] = "Monture: Flying";

	}
end);


if (GetLocale() == "frFR") then

AUTOBAR_CHAT_MESSAGE1 = "La configuration pour ce personnage vient d'une ancienne version. Effacer. Aucune tentative de mise \195\160 jour n'a \195\169t\195\169 tent\195\169.";
AUTOBAR_CHAT_MESSAGE2 = "Mise \195\160 jour du bouton multi-objet #%d objet #%d afin d'utiliser l'ID \195\160 la place du nom de l'objet.";
AUTOBAR_CHAT_MESSAGE3 = "Mise à jour du bouton mono-objet #%d objet #%d afin d'utiliser l'ID \195\160 la place du nom de l'objet.";

--  AutoBar_Config.xml
AUTOBAR_CONFIG_VIEWTEXT = "Pour éditer un bouton, sélectionner le dans la section \nd'édition, en bas de la feuille Emplacements.";
AUTOBAR_CONFIG_SLOTVIEWTEXT = "Vue des sets combin\195\169s (non \195\169ditable)";
AUTOBAR_CONFIG_RESET = "R\195\169initialiser";
AUTOBAR_CONFIG_REVERT = "Inverser";
AUTOBAR_CONFIG_DONE = "OK";
AUTOBAR_CONFIG_DETAIL_CATEGORIES = "(Shift+Clique explore la cat\195\169gorie)";
AUTOBAR_CONFIG_DRAGHANDLE = "Bouton gauche maintenu pour d\195\169placer AutoBar\nClique gauche pour v\195\169rouiller/d\195\169v\195\169rouiller\nClique droit pour les options";
AUTOBAR_CONFIG_EMPTYSLOT = "RAZ";
AUTOBAR_CONFIG_CLEARSLOT = "Bouton vide";
AUTOBAR_CONFIG_SETSHARED = "Partager le profile:";
AUTOBAR_CONFIG_SETSHAREDTIP = "S\195\169lectionner le profile partag\195\169 \195\160 utiliser pour ce personnage.\nLes modifications apport\195\169es \195\160 un profile partag\195\169 touchent tous les personnage l'utilisant";

AUTOBAR_CONFIG_TAB_SLOTS = "Emplacements";
AUTOBAR_CONFIG_TAB_BAR = "Barre";
AUTOBAR_CONFIG_TAB_BUTTONS = "Boutons";
AUTOBAR_CONFIG_TAB_POPUP = "D\195\169ploiement";
AUTOBAR_CONFIG_TAB_PROFILE = "Profile";
AUTOBAR_CONFIG_TAB_KEYS = "Keys";

AUTOBAR_TOOLTIP1 = " (Qauntit\195\169 : ";
AUTOBAR_TOOLTIP2 = " [Objet personnalis\195\169]";
AUTOBAR_TOOLTIP4 = " [En champs de bataille seulement]";
AUTOBAR_TOOLTIP5 = " [Hors-combat seulement]";
AUTOBAR_TOOLTIP6 = " [Utilisation limit\195\169]";
AUTOBAR_TOOLTIP7 = " [Cooldown]";
AUTOBAR_TOOLTIP8 = "\n(Clique gauche pour application sur l'arme main droite\nClique droit pour application sur l'arme main gauche)";

AUTOBAR_CONFIG_DOCKTO = "Attacher \195\160 :";
AUTOBAR_CONFIG_USECHARACTERTIP = "Les objets de ce set de personnage sont spécifique à ce personnage.";
AUTOBAR_CONFIG_USESHAREDTIP = "Les objets d'un set partag\195\169 sont partag\195\169s par les personnages utilisant le m\195\170me set partag\195\169.\nLe set sp\195\169cifique peut \195\170tre d\195\169sign\195\169 dans l'onglet Profile.";
AUTOBAR_CONFIG_USECLASSTIP = "Les objets d'un set de classe sont partag\195\169s par les personnages de même classe utilisant le set de classe.";
AUTOBAR_CONFIG_USEBASICTIP = "Les objets du set de base sont partag\195\169s par les personnages utilisant le set de base.";
AUTOBAR_CONFIG_CHARACTERLAYOUTTIP = "Les modifications de l'organisation visuelle ne touchent que ce personnage.";
AUTOBAR_CONFIG_SHAREDLAYOUTTIP = "Les modifications de l'organisation visuelle touchent tous les personnage utilisant le même profile partag\195\169.";
AUTOBAR_CONFIG_TIPOVERRIDE = "Les boutons de ce set sont prioritaires sur les boutons des sets inf\195\169rieurs.\n";
AUTOBAR_CONFIG_TIPOVERRIDDEN = "Les boutons de ce set seront cacher par les sets supérieurs.\n";
AUTOBAR_CONFIG_TIPAFFECTSCHARACTER = "Les modifications ne touchent que ce personnage.";
AUTOBAR_CONFIG_TIPAFFECTSALL = "Les modifications touchent tous les personnages.";
AUTOBAR_CONFIG_SETUPSINGLE = "Configuration unique";
AUTOBAR_CONFIG_SETUPSHARED = "Configuration partag\195\169e";
AUTOBAR_CONFIG_SETUPSTANDARD = "Configuration standard";
AUTOBAR_CONFIG_SETUPBLANKSLATE = "Remise \195\160 blanc";
AUTOBAR_CONFIG_SETUPSINGLETIP = "Cliquer pour obtenir une configuration de personnage unique, similaire \195\160 AutoBar classique.";
AUTOBAR_CONFIG_SETUPSHAREDTIP = "Cliquer pour obtenir une configuration partag\195\169.\nActive les sets partag\195\169s et sp\195\169cifiques \195\160 un personnage.";
AUTOBAR_CONFIG_SETUPSTANDARDTIP = "Active l'\195\169diton et l'utilisation de tous les sets.";
AUTOBAR_CONFIG_SETUPBLANKSLATETIP = "Efface l'ensemble des boutons des sets partag\195\169s et de personnages.";
AUTOBAR_CONFIG_RESETSINGLETIP = "Cliquer pour r\195\169initialiser la configuration de personnage unique.";
AUTOBAR_CONFIG_RESETSHAREDTIP = "Cliquer pour r\195\169initialiser la configuration partag\195\169.\nLe set de classe est copi\195\169 vers le set de personnage.\nLe set par d\195\169faut est copi\195\169 vers le set partag\195\169.";
AUTOBAR_CONFIG_RESETSTANDARDTIP = "Cliquer pour r\195\169initialiser la configuration standard.\nLes boutons de classe sont dans le set de classe.\nLes boutons par d\195\169faut sont dans le set de base.\nLes sets partag\195\169s et de personnages sont r\195\169initialis\195\169s.";

--  AutoBarConfig.lua
AUTOBAR_TOOLTIP9 = "Bouton multi cat\195\169gorie\n";
AUTOBAR_TOOLTIP10 = " (Objet personnalis\195\169 par ID)";
AUTOBAR_TOOLTIP11 = "\n(ID de l'objet inconnu)";
AUTOBAR_TOOLTIP12 = " (Objet personnalis\195\169 par nom)";
AUTOBAR_TOOLTIP13 = "Bouton de cat\195\169gorie unique\n\n";
AUTOBAR_TOOLTIP14 = "\nPas utilisable directement.";
AUTOBAR_TOOLTIP15 = "\nCible une arme\n(Clique gauche pour l'arme main droite\nClique droit pour l'arme main gauche)";
AUTOBAR_TOOLTIP16 = "\nCibl\195\169.";
AUTOBAR_TOOLTIP17 = "\nHors-combat seulement.";
AUTOBAR_TOOLTIP18 = "\nCombat seulement.";
AUTOBAR_TOOLTIP19 = "\nLocalisation: ";
AUTOBAR_TOOLTIP20 = "\nUtilisation limit\195\169 : "
AUTOBAR_TOOLTIP21 = "Requi\195\168re une restauration de PV";
AUTOBAR_TOOLTIP22 = "Requi\195\168re une restauration de mana";
AUTOBAR_TOOLTIP23 = "Bouton pour objet unique\n\n";

--  AutoBarItemList.lua
--AUTOBAR_ALTERACVALLEY = "Vall\195\169e d'Alterac";
--AUTOBAR_WARSONGGULCH = "Goulet des Chanteguerres";
--AUTOBAR_ARATHIBASIN = "Bassin d'Arathi";
--AUTOBAR_AHN_QIRAJ = "Ahn'Qiraj";

end
