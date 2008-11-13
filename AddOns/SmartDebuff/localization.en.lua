-------------------------------------------------------------------------------
-- English localization (Default)
-------------------------------------------------------------------------------

SMARTDEBUFF_REJUVENATION      = "Rejuvenation";
SMARTDEBUFF_RENEW             = "Renew";
SMARTDEBUFF_FLASHOFLIGHT      = "Flash of Light";
SMARTDEBUFF_LESSERHEALINGWAVE = "Lesser Healing Wave";

-- Debuff spells
SMARTDEBUFF_CUREDISEASE       = "Cure Disease";
SMARTDEBUFF_ABOLISHDISEASE    = "Abolish Disease";
SMARTDEBUFF_PURIFY            = "Purify";
SMARTDEBUFF_CLEANSE           = "Cleanse";
SMARTDEBUFF_DISPELLMAGIC      = "Dispel Magic";
SMARTDEBUFF_CUREPOISON        = "Cure Poison";
SMARTDEBUFF_ABOLISHPOISON     = "Abolish Poison";
SMARTDEBUFF_REMOVELESSERCURSE = "Remove Lesser Curse";
SMARTDEBUFF_REMOVECURSE       = "Remove Curse";
SMARTDEBUFF_PURGE             = "Purge";
SMARTDEBUFF_POLYMORPH         = "Polymorph";

SMARTDEBUFF_UNENDINGBREATH    = "Unending Breath";
SMARTDEBUFF_PET_FELHUNTER     = "Devour Magic";
SMARTDEBUFF_PET_DOOMGUARD     = "Dispel Magic";


-- Debuff types
SMARTDEBUFF_DISEASE = "Disease";
SMARTDEBUFF_MAGIC   = "Magic";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Curse";
SMARTDEBUFF_CHARMED = "Mind Control";
SMARTDEBUFF_HEAL    = "Heal";

-- Ignore this effects
SMARTDEBUFF_DEBUFFSKIPLIST = {
  ["Dreamless Sleep"] = true,
	["Greater Dreamless Sleep"]	= true,
	["Mind Vision"] = true,
	["Mutating Injection"] = true,
  ["Banish"] = true,
  ["Phase Shift"] = true,
  ["Arcane Blast"] = true,
  ["Unstable Affliction"] = true,
};

-- Ignore this class based effects
SMARTDEBUFF_DEBUFFCLASSSKIPLIST = {
	["WARRIOR"] = {
	    ["Ancient Hysteria"] = true,
	    ["Ignite Mana"]	= true,
	    ["Tainted Mind"] = true,
	    ["Widow's Embrace"] = true,
	    ["Delusions of Jin'do"] = true,
	};
	["ROGUE"] = {
	    ["Silence"] = true;
	    ["Ancient Hysteria"] = true,
	    ["Ignite Mana"]	= true,
	    ["Tainted Mind"] = true,
	    ["Curse of Tongues"] = true,
	    ["Widow's Embrace"] = true,
	    ["Sonic Burst"] = true,
	    ["Delusions of Jin'do"] = true,
	};
	["HUNTER"] = {
	    ["Magma Shackles"] = true,
	    ["Delusions of Jin'do"] = true,
	};
	["MAGE"] = {
	    ["Magma Shackles"] = true,
	    ["Cripple"] = true,
	    ["Dust Cloud"] = true,
	    ["Thunderclap"] = true,
	    ["Delusions of Jin'do"] = true,
	};
	["WARLOCK"] = {
	    ["Cripple"] = true,
	    ["Dust Cloud"] = true,
	    ["Thunderclap"] = true,
	    ["Delusions of Jin'do"] = true,
	};	
	["DRUID"] = {
	    ["Cripple"] = true,
	    ["Dust Cloud"] = true,
	    ["Thunderclap"] = true,
	    ["Delusions of Jin'do"] = true,
	};
	["PRIEST"] = {
	    ["Cripple"] = true,
	    ["Dust Cloud"] = true,
	    ["Thunderclap"] = true,
	    ["Delusions of Jin'do"] = true,
	};	
	["PALADIN"] = {
	    ["Cripple"] = true,
	    ["Dust Cloud"] = true,
	    ["Delusions of Jin'do"] = true,
	};
	["SHAMAN"] = {
	    ["Cripple"] = true,
	    ["Dust Cloud"] = true,
	    ["Delusions of Jin'do"] = true,
	};	
};


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoid";
SMARTDEBUFF_DEMON     = "Demon";
SMARTDEBUFF_BEAST     = "Beast";
SMARTDEBUFF_ELEMENTAL = "Elemental";
SMARTDEBUFF_IMP       = "Imp";
SMARTDEBUFF_FELHUNTER = "Felhunter";
SMARTDEBUFF_DOOMGUARD = "Doomguard";

