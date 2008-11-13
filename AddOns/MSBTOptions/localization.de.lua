-------------------------------------------------------------------------------------
-- Title: MSBT Options German Localization
-- Author: Mik
-- German Translation by: Farook
-------------------------------------------------------------------------------------

-- Don't do anything if the locale isn't German.
if (GetLocale() ~= "deDE") then return; end

-- Local reference for faster access.
local MSBTLocale = MikSBT.Locale;


-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------


------------------------------
-- Interface messages
------------------------------

MSBTLocale.MSG_NEW_PROFILE					= "Neues Profil";
MSBTLocale.MSG_PROFILE_ALREADY_EXISTS		= "Profil besteht bereits.";
MSBTLocale.MSG_INVALID_PROFILE_NAME			= "Ung\195\188ltiger Profil-Name.";
MSBTLocale.MSG_NEW_SCROLL_AREA				= "Neues Scroll-Bereich";
MSBTLocale.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Name f\195\188r Scroll-Bereich existiert bereits.";
MSBTLocale.MSG_INVALID_SCROLL_AREA_NAME		= "Ung\195\188ltiger Name f\195\188r Scroll-Bereich.";
MSBTLocale.MSG_ACKNOWLEDGE_TEXT				= "Bist du sicher, dass du diese Aktion durchführen willst?";
--MSBTLocale.MSG_NORMAL_PREVIEW_TEXT			= "Normal";
--MSBTLocale.MSG_INVALID_SOUND_FILE			= "Sound must be a .mp3 or .wav file.";
MSBTLocale.MSG_NEW_TRIGGER					= "Neuer Ausl\195\182ser";
--MSBTLocale.MSG_TRIGGER_CLASSES				= "Trigger Classes";
--MSBTLocale.MSG_MAIN_CONDITIONS				= "Main Conditions";
--MSBTLocale.MSG_SECONDARY_CONDITIONS			= "Secondary Conditions";
--MSBTLocale.MSG_SKILLS						= "Skills";
--MSBTLocale.MSG_SKILL_ALREADY_EXISTS			= "Skill name already exists.";
--MSBTLocale.MSG_INVALID_SKILL_NAME			= "Invalid skill name.";


------------------------------
-- Class Names.
------------------------------

local obj = MSBTLocale.CLASS_NAMES;
obj["DRUID"]	= "Druide";
obj["HUNTER"]	= "J\195\164ger";
obj["MAGE"]		= "Magier";
obj["PALADIN"]	= "Paladin";
obj["PRIEST"]	= "Priester";
obj["ROGUE"]	= "Schurke";
obj["SHAMAN"]	= "Schamane";
obj["WARLOCK"]	= "Hexenmeister";
obj["WARRIOR"]	= "Krieger";


------------------------------
-- Interface tabs
------------------------------

-- #2, 3, and 4 need additional translation.
obj = MSBTLocale.TABS;
obj[1] = { label="Allgemein", tooltip="Allgemeine Optionen anzeigen."};
obj[2] = { label="Scrollbereiche", tooltip="Optionen f\195\188r das Erstellen, L\195\182schen, und Konfigurieren der Scroll-Bereiche anzeigen.\n\nMouse over the icon buttons for more information."};
obj[3] = { label="Ereignisse", tooltip="Optionen f\195\188r eingehende, ausgehende und benachrichtigende Ereignisse anzeigen.\n\nMouse over the icon buttons for more information."};
obj[4] = { label="Ausl\195\182ser", tooltip="Optionen f\195\188r das Ausl\195\182ser-System anzeigen.\n\nMouse over the icon buttons for more information."};
--obj[5] = { label="Spam Control", tooltip="Display options for controlling spam."};
--obj[6] = { label="Cooldowns", tooltip="Display options for cooldown notifications."};
--obj[7] = { label="Skill Icons", tooltip="Display options for skill icons.\n\nThis tab will be disabled if the optional MSBTIcons module is not present."};


------------------------------
-- Interface checkboxes
------------------------------

