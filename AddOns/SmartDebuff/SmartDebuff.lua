-------------------------------------------------------------------------------
-- SmartDebuff
-- Created by Aeldra (EU-Proudmoore)
--
-- Supports you to cast debuff spells on friendly units
-------------------------------------------------------------------------------

SMARTDEBUFF_VERSION       = "v3.0a";
SMARTDEBUFF_TITLE         = "SmartDebuff";
SMARTDEBUFF_SUBTITLE      = "Debuff support";
SMARTDEBUFF_DESC          = "Supports you to cast debuff spells on friendly units";
SMARTDEBUFF_VERS_TITLE    = SMARTDEBUFF_TITLE .. " " .. SMARTDEBUFF_VERSION;
SMARTDEBUFF_OPTIONS_TITLE = SMARTDEBUFF_VERS_TITLE .. " Options";

BINDING_HEADER_SMARTDEBUFF = "SmartDebuff";
SMARTDEBUFF_BOOK_TYPE_SPELL = "spell";

local maxRaid = 40;
local maxPets = 20;
local maxScrollBtn = 34;

local isLoaded = false;
local isPlayer = false;
local isInit = false;
local isSetUnits = false;
local isSetPets = false;
local isSetPlayerPet = false;
local isSetSpells = false;
local isSoundPlayed = false;
local isSpellActive = true;

local tTicker = 0;
local tDebuff = 0;
local tSound = 0;

local sRealmName = nil;
local sPlayerName = nil;
local sID = nil;
local sPlayerClass = nil;
local sAggroList = nil;
local iGroupSetup = -1;

local cGroups  = { };
local cClasses = { };
local cUnits   = { };
local cPets    = { };

local cSpells = { };
local cSpellList = nil;
local cSpellDefault = nil;
local sRangeCheckSpell = nil;

local cScrollButtons = nil;

local canDebuff = false;
local hasDebuff = false;

local iTotMana = 0;
local iTotHP = 0;
local iTotAFK = 0;
local iTotOFF = 0;
local iTotDead = 0;
local iTotPlayers = 0;
local iTotManaUser = 0;
local iTmp;

local cOrderClass = {"WARRIOR", "PRIEST", "DRUID", "PALADIN", "SHAMAN", "MAGE", "WARLOCK", "HUNTER", "ROGUE", "DEATHKNIGHT"};
local cOrderGrp   = {1, 2 , 3, 4 , 5 , 6, 7, 8};
local cOrderKeys  = {"L", "R", "M", "SL", "SR", "SM", "AL", "AR", "AM", "CL", "CR", "CM"};

local imgSDB        = "Interface\\Icons\\Spell_Holy_LayOnHands";
--local imgIconOn     = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonEnabled";
--local imgIconOff    = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonDisabled";
local imgActionSlot = "Interface/Buttons/UI-Quickslot2";
local imgTarget     = nil;

local DebugChatFrame = DEFAULT_CHAT_FRAME;


-- Rounds a number to the given number of decimal places. 
local r_mult;
local function Round(num, idp)
  r_mult = 10^(idp or 0);
  return math.floor(num * r_mult + 0.5) / r_mult;
end

-- Returns a chat color code string
local function BCC(r, g, b)
  return string.format("|cff%02x%02x%02x", (r*255), (g*255), (b*255));
end

local BL  = BCC(0.1, 0.1, 1.0);
local BLD = BCC(0.0, 0.0, 0.7);
local BLL = BCC(0.5, 0.8, 1.0);
local GR  = BCC(0.1, 1.0, 0.1);
local GRD = BCC(0.0, 0.7, 0.0);
local GRL = BCC(0.25, 0.75, 0.25);
local RD  = BCC(1.0, 0.1, 0.1);
local RDD = BCC(0.7, 0.0, 0.0);
local RDL = BCC(1.0, 0.3, 0.3);
local YL  = BCC(1.0, 1.0, 0.0);
local YLD = BCC(0.7, 0.7, 0.0);
local YLL = BCC(1.0, 1.0, 0.5);
local OR  = BCC(1.0, 0.5, 0.25);
local ORD = BCC(0.7, 0.5, 0.0);
local ORL = BCC(1.0, 0.6, 0.3);
local WH  = BCC(1.0, 1.0, 1.0);
local CY  = BCC(0.5, 1.0, 1.0);
local GY  = BCC(0.5, 0.5, 0.5);
local GYD = BCC(0.35, 0.35, 0.35);
local GYL = BCC(0.65, 0.65, 0.65);

-- Returns "" instead of nil
local function ChkS(text)
  if (text == nil) then
    text = "";
  end
  return text;
end

-- Set texture on the key binding options frame
local function SetATexture(btn, texture)
  if (not texture) then
    btn:SetNormalTexture(imgActionSlot);
  else
    btn:SetNormalTexture(texture);
  end  
  if (not texture or texture == imgActionSlot) then
    btn:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8);
  else
    btn:GetNormalTexture():SetTexCoord(0, 1, 0, 1);
  end
end

-- Get normal/target mode by button index
local function GetActionMode(i)
  local m = 1;
  if (i <= 12) then
    m = 1;
  else
    m = 2;
    i = i - 12;
  end
  return m, i;
end

-- Get action info on an specific button
local function GetActionInfo(mode, i)
  local aType, aName, aRank, aId, aLink = nil, nil, nil, nil, nil;
  if (SMARTDEBUFF_Options.Keys[mode] and cOrderKeys[i] and SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]]) then
    aType = SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][1];
    if (aType) then
      aName = SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][2];
      if (aName) then
        aRank = SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][3];
        aId   = SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][4];
        aLink = SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][5];
        if (aType == "spell") then
          aId = SMARTDEBUFF_GetSpellID(aName, aRank);
          SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][4] = aId;
          --SMARTDEBUFF_AddMsgD("Id = "..ChkS(aId)..", Name = "..aName);
          if (not aLink) then
            SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][5] = BOOKTYPE_SPELL;
          end
        elseif (aType == "item") then
          if (not aLink) then
            _, aLink = GetItemInfo(aName);
          end
        elseif (aType == "macro") then
          aId = GetMacroIndexByName(aName);
          if (aId > 0) then
            SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][4] = aId;
          else
            aType, aName, aRank, aId, aLink = nil, nil, nil, nil, nil;
            SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]] = { };
          end
        elseif (aType == "action") then
          -- Do nothing
        end
      else
        aType = nil;
        SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]] = { };
      end
    end
  end
  return aType, aName, aRank, aId, aLink;
end

-- Set actin in info on a specific button
local function SetActionInfo(mode, i, aType, aName, aRank, aId, aLink)
  if (aType) then
    if (SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]]) then
      SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]] = { };
    end
    SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][1] = aType;
    SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][2] = aName;
    SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][3] = aRank;
    SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][4] = aId;
    SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][5] = aLink;
    --SMARTDEBUFF_AddMsgD("Set Id = "..ChkS(aId)..", Name = "..aName);
  else
    SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]] = { };
  end
end

-- Set actin Id on a specific button
local function SetActionInfoId(mode, i, aId)
  if (SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]]) then
    SMARTDEBUFF_Options.Keys[mode][cOrderKeys[i]][4] = aId;
  end
end


-- SMARTDEBUFF_OnLoad
function SMARTDEBUFF_OnLoad(self)
  self:RegisterEvent("ADDON_LOADED");
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("UNIT_NAME_UPDATE");

  self:RegisterEvent("PARTY_MEMBERS_CHANGED");
  self:RegisterEvent("RAID_ROSTER_UPDATE");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
  self:RegisterEvent("PLAYER_REGEN_DISABLED");

  self:RegisterEvent("LEARNED_SPELL_IN_TAB");
  self:RegisterEvent("UNIT_PET");

  --One of them allows SmartDebuff to be closed with the Escape key
  tinsert(UISpecialFrames, "SmartDebuffOF");
  UIPanelWindows["SmartDebuffOF"] = nil;

  SlashCmdList["SMARTDEBUFF"] = SMARTDEBUFF_command;
  SLASH_SMARTDEBUFF1 = "/sdb";
  SLASH_SMARTDEBUFF2 = "/smartdebuff";

  SlashCmdList["SMARTDEBUFFOPTIONS"] = SMARTDEBUFF_ToggleOF;
  SLASH_SMARTDEBUFFOPTIONS1 = "/sdbo";
  SLASH_SMARTDEBUFFOPTIONS2 = "/sdbm";

  SlashCmdList["SMARTDEBUFFRELOAD"] = function(msg) ReloadUI(); end;
  SLASH_SMARTDEBUFFRELOAD1 = "/rui";

  --DEFAULT_CHAT_FRAME:AddMessage("SDB OnLoad");
end
-- END SMARTDEBUFF_OnLoad


-- SMARTDEBUFF_OnEvent
function SMARTDEBUFF_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5)
  --DebugChatFrame:AddMessage(event);
  if ((event == "UNIT_NAME_UPDATE" and arg1 == "player") or event == "PLAYER_ENTERING_WORLD") then
    isPlayer = true;
  elseif(event == "ADDON_LOADED" and arg1 == SMARTDEBUFF_TITLE) then
    isLoaded = true;
  end
    
  if (isLoaded and isPlayer and not isInit) then
    SMARTDEBUFF_Options_Init();
  end
  
  if (not isInit or SMARTDEBUFF_Options == nil) then
    return;
  end;
  
  if (event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE") then
    isSetUnits = true;
  
  elseif (event == "UNIT_PET") then
    isSetPlayerPet = true;
    
  elseif (event == "UNIT_NAME_UPDATE" and string.find(arg1, "pet")) then
    isSetPets = true;    
    
  elseif (event == "PLAYER_REGEN_DISABLED") then
    SMARTDEBUFF_SetAutoHide(true);
    SMARTDEBUFF_CheckSFButtons(true);
    SMARTDEBUFF_Ticker(true);
    SMARTDEBUFF_CheckIF();
    
  elseif (event == "PLAYER_REGEN_ENABLED") then
    SMARTDEBUFF_SetAutoHide(false);    
    SMARTDEBUFF_CheckSFButtons();
    SMARTDEBUFF_Ticker(true);
    SMARTDEBUFF_CheckIF();

  elseif (event == "LEARNED_SPELL_IN_TAB") then   
    isSetSpells = true;
  end

end
-- END SMARTDEBUFF_OnEvent


function SMARTDEBUFF_OnUpdate(self, elapsed)
  if (isInit) then
    SMARTDEBUFF_Ticker();
    SMARTDEBUFF_CheckDebuffs();
  end
end

function SMARTDEBUFF_Ticker(force)
  if (force or GetTime() > tTicker + 1) then
    tTicker = GetTime();
    
    if ((isSetPlayerPet or isSetPets) and not isSetUnits) then
      if (canDebuff and SMARTDEBUFF_IsVisible()) then
        if (InCombatLockdown()) then
          isSetUnits = true;
        else
          SMARTDEBUFF_AddMsgD("Unit pet changed");
          if (isSetPlayerPet) then
            SMARTDEBUFF_CheckWarlockPet();
            isSetUnits = true;
          else
            SMARTDEBUFF_SetPetButtons(true);
          end          
        end
      end
      isSetPlayerPet = false;
      isSetPets = false;      
    end
    
    if (isSetUnits and not InCombatLockdown()) then
      isSetUnits = false;
      SMARTDEBUFF_SetUnits();
    end
    
    if (isSetSpells) then
      isSetSpells = false;
      SMARTDEBUFF_SetSpells();
      SMARTDEBUFF_CheckForSpellUpgrade();
    end    
    
  end 
end

function SMARTDEBUFF_IsVisible()
  if (SmartDebuffSF:IsVisible() or SMARTDEBUFF_Options.AutoHide) then
    return true;
  end
  return false;
end



-- Will dump the value of msg to the default chat window
function SMARTDEBUFF_AddMsg(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or SMARTDEBUFF_Options.ShowMsgNormal)) then
    DEFAULT_CHAT_FRAME:AddMessage(YLL .. msg .. "|r");
  end
end

function SMARTDEBUFF_AddMsgErr(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or SMARTDEBUFF_Options.ShowMsgError)) then
    DEFAULT_CHAT_FRAME:AddMessage(RDL .. SMARTDEBUFF_TITLE .. ": " .. msg .. "|r");
  end
end

function SMARTDEBUFF_AddMsgWarn(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or SMARTDEBUFF_Options.ShowMsgWarning)) then
    DEFAULT_CHAT_FRAME:AddMessage(CY .. msg .. "|r");
  end
end

function SMARTDEBUFF_AddMsgD(msg, r, g, b)
  if (r == nil) then r = 0.5; end
  if (g == nil) then g = 0.8; end
  if (b == nil) then b = 1; end
  if (DEFAULT_CHAT_FRAME and SMARTDEBUFF_Options and SMARTDEBUFF_Options.Debug) then
    DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
  end
end

function SMARTDEBUFF_CheckWarlockPet()
  if (sPlayerClass == "WARLOCK") then
    isSpellActive = false;
    SetActionInfoId(1, 1, nil);
    SetActionInfoId(2, 7, nil);
    if (UnitExists("pet")) then
      local ucf = UnitCreatureFamily("pet");
      if (ucf == SMARTDEBUFF_FELHUNTER) then        
        local i = 1;
        local name, subtext, texture;        
        for i = 1, 10, 1 do
          name, subtext, texture = GetPetActionInfo(i);
          if (name and name == GetSpellInfo(SMARTDEBUFF_PET_FELHUNTER_ID)) then
            subtext = "";
            SmartDebuffTooltip:ClearLines();
            SmartDebuffTooltip:SetPetAction(i);
            for j = 4, SmartDebuffTooltip:NumLines(), 1 do
              subtext = subtext..SMARTDEBUFF_GetTooltipLine(j).."\n";
            end            
            SetActionInfo(1, 1, "action", name, subtext, i, texture);
            SetActionInfo(2, 7, "action", name, subtext, i, texture);
            isSpellActive = true;            
            SMARTDEBUFF_AddMsgD("Warlock pet spell found: " .. GetSpellInfo(SMARTDEBUFF_PET_FELHUNTER_ID));
            break;
          end
        end
        SMARTDEBUFF_AddMsgD("Warlock pet found: " .. SMARTDEBUFF_FELHUNTER);
      end
    end
  else
    isSpellActive = true;
  end
end


-- Creates an array of units
function SMARTDEBUFF_SetUnits()
  if (not isInit or InCombatLockdown()) then
    isSetUnits = true;
    return;
  end    
  
  local i = 0;
  local n = 0;
  local j = 0;
  local s = nil;
  local psg = 0;
  local b = false;

  -- player
  -- pet
  -- party1-4
  -- partypet1-4
  -- raid1-40
  -- raidpet1-40
 
  iGroupSetup = -1;
  if (GetNumRaidMembers() ~= 0) then
    iGroupSetup = 3;
  elseif (GetNumPartyMembers() ~= 0) then
    iGroupSetup = 2;
  else
    iGroupSetup = 1;
  end
  
  cGroups  = { };
  cClasses = { };
  cPets    = { };
  cUnits   = { };
  
  -- Raid Setup  
  if (iGroupSetup == 3) then
    local name, rank, subgroup, level, class, classeng, zone, online, isDead;
    
    for n = 1, maxRaid, 1 do
      name, rank, subgroup, level, class, classeng, zone, online, isDead = GetRaidRosterInfo(n);
      if (name) then
        
        SMARTDEBUFF_AddUnit("raid", n, subgroup, classeng);
                        
        --SmartBuff_AddToUnitList(1, sRUnit, subgroup);
        --SmartBuff_AddToUnitList(2, sRUnit, subgroup);
      end

    end --end for
    SMARTDEBUFF_AddMsgD("Raid Unit-Setup finished");
  
  -- Party Setup
  elseif (iGroupSetup == 2) then        
    SMARTDEBUFF_AddUnit("player", 0, 1, sPlayerClass);
    for j = 1, 4, 1 do
      SMARTDEBUFF_AddUnit("party", j, 1);      
      --SmartBuff_AddToUnitList(1, "party"..j, 1);
      --SmartBuff_AddToUnitList(2, "party"..j, 1);      
    end
    SMARTDEBUFF_AddMsgD("Party Unit-Setup finished");
  
  -- Solo Setup
  else    
    SMARTDEBUFF_AddUnit("player", 0, 1, sPlayerClass);
    SMARTDEBUFF_AddMsgD("Solo Unit-Setup finished");
  end
  
  --SMARTDEBUFF_CheckWarlockPet();
  SMARTDEBUFF_SetButtons();
  SMARTDEBUFF_CheckIF();
