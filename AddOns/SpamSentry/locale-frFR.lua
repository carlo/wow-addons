local L = AceLibrary("AceLocale-2.2"):new("SpamSentry");

L:RegisterTranslations("frFR", function() return {
  -- Channel names
  ["whisper"] = "chuchoter",
  ["say"] = "dire",
  ["yell"] = "crier",
  ["general"] = "commerce",
  ["trade"] = "g\195\169n\195\169ral",
  ["guildrecruitment"] = "recrutementdeguilde",
  
  -- Welcome message 
  ["SpamSentry v%s by Anea. Type |cffffffff/sentry|r or right-click the icon for options."] = "SpamSentry v%s par Anea. Tapez |cffffffff/sentry|r pour les options",
  
  -- Alerts
  ["%s has been added to the feedback list"] = "Le message de %s \195\160 \195\169t\195\169 ajout\195\169 au rapport.",
  ["* Alert: %s tried to send you %s (%s). Click %s to report."] = "Alerte: %s essaye de vous envoyer %s (%s). Cliquez|r %s |cffff9977pour envoyer un rapport.",
  ["this message"] = "ce message",
  ["One or more characters are on the reportlist. Click %s to report them to a GM."] = "Un ou plusieurs spammers ont \195\169t\195\169 bloqu\195\169s. Cliquez|r %s |cffff9977pour envoyer un rapport \195\160 un MJ.",
  ["here"] = "ici",
  ["Player already removed from game by a GM"] = "Ce joueur \195\160 d\195\169j\195\160 \195\169t\195\169 enlev\195\169 du jeu par un MJ",
  ["No messages from %s in cache"] = "Le message de %s ne peux pas \195\170tre ajout\195\169 au rapport (erreur de cache).",
  
  -- Button in mailframe
  ["|cffdd0000Spam|r"] = "|cffdd0000Spam|r",
  
  -- Button in popup menu
  ["|cffdd0000Report Spam|r"] = "|cffdd0000Rapporter un Spam|r",
  ["Add the last message from this player to the SpamSentry reportlist"] = "Ajouter le dernier message de ce joueur \195\160 la liste de SpamSentry",
  ["|cffff8833Report Name|r"] = "|cffff8833Rapporter un Nom|r",
  ["Add this player to the SpamSentry naming violation reportlist"] = "Ajouter le nom de ce joueur \195\160 la liste de SpamSentry",
  
  -- Tooltip
  ["Click to submit ticket"] = "Cliquez pour envoyer un rapport \195\160 un MJ",
  ["on reportlist"] = "Liste des rapports:",
  ["total blocked"] = "Bloqu\195\169 (total):",

  -- Options:
  ["options"] = "Options",
  ["setup this mod to your needs"] = "Changer les r\195\169glages de SpamSentry",
  ["FuBar options"] = "Options de FuBar",
  ["set the FuBar options"] = "Changer les r\195\169glages de FuBar",

  -- Options: List
  ["bot"] = "Robot",
  ["manage or add bots"] = "G\195\168re les joueurs signal\195\169s en tant que robot",
  ["spam"] = "Spam",
  ["manage blocked spam messages"] = "G\195\168re les messages de spam bloqu\195\169s",
  ["naming"] = "Jeu de r\195\180le",
  ["manage or add players that violated naming rules"] = "G\195\168re les joueurs qui ne resp\195\168ctent pas les r\195\168gles du Jeu de r\195\180le",
  ["add"] = "Ajouter",
  ["add a character to the reportlist"] = "Signaler ce joueur en tant que robot",
  ["remove"] = "Enlever",
  ["removes the specified character from the list"] = "Enlever l'option choisie",
  ["character"] = "joueur",
  ["clear"] = "Nettoyer",
  ["empties the report list"] = "Nettoyer la liste de rapport",
  ["list"] = "Liste",
  ["lists all reported characters"] = "Liste des joueurs rapport\195\169s",
  ["report"] = "Rapport",
  ["report the characters to a GM"] = "Rapporter les joueurs rapport\195\169s \195\160 un MJ",

  -- Options: Channels
  ["channel"] = "Cannaux",
  ["check the channels you want the addon to monitor"] = "V\195\169rifier les canaux \195\160 surveiller",

  -- Options: Counters
  ["counters"] = "counters",
  ["set which counters you would like to see on FuBar/Titan"] = "set which counters you would like to see on FuBar/Titan",

  -- Options: Ticket texts    
  ["bottext"] = "Message pour les robots",
  ["set the text for the bot ticket"] = "Editer le message pour les rapports sur les robots",
  ["spamtext"] = "Message pour les spams",
  ["set the text for the spam ticket"] = "Editer le message pour les rapports de spam",
  ["naming text"] = "Message pour le Jeu de r\195\180le",
  ["set the text for the naming ticket"] = "Editer le message pour les rapports sur le non respect des r\195\168gles de Jeu de r\195\180le",

  -- Options: Language
  ["language"] = "Langue",
  ["set the language of the ticket text"] = "Changer la langue du rapport aux MJ",

  -- Options: Notification
  ["notification"] = "Notification",
  ["set what notifications you would like to see"] = "Options de notification",
  ["message"] = "message",
  ["show a warning when a message is blocked"] = "Vous recevrez un avertissement chaque fois qu'un message sera bloqu\195\169.",
  ["hourly"] = "heure",
  ["show an hourly reminder when messages are waiting to be reported"] = "Vous recevrez un rappel horaire.",
  ["debug"] = "debug",
  ["show debug messages"] = "voir les messegaes du debug",
  
  --Options: Delay
  ["delay"] = "d\195\169lais",
  ["toggle the delaying of suspicious messages, to stop multi-message spams from showing"] = "D\195\169sactiver les messages instantan\195\169s.",

  -- Options: Autoclear reportlist
  ["autoclear"] = "vider la liste automatiquement",
  ["automatically clear the reportlist on login"] = "Nettoyer la liste de rapport automatiquement \195\160 chaque connexion",

  -- Options: Ignore party invites
  ["ignore party invite"] = "ignore party invite",
  ["ignore party invites from people you don't know"] = "ignore party invites from people you don't know",
  ["Player unknown, party invite cancelled"] = "Player unknown, party invite cancelled",

  --Options: Feedback
  ["feedback"] = "feedback",
  ["FEEDBACK_DESC"] = "Utilisez cette fonction pour faire un rapport quand un spam n'a pas \195\169t\195\169 automatiquement d\195\169tect\195\169. Le rapport peut alors \195\170tre soumis \195\160 l'auteur du mod.",

  -- Options: Ignore by level
  ["ignore by level"] = "ignore by level",
  ["hide whispers from characters below the set level"] = "hide whispers from characters below the set level",

  -- Tickets: No reply
  ["[NO REPLY NEEDED]\n"] = "[VEUILLEZ NE PAS R\195\137PONDRE]\n",
  
} end )

function L:LocalisedBlackList()
  return nil
end