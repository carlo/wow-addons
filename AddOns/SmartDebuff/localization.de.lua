-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

if (GetLocale() == "deDE") then

SMARTDEBUFF_REJUVENATION      = "Verj\195\188ngung";
SMARTDEBUFF_RENEW             = "Erneuerung";
SMARTDEBUFF_FLASHOFLIGHT      = "Lichtblitz";
SMARTDEBUFF_LESSERHEALINGWAVE = "Geringe Welle der Heilung";

-- Debuff spells
SMARTDEBUFF_CUREDISEASE       = "Krankheit heilen";
SMARTDEBUFF_ABOLISHDISEASE    = "Krankheit aufheben";
SMARTDEBUFF_PURIFY            = "L\195\164utern";
SMARTDEBUFF_CLEANSE           = "Reinigung des Glaubens";
SMARTDEBUFF_DISPELLMAGIC      = "Magiebannung";
SMARTDEBUFF_CUREPOISON        = "Vergiftung heilen";
SMARTDEBUFF_ABOLISHPOISON     = "Vergiftung aufheben";
SMARTDEBUFF_REMOVELESSERCURSE = "Geringen Fluch aufheben";
SMARTDEBUFF_REMOVECURSE       = "Fluch aufheben";
SMARTDEBUFF_PURGE             = "Reinigen";
SMARTDEBUFF_POLYMORPH         = "Verwandlung";

SMARTDEBUFF_UNENDINGBREATH    = "Unendlicher Atem";
SMARTDEBUFF_PET_FELHUNTER     = "Magie verschlingen";
SMARTDEBUFF_PET_DOOMGUARD     = "Magiebannung";


-- Debuff types, in english in game!
--[[
SMARTDEBUFF_DISEASE = "Krankheit";
SMARTDEBUFF_MAGIC   = "Magie";
SMARTDEBUFF_POISON  = "Gift";
SMARTDEBUFF_CURSE   = "Fluch";
SMARTDEBUFF_CHARMED = "Verf\195\188hrung";
]]--

-- Ignore this effects
SMARTDEBUFF_DEBUFFSKIPLIST = {
  ["Traumloser Schlaf"] = true,
	["Gro\195\159er traumloser Schlaf"]	= true,
	["Gedankensicht"] = true,
	["Verbannen"] = true,
	["Phasenverschiebung"] = true,
	["Arkanschlag"] = true,
	["Instabiles Gebrechen"] = true,
};

-- Ignore this class based effects
SMARTDEBUFF_DEBUFFCLASSSKIPLIST = {
	["WARRIOR"] = {
	    ["Uralte Hysterie"] = true,
	    ["Mana entz\195\188nden"]	= true,
	    ["Besudelte Gedanken"] = true,
	    ["Umarmung der Witwe"] = true,
	    ["Fluch der Schatten"] = true,	    
	};
	["ROGUE"] = {
	    ["Stille"] = true;
	    ["Uralte Hysterie"] = true,
	    ["Mana entz\195\188nden"]	= true,
	    ["Besudelte Gedanken"] = true,
	    ["Fluch der Sprachen"] = true,
	    ["Umarmung der Witwe"] = true,
	    ["Schallexplosion"] = true,
	    ["Fluch der Schatten"] = true,	    
	};
	["HUNTER"] = {
	    ["Magmafesseln"] = true,
	    ["Fluch der Schatten"] = true,	    
	};
	["MAGE"] = {
	    ["Magmafesseln"] = true,
	    ["Verkr\195\188ppeln"] = true,
	    ["Staubwolke"] = true,
	    ["Donnerknall"] = true,
	    ["Fluch der Schatten"] = true,
	};
	["WARLOCK"] = {
	    ["Verkr\195\188ppeln"] = true,
	    ["Staubwolke"] = true,
	    ["Donnerknall"] = true,
	    ["Fluch der Schatten"] = true,
	};	
	["DRUID"] = {
	    ["Verkr\195\188ppeln"] = true,
	    ["Staubwolke"] = true,
	    ["Donnerknall"] = true,
	    ["Fluch der Schatten"] = true,
	};
	["PRIEST"] = {
	    ["Verkr\195\188ppeln"] = true,
	    ["Staubwolke"] = true,
	    ["Donnerknall"] = true,
	    ["Fluch der Schatten"] = true,
	};	
	["PALADIN"] = {
	    ["Verkr\195\188ppeln"] = true,
	    ["Staubwolke"] = true,
	    ["Fluch der Schatten"] = true,
	};
	["SHAMAN"] = {
	    ["Verkr\195\188ppeln"] = true,
	    ["Staubwolke"] = true,
	    ["Fluch der Schatten"] = true,
	};	
};


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoid";
SMARTDEBUFF_DEMON     = "D\195\164mon";
SMARTDEBUFF_BEAST     = "Wildtier";
SMARTDEBUFF_ELEMENTAL = "Elementar";
SMARTDEBUFF_IMP       = "Wichtel";
SMARTDEBUFF_FELHUNTER = "Teufelsj\195\164ger";
SMARTDEBUFF_DOOMGUARD = "Verdammniswache";