-- inheritField needs additional translation.
obj = MSBTLocale.CHECKBOXES;
obj["enableMSBT"]				= { label="Mik's Scrolling Battle Text aktivieren", tooltip="MSBT aktivieren."};
--obj["stickyCrits"]				= { label="Sticky Crits", tooltip="Display crits using the sticky style."};
--obj["gameDamage"]				= { label="Game Damage", tooltip="Display blizzard's default damage above the enemy's heads."};
--obj["gameHealing"]				= { label="Game Healing", tooltip="Display blizzard's default healing above the target's heads."};
--obj["enableSounds"]				= { label="Sounds aktivieren", tooltip="Play sounds that are assigned to events and triggers."};
obj["colorPartialEffects"]		= { label="Partielle Effekte einf\195\164rben", tooltip="Partiellen effekte die festgelegten farben."};
--obj["crushing"]					= { label="Crushing Blows", tooltip="Display the crushing blows trailer."};
--obj["glancing"]					= { label="Glancing Hits", tooltip="Display the glancing hits trailer."};
--obj["absorb"]					= { label="Partial Absorbs", tooltip="Display partial absorb amounts."};
--obj["block"]					= { label="Partial Blocks", tooltip="Display partial block amounts."};
--obj["resist"]					= { label="Partial Resists", tooltip="Display partial resist amounts."};
--obj["vulnerability"]			= { label="Vulnerability Bonuses", tooltip="Display vulnerabliity bonus amounts."};
--obj["overheal"]					= { label="Overheals", tooltip="Display overhealing amounts."};
--obj["colorDamageAmounts"]		= { label="Color Damage Amounts", tooltip="Apply specified colors to damage amounts."};
--obj["colorDamageEntry"]			= { tooltip="Enable coloring for this damage type."};
obj["enableScrollArea"]			= { tooltip="Scroll-Bereich aktivieren."};
obj["inheritField"]				= { label="\195\156bernehmen", tooltip="Inherit the field's value.  Uncheck to override."};
obj["stickyEvent"]				= { label="Immer Sticky-Style", tooltip="Ereignis im Sticky-Style angezeigt."};
obj["enableTrigger"]			= { tooltip="Ausl\195\182ser aktivieren."};
--obj["allPowerGains"]			= { label="ALL Power Gains", tooltip="Display all power gains including those that are not reported to the combat log.\n\nWARNING: This option is very spammy and will ignore the power threshold and throttling mechanics.\n\nNOT RECOMMENDED."};
--obj["hyperRegen"]				= { label="Hyper Regen", tooltip="Display power gains during fast regen abilities such as Evocation and Spirit Tap.\n\nNOTE: The gains shown will not be throttled."};
--obj["abbreviateSkills"]			= { label="Abbreviate Skills", tooltip="Abbreviates skill names (English only).\n\nThis can be overriden by each event with the %sl event code."};
--obj["hideSkills"]				= { label="Hide Skills", tooltip="Don't display skill names for incoming and outgoing events.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %s event code to be ignored."};
--obj["hideNames"]				= { label="Hide Names", tooltip="Don't display unit names for incoming and outgoing events.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %n event code to be ignored."};
obj["allClasses"]				= { label="Alle Klassen"};
--obj["enableCooldowns"]			= { label="Enable Cooldowns", tooltip="Display notifications when cooldowns complete."};
--obj["cooldownIcons"]			= { label="Enable Cooldown Icons", tooltip="Display an icon next to the skill that has cooled down."};
obj["exclusiveSkills"]			= { label="Exclusive Skill Names", tooltip="Only show skill names when an icon is not available."};


------------------------------
-- Interface dropdowns
------------------------------

obj = MSBTLocale.DROPDOWNS;
obj["profile"]				= { label="Aktuelles Profil:", tooltip="Legt das aktuelle Profil fest."};
obj["normalFont"]			= { label="Schrift - Normal:", tooltip="Legt die Schriftart f\195\188r Nicht-kritische Treffer."};
obj["critFont"]				= { label="Schrift - Kritisch:", tooltip="Legt die Schriftart f\195\188r kritische Treffer."};
obj["normalOutline"]		= { label="Kontur - Normal:", tooltip="Legt die Kontur f\195\188r Nicht-kritische Treffer."};
obj["critOutline"]			= { label="Kontur - Kritisch:", tooltip="Legt die Kontur f\195\188r kritische Treffer."};
--obj["sound"]				= { label="Sound:", tooltip="Selects the sound to play when the event occurs."};
obj["scrollArea"]			= { label="Scrollbereich:", tooltip="W\195\164hlt den zu konfigurierenden Scrollbereich aus."};
--obj["animationStyle"]		= { label="Animations:", tooltip="The animation style for non-sticky animations in the scroll area."};
--obj["stickyAnimationStyle"]	= { label="Sticky Animations:", tooltip="The animation style for sticky animations in the scroll area."};
--obj["direction"]			= { label="Direction:", tooltip="The direction of the animation."};
--obj["behavior"]				= { label="Behavior:", tooltip="The behavior of the animation."};
obj["textAlign"]			= { label="Text ausrichten:", tooltip="Die Ausrichtung des Textes f\195\188r den Animation."};
obj["eventCategory"]		= { label="Ereignis-Kategorie:", tooltip="Die Kategorie der zu konfigurienden Ereignisse."};
obj["outputScrollArea"]		= { label="Scrollbereich:", tooltip="Den Scrollbereich f\195\188r die Textausgabe ausw\195\164hlen."};
--obj["conditionType"]		= { label="Condition Type:"};


