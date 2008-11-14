local L = AceLibrary("AceLocale-2.2"):new("beql")
L:RegisterTranslations("huHU", function() return{

	["Bayi's Extended Quest Log"] = "Bayi B\195\181vitett K\195\188ldet\195\169s Napl\195\179ja",
	["No Objectives!"] = "Nincsenek C\195\169lkit\195\187z\195\169sek",
	["(Done)"] = "(K\195\169sz)",
	["Click to open Quest Log"] = "Klikkelj a K\195\188ldet\195\169s Nap\195\178 megnyit\195\161s\195\161h\195\178z",
	["Completed!"] = "K\195\169sz!",
	[" |cffff0000Disabled by|r"] = " |cffff0000Letiltva: |r",
	["Reload UI ?"] = "GUI Ujrat\195\182lt\195\169se ?",
	["FubarPlugin Config"] = "FubarPlugin Be\195\161llit\195\161s",
	["Requires Interface Reload"] = "A GUI Ujrat\195\182lt\195\169se sz\195\188ks\195\169ges",	
	
	["Quest Log Options"] = "K\195\188ldet\195\169s napl\195\178 be\195\161llit\195\161sok",
	["Options related to the Quest Log"] = "Be\195\161llit\195\161sok a k\195\188ldet\195\169s napl\195\178val kapcsolatban",
	["Lock Quest Log"] = "K\195\188ldet\195\169s napl\195\178 fix\195\161l\195\161sa",
	["Makes the quest log unmovable"] = "A K\195\188ldet\195\169s napl\195\178t nem lehet mozgatni",
	["Always Open Minimized"] = "Mindig kicsinyitve",	
	["Force the quest log to open minimized"] = "A K\195\188ldet\195\169s napl\195\178 mindig kicsinyitve jelenik meg",
	["Always Open Maximized"] = "Mindig maximiz\195\161lva",
	["Force the quest log to open maximized"] = "A K\195\188ldet\195\169s napl\195\178 mindig maximiz\195\161lva jelenik meg",
	["Show Quest Level"] = "K\195\188ldet\195\169s szint mutat\195\161sa",
	["Shows the quests level"] = "A K\195\188ldet\195\169sek mellett mutatja a javasolt szintet",
	["Info on Quest Completion"] = "\195\156zenet megjelenit\195\169se k\195\188ldet\195\169s befejez\195\169sekor",
	["Shows a message and plays a sound when you complete a quest"] = "Kiirja az \195\169ppen befejezett k\195\188ldet\195\169s nev\195\169t es lej\195\161tszik egy hangot",
	["Auto Complete Quest"] = "K\195\188ldet\195\169s automatikus lead\195\161sa",
	["Automatically Complete Quests"] = "Automatikusan leadja a k\195\188ldet\195\169st az NPCn\195\169l",	
	["Mob Tooltip Quest Info"] = "K\195\188ldet\195\169s inform\195\161ci\195\178k a Mobok tooltipj\195\169ben",
	["Show quest info in mob tooltips"] = "Az \195\169ppen aktu\195\161lis k\195\188ldet\195\169shez tartoz\195\178 mob tooltipj\195\169ben mutatja a k\195\188ldet\195\169s inform\195\161ci\195\178it",
	["Item Tooltip Quest Info"] = "K\195\188ldet\195\169s inform\195\161ci\195\178k a t\195\161rgyak tooltipj\195\169ben",
	["Show quest info in item tooltips"] = "Az \195\169ppen aktu\195\161lis k\195\188ldet\195\169shez tartoz\195\178 t\195\161rgyak tooltipj\195\169ben mutatja a k\195\188ldet\195\169s inform\195\161ci\195\178it",
	["Simple Quest Log"] = "Egyszer\195\187 K\195\188ldet\195\169s napl\195\178",
	["Uses the default Blizzard Quest Log"] = "Az alap Blizzard K\195\188ldet\195\169s napl\195\178 haszn\195\161lata",	
	["Quest Log Alpha"] = "K\195\188ldet\195\169s Napl\195\178 Alfa csatorna",
	["Sets the Alpha of the Quest Log"] = "Be\195\161llitja a K\195\188ldet\195\169s napl\195\178 alfa csatorn\195\161j\195\161t",	
	
	["Quest Tracker"] = "K\195\188ldet\195\169s figyel\195\181",
	["Quest Tracker Options"] = "K\195\188ldet\195\169s figyel\195\181 be\195\161llit\195\161sai",
	["Options related to the Quest Tracker"] = "Be\195\161llit\195\161sok a K\195\188ldet\195\169s figyel\195\181vel kapcsolatban",
	["Lock Tracker"] = "Figyel\195\181 fix\195\161l\195\161sa",
	["Makes the quest tracker unmovable"] = "A Figyel\195\181 mozg\195\161s\195\161nak enged\195\169lyez\195\169se/tilt\195\161sa",	
	["Show Tracker Header"] = "Figyel\195\181 Cimsor",
	["Shows the trackers header"] = "Enged\195\169lyezi a Figyel\195\181 Cimsor\195\161t",
	["Hide Completed Objectives"] = "K\195\169sz c\195\169lkit\195\187z\195\169sek elrejt\195\169se",
	["Automatical hide completed objectives in tracker"] = "Elrejti a befejezett k\195\188ldet\195\169s c\195\169lkit\195\187z\195\169seket a figyel\195\181b\195\182l",	
	["Remove Completed Quests"] = "K\195\169sz k\195\188ldet\195\169sek elrejt\195\169se",
	["Automatical remove completed quests from tracker"] = "Elrejti a befejezett k\195\188ldet\195\169seket a figyel\195\181b\195\182l",	
	["Font Size"] = "Bet\195\187m\195\169ret",
	["Changes the font size of the tracker"] = "Megv\195\161ltoztatja a figyel\195\187 bet\195\187tipus\195\161nak m\195\169ret\195\169t",
	["Sort Tracker Quests"] = "Figyel\195\181 kuldet\195\169seinek rendez\195\169se",
	["Sort the quests in tracker"] = "Sorba rendezi a k\195\188ldet\195\169seket a figyel\195\181ben",	
	["Show Quest Zones"] = "K\195\188ldet\195\169s Zon\195\161k mutat\195\161sa",
	["Show the quests zone it belongs to above its name"] = "Mutatja a k\195\188ldet\195\169sek hozz\195\161tartoz\195\178 zon\195\161it",
	["Add New Quests"] = "Uj K\195\188ldet\195\169sek felv\195\169tele",
	["Automatical add new Quests to tracker"] = "Automatikusan felveszi az ujonnan felvett k\195\188ldet\195\169seket a figyel\195\181be",
	["Add Untracked"] = "Nem figyelt k\195\188ldet\195\169sek felv\195\169tele",
	["Automatical add quests with updated objectives to tracker"] = "Automatikusan felveszi a nem figyelt, de \195\169ppen folyamatban l\195\169v\195\181 k\195\188ldet\195\169seket a figyel\195\181be",	
	["Reset tracker position"] = "Figyel\195\181 ujrapozicion\195\161l\195\161sa",
	["Active Tracker"] = "Aktiv Figyel\195\181",
	["Showing on mouseover tooltips, clicking opens the tracker, rightclicking removes the quest from tracker"] = "Az \195\169g\195\169r haszn\195\161latot enged\195\169lyezi a figyel\195\181ben, illetve a k\195\188ldet\195\169sekhez inform\195\161ci\195\186kat jelenit meg ha az eg\195\169rrel ramutatunk a nev\195\169re",	
	
	["Markers"] = "Jelz\195\181k",
	["Customize the Objective/Quest Markers"] = "A figyel\195\181ben haszn\195\161lt k\195\188ldet\195\169s jel\195\182l\195\169sek testreszab\195\161sa",
	["Show Objective Markers"] = "Mutasd a c\195\169lkit\195\187z\195\169sek jel\195\182l\195\169seit",
	["Display Markers before objectives"] = "A k\195\188ldet\195\169sek c\195\169lkit\195\187z\195\169sei el\195\181tti jel\195\182l\195\169sek/sorsz\195\161mok megjelenit\195\169se",
	["Use Listing"] = "Felsorol\195\161s haszn\195\161lata",
	["User Listing rather than symbols"] = "Sorsz\195\161moz\195\161s haszn\195\161lata szimbolumok helyett",
	["List Type"] = "Felsorol\195\161s tipus",
	["Set the type of listing"] = "V\195\161lassz tipust",
	["Symbol Type"] = "Szimbolum tipus",
	["Set the type of symbol"] = "V\195\161lassz tipust",

	["Colors"] = "Szinek",
	["Set tracker Colors"] = "A Figyel\195\181 szineinek be\195\161llit\195\161sa",
	["Background"] = "H\195\161tt\195\169r",
	["Use Background"] = "H\195\161tt\195\169r mutat\195\161sa",
	["Custom Background Color"] = "Egy\195\169ni h\195\161tt\195\169rszin",
	["Use custom color for background"] = "Egy\195\169ni h\195\161tt\195\169rszin haszn\195\161lata",
	["Background Color"] = "H\195\161tt\195\169rszin",
	["Sets the Background Color"] = "Be\195\161llitja a h\195\161tt\195\169r szin\195\169t",
	["Background Corner Color"] = "H\195\161tt\195\169r-keret szin",
	["Sets the Background Corner Color"] = "Egyedi h\195\161tt\195\169r-keret szin haszn\195\161lata",	
	["Use Quest Level Colors"] = "K\195\188ldet\195\169s szin szint szerint",
	["Use the colors to indicate quest difficulty"] = "A k\195\188ldet\195\169seket a szinthez igazitva szinezi",	
	["Custom Zone Color"] = "Egy\195\169ni Zona szin",
	["Use custom color for Zone names"] = "Egy\195\169ni Zona szin haszn\195\161lata",
	["Zone Color"] = "Zona szin",
	["Sets the zone color"] = "Egy\195\169ni Zona szin be\195\161llit\195\161sa",
	["Fade Colors"] = "Szin \195\161tmenetek",
	["Fade the objective colors"] = "A c\195\169lkit\195\187z\195\169sek szineinek folyamatos \195\161tmenete a nem megkezdett\195\181l a befejezettig",
	["Custom Objective Color"] = "Egy\195\169ni c\195\169lkit\195\187z\195\169s szin",
	["Use custom color for objective text"] = "Egy\195\169ni szin haszn\195\161lata a c\195\169lkit\195\187z\195\169sekhez",	
	["Objective Color"] = "C\195\169lkit\195\187z\195\169s szin",
	["Sets the color for objectives"] = "C\195\169lkit\195\187z\195\169s szin\195\169nek megv\195\161laszt\195\161sa",	
	["Completed Objective Color"] = "Befejezett c\195\169lkit\195\187z\195\169s szin",
	["Sets the color for completed objectives"] = "Befejezett c\195\169lkit\195\187z\195\169se szin\195\169nek megv\195\161laszt\195\161sa",	
	["Custom Header Color"] = "Egy\195\169ni k\195\188ldet\195\169s szin",
	["Use custom color for headers"] = "Haszn\195\161lj egy\195\169ni szineket a k\195\188ldet\195\169sek nev\195\169ben",
	["Completed Header Color"] = "Befejezett k\195\188ldet\195\169s szine",
	["Sets the color for completed headers"] = "Befejezett k\195\188ldet\195\169s szin\195\169nek be\195\161llit\195\161sa",
	["Header Color"] = "K\195\188ldet\195\169s szine",
	["Sets the color for headers"] = "K\195\188ldet\195\169s szin\195\169nek be\195\161llit\195\161sa",
	["Disable Tracker"] = "Figyel\195\181 kikapcsol\195\161sa",
	["Disable the Tracker"] = "Az addon be\195\169pitett figyel\195\181j\195\169nek kikapcsol\195\161sa",
	["Quest Tracker Alpha"] = "Figyel\195\181 alfa csatorna",
	["Sets the Alpha of the Quest Tracker"] = "Be\195\161llitja a figyel\195\181 alfa csatorn\195\161j\195\161t",
	["Auto Resize Tracker"] = "Automata M\195\169retez\195\169s",
	["Automatical resizes the tracker depending on the lenght of the text in it"] = "Automat\195\161n m\195\169retezi a Figyel\195\181 sz\195\169less\195\169g\195\169t",
	["Fixed Tracker Width"] = "Fix sz\195\169less\195\169g",
	["Sets the fixed width of the tracker if auto resize is disabled"] = "Be\195\161llitja a fix sz\195\169less\195\169get ha az automata m\195\169retez\195\169s ki van kapcsolva",	
	
	["Pick Locale"] = "Nyelv",
	["Change Locale (needs Interface Reload)"] = "Nyelv megv\195\161ltoztat\195\161sa (GUI Ujrat\195\182lt\195\169st ig\195\169nyel)",

	["|cffffffffQuests|r"] = "|cffffffffK\195\188ldet\195\169sek|r",
	["|cffff8000Tracked Quests|r"] = "|cffff8000Figyelt K\195\188ldet\195\169sek|r",
	["|cff00d000Completed Quests|r"] = "|cff00d000Befejezett K\195\188ldet\195\169sek|r",
	["|cffeda55fClick|r to open Quest Log and |cffeda55fShift+Click|r to open Waterfall config"] = "|cffeda55fKlikkelj|r a K\195\188ldet\195\169s Napl\195\178 megnyit\195\161s\195\161hoz vagyd |cffeda55fShift+Klikkelj|r a Waterfall be\195\161llit\195\161s el\195\181hoz\195\161s\195\161hoz",	
	
	["Tooltip"] = "Tooltip",
	["Tooltip Options"] = "Tooltip Be\195\161lit\195\161sok",
	["Tracker Tooltip"] = "Figyel\195\181 Tooltip",
	["Showing mouseover tooltips in tracker"] = "Az eg\195\169r alatti tooltipek megjelenti\195\169se a Figyel\195\181ben",
	["Quest Description in Tracker Tooltip"] = "K\195\188ldet\195\169s leir\195\161sa a tooltipben",
	["Displays the actual quest's description in the tracker tooltip"] = "Az aktu\195\161lis k\195\188ldet\195\169s r\195\182vid leir\195\161s\195\161nak megjelenit\195\169se a tooltipben",
	["Party Quest Progression info"] = "Csapat Kuldet\195\169s St\195\161tusz",
	["Displays Party members quest status in the tooltip - Quixote must be installed on the partymembers client"] = "Mutatja hogy az \195\169ppen aktu\195\161lis k\195\188ldet\195\169ssel hogy \195\161llnak a csapat tagjai a tooltipben",
	["Enable Left Click"] = "Bal klikk enged\195\169lyez\195\169se",
	["Left clicking a quest in the tracker opens the Quest Log"] = "Bal klikk egy k\195\188ldet\195\169sen megnyitja a K\195\188ldet\195\169s napl\195\178t",
	["Enable Right Click"] = "Jobb klikk enged\195\169lyez\195\169se",
	["Right clicking a quest in the tracker removes it from the tracker"] = "Jobb klikk egy k\195\188ldet\195\169sen elt\195\161volitja azt a figyel\195\181b\195\182l",
	["Quest Log Scale"] = "K\195\188ldet\195\169s Napl\195\178 m\195\169rete",
	["Sets the Scale of the Quest Log"] = "Be\195\161llitja a m\195\169ret\195\169t a K\195\188ldet\195\169s Napl\195\178nak",
	["Force Tracker Unlock"] = "Mozgat\195\161s k\195\169nyszerit\195\169se",
	["Make the Tracker movable even with CTMod loaded. Please check your CTMod config before using it"] = "Akkor is enged\195\169lyezi a Figyel\195\181 mozgat\195\161s\195\161t ha a CTMod ill. m\195\161s Mozgat\195\178 addonok be vannak t\195\182ltve. Haszn\195\161lata nem javasolt, k\195\169rlek ellen\195\182rizd a m\195\161sik mozgat\195\178 addon be\195\161llit\195\161sait.",	
	["Quest Progression to Party Chat"] = "K\195\188ldet\195\169s kiir\195\161sa a parti chatbe",
	["Prints the Quest Progression Status to the Party Chat"] = "A K\195\188ldet\195\169ssel val\195\178 halad\195\161s \195\161llom\195\161sait kiirja a parti chatbe",		
	["Completion Sound"] = "Hangok",
	["Select the sound to be played when a quest is completed"] = "Be\195\161llitja hogy milyen hangot jatszon le az addon ha egy k\195\188ldet\195\169s k\195\169sz",	

	["Quest Description Color"] = "K\195\188ldet\195\169s leir\195\161sa szin",
	["Sets the color for the Quest description"] = "Be\195\161llitja a k\195\188ldet\195\169s leir\195\161s\195\161nak a szin\195\169t",
	["Party Member Color"] = "Parti tag szin",
	["Party Member with Quixote Color"] = "Parti tag Quixoteval szin",
	["Sets the color for Party member"] = "Be\195\161llitja a parti tag szin\195\169t",	

--[[ new with 3.0
	["Main Options"] = true, -- translate me!!!
	["Enable Addon"] = true, -- translate me!!!
	["Enable this Addon"] = true, -- translate me!!!
	["General Quest Log Options"] = true, -- translate me!!!
	["No sound"] = true, -- translate me!!!
	["Don't play a sound"] = true, -- translate me!!!
	["Watch Options"] = true, -- translate me!!!
	["Zones"] = true, -- translate me!!!
	["NPC color"] = true, -- translate me!!!
	["Title color"] = true, -- translate me!!!

-- Fubar
	["Show icon"] = true, -- translate me!!!
	["Show the plugins icon on the panel."] = true, -- translate me!!!
	["Show text"] = true, -- translate me!!!
	["Show the plugins text on the panel."] = true, -- translate me!!!
	["Show colored text"] = true, -- translate me!!!
	["Allow the plugin to color its text."] = true, -- translate me!!!
	["Detach tooltip"] = true, -- translate me!!!
	["Detach the tooltip from the panel."] = true, -- translate me!!!
	["Lock tooltip"] = true, -- translate me!!!
	["Lock the tooltips position. When the tooltip is locked, you must use Alt to access it with your mouse."] = true, -- translate me!!!
	["Position"] = true, -- translate me!!!
	["Position the plugin on the panel."] = true, -- translate me!!!
	["Left"] = true, -- translate me!!!
	["Right"] = true, -- translate me!!!
	["Center"] = true, -- translate me!!!
	["Attach to minimap"] = true, -- translate me!!!
	["Attach the plugin to the minimap instead of the panel."] = true, -- translate me!!!
	["Hide plugin"] = true, -- translate me!!!
	["Hidden"] = true, -- translate me!!!
	["Hide the plugin from the panel or minimap, leaving the addon running."] = true, -- translate me!!!
	["Other"] = true, -- translate me!!!
	["Close"] = true, -- translate me!!!
	["Close the menu."] = true, -- translate me!!!
	["Minimap position"] = true, -- translate me!!!

-- Profiles
	["Profiles"] = true, -- translate me!!!
 
-- Achievement Tracker
	["Achievement Tracker"] = true, -- translate me!!!
	["Enable Achievement Tracker"] = true, -- translate me!!!
	["Enables the Achievement Tracker, which can be moved an collapsed."] = true, -- translate me!!!
	["Makes the achievement tracker unmovable"] = true, -- translate me!!!
	["Show Achievement Tracker Header"] = true, -- translate me!!!
	["Shows the header of the Achievementtracker"] = true, -- translate me!!!
	["Save tracked Achievement"] = true, -- translate me!!!
	["Save last tracked Achievement and resore it after login"] = true, -- translate me!!!
	["Remove Completed Achievement"] = true, -- translate me!!!
	["Automatical remove the completed Achievement from tracker"] = true, -- translate me!!!
	["Achievement Tracker Alpha"] = true, -- translate me!!!
	["Sets the Alpha of the Achievement Tracker"] = true, -- translate me!!!
	["Achievement Tracker Scale"] = true, -- translate me!!!
	["Sets the Scale of the Achievement Tracker"] = true, -- translate me!!!
--]]
-- Profiles
	ace2profile_default = "Default", -- translate me!!!
	ace2profile_intro = "You can change the active database profile, so you can have different settings for every character.", -- translate me!!!
	ace2profile_reset_desc = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over.", -- translate me!!!
	ace2profile_reset = "Reset Profile", -- translate me!!!
	ace2profile_reset_sub = "Reset the current profile to the default", -- translate me!!!
	ace2profile_choose_desc = "You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles.", -- translate me!!!
	ace2profile_new = "New", -- translate me!!!
	ace2profile_new_sub = "Create a new empty profile.", -- translate me!!!
	ace2profile_choose = "Existing Profiles", -- translate me!!!
	ace2profile_choose_sub = "Select one of your currently available profiles.", -- translate me!!!
	ace2profile_copy_desc = "Copy the settings from one existing profile into the currently active profile.", -- translate me!!!
	ace2profile_copy = "Copy From", -- translate me!!!
	ace2profile_delete_desc = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file.", -- translate me!!!
	ace2profile_delete = "Delete a Profile", -- translate me!!!
	ace2profile_delete_sub = "Deletes a profile from the database.", -- translate me!!!
	ace2profile_delete_confirm = "Are you sure you want to delete the selected profile?", -- translate me!!!
	ace2profile_profiles = "Profiles", -- translate me!!!
	ace2profile_profiles_sub = "Manage Profiles", -- translate me!!!


	} end )

