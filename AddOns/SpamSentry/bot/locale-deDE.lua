local L = AceLibrary("AceLocale-2.2"):new("SS_Bot")

L:RegisterTranslations("deDE", function() return {
  -- Bot message
  ["%s has been added to the reportlist"] = "%s wurde zu der Reportliste hinzugefügt.",
  ["Type a name or select a player to mark as bot"] = "Gib den Namen ein oder wähle den Spieler an der ein Bot ist.",
  ["Type a name or select the mob this bot is farming"] = "Gib einen Namen ein oder wähle einen Mob den dieser Bot farmt",
  ["farming:"] = "Farmer:",
  ["%s has been reported before"] = "%s wurde bereits als Bot gemeldet.",
  ["%s has been removed"] = "%s entfernt.",
  ["Reportlist cleared (%s items)"] = "Die Ticketliste wurde gelöscht. (%s Mitteilungen)",
  ["Marked bots"] = "Blockierte Bot(s)",
  ["No marked bots"] = "Niemand zum Melden",
} end )