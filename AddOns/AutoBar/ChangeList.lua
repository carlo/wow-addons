--
-- AutoBar Change List

-- Maintained by Azethoth / Toadkiller of Proudmoore.  Original author Saien of Hyjal
-- http://code.google.com/p/autobar/

-- 2.01.00.04 beta
-- Removed a bunch of redundant categories, shifted all non spell ones to PT3, partway through being completely PT3 based.
-- Spell categories converted
-- Bottled Nethergon Energy (32902) and Bottled Nethergon Vapor (32905)
-- 11562:670 Ungoro Restore, 11952:425 Night Dragon's Breath
-- 19183 Hourglass Sand
-- Consumable.Buff.Spell Reflect.Self 20080 Sheen of Zanza
-- Misc.Hearth : Hearthsone & Ruby Slippers
-- Consumable.Buff.Free Action : 20008,5634
-- Consumable.Buff.Speed.Self added 20081:20 Swiftness of Zanza, 2459:50 Swiftness Potion
-- Misc.Battle Standard.Battleground : 18606,18607
-- Misc.Battle Standard.Alterac Valley : 19045,19046
-- Consumable.Recovery.Rune : 20520:1200,12662:1200
-- 32503 Yazzil's Poison Mutton
-- 30616 Bundle of Bloodthistle, 31360 Unfinished Headpiece, 30639 Blood Elf disguise, 32467 Vim'gol's Grimoire
-- 32686 Mingo's Fortune Giblets, 32685 Ogri'la Chicken Fingers
-- 31386 Staff of Parshah, 32578:2000 Charged Crystal Focus
-- 32680 Booterang
-- Consumable.Recovery.Stone.Other : 11951:800 Whipper Root
-- Consumable.Recovery.Stone.Warlock
-- Consumable.Buff.Water Breathing : 24421:30
-- Fix AutoBarSearch:CanCastSpell
-- Fiery Warhorse's Reins (30480), Banishing Crystal (32696)
-- 30853,29443,30175 & other quest items
-- Fix Attempt to call method 'GetProfile' (a nil value)
-- 33042:7200 Black Coffee
-- Fix cyCircled timing issue
-- Fix weapon buff to be arrange on use again

-- 2.01.00.03 beta
-- 22850:2200 Super Rejuvenation
-- 31677:3200 Fel Mana
-- Consumable.Weapon Buff.Misc 3829 Frost Oil
-- clamlette surprise and spider sausage 17222:12,16971:12
-- Druid Swift Flight Form added to mount button
-- Use items by itemlink.  Fixes stack problems during combat.
-- Fix tooltip bug
-- Add script support
-- Consumable.Buff Group.General Caster & Melee
-- 32721:20 Skyguard Rations
-- 729 Stringy Vulture Meat
-- Consumable.Quest.Usable
-- Rumsey Rum Dark
-- AutoBarCategory.lua + BabbleZone-2.2
-- Coilfang & Tempest Keep potions
-- 32698 Wrangling Rope
-- New Elixers: 32067 Draenic Wisdom, 32062 Major Fortitude
-- Consumable.Buff.Absorb.Self.Damage 32063 Earthen Shield
-- Consumable.Buff.Resilience.Self 32068 Ironskin
-- 22849 Ironshield Potion added, bogus 22927 Recipe for it removed.
-- "Toggle the config panel" & other localizations by helium
-- Consumable.Potion.Recovery.[Healing | Mana].Blades Edge
-- Nether Ray Mounts

-- 2.01.00.02 beta
-- TOC update 20100
-- Ace2 lib update
-- Fix Consumable.Weapon Buff.Stone.Sharpening Stone
-- Move Create Healthstone to a separate button with its own category.
-- Babble-2.2 frFR Summon Dreadsteed: fix case
-- Remove some Data Rot from AutoBar.xml
-- Fix missing keybindings

