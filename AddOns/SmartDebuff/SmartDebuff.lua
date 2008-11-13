-------------------------------------------------------------------------------
-- SmartDebuff
-- Created by Aeldra (EU-Proudmoore)
--
-- Supports you to cast debuff spells on friendly units
-------------------------------------------------------------------------------

SMARTDEBUFF_VERSION       = "v2.3a";
SMARTDEBUFF_TITLE         = "SmartDebuff";
SMARTDEBUFF_SUBTITLE      = "Debuff support";
SMARTDEBUFF_DESC          = "Supports you to cast debuff spells on friendly units";
SMARTDEBUFF_VERS_TITLE    = SMARTDEBUFF_TITLE .. " " .. SMARTDEBUFF_VERSION;
SMARTDEBUFF_OPTIONS_TITLE = SMARTDEBUFF_VERS_TITLE .. " Options";

BINDING_HEADER_SMARTDEBUFF = "SmartDebuff";
SMARTDEBUFF_BOOK_TYPE_SPELL = "spell";

local maxRaid = 40;
local maxPets = 20;

local isLoaded = false;
local isPlayer = false;
local isInit = false;
local isSetUnits = false;
local isSetPets = false;
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
local iGroupSetup = -1;

local cGroups  = { };
local cClasses = { };
local cUnits   = { };
local cPets    = { };

local cHeals = nil;
local cSpells = nil;

local canDebuff = false;
local hasDebuff = false;

local cAddUnitList = { };
local cIgnoreUnitList = { };

local sHeal1 = nil;
local sDSpell1 = nil;

local fiMain = nil;
local fiInfo = nil;

local iTotMana = 0;
local iTotHP = 0;
local iTotAFK = 0;
local iTotOFF = 0;
local iTotDead = 0;
local iTotPlayers = 0;
local iTotManaUser = 0;
local iTmp;


local cOrderClass = {"WARRIOR", "PRIEST", "DRUID", "PALADIN", "SHAMAN", "MAGE", "WARLOCK", "HUNTER", "ROGUE"};
local cOrderGrp   = {1, 2 , 3, 4 , 5 , 6, 7, 8};
local cOrderKeys  = {"L", "R", "M", "SL", "SR", "SM", "AL", "AR", "AM", "CL", "CR", "CM"};

local imgSDB       = "Interface\\Icons\\Spell_Holy_LayOnHands";
--local imgIconOn  = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonEnabled";
--local imgIconOff = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonDisabled";

local DebugChatFrame = DEFAULT_CHAT_FRAME;

local cActionName = { "-", "target", "trade", "wisper", "-" };


--Returns a chat color code string
local function BCC(r, g, b)
	return string.format("|cff%02x%02x%02x", (r*255), (g*255), (b*255));
end

local BL  = BCC(0, 0, 1);
local BLD = BCC(0, 0, 0.7);
local BLL = BCC(0.5, 0.8, 1);
local GR  = BCC(0, 1, 0);
local GRD = BCC(0, 0.7, 0);
local GRL = BCC(0.6, 1, 0.6);
local RD  = BCC(1, 0, 0);
local RDD = BCC(0.7, 0, 0);
local RDL = BCC(1, 0.3, 0.3);
local YL  = BCC(1, 1, 0);
local YLD = BCC(0.7, 0.7, 0);
local YLL = BCC(1, 1, 0.5);
local OR  = BCC(1, 0.7, 0);
local ORD = BCC(0.7, 0.5, 0);
local ORL = BCC(1, 0.6, 0.3);
local WH  = BCC(1, 1, 1);
local CY  = BCC(0.5, 1, 1);

local function ChkS(text)
  if (text == nil) then
    text = "";
  end
  return text;
end


-- SMARTDEBUFF_OnLoad
function SMARTDEBUFF_OnLoad()
  this:RegisterEvent("ADDON_LOADED");
  this:RegisterEvent("PLAYER_ENTERING_WORLD");
  this:RegisterEvent("UNIT_NAME_UPDATE");
  
  this:RegisterEvent("PARTY_MEMBERS_CHANGED");
  this:RegisterEvent("RAID_ROSTER_UPDATE");
  this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	
	this:RegisterEvent("LEARNED_SPELL_IN_TAB");
  this:RegisterEvent("UNIT_PET");
  
  --One of them allows SmartDebuff to be closed with the Escape key
  tinsert(UISpecialFrames, "SmartDebuffOF");
	UIPanelWindows["SmartDebuffOF"] = nil;
  
	SlashCmdList["SMARTDEBUFF"] = SMARTDEBUFF_command;
	SLASH_SMARTDEBUFF1 = "/sdb";
	SLASH_SMARTDEBUFF2 = "/smartdebuff";

	SlashCmdList["SMARTDEBUFFOPTIONS"] = SMARTDEBUFF_ToggleOF;
	SLASH_SMARTDEBUFFOPTIONS1 = "/sdbo";
	
  SlashCmdList["SMARTDEBUFFRELOAD"] = function(msg) ReloadUI(); end;
	SLASH_SMARTDEBUFFRELOAD1 = "/rui";  
end
-- END SMARTDEBUFF_OnLoad


-- SMARTDEBUFF_OnEvent
function SMARTDEBUFF_OnEvent(event)
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
  
  elseif (event == "UNIT_PET" or (event == "UNIT_NAME_UPDATE" and string.find(arg1, "pet"))) then
    isSetPets = true;
    SMARTDEBUFF_CheckWarlockPet();
    
  elseif (event == "PLAYER_REGEN_DISABLED") then
    SMARTDEBUFF_CheckSFButtons(true);
    SMARTDEBUFF_Ticker(true);
    
  elseif (event == "PLAYER_REGEN_ENABLED") then
    SMARTDEBUFF_CheckSFButtons();
    SMARTDEBUFF_Ticker(true);

	elseif (event == "LEARNED_SPELL_IN_TAB") then   
    isSetSpells = true;
  end

end
-- END SMARTDEBUFF_OnEvent


