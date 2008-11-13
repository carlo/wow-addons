-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Parser
-- Author: Mik
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {};
local moduleName = "Parser";
MikSBT[moduleName] = module;


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Event types.
local EVENTTYPE_DAMAGE			= 1001;
local EVENTTYPE_MISS			= 1002;
local EVENTTYPE_HEAL			= 1003;
local EVENTTYPE_NOTIFICATION	= 1004;
local EVENTTYPE_ENVIRONMENTAL	= 1005;

-- Damage types.
local DAMAGETYPE_PHYSICAL	= 2001;
local DAMAGETYPE_HOLY		= 2002;
local DAMAGETYPE_FIRE		= 2003;
local DAMAGETYPE_NATURE		= 2004;
local DAMAGETYPE_FROST		= 2005;
local DAMAGETYPE_SHADOW		= 2006;
local DAMAGETYPE_ARCANE		= 2007;
local DAMAGETYPE_UNKNOWN	= 2999;

-- Miss types.
local MISSTYPE_MISS			= 3001;
local MISSTYPE_DODGE		= 3002;
local MISSTYPE_PARRY		= 3003;
local MISSTYPE_BLOCK		= 3004;
local MISSTYPE_RESIST		= 3005;
local MISSTYPE_ABSORB		= 3006;
local MISSTYPE_IMMUNE		= 3007;
local MISSTYPE_EVADE		= 3008;
local MISSTYPE_REFLECT		= 3009;
local MISSTYPE_INTERRUPT	= 3010;

-- Notification types.
local NOTIFICATIONTYPE_DEBUFF			= 4001;
local NOTIFICATIONTYPE_BUFF				= 4002;
local NOTIFICATIONTYPE_ITEM_BUFF		= 4003;
local NOTIFICATIONTYPE_DEBUFF_FADE		= 4004;
local NOTIFICATIONTYPE_BUFF_FADE		= 4005;
local NOTIFICATIONTYPE_ITEM_BUFF_FADE	= 4006;
local NOTIFICATIONTYPE_COMBAT_ENTER		= 4007;
local NOTIFICATIONTYPE_COMBAT_LEAVE		= 4008;
local NOTIFICATIONTYPE_POWER_GAIN		= 4009;
local NOTIFICATIONTYPE_POWER_LOSS		= 4010;
local NOTIFICATIONTYPE_CP_GAIN			= 4011;
local NOTIFICATIONTYPE_HONOR_GAIN		= 4012;
local NOTIFICATIONTYPE_REP_GAIN			= 4013;
local NOTIFICATIONTYPE_REP_LOSS			= 4014;
local NOTIFICATIONTYPE_SKILL_GAIN		= 4015;
local NOTIFICATIONTYPE_EXPERIENCE_GAIN	= 4016;
local NOTIFICATIONTYPE_PC_KILLING_BLOW	= 4017;
local NOTIFICATIONTYPE_NPC_KILLING_BLOW	= 4018;
local NOTIFICATIONTYPE_ITEM_CREATED		= 4019;
local NOTIFICATIONTYPE_EXTRA_ATTACK		= 4020;
local NOTIFICATIONTYPE_MONSTER_EMOTE	= 4021;
local NOTIFICATIONTYPE_MONEY			= 4022;

-- Hazard types.
local HAZARDTYPE_DROWNING	= 5001;
local HAZARDTYPE_FALLING	= 5002;
local HAZARDTYPE_FATIGUE	= 5003;
local HAZARDTYPE_FIRE		= 5004;
local HAZARDTYPE_LAVA		= 5005;
local HAZARDTYPE_SLIME		= 5006;

-- Special values to denote the player and pet.
local UNITTYPE_PLAYER	= "9001";
local UNITTYPE_PET		= "9002";

-- Amount of time to hold a recently selected hostile player in cache.
local RECENT_HOSTILES_HOLD_TIME = 60;

-- Update timings.
local ITEM_BUFF_UPDATE_INTERVAL = 1;
local UNIT_MAP_UPDATE_DELAY = 0.2;
local PET_UPDATE_DELAY = 1;

-- The maximum number of buffs and debuffs that can be on a unit.
local MAX_BUFFS = 16;
local MAX_DEBUFFS = 40;


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Dynamically created frames for receiving events and tooltip info.
local eventFrame;
local tooltipFrame;

-- Name of the player and pet.
local playerName;
local petName;

-- Used for timing between updates.
local lastItemBuffUpdate = 0;
local lastUnitMapUpdate = 0;
local lastPetUpdate = 0;
local targetCleanupTime = 0;

-- Whether or not values that need to be updated after a delay are stale.
local isPetNameStale;
local isUnitMapStale;

-- List of recently selected hostile players.
local recentHostiles = {};

-- Map of names to unit ids.
local unitMap = {};

-- Map of unit types to names.
local unitTypeMap = {};

-- Map of damage type numbers to strings.
local damageTypeMap = {};

-- Saved and current buffs and debuffs.
local currentAuras = {buffs = {}, debuffs = {}, itemBuffs = {}};
local savedAuras = {buffs = {}, debuffs = {}, itemBuffs = {}};
local aurasInitialized;

-- List of global strings to search for each event.
local eventSearchMap;

-- Information about global strings.
local captureMaps;
local rareWords = {};
local searchPatterns = {};
local captureOrders = {};

-- Lists of events that are fired for pets.
local inPetEvents;
local outPetEvents;
local outPeriodicPetEvents;
local currentEvent;

-- Captured data.
local captureTable = {};

-- Parsed event data.
local parserEvent = {};


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to certain functions for faster access.
local strtrim = strtrim;
local string_find = string.find;
local string_gmatch = string.gmatch;
local string_len = string.len;
local Print = MikSBT.Print;
local EraseTable = MikSBT.EraseTable;
local MainParserHandler;
local TriggerParserHandler;



-------------------------------------------------------------------------------
-- Populate functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Populates the parser event data table for a damage event.
-- ****************************************************************************
local function PopulateDamageEvent(captureMap)
 -- Damage Event (damageType, sourceName, recipientName, amount, abilityName, isCrit, isDoT).
 -- Attempt to get the damage type and convert it to a number if needed.
 local damageType = captureTable[captureMap[2]] or captureMap[2];
 if (type(damageType) == "string") then
  damageType = damageTypeMap[damageType] or DAMAGETYPE_UNKNOWN;
 end

 local sourceName = captureTable[captureMap[3]] or captureMap[3];
 local recipientName = captureTable[captureMap[4]] or captureMap[4];
 if (sourceName) then sourceName = strtrim(sourceName); end
 if (recipientName) then recipientName = strtrim(recipientName); end
 local sourceType = sourceName ~= UNITTYPE_PLAYER and outPetEvents[currentEvent] and UNITTYPE_PET or sourceName;
 if (sourceType ~= UNITTYPE_PET and outPeriodicPetEvents[currentEvent] and sourceName == petName) then sourceType = UNITTYPE_PET; end
 local recipientType = recipientName ~= UNITTYPE_PLAYER and inPetEvents[currentEvent] and recipientName == petName and UNITTYPE_PET or recipientName;

 parserEvent.eventType = EVENTTYPE_DAMAGE;
 parserEvent.damageType = damageType;
 parserEvent.sourceUnit = unitMap[sourceType];
 parserEvent.sourceName = unitTypeMap[sourceType] or sourceName;
 parserEvent.recipientUnit = unitMap[recipientType];
 parserEvent.recipientName = unitTypeMap[recipientType] or recipientName;
 parserEvent.amount = tonumber(captureTable[captureMap[5]] or captureMap[5]);
 parserEvent.abilityName = captureTable[captureMap[6]] or captureMap[6];
 parserEvent.isCrit = captureMap[7];
 parserEvent.isDoT = captureMap[8];
end


-- ****************************************************************************
-- Populates the parser event data table for a miss event.
-- ****************************************************************************
local function PopulateMissEvent(captureMap)
 -- Miss Event (missType, sourceName, recipientName, abilityName).
 local sourceName = captureTable[captureMap[3]] or captureMap[3];
 local recipientName = captureTable[captureMap[4]] or captureMap[4];
 if (sourceName) then sourceName = strtrim(sourceName); end
 if (recipientName) then recipientName = strtrim(recipientName); end
 local sourceType = sourceName ~= UNITTYPE_PLAYER and outPetEvents[currentEvent] and UNITTYPE_PET or sourceName;
 if (sourceType ~= UNITTYPE_PET and outPeriodicPetEvents[currentEvent] and sourceName == petName) then sourceType = UNITTYPE_PET; end
 local recipientType = recipientName ~= UNITTYPE_PLAYER and inPetEvents[currentEvent] and recipientName == petName and UNITTYPE_PET or recipientName;

 parserEvent.eventType = EVENTTYPE_MISS;
 parserEvent.missType = captureMap[2];
 parserEvent.sourceUnit = unitMap[sourceType]
 parserEvent.sourceName = unitTypeMap[sourceType] or sourceName;
 parserEvent.recipientUnit = unitMap[recipientType]
 parserEvent.recipientName = unitTypeMap[recipientType] or recipientName;
 parserEvent.abilityName = captureTable[captureMap[5]] or captureMap[5];
end