------------------------------
-- Interface buttons
------------------------------

obj = MSBTLocale.BUTTONS;
obj["copyProfile"]				= { label="Kopieren", tooltip="Kopiert das aktuelle Profil auf ein neues Profil, dessen Namen du selbst bestimmst."};
obj["resetProfile"]				= { label="Zur\195\188cksetzen", tooltip="Setzt das Profil auf die Standardeinstellungen zur\195\188ck."};
obj["deleteProfile"]			= { label="L\195\182schen", tooltip="L\195\182scht das Profil."};
--obj["masterFont"]				= { label="Master Fonts", tooltip="Allows you to setup the master font settings which will be inherited by all scroll areas and events within them, unless overridden."};
obj["partialEffects"]			= { label="Partielle Effekte", tooltip="Erlaubt dir festzulegen welche partiellen Effekte angezeigt werden sollen, ob sie eingef\195\164rbt werden sollen, und wenn ja in welcher Farbe."};
--obj["damageColors"]				= { label="Damage Colors", tooltip="Allows you to setup whether or not amounts are color coded by damage type and what colors to use for each type."};
obj["inputOkay"]				= { label=OKAY, tooltip="Eingaben \195\188bernehmen."};
obj["inputCancel"]				= { label=CANCEL, tooltip="Eingaben zur\195\188cksetzen."};
obj["genericSave"]				= { label=SAVE, tooltip="Speichert die \195\132nderungen."};
obj["genericCancel"]			= { label=CANCEL, tooltip="Bricht die \195\132nderungen."};
obj["addScrollArea"]			= { label="Nueus Scrollbereich", tooltip="Einen neuen Scrollbereich ausw\195\164hlen, dem Ereignisse und Ausl\195\182ser zugewiesen werden k\195\182nnen."};
--obj["configScrollAreas"]		= { label="Scrollbereiche konfigurieren", tooltip="Configure the normal and sticky animation styles, text alignment, scroll width/height, and location of the scroll areas."};
obj["editScrollAreaName"]		= { tooltip="Klicken, um den Namen des Scrollbereichs zu bearbeiten."};
obj["scrollAreaFontSettings"]	= { tooltip="Klicken, um die Schrifteinstellungen des Scrollbereichs zu bearbeiten, welche von allen Ereignissen dieses Bereichs \195\188bernommen werden, sofern sie nicht \195\188berschrieben werden."};
obj["deleteScrollArea"]			= { tooltip="Klicken, um den Scrollbereich zu l\195\182schen."};
obj["scrollAreasPreview"]		= { label="Vorschau", tooltip="Eine Vorschau auf die \195\132nderungen."};
--obj["toggleAll"]				= { label="Toggle All", tooltip="Toggle the enable state of all events in the selected category."};
--obj["moveAll"]					= { label="Move All", tooltip="Moves all of the events in the selected category to the specified scroll area."};
obj["eventFontSettings"]		= { tooltip="Klicken, um die Schrifteinstellungen f\195\188r das Event zu bearbeiten."};
--obj["eventSettings"]			= { tooltip="Click to edit the event settings such as the output scroll area, output message, sound, etc."};
--obj["customSound"]				= { tooltip="Click to enter a custom sound file." };
obj["addTrigger"]				= { label="Neuen Ausl\195\182ser hinzuf\195\188gen", tooltip="Einen neuen Ausl\195\182ser hinzuf\195\188gen."};
obj["triggerSettings"]			= { tooltip="Klicken, um die Ausl\195\182ser-Einstellungen zu konfigurieren."};
obj["deleteTrigger"]			= { tooltip="Klicken, um diesen Ausl\195\182ser zu l\195\182schen."};
--obj["editTriggerClasses"]		= { tooltip="Click to edit the classes the trigger applies to."};
--obj["addMainCondition"]			= { label="Add Condition", tooltip="When ANY of these conditions apply, the secondary conditions are checked."};
--obj["addSecondaryCondition"]	= { label="Add Condition", tooltip="After ANY of the main conditions occur, ALL of these conditions are checked."};
--obj["editCondition"]			= { tooltip="Click to edit the condition."};
--obj["deleteCondition"]			= { tooltip="Click to delete the condition."};
obj["triggerEventTypes"]		= { label="Ausl\195\182ser: Ereignisarten", tooltip="Legt fest, nach welchen Ereignisarten gesucht werden soll."};
--obj["throttleList"]				= { label="Throttle List", tooltip="Set custom throttle times for specified skills."};
--obj["mergeExclusions"]			= { label="Merge Exclusions", tooltip="Prevent specified skills from being merged."};
--obj["skillSuppressions"]		= { label="Skill Suppressions", tooltip="Suppress skills by their name."};
--obj["skillSubstitutions"]		= { label="Skill Substitutions", tooltip="Substitute skill names with customized values."};
--obj["addSkill"]					= { label="Add Skill", tooltip="Add a new skill to the list."};
--obj["deleteSkill"]				= { tooltip="Click to delete the skill."};
--obj["cooldownExclusions"]		= { label="Cooldown Exclusions", tooltip="Specify skills that will ignore cooldown tracking."};