function SMARTDEBUFF_OnUpdate(elapsed)
  if (isInit) then
    SMARTDEBUFF_Ticker();
    SMARTDEBUFF_CheckDebuffs();
  end
end

function SMARTDEBUFF_Ticker(force)
  if (force or GetTime() > tTicker + 1) then
    tTicker = GetTime();
    
    if (isSetPets and not isSetUnits) then
      isSetPets = false;
      if (canDebuff and SmartDebuffSF:IsVisible()) then
        if (InCombatLockdown()) then
          isSetUnits = true;
        else
          SMARTDEBUFF_AddMsgD("Unit pet changed");
          SMARTDEBUFF_SetPetButtons();
        end
      end    
    end
    
    if (isSetUnits and not InCombatLockdown()) then
      isSetUnits = false;
      SMARTDEBUFF_SetUnits();
    end
    
    if (isSetSpells) then
      isSetSpells = false;
      SMARTDEBUFF_SetSpells();
    end    
    
  end 
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


function SMARTDEBUFF_ClearTable(tab)
	for key in pairs(tab) do
	  if (type(tab[key]) == "table") then
	    SMARTDEBUFF_ClearTable(tab[key]);
	  end
		table[key] = nil;
	end
end


function SMARTDEBUFF_CheckWarlockPet()
  if (sPlayerClass == "WARLOCK") then
    cSpells[SMARTDEBUFF_MAGIC] = nil;
    isSpellActive = false;
    if (UnitExists("pet")) then
      local ucf = UnitCreatureFamily("pet");
      if (ucf == SMARTDEBUFF_FELHUNTER) then        
        local i = 1;
        for i = 1, 10, 1 do
          name = GetPetActionInfo(i);
          if (name and name == SMARTDEBUFF_PET_FELHUNTER) then
            cSpells[SMARTDEBUFF_MAGIC] = {i, 1};
            isSpellActive = true;
            isSetUnits = true;
            SMARTDEBUFF_AddMsgD("Warlock pet spell found: " .. SMARTDEBUFF_PET_FELHUNTER);
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
  --SMARTDEBUFF_ClearTable(cGroups);
  --SMARTDEBUFF_ClearTable(cClasses);
  --SMARTDEBUFF_ClearTable(cPets);
  --SMARTDEBUFF_ClearTable(cUnits);
  
  --cAddUnitList = { };
  --cIgnoreUnitList = { };
  
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
  
  SMARTDEBUFF_CheckWarlockPet();
  SMARTDEBUFF_SetButtons();
  SMARTDEBUFF_CheckIF();
  
  --collectgarbage();
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

function SmartDebuffOFSlider_OnLoad(low, high, step)
  if (this:GetOrientation() ~= "VERTICAL") then
    getglobal(this:GetName().."Low"):SetText(low);
  else
    getglobal(this:GetName().."Low"):SetText("");
  end
  getglobal(this:GetName().."High"):SetText(high);
	this:SetMinMaxValues(low, high);
	this:SetValueStep(step);
end
-- END Bool helper functions


-- IsFeignDeath(unit)
--local ifd_name, ifd_icon, ifd_i;
function SMARTDEBUFF_IsFeignDeath(unit)
  return UnitIsFeignDeath(unit);
  --[[
	for ifd_i = 1, 32, 1 do
		ifd_name, _, ifd_icon = UnitBuff(unit, ifd_i);
		if (ifd_icon) then
			if (string.find(string.lower(ifd_icon), "feigndeath")) then
				return true;
			end
		else
			break;
		end
	end
  return false;
  ]]--
end
-- END SMARTDEBUFF_IsFeignDeath


-- Get Spell ID from spellbook
function SMARTDEBUFF_GetSpellID(spellname)
	if (spellname) then 
	  spellname = string.lower(spellname);
	else
	  return nil;
	end
	
	local i = 0;
	local id = nil;
	local spellN;
	while true do
	  i = i + 1;
   	spellN = GetSpellName(i, SMARTDEBUFF_BOOK_TYPE_SPELL);
   	if (not spellN or string.lower(spellN) == spellname) then
   	  break;
   	end   	
	end
	while (spellN ~= nil) do
	  id = i;
	  i = i + 1;
   	spellN = GetSpellName(i, SMARTDEBUFF_BOOK_TYPE_SPELL);
	  if (not spellN or string.lower(spellN) ~= spellname) then 
		  break;
		end
	end	
	return id;
end
-- END SMARTDEBUFF_GetSpellID


