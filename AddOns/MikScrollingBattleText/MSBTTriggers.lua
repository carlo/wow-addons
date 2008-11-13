-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Triggers
-- Author: Mik
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {};
local moduleName = "Triggers";
MikSBT[moduleName] = module;


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Main Trigger Conditions.
local MAINCONDITIONTYPE_SELF_HEALTH			= "SelfHealth";
local MAINCONDITIONTYPE_SELF_MANA			= "SelfMana";
local MAINCONDITIONTYPE_PET_HEALTH			= "PetHealth";
local MAINCONDITIONTYPE_ENEMY_HEALTH		= "EnemyHealth";
local MAINCONDITIONTYPE_FRIENDLY_HEALTH		= "FriendlyHealth";
local MAINCONDITIONTYPE_INCOMING_CRIT		= "IncomingCrit";
local MAINCONDITIONTYPE_INCOMING_BLOCK		= "IncomingBlock";
local MAINCONDITIONTYPE_INCOMING_DODGE		= "IncomingDodge";
local MAINCONDITIONTYPE_INCOMING_PARRY		= "IncomingParry";
local MAINCONDITIONTYPE_OUTGOING_CRIT		= "OutgoingCrit";
local MAINCONDITIONTYPE_OUTGOING_BLOCK		= "OutgoingBlock";
local MAINCONDITIONTYPE_OUTGOING_DODGE		= "OutgoingDodge";
local MAINCONDITIONTYPE_OUTGOING_PARRY		= "OutgoingParry";
local MAINCONDITIONTYPE_SELF_BUFF_GAIN		= "SelfBuff";
local MAINCONDITIONTYPE_SELF_DEBUFF_GAIN	= "SelfDebuff";
local MAINCONDITIONTYPE_TARGET_BUFF_GAIN	= "TargetBuff";
local MAINCONDITIONTYPE_TARGET_DEBUFF_GAIN	= "TargetDebuff";
local MAINCONDITIONTYPE_TARGET_DEBUFF_APP	= "TargetDebuffApplication";
local MAINCONDITIONTYPE_SEARCH_PATTERN		= "SearchPattern";

-- Secondary Trigger Conditions.
local SECONDARYCONDITIONTYPE_SPELL_READY		= "SpellReady";
local SECONDARYCONDITIONTYPE_SPELL_USABLE		= "SpellUsable";
local SECONDARYCONDITIONTYPE_BUFF_INACTIVE		= "BuffInactive";
local SECONDARYCONDITIONTYPE_MINIMUM_POWER		= "MinPower";
local SECONDARYCONDITIONTYPE_WARRIOR_STANCE		= "WarriorStance";
local SECONDARYCONDITIONTYPE_TRIGGER_COOLDOWN	= "TriggerCooldown";
local SECONDARYCONDITIONTYPE_DEBUFF_APP_NUM		= "DebuffApplicationNum";


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Holds dynamically created frame for receiving events.
local eventFrame;

-- Holds all of the supported trigger search pattern events.
local supportedSearchPatternEvents;

-- Holds the search pattern for event searching mode.
local searchModePattern;

-- Holds the player's name and class.
local playerName, playerClass;

-- Table to cache spell ID's that are checked for readiness. 
local spellIDCache = {};

-- Holds the last time triggers with a cooldown condition were fired.
local cooldownTimes = {};

-- Holds the number of applications of the last debuff.
local lastDebuffApplicationNum;

-- Holds triggers in a format optimized for searching.
local categorizedTriggers = {};
local secondaryConditions = {};

-- Hold the events the triggers use.
local listenEvents = {};

-- Previous health and mana values.
local lastPercentages = {};

-- Captured data.
local captureTable = {};

-- Hold buffs and debuffs that should be suppressed since there is a trigger for them.
local triggerSuppressions = {};


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to certain MSBT modules for faster access.
local MSBTProfiles = MikSBT.Profiles;
local MSBTParser = MikSBT.Parser;
local LBS = MSBTIconSupport and MSBTIconSupport.LBS;

