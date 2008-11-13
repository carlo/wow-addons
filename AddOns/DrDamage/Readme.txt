You can report bugs you find in #wowace @ irc.freenode.net to rw3/Gagorian or alternatively email me at gagorian@gmail.com
I'm happy to accept any help anyone wants to provide.

*** If any damage/healing calculation is incorrect, please report it. Provide as much information as possible. ***


Dr. Damage is a lighter version of TheoryCraft. 
It display calculated average damage/healing of abilities with talents, gear and buffs included on your actionbar buttons. 
The addon will also add various information to the default tooltips in your spellbook and on the actionbar.


'''Slash Commands:'''

/drdmg or /drdamage


'''Functionality:'''

* Supports all classes.
* Actionbar addons supported: Default, Bartender3, Bongos and Bongos2, CT_BarMod, DAB, Nurfed AB, CogsBar, InfiniBar and FlexBar
* Places damage/healing text of the stat of your choice on the actionbar buttons
* Can also place the text on macro slots if macros have their tooltips set to the spell/action with #showtooltip spellname
* Loads of damage and healing statistics from action tooltips on the actionbar and in the spellbook
* Active scanning of buffs on you / debuffs on target that affect damage/healing.



'''More information about functionality:'''

* Uses WoW API to grab spell damage, crit chance, mana regeneration and bonuses received from gear.
* Adaptable damage/healing calculation engine used for all calculations
* Easy table design to add/modify talent effects, spells and buffs/debuffs
* Manual modification of the damage and crit used to calculate (you can test how much that +n spelldamage or healing would increase your spells different calculated values)



'''FAQ:'''

-How can I get the Dr.Damage tooltip info or actionbar text on macro buttons?
* Modify your macro to show the blizzard tooltip by inserting the line: "#showtooltip Spellname" or "#showtooltip Spellname(Rank x)"

-Are you planning to make an UI for configuration?
* Dr. Damage has a FuBar plugin capability for easy configuration. DeuceCommander works as well.



KNOWN ISSUES:

*Improved divine spirit doesn't affect some spells (dark pact, lifetap at least) even if character screen displays it. DrDamage will report too high values. REASON: Blizzard bug. SOLUTION: None.
*Impossible to detect if the warlock curse (CoS/CoE) has been improved with malediction. REASON: Tooltip doesn't display it. SOLUTION: None.