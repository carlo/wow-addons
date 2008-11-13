local L = AceLibrary("AceLocale-2.2"):new("SpamSentry");

L:RegisterTranslations("esES", function() return {
  -- Channel names
  ["whisper"] = "susurrar",
  ["say"] = "decir",
  ["yell"] = "gritar",
  ["general"] = "comercio",
  ["trade"] = "general",
  ["guildrecruitment"] = "buscandohermandad",
  
  -- Welcome message 
  ["SpamSentry v%s by Anea. Type |cffffffff/sentry|r or right-click the icon for options."] = "SpamSentry v%sde Anea. Escribe |cffffffff/sentry|r para las opciones.",
  
  -- Alerts
  ["%s has been added to the feedback list"] = "%s a\195\177adido",
  ["* Alert: %s tried to send you %s (%s). Click %s to report."] = "* Alerta: %s ha intentado enviarte %s (%s). Pulsa %s para informar de ello a un MJ.",
  ["this message"] = "este mensaje",
  ["One or more characters are on the reportlist. Click %s to report them to a GM."] = "Uno o m\195\161s spammers han sido bloqueados. Pulsa %s para informar de ello a un MJ.",
  ["here"] = "aqu\195\173",
  ["Player already removed from game by a GM"] = "El jugador ya ha sido borrado del juego por un MJ",
  ["No messages from %s in cache"] = "Ning\195\186n mensaje de %s guardado",
  
  -- Button in mailframe
  ["|cffdd0000Spam|r"] = "|cffdd0000Spam|r",
  
  -- Button in popup menu
  ["|cffdd0000Report Spam|r"] = "|cffdd0000Spam|r",
  ["Add the last message from this player to the SpamSentry reportlist"] = "A\195\177ade el \195\186ltimo mensaje de este jugador a la lista de informes de SpamSentry.",
  ["|cffff8833Report Name|r"] = "|cffff8833Nombre|r",
  ["Add this player to the SpamSentry naming violation reportlist"] = "A\195\177ade el nombre de este jugador a la lista de informes de SpamSentry.",
  
  -- Tooltip
  ["Click to submit ticket"] = "Pulsa para enviar un ticket",
  ["on reportlist"] = "en lista de informes",
  ["total blocked"] = "bloqueados en total",

  -- Options:
  ["options"] = "Opciones",
  ["setup this mod to your needs"] = "ajusta este addon a tus necesidades",
  ["FuBar options"] = "opciones de FuBar - Titan",
  ["set the FuBar options"] = "ajusta las opciones de FuBar - Titan",
  
  -- Options: List
  ["bot"] = "bot",
  ["manage or add bots"] = "gestionar o a\195\177adir bots",
  ["spam"] = "spam",
  ["manage blocked spam messages"] = "gestionar mensajes de spam bloqueados",
  ["naming"] = "nombres",
  ["manage or add players that violated naming rules"] = "gestionar o a\195\177adir jugadores que violan la politica de nombres de Rol",
  ["add"] = "A\195\177adir",
  ["add a character to the reportlist"] = "a\195\177adir un personaje a la lista de informes",
  ["remove"] = "Borrar",
  ["removes the specified character from the list"] = "borra el personaje especificado de la lista",
  ["character"] = "personaje",
  ["clear"] = "Limpiar",
  ["empties the report list"] = "vacia la lista de informes",
  ["list"] = "Lista",
  ["lists all reported characters"] = "muestra todos los personajes informados",
  ["report"] = "informar",
  ["report the characters to a GM"] = "informa sobre los personajes a un MJ",

  -- Options: Channels
  ["channel"] = "canales",
  ["check the channels you want the addon to monitor"] = "selecciona los canales que quieres a\195\177adir al monitor",

  -- Options: Counters
  ["counters"] = "contadores",
  ["set which counters you would like to see on FuBar/Titan"] = "selecciona que contadores quieres ver en FuBar/Titan",
    
  ["bottext"] = "bottext",
  ["set the text for the bot ticket"] = "ajusta el texto para el ticket sobre bots",
  ["spamtext"] = "spamtext",
  ["set the text for the spam ticket"] = "ajusta el texto para el ticket sobre spam",
  ["naming text"] = "naming text",
  ["set the text for the naming ticket"] = "ajusta el texto para el ticket sobre nombres",
  
  -- Options: Language
  ["language"] = "idioma",
  ["set the language of the ticket text"] = "selecciona el idioma para el texto del ticket",

  -- Options: Notification
  ["notification"] = "notificar",
  ["set what notifications you would like to see"] = "ajusta que notificaciones quieres ver",
  ["message"] = "mensaje",
  ["show a warning when a message is blocked"] = "muestra una alerta cuando un mensaje sea bloqueado",
  ["hourly"] = "horaria",
  ["show an hourly reminder when messages are waiting to be reported"] = "muestra una alerta cada hora cuando los mensajes esperan ser reportados",
  ["debug"] = "debug",
  ["show debug messages"] = "mostrar mensajes de debug",
  
  --Options: Delay
  ["delay"] = "retraso",
  ["toggle the delaying of suspicious messages, to stop multi-message spams from showing"] = "ajusta el retraso de mensajes sospechosos, para evitar que se muestren los multi-mensajes",
  
  -- Options: Autoclear reportlist
  ["autoclear"] = "autolimpieza",
  ["automatically clear the reportlist on login"] = "borra la lista de informes de forma autom\195\161tica al iniciar sesion",

  -- Options: Ignore party invites
  ["ignore party invite"] = "ignore party invite",
  ["ignore party invites from people you don't know"] = "ignore party invites from people you don't know",
  ["Player unknown, party invite cancelled"] = "Player unknown, party invite cancelled",

  --Options: Feedback
  ["feedback"] = "feedback",
  ["FEEDBACK_DESC"] = "Utiliza esta opcion para generar un informe cuando un mensaje de spam no sea detectado. El informe puede ser enviado al autor del mod.",

  -- Options: Ignore by level
  ["ignore by level"] = "ignorar por nivel",
  ["hide whispers from characters below the set level"] = "oculta susurros de personajes inferiores al nivel fijado",
  
  -- Tickets: No reply
  ["[NO REPLY NEEDED]\n"] = "[NO ES NECESARIO CONTACTAR CONMIGO]\n",
  
} end )

function L:LocalisedBlackList()
  return nil
end