-- Get local references to certain functions and variables for faster access.
local string_find = string.find;
local string_gsub = string.gsub;
local string_gmatch = string.gmatch;
local Print = MikSBT.Print;
local EraseTable = MikSBT.EraseTable;
local ConvertGlobalString = MSBTParser.ConvertGlobalString
local DisplayEvent = MikSBT.Animations.DisplayEvent;
local currentBuffs = MSBTParser.currentAuras.buffs;


-------------------------------------------------------------------------------
-- Trigger utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Gets up a list of all of the supported trigger search pattern events.
-- ****************************************************************************
local function GetSupportedSearchPatternEvents()
 -- Create supported search pattern events table if it hasn't been created yet.
 if (not supportedSearchPatternEvents) then
  supportedSearchPatternEvents = {
   "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS",
   "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES",
   "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS",
   "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES",
   "CHAT_MSG_COMBAT_FACTION_CHANGE",
   "CHAT_MSG_COMBAT_FRIENDLY_DEATH",
   "CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS",
   "CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES",
   "CHAT_MSG_COMBAT_HONOR_GAIN",
   "CHAT_MSG_COMBAT_HOSTILE_DEATH",
   "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS",
   "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES",
   "CHAT_MSG_COMBAT_PARTY_HITS",
   "CHAT_MSG_COMBAT_PARTY_MISSES",
   "CHAT_MSG_COMBAT_PET_HITS",
   "CHAT_MSG_COMBAT_PET_MISSES",
   "CHAT_MSG_COMBAT_SELF_HITS",
   "CHAT_MSG_COMBAT_SELF_MISSES",
   "CHAT_MSG_COMBAT_XP_GAIN",
   "CHAT_MSG_SKILL",
   "CHAT_MSG_SPELL_AURA_GONE_PARTY",
   "CHAT_MSG_SPELL_AURA_GONE_OTHER",
   "CHAT_MSG_SPELL_AURA_GONE_SELF",
   "CHAT_MSG_SPELL_BREAK_AURA",
   "CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE",
   "CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF",
   "CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF",
   "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE",
   "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
   "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
   "CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF",
   "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
   "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
   "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
   "CHAT_MSG_SPELL_ITEM_ENCHANTMENTS",
   "CHAT_MSG_SPELL_PARTY_BUFF",
   "CHAT_MSG_SPELL_PARTY_DAMAGE",
   "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS",
   "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
   "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS",
   "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE",
   "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS",
   "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
   "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS",
   "CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE",
   "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
   "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
   "CHAT_MSG_SPELL_PET_BUFF",
   "CHAT_MSG_SPELL_PET_DAMAGE",
   "CHAT_MSG_SPELL_SELF_BUFF",
   "CHAT_MSG_SPELL_SELF_DAMAGE",
  }
 end

 -- Return the supported search pattern events.
 return supportedSearchPatternEvents;
end


-- ****************************************************************************
-- Enables event searching mode.  The passed pattern will be used to only show
-- event types where the combat message contains the pattern.
-- ****************************************************************************
local function EnableEventSearching(pattern)
 -- Set the event searching mode search pattern to the passed pattern.
 searchModePattern = pattern;

 -- Register extra events for broader searching.
 local searchPatternEvents = GetSupportedSearchPatternEvents();
 for _, event in ipairs(searchPatternEvents) do
  eventFrame:RegisterEvent(event);
 end
end


-- ****************************************************************************
-- Disables event searching mode.
-- ****************************************************************************
local function DisableEventSearching()
 -- Clear the event searching mode search pattern.
 searchModePattern = nil;

 -- Unregister the extra events we registered for broader searching if they aren't in use by a trigger.
 local searchPatternEvents = GetSupportedSearchPatternEvents();
 for _, event in pairs(searchPatternEvents) do
  if (not listenEvents[event]) then eventFrame:UnregisterEvent(event); end
 end
end


