local L = AceLibrary("AceLocale-2.2"):new("SS_Report")

L:RegisterTranslations("deDE", function() return {
  -- Messages
  ["Blocked messages:"] = "Blockierte Mitteilung(en):",
  ["No blocked messages"] = "Keine blockierte Mitteilung(en)",
  ["%s has been removed"] = "%s entfernt.",
  ["Reportlist cleared (%s items)"] = "Die Ticketliste wurde gel\195\182scht. (%s Mitteilung(en))",
  ["You already have a ticket pending"] = "Noch offene Tickets...",
  ["Nothing to report"] = "Niemand zum Melden",
  ["Farming:"] = "Farmer:",
  
  -- Edit ticket text
  ["Edit the text for your ticket"] = "Editiere den Text f\195\r das Ticket",
  
  --GUI
  ["SSGUIHELP"] = "|cffff0000Anmerkung: Pr\195\188fe genau nach, bevor du jemanden meldest!|r",
  ["SSGUITICKETHELP"] = "Copy this text and paste it into your ticket.",
  ["SSGUIHELP_EDITTICKETTEXT"] = "Editiere den Tickettext. '%s' wird durch Deinen Namen ersetzt.",
  ["SSGUIHELP_FEEDBACK"] = "Kopiere die Meldungen und sende sie an den Author.",
  ["[Items on reportlist: %s]"] = "[Items on reportlist: %s]",
  ["Message:"] = "Message:",

  --GUI tooltip
  ["Date / time"] = "Date / time",
  ["Channel"] = "Channel",
  ["Message-ID"] = "Message-ID",
  ["Click to copy message\n<CTRL>-Click to remove message"] = "Click to copy message\n<CTRL>-Click to remove message",

  -- No reply
  ["[NO REPLY NEEDED]"] = "[KEINE ANTWORT BEN\195\150TIGT]",
} end )

-- Ticket texts: Virtually impossible to do this using dynamic translations
SPAMSENTRY_BOTTEXT_deDE =  "Lieber GM,\n\nDie Art wie dieser Charakter sich verhalten und bewegt hat kam mir automatisiert vor. Deshalb w\195\188rde ich diesen Spieler gerne als Bot melden.\n\nMit freundlichen Gr\195\188\195\159en,\n\n%s\n---\n"
SPAMSENTRY_RPTEXT_deDE =   "Lieber GM,\n\nDie folgenden Charaktere haben einen Namen der die Namensbestimmungen verletzt. Ich hoffe das sie den Fall untersuchen werden und angemessene Ma\195\159nahmen ergreifen werden.\n\Mit freundlichen Gr\195\188\195\159en,\n\n%s\n---\n"