end

function SMARTDEBUFF_AddUnit(unit, i, sg, uc)
  local u = unit;
  local up = "pet";
  if (unit ~= "player") then
    u = unit..i;
    up = unit.."pet"..i;
  end
  
  if (UnitExists(u)) then
    if (not cUnits[u]) then
      cUnits[u] = { };
    end
    cUnits[u].Subgroup = sg;
  
    if (not cGroups[sg]) then
      cGroups[sg] = { };
    end
    if (not cGroups[sg][i]) then
      cGroups[sg][i] = { };
    end
    cGroups[sg][i].Unit = u;
    cGroups[sg][i].Subgroup = sg;
    SMARTDEBUFF_AddMsgD("Unit to subgroup added: " .. UnitName(u) .. ", " .. u .. ", " .. sg);
    
    if (not uc) then
      _, uc = UnitClass(u);
    end

    if (uc) then
      if (not cClasses[uc]) then
        cClasses[uc] = { };
      end
      if (not cClasses[uc][i]) then
        cClasses[uc][i] = { };
      end
      cClasses[uc][i].Unit = u;
      cClasses[uc][i].Subgroup = sg;
      SMARTDEBUFF_AddMsgD("Unit to class added: " .. UnitName(u) .. ", " .. u .. ", " .. sg);
      
      if (uc == "HUNTER" or uc == "WARLOCK") then
        if (not cPets[i]) then
          cPets[i] = { };
        end    
        cPets[i].Unit = up;
        cPets[i].Subgroup = sg;
        cPets[i].Owner = u;
        cPets[i].OwnerClass = uc;
        if (UnitName(up)) then
          SMARTDEBUFF_AddMsgD("Pet added: " .. UnitName(up) .. ", " .. up .. ", " .. sg);
        end
      end
    end
    
  end
end

-- END SMARTDEBUFF_SetUnits


-- Helper functions ---------------------------------------------------------------------------------------
function SMARTDEBUFF_toggleBool(b, msg)
  if (not b or b == nil) then
    b = true;
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. GR .. "On");
  else
    b = false
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. RD .."Off");
  end
  return b;
end

function SMARTDEBUFF_BoolState(b, msg)
  if (b) then
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. GR .. "On");
  else
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_TITLE .. ": " .. msg .. RD .."Off");
  end
end

function SMARTDEBUFF_Split(msg, char)
  local arr = { };
  while (string.find(msg, char)) do
    local iStart, iEnd = string.find(msg, char);
    tinsert(arr, strsub(msg, 1, iStart - 1));
    msg = strsub(msg, iEnd + 1, strlen(msg));
  end
  if (strlen(msg) > 0) then
    tinsert(arr, msg);
  end
  return arr;
end

function SmartDebuffOFSlider_OnLoad(self, low, high, step)
  if (self:GetOrientation() ~= "VERTICAL") then
    getglobal(self:GetName().."Low"):SetText(low);
  else
    getglobal(self:GetName().."Low"):SetText("");
  end
  getglobal(self:GetName().."High"):SetText(high);
  self:SetMinMaxValues(low, high);
  self:SetValueStep(step);
end
-- END Bool helper functions
  

-- IsFeignDeath(unit)
local ifd_name, ifd_icon, ifd_i;
function SMARTDEBUFF_IsFeignDeath(unit)
  --return UnitIsFeignDeath(unit); -- works only for members in own group
  ifd_i = 0;
  while (true) do
    ifd_i = ifd_i + 1;
    ifd_name, _, ifd_icon = UnitBuff(unit, ifd_i);
    SMARTDEBUFF_AddMsgD("Check FeignDeath");
    if (ifd_icon) then
      if (string.find(string.lower(ifd_icon), "feigndeath")) then
        return true;
      end
    else
      break;
    end
  end
  return false;
end
-- END SMARTDEBUFF_IsFeignDeath


-- Get Spell ID from spellbook
function SMARTDEBUFF_GetSpellID(spellname, rank)
  if (not spellname) then 
    return nil;
  end
  
  local i = 0;
  local id = nil;
  local spellN;
  local spellR;
  while true do
    i = i + 1;
     spellN, spellR = GetSpellName(i, SMARTDEBUFF_BOOK_TYPE_SPELL);
     if (not spellN or spellN == spellname) then
       break;
     end     
  end
  while (spellN ~= nil) do
    id = i;
    i = i + 1;
     spellN, spellR = GetSpellName(i, SMARTDEBUFF_BOOK_TYPE_SPELL);
    if (not spellN or spellN ~= spellname or (spellR and rank and spellR == rank)) then 
      break;
    end
  end  
  return id;
end
-- END SMARTDEBUFF_GetSpellID