-- ****************************************************************************
-- Populates the parser event data table for a heal event.
-- ****************************************************************************
local function PopulateHealEvent(captureMap)
 -- Heal Event (sourceName, recipientName, amount, abilityName, isCrit, isHoT).
 local sourceName = captureTable[captureMap[2]] or captureMap[2];
 local recipientName = captureTable[captureMap[3]] or captureMap[3];
 if (sourceName) then sourceName = strtrim(sourceName); end
 if (recipientName) then recipientName = strtrim(recipientName); end
 local sourceType = sourceName ~= UNITTYPE_PLAYER and outPetEvents[currentEvent] and UNITTYPE_PET or sourceName;
 local recipientType = recipientName ~= UNITTYPE_PLAYER and inPetEvents[currentEvent] and recipientName == petName and UNITTYPE_PET or recipientName;

 parserEvent.eventType = EVENTTYPE_HEAL;
 parserEvent.sourceUnit = unitMap[sourceType]
 parserEvent.sourceName = unitTypeMap[sourceType] or sourceName;
 parserEvent.recipientUnit = unitMap[recipientType]
 parserEvent.recipientName = unitTypeMap[recipientType] or recipientName;
 parserEvent.amount = tonumber(captureTable[captureMap[4]] or captureMap[4]);
 parserEvent.abilityName = captureTable[captureMap[5]] or captureMap[5];
 parserEvent.isCrit = captureMap[6];
 parserEvent.isHoT = captureMap[7];
 
 -- Calculate the overhealing on the healed unit (if unit is in the party/raid).
 if (parserEvent.recipientUnit) then
  local healthMissing = UnitHealthMax(parserEvent.recipientUnit) - UnitHealth(parserEvent.recipientUnit);
  local overhealAmount = parserEvent.amount - healthMissing;

  -- Check if any overhealing occured.
  if (overhealAmount > 0) then
   parserEvent.overhealAmount = overhealAmount;
  end 
 end
end


-- ****************************************************************************
-- Populates the parser event data table for a notification event.
-- ****************************************************************************
local function PopulateNotificationEvent(captureMap)
 -- Notification Event (notificationType, sourceName, effectName, amount).
 local sourceName = captureTable[captureMap[3]] or captureMap[3];
 if (sourceName) then sourceName = strtrim(sourceName); end
 local sourceType = sourceName ~= UNITTYPE_PLAYER and inPetEvents[currentEvent] and sourceName == petName and UNITTYPE_PET or sourceName;

 parserEvent.eventType = EVENTTYPE_NOTIFICATION;
 parserEvent.notificationType = captureMap[2];
 parserEvent.sourceUnit = unitMap[sourceType]
 parserEvent.sourceName = unitTypeMap[sourceType] or sourceName;
 parserEvent.effectName = captureTable[captureMap[4]] or captureMap[4];
 parserEvent.amount = tonumber(captureTable[captureMap[5]] or captureMap[5]);
 parserEvent.powerType = captureTable[captureMap[6]] or captureMap[6];
end


-- ****************************************************************************
-- Populates the parser event data table for a PC or NPC killing blow.
-- ****************************************************************************
local function PopulateKillingBlowEvent(captureMap)
 -- Get the name of the slain enemy.
 local enemyName = captureTable[captureMap[2]] or captureMap[2];

 parserEvent.eventType = EVENTTYPE_NOTIFICATION;
 parserEvent.notificationType = NOTIFICATIONTYPE_NPC_KILLING_BLOW;
 parserEvent.sourceUnit = "player";
 parserEvent.sourceName = playerName;
 parserEvent.effectName = enemyName;

 -- Check if the current target is the slain enemy and is a player, or the slain target is on the recently
 -- selected hostile players list.
 if ((UnitExists("target") and (UnitName("target") == enemyName) and UnitIsPlayer("target")) or
     (recentHostiles[enemyName] ~= nil)) then
  -- Change the notification type to a PC killing blow and clear the slain player from the list.
  parserEvent.notificationType = NOTIFICATIONTYPE_PC_KILLING_BLOW;
  recentHostiles[enemyName] = nil;
 end
end


-- ****************************************************************************
-- Populates the parser event data table for an item creation event.
-- ****************************************************************************
local function PopulateItemCreationEvent(captureMap)
 -- Get the created item link.
 local itemLink = captureTable[captureMap[2]] or captureMap[2];

 -- Check if the item created is a Soul Shard.
 local matchStart, _, itemID, itemName = string_find(itemLink, "item:(%d+):[%d:]+|h%[(.+)%]");
 parserEvent.eventType = EVENTTYPE_NOTIFICATION;
 parserEvent.notificationType = NOTIFICATIONTYPE_ITEM_CREATED;
 parserEvent.sourceUnit = "player";
 parserEvent.sourceName = playerName;
 parserEvent.effectName = itemName;
 parserEvent.amount = tonumber(itemID);
end


-- ****************************************************************************
-- Populates the parser event data table for an environmental event.
-- ****************************************************************************
local function PopulateEnvironmentalEvent(captureMap)
 -- Environmental Event (hazardType, damageType, amount).
 parserEvent.eventType = EVENTTYPE_ENVIRONMENTAL;
 parserEvent.hazardType = captureMap[2];
 parserEvent.damageType = captureMap[3];
 parserEvent.recipientUnit = "player";
 parserEvent.recipientName = playerName; 
 parserEvent.amount = tonumber(captureTable[captureMap[4]] or captureMap[4]);
end


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Sends the parser event to the registered event handler for the type.
-- ****************************************************************************
local function SendParserEvent()
 MainParserHandler(parserEvent);
 TriggerParserHandler(parserEvent);
end


-- ****************************************************************************
-- Compares two global strings so the most specific one comes first.  This
-- prevents incorrectly capturing information for certain events.
-- ****************************************************************************
local function GlobalStringCompareFunc(globalStringNameOne, globalStringNameTwo)
 -- Get the global string for the passed names.
 local globalStringOne = _G[globalStringNameOne];
 local globalStringTwo = _G[globalStringNameTwo];

 local gsOneStripped = string.gsub(globalStringOne, "%%%d?%$?[sd]", "");
 local gsTwoStripped = string.gsub(globalStringTwo, "%%%d?%$?[sd]", "");

 -- Check if the stripped global strings are the same length.
 if (string_len(gsOneStripped) == string_len(gsTwoStripped)) then
  -- Count the number of captures in each string.
  local numCapturesOne = 0;
  for _ in string_gmatch(globalStringOne, "%%%d?%$?[sd]") do
   numCapturesOne = numCapturesOne + 1;
  end

  local numCapturesTwo = 0;
  for _ in string_gmatch(globalStringTwo, "%%%d?%$?[sd]") do
   numCapturesTwo = numCapturesTwo + 1;
  end
  
  -- Return the global string with the least captures.
  return numCapturesOne < numCapturesTwo;

 else
  -- Return the longest global string.
  return string_len(gsOneStripped) > string_len(gsTwoStripped);
 end
end


-- ****************************************************************************
-- Converts the passed global string into a lua search pattern with a capture
-- order table and stores the results so any requests to convert the same
-- global string will just return the cached one.
-- ****************************************************************************
local function ConvertGlobalString(globalStringName)
 -- Check if the passed global string does not exist.
 local globalString = _G[globalStringName];
 if (globalString == nil) then
  return;
 end

 -- Return the cached conversion if it has already been converted.
 -- Change to new code.
 if (searchPatterns[globalStringName]) then
  return searchPatterns[globalStringName], captureOrders[globalStringName];
 end

 -- Hold the capture order.
 local captureOrder;
 local numCaptures = 0;

 -- Escape lua magic chars.
 local searchPattern = string.gsub(globalString, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1");

 -- Loop through each capture and setup the capture order.
 for captureIndex in string_gmatch(searchPattern, "%%(%d)%$[sd]") do
  if (not captureOrder) then captureOrder = {}; end
  numCaptures = numCaptures + 1;
  captureOrder[tonumber(captureIndex)] = numCaptures;
 end
 
 -- Convert %1$s / %s to (.+) and %1$d / %d to (%d+).
 searchPattern = string.gsub(searchPattern, "%%%d?%$?s", "(.+)");
 searchPattern = string.gsub(searchPattern, "%%%d?%$?d", "(%%d+)");

 -- Escape any remaining $ chars.
 searchPattern = string.gsub(searchPattern, "%$", "%%$");
 
 -- Cache the converted pattern and capture order.
 searchPatterns[globalStringName] = searchPattern;
 captureOrders[globalStringName] = captureOrder;

 -- Return the converted global string.
 return searchPattern, captureOrder;
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
-- Reorders the capture table according to the passed capture order.
-- ****************************************************************************
local function ReorderCaptures(capOrder)
 local t = captureTable;
 
 t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9] = 
 t[capOrder[1]], t[capOrder[2]], t[capOrder[3]], t[capOrder[4]], t[capOrder[5]], t[capOrder[6]],
 t[capOrder[7]], t[capOrder[8]], t[capOrder[9]];
end


-- ****************************************************************************
-- Parses the passed combat message for partial effects and populates the
-- parser event data table with any found data.
-- ****************************************************************************
local function ParsePartialEffectInfo(combatMessage, startPos)
 local matchStart, capturedAmount;

 -- Check for a glancing blow.
 if (string_find(combatMessage, searchPatterns["GLANCING_TRAILER"], startPos)) then
  parserEvent.isGlancing = true;
 end

 -- Check for a crushing blow.
 if (string_find(combatMessage, searchPatterns["CRUSHING_TRAILER"], startPos)) then
  parserEvent.isCrushing = true;
 end

 -- Check for a partial absorb.
 matchStart, _, capturedAmount = string_find(combatMessage, searchPatterns["ABSORB_TRAILER"], startPos)
 if (matchStart) then
  parserEvent.absorbAmount = capturedAmount;
 end

 -- Check for a partial block.
 matchStart, _, capturedAmount = string_find(combatMessage, searchPatterns["BLOCK_TRAILER"], startPos)
 if (matchStart) then
  parserEvent.blockAmount = capturedAmount;
 end

 -- Check for a partial resist.
 matchStart, _, capturedAmount = string_find(combatMessage, searchPatterns["RESIST_TRAILER"], startPos)
 if (matchStart) then
  parserEvent.resistAmount = capturedAmount;
 end

 -- Check for vulnerability damage.
 matchStart, _, capturedAmount = string_find(combatMessage, searchPatterns["VULNERABLE_TRAILER"], startPos)
 if (matchStart) then
  parserEvent.vulnerabilityAmount = capturedAmount;
 end
end