function SMARTDEBUFF_SetSpells()
  local i = 1;
  cSpells = nil;
  sHeal1 = nil;
  
  -- TOCHANGE
  cSpells = {};
  cHeals = {};
  cActionName = { "-", "target", "trade", "wisper", "-" };
  
  canDebuff = true;
  -- check debuff spells
  if (sPlayerClass == "DRUID") then
    cSpells = {};
    canDebuff = true;

    -- Cure Poison / Abolish Poison
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_CUREPOISON)) then
      table.insert(cActionName, SMARTDEBUFF_CUREPOISON);
      cSpells[SMARTDEBUFF_POISON] = {SMARTDEBUFF_CUREPOISON, i};
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. SMARTDEBUFF_CUREPOISON);
    end
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_ABOLISHPOISON)) then
      table.insert(cActionName, SMARTDEBUFF_ABOLISHPOISON);
      cSpells[SMARTDEBUFF_POISON] = {SMARTDEBUFF_ABOLISHPOISON, i};
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. SMARTDEBUFF_ABOLISHPOISON);
    end
    i = i + 1;
    
    --Remove Curse
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_REMOVECURSE)) then
      table.insert(cActionName, SMARTDEBUFF_REMOVECURSE);
      cSpells[SMARTDEBUFF_CURSE] = {SMARTDEBUFF_REMOVECURSE, i};
      SMARTDEBUFF_AddMsgD("Debuff spell found: " .. SMARTDEBUFF_REMOVECURSE);
    end
    i = i + 1;
    
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_REJUVENATION)) then
      table.insert(cActionName, SMARTDEBUFF_REJUVENATION);
      cHeals[SMARTDEBUFF_HEAL] = {SMARTDEBUFF_REJUVENATION, 1};
      SMARTDEBUFF_AddMsgD("Heal spell found: " .. SMARTDEBUFF_REJUVENATION);
      sHeal1 = SMARTDEBUFF_REJUVENATION;
    end
    
  elseif (sPlayerClass == "PRIEST") then
    cSpells = {};
    canDebuff = true;
    
    -- Cure Disease / Abolish Disease
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_CUREDISEASE)) then
      table.insert(cActionName, SMARTDEBUFF_CUREDISEASE);
      cSpells[SMARTDEBUFF_DISEASE] = {SMARTDEBUFF_CUREDISEASE, i};
    end
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_ABOLISHDISEASE)) then
      table.insert(cActionName, SMARTDEBUFF_ABOLISHDISEASE);
      cSpells[SMARTDEBUFF_DISEASE] = {SMARTDEBUFF_ABOLISHDISEASE, i};
    end
    i = i + 1;
    
    --Dispel Magic
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_DISPELLMAGIC)) then
      table.insert(cActionName, SMARTDEBUFF_DISPELLMAGIC);
      cSpells[SMARTDEBUFF_MAGIC] = {SMARTDEBUFF_DISPELLMAGIC, i};
    end
    
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_RENEW)) then
      table.insert(cActionName, SMARTDEBUFF_RENEW);
      cHeals[SMARTDEBUFF_HEAL] = {SMARTDEBUFF_RENEW, 1};
      sHeal1 = SMARTDEBUFF_RENEW;
    end    
    
    --cSpells[SMARTDEBUFF_MAGIC] = SMARTDEBUFF_DISPELLMAGIC;
    --canDebuffEnemyMagic = true;
  elseif (sPlayerClass == "MAGE") then
    cSpells = {};
    canDebuff = true;
    
    -- Remove Lesser Curse
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_REMOVELESSERCURSE)) then
      table.insert(cActionName, SMARTDEBUFF_REMOVELESSERCURSE);
      cSpells[SMARTDEBUFF_CURSE] = {SMARTDEBUFF_REMOVELESSERCURSE, i};
    end
    i = i + 1;    
    
    -- Polymorph
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_POLYMORPH)) then
      table.insert(cActionName, SMARTDEBUFF_POLYMORPH);
      cSpells[SMARTDEBUFF_CHARMED] = {SMARTDEBUFF_POLYMORPH, i};
    end
  elseif (sPlayerClass == "PALADIN") then
    cSpells = {};
    canDebuff = true;
    
    -- Purify (Disease, Poison)
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_PURIFY)) then
      table.insert(cActionName, SMARTDEBUFF_PURIFY);
      cSpells[SMARTDEBUFF_DISEASE] = {SMARTDEBUFF_PURIFY, i};
      cSpells[SMARTDEBUFF_POISON] = {SMARTDEBUFF_PURIFY, i};
    end
    
    --Cleanse (Disease, Poison, Magic)
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_CLEANSE)) then
      table.insert(cActionName, SMARTDEBUFF_CLEANSE);
      cSpells[SMARTDEBUFF_DISEASE] = {SMARTDEBUFF_CLEANSE, i};
      cSpells[SMARTDEBUFF_POISON] = {SMARTDEBUFF_CLEANSE, i};    
      cSpells[SMARTDEBUFF_MAGIC] = {SMARTDEBUFF_CLEANSE, i};
    end
    
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_FLASHOFLIGHT)) then
      table.insert(cActionName, SMARTDEBUFF_FLASHOFLIGHT);
      cHeals[SMARTDEBUFF_HEAL] = {SMARTDEBUFF_FLASHOFLIGHT, 1};
      sHeal1 = SMARTDEBUFF_FLASHOFLIGHT;
    end     
  elseif (sPlayerClass == "SHAMAN") then
    cSpells = {};
    canDebuff = true;
    
    -- Cure Poison / Abolish Poison
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_CUREPOISON)) then
      table.insert(cActionName, SMARTDEBUFF_CUREPOISON);
      cSpells[SMARTDEBUFF_POISON] = {SMARTDEBUFF_CUREPOISON, i};
    end
    --if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_ABOLISHPOISON)) then
    --  table.insert(cActionName, SMARTDEBUFF_ABOLISHPOISON);
    --  cSpells[SMARTDEBUFF_POISON] = {SMARTDEBUFF_ABOLISHPOISON, i};
    --end
	i = i + 1;
	
    -- Cure Disease / Abolish Disease
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_CUREDISEASE)) then
      table.insert(cActionName, SMARTDEBUFF_CUREDISEASE);
      cSpells[SMARTDEBUFF_DISEASE] = {SMARTDEBUFF_CUREDISEASE, i};
    end
    --if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_ABOLISHDISEASE)) then
    --  table.insert(cActionName, SMARTDEBUFF_ABOLISHDISEASE);
    --  cSpells[SMARTDEBUFF_DISEASE] = {SMARTDEBUFF_ABOLISHDISEASE, i}; 
    --end
    
    if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_LESSERHEALINGWAVE)) then
      table.insert(cActionName, SMARTDEBUFF_LESSERHEALINGWAVE);
      cHeals[SMARTDEBUFF_HEAL] = {SMARTDEBUFF_LESSERHEALINGWAVE, 1};
      sHeal1 = SMARTDEBUFF_LESSERHEALINGWAVE;
    end
    --Purge
    --cSpells[SMARTDEBUFF_MAGIC] = SMARTDEBUFF_PURGE;
  
  elseif (sPlayerClass == "WARLOCK") then
    cSpells = {};
    canDebuff = true;
    
    -- Purify (Disease, Poison)
    --if (SMARTDEBUFF_GetSpellID(SMARTDEBUFF_PURIFY)) then
      table.insert(cActionName, SMARTDEBUFF_PET_FELHUNTER);
      cSpells[SMARTDEBUFF_MAGIC] = {SMARTDEBUFF_PET_FELHUNTER, i};
    --end
       
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
  if (SMARTDEBUFF_Options.SFPosX == nil) then	SMARTDEBUFF_Options.SFPosX = 400; end
  if (SMARTDEBUFF_Options.SFPosY == nil) then	SMARTDEBUFF_Options.SFPosY = -300; end
  
  if (SMARTDEBUFF_Options.OrderClass == nil) then	SMARTDEBUFF_Options.OrderClass = cOrderClass; end
  if (SMARTDEBUFF_Options.OrderGrp == nil) then	SMARTDEBUFF_Options.OrderGrp = cOrderGrp; end
  
	if (SMARTDEBUFF_Options.Toggle == nil) then	SMARTDEBUFF_Options.Toggle = true; end
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
  if (SMARTDEBUFF_Options.ShowHealRange == nil) then SMARTDEBUFF_Options.ShowHealRange = false; end
  if (SMARTDEBUFF_Options.CheckInterval == nil) then SMARTDEBUFF_Options.CheckInterval = 0.5; end
  if (SMARTDEBUFF_Options.ShowBackdrop == nil) then SMARTDEBUFF_Options.ShowBackdrop = true; end
      
  if (not SMARTDEBUFF_Options.AddList) then SMARTDEBUFF_Options.AddList = { }; end
  if (not SMARTDEBUFF_Options.IgnoreList) then SMARTDEBUFF_Options.IgnoreList = { }; end
  
  if (SMARTDEBUFF_Options.ShowMsgNormal == nil) then SMARTDEBUFF_Options.ShowMsgNormal = true; end
  if (SMARTDEBUFF_Options.ShowMsgError == nil) then SMARTDEBUFF_Options.ShowMsgError = true; end
  if (SMARTDEBUFF_Options.ShowMsgWarning == nil) then SMARTDEBUFF_Options.ShowMsgWarning = true; end
	  
  if (SMARTDEBUFF_Options.FirstStart == nil) then SMARTDEBUFF_Options.FirstStart = "V0";	end
  if (SMARTDEBUFF_Options.Debug == nil) then SMARTDEBUFF_Options.Debug = false;	end
  
  if (SMARTDEBUFF_Options.Keys == nil) then
    SMARTDEBUFF_Options.Keys = { };
    SMARTDEBUFF_SetDefaultKeys(1);
    SMARTDEBUFF_SetDefaultKeys(2);
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
  
	SMARTDEBUFF_AddMsg(SMARTDEBUFF_VERS_TITLE .. " " .. SMARTDEBUFF_MSG_LOADED, true);
  SMARTDEBUFF_AddMsg("/sdb - " .. SMARTDEBUFF_MSG_SDB, true);
	isInit = true;  
	
	if (SMARTDEBUFF_Options.FirstStart ~= SMARTDEBUFF_VERSION) then
	  SMARTDEBUFF_Options.FirstStart = SMARTDEBUFF_VERSION;
	  SMARTDEBUFF_ToggleOF();
	end
  SMARTDEBUFF_CheckWarlockPet();
  SMARTDEBUFF_CheckSF();
  SMARTDEBUFF_SetUnits();
