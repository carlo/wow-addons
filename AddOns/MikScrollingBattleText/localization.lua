-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Localization
-- Author: Mik
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {};
local moduleName = "Locale";
MikSBT[moduleName] = module;

-- Local reference for uniformity with localization files.
local MSBTLocale = module;


-------------------------------------------------------------------------------
-- English localization (Default)
-------------------------------------------------------------------------------

------------------------------
-- Commands
------------------------------

MSBTLocale.COMMAND_RESET	= "reset";
MSBTLocale.COMMAND_DISABLE	= "disable";
MSBTLocale.COMMAND_ENABLE	= "enable";
MSBTLocale.COMMAND_DISPLAY	= "display";
MSBTLocale.COMMAND_SHOWVER	= "version";
MSBTLocale.COMMAND_SEARCH	= "search";
MSBTLocale.COMMAND_HELP		= "help";

MSBTLocale.COMMAND_USAGE = {
 "Usage: " .. MikSBT.COMMAND .. " <command> [params]",
 " Commands:",
 "  " .. MSBTLocale.COMMAND_RESET .. " - Reset the current profile to the default settings.",
 "  " .. MSBTLocale.COMMAND_DISABLE .. " - Disables the mod.",
 "  " .. MSBTLocale.COMMAND_ENABLE .. " - Enables the mod.",
 "  " .. MSBTLocale.COMMAND_SHOWVER .. " - Shows the current version.",
 "  " .. MSBTLocale.COMMAND_SEARCH .. " filter - Sets a filter for searching event types.",
 "  " .. MSBTLocale.COMMAND_HELP .. " - Show the command usage.",
};


------------------------------
-- Output messages
------------------------------

MSBTLocale.MSG_SEARCH_ENABLE			= "Event search mode enabled.  Searching for: ";
MSBTLocale.MSG_SEARCH_DISABLE			= "Event search mode disabled.";
MSBTLocale.MSG_DISABLE					= "Mod disabled.";
MSBTLocale.MSG_ENABLE					= "Mod enabled.";
MSBTLocale.MSG_PROFILE_RESET			= "Profile Reset";
MSBTLocale.MSG_HITS						= "Hits";
MSBTLocale.MSG_CRIT						= "Crit";
MSBTLocale.MSG_CRITS					= "Crits";
MSBTLocale.MSG_MULTIPLE_TARGETS			= "Multiple";
MSBTLocale.MSG_READY_NOW				= "Ready Now";
MSBTLocale.MSG_VULNERABLE_TRAILER		= " (%d vulnerability)";
MSBTLocale.MSG_ENVIRONMENTAL_DROWNING	= "Drowning";
MSBTLocale.MSG_ENVIRONMENTAL_FALLING	= "Falling";
MSBTLocale.MSG_ENVIRONMENTAL_FATIGUE	= "Fatigue";
MSBTLocale.MSG_ENVIRONMENTAL_FIRE		= "Fire";
MSBTLocale.MSG_ENVIRONMENTAL_LAVA		= "Lava";
MSBTLocale.MSG_ENVIRONMENTAL_SLIME		= "Slime";


------------------------------
-- Scroll area names
------------------------------

MSBTLocale.MSG_INCOMING			= "Incoming";
MSBTLocale.MSG_OUTGOING			= "Outgoing";
MSBTLocale.MSG_NOTIFICATION		= "Notification";
MSBTLocale.MSG_STATIC			= "Static";


----------------------------------------
-- Master profile event output messages
----------------------------------------

MSBTLocale.MSG_COMBAT					= "Combat";
MSBTLocale.MSG_CP						= "CP";
MSBTLocale.MSG_CP_FULL					= "Finish It";
MSBTLocale.MSG_KILLING_BLOW				= "Killing Blow";
MSBTLocale.MSG_TRIGGER_BACKLASH			= "Backlash";
MSBTLocale.MSG_TRIGGER_BLACKOUT			= "Blackout";
MSBTLocale.MSG_TRIGGER_CLEARCASTING		= "Clearcasting";
MSBTLocale.MSG_TRIGGER_COUNTER_ATTACK	= "Counterattack";
MSBTLocale.MSG_TRIGGER_EXECUTE			= "Execute";
MSBTLocale.MSG_TRIGGER_FROSTBITE		= "Frostbite";
MSBTLocale.MSG_TRIGGER_HAMMER_OF_WRATH	= "Hammer of Wrath";
MSBTLocale.MSG_TRIGGER_IMPACT			= "Impact";
MSBTLocale.MSG_TRIGGER_KILL_COMMAND		= "Kill Command";
MSBTLocale.MSG_TRIGGER_LOW_HEALTH		= "Low Health";
MSBTLocale.MSG_TRIGGER_LOW_MANA			= "Low Mana";
MSBTLocale.MSG_TRIGGER_LOW_PET_HEALTH	= "Low Pet Health";
MSBTLocale.MSG_TRIGGER_MONGOOSE_BITE	= "Mongoose Bite";
MSBTLocale.MSG_TRIGGER_NIGHTFALL		= "Nightfall";
MSBTLocale.MSG_TRIGGER_RAMPAGE			= "Rampage";
MSBTLocale.MSG_TRIGGER_REVENGE			= "Revenge";
MSBTLocale.MSG_TRIGGER_RIPOSTE			= "Riposte";
MSBTLocale.MSG_TRIGGER_OVERPOWER		= "Overpower";


----------------------------------
-- Spell names
----------------------------------

MSBTLocale.SPELL_COLD_SNAP			= "Cold Snap";
MSBTLocale.SPELL_DRAIN_LIFE			= "Drain Life";
MSBTLocale.SPELL_EVOCATION			= "Evocation";
MSBTLocale.SPELL_INNERVATE			= "Innervate";
MSBTLocale.SPELL_MANA_SPRING		= "Mana Spring";
MSBTLocale.SPELL_PREPARATION		= "Preparation";
MSBTLocale.SPELL_READINESS			= "Readiness";
MSBTLocale.SPELL_REFLECTIVE_SHIELD	= "Reflective Shield";
MSBTLocale.SPELL_SHADOWMEND			= "Shadowmend";
MSBTLocale.SPELL_SHADOW_TRANCE		= "Shadow Trance";
MSBTLocale.SPELL_SIPHON_LIFE		= "Siphon Life";
MSBTLocale.SPELL_SPIRIT_TAP			= "Spirit Tap";
MSBTLocale.SPELL_VAMPIRIC_EMBRACE	= "Vampiric Embrace";
MSBTLocale.SPELL_VAMPIRIC_TOUCH		= "Vampiric Touch";