-- ****************************************************************************
-- Parses the chat message combat events.
-- ****************************************************************************
local function ParseCombatEvent(event, combatMessage)
 -- Leave if there is no map of global strings to search for the event.
 if (not eventSearchMap[event]) then return; end

 -- Set the current event. 
 currentEvent = event;

 -- Loop through all of the global strings to search for the event.
 for _, globalStringName in pairs(eventSearchMap[event]) do
  
  -- Make sure the capture map for the global string exists.
  local captureMap = captureMaps[globalStringName];
  if (captureMap) then
   -- First, check if there is a rare word for the global string and it is in the combat
   -- message since a plain text search is faster than doing a full regular expression search.
   if (not rareWords[globalStringName] or string_find(combatMessage, rareWords[globalStringName], 1, true)) then
   -- Get capture data.
    local matchEnd = CaptureData(string_find(combatMessage, searchPatterns[globalStringName]));

    -- Check if a match was found. 
    if (matchEnd) then
	-- Check if there is a capture order for the global string and reorder the data accordingly.
     if (captureOrders[globalStringName]) then ReorderCaptures(captureOrders[globalStringName]); end

     -- Erase the parser event table and call the appropriate function to populate it.
     for key in pairs(parserEvent) do
      parserEvent[key] = nil;
     end
     captureMap[1](captureMap);

     -- Check if the event type is damage or environmental.
     if (parserEvent.eventType == EVENTTYPE_DAMAGE or
         parserEvent.eventType == EVENTTYPE_ENVIRONMENTAL) then
      -- Check if there are any trailers.
      if (string_len(combatMessage) > matchEnd) then
       -- Parse partial effect trailer information.
       ParsePartialEffectInfo(combatMessage, matchEnd+1);
      end
     end

     -- Send the event if there is one to send.
     if (parserEvent.eventType) then SendParserEvent(); end
     return;
    end -- Match found.
   end -- Fast plain search.
  end -- Capture map is valid.
 end -- Loop through global strings to search. 
end


-------------------------------------------------------------------------------
-- Startup utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates lists of incoming and outgoing events that are fired for pets.
-- ****************************************************************************
local function CreatePetEvents()
 -- Incoming pet events.
 inPetEvents = {
  CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = true, CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS = true, CHAT_MSG_COMBAT_PARTY_HITS = true,
  CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES = true, CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES = true, CHAT_MSG_COMBAT_PARTY_MISSES = true,
  CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = true, CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = true, CHAT_MSG_SPELL_PARTY_DAMAGE = true,
  CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS = true, CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE = true
 };

 -- Outgoing pet events.
 outPetEvents = {
  CHAT_MSG_COMBAT_PET_HITS = true, CHAT_MSG_COMBAT_PET_MISSES = true, CHAT_MSG_SPELL_PET_DAMAGE = true,
 };
 
 -- Outgoing periodic pet events.  These are separate because there is no gaurantee that they are actually from
 -- the pet and thus the name must be checked.
 outPeriodicPetEvents = {
  CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE = true, CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = true
 }; 
end


-- ****************************************************************************
-- Creates a bidirectional map of damage type numbers and strings.
-- ****************************************************************************
local function CreateDamageTypeMap()
 -- Create a map of damage type number to strings.
 damageTypeMap[DAMAGETYPE_PHYSICAL] = SPELL_SCHOOL0_CAP;
 damageTypeMap[DAMAGETYPE_HOLY] = SPELL_SCHOOL1_CAP;
 damageTypeMap[DAMAGETYPE_FIRE] = SPELL_SCHOOL2_CAP;
 damageTypeMap[DAMAGETYPE_NATURE] = SPELL_SCHOOL3_CAP;
 damageTypeMap[DAMAGETYPE_FROST] = SPELL_SCHOOL4_CAP;
 damageTypeMap[DAMAGETYPE_SHADOW] = SPELL_SCHOOL5_CAP;
 damageTypeMap[DAMAGETYPE_ARCANE] = SPELL_SCHOOL6_CAP;
 damageTypeMap[DAMAGETYPE_UNKNOWN] = UNKNOWN; 

 -- Create a reverse lookup.
 damageTypeMap[SPELL_SCHOOL0_CAP] = DAMAGETYPE_PHYSICAL;
 damageTypeMap[SPELL_SCHOOL1_CAP] = DAMAGETYPE_HOLY;
 damageTypeMap[SPELL_SCHOOL2_CAP] = DAMAGETYPE_FIRE;
 damageTypeMap[SPELL_SCHOOL3_CAP] = DAMAGETYPE_NATURE;
 damageTypeMap[SPELL_SCHOOL4_CAP] = DAMAGETYPE_FROST;
 damageTypeMap[SPELL_SCHOOL5_CAP] = DAMAGETYPE_SHADOW;
 damageTypeMap[SPELL_SCHOOL6_CAP] = DAMAGETYPE_ARCANE;
 damageTypeMap[UNKNOWN] = DAMAGETYPE_UNKNOWN;
end