-- 2.00.00.37 beta
-- Add Summon Warhorse and Summon Felsteed
-- Only parent anchor, dont specify relpoint so tinytip will be happy
-- Consumable.Buff.Shadow Power added to Caster Buffs
-- Remove unused PreClick call
-- Fix doubleclick effect
-- Cleared slot 6: protection potions.  They are all in the buff slot already.
-- Fix Shadow Power cut & paste error
-- Add support for bandaging pets.  Tx Tarkumi.
-- Remove auto added spell slots.  Spell slots now only show if explicitly added.  This should move all conjure items to the conjure slot.
-- Note that food & water have a conjure button set as lowest priority so you can just click it to make more when you run out.
-- Fix bug in pet bandage code.
-- Merge in LaoTseu's Quest Items
-- Fix Mana Citrine & Jade order
-- Fix arrangeOnUse
-- Clearer AutoBarConfig load error message.

-- 2.00.00.36 beta
-- Add missing sets to PT3 consumable

-- 2.00.00.35 beta
-- Switch from PT3 alldata to consumable, misc & tradeskill
-- Add links to Google Code Project Page

-- 2.00.00.34 beta
-- Bug Fix for 2.1.
-- Fix update issue after flying
-- Fixed bug in Sorted items Reset()
-- Fix the square glitch with cyCircled and AutoBar
-- Update AutoBar when cyCircled skin changes
-- ["Consumable.Buff.Fire Power"] = "6373:10,21546:40,22833:65",
-- ["Consumable.Buff.Frost Power"] = "17708:15,22827:55",
-- ["Consumable.Buff.Shadow Power"] = "9264:40,22835:65",
-- 28112:4410 Underspore Pod
-- 23822:2000 23823:2400 Healing and Mana Injectors
-- 30360 Lurky's Egg
-- Drums 29528:60/30 29530:15 29531:750 29529:80 29532
-- ["Consumable.Leatherworking.Drums"]		= "29528:1 29530:2 29531:3 29529:4 29532:5"
-- 22797:2000 Nightmare Seed
-- Fixed a bug in Spell scanning code that incorrectly disabled spells when scanning with low mana.
-- All weapon buffs now have a single category.
-- All classes get a weapon buff slot.  Dual wielding classes get an extra one.
-- Rogue poisons are all in the 2 weapon buff slots.
-- The weapon buff slots & category are arrange on use so the last used item becomes the default.
-- As usual, do a reset on the profile page to pick up the changes

-- 2.00.00.33 beta
-- Split out Mana Stone conjure buttons for Mages
-- Fix bg mana & heal potion categories.  Requires Reset on the profile tab.
-- Localization fix for deDE Teleport: Moonglade and Conjure Mana Stones.  Tx
-- Portals & Teleports category added.  Includes Druid, Mage, Shaman and Warlock spells
-- Edit the Class layer to get rid of it.  Needs Reset on Profile Tab to pick up the changes.
-- Mess with event delays.
-- Fix cyCircled AutoBar code to avoid skinning 288 buttons on every update

-- 2.00.00.32 beta
-- crash fix in update
-- Sort weapon poisons
-- Remove deprecated "Alterac Valley" potions.  Use PvP potions instead.
-- Reinstated Anesthetic poison category.  It is like instant but has no extra aggro & is cheaper apparently.
-- 18045:12 Tender Wolf Steak
-- Flying Mount localization
-- Spells now have their own buttons.
-- Conjure Mana Emerald added.  Babble-Spell-2.2 needs translations.  Spanish & German may have some lucky guesses
-- Druid Flight Form added
-- zhTW locale: tx helium_wong
-- 21151:15 Rumsey Rum Black Label
-- Added some performance profiling support: checkbox on profile tab to activate

-- 2.00.00.31 beta
-- New bag scan code, integrated, likely some issues left
-- 30360 Murky pet
-- 28102:60 Onslaught Elixer
-- 22927:2500 Ironshield Potion
-- 28103 Adept's Elixir
-- 31679:120 Fel Strength
-- 22837:75 Heroic Potion
-- 22828:120 Insane Strength Potion
-- 27553 Red Bull .. er Steer

