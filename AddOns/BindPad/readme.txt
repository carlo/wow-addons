BindPad -- Created by Tageshi

---------------------------------------------------------------
1. WHAT IS "BindPad"?
---------------------------------------------------------------

BindPad is an addon to make KeyBindings for spells, items, and macroes.
You no longer need actionbar slots just to make Key bindings for your macores etc.

BindPad addon provides many icon slots in its frame.  You can drag and drop 
anything into one of these slots, and click the slot to set KeyBindings.



---------------------------------------------------------------
2. HOW TO USE "BindPad"?
---------------------------------------------------------------

  (1) Type /bindpad or /bp to display BindPad frame.
      (Also you can find "Toggle BindPad" Keybinding command in standard 
       KeyBindings frame of Blizzard-UI.)

  (2) Open spellbook frame (p), you bag (b), or Macro Panel (/macro).
      (Also you can use three mini-icons on BindPad frame to open these windows.)

  (3) Drag an spell icon, item icon, or macro icon using left button drag and 
      drop it onto the BindPad window.  
      (Maybe you need shift key + left button drag if action bars are locked.)

  (4) Now you see the icon placed on BindPad frame.  Click it,
      and a dialog window "Press a key to bind" will appear.

  (5) Type a key to bind.  And click 'Close' button.

  (6) When you want to remove icons from BindPad frame, simply drag away the icon 
      and press right click to delete it.

      Note that KeyBinding itself will not be unbinded when you delete the icon.
      To unbind it, click the icon and click Unbind button on the dialog window.
      Also you can simply override Keybindings.


---------------------------------------------------------------
3. HOW TO USE TABS
---------------------------------------------------------------

There are two tabs on BindPad frame; 'General Slots' and '<Character> Specific Slots'.
Icons placed on 'General Slots' are for all characters of your account. 
Those on '<Character> Specific Slots' are for that specific character only.

Note that you can use '<Character> Specific Slots' tab only after you click
'Character Specific Key Bindings' check box at standard KeyBindings frame of Blizzard-UI.

From BindPad version 1.5, you can see this checkbox on BindPad window itself too.
(Also BindPad will inform you about 'Character Specific Key Bindings' and automatically 
activate it for you when you click '<Character> Specific Slots' tab.)



---------------------------------------------------------------
4.  DETAILS
---------------------------------------------------------------

BindPad addon utilizes new functions added from WoW API 2.0 .

You can use these functions (and many others) in any addons or macroes.

  GetBindingKey("command")
  SetBindingSpell("KEY", "Spell Name")
  SetBindingItem("KEY", "itemname")
  SetBindingMacro("KEY", "macroname"|macroid)

Just don't forget to save changes by
  SaveBindings(GetCurrentBindingSet());


There are some other similar addons by other authers.
Try them and choose what you like.

SpellBinder
http://www.wowinterface.com/downloads/info5614-SpellBinder.html

And at least one more good addon that I have forgot its name...



---------------------------------------------------------------
5.  WHERE CAN I GET LATEST VERSION?
---------------------------------------------------------------

You can get latest version of BindPad from www.wowinterface.com:

http://www.wowinterface.com/downloads/fileinfo.php?id=6385

Or from Curse:

http://www.curse.com/downloads/details/5002/


---------------------------------------------------------------
6.  CHANGES
---------------------------------------------------------------

Version 1.6.1
Updated for WoW client 2.3.0 .
Fixed a bug causing macro icons sometimes not working.

Version 1.6
Added two extra tabs for heavy users.


Version 1.5.1
TOC update.


Version 1.5
TOC update.
Added the 'Character Specific Key Bindings' check box at upper right corner of BindPad frame.
Added some functions to inform about 'Character Specific Key Bindings'.


Version 1.4
TOC update.
Added three mini-icons to open Spellbook, Macroes Panel, and All bags.
Now uses new GetCursorInfo() API. (Slouken have kindly added it for me.)
You can now drag&drop icons from Action Bars too.
You can now use mouse wheel up/down as a keybind.


Version 1.3 (Now really updated version):
Added slash command /bindpad and /bp


Version 1.2 (not uploaded!):
More bug fixes.
Savefile format was changed and not compatible to 1.0 and 1.1.
(Old save data will be deleted when you use version 1.2; that don't unbind but you need to drag icons again.)


Version 1.1 (not uploaded!):
Fixed some tainting bug.


Version 1.0
Initial release.