-- ****************************************************************************
-- Creates a map of global strings to search for each event.
-- ****************************************************************************
local function CreateEventSearchMap()
 eventSearchMap = {
  -- Incoming Melee Hits/Crits
  CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = {
   "COMBATHITCRITSCHOOLOTHERSELF", "COMBATHITSCHOOLOTHERSELF", "COMBATHITCRITOTHERSELF", "COMBATHITOTHERSELF",
   "COMBATHITCRITSCHOOLOTHEROTHER", "COMBATHITSCHOOLOTHEROTHER", "COMBATHITCRITOTHEROTHER", "COMBATHITOTHEROTHER"
  },

  -- Incoming Melee Misses, Dodges, Parries, Blocks, Absorbs, Immunes
  CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES = {
   "MISSEDOTHERSELF", "VSDODGEOTHERSELF", "VSPARRYOTHERSELF", "VSBLOCKOTHERSELF", "VSABSORBOTHERSELF", "VSIMMUNEOTHERSELF",
   "MISSEDOTHEROTHER", "VSDODGEOTHEROTHER", "VSPARRYOTHEROTHER", "VSBLOCKOTHEROTHER", "VSABSORBOTHEROTHER", "VSIMMUNEOTHEROTHER"
  },

  -- Incoming Spell/Ability Damage, Misses, Dodges, Parries, Blocks, Absorbs, Resists, Immunes, Reflects, Interrupts, Power Losses
  CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = {
   "COMBATHITCRITOTHERSELF", "COMBATHITOTHERSELF", "COMBATHITSCHOOLOTHERSELF", "COMBATHITCRITSCHOOLOTHERSELF ",
   "SPELLLOGCRITSCHOOLOTHERSELF", "SPELLLOGSCHOOLOTHERSELF", "SPELLLOGCRITOTHERSELF", "SPELLLOGOTHERSELF",
   "SPELLSPLITDAMAGEOTHERSELF", "SPELLMISSOTHERSELF", "SPELLDODGEDOTHERSELF", "SPELLPARRIEDOTHERSELF",
   "SPELLBLOCKEDOTHERSELF", "SPELLRESISTOTHERSELF", "SPELLLOGABSORBOTHERSELF", "SPELLIMMUNEOTHERSELF",
   "COMBATHITCRITOTHEROTHER", "COMBATHITOTHEROTHER", "SPELLLOGCRITSCHOOLOTHEROTHER", "SPELLLOGSCHOOLOTHEROTHER",
   "SPELLLOGCRITOTHEROTHER", "SPELLLOGOTHEROTHER", "SPELLMISSOTHEROTHER", "SPELLDODGEDOTHEROTHER",
   "SPELLPARRIEDOTHEROTHER", "SPELLBLOCKEDOTHEROTHER", "SPELLRESISTOTHEROTHER", "SPELLLOGABSORBOTHEROTHER",
   "SPELLIMMUNEOTHEROTHER", "SPELLINTERRUPTOTHERSELF", "SPELLREFLECTOTHERSELF", "DISPELFAILEDOTHERSELF",
   "SPELLPOWERLEECHOTHERSELF", "SPELLPOWERDRAINOTHERSELF"
  },

  -- Incoming damage from shields
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS = {"DAMAGESHIELDOTHERSELF"},

  -- Incoming Heals, Power Gains
  CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF = {
   "HEALEDCRITOTHERSELF", "HEALEDOTHERSELF", "PERIODICAURAHEALOTHERSELF", "POWERGAINOTHERSELF",
   "POWERGAINSELFSELF", "SPELLPOWERLEECHSELFOTHER"
  },

  -- Incoming DoTs, Power Gains (Leech)
  CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE = {
   "PERIODICAURADAMAGEOTHERSELF", "PERIODICAURADAMAGESELF", "SPELLLOGABSORBOTHERSELF", "SPELLLOGABSORBSELF", "PERIODICAURADAMAGEOTHEROTHER",
   "SPELLLOGABSORBOTHEROTHER", "SPELLPOWERLEECHSELFOTHER"
  },

  -- Incoming HoTs, Power Gains
  CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS = {
   "HEALEDCRITOTHERSELF", "HEALEDOTHERSELF", "PERIODICAURAHEALOTHERSELF", "PERIODICAURAHEALSELFSELF",
   "POWERGAINOTHERSELF", "POWERGAINSELFSELF", "PERIODICAURAHEALSELFOTHER"
  },

  -- Incoming Power Gains from Pet
  CHAT_MSG_SPELL_PET_BUFF = {"POWERGAINOTHERSELF"},

  -- Outgoing Melee Hits/Crits, Environmental Damage
  CHAT_MSG_COMBAT_SELF_HITS = {
   "COMBATHITSELFOTHER", "COMBATHITCRITSELFOTHER", "SPELLLOGCRITSELFOTHER", "SPELLLOGSELFOTHER",
   "SPELLLOGCRITSCHOOLSELFSELF", "SPELLLOGSCHOOLSELFSELF", "SPELLLOGCRITSCHOOLSELFOTHER", "SPELLLOGSCHOOLSELFOTHER",
   "VSENVIRONMENTALDAMAGE_DROWNING_SELF", "VSENVIRONMENTALDAMAGE_FALLING_SELF", "VSENVIRONMENTALDAMAGE_FATIGUE_SELF",
   "VSENVIRONMENTALDAMAGE_FIRE_SELF", "VSENVIRONMENTALDAMAGE_LAVA_SELF", "VSENVIRONMENTALDAMAGE_SLIME_SELF"
  },

  -- Outgoing Melee Misses, Dodges, Parries, Blocks, Absorbs, Immunes, Evades
  CHAT_MSG_COMBAT_SELF_MISSES = { "MISSEDSELFOTHER", "VSDODGESELFOTHER", "VSPARRYSELFOTHER", "VSBLOCKSELFOTHER", "VSABSORBSELFOTHER", "VSIMMUNESELFOTHER", "VSEVADESELFOTHER"},

  -- Outgoing Spell/Ability Damage, Misses, Dodges, Parries, Blocks, Absorbs, Resists, Immunes, Evades, Extra Attacks
  CHAT_MSG_SPELL_SELF_DAMAGE = {
   "SPELLLOGCRITSELFOTHER", "SPELLLOGSELFOTHER", "SPELLLOGCRITSCHOOLSELFSELF", "SPELLLOGSCHOOLSELF",
   "SPELLLOGSCHOOLSELFSELF", "SPELLLOGCRITSCHOOLSELFOTHER", "SPELLLOGSCHOOLSELFOTHER", "SPELLMISSSELFOTHER",
   "SPELLDODGEDSELFOTHER", "SPELLPARRIEDSELFOTHER", "SPELLBLOCKEDSELFOTHER", "SPELLRESISTSELFOTHER",
   "SPELLLOGABSORBSELFOTHER", "SPELLIMMUNESELFOTHER", "SPELLREFLECTSELFOTHER", "SPELLEVADEDSELFOTHER",
   "SPELLINTERRUPTSELFOTHER", "DISPELFAILEDSELFOTHER", "SPELLEXTRAATTACKSSELF", "SPELLEXTRAATTACKSSELF_SINGULAR"
  },

  -- Outgoing damage from shields
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF = {"DAMAGESHIELDSELFOTHER"},

  -- Outgoing Heals, Power Gains, Dispel/Purge Resists, Extra Attacks
  CHAT_MSG_SPELL_SELF_BUFF = {
   "HEALEDCRITSELFSELF", "HEALEDSELFSELF", "HEALEDCRITSELFOTHER", "HEALEDSELFOTHER",
   "POWERGAINSELFSELF", "SPELLPOWERLEECHSELFOTHER", "SPELLRESISTSELFOTHER", "SPELLEXTRAATTACKSSELF",
   "SPELLEXTRAATTACKSSELF_SINGULAR"
  },

  -- Outgoing HoTs, Other's Buffs
  CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS = {
  "PERIODICAURAHEALSELFOTHER", "AURAADDEDOTHERHELPFUL", "AURAAPPLICATIONADDEDOTHERHELPFUL", "PERIODICAURAHEALOTHEROTHER",
  "POWERGAINOTHEROTHER", "POWERGAINOTHERSELF", "SPELLPOWERLEECHOTHEROTHER", "SPELLPOWERLEECHOTHERSELF"
  },

  -- Outgoing DoTs, Power Losses, Other's Debuffs
  CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE = {
   "PERIODICAURADAMAGESELFOTHER", "SPELLLOGABSORBSELFOTHER", "SPELLPOWERLEECHOTHERSELF", "SPELLPOWERDRAINOTHERSELF",
   "AURAADDEDOTHERHARMFUL", "AURAAPPLICATIONADDEDOTHERHARMFUL", "PERIODICAURADAMAGEOTHEROTHER"
  },

  -- Outgoing Pet Melee Hits/Crits
  CHAT_MSG_COMBAT_PET_HITS = {"COMBATHITCRITSCHOOLOTHEROTHER", "COMBATHITSCHOOLOTHEROTHER", "COMBATHITCRITOTHEROTHER", "COMBATHITOTHEROTHER"},

  -- Outgoing Pet Melee Misses
  CHAT_MSG_COMBAT_PET_MISSES = {"MISSEDOTHEROTHER", "VSDODGEOTHEROTHER", "VSPARRYOTHEROTHER", "VSBLOCKOTHEROTHER", "VSABSORBOTHEROTHER", "VSIMMUNEOTHEROTHER", "VSEVADEOTHEROTHER"},

  -- Outgoing Pet Spell/Ability Damage, Misses, Dodges, Parries, Blocks, Absorbs, Resists, Immunes, Evades
  CHAT_MSG_SPELL_PET_DAMAGE = {
   "SPELLLOGCRITOTHEROTHER", "SPELLLOGOTHEROTHER", "SPELLLOGCRITSCHOOLOTHEROTHER", "SPELLLOGSCHOOLOTHEROTHER",
   "SPELLMISSOTHEROTHER", "SPELLDODGEDOTHEROTHER", "SPELLPARRIEDOTHEROTHER", "SPELLBLOCKEDOTHEROTHER",
   "SPELLRESISTOTHEROTHER", "SPELLLOGABSORBOTHEROTHER", "SPELLIMMUNEOTHEROTHER", "SPELLEVADEDOTHEROTHER"
  },

  -- Honor Gains
  CHAT_MSG_COMBAT_HONOR_GAIN = {"COMBATLOG_HONORGAIN", "COMBATLOG_HONORAWARD"},

  -- Reputation Gains/Losses
  CHAT_MSG_COMBAT_FACTION_CHANGE = {"FACTION_STANDING_INCREASED", "FACTION_STANDING_DECREASED"},

  -- Skill Gains
  CHAT_MSG_SKILL = {"SKILL_RANK_UP"},

  -- Experience Gains
  CHAT_MSG_COMBAT_XP_GAIN = {"COMBATLOG_XPGAIN_FIRSTPERSON", "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED"},

  -- Killing Blows
  CHAT_MSG_COMBAT_HOSTILE_DEATH = {"SELFKILLOTHER"},

  -- Created Items
  CHAT_MSG_LOOT = {"LOOT_ITEM_CREATED_SELF", "LOOT_ITEM_PUSHED_SELF"},
  
  CHAT_MSG_MONEY = {"YOU_LOOT_MONEY", "LOOT_MONEY_SPLIT"},
 };

 eventSearchMap["CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"];				-- Incoming Melee Hits/Crits
 eventSearchMap["CHAT_MSG_COMBAT_PARTY_HITS"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"];						-- Incoming Melee Hits/Crits
 eventSearchMap["CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"];			-- Incoming Melee Misses, Dodges, Parries, Blocks, Absorbs, Immunes
 eventSearchMap["CHAT_MSG_COMBAT_PARTY_MISSES"] = eventSearchMap["CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES"];					-- Incoming Melee Misses, Dodges, Parries, Blocks, Absorbs, Immunes
 eventSearchMap["CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"];				-- Incoming Spell/Ability Damage, Misses, Dodges, Parries, Blocks, Absorbs, Resists, Immunes, Reflects, Interrupts, Power Losses
 eventSearchMap["CHAT_MSG_SPELL_PARTY_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"];						-- Incoming Spell/Ability Damage, Misses, Dodges, Parries, Blocks, Absorbs, Resists, Immunes, Reflects, Interrupts, Power Losses
 eventSearchMap["CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF"] = eventSearchMap["CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF"];					-- Incoming Heals, Power Gains
 eventSearchMap["CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"];		-- Outgoing HoTs, Other's Buffs
 eventSearchMap["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"];		-- Outgoing HoTs, Other's Buffs
 eventSearchMap["CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"];				-- Outgoing HoTs, Other's Buffs
 eventSearchMap["CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE"] = eventSearchMap["CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"];	-- Outgoing DoTs, Power Losses, Other's Debuffs


 -- Loop through each of the events.
 for event, map in pairs(eventSearchMap) do
  -- Remove invalid global strings.
  for i = #map, 1, -1 do
   if (not _G[map[i]]) then
    table.remove(map, i);
   end
  end

  -- Sort the global strings from most to least specific.
  table.sort(map, GlobalStringCompareFunc);
 end
end


-- ****************************************************************************
-- Creates a map of data to capture for each global string.
-- ****************************************************************************
local function CreateCaptureMaps()
 captureMaps = {
  -- Damage Event (damageType, sourceName, recipientName, amount, abilityName, isCrit, isDoT).
  COMBATHITCRITOTHEROTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, 2, 3, nil, true, false},
  COMBATHITCRITOTHERSELF = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, UNITTYPE_PLAYER, 2, nil, true, false},
  COMBATHITCRITSCHOOLOTHEROTHER = {PopulateDamageEvent, 4, 1, 2, 3, nil, true, false},
  COMBATHITCRITSCHOOLOTHERSELF = {PopulateDamageEvent, 3, 1, UNITTYPE_PLAYER, 2, nil, true, false},
  COMBATHITCRITSELFOTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, UNITTYPE_PLAYER, 1, 2, nil, true, false},
  COMBATHITOTHEROTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, 2, 3, nil, false, false},
  COMBATHITOTHERSELF = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, UNITTYPE_PLAYER, 2, nil, false, false},
  COMBATHITSCHOOLOTHEROTHER = {PopulateDamageEvent, 4, 1, 2, 3, nil, false, false},
  COMBATHITSCHOOLOTHERSELF = {PopulateDamageEvent, 3, 1, UNITTYPE_PLAYER, 2, nil, false, false},
  COMBATHITSELFOTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, UNITTYPE_PLAYER, 1, 2, nil, false, false},
  DAMAGESHIELDOTHERSELF = {PopulateDamageEvent, 3, 1, UNITTYPE_PLAYER, 2, nil, false, false},
  DAMAGESHIELDSELFOTHER = {PopulateDamageEvent, 2, UNITTYPE_PLAYER, 3, 1, nil, false, false},
  PERIODICAURADAMAGEOTHEROTHER = {PopulateDamageEvent, 3, 4, 1, 2, 5, false, true},
  PERIODICAURADAMAGEOTHERSELF = {PopulateDamageEvent, 2, 3, UNITTYPE_PLAYER, 1, 4, false, true},
  PERIODICAURADAMAGESELF = {PopulateDamageEvent, 2, 3, UNITTYPE_PLAYER, 1, 3, false, true},
  PERIODICAURADAMAGESELFOTHER = {PopulateDamageEvent, 3, UNITTYPE_PLAYER, 1, 2, 4, false, true},
  SPELLLOGCRITOTHEROTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, 3, 4, 2, true, false},
  SPELLLOGCRITOTHERSELF = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, UNITTYPE_PLAYER, 3, 2, true, false},
  SPELLLOGCRITSCHOOLOTHEROTHER = {PopulateDamageEvent, 5, 1, 3, 4, 2, true, false},
  SPELLLOGCRITSCHOOLOTHERSELF = {PopulateDamageEvent, 4, 1, UNITTYPE_PLAYER, 3, 2, true, false},
  SPELLLOGCRITSCHOOLSELFOTHER = {PopulateDamageEvent, 4, UNITTYPE_PLAYER, 2, 3, 1, true, false},
  SPELLLOGCRITSCHOOLSELFSELF = {PopulateDamageEvent, 3, UNITTYPE_PLAYER, UNITTYPE_PLAYER, 2, 1, true, false},
  SPELLLOGCRITSELFOTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, UNITTYPE_PLAYER, 2, 3, 1, true, false},
  SPELLLOGOTHEROTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, 3, 4, 2, false, false},
  SPELLLOGOTHERSELF = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, UNITTYPE_PLAYER, 3, 2, false, false},
  SPELLLOGSCHOOLOTHEROTHER = {PopulateDamageEvent, 5, 1, 3, 4, 2, false, false},
  SPELLLOGSCHOOLOTHERSELF = {PopulateDamageEvent, 4, 1, UNITTYPE_PLAYER, 3, 2, false, false},
  SPELLLOGSCHOOLSELF = {PopulateDamageEvent, 3, UNITTYPE_PLAYER, UNITTYPE_PLAYER, 2, 1, false, false},
  SPELLLOGSCHOOLSELFOTHER = {PopulateDamageEvent, 4, UNITTYPE_PLAYER, 2, 3, 1, false, false},
  SPELLLOGSCHOOLSELFSELF = {PopulateDamageEvent, 3, UNITTYPE_PLAYER, UNITTYPE_PLAYER, 2, 1, false, false},
  SPELLLOGSELFOTHER = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, UNITTYPE_PLAYER, 2, 3, 1, false, false},
  SPELLSPLITDAMAGEOTHERSELF = {PopulateDamageEvent, DAMAGETYPE_PHYSICAL, 1, UNITTYPE_PLAYER, 3, 2, false, false},
  
  -- Miss Event (missType, sourceName, recipientName, abilityName).
  DISPELFAILEDOTHERSELF = {PopulateMissEvent, MISSTYPE_RESIST, 1, UNITTYPE_PLAYER, 2};
  DISPELFAILEDSELFOTHER = {PopulateMissEvent, MISSTYPE_RESIST, UNITTYPE_PLAYER, 1, 2};
  MISSEDOTHEROTHER = {PopulateMissEvent, MISSTYPE_MISS, 1, 2, nil},
  MISSEDOTHERSELF = {PopulateMissEvent, MISSTYPE_MISS, 1, UNITTYPE_PLAYER, nil},
  MISSEDSELFOTHER = {PopulateMissEvent, MISSTYPE_MISS, UNITTYPE_PLAYER, 1, nil},
  SPELLBLOCKEDOTHEROTHER = {PopulateMissEvent, MISSTYPE_BLOCK, 1, 3, 2},
  SPELLBLOCKEDOTHERSELF = {PopulateMissEvent, MISSTYPE_BLOCK, 1, UNITTYPE_PLAYER, 2},
  SPELLBLOCKEDSELFOTHER = {PopulateMissEvent, MISSTYPE_BLOCK, UNITTYPE_PLAYER, 2, 1},
  SPELLDODGEDOTHEROTHER = {PopulateMissEvent, MISSTYPE_DODGE, 1, 3, 2},
  SPELLDODGEDOTHERSELF = {PopulateMissEvent, MISSTYPE_DODGE, 1, UNITTYPE_PLAYER, 2},
  SPELLDODGEDSELFOTHER = {PopulateMissEvent, MISSTYPE_DODGE, UNITTYPE_PLAYER, 2, 1},
  SPELLEVADEDOTHEROTHER = {PopulateMissEvent, MISSTYPE_EVADE, 1, 3, 2},
  SPELLEVADEDSELFOTHER = {PopulateMissEvent, MISSTYPE_EVADE, UNITTYPE_PLAYER, 2, 1},
  SPELLIMMUNEOTHEROTHER = {PopulateMissEvent, MISSTYPE_IMMUNE, 1, 3, 2},
  SPELLIMMUNEOTHERSELF = {PopulateMissEvent, MISSTYPE_IMMUNE, 1, UNITTYPE_PLAYER, 2},
  SPELLIMMUNESELFOTHER = {PopulateMissEvent, MISSTYPE_IMMUNE, UNITTYPE_PLAYER, 2, 1},
  SPELLINTERRUPTOTHERSELF = {PopulateMissEvent, MISSTYPE_INTERRUPT, 1, UNITTYPE_PLAYER, 2},
  SPELLINTERRUPTSELFOTHER = {PopulateMissEvent, MISSTYPE_INTERRUPT, UNITTYPE_PLAYER, 1, 2},
  SPELLLOGABSORBOTHEROTHER = {PopulateMissEvent, MISSTYPE_ABSORB, 1, 3, 2},
  SPELLLOGABSORBOTHERSELF = {PopulateMissEvent, MISSTYPE_ABSORB, 1, UNITTYPE_PLAYER, 2},
  SPELLLOGABSORBSELF = {PopulateMissEvent, MISSTYPE_ABSORB, 1, UNITTYPE_PLAYER, 1},
  SPELLLOGABSORBSELFOTHER = {PopulateMissEvent, MISSTYPE_ABSORB, UNITTYPE_PLAYER, 2, 1},
  SPELLMISSOTHEROTHER = {PopulateMissEvent, MISSTYPE_MISS, 1, 3, 2},
  SPELLMISSOTHERSELF = {PopulateMissEvent, MISSTYPE_MISS, 1, UNITTYPE_PLAYER, 2},
  SPELLMISSSELFOTHER = {PopulateMissEvent, MISSTYPE_MISS, UNITTYPE_PLAYER, 2, 1},
  SPELLPARRIEDOTHEROTHER = {PopulateMissEvent, MISSTYPE_PARRY, 1, 3, 2},
  SPELLPARRIEDOTHERSELF = {PopulateMissEvent, MISSTYPE_PARRY, 1, UNITTYPE_PLAYER, 2},
  SPELLPARRIEDSELFOTHER = {PopulateMissEvent, MISSTYPE_PARRY, UNITTYPE_PLAYER, 2, 1},
  SPELLREFLECTOTHERSELF = {PopulateMissEvent, MISSTYPE_REFLECT, 1, UNITTYPE_PLAYER, 2},
  SPELLREFLECTSELFOTHER = {PopulateMissEvent, MISSTYPE_REFLECT, UNITTYPE_PLAYER, 2, 1},
  SPELLRESISTOTHEROTHER = {PopulateMissEvent, MISSTYPE_RESIST, 1, 3, 2},
  SPELLRESISTOTHERSELF = {PopulateMissEvent, MISSTYPE_RESIST, 1, UNITTYPE_PLAYER, 2},
  SPELLRESISTSELFOTHER = {PopulateMissEvent, MISSTYPE_RESIST, UNITTYPE_PLAYER, 2, 1},
  VSABSORBOTHEROTHER = {PopulateMissEvent, MISSTYPE_ABSORB, 1, 2, nil},
  VSABSORBOTHERSELF = {PopulateMissEvent, MISSTYPE_ABSORB, 1, UNITTYPE_PLAYER, nil},
  VSABSORBSELFOTHER = {PopulateMissEvent, MISSTYPE_ABSORB, UNITTYPE_PLAYER, 1, nil},
  VSBLOCKOTHEROTHER = {PopulateMissEvent, MISSTYPE_BLOCK, 1, 2, nil},
  VSBLOCKOTHERSELF = {PopulateMissEvent, MISSTYPE_BLOCK, 1, UNITTYPE_PLAYER, nil},
  VSBLOCKSELFOTHER = {PopulateMissEvent, MISSTYPE_BLOCK, UNITTYPE_PLAYER, 1, nil},
  VSDODGEOTHEROTHER = {PopulateMissEvent, MISSTYPE_DODGE, 1, 2, nil},
  VSDODGEOTHERSELF = {PopulateMissEvent, MISSTYPE_DODGE, 1, UNITTYPE_PLAYER, nil},
  VSDODGESELFOTHER ={PopulateMissEvent, MISSTYPE_DODGE, UNITTYPE_PLAYER, 1, nil},
  VSEVADEOTHEROTHER = {PopulateMissEvent, MISSTYPE_EVADE, 1, 2, nil},
  VSEVADESELFOTHER = {PopulateMissEvent, MISSTYPE_EVADE, UNITTYPE_PLAYER, 1, nil},
  VSIMMUNEOTHEROTHER = {PopulateMissEvent, MISSTYPE_IMMUNE, 1, 2, nil},
  VSIMMUNEOTHERSELF = {PopulateMissEvent, MISSTYPE_IMMUNE, 1, UNITTYPE_PLAYER, nil},
  VSIMMUNESELFOTHER = {PopulateMissEvent, MISSTYPE_IMMUNE, UNITTYPE_PLAYER, 1, nil},
  VSPARRYOTHEROTHER = {PopulateMissEvent, MISSTYPE_PARRY, 1, 2, nil},
  VSPARRYOTHERSELF = {PopulateMissEvent, MISSTYPE_PARRY, 1, UNITTYPE_PLAYER, nil},
  VSPARRYSELFOTHER = {PopulateMissEvent, MISSTYPE_PARRY, UNITTYPE_PLAYER, 1, nil},  

  -- Heal Event (sourceName, recipientName, amount, abilityName, isCrit, isHoT).
  HEALEDCRITOTHERSELF = {PopulateHealEvent, 1, UNITTYPE_PLAYER, 3, 2, true, false},
  HEALEDCRITSELFOTHER = {PopulateHealEvent, UNITTYPE_PLAYER, 2, 3, 1, true, false},
  HEALEDCRITSELFSELF = {PopulateHealEvent, UNITTYPE_PLAYER, UNITTYPE_PLAYER, 2, 1, true, false},
  HEALEDOTHERSELF = {PopulateHealEvent, 1, UNITTYPE_PLAYER, 3, 2, false, false},
  HEALEDSELFOTHER = {PopulateHealEvent, UNITTYPE_PLAYER, 2, 3, 1, false, false},
  HEALEDSELFSELF = {PopulateHealEvent, UNITTYPE_PLAYER, UNITTYPE_PLAYER, 2, 1, false, false},
  PERIODICAURAHEALOTHEROTHER = {PopulateHealEvent, 3, 1, 2, 4, false, false},
  PERIODICAURAHEALOTHERSELF = {PopulateHealEvent, 2, UNITTYPE_PLAYER, 1, 3, false, true},
  PERIODICAURAHEALSELFOTHER = {PopulateHealEvent, UNITTYPE_PLAYER, 1, 2, 3, false, true},
  PERIODICAURAHEALSELFSELF = {PopulateHealEvent, UNITTYPE_PLAYER, UNITTYPE_PLAYER, 1, 2, false, true},

  -- Notification Event (notificationType, sourceName, effectName, amount, powerType).
  AURAADDEDOTHERHARMFUL = {PopulateNotificationEvent, NOTIFICATIONTYPE_DEBUFF, 1, 2, nil, nil},
  AURAADDEDOTHERHELPFUL = {PopulateNotificationEvent, NOTIFICATIONTYPE_BUFF, 1, 2, nil, nil},
  AURAAPPLICATIONADDEDOTHERHARMFUL = {PopulateNotificationEvent, NOTIFICATIONTYPE_DEBUFF, 1, 2, 3, nil},
  AURAAPPLICATIONADDEDOTHERHELPFUL = {PopulateNotificationEvent, NOTIFICATIONTYPE_BUFF, 1, 2, 3, nil}, 
  COMBATLOG_HONORAWARD = {PopulateNotificationEvent, NOTIFICATIONTYPE_HONOR_GAIN, UNITTYPE_PLAYER, nil, 1, nil},
  COMBATLOG_HONORGAIN = {PopulateNotificationEvent, NOTIFICATIONTYPE_HONOR_GAIN, UNITTYPE_PLAYER, nil, 3, nil},
  COMBATLOG_XPGAIN_FIRSTPERSON = {PopulateNotificationEvent, NOTIFICATIONTYPE_EXPERIENCE_GAIN, UNITTYPE_PLAYER, nil, 2, nil},
  COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = {PopulateNotificationEvent, NOTIFICATIONTYPE_EXPERIENCE_GAIN, UNITTYPE_PLAYER, nil, 1, nil},
  FACTION_STANDING_DECREASED = {PopulateNotificationEvent, NOTIFICATIONTYPE_REP_LOSS, UNITTYPE_PLAYER, 1, 2, nil},
  FACTION_STANDING_INCREASED =  {PopulateNotificationEvent, NOTIFICATIONTYPE_REP_GAIN, UNITTYPE_PLAYER, 1, 2, nil},
  LOOT_MONEY_SPLIT = {PopulateNotificationEvent, NOTIFICATIONTYPE_MONEY, UNITTYPE_PLAYER, 1, nil, nil},
  POWERGAINOTHEROTHER = {PopulateNotificationEvent, NOTIFICATIONTYPE_POWER_GAIN, 1, 5, 2, 3},
  POWERGAINOTHERSELF = {PopulateNotificationEvent, NOTIFICATIONTYPE_POWER_GAIN, UNITTYPE_PLAYER, 4, 1, 2},
  POWERGAINSELFSELF = {PopulateNotificationEvent, NOTIFICATIONTYPE_POWER_GAIN, UNITTYPE_PLAYER, 3, 1, 2},
  SKILL_RANK_UP = {PopulateNotificationEvent, NOTIFICATIONTYPE_SKILL_GAIN, UNITTYPE_PLAYER, 1, 2, nil},
  SPELLEXTRAATTACKSSELF = {PopulateNotificationEvent, NOTIFICATIONTYPE_EXTRA_ATTACK, UNITTYPE_PLAYER, 2, 1, nil},
  SPELLEXTRAATTACKSSELF_SINGULAR = {PopulateNotificationEvent, NOTIFICATIONTYPE_EXTRA_ATTACK, UNITTYPE_PLAYER, 2, 1, nil},
  SPELLPOWERDRAINOTHERSELF = {PopulateNotificationEvent, NOTIFICATIONTYPE_POWER_LOSS, UNITTYPE_PLAYER, 2, 3, 4},
  SPELLPOWERLEECHOTHEROTHER = {PopulateNotificationEvent, NOTIFICATIONTYPE_POWER_LOSS, 5, 2, 3, 4},
  SPELLPOWERLEECHOTHERSELF = {PopulateNotificationEvent, NOTIFICATIONTYPE_POWER_LOSS, UNITTYPE_PLAYER, 2, 3, 4},
  SPELLPOWERLEECHSELFOTHER = {PopulateNotificationEvent, NOTIFICATIONTYPE_POWER_GAIN, UNITTYPE_PLAYER, 1, 2, 3},
  YOU_LOOT_MONEY = {PopulateNotificationEvent, NOTIFICATIONTYPE_MONEY, UNITTYPE_PLAYER, 1, nil, nil},
  
  -- Item Creation Notification Event (itemLink).
  LOOT_ITEM_CREATED_SELF = {PopulateItemCreationEvent, 1},
  LOOT_ITEM_PUSHED_SELF = {PopulateItemCreationEvent, 1},
  
  -- Killing Blow Notification Event (recipientName).
  SELFKILLOTHER = {PopulateKillingBlowEvent, 1},

  -- Environmental Event (hazardType, damageType, amount).
  VSENVIRONMENTALDAMAGE_DROWNING_SELF = {PopulateEnvironmentalEvent, HAZARDTYPE_DROWNING, DAMAGETYPE_NATURE, 1},
  VSENVIRONMENTALDAMAGE_FALLING_SELF = {PopulateEnvironmentalEvent, HAZARDTYPE_FALLING, DAMAGETYPE_PHYSICAL, 1},
  VSENVIRONMENTALDAMAGE_FATIGUE_SELF = {PopulateEnvironmentalEvent, HAZARDTYPE_FATIGUE, DAMAGETYPE_PHYSICAL, 1},
  VSENVIRONMENTALDAMAGE_FIRE_SELF = {PopulateEnvironmentalEvent, HAZARDTYPE_FIRE, DAMAGETYPE_FIRE, 1},
  VSENVIRONMENTALDAMAGE_LAVA_SELF = {PopulateEnvironmentalEvent, HAZARDTYPE_LAVA, DAMAGETYPE_FIRE, 1},
  VSENVIRONMENTALDAMAGE_SLIME_SELF = {PopulateEnvironmentalEvent, HAZARDTYPE_SLIME, DAMAGETYPE_NATURE, 1},
 };


 -- Print an error message for each global string that isn't found and remove it from the map.
 for globalStringName in pairs(captureMaps) do
  if (not _G[globalStringName]) then
   Print("Unable to find global string: " .. globalStringName, 1, 0, 0);
   captureMaps[globalStringName] = nil;
  end
 end
