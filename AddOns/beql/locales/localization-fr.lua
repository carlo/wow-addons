local L = AceLibrary("AceLocale-2.2"):new("beql")

L:RegisterTranslations("frFR", function() return{

	["Bayi's Extended Quest Log"] = "Bayi's Extended Quest Log",
	["No Objectives!"] = "Pas d'objectif",
	["(Done)"] = "(Fait)",
	["Click to open Quest Log"] = "Cliquer pour ouvrir le Journal de Qu\195\170tes",
	["Completed!"] = "Fini!",
	[" |cffff0000Disabled by|r"] = " |cffff0000D\195\169sactiv\195\169 par|r",
	["Reload UI ?"] = "Rechager l'interface ?",
	["FubarPlugin Config"] = "Configuration FubarPlugin",
	["Requires Interface Reload"] = "N\195\169cessite un rechargement de l'interface",
	
	["Quest Log Options"] = "Options du Journal de Qu\195\170tes",
	["Options related to the Quest Log"] = "Options \195\160 propos du Journal de Qu\195\170tes",
	["Lock Quest Log"] = "Verrouiller le Journal de Qu\195\170tes",
	["Makes the quest log unmovable"] = "Rendre le Journal de Qu\195\170tes imbougeable",
	["Always Open Minimized"] = "Toujours ouvrir minimis\195\169",	
	["Force the quest log to open minimized"] = "Forcer le Journal de Qu\195\170tes \195\160 s'ouvrir minimis\195\169",
	["Always Open Maximized"] = "Toujours ouvrir maximis\195\169",
	["Force the quest log to open maximized"] = "Forcer le Journal de Qu\195\170tes \195\160 s'ouvrir maximis\195\169",
	["Show Quest Level"] = "Voir le niveau des qu\195\170tes",
	["Shows the quests level"] = "Voir le niveau des qu\195\170tes",
	["Info on Quest Completion"] = "Infos sur les objectifs de qu\195\170te",
	["Shows a message and plays a sound when you complete a quest"] = "Voir un message et jouer un son quand vous completez une qu\195\170te",
	["Auto Complete Quest"] = "Validation automatique",
	["Automatically Complete Quests"] = "Valide automatiquement les qu\195\170tes",	
	["Mob Tooltip Quest Info"] = "Tooltips d'info sur les mobs",
	["Show quest info in mob tooltips"] = "Montre les infos des qu\195\170tes sur le tooltip des monstres",
	["Item Tooltip Quest Info"] = "Tooltips d'info sur les objets",
	["Show quest info in item tooltips"] = "Montre les infos des qu\195\170tes sur le tooltip des objets",
	["Simple Quest Log"] = "Journal de Qu\195\170tes simple",
	["Uses the default Blizzard Quest Log"] = "Utiliser le Journal de Qu\195\170tes",
	["Quest Log Alpha"] = "Transparence du Journal de Qu\195\170tes",
	["Sets the Alpha of the Quest Log"] = "Change la transparence du Journal de Qu\195\170tes",

	["Quest Tracker"] = "Suivi des qu\195\170tes",
	["Quest Tracker Options"] = "Options du suivi des qu\195\170tes",
	["Options related to the Quest Tracker"] = "Options du suivi des qu\195\170tes",
	["Lock Tracker"] = "Verrouiller le suivi",
	["Makes the quest tracker unmovable"] = "Rendre le suivi des qu\195\170tes imbougeable",	
	["Show Tracker Header"] = "Voir le titre du suivi",
	["Shows the trackers header"] = "Voir le titre du suivi",
	["Hide Completed Objectives"] = "Cacher les objectifs termin\195\169s",
	["Automatical hide completed objectives in tracker"] = "Cacher automatiquement les objectifs termin\195\169s dans le suivi",	
	["Remove Completed Quests"] = "Enlever les qu\195\170tes termin\195\169es",
	["Automatical remove completed quests from tracker"] = "Enlever automatiquement les qu\195\170tes termin\195\169es du suivi",	
	["Font Size"] = "Taille de la police",
	["Changes the font size of the tracker"] = "Change la taille de la police du suivi",
	["Sort Tracker Quests"] = "Classer les qu\195\170tes",
	["Sort the quests in tracker"] = "Classer les qu\195\170tes dans le suivi",	
	["Show Quest Zones"] = "Montrer les r\195\169gions",
	["Show the quests zone it belongs to above its name"] = "Montrer les r\195\169gions des qu\195\170tes",
	["Add New Quests"] = "Ajout des nouvelles qu\195\170tes",
	["Automatical add new Quests to tracker"] = "Ajouter automatiquement les nouvelles qu\195\170tes",
	["Add Untracked"] = "Ajout non-suivi",
	["Automatical add quests with updated objectives to tracker"] = "Ajouter automatiquement les qu\195\170tes non suivies quand un objectif est modifi\195\169",	
	["Reset tracker position"] = "R\195\169initialiser la position du suivi",
	["Active Tracker"] = "Suivi actif",
	["Showing on mouseover tooltips, clicking opens the tracker, rightclicking removes the quest from tracker"] = "Showing on mouseover tooltips, clicking opens the tracker, rightclicking removes the quest from tracker",
	["Hide Objectives for Completed only"] = "Cacher les objectifs complets uniquement",
	["Hide objectives only for completed quests"] = "Cacher les objectifs uniquement pour les qu\195\170tes termin\195\169es",
	
	["Markers"] = "Symboles",
	["Customize the Objective/Quest Markers"] = "Changer les symboles des objectifs/qu\195\170tes",
	["Show Objective Markers"] = "Montrer les symboles des objectifs",
	["Display Markers before objectives"] = "Affiche un symbole devant les objectifs",
	["Use Listing"] = "Utiliser une liste",
	["User Listing rather than symbols"] = "Utilise une liste plut\195\180t que des symboles",
	["List Type"] = "Types de listes",
	["Set the type of listing"] = "Change le type de la liste",
	["Symbol Type"] = "Types de symboles",
	["Set the type of symbol"] = "Change le type de symbole",

	["Colors"] = "Couleurs",
	["Set tracker Colors"] = "Change les couleurs du suivi",
	["Background"] = "Fond",
	["Use Background"] = "Ajouter un fond",
	["Custom Background Color"] = "Couleur de fond personnalis\195\169",
	["Use custom color for background"] = "Utiliser une couleur personnalis\195\169e pour le fond",
	["Background Color"] = "Couleur de fond",
	["Sets the Background Color"] = "Change la couleur de fond",
	["Background Corner Color"] = "Couleur du bord",
	["Sets the Background Corner Color"] = "Change la couleur de la bordure",	
	["Use Quest Level Colors"] = "Utiliser la couleur de niveau des qu\195\170tes",
	["Use the colors to indicate quest difficulty"] = "Utiliser la couleur de niveau de la qu\195\170te pour montrer la difficult\195\169",	
	["Custom Zone Color"] = "Couleur de r\195\169gions personnalis\195\169e",
	["Use custom color for Zone names"] = "Utiliser la couleur personnalis\195\169e pour les r\195\169gions",
	["Zone Color"] = "Couleur des r\195\169gions",
	["Sets the zone color"] = "Change la couleur des r\195\169gions",	
	["Fade Colors"] = "Fondu des couleurs",
	["Fade the objective colors"] = "Cr\195\169e un fondu sur les couleurs des objectifs",
	["Custom Objective Color"] = "Couleur personnalis\195\169e des objectifs",
	["Use custom color for objective text"] = "Utiliser la couleur personnalis\195\169e pour les textes des objectifs",	
	["Objective Color"] = "Couleur des objectifs",
	["Sets the color for objectives"] = "Change la couleur des objectifs",
	["Completed Objective Color"] = "Couleur objectifs termin\195\169s",
	["Sets the color for completed objectives"] = "Change la couleur des objectifs termin\195\169s",	
	["Custom Header Color"] = "Couleur personnalis\195\169e des titres",
	["Use custom color for headers"] = "Changer la couleur des titres",
	["Completed Header Color"] = "Couleur qu\195\170te termin\195\169e",
	["Sets the color for completed headers"] = "Change la couleur des titres des qu\195\170tes terminées",
	["Header Color"] = "Couleur de titre",
	["Failed Header Color"] = "Couleur de qu\195\170te rat\195\169",
	["Sets the color for failed quests"] = "Change la couleur des titres des qu\195\170tes rat\195\169es",
	["Sets the color for headers"] = "Change la couleur des titres",
	["Disable Tracker"] = "D\195\169sactiver le suivi",
	["Disable the Tracker"] = "D\195\169sactive le suivi des qu\195\170tes",
	["Quest Tracker Alpha"] = "Transparence du suivi",
	["Sets the Alpha of the Quest Tracker"] = "Change la transparence pour le suivi des qu\195\170tes",
	["Auto Resize Tracker"] = "Auto Resize Tracker",
	["Automatical resizes the tracker depending on the lenght of the text in it"] = "Automatical resizes the tracker depending on the lenght of the text in it",
	["Fixed Tracker Width"] = "Fixed Tracker Width",
	["Sets the fixed width of the tracker if auto resize is disabled"] = "Sets the fixed width of the tracker if auto resize is disabled",	

	["Pick Locale"] = "Choix de la langue",
	["Change Locale (needs Interface Reload)"] = "Change la langue (requiert un rechargement de l'interface)",
	
	["|cffffffffQuests|r"] = "|cffffffffQu\195\170tes|r",
	["|cffff8000Tracked Quests|r"] = "|cffff8000Qu\195\170tes suivies|r",
	["|cff00d000Completed Quests|r"] = "|cff00d000Qu\195\170tes termin\195\169es|r",
	["|cffeda55fClick|r to open Quest Log and |cffeda55fShift+Click|r to open Waterfall config"] = "|cffeda55fCliquer|r pour ouvrir le Journal de Qu195\170tes et |cffeda55fMaj+Clic|r pour ouvrir la configuration",
	
	["Tooltip"] = "Tooltip",
	["Tooltip Options"] = "Tooltip Options",
	["Tracker Tooltip"] = "Tracker Tooltip",
	["Showing mouseover tooltips in tracker"] = "Showing mouseover tooltips in tracker",
	["Quest Description in Tracker Tooltip"] = "Quest Description in Tracker Tooltip",
	["Displays the actual quest's description in the tracker tooltip"] = "Displays the actual quest's description in the tracker tooltip",
	["Party Quest Progression info"] = "Party Quest Progression info",
	["Displays Party members quest status in the tooltip - Quixote must be installed on the partymembers client"] = "Displays Party members quest status in the tooltip - Quixote must be installed on the partymembers client",
	["Enable Left Click"] = "Enable Left Click",
	["Left clicking a quest in the tracker opens the Quest Log"] = "Left clicking a quest in the tracker opens the Quest Log",
	["Enable Right Click"] = "Enable Right Click",
	["Right clicking a quest in the tracker removes it from the tracker"] = "Right clicking a quest in the tracker removes it from the tracker",
	["Quest Log Scale"] = "Quest Log Scale",
	["Sets the Scale of the Quest Log"] = "Sets the Scale of the Quest Log",
	["Force Tracker Unlock"] = "Force Tracker Unlock",
	["Make the Tracker movable even with CTMod loaded. Please check your CTMod config before using it"] = "Make the Tracker movable even with CTMod loaded. Please check your CTMod config before using it",	
	["Quest Progression to Party Chat"] = "Quest Progression to Party Chat",
	["Prints the Quest Progression Status to the Party Chat"] = "Prints the Quest Progression Status to the Party Chat",		
	["Completion Sound"] = "Completion Sound",
	["Select the sound to be played when a quest is completed"] = "Select the sound to be played when a quest is completed",	
	
	["Quest Description Color"] = "Quest Description Color",
	["Sets the color for the Quest description"] = "Sets the color for the Quest description",
	["Party Member Color"] = "Party Member Color",
	["Party Member with Quixote Color"] = "Party Member with Quixote Color",
	["Sets the color for Party member"] = "Sets the color for Party member",	

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

	["ace2profile_default"] = "D\195\169faut",
	["ace2profile_intro"] = "Vous pouvez changer le profil actuel afin d'avoir des param\195\168tres diff\195\169rents pour chaque personnage, permettant ainsi d'avoir une configuration tr\195\168s flexible.",
	["ace2profile_reset_desc"] = "R\195\169initialise le profil actuel au cas o\195\185 votre configuration est corrompue ou si vous voulez tout simplement faire table rase.",
	["ace2profile_reset"] = "R\195\169initialiser le profil",
	["ace2profile_reset_sub"] = "R\195\169initialise le profil actuel avec les param\195\168tres par d\195\169faut.",
	["ace2profile_choose_desc"] = "Vous pouvez cr\195\169er un nouveau profil en entrant un nouveau nom dans la bo\195\174te de saisie, ou en choississant un des profils d\195\169j\195\160 existants.",
	["ace2profile_new"] = "Nouveau",
	["ace2profile_new_sub"] = "Cr\195\169\195\169e un nouveau profil vierge.",
	["ace2profile_choose"] = "Profils existants",
	["ace2profile_choose_sub"] = "Permet de choisir un des profils d\195\169j\195\160 disponibles.",
	["ace2profile_copy_desc"] = "Copie les param\195\168tres d'un profil d\195\169j\195\160 existant dans le profil actuellement actif.",
	["ace2profile_copy"] = "Copier \195\160 partir de",
	["ace2profile_delete_desc"] = "Supprime les profils existants inutilis\195\169s de la base de donn\195\169es afin de gagner de la place et de nettoyer le fichier SavedVariables.",
	["ace2profile_delete"] = "Supprimer un profil",
	["ace2profile_delete_sub"] = "Supprime un profil de la base de donn\195\169es.",
	["ace2profile_delete_confirm"] = "Etes-vous s\195\187r de vouloir supprimer le profil s\195\169lectionn\195\169 ?",
	["ace2profile_profiles"] = "Profils",
	["ace2profile_profiles_sub"] = "Gestion des profils",

} end )

if GetLocale() == "frFR" then

BEQL_COMPLETE = "%(Compl\195\168te%)"
BEQL_QUEST_ACCEPTED = "Qu\195\170te accept\195\169e:"

end
