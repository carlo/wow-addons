------------------------------------------------------
Fizzwidget Linkerator
by Gazmik Fizzwidget
http://fizzwidget.com/linkerator/
gazmik@fizzwidget.com
------------------------------------------------------

Have you ever wanted to tell your friends about some impressive loot you saw another adventurer using? Share your regret about the quest reward you foolishly didn't choose? Spread word to your guild of what your raiding party found? Now you can do so easily with my latest gizmo! Not only does it help you keep track of all the items you encounter, Linkerator makes it super-easy to tell your friends about them in full detail! 
 
------------------------------------------------------

INSTALLATION: Put this folder into your World Of Warcraft/Interface/AddOns folder and launch WoW.

USAGE: 
	- Automatically remembers item links you come across (some of which you might not even see!)... in chat channels, in your inventory and bank, on other players, in loot messages, etc. (Unlike some addons which do this, Linkerator doesn't keep a database of full names for all items; for most items, it just makes sure your WoW client caches the data.)
	- Allows you to insert an item link in chat by merely typing its name in brackets. (i.e., type `/g [swift razzashi raptor]` to send a message to your guild with a clickable link for the mount they likely won't see often.) 
	- Since there are some cases of different items which have the same name, you can type the name followed by something distinctive about the item in parentheses (e.g. `[punctured voodoo doll (druid)]` or `[warblade of the hakkari (off)]`) if you're looking for a specific match -- you can use any item attribute that shows up in that item's tooltip. (This only works if the variant you're looking for is in your WoW client's cache, however.) Alternately, if you know the item ID of a specific item, you can type it in brackets (preceded by a pound sign) to link it (e.g. `[#18473]` to get the Hunter variant of [Royal Seal of Eldre'thalas]).
	- You can also retrieve stored links via various `/link` chat commands.
	
CHAT COMMANDS:
	/linkerator (or /link) <command>
where <command> can be any of the following:
	help - Print this list.
	<number> - Print a link in the chat window for an item given its ID number.
	<link code> - Print a link in the chat window for an item given a complete link code (e.g. "item:789:241:0:0:0:0:2029:0" for a [Stout Battlehammer of Healing] with a +2 damage enchant).
	<name> - Print a link in the chat window for an item given its name or part of its name. (Will show more than one match if available.)
	
CAVEATS, ETC.: 
	- WoW only allows hyperlinks for items that the server has "seen" since its last reset. Linkerator can tell whether an item is in your WoW client's cache, but it can't tell whether it's okay with the server -- so you might get disconnected if you try to send a link for, say, [Thunderfury, Blessed Blade of the Windseeker] to a chat channel shortly after server maintenance (unless you have one yourself).
	
------------------------------------------------------
VERSION HISTORY

v. 3.0.1 - 2008/10/22
- Fixes an error when attempting to type links in chat.

v. 3.0 - 2008/10/14
- Updated for compatibility with WoW Patch 3.0 and Wrath of the Lich King.
- It's now possible to retrieve item links given a known item ID (using `/link <number>`) even if the item is not in your client's local cache. Items unknown by the server will return no results.
- Includes preliminary support for spell links -- they're now returned in `/link` search results but not for as-you-type linking. More spell, talent, quest, and achievement link features will follow in future releases.

v. 2.4 - 2007/03/25
- Updated TOC to indicate compatibility with WoW Patch 2.4.
- Processing of links seen at the Auction House is now done asynchronously; this avoids locking up the client for long periods of time if another addon requests all the AH listings at once.

v. 2.3 - 2007/11/13
- Updated TOC to indicate compatibility with WoW Patch 2.3.

v. 2.2.1 - 2007/10/12
- Fixed an issue where typed characters could be lost when Linkerator attempts to complete a link in the chat input box.
- The delay before link completion in chat can now be customized with the `/link delay <seconds>` command. (Fractional seconds are allowed; 0.25 is the default, which can be reset with `/link delay reset`.)

v. 2.2 - 2007/09/25
- Updated TOC to indicate compatibility with WoW Patch 2.2.

v. 2.1.3 - 2007/09/18
- Fixed an issue where the first completion for a partial link typed in chat input box would sometimes get deselected with the cursor moved to its end, preventing one from continuing to type something else (e.g. intending to type the first three letters of [Bracers of the Green Fortress], but getting [B.O.O.M Operative's Beltr or [B.O.O.M Operative's Belta instead).
- Link completion in the chat input box is now triggered 0.25 seconds after the latest character is typed (instead of every 0.25 seconds while the input box contains new characters), further reducing lag while typing.
- Fixed several issues with using the Tab key to cycle through possible link completions or advance the cursor withing them.

v. 2.1.2 - 2007/09/13
- Optimized item link lookups for better performance; there should now be much less lag while typing or pasting text in the chat window.
- Reduced memory usage after link lookups.
- Enchanting links will no longer appear twice in the results of a `/link <name>` search.

v. 2.1.1 - 2007/07/20
- Added support for tradeskill links (introduced in WoW patch 2.1).
- Redesigned code for handling item links. Over the last several patches, Blizzard has optimized the item info APIs to where we can get by without our own item names database... so we can save a big chunk of RAM by getting rid of it.
- Added support for the Ace [AddonLoader][] -- when that addon is present, Linkerator will load in the background shortly after login (reducing initial load time). 
[AddonLoader]: http://www.wowace.com/wiki/AddonLoader

v. 2.1 - 2007/05/22
- Updated TOC for WoW Patch 2.1.
- Uses a more accurate means of avoiding secure chat commands.
- Shortened messages printed when `/link debug` is enabled.

v. 2.0.2 - 2007/01/15
- Updated TOC to indicate compatibility with WoW Patch 2.0.5 and the Burning Crusade release.
- We now record the unique ID when saving links for random-property items (e.g. [Wild Leather Cloak of the Boar], [Queen's Insignia of the Elder]), as it's necessary to retrieve a correct tooltip for new items in the Burning Crusade.
 
v. 2.0.1 - 2006/12/19
- Fixed an issue where manually finishing typing of an autocompleted link would erase it as you typed the closing bracket.
- Fixed a case sensitivity issue which prevented some link searches from returning correct results.

v. 2.0 - 2006/12/05
- Updated for compatibility with WoW 2.0 (and the Burning Crusade Closed Beta).
- NOTE: Linkerator doesn't quite work right for new random-property items from Burning Crusade content (e.g. [Naaru Lightmace of the Elder]... we'll retrieve the link, but it'll show +0 for its added stats due to changes in the WoW client/server architecture).

See http://www.fizzwidget.com/notes/linkerator for older release notes.