function SMARTDEBUFF_SetSpells()
  canDebuff = true;
  sName = nil;
  sRangeCheckSpell = nil;
  cSpellList = { };
  cSpellDefault = { };
  cSpellDefault[1] = { };
  cSpellDefault[2] = { };
  cSpellDefault[3] = { };
  cSpellDefault[10] = { };
  
  -- check debuff spells
  -- name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellId or spellName or spellLink)
  if (sPlayerClass == "DRUID") then
    -- Cure Poison / Abolish Poison
    sName = GetSpellInfo(SMARTDEBUFF_CUREPOISON_ID_DRUID);    
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_POISON};
      cSpellDefault[1] = {1, 7, sName};
    end
    sName = GetSpellInfo(SMARTDEBUFF_ABOLISHPOISON_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_POISON};
      table.insert(cSpellDefault[1], 3, sName);
    end
    -- Remove Curse
    sName = GetSpellInfo(SMARTDEBUFF_REMOVECURSE_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_CURSE};
      cSpellDefault[2] = {2, 8, sName};
    end
    -- Rejuvenation    
    sName = GetSpellInfo(SMARTDEBUFF_REJUVENATION_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Heal spell found: " .. sName);
      cSpellDefault[10] = {7, 2, sName};
    end
    
  elseif (sPlayerClass == "PRIEST") then    
    -- Cure Disease / Abolish Disease
    sName = GetSpellInfo(SMARTDEBUFF_CUREDISEASE_ID_PRIEST);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_DISEASE};
      cSpellDefault[1] = {1, 7, sName};
    end
    sName = GetSpellInfo(SMARTDEBUFF_ABOLISHDISEASE_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_DISEASE};
      table.insert(cSpellDefault[1], 3, sName);
    end
    -- Dispel Magic
    sName = GetSpellInfo(SMARTDEBUFF_DISPELMAGIC_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_MAGIC};
      cSpellDefault[2] = {2, 8, sName};
    end    
    -- Renew
    sName = GetSpellInfo(SMARTDEBUFF_RENEW_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Heal spell found: " .. sName);
      cSpellDefault[10] = {7, 2, sName};
    end    
    
  elseif (sPlayerClass == "MAGE") then
    -- Remove Lesser Curse
    sName = GetSpellInfo(SMARTDEBUFF_REMOVELESSERCURSE_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_CURSE};
      cSpellDefault[1] = {1, 7, sName};
    end
    -- Polymorph
    sName = GetSpellInfo(SMARTDEBUFF_POLYMORPH_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_CHARMED};
      cSpellDefault[2] = {2, 8, sName};
    end
    
  elseif (sPlayerClass == "PALADIN") then
    -- Purify (Disease, Poison)
    sName = GetSpellInfo(SMARTDEBUFF_PURIFY_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON};
      cSpellDefault[1] = {1, 7, sName};
    end    
    --Cleanse (Disease, Poison, Magic)
    sName = GetSpellInfo(SMARTDEBUFF_CLEANSE_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON, SMARTDEBUFF_MAGIC};
      table.insert(cSpellDefault[1], 3, sName);
    end
    -- Flash of light
    sName = GetSpellInfo(SMARTDEBUFF_FLASHOFLIGHT_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Heal spell found: " .. sName);
      cSpellDefault[10] = {7, 2, sName};
    end
    
  elseif (sPlayerClass == "SHAMAN") then
    -- Cure Poison
    sName = GetSpellInfo(SMARTDEBUFF_CUREPOISON_ID_SHAMAN);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_POISON};
      cSpellDefault[1] = {1, 7, sName};
    end
    --Cleanse Spirit (Poison, Disease, Curse)
    sName = GetSpellInfo(SMARTDEBUFF_CLEANSESPIRIT_ID);      
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_DISEASE, SMARTDEBUFF_POISON, SMARTDEBUFF_CURSE};
      table.insert(cSpellDefault[1], 3, sName);
    end
    -- Cure Disease
    sName = GetSpellInfo(SMARTDEBUFF_CUREDISEASE_ID_SHAMAN);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_DISEASE};
      cSpellDefault[2] = {2, 8, sName};
    end
    -- Hex
    sName = GetSpellInfo(SMARTDEBUFF_HEX_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Spell found: " .. sName);
      cSpellList[sName] = {SMARTDEBUFF_CHARMED};
      if (cSpellDefault[1][4]) then
        table.insert(cSpellDefault[2], 3, sName);
      else
        cSpellDefault[3] = {3, 9, sName};
      end
    end    
    -- Lesser Healing Wave
    sName = GetSpellInfo(SMARTDEBUFF_LESSERHEALINGWAVE_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Heal spell found: " .. sName);
      cSpellDefault[10] = {7, 2, sName};
    end
  
  elseif (sPlayerClass == "WARLOCK") then
    -- Dispel Magic
    sName = GetSpellInfo(SMARTDEBUFF_PET_FELHUNTER_ID);
    SMARTDEBUFF_AddMsgD("Debuff spell found: " .. sName);
    cSpellList[sName] = {SMARTDEBUFF_MAGIC};
    cSpellDefault[1] = {1, 7, SMARTDEBUFF_PET_FELHUNTER_ID};
    
    -- Used for range check
    sRangeCheckSpell = GetSpellInfo(SMARTDEBUFF_UNENDINGBREATH_ID);
    
  elseif (sPlayerClass == "HUNTER") then
    -- Misdirection
    sName = GetSpellInfo(SMARTDEBUFF_MISDIRECTION_ID);
    if (sName and SMARTDEBUFF_GetSpellID(sName)) then
      SMARTDEBUFF_AddMsgD("Misc spell found: " .. sName);
      cSpellDefault[10] = {7, 2, sName};
    end 
       
  end
  
end


-- Init the SmartDebuff variables ---------------------------------------------------------------------------------------
function SMARTDEBUFF_Options_Init()
  if (isInit or InCombatLockdown()) then return; end 

  _, sPlayerClass = UnitClass("player");
  sRealmName = GetCVar("RealmName");
  sPlayerName = UnitName("player");
  sID = sRealmName .. ":" .. sPlayerName;
  
  SMARTDEBUFF_SetSpells();
  
  if (not SMARTDEBUFF_Options) then SMARTDEBUFF_Options = { }; end
  if (SMARTDEBUFF_Options.SFPosX == nil) then  SMARTDEBUFF_Options.SFPosX = 400; end
  if (SMARTDEBUFF_Options.SFPosY == nil) then  SMARTDEBUFF_Options.SFPosY = -300; end
  
  if (SMARTDEBUFF_Options.OrderClass == nil) then  SMARTDEBUFF_Options.OrderClass = cOrderClass; end
  if (SMARTDEBUFF_Options.OrderGrp == nil) then  SMARTDEBUFF_Options.OrderGrp = cOrderGrp; end
  
  if (SMARTDEBUFF_Options.Toggle == nil) then  SMARTDEBUFF_Options.Toggle = true; end
  if (SMARTDEBUFF_Options.ShowSF == nil) then SMARTDEBUFF_Options.ShowSF = true; end
  if (SMARTDEBUFF_Options.ShowIF == nil) then SMARTDEBUFF_Options.ShowIF = true; end
  if (SMARTDEBUFF_Options.ShowPets == nil) then SMARTDEBUFF_Options.ShowPets = true; end
  if (SMARTDEBUFF_Options.ShowPetsWL == nil) then SMARTDEBUFF_Options.ShowPetsWL = true; end
  
  if (SMARTDEBUFF_Options.ShowClassColors == nil) then SMARTDEBUFF_Options.ShowClassColors = true; end
  if (SMARTDEBUFF_Options.SortedByClass == nil) then SMARTDEBUFF_Options.SortedByClass = true; end
  if (SMARTDEBUFF_Options.ShowLR == nil) then SMARTDEBUFF_Options.ShowLR = true; end
  
  if (SMARTDEBUFF_Options.DebuffGrp == nil) then SMARTDEBUFF_Options.DebuffGrp = {true, true, true, true, true, true, true, true}; end
  if (SMARTDEBUFF_Options.DebuffClasses == nil) then SMARTDEBUFF_Options.DebuffClasses = {["WARRIOR"] = true, ["PRIEST"] = true, ["DRUID"] = true, ["PALADIN"] = true, ["SHAMAN"] = true, ["MAGE"] = true, ["WARLOCK"] = true, ["HUNTER"] = true, ["ROGUE"] = true}; end
  if (SMARTDEBUFF_Options.ANormal == nil) then SMARTDEBUFF_Options.ANormal = 0.8; end
  if (SMARTDEBUFF_Options.ANormalOOR == nil) then SMARTDEBUFF_Options.ANormalOOR = 0.4; end
  if (SMARTDEBUFF_Options.ADebuff == nil) then SMARTDEBUFF_Options.ADebuff = 1.0; end
  
  if (SMARTDEBUFF_Options.ColNormal == nil) then SMARTDEBUFF_Options.ColNormal = { r = 0.39, g = 0.42, b = 0.64 }; end
  if (SMARTDEBUFF_Options.ColDebuffL == nil) then SMARTDEBUFF_Options.ColDebuffL = { r = 0.0, g = 0.0, b = 1.0 }; end
  if (SMARTDEBUFF_Options.ColDebuffR == nil) then SMARTDEBUFF_Options.ColDebuffR = { r = 1.0, g = 0.0, b = 0.0 }; end
  if (SMARTDEBUFF_Options.ColDebuffM == nil) then SMARTDEBUFF_Options.ColDebuffM = { r = 0.0, g = 0.7, b = 0.0 }; end
  if (SMARTDEBUFF_Options.ColDebuffNR == nil) then SMARTDEBUFF_Options.ColDebuffNR = { r = 0.86, g = 0.3, b = 1.0 }; end
  
  if (SMARTDEBUFF_Options.ShowHP == nil) then SMARTDEBUFF_Options.ShowHP = true; end
  if (SMARTDEBUFF_Options.ShowMana == nil) then SMARTDEBUFF_Options.ShowMana = true; end
  if (SMARTDEBUFF_Options.Invert == nil) then SMARTDEBUFF_Options.Invert = true; end  
  if (SMARTDEBUFF_Options.ShowHeaders == nil) then SMARTDEBUFF_Options.ShowHeaders = true; end
  if (SMARTDEBUFF_Options.ShowGrpNr == nil) then SMARTDEBUFF_Options.ShowGrpNr = false; end
  if (SMARTDEBUFF_Options.ShowHeaderRow == nil) then SMARTDEBUFF_Options.ShowHeaderRow = true; end
  if (SMARTDEBUFF_Options.Vertical == nil) then SMARTDEBUFF_Options.Vertical = true; end
  if (SMARTDEBUFF_Options.VerticalUp == nil) then SMARTDEBUFF_Options.VerticalUp = false; end
  if (SMARTDEBUFF_Options.Columns == nil) then SMARTDEBUFF_Options.Columns = 4; end
  if (SMARTDEBUFF_Options.BarH == nil) then SMARTDEBUFF_Options.BarH = 4; end
    
  if (SMARTDEBUFF_Options.BtnW == nil) then SMARTDEBUFF_Options.BtnW = 28; end
  if (SMARTDEBUFF_Options.BtnH == nil) then SMARTDEBUFF_Options.BtnH = 20; end
  if (SMARTDEBUFF_Options.Fontsize == nil) then SMARTDEBUFF_Options.Fontsize = 9; end
  
  if (SMARTDEBUFF_Options.ShowTooltip == nil) then SMARTDEBUFF_Options.ShowTooltip = true; end
  if (SMARTDEBUFF_Options.UseSound == nil) then SMARTDEBUFF_Options.UseSound = false; end
  if (SMARTDEBUFF_Options.TargetMode == nil) then SMARTDEBUFF_Options.TargetMode = false; end
  if (SMARTDEBUFF_Options.ShowHealRange == nil) then SMARTDEBUFF_Options.ShowHealRange = true; end
  if (SMARTDEBUFF_Options.ShowAggro == nil) then SMARTDEBUFF_Options.ShowAggro = true; end
  if (SMARTDEBUFF_Options.ShowNotRemov == nil) then SMARTDEBUFF_Options.ShowNotRemov = false; end
  if (SMARTDEBUFF_Options.CheckInterval == nil) then SMARTDEBUFF_Options.CheckInterval = 0.1; end
  if (SMARTDEBUFF_Options.ShowBackdrop == nil) then SMARTDEBUFF_Options.ShowBackdrop = true; end
  if (SMARTDEBUFF_Options.ShowGradient == nil) then SMARTDEBUFF_Options.ShowGradient = true; end  
  if (SMARTDEBUFF_Options.AutoHide == nil) then SMARTDEBUFF_Options.AutoHide = false; end
  --SMARTDEBUFF_Options.AutoHide = false;
      
  if (not SMARTDEBUFF_Options.AddList) then SMARTDEBUFF_Options.AddList = { }; end
  if (not SMARTDEBUFF_Options.IgnoreList) then SMARTDEBUFF_Options.IgnoreList = { }; end
  
  if (SMARTDEBUFF_Options.ShowMsgNormal == nil) then SMARTDEBUFF_Options.ShowMsgNormal = true; end
  if (SMARTDEBUFF_Options.ShowMsgError == nil) then SMARTDEBUFF_Options.ShowMsgError = true; end
  if (SMARTDEBUFF_Options.ShowMsgWarning == nil) then SMARTDEBUFF_Options.ShowMsgWarning = true; end
    
  if (SMARTDEBUFF_Options.FirstStart == nil) then SMARTDEBUFF_Options.FirstStart = "V0";  end
  if (SMARTDEBUFF_Options.Debug == nil) then SMARTDEBUFF_Options.Debug = false;  end
  
  if (SMARTDEBUFF_Options.Keys == nil or SMARTDEBUFF_Options.Keys[1]["M"] == "-") then    
    SMARTDEBUFF_SetDefaultKeys(true);
  end
  
  if (SMARTDEBUFF_Options.NotRemovableDebuffs == nil) then    
    SMARTDEBUFF_SetDefaultNotRemovableDebuffs();
  end  
    
  -- Cosmos support
  if(EarthFeature_AddButton) then 
    EarthFeature_AddButton(
      { id = SMARTDEBUFF_TITLE;
        name = SMARTDEBUFF_TITLE;
        subtext = SMARTDEBUFF_SUBTITLE; 
        tooltip = "";      
        icon = imgSDB;
        callback = SMARTDEBUFF_ToggleSF;
        test = nil;
      } );
  elseif (Cosmos_RegisterButton) then 
    Cosmos_RegisterButton(SMARTDEBUFF_TITLE, SMARTDEBUFF_TITLE, SMARTDEBUFF_SUBTITLE, imgSDB, SMARTDEBUFF_ToggleSF);
  end

  -- CTMod support
  if(CT_RegisterMod) then
    CT_RegisterMod(
      SMARTDEBUFF_TITLE,
      SMARTDEBUFF_SUBTITLE,
      5,
      imgSDB,
      SMARTDEBUFF_DESC,
      "switch",
      "",
      SMARTDEBUFF_ToggleSF);
  end
    
  if (canDebuff) then
    SMARTDEBUFF_CreateButtons();
  end
  
  sname = nil;
  SMARTDEBUFF_DEBUFFSKIP_NAME = { };
  -- Get localized spellnames from id list
  for key, val in ipairs(SMARTDEBUFF_DEBUFFSKIP_ID) do
    if (val and type(val) == "number") then
      sname = GetSpellInfo(val);
      if (sname) then
        SMARTDEBUFF_DEBUFFSKIP_NAME[key] = sname;
        --SMARTDEBUFF_AddMsgD("Debuff localized: "..key..". ".. sname);
      end
    end
  end  
  
  -- Populate global ignore list
  SMARTDEBUFF_DEBUFFSKIPLIST = { };
  for _, val in ipairs(SMARTDEBUFF_DEBUFFSKIPLIST_ID) do
    if (val and type(val) == "number" and SMARTDEBUFF_DEBUFFSKIP_NAME[val]) then
      sname = SMARTDEBUFF_DEBUFFSKIP_NAME[val];
      SMARTDEBUFF_DEBUFFSKIPLIST[sname] = true;
      --SMARTDEBUFF_AddMsgD("Global skip debuff added: "..sname);
    end
  end
  
  -- Populate class ignore list
  SMARTDEBUFF_DEBUFFCLASSSKIPLIST = { };
  for _, class in ipairs(cOrderClass) do
    if (class and not SMARTDEBUFF_DEBUFFCLASSSKIPLIST[class]) then
      SMARTDEBUFF_DEBUFFCLASSSKIPLIST[class] = { };
      --SMARTDEBUFF_AddMsgD("Skip debuff class added: "..class);
      for _, val in ipairs(SMARTDEBUFF_DEBUFFCLASSSKIPLIST_ID[class]) do
        if (val and type(val) == "number" and SMARTDEBUFF_DEBUFFSKIP_NAME[val]) then
          sname = SMARTDEBUFF_DEBUFFSKIP_NAME[val];
          SMARTDEBUFF_DEBUFFCLASSSKIPLIST[class][sname] = true;
          --SMARTDEBUFF_AddMsgD("Skip debuff added: "..sname);
        end
      end
    end
  end
  
  _, _, imgTarget = GetSpellInfo(1130);  -- Hunter's Mark
  --_, _, imgTarget = GetSpellInfo(34500); -- Expose Weakness
  --_, _, imgTarget = GetSpellInfo(34485); -- Master Marksman
  
  SMARTDEBUFF_AddMsg(SMARTDEBUFF_VERS_TITLE .. " " .. SMARTDEBUFF_MSG_LOADED, true);
  SMARTDEBUFF_AddMsg("/sdb - " .. SMARTDEBUFF_MSG_SDB, true);
  isInit = true;  
  
  if (SMARTDEBUFF_Options.FirstStart ~= SMARTDEBUFF_VERSION) then
    -- Upgrade to 2.4a
    if (SMARTDEBUFF_VERSION == "v2.4a") then
      SMARTDEBUFF_Options.CheckInterval = 0.1;
    end 
    
    SMARTDEBUFF_Options.FirstStart = SMARTDEBUFF_VERSION;
    SMARTDEBUFF_ToggleOF();
    SMARTDEBUFF_ToggleAOFKeys();
    
    SmartDebuffWNF_lblText:SetText(SMARTDEBUFF_WHATSNEW);
    SmartDebuffWNF:Show();
  end
  
  SMARTDEBUFF_CheckWarlockPet();
  SMARTDEBUFF_CheckSF();
  SMARTDEBUFF_CheckForSpellUpgrade();
  SMARTDEBUFF_CheckAutoHide();
end
-- END SMARTDEBUFF_Options_Init


function SMARTDEBUFF_SetDefaultColors()
  SMARTDEBUFF_Options.ColNormal  = { r = 0.39, g = 0.42, b = 0.64 };
  SMARTDEBUFF_Options.ColDebuffL = { r = 0.0, g = 0.0, b = 1.0 };
  SMARTDEBUFF_Options.ColDebuffR = { r = 1.0, g = 0.0, b = 0.0 };
  SMARTDEBUFF_Options.ColDebuffM = { r = 0.0, g = 0.7, b = 0.0 };
  SMARTDEBUFF_Options.ColDebuffNR = { r = 0.86, g = 0.3, b = 1.0 };
end

function SMARTDEBUFF_SetDefaultNotRemovableDebuffs()
  SMARTDEBUFF_Options.NotRemovableDebuffs = { };
  local name;
  for _, v in ipairs(SMARTDEBUFF_NOTREMOVABLE_ID) do
    if (v) then
      name = GetSpellInfo(v);
      if (name) then
        table.insert(SMARTDEBUFF_Options.NotRemovableDebuffs, name);
      end
    end
  end
end

function SMARTDEBUFF_SetDefaultKeys(bReload)
  local isAction = false;
  local aType = "spell";  
  
  if (cSpellDefault[1] and type(cSpellDefault[1][3]) == "number") then
    aType = "action";
    isAction = true;
  end
  
  SMARTDEBUFF_Options.Keys = { };
  -- normal mode
  SMARTDEBUFF_Options.Keys[1]    = {["L"]  = {aType, cSpellDefault[1][3]},
                                    ["R"]  = {"spell", cSpellDefault[2][3]},
                                    ["M"]  = {"spell", cSpellDefault[3][3]},
                                    ["SL"] = {"target", "target"},
                                    ["SR"] = { },
                                    ["SM"] = { },
                                    ["AL"] = {"spell", cSpellDefault[10][3]},
                                    ["AR"] = { },
                                    ["AM"] = { },
                                    ["CL"] = { },
                                    ["CR"] = { },
                                    ["CM"] = { }
                                    };
  -- target mode
  SMARTDEBUFF_Options.Keys[2]    = {["L"]  = {"target", "target"},
                                    ["R"]  = {"spell", cSpellDefault[10][3]},
                                    ["M"]  = { },
                                    ["SL"] = { },
                                    ["SR"] = { },
                                    ["SM"] = { },
                                    ["AL"] = {aType, cSpellDefault[1][3]},
                                    ["AR"] = {"spell", cSpellDefault[2][3]},
                                    ["AM"] = {"spell", cSpellDefault[3][3]},
                                    ["CL"] = { },
                                    ["CR"] = { },
                                    ["CM"] = { }
                                    };
  
  local i, j;
  if (bReload) then
    for i = 1, 24, 1 do
      mode, j = GetActionMode(i);
      GetActionInfo(mode, j);
    end
  end
  
  if (isAction) then
    local name, _, texture = GetSpellInfo(cSpellDefault[1][3]);
    SetActionInfo(1, 1, "action", name, nil, nil, texture);
    SetActionInfo(2, 7, "action", name, nil, nil, texture);
    SMARTDEBUFF_CheckWarlockPet();
  end
  
  SMARTDEBUFF_SetButtons();
end

-- Check if a newer spell was learned
function SMARTDEBUFF_CheckForSpellUpgrade()
  local iC = -1;
  local b = false;
  
  --SMARTDEBUFF_Options.CurrentSpells = nil;
  if (not SMARTDEBUFF_Options.CurrentSpells) then
    SMARTDEBUFF_Options.CurrentSpells = { };
    for i, s in pairs(cSpellDefault) do
      if (s) then
        SMARTDEBUFF_Options.CurrentSpells[i] = s[3];
      end
    end
  end

  --SMARTDEBUFF_Options.CurrentSpells[1] = "Vergiftung heilen";
  --SMARTDEBUFF_Options.CurrentSpells[2] = nil;
  
  for i, s in pairs(cSpellDefault) do
    if (s and s[3]) then
      SMARTDEBUFF_AddMsgD(i.." "..s[3]);
      iC = 0;
      for j, t in ipairs(s) do
        if (t == SMARTDEBUFF_Options.CurrentSpells[i]) then
          iC = j;
          break;
        end
        iC = j + 1;
      end
            
      if (iC > 3) then
        -- Spell upgrade found
        SMARTDEBUFF_AddMsgD("Spell upgrade found: "..ChkS(SMARTDEBUFF_Options.CurrentSpells[i]).."->"..s[3]);
        SMARTDEBUFF_UpgradeSpell(1, s[1], SMARTDEBUFF_Options.CurrentSpells[i], s[3]);
        SMARTDEBUFF_UpgradeSpell(2, s[2], SMARTDEBUFF_Options.CurrentSpells[i], s[3]);
        SMARTDEBUFF_Options.CurrentSpells[i] = s[3];
        b = true;
      end
    end
  end  
  if (b) then
    SMARTDEBUFF_SetButtons();
  end
end

-- Upgrades a debuff spell to the next better one and replaces it in the key options
function SMARTDEBUFF_UpgradeSpell(mode, idx, oldSpell, newSpell)
  local v;
  local b;
  b = false;
  for _, k in ipairs(cOrderKeys) do
    v = SMARTDEBUFF_Options.Keys[mode][k];
    if (v and v[1] and v[1] == "spell" and v[2]) then
      if (oldSpell and v[2] == oldSpell) then
        SMARTDEBUFF_Options.Keys[mode][k][2] = newSpell;
        b = true;
        --break;
      elseif (newSpell and v[2] == newSpell) then
        b = true;
        --break;
      end
    end
  end
  if (not b) then
    for i, k in ipairs(cOrderKeys) do
      v = SMARTDEBUFF_Options.Keys[mode][k];
      if (v and not v[1] and i >= idx) then
        SMARTDEBUFF_Options.Keys[mode][k] = {"spell", newSpell};
        break;
      end
    end
  end
end

-- Links the debuff spells to the assign keys, to make sure the display highlights up correctly 
function SMARTDEBUFF_LinkSpellsToKeys()
  cSpells = { };
  local idx = 0;
  local v;
  local mode = 1;
  if (SMARTDEBUFF_Options.TargetMode) then
    mode = 2;
  end
  for _, k in ipairs(cOrderKeys) do    
    v = SMARTDEBUFF_Options.Keys[mode][k];
    if (v and v[1] and (v[1] == "spell" or (v[1] == "action" and v[4])) and v[2]) then
      idx = 0;
      if     (k == "L" or k == "SL" or k == "AL" or k == "CL") then
        idx = 1;
      elseif (k == "R" or k == "SR" or k == "AR" or k == "CR") then
        idx = 2;
      elseif (k == "M" or k == "SM" or k == "AL" or k == "CM") then
        idx = 3;
      end
      if (cSpellList[v[2]]) then
        for i, s in ipairs(cSpellList[v[2]]) do
          if (s and not cSpells[s]) then
            cSpells[s] = {v[2], idx};
            SMARTDEBUFF_AddMsgD("Debuff spell linked: "..v[2].." ("..s..") -> "..idx);
          end
        end
      end
    end
  end
end


-- SmartDebuff commandline menu ---------------------------------------------------------------------------------------
function SMARTDEBUFF_command(msg)
  if (not isInit) then
    SMARTDEBUFF_AddMsgWarn(SMARTDEBUFF_VERS_TITLE.." not initialized correctly!", true);
    return;
  end
  
  if(msg == "help" or msg == "?") then
    SMARTDEBUFF_AddMsg(SMARTDEBUFF_VERS_TITLE, true);
    SMARTDEBUFF_AddMsg("Syntax: /sdb [command] or /smartdebuff [command]", true);
    SMARTDEBUFF_AddMsg("o      -  " .. SMARTDEBUFF_MSG_SDB, true);
    SMARTDEBUFF_AddMsg("rafp -  " .. "Reset all frame positions", true);
  elseif (msg == "options" or msg == "o") then
    SMARTDEBUFF_ToggleOF();
  elseif (msg == "rafp") then
    SmartDebuffSF:ClearAllPoints();
    SMARTDEBUFF_Options.SFPosX = 400;
    SMARTDEBUFF_Options.SFPosY = -300;
    SmartDebuffSF:SetPoint("TOPLEFT", UIParent, "TOPLEFT", SMARTDEBUFF_Options.SFPosX, SMARTDEBUFF_Options.SFPosY);
    SmartDebuffIF:ClearAllPoints();
    SmartDebuffIF:SetPoint("CENTER", UIParent, "CENTER");
    SmartDebuffOF:ClearAllPoints();
    SmartDebuffOF:SetPoint("CENTER", UIParent, "CENTER");
  elseif (msg == "debug") then
    SMARTDEBUFF_Options.Debug = SMARTDEBUFF_toggleBool(SMARTDEBUFF_Options.Debug, "Debug active = ");  
  else
    SMARTDEBUFF_ToggleSF();
  end
end
-- END SMARTDEBUFF_command


-- SmartDebuff frame functions ---------------------------------------------------------------------------------------

function SMARTDEBUFF_ToggleSF()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
  
  SMARTDEBUFF_Options.ShowSF = not SMARTDEBUFF_Options.ShowSF;
  SMARTDEBUFF_CheckSF();
  
  if (IsAddOnLoaded("SmartBuff") and SMARTDEBUFF_IsVisible()) then
    if (SmartBuffOptionsFrame_cbSmartDebuff) then
      SmartBuffOptionsFrame_cbSmartDebuff:SetChecked(SMARTDEBUFF_Options.ShowSF);
    end
  end
end

function SMARTDEBUFF_CheckSF()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
  
  if (not SMARTDEBUFF_Options.ShowSF) then
    SmartDebuffSF:Hide();
  else
    SmartDebuffSF:Show();
    SMARTDEBUFF_CheckSFBackdrop();
    SMARTDEBUFF_CheckSFButtons();
    SMARTDEBUFF_SetUnits();
  end
  SMARTDEBUFF_CheckIF();
  
  -- Update the FuBar icon
  if (IsAddOnLoaded("FuBar") and IsAddOnLoaded("FuBar_SmartDebuffFu")) then
    SMARTDEBUFF_Fu_UpdateIcon();
  end
end

function SMARTDEBUFF_CheckSFButtons(hide)
  if (SMARTDEBUFF_IsVisible()) then
    if (canDebuff and SMARTDEBUFF_Options.ShowHeaderRow and not InCombatLockdown() and not hide) then
      SmartDebuffSF_Title:SetText("martDebuff");
      SmartDebuffSF_btnClose:Show();
      SmartDebuffSF_btnStyle:Show();
      SmartDebuffSF_btnOptions:Show();
    else
      if (SMARTDEBUFF_Options.ShowHeaderRow) then
        SmartDebuffSF_Title:SetText("SmartDebuff");
      else
        SmartDebuffSF_Title:SetText("");
      end
      SmartDebuffSF_btnClose:Hide();
      SmartDebuffSF_btnStyle:Hide();
      SmartDebuffSF_btnOptions:Hide();
      if (hide) then
        SmartDebuffOF:Hide();
      end
    end
    
    if (SMARTDEBUFF_Options.VerticalUp) then
      SmartDebuffSF_btnStyle:ClearAllPoints();
      SmartDebuffSF_btnStyle:SetPoint("BOTTOMLEFT", SmartDebuffSF, "BOTTOMLEFT", 4, 3);
      SmartDebuffSF_btnClose:ClearAllPoints();
      SmartDebuffSF_btnClose:SetPoint("BOTTOMRIGHT", SmartDebuffSF, "BOTTOMRIGHT", 2, -1);
    else
      SmartDebuffSF_btnStyle:ClearAllPoints();
      SmartDebuffSF_btnStyle:SetPoint("TOPLEFT", SmartDebuffSF, "TOPLEFT", 4, -3);
      SmartDebuffSF_btnClose:ClearAllPoints();
      SmartDebuffSF_btnClose:SetPoint("TOPRIGHT", SmartDebuffSF, "TOPRIGHT", 2, 1);              
    end
    
  end
end

function SMARTDEBUFF_ToggleIF()
  if (not isInit) then return; end
  SMARTDEBUFF_Options.ShowIF = not SMARTDEBUFF_Options.ShowIF;
  SMARTDEBUFF_CheckIF();  
end

function SMARTDEBUFF_CheckIF()
  if (not isInit) then return; end
  if (not SMARTDEBUFF_Options.ShowIF or not SMARTDEBUFF_IsVisible() or iGroupSetup <= 1) then
    if (SmartDebuffIF:IsVisible()) then
      SmartDebuffIF:Hide();
    end
  else
    if (not SmartDebuffIF:IsVisible()) then
      SmartDebuffIF:Show();
    end
  end
end

function SMARTDEBUFF_ToggleSFBackdrop()
  if (SmartDebuffSF) then
    SMARTDEBUFF_Options.ShowBackdrop = not SMARTDEBUFF_Options.ShowBackdrop;
    if (SmartDebuffOF:IsVisible()) then
      SmartDebuffOF_cbShowBackdrop:SetChecked(SMARTDEBUFF_Options.ShowBackdrop);
    end    
    SMARTDEBUFF_CheckSFBackdrop();
  end
end

function SMARTDEBUFF_CheckSFBackdrop()
  if (SmartDebuffSF) then
    if (SMARTDEBUFF_Options.ShowBackdrop) then
      SmartDebuffSF:SetBackdrop( { 
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = nil, tile = false, tileSize = 0, edgeSize = 2, 
        insets = { left = 0, right = 0, top = 0, bottom = 0 } });
    else
      SmartDebuffSF:SetBackdrop(nil);
    end
  end
end



function SMARTDEBUFF_CreateButtons()
  local frame = getglobal("SmartDebuffSF");
  
  if (frame) then
    local i = 1;
    
    for i = 1, 10, 1 do
      local lbl = CreateFrame("EditBox", "SmartDebuffTxt"..i, frame);
      lbl:SetMultiLine(true);
      lbl:SetMaxLetters(16);
      lbl:SetFontObject("SmartDebuff_GameFontNormalMicro");
      lbl:SetJustifyH("CENTER");
      lbl:SetJustifyV("BOTTOM");
      --lbl:SetNonSpaceWrap(1);
      lbl:EnableMouse(false);
      lbl:EnableKeyboard(false); 
      lbl:SetAutoFocus(false);
    end
    
    for i = 1, maxRaid, 1 do
          
      local button = CreateFrame("Button", "SmartDebuffBtn"..i, frame, "SecureActionButtonTemplate");
      button:SetWidth(1);
      button:SetHeight(1);
      button:ClearAllPoints();
      
      button:SetBackdrop( { 
        bgFile = nil, edgeFile = "Interface\\AddOns\\SmartDebuff\\Icons\\white16x16", tile = false, tileSize = 0, edgeSize = 2, 
        insets = { left = 0, right = 0, top = 0, bottom = 0 } });
      
      
      -- create bg texture
      button.texture = button:CreateTexture(nil, "BORDER");
      button.texture:SetTexture(0, 0, 0);
      button.texture:SetAllPoints(button);
      button.texture:SetBlendMode("BLEND");
      
      button.text = button:CreateFontString(nil, nil, "SmartDebuff_Font");
      button.text:SetJustifyH("CENTER");
      button.text:SetAllPoints(button);
      button:SetFontString(button.text);
      
      -- create hp texture
      button.hp = button:CreateTexture(nil, "STATUSBAR");
      button.hp:SetTexture(0, 1, 0);
      button.hp:SetBlendMode("DISABLE");
      button.hp:ClearAllPoints();
      
      -- create mana texture
      button.mana = button:CreateTexture(nil, "STATUSBAR");
      button.mana:SetTexture(0, 0, 1);
      button.mana:SetBlendMode("DISABLE");
      button.mana:ClearAllPoints();    
      
      -- create aggro texture
      button.aggro = button:CreateTexture(nil, "STATUSBAR");
      button.aggro:SetTexture(1, 1, 0);
      button.aggro:SetBlendMode("DISABLE");
      button.aggro:ClearAllPoints();      
      
      button:EnableMouse(true);
      --button:EnableMouseWheel(true);
      button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
      button:SetScript("OnEnter", SMARTDEBUFF_ButtonTooltipOnEnter);
      button:SetScript("OnLeave", SMARTDEBUFF_ButtonTooltipOnLeave);
      
      button:SetAttribute("unit", nil);
      button:SetAttribute("type1", "spell");
      button:SetAttribute("type2", "spell");
      button:SetAttribute("type3", "target");
      button:SetAttribute("spell1", nil);
      button:SetAttribute("spell2", nil);
    end
    
    for i = 1, maxPets, 1 do      
      local button = CreateFrame("Button", "SmartDebuffPetBtn"..i, frame, "SecureActionButtonTemplate");
      button:SetWidth(1);
      button:SetHeight(1);
      button:ClearAllPoints();
      
      button:SetBackdrop( { 
        bgFile = nil, edgeFile = "Interface\\AddOns\\SmartDebuff\\Icons\\white16x16", tile = false, tileSize = 0, edgeSize = 2, 
        insets = { left = 0, right = 0, top = 0, bottom = 0 } });      
      
      -- create bg texture
      button.texture = button:CreateTexture(nil, "BORDER");
      button.texture:SetTexture(0, 0, 0);
      button.texture:SetAllPoints(button);
      button.texture:SetBlendMode("BLEND");
      
      button.text = button:CreateFontString(nil, nil, "SmartDebuff_Font");
      button.text:SetJustifyH("CENTER");
      button.text:SetAllPoints(button);
      button:SetFontString(button.text);      
      
      -- create hp texture
      button.hp = button:CreateTexture(nil, "STATUSBAR");
      button.hp:SetTexture(0, 1, 0);
      button.hp:SetBlendMode("DISABLE");
      button.hp:ClearAllPoints();
      
      -- create mana texture
      button.mana = button:CreateTexture(nil, "STATUSBAR");
      button.mana:SetTexture(0, 0, 1);
      button.mana:SetBlendMode("DISABLE");
      button.mana:ClearAllPoints();
      
      -- create aggro texture
      button.aggro = button:CreateTexture(nil, "STATUSBAR");
      button.aggro:SetTexture(1, 1, 0);
      button.aggro:SetBlendMode("DISABLE");
      button.aggro:ClearAllPoints();      
      
      button:EnableMouse(true);
      button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
      button:SetScript("OnEnter", SMARTDEBUFF_ButtonTooltipOnEnter);
      button:SetScript("OnLeave", SMARTDEBUFF_ButtonTooltipOnLeave);      
      
      button:SetAttribute("unit", nil);
      button:SetAttribute("type1", "spell");
      button:SetAttribute("type2", "spell");
      button:SetAttribute("type3", "target");
      button:SetAttribute("spell1", nil);
      button:SetAttribute("spell2", nil);      
    end   
  end
  
  local offX = 4;
  local offY = 24;
  local lblW = 96;
  frame = getglobal("SmartDebuffAOFKeys");  
  if (frame) then
    local lbl = CreateFrame("EditBox", "SmartDebuff_lblColumnTitle", frame);
    lbl:SetWidth(lblW);
    lbl:SetHeight(16);        
    lbl:SetMultiLine(false);
    lbl:SetMaxLetters(30);
    lbl:SetFontObject("GameFontHighlightSmall");
    lbl:SetJustifyH("LEFT");
    lbl:SetJustifyV("MIDDLE");
    lbl:EnableMouse(false);
    lbl:EnableKeyboard(false); 
    lbl:SetAutoFocus(false);
    lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", offX, -2);
    lbl:SetText(SMARTDEBUFF_FT_MODES);  

    for i = 1, 24, 1 do
      if (i == 1 or i == 13) then
        lbl = CreateFrame("EditBox", "SmartDebuff_lblColumn"..i, frame);
        lbl:SetWidth(32);
        lbl:SetHeight(16);        
        lbl:SetMultiLine(true);
        lbl:SetMaxLetters(30);
        lbl:SetFontObject("GameFontHighlightSmall");
        lbl:SetJustifyH("CENTER");
        lbl:SetJustifyV("MIDDLE");
        lbl:EnableMouse(false);
        lbl:EnableKeyboard(false); 
        lbl:SetAutoFocus(false);
        lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", offX + lblW, -4);
        if (i == 1) then
          lbl:SetText(SMARTDEBUFF_FT_MODENORMAL);
        else
          lbl:SetText(SMARTDEBUFF_FT_MODETARGET);
        end
      end    
    
      if (i <= 12) then
        lbl = CreateFrame("EditBox", "SmartDebuff_lblAction"..i, frame);
        lbl:SetWidth(lblW);
        lbl:SetHeight(32);        
        lbl:SetMultiLine(false);
        lbl:SetMaxLetters(30);
        lbl:SetFontObject("GameFontNormalSmall");
        lbl:SetJustifyH("LEFT");
        lbl:SetJustifyV("MIDDLE");
        lbl:EnableMouse(false);
        lbl:EnableKeyboard(false); 
        lbl:SetAutoFocus(false);
        lbl:SetPoint("TOPLEFT", frame, "TOPLEFT", offX, -offY);
        if (cOrderKeys[i]) then
          lbl:SetText(SMARTDEBUFF_KEYS[cOrderKeys[i]]);
        end
      end
      
      --SMARTDEBUFF_AddMsgD("Texture = "..ChkS(imgActionSlot));
      local button = CreateFrame("Button", "SmartDebuff_btnAction"..i, frame);
      button:SetWidth(32);
      button:SetHeight(32);
      SetATexture(button, imgActionSlot);
      button:ClearAllPoints();
      button:SetPoint("TOPLEFT", frame, "TOPLEFT", offX + lblW, -offY);
      button:SetID(i);            
      button:SetScript("OnMouseDown", SMARTDEBUFF_OnActionDown);
      --button:SetScript("OnMouseUp", SMARTDEBUFF_OnActionUp);
      button:SetScript("OnReceiveDrag", SMARTDEBUFF_OnReceiveDrag);
      button:SetScript("OnEnter", SMARTDEBUFF_BtnActionOnEnter);
      button:SetScript("OnLeave", SMARTDEBUFF_BtnActionOnLeave);
      
      offY = offY + 36;
      if (i == 12) then
        offX = offX + 36;
        offY = 24;
      end      
    end
  end
      
end

function SMARTDEBUFF_SetButtons()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
  
  local i, j;
  -- reset all buttons
  for i = 1, maxRaid, 1 do
    SMARTDEBUFF_SetButton(nil, i);
  end
  
  i = 1;
  local cl, data, unit, uc;
  if (SMARTDEBUFF_Options.SortedByClass) then
    for j, cl in ipairs(SMARTDEBUFF_Options.OrderClass) do
      if (cl and cClasses[cl] and SMARTDEBUFF_Options.DebuffClasses[cl]) then
        for _, data in pairs(cClasses[cl]) do
          if (data and UnitExists(data.Unit) and SMARTDEBUFF_Options.DebuffGrp[data.Subgroup]) then
            SMARTDEBUFF_SetButton(data.Unit, i);
            i = i + 1;
          end
        end
      end
    end
  else
    --for cl = 1, 8, 1 do
    for j, cl in ipairs(SMARTDEBUFF_Options.OrderGrp) do
      if (cl and cGroups[cl] and SMARTDEBUFF_Options.DebuffGrp[cl]) then
        for _, data in pairs(cGroups[cl]) do
          if (data and UnitExists(data.Unit)) then
            _, uc = UnitClass(data.Unit);
            if (uc and SMARTDEBUFF_Options.DebuffClasses[uc]) then
              SMARTDEBUFF_SetButton(data.Unit, i);
              i = i + 1;
            end
          end
        end
      end
      if (math.fmod(i - 1, 5) ~= 0) then
        i = i + (5 - math.fmod(i - 1, 5));
      end
    end      
  end
  --SMARTDEBUFF_AddMsgD("Debuff buttons set");
  
  SMARTDEBUFF_SetPetButtons(false);
  SMARTDEBUFF_SetStyle();
end

function SMARTDEBUFF_SetPetButtons(b)
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
    
  local i;
  -- reset all buttons
  for i = 1, maxPets, 1 do
    SMARTDEBUFF_SetButton(nil, i, 1);
  end
  
  local data;
  if (SMARTDEBUFF_Options.ShowPets or SMARTDEBUFF_Options.ShowPetsWL) then
    i = 1;
    for _, data in pairs(cPets) do
      if (data and UnitExists(data.Unit) and i <= maxPets) then
        --SMARTDEBUFF_AddMsgD("Set Pet: " .. unit .. ", " .. UnitName(unit) .. ", " .. uc);
        if (data.OwnerClass and ((data.OwnerClass == "HUNTER" and SMARTDEBUFF_Options.ShowPets) or (data.OwnerClass == "WARLOCK" and SMARTDEBUFF_Options.ShowPetsWL)) and (iGroupSetup ~= 3 or (iGroupSetup == 3 and SMARTDEBUFF_Options.DebuffGrp[data.Subgroup]))) then
          --SMARTDEBUFF_AddMsgD("Set Pet: " .. unit .. ", " .. UnitName(unit));
          SMARTDEBUFF_SetButton(data.Unit, i, 1);
          i = i + 1;
        end
      end
    end
  end
  --SMARTDEBUFF_AddMsgD("Debuff pet buttons set");
  
  SMARTDEBUFF_LinkSpellsToKeys();
  if (b) then
    SMARTDEBUFF_SetStyle();
  end
end


function SMARTDEBUFF_SetButton(unit, idx, pet)
  if (not canDebuff or InCombatLockdown()) then return; end
  
  local btn;
  if (pet) then
    btn = getglobal("SmartDebuffPetBtn"..idx);
  else
    btn = getglobal("SmartDebuffBtn"..idx);
  end
  
  if (not btn) then return; end
  btn:SetAttribute("unit", unit);
  
  
  local pre = "";
  local suf = "";
  local mode = 1;
  if (SMARTDEBUFF_Options.TargetMode) then
    mode = 2;
  end
  --"L", "R", "M", "SL", "SR", "SM", "AL", "AR", "AM", "CL", "CR", "CM"
  for k, v in pairs(SMARTDEBUFF_Options.Keys[mode]) do
    if (k == "L") then
      pre = "";       suf = "1";
    elseif (k == "R") then
      pre = "";       suf = "2";
    elseif (k == "M") then
      pre = "";       suf = "3";
    elseif (k == "SL") then
      pre = "shift-"; suf = "1";
    elseif (k == "SR") then
      pre = "shift-"; suf = "2";
    elseif (k == "SM") then
      pre = "shift-"; suf = "3";
    elseif (k == "AL") then
      pre = "alt-";   suf = "1";
    elseif (k == "AR") then
      pre = "alt-";   suf = "2";
    elseif (k == "AM") then
      pre = "alt-";   suf = "3";
    elseif (k == "CL") then
      pre = "ctrl-";  suf = "1";
    elseif (k == "CR") then
      pre = "ctrl-";  suf = "2";
    elseif (k == "CM") then
      pre = "ctrl-";  suf = "3";
    end
    if (v and v[1]) then
      if (unit) then
        btn:SetAttribute(pre.."type"..suf, v[1]);
        --SMARTDEBUFF_AddMsgD(idx.." set: "..pre.."type"..suf..":"..v[1]);
        if ((v[1] == "spell" or v[1] == "item" or v[1] == "macro") and v[2]) then
          btn:SetAttribute(pre..v[1]..suf, v[2]);
          SMARTDEBUFF_AddMsgD(idx.." set: "..pre..v[1]..suf..":"..v[2]);
        elseif ((v[1] == "action") and v[4]) then
          btn:SetAttribute(pre.."type"..suf, "pet");
          btn:SetAttribute(pre..v[1]..suf, v[4]);
          --SMARTDEBUFF_AddMsgD(idx.." set: "..pre..v[1]..suf..":"..v[2]);
        elseif ((v[1] == "target") and v[2]) then
          -- Do nothing
        else
          btn:SetAttribute(pre.."type"..suf, nil);
          btn:SetAttribute(pre..v[1]..suf, nil);
        end
      else
        btn:SetAttribute(pre.."type"..suf, nil);
        btn:SetAttribute(pre..v[1]..suf, nil);
      end
    else
      btn:SetAttribute(pre.."type"..suf, nil);
    end    
  end  
  
  --[[
    if (sPlayerClass == "WARLOCK") then
      btn:SetAttribute("alt-type1", "pet");
      btn:SetAttribute("alt-action1", spell1);
    end
  ]]--
  
  --btn:SetAttribute("ctrl-type1", "menu");
  --btn.showmenu = UnitPopup_ShowMenu; --UnitPopup_OnClick;  
  
  if (unit) then
    btn:SetAlpha(0.5);
    btn:Show();
  else
    btn:SetAlpha(0.1);
    btn:Hide();
  end
end

local sbs_btn, sbs_un, sbs_uc, sbs_st, sbs_fontH, sbs_pre, sbs_ln, sbs_wd, sbs_io;
local sbs_col = { r = 0.39, g = 0.42, b = 0.64 };
function SMARTDEBUFF_SetButtonState(unit, idx, nr, ir, ti, pet)
  sbs_btn = nil;
  sbs_un = "";
  sbs_uc = "";
  sbs_st = "";

  if (pet) then
    sbs_btn = getglobal("SmartDebuffPetBtn"..idx);
  else
    sbs_btn = getglobal("SmartDebuffBtn"..idx);
  end
  
  if (not sbs_btn) then return; end
  
  sbs_col.r = 0.39; sbs_col.g = 0.42; sbs_col.b = 0.64;
  if (unit and UnitExists(unit) and not pet) then
    sbs_un = UnitName(unit);
    _, sbs_uc = UnitClass(unit);
    if (SMARTDEBUFF_Options.ShowClassColors and sbs_uc and RAID_CLASS_COLORS[sbs_uc]) then
      sbs_col.r = RAID_CLASS_COLORS[sbs_uc].r;
      sbs_col.g = RAID_CLASS_COLORS[sbs_uc].g;
      sbs_col.b = RAID_CLASS_COLORS[sbs_uc].b;
    end
  elseif (unit and UnitExists(unit)) then
    sbs_un = UnitName(unit);
    if (pet and SMARTDEBUFF_Options.ShowClassColors) then
      sbs_col.r = 0.39; sbs_col.g = 0.42; sbs_col.b = 0.64;
    end
  end
    
  if (not sbs_col.r or not sbs_col.g or not sbs_col.b) then
    sbs_col.r = SMARTDEBUFF_Options.ColNormal.r;
    sbs_col.g = SMARTDEBUFF_Options.ColNormal.g;
    sbs_col.b = SMARTDEBUFF_Options.ColNormal.b;
  end
  
  if (cSpellDefault[10] and cSpellDefault[10][3] and SMARTDEBUFF_Options.ShowHealRange and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit)) then
    if (IsSpellInRange(cSpellDefault[10][3], unit) == 1) then
      sbs_btn:SetBackdropBorderColor(0, 0, 0, 0);
    else
      if (nr > 0) then
        sbs_btn:SetBackdropBorderColor(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      else
        sbs_btn:SetBackdropBorderColor(1, 0, 0, 1);
      end
    end
  else
    sbs_btn:SetBackdropBorderColor(0, 0, 0, 0);
  end  
  
  --SMARTDEBUFF_AddMsgD(un);
  -- GameFontHighlightSmall
  -- GameFontHighlightLarge
  -- SmartDebuff_GameFontHighlightMini  
  
  sbs_fontH = SMARTDEBUFF_Options.Fontsize;
  
  if (unit and UnitExists(unit)) then 
    sbs_pre = nil;
    sbs_ln = 5.5;
    sbs_wd = 0;
    
    if (iGroupSetup == 3 and SMARTDEBUFF_Options.ShowGrpNr and not pet) then
      sbs_un = cUnits[unit].Subgroup .. ":" .. sbs_un;
    end
    
    if (UnitIsAFK(unit)) then
      sbs_pre = "AFK";
      sbs_col.r = 0.2; sbs_col.g = 0.1; sbs_col.b = 0;
      iTotAFK = iTotAFK + 1;
    end
    
    sbs_io = false;
    if (UnitIsConnected(unit) == nil or not UnitIsConnected(unit) or SMARTDEBUFF_IsOffline(unit)) then
      sbs_io = true;
    end
    
    if (UnitIsDeadOrGhost(unit) or sbs_io) then
      if (sbs_io) then
        ir = 1;
        if (not pet) then
          sbs_pre = "OFF";
          iTotOFF = iTotOFF + 1;
        else
          sbs_pre = "REL";
        end
        sbs_col.r = 0; sbs_col.g = 0; sbs_col.b = 0;
      else
        if (sbs_uc and sbs_uc == "HUNTER" and SMARTDEBUFF_IsFeignDeath(unit)) then
          sbs_pre = "-FD-";
          sbs_col.r = 0.15; sbs_col.g = 0.05; sbs_col.b = 0;
        else
          ir = 1;
          sbs_pre = "DEAD";
          sbs_col.r = 0; sbs_col.g = 0; sbs_col.b = 0;
          iTotDead = iTotDead + 1;
        end
      end
    end
    if (sbs_pre) then
      sbs_ln = 5;
      sbs_wd = math.floor(sbs_btn:GetWidth() / sbs_ln - 1);
      if (string.len(sbs_pre) > sbs_wd) then
        sbs_pre = string.sub(sbs_pre, 1, sbs_wd);
      end
    end
    
    sbs_wd = math.floor(sbs_btn:GetWidth() / sbs_ln - 1);
    if (string.len(sbs_un) > sbs_wd) then
      sbs_un = string.sub(sbs_un, 1, sbs_wd);
    end
    
    if (sbs_pre) then
      sbs_un = sbs_pre .. "\n" .. sbs_un;
      sbs_fontH = sbs_fontH - 1;
    end
    sbs_st = sbs_un;
  else
    sbs_st = "?";
  end

  if (ti and ti >= 0.0) then
    if (ti > 60) then
      --sbs_st = string.format("%.0fm", Round(ti/60, 0));
      sbs_st = string.format("%.0fm", math.floor((ti/60) + 0.5));
      --sbs_fontH = SMARTDEBUFF_Options.BtnH - 8;
    else
      --sbs_st = string.format("%.0f", Round(ti, 0));
      sbs_st = string.format("%.0f", math.floor(ti + 0.5));
      --sbs_fontH = SMARTDEBUFF_Options.BtnH - 6;
    end
    sbs_st = sbs_un.."\n"..sbs_st;
  end
  
  --[[
  if (nr == 0) then
    sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 0.6);
    if (not sbs_pre and SMARTDEBUFF_Options.ShowGradient) then
      sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r / 4, sbs_col.g / 4, sbs_col.b / 4, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0);
    else
      sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r, sbs_col.g, sbs_col.b, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0)
    end
    if (ir == 1) then
      sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormal);
    else
      sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormalOOR);
    end
  ]]--
  
  if (nr == 1) then
    sbs_col.r = SMARTDEBUFF_Options.ColDebuffL.r;
    sbs_col.g = SMARTDEBUFF_Options.ColDebuffL.g;
    sbs_col.b = SMARTDEBUFF_Options.ColDebuffL.b;
    if (ir == 1) then
      sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      if (SMARTDEBUFF_Options.ShowLR) then
        sbs_st = "L";
      end
    else
      sbs_btn.texture:SetTexture(sbs_col.r / 2, sbs_col.g / 2, sbs_col.b / 2, 1);
      if (SMARTDEBUFF_Options.ShowLR) then
        sbs_st = "-";
      end
    end
    sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r, sbs_col.g, sbs_col.b, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0)
    sbs_btn:SetAlpha(SMARTDEBUFF_Options.ADebuff);
    if (SMARTDEBUFF_Options.ShowLR) then
      sbs_fontH = SMARTDEBUFF_Options.BtnH - 2;
    end
  elseif (nr == 2) then
    sbs_col.r = SMARTDEBUFF_Options.ColDebuffR.r;
    sbs_col.g = SMARTDEBUFF_Options.ColDebuffR.g;
    sbs_col.b = SMARTDEBUFF_Options.ColDebuffR.b;
    if (ir == 1) then
      sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      if (SMARTDEBUFF_Options.ShowLR) then
        sbs_st = "R";
      end
    else
      sbs_btn.texture:SetTexture(sbs_col.r / 2, sbs_col.g / 2, sbs_col.b / 2, 1);
      if (SMARTDEBUFF_Options.ShowLR) then
        sbs_st = "-";
      end
    end
    sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r, sbs_col.g, sbs_col.b, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0)
    sbs_btn:SetAlpha(SMARTDEBUFF_Options.ADebuff);
    if (SMARTDEBUFF_Options.ShowLR) then
      sbs_fontH = SMARTDEBUFF_Options.BtnH - 2;
    end
  elseif (nr == 3) then
    sbs_col.r = SMARTDEBUFF_Options.ColDebuffM.r;
    sbs_col.g = SMARTDEBUFF_Options.ColDebuffM.g;
    sbs_col.b = SMARTDEBUFF_Options.ColDebuffM.b;
    if (ir == 1) then
      sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
      if (SMARTDEBUFF_Options.ShowLR) then
        sbs_st = "M";
      end
    else
      sbs_btn.texture:SetTexture(sbs_col.r / 2, sbs_col.g / 2, sbs_col.b / 2, 1);
      if (SMARTDEBUFF_Options.ShowLR) then
        sbs_st = "-";
      end
    end
    sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r, sbs_col.g, sbs_col.b, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0)
    sbs_btn:SetAlpha(SMARTDEBUFF_Options.ADebuff);
    if (SMARTDEBUFF_Options.ShowLR) then
      sbs_fontH = SMARTDEBUFF_Options.BtnH - 2;
    end
  elseif (nr == 10 and not UnitIsDeadOrGhost(unit)) then
    sbs_col.r = SMARTDEBUFF_Options.ColDebuffNR.r;
    sbs_col.g = SMARTDEBUFF_Options.ColDebuffNR.g;
    sbs_col.b = SMARTDEBUFF_Options.ColDebuffNR.b;
    sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 1);
    sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r, sbs_col.g, sbs_col.b, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0)
    sbs_btn:SetAlpha(SMARTDEBUFF_Options.ADebuff);
  else
    sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 0.6);
    if (not sbs_pre and SMARTDEBUFF_Options.ShowGradient) then
      sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r / 4, sbs_col.g / 4, sbs_col.b / 4, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0)
    else
      sbs_btn.texture:SetGradientAlpha("HORIZONTAL", sbs_col.r, sbs_col.g, sbs_col.b, 1.0, sbs_col.r, sbs_col.g, sbs_col.b, 1.0)
    end
    --sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormalOOR);
    if (ir == 1) then
      sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormal);
    else
      sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormalOOR);
    end    
  end

  sbs_btn.text:SetFont("Fonts\\FRIZQT__.TTF", sbs_fontH);
  sbs_btn.text:SetText(sbs_st);
  sbs_btn.texture:SetAllPoints(sbs_btn);
  
  SmartDebuff_SetButtonBars(sbs_btn, unit, sbs_uc);