if GetLocale() == "huHU" then

BINDING_HEADER_beqlTITLE = "bEQL"
BINDING_NAME_TrackerToggle = "Figyel\195\181 Megjelenit\195\169se/Elt\195\188ntet\195\169se"

BEQL_COMPLETE = "%(Complete%)"
BEQL_QUEST_ACCEPTED = "Quest accepted:"

end

-- Ingame Strings from globals.lua:


function BEQL_PostTransFunc.huHU()
	-- Abandon Button Text
	QuestLogFrameAbandonButton:SetText("K\195\188ldet\195\169s felad\195\161sa")
	-- Share Quest Button Text
	QuestFramePushQuestButton:SetText("Megoszt\195\161s")
	-- Exit Button Text
	QuestFrameExitButton:SetText("Kil\195\169p\195\169s")
	-- Collapse All Button Text
	QuestLogCollapseAllButton:SetText("\195\150ssz")
	-- Track Quest Button Text
	QuestLogTrackTitle:SetText("K\195\188ldet\195\169s Figyel\195\169se")	
	-- Track Quest Button Tooltip
	QUEST_WATCH_TOOLTIP = "Shift+Klikk egy K\195\188ldet\195\169sre hogy hozz\195\161add/elt\195\161volisd a figyel\195\181b\195\181l"
	-- Quest Log Count Template (Quests: x/y)
	QUEST_LOG_COUNT_TEMPLATE = "K\195\188ldet\195\169sek: |cffffffff%d/%d|r";
end

-- Kulonleges betuk
-- á \195\161
-- é \195\169
-- í \195\173
-- ó \195\178
-- ö \195\182
-- õ \195\181
-- ú \195\186
-- ü \195\188
-- û \195\187
-- Ö \195\150