end
-- END SMARTDEBUFF_Options_Init


function SMARTDEBUFF_SetDefaultKeys(mode)
  -- normal mode
  if (mode == 1) then
    SMARTDEBUFF_Options.Keys[mode] = {["L"]  = "debuff1",
                                      ["R"]  = "debuff2",
                                      ["M"]  = "-",
                                      ["SL"] = "target",
                                      ["SR"] = "-",
                                      ["SM"] = "-",
                                      ["AL"] = "heal1",
                                      ["AR"] = "-",
                                      ["AM"] = "-",
                                      ["CL"] = "-",
                                      ["CR"] = "-",
                                      ["CM"] = "-"
                                      };
  -- target mode
  elseif (mode == 2) then
    SMARTDEBUFF_Options.Keys[mode] = {["L"]  = "target",
                                      ["R"]  = "heal1",
                                      ["M"]  = "-",
                                      ["SL"] = "-",
                                      ["SR"] = "-",
                                      ["SM"] = "-",
                                      ["AL"] = "debuff1",
                                      ["AR"] = "debuff2",
                                      ["AM"] = "-",
                                      ["CL"] = "-",
                                      ["CR"] = "-",
                                      ["CM"] = "-"
                                      };
  end
end


function SMARTDEBUFF_SetFonts()
  local h = SMARTDEBUFF_Options.BtnH / 4 + 4;
  if (h < 9) then h = 9; end
  fiMain:SetFont("FRIZQT__.TTF", h, "OUTLINE, MONOCHROME");
  fiInfo:SetFont("FRIZQT__.TTF", h-1, "OUTLINE, MONOCHROME");
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