------------------------------
-- Interface editboxes
------------------------------

obj = MSBTLocale.EDITBOXES;
--obj["copyProfile"]		= { label="Gib einen neuen Profilnamen ein:", tooltip="Der Name des neuen Profils auf den das eben gew\195\164hlte Profil kopiert werden soll."};
--obj["scrollAreaName"]	= { label="Neuen Scrollbereich-Namen eingeben:", tooltip="Neuer Name f\195\188r den Scrollbereichs."};
--obj["xOffset"]			= { label="X Offset:", tooltip="The X offset of the selected scroll area."};
--obj["yOffset"]			= { label="Y Offset:", tooltip="The Y offset of the selected scroll area."};
--obj["eventMessage"]		= { label="Ausgabenachricht eingeben:", tooltip="Die Nachricht die angezeigt wird, wenn das Ereignis vorkommt."};
--obj["soundFile"]		= { label="Sound filename:", tooltip="The name of the sound file to play when the event occurs."};
--obj["iconSkill"]		= { label="Icon Skill:", tooltip="The name of a skill whose icon will be displayed when the event occurs."};
--obj["conditionParam"]	= { label="Parameter:", tooltip="The parameter for the selected condition type."};
--obj["skillName"]		= { label="Skill name:", tooltip="The name of the skill to add."};
--obj["substitutionText"]	= { label="Substition text:", tooltip="The text to be substituted for the skill name."};


------------------------------
-- Interface sliders
------------------------------

obj = MSBTLocale.SLIDERS;
obj["animationSpeed"]		= { label="Animationsgeschwindigkeit", tooltip="Die Master Geschwindigkeit der Animation."};
obj["normalFontSize"]		= { label="Normale Schriftgr\195\182\195\159e", tooltip="Die Schriftgr\195\182\195\159e f\195\188r Nicht-kritische Treffer."};
--obj["normalFontOpacity"]	= { label="Normal Opacity", tooltip="Sets the font opacity for non-crits."};
obj["critFontSize"]			= { label="Kritische Schriftgr\195\182\195\159e", tooltip="Die Schriftgr\195\182\195\159e f\195\188r kritische Treffer."};
--obj["critFontOpacity"]		= { label="Crit Opacity", tooltip="Sets the font opacity for crits."};
obj["scrollHeight"]			= { label="Scroll-H\195\182he", tooltip="Die H\195\182he des Scrollbereich."};
obj["scrollWidth"]			= { label="Scroll Width", tooltip="The width of the scroll area."};
obj["scrollAnimationSpeed"]	= { label="Geschwindigkeit", tooltip="Die Geschwindigkeit der Animation des Scrollbereich."};
--obj["conditionParam"]		= { label="Parameter", tooltip="The parameter for the selected condition type."};
--obj["powerThreshold"]		= { label="Power Threshold", tooltip="The threshold that power gains must exceed to be displayed."};
--obj["healThreshold"]		= { label="Heal Threshold", tooltip="The threshold that heals must exceed to be displayed."};
--obj["damageThreshold"]		= { label="Damage Threshold", tooltip="The threshold that damage must exceed to be displayed."};
--obj["dotThrottleTime"]		= { label="DoT Throttle Time", tooltip="The number of seconds to throttle DoTs."};
--obj["hotThrottleTime"]		= { label="HoT Throttle Time", tooltip="The number of seconds to throttle HoTs."};
--obj["powerThrottleTime"]	= { label="Power Throttle Time", tooltip="The number of seconds to throttle power changes."};
--obj["powerThrottleTime"]	= { label="Throttle Time", tooltip="The number of seconds to throttle power changes."};
--obj["skillThrottleTime"]	= { label="Throttle Time", tooltip="The number of seconds to throttle the skill."};
--obj["cooldownThreshold"]	= { label="Cooldown Threshold", tooltip="Skills with a cooldown less than the specified number of seconds will not be displayed."};