-- ****************************************************************************
-- Categorizes the passed trigger if it is not disabled and it applies to the 
-- current player's class.  Also tracks the events the trigger uses so that the 
-- only events that are received are those that are needed by the triggers that
-- are in use.
-- ****************************************************************************
local function CategorizeTrigger(triggerSettings)
 -- Don't register the trigger if it is disabled, not for the current class,
 -- or there aren't any main conditions. 
 if (triggerSettings.disabled) then return; end
 if (triggerSettings.classes and not string_find(triggerSettings.classes, playerClass, nil, 1)) then return; end 
 if (not triggerSettings.mainConditions) then return; end

 -- Holds a table of search patterns for the trigger if there are any.
 local tempSearchPatterns;
 
 -- Loop through the main conditions for the trigger.
 local conditionTriggers, params;
 for conditionType, conditionParam in string_gmatch(triggerSettings.mainConditions, "(.-)=(.-)&&") do
  -- Create a table to hold an array of the triggers for the main condition type if there isn't already one for it. 
  if (not categorizedTriggers[conditionType]) then categorizedTriggers[conditionType] = {}; end
  conditionTriggers = categorizedTriggers[conditionType];

  -- Search Pattern.
  if (conditionType == MAINCONDITIONTYPE_SEARCH_PATTERN) then
   -- Make sure there is a condition.
   if (conditionParam and conditionParam ~= "") then
    -- Create a table to hold the search patterns if it hasn't already been done.
    if (not tempSearchPatterns) then tempSearchPatterns = {}; end

    -- Add the search pattern to the temp search patterns table.
    tempSearchPatterns[#tempSearchPatterns+1] = conditionParam;
   end

  -- Not a search pattern main condition.
  else
   -- Categorize the triggers by their main condition types so time is not wasted checking for triggers that don't apply.
   params = conditionTriggers[triggerSettings];
   if (params and type(params ~= "table")) then
    conditionTriggers[triggerSettings] = {};
    conditionTriggers[triggerSettings][#conditionTriggers[triggerSettings]+1] = params;
    params = conditionTriggers[triggerSettings];
   end
   if (type(params) == "table") then
    params[#params+1] = conditionParam;
   else
    conditionTriggers[triggerSettings] = conditionParam;
   end

   -- Self Health.
   if (conditionType == MAINCONDITIONTYPE_SELF_HEALTH) then
    listenEvents["UNIT_HEALTH"] = true;

   -- Self Mana.
   elseif (conditionType == MAINCONDITIONTYPE_SELF_MANA) then
    listenEvents["UNIT_MANA"] = true;

   -- Pet Health.
   elseif (conditionType == MAINCONDITIONTYPE_PET_HEALTH) then
    listenEvents["UNIT_HEALTH"] = true;

   -- Enemy Health.
   elseif (conditionType == MAINCONDITIONTYPE_ENEMY_HEALTH) then
    listenEvents["UNIT_HEALTH"] = true;

   -- Friendly Health.
   elseif (conditionType == MAINCONDITIONTYPE_FRIENDLY_HEALTH) then
    listenEvents["UNIT_HEALTH"] = true;

   -- Self buff and debuff gains.	
   elseif (conditionType == MAINCONDITIONTYPE_SELF_BUFF_GAIN or
           conditionType == MAINCONDITIONTYPE_SELF_DEBUFF_GAIN) then
    -- Add the buff/debuff name to the trigger suppressions list.
    triggerSuppressions[conditionParam] = true;
   end
  end  -- Search pattern check.
 end  -- Main Conditions Loop.
  
 -- Categorize the search patterns by their event types and trigger key.
 if (triggerSettings.triggerEvents and tempSearchPatterns) then
  for triggerEvent in string_gmatch(triggerSettings.triggerEvents, "[^,]+") do
   -- Create a table to hold the triggers categorized by event type if there isn't already one for it.
   if (not categorizedTriggers[MAINCONDITIONTYPE_SEARCH_PATTERN][triggerEvent]) then
    categorizedTriggers[MAINCONDITIONTYPE_SEARCH_PATTERN][triggerEvent] = {};
   end

   categorizedTriggers[MAINCONDITIONTYPE_SEARCH_PATTERN][triggerEvent][triggerSettings] = tempSearchPatterns;
   listenEvents[triggerEvent] = true;
  end
 end

 -- Leave the function if there are no secondary conditions for the trigger. 
 if (not triggerSettings.secondaryConditions) then return; end

 -- Loop through the secondary conditions for the trigger.
 local conditions;
 for conditionType, conditionParam in string_gmatch(triggerSettings.secondaryConditions, "(.-)=(.-)&&") do
  -- Create a table to hold an array of the secondary conditions if there isn't already one for it. 
  if (not secondaryConditions[triggerSettings]) then secondaryConditions[triggerSettings] = {}; end
  conditions = secondaryConditions[triggerSettings];

  -- Populate the secondary conditions.  Create a table to hold multiple values for a given condition
  -- type if needed.
  params = conditions[conditionType];
  if (params and type(params ~= "table")) then
   conditions[conditionType] = {};
   conditions[conditionType][#conditions[conditionType]+1] = params;
   params = conditions[conditionType];
  end
  if (type(params) == "table") then
   params[#params+1] = conditionParam;
  else
   conditions[conditionType] = conditionParam;
  end
 end
end


-- ****************************************************************************
-- Update the categorized triggers table that is used for optimized searching.
-- ****************************************************************************
local function UpdateTriggers()
 -- Unregister all of the events from the event frame.
 eventFrame:UnregisterAllEvents();

 -- Erase the listen events table.
 EraseTable(listenEvents);

 -- Loop through all of the categorized trigger arrays and erase them.
 for conditionType in pairs(categorizedTriggers) do
  EraseTable(categorizedTriggers[conditionType]);
 end
 
 -- Erase the secondary condition arrays.
 EraseTable(secondaryConditions);

 -- Categorize triggers from the current profile.
 local currentProfileTriggers = rawget(MSBTProfiles.currentProfile, "triggers");
 if (currentProfileTriggers) then
  for triggerKey, triggerSettings in pairs(currentProfileTriggers) do
   if (triggerSettings) then CategorizeTrigger(triggerSettings); end
  end
 end
 
 -- Categorize triggers available in the master profile that aren't in the current profile. 
 for triggerKey, triggerSettings in pairs(MSBTProfiles.masterProfile.triggers) do
  if (not currentProfileTriggers or rawget(currentProfileTriggers, triggerKey) == nil) then
   CategorizeTrigger(triggerSettings);
  end
 end
 
 -- Register all of the events the triggers use.
 for event in pairs(listenEvents) do
  eventFrame:RegisterEvent(event);
 end
end


-- ****************************************************************************
-- Returns the spell id for the passed spell name if it is in the spell book.
-- Returns 0 is the spell wasn't found.
-- ****************************************************************************
local function GetSpellID(spellName)
 -- Get the total number of spells in the spell book.
 local _, _, offset, numSpells = GetSpellTabInfo(GetNumSpellTabs());
 local totalSpells = offset + numSpells;

 -- Loop through all of the spells looking for the passed spell name and return the spell
 -- ID if it's found.
 for i = 1, totalSpells do
  if (spellName == GetSpellName(i, BOOKTYPE_SPELL)) then return i; end
 end

 -- Return 0 if the spell wasn't found.
 return 0;
end


-- ****************************************************************************
-- Fills in the capture table with the captured data if a match is found.
-- ****************************************************************************
local function CaptureData(matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9)
 -- Check if a match was found.
 if (matchStart) then
  captureTable[1] = c1;
  captureTable[2] = c2;
  captureTable[3] = c3;
  captureTable[4] = c4;
  captureTable[5] = c5;
  captureTable[6] = c6;
  captureTable[7] = c7;
  captureTable[8] = c8;
  captureTable[9] = c9;

  -- Return the last position of the match.
  return matchEnd;
 end

 -- Don't return anything since no match was found.
 return nil;
end


-- ****************************************************************************
-- Displays the passed trigger settings.
-- ****************************************************************************
local function DisplayTrigger(triggerSettings, ...)
 -- Get the trigger message.
 local message = triggerSettings.message;
 
 -- Loop through all of the arguments replacing any %i codes with the corresponding
 -- arguments.
 local numArgs = select("#", ...);
 for i = 1, numArgs do
  local value = select(i, ...);
  message = string_gsub(message, "%%" .. i, value);
 end
 
 -- Get texture for the trigger.
 local texturePath;
 if (not MSBTProfiles.currentProfile.skillIconsDisabled and triggerSettings.iconSkill) then
  texturePath = LBS and LBS:GetSpellIcon(triggerSettings.iconSkill);
 end
 
 -- Display the trigger event.
 DisplayEvent(triggerSettings, message, texturePath);
end


-------------------------------------------------------------------------------
-- Trigger condition functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns whether or not the passed spell name is ready.
-- ****************************************************************************
local function CheckSpellReady(spellName)
 -- Return true if there is no spell to check.
 if (not spellName or spellName == "") then return true; end

 -- Get the spell ID for the spell name.  Search the spell book the first time, and
 -- cache the results for subsequent calls.
 if (not spellIDCache[spellName]) then spellIDCache[spellName] = GetSpellID(spellName); end
 local spellID = spellIDCache[spellName];

 -- Fail check if the spell is not known.
 if (spellID == 0) then return false; end

 -- Fail check if the spell is cooling down (but ignore the global cooldown).
 local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL);
 if (start > 0 and duration > 1.5) then return false; end

 -- Success. 
 return true;
end


-- ****************************************************************************
-- Returns whether or not all of the passed secondary conditions are met.
-- ****************************************************************************
local function CheckSecondaryConditions(triggerSettings)
 -- Return true if there are no secondary conditions.
 if (not secondaryConditions[triggerSettings]) then return true; end

 -- Holds whether or not all secondary conditions are met.
 local conditionsMet = true;
 
 -- Holds whether or not the trigger has a cooldown condition.
 local hasCooldownCondition = false;

 -- Loop through all of the secondary conditions.
 for conditionType, conditionParam in pairs(secondaryConditions[triggerSettings]) do
  -- Buff inactive.
  if (conditionType == SECONDARYCONDITIONTYPE_BUFF_INACTIVE) then
   -- Loop through all parameters if it's a table.
   if (type(conditionParam) == "table") then
    for _, param in ipairs(conditionParam) do
     if (currentBuffs and currentBuffs[param]) then conditionsMet = false; end
    end
   else
    if (currentBuffs and currentBuffs[conditionParam]) then conditionsMet = false; end
   end
  
  -- Spell ready.
  elseif (conditionType == SECONDARYCONDITIONTYPE_SPELL_READY) then
   -- Loop through all parameters if it's a table.
   if (type(conditionParam) == "table") then
    for _, param in ipairs(conditionParam) do
     if (not CheckSpellReady(param)) then conditionsMet = false; end
    end
   else
    if (not CheckSpellReady(conditionParam)) then conditionsMet = false; end
   end

  -- Spell usable.   
  elseif (conditionType == SECONDARYCONDITIONTYPE_SPELL_USABLE) then
   -- Loop through all parameters if it's a table.
   if (type(conditionParam) == "table") then
    for _, param in ipairs(conditionParam) do
     if (not IsUsableSpell(param)) then conditionsMet = false; end
    end
   else
    if (not IsUsableSpell(conditionParam)) then conditionsMet = false; end
   end

  -- Minimum power amount.
  elseif (conditionType == SECONDARYCONDITIONTYPE_MINIMUM_POWER) then
   -- Check if there is less power than the minimum amount.
   if (UnitMana("player") < tonumber(conditionParam)) then conditionsMet = false; end

  -- Warrior stance.
  elseif (conditionType == SECONDARYCONDITIONTYPE_WARRIOR_STANCE) then
   if (playerClass == "WARRIOR" and (GetShapeshiftForm(true) ~= tonumber(conditionParam))) then
    conditionsMet = false;
   end
   
  -- Trigger cooldown.
  elseif (conditionType == SECONDARYCONDITIONTYPE_TRIGGER_COOLDOWN) then
   hasCooldownCondition = true;
   local lastFired = cooldownTimes[triggerSettings] or 0;
   if ((GetTime() - lastFired) < tonumber(conditionParam)) then conditionsMet = false; end

  -- Debuff application number.
  elseif (conditionType == SECONDARYCONDITIONTYPE_DEBUFF_APP_NUM) then
   if (tonumber(conditionParam) ~= lastDebuffApplicationNum) then conditionsMet = false; end
  end
 end

 -- Set the current time as the last time the trigger was fired if all conditions
 -- are met and the trigger has a cooldown condition.
 if (conditionsMet and hasCooldownCondition) then cooldownTimes[triggerSettings] = GetTime(); end
 
 -- Return whether or not the secondary conditions are satisfied.
 return conditionsMet;
end


-- ****************************************************************************
-- Fires the passed triggers if the passed condition and the secondary
-- conditions are met. Any additional parameters will be treated as captured
-- data that can be accessed with %1 - %9.
-- ****************************************************************************
local function FireTriggers(conditionType, condition, ...)
 -- Don't do anything if there are no triggers to search for.
 local triggers = categorizedTriggers[conditionType];
 if (not triggers) then return; end

 -- Loop through the passed triggers.
 local conditionsMet;
 for triggerSettings, triggerValue in pairs(triggers) do
  conditionsMet = false;

  -- Loop through all condition parameters for the trigger if needed.
  if (type(triggerValue) == "table") then
   for _, value in ipairs(triggerValue) do
    if (value == condition) then conditionsMet = true; end
   end

  -- Only one parameter.
  else
   if (triggerValue == condition) then conditionsMet = true; end
  end

  -- Display the trigger if any of the conditions match and the secondary conditions are met.
  if (conditionsMet and CheckSecondaryConditions(triggerSettings)) then DisplayTrigger(triggerSettings, ...); end
 end
end


-- ****************************************************************************
-- Fires the passed health triggers if the secondary conditions are met and
-- returns the updated health percentage.
-- ****************************************************************************
local function FireHealthTriggers(unit, conditionType)
 -- Don't do anything if there are no triggers to search for.
 local healthTriggers = categorizedTriggers[conditionType];
 if (not healthTriggers) then lastPercentages[conditionType] = 0; return; end

 local healthAmount = UnitHealth(unit);
 local healthPercentage = healthAmount / UnitHealthMax(unit);
 local lastHealthPercentage = lastPercentages[conditionType] or 0;

 -- Loop through the passed health triggers.
 for triggerSettings, thresholdPercentage in pairs(healthTriggers) do
  -- Check if we just crossed the trigger's threshold.
  if (healthPercentage < thresholdPercentage/100 and lastHealthPercentage >= thresholdPercentage/100) then

   -- Display the trigger if the secondary conditions are met.
   if (CheckSecondaryConditions(triggerSettings)) then DisplayTrigger(triggerSettings, healthAmount); end
  end
 end -- Loop through triggers.

 -- Update the last health percentage for the condition type.
 lastPercentages[conditionType] = healthPercentage;
end


-- ****************************************************************************
-- Fires the passed mana triggers if the secondary conditions are met and
-- returns the updated mana percentage.
-- ****************************************************************************
local function FireManaTriggers(unit, conditionType)
 -- Don't do anything if there are no triggers to search for.
 local manaTriggers = categorizedTriggers[conditionType];
 if (not manaTriggers) then lastPercentages[conditionType] = 0; return; end

 -- Make sure we're dealing with mana.
 if (UnitPowerType(unit) == 0) then
  local manaAmount = UnitMana(unit);
  local manaPercentage = manaAmount / UnitManaMax(unit);
  local lastManaPercentage = lastPercentages[conditionType] or 0;

  -- Loop through the passed mana triggers.
  for triggerSettings, thresholdPercentage in pairs(manaTriggers) do
   -- Check if we just crossed the trigger's threshold.
   if (manaPercentage < thresholdPercentage/100 and lastManaPercentage >= thresholdPercentage/100) then

    -- Display the trigger if the secondary conditions are met.
    if (CheckSecondaryConditions(triggerSettings)) then DisplayTrigger(triggerSettings, manaAmount); end
   end
  end -- Loop through triggers.
  
  -- Update the last mana percentage for the condition type.
  lastPercentages[conditionType] = manaPercentage;
  return;
 end -- Power type is mana.
end


-- ****************************************************************************
-- Parses the search pattern triggers for a match with the passed combat
-- message and event.
-- ****************************************************************************
local function ParseSearchPatternTriggers(event, combatMessage)
 -- Check if event search mode is enabled.
 if (searchModePattern) then
  -- Print out the event type and the combat message if the pattern is in the combat message.
  if (string.find(combatMessage, searchModePattern)) then
   Print(event .. " - " .. combatMessage, 0, 1, 0);
  end
 end

 -- Ignore the event if there are no search pattern triggers or none for the event type.
 if (not categorizedTriggers[MAINCONDITIONTYPE_SEARCH_PATTERN]) then return; end
 if (not categorizedTriggers[MAINCONDITIONTYPE_SEARCH_PATTERN][event]) then return; end

 -- Loop through all triggers for the event.
 for triggerSettings, searchPatterns in pairs(categorizedTriggers[MAINCONDITIONTYPE_SEARCH_PATTERN][event]) do
  -- Loop through all of the search patterns for the trigger.
  for _, searchPattern in pairs(searchPatterns) do
   -- Format the global string into a lua compatible search string if the search pattern is a global string.
   if (_G[searchPattern]) then searchPattern = ConvertGlobalString(searchPattern); end

   -- Get capture data.
   local matchEnd = CaptureData(string_find(combatMessage, searchPattern));

   -- Display the trigger if a match was found and the secondary conditions are met.
   if (matchEnd) then
    if (CheckSecondaryConditions(triggerSettings)) then DisplayTrigger(triggerSettings, unpack(captureTable)); end
    break;
   end
  end -- Loop through search patterns. 
 end -- Loop through triggers.
end


-------------------------------------------------------------------------------
-- Initialization and event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Handle parser events.
-- ****************************************************************************
local function ParserEventsHandler(parserEvent)
 -- Check if the event is a critical hit.
 if (parserEvent.eventType == MSBTParser.EVENTTYPE_DAMAGE and parserEvent.isCrit) then
  -- Check if the event is incoming.
  if (parserEvent.recipientUnit == "player") then
   FireTriggers(MAINCONDITIONTYPE_INCOMING_CRIT, "true");
  -- Event is outgoing.
   elseif (parserEvent.sourceUnit == "player") then
   FireTriggers(MAINCONDITIONTYPE_OUTGOING_CRIT, "true");
  end

 -- Check if the event is a miss.
 elseif (parserEvent.eventType == MSBTParser.EVENTTYPE_MISS) then
  -- Block.
  if (parserEvent.missType == MSBTParser.MISSTYPE_BLOCK) then
   -- Check if the event is incoming.
   if (parserEvent.recipientUnit == "player") then
    FireTriggers(MAINCONDITIONTYPE_INCOMING_BLOCK, "true");
   -- Event is outgoing.
   elseif (parserEvent.sourceUnit == "player") then
    FireTriggers(MAINCONDITIONTYPE_OUTGOING_BLOCK, "true");
   end

  -- Dodge.
  elseif (parserEvent.missType == MSBTParser.MISSTYPE_DODGE) then
   -- Check if the event is incoming.
   if (parserEvent.recipientUnit == "player") then
    FireTriggers(MAINCONDITIONTYPE_INCOMING_DODGE, "true");
   -- Event is outgoing.
   elseif (parserEvent.sourceUnit == "player") then
    FireTriggers(MAINCONDITIONTYPE_OUTGOING_DODGE, "true");
   end

  -- Parry.
  elseif (parserEvent.missType == MSBTParser.MISSTYPE_PARRY) then
   -- Check if the event is incoming.
   if (parserEvent.recipientUnit == "player") then
    FireTriggers(MAINCONDITIONTYPE_INCOMING_PARRY, "true");
   -- Event is outgoing.
   elseif (parserEvent.sourceUnit == "player") then
    FireTriggers(MAINCONDITIONTYPE_OUTGOING_PARRY, "true");
   end
  end

 -- Check if the event is a notification.
 elseif (parserEvent.eventType == MSBTParser.EVENTTYPE_NOTIFICATION) then
  -- The notification is for the player.
  if (parserEvent.sourceUnit == "player") then
   -- Debuff gain.
   if (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_DEBUFF) then
    FireTriggers(MAINCONDITIONTYPE_SELF_DEBUFF_GAIN, parserEvent.effectName);
   -- Buff gain.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_BUFF) then
    FireTriggers(MAINCONDITIONTYPE_SELF_BUFF_GAIN, parserEvent.effectName);
   end

  -- The notification is for the current target.
  elseif (parserEvent.sourceName == UnitName("target")) then
   -- Debuff gain.
   if (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_DEBUFF) then
    -- First application of the debuff.
    if (not parserEvent.amount) then
     lastDebuffApplicationNum = 1;
     FireTriggers(MAINCONDITIONTYPE_TARGET_DEBUFF_GAIN, parserEvent.effectName);
     FireTriggers(MAINCONDITIONTYPE_TARGET_DEBUFF_APP, parserEvent.effectName, 1);
    -- Another application of the debuff.
    else
     lastDebuffApplicationNum = parserEvent.amount;
     FireTriggers(MAINCONDITIONTYPE_TARGET_DEBUFF_APP, parserEvent.effectName, parserEvent.amount);
    end

   -- Buff gain.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_BUFF) then
    FireTriggers(MAINCONDITIONTYPE_TARGET_BUFF_GAIN, parserEvent.effectName);
   end
  end

 end 
end


-- ****************************************************************************
-- Called when the events the helper registered for occur.
-- ****************************************************************************
local function OnEvent(this, event, arg1)
 -- Health changes.
 if (event == "UNIT_HEALTH") then
  if (arg1 == "player") then
   FireHealthTriggers("player", MAINCONDITIONTYPE_SELF_HEALTH)
  elseif (arg1 == "target") then
   -- Target is an enemy.
   if (not UnitIsFriend("player", "target")) then
    FireHealthTriggers("target", MAINCONDITIONTYPE_ENEMY_HEALTH)
   -- Target is not an enemy.
   else
    FireHealthTriggers("target", MAINCONDITIONTYPE_FRIENDLY_HEALTH);
   end
  elseif (arg1 == "pet") then
   FireHealthTriggers("pet", MAINCONDITIONTYPE_PET_HEALTH);
  end

 -- Mana changes.
 elseif (event == "UNIT_MANA") then
  if (arg1 == "player") then
   FireManaTriggers("player", MAINCONDITIONTYPE_SELF_MANA);
  end

 -- Chat message combat events.
 else
  ParseSearchPatternTriggers(event, arg1);

 end
end


-- ****************************************************************************
-- Enables the trigger parsing.
-- ****************************************************************************
local function Enable()
 -- Register the events the triggers use.
 for event in pairs(listenEvents) do
  eventFrame:RegisterEvent(event);
 end
end


-- ****************************************************************************
-- Disables the trigger parsing.
-- ****************************************************************************
local function Disable()
 -- Unregister all of the events from the event frame.
 eventFrame:UnregisterAllEvents();
end


-- ****************************************************************************
-- Called when the module is loaded.
-- ****************************************************************************
local function OnLoad()
 -- Get the player's name and class.
 playerName = UnitName("player");
 _, playerClass = UnitClass("player");

 -- Create a frame to receive events.
 eventFrame = CreateFrame("Frame");
 eventFrame:Hide();
 eventFrame:SetScript("OnEvent", OnEvent);
end




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Variables.
module.triggerSuppressions = triggerSuppressions;

-- Protected Functions.
module.EnableEventSearching				= EnableEventSearching;
module.DisableEventSearching			= DisableEventSearching;
module.GetSupportedSearchPatternEvents	= GetSupportedSearchPatternEvents;
module.UpdateTriggers					= UpdateTriggers;
module.GetSpellID						= GetSpellID;
module.ParserEventsHandler				= ParserEventsHandler;
module.Enable							= Enable;
module.Disable							= Disable;


-------------------------------------------------------------------------------
-- Load.
-------------------------------------------------------------------------------

OnLoad();