-- Playerlist functions ---------------------------------------------------------------------------------------
--[[
function SmartBuff_PlayerSetup_OnShow()
end

function SmartBuff_PlayerSetup_OnHide()
end

function SmartBuff_PS_GetList()
  if (iCurrentList == 1) then
    return SMARTBUFF_Options.AddList;
  else
    return SMARTBUFF_Options.IgnoreList;
  end  
end

function SmartBuff_PS_GetUnitList()
  if (iCurrentList == 1) then
    return cAddUnitList;
  else
    return cIgnoreUnitList;
  end
end

function SmartBuff_UnitIsAdd(unit)
  local b = false;
  if (unit and cAddUnitList[unit]) then
    b = true;
  end
  return b;
end

function SmartBuff_UnitIsIgnored(unit)
  local b = false;
  if (unit and cIgnoreUnitList[unit]) then
    b = true;
  end
  return b;
end

function SmartBuff_PS_Show(i)
  iCurrentList = i;
  iLastPlayer = -1;
  local obj = SmartBuff_PlayerSetup_Title;
  if (iCurrentList == 1) then
    obj:SetText("Additional list");
  else
    obj:SetText("Ignore list");
  end
  obj:ClearFocus();
  SmartBuff_PlayerSetup_EditBox:ClearFocus();
  SmartBuff_PlayerSetup:Show();
  SmartBuff_PS_SelectPlayer(0);  
end

function SmartBuff_PS_AddPlayer()
  local cList = SmartBuff_PS_GetList();
  local un = UnitName("target");
  if (un and not UnitIsUnit("player", "target") and UnitIsPlayer("target") and (UnitInRaid("target") or UnitInParty("target") or SMARTBUFF_Options.Debug)) then
	  if (not cList[un]) then
	    cList[un] = true;
      SmartBuff_PS_SelectPlayer(0);    
    end
  end
end

function SmartBuff_PS_RemovePlayer()
  local n = 0;
  local cList = SmartBuff_PS_GetList();
  for player in pairs(cList) do
    n = n + 1;
    if (n == iLastPlayer) then
      cList[player] = nil;
      break;
    end
  end  
  SmartBuff_PS_SelectPlayer(0);  
end

function SmartBuff_AddToUnitList(idx, unit, subgroup)
  iCurrentList = idx;
  local cList = SmartBuff_PS_GetList();
  local cUnitList = SmartBuff_PS_GetUnitList(); 
  if (unit and subgroup) then
    local un = UnitName(unit);
    if (un and cList[un]) then
      cUnitList[unit] = subgroup;
      --SMARTDEBUFF_AddMsgD("Added to UnitList:" .. un .. "(" .. unit .. ")");
    end
  end
end

function SmartBuff_PS_SelectPlayer(iOp)
  local idx = iLastPlayer + iOp;
  local cList = SmartBuff_PS_GetList();
  local s = "";
  
  local tn = 0;
  for player in pairs(cList) do
    tn = tn + 1;
    s = s .. player .. "\n";
  end
  
  -- update list in textbox
  if (iOp == 0) then
	  SmartBuff_PlayerSetup_EditBox:SetText(s);
	  --SmartBuff_PlayerSetup_EditBox:ClearFocus();
	end
  
  -- highlight selected player
  if (tn > 0) then
    if (idx > tn) then idx = tn; end
    if (idx < 1)  then idx = 1; end
    iLastPlayer = idx;
    --SmartBuff_PlayerSetup_EditBox:ClearFocus();
    local n = 0;
    local i = 0;
    local w = 0;
	  for player in pairs(cList) do
	    n = n + 1;
	    w = string.len(player);
	    if (n == idx) then
	      SmartBuff_PlayerSetup_EditBox:HighlightText(i + n - 1, i + n + w);
	      break;
	    end
	    i = i + w;
	  end
	end
end

function SmartBuff_PS_Resize()
  local h = SmartBuffOptionsFrame:GetHeight();
  local b = true;
  
  if (h < 200) then
    SmartBuffOptionsFrame:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
    --SmartBuff_BuffSetup:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
    b = true;
  else
    SmartBuffOptionsFrame:SetHeight(40);
    --SmartBuff_BuffSetup:SetHeight(40);
    b = false;
  end
  SmartBuff_ShowControls("SmartBuffOptionsFrame", b); 
  if (b) then
    SMARTBUFF_SetCheckButtonBuffs(1);
  end
end
]]--
-- END Playerlist functions




-- SmartDebuff frame functions

function SMARTDEBUFF_ToggleSF()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
  
  SMARTDEBUFF_Options.ShowSF = not SMARTDEBUFF_Options.ShowSF;
  SMARTDEBUFF_CheckSF();
  
  if (IsAddOnLoaded("SmartBuff") and SmartBuffOptionsFrame:IsVisible()) then
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
end

function SMARTDEBUFF_CheckSFButtons(hide)
  if (SmartDebuffSF:IsVisible()) then
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
  if (not SMARTDEBUFF_Options.ShowIF or not SmartDebuffSF:IsVisible() or iGroupSetup <= 1) then
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
      
      button:EnableMouse(true);
      --button:EnableMouseWheel(true);
      button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
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
      
      button:EnableMouse(true);
      button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
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
end

function SMARTDEBUFF_SetButtons()
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
  
  local i, j;
  -- reset all buttons
  for i = 1, maxRaid, 1 do
    SMARTDEBUFF_SetButton(nil, i, nil, nil, nil);
  end
  
  local spell1 = nil;
  local spell2 = nil;
  if (cSpells) then
    for debuff in pairs(cSpells) do
      if (debuff) then
        if (cSpells[debuff][2] == 1) then
          spell1 = cSpells[debuff][1];
          SMARTDEBUFF_AddMsgD("Set spell 1: " .. spell1);
        elseif (cSpells[debuff][2] == 2) then
          spell2 = cSpells[debuff][1];
          SMARTDEBUFF_AddMsgD("Set spell 2: " .. spell2);
        end
      end
    end
  else
    return;
  end
  
  local heal1 = nil;
  if (cHeals[SMARTDEBUFF_HEAL]) then
    heal1 = cHeals[SMARTDEBUFF_HEAL][1];
  end
  
  i = 1;
  local cl, data, unit, uc;
  if (SMARTDEBUFF_Options.SortedByClass) then
    for j, cl in ipairs(SMARTDEBUFF_Options.OrderClass) do
      if (cClasses[cl] and SMARTDEBUFF_Options.DebuffClasses[cl]) then
        for _, data in pairs(cClasses[cl]) do
          if (data and UnitExists(data.Unit) and SMARTDEBUFF_Options.DebuffGrp[data.Subgroup]) then
            SMARTDEBUFF_SetButton(data.Unit, i, spell1, spell2, heal1);
            i = i + 1;
          end
        end
      end
    end
  else
    --for cl = 1, 8, 1 do
    for j, cl in ipairs(SMARTDEBUFF_Options.OrderGrp) do
      if (cGroups[cl] and SMARTDEBUFF_Options.DebuffGrp[cl]) then
        for _, data in pairs(cGroups[cl]) do
          if (data and UnitExists(data.Unit)) then
            _, uc = UnitClass(data.Unit);
            if (uc and SMARTDEBUFF_Options.DebuffClasses[uc]) then
              SMARTDEBUFF_SetButton(data.Unit, i, spell1, spell2, heal1);
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
  
  SMARTDEBUFF_SetPetButtons(spell1, spell2, heal1);  
  SMARTDEBUFF_SetStyle();
