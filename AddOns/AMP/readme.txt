Answering Machine Plus stores your tells and also Auction House messages while you are AFK or DND and plays them back to you when you return.

Answering Machine Plus is largely based on the former Answering Machine mod, but with the following pluses:

- Titan Panel Support.
- FuBar Support.
- Auto-replies to people who sends tell when you're in combat to let them know that you're busy. Once per whisperer per combat.
- Play recorded messages whenever you like, not just when you leave AFK.
- Also playblack of recorded message has the peoples' name as working links, so you can reply with a click.
- Ignore list support. you can maintain a list of keywords to ignore. Whispers containing keywords will not be recorded.
- Recording of AH messages.
- Audio alert of AH messages.
- AMP is disable in Battlegrounds.
- Away Message Persistence.

Thanks for taking the time to take a look at Answering Machine Plus. If you love Answering Machine Plus or have a comment/bug report, please contact me at krakhaan@gmail.com.

Official Website: http://ui.worldofwar.net/ui.php?id=3544

Authors: Krakhaan of Khaz'goroth

Credits:
Original Author: Mindark of Dragonmaw
Original Mod: http://ui.worldofwar.net/ui.php?id=1221

Translators: Put your name here by helping with the translation.

Installation instructions:
Extract to your World of Warcraft\Interface\AddOns directory

Slash Commands (/answer or /amp):

'/amp msg' - changes your default away message
Syntax: 
/amp msg <new away message>

'/amp msgpersist' - toggles persistence of your away message across sessions.  Defaults to off.
Syntax: 
/amp msgpersist ( on | off )

'/amp play' - playbacks recorded messages
Syntax: 
/amp play

'/amp clear' - deletes all recorded messages
Syntax: 
/amp clear

'/amp afk' - toggles recording while AFK. Defaults to on.
Syntax: 
/amp afk ( on | off )
	
'/amp dnd' - toggles recording while DND. Defaults to on.
Syntax: 
/amp dnd ( on | off )

'/amp combat' - toggles auto-reply while in combat. Defaults to off.
Syntax: 
/amp combat ( on | off )

'/amp auction' - toggles recording of Auction House messages. Defaults to on.
Syntax: 
/amp auction ( on | off )

'/amp ignore' - ignore list check during recording. Defaults to on.
Syntax:
/amp ignore ( on | off )
/amp ignore ( add | remove ) [word]
/amp ignore list

'/amp autoclear' - toggles recording while AFK. Defaults to on.
Syntax: /amp autoclear ( on | off )

'/amp frame' - toggle frame settings
Syntax: 
/amp frame ( on | off ) - toggles use of frame to display missed messages. Defaults to off.
/amp frame ( left | right | double ) - toggles use of left, right or double click on frame to activate playback. Defaults to double click.

Version history:
3.4  -  Added user away message persistence
	Updated Titan and FuBar plugins
	Updated AV detection
	Minor code revisions

3.3  -  Updated BG detection, no longer requires Atlas (Thanks Aisling, Drizzd)
	Removed debug messages that were unintentionally left in v3.2

3.2  -  Added user selectable click action for frame
	Updated localization files to reflect /amp slash commands as in readme.txt and more...
	Updated code for slightly increased efficiency
	Updated Titan and FuBar plugins

3.1.1-  Added patch for clearing AMP Frame after playback
	Changed click frame to playback to double-click

3.1  -  Added remember AMP_Frame settings
	Added click to retell message function to frame

3.0  -  Renamed folders to AMP, AMPFu, AMPTitan. Apparently the former long folder name was the problem with Fu. You may want to delete the former AnsweringMachinePlus.lua savedvariables file.
	Fixed FuBar plugin text to match Titan's.

2.3.1-  Changed autoreply in combat default to false (based on user feedback)
	Fixed FuBar Plugin label

2.3  -  Added autoclear of messages after playback

2.2  -  Added Fubar 2.0 plugin
	Changed Titan Panel support as separated mod
	Added Dynamic Event Registration
	Added click on Titan Panel/FuBar icon to play messages

2.1  -  Added manual playback of recorded messages, hence also require manual clearing
        Added on demand event registration
        Added saving of messages in savedvariables
        Changed auto-replies to once per character per combat session
	Added alternate slash command /amp

2.0  -  Added Titan Panel Plugin
        Added auto-replies while in combat
	Added Ignore list (Case Insensitive)
	Added /amp ignore list - print ignore list
	Added /amp ignore add word - add a word to ignore list
	Added /amp ignore remove word - remove a word from ignore list
	Added Per User Configuration
	Added Linked Retells. Now you can click on the names to reply the tell
	Added Battleground detection/bug fix, requires Atlas
        Hide Answer Frame

1.11 -	Removed a bug when returning from DND
	Added French localization - Thanks Sasmira of Curse-Gaming!
	Switching to and from AFK and DND while one or the other is not set to record appears to be working properly now

1.10 -	Frame wasn't correctly docked to the player frame, this has been corrected
	Changed /amp to /amp default
	Added /amp frame - toggles and frame on and off
	Added /amp afk - toggles whether or not to record while afk
	Added /amp dnd - toggles whether or not to record while dnd

	Known issues:
	A bug exists while going AFK in the battlegrounds. Let's just say I'm not going to fix this because I don't condone deserting.  The real reason is it's just too much effort to fix for this.  If you need to /afk out of BGs just make sure you flag /afk again when you zone out.

	There are some problems when moving directly to and from /afk and /dnd status when one or the other is not set to record.  Example:
	You are not recording DND messages.  You go AFK.  You move straight from AFK to DND.  You return from DND.  You will have missed all messages you received while DND

	Support for french and german is implemented, but translations are needed

1.00 -	Movable frame now displays missed tells, originally docked above player portrait
	Corrected some french translations

0.80 -	Fixed a bug with the german clients
	Added translations to french and german clients
	Made playback of messages less confusing

0.70 -	Rewrote code to be more compatible with changes by blizzard, localization
	Added support for DND
	Allows for customized default AFK messages (/amp)
	Should work for non-english clients now; however, all messages are currently in english

0.65 -	Answering Machine v0.60 only worked with the default away message, now it works with custom away messages

0.60 -	initial release