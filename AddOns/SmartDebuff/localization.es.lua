-------------------------------------------------------------------------------
-- Spanish localization
-------------------------------------------------------------------------------

if (GetLocale() == "esES") then


SMARTDEBUFF_REJUVENATION      = "Rejuvenecimiento";
SMARTDEBUFF_RENEW             = "Renovar";
SMARTDEBUFF_FLASHOFLIGHT      = "Destello de Luz";
SMARTDEBUFF_LESSERHEALINGWAVE = "Ola de sanación inferior";

-- Debuff spells
SMARTDEBUFF_CUREDISEASE       = "Curar enfermedad";
SMARTDEBUFF_ABOLISHDISEASE    = "Suprimir enfermedad";
SMARTDEBUFF_PURIFY            = "Purificar";
SMARTDEBUFF_CLEANSE           = "Limpiar";
SMARTDEBUFF_DISPELLMAGIC      = "Disipar magia";
SMARTDEBUFF_CUREPOISON        = "Curar envenenamiento";
SMARTDEBUFF_ABOLISHPOISON     = "Suprimir veneno";
SMARTDEBUFF_REMOVELESSERCURSE = "Deshacer maldición inferior";
SMARTDEBUFF_REMOVECURSE       = "Deshacer maldición";
SMARTDEBUFF_PURGE             = "Purgar";
SMARTDEBUFF_POLYMORPH         = "Polimorfia";

SMARTDEBUFF_UNENDINGBREATH    = "Respiración inagotable";
SMARTDEBUFF_PET_FELHUNTER     = "Devorar magia";
SMARTDEBUFF_PET_DOOMGUARD     = "Disipar magia";


-- Debuff types
SMARTDEBUFF_DISEASE = "Enfermedad";
SMARTDEBUFF_MAGIC   = "Magia";
SMARTDEBUFF_POISON  = "Veneno";
SMARTDEBUFF_CURSE   = "Maldición";
SMARTDEBUFF_CHARMED = "Control mental";
SMARTDEBUFF_HEAL    = "Sanar";

-- Ignore this effects
SMARTDEBUFF_DEBUFFSKIPLIST = {
  ["Letargo sin sueños"] = true,
	["Letargo sin sueños superior"]	= true,
	["Visión mental"] = true,
	["Inyección mutante"] = true,
  ["Desterrar"] = true,
  ["Cambio de fase"] = true,
  ["Aflicci\195\179n inestable"] = true,
};

-- Ignore this class based effects
SMARTDEBUFF_DEBUFFCLASSSKIPLIST = {
	["WARRIOR"] = {
	    ["Histeria antigua"] = true,
	    ["Maná incendiado"]	= true,
	    ["Mente contaminada"] = true,
	};
	["ROGUE"] = {
	    ["Silencio"] = true;
	    ["Histeria antigua"] = true,
	    ["Maná incendiado"]	= true,
	    ["Mente contaminada"] = true,
	};
	["HUNTER"] = {
	    ["Grilletes de magma"] = true,
	};
	["MAGE"] = {
	    ["Grilletes de magma"] = true,
	};
};


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoide";
SMARTDEBUFF_DEMON     = "Demonio";
SMARTDEBUFF_BEAST     = "Bestia";
SMARTDEBUFF_ELEMENTAL = "Elemental";
SMARTDEBUFF_IMP       = "Diablillo";
SMARTDEBUFF_FELHUNTER = "Manáfago";
SMARTDEBUFF_DOOMGUARD = "Guardia apocalíptico";

-- Classes
SMARTDEBUFF_CLASSES = { ["DRUID"] = "Druida", ["HUNTER"] = "Cazador", ["MAGE"] = "Mago", ["PALADIN"] = "Paladín", ["PRIEST"] = "Sacerdote", ["ROGUE"] = "Pícaro"
                      , ["SHAMAN"] = "Chamán", ["WARLOCK"] = "Brujo", ["WARRIOR"] = "Guerrero", ["HPET"] = "Mascota de cazador", ["WPET"] = "Mascota de Brujo"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Marco de opciones";


-- Messages
SMARTDEBUFF_MSG_LOADED         = "cargado";
SMARTDEBUFF_MSG_SDB            = "Marco de opciones de SmartDebuff";

-- Options frame text
SMARTDEBUFF_OFT                = "Mostrar/ocultar Marco de opciones de SmartDebuff";
SMARTDEBUFF_OFT_HUNTERPETS     = "Mascotas de cazador";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Mascotas de brujo";
SMARTDEBUFF_OFT_INVERT         = "Invertir";
SMARTDEBUFF_OFT_CLASSVIEW      = "Ver clases";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Colores de clases";
SMARTDEBUFF_OFT_SHOWLR         = "Mostrar L/R";
SMARTDEBUFF_OFT_HEADERS        = "Encabezados";
SMARTDEBUFF_OFT_GROUPNR        = "Nº de grupo";
SMARTDEBUFF_OFT_SOUND          = "Sonido";
SMARTDEBUFF_OFT_TOOLTIP        = "Ayuda visual";
SMARTDEBUFF_OFT_TARGETMODE     = "Modo objetivo";
SMARTDEBUFF_OFT_HEALRANGE      = "Rango de cura";
SMARTDEBUFF_OFT_VERTICAL       = "Orden vertical";
SMARTDEBUFF_OFT_VERTICALUP     = "Vertical arriba";
SMARTDEBUFF_OFT_HEADERROW      = "Encabezado de fila, con botones";
SMARTDEBUFF_OFT_BACKDROP       = "Mostrar fondo";
SMARTDEBUFF_OFT_INFOFRAME      = "Mostrar marco de sumario";
SMARTDEBUFF_OFT_COLUMNS        = "Columnas";
SMARTDEBUFF_OFT_INTERVAL       = "Intervalo";
SMARTDEBUFF_OFT_FONTSIZE       = "Tamaño de fuente";
SMARTDEBUFF_OFT_WIDTH          = "Ancho";
SMARTDEBUFF_OFT_HEIGHT         = "Alto";
SMARTDEBUFF_OFT_BARHEIGHT      = "Barra alto";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "Opacidad en rango";
SMARTDEBUFF_OFT_OPACITYOOR     = "Opacidad fuera de rango";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Opacidad al quitar debuff";


-- Tooltip text
SMARTDEBUFF_TT                 = "Mayúsculas-arrastrar izquierdo: Mover marco\n|cff20d2ff- S botón -|r\nClick Izquierdo: Mostrar por clases\nMayúscuals-Click Izquierdo: Colores de clase\nAlt-Click izquierdo: Destacar L/R\nClick derecho: Fondo";
SMARTDEBUFF_TT_TARGETMODE      = "En modo objetivo |cff20d2ffClick izquierdo|r selecciona la unidad y |cff20d2ffClick derecho|r lanza el hechizo más rápido de curación.\nUsar |cff20d2ffAlt-Click derecho/izquierdo|r para debuff.";

end