end

local sbb_w, sbb_h, sbb_upt, sbb_cur, sbb_nmax, sbb_n;
local sbb_col = { r = 0, g = 1, b = 0 };
function SmartDebuff_SetButtonBars(btn, unit, unitclass)
  if (unit) then -- and btn:IsVisible()
    if (SMARTDEBUFF_Options.BarH > (btn:GetHeight() / 2)) then sbb_h = btn:GetHeight() / 2; else sbb_h = SMARTDEBUFF_Options.BarH; end
    --sbb_h = btn:GetHeight() / 4 - 1;
    sbb_w = btn:GetWidth();
    sbb_upt = UnitPowerType(unit);
    sbb_cur = UnitHealth(unit);
    sbb_nmax = UnitHealthMax(unit);
    sbb_n = math.floor(sbb_w * (sbb_cur / sbb_nmax));
    sbb_col.r = 0; sbb_col.g = 1; sbb_col.b = 0;
    
    if UnitIsPlayer(unit) then
      iTotPlayers = iTotPlayers + 1;
      iTotHP = iTotHP + (sbb_cur * 100 / sbb_nmax);
    end
    
    --btn.hp:ClearAllPoints();
    --btn.mana:ClearAllPoints();
    if (SMARTDEBUFF_Options.Invert) then sbb_n = sbb_w - sbb_n; end
    if (sbb_nmax == 1 or sbb_n < 0 or sbb_n > sbb_w or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or not SMARTDEBUFF_Options.ShowHP) then sbb_n = 0; end
    --if (n == max) then n = w; end;
    btn.hp:SetTexture(sbb_col.r, sbb_col.g, sbb_col.b, 1);
    btn.hp:SetPoint("TOPLEFT", btn , "TOPLEFT", 0, 0);
    btn.hp:SetPoint("TOPRIGHT", btn , "TOPLEFT", sbb_n, 0);
    btn.hp:SetPoint("BOTTOMLEFT", btn , "TOPLEFT", 0, -sbb_h);
    btn.hp:SetPoint("BOTTOMRIGHT", btn , "TOPLEFT", sbb_n, -sbb_h);
    
    sbb_cur = UnitMana(unit);
    sbb_nmax = UnitManaMax(unit);
    sbb_n = math.floor(sbb_w * (sbb_cur / sbb_nmax));
    if (SMARTDEBUFF_Options.Invert) then sbb_n = sbb_w - sbb_n; end
    if (sbb_nmax == 1 or sbb_n < 0 or sbb_n > sbb_w or sbb_upt ~= 0 or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or not SMARTDEBUFF_Options.ShowMana) then sbb_n = 0; end
    --if (n == max) then n = w; end;
    if (sbb_upt == 3) then
      -- 3 for Energy
      sbb_col.r = 1; sbb_col.g = 1; sbb_col.b = 0;
    elseif (sbb_upt == 2) then
      -- 2 for Focus (hunter pets)
      sbb_col.r = 1; sbb_col.g = 0.5; sbb_col.b = 0.25;
    elseif (sbb_upt == 1) then
      -- 1 for Rage
      sbb_col.r = 1; sbb_col.g = 0; sbb_col.b = 0;
    elseif (sbb_upt == 0) then
      -- 0 for Mana
      if (SMARTDEBUFF_Options.ShowClassColors and unitclass == "SHAMAN") then
        sbb_col.r = 0.5; sbb_col.g = 0.5; sbb_col.b = 1;
      else
        sbb_col.r = 0.2; sbb_col.g = 0.2; sbb_col.b = 1;
      end
      if UnitIsPlayer(unit) then
        iTotManaUser = iTotManaUser + 1;
        iTotMana = iTotMana + (sbb_cur * 100 / sbb_nmax);
      end
    else
      sbb_col.r = 0; sbb_col.g = 0; sbb_col.b = 0;
    end    
    btn.mana:SetTexture(sbb_col.r, sbb_col.g, sbb_col.b, 1);
    btn.mana:SetPoint("TOPLEFT", btn , "BOTTOMLEFT", 0, sbb_h);
    btn.mana:SetPoint("TOPRIGHT", btn , "BOTTOMLEFT", sbb_n, sbb_h);
    btn.mana:SetPoint("BOTTOMLEFT", btn , "BOTTOMLEFT", 0, 0);
    btn.mana:SetPoint("BOTTOMRIGHT", btn , "BOTTOMLEFT", sbb_n, 0);
    
    if (SMARTDEBUFF_Options.ShowAggro and sAggroList ~= nil and UnitIsPlayer(unit) and string.find(sAggroList, ":"..UnitName(unit)..":")) then
      btn.aggro:SetTexture(1, 1, 0, 1);
      btn.aggro:SetGradient("VERTICAL", 1, 1, 1, 1, 0.2, 0.2);
      btn.aggro:SetPoint("TOPLEFT", btn , "TOPLEFT", 0, -sbb_h);
      btn.aggro:SetPoint("TOPRIGHT", btn , "TOPLEFT", 3, -sbb_h);
      btn.aggro:SetPoint("BOTTOMLEFT", btn , "TOPLEFT", 0, -(btn:GetHeight() - sbb_h));
      btn.aggro:SetPoint("BOTTOMRIGHT", btn , "TOPLEFT", 3, -(btn:GetHeight() - sbb_h));
      btn.aggro:Show();
    else
      btn.aggro:Hide();
    end
    
  end
