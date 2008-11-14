local L = AceLibrary("AceLocale-2.2"):new("SS_Report")

L:RegisterTranslations("deDE", function() return {
  -- Messages
  ["Blocked messages:"] = "Blockierte Mitteilung(en):",
  ["No blocked messages"] = "Keine blockierte Mitteilung(en)",
  ["%s has been removed"] = "%s entfernt.",
  ["Reportlist cleared (%s items)"] = "Die Ticketliste wurde gelöscht. (%s Mitteilung(en))",
  ["You already have a ticket pending"] = "Du hast noch offene Tickets...",
  ["Nothing to report"] = "Niemand zum Melden",
  ["Farming:"] = "Farmer:",
  
  -- Edit ticket text
  ["Edit the text for your ticket"] = "Editiere den Text für das Ticket",
  
  --GUI
  ["SSGUIHELP"] = "|cffff0000Anmerkung: Prüfe genau nach, bevor du jemanden meldest!|r",
  ["SSGUITICKETHELP"] = "Kopiere diesen Taxt und füge Ihn in dein Tiket ein.",
  ["SSGUIHELP_EDITTICKETTEXT"] = "Editiere den Tickettext. '%s' wird durch Deinen Namen ersetzt.",
  ["SSGUIHELP_FEEDBACK"] = "Kopiere die Meldungen und sende sie an den Author.",
  ["[Items on reportlist: %s]"] = "[Gegenstände in der Reportliste: %s]",
  ["Message:"] = "Nachricht:",

  --GUI tooltip
  ["Date / time"] = "Datum / Zeit",
  ["Channel"] = "Kanal",
  ["Message-ID"] = "Nachrichten-ID",
  ["Click to copy message\n<CTRL>-Click to remove message"] = "Klicken um die Nachricht zu kopieren.\n<STRG>-Klick um die Nachricht zu entfernen.",

  -- No reply
  ["[NO REPLY NEEDED]"] = "[KEINE ANTWORT BENÖTIGT]",
} end )

-- Ticket texts: Virtually impossible to do this using dynamic translations
SPAMSENTRY_BOTTEXT_deDE =  "Lieber GM,\n\nDie Art wie dieser Charakter sich verhalten und bewegt hat kam mir automatisiert vor. Deshalb würde ich diesen Spieler gerne als Bot melden.\n\nMit freundlichen Grüßen,\n\n%s\n---\n"
SPAMSENTRY_RPTEXT_deDE =   "Lieber GM,\n\nDie folgenden Charaktere haben einen Namen der die Namensbestimmungen verletzt. Ich hoffe das sie den Fall untersuchen werden und angemessene Maßnahmen ergreifen werden.\n\Mit freundlichen Grüßen,\n\n%s\n---\n"
