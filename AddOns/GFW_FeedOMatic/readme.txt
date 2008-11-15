------------------------------------------------------
Fizzwidget Feed-O-Matic
by Gazmik Fizzwidget
http://fizzwidget.com
gazmik@fizzwidget.com
------------------------------------------------------

As my Hunter friends can readily attest, keeping a wild pet can be a full-time job. Why, just feeding the critter when he gets hungry can throw off your routine -- you've got to rummage around in your bags, find a piece of food, make sure it's appropriate for his diet, and check your aim before tossing it to him (lest you accidentally destroy a tasty morsel). So inconvenient! Not to mention potentially dangerous... you don't want to spend so long digging through your bags that you or your pet become someone else's snack.

Never fear, Gazmik Fizzwidget is here with a new gadget to automate all your pet-food-management tasks! My incredible Feed-O-Matic features state-of-the-art nutritional analyzers to make sure your pet's hunger is satisfied with a minimum of fuss, advanced selective logic to make your pet doesn't eat anything you have another use for, and a weight optimizer to make sure the food in your bags stays well organized! Just press the "Feed Now" button and it'll intelligently choose a food and accurately toss it to your pet. This is actually one of the first gizmos I started work on... but because I'm a perfectionist I haven't considered it ready for release until now.

------------------------------------------------------

INSTALLATION: Put this folder into your World Of Warcraft/Interface/AddOns folder and launch WoW.

USAGE:
Makes feeding your pet quick, easy, and fun:
	- Provides several options for a more prominent reminder of when your pet needs feeding.
	- Bind a key to "Feed Pet", and Feed-O-Matic will automatically choose an appropriate food and give it to the pet whenever you press it. 
	- Can use an emote to notify you when it's feeding your pet, with custom randomized messages. See FeedOMatic_Emotes.lua to customize them to your characters!

Helps you manage all the pet food in your inventory:
	- Keeps track of which foods your pet likes more, and prioritizes "better" foods when choosing what to feed the pet. Also remembers what foods your pet has "outgrown", and doesn't choose them in the future (unless you've switched to a pet who might have different tastes).
	- If you're on a quest to collect several of a certain item which also happens to be something your pet likes to eat, Feed-O-Matic can avoid consuming it. (Unless you're carrying more than is needed for the quest or there's nothing else for your pet to eat.)
	- Feed-O-Matic can keep track of what foods are used by the Cooking recipes you know and avoid choosing food you'd rather cook; this behavior can be customized based on the difficulty of the recipies (so, for example, you can either save all cookable food or only save the foods most likely to increase your Cooking skill).
	- If you'd prefer to save the better food (that is, those which provide a "well fed" bonus or other effect when eaten) for yourself, Feed-O-Matic can also avoid it when looking for pet food.
	- All other things being equal, Feed-O-Matic will try to pick foods from smaller stacks, making sure your food supply doesn't take up all your bag space. When your bags get close to full, Feed-O-Matic will start ignoring other criteria and always choosing the smallest stack so that you won't run out of inventory sooner.

CHAT COMMANDS:
	`/feedomatic` (or `/fom` or `/feed`) - Show the Options window.
or:
	`/feedomatic` (or `/fom` or `/feed`) <command>
where <command> can be any of the following:
	`help` - Print this helplist.
	`reset` - Reset to default settings.
	`add <diet> <item link>` - Add food to the list for a specific diet (meat, fish, fruit, etc).
	`remove <diet> <item link>` - Remove food from the list.
	`show <diet>` - Show food list for a specific diet (or for `all`).

