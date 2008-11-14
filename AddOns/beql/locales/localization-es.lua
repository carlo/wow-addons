--[[
	Spanish Local :  NeKRoMaNT - contacto@nekromant.com
	$Date: 2008-11-09 13:00:00 +0100 $
]]
local L = AceLibrary("AceLocale-2.2"):new("beql")
L:RegisterTranslations("esES", function() return{

	["Bayi's Extended Quest Log"] = "Registro de Misiones Extendido de Bayi",
	["No Objectives!"] = "Sin Objetivos",
	["(Done)"] = "(Hecho)",
	["Click to open Quest Log"] = "Haz click para abrir el Registro de Misiones",
	["Completed!"] = "Completada!",
	[" |cffff0000Disabled by|r"] = " |cffff0000Desactivado por|r",
	["Reload UI ?"] = "Recargar Interfaz ?",	
	["FubarPlugin Config"] = "Configuraci\195\179n FubarPlugin",
	["Requires Interface Reload"] = "Requiere recargar el interfaz",	
	
	["Quest Log Options"] = "Opciones de Registro de Misiones",
	["Options related to the Quest Log"] = "Opciones relacionadas con el Registro de Misiones",
	["Lock Quest Log"] = "Bloquear Registro de Misiones",
	["Makes the quest log unmovable"] = "Impide que pueda moverse el Registro de Misiones",
	["Always Open Minimized"] = "Siempre abrir minimizado",	
	["Force the quest log to open minimized"] = "Fuerza el registro de misiones para abrirse siempre minimizado",
	["Always Open Maximized"] = "Siempre abrir maximizado",
	["Force the quest log to open maximized"] = "Fuerza el registro de misiones para abrirse siempre maximizado",
	["Show Quest Level"] = "Mostrar nivel de misi\195\179n",
	["Shows the quests level"] = "Mostrar el nivel de las misiones",
	["Info on Quest Completion"] = "Informa al completar misi\195\179n",
	["Shows a message and plays a sound when you complete a quest"] = "Muestra un mensaje y reproduce un sonido cuando completas una misi\195\179n",
	["Auto Complete Quest"] = "Autocompletar Misi\195\179n",
	["Automatically Complete Quests"] = "Completa las misiones autom\195\161ticamente",	
	["Mob Tooltip Quest Info"] = "Informaci\195\179n Misi\195\179n en Tooltip de Monstruo",
	["Show quest info in mob tooltips"] = "Muestra informaci\195\179n sobre la misi\195\179n en los cuadros de datos de los monstruos",
	["Item Tooltip Quest Info"] = "Informaci\195\179n Misi\195\179n en Tooltip de Objeto",
	["Show quest info in item tooltips"] = "Muestra informaci\195\179n sobre la misi\195\179n en los cuadros de datos de los objetos",
	["Simple Quest Log"] = "Registro de Misiones Simple",
	["Uses the default Blizzard Quest Log"] = "Utiliza el registro de misiones por defecto de Blizzard",	
	["Quest Log Alpha"] = "Transparencia Registro Misiones",
	["Sets the Alpha of the Quest Log"] = "Ajusta la transparencia del registro de misiones",

	["Quest Tracker"] = "Rastreador de Misiones",
	["Quest Tracker Options"] = "Opciones del rastreador de misiones",
	["Options related to the Quest Tracker"] = "Opciones relacionadas con el rastreador de misiones",
	["Lock Tracker"] = "Bloquear Rastreador",
	["Makes the quest tracker unmovable"] = "Impide que pueda moverse el rastreador de misiones",	
	["Show Tracker Header"] = "Mostrar cabecera del rastreador",
	["Shows the trackers header"] = "Muestra la cabecera del rastreador",
	["Hide Completed Objectives"] = "Ocultar Objetivos Completados",
	["Automatical hide completed objectives in tracker"] = "Ocultar autom\195\161ticamente los objetivos completados en el rastreador",	
	["Remove Completed Quests"] = "Borrar Misiones Completadas",
	["Automatical remove completed quests from tracker"] = "Borrar autom\195\161ticamente las misiones completadas del rastreador",	
	["Font Size"] = "Tama\195\177o de Fuente",
	["Changes the font size of the tracker"] = "Cambia el tama\195\177o de la fuente del rastreador",
	["Sort Tracker Quests"] = "Ordena Misiones del Rastreador",
	["Sort the quests in tracker"] = "Ordena las misiones en el rastreador",	
	["Show Quest Zones"] = "Mostrar Zonas",
	["Show the quests zone it belongs to above its name"] = "Muestra la zona de la misi\195\179n a la que pertenece sobre su nombre",
	["Add New Quests"] = "A\195\177ade Nuevas Misiones",
	["Automatical add new Quests to tracker"] = "A\195\177ade nuevas misiones autom\195\161ticamente al rastreador",
	["Add Untracked"] = "A\195\177ade No Rastreadas",
	["Automatical add quests with updated objectives to tracker"] = "A\195\177ade autom\195\161ticamente las misiones con objetivos actualizados al rastreador",	
	["Reset tracker position"] = "Resetear Posici\195\179n Rastreador",	
	["Active Tracker"] = "Rastreador Activo",
	["Showing on mouseover tooltips, clicking opens the tracker, rightclicking removes the quest from tracker"] = "Muestra el tooltip al pasar el rat\195\179n por encima, haciendo click abre el rastreador, bot\195\179n derecho elimina la misi\195\179n del rastreador",
	["Hide Objectives for Completed only"] = "Oculta Objetivos S\195\179lo Completadas",
	["Hide objectives only for completed quests"] = "Oculta los objetivos s\195\179lo para las misiones completadas",
	
	["Markers"] = "Marcadores",
	["Customize the Objective/Quest Markers"] = "Personaliza los marcadores del objetivo/misi\195\179n",
	["Show Objective Markers"] = "Muestra Marcadores Objetivo",
	["Display Markers before objectives"] = "Muestra los marcadores antes de los objetivos",
	["Use Listing"] = "Utilizar Listado",
	["User Listing rather than symbols"] = "Utiliza un listado en vez de los s\195\173mbolos",
	["List Type"] = "Tipo de Listado",
	["Set the type of listing"] = "Ajusta el tipo de listado",
	["Symbol Type"] = "Tipo de S\195\173mbolo",
	["Set the type of symbol"] = "Ajusta el tipo de s\195\173mbolo",

	["Colors"] = "Colores",
	["Set tracker Colors"] = "Ajusta los colores del rastreador",
	["Background"] = "Fondo",
	["Use Background"] = "Utilizar fondo",
	["Custom Background Color"] = "Color de Fondo Personalizado",
	["Use custom color for background"] = "Utiliza un color personalizado para el fondo",
	["Background Color"] = "Color de Fondo",
	["Sets the Background Color"] = "Ajusta el color de fondo",
	["Background Corner Color"] = "Color de Fondo de Bordes",
	["Sets the Background Corner Color"] = "Ajusta el color de fondo de los bordes",	
	["Use Quest Level Colors"] = "Utilizar Colores de Nivel en Misiones",
	["Use the colors to indicate quest difficulty"] = "Utiliza los colores para indicar la dificultad de la misi\195\179n",	
	["Custom Zone Color"] = "Color de Zona Personalizado",
	["Use custom color for Zone names"] = "Utiliza un color personalizado para los nombres de zona",
	["Zone Color"] = "Color de zona",
	["Sets the zone color"] = "Ajusta el color de zona",	
	["Fade Colors"] = "Colores Atenuados",
	["Fade the objective colors"] = "Aten\195\186a los colores del objetivo",
	["Custom Objective Color"] = "Color de Objetivo Personalizado",
	["Use custom color for objective text"] = "Utiliza un color personalizado para el texto de objetivo",	
	["Objective Color"] = "Color de Objetivo",
	["Sets the color for objectives"] = "Ajusta el color para los objetivos",	
	["Completed Objective Color"] = "Color Objetivo Completado",
	["Sets the color for completed objectives"] = "Ajusta el color para los objetivos completados",	
	["Custom Header Color"] = "Color Cabecera Personalizado",
	["Use custom color for headers"] = "Utiliza un color personalizado para las cabeceras",
	["Completed Header Color"] = "Color Cabecera Completada",
	["Sets the color for completed headers"] = "Ajusta el color para las cabeceras completadas",
	["Header Color"] = "Color Cabecera",
	["Sets the color for headers"] = "Ajusta el color para las cabeceras",
	["Disable Tracker"] = "Desactiva Rastreador",
	["Disable the Tracker"] = "Desactiva el rastreador",
	["Quest Tracker Alpha"] = "Transparencia Rastreador",
	["Sets the Alpha of the Quest Tracker"] = "Ajusta la transparencia del rastreador de misiones",
	["Auto Resize Tracker"] = "Cambiar tama\195\177o del rastreador autom\195\161ticamente",
	["Automatical resizes the tracker depending on the lenght of the text in it"] = "Cambia el tama\195\177o del rastreador de forma autom\195\161tica dependiendo de la longitud del texto",
	["Fixed Tracker Width"] = "Ancho Fijo del Rastreador",
	["Sets the fixed width of the tracker if auto resize is disabled"] = "Ajusta el ancho fijo del rastreador si el cambio de tama\195\177o autom\195\161tico est\195\161 desactivado",		
	
	["Pick Locale"] = "Selecciona Idioma",
	["Change Locale (needs Interface Reload)"] = "Cambiar idioma (necesita recargar el interfaz)",
	
	["|cffffffffQuests|r"] = "|cffffffffMisiones|r",
	["|cffff8000Tracked Quests|r"] = "|cffff8000Misiones|r Supervisadas",
	["|cff00d000Completed Quests|r"] = "|cff00d000Misiones|r Completadas",
	["|cffeda55fClick|r to open Quest Log and |cffeda55fShift+Click|r to open Waterfall config"] = "|cffeda55fHaz click|r para abrir el registro de misiones y |cffeda55fhaz click + mays|r para abrir la configuraci\195\179n de Waterfall",
	
	["Tooltip"] = "Tooltip",
	["Tooltip Options"] = "Opciones de Tooltip",
	["Tracker Tooltip"] = "Tooltip de Rastreador",
	["Showing mouseover tooltips in tracker"] = "Mostrar tooltip en rastreador al pasar el rat\195\179n",
	["Quest Description in Tracker Tooltip"] = "Descripci\195\179n de misi\195\179n en tooltip de rastreador",
	["Displays the actual quest's description in the tracker tooltip"] = "Mostrar la descripci\195\179n actual de la misi\195\179n en el tooltip del rastreador",
	["Party Quest Progression info"] = "Informaci\195\179n del progreso de la misi\195\179n del grupo",
	["Displays Party members quest status in the tooltip - Quixote must be installed on the partymembers client"] = "Muestra el estado de la misi\195\179n de los miembros del grupo en el tooltip - Quixote debe estar instalado en cada miembro del grupo",
	["Enable Left Click"] = "Activar Click Izquierdo",
	["Left clicking a quest in the tracker opens the Quest Log"] = "Al hacer click izquierdo en una misi\195\179n en el rastreador se abre el registro de misiones",
	["Enable Right Click"] = "Activar Click Derecho",
	["Right clicking a quest in the tracker removes it from the tracker"] = "Al hacer click derecho en una misi\195\179n en el rastreador se borra del rastreador",
	["Quest Log Scale"] = "Escala del Registro de Misiones",
	["Sets the Scale of the Quest Log"] = "Ajusta la escala del Registro de Misiones",
	["Force Tracker Unlock"] = "Fuerza la desactivaci\195\179n del rastreador",
	["Make the Tracker movable even with CTMod loaded. Please check your CTMod config before using it"] = "Hace posible el movimiento del rastreador incluso con CTMod cargado. Por favor, revisa tu configuraci\195\179n de CTMod antes de usarlo",	
	["Quest Progression to Party Chat"] = "Mostrar progreso de misiones al chat del grupo",
	["Prints the Quest Progression Status to the Party Chat"] = "Muestra el progreso de la misi\195\179n al chat del grupo",		
	["Completion Sound"] = "Sonido de misi\195\179n completada",
	["Select the sound to be played when a quest is completed"] = "Selecciona el sonido que se reproduce cuando una misi\195\179n se completa",
	
	["Quest Description Color"] = "Color Descripci\195\179n Misi\195\179n",
	["Sets the color for the Quest description"] = "Ajusta el color para la descripci\195\179n de la misi\195\179n",
	["Party Member Color"] = "Color Miembro Grupo",
	["Party Member with Quixote Color"] = "Color Miembro Grupo con Quixote instalado",
	["Sets the color for Party member"] = "Ajusta el color para el miembro del grupo",
	
-- new with 3.0
	["Main Options"] = "Opciones Principales",
	["Enable Addon"] = "Activar Addon",
	["Enable this Addon"] = "Activar este Addon",
	["General Quest Log Options"] = "Opciones Generales del Registro de Misiones",
	["No sound"] = "Sin Sonido",
	["Don't play a sound"] = "No reproducir un sonido",
    ["Watch Options"] = "Opciones de Revisi\195\179n",
    ["Zones"] = "Zonas",
    ["NPC color"] = "Color del PNJ",
    ["Title color"] = "Color del T\195\173tulo",

-- Fubar
    ["Show icon"] = "Mostrar icono",
    ["Show the plugins icon on the panel."] = "Mostrar el icono del plugin en el panel",
    ["Show text"] = "Mostrar texto",
    ["Show the plugins text on the panel."] = "Mostrar el texto del plugin en el panel",
    ["Show colored text"] = "Mostrar texto con colores",
    ["Allow the plugin to color its text."] = "Permitir al plugin colorear su texto",
    ["Detach tooltip"] = "Quitar tooltip",
    ["Detach the tooltip from the panel."] = "Quitar el tooltip del panel",
    ["Lock tooltip"] = "Bloquear tooltip",
    ["Lock the tooltips position. When the tooltip is locked, you must use Alt to access it with your mouse."] = "Bloquea la posici\195\179n del tooltip. Cuando el tooltip se bloquea, puedes usar Alt para acceder a \195\169l con tu rat\195\179n.",
    ["Position"] = "Posici\195\179n",
    ["Position the plugin on the panel."] = "Posici\195\179n del plugin en el panel",
    ["Left"] = "Izquierda",
    ["Right"] = "Derecha",
    ["Center"] = "Centro",
    ["Attach to minimap"] = "Adjuntar al minimapa",
    ["Attach the plugin to the minimap instead of the panel."] = "Adjuntar el plugin al minimapa en lugar de al panel",
    ["Hide plugin"] = "Ocultar plugin",
    ["Hidden"] = "Oculto",
    ["Hide the plugin from the panel or minimap, leaving the addon running."] = "Ocultar el plugin del panel o minimapa, dejando funcionando el addon",
    ["Other"] = "Otro/a",
    ["Close"] = "Cerrar",
    ["Close the menu."] = "Cierra el men\195\186",
    ["Minimap position"] = "Posici\195\179n Minimapa",
    
    ["Profiles"] = "Perfiles",
	

--[[ new with 3.0.3

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

if GetLocale() == "esES" then

BINDING_HEADER_beqlTITLE = "bEQL"
BINDING_NAME_TrackerToggle = "Mostrar/Ocultar Rastreador"

BEQL_COMPLETE = "%(Completada%)"
BEQL_QUEST_ACCEPTED = "Misi\195\179n Aceptada:"

end
