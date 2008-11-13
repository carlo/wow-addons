-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Main
-- Author: Mik
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {};
local moduleName = "Main";
MikSBT[moduleName] = module;


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- How long to wait before showing events so that merges may happen.
local MERGE_DELAY_TIME = 0.3;

-- How long to wait between throttle window checking.
local THROTTLE_UPDATE_TIME = 0.5;

-- The overheal trailer to use.
local OVERHEAL_TRAILER = " <%d>";


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Dynamically created frames for receiving events.
local eventFrame;
local throttleFrame;

-- Pool of dynamically created combat events that are reused.
local combatEventCache = {};

-- Lookup tables.
local missTypes = {};
local notificationTypes = {};
local hazardTypes = {};
local damageColorProfileEntries = {};
local powerTypes = {};

-- Throttled ability info.
local throttledAbilities = {};

-- Holds unmerged and merged combat events.
local unmergedEvents = {};
local mergedEvents = {};

-- Used for timing between updates.
local lastMergeUpdate = 0;
local lastThrottleUpdate = 0;

-- Spam control info.
local lastPowerAmount = 65535;
local isEnglish;

-- Regen ability info.
local regenAbilities = {};
local activeRegenAbility;
local currentBuffs = MikSBT.Parser.currentAuras.buffs;


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to certain MSBT modules for faster access.
local MSBTLocale = MikSBT.Locale;
local MSBTAnimations = MikSBT.Animations;
local MSBTParser = MikSBT.Parser;
local MSBTTriggers = MikSBT.Triggers;
local MSBTProfiles = MikSBT.Profiles;
local LBS = MSBTIconSupport and MSBTIconSupport.LBS;

-- Local references to certain functions and variables for faster access.
local table_remove = table.remove;
local math_ceil = math.ceil;
local string_find = string.find;
local string_gsub = string.gsub;
local string_format = string.format;
local GetTime = GetTime;
local EraseTable = MikSBT.EraseTable;
local Print = MikSBT.Print;
local DisplayEvent = MSBTAnimations.DisplayEvent;
local IsScrollAreaActive = MSBTAnimations.IsScrollAreaActive;
local damageTypeMap = MSBTParser.damageTypeMap;
local triggerSuppressions = MSBTTriggers.triggerSuppressions;


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns an abbreviated form of the passed ability name.
-- ****************************************************************************
local function AbbreviateAbilityName(abilityName)
  if (string_find(abilityName, "[%s%-]")) then
   abilityName = string_gsub(abilityName, "(%a)[%l%p]*[%s%-]*", "%1");
  end

  return abilityName;
end


-- ****************************************************************************
-- Returns a formatted partial effects trailer using the passed parameters.
-- ****************************************************************************
local function FormatPartialEffects(absorbAmount, blockAmount, resistAmount, vulnerabilityAmount, isGlancing, isCrushing)
 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile;

 local effectSettings, trailer;
 local partialEffectText = "";

 -- Partial Absorb
 if (absorbAmount and ABSORB_TRAILER) then
  effectSettings = currentProfile.absorb;
  trailer = string_gsub(ABSORB_TRAILER, "%%d", absorbAmount);

 -- Partial Block
 elseif (blockAmount and BLOCK_TRAILER) then
  effectSettings = currentProfile.block;
  trailer = string_gsub(BLOCK_TRAILER, "%%d", blockAmount);

 -- Partial Resist
 elseif (resistAmount and RESIST_TRAILER) then
  effectSettings = currentProfile.resist;
  trailer = string_gsub(RESIST_TRAILER, "%%d", resistAmount);

 -- Vulnerability
 elseif (vulnerabilityAmount) then
  effectSettings = currentProfile.vulnerability;
  trailer = string_gsub(MSBTLocale.MSG_VULNERABLE_TRAILER, "%%d", vulnerabilityAmount);
 end

 -- Set the partial effect text if there are settings for it, it's enabled, and it's valid.
 if (effectSettings and not effectSettings.disabled and trailer) then
  -- Color the text if coloring isn't disabled.
  if (not currentProfile.partialColoringDisabled) then
   partialEffectText = string_format("|cFF%02x%02x%02x%s|r", math_ceil(effectSettings.colorR * 255), math_ceil(effectSettings.colorG * 255), math_ceil(effectSettings.colorB * 255), trailer);
  else
   partialEffectText = trailer;
  end
 end

 
 -- Clear the effect settings and trailer.
 effectSettings = nil;
 trailer = nil;
 
 -- Glancing hit
 if (isGlancing and not currentProfile.glancing.disabled and GLANCING_TRAILER) then
  effectSettings = currentProfile.glancing;
  trailer = GLANCING_TRAILER;

 -- Crushing blow
 elseif (isCrushing and CRUSHING_TRAILER) then
  effectSettings = currentProfile.crushing;
  trailer = CRUSHING_TRAILER;
 end

 -- Append the crushing/glancing text if there are settings for it, it's enabled, and it's valid.
 if (effectSettings and not effectSettings.disabled and trailer) then
  -- Color the text if coloring isn't disabled.
  if (not currentProfile.partialColoringDisabled) then
   partialEffectText = partialEffectText .. string_format("|cFF%02x%02x%02x%s|r", math_ceil(effectSettings.colorR * 255), math_ceil(effectSettings.colorG * 255), math_ceil(effectSettings.colorB * 255), trailer);
  else
   partialEffectText = partialEffectText .. trailer;
  end
 end

 return partialEffectText; 
