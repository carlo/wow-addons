AMP_SEPARATOR = "-----------------------------------"

if (GetLocale() == "enUS") then
	AMP_NOTELLS = "You do not have any missed tells."
	AMP_MSG_HELP = "/amp msg changes your default away message\nSyntax: /amp msg <new away message>"
	AMP_DEFAULT = "Default away message is now: "
	AMP_MISSED1 = "You have "
	AMP_MISSED2 = " missed tells."
	
	AMP_ON = "On"
	AMP_OFF = "Off"
	AMP_AWAY_MSG = "Your away message is: "
	AMP_FRAME_STATUS = "AnswerFrame: "
	AMP_REC_AFK_STATUS = "Record while AFK: "
	AMP_REC_DND_STATUS = "Record while DND: "
	AMP_REC_AFK_HELP = "/amp afk toggles recording while AFK\nSyntax: /amp afk ( on | off )"
	AMP_REC_DND_HELP = "/amp dnd toggles recording while DND\nSyntax: /amp dnd ( on | off )"

end

if (GetLocale() == "frFR") then
	AMP_NOTELLS = "Vous n\'avez rat\195\169 aucun message priv\195\169."
	AMP_MSG_HELP = "/amp msg permet de changer votre message d\'absence\nSyntaxe : /amp msg <Message>"
	AMP_DEFAULT = "Votre message d\'absence est maintenant : "
	AMP_MISSED1 = "Vous avez manqu\195\169 "
	AMP_MISSED2 = " messages."
	
	AMP_ON = "On"
	AMP_OFF = "Off"
	AMP_AWAY_MSG = "Votre message d\'absence est: "
	AMP_FRAME_STATUS = "La fen\195\170tre d\'Answer: "
	AMP_REC_AFK_STATUS = "Enregistrement en ABS: "
	AMP_REC_DND_STATUS = "Enregistrement en NPD: "
	AMP_FRAME_HELP = "/amp frame [ON/OFF] la fen\195\170tre d\'\195\169tat ABS/NPD\nSyntaxe: /amp frame ( on | off )"
	AMP_REC_AFK_HELP = "/amp afk [ON/OFF] Enregistrement en ABS\nSyntaxe: /amp afk ( on | off )"
	AMP_REC_DND_HELP = "/amp dnd [ON/OFF] Enregistrement en NPD\nSyntaxe: /amp dnd ( on | off )"
end

if (GetLocale() == "deDE") then
	AMP_NOTELLS = "Sie haben keine vers\195\164umten Nachrichten."
	AMP_MSG_HELP = "/amp msg <Nachricht> - \195\132ndert die Standard Abwesenheits-Nachricht."
	AMP_DEFAULT = "Standard Abwesenheits-Nachricht ist nun: "
	AMP_MISSED1 = "Sie haben "
	AMP_MISSED2 = " Nachrichten verpasst."
	
	AMP_ON = "On"
	AMP_OFF = "Off"
	AMP_AWAY_MSG = "Your away message is: "
	AMP_FRAME_STATUS = "AnswerFrame: "
	AMP_REC_AFK_STATUS = "Record while AFK: "
	AMP_REC_DND_STATUS = "Record while DND: "
	AMP_REC_AFK_HELP = "/amp afk toggles recording while AFK\nSyntax: /amp afk ( on | off )"
	AMP_REC_DND_HELP = "/amp dnd toggles recording while DND\nSyntax: /amp dnd ( on | off )"
end

-- Need localization for the below.
AMP_MENU = "Answering Machine Plus"
AMP_VERSION = "3.4"
AMP_BG_DISABLED = "Disabled in "
AMP_REC = "Recording: "
AMP_LOADED = " loaded."

-- Combat
AMP_REC_COMBAT_STATUS = "Combat Auto-reply: "
AMP_REC_COMBAT_HELP = "/amp combat - toggles auto-reply while in combat\nSyntax: /amp combat ( on | off )"
AMP_IN_COMBAT_AUTO_MSG = AMP_MENU .. " automated reply. I am currently in combat and may not get your message."

-- AH
AMP_REC_AUCTION_STATUS = "Record Auction House messages: "
AMP_REC_AUCTION_HELP = "/amp auction toggles recording of Auction House messages\nSyntax: /amp auction ( on | off )"
AMP_NOAUCTIONS = "You do not have any missed Auction House messages."
AMP_MISSED3 = " missed Auction House messages."

-- Ignores
AMP_IGNORE_HELP = "/amp ignore - toggles ignore list check during recording\nSyntax:\n/amp ignore ( on | off )\n/amp ignore ( add | remove ) [word]\n/amp ignore list"
AMP_IGNORE_STATUS = "Ignore List: "
AMP_NOIGNORES = "Ignore list is empty."
AMP_IGNORE_REMOVED = " is removed from ignore list"
AMP_IGNORE_ADDED = " is added to ignore list"
AMP_IGNORE_PREEXISTS = " is already in ignore list"
AMP_IGNORE_NOTEXISTS = " does not exist in ignore list"

-- Autoclear
AMP_AUTOCLEAR_STATUS = "Autoclear: "
AMP_AUTOCLEAR_HELP = "/amp autoclear - toggles automatic clearing of message after playback\nSyntax:\n/amp autoclear ( on | off) "

-- Frame
AMP_FRAME_HELP = "/amp frame - toggles frame settings\nSyntax: \n/amp frame ( on | off ) - toggles if to use frame to display missed messages. Defaults to off.\n/amp frame ( left | right | double ) - toggles if to use left, right or double click on frame to activate playback."
AMP_LCLICK = "Left-Click"
AMP_RCLICK = "Right-Click"
AMP_DCLICK = "Double-Click"

-- Play
AMP_PLAY_HELP = "/amp play - playback recorded messages"
AMP_CLEAR_HELP = "/amp clear - clears recorded messages"

-- AFK Message Persistence
AMP_AWAY_MSG_PERSIST_HELP = "/amp msgpersist - toggles away message persistence\nSyntax:\n/amp msgpersist ( on | off)"
AMP_AWAY_MSG_PERSIST_STATUS = "Away Message Persistence: "
AMP_AWAY_MSG_MENU = "Away Message Persistence"

-- FuBar/Titan Support
AMP_LABEL = "Missed: "
AMP_IGNORE_MENU = "Ignore List"
AMP_REC_AFK_MENU = "Record while AFK"
AMP_REC_DND_MENU = "Record while DND"
AMP_REC_AUCTION_MENU = "Record Auction House messages"
AMP_IN_COMBAT_MENU = "Combat Auto-reply"
AMP_AUTOCLEAR_MENU = "Autoclear messages"
AMP_FRAME_MENU = "Display frame"
AMP_HINT = "Hint: Left-click to play messages"

AMP_BG = {"Alterac Valley","Arathi Basin","Warsong Gulch"}