-- 2.00.00.30 beta
-- Added more stuff to caster buffs.  Requires Profile tab reset.
-- Attack Power, Healing and Spell Damage Foods.  Requires Profile tab reset.
-- New bag scan code, not integrated yet but tested

-- 2.00.00.29 beta
-- Consumable.Warlock.Health Stone -> Consumable.Warlock.Healthstone
-- Jeweler Stone Statues added
-- First cut at new buffs.  Default categories are buffs general, melee, caster and other.
-- Targeted buffs have lower default priority
-- More specific categories are available as well by buff type.
-- Requires a reset on the Profile Tab or manual adding of buff categories
-- Disable arrange on use for first popup button
-- Removed bogus instance dependency for flying mounts.  Awaiting patch 2.1 "canfly" or something property for final flying mount support.
-- Reorganize buff foods a bit.  Added warp burgers.
-- Add Chest and Shield Buffs

-- 2.00.00.28 beta
-- Mini Pets: Gurky [Pink Murloc Egg] itemid = 22114, Murky [Blue Murloc Egg] itemid = 20371
-- Major Combat Potions
-- Fixed right click Conjure Food for mages
-- PT3.  This is a reworked item database, if you are missing an item see above for how to report it.
-- Code to add priority to certain items.  eg. conjured food.  Not used everywhere yet.
-- New conjured food & water added

-- 2.00.00.27 beta
-- Dont lock size for cyCircled buttons
-- Dont show annoying ugly borders around buttons
-- Slightly better button click feedback

-- 2.00.00.26 beta
-- Kill the keybind tab & switch back to Blizzard KeyBind UI based keys.
-- Keys tab keys are not preserved, old ones still bound from Blizzard UI will be reused.
-- Barring bugs that finalizes the key bindings feature.
-- Allow gapping of -1
-- CanCastSpell -> AutoBarProfile:CanCastSpell
-- Zorbin's Ultra-Shrinker

-- 2.00.00.25 beta
-- Fix cyCircled code
-- Add flying mounts to defaults.  Needs reset to pick up change.
-- Extend icon gapping minimum down to 0

-- 2.00.00.24 beta
-- Chinese New Year prep: Fireworks added.
-- Dragging items from bag or character sheet now supported.
-- Can now drag items directly to the edit slots on the Slots Tab; category slots on the slot edit view;

-- 2.00.00.23 beta
-- Move Summon Charger and Summon Warhorse to the mount slot.

-- 2.00.00.22 beta
-- Split Out the button code
-- Switch to Bartender3 style buttons
-- Check for BG needed items.

-- 2.00.00.21 beta
-- TOC fix
-- Possibly fixed right click to feed pet.
-- Fixed alpha of standalone icon for spell casts (mounts etc.)
-- First cut at support for equipped items.
-- Partial fix for layout centering issues.

-- 2.00.00.20 beta
-- Removed alt & ctrl self cast in options.  Use blizz interface instead.
-- Alt / Ctrl selfcast changed to use blizz code.
-- Note that autoSelfCast is via blizzard interface options / basic / Auto Self Cast
-- Unless there are bugs Self Cast should now be a fully implemented feature.
-- Do not show a count of just 1
-- Fixed show category icons
-- Fixed one issue with the cast spells migrating to the left click.

-- 2.00.00.19 beta
-- Added "Summon Warhorse" & "Summon Felsteed" for low level pallies & locks.
-- Replaced "smartSelfCast" in config with automatic right click selfcast, as well as alt or ctrl - self cast.

-- 2.00.00.18 beta
-- Update cooldown & counts during combat.

-- 2.00.00.17 beta
-- Upgraded right click spell casts to show spell icon if no such item in inventory.  Should now work for all summoned mounts and travel forms, mana & health stones, conjured food & water.  Needs a reset.
-- Right Click to feed pet for Food: Pet Bread / Cheese / Fish / Fruit / Fungus / Meat added.  No hunter so not tested...
-- Right Click to target pet option for slot should now work again as well.  No hunter so not tested...
-- Renamed profile "Single Setup" to "Single (Classic) Setup"
-- Extra InCombatLockdown() checks in case 3rd parties call update functions or delayed callbacks get triggered during combat lockdown.
-- Fixed bug with resetting not showing basic layer slots.
-- Dock to Bartender bar 6 option

