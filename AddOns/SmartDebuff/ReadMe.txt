***********************************************************************
SmartDebuff
Created by Aeldra (EU-Proudmoore)
***********************************************************************

SmartDebuff is an addon to support you in cast debuff spells.

FAQ
Q1: How can I move the frames?
A1: Use Shift-Left click and drag them arround

Q2: How can I assign a key for debuffing?
A2: During the new Blizzard secure UI is this not longer possible!

Q3: SmartDebuff casts the wrong debuff on a player, is this a bug?
A3: Please watch carfully in which color the debuff button is highlighted, this is very important! You have to click the button with the correct mouse click
As example per default:
Highlighted BLUE = LEFT click
Highlighted RED = RIGHT click

Q4: My SmartDebuff frame is gone, how I get it back?
A4: Type in the chat "/sdbo" or "/sdbm", if the options menu not opens SmartDebuff is not enabled, type "/sdb rafp" to reset all frame positions.

Q5: I use the "Auto hide" feature, but now SmartDebuff is hidden till combat, how I can configure it?
A5: Type in the chat "/sdbo" or "/sdbm" the options menu will displayed and the unit buttons also.




Features:
- Supports all classes
- Supports all clients
- Checks debuffs on you, raid/party members, raid/party pets
- Shows HP, Mana, AFK, offline, aggro state
- Shows class colors
- Sorted by groups or classes
- Choose your favorite debuff hightlight colors
- Choose opacity
- Sound reminder
- Target mode (like raid unit frames)


Normal mode:
Left click: Debuff 1
Right click: Debuff 2
Shift-Left click: Target unit
Alt-Left click: HoT 1

Target mode:
Left click: Target unit
Right click: HoT 1
Alt-Left click: Debuff 1
Alt-Right click: Debuff 2


Chat:
Type /sdb for SmartDebuff frame in game
Type /sdb [command] or /smartdebuff [command] in game
options - Show/hide SmartDebuff options frame
rafp - Reset all frame positions

Type /sdbo or /sdbm for SmartDebuff options frame in game


Please send me a mail or write a comment if you discover Bugs or have Suggestions.

Contact:
aeldra@sonnenkinder.org


***********************************************************************



Changes: 
Rev     Date        Description
------  ----------  -----------------------
3.0a    2008-10-15  Updated to patch 3.0
                    Updated debuff detection
                    Fixed auto hide feature

2.4b    2008-07-31  Added 'Debuff Guard', highlights critical debuffs which are not removable.
                    Added 'Debuff Guard' option frame
                    Added debuff timer (if L/R/M is unchecked), shows how many seconds the debuff ticks, since it was applied
                    Added full customizable buttons for spells/items/macros
                    Added 3rd mouse button and shift/alt/ctrl modifier support
                    Added key binding option frame (drag'n'drop)
                    Added auto update if a newer debuff spell is learned
                    Added 'Reset Color' button for debuff colors
                    Added options tooltips
                    Updated Warlock Felhunter check and option frame
                    Updated options frame
                    Removed auto hide feature, due to frame update issue befor combat
                    
2.4a    2008-07-31  Redesign to the new GetSpellInfo method, localization of the spells is not longer needed and SDB will now work for every language
                    Added new option: "Show Aggro", shows who has currently aggro
                    Added new option: "Gradient", enable gradient to the unit button color
                    Added new option: "Auto hide", hides automatically the SDB frame out of combat, if no one has a debuff
                    Added "Frost Trap Aura" to ignore list
                    Added Missdirection for hunters as support spell (use heal range to display in range)
                    Changed interval slider, values start now from 25ms - 500ms, default is 100ms
                    Fixed display debuff of mind controlled players for priests
                    Updated offline detection                    
                    Updated TOC

2.3a    2007-11-14  Added "Unstable Affliction" to ignore list
                    Updated TOC

2.2a    2007-09-26  Hotfix moving window

2.1a    2007-05-30  Added new slider: Bar height, to change the hp/mana bar height
                    Changed the mana bar color of shamans
                    Fixed "strange" bars, when a hunter/warlock and its pet left an instance
                    Fixed German localization (Arkanschlag)
                    Added Spanish localization

2.0d    2007-01-30  Added advanced sort order frame, manually sorting of the displayed class order
                    Added new button: "C" to open the class sort order frame
                    Added new click command: shift-right click on the SmartDebuff (background) frame to open the options frame
                    Added class selection
                    Changed hunter and warlock pets to new class selection
                    Updated class debuff skip list
                    Memory usage optimized
                    
2.0c    2007-01-11  Added new option: "Vertical", shows the units in vertical order (default)
                    Added new option: "Vertical up", shows the units from the bottom to the top
                    Added new option: "Header row, incl. buttons", shows the frame header (default)
                    Added new option: "Columns", slider to ajust the horizontally column count
                    Added new option: "Show summary frame"
                    Added new summary frame: shows party/raid total hp/mana/dead/afk/off (only in party/raid)
                    Added new chat command: "/sdb rafp", reset all frame positions
                    German localization
                    Fix target frame loss problem
                    
2.0b    2007-01-04  Added heal spells: Paladin (Flash of Light), Shaman (Lesser Healing Wave)
                    Added debuff support for the Felhunter
                    Added new option: Hunter Pets
                    Added new option: Warlock Pets
                    Added new option: Heal range, if a unit is out of your heal range the button gets a red boarder
                    Added new option: Header, shows column headers group/class
                    Added new option: Group Nr., shows the group nr. in front of the name
                    Added new option: Show background, displays a black backgound
                    Added new slider: Check interval
                    Added new slider: Fontsize
                    Fixed range check in target mode

2.0a    2006-12-21  Initial version of SmartDebuff