end

local shl_wd;
function SMARTDEBUFF_SetHeaderLabels(text, n, btn)
  lbl = getglobal("SmartDebuffTxt"..n);
  if (btn and btn:IsVisible() and SMARTDEBUFF_Options.ShowHeaders) then
    if (not text) then text = ""; end
    shl_wd = math.floor(btn:GetWidth() / 4 - 2);
    if (string.len(text) > shl_wd) then
      text = string.sub(text, 1, shl_wd);
    end
    lbl:SetText(text);
    if (SMARTDEBUFF_Options.VerticalUp) then
      lbl:SetPoint("TOPLEFT", btn , "BOTTOMLEFT", 0, 0);
      lbl:SetPoint("TOPRIGHT", btn , "BOTTOMRIGHT", 0, 0);
      lbl:SetPoint("BOTTOMLEFT", btn , "BOTTOMLEFT", 0, -10);
      lbl:SetPoint("BOTTOMRIGHT", btn , "BOTTOMRIGHT", 0, -10);    
    else
      lbl:SetPoint("TOPLEFT", btn , "TOPLEFT", 0, 10);
      lbl:SetPoint("TOPRIGHT", btn , "TOPRIGHT", 0, 10);
      lbl:SetPoint("BOTTOMLEFT", btn , "TOPLEFT", 0, 0);
      lbl:SetPoint("BOTTOMRIGHT", btn , "TOPRIGHT", 0, 0);
    end
    if (not lbl:IsVisible()) then
      lbl:Show();
    end
  else
    lbl:SetText("");
    if (lbl:IsVisible()) then
      lbl:Hide();
    end
  end
