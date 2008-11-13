-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text German Localization
-- Author: Mik
-- German Translation by: Farook
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't German.
if (GetLocale() ~= "deDE") then return; end

-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

-- Local reference for faster access.
local MSBTLocale = MikSBT.Locale;


MSBTLocale.COMMAND_USAGE = {
 "Usage: " .. MikSBT.COMMAND .. " <befehle> [params]",
 " Befehle:",
 "  " .. MSBTLocale.COMMAND_RESET .. " - Das aktuelle Profil auf Standardwerte zur\195\188cksetzen.",
 "  " .. MSBTLocale.COMMAND_DISABLE .. " - Das Addon deaktivieren.",
 "  " .. MSBTLocale.COMMAND_ENABLE .. " - Das Addon aktivieren.",
 "  " .. MSBTLocale.COMMAND_SHOWVER .. " - Zeigt die aktuelle Version an.",
 "  " .. MSBTLocale.COMMAND_SEARCH .. " filter - Setzt einen Filter f\195\188r das Suchen von Event-Typen.",
 "  " .. MSBTLocale.COMMAND_HELP .. " - Hilfe anzeigen.",
};


------------------------------
-- Output messages
------------------------------

MSBTLocale.MSG_SEARCH_ENABLE			= "Event-Suchmodus aktiviert. Suche nach: ";
MSBTLocale.MSG_SEARCH_DISABLE			= "Event-Suchmodus deaktiviert.";
MSBTLocale.MSG_DISABLE					= "Addon deaktiviert.";
MSBTLocale.MSG_ENABLE					= "Addon aktiviert.";
MSBTLocale.MSG_PROFILE_RESET			= "Profil zur\195\188cksetzen";
MSBTLocale.MSG_HITS						= "Treffer";
--MSBTLocale.MSG_CRIT					= "Crit";
--MSBTLocale.MSG_CRITS					= "Crits";
MSBTLocale.MSG_MULTIPLE_TARGETS			= "Mehrere";
MSBTLocale.MSG_READY_NOW				= "Vorhanden";
MSBTLocale.MSG_VULNERABLE_TRAILER		= " (%d Schadenanf\195\164lligkeit)";
MSBTLocale.MSG_ENVIRONMENTAL_DROWNING	= "Ertrinken";
MSBTLocale.MSG_ENVIRONMENTAL_FALLING	= "Abst\195\188rzen";
MSBTLocale.MSG_ENVIRONMENTAL_FATIGUE	= "Ersch\195\182pfung";
MSBTLocale.MSG_ENVIRONMENTAL_FIRE		= "Feuer";
--MSBTLocale.MSG_ENVIRONMENTAL_LAVA		= "Lava";
MSBTLocale.MSG_ENVIRONMENTAL_SLIME		= "Schleim";


------------------------------
-- Scroll area messages
------------------------------

MSBTLocale.MSG_INCOMING			= "Eingehend";
MSBTLocale.MSG_OUTGOING			= "Ausgehend";
MSBTLocale.MSG_NOTIFICATION		= "Benachrichtigung";
MSBTLocale.MSG_STATIC			= "Statisch";


---------------------------------------
-- Master profile event output messages
---------------------------------------

MSBTLocale.MSG_COMBAT					= "Kampf";
--MSBTLocale.MSG_CP						= "CP";
MSBTLocale.MSG_CP_FULL					= "Alle Combo-Punkte";
MSBTLocale.MSG_KILLING_BLOW				= "Todessto\195\159";
MSBTLocale.MSG_TRIGGER_BACKLASH			= "Heimzahlen";
MSBTLocale.MSG_TRIGGER_BLACKOUT			= "Verdunkelung";
MSBTLocale.MSG_TRIGGER_CLEARCASTING		= "Freizauber";
MSBTLocale.MSG_TRIGGER_COUNTER_ATTACK	= "Gegenangriff";
MSBTLocale.MSG_TRIGGER_EXECUTE			= "Hinrichten";
MSBTLocale.MSG_TRIGGER_FROSTBITE		= "Erfrierung";
MSBTLocale.MSG_TRIGGER_HAMMER_OF_WRATH	= "Hammer des Zorns";
MSBTLocale.MSG_TRIGGER_IMPACT			= "Einschlag";
MSBTLocale.MSG_TRIGGER_KILL_COMMAND		= "Fass";
MSBTLocale.MSG_TRIGGER_LOW_HEALTH		= "Gesundheit Niedrig";
MSBTLocale.MSG_TRIGGER_LOW_MANA			= "Mana Niedrig";
MSBTLocale.MSG_TRIGGER_LOW_PET_HEALTH	= "Begleiter Gesundheit Niedrig";
MSBTLocale.MSG_TRIGGER_MONGOOSE_BITE	= "Mungobiss";
MSBTLocale.MSG_TRIGGER_NIGHTFALL		= "Einbruch der Nacht";
MSBTLocale.MSG_TRIGGER_RAMPAGE			= "Toben";
MSBTLocale.MSG_TRIGGER_REVENGE			= "Rache";
--MSBTLocale.MSG_TRIGGER_RIPOSTE		= "Riposte";
MSBTLocale.MSG_TRIGGER_OVERPOWER		= "\195\156berw\195\164ltigen";


----------------------------------
-- Spell names
----------------------------------

MSBTLocale.SPELL_COLD_SNAP				= "K\195\164lteeinbruch";
MSBTLocale.SPELL_DRAIN_LIFE				= "Blutsauger";
MSBTLocale.SPELL_EVOCATION				= "Hervorrufung";
MSBTLocale.SPELL_INNERVATE				= "Anregen";
MSBTLocale.SPELL_MANA_SPRING			= "Manaquelle";
MSBTLocale.SPELL_PREPARATION			= "Vorbereitung";
MSBTLocale.SPELL_READINESS				= "Bereitschaft";
MSBTLocale.SPELL_REFLECTIVE_SHIELD		= "Reflektierender Schild";
MSBTLocale.SPELL_SHADOWMEND				= "Schattenheilung";
MSBTLocale.SPELL_SHADOW_TRANCE			= "Schattentrance";
MSBTLocale.SPELL_SIPHON_LIFE			= "Lebensentzug";
MSBTLocale.SPELL_SPIRIT_TAP				= "Willensentzug";
MSBTLocale.SPELL_VAMPIRIC_EMBRACE		= "Vampirumarmung";
MSBTLocale.SPELL_VAMPIRIC_TOUCH			= "Vampirber\195\188hrung";