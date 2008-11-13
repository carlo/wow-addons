local L = AceLibrary("AceLocale-2.2"):new("SpamSentry");
L:EnableDebugging()

L:RegisterTranslations("enUS", function() return {
  -- Channel names
  ["whisper"] = true,
  ["say"] = true,
  ["yell"] = true,
  ["general"] = true,
  ["trade"] = true,
  ["guildrecruitment"] = true,
  
  -- Welcome message 
  ["SpamSentry v%s by Anea. Type |cffffffff/sentry|r or right-click the icon for options."] = true,
  
  -- Alerts
  ["%s has been added to the feedback list"] = true,
  ["* Alert: %s tried to send you %s (%s). Click %s to report."] = true,
  ["this message"] = true,
  ["One or more characters are on the reportlist. Click %s to report them to a GM."] = true,
  ["here"] = true,
  ["Player already removed from game by a GM"] = true,
  ["No messages from %s in cache"] = true,
  
  -- Button in mailframe
  ["|cffdd0000Spam|r"] = true,
  
  -- Button in popup menu
  ["|cffdd0000Report Spam|r"] = true,
  ["Add the last message from this player to the SpamSentry reportlist"] = true,
  ["|cffff8833Report Name|r"] = true,
  ["Add this player to the SpamSentry naming violation reportlist"] = true,
  
  -- Tooltip
  ["Click to submit ticket"] = true,
  ["on reportlist"] = true,
  ["total blocked"] = true,

  -- Options:
  ["options"] = true,
  ["setup this mod to your needs"] = true,
  ["FuBar options"] = true,
  ["set the FuBar options"] = true,

  -- Options: List
  ["bot"] = true,
  ["manage or add bots"] = true,
  ["spam"] = true,
  ["manage blocked spam messages"] = true,
  ["naming"] = true,
  ["manage or add players that violated naming rules"] = true,
  ["add"] = true,
  ["add a character to the reportlist"] = true,
  ["remove"] = true,
  ["removes the specified character from the list"] = true,
  ["character"] = true,
  ["clear"] = true,
  ["empties the report list"] = true,
  ["list"] = true,
  ["lists all reported characters"] = true,
  ["report"] = true,
  ["report the characters to a GM"] = true,

  -- Options: Channels
  ["channel"] = true,
  ["check the channels you want the addon to monitor"] = true,
  
  -- Options: Counters
  ["counters"] = true,
  ["set which counters you would like to see on FuBar/Titan"] = true,

  -- Options: Ticket texts    
  ["bottext"] = true,
  ["set the text for the bot ticket"] = true,
  ["spamtext"] = true,
  ["set the text for the spam ticket"] = true,
  ["naming text"] = true,
  ["set the text for the naming ticket"] = true,

  -- Options: Language
  ["language"] = true,
  ["set the language of the ticket text"] = true,
  
  -- Options: Notification
  ["notification"] = true,
  ["set what notifications you would like to see"] = true,
  ["message"] = true,
  ["show a warning when a message is blocked"] = true,
  ["hourly"] = true,
  ["show an hourly reminder when messages are waiting to be reported"] = true,
  ["debug"] = true,
  ["show debug messages"] = true,
  
  -- Options: Delay
  ["delay"] = true,
  ["toggle the delaying of suspicious messages, to stop multi-message spams from showing"] = true,
  
  -- Options: Autoclear reportlist
  ["autoclear"] = true,
  ["automatically clear the reportlist on login"] = true,
  
  -- Options: Ignore party invites
  ["ignore party invite"] = true,
  ["ignore party invites from people you don't know"] = true,
  ["Player unknown, party invite cancelled"] = true,
  
  --Options: Feedback
  ["feedback"] = true,
  ["FEEDBACK_DESC"] = "Use this option to generate a report when a spammessage wasn't automatically detected. The report can then be submitted to the mod-author.",
  
  -- Options: Ignore by level
  ["ignore by level"] = true,
  ["hide whispers from characters below the set level"] = true,
  
  -- Tickets: No reply
  ["[NO REPLY NEEDED]\n"] = true,
  
} end )

function L:LocalisedBlackList()
  return nil
end