end

function SMARTDEBUFF_SetStyle()
  if (not canDebuff) then return; end
  
  local frmH, frmW, btnH, btnW;
  local nMax = 0;
  local frame = getglobal("SmartDebuffSF");
  local vu = 1;
  local anchor = "TOPLEFT";
  
  --if (not frame:IsVisible()) then return; end;
  if (not SMARTDEBUFF_IsVisible()) then return; end;
  
  if (SMARTDEBUFF_Options.VerticalUp) then
    vu = -1;
    anchor = "BOTTOMLEFT";
  end
  
  for i = 1, 10, 1 do
    SMARTDEBUFF_SetHeaderLabels("", i, nil);
  end  
  
  if (iGroupSetup == 3) then
    nMax = maxRaid;
  elseif (iGroupSetup == 2) then
    nMax = 5;
  elseif (iGroupSetup == 1) then
    nMax = 1;
  else
    return;
  end
  
  btnW = SMARTDEBUFF_Options.BtnW;
  btnH = SMARTDEBUFF_Options.BtnH;
  
  local i = 0;
  local j = 0;
  local btn, lbl;
  local sp = 0;
  local ln = 0;
  local offX = 0;
  local offY = 0;
  local grp = 1;
  local sbtn, unit, uc, luc;
  local b = true;
  local hx = 4;
  local hox = 0;
  local tX = 0;
  local tY = 0;
  
  if (SMARTDEBUFF_Options.ShowHeaderRow) then
    hx = 20;
  end
  if (SMARTDEBUFF_Options.ShowHeaders) then
    hox = 6;
  end
  

  for j = 0, (nMax - 1), 1 do
    btn = getglobal("SmartDebuffBtn"..(j + 1));
    btn:SetWidth(btnW);
    btn:SetHeight(btnH);
    sbtn = SecureButton_GetEffectiveButton(btn);
    unit = SecureButton_GetModifiedAttribute(btn, "unit", sbtn, "");
    
    if (unit) then

      if (SMARTDEBUFF_Options.SortedByClass) then
        if (btn:IsVisible()) then
          _, uc = UnitClass(unit);
          if (j == 0) then luc = uc; end
          
          if (j > 0 and luc ~= uc) then
            luc = uc;
            i = 0;
            sp = sp + btnW + 4;
            b = true;
          end
          if (b and (grp - 1) > 0 and math.fmod((grp - 1), SMARTDEBUFF_Options.Columns) == 0) then
            ln = offY + 4 + hox;
            sp = 0;
          end          
          btn:ClearAllPoints();
          btn:SetPoint(anchor, frame, anchor, 4 + sp, (-hx - hox - i * (btnH + 2) - ln) * vu);
          if (b) then
            SMARTDEBUFF_SetHeaderLabels(SMARTDEBUFF_CLASSES[uc], grp, btn);
            grp = grp + 1;
            b = false;
          end
        end
      
      elseif (SMARTDEBUFF_Options.Vertical) then
        if (j > 0 and math.fmod(j, 5) == 0) then
          i = 0;
          sp = sp + btnW + 4;
          b = true;
        end
        if (j > 0 and math.fmod(j, (SMARTDEBUFF_Options.Columns * 5)) == 0) then
          sp = 0;
          ln = ln + 5 * (btnH + 2) + 4 + hox;
        end
        btn:ClearAllPoints();
        btn:SetPoint(anchor, frame, anchor, 4 + sp, (-hx - hox - i * (btnH + 2) - ln) * vu);
        if (b) then
          SMARTDEBUFF_SetHeaderLabels("G"..cUnits[unit].Subgroup, grp, btn);
          grp = grp + 1;
          b = false;
        end      
      else
        if (j > 0 and math.fmod(j, 5) == 0) then
          sp = sp + 4;
          b = true;
        end
        if (j > 0 and math.fmod(j, (SMARTDEBUFF_Options.Columns * 5)) == 0) then
          ln = ln + 1;
          sp = 0;
          i = 0;
        end
        btn:ClearAllPoints();
        btn:SetPoint(anchor, frame, anchor, 4 + i * (btnW + 2) + sp, (-hx - hox - ln * (btnW + 4 + hox)) * vu);
        if (b) then
          SMARTDEBUFF_SetHeaderLabels("G"..cUnits[unit].Subgroup, grp, btn);
          grp = grp + 1;
          b = false;
        end      
      end
      
      if (btn:IsVisible()) then
        tX = btn:GetLeft() - frame:GetLeft() + btnW + 8;        
        if (SMARTDEBUFF_Options.VerticalUp) then
          tY = frame:GetBottom() - btn:GetTop() - 4;
        else
          tY = frame:GetTop() - btn:GetBottom() + 4;
        end        
        if (tX > offX) then
          offX = tX;
        end
        if (math.abs(tY) > math.abs(offY)) then
          offY = math.abs(tY);
        end
        --SMARTDEBUFF_AddMsgD("Get button values");
      end     
    end
    i = i + 1;
  end
  
  i = 0;
  j = 0;
  sp = 0;
  ln = 0;
  b = true;
  local offPX = offX;
  for j = 0, 19, 1 do
    btn = getglobal("SmartDebuffPetBtn"..(j + 1));
    btn:SetWidth(btnW);
    btn:SetHeight(btnH);        

    if (SMARTDEBUFF_Options.SortedByClass) then
      btn:ClearAllPoints();
      btn:SetPoint(anchor, frame, anchor, offX + sp, (-hx - hox - i * (btnH + 2)) * vu);
    elseif (SMARTDEBUFF_Options.Vertical) then
      if (j > 0 and math.fmod(j, 5) == 0) then
        i = 0;
        sp = sp + btnW + 4;
      end
      if (j > 0 and math.fmod(j, 10) == 0) then
        sp = 0;
        ln = ln + 5 * (btnH + 2) + 4 + hox;
      end
      btn:ClearAllPoints();
      btn:SetPoint(anchor, frame, anchor, offX + sp, (-hx - hox - i * (btnH + 2) - ln) * vu);
    else
      if (j > 0 and math.fmod(j, 5) == 0) then
        sp = sp + 4;
      end
      if (j > 0 and math.fmod(j, 5) == 0) then
        ln = ln + 1;
        sp = 0;
        i = 0;
      end
      btn:ClearAllPoints();
      btn:SetPoint(anchor, frame, anchor, offX + i * (btnW + 2) + sp, (-hx - hox - ln * (btnW + 4 + hox)) * vu);
    end
    if (b) then
      SMARTDEBUFF_SetHeaderLabels("Pets", grp, btn);
      grp = grp + 1;
      b = false;
    end    
    if (btn:IsVisible()) then
      tX = btn:GetLeft() - frame:GetLeft() + btnW + 8;
      if (SMARTDEBUFF_Options.VerticalUp) then
        tY = frame:GetBottom() - btn:GetTop() - 4;
      else
        tY = frame:GetTop() - btn:GetBottom() + 4;
      end       
      if (tX > offPX) then
        offPX = tX;
      end
      if (math.abs(tY) > math.abs(offY)) then
        offY = math.abs(tY);
      end
    end    
    i = i + 1;
  end  
  
  frmW = offPX - 4;
  frmH = offY;
  if (frmW < 120 and SMARTDEBUFF_Options.ShowHeaderRow) then frmW = 120; end
  if (frmH < 20) then frmH = 20; end
  frame:SetWidth(frmW);
  frame:SetHeight(frmH);  
  --frame:ClearAllPoints();
  --frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", SMARTDEBUFF_Options.SFPosX, SMARTDEBUFF_Options.SFPosY);
  --frame:SetPoint(anchor, UIParent, "TOPLEFT", SMARTDEBUFF_Options.SFPosX, SMARTDEBUFF_Options.SFPosY);
  --frame:SetPoint(anchor, SMARTDEBUFF_Options.SFPosX, SMARTDEBUFF_Options.SFPosY);
    
  --SMARTDEBUFF_AddMsgD("Debuff style set");
  SMARTDEBUFF_CheckDebuffs(true);
