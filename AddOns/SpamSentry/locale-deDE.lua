local L = AceLibrary("AceLocale-2.2"):new("SpamSentry");

L:RegisterTranslations("deDE", function() return {
  -- Channel names
  ["whisper"] = "fl\195\188stern",
  ["say"] = "sagen",
  ["yell"] = "schreien",
  ["general"] = "allgemein",
  ["trade"] = "handel",
  ["guildrecruitment"] = "gildenrekrutierung",
  
  -- Welcome message 
  ["SpamSentry v%s by Anea. Type |cffffffff/sentry|r or right-click the icon for options."] = "SpamSentry v%s von Anea. Gib |cffffffff/sentry|r ein f\195\188r Optionen.",
  
  -- Alerts
  ["%s has been added to the feedback list"] = "%s hinzugef\195\188gt.",
  ["* Alert: %s tried to send you %s (%s). Click %s to report."] = "* Warnung: %s hat versucht dir %s zu schicken (%s). Klick %s an, um sie einem GM zu melden.",
  ["this message"] = "diese Mitteilung",
  ["One or more characters are on the reportlist. Click %s to report them to a GM."] = "Einer oder mehrere Spammer wurden geblockt. Klick %s an, um sie einem GM zu melden.",
  ["here"] = "hier",
  ["Player already removed from game by a GM"] = "Spieler wurde bereits aus dem Spiel von einem GM entfernt",
  ["No messages from %s in cache"] = "Keine Mitteilung von %s gespeichert.",
  
  -- Button in mailframe
  ["|cffdd0000Spam|r"] = "|cffdd0000Spam|r",
  
  -- Button in popup menu
  ["|cffdd0000Report Spam|r"] = "|cffdd0000Spam melden|r",
  ["Add the last message from this player to the SpamSentry reportlist"] = "F\195\188gt die letzte Mitteilung dieses Spielers zur SpamSentry Ticketliste hinzu.",
  ["|cffff8833Report Name|r"] = "|cffff8833Name melden|r",
  ["Add this player to the SpamSentry naming violation reportlist"] = "F\195\188gt die Name dieses Spielers zur SpamSentry Namenticketliste hinzu.",
  
  -- Tooltip
  ["Click to submit ticket"] = "Klicken um ein Ticket zu schicken",
  ["on reportlist"] = "Meldeliste:",
  ["total blocked"] = "Blockiert (insgesamt):",

  -- Options:
  ["options"] = "Optionen",
  ["setup this mod to your needs"] = "Die Einstellungen von Spam Sentry \195\164ndern",
  ["FuBar options"] = "FuBar options",
  ["set the FuBar options"] = "Die Einstellungen von FuBar \195\164ndern",

  -- Options: List
  ["bot"] = "Bot",
  ["manage or add bots"] = "Markierte Spieler auflisten",
  ["spam"] = "Spam",
  ["manage blocked spam messages"] = "Blockierten Spam verwalten",
  ["naming"] = "Namen",
  ["manage or add players that violated naming rules"] = "verwalten oder hinzufügen von Namen, die die Namensbestimmungen verlertzen.",
  ["add"] = "Hinzuf\195\188gen",
  ["add a character to the reportlist"] = "Spieler als Bot makieren",
  ["remove"] = "Entfernen",
  ["removes the specified character from the list"] = "Den markierten Spieler entfernen",
  ["character"] = "Spieler",
  ["clear"] = "l\195\182schen",
  ["empties the report list"] = "Die Meldeliste l\195\182schen",
  ["list"] = "Auflisten",
  ["lists all reported characters"] = "Spieler auflisten",
  ["report"] = "Melden",
  ["report the characters to a GM"] = "Die oder den Spieler an einen GM melden",

  -- Options: Channels
  ["channel"] = "Chatkan\195\164le",
  ["check the channels you want the addon to monitor"] = "Kontrollierte Chatkan\195\164le angeben",

  -- Options: Counters
  ["counters"] = "counters",
  ["set which counters you would like to see on FuBar/Titan"] = "set which counters you would like to see on FuBar/Titan",
    
  ["bottext"] = "Bottext",
  ["set the text for the bot ticket"] = "Den Text f\195\188r das Bot-Ticket einstellen",
  ["spamtext"] = "Spamtext",
  ["set the text for the spam ticket"] = "Den Text f\195\188r das Spam-Ticket einstellen",
  ["naming text"] = "Namentext",
  ["set the text for the naming ticket"] = "Den Text f\195\188r das Namen-Ticket einstellen",

  -- Options: Language
  ["language"] = "Sprache",
  ["set the language of the ticket text"] = "Die Sprache f\195\188r das GM-Ticket einstellen",

  -- Options: Notification
  ["notification"] = "Benachrichtigung",
  ["set what notifications you would like to see"] = "Die Benachrichtigungseinstellungen \195\164ndern",
  ["message"] = "Mitteilung",
  ["show a warning when a message is blocked"] = "Du wirst jedes mal eine Warnung erhalten, wenn eine Mitteilung geblockt wurde.",
  ["hourly"] = "st\195\188ndlich",
  ["show an hourly reminder when messages are waiting to be reported"] = "Du wirst st\195\188ndlich eine Warnung erhalten.",
  ["debug"] = "Fehlersuchen",
  ["show debug messages"] = "Zeige Fehlermeldungen",
  
  --Options: Delay
  ["delay"] = "Verz\195\182gerung",
  ["toggle the delaying of suspicious messages, to stop multi-message spams from showing"] = "Die Verz\195\182gerung von Mitteilungen umschalten.",
  
  -- Options: Autoclear reportlist
  ["autoclear"] = "auto l\195\182schen",
  ["automatically clear the reportlist on login"] = "Automatisch die Meldeliste l\195\182schen am login",

  -- Options: Ignore party invites
  ["ignore party invite"] = "ignore party invite",
  ["ignore party invites from people you don't know"] = "ignore party invites from people you don't know",
  ["Player unknown, party invite cancelled"] = "Player unknown, party invite cancelled",

  --Options: Feedback
  ["feedback"] = "R\195\188ckmeldung",
  ["FEEDBACK_DESC"] = "Benutze diese Option um einen Report zu erstellen, wenn eine Spammitteilungnicht automatisch erkannt wurde. Der Report kann dem Mod-Autor \195\188bermittelt werden.",

  -- Options: Ignore by level
  ["ignore by level"] = "ignore by level",
  ["hide whispers from characters below the set level"] = "hide whispers from characters below the set level",
  
  -- Tickets: No reply
  ["[NO REPLY NEEDED]\n"] = "[KEINE ANTWORT BEN\195\150TIGT]\n",
    
} end )

function L:LocalisedBlackList()
  return nil
end