end


-- ****************************************************************************
-- Finds the rarest word for each global string.
-- ****************************************************************************
local function FindRareWords()
 -- Hold the number of times each word appears in all the global strings.
 local wordCounts = {};

 -- Loop through all of the supported global strings.
 for globalStringName in pairs(captureMaps) do
  -- Strip out all of the formatting codes.
  local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "");

  -- Count how many times each word appears in the global string.
  for word in string_gmatch(strippedGS, "%w+") do
   wordCounts[word] = (wordCounts[word] or 0) + 1;
  end
 end


 -- Loop through all of the supported global strings.
 for globalStringName in pairs(captureMaps) do
  local leastSeen, rarestWord;

  -- Strip out all of the formatting codes.
  local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "");

  -- Find the rarest word in the global string.
  for word in string_gmatch(strippedGS, "%w+") do
   if (not leastSeen or wordCounts[word] < leastSeen) then
    leastSeen = wordCounts[word];
    rarestWord = word;
   end
  end

  -- Set the rarest word.
  rareWords[globalStringName] = rarestWord;
 end
end


-- ****************************************************************************
-- Validates rare words to make sure there are no oddities caused by various
-- languages. 
-- ****************************************************************************
local function ValidateRareWords()
 -- Loop through all of the global strings there is a rare word entry for.
 for globalStringName, rareWord in pairs(rareWords) do
  -- Remove the entry if the rare word isn't found in the associated global string.
  if (not string_find(_G[globalStringName], rareWord, 1, true)) then
   rareWords[globalStringName] = nil;
  end
 end