end


-- ****************************************************************************
-- Formats an event with the parameters.
-- ****************************************************************************
local function FormatEvent(message, amount, damageType, overhealAmount, powerType, name, effectName, partialEffects, mergeTrailer, ignorePhysical, filterCodes)
 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile;
 local texturePath, checkParens;
 
 -- Substitute amount.
 if (amount and string_find(message, "%%a")) then
  -- Get the hex color for the damage type if there is one and coloring is enabled.
  local damageColorCode;
  if (damageType and not currentProfile.damageColoringDisabled) then
   -- Set the damage color code if the color data is present for the damage type.
   local damageColor = currentProfile[damageColorProfileEntries[damageType]];
   if (damageColor and not damageColor.disabled) then
    damageColorCode = string_format("|cFF%02x%02x%02x", math_ceil(damageColor.colorR * 255), math_ceil(damageColor.colorG * 255), math_ceil(damageColor.colorB * 255));
   end

   -- Ignore physical damage coloring on outgoing events.
   if (ignorePhysical and damageType == MSBTParser.DAMAGETYPE_PHYSICAL) then damageColorCode = nil; end
  end -- Damage type and damage coloring is enabled.

  -- Check if there is overheal information and displaying it is enabled.
  if (overhealAmount and not currentProfile.overheal.disabled) then
   -- Deduct the overheal amount from the total amount healed.
   amount = amount - overhealAmount;
   
   -- Get the overheal amount and color it with the correct color if coloring is enabled.
   local overhealColorCode;
   if (not currentProfile.partialColoringDisabled) then
    local overhealColor = currentProfile.overheal;
    overhealColorCode = string_format("|cFF%02x%02x%02x", math_ceil(overhealColor.colorR * 255), math_ceil(overhealColor.colorG * 255), math_ceil(overhealColor.colorB * 255)); 
   end

   -- Color the overheal amount if there is a color code.
   if (overhealColorCode) then
    overhealAmount = overhealColorCode .. overhealAmount .. "|r";
   end
   
   -- Append the overheal amount to the actual amount healed.
   amount = amount .. string_gsub(OVERHEAL_TRAILER, "%%d", overhealAmount);
  end -- Overheal amount and overhealing display enabled.

  -- Color the amount according to the damage type, if any.
  if (damageColorCode) then amount = damageColorCode .. amount .. "|r"; end

  -- Substitute all %a event codes with the amount.
  message = string_gsub(message, "%%a", amount);
 end -- Substitute amount.


 -- Substitute power type.
 if (powerType and string_find(message, "%%p")) then message = string_gsub(message, "%%p", powerType); end
 

 -- Substitute names.
 if (name and string_find(message, "%%n")) then
  if (filterCodes and currentProfile.hideNames) then
   message = string_gsub(message, "%s?%-?%s?%%n", "");
   checkParens = true;
  else
   message = string_gsub(message, "%%n", name);
  end
 end


 -- Substitute effect names. 
 if (effectName and string_find(message, "%%e")) then message = string_gsub(message, "%%e", effectName); end


 -- Substitute ability names.
 if (effectName) then
  if (not currentProfile.skillIconsDisabled) then texturePath = LBS and LBS:GetSpellIcon(effectName); end
  
  if (string_find(message, "%%s")) then
   -- Hide skill names if there is an icon for it and the option is set.
   if (filterCodes and (texturePath and not currentProfile.exclusiveSkillsDisabled or currentProfile.hideSkills)) then
    message = string_gsub(message, "%s?%-?%s?%%sl?%s?%-?%s?", "");
    checkParens = true;
   else
    -- Use the user defined substitution for the ability if there is one.
    local isChanged;
    if (currentProfile.abilitySubstitutions[effectName]) then
     effectName = currentProfile.abilitySubstitutions[effectName];
     isChanged = true;
    end

    -- Do long substitutions.
    if (string_find(message, "%%sl")) then message = string_gsub(message, "%%sl", effectName); end

    -- Abbreviate ability for english if it wasn't user substituted and abbreviation is enabled.
    if (isEnglish and not isChanged and currentProfile.abbreviateAbilities) then
     effectName = AbbreviateAbilityName(effectName);
    end

    -- Do remaining substitutions.
    message = string_gsub(message, "%%s", effectName);
   end
  end
 end
 

 -- Remove empty parenthesis left frame ignoring event codes.
 if (checkParens) then message = string_gsub(message, "%(%)", ""); end


 -- Substitute damage types.
 if (damageType and string_find(message, "%%t")) then message = string_gsub(message, "%%t", damageTypeMap[damageType]); end
 
 
 -- Append partial effects if there are any.
 if (partialEffects) then message = message .. partialEffects; end

 
 -- Append the merge trailer if there is one.
 if (mergeTrailer) then message = message .. mergeTrailer; end
 
 -- Return the formatted message.
 return message, texturePath; 
end


-- ****************************************************************************
-- Detect all power gains.
-- ****************************************************************************
local function DetectPowerGain(powerAmount)
 -- Get the event settings for power gains.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_POWER_GAIN;

 -- Don't do anything if power gains are disabled. 
 if (eventSettings.disabled) then return; end

 -- Display the power change if it is a gain.
 if (powerAmount > lastPowerAmount) then
  -- Display the power gain.
  DisplayEvent(eventSettings, FormatEvent(eventSettings.message, powerAmount - lastPowerAmount, nil, nil, powerTypes[UnitPowerType("player")]));
 end