-- Classes
SMARTDEBUFF_CLASSES = { ["DRUID"] = "Druid", ["HUNTER"] = "Hunter", ["MAGE"] = "Mage", ["PALADIN"] = "Paladin", ["PRIEST"] = "Priest", ["ROGUE"] = "Rogue"
                      , ["SHAMAN"] = "Shaman", ["WARLOCK"] = "Warlock", ["WARRIOR"] = "Warrior", ["HPET"] = "Hunter Pet", ["WPET"] = "Warlock Pet"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Options frame";

SMARTDEBUFF_KEYS = {["L"]  = "Left",
                    ["R"]  = "Right",
                    ["M"]  = "Middle",
                    ["SL"] = "Shift left",
                    ["SR"] = "Shift right",
                    ["SM"] = "Shift middle",
                    ["AL"] = "Alt left",
                    ["AR"] = "Alt right",
                    ["AM"] = "Alt middle",
                    ["CL"] = "Ctrl left",
                    ["CR"] = "Ctrl right",
                    ["CM"] = "Ctrl middle"
                    };


-- Messages
SMARTDEBUFF_MSG_LOADED         = "loaded";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff options frame";

-- Options frame text
SMARTDEBUFF_OFT                = "Show/Hide SmartDebuff options frame";
SMARTDEBUFF_OFT_HUNTERPETS     = "Hunter pets";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Warlock pets";
SMARTDEBUFF_OFT_INVERT         = "Invert";
SMARTDEBUFF_OFT_CLASSVIEW      = "Class view";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Class colors";
SMARTDEBUFF_OFT_SHOWLR         = "Show L/R";
SMARTDEBUFF_OFT_HEADERS        = "Headers";
SMARTDEBUFF_OFT_GROUPNR        = "Group Nr.";
SMARTDEBUFF_OFT_SOUND          = "Sound";
SMARTDEBUFF_OFT_TOOLTIP        = "Tooltip";
SMARTDEBUFF_OFT_TARGETMODE     = "Target mode";
SMARTDEBUFF_OFT_HEALRANGE      = "Heal range";
SMARTDEBUFF_OFT_VERTICAL       = "Vertical arranged";
SMARTDEBUFF_OFT_VERTICALUP     = "Vertical up";
SMARTDEBUFF_OFT_HEADERROW      = "Header row, incl. buttons";
SMARTDEBUFF_OFT_BACKDROP       = "Show background";
SMARTDEBUFF_OFT_INFOFRAME      = "Show summary frame";
SMARTDEBUFF_OFT_COLUMNS        = "Columns";
SMARTDEBUFF_OFT_INTERVAL       = "Interval";
SMARTDEBUFF_OFT_FONTSIZE       = "Font size";
SMARTDEBUFF_OFT_WIDTH          = "Width";
SMARTDEBUFF_OFT_HEIGHT         = "Height";
SMARTDEBUFF_OFT_BARHEIGHT      = "Bar height";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "Opacity in range";
SMARTDEBUFF_OFT_OPACITYOOR     = "Opacity out of range";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Opacity debuff";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Sort by class order";


-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-Left drag: Move frame\n|cff20d2ff- S button -|r\nLeft click: Show by classes\nShift-Left click: Class colors\nAlt-Left click: Highlight L/R\nRight click: Background";
SMARTDEBUFF_TT_TARGETMODE      = "In target mode |cff20d2ffLeft click|r selects the unit and |cff20d2ffRight click|r casts the fastest heal spell.\nUse |cff20d2ffAlt-Left/Right click|r to debuff.";