------------------------------
-- Event categories
------------------------------
obj = MSBTLocale.EVENT_CATEGORIES;
obj[1] = "Eingehend player";
obj[2] = "Eingehend begleiter";
obj[3] = "Ausgehend player";
obj[4] = "Ausgehend begleiter";
obj[5] = "Benachrichtigung";


------------------------------
-- Event codes
------------------------------

obj = MSBTLocale.EVENT_CODES;
--obj["DAMAGE_TAKEN"]			= "%a - Amount of damage taken.\n";
--obj["HEALING_TAKEN"]		= "%a - Amount of healing taken.\n";
--obj["DAMAGE_DONE"]			= "%a - Amount of damage done.\n";
--obj["HEALING_DONE"]			= "%a - Amount of healing done.\n";
--obj["ENERGY_AMOUNT"]		= "%a - Amount of energy.\n";
--obj["CP_AMOUNT"]			= "%a - Amount of combo points you have.\n";
--obj["HONOR_AMOUNT"]			= "%a - Amount of honor.\n";
--obj["REP_AMOUNT"]			= "%a - Amount of reputation.\n";
--obj["SKILL_AMOUNT"]			= "%a - Amount of points you have in the skill.\n";
--obj["EXPERIENCE_AMOUNT"]	= "%a - Amount of experience you gained.\n";
--obj["ATTACKER_NAME"]		= "%n - Name of the attacker.\n";
--obj["HEALER_NAME"]			= "%n - Name of the healer.\n";
--obj["ATTACKED_NAME"]		= "%n - Name of the attacked unit.\n";
--obj["HEALED_NAME"]			= "%n - Name of the healed unit.\n";
--obj["BUFFED_NAME"]			= "%n - Name of the buffed unit.\n";
--obj["SKILL_NAME"]			= "%s - Name of the skill.\n";
--obj["SPELL_NAME"]			= "%s - Name of the spell.\n";
--obj["DEBUFF_NAME"]			= "%s - Name of the debuff.\n";
--obj["BUFF_NAME"]			= "%s - Name of the buff.\n";
--obj["ITEM_BUFF_NAME"]		= "%s - Name of the item buff.\n";
--obj["EXTRA_ATTACKS"]		= "%s - Name of skill granting the extra attacks.\n";
--obj["SKILL_LONG"]			= "%sl - Long form of %s. Used to override abbreviation for the event.\n";
--obj["DAMAGE_TYPE_TAKEN"]	= "%t - Type of damage taken.\n";
--obj["DAMAGE_TYPE_DONE"]		= "%t - Type of damage done.\n";
--obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Name of the source of the damage (falling, drowning, lava, etc...)\n";
--obj["FACTION_NAME"]			= "%e - Name of the faction.\n";
--obj["UNIT_KILLED"]			= "%e - Name of the unit killed.\n";
--obj["SHARD_NAME"]			= "%e - Localized name of the soul shard.\n";
--obj["EMOTE_TEXT"]			= "%e - The text of the emote.\n";
--obj["MONEY_TEXT"]			= "%e - The money gained text.\n";
--obj["COOLDOWN_NAME"]		= "%e - The name of skill that is ready.\n"
--obj["POWER_TYPE"]			= "%p - Type of power (energy, rage, mana).\n";


------------------------------
-- Incoming events
------------------------------

obj = MSBTLocale.INCOMING_PLAYER_EVENTS;
--obj[1]	= { label="Melee Hits", tooltip="Enable incoming melee hits."};
--obj[2]	= { label="Melee Crits", tooltip="Enable incoming melee crits."};
--obj[3]	= { label="Melee Misses", tooltip="Enable incoming melee misses."};
--obj[4]	= { label="Melee Dodges", tooltip="Enable incoming melee dodges."};
--obj[5]	= { label="Melee Parries", tooltip="Enable incoming melee parries."};
--obj[6]	= { label="Melee Blocks", tooltip="Enable incoming melee blocks."};
--obj[7]	= { label="Melee Absorbs", tooltip="Enable absorbed incoming melee damage."};
--obj[8]	= { label="Melee Immunes", tooltip="Enable incoming melee damage you are immune to."};
--obj[9]	= { label="Skill Hits", tooltip="Enable incoming skill hits."};
--obj[10]	= { label="Skill Crits", tooltip="Enable incoming skill damage."};
--obj[11]	= { label="Skill DoTs", tooltip="Enable incoming skill damage over time."};
--obj[12]	= { label="Skill Misses", tooltip="Enable incoming skill misses."};
--obj[13]	= { label="Skill Dodges", tooltip="Enable incoming skill dodges."};
--obj[14]	= { label="Skill Parries", tooltip="Enable incoming skill parries."};
--obj[15]	= { label="Skill Blocks", tooltip="Enable incoming skill blocks."};
--obj[16]	= { label="Spell Resists", tooltip="Enable incoming spell resists."};
--obj[17]	= { label="Skill Absorbs", tooltip="Enable absorbed damage from incoming skills."};
--obj[18]	= { label="Skill Immunes", tooltip="Enable incoming skill damage you are immune to."};
--obj[19]	= { label="Skill Reflects", tooltip="Enable incoming skill damage you reflected."};
--obj[20]	= { label="Spell Interrupts", tooltip="Enable incoming spell interrupts."};
--obj[21]	= { label="Heals", tooltip="Enable incoming heals."};
--obj[22]	= { label="Crit Heals", tooltip="Enable incoming crit heals."};
--obj[23]	= { label="Heals Over Time", tooltip="Enable incoming heals over time."};
--obj[24]	= { label="Environmental Damage", tooltip="Enable environmental (falling, drowning, lava, etc...) damage."};