end

function SMARTDEBUFF_SetPetButtons(spell1, spell2, heal1)
  if (not isInit or not canDebuff or InCombatLockdown()) then return; end
    
  local i;
  local b = false;
  -- reset all buttons
  for i = 1, maxPets, 1 do
    SMARTDEBUFF_SetButton(nil, i, nil, nil, nil, 1);
  end
  
  if (not spell1 and not spell2) then
    b = true;
    if (cSpells) then
      for debuff in pairs(cSpells) do
        if (debuff) then
          if (cSpells[debuff][2] == 1) then
            spell1 = cSpells[debuff][1];
            SMARTDEBUFF_AddMsgD("Set spell 1: " .. spell1);
          elseif (cSpells[debuff][2] == 2) then
            spell2 = cSpells[debuff][1];
            SMARTDEBUFF_AddMsgD("Set spell 2: " .. spell2);
          end
        end
      end
    else
      return;
    end
  end
  
  if (not heal1 and cHeals[SMARTDEBUFF_HEAL]) then
    heal1 = cHeals[SMARTDEBUFF_HEAL][1];
  end  
  
  local data;
  if (SMARTDEBUFF_Options.ShowPets or SMARTDEBUFF_Options.ShowPetsWL) then
    i = 1;
    for _, data in pairs(cPets) do
      if (data and UnitExists(data.Unit) and i <= maxPets) then
        --SMARTDEBUFF_AddMsgD("Set Pet: " .. unit .. ", " .. UnitName(unit) .. ", " .. uc);
        if (data.OwnerClass and ((data.OwnerClass == "HUNTER" and SMARTDEBUFF_Options.ShowPets) or (data.OwnerClass == "WARLOCK" and SMARTDEBUFF_Options.ShowPetsWL)) and (iGroupSetup ~= 3 or (iGroupSetup == 3 and SMARTDEBUFF_Options.DebuffGrp[data.Subgroup]))) then
          --SMARTDEBUFF_AddMsgD("Set Pet: " .. unit .. ", " .. UnitName(unit));
          SMARTDEBUFF_SetButton(data.Unit, i, spell1, spell2, heal1, 1);
          i = i + 1;
        end
      end
    end
  end

  --SMARTDEBUFF_AddMsgD("Debuff pet buttons set");
  
  if (b) then
    SMARTDEBUFF_SetStyle();
  end
end


--cActions[actionName] = { actionGrp, actionType, buttonNr, prefix};
--cActions["Magie entfernen"] = { SMARTDEBUFF_MAGIC, "spell", 1, "alt"};
--cActions["target"] = { "TARGET", "target", 1, ""};

function SMARTDEBUFF_SetButton(unit, idx, spell1, spell2, heal1, pet)
  if (not canDebuff or InCombatLockdown()) then return; end
  
  local btn;
  if (pet) then
    btn = getglobal("SmartDebuffPetBtn"..idx);
  else
    btn = getglobal("SmartDebuffBtn"..idx);
  end
  
  if (not btn) then return; end
  
  if (SMARTDEBUFF_Options.TargetMode) then
    btn:SetAttribute("unit", unit);
    btn:SetAttribute("type1", "target");    
    if (sPlayerClass == "WARLOCK") then
      btn:SetAttribute("alt-type1", "pet");
      btn:SetAttribute("alt-action1", spell1);
    else
      btn:SetAttribute("alt-type1", "spell");
      btn:SetAttribute("alt-spell1", spell1);
    end
    btn:SetAttribute("alt-type2", "spell");
    btn:SetAttribute("alt-spell2", spell2);
    btn:SetAttribute("shift-type1", nil);
    if (sHeal1) then
      btn:SetAttribute("type2", "spell");
      btn:SetAttribute("spell2", heal1);          
    else
      btn:SetAttribute("type2", "menu");
      --btn.menu = menufunc;
      btn:SetAttribute("spell2", nil);    
    end
  else
    btn:SetAttribute("unit", unit);
    
    if (sPlayerClass == "WARLOCK") then
      btn:SetAttribute("type1", "pet");
      btn:SetAttribute("action1", spell1);
    else
      btn:SetAttribute("type1", "spell");
      btn:SetAttribute("spell1", spell1);
    end
    
    btn:SetAttribute("type2", "spell");
    btn:SetAttribute("spell2", spell2);
    
    btn:SetAttribute("alt-type1", "spell");
    btn:SetAttribute("alt-spell1", heal1);
    btn:SetAttribute("alt-type2", nil);
    btn:SetAttribute("alt-spell2", nil);
    btn:SetAttribute("shift-type1", "target");
  end
  
  if (unit) then
    btn:SetAlpha(0.5);
    btn:Show();
  else
    btn:SetAlpha(0.1);
    btn:Hide();
  end
end