end


-- ****************************************************************************
-- Converts all of the supported global strings.
-- ****************************************************************************
local function ConvertGlobalStrings()
 -- Loop through all of the global string capture maps.
 for globalStringName in pairs(captureMaps) do
  -- Get the global string converted to a lua search pattern and prepend an anchor to
  -- speed up searching.
  searchPatterns[globalStringName] = "^" .. ConvertGlobalString(globalStringName);
 end

 -- Convert and cache all of the trailer global strings.
 ConvertGlobalString("ABSORB_TRAILER");
 ConvertGlobalString("BLOCK_TRAILER");
 ConvertGlobalString("RESIST_TRAILER");
 ConvertGlobalString("VULNERABLE_TRAILER");
 ConvertGlobalString("CRUSHING_TRAILER");
 ConvertGlobalString("GLANCING_TRAILER");
end


-------------------------------------------------------------------------------
-- Aura functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Gets the item buff name for the passed slot.
-- ****************************************************************************
local function GetItemBuffName(slotNumber)
 -- Set the tooltip to the buff index.
 tooltipFrame:SetOwner(UIParent, "ANCHOR_NONE");
 tooltipFrame:SetInventoryItem("player", slotNumber);

 local text, buffName;
 for i = 1, tooltipFrame:NumLines() do
  -- Get the text for the line number and attempt to extract a temporary item buff from it.
  text = _G[tooltipFrame:GetName() .. "TextLeft" .. i]:GetText();
  _, _, buffName = string_find(text, "^([^%(]+) %(%d+ [^%)]+%)");

  -- Check if an item buff was found and return it.
  if (buffName) then return buffName; end
 end