obj = MSBTLocale.INCOMING_PET_EVENTS;
--obj[1]	= { label="Melee Hits", tooltip="Enable your pet's incoming melee hits."};
--obj[2]	= { label="Melee Crits", tooltip="Enable your pet's incoming melee crits."};
--obj[3]	= { label="Melee Misses", tooltip="Enable your pet's incoming melee misses."};
--obj[4]	= { label="Melee Dodges", tooltip="Enable your pet's incoming melee dodges."};
--obj[5]	= { label="Melee Parries", tooltip="Enable your pet's incoming melee parries."};
--obj[6]	= { label="Melee Blocks", tooltip="Enable your pet's incoming melee blocks."};
--obj[7]	= { label="Melee Absorbs", tooltip="Enable your pet's absorbed incoming melee damage."};
--obj[8]	= { label="Melee Immunes", tooltip="Enable melee damage your is pet immune to."};
--obj[9]	= { label="Skill Hits", tooltip="Enable your pet's incoming skill hits."};
--obj[10]	= { label="Skill Crits", tooltip="Enable your pet's incoming skill crits."};
--obj[11]	= { label="Skill DoTs", tooltip="Enable your pet's incoming skill damage over time."};
--obj[12]	= { label="Skill Misses", tooltip="Enable your pet's incoming skill misses."};
--obj[13]	= { label="Skill Dodges", tooltip="Enable your pet's incoming skill dodges."};
--obj[14]	= { label="Skill Parries", tooltip="Enable your pet's incoming skill parries."};
--obj[15]	= { label="Skill Blocks", tooltip="Enable your pet's incoming skill blocks."};
--obj[16]	= { label="Spell Resists", tooltip="Enable your pet's incoming spell resists."};
--obj[17]	= { label="Skill Absorbs", tooltip="Enable absorbed damage from your pet's incoming skills."};
--obj[18]	= { label="Skill Immunes", tooltip="Enable incoming skill damage your pet is immune to."};
--obj[19]	= { label="Heals", tooltip="Enable your pet's incoming heals."};
--obj[20]	= { label="Crit Heals", tooltip="Enable your pet's incoming crit heals."};
--obj[21]	= { label="Heals Over Time", tooltip="Enable your pet's incoming heals over time."};


------------------------------
-- Outgoing events
------------------------------

obj = MSBTLocale.OUTGOING_PLAYER_EVENTS;
--obj[1]	= { label="Melee Hits", tooltip="Enable outgoing melee hits."};
--obj[2]	= { label="Melee Crits", tooltip="Enable outgoing melee crits."};
--obj[3]	= { label="Melee Misses", tooltip="Enable outgoing melee misses."};
--obj[4]	= { label="Melee Dodges", tooltip="Enable outgoing melee dodges."};
--obj[5]	= { label="Melee Parries", tooltip="Enable outgoing melee parries."};
--obj[6]	= { label="Melee Blocks", tooltip="Enable outgoing melee blocks."};
--obj[7]	= { label="Melee Absorbs", tooltip="Enable absorbed outgoing melee damage."};
--obj[8]	= { label="Melee Immunes", tooltip="Enable outgoing melee damage the enemy is immune to."};
--obj[9]	= { label="Melee Evades", tooltip="Enable outgoing melee evades."};
--obj[10]	= { label="Skill Hits", tooltip="Enable outgoing skill hits."};
--obj[11]	= { label="Skill Crits", tooltip="Enable outgoing skill crits."};
--obj[12]	= { label="Skill DoTs", tooltip="Enable outgoing skill damage over time."};
--obj[13]	= { label="Skill Misses", tooltip="Enable outgoing skill misses."};
--obj[14]	= { label="Skill Dodges", tooltip="Enable outgoing skill dodges."};
--obj[15]	= { label="Skill Parries", tooltip="Enable outgoing skill parries."};
--obj[16]	= { label="Skill Blocks", tooltip="Enable outgoing skill blocks."};
--obj[17]	= { label="Spell Resists", tooltip="Enable outgoing spell resists."};
--obj[18]	= { label="Skill Absorbs", tooltip="Enable absorbed damage from outgoing skills."};
--obj[19]	= { label="Skill Immunes", tooltip="Enable outgoing skill damage the enemy is immune to."};
--obj[20]	= { label="Skill Reflects", tooltip="Enable outgoing skill damage reflected back to you."};
--obj[21]	= { label="Spell Interrupts", tooltip="Enable outgoing spell interrupts."};
--obj[22]	= { label="Skill Evades", tooltip="Enable outgoing skill evades."};
--obj[23]	= { label="Heals", tooltip="Enable outgoing heals."};
--obj[24]	= { label="Crit Heals", tooltip="Enable outgoing crit heals."};
--obj[25]	= { label="Heals Over Time", tooltip="Enable outgoing heals over time."};

