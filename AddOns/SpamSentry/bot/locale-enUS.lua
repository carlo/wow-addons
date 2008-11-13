local L = AceLibrary("AceLocale-2.2"):new("SS_Bot")
L:EnableDebugging()

L:RegisterTranslations("enUS", function() return {
  -- Bot message
  ["%s has been added to the reportlist"] = true,
  ["Type a name or select a player to mark as bot"] = true,
  ["Type a name or select the mob this bot is farming"] = true,
  ["farming:"] = true,
  ["%s has been reported before"] = true,
  ["%s has been removed"] = true,
  ["Reportlist cleared (%s items)"] = true,
  ["Marked bots"] = true,
  ["No marked bots"] = true,
} end )