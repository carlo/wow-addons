-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text French Localization
-- Author: Mik
-- French Translation by: Calthas
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't French.
if (GetLocale() ~= "frFR") then return; end

-------------------------------------------------------------------------------
-- French localization
-------------------------------------------------------------------------------

-- Local reference for faster access.
local MSBTLocale = MikSBT.Locale;


MSBTLocale.COMMAND_USAGE = {
 "Usage: " .. MikSBT.COMMAND .. " <commande> [params]",
 " Commande:",
 "  " .. MSBTLocale.COMMAND_RESET .. " - Restaure les param\195\168tres par d\195\169faut.",
 "  " .. MSBTLocale.COMMAND_DISABLE .. " - D\195\169sactive l'addon.",
 "  " .. MSBTLocale.COMMAND_ENABLE .. " - Active l'addon.",
 "  " .. MSBTLocale.COMMAND_SHOWVER .. " - Affiche la version actuelle.",
 "  " .. MSBTLocale.COMMAND_SEARCH .. " filtre - D\195\169clare un filtre de recherche d'\195\169v\195\168nements.",
 "  " .. MSBTLocale.COMMAND_HELP .. " - Affiche l'aide des commandes.",
};


------------------------------
-- Output messages
------------------------------

MSBTLocale.MSG_SEARCH_ENABLE			= "Mode de recherche d'\195\169v\195\168nements activ\195\169e. Recherche de: ";
MSBTLocale.MSG_SEARCH_DISABLE			= "Mode de recherche d'\195\169v\195\168nements d\195\169sactiv\195\169e.";
MSBTLocale.MSG_DISABLE					= "Addon d\195\169sactiv\195\169.";
MSBTLocale.MSG_ENABLE					= "Addon activ\195\169.";
MSBTLocale.MSG_PROFILE_RESET			= "Profil r\195\169initialis\195\169";
MSBTLocale.MSG_HITS						= "Coups";
--MSBTLocale.MSG_CRIT					= "Crit";
--MSBTLocale.MSG_CRITS					= "Crits";
MSBTLocale.MSG_MULTIPLE_TARGETS			= "Multiples";
MSBTLocale.MSG_READY_NOW				= "Disponible";
MSBTLocale.MSG_VULNERABLE_TRAILER		= " (vuln\195\169rabilit\195\169: %d)";
MSBTLocale.MSG_ENVIRONMENTAL_DROWNING	= "Noyade";
MSBTLocale.MSG_ENVIRONMENTAL_FALLING	= "Chute";
MSBTLocale.MSG_ENVIRONMENTAL_FATIGUE	= "Epuis\195\169";
MSBTLocale.MSG_ENVIRONMENTAL_FIRE		= "Feu";
MSBTLocale.MSG_ENVIRONMENTAL_LAVA		= "Lave";
MSBTLocale.MSG_ENVIRONMENTAL_SLIME		= "Vase";


------------------------------
-- Scroll area messages
------------------------------

MSBTLocale.MSG_INCOMING			= "Entrant";
MSBTLocale.MSG_OUTGOING			= "Sortant";
MSBTLocale.MSG_NOTIFICATION		= "Alertes";
MSBTLocale.MSG_STATIC			= "Statique";


---------------------------------------
-- Master profile event output messages
---------------------------------------

--MSBTLocale.MSG_COMBAT					= "Combat";
--MSBTLocale.MSG_CP						= "CP";
--MSBTLocale.CP_FULL					= "Finish It";
MSBTLocale.MSG_KILLING_BLOW				= "Coup Fatal";
MSBTLocale.MSG_TRIGGER_BACKLASH			= "Contrecoup";
MSBTLocale.MSG_TRIGGER_BLACKOUT			= "Aveuglement";
MSBTLocale.MSG_TRIGGER_CLEARCASTING		= "Id\195\169es claires";
MSBTLocale.MSG_TRIGGER_COUNTER_ATTACK	= "Contre-attaque";
MSBTLocale.MSG_TRIGGER_EXECUTE			= "Ex\195\169cution";
MSBTLocale.MSG_TRIGGER_FROSTBITE		= "Morsure du givre";
MSBTLocale.MSG_TRIGGER_HAMMER_OF_WRATH	= "Marteau de courroux";
--MSBTLocale.MSG_TRIGGER_IMPACT			= "Impact";
MSBTLocale.MSG_TRIGGER_KILL_COMMAND		= "Ordre de tuer";
MSBTLocale.MSG_TRIGGER_LOW_HEALTH		= "Vie Faible";
MSBTLocale.MSG_TRIGGER_LOW_MANA			= "Mana Faible";
MSBTLocale.MSG_TRIGGER_LOW_PET_HEALTH	= "Vie du fam faible";
MSBTLocale.MSG_TRIGGER_MONGOOSE_BITE	= "Morsure de la Mangouste";
MSBTLocale.MSG_TRIGGER_NIGHTFALL		= "Cr\195\169puscule";
MSBTLocale.MSG_TRIGGER_RAMPAGE			= "Saccager";
MSBTLocale.MSG_TRIGGER_REVENGE			= "Vengeance";
--MSBTLocale.MSG_TRIGGER_RIPOSTE		= "Riposte";
MSBTLocale.MSG_TRIGGER_OVERPOWER		= "Surpuissance";


----------------------------------
-- Spell names
----------------------------------

MSBTLocale.SPELL_COLD_SNAP				= "Morsure de glace";
MSBTLocale.SPELL_DRAIN_LIFE				= "Drain de vie";
--MSBTLocale.SPELL_EVOCATION			= "Evocation";
MSBTLocale.SPELL_INNERVATE				= "Innervation";
MSBTLocale.SPELL_MANA_SPRING			= "Fontaine de mana";
MSBTLocale.SPELL_PREPARATION			= "Pr\195\169paration";
MSBTLocale.SPELL_READINESS				= "Promptitude";
--MSBTLocale.SPELL_REFLECTIVE_SHIELD	= "Reflective Shield";			-- Needs Translation.
--MSBTLocale.SPELL_SHADOWMEND			= "Shadowmend";					-- Needs Translation.
MSBTLocale.SPELL_SHADOW_TRANCE			= "Transe de l'ombre";
MSBTLocale.SPELL_SIPHON_LIFE			= "Siphon de vie";
MSBTLocale.SPELL_SPIRIT_TAP				= "Connexion spirituelle";
MSBTLocale.SPELL_VAMPIRIC_EMBRACE		= "Etreinte vampirique";
MSBTLocale.SPELL_VAMPIRIC_TOUCH			= "Toucher vampirique";