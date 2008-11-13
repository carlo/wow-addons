rpgo-CharacterProfiler: Character Profiler: WoW Addon 2.0
http://www.rpgoutfitter.com/CharacterProfiler/

DESCRIPTION
CharacterProfiler is a World of Warcraft addon that extracts character info including stats, equipment, inventory (bags & bank), trade skills, spellbook, mail, and pets.
This is saved in your SavedVariables\CharacterProfiler.lua in the myProfile block.
This information can then be uploaded to your website to display your profile(s).

USAGE
--SmartScan. the addon will scan your character info as you play the game.
--'save' button. Character ('C') -> Save Button (top left).
--'/command' commands with '/cp export'

TIPS
to get a complete extract:
--open Character Frame ('C'); hit 'save'
--open your Bank
--open each Profession
--open your Mailbox

/COMMANDS
	'/cp' or '/rpgocp' or '/profiler'
	'/cp [on|off]'           -- turns on|off
	'/cp show'               -- show current session scan
	'/cp list'               -- show profiles stored
	'/cp export'             -- force export
	'/cp purge [all|server|char]'
	'/cp (preference) [on|off]'

PREFERENCES
	lite         [_on_|off]  -- disables scanning while in raid or in-instance
	button       [_on_|off]  -- removes button from CharacterFrame
	tooltipshtml [_on_|off]  -- scan tooltips in html or lua-array form
	reagentfull  [_on_|off]  -- scan recipe reagents in html or lua-array form
	talentsfull  [_on_|off]  -- scan all talents including ones without points
	questsfull   [on|_off_]  -- scan full info for quests (Description & Objective)

	fixtooltip   [_on_|off]  -- remove item.Tooltips where same as item.Name
	fixquantity  [_on_|off]  -- remove item.Quantity when = 1
	fixicon      [_on_|off]  -- remove path info from ["Icon"] (Interface\...)
	fixcolor     [_on_|off]  -- remove alpha info from ["Color"]

HISTORY:
full history available at: http://www.rpgoutfitter.com/CharacterProfiler/#history

ADDON LICENSE
http://rpgoutfitter.com/addons/license.cfm
All RPG Outfitter add ons for World of Warcraft are provided free of charge.

You are free to copy, distribute, display, and perform these addons and to make derivative addons under the following conditions:
--Attribution. You must attribute all add ons in the manner specified by RPG Outfitter.
--Noncommercial. You may not use these add ons for commercial purposes.
--Share Alike. If you alter, transform, or build upon these add ons, you may distribute the resulting add on only under a license identical to this one.
--For any reuse or distribution, you must make clear to others the license terms of these add ons. Any of these conditions can be waived if you get permission from RPG Outfitter.
Your fair use and other rights are in no way affected by the above.

COPYRIGHT
All World or Warcraft game related content and images are the property of Blizzard Entertainment, Inc. and protected by U.S. and international copyright laws. The Addon (code and supporting files) is property of RPG Outfitter and protected by U.S. and international copyright laws.