end


-- ****************************************************************************
-- Merges like combat events.
-- ****************************************************************************
local function MergeEvents(numEvents)
 -- Holds an unmerged event and whether or not to merge it.
 local unmergedEvent;
 local doMerge = false;

 -- Don't attempt to merge any more events than were available when the function was called since
 -- more events may get added while the merge is taking place.
 for i = 1, numEvents do
  -- Get the unmerged event.
  unmergedEvent = unmergedEvents[i];

  -- Loop through all of the events in the merged events array.
  for _, mergedEvent in ipairs(mergedEvents) do
   -- Check if the event types match.
   if (unmergedEvent.eventType == mergedEvent.eventType) then
    -- Check if there is no ability/spell name. 
    if (not unmergedEvent.effectName) then
     -- Set the merge flag if the affected unit name is the same.
     if ((unmergedEvent.name == mergedEvent.name) and unmergedEvent.name) then doMerge = true; end

    -- The ability/spell names match.
    elseif (unmergedEvent.effectName == mergedEvent.effectName) then
     -- Change the name to the multiple targets string if the names don't match.
     if (unmergedEvent.name ~= mergedEvent.name) then mergedEvent.name = MSBTLocale.MSG_MULTIPLE_TARGETS; end

     -- Set the merge flag.
     doMerge = true; 
    end
   end -- Event types match.

   -- Check if the event should be merged.
   if (doMerge) then
    -- Clear partial effects.
    mergedEvent.partialEffects = nil;

    -- Set the event merged flag for the event being merged.
    unmergedEvent.eventMerged = true;

    -- Total the amount if there is one.
    if (unmergedEvent.amount) then mergedEvent.amount = (mergedEvent.amount or 0) + unmergedEvent.amount; end

    -- Total the overheal amount if there is one.
    if (unmergedEvent.overhealAmount) then mergedEvent.overhealAmount = (mergedEvent.overhealAmount or 0) + unmergedEvent.overhealAmount; end

    -- Increment the number of merged events.
    mergedEvent.numMerged = mergedEvent.numMerged + 1;

    -- Increment the number of crits is the event being merged is a crit.  Clear the crit flag for the merged event if it isn't.
    if (unmergedEvent.isCrit) then mergedEvent.numCrits = mergedEvent.numCrits + 1; else mergedEvent.isCrit = false; end

    -- Break out of the merged events loop since the event has been merged.
    break;
   end -- Do Merge.
  end -- Loop through merged events.

  -- Add the event to the end of the merged events array if it wasn't merged.
  if (not doMerge) then
   unmergedEvent.numMerged = 0;

   -- Set the number of crits depending on if the event is a crit or not.
   if (unmergedEvent.isCrit) then unmergedEvent.numCrits = 1; else unmergedEvent.numCrits = 0; end

   -- Add the event to the end of the merged events array.
   mergedEvents[#mergedEvents+1] = unmergedEvent;
  end

  -- Reset the event merge flag.
  doMerge = false;
 end -- Loop through unmerged events.

 
 -- Append merge trailer information to the merged events.
 for _, mergedEvent in ipairs(mergedEvents) do
  -- Check if there were any events merged.
  if (mergedEvent.numMerged > 0) then
   -- Create the crit trailer text if there were any crits.
   local critTrailer = "";
   if (mergedEvent.numCrits > 0) then
    critTrailer = string_format(", %d %s", mergedEvent.numCrits, mergedEvent.numCrits == 1 and MSBTLocale.MSG_CRIT or MSBTLocale.MSG_CRITS);
   end
   
   -- Set the event's merge trailer field.
   mergedEvent.mergeTrailer = string_format(" [%d %s%s]", mergedEvent.numMerged + 1, MSBTLocale.MSG_HITS, critTrailer);
  end -- Events were merged.
 end

 
 -- Remove the processed events from unmerged events queue.
 for i = 1, numEvents do
  -- Recycle the unmerged event if it was merged.
  if (unmergedEvents[1].eventMerged) then 
   EraseTable(unmergedEvents[1]);
   combatEventCache[#combatEventCache+1] = unmergedEvents[1];
  end
  
  -- Remove the event from the unmerged events array.
  table_remove(unmergedEvents, 1);
 end
end


-------------------------------------------------------------------------------
-- Command handler functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns the current and remaining parameters from the passed string.
-- ****************************************************************************
local function GetNextParameter(paramString)
 local remainingParams;
 local currentParam = paramString;

 -- Look for a space.
 local index = string_find(paramString, " ");
 if (index) then
  -- Get the current and remaing parameters.
  currentParam = string.sub(paramString, 1, index-1);
  remainingParams = string.sub(paramString, index+1);
 end

 -- Return the current parameter and the remaining ones.
 return currentParam, remainingParams;
end


-- ****************************************************************************
-- Called to handle commands.
-- ****************************************************************************
local function CommandHandler(params)
 -- Get the parameter.
 local currentParam, remainingParams;
 currentParam, remainingParams = GetNextParameter(params);

 -- Flag for whether or not to show usage info.
 local showUsage = true;

 -- Make sure there is a current parameter and lower case it.
 if (currentParam) then currentParam = string.lower(currentParam); end

 -- Look for the recognized parameters.
 if (currentParam == "") then
  -- Load the on demand options if they are not loaded.
  if (not IsAddOnLoaded("MSBTOptions")) then UIParentLoadAddOn("MSBTOptions"); end

  -- Show the options interface after verifying the on demand options actually loaded.
  if (IsAddOnLoaded("MSBTOptions")) then MSBTOptions.Main.ShowMainFrame(); end

  -- Don't show the usage info.
  showUsage = false;

  -- Reset.
  elseif (currentParam == MSBTLocale.COMMAND_RESET) then
  -- Reset the current profile.
  MSBTProfiles.ResetProfile(nil, true);

  -- Don't show the usage info.
  showUsage = false;
  
 -- Disable.
 elseif (currentParam == MSBTLocale.COMMAND_DISABLE) then
  -- Set the user disabled option.
  MSBTProfiles.SetOptionUserDisabled(true);

  -- Output an informative message.
  Print(MSBTLocale.MSG_DISABLE, 1,1,1);

  -- Don't show the usage info.
  showUsage = false;

 -- Enable.
 elseif (currentParam == MSBTLocale.COMMAND_ENABLE) then
  -- Unset the user disabled option.
  MSBTProfiles.SetOptionUserDisabled(false);

  -- Output an informative message.
  Print(MSBTLocale.MSG_ENABLE, 1,1,1);

  -- Don't show the usage info.
  showUsage = false;

 -- Version.
 elseif (currentParam == MSBTLocale.COMMAND_SHOWVER) then
  -- Output the current version number.
  Print(MikSBT.VERSION_STRING, 1,1,1);

  -- Don't show the usage info.
  showUsage = false;

 -- Search.
 elseif (currentParam == MSBTLocale.COMMAND_SEARCH) then
  -- Turn on event searching mode if there is filter text.
  if (remainingParams and remainingParams ~= "") then
   MSBTTriggers.EnableEventSearching(remainingParams);
   Print(MSBTLocale.MSG_SEARCH_ENABLE .. remainingParams, 1, 1, 1);
  else
   -- Turn off event searching mode.
   MSBTTriggers.DisableEventSearching();
   Print(MSBTLocale.MSG_SEARCH_DISABLE, 1, 1, 1);
  end

  -- Don't show the usage info.
  showUsage = false;

 end 

 -- Check if the usage information should be shown.
 if (showUsage) then
  -- Loop through all of the entries in the command usage list.
  for _, msg in ipairs(MSBTLocale.COMMAND_USAGE) do
   Print(msg, 1, 1, 1);
  end
 end
 
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Parser events handler.
-- ****************************************************************************
local function ParserEventsHandler(parserEvent)
 -- Hold the event type string and affected unit name.
 local eventTypeString, affectedUnitName;

 -- Hold the merge flag, effect name, and ignore physical coloring flag.
 local mergeEligible = true;
 local effectName, ignorePhysical;

 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile;
 
 -- Hold whether the event is a crit.
 local isCrit;


 -- Notification.
 if (parserEvent.eventType == MSBTParser.EVENTTYPE_NOTIFICATION) then
  -- Clear the merge flag since notification events don't need to be merged.
  mergeEligible = nil;

  -- Set the effect name.
  effectName = parserEvent.effectName;

  -- The player is the source of the notification.
  if (parserEvent.sourceUnit == "player") then
   -- Set the appropriate notification type.
   eventTypeString = notificationTypes[parserEvent.notificationType]


   -- Buff gain.
   if (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_BUFF) then
    -- Set the active regen ability if the buff being gained is on the regen abilities list.
    if (regenAbilities[effectName] and not currentProfile.regenAbilitiesDisabled) then activeRegenAbility = effectName; end

    -- Ignore the event if it's suppressed due to a trigger.
    if (triggerSuppressions[effectName]) then return; end

   -- Buff fade.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_BUFF_FADE) then
    -- Clear the active regen ability if the fading buff is the active one.
    if (effectName == activeRegenAbility) then activeRegenAbility = nil; end
   
    -- Ignore the event if it's suppressed due to a trigger.
    if (triggerSuppressions[effectName]) then return; end

   -- Debuff gain/fade.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_DEBUFF or
           parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_DEBUFF_FADE) then

    -- Ignore the event if it's suppressed due to a trigger.
    if (triggerSuppressions[effectName]) then return; end

   -- Combo point gain.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_CP_GAIN) then
    -- Set event to full combo points if we just reached the max combo points.
    if (parserEvent.amount == MAX_COMBO_POINTS) then eventTypeString = "NOTIFICATION_CP_FULL"; end

   -- Created item.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_ITEM_CREATED) then
    -- Set event to soul shard creation if the created item is one.
    if (parserEvent.amount == 6265) then eventTypeString = "NOTIFICATION_SOUL_SHARD_CREATED"; end

   -- Power gain.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_POWER_GAIN) then
    -- Ignore the event if all power gains are being shown.
    if (currentProfile.showAllPowerGains or currentBuffs[activeRegenAbility]) then return; end
   
    -- Ignore the event if the power gain is under the threshold to be shown.
    if (parserEvent.amount and parserEvent.amount < currentProfile.powerThreshold) then return; end

    -- Allow power gains to be merged.
    mergeEligible = true;
	
   -- Money gain.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_MONEY) then
    -- Color the gold, silver, and copper text.
    effectName = string_gsub(effectName, GOLD, "|cffffd700%1|r");
    effectName = string_gsub(effectName, SILVER, "|cff808080%1|r");
    effectName = string_gsub(effectName, COPPER, "|cffeda55f%1|r");
   end
 
  -- Another unit is the source of the notification.   
  else  
   -- Target buff gains.
   if (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_BUFF) then
    -- TODO: Option for Target only buff gains.
    -- Ignore the event if it's not the current target.
    if (parserEvent.sourceName ~= UnitName("target")) then return; end
	
    -- Ignore the event if it's a friendly unit.
	if (not UnitIsEnemy("player", "target")) then return; end

    -- Set the event type and correct name.
    eventTypeString = "NOTIFICATION_ENEMY_BUFF";
    affectedUnitName = parserEvent.sourceName;

   -- Monster emotes.
   elseif (parserEvent.notificationType == MSBTParser.NOTIFICATIONTYPE_MONSTER_EMOTE) then
    -- Ignore the event if it's not the current target.
    if (parserEvent.sourceName ~= UnitName("target")) then return; end

    -- Set the event type.
    eventTypeString = "NOTIFICATION_MONSTER_EMOTE";

	-- Substitute in the correct monster name.
	effectName = string_gsub(effectName, "%%s", parserEvent.sourceName);
    
   end
  end
  

 -- Environmental.
 elseif (parserEvent.eventType == MSBTParser.EVENTTYPE_ENVIRONMENTAL) then
  -- Clear the merge flag since environmental events don't need to be merged.
  mergeEligible = nil;
  eventTypeString = "INCOMING_ENVIRONMENTAL";

  -- Set the correct effect name.
  effectName = hazardTypes[parserEvent.hazardType];


 -- Other event types.
 else
  -- Setup info for whether the event is incoming or outgoing.
  if (parserEvent.recipientUnit == "player") then
   affectedUnitName = parserEvent.sourceName;
   eventTypeString = "INCOMING";
  elseif (parserEvent.sourceUnit == "player") then
   affectedUnitName = parserEvent.recipientName;
   eventTypeString = "OUTGOING";
   ignorePhysical = true;
  elseif (parserEvent.recipientUnit == "pet") then
   affectedUnitName = parserEvent.sourceName;
   eventTypeString = "PET_INCOMING";
  elseif (parserEvent.sourceUnit == "pet") then
   affectedUnitName = parserEvent.recipientName;
   eventTypeString = "PET_OUTGOING";
  else
   -- Ignore the event if it doesn't pertain to the player or their pet.
   return;
  end


  -- Damage.
  if (parserEvent.eventType == MSBTParser.EVENTTYPE_DAMAGE) then
   -- Ignore the event if the damage amount is under the damage threshold to be shown.
   if (parserEvent.amount and parserEvent.amount < currentProfile.damageThreshold) then return; end
 
   -- Append the spell prefix if there is an ability name.
   if (parserEvent.abilityName) then
    eventTypeString = eventTypeString .. "_SPELL";
    effectName = parserEvent.abilityName;
   end

   -- Append the correct damage event type for whether or not it's a DoT.
   if (parserEvent.isDoT) then
    eventTypeString = eventTypeString .. "_DOT";
   else
    eventTypeString = eventTypeString .. "_DAMAGE";
   end

   -- Get whether or not it's a crit.
   isCrit = parserEvent.isCrit;


  -- Miss.
  elseif (parserEvent.eventType == MSBTParser.EVENTTYPE_MISS) then
   -- Append the spell prefix if there is an ability name.
   if (parserEvent.abilityName) then
    eventTypeString = eventTypeString .. "_SPELL";
    effectName = parserEvent.abilityName;
   end

   -- Append the correct miss type.
   local missType = missTypes[parserEvent.missType];
   if (missType) then eventTypeString = eventTypeString .. missType; end
  

  -- Heal.
  elseif (parserEvent.eventType == MSBTParser.EVENTTYPE_HEAL) then
   -- Ignore the event if the heal amount is under the healing threshold to be shown.
   if (parserEvent.amount and parserEvent.amount < currentProfile.healThreshold) then return; end
  
   -- Set the effect name.
   effectName = parserEvent.abilityName;

   -- Append the correct heal event type for whether or not it's a HoT.
   if (parserEvent.isHoT) then
    eventTypeString = eventTypeString .. "_HOT";
   else
    eventTypeString = eventTypeString .. "_HEAL";
   end
  
   -- Get whether or not it's a crit.
   isCrit = parserEvent.isCrit;
  end
 end

 
 -- Ignore the event if there is an ability name and it's suppressed.
 if (effectName and currentProfile.abilitySuppressions[effectName]) then return; end
 
 -- Ignore the event if there is no profile data for it, it's disabled, or the scroll area it's using is not active.
 local eventSettings = currentProfile.events[isCrit and eventTypeString .. "_CRIT" or eventTypeString];
 if (not eventSettings or eventSettings.disabled or not IsScrollAreaActive(eventSettings.scrollArea)) then return; end


 -- Get the formatted partial effects if it's a damage or environmental event. 
 local partialEffects;
 if (parserEvent.eventType == MSBTParser.EVENTTYPE_DAMAGE or parserEvent.eventType == MSBTParser.EVENTTYPE_ENVIRONMENTAL) then
  partialEffects = FormatPartialEffects(parserEvent.absorbAmount, parserEvent.blockAmount, parserEvent.resistAmount, parserEvent.vulnerabilityAmount, parserEvent.isGlancing, parserEvent.isCrushing);
 end


 -- Check if the event is eligible for merging. 
 if (mergeEligible and not currentProfile.mergeExclusions[effectName]) then
  -- Acquire a recycled table from cache or create a new one if there aren't any available in cache.
  local combatEvent = table_remove(combatEventCache) or {};
  

  -- Setup the combat event.
  combatEvent.eventType = eventTypeString;
  combatEvent.isCrit = isCrit;
  combatEvent.amount = parserEvent.amount;
  combatEvent.effectName = effectName;
  combatEvent.name = affectedUnitName;
  combatEvent.damageType = parserEvent.damageType;
  combatEvent.ignorePhysical = ignorePhysical;
  combatEvent.partialEffects = partialEffects;
  combatEvent.overhealAmount = parserEvent.overhealAmount;
  combatEvent.powerType = parserEvent.powerType;

  
  -- Throttle events according to user settings.
  if (effectName) then
   -- Get the duration the ability should be throttled for, if any.
   local throttleDuration = currentProfile.throttleList[effectName];

   -- Set throttle duration for power changes or dots/hots if there isn't a specific one set for the ability.
   if (not throttleDuration) then
    -- Use the dot throttle duration.
    if (parserEvent.isDoT and currentProfile.dotThrottleDuration > 0) then
     throttleDuration = currentProfile.dotThrottleDuration;

    -- Use the hot throttle duration.
    elseif (parserEvent.isHoT and currentProfile.hotThrottleDuration > 0) then
     throttleDuration = currentProfile.hotThrottleDuration;

    -- Use the power change throttle duration.
    elseif (parserEvent.powerType and currentProfile.powerThrottleDuration > 0) then
     throttleDuration = currentProfile.powerThrottleDuration;
    end
   end

   -- Check if there is a throttle duration for the ability.
   if (throttleDuration and throttleDuration > 0) then
    -- Get throttle info for the ability.  Create it if it hasn't already been.
    local throttledAbility = throttledAbilities[effectName];
    if (not throttledAbility) then
     throttledAbility = {};
     throttledAbility.throttleWindow = 0;
     throttledAbility.lastEventTime = 0;
     throttledAbilities[effectName] = throttledAbility;
    end

    -- Throttle the event and exit if the throttle window for the ability hasn't elapsed.
    local curTime = GetTime();
    if (throttledAbility.throttleWindow > 0) then
      throttledAbility.lastEventTime = curTime;
      throttledAbility[#throttledAbility+1] = combatEvent;
      return;

    -- The throttle window for the ability has elapsed.
    else
     -- Set the throttle window for the ability to its throttle duration.
     throttledAbility.throttleWindow = throttleDuration;

     -- Check if the throttle frame is not visible and make it visible so the OnUpdate events start firing.
     -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
     if (not throttleFrame:IsVisible()) then throttleFrame:Show(); end

     -- Throttle the event and exit if it has been seen within the throttle duration.
     if (curTime - throttledAbility.lastEventTime < throttleDuration) then
      throttledAbility.lastEventTime = curTime;
      throttledAbility[#throttledAbility+1] = combatEvent; 
      return;
     end -- 
    end
   end 
  end
  
  -- Add event to the unmerged events for potential merging.
  unmergedEvents[#unmergedEvents+1] = combatEvent;
  
  -- Check if the merge event frame is not visible and make it visible so the OnUpdate events start firing.
  -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
  if (not eventFrame:IsVisible()) then eventFrame:Show(); end
  
 -- Event is not to be merged so just display it now.
 else
  -- Display the event.
  DisplayEvent(eventSettings, FormatEvent(eventSettings.message, parserEvent.amount, parserEvent.damageType, nil, parserEvent.powerType, affectedUnitName, effectName));
 end
end


-- ****************************************************************************
-- Called when the event frame is updated.
-- ****************************************************************************
local function OnUpdateEventFrame(this, elapsed)
 -- Increment the amount of time passed since the last update. 
 lastMergeUpdate = lastMergeUpdate + elapsed;

 -- If it's time for an update.
 if (lastMergeUpdate >= MERGE_DELAY_TIME) then
  -- Merge like events.
  MergeEvents(#unmergedEvents);

  -- Display and recycle the merged events.
  local eventSettings;
  for i, combatEvent in ipairs(mergedEvents) do
   eventSettings = MSBTProfiles.currentProfile.events[combatEvent.isCrit and combatEvent.eventType .. "_CRIT" or combatEvent.eventType];
   DisplayEvent(eventSettings, FormatEvent(eventSettings.message, combatEvent.amount, combatEvent.damageType, combatEvent.overhealAmount, combatEvent.powerType, combatEvent.name, combatEvent.effectName, combatEvent.partialEffects, combatEvent.mergeTrailer, combatEvent.ignorePhysical, true));
   mergedEvents[i] = nil;
   EraseTable(combatEvent);
   combatEventCache[#combatEventCache+1] = combatEvent;
  end

  -- Hide the frame if there are no remaining unmerged events so the OnUpdate events stop firing.
  -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
  if (#unmergedEvents == 0) then this:Hide(); end 
  
  -- Reset the time since last update.
  lastMergeUpdate = 0;
 end
end


-- ****************************************************************************
-- Called when the throttle frame is updated.
-- ****************************************************************************
local function OnUpdateThrottleFrame(this, elapsed)
 -- Increment the amount of time passed since the last update. 
 lastThrottleUpdate = lastThrottleUpdate + elapsed;

 -- If it's time for an update.
 if (lastThrottleUpdate >= THROTTLE_UPDATE_TIME) then
  -- Flag for whether there are any events currently throttled.
  local eventsThrottled;

  -- Loop through all the throttled abilities.
  for _, throttledAbility in pairs(throttledAbilities) do
   -- Check if the ability is currently being throttled.
   if (throttledAbility.throttleWindow > 0) then
    -- Decrement the throttle window.
    throttledAbility.throttleWindow = throttledAbility.throttleWindow - lastThrottleUpdate;

    -- Check if the throttle window has elapsed.
    if (throttledAbility.throttleWindow <= 0) then
     -- Add throttled events to the merging system if there are any.
     if (#throttledAbility > 0) then 
      for i = 1, #throttledAbility do
       unmergedEvents[#unmergedEvents+1] = throttledAbility[i];
       throttledAbility[i] = nil;
      end

      -- Check if the merge event frame is not visible and make it visible so the OnUpdate events start firing.
      -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
      if (not eventFrame:IsVisible()) then eventFrame:Show(); end
     end
    -- Ability is still throttled so set the flag.
	else
     eventsThrottled = true;
    end
   end -- Ability is within its throttle window.
  end -- Loop through throttled abilities.


  -- Hide the frame if there are no remaining throttled events so the OnUpdate events stop firing.
  -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
  if (not eventsThrottled) then this:Hide(); end
  
  -- Reset the time since last update.
  lastThrottleUpdate = 0;
 end
end


-- ****************************************************************************
-- Called when the registered events occur.
-- ****************************************************************************
local function OnEvent(this, event, arg1)
 -- When an addon is loaded.
 if (event == "ADDON_LOADED") then
  -- Make sure it's this addon.
  if (arg1 == "MikScrollingBattleText") then
   -- Don't get notification for other addons being loaded.
   this:UnregisterEvent("ADDON_LOADED");

   -- Register slash commands
   SLASH_MSBT1 = MikSBT.COMMAND;
   SlashCmdList["MSBT"] = CommandHandler;

   -- Let the parser know that the addon is loaded.
   MSBTParser.OnAddonLoaded();

   -- Initialize the saved variables to make sure there is a profile to work with.
   MSBTProfiles.InitSavedVariables();
  end
  
 -- Variables for all addons loaded.
 elseif (event == "VARIABLES_LOADED") then
  -- Disable or enable the mod depending on the saved setting.
  -- Must do it once the variables are loaded because blizzard's code overrides the FCT
  -- settings after the ADDON_LOADED code runs.
  MSBTProfiles.SetOptionUserDisabled(MSBTProfiles.IsModDisabled());
  collectgarbage("collect");


 -- Power changes.
 elseif (event == "UNIT_MANA" or event == "UNIT_RAGE" or event == "UNIT_ENERGY") then
  -- Check if the power change is for the player.  
  if (arg1 == "player") then
   -- Update the power amount.
   -- Detect power gains if there is a regen ability active or show all power gains is enabled.
   local powerAmount = UnitMana("player");
   if (currentBuffs[activeRegenAbility] or MSBTProfiles.currentProfile.showAllPowerGains) then DetectPowerGain(powerAmount); end
   lastPowerAmount = powerAmount; 
  end
 end
end


-- ****************************************************************************
-- Enables the module.
-- ****************************************************************************
local function Enable()
 -- Register events to handle all power gains.
 eventFrame:RegisterEvent("UNIT_MANA");
 eventFrame:RegisterEvent("UNIT_RAGE");
 eventFrame:RegisterEvent("UNIT_ENERGY");
end


-- ****************************************************************************
-- Disables the module.
-- ****************************************************************************
local function Disable()
 -- Stop receiving updates.
 eventFrame:Hide();
 eventFrame:UnregisterAllEvents();
end


-- ****************************************************************************
-- Called when the module is loaded.
-- ****************************************************************************
local function OnLoad()
 -- Create a frame to receive events.
 eventFrame = CreateFrame("Frame");
 eventFrame:Hide();
 eventFrame:SetScript("OnEvent", OnEvent);
 eventFrame:SetScript("OnUpdate", OnUpdateEventFrame);
 
 -- Create a frame to receive throttle update events.
 throttleFrame = CreateFrame("Frame");
 throttleFrame:Hide();
 throttleFrame:SetScript("OnUpdate", OnUpdateThrottleFrame);
 
 
 -- Create the miss types lookup map.
 missTypes[MSBTParser.MISSTYPE_MISS] = "_MISS";
 missTypes[MSBTParser.MISSTYPE_DODGE] = "_DODGE";
 missTypes[MSBTParser.MISSTYPE_PARRY] = "_PARRY";
 missTypes[MSBTParser.MISSTYPE_BLOCK] = "_BLOCK";
 missTypes[MSBTParser.MISSTYPE_RESIST] = "_RESIST";
 missTypes[MSBTParser.MISSTYPE_ABSORB] = "_ABSORB";
 missTypes[MSBTParser.MISSTYPE_IMMUNE] = "_IMMUNE";
 missTypes[MSBTParser.MISSTYPE_EVADE] = "_EVADE";
 missTypes[MSBTParser.MISSTYPE_REFLECT] = "_REFLECT";
 missTypes[MSBTParser.MISSTYPE_INTERRUPT] = "_INTERRUPT"; 
 
 -- Create the notification types lookup map.
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_DEBUFF] = "NOTIFICATION_DEBUFF";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_BUFF] = "NOTIFICATION_BUFF";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_ITEM_BUFF] = "NOTIFICATION_ITEM_BUFF";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_DEBUFF_FADE] = "NOTIFICATION_DEBUFF_FADE";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_BUFF_FADE] = "NOTIFICATION_BUFF_FADE";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_ITEM_BUFF_FADE] = "NOTIFICATION_ITEM_BUFF_FADE";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_COMBAT_ENTER] = "NOTIFICATION_COMBAT_ENTER";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_COMBAT_LEAVE] = "NOTIFICATION_COMBAT_LEAVE";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_POWER_GAIN] = "NOTIFICATION_POWER_GAIN";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_POWER_LOSS] = "NOTIFICATION_POWER_LOSS";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_CP_GAIN] = "NOTIFICATION_CP_GAIN";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_HONOR_GAIN] = "NOTIFICATION_HONOR_GAIN";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_REP_GAIN] = "NOTIFICATION_REP_GAIN";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_REP_LOSS] = "NOTIFICATION_REP_LOSS";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_SKILL_GAIN] = "NOTIFICATION_SKILL_GAIN";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_EXPERIENCE_GAIN] = "NOTIFICATION_EXPERIENCE_GAIN";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_PC_KILLING_BLOW] = "NOTIFICATION_PC_KILLING_BLOW";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_NPC_KILLING_BLOW] = "NOTIFICATION_NPC_KILLING_BLOW";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_EXTRA_ATTACK] = "NOTIFICATION_EXTRA_ATTACK";
 notificationTypes[MSBTParser.NOTIFICATIONTYPE_MONEY] = "NOTIFICATION_MONEY";
  
 -- Create the hazard types lookup map.
 hazardTypes[MSBTParser.HAZARDTYPE_DROWNING] = MSBTLocale.MSG_ENVIRONMENTAL_DROWNING;
 hazardTypes[MSBTParser.HAZARDTYPE_FALLING] = MSBTLocale.MSG_ENVIRONMENTAL_FALLING;
 hazardTypes[MSBTParser.HAZARDTYPE_FATIGUE] = MSBTLocale.MSG_ENVIRONMENTAL_FATIGUE;
 hazardTypes[MSBTParser.HAZARDTYPE_FIRE] = MSBTLocale.MSG_ENVIRONMENTAL_FIRE;
 hazardTypes[MSBTParser.HAZARDTYPE_LAVA] = MSBTLocale.MSG_ENVIRONMENTAL_LAVA;
 hazardTypes[MSBTParser.HAZARDTYPE_SLIME] = MSBTLocale.MSG_ENVIRONMENTAL_SLIME;

 -- Create the damage color profile entries lookup map. 
 damageColorProfileEntries[MSBTParser.DAMAGETYPE_PHYSICAL] = "physical";
 damageColorProfileEntries[MSBTParser.DAMAGETYPE_HOLY] = "holy";
 damageColorProfileEntries[MSBTParser.DAMAGETYPE_FIRE] = "fire";
 damageColorProfileEntries[MSBTParser.DAMAGETYPE_NATURE] = "nature";
 damageColorProfileEntries[MSBTParser.DAMAGETYPE_FROST] = "frost";
 damageColorProfileEntries[MSBTParser.DAMAGETYPE_SHADOW] = "shadow";
 damageColorProfileEntries[MSBTParser.DAMAGETYPE_ARCANE] = "arcane";

 -- Create the power types lookup map. 
 powerTypes[0] = MANA;
 powerTypes[1] = RAGE;
 powerTypes[3] = ENERGY;
 
 -- Set the isEnglish flag correctly.
 if (string_find(GetLocale(), "en..")) then isEnglish = true; end

 -- Add the regen abilities. 
 regenAbilities[MSBTLocale.SPELL_EVOCATION] = true;
 regenAbilities[MSBTLocale.SPELL_SPIRIT_TAP] = true;
 regenAbilities[MSBTLocale.SPELL_INNERVATE] = true;
 
 -- Register events for when the mod is loaded and variables are loaded.
 eventFrame:RegisterEvent("ADDON_LOADED");
 eventFrame:RegisterEvent("VARIABLES_LOADED");
