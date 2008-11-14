local L = AceLibrary("AceLocale-2.2"):new("SpamSentry");

L:RegisterTranslations("deDE", function() return {
  -- Channel names
  ["whisper"] = "flüstern",
  ["say"] = "sagen",
  ["yell"] = "schreien",
  ["general"] = "allgemein",
  ["trade"] = "handel",
  ["guildrecruitment"] = "gildenrekrutierung",
  ["emote"] = "emote",
  ["lookingforgroup"] = "suchenachgruppe",
  ["localdefense"] = "lokaleverteidigung",
  
  -- Welcome message 
  ["SpamSentry v%s by Anea. Type |cffffffff/sentry|r or right-click the icon for options."] = "SpamSentry v%s von Anea. Gib |cffffffff/sentry|r ein für die Optionen.",
  
  -- Alerts
  ["%s has been added to the SpamSentry feedback list"] = "SpamSentry: %s hinzugefügt.",
  ["* Alert: %s tried to send you %s (%s). Click %s to report."] = "* Warnung: %s hat versucht dir %s zu schicken (%s). Klick %s an, um sie einem GM zu melden.",
  ["this message"] = "diese Mitteilung",
  ["One or more characters are on the reportlist. Click %s to report them to a GM."] = "Einer oder mehrere Spammer wurden geblockt. Klick %s an, um sie einem GM zu melden.",
  ["here"] = "hier",
  ["Player already removed from game by a GM"] = "Spieler wurde bereits aus dem Spiel von einem GM entfernt.",
  ["No messages from %s in cache"] = "Keine Mitteilung von %s gespeichert.",
  
  -- Button in mailframe
  ["|cffdd0000Spam|r"] = "|cffdd0000Spam|r",
  
  -- Button in popup menu
  ["|cffdd0000Report Spam|r"] = "|cffdd0000Spam melden|r",
  ["Add the last message from this player to the SpamSentry reportlist"] = "Fügt die letzte Mitteilung dieses Spielers zur SpamSentry Ticketliste hinzu.",
  ["|cffff8833Report Name|r"] = "|cffff8833Name melden|r",
  ["Add this player to the SpamSentry naming violation reportlist"] = "Fügt den Namen dieses Spielers zur SpamSentry Namenticketliste hinzu.",
  
  -- Tooltip
  ["Click to submit ticket"] = "Klicken um ein Ticket zu verschicken.",
  ["on reportlist"] = "Meldeliste:",
  ["total blocked"] = "Blockiert (insgesamt):",

  -- Options:
  ["options"] = "Optionen",
  ["setup this mod to your needs"] = "Die Einstellungen von Spam Sentry ändern.",
  ["FuBar options"] = "FuBar Optionen",
  ["set the FuBar options"] = "Die Einstellungen von FuBar ändern.",

  -- Options: List
  ["bot"] = "Bot",
  ["manage or add bots"] = "Markierte Spieler auflisten.",
  ["spam"] = "Spam",
  ["manage blocked spam messages"] = "Blockierten Spam verwalten.",
  ["naming"] = "Namen",
  ["manage or add players that violated naming rules"] = "verwalten oder hinzufügen von Namen, die die Namensbestimmungen verletzen.",
  ["add"] = "Hinzufügen",
  ["add a character to the reportlist"] = "Spieler als Bot makieren.",
  ["remove"] = "Entfernen",
  ["removes the specified character from the list"] = "Den markierten Spieler entfernen.",
  ["character"] = "Spieler",
  ["clear"] = "Löschen",
  ["empties the report list"] = "Die Meldeliste löschen.",
  ["list"] = "Auflisten",
  ["lists all reported characters"] = "Alle gemeldeten Spieler auflisten.",
  ["report"] = "Melden",
  ["report the characters to a GM"] = "Die oder den Spieler an einen GM melden.",

  -- Options: Channels
  ["channel"] = "Chatkanäle",
  ["check the channels you want the addon to monitor"] = "Markiere die Chatkanäle die kontrolliert werden sollen.",

  -- Options: Counters
  ["counters"] = "Spamzähler",
  ["set which counters you would like to see on FuBar/Titan"] = "Justiere welchen Spamzähler du in der FuBar/Tianleiste du angezeigt haben möchtest.",
    
  ["bottext"] = "Bottext",
  ["set the text for the bot ticket"] = "Den Text für das Bot-Ticket einstellen.",
  ["spamtext"] = "Spamtext",
  ["set the text for the spam ticket"] = "Den Text für das Spam-Ticket einstellen.",
  ["naming text"] = "Namentext",
  ["set the text for the naming ticket"] = "Den Text für das Namen-Ticket einstellen.",

  -- Options: Language
  ["language"] = "Sprache",
  ["set the language of the ticket text"] = "Die Sprache für das GM-Ticket auswählen.",

  -- Options: Notification
  ["notification"] = "Benachrichtigung",
  ["set what notifications you would like to see"] = "Die Benachrichtigungseinstellungen ändern.",
  ["message"] = "Mitteilung",
  ["show a warning when a message is blocked"] = "Du wirst jedes mal eine Warnung erhalten, wenn eine Mitteilung geblockt wurde.",
  ["hourly"] = "Stündlich",
  ["show an hourly reminder when messages are waiting to be reported"] = "Du wirst stündlich eine Warnung erhalten.",
  ["debug"] = "Fehlersuchen",
  ["show debug messages"] = "Zeige Fehlermeldungen.",
  
  --Options: Delay
  ["delay"] = "Verzögerung",
  ["toggle the delaying of suspicious messages, to stop multi-message spams from showing"] = "Aktiviere eine Verzögerung bei Spam Mitteilungen, damit Nachrichten die mehrfach gespammt wurden nur einmal angezeigt werden.",
  
  -- Options: Autoclear reportlist
  ["autoclear"] = "Auto Löschen",
  ["automatically clear the reportlist on login"] = "Automatisch die Meldeliste löschen beim Login.",

  -- Options: Ignore party invites
  ["ignore party invite"] = "Ignoriere Gruppeneinladungen",
  ["ignore party invites from people you don't know"] = "Ignoriere Gruppeneinladungen von Spielern die du nicht kennst.",
  ["Player unknown, party invite cancelled"] = "Spieler unbekannt, Gruppeneinladung wurde zurrückgewiesen!",

  --Options: Feedback
  ["feedback"] = "Rückmeldung",
  ["FEEDBACK_DESC"] = "Benutze diese Option um einen Report zu erstellen, wenn eine Spammitteilung nicht automatisch erkannt wurde. Der Report kann dem Mod-Autor übermittelt werden.",

  -- Options: Ignore by level
  ["ignore by level"] = "Ignoriere nach Level",
  ["hide whispers from characters below the set level"] = "Verstecke Nachrichten von Spielern unter dem eingestellten Level.",
  
  -- Tickets: No reply
  ["[NO REPLY NEEDED]\n"] = "[KEINE ANTWORT BENÖTIGT]\n",
    
} end )

function L:LocalisedBlackList()
  return nil
end