CAVEATS, ETC.: 
	- Feed-O-Matic has a database of many known foods, but it's not guaranteed to be comprehensive. You can use the `add`, `remove`, and `show` commands noted above to manage these lists directly. (Please drop me a line if you find a food that should be on there, or discover that something on the list shouldn't be there.) 
	- Currently, Feed-O-Matic can only update its list of which foods you know how to cook when your Cooking window is open. (So if you read a new recipe, we won't know to preserve the ingredients until you open your Cooking window again.)

------------------------------------------------------
VERSION HISTORY

v. 3.0.4 - 2008/10/24
- Includes an update to the PeriodicTable library, fixing an issue in which older versions of the library's datasets would override newer versions... which could cause FOM to ignore certain foods.

v. 3.0.3 - 2008/10/18
- Includes an update to the PeriodicTable library and its food lists:
	- Fixes subcategory/supercategory linkage issues that caused FOM to ignore certain foods (such as Conjured Mana Biscuit and Naaru Ration).
	- Includes all (currently known to Wowhead) new foods from Wrath of the Lich King content.
- Reorganized the Food Preferences panel slightly to account for Wrath of the Lich King foods having more possible cooking products. (Don't like mammoth? Try cooking it differently!)
- Fixed an error that could occur when FOM chooses the next food to use.
- Fixed an issue where FOM wouldn't choose a food (and thus feeding would be unavailable) after reloading the UI.
- Fixed an issue where category headers would inconsistently appear grayed out in the Food Preferences list.
- Items that aren't in the PeriodicTable categories corresponding to the six possible pet diets (i.e. not edible by pets) will no longer show in the Food Preferences list.
- Added more random feeding emotes thanks to the commenters at maniasarcania.com. Feeding emotes can now be made specific to categories of foods (specified by PeriodicTable sets).

v. 3.0.2 - 2008/10/15
- Fixed an bug causing us to ignore diets beyond the first for pets with multiple diets.
- Fixed an error when attempting to play pet hungry sounds.
- Added French random emotes by Laumac from WoWInterface.com.

v. 3.0.1 - 2008/10/14
- Fixed a bug where clicking foods in the new Food Preferences panel (see 3.0 release notes below) wouldn't show them as excluded/unchecked.
- When a category is excluded/unchecked in said panel, the foods within it appear grayed out.

v. 3.0 - 2008/10/14
- Updated for compatibility with WoW Patch 3.0 and Wrath of the Lich King.
- Rebuilt FOM's system for choosing foods to feed your pet:
	- Our database of valid pet foods now comes from the PeriodicTable library.
	- Priority order for choosing foods is based (in part) on PeriodicTable sets (conjured, basic, or bonus foods, etc.)
	- There's now a Food Preferences sub-panel under GFW Feed-O-Matic in the Interface Options window.
		- In it, all valid pet foods your WoW client has seen are listed by category.
		- The order of categories and foods in the list reflects the priority order for choosing foods: those nearer the top of the list will be picked before those below.
		- Individual foods can be unchecked in the list to prevent FOM from feeding them to your pet.
		- Entire categories can also be unchecked, which will prevent FOM from using any food of that category (even ones you haven't seen yet). By default, only the "Well Fed" foods are disabled, so be sure to visit the list if you want to exclude other foods.
		- The list can be filtered to show only relevant foods for your pet (or for a pet of about your level, if you don't have a pet summoned at the moment) or only foods you're currently carrying.
		- If a food can be cooked, the list shows information about each of the the Cooking recipe(s) that use it: whether you know the recipe, its difficulty (i.e. orange, yellow, green or gray in the Cooking window), and the food produced.
		- This list replaces the "avoid bonus foods" and "avoid cooking foods" options in previous releases.
- The "keep bag space open" option from previous releases has been removed: given multiple stacks of the same food, FOM will now always consume the smaller stack first so as to free up bag space more quickly.
- Fixed several issues which caused the "Avoid foods needed for quests" option to fail.
- Added numerous random feeding emotes -- thanks to Mania and the creative commenters at http://maniasarcania.com!
- Locale issues:
	- The random text added to feeding emotes (e.g. "Yum!", "Good boy!", etc) is now localizable. See the FeedOMatic_Emotes.lua file for details. (Thanks Virshan for a few Spanish.)
	- Added Korean localization by Boddalhee of Deathwing (KR).
	- Added Spanish localization by Javier Melo. 
	- Added basic locale support for Russian, and updated basic locale support for French and German, based on Wowhead's multilingual database. (That is, enough translations for all features to work the same as in English, but no localized UI text.)
		- Translations are missing for the new and renamed beast families (in WoW 3.0 / WotLK), so the family-specific hungry sounds don't currently work in locales other than English.
	
v. 2.4.1 - 2008/04/11
- Fixed an issue where some checkboxes in the options UI weren't having an effect.
- Fixed an issue with the Save for Cooking setting not being applied properly.
- Added several new foods from recent patches to the default list.

v. 2.4 - 2008/03/24
- Updated for compatibility with WoW Patch 2.4.
- Configuration controls are moved into a pane in the new Interface Options panel provided by the default UI. Key binding moved back into the default UI's Key Bindings panel.
- The option to avoid foods used in Cooking recipes you don't know yet is now independent of that for which level of known recipes to avoid foods from.

v. 2.3.1 - 2007/12/01
- Added new foods introduced in WoW Patch 2.3.
- Fixed an issue with setting key bindings that include modifier keys.
- Added "Unbind Key" buttons to the Options window for removing FOM's key bindings.
- The `diet` argument to the `/fom remove` command is now optional; if omitted, the specified food will be removed from any and all diets it's listed in. (e.g. `/fom remove [Delicious Chocolate Cake]` is now the same as `/fom remove bread [Delicious Chocolate Cake]`.)

v. 2.3 - 2007/11/13
- Updated TOC to indicate compatibility with WoW Patch 2.3.
- Fixed an issue where FOM would report being unable to find your Feed Pet spell upon login; we now wait until the spellbook is more likely to have been loaded by the game before checking.

v. 2.2.1 - 2007/10/12
- Added a workaround for a sound bug in WoW Patch 2.2; "hungry" sounds should be working again.

v. 2.2 - 2007/09/25
- Updated TOC to indicate compatibility with WoW Patch 2.2.
- Fixed an off-by-one error in calculating which foods are edible by the current pet and which provide the most happiness.
- Added a few foods introduced in the Burning Crusade and Patch 2.1 to the default list.

v. 2.1.1 - 2007/07/20
- Fixed an issue where FOM would mistakenly indicate that no food is in your bags upon zoning, logging in, dismounting, etc.
- Typing `/fom debug` will toggle the display of additional info in the tooltip when mousing over the pet happiness icon, showing the list of the next several foods FOM will attempt to use. Check this if FOM is using foods you don't expect it to (or failing to find foods you do).
- Fixed an error when pressing the Feed Pet keybinding while your pet is dead or dismissed.
- We no longer show a chat window message or emote if feeding was unsuccessful (e.g. if the pet is out of range).
- [Underspore Pod] is now treated as an exception to the "foods with bonus effects" rule, since it's easy to summon more. (Yeah, it's kinda hackish. A better UI for customizing food preferences is coming in a future update.)
- Added Traditional Chinese localization.
- Uses a simpler, more reliable means of hooking item tooltips.
- Added support for the Ace [AddonLoader][] -- when that addon is present, Feed-O-Matic will only load for Hunter characters.
[AddonLoader]: http://www.wowace.com/wiki/AddonLoader

v. 2.1 - 2007/05/22
- Updated TOC for WoW Patch 2.1.
- Added family-specific "hungry" sounds for the new pet species introduced in the Burning Crusade.

v. 2.0.6 - 2007/02/17
- Fixed an error that would occur when the keyring is updated. (There's no food there, anyway.)
- Fixed some issues with hooking tooltips when other tooltip-modifying addons are present.
- Added Underspore Pod (fungus) to the food list.

v. 2.0.5 - 2007/01/31
- Fixed several bugs in the food-choosing algorithm which tended to result in Feed-O-Matic choosing items you've told it to avoid.
- Eliminated the "fall back to otherwise-avoided foods if nothing else available" preference. Instead, there's now an error message if you press the feed button when the only foods available are items you've told Feed-O-Matic to avoid. Hold Alt while pressing your Feed Pet keybinding (or Alt-left-click the happiness icon) to feed one of these items anyway.
- Mousing over the pet happiness icon now shows the next food to be used.
- We now keep a list of all foods known to be used in Cooking; the "Save foods used in Cooking recipes" option now has an additional setting for foods used in recipes your character hasn't yet learned.
- You can now set two different key bindings for each action in Feed-O-Matic's Options panel.
- Cut down on CPU usage a bit -- if an inventory update affects only your quiver / ammo pouch, we'll assume that nothing related to pet foods has changed.
- Reorganized the Options panel and reworded some options for better clarity.
- Fixed a bug that kept the `/fom add` and `/fom remove` commands from working properly.
- Removed chat commands for configuation settings which are present in the Options panel.
- Added Conjured Croissant to the built-in foods list.

v. 2.0.4 - 2007/01/14
- Simplified code for adding text to item tooltips thanks to new API in WoW 2.0.3 -- this should fix issues with the same info being added to a tooltip multiple times or sometimes being missing, as well as allow us to work with more third-party addons that show item tooltips.

v. 2.0.3 - 2007/01/11
- Updated for compatibility with WoW Patch 2.0.3 and the Burning Crusade release.
- Added a number of foods to the built-in list (thanks to Griffon Silvertongue).

v. 2.0.2 - 2006/12/08
- Fixed error (introduced in 2.0.1) when mousing over items.

v. 2.0.1 - 2006/12/07
- Fixed posible blocked action errors in tooltip-hooking code.

v. 2.0 - 2006/12/05
- Redesigned to use new secure action functionality in WoW 2.0 (and the Burning Crusade Closed Beta):
 	- Feed-O-Matic now maintains a special action button for feeding your pet a specific item from your bags. Whenever your inventory changes, Feed-O-Matic will (if necessary) choose an appropriate food for your pet's next feeding and set up the button to use it.
	- To use this action button, click the pet happiness icon or bind a key...
	- Due to limitations in WoW 2.0's key binding interface, key bindings for Feed-O-Matic are found in its own Options window instead of the normal Key Bindings window. To show Feed-O-Matic's options window, type `/fom` or right-click the pet happiness icon.
	- It's no longer possible to feed your pet from a custom chat command, so `/fom feed` has been removed. (It is possible to feed your pet in a macro, but this requires a static choice of foods: e.g. `/cast Feed Pet /use Roasted Quail`.)
	- The pet happiness icon will darken if Feed-O-Matic can't find any appropriate food. Mousing over the buttons shows why we can't find food for your pet (either there's nothing in your inventory your pet will eat, or you've configured Feed-O-Matic to avoid certain foods and those are the only ones left).
- We now automatically detect whether a food provides a bonus effect when eaten by players (e.g. a Stamina buff in addition to the health gained), instead of needing to be told which foods fall into this category. If you find that Feed-O-Matic fails to detect such a food, please let us know! 
- Added many foods from Burning Crusade content to the default list. If you find more, please let us know!
- NOTE: The new tameable beast families don't yet have specific sounds for when they're hungry, so they'll just play a bell sound instead. (If you'd like to help pick some, please contact us with the paths of sound files in the WoW MPQs that you think would be appropriate: e.g. "Sound\Creature\OWl\OwlPreAggro.wav".)

v. 12000.2 - 2006/10/27
- Now always prefers conjured foods if available when feeding a pet that can eat them. (This was supposed to have been the case before, but the implementation turned out to be unreliable.)
- Fixed some issues which could result in Feed-O-Matic feeding the pet a food you'd told it to avoid, even if the "fall back" option was turned off. Also, a clearer error message is given if "fall back" is off and we can't find any allowed foods.
- The various reminder options for when your pet needs feeding (flashing the happiness icon, text messages, sounds) are now suppressed while you or your pet is in combat or if your pet is dead.
- Feed-O-Matic posts its own error message if you attempt use it to feed your pet while in combat. (Instead of trying to feed the pet anyway, causing WoW itself to post an error message.)
- Added a number of items to the default foods list (including some holiday treats and the new level 55 mage-conjured bread).

See http://fizzwidget.com/notes/feedomatic/ for older release notes.