end


function SMARTDEBUFF_ToggleClassColors()
  SMARTDEBUFF_Options.ShowClassColors = SMARTDEBUFF_toggleBool(SMARTDEBUFF_Options.ShowClassColors, "Use class colors = ");
  if (SmartDebuffOF:IsVisible()) then
    SmartDebuffOF_cbClassColors:SetChecked(SMARTDEBUFF_Options.ShowClassColors);
  end  
  SMARTDEBUFF_CheckDebuffs(true);
end

function SMARTDEBUFF_ToggleShowLR()
  SMARTDEBUFF_Options.ShowLR = SMARTDEBUFF_toggleBool(SMARTDEBUFF_Options.ShowLR, "Show L/R = ");
  if (SmartDebuffOF:IsVisible()) then
    SmartDebuffOF_cbShowLR:SetChecked(SMARTDEBUFF_Options.ShowLR);
  end  
  SMARTDEBUFF_CheckDebuffs(true);
end

function SMARTDEBUFF_ToggleSortedByClass()
  SMARTDEBUFF_Options.SortedByClass = SMARTDEBUFF_toggleBool(SMARTDEBUFF_Options.SortedByClass, "Sorted by class = ");
  SMARTDEBUFF_SetButtons();
end


function SMARTDEBUFF_ButtonTooltipOnEnter(self)
  if (not self or not self:IsVisible() or InCombatLockdown() or not SMARTDEBUFF_Options.ShowTooltip) then return; end
  
  local sbtn = SecureButton_GetEffectiveButton(self);
  local unit = SecureButton_GetModifiedAttribute(self, "unit", sbtn, "");
  if (unit) then
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
    GameTooltip:SetUnit(unit);
    GameTooltip:Show();
  end
end

function SMARTDEBUFF_ButtonTooltipOnLeave()
  GameTooltip:Hide();
end

local gtl_text, gtl_obj;
function SMARTDEBUFF_GetTooltipLine(line)
  gtl_text = nil;
  gtl_obj = getglobal("SmartDebuffTooltipTextLeft" .. line);
  if (gtl_obj) then
    gtl_text = gtl_obj:GetText();
  end
  return gtl_text;
end

local io_text, io_nl, io_gname, io_i;
function SMARTDEBUFF_IsOffline(unit)
  if (unit and UnitIsPlayer(unit)) then
    SmartDebuffTooltip:ClearLines();
    SmartDebuffTooltip:SetUnit(unit);  
    io_nl = SmartDebuffTooltip:NumLines();
    io_gname = GetGuildInfo(unit);
    for io_i = 1, io_nl, 1 do
      io_text = SMARTDEBUFF_GetTooltipLine(io_i);
      if (io_text) then
        --SMARTDEBUFF_AddMsgD("Tooltip: " .. io_text);
        if (io_text ~= UnitName(unit) and io_text ~= io_gname and string.find(string.lower(io_text), "offline")) then
          return true;
        end
      end
    end
  end
  return false;
end

-- END SmartDebuff frame functions


-- SmartDebuff functions ---------------------------------------------------------------------------------------
-- Main check function, called by update event
local cd_i, cd_unit, cd_btn, cd_sbtn, cd_spell;
function SMARTDEBUFF_CheckDebuffs(force)
  if (not isInit or not canDebuff or (not force and GetTime() < (tDebuff + SMARTDEBUFF_Options.CheckInterval))) then
    return;
  end 
  tDebuff = GetTime();  
  hasDebuff = false;

  if (SMARTDEBUFF_IsVisible() and cSpells) then    
    --SMARTDEBUFF_AddMsgD(string.format("Debuff check (%.1f): %.2f", SMARTDEBUFF_Options.CheckInterval, tDebuff));
    
    iTotMana = 0;
    iTotHP = 0;
    iTotAFK = 0;
    iTotOFF = 0;
    iTotDead = 0;
    iTotPlayers = 0;
    iTotManaUser = 0;
    
    sAggroList = ":";
    if (SMARTDEBUFF_Options.ShowAggro) then
      for cd_i = 1, maxRaid, 1 do
        cd_btn = getglobal("SmartDebuffBtn"..cd_i);
        cd_sbtn = SecureButton_GetEffectiveButton(cd_btn);
        if (cd_sbtn) then
          cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
          if (cd_unit and UnitExists(cd_unit)) then
            if (UnitName(cd_unit.."target") and not UnitIsPlayer(cd_unit.."target") and UnitName(cd_unit.."targettarget")) then
              if (not string.find(sAggroList, ":"..UnitName(cd_unit.."targettarget")..":")) then
                sAggroList = sAggroList..UnitName(cd_unit.."targettarget")..":";
              end
            end
            if (UnitName(cd_unit.."targettarget") == UnitName(cd_unit) and not UnitIsPlayer(cd_unit.."target")) then            
              if (not string.find(sAggroList, ":"..UnitName(cd_unit)..":")) then
                sAggroList = sAggroList..UnitName(cd_unit)..":";
              end
            end
          end
        end
      end
    end
    
    for cd_i = 1, maxRaid, 1 do
      cd_btn = getglobal("SmartDebuffBtn"..cd_i);
      cd_sbtn = SecureButton_GetEffectiveButton(cd_btn);
      if (cd_sbtn) then
        cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
        cd_spell = cSpellDefault[1][3];
        if (cd_unit and UnitExists(cd_unit)) then
          --SMARTDEBUFF_AddMsgD("Unit found: " .. unit .. ", " .. UnitName(unit) .. ", " .. i);
          SMARTDEBUFF_CheckUnitDebuffs(cd_spell, cd_unit, cd_i, isSpellActive);
        end
      end
    end
    
    --SmartDebuffIF_lblInfo:SetText(string.format("|cff20d2ff.:Info:.|r\nPlayers: |cffffffff%d|r\nHP: |cffffffff%.1f%%|r\nMana: |cffffffff%.1f%%|r\nDead: |cffffffff%d|r\nAFK: |cffffffff%d|r\nOffline: |cffffffff%d|r", iTotPlayers, iTotHP / iTotPlayers, iTotMana / iTotManaUser, iTotDead, iTotAFK, iTotOFF));
    SmartDebuffIF_lblInfo:SetText("Players:\nHP %:\nMana %:\nDead:\nAFK:\nOffline:");
    if (iTotManaUser == 0) then iTotManaUser = 1; end
    iTmp = iTotPlayers;
    if (iTmp == 0) then iTmp = 1; end
    SmartDebuffIF_lblOut:SetText(string.format("%d\n%.1f\n%.1f\n%d\n%d\n%d", iTotPlayers, iTotHP / iTmp, iTotMana / iTotManaUser, iTotDead, iTotAFK, iTotOFF));
    
    if (SMARTDEBUFF_Options.ShowPets or SMARTDEBUFF_Options.ShowPetsWL) then
      for cd_i = 1, maxPets, 1  do
        cd_btn = getglobal("SmartDebuffPetBtn"..cd_i);
        cd_sbtn = SecureButton_GetEffectiveButton(cd_btn);
        if (cd_sbtn) then
          cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
          cd_spell = cSpellDefault[1][3];
          if (cd_unit and UnitExists(cd_unit)) then
            --SMARTDEBUFF_AddMsgD("Pet found: " .. unit .. ", " .. UnitName(unit) .. ", " .. i);
            SMARTDEBUFF_CheckUnitDebuffs(cd_spell, cd_unit, cd_i, isSpellActive, 1);
          end
        end
      end
    end    
    
    --SMARTDEBUFF_AddMsgD("Debuffs checked");
  end

  SMARTDEBUFF_CheckAutoHide();  
  if (not hasDebuff) then
    isSoundPlayed = false;
  end
end

-- Dectects debuffs on a single unit
local cud_name, cud_icon, cud_dtype, cud_uclass, cud_ir, cud_n, cud_dur, cud_tl, cud_nrd, cud_un, cud_tlnr;
function SMARTDEBUFF_CheckUnitDebuffs(spell, unit, idx, isActive, pet)
  cud_n = -1;
  cud_nrd = false;
  if ((spell or SMARTDEBUFF_Options.ShowNotRemov) and isActive) then
    if (spell and ((type(spell) ~= "number" and IsSpellInRange(spell, unit) == 1) or (type(spell) == "number" and sRangeCheckSpell and IsSpellInRange(sRangeCheckSpell, unit) == 1))) then
      cud_ir = 1;
    else
      cud_ir = 0;
    end
    --SMARTDEBUFF_AddMsgD("Check unit: " .. unit .. ", " .. UnitName(unit) .. ", " .. idx);

    cud_n = 1;
    while (true) do
      --name,rank,icon,count,type = UnitDebuff("unit", id or "name"[,"rank"])
      cud_name, _, cud_icon, _, cud_dtype, cud_dur, cud_tl, _ = UnitAura(unit, cud_n, "HARMFUL");
      if (not cud_icon) then
        break;
      end
      
      if (not cud_tl) then cud_tl = -1; end
      cud_tl = cud_tl - GetTime();
            
      if (spell and cud_name and cud_dtype) then
        --SMARTDEBUFF_AddMsgD("Debuff found: " .. name .. ", " .. cud_dtype);
        _, cud_uclass = UnitClass(unit);
        
        --and not UnitCanAttack("player", unit)
        if (cSpells[cud_dtype] and (not UnitCanAttack("player", unit) or UnitIsCharmed(unit)) and not SMARTDEBUFF_DEBUFFSKIPLIST[cud_name] and not (SMARTDEBUFF_DEBUFFCLASSSKIPLIST[cud_uclass] and SMARTDEBUFF_DEBUFFCLASSSKIPLIST[cud_uclass][cud_name])) then
          hasDebuff = true;
          SMARTDEBUFF_SetButtonState(unit, idx, cSpells[cud_dtype][2], cud_ir, cud_tl, pet);
          SMARTDEBUFF_PlaySound();
          return;
        end
      end
      
      -- Check if a player has an unremovable debuff
      if (not cud_nrd and SMARTDEBUFF_Options.ShowNotRemov and cud_name and not cud_dtype) then
        for _, v in ipairs(SMARTDEBUFF_Options.NotRemovableDebuffs) do
          if (v and cud_name and v == cud_name) then            
            cud_nrd = true;
            cud_tlnr = cud_tl;
            break;
          end
        end      
      end

      cud_n = cud_n + 1;
      --SMARTDEBUFF_AddMsgD("Check debuff");
    end
    
    -- check if a player is charmed, can be attacked and is polymorphable
    if (cSpells[SMARTDEBUFF_CHARMED] and UnitIsCharmed(unit) and UnitCanAttack("player", unit) and UnitCreatureType(unit) == SMARTDEBUFF_HUMANOID) then
      hasDebuff = true;
      SMARTDEBUFF_SetButtonState(unit, idx, cSpells[SMARTDEBUFF_CHARMED][2], cud_ir, cud_tl, pet);
      SMARTDEBUFF_PlaySound();
      return;
    end
    
    if (cud_nrd) then
      hasDebuff = true;
      SMARTDEBUFF_SetButtonState(unit, idx, 10, 1, cud_tlnr, pet);
      SMARTDEBUFF_PlaySound();
      return;
    end
      
    SMARTDEBUFF_SetButtonState(unit, idx, 0, cud_ir, -1, pet);
  else
    SMARTDEBUFF_SetButtonState(unit, idx, -1, 0, -1, pet);
  end
  
end

function SMARTDEBUFF_PlaySound()
  if (SMARTDEBUFF_Options.UseSound and not isSoundPlayed) then
    PlaySoundFile(SMARTDEBUFF_CONST_SOUND);
    isSoundPlayed = true;
    --SMARTDEBUFF_AddMsgD("Play sound");
  end
end
-- END SmartDebuff functions


-- SmartDebuff option frame functions ---------------------------------------------------------------------------------------

function SMARTDEBUFF_SetGameTooltip(self, title, text, anchor)
  if (not anchor) then anchor = "ANCHOR_LEFT"; end
  GameTooltip:SetOwner(self, anchor);
  GameTooltip:SetText(WH..title);
  GameTooltip:AddLine(text, SMARTDEBUFF_TTC_R, SMARTDEBUFF_TTC_G, SMARTDEBUFF_TTC_B, 1);
  GameTooltip:AppendText("");
end

function SMARTDEBUFF_ToggleOF()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
  local frame = SmartDebuffOF;
  if (frame:IsVisible()) then
    frame:Hide();
  else
    frame:Show();
  end
end

function SMARTDEBUFF_OFToggleGrp(i)
  SMARTDEBUFF_Options.DebuffGrp[i] = not SMARTDEBUFF_Options.DebuffGrp[i];
  isSetUnits = true;
end

function SMARTDEBUFF_OFOnShow()
  if (SmartDebuffAOFOrder:IsVisible()) then
    SmartDebuffAOFOrder:Hide();
  end
  if (SmartDebuffNRDebuffs:IsVisible()) then
    SmartDebuffNRDebuffs:Hide();
  end  
  if (SmartDebuffAOFKeys:IsVisible()) then
    SmartDebuffAOFKeys:Hide();
  end
  SMARTDEBUFF_CheckAutoHide();
end

function SMARTDEBUFF_OFOnHide()
  SMARTDEBUFF_LinkSpellsToKeys();
  SMARTDEBUFF_CheckAutoHide();
  if (SmartDebuffWNF:IsVisible()) then
    SmartDebuffWNF:Hide();
  end
end


function SMARTDEBUFF_SetAutoHide(b)
  if (SMARTDEBUFF_Options.AutoHide) then
    local i, btn;
    SmartDebuffSF:EnableMouse(b);
    for i = 1, maxRaid, 1 do
      btn = getglobal("SmartDebuffBtn"..i);
      if (btn) then btn:EnableMouse(b); end
    end
    for i = 1, maxPets, 1 do
      btn = getglobal("SmartDebuffPetBtn"..i);
      if (btn) then btn:EnableMouse(b); end
    end
          
    if (b) then
      SmartDebuffSF:SetAlpha(1);
    else
      SmartDebuffSF:SetAlpha(0.01);
    end
  end
end

function SMARTDEBUFF_CheckAutoHide()
  if (not isInit or not SMARTDEBUFF_Options or not SMARTDEBUFF_Options.ShowSF or InCombatLockdown()) then return; end
  if (SMARTDEBUFF_Options.AutoHide) then
    if ((hasDebuff or SmartDebuffOF:IsVisible())) then
      SMARTDEBUFF_SetAutoHide(true);
    else
      SMARTDEBUFF_SetAutoHide(false);
    end     
  else
    SMARTDEBUFF_SetAutoHide(true);
  end
end