obj = MSBTLocale.OUTGOING_PET_EVENTS;
--obj[1]	= { label="Melee Hits", tooltip="Enable your pet's outgoing melee hits."};
--obj[2]	= { label="Melee Crits", tooltip="Enable your pet's outgoing melee crits."};
--obj[3]	= { label="Melee Misses", tooltip="Enable your pet's outgoing melee misses."};
--obj[4]	= { label="Melee Dodges", tooltip="Enable your pet's outgoing melee dodges."};
--obj[5]	= { label="Melee Parries", tooltip="Enable your pet's outgoing melee parries."};
--obj[6]	= { label="Melee Blocks", tooltip="Enable your pet's outgoing melee blocks."};
--obj[7]	= { label="Melee Absorbs", tooltip="Enable your pet's absorbed outgoing melee damage."};
--obj[8]	= { label="Melee Immunes", tooltip="Enable your pet's outgoing melee damage the enemy is immune to."};
--obj[9]	= { label="Melee Evades", tooltip="Enable your pet's outgoing melee evades."};
--obj[10]	= { label="Skill Hits", tooltip="Enable your pet's outgoing skill hits."};
--obj[11]	= { label="Skill Crits", tooltip="Enable your pet's outgoing skill crits."};
--obj[12]	= { label="Skill DoTs", tooltip="Enable outgoing skill damage over time."};
--obj[13]	= { label="Skill Misses", tooltip="Enable your pet's outgoing skill misses."};
--obj[14]	= { label="Skill Dodges", tooltip="Enable your pet's outgoing skill dodges."};
--obj[15]	= { label="Skill Parries", tooltip="Enable your pet's outgoing ability parries."};
--obj[16]	= { label="Skill Blocks", tooltip="Enable your pet's outgoing skill blocks."};
--obj[17]	= { label="Spell Resists", tooltip="Enable your pet's outgoing spell resists."};
--obj[18]	= { label="Skill Absorbs", tooltip="Enable your pet's absorbed damage from outgoing skills."};
--obj[19]	= { label="Skill Immunes", tooltip="Enable your pet's outgoing skill damage the enemy is immune to."};
--obj[20]	= { label="Skill Evades", tooltip="Enable your pet's outgoing skill evades."};


------------------------------
-- Notification events
------------------------------

