local L = AceLibrary("AceLocale-2.2"):new("SS_RP")
L:EnableDebugging()

L:RegisterTranslations("enUS", function() return {
  -- RP message
  ["%s has been added to the reportlist"] = true,
  ["Type a name or select a player violating naming rules"] = true,
  ["%s has been reported before"] = true,
  ["%s has been removed"] = true,
  ["Reportlist cleared (%s items)"] = true,
  ["Marked players"] = true,
  ["No marked players"] = true,
} end )