local sbs_btn, sbs_un, sbs_uc, sbs_st, sbs_fontH, sbs_pre, sbs_ln, sbs_wd;
local sbs_col = { r = 0.39, g = 0.42, b = 0.64 };
function SMARTDEBUFF_SetButtonState(unit, idx, nr, ir, pet)
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
    if (UnitIsDeadOrGhost(unit) or UnitIsConnected(unit) == nil or not UnitIsConnected(unit)) then
      if (UnitIsConnected(unit) == nil or not UnitIsConnected(unit)) then
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
 
  if (nr == 0) then
    sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 0.6);
    if (ir == 1) then
      sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormal);
    else
      sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormalOOR);
    end
  elseif (nr == 1) then
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
    sbs_btn:SetAlpha(SMARTDEBUFF_Options.ADebuff);
    if (SMARTDEBUFF_Options.ShowLR) then
      sbs_fontH = SMARTDEBUFF_Options.BtnH - 2;
    end
  else
    sbs_btn.texture:SetTexture(sbs_col.r, sbs_col.g, sbs_col.b, 0.6);
    sbs_btn:SetAlpha(SMARTDEBUFF_Options.ANormalOOR);
  end
  
  sbs_btn:SetFont("Fonts\\FRIZQT__.TTF", sbs_fontH);  
  sbs_btn:SetText(sbs_st);
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
    
    if (sHeal1 and SMARTDEBUFF_Options.ShowHealRange and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit)) then
      if (IsSpellInRange(sHeal1, unit) == 1) then
        btn:SetBackdropBorderColor(0, 0, 0, 0);
      else
        btn:SetBackdropBorderColor(1, 0, 0, 1);
      end
    else
      btn:SetBackdropBorderColor(0, 0, 0, 0);
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
        sbb_col.r = 0; sbb_col.g = 0; sbb_col.b = 1;
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
  if (not frame:IsVisible()) then return; end;
  
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
    sbtn = SecureStateChild_GetEffectiveButton(btn);
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

function SMARTDEBUFF_ButtonTooltipOnEnter()
  if (not this or not this:IsVisible() or InCombatLockdown() or not SMARTDEBUFF_Options.ShowTooltip) then return; end
  
  local sbtn = SecureStateChild_GetEffectiveButton(this);
  local unit = SecureButton_GetModifiedAttribute(this, "unit", sbtn, "");
  if (unit) then
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
    GameTooltip:SetUnit(unit);
    GameTooltip:Show();
  end
end

function SMARTDEBUFF_ButtonTooltipOnLeave()
  GameTooltip:Hide();
end

-- END SmartDebuff frame functions


-- SmartDebuff functions
-- Main check function, called by update event
local cd_i, cd_unit, cd_btn, cd_sbtn, cd_spell;
function SMARTDEBUFF_CheckDebuffs(force)
  if (not isInit or not canDebuff or (not force and GetTime() < tDebuff + SMARTDEBUFF_Options.CheckInterval)) then
    return;
  end 
  tDebuff = GetTime();  
  hasDebuff = false;

  if (SmartDebuffSF:IsVisible() and cSpells) then    
    --SMARTDEBUFF_AddMsgD(string.format("Debuff check (%.1f): %.2f", SMARTDEBUFF_Options.CheckInterval, tDebuff));
    
    iTotMana = 0;
    iTotHP = 0;
    iTotAFK = 0;
    iTotOFF = 0;
    iTotDead = 0;
    iTotPlayers = 0;
    iTotManaUser = 0;    
    
    for cd_i = 1, maxRaid, 1 do
      cd_btn = getglobal("SmartDebuffBtn"..cd_i);
      cd_sbtn = SecureStateChild_GetEffectiveButton(cd_btn);
      if (cd_sbtn) then
        cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
        if (SMARTDEBUFF_Options.TargetMode) then
          if (sPlayerClass == "WARLOCK") then
            cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "alt-action1", cd_sbtn, "");
          else
            cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "alt-spell1", cd_sbtn, "");
          end
        else
          if (sPlayerClass == "WARLOCK") then
            cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "action1", cd_sbtn, "");
          else       
            cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "spell1", cd_sbtn, "");
          end
        end
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
        cd_sbtn = SecureStateChild_GetEffectiveButton(cd_btn);
        if (cd_sbtn) then
          cd_unit = SecureButton_GetModifiedAttribute(cd_btn, "unit", cd_sbtn, "");
          if (SMARTDEBUFF_Options.TargetMode) then
            if (sPlayerClass == "WARLOCK") then
              cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "alt-action1", cd_sbtn, "");
            else
              cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "alt-spell1", cd_sbtn, "");
            end
          else
            if (sPlayerClass == "WARLOCK") then
              cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "action1", cd_sbtn, "");
            else       
              cd_spell = SecureButton_GetModifiedAttribute(cd_btn, "spell1", cd_sbtn, "");
            end
          end
          if (cd_unit and UnitExists(cd_unit)) then
            --SMARTDEBUFF_AddMsgD("Pet found: " .. unit .. ", " .. UnitName(unit) .. ", " .. i);
            SMARTDEBUFF_CheckUnitDebuffs(cd_spell, cd_unit, cd_i, isSpellActive, 1);
          end
        end
      end
    end    
    
    --SMARTDEBUFF_AddMsgD("Debuffs checked");
  end
  if (not hasDebuff) then
    isSoundPlayed = false;
  end
end

-- Dectects debuffs on a single unit
local cud_name, cud_icon, cud_dtype, cud_uclass, cud_ir, cud_n;
function SMARTDEBUFF_CheckUnitDebuffs(spell, unit, idx, isActive, pet)  
  --local name, dtype, uclass, ir;
  
  if (spell and isActive) then
    if (IsSpellInRange(spell, unit) == 1 or (sPlayerClass == "WARLOCK" and type(spell) == "number" and IsSpellInRange(SMARTDEBUFF_UNENDINGBREATH, unit) == 1)) then
      cud_ir = 1;
    else
      cud_ir = 0;
    end
    --SMARTDEBUFF_AddMsgD("Check unit: " .. unit .. ", " .. UnitName(unit) .. ", " .. idx);

    cud_n = 1;
    while (true) do
      --name,rank,icon,count,type = UnitDebuff("unit", id or "name"[,"rank"])
      cud_name, _, cud_icon, _, cud_dtype = UnitDebuff(unit, cud_n);
      
      if (not cud_icon) then
        break;
      end
      
      if (cud_name and cud_dtype) then
        --SMARTDEBUFF_AddMsgD("Debuff found: " .. name .. ", " .. cud_dtype);
        _, cud_uclass = UnitClass(unit);
        if (cSpells[cud_dtype] and not UnitCanAttack("player", unit) and not SMARTDEBUFF_DEBUFFSKIPLIST[cud_name] and not (SMARTDEBUFF_DEBUFFCLASSSKIPLIST[cud_uclass] and SMARTDEBUFF_DEBUFFCLASSSKIPLIST[cud_uclass][cud_name])) then
          hasDebuff = true;
          SMARTDEBUFF_SetButtonState(unit, idx, cSpells[cud_dtype][2], cud_ir, pet);
          SMARTDEBUFF_PlaySound();
          return;
        end
      end

      cud_n = cud_n + 1;
      --SMARTDEBUFF_AddMsgD("Check debuff");
    end
    
    -- check if a player is charmed, can be attacked and is polymorphable
    if (cSpells[SMARTDEBUFF_CHARMED] and UnitIsCharmed(unit) and UnitCanAttack("player", unit) and UnitCreatureType(unit) == SMARTDEBUFF_HUMANOID) then
      hasDebuff = true;
      SMARTDEBUFF_SetButtonState(unit, idx, cSpells[SMARTDEBUFF_CHARMED][2], cud_ir, pet);
      SMARTDEBUFF_PlaySound();
      return;
    end      
      
    SMARTDEBUFF_SetButtonState(unit, idx, 0, cud_ir, pet);
  else
    SMARTDEBUFF_SetButtonState(unit, idx, -1, 0, pet);
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
end

