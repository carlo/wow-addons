-------------------------------------------------------------------------------
-- French localization
-------------------------------------------------------------------------------

if (GetLocale() == "frFR") then

SMARTDEBUFF_REJUVENATION      = "R\195\169cup\195\169ration";
SMARTDEBUFF_RENEW             = "R\195\169novation";
SMARTDEBUFF_FLASHOFLIGHT      = "Eclair lumineux";
SMARTDEBUFF_LESSERHEALINGWAVE = "Vague de soins mineurs";

-- Debuff spells
SMARTDEBUFF_CUREDISEASE       = "Gu\195\169rison des maladies";
SMARTDEBUFF_ABOLISHDISEASE    = "Abolir maladie";
SMARTDEBUFF_PURIFY            = "Purification";
SMARTDEBUFF_CLEANSE           = "Epuration";
SMARTDEBUFF_DISPELLMAGIC      = "Dissipation de la magie";
SMARTDEBUFF_CUREPOISON        = "Gu\195\169rison du poison";
SMARTDEBUFF_ABOLISHPOISON     = "Abolir le poison";
SMARTDEBUFF_REMOVELESSERCURSE = "D\195\169livrance de la mal\195\169diction mineure";
SMARTDEBUFF_REMOVECURSE       = "D\195\169livrance de la mal\195\169diction";
SMARTDEBUFF_PURGE             = "Expiation";
SMARTDEBUFF_POLYMORPH         = "M\195\169tamorphose";

SMARTDEBUFF_UNENDINGBREATH    = "Respiration interminable";
SMARTDEBUFF_PET_FELHUNTER     = "D\195\169vorer la magie";
SMARTDEBUFF_PET_DOOMGUARD     = "Dissipation de la magie";


-- Debuff types, in english in game!
--[[
SMARTDEBUFF_DISEASE = "Maladie";
SMARTDEBUFF_MAGIC   = "Magie";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Mal\195\169diction";
SMARTDEBUFF_CHARMED = "Contr\195\180le mentale";
]]--

-- Ignore this effects
SMARTDEBUFF_DEBUFFSKIPLIST = {
  ["Sommeil sans r\195\170ve"] = true,
	["Sommeil sans r\195\170ve sup\195\169rieur"]	= true,
	["Vision T\195\169l\195\169pathique"] = true,
	["Bannir"] = true,
	["Changement de phase"]	= true,
	["Affliction instable"] = true,
};

-- Ignore this class based effects
SMARTDEBUFF_DEBUFFCLASSSKIPLIST = {
	["WARRIOR"] = {
	    ["Hyst\195\169rie ancienne"] = true,
	    ["Enflammer le mana"]	= true,
	    ["Esprit corrompu"] = true,
	    ["Baiser de la veuve"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};
	["ROGUE"] = {
	    ["Silence"] = true;
	    ["Hyst\195\169rie ancienne"] = true,
	    ["Enflammer le mana"]	= true,
	    ["Esprit corrompu"] = true,
	    ["Mal\195\169diction des langages"] = true,
	    ["Baiser de la veuve"] = true,
	    ["Explosion sonore"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};
	["HUNTER"] = {
	    ["Entraves de magma"] = true,
	    ["Illusions de Jin'do"] = true,
	};
	["MAGE"] = {
	    ["Entraves de magma"] = true,
	    ["Faiblesse"] = true,
	    ["Nuage de poussi\195\168re"] = true,
	    ["Coup de tonnerre"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};
	["WARLOCK"] = {
	    ["Faiblesse"] = true,
	    ["Nuage de poussi\195\168re"] = true,
	    ["Coup de tonnerre"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};
	["DRUID"] = {
	    ["Faiblesse"] = true,
	    ["Nuage de poussi\195\168re"] = true,
	    ["Coup de tonnerre"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};
	["PRIEST"] = {
	    ["Faiblesse"] = true,
	    ["Nuage de poussi\195\168re"] = true,
	    ["Coup de tonnerre"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};	
	["PALADIN"] = {
	    ["Faiblesse"] = true,
	    ["Nuage de poussi\195\168re"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};	
	["SHAMAN"] = {
	    ["Faiblesse"] = true,
	    ["Nuage de poussi\195\168re"] = true,
	    ["Illusions de Jin'do"] = true,	    
	};		
};


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humano\195\175de";
SMARTDEBUFF_DEMON     = "D\195\169mon";
SMARTDEBUFF_BEAST     = "B\195\170te";
SMARTDEBUFF_ELEMENTAL = "\195\137l\195\169mentaire";
SMARTDEBUFF_IMP       = "Diablotin";
SMARTDEBUFF_FELHUNTER = "Chasseur corrompu";
SMARTDEBUFF_DOOMGUARD = "Garde funeste";

-- Classes
SMARTDEBUFF_CLASSES = { ["DRUID"] = "Druide", ["HUNTER"] = "Chasseur", ["MAGE"] = "Mage", ["PALADIN"] = "Paladin", ["PRIEST"] = "Pr\195\170tre", ["ROGUE"] = "Voleur"
                      , ["SHAMAN"] = "Chaman", ["WARLOCK"] = "D\195\169moniste", ["WARRIOR"] = "Guerrier", ["HPET"] = "Chasseur Pet", ["WPET"] = "D\195\169moniste Pet"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Menu d\'Options";


-- Messages
SMARTDEBUFF_MSG_LOADED         = "lanc\195\169";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff menu d\'Options";

-- Options frame text
SMARTDEBUFF_OFT                = "Show/Hide SmartDebuff options frame";

-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-Left drag: Move frame\n|cff20d2ff- S button -|r\nLeft click: Show by classes\nShift-Left click: Class colors\nAlt-Left click: Highlight L/R\nRight click: Background"; -- NOT TRANSLATED

end