-- 2.00.00.16 beta
-- IsUsableItem check added.  Thanks turkoid.
-- Back out the callback update mechanism for buttons that are not action items.  This should fix the lag.

-- 2.00.00.15 beta
-- May have successfully added Conjure Food and Conjure Water on right click on food & water item / category.
-- Changed the Manastone code to look for the first castable one in order (on init so far only).
-- Upgraded deDE to have all the entries of the enUS locale.  Should fix use of deDE with enGB.
-- Mana Emerald 22044:1250
-- Conjured Mountain Spring Water 30703:5100
-- Candy Cane 17344:61
-- Graccu's Meat Pie 17407:874

-- 2.00.00.14 beta
-- Selectable strata level Config/Bar/High Frame Strata

-- 2.00.00.13 beta
-- Fixed bug in the casting code when the slot is empty
-- Partial lag fix.  Added delay timers to avoid multiple bag scans.

-- 2.00.00.12 beta
-- Change strata to always be high
-- Right clicking healthstone by warlock, or mana stone by mage should cast it.
-- Right click mount by druid / shaman will cast travel form
-- Right click mount by pally or warlock casts summon mount
-- Only tested for a druid...
-- More mounts added

-- 2.00.00.11 beta
-- Espanol or something!  Tx shiftos!
-- Fixed illegal use of Show();
-- Right Click self targets
-- Removed obsolete option to disable popups
-- Popup on shift is broken for now
-- Only tested for a druid...

-- 2.00.00.10 beta
-- Just fixing externals for ace

-- 2.00.00.09 beta
-- Switch to PeriodicTable-2.0
-- mana & hp thresholds now based on PT so wont get out of sync again
-- Set header framestrata to DIALOG so popups dont popunder
-- Booze category added.  Temporary until buffs are overhauled.
-- HideTooltips checkbox works again
-- Docking adjusted a bit but not completely redone yet
-- Add ItemId to tooltip so missing items can be reported easily!

-- 2.00.00.08 beta
-- Reduced the key bindings in Blizzards Keybind UI to only the config toggle.
-- Added basic Tooltip support.
-- Update bar after binding changes

-- 2.00.00.07 beta
-- Alt self target support added
-- Close & disable config during combat
-- Cooldown support added
-- Hotkey display support added to bar buttons

-- 2.00.00.06 beta
-- Fixed lib path issue

-- 2.00.00.05 beta
-- Left & Right clicking a button fixed.  Should target offhand weapon for right click once more.
-- Fixed at least one instance of the itemCount error.
-- Draghandle can be hidden once more
-- First cut at fixing docking.  It works & is tested only for the chat frame.  Offsets still need adjusting and new anchor frames used or hilarity does ensue.
-- More keybinding progress.  Now saves for single & shared profile.

-- 2.00.00.04 beta
-- Unbind button now actually unbinds key binding
-- Revert button will now revert key binds made since the last time done or revert was pressed or the mod loaded. Escaping out of config neither reverts nor commits.

-- 2.00.00.03
-- Fixed popups
-- Quest category added.  Slot 24 for non-rogues.
-- Disable health & mana change updates.  No point since we can't change items during combat anymore & out of combat you can just eat something.
-- First cut at Key binding tab.  Mostly works, left click to set left mouse button binding, right click to set right mouse button binding.

-- 2.00.00.02
-- Some gimped keybindings workaround.  It sort of works off the blizz interface but you can lose bindings if u open it during combat.
-- It may be unstable in some other ways, I seem to lose the bindings from time to time but haven't noticed why yet.
-- This will have to do for now.  I may add explicit per slot binding if this is too lame for real use.
-- Show category icons for 0 item slots works again
-- Show empty slots kinda works but still some strangeness when used with category icons off.

