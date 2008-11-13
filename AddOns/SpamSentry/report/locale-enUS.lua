local L = AceLibrary("AceLocale-2.2"):new("SS_Report")
L:EnableDebugging()

L:RegisterTranslations("enUS", function() return {
  -- Messages
  ["Blocked messages:"] = true,
  ["No blocked messages"] = true,
  ["%s has been removed"] = true,
  ["Reportlist cleared (%s items)"] = true,
  ["You already have a ticket pending"] = true,
  ["Nothing to report"] = true,
  ["Farming:"] = true,
  
  -- Edit ticket text
  ["Edit the text for your ticket"] = true,
  
  --GUI
  ["SSGUIHELP"] = "|cffff0000Note: Double check characters before reporting them!|r",
  ["SSGUITICKETHELP"] = "Copy this text and paste it into your ticket.",
  ["SSGUIHELP_EDITTICKETTEXT"] = "Edit ticket text. '%s' will be replaced with your name.",
  ["SSGUIHELP_FEEDBACK"] = "Copy this sequence and submit it to the mod-author.",
  ["[Items on reportlist: %s]"] = true,
  ["Message:"] = true,
  
  --GUI tooltip
  ["Date / time"] = true,
  ["Channel"] = true,
  ["Message-ID"] = true,
  ["Click to copy message\n<CTRL>-Click to remove message"] = true,
  
  -- No reply
  ["[NO REPLY NEEDED]"] = true,
} end )

-- Ticket texts: Virtually impossible to do this using dynamic translations
SPAMSENTRY_BOTTEXT_enUS =  "Dear GM,\n\nThe way the following characters acted and moved appeared to be automated/scripted. Therefore I would like to report them as a bot.\n\nBest regards,\n\n%s\n---\n"
SPAMSENTRY_RPTEXT_enUS =  "Dear GM,\n\nThe following character(s) have a name that violates the naming policy. I hope you will investigate the matter and take appropriate action.\n\nBest regards,\n\n%s\n---\n"