end




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Functions.
module.ParserEventsHandler	= ParserEventsHandler;
module.Enable				= Enable;
module.Disable				= Disable;




------------------------------------------------------------------------------------
-- API.
-------------------------------------------------------------------------------

-- Public Constants.
MikSBT.DISPLAYTYPE_INCOMING			= "Incoming";
MikSBT.DISPLAYTYPE_OUTGOING			= "Outgoing";
MikSBT.DISPLAYTYPE_NOTIFICATION		= "Notification";
MikSBT.DISPLAYTYPE_STATIC			= "Static";

-- Public Functions.
MikSBT.RegisterFont					= MSBTAnimations.RegisterFont;
MikSBT.RegisterAnimationStyle		= MSBTAnimations.RegisterAnimationStyle;
MikSBT.RegisterStickyAnimationStyle	= MSBTAnimations.RegisterStickyAnimationStyle;
MikSBT.RegisterSound				= MSBTAnimations.RegisterSound;
MikSBT.IterateFonts					= MSBTAnimations.IterateFonts;
MikSBT.IterateScrollAreas			= MSBTAnimations.IterateScrollAreas;
MikSBT.IterateSounds				= MSBTAnimations.IterateSounds;
MikSBT.DisplayMessage				= MSBTAnimations.DisplayMessage;
MikSBT.IsModDisabled				= MSBTProfiles.IsModDisabled;


-------------------------------------------------------------------------------
-- Load.
-------------------------------------------------------------------------------

OnLoad();