-- 2.00.00.01
-- Make blizz clock cooldown show up again
-- Some progress on drag handle
-- Got rid of Compost

-- 2.00.00.00
-- First rough cut.  Using Secure State Header & Buttons for the bar & popups.
-- Hacking around the lack of an inventory item button with itemId other than direct bag slot & by name.
-- Oops, didnt ship the config.  Doh!


-- 1.12.07.07
-- Final Ace Locale conversions

-- 1.12.07.06
-- Pet Food fruits now have 4 kinds of kimchi.  Seems like a vegetable to me.  Do pets eat delicious kimchi?
-- Almost done integrating with PeriodicTable.
-- Some new bonus foods: Spirit, Well Fed (sta & spi), Other (Dragonbreath Chili for now), Stamina (just stamina)
-- Will need to manually edit food slot or reset to pick up this change.  Existing Stamina items changed to the jsut stamina ones.

-- 1.12.07.05
-- Actually sort the PeriodicTable sets
-- ArrangeOnUse inside a category as well.  Not persistent across reloads yet.  Only Mounts & Pets so far.
-- Added a Checkbox for ActionBar buttons locking when AutoBar is locked.
-- Fix drag & drop error caused by table.getn not returning anything remotely close to number of elements in the array.

-- 1.12.07.04
-- Heavy Crocolisk Stew
-- Switched all but food to use PeriodicTable
-- Rearranged some more of the localization strings.  Much less spam in global space now.
-- Fishing slot modified a bit so it lists fishing pole and some gear. (Requires reset or manual slot edit)
-- Clicking it equips the pole then lucky fishing hat then click to use lures.
-- Naturally you want to add your enchanted fishing gloves to the slot as well.

-- 1.12.07.03
-- French!  Thank you so much Cinedelle!
-- Config is now load on demand.
-- Added rest of the percent foods for Halloween.  (Requires reset or manual slot edit)
-- Pets added, (Rogues need to manually add Pets / Holiday Pets)

-- 1.12.07.02
-- Restored lost changes to character & shared display edit.
-- Acelocale 2.2
-- Some more Ace Locale conversion

-- 1.12.07.01
-- Fixed error with smartSelfCast on the profile tab.

-- 1.12.07
-- Official Ace2 release.
-- Chinese: PDI175

-- 1.12.06.10 beta
-- Make Drag Handle hideable again
-- Dock to bottom right action bar, left or right side of it.

-- 1.12.06.09
-- Switch to Ace Event for timers
-- Upgrade align buttons option to have any combination of vertical and horizontal alignment (9 options).
-- Fix toc for Ace svn

-- 1.12.06.08
-- Korean + some more incremental ACE Locale changes for all languages.

-- 1.12.06.07
-- Renamed files ACE Locale style + some incremental ACE Locale changes for all languages.
-- Deleted obsolete dependencies and files.
-- Toc changes to support ace & ace wiki.

-- 1.12.06.06
-- Actually separate display editing from slots editing for Character vs Shared.
-- This clears up a crasher & some non-obvious behavior after a reset.

-- 1.12.06.05
-- Lock all bars option for drag handle + 30 second timeout on the unlock.  No more accidentally dragging action bar items around!
-- Cleared up a case of algorithm necrosis
-- Looks like Character layout got broken.  Will be fixed next version.  Use Shared layout for now.

-- 1.12.06.04
-- Fixed some Compost library issues.
-- Fixed a couple of spots where non tables were fed into the slots list again.

-- 1.12.06.03
-- Remove single item slot option.  Its pretty pointless & prevents all kinds of options.
-- Compost-2.0
-- oSkin support checkbox on profile tab.  Random results on choose category / view category dialog though.

-- 1.12.06.02
-- Fix embedded library issue

-- 1.12.06.01
-- Ace 2
-- Dewdrop-2.0
-- Boiled clams moved to bonus category
-- Do not flash the popup when using keybinding
-- Harvest festival foods
-- Korean, tx Sayclub!