end


-- ****************************************************************************
-- Populates the current auras table with current buff and debuff information.
-- ****************************************************************************
local function PopulateCurrentBuffsAndDebuffs()
 -- Erase the old current aura buffs.
 EraseTable(currentAuras.buffs);

 -- Erase the old current aura debuffs.
 EraseTable(currentAuras.debuffs);

 -- Loop through all of the buffs and add the name to the buffs table.
 local buffName;
 for buffIndex = 1, MAX_BUFFS do
  buffName = UnitBuff("player", buffIndex);
  if (not buffName) then break; end
  currentAuras.buffs[buffName] = true;
 end

 -- Loop through all of the debuffs and add the name to the debuffs table.
 for buffIndex = 1, MAX_DEBUFFS do
  buffName = UnitDebuff("player", buffIndex);
  if (not buffName) then break; end
  currentAuras.debuffs[buffName] = true;
 end
end


-- ****************************************************************************
-- Populates the current auras table with the current item buff information.
-- ****************************************************************************
local function PopulateCurrentItemBuffs()
 -- Erase the old current aura item buffs.
 for buffName in pairs(currentAuras.itemBuffs) do
  currentAuras.itemBuffs[buffName] = nil;
 end

 -- Add main hand item buff info to the item buffs table.
 local hasMainHandBuff, _, _, hasOffHandBuff = GetWeaponEnchantInfo();
 if (hasMainHandBuff) then
  buffName = GetItemBuffName(GetInventorySlotInfo("MainHandSlot"));
  if (buffName) then
   currentAuras.itemBuffs[buffName] = true;
  end
 end

 -- Add off hand item buff info to the item buffs table.
 if (hasOffHandBuff) then
  buffName = GetItemBuffName(GetInventorySlotInfo("SecondaryHandSlot"));
  if (buffName) then
   currentAuras.itemBuffs[buffName] = true;
  end
 end
end


-- ****************************************************************************
-- Populates the parser event data table for an aura change or the passed type.
-- ****************************************************************************
local function DoAuraChange(tableName, gainNotificationType, fadeNotificationType)
 -- Loop through all of the saved auras for the passed buff table to check for those that have faded.
 for buffName in pairs(savedAuras[tableName]) do
  if (not currentAuras[tableName][buffName]) then
   savedAuras[tableName][buffName] = nil;
   EraseTable(parserEvent);
   parserEvent.eventType = EVENTTYPE_NOTIFICATION;
   parserEvent.notificationType = fadeNotificationType;
   parserEvent.sourceUnit = "player";
   parserEvent.sourceName = playerName;
   parserEvent.effectName = buffName;
   SendParserEvent();
  end
 end

 -- Loop through all of the current auras for the passed buff table to check for those that have been gained.
 for buffName in pairs(currentAuras[tableName]) do
  if (not savedAuras[tableName][buffName]) then
   savedAuras[tableName][buffName] = true;
   EraseTable(parserEvent);
   parserEvent.eventType = EVENTTYPE_NOTIFICATION;
   parserEvent.notificationType = gainNotificationType;
   parserEvent.sourceUnit = "player";
   parserEvent.sourceName = playerName;
   parserEvent.effectName = buffName;
   SendParserEvent();
  end
 end
end


-- ****************************************************************************
-- Called when the OnUpdate event occurs.
-- ****************************************************************************
local function OnUpdateItemBuffs(this, elapsed)
 -- Increment the amount of time passed since the last update.
 lastItemBuffUpdate = lastItemBuffUpdate + elapsed;

 -- Check if it's time for an update.
 if (lastItemBuffUpdate >= ITEM_BUFF_UPDATE_INTERVAL) then
  -- Send events for item buff changes.
  PopulateCurrentItemBuffs();
  DoAuraChange("itemBuffs", NOTIFICATIONTYPE_ITEM_BUFF, NOTIFICATIONTYPE_ITEM_BUFF_FADE);

  -- Reset the time since last update.
  lastItemBuffUpdate = 0;
 end
end


-- ****************************************************************************
-- Initializes the current auras.
-- ****************************************************************************
local function InitAuras()
 -- Populate the current buffs, debuffs, and item buffs.
 PopulateCurrentBuffsAndDebuffs();
 PopulateCurrentItemBuffs();

 -- Save the current auras as the initial state.
 for tableName in pairs(currentAuras) do
  for buffName in pairs(currentAuras[tableName]) do
   savedAuras[tableName][buffName] = true;
  end
 end
 
 -- Set the auras initialized flag.
 aurasInitialized = true;

 -- Start searching for item buff changes if there is no delayed info.
 if (not isUnitMapStale and not isPetNameStale) then eventFrame:SetScript("OnUpdate", OnUpdateItemBuffs); end
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when there is information that needs to be obtained after a delay.
-- ****************************************************************************
local function OnUpdateDelayedInfo(this, elapsed)
 -- Check if the unit map needs to be updated after a delay.
 if (isUnitMapStale) then
  -- Increment the amount of time passed since the last update.
  lastUnitMapUpdate = lastUnitMapUpdate + elapsed;

  -- Check if it's time for an update.
  if (lastUnitMapUpdate >= UNIT_MAP_UPDATE_DELAY) then
   -- Erase the unit map table.
   for key in pairs(unitMap) do
    unitMap[key] = nil;
   end

   -- Create an entry for the player and pet.
   unitMap[UNITTYPE_PLAYER] = "player";
   unitMap[UNITTYPE_PET] = "pet";
  
   -- Get the number of raid and party members.
   local numRaidMembers = GetNumRaidMembers();
  
   -- Check if there are raid members.
   if (numRaidMembers > 0) then
    -- Loop through all of the raid members and add them.
    for i = 1, numRaidMembers do
     local unitID = "raid" .. i;
	 unitMap[UnitName(unitID)] = unitID;
    end
   else
    -- Loop through all of the party members and add them.
    for i = 1, GetNumPartyMembers() do
     local unitID = "party" .. i;
     unitMap[UnitName(unitID)] = unitID;    
    end
   end

   -- Clear the unit map stale flag.
   isUnitMapStale = false;

   -- Reset the time since last update.
   lastUnitMapUpdate = 0;
  end
 end -- Unit map is stale.


 -- Check if the pet name needs to be updated after a delay.
 if (isPetNameStale) then
  -- Increment the amount of time passed since the last update.
  lastPetUpdate = lastPetUpdate + elapsed;
  
  -- Check if it's time for an update.
  if (lastPetUpdate >= PET_UPDATE_DELAY) then
   -- Update the pet name.
   petName = UnitName("pet");
   unitTypeMap[UNITTYPE_PET] = petName;

   -- Clear the pet name stale flag if there is no pet name at all or there is a pet name
   -- and it's not unknown.
   if (not petName or petName ~= UNKNOWN) then isPetNameStale = false; end

   -- Reset the time since last update.
   lastPetUpdate = 0;
  end
 end -- Pet name is stale.


 -- Check if the auras have been initialized.
 if (aurasInitialized) then
  -- Call the item buffs update handler.
  OnUpdateItemBuffs(this, elapsed);

  -- Reset the OnUpdate handler to the item buffs handler if there is no more delayed info.
  if (not isUnitMapStale and not isPetNameStale) then eventFrame:SetScript("OnUpdate", OnUpdateItemBuffs); end
 end
end