-- Classes
SMARTDEBUFF_CLASSES = { ["DRUID"] = "Druide", ["HUNTER"] = "J\195\164ger", ["MAGE"] = "Magier", ["PALADIN"] = "Paladin", ["PRIEST"] = "Priester", ["ROGUE"] = "Schurke"
                      , ["SHAMAN"] = "Schamane", ["WARLOCK"] = "Hexer", ["WARRIOR"] = "Krieger", ["HPET"] = "J\195\164ger Pet", ["WPET"] = "Hexer Pet"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Optionen";

SMARTDEBUFF_KEYS = {["L"]  = "Links",
                    ["R"]  = "Rechts",
                    ["M"]  = "Mitte",
                    ["SL"] = "Shift links",
                    ["SR"] = "Shift rechts",
                    ["SM"] = "Shift mitte",
                    ["AL"] = "Alt links",
                    ["AR"] = "Alt rechts",
                    ["AM"] = "Alt mitte",
                    ["CL"] = "Strg links",
                    ["CR"] = "Strg rechts",
                    ["CM"] = "Strg mitte"
                    };


-- Messages
SMARTDEBUFF_MSG_LOADED         = "geladen";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff Optionen";

-- Options frame text
SMARTDEBUFF_OFT                = "Zeige/verberge SmartDebuff Optionen";
SMARTDEBUFF_OFT_HUNTERPETS     = "J\195\164ger Pets";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Hexer Pets";
SMARTDEBUFF_OFT_INVERT         = "Invertiert";
SMARTDEBUFF_OFT_CLASSVIEW      = "Klassenansicht";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Klassenfarben";
SMARTDEBUFF_OFT_SHOWLR         = "Zeige L/R";
SMARTDEBUFF_OFT_HEADERS        = "Titel";
SMARTDEBUFF_OFT_GROUPNR        = "Gruppen Nr.";
SMARTDEBUFF_OFT_SOUND          = "Warnton";
SMARTDEBUFF_OFT_TOOLTIP        = "Tooltip";
SMARTDEBUFF_OFT_TARGETMODE     = "Ziel-Modus";
SMARTDEBUFF_OFT_HEALRANGE      = "Heil-Reichweite";
SMARTDEBUFF_OFT_VERTICAL       = "Vertikal ausgerichtet";
SMARTDEBUFF_OFT_VERTICALUP     = "Von unten nach oben";
SMARTDEBUFF_OFT_HEADERROW      = "Titelzeile, inkl. Kn\195\182pfe";
SMARTDEBUFF_OFT_BACKDROP       = "Hintergrund";
SMARTDEBUFF_OFT_INFOFRAME      = "Zeige Status-Fenster";
SMARTDEBUFF_OFT_COLUMNS        = "Spalten";
SMARTDEBUFF_OFT_INTERVAL       = "Interval";
SMARTDEBUFF_OFT_FONTSIZE       = "Schriftgr\195\182sse";
SMARTDEBUFF_OFT_WIDTH          = "Breite";
SMARTDEBUFF_OFT_HEIGHT         = "H\195\182he";
SMARTDEBUFF_OFT_BARHEIGHT      = "Balkenh\195\182he";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "In Reichweite";
SMARTDEBUFF_OFT_OPACITYOOR     = "Ausser Reichweite";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Debuff";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Klassenanordnung";

-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-Links ziehen: Fenster verschieben\n|cff20d2ff- S Knopf -|r\nLinks Klick: Ordne nach Klassen\nShift-Links Klick: Klassen-Farben\nAlt-Links Klick: Zeige L/R\nRechts Klick: Hintergrund";
SMARTDEBUFF_TT_TARGETMODE      = "Im Ziel-Modus w\195\164hlt |cff20d2fflinks klick|r die Einheit aus und |cff20d2ffrechts klick|r zaubert den schnellsten Heilspruch.\n|cff20d2ffAlt-Links/Rechts klick|r wird zum Debuffen benutzt.";

end