function SMARTDEBUFF_OFOnHide()
end



function SMARTDEBUFF_SetOrderItem(control, cTable, idx)
  local s = "";  
  local tn = 0;
  for _, data in ipairs(cTable) do
    tn = tn + 1;
    s = s .. SMARTDEBUFF_CLASSES[data] .. "\n";
  end
  control:SetText(s);
    
  -- highlight selected player
  if (idx > tn) then idx = tn; end
  if (idx < 1)  then idx = 1; end
  local n = 0;
  local i = 0;
  local w = 0;
	for _, data in ipairs(cTable) do
	  n = n + 1;
	  w = string.len(SMARTDEBUFF_CLASSES[data]);
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

function SMARTDEBUFF_OrderOnShow()
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
  SMARTDEBUFF_SetOrderItem(SmartDebuff_txtScrollFrame, SMARTDEBUFF_Options.OrderClass, n);
end

function SMARTDEBUFF_MoveClassOrder(iOp)
  local n = SMARTDEBUFF_MoveOrderItem(SMARTDEBUFF_Options.OrderClass, iOp);
  SMARTDEBUFF_SetOrderItem(SmartDebuff_txtScrollFrame, SMARTDEBUFF_Options.OrderClass, n);
end



local currentKey = "";
local currentKeyMode = 1;
function SMARTDEBUFF_ToggleAOFKeys(mode)
  currentKeyMode = mode;
  if (SmartDebuffAOFKeys:IsVisible()) then
    SmartDebuffAOFKeys:Hide();
  else
    currentKey = "L";
    SmartDebuffAOFKeys:Show();
    SMARTDEBUFF_ShowKeys();
  end
end


function SMARTDEBUFF_ddKeys_OnShow(self)
  local i = 1;
  local n = 0;
	for _, k in ipairs(cOrderKeys) do
	  n = n + 1;
    --SMARTDEBUFF_AddMsgD(i .. "." .. tmp);
	  if (k == currentKey) then
	    i = n;
	    break;
	  end
	end
	currentKey = cOrderKeys[i];
	UIDropDownMenu_Initialize(self, SMARTDEBUFF_ddKeys_Initialize);
	UIDropDownMenu_SetSelectedID(self, i);
  --UIDropDownMenu_SetWidth(135);
  
  SMARTDEBUFF_ddActions_Set();
end

function SMARTDEBUFF_ddKeys_Initialize()
	for _, k in ipairs(cOrderKeys) do
		local info = {};
		info.text = SMARTDEBUFF_KEYS[k];
		info.func = SMARTDEBUFF_ddKeys_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function SMARTDEBUFF_ddKeys_OnClick()
  local i = this:GetID();
  local tmp = nil;
	UIDropDownMenu_SetSelectedID(this, i);
  local n = 0;
	for _, k in pairs(cOrderKeys) do
	  n = n + 1;
	  if (n == i) then
	    currentKey = k;
	    SMARTDEBUFF_ddActions_Set();
	    break;
	  end
	end	
end


function SMARTDEBUFF_ddActions_Set()
  local i = 1;
  local n = 0;
	for k, v in pairs(cActionName) do
	  n = n + 1;
    --SMARTDEBUFF_AddMsgD(i .. "." .. tmp);
	  if (SMARTDEBUFF_Options.Keys[currentKeyMode][currentKey] == v) then
	    i = n;
	    break;
	  end
	end
	SMARTDEBUFF_Options.Keys[currentKeyMode][currentKey] = cActionName[i];
	UIDropDownMenu_SetSelectedID(SmartDebuffAOFKeys_ddActions, i);
end

function SMARTDEBUFF_ddActions_OnShow(self)
	UIDropDownMenu_Initialize(self, SMARTDEBUFF_ddActions_Initialize);
	--UIDropDownMenu_SetSelectedID(self, i);
  --UIDropDownMenu_SetWidth(135);
end

function SMARTDEBUFF_ddActions_Initialize()
	for i in ipairs(cActionName) do
		local info = {};
		info.text = cActionName[i];
		info.func = SMARTDEBUFF_ddActions_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function SMARTDEBUFF_ddActions_OnClick()
  local i = this:GetID();
	UIDropDownMenu_SetSelectedID(this, i);
  local n = 0;
	for k, v in pairs(cActionName) do
	  n = n + 1;
	  if (n == i) then
	    SMARTDEBUFF_Options.Keys[currentKeyMode][currentKey] = v;
	    break;
	  end
	end
	SMARTDEBUFF_ShowKeys();
end

function SMARTDEBUFF_ShowKeys()
	local s = "";
	for k, v in pairs(SMARTDEBUFF_Options.Keys[currentKeyMode]) do
    s = s .. SMARTDEBUFF_KEYS[k] .. ": " .. v .. "\n";
	end
	SmartDebuffAOFKeys_txtOut:SetText(s);
end