-- ****************************************************************************
-- Called when the events the parser registered for occur.
-- ****************************************************************************
local function OnEvent(this, event, arg1, arg2)
 -- Combo Point Gains
 if (event == "PLAYER_COMBO_POINTS") then
  local numCP = GetComboPoints();

  -- Make sure there are combo points.
  if (numCP ~= 0) then
   EraseTable(parserEvent);
   parserEvent.eventType = EVENTTYPE_NOTIFICATION;
   parserEvent.notificationType = NOTIFICATIONTYPE_CP_GAIN;
   parserEvent.sourceUnit = "player";
   parserEvent.sourceName = playerName;
   parserEvent.amount = numCP;
   SendParserEvent();
  end

 -- Leave Combat
 elseif (event == "PLAYER_REGEN_ENABLED") then
  EraseTable(parserEvent);
  parserEvent.eventType = EVENTTYPE_NOTIFICATION;
  parserEvent.notificationType = NOTIFICATIONTYPE_COMBAT_LEAVE;
  parserEvent.sourceUnit = "player";
  parserEvent.sourceName = playerName;
  SendParserEvent();

 -- Enter Combat
 elseif (event == "PLAYER_REGEN_DISABLED") then
  EraseTable(parserEvent);
  parserEvent.eventType = EVENTTYPE_NOTIFICATION;
  parserEvent.notificationType = NOTIFICATIONTYPE_COMBAT_ENTER;
  parserEvent.sourceUnit = "player";
  parserEvent.sourceName = playerName;
  SendParserEvent();

 -- Target changes
 elseif (event == "PLAYER_TARGET_CHANGED") then
  -- Make sure a unit is selected, is a player, and is hostile.
  if (UnitExists("target") and UnitIsPlayer("target") and not UnitIsFriend("player", "target")) then
   -- Get the current time and check if it's time to clean up targets.
   local now = GetTime();
   if (now >= targetCleanupTime) then
    -- Loop through all of the recently selected hostile players.
    for name, cleanupTime in pairs(recentHostiles) do
     if (now >= cleanupTime) then
      recentHostiles[name] = nil;
     end
    end

    -- Update the target cleanup time.
    targetCleanupTime = now + RECENT_HOSTILES_HOLD_TIME;
   end

   -- Get the unit's name and make sure it's valid before adding it to the recent hostile player's list.
   local targetName = UnitName("target");
   if (targetName) then
    recentHostiles[targetName] = now + RECENT_HOSTILES_HOLD_TIME;
   end
  end

 -- Buff/Debuff Gains/Fades
 elseif (event == "PLAYER_AURAS_CHANGED") then
  -- Initialize the auras if they haven't already been.
  if (not aurasInitialized) then
   InitAuras();
   return;
  end

  -- Populate the current buffs and debuffs.
  PopulateCurrentBuffsAndDebuffs();

  -- Send events for buff and debuff changes.
  DoAuraChange("buffs", NOTIFICATIONTYPE_BUFF, NOTIFICATIONTYPE_BUFF_FADE);
  DoAuraChange("debuffs", NOTIFICATIONTYPE_DEBUFF, NOTIFICATIONTYPE_DEBUFF_FADE);

 -- Monster emotes.
 elseif (event == "CHAT_MSG_MONSTER_EMOTE") then
  EraseTable(parserEvent);
  parserEvent.eventType = EVENTTYPE_NOTIFICATION;
  parserEvent.notificationType = NOTIFICATIONTYPE_MONSTER_EMOTE;
  parserEvent.sourceName = arg2;
  parserEvent.effectName = arg1;
  SendParserEvent();


 -- Party/Raid changes
 elseif (event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE") then
  -- Set the unit map stale flag and schedule the unit map to be updated after a short delay.
  isUnitMapStale = true;
  eventFrame:SetScript("OnUpdate", OnUpdateDelayedInfo);

 -- Pet changes
 elseif (event == "UNIT_PET") then
  if (arg1 == "player") then
   -- Set the pet name stale flag and schedule the pet name to be updated after a short delay.
   isPetNameStale = true;
   eventFrame:SetScript("OnUpdate", OnUpdateDelayedInfo);
  end
   
 -- Chat message combat events.
 else
  ParseCombatEvent(event, arg1);

 end
end


-- ****************************************************************************
-- Enables parsing.
-- ****************************************************************************
local function Enable()
 -- Register events in the search map.
 for event in pairs(eventSearchMap) do
  eventFrame:RegisterEvent(event);
 end
 
 -- Register events that aren't a part of the event search map.
 eventFrame:RegisterEvent("PLAYER_COMBO_POINTS");
 eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
 eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
 eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
 eventFrame:RegisterEvent("PLAYER_AURAS_CHANGED");
 eventFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE");
 eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
 eventFrame:RegisterEvent("RAID_ROSTER_UPDATE");
 eventFrame:RegisterEvent("UNIT_PET");

 -- Update the unit map and current pet information.
 isUnitMapStale = true;
 isPetNameStale = true;
 eventFrame:SetScript("OnUpdate", OnUpdateDelayedInfo);

 -- Start receiving updates.
 eventFrame:Show();
end


-- ****************************************************************************
-- Disables the parsing.
-- ****************************************************************************
local function Disable()
 -- Stop receiving updates.
 eventFrame:Hide();
 eventFrame:SetScript("OnUpdate", nil); 
 eventFrame:UnregisterAllEvents();
 
 -- Clear the recently selected hostile players list.
 EraseTable(recentHostiles);

 -- Erase the saved aura tables.
 EraseTable(savedAuras.buffs);
 EraseTable(savedAuras.debuffs)
 EraseTable(savedAuras.itemBuffs)
 aurasInitialized = nil;
end


-- ****************************************************************************
-- Called when the entire addon is loaded.
-- ****************************************************************************
local function OnAddonLoaded()
 MainParserHandler = MikSBT.Main.ParserEventsHandler;
 TriggerParserHandler = MikSBT.Triggers.ParserEventsHandler;
end


-- ****************************************************************************
-- Called when the parser is loaded.
-- ****************************************************************************
local function OnLoad()
 -- Create a frame to receive events.
 eventFrame = CreateFrame("Frame");
 eventFrame:Hide();
 eventFrame:SetScript("OnEvent", OnEvent);

 -- Create a tooltip frame to get item buff names.
 tooltipFrame = CreateFrame("GameTooltip", "MSBT" .. moduleName .. "Tooltip", UIParent, "GameTooltipTemplate");

 -- Get the name of the player and associate the special unit type id.
 playerName = UnitName("player");
 unitTypeMap[UNITTYPE_PLAYER] = playerName;

 -- Create the lists of incoming and outgoing events that are fired for pets.
 CreatePetEvents();
 
 -- Create various maps.
 CreateDamageTypeMap();
 CreateEventSearchMap();
 CreateCaptureMaps();

 -- Find the rarest word for each supported global string.
 FindRareWords();
 ValidateRareWords();

 -- Convert the supported global strings into lua search patterns.
 ConvertGlobalStrings();
end





-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Constants.
module.EVENTTYPE_DAMAGE 					= EVENTTYPE_DAMAGE;
module.EVENTTYPE_MISS						= EVENTTYPE_MISS;
module.EVENTTYPE_HEAL						= EVENTTYPE_HEAL;
module.EVENTTYPE_NOTIFICATION				= EVENTTYPE_NOTIFICATION;
module.EVENTTYPE_ENVIRONMENTAL				= EVENTTYPE_ENVIRONMENTAL;
module.DAMAGETYPE_PHYSICAL					= DAMAGETYPE_PHYSICAL;
module.DAMAGETYPE_HOLY						= DAMAGETYPE_HOLY;
module.DAMAGETYPE_FIRE						= DAMAGETYPE_FIRE;
module.DAMAGETYPE_NATURE					= DAMAGETYPE_NATURE;
module.DAMAGETYPE_FROST						= DAMAGETYPE_FROST;
module.DAMAGETYPE_SHADOW					= DAMAGETYPE_SHADOW;
module.DAMAGETYPE_ARCANE					= DAMAGETYPE_ARCANE;
module.DAMAGETYPE_UNKNOWN					= DAMAGETYPE_UNKNOWN;
module.MISSTYPE_MISS						= MISSTYPE_MISS;
module.MISSTYPE_DODGE						= MISSTYPE_DODGE;
module.MISSTYPE_PARRY						= MISSTYPE_PARRY;
module.MISSTYPE_BLOCK						= MISSTYPE_BLOCK;
module.MISSTYPE_RESIST						= MISSTYPE_RESIST;
module.MISSTYPE_ABSORB						= MISSTYPE_ABSORB;
module.MISSTYPE_IMMUNE						= MISSTYPE_IMMUNE;
module.MISSTYPE_EVADE						= MISSTYPE_EVADE;
module.MISSTYPE_REFLECT						= MISSTYPE_REFLECT;
module.MISSTYPE_INTERRUPT					= MISSTYPE_INTERRUPT;
module.NOTIFICATIONTYPE_DEBUFF				= NOTIFICATIONTYPE_DEBUFF;
module.NOTIFICATIONTYPE_BUFF				= NOTIFICATIONTYPE_BUFF;
module.NOTIFICATIONTYPE_ITEM_BUFF			= NOTIFICATIONTYPE_ITEM_BUFF;
module.NOTIFICATIONTYPE_DEBUFF_FADE			= NOTIFICATIONTYPE_DEBUFF_FADE;
module.NOTIFICATIONTYPE_BUFF_FADE			= NOTIFICATIONTYPE_BUFF_FADE;
module.NOTIFICATIONTYPE_ITEM_BUFF_FADE		= NOTIFICATIONTYPE_ITEM_BUFF_FADE;
module.NOTIFICATIONTYPE_COMBAT_ENTER		= NOTIFICATIONTYPE_COMBAT_ENTER;
module.NOTIFICATIONTYPE_COMBAT_LEAVE		= NOTIFICATIONTYPE_COMBAT_LEAVE;
module.NOTIFICATIONTYPE_POWER_GAIN			= NOTIFICATIONTYPE_POWER_GAIN;
module.NOTIFICATIONTYPE_POWER_LOSS			= NOTIFICATIONTYPE_POWER_LOSS;
module.NOTIFICATIONTYPE_CP_GAIN				= NOTIFICATIONTYPE_CP_GAIN;
module.NOTIFICATIONTYPE_HONOR_GAIN			= NOTIFICATIONTYPE_HONOR_GAIN;
module.NOTIFICATIONTYPE_REP_GAIN			= NOTIFICATIONTYPE_REP_GAIN;
module.NOTIFICATIONTYPE_REP_LOSS			= NOTIFICATIONTYPE_REP_LOSS;
module.NOTIFICATIONTYPE_SKILL_GAIN			= NOTIFICATIONTYPE_SKILL_GAIN;
module.NOTIFICATIONTYPE_EXPERIENCE_GAIN		= NOTIFICATIONTYPE_EXPERIENCE_GAIN;
module.NOTIFICATIONTYPE_PC_KILLING_BLOW		= NOTIFICATIONTYPE_PC_KILLING_BLOW;
module.NOTIFICATIONTYPE_NPC_KILLING_BLOW	= NOTIFICATIONTYPE_NPC_KILLING_BLOW;
module.NOTIFICATIONTYPE_ITEM_CREATED		= NOTIFICATIONTYPE_ITEM_CREATED;
module.NOTIFICATIONTYPE_EXTRA_ATTACK		= NOTIFICATIONTYPE_EXTRA_ATTACK;
module.NOTIFICATIONTYPE_MONSTER_EMOTE		= NOTIFICATIONTYPE_MONSTER_EMOTE;
module.NOTIFICATIONTYPE_MONEY				= NOTIFICATIONTYPE_MONEY;
module.HAZARDTYPE_DROWNING					= HAZARDTYPE_DROWNING;
module.HAZARDTYPE_FALLING					= HAZARDTYPE_FALLING;
module.HAZARDTYPE_FATIGUE					= HAZARDTYPE_FATIGUE;
module.HAZARDTYPE_FIRE						= HAZARDTYPE_FIRE;
module.HAZARDTYPE_LAVA						= HAZARDTYPE_LAVA;
module.HAZARDTYPE_SLIME						= HAZARDTYPE_SLIME;

-- Protected Variables.
module.currentAuras = currentAuras;
module.damageTypeMap = damageTypeMap;

-- Protected Functions.
module.ConvertGlobalString			= ConvertGlobalString;
module.Enable						= Enable;
module.Disable						= Disable;
module.OnAddonLoaded				= OnAddonLoaded;


-------------------------------------------------------------------------------
-- Load.
-------------------------------------------------------------------------------

OnLoad();