function SMARTDEBUFF_SetOrderItem(control, cTable, idx, cHelperTable)
  local s = "";  
  local tn = 0;
  for _, data in ipairs(cTable) do
    tn = tn + 1;
    if (cHelperTable) then
      s = s .. cHelperTable[data] .. "\n";
    else
      s = s .. data .. "\n";
    end
  end
  control:SetText(s);
    
  -- highlight selected item
  if (idx > tn) then idx = tn; end
  if (idx < 1)  then idx = 1; end
  local n = 0;
  local i = 0;
  local w = 0;
  for _, data in ipairs(cTable) do
    n = n + 1;
    if (cHelperTable) then
      w = string.len(cHelperTable[data]);
    else
      w = string.len(data);
    end
    if (n == idx) then
      control:HighlightText(i + n - 1, i + n + w);
      break;
    end
    i = i + w;
  end
end

local iLastItem = 1;
function SMARTDEBUFF_GetOrderItem(cTable, iOp)
  local idx = iLastItem + iOp;
  local iLast = iLastItem;
  local tn = 0;
  
  for _ in ipairs(cTable) do
    tn = tn + 1;
  end  
  
  if (idx > tn) then idx = tn; end
  if (idx < 1)  then idx = 1; end
  iLastItem = idx;
  return idx, iLast, tn;
end

function SMARTDEBUFF_MoveOrderItem(cTable, iOp)
  local n, c, max = SMARTDEBUFF_GetOrderItem(cTable, iOp);
  if (n ~= c) then
    local val = cTable[c];
    table.remove(cTable, c);
    table.insert(cTable, n, val);
  end
  return n;
end

function SMARTDEBUFF_RemoveOrderItem(cTable)
  local n, c, max = SMARTDEBUFF_GetOrderItem(cTable, 0);
  if (n == c) then
    table.remove(cTable, c);
  end
  return n - 1;  
end


function SMARTDEBUFF_OrderOnShow()
  if (SmartDebuffAOFKeys:IsVisible()) then
    SmartDebuffAOFKeys:Hide();
  end
  if (SmartDebuffNRDebuffs:IsVisible()) then
    SmartDebuffNRDebuffs:Hide();
  end
end

function SMARTDEBUFF_OrderOnHide()
end

function SMARTDEBUFF_ToggleAOFOrder(mode)
  iLastItem = 1;
  if (SmartDebuffAOFOrder:IsVisible()) then
    SmartDebuffAOFOrder:Hide();
  else
    SmartDebuffAOFOrder:Show();
    if (mode == 1) then
      SMARTDEBUFF_ClassOrderOnShow();
    end
  end
end

function SMARTDEBUFF_ClassOrderOnShow()
  SmartDebuffAOFOrder_Title:SetText(SMARTDEBUFF_AOFT_SORTBYCLASS);
  SMARTDEBUFF_ClassOrder(0);
end

function SMARTDEBUFF_ClassOrder(iOp)
  local n = SMARTDEBUFF_GetOrderItem(SMARTDEBUFF_Options.OrderClass, iOp);
  SMARTDEBUFF_SetOrderItem(SmartDebuff_txtAOFScrollFrame, SMARTDEBUFF_Options.OrderClass, n, SMARTDEBUFF_CLASSES);
end

function SMARTDEBUFF_MoveClassOrder(iOp)
  local n = SMARTDEBUFF_MoveOrderItem(SMARTDEBUFF_Options.OrderClass, iOp);
  SMARTDEBUFF_SetOrderItem(SmartDebuff_txtAOFScrollFrame, SMARTDEBUFF_Options.OrderClass, n, SMARTDEBUFF_CLASSES);
end


function SMARTDEBUFF_NRDebuffsOnShow()
  iLastItem = 1;
  if (SmartDebuffAOFKeys:IsVisible()) then
    SmartDebuffAOFKeys:Hide();
  end
  if (SmartDebuffAOFOrder:IsVisible()) then
    SmartDebuffAOFOrder:Hide();
  end
  SmartDebuffNRDebuffs_Title:SetText(SMARTDEBUFF_NRDT_TITLE);  
end

function SMARTDEBUFF_ToggleNRDebuffs()
  if (SmartDebuffNRDebuffs:IsVisible()) then
    SmartDebuffNRDebuffs:Hide();
  else
    SmartDebuffNRDebuffs:Show();
  end
end

function SMARTDEBUFF_NRDebuffsOnHide()
end


function SMARTDEBUFF_NRDAddDebuff(self)
  if (self) then
    local text = self:GetText();
    if (text and string.len(text) > 1) then
      table.insert(SMARTDEBUFF_Options.NotRemovableDebuffs, text);
      self:SetText("");      
    end
    self:ClearFocus();
  end
end

local function CreateScrollButton(name, parent)
	local button = CreateFrame("Button", name, parent);
	button:SetWidth(parent:GetWidth());
	button:SetHeight(10);
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:SetScript("OnClick", SmartDebuff_NRDBtnOnClick);

	local text = button:CreateFontString(nil, nil, "GameFontNormal");
	text:SetJustifyH("LEFT");
	text:SetAllPoints(button);
	button:SetFontString(text);
	button:SetHighlightFontObject("GameFontHighlight");

	local highlight = button:CreateTexture();
	highlight:SetAllPoints(button);
	highlight:SetTexture("Interface/QuestFrame/UI-QuestTitleHighlight");
	button:SetHighlightTexture(highlight);

	return button;
end

function SMARTDEBUFF_NRDOnScroll(self, arg1)
  if (not self) then
    self = SmartDebuffNRDebuffs_ScrollFrame;
  end
  
  local btn, i;
  local name = "SMARTDEBUFF_BtnScroll";
  if (not cScrollButtons and self) then
    cScrollButtons = { };
    for i = 1, maxScrollBtn, 1 do
      btn = CreateScrollButton(name..i, self);
      btn:SetID(i);
      if (i == 1) then
        btn:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2);
      else
        btn:SetPoint("TOPLEFT", name..i-1, "BOTTOMLEFT", 0, -2);
        btn:SetPoint("TOPRIGHT", name..i-1, "BOTTOMRIGHT", 0, -2);
      end
      cScrollButtons[i] = btn;
      --table.insert(SMARTDEBUFF_Options.NotRemovableDebuffs, name..i);
    end
  end
  
  local num = #SMARTDEBUFF_Options.NotRemovableDebuffs;
  local n, numToDisplay;
  
  if (num <= maxScrollBtn) then
    numToDisplay = num - 1;
  else
    numToDisplay = maxScrollBtn;
  end
  
  FauxScrollFrame_Update(self, num, numToDisplay, 10);
  for i = 1, maxScrollBtn, 1 do
    n = i + FauxScrollFrame_GetOffset(self);
    btn = getglobal("SMARTDEBUFF_BtnScroll"..i);
    if (btn) then
      if (n <= num) then
        btn:SetNormalFontObject("GameFontNormalSmall");
        btn:SetHighlightFontObject("GameFontHighlightSmall");      
        btn:SetText(SMARTDEBUFF_Options.NotRemovableDebuffs[n]);
        btn:Show();
        --SMARTDEBUFF_AddMsgD("Show "..n.." - "..SMARTDEBUFF_Options.NotRemovableDebuffs[n]);
      else
        btn:Hide();
      end
    end
  end
end

function SmartDebuff_NRDBtnOnClick(self, button)
	--self:LockHighlight();
  if (button == "LeftButton") then
    SmartDebuffNRDebuffs_txtDebuff:SetText(self:GetText());
  else    
    local n = self:GetID() + FauxScrollFrame_GetOffset(self:GetParent());
    --SMARTDEBUFF_AddMsgD("Remove: "..n);
    if (SMARTDEBUFF_Options.NotRemovableDebuffs[n]) then
      table.remove(SMARTDEBUFF_Options.NotRemovableDebuffs, n);
    end
    SMARTDEBUFF_NRDOnScroll();
  end
  SmartDebuffNRDebuffs_txtDebuff:ClearFocus();
end


-- SmartDebuff action binding option frame functions ---------------------------------------------------------------------------------------

function SMARTDEBUFF_ToggleAOFKeys()
  if (SmartDebuffAOFKeys:IsVisible()) then
    SmartDebuffAOFKeys:Hide();
  else
    SmartDebuffAOFKeys:Show();
  end
end

function SmartDebuffAOFKeys_OnShow(self)
  if (SmartDebuffAOFOrder:IsVisible()) then
    SmartDebuffAOFOrder:Hide();
  end
  if (SmartDebuffNRDebuffs:IsVisible()) then
    SmartDebuffNRDebuffs:Hide();
  end  
  
  local aName, aType, aRank, aId, aLink, aTexture;
  local mode = 1;
  local j;
  local btn;
  for i = 1, 24, 1 do
    btn = getglobal("SmartDebuff_btnAction"..i);
    mode, j = GetActionMode(i);    
    aType, aName, aRank, aId, aLink = GetActionInfo(mode, j);
    if (aType == "spell" and aName) then
      SetATexture(btn, GetSpellTexture(aId, BOOKTYPE_SPELL));      
      --SMARTDEBUFF_AddMsgD("Added: "..self:GetID().." - "..aName.." - "..aRank);
    elseif (aType == "item") then
      SetATexture(btn, GetItemIcon(aName));
    elseif (aType == "macro") then
      _, aTexture = GetMacroInfo(aId);
      SetATexture(btn, aTexture);
    elseif (aType == "target") then
      SetATexture(btn, imgTarget);
    elseif (aType == "action" and aLink) then
      SetATexture(btn, aLink);
    else      
      SetATexture(btn, imgActionSlot);
    end    
  end
end


function SMARTDEBUFF_OnActionUp(self, button)
  if (GetCursorInfo()) then
    SMARTDEBUFF_DropAction(self, button);
  end
end

function SMARTDEBUFF_OnActionDown(self, button)
  if (GetCursorInfo()) then
    SMARTDEBUFF_DropAction(self, button);
  else
    SMARTDEBUFF_PickAction(self, button);
  end
end

function SMARTDEBUFF_OnReceiveDrag(self)
  if (GetCursorInfo()) then
    SMARTDEBUFF_DropAction(self, "LeftButton");
  else
    SMARTDEBUFF_PickAction(self, "LeftButton");
  end
end


function SMARTDEBUFF_PickAction(self, button)
  local i = self:GetID();
  local mode = 1;
  
  mode, i = GetActionMode(i);
  local aType, aName, aRank, aId = GetActionInfo(mode, i);
  if (button == "LeftButton") then    
    if (aType) then
      if (aType == "spell") then
        --SMARTDEBUFF_AddMsgD("Pick: "..aId.." - "..aName.." - "..aRank);
        PickupSpell(aId, "spell");
      elseif (aType == "item") then
        PickupItem(aId);
      elseif (aType == "macro") then
        PickupMacro(aId);
      elseif (aType == "action") then
        -- Do nothing
      elseif (aType == "target") then
        -- Do nothing
      end
      if (not IsShiftKeyDown() and aType ~= "action") then
        SetActionInfo(mode, i, nil, nil, nil, nil, nil);
        SetATexture(self, imgActionSlot);
      end      
    else
      SetActionInfo(mode, i, "target", "target", nil, nil, nil);
      SetATexture(self, imgTarget);
    end
  else
    if (aType and aType == "action") then
      -- Do nothing
    else
      SetActionInfo(mode, i, nil, nil, nil, nil, nil);
      SetATexture(self, imgActionSlot);
    end
  end
  SMARTDEBUFF_SetButtons();
end


function SMARTDEBUFF_DropAction(self, button)
  --"item", itemID, itemLink
  --"spell", spellid, bookType - Only works for player spells, so this always returns BOOKTYPE_SPELL!
  --"macro", index
  --"money", amount
  --"merchant", index
  
  local infoType, infoId, info2 = GetCursorInfo();
  local aName, aRank, aTexture;
  local i = self:GetID();
  local mode = 1;
  local bDroped = false;
  
  --SMARTDEBUFF_AddMsgD(button);
  SMARTDEBUFF_AddMsgD(ChkS(infoType)..", "..ChkS(infoId)..", "..ChkS(info2));
  mode, i = GetActionMode(i);
  if (button == "LeftButton" and infoType) then
    local aTypeOld, aNameOld, _, aIdOld, aLinkOld = GetActionInfo(mode, i);    
    
    if (aTypeOld ~= "action") then
      if (infoType == "spell" and not IsPassiveSpell(infoId, info2)) then      
        aName, aRank = GetSpellName(infoId, info2);
        if (aName) then
          aTexture = GetSpellTexture(infoId, info2);
          SetActionInfo(mode, i, infoType, aName, aRank, infoId, info2);
          bDroped = true;
        end
      elseif (infoType == "item") then
        --itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)
        aName, _, _, _, _, _, _, _, _, aTexture = GetItemInfo(infoId);
        SetActionInfo(mode, i, infoType, aName, nil, infoId, info2);
        bDroped = true;
      elseif (infoType == "macro") then
        aName, aTexture = GetMacroInfo(infoId);
        SetActionInfo(mode, i, infoType, aName, nil, infoId, nil);
        bDroped = true;
      elseif (infoType == "action") then
        -- Do nothing
      end
    end
    
    if (bDroped) then      
      SetATexture(self, aTexture);
      ClearCursor();
      if (aTypeOld) then
        if (aTypeOld == "spell") then
          PickupSpell(aIdOld, aLinkOld);
        elseif (aTypeOld == "item") then
          PickupItem(aIdOld);
        elseif (aTypeOld == "macro") then
          PickupMacro(aIdOld);
        elseif (aTypeOld == "action") then
          -- Do nothing
        end        
      end
      GameTooltip:Hide();
      SMARTDEBUFF_AddMsgD("Droped: "..self:GetID().." - "..infoType.." - "..aName.." - "..infoId);
      SMARTDEBUFF_SetButtons();
    end
  end
end


function SMARTDEBUFF_BtnActionOnEnter(self, motion)
  local i = self:GetID();
  local mode = 1;  
  mode, i = GetActionMode(i);
  local aType, aName, aRank, aId, aLink = GetActionInfo(mode, i);
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
  if (aType == "spell") then
    --GameTooltip:SetText(WH..aName);
    GameTooltip:SetSpell(aId, 1);
    GameTooltip:AddLine(GR..SMARTDEBUFF_TT_DROPSPELL);
  elseif (aType == "item") then
    GameTooltip:SetHyperlink(aLink);
    GameTooltip:AddLine(GR..SMARTDEBUFF_TT_DROPITEM);
  elseif (aType == "macro") then  
    GameTooltip:SetText(WH..aName);
    GameTooltip:AddLine(GR..SMARTDEBUFF_TT_DROPMACRO);
  elseif (aType == "target") then
    GameTooltip:SetText(WH..SMARTDEBUFF_TT_TARGET);
    GameTooltip:AddLine(SMARTDEBUFF_TT_TARGETINFO);
    GameTooltip:AddLine(GR..SMARTDEBUFF_TT_DROPTARGET);
  elseif (aType == "action") then
    --GameTooltip:SetPetAction(aId);
    GameTooltip:SetText(WH..aName);
    if (aRank) then
      GameTooltip:AddLine(aRank, 1.0, 0.82, 0.0, 1);
    end
    GameTooltip:AddLine(GR..SMARTDEBUFF_TT_DROPACTION);
  else  
    --GameTooltip:SetText(WH.."Drop ("..self:GetID()..")");
    GameTooltip:SetText(WH..SMARTDEBUFF_TT_DROP);
    GameTooltip:AddLine(SMARTDEBUFF_TT_DROPINFO);
  end
  GameTooltip:AppendText("");
end


function SMARTDEBUFF_BtnActionOnLeave(self, motion)
  GameTooltip:Hide();
end