obj = MSBTLocale.NOTIFICATION_EVENTS;
--obj[1]	= { label="Debuffs", tooltip="Enable debuffs you are afflicted by."};
--obj[2]	= { label="Buffs", tooltip="Enable buffs you receive."};
--obj[3]	= { label="Item Buffs", tooltip="Enable buffs your items receive."};
--obj[4]	= { label="Debuff Fades", tooltip="Enable debuffs that have faded from you."};
--obj[5]	= { label="Buff Fades", tooltip="Enable buffs that have faded from you."};
--obj[6]	= { label="Item Buff Fades", tooltip="Enable item buffs that have faded from you."};
--obj[7]	= { label="Enter Combat", tooltip="Enable when you have entered combat."};
--obj[8]	= { label="Leave Combat", tooltip="Enable when you have left combat."};
--obj[9]	= { label="Power Gains", tooltip="Enable when you gain extra mana, rage, or energy."};
--obj[10]	= { label="Power Losses", tooltip="Enable when you lose mana, rage, or energy from drains."};
--obj[11]	= { label="Combo Point Gains", tooltip="Enable when you gain combo points."};
--obj[12]	= { label="Combo Points Full", tooltip="Enable when you attain full combo points."};
--obj[13]	= { label="Honor Gains", tooltip="Enable when you gain honor."};
--obj[14]	= { label="Reputation Gains", tooltip="Enable when you gain reputation."};
--obj[15]	= { label="Reputation Losses", tooltip="Enable when you lose reputation."};
--obj[16]	= { label="Skill Gains", tooltip="Enable when you gain skill points."};
--obj[17]	= { label="Experience Gains", tooltip="Enable when you gain experience points."};
--obj[18]	= { label="Player Killing Blows", tooltip="Enable when you get a killing blow against a hostile player."};
--obj[19]	= { label="NPC Killing Blows", tooltip="Enable when you get a killing blow against an NPC."};
--obj[20]	= { label="Soul Shard Gains", tooltip="Enable when you gain a soul shard."};
--obj[21]	= { label="Extra Attacks", tooltip="Enable when you gain extra attacks such as windfury, thrash, sword spec, etc."};
--obj[22]	= { label="Enemy Buff Gains", tooltip="Enable buffs your currently targeted enemy gains."};
--obj[23]	= { label="Monster Emotes", tooltip="Enable emotes by the currently targeted monster."};
--obj[24]	= { label="Money Gains", tooltip="Enable money you gain."};


------------------------------
-- Trigger info
------------------------------

-- Holds the available trigger main conditions.
obj = MSBTLocale.TRIGGER_MAIN_CONDITIONS;
--obj["SelfHealth"]				= "Self Health %";
--obj["SelfMana"]					= "Self Mana %";
--obj["PetHealth"]				= "Pet Health %";
--obj["EnemyHealth"]				= "Enemy Target Health %";
--obj["FriendlyHealth"]			= "Friendly Target Health %";
--obj["IncomingCrit"]				= "Incoming Crit";
--obj["IncomingBlock"]			= "Incoming Block";
--obj["IncomingDodge"]			= "Incoming Dodge";
--obj["IncomingParry"]			= "Incoming Parry";
--obj["OutgoingCrit"]				= "Outgoing Crit";
--obj["OutgoingBlock"]			= "Outgoing Block";
--obj["OutgoingDodge"]			= "Outgoing Dodge";
--obj["OutgoingParry"]			= "Outgoing Parry";
--obj["SelfBuff"]					= "Self Buff Gain";
--obj["SelfDebuff"]				= "Self Debuff Gain";
--obj["TargetBuff"]				= "Target Buff Gain";
--obj["TargetDebuff"]				= "Target Debuff Gain";
--obj["TargetDebuffApplication"]	= "Target Debuff Application";
--obj["SearchPattern"]			= "Search Pattern";


-- Holds the available trigger secondary conditions.
obj = MSBTLocale.TRIGGER_SECONDARY_CONDITIONS;
--obj["SpellReady"]			= "Spell Ready";
--obj["SpellUsable"]			= "Spell Usable";
--obj["BuffInactive"]			= "Buff Inactive";
--obj["MinPower"]				= "Minimum Power Amount";
--obj["WarriorStance"]		= "Warrior Stance";
--obj["TriggerCooldown"]		= "Trigger Cooldown";
--obj["DebuffApplicationNum"]	= "Debuff Application Number";


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = MSBTLocale.OUTLINES;
obj[1] = "Kein";
obj[2] = "D\195\188nn";
obj[3] = "Dick";

-- Text aligns.
obj = MSBTLocale.TEXT_ALIGNS;
obj[1] = "Links";
obj[2] = "Zentriert";
obj[3] = "Rechts";


------------------------------
-- Sound info
------------------------------

obj = MSBTLocale.SOUNDS;
obj["LowMana"]		= "Mana Niedrig";
obj["LowHealth"]	= "Gesundheit Niedrig";


------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = MSBTLocale.ANIMATION_STYLE_DATA;
obj["Horizontal"]	= "Horizontale";
obj["Parabola"]		= "Parabel";
obj["Straight"]		= "Gerade";
obj["Static"]		= "Statisch";
--obj["Pow"]			= "Pow";

-- Animation style directions.
obj["Left"]			= "Links";
obj["Right"]		= "Rechts";
obj["Up"]			= "Bis";
obj["Down"]			= "Hinunter";

-- Animation style behaviors.
--obj["GrowUp"]			= "Grow Upwards";
--obj["GrowDown"]			= "Grow Downwards";
--obj["CurvedLeft"]		= "Curved Left";
--obj["CurvedRight"]		= "Curved Right";
--obj["Jiggle"]			= "Jiggle";
--obj["Normal"]			= "Normal";