-- 1.12.05
-- Ok, here it is: the release version of the profiling system.
-- Changed defaults so profile is Single for people with existing Character layer buttons, and Standard profile if not.
-- Dense Dynamite
-- Default noPopup for mount changed to arrangeOnUse.  A better way to go now that mounts are cheap.

-- 1.12.04.12
-- Korean
-- Label Combined Layer View & Layer Edit Sections.
-- Hide edit layer buttons that are not enabled.
-- Config Tooltips.

-- 1.12.04.11
-- View Slot now has a red background and appropriate title and the errant button is now properly hidden.
-- Added some text directing you to the Slots tab for editing as well.
-- Edit Slot dialog has a slightly green background to indicate editing is possible.

-- 1.12.04.10
-- Winterfall Firewater
-- Removed some duplicates in the pet food meat section
-- Revert Button for config so you can undo unintended changes & experiment more freely
-- Basic and Class layers now editable as well
-- Quick Setup & Reset buttons: Single, Shared, Custom as well as blank slate button.

-- 1.12.04.09
-- Chinese & Korean courtesy of the usual suspects
-- Runes added to potion slot

-- 1.12.04.08
-- Fixed dragging slots around on the slots tab.
-- Can now drag from the slot view at the top to the slots being edited at the bottom as well.
-- Fixed slot view not updating when selecting profile layers in the profile

-- 1.12.04.07
-- Added a zeroing out category called "Clear Slot" as well as a button for it on the edit slot dialog.

-- 1.12.04.06
-- Simplified profile interface
-- Now has 4 shared profiles, selectable under profile tab
-- Fixed Smart Self Cast bug.
-- Added Smart Self Cast to defaults
-- Smart Self Cast remains partly broken in its current implementation until it gets a rewrite
-- You can turn the individual ones on but not necessarily off if they are part of the defaults etc.

-- 1.12.04.05
-- Added Clear Slot category.

-- 1.12.04.04
-- Fixed warrior rage potion slot conflicting with heal potions

-- 1.12.04.03
-- Class default bug fix
-- Arathi Basin Food upgrade, tx Ghoschdi
-- Korean, tx Sayclub
-- Expanded slot list to 16.  Removed the clunky movement buttons.  Use drag & drop to reorder instead.
-- Split out more code for the various frames
-- Fixed autoselfcast for now.  Needs a better implementation.
-- Slot View area has tooltips again & clicking them brings up a non-editable Slot View.

-- 1.12.04.01
-- Profile Tab: 4 layers, current edit layer picked at top of dialog.  Class & Basic defaults (not editable)
-- Display settings are either character specific or shared.  No layering.
-- Fixed frame strata for bar & popup
-- Seperated code for ChooseCategory and ConfigSlot.
-- Some lua changes for 2.0
-- Hourglass Sand
-- Casting Cursor used for button interaction
-- Removed custom item insertion.  Cumbersome and not needed if u can drag & drop.
-- Align center button is not functional.  Renamed from "reverse buttons"
-- Slots tab for editing character or shared slots.  Old slots section is now display only, still needs work.

-- 1.12.03
-- Korean thanks to Sayclub
-- Disabled code that hid character buttons when docking to main menu.  These have unintended side effects.

-- 1.12.02.05
-- Chinese Simplified & Traditional (Thanks PDI175)
-- Fixed some typos in localization.

-- 1.12.02.04
-- Pet feed on right click should now work.  Tx Kerrang.  Still need to upgrade the pet food category handling itself.

-- 1.12.02.03
-- Fixed onload issue that broke slash commands
-- AutoBar now dismisses with the escape key as it should
-- Added click for config show / hide

-- 1.12.02.02
-- New 1.12 function ClearCursor() called after drag & drop.
-- Juju
-- First cut of tabbed interface for config
-- 24 buttons
-- Arathi Basin Field Ration
-- Config dialog is now draggable
-- Hunter Pet Food & Feeding
-- First cut at blizzard style dialog.  A frustrating thing as texcoords don't act as expected.

-- 1.12.02
-- Dock to is now list based with a drop down.  I will make the drop down pretty some other time.  Needs settings for various bars.
-- Empty Slot button added.
-- Popup Z order increased so its in front of other mods

-- 1.12.01
-- Chinese Simplified & Traditional (Thanks PDI175)
-- TOC updated.
-- Fixed plain buttons bug
-- Improved config layout for Korean.

-- 1.11.16.01
-- Fixed popup click bug.  Apparently mouseup events do not allow casting like click events.  Strange.
-- Disabled some config checkboxes for single category slots.  Fixes crash.
-- Fixed keybinding screwup.
-- Some more hunter pet foods added.  meats aren't done yet.
-- Added a drag handle for the bar.  Left click to lock right click to bring up options.  Handle can be hidden.
-- Slot specific option to disable popup.
-- Slot specific option to rearrange category priority on use.
-- Increased max popup buttons to 12.

-- 1.11.15.04
-- Done button on config panel to avoid confusion.
-- Option to show Category Icon for slots with 0 item count.  Displayed dark & with -- to distinguish them from regular slots.
-- Scale item count, hotKey and Cooldown Clock text beyond size 36 and up to size 72
-- First cut at a popup list for slots with 2 or more available items
-- Added some unsorted items to pet foods.  These will be broken till sorted.
-- Config for popup direction
-- Fixed popup button scaling
-- Popup on modifier key
-- Popup disable
-- Tooltip for popup buttons
-- Added Jungle Remedy
-- Popup hit rect overlap fixed

-- 1.11.14.03
-- New User / deleted wtf config file bug fix.  tx Xavior for finding it.
-- Ahn Qirajh translation for Chinese. Thanks PDI175.
-- Typo fixed
-- Working Korean I think.  Thanks to Sayclub

-- 1.11.13
-- Deutch! Ser gut Teodred!

-- 1.11.12
-- Korean thanks to Sayclub!

-- 1.11.11
-- Ooh, Traditional Chinese thanks to PDI175
-- Roasted Quail added to pet meats
-- Use the highest priority item for the icon.  (ie. the bottom one in the category list).

-- 1.11.10
-- More Drag & Drop: rearrange button categories now as well
-- Drag from inventory into a button's items (or click on an item then click on category button)
-- Potions: Holy Protection, Agility, Strength, Fortitude, Intellect, Wisdom, Defense, Troll Blood

-- 1.11.09
-- Anti-Venom
-- Global smart self cast checkbox
-- Scrolls of Agility, Intellect, Protection, Stamina, Strength, Spirit
-- Food categories for no bonus food so hunters can feed themselves

-- 1.11.08
-- Drag & Drop to rearrange slot category order in the config dialog.
-- Close button added to config
-- Updated some category icons.

-- 1.11.07
-- Row & column sliders in the config panel are now freely slideable.

-- 1.11.06
-- Fixed glitch at 6 columns

-- 1.11.05
-- Friendship Bread, Freshly Squeezed Lemonade, Wildvine Potion, Sagefish Delight, Smoked Sagefish
-- Dirge's Kickin' Chimaerok Chops,
-- Fixed: Essence Mango,

-- 1.11.04
-- Reset to default button for the buttons
-- Hide tooltips option
-- Demonic and Dark Runes, Battle Standards, Invulnerability Potions

-- 1.11.03.01
-- Deathcharger's Reins, Qiraji Mounts
-- Reworked defaults a bit.

-- 1.11.02
-- Mojos of Zanza & essence mangos; arcane, fire, frost, nature, shadow, spell Protection Potions.
-- Dreamless sleep
-- First cut of cooldown.

-- 1.11.01
-- Added new AD oil & sharpening stone.
-- Expand up to 18 buttons.
-- Rolled in the nurfed version's changes for pvp potions
-- Chocolate Square

-- 2006.03.31
-- Minor category changes
-- Last version by Saien
