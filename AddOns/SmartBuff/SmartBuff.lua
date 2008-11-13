-------------------------------------------------------------------------------
-- SmartBuff
-- Created by Aeldra (EU-Proudmoore)
--
-- Cast the most important buffs on you or party/raid members/pets.
-------------------------------------------------------------------------------

SMARTBUFF_VERSION       = "v2.3a";
SMARTBUFF_TITLE         = "SmartBuff";
SMARTBUFF_SUBTITLE      = "Supports you in cast buffs";
SMARTBUFF_DESC          = "Cast the most important buffs on you or party/raid members/pets";
SMARTBUFF_VERS_TITLE    = SMARTBUFF_TITLE .. " " .. SMARTBUFF_VERSION;
SMARTBUFF_OPTIONS_TITLE = SMARTBUFF_VERS_TITLE .. " Options";

BINDING_HEADER_SMARTBUFF = "SmartBuff";
SMARTBUFF_BOOK_TYPE_SPELL = "spell";

local GlobalCd = 1.6;
local maxSkipCoolDown = 3;
local maxRaid = 40;
local maxBuffs = 36;
local maxCheckButtons = 28;
local numBuffs = 0;


local isLoaded = false;
local isPlayer = false;
local isInit = false;
local isCombat = false;
local isSetBuffs = false;
local isSetZone = false;
local isFirstError = false;
local isMounted = false;
local isCTRA = true;
local isSetUnits = false;
local isKeyUpChanged = false;
local isKeyDownChanged = false;
local isAuraChanged = false;
local isClearSplash = false;

local isShapeshifted = false;
local sShapename = "";

local tStart = 0;
local tStartZone = 0;
local tTicker = 0;

local sRealmName = nil;
local sPlayerName = nil;
local sID = nil;
local sPlayerClass = nil;
local iLastSubgroup = 0;
local tLastCheck = 0;
local iGroupSetup = -1;
local cPatterns = nil;
local iLastBuffSetup = -1;
local sLastTexture = "";
local iLastGroupSetup = -99;
local sLastInstance = "";
local tAutoBuff = 0;
local tDebuff = 0;
local sMsgWarning = "";
local iCurrentFont = 1;
local iCurrentList = -1;
local iLastPlayer = -1;

local cGroups = { };
local cClassGroups = { };
local cBuffs = { };
local cBuffIndex = { };
local cBuffTimer = { };
local cBlacklist = { };
local cUnits = { };
local cBuffsCombat = { };

local cAddUnitList = { };
local cIgnoreUnitList = { };

local cClasses       = {"DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR", "HPET", "WPET"};
local cOrderClass    = {0, "WARRIOR", "PRIEST", "DRUID", "PALADIN", "SHAMAN", "MAGE", "WARLOCK", "HUNTER", "ROGUE", "HPET", "WPET"};
local cOrderGrp      = {0, 1, 2 , 3, 4 , 5 , 6, 7, 8};
local cFonts         = {"NumberFontNormal", "NumberFontNormalLarge", "NumberFontNormalHuge", "GameFontNormal", "GameFontNormalLarge", "GameFontNormalHuge", "ChatFontNormal", "SystemFont", "MailTextFontNormal", "QuestTitleFont"};

local currentUnit = nil;
local currentSpell = nil;
local currentTemplate = nil;

local imgSB      = "Interface\\Icons\\Spell_Nature_Purge";
local imgIconOn  = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonEnabled";
local imgIconOff = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonDisabled";

local DebugChatFrame = DEFAULT_CHAT_FRAME;


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

--[[
local CastHook = function (spellname, unit)
  --local msg = "";
  --table.foreach({...}, function(k,v) msg = msg .. k .. "=[" .. tostring(v) .."] "; end);
  --DEFAULT_CHAT_FRAME:AddMessage("[Echo] " .. msg);
  if (spellname and unit) then
    DEFAULT_CHAT_FRAME:AddMessage("Spell hook: " .. spellname .. ", " .. unit);
  end;
end;

local CastSpellHook = function (...)
  local msg = "";
  table.foreach({...}, function(k,v) msg = msg .. k .. "=[" .. tostring(v) .."] "; end);
  DEFAULT_CHAT_FRAME:AddMessage("[Echo] " .. msg);
end;
]]--


-- SMARTBUFF_OnLoad
function SMARTBUFF_OnLoad()
  this:RegisterEvent("ADDON_LOADED");
  this:RegisterEvent("PLAYER_ENTERING_WORLD");
  this:RegisterEvent("UNIT_NAME_UPDATE");
  
  this:RegisterEvent("PARTY_MEMBERS_CHANGED");
  this:RegisterEvent("RAID_ROSTER_UPDATE");
  this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	--this:RegisterEvent("PLAYER_TARGET_CHANGED");
	
	this:RegisterEvent("LEARNED_SPELL_IN_TAB");
	this:RegisterEvent("ACTIONBAR_HIDEGRID");
	
  this:RegisterEvent("UNIT_AURA");
  --this:RegisterEvent("CHAT_MSG_ADDON");
  this:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");
  this:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
  --this:RegisterEvent("PLAYER_AURAS_CHANGED");
	--this:RegisterEvent("CHAT_MSG_CHANNEL");
	--this:RegisterEvent("ACTIONBAR_UPDATE_STATE");
    
  this:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER");
  --this:RegisterEvent("UI_ERROR_MESSAGE");
  this:RegisterEvent("UNIT_SPELLCAST_SENT");
  this:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  
  --One of them allows SmartBuff to be closed with the Escape key
  tinsert(UISpecialFrames, "SmartBuffOptionsFrame");
	UIPanelWindows["SmartBuffOptionsFrame"] = nil;
  
	SlashCmdList["SMARTBUFF"] = SMARTBUFF_command;
	SLASH_SMARTBUFF1 = "/sb";
	SLASH_SMARTBUFF2 = "/smartbuff";

	SlashCmdList["SMARTBUFFMENU"] = SMARTBUFF_OptionsFrame_Toggle;
	SLASH_SMARTBUFFMENU1 = "/sbm";
	
  SlashCmdList["SMARTBUFFRELOAD"] = function(msg) ReloadUI(); end;
	SLASH_SMARTBUFFRELOAD1 = "/rui";
  
	-- FuBar support
	--if (IsAddOnLoaded("FuBar")) then
  --  SMARTBUFF_FuBar_OnLoad();
	--end
  
end
-- END SMARTBUFF_OnLoad


-- SMARTBUFF_OnEvent
function SMARTBUFF_OnEvent(event)
  --DebugChatFrame:AddMessage(event);
	if ((event == "UNIT_NAME_UPDATE" and arg1 == "player") or event == "PLAYER_ENTERING_WORLD") then
		isPlayer = true;
		if  (event == "PLAYER_ENTERING_WORLD" and isInit and SMARTBUFF_Options.Toggle) then
      --SMARTBUFF_AddMsgD("Set zone");
      isSetZone = true;
      tStartZone = GetTime();
		end
  elseif(event == "ADDON_LOADED" and arg1 == SMARTBUFF_TITLE) then
    --DebugChatFrame:AddMessage("SB loaded");
    isLoaded = true;
  end
    
  if (isLoaded and isPlayer and not isInit) then
    if(tStart == 0) then
      tStart = GetTime();
      --DebugChatFrame:AddMessage("SB set start timer: " .. tStart);
      --DebugChatFrame:AddMessage("SB channel name: " .. GetChannelName(1));
    end
    if (event == "UPDATE_MOUSEOVER_UNIT" or event == "CHAT_MSG_CHANNEL_NOTICE" or (GetChannelName(1) > 0 and GetTime() > (tStart + 2)) or GetTime() > (tStart + 5)) then
      this:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE");
      this:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
      --DebugChatFrame:AddMessage("SB timer: " .. GetTime());
      --DebugChatFrame:AddMessage("SB channel name: " .. GetChannelName(1));
      SMARTBUFF_Options_Init();
    end
  end
  
  if (not isInit or SMARTBUFF_Options == nil) then
    return;
  end;
  
  if (event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE") then
    isSetUnits = true;
    
  elseif (event == "PLAYER_REGEN_DISABLED") then
    SMARTBUFF_Ticker(true);
    
    if (SMARTBUFF_Options.Toggle) then
      if (SMARTBUFF_Options.InCombat) then
        for spell, data in pairs(cBuffsCombat) do
          if (data and data.Unit and data.ActionType) then
            if (data.Type == SMARTBUFF_CONST_SELF or data.Type == SMARTBUFF_CONST_FORCESELF) then
              SmartBuff_KeyButton:SetAttribute("unit", nil);
            else
              SmartBuff_KeyButton:SetAttribute("unit", data.Unit);
            end
            SmartBuff_KeyButton:SetAttribute("type", data.ActionType);
            SmartBuff_KeyButton:SetAttribute("spell", spell);
            SmartBuff_KeyButton:SetAttribute("item", nil);
            SmartBuff_KeyButton:SetAttribute("target-slot", nil); 
            SmartBuff_KeyButton:SetAttribute("action", nil);
            SMARTBUFF_AddMsgD("Enter Combat, set button: " .. spell .. " on " .. data.Unit .. ", " .. data.ActionType);
            break;
          end
        end
      end
  	  SMARTBUFF_Check(1, true);
    end
    
  elseif (event == "PLAYER_REGEN_ENABLED") then
    SMARTBUFF_Ticker(true);
    
    if (SMARTBUFF_Options.Toggle) then
      if (SMARTBUFF_Options.InCombat) then
        SmartBuff_KeyButton:SetAttribute("type", nil);
        SmartBuff_KeyButton:SetAttribute("unit", nil);
        SmartBuff_KeyButton:SetAttribute("spell", nil);
        SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, imgSB);
        --SMARTBUFF_AddMsgD("Leave combat, reset button");
      end
      SMARTBUFF_SyncBuffTimers();
  	  SMARTBUFF_Check(1, true);
    end
  end    

  if (not SMARTBUFF_Options.Toggle) then
    return;
  end;
  
  if (event == "UNIT_AURA") then
    --[[
    if (arg1 == "player" or string.find(arg1, "^party") or string.find(arg1, "^raid") or string.find(arg1, "^pet")) then
      isAuraChanged = true;
      SMARTBUFF_AddMsgD("Aura changed: " .. arg1);
    end
    ]]--
    
    -- checks if aspect of cheetah or pack is active and cancel it if someone gets dazed
    if (sPlayerClass == "HUNTER" and SMARTBUFF_Options.AntiDaze and (arg1 == "player" or string.find(arg1, "party%d") or string.find(arg1, "pet") or string.find(arg1, "partypet%d"))) then
      SMARTBUFF_AddMsgD("Checking: " .. arg1);
      local isDazed = SMARTBUFF_IsDebuffTexture(arg1, "Spell_Frost_Stun");
      if (isDazed) then
        local _, index, buff = SMARTBUFF_CheckUnitBuffs("player", SMARTBUFF_AOTC, SMARTBUFF_AOTP, true);
        if (index) then
          if (arg1 == "player" or (buff == SMARTBUFF_AOTP and SMARTBUFF_CheckUnitBuffs(arg1, SMARTBUFF_AOTP, nil, true) == nil)) then
            --SMARTBUFF_AddMsgD(arg1 .. " is dazed, cancel " .. buff .. ", index = " .. index);
  		      CancelPlayerBuff(index);
          end
        end
      end      
    end    
  end
  
  --[[  
  elseif (event == "CHAT_MSG_ADDON" and SMARTBUFF_Options.CTRASync) then
    --Fired when the client receives a message from SendAddonMessage 
    --arg1 prefix 
    --arg2 message 
    --arg3 distribution type ("PARTY","RAID","GUILD" or "BATTLEGROUND") 
    --arg4 sender
    
    if (not isCombat and arg1 == "CTRA" and arg3 == "RAID") then
      local msg = arg2;
      local dtype = arg3;
      local sender = arg4;

      if (string.find(msg, "^RN ")) then
        --SMARTBUFF_AddMsgD(sender .. ": " .. msg);

        local bdata = false;
        local unit = nil;
        local subgroup = nil;
        local classeng = nil;
        local uname = nil;
        
        for sg = 1, 8, 1 do
          if (cGroups[sg] ~= nil) then
            for _, un in pairs(cGroups[sg]) do
              if (un and UnitIsPlayer(un) and UnitName(un) == sender) then
                _, classeng = UnitClass(un);
                subgroup = sg;
                unit = un;
                bdata = true;
                SMARTBUFF_AddMsgD(sender .. "(Grp " .. subgroup .. ", " .. unit .. ") data retrived");
                break;                
              end
            end
          end
        end        
        
        if (bdata) then
          if (string.find(msg, "#")) then
            local k = 0;
            local v = nil;
            local arr = SMARTBUFF_Split(msg, "#");
    				for _, v in pairs(arr) do
    				  k = k + 1;
              SMARTBUFF_AddMsgD(k .. ". " .. v);
              SMARTBUFF_CTRASync(unit, subgroup, classeng, v);
    				end
          else
            SMARTBUFF_AddMsgD("1. " .. msg);
            SMARTBUFF_CTRASync(unit, subgroup, classeng, msg);
          end
        end
        
      end
    end
  end
  ]]--
   
          
	--if (event == "PLAYER_TARGET_CHANGED") then
    --[[
	  if (SMARTBUFF_Options.TargetSwitch) then
      if (GetTime() > tAutoBuff + GlobalCd) then
        tAutoBuff = GetTime();
        --SMARTBUFF_Check(5);
      end
		end
    ]]--
	
	if (event == "LEARNED_SPELL_IN_TAB" or event == "ACTIONBAR_HIDEGRID") then   
    isSetBuffs = true;
  elseif (event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER") then
    SMARTBUFF_AddMsgD("Spell failed: " .. arg1);

    if (currentUnit and (string.find(currentUnit, "party") or string.find(currentUnit, "raid") or (currentUnit == "target" and SMARTBUFF_Options.Debug))) then
      if (UnitName(currentUnit) ~= sPlayerName and SMARTBUFF_Options.BlacklistTimer > 0) then
        cBlacklist[currentUnit] = GetTime();
        if (currentUnit and UnitName(currentUnit)) then
          SMARTBUFF_AddMsgWarn(UnitName(currentUnit) .. " (" .. currentUnit .. ") blacklisted (" .. SMARTBUFF_Options.BlacklistTimer .. "sec)");
        end
      end
    end
    currentUnit = nil;
  elseif (event == "UI_ERROR_MESSAGE") then
  
  elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
    --Fired when the client receives a message from SendAddonMessage 
    --arg1 "player" 
    --arg2 spell 
    --arg3 rank
    --arg4 target
    
    if (arg1 and arg1 == "player") then
      local unit = nil;
      local spell = nil;
      local target = nil;
      
      if (arg1 and arg2) then
        if (not arg3) then arg3 = ""; end
        if (not arg4) then arg4 = ""; end
        SMARTBUFF_AddMsgD("Spellcast succeeded: " .. arg1 .. ", " .. arg2 .. ", " .. arg3 .. ", " .. arg4)
        if (string.find(arg1, "party") or string.find(arg1, "raid")) then
          spell = arg2;
        end
      end
      
      if (currentUnit and currentSpell and currentUnit ~= "target") then
        unit = currentUnit;
        spell = currentSpell;
      end
      
      if (unit) then
        local name = UnitName(unit);
        if (cBuffTimer[unit] == nil) then
          cBuffTimer[unit] = { };
        end
        --if (not SMARTBUFF_IsPlayer(unit)) then
          cBuffTimer[unit][spell] = GetTime();
        --end
        if (name ~= nil) then 
          SMARTBUFF_AddMsg(name .. ": " .. spell .. " " .. SMARTBUFF_MSG_BUFFED);
          currentUnit = nil;
          currentSpell = nil;
        end
      end
      
      if (isClearSplash) then
        isClearSplash = false;
        SMARTBUFF_Splash_Clear();
      end
      
    end
    
  end

end
-- END SMARTBUFF_OnEvent


function SMARTBUFF_OnUpdate(elapsed)
  if (not isInit) then
    if (GetTime() > tAutoBuff + 1) then
      tAutoBuff = GetTime();
      SMARTBUFF_OnEvent("SMARTBUFF_UPDATE");
    end    
  else
    if ((SMARTBUFF_Options.AutoSwitchTemplateInst or SMARTBUFF_Options.AutoSwitchTemplate) and isSetZone and GetTime() > (tStartZone + 4)) then
      SMARTBUFF_CheckLocation();
    end
    SMARTBUFF_Ticker();
    SMARTBUFF_Check(1);
  end
end

function SMARTBUFF_Ticker(force)
  if (force or GetTime() > tTicker + 1) then
    tTicker = GetTime();
       
    if (isSetUnits) then
      isSetUnits = false;
      SMARTBUFF_SetUnits();
      SMARTBUFF_SyncBuffTimers();
    end
    
    if (isAuraChanged) then
      isAuraChanged = false;
      SMARTBUFF_AddMsgD("Force check");
      SMARTBUFF_Check(1, true);
    end
    
  end 
end


--[[
function SMARTBUFF_CTRASync(unit, subgroup, classeng, msg)
  if (unit == nil or msg == nil) then return; end
  
  local _, _, val1, val2, val3 = string.find(msg, "^RN ([^%s]+) ([^%s]+) ([^%s]+)$"); -- timeleft(1), id(2), num(3)
  if (not val1 or not val2 or not val3) then return; end
   
  local tleft = tonumber(val1);
  local index = tonumber(val2);
  local num = tonumber(val3);
  
  -- Try to detect if the sender uses CTRA or oRA2
  if ((index == 4 or index == 7) and cUnits[unit] and cUnits[unit].UsesCTRA == nil) then
    if (num > 0) then
      cUnits[unit].UsesCTRA = true;
      SMARTBUFF_AddMsgD(cUnits[unit].Name .. " uses CTRA");
    else
      cUnits[unit].UsesCTRA = false;
      SMARTBUFF_AddMsgD(cUnits[unit].Name .. " uses oRA2");
    end
  end
  
  -- CTRA sends the wrong index, after the 4th
  if (index >= 4 and cUnits[unit] and cUnits[unit].UsesCTRA) then
    index = index + 1;
  end  
  
  if (num == 0) then num = 1; end  
  local buff = nil;
  if (SMARTBUFF_CTRABUFFS[index]) then
    buff = SMARTBUFF_CTRABUFFS[index];
  else
    return;
  end  
  
  local bname = nil;
  if (buff[num]) then
    bname = buff[num];
  else
    return;
  end
  
  SMARTBUFF_AddMsgD(UnitName(unit) .. ", " .. bname .. " bufftime left: " .. tleft .. "sec");

  if (cBuffIndex[bname] and unit and SMARTBUFF_Options.ToggleGrp[subgroup]) then
    local i = cBuffIndex[bname];
    local dt = -1;
    local mode = -1;
    local ct = currentTemplate;    
    local sBNameS = cBuffs[i].BuffS;
    local sBNameG = cBuffs[i].BuffG;
    if (sBNameG and SMARTBUFF_Buffs[ct][sBNameS].EnableG and sBNameG == bname) then
      dt = cBuffs[i].DurationG - tleft;
      mode = 1;
    elseif (sBNameS and SMARTBUFF_Buffs[ct][sBNameS].EnableS and sBNameS == bname) then
      dt = cBuffs[i].DurationS - tleft;
      mode = 2;
    end
    
    SMARTBUFF_AddMsgD(bname .. " (" .. sBNameS .. ") found, index = " .. i .. ", time up = " .. dt);
    
    if (dt > 0) then
      if (mode == 1) then
        if (sPlayerClass == "PALADIN") then
          if (cBuffTimer[classeng] == nil) then
            cBuffTimer[classeng] = { };
          end
          cBuffTimer[classeng][sBNameG] = GetTime() - dt;
          SMARTBUFF_AddMsgD("Set class " .. classeng .. " timer");
        else
          if (cBuffTimer[subgroup] == nil) then
            cBuffTimer[subgroup] = { };
          end
          cBuffTimer[subgroup][sBNameG] = GetTime() - dt;
          
          if (cBuffTimer[unit] and cBuffTimer[unit][sBNameS]) then
            cBuffTimer[unit][sBNameS] = nil;
          end
          SMARTBUFF_AddMsgD("Set group " .. subgroup .. " timer");
        end
      elseif (mode == 2) then
        if (cBuffTimer[unit] == nil) then
          cBuffTimer[unit] = { };
        end
        cBuffTimer[unit][sBNameS] = GetTime() - dt;
        SMARTBUFF_AddMsgD("Set ".. unit .. " timer");
      end		      
    end

  end
end
]]--


-- Will dump the value of msg to the default chat window
function SMARTBUFF_AddMsg(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not SMARTBUFF_Options.ToggleMsgNormal)) then
    DEFAULT_CHAT_FRAME:AddMessage(YLL .. msg .. "|r");
  end
end

function SMARTBUFF_AddMsgErr(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not SMARTBUFF_Options.ToggleMsgError)) then
    DEFAULT_CHAT_FRAME:AddMessage(RDL .. SMARTBUFF_TITLE .. ": " .. msg .. "|r");
  end
end

function SMARTBUFF_AddMsgWarn(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not SMARTBUFF_Options.ToggleMsgWarning)) then
    DEFAULT_CHAT_FRAME:AddMessage(CY .. msg .. "|r");
    --DEFAULT_CHAT_FRAME:AddMessage(CY .. " " .. msg);
    --DEFAULT_CHAT_FRAME:AddMessage(msg, 0.5, 1, 1);
  end
end

function SMARTBUFF_AddMsgD(msg, r, g, b)
  if (r == nil) then r = 0.5; end
  if (g == nil) then g = 0.8; end
  if (b == nil) then b = 1; end
  if (DebugChatFrame and SMARTBUFF_Options and SMARTBUFF_Options.Debug) then
    DebugChatFrame:AddMessage(msg, r, g, b);
  end
end


-- Creates an array of units
function SMARTBUFF_SetUnits()
  --if (not isInit or not SMARTBUFF_Options.Toggle) then return; end
  if (InCombatLockdown()) then
    isSetUnits = true;
    return;
  end    
  if (SmartBuffOptionsFrame:IsVisible()) then return; end 
  
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
  
  if (iGroupSetup ~= iLastGroupSetup) then
    iLastGroupSetup = iGroupSetup;
    cUnits = { };
    cBlacklist = { };
    cBuffTimer = { };
    if (SMARTBUFF_TEMPLATES[iGroupSetup] == nil) then
      SMARTBUFF_SetBuffs();
    end
    local tmp = SMARTBUFF_TEMPLATES[iGroupSetup];
    if (SMARTBUFF_Options.AutoSwitchTemplate and currentTemplate ~= tmp and not (SMARTBUFF_Options.AutoSwitchTemplateInst and (SMARTBUFF_IsPlayerInBG() or IsActiveBattlefieldArena()))) then
      SMARTBUFF_AddMsg(SMARTBUFF_OFT_AUTOSWITCHTMP .. ": " .. currentTemplate .. " -> " .. tmp); 
      currentTemplate = tmp;
      SMARTBUFF_SetBuffs();
    end
    SMARTBUFF_MiniGroup_Show();
    --SMARTBUFF_AddMsgD("Group type changed");
  end  
  
  cGroups = { };
  cClassGroups = nil;
  cAddUnitList = { };
  cIgnoreUnitList = { };
  -- Raid Setup  
  if (iGroupSetup == 3) then
    cClassGroups = { };
    local name, server, rank, subgroup, level, class, classeng, zone, online, isDead;
    local sRUnit = nil;
	  
	  j = 1;
	  --for n = 1, GetNumRaidMembers(), 1 do
	  for n = 1, maxRaid, 1 do
		  name, rank, subgroup, level, class, classeng, zone, online, isDead = GetRaidRosterInfo(n);
		  if (name) then
		    server = nil;
		    i = string.find(name, "-");
		    if (i and i > 0) then
		      server = string.sub(name, i + 1);
  		    name   = string.sub(name, 1, i - 1);
  		    SMARTBUFF_AddMsgD(name .. ", " .. server);
		    end
		    sRUnit = "raid"..n;
		    
		    --SMARTBUFF_AddMsgD(name .. ", " .. sRUnit .. ", " .. UnitName(sRUnit));
        
        SMARTBUFF_AddUnitToClass("raid", n)        
  		  
		    SmartBuff_AddToUnitList(1, sRUnit, subgroup);
		    SmartBuff_AddToUnitList(2, sRUnit, subgroup);
  		  
		    if (not cUnits[sRUnit]) then
		      cUnits[sRUnit] = { };
		    end
		    if (not cUnits[sRUnit].Name or cUnits[sRUnit].Name ~= name) then
		      cUnits[sRUnit].Name = name;
		      cUnits[sRUnit].Subgroup = subgroup;
		      cUnits[sRUnit].UsesCTRA = nil;
		    end
        if (cUnits[sRUnit].Subgroup ~= subgroup) then
          cUnits[sRUnit].Subgroup = subgroup;
        end
  		  
		    if (name == sPlayerName and not server) then
		      psg = subgroup;
		    end		  
  		    		
  		  if (SMARTBUFF_Options.ToggleGrp[subgroup]) then
	        s = "";
	        if (name == UnitName(sRUnit)) then
	          if (cGroups[subgroup] == nil) then
	            cGroups[subgroup] = { };
	          end
            if (name == sPlayerName and not server) then b = true; end
	          cGroups[subgroup][j] = sRUnit;
	          --if (SMARTBUFF_Options.Debug) then s = "Add raid"..n .. ": " .. name .. "(" .. subgroup .. "/" .. class .. "/" .. classeng .. ")"; end
            j = j + 1;
	          if (classeng == "HUNTER" or classeng == "WARLOCK") then
	            cGroups[subgroup][j] = "raidpet"..n;
              --if (SMARTBUFF_Options.Debug) then s = s .. ", add raidpet"..n; end
              j = j + 1;
            end
	        end
	      end
	    end
	  end --end for
    if (not b or SMARTBUFF_Buffs[currentTemplate].SelfFirst) then
      SMARTBUFF_AddSoloSetup();
      iLastSubgroup = psg;
      --SMARTBUFF_AddMsgD("Player not in selected groups or buff self first");
    end

		if (iLastSubgroup ~= psg) then
		  SMARTBUFF_AddMsgWarn(SMARTBUFF_TITLE .. ": " .. SMARTBUFF_MSG_SUBGROUP);
		  if (SMARTBUFF_Options.ToggleSubGrpChanged) then
        SMARTBUFF_Options.ToggleGrp[psg] = true;
		    if (SmartBuffOptionsFrame:IsVisible()) then
		      SMARTBUFF_ShowSubGroupsOptions();
		    else
		      SMARTBUFF_OptionsFrame_Open();
		    end
		  end
		  iLastSubgroup = psg;
		end
		--table.sort(cGroups);
		
	  SMARTBUFF_AddMsgD("Raid Unit-Setup finished");
	
	-- Party Setup
	elseif (iGroupSetup == 2) then
    cClassGroups = { };
	  if (SMARTBUFF_Buffs[currentTemplate].SelfFirst) then
      SMARTBUFF_AddSoloSetup();
      --SMARTBUFF_AddMsgD("Buff self first");
    end
    
    cGroups[1] = { };
    cGroups[1][0] = "player";
    SMARTBUFF_AddUnitToClass("player", 0);
	  if (sPlayerClass == "HUNTER" or sPlayerClass == "WARLOCK") then
      cGroups[1][9] = "pet";
    end
    for j = 1, 4, 1 do
      cGroups[1][j] = "party"..j;
      cGroups[1][j + 4] = "partypet"..j;
      
      SMARTBUFF_AddUnitToClass("party", j);
		  
      SmartBuff_AddToUnitList(1, "party"..j, 1);
		  SmartBuff_AddToUnitList(2, "party"..j, 1);      
      --SMARTBUFF_AddMsgD("Add party"..j, 0, 1, 0.5);
    end
    SMARTBUFF_AddMsgD("Party Unit-Setup finished");
    --table.sort(cGroups);
  
  -- Solo Setup
  else    
    SMARTBUFF_AddSoloSetup();
    SMARTBUFF_AddMsgD("Solo Unit-Setup finished");
  end
  
  --collectgarbage();
end


function SMARTBUFF_AddUnitToClass(unit, i)
  local u = unit;
  local up = "pet";
  if (unit ~= "player") then
    u = unit..i;
    up = unit.."pet"..i;
  end
  if (UnitExists(u)) then
    local _, uc = UnitClass(u);
    if (uc and not cClassGroups[uc]) then
      cClassGroups[uc] = { };
    end
    if (uc) then
      cClassGroups[uc][i] = u;
    end
    --SMARTBUFF_AddMsgD("Unit added: " .. UnitName(u) .. ", " .. u);
    if (uc and uc == "HUNTER") then
      if (not cClassGroups["HPET"]) then
        cClassGroups["HPET"] = { };
      end
      cClassGroups["HPET"][i] = up;
      --if (UnitExists(up)) then
        --SMARTBUFF_AddMsgD("HPet added: " .. UnitName(up) .. ", " .. up);
      --end
    elseif (uc and uc == "WARLOCK") then
      if (not cClassGroups["WPET"]) then
        cClassGroups["WPET"] = { };
      end
      cClassGroups["WPET"][i] = up;
      --if (UnitExists(up)) then
        --SMARTBUFF_AddMsgD("WPet added: " .. UnitName(up) .. ", " .. up);
      --end
    end
  end
end

function SMARTBUFF_AddSoloSetup()
  cGroups[0] = { };
  cGroups[0][0] = "player";
  if (sPlayerClass == "HUNTER" or sPlayerClass == "WARLOCK") then cGroups[0][1] = "pet"; end
  
  if (SMARTBUFF_Buffs[currentTemplate].SelfFirst) then
    if (not cClassGroups) then
      cClassGroups = { };
    end  
    cClassGroups[0] = { };
    cClassGroups[0][0] = "player";
  end
end
-- END SMARTBUFF_SetUnits


-- Get Spell ID from spellbook
function SMARTBUFF_GetSpellID(spellname)
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
   	spellN = GetSpellName(i, SMARTBUFF_BOOK_TYPE_SPELL);
   	--if (spellN) then SMARTBUFF_AddMsgD(spellN .. " found"); end
   	if (not spellN or string.lower(spellN) == spellname) then
   	  break;
   	end   	
	end
	while (spellN ~= nil) do
	  id = i;
	  i = i + 1;
   	spellN = GetSpellName(i, SMARTBUFF_BOOK_TYPE_SPELL);
   	--if (spellN) then SMARTBUFF_AddMsgD(spellname .. " ID = " .. id); end 	
	  if (not spellN or string.lower(spellN) ~= spellname) then 
		  break;
		end
	end	
	return id;
end
-- END SMARTBUFF_GetSpellID


-- Set the buff array
function SMARTBUFF_SetBuffs()
  --if (not SMARTBUFF_Options.Toggle) then return; end
  
  local n = 1;
  local buff = nil; 
  local ct = currentTemplate;
  
  if (SMARTBUFF_Buffs[ct] == nil) then
    SMARTBUFF_Buffs[ct] = { };
    SMARTBUFF_Buffs[ct].SelfFirst = false;
  end
  
  -- update to 1.12c
  if (SMARTBUFF_Buffs[ct].GrpBuffSize == nil) then
    SMARTBUFF_Buffs[ct].GrpBuffSize = 4;
  end  
  
  cBuffs = nil;
  cBuffs = { };
  cBuffIndex = { };
  cPatterns = nil;
  numBuffs = 0;
  
  if (sPlayerClass == "DRUID") then
    for _, buff in ipairs(SMARTBUFF_DRUID) do
      n = SMARTBUFF_SetBuff(buff, n);
    end
    
  elseif (sPlayerClass == "MAGE") then
    for _, buff in ipairs(SMARTBUFF_MAGE) do
      n = SMARTBUFF_SetBuff(buff, n);
    end    
    cPatterns = SMARTBUFF_MAGE_PATTERN;
    
  elseif (sPlayerClass == "PRIEST") then
    for _, buff in ipairs(SMARTBUFF_PRIEST) do
      n = SMARTBUFF_SetBuff(buff, n);
    end
    
  elseif (sPlayerClass == "WARLOCK") then
    for _, buff in ipairs(SMARTBUFF_WARLOCK) do
      n = SMARTBUFF_SetBuff(buff, n);
    end
    cPatterns = SMARTBUFF_WARLOCK_PATTERN;
    
  elseif (sPlayerClass == "HUNTER") then
    for _, buff in ipairs(SMARTBUFF_HUNTER) do
      n = SMARTBUFF_SetBuff(buff, n);
    end     
    cPatterns = SMARTBUFF_HUNTER_PATTERN;
    
  elseif (sPlayerClass == "SHAMAN") then
    for _, buff in ipairs(SMARTBUFF_SHAMAN)  do
      n = SMARTBUFF_SetBuff(buff, n);
    end
    cPatterns = SMARTBUFF_SHAMAN_PATTERN;
    
  elseif (sPlayerClass == "WARRIOR") then
    for _, buff in ipairs(SMARTBUFF_WARRIOR)  do
      n = SMARTBUFF_SetBuff(buff, n);
    end
        
  elseif (sPlayerClass == "ROGUE") then
    for _, buff in ipairs(SMARTBUFF_ROGUE)  do
      n = SMARTBUFF_SetBuff(buff, n);
    end
    
  elseif (sPlayerClass == "PALADIN") then
    for _, buff in ipairs(SMARTBUFF_PALADIN)  do
      n = SMARTBUFF_SetBuff(buff, n);
    end
    cPatterns = SMARTBUFF_PALADIN_PATTERN;
    
  end

  for _, buff in ipairs(SMARTBUFF_WEAPON) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  for _, buff in ipairs(SMARTBUFF_RACIAL) do
    n = SMARTBUFF_SetBuff(buff, n);
  end
      
  for _, buff in ipairs(SMARTBUFF_TRACKING) do
    n = SMARTBUFF_SetBuff(buff, n);
  end
  
  for _, buff in ipairs(SMARTBUFF_FOOD) do
    n = SMARTBUFF_SetBuff(buff, n);
  end
    
  cBuffsCombat = { };  
  SMARTBUFF_SetInCombatBuffs();
  
  numBuffs = n - 1;
  isSetBuffs = false;
end

function SMARTBUFF_SetBuff(buff, i)
  if (buff == nil or i > maxCheckButtons) then return i; end
  
  cBuffs[i] = nil;
  cBuffs[i] = { };
  cBuffs[i].BuffS = buff[1];
  cBuffs[i].DurationS = ceil(buff[2] * 60);
  cBuffs[i].Type = buff[3];
  cBuffs[i].CanCharge = false;
  cBuffs[i].IDS = SMARTBUFF_GetSpellID(cBuffs[i].BuffS);
  if (cBuffs[i].IDS == nil and not (cBuffs[i].Type == SMARTBUFF_CONST_INV or cBuffs[i].Type == SMARTBUFF_CONST_FOOD)) then
    cBuffs[i] = nil;
    return i;
  end
  
  if (cBuffs[i].IDS) then
    cBuffs[i].IconS = GetSpellTexture(cBuffs[i].IDS, SMARTBUFF_BOOK_TYPE_SPELL);
  else
    local bag, slot, count, texture = SMARTBUFF_FindReagent(cBuffs[i].BuffS);
    if (count == 0) then
      cBuffs[i] = nil;
      return i;
    end    
    cBuffs[i].IconS = texture;
  end
  
  if (buff[4] ~= nil) then cBuffs[i].LevelsS = buff[4]; else cBuffs[i].LevelsS = nil; end
  if (buff[5] ~= nil) then cBuffs[i].Exclude = buff[5]; else cBuffs[i].Exclude = "x"; end
  
  
  local ct = currentTemplate;  
  local name = cBuffs[i].BuffS;
  if (SMARTBUFF_Buffs[ct][name] == nil) then
    SMARTBUFF_Buffs[ct][name] = { };
    SMARTBUFF_Buffs[ct][name].EnableS = false;
    SMARTBUFF_Buffs[ct][name].EnableG = false;
    SMARTBUFF_Buffs[ct][name].SelfOnly = false;
    SMARTBUFF_Buffs[ct][name].SelfNot = false;
    SMARTBUFF_Buffs[ct][name].CIn = false;
    SMARTBUFF_Buffs[ct][name].COut = true;
    SMARTBUFF_Buffs[ct][name].MH = false;
    SMARTBUFF_Buffs[ct][name].OH = false;
    SMARTBUFF_Buffs[ct][name].Reminder = true;
    SMARTBUFF_Buffs[ct][name].RBTime = 0;
    SMARTBUFF_Buffs[ct][name].ManaLimit = 0;
    
    if (cBuffs[i].Type == SMARTBUFF_CONST_GROUP) then
      for n in ipairs(cClasses) do
        if (not string.find(cBuffs[i].Exclude, cClasses[n])) then
          SMARTBUFF_Buffs[ct][name][cClasses[n]] = true;
        else
          SMARTBUFF_Buffs[ct][name][cClasses[n]] = false;
        end
      end
    end
  end  
  
  -- update to 1.10g
  if (SMARTBUFF_Buffs[ct][name].RBTime == nil) then
    SMARTBUFF_Buffs[ct][name].Reminder = true;
    SMARTBUFF_Buffs[ct][name].RBTime = 0;
  end

  -- update to 1.12b
  if (SMARTBUFF_Buffs[ct][name].ManaLimit == nil) then
    SMARTBUFF_Buffs[ct][name].ManaLimit = 0;
  end
  
  -- update to 2.0i
  if (SMARTBUFF_Buffs[ct][name].SelfNot == nil) then
    SMARTBUFF_Buffs[ct][name].SelfNot = false;
  end
  
  -- update to 2.1a
  if (SMARTBUFF_Buffs[ct][name].AddList == nil) then
    SMARTBUFF_Buffs[ct][name].AddList = { };
  end  
  if (SMARTBUFF_Buffs[ct][name].IgnoreList == nil) then
    SMARTBUFF_Buffs[ct][name].IgnoreList = { };
  end  
    
  cBuffs[i].BuffG = buff[6];
  cBuffs[i].IDG = SMARTBUFF_GetSpellID(cBuffs[i].BuffG);
  if (cBuffs[i].IDG ~= nil) then 
    cBuffs[i].IconG = GetSpellTexture(cBuffs[i].IDG, SMARTBUFF_BOOK_TYPE_SPELL);
  else
    cBuffs[i].IconG = nil;
  end
  if (buff[7] ~= nil) then cBuffs[i].DurationG = ceil(buff[7] * 60); else cBuffs[i].DurationG = nil; end
  if (buff[8] ~= nil) then cBuffs[i].LevelsG = buff[8]; else cBuffs[i].LevelsG = nil; end
  if (buff[9] ~= nil) then cBuffs[i].ReagentG = buff[9]; else cBuffs[i].ReagentG = nil; end
  
  --[[
  if (SMARTBUFF_Options.Debug) then
    local s = name;
    if (cBuffs[i].IDS) then s = s .. " ID = " .. cBuffs[i].IDS .. ", Icon = " .. cBuffs[i].IconS; else s = s .. " ID = nil"; end
    if (cBuffs[i].BuffG ~= nil) then 
      s = s .. " - " .. cBuffs[i].BuffG;
      if (cBuffs[i].IDG) then s = s .. " ID = " .. cBuffs[i].IDG .. ", Icon = " .. cBuffs[i].IconG; else s = s .. " ID = nil"; end
    end
    SMARTBUFF_AddMsgD(s);
  end
  ]]--
  
  cBuffIndex[name] = i;
  if (cBuffs[i].IDG ~= nil) then
    cBuffIndex[cBuffs[i].BuffG] = i;
  end
 
  return i + 1;
end

function SMARTBUFF_SetInCombatBuffs()
  local ct = currentTemplate;
  for name, data in pairs(SMARTBUFF_Buffs[ct]) do
    --SMARTBUFF_AddMsgD(name .. ", type = " .. type(data));
    if (type(data) == "table" and cBuffIndex[name] and (SMARTBUFF_Buffs[ct][name].EnableS or SMARTBUFF_Buffs[ct][name].EnableG) and SMARTBUFF_Buffs[ct][name].CIn) then
      cBuffsCombat[name] = { };
      cBuffsCombat[name].Unit = "player";
      cBuffsCombat[name].Type = cBuffs[cBuffIndex[name]].Type;
      cBuffsCombat[name].ActionType = "spell";
      SMARTBUFF_AddMsgD("Set combat spell: " .. name);
      --break;
    end
  end
end

-- END SMARTBUFF_SetBuffs


-- Main Check functions
function SMARTBUFF_PreCheck(mode, force)
  if (not isInit) then return false; end

  if (not SMARTBUFF_Options.Toggle) then
    if (mode == 0) then
      SMARTBUFF_AddMsg(SMARTBUFF_MSG_DISABLED);
    end
    return false;
  end
    
  if (mode == 1 and not force) then
    if ((GetTime() - tLastCheck) < SMARTBUFF_Options.AutoTimer) then
      return false;
    end
  end
  --SMARTBUFF_AddMsgD(string.format("%.2f, %.2f", GetTime(), GetTime() - tLastCheck));
  tLastCheck = GetTime();

  if ((mode == 1 and not SMARTBUFF_Options.ToggleAuto) or IsMounted() or IsFlying() or LootFrame:IsVisible()
    or UnitOnTaxi("player") or UnitIsDeadOrGhost("player") or UnitIsCorpse("player")
    --or (mode == 1 and (SMARTBUFF_Options.ToggleAutoRest and IsResting()) and not UnitIsPVP("player"))
    or (not SMARTBUFF_Options.BuffInCities and IsResting() and not UnitIsPVP("player"))) then
    
    if (UnitIsDeadOrGhost("player")) then
      SMARTBUFF_CheckBuffTimers();
    end    
    
    return false;
  end
  --SMARTBUFF_AddMsgD("2: " .. GetTime() - tLastCheck);
   
  if (isSetBuffs) then
    SMARTBUFF_SetBuffs();
  end
    
  if (UnitAffectingCombat("player")) then
    isCombat = true;
    --SMARTBUFF_AddMsgD("In combat");
  else
    isCombat = false;
    --SMARTBUFF_AddMsgD("Out of combat");
  end
  
  sMsgWarning = "";
  isFirstError = true;
	
	return true;
end


-- Bufftimer check functions
function SMARTBUFF_CheckBuffTimers()
  local n = 0;
  local ct = currentTemplate;
  
  local cGrp = nil;
  if (sPlayerClass == "PALADIN" and cClassGroups) then
    cGrp = cClassGroups;
  else
    cGrp = cGroups;
  end  
  
  for subgroup in pairs(cGrp) do
  --for subgroup = 0, 8, 1 do
    n = 0;    
    if (cGrp[subgroup] ~= nil) then
      for _, unit in pairs(cGrp[subgroup]) do
        if (unit) then
          if (SMARTBUFF_CheckUnitBuffTimers(unit)) then
            n = n + 1;
          end
        end
      end
      if (n >= SMARTBUFF_Buffs[ct].GrpBuffSize and cBuffTimer[subgroup]) then
        cBuffTimer[subgroup] = nil;
        SMARTBUFF_AddMsgD("Group " .. subgroup .. ": group timer reseted");
      end
    end
  end
end
-- END SMARTBUFF_CheckBuffTimers

-- if unit is dead, remove all timers
function SMARTBUFF_CheckUnitBuffTimers(unit)
  if (UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and UnitIsPlayer(unit) and UnitIsDeadOrGhost(unit)) then
    local _, uc = UnitClass(unit);
    local fd = nil;
    if (uc == "HUNTER") then
      fd = SMARTBUFF_IsFeignDeath(unit);
    end 
    if (not fd) then
      if (cBuffTimer[unit]) then
        cBuffTimer[unit] = nil;
        SMARTBUFF_AddMsgD(UnitName(unit) .. ": unit timer reseted");
      end
      if (cBuffTimer[uc]) then
        cBuffTimer[uc] = nil;
        SMARTBUFF_AddMsgD(uc .. ": class timer reseted");
      end
      return true;
    end
  end
end
-- END SMARTBUFF_CheckUnitBuffTimers


-- Reset the buff timers and set them to running out soon
function SMARTBUFF_ResetBuffTimers()
  if (not isInit) then return; end
  
  local ct = currentTemplate;
  local t = GetTime();
  local rbTime = 0;
  local i = 0;
  local d = 0;
  local tl = 0;
  local buffS = nil;
  local buff = nil;
  local unit = nil;
  local obj = nil;
  local uc = nil;
  
  local cGrp = nil;
  if (sPlayerClass == "PALADIN" and cClassGroups) then
    cGrp = cClassGroups;
  else
    cGrp = cGroups;
  end
  
  for subgroup in pairs(cGrp) do
    n = 0;    
    if (cGrp[subgroup] ~= nil) then
    
      for _, unit in pairs(cGrp[subgroup]) do
        --if (unit and UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and (UnitIsPlayer(unit) or (sPlayerClass == "PALADIN" and (UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit)))) and not UnitIsDeadOrGhost(unit)) then
        if (unit and UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit)) then
          _, uc = UnitClass(unit);
          i = 1;
          while (cBuffs[i] and cBuffs[i].BuffS) do
            d = -1;
            buff = nil;
            rbTime = 0;
            buffS = cBuffs[i].BuffS;
            
            rbTime = SMARTBUFF_Buffs[ct][buffS].RBTime;
            if (rbTime <= 0) then
              rbTime = SMARTBUFF_Options.RebuffTimer;
            end
                        
            if (cBuffs[i].BuffG and SMARTBUFF_Buffs[ct][buffS].EnableG and cBuffs[i].IDG ~= nil and cBuffs[i].DurationG > 0
              and (sPlayerClass ~= "PALADIN" or not cClassGroups or (sPlayerClass == "PALADIN" and (SMARTBUFF_Buffs[ct][buffS][subgroup] or (type(subgroup) == "number" and subgroup == 0))))) then
              d = cBuffs[i].DurationG;
              buff = cBuffs[i].BuffG;
              obj = subgroup;
            end
            
            if (d > 0 and buff) then
              if (not cBuffTimer[obj]) then
                cBuffTimer[obj] = { };
              end
              cBuffTimer[obj][buff] = t - d + rbTime - 1;
            end            
            
            buff = nil;
            if (buffS and SMARTBUFF_Buffs[ct][buffS].EnableS and cBuffs[i].IDS ~= nil and cBuffs[i].DurationS > 0
              and uc and SMARTBUFF_Buffs[ct][buffS][uc]) then
              d = cBuffs[i].DurationS;
              buff = buffS;
              obj = unit;
            end
            
            if (d > 0 and buff) then
              if (not cBuffTimer[obj]) then
                cBuffTimer[obj] = { };
              end
              cBuffTimer[obj][buff] = t - d + rbTime - 1;
            end
            
            i = i + 1;
          end

        end
      end
    end
  end
  --isAuraChanged = true;
  SMARTBUFF_Check(1, true);
  
end

function SMARTBUFF_ShowBuffTimers()
  if (not isInit) then return; end
  
  local ct = currentTemplate;
  local t = GetTime();
  local rbTime = 0;
  local i = 0;
  local d = 0;
  local tl = 0;
  local buffS = nil;
  
  for unit in pairs(cBuffTimer) do
    for buff in pairs(cBuffTimer[unit]) do
      if (unit and buff and cBuffTimer[unit][buff]) then        
        
        d = -1;
        buffS = nil;
        if (cBuffIndex[buff]) then
          i = cBuffIndex[buff];
          if (cBuffs[i].BuffS == buff and cBuffs[i].DurationS > 0) then
            d = cBuffs[i].DurationS;
            buffS = cBuffs[i].BuffS;
          elseif (cBuffs[i].BuffG == buff and cBuffs[i].DurationG > 0) then
            d = cBuffs[i].DurationG;
            buffS = cBuffs[i].BuffS;
          end
          i = i + 1;
        end
        
        --SMARTBUFF_AddMsg(d);
        
        if (buffS and SMARTBUFF_Buffs[ct][buffS] ~= nil) then
          if (d > 0) then
            rbTime = SMARTBUFF_Buffs[ct][buffS].RBTime;
            if (rbTime <= 0) then
              rbTime = SMARTBUFF_Options.RebuffTimer;
            end
            tl = cBuffTimer[unit][buff] + d - t;
            if (tl >= 0) then              
              local s = "";
              if (string.find(unit, "^party") or string.find(unit, "^raid") or string.find(unit, "^player") or string.find(unit, "^pet")) then
                local un = UnitName(unit);
                if (un) then
                  un = " (" .. un .. ")";
                else
                  un = "";
                end
                s = "Unit " .. unit .. un;
              elseif (string.find(unit, "^%d$")) then
                s = "Grp " .. unit;
              else
                s = "Class " .. unit;
              end
              --SMARTBUFF_AddMsg(s .. ": " .. buff .. ", time left: " .. string.format(": %.0f", tl) .. ", rebuff time: " .. rbTime);
              SMARTBUFF_AddMsg(string.format("%s: %s, time left: %.0f, rebuff time: %.0f", s, buff, tl, rbTime));
            else
              cBuffTimer[unit][buff] = nil;
            end
          else
            --SMARTBUFF_AddMsgD("Removed: " .. buff);
            cBuffTimer[unit][buff] = nil;
          end
        end
        
      end
    end
  end
  
end
-- END SMARTBUFF_ResetBuffTimers


-- Synchronize the internal buff timers with the UI timers
function SMARTBUFF_SyncBuffTimers()
  if (not isInit or not SMARTBUFF_Options.UISync) then return; end
  
  local ct = currentTemplate;  
  local rbTime = 0;
  local i = 0;
  local buffS = nil;
  local unit = nil;
  local uc = nil;
  
  local cGrp = nil;
  if (sPlayerClass == "PALADIN" and cClassGroups) then
    cGrp = cClassGroups;
  else
    cGrp = cGroups;
  end
  
  for subgroup in pairs(cGrp) do
    n = 0;    
    if (cGrp[subgroup] ~= nil) then
      for _, unit in pairs(cGrp[subgroup]) do
        --if (unit and UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and (UnitIsPlayer(unit) or (sPlayerClass == "PALADIN" and (UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit)))) and not UnitIsDeadOrGhost(unit)) then
        if (unit and UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit)) then
          _, uc = UnitClass(unit);
          i = 1;
          while (cBuffs[i] and cBuffs[i].BuffS) do
            rbTime = 0;
            buffS = cBuffs[i].BuffS;
            
            rbTime = SMARTBUFF_Buffs[ct][buffS].RBTime;
            if (rbTime <= 0) then
              rbTime = SMARTBUFF_Options.RebuffTimer;
            end
            
            --SMARTBUFF_AddMsgD("Buff timer sync check: " .. buffS);
                        
            if (cBuffs[i].BuffG and SMARTBUFF_Buffs[ct][buffS].EnableG and cBuffs[i].IDG ~= nil and cBuffs[i].DurationG > 0
              and (sPlayerClass ~= "PALADIN" or not cClassGroups or (sPlayerClass == "PALADIN" and (SMARTBUFF_Buffs[ct][buffS][subgroup] or (type(subgroup) == "number" and subgroup == 0))))) then
              SMARTBUFF_SyncBuffTimer(unit, subgroup, cBuffs[i].BuffG, cBuffs[i].DurationG);
            end
            
            if (buffS and SMARTBUFF_Buffs[ct][buffS].EnableS and cBuffs[i].IDS ~= nil and cBuffs[i].DurationS > 0
              and uc and SMARTBUFF_Buffs[ct][buffS][uc]) then
              SMARTBUFF_SyncBuffTimer(unit, unit, buffS, cBuffs[i].DurationS);
            end
            
            i = i + 1;
          end -- END while
        end
      end -- END for
    end
  end -- END for
end

function SMARTBUFF_SyncBuffTimer(unit, grp, buff, d)
  if (d and d > 0 and buff) then
    local t = GetTime();
    local ret, _, _, timeleft = SMARTBUFF_CheckUnitBuffs(unit, buff, nil);
    if (ret == nil and timeleft ~= nil) then
      if (not cBuffTimer[grp]) then
        cBuffTimer[grp] = { };
      end
      st = t - d + timeleft;
      if (cBuffTimer[grp][buff] == nil or (cBuffTimer[grp][buff] ~= nil and cBuffTimer[grp][buff] > st)) then
        cBuffTimer[grp][buff] = st;
        SMARTBUFF_AddMsgD("Buff timer sync: " .. grp .. ", " .. buff .. ", " .. timeleft);
      end
    end
  end
end


--/script DEFAULT_CHAT_FRAME:AddMessage(GetShapeshiftForm(true));
-- check if the player is shapeshifted
function SMARTBUFF_IsShapeshifted()
	if (sPlayerClass == "SHAMAN") then
    if (GetShapeshiftForm(true) > 0) then
      return true, "Ghost Wolf";
    end
	elseif (sPlayerClass == "DRUID") then
	  local i;
  	for i = 1, GetNumShapeshiftForms(), 1 do
  		local icon, name, active = GetShapeshiftFormInfo(i);
  		if (active == 1 and SMARTBUFF_GetSpellID(name) ~= nil) then
        return true, name;
      end
  	end  
  end
  return false, nil;
end
-- END SMARTBUFF_IsShapeshifted


function SMARTBUFF_Check(mode, force)
  if (not SMARTBUFF_PreCheck(mode, force)) then
    return;
  end
  
  local ct = currentTemplate;
  local unit = nil;
  local unitB = nil;
  local unitL = nil;
  local unitU = nil;
  local uLevel = nil;
  local uLevelL = nil;
  local uLevelU = nil;
  local idL = nil;
  local idU = nil;
  local subgroup = 0;
  local i;
  local j;
  local n;
  local m;
  local rc;
  local rank;
  local reagent;
  local nGlobal = 0;
  
  SMARTBUFF_checkBlacklist();
  
  -- check in combat buffs first
  if (InCombatLockdown()) then -- and SMARTBUFF_Options.InCombat
    for spell in pairs(cBuffsCombat) do
      if (spell) then
        local ret, actionType, spellName, slot, unit, buffType = SMARTBUFF_BuffUnit("player", 0, mode, spell)
        SMARTBUFF_AddMsgD("Check combat spell: " .. spell .. ", ret = " .. ret);
        if (ret and ret == 0) then
          return;
        end
      end
    end  
  end
    
  -- buff target first, if enabled
  if ((mode == 0 or mode == 5) and SMARTBUFF_Options.BuffTarget) then
    local actionType, spellName, slot, buffType;
    i, actionType, spellName, slot, _, buffType = SMARTBUFF_BuffUnit("target", 0, mode);
    if (i <= 1) then
      if (i == 0) then
        --tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + GlobalCd;
      end
      return i, actionType, spellName, slot, "target", buffType;
    end    
  end

  
  --[[
  -- buff player in additional list first
  if (UnitInRaid("player") or UnitInParty("player")) then
    local actionType, spellName, slot, buffType;
    for unit in pairs(cAddUnitList) do
      if (SmartBuff_UnitIsAdd(unit)) then
        --SMARTBUFF_AddMsgD("Checking AddUnits: " .. UnitName(unit) .. " (" .. unit .. ")");  
        i, actionType, spellName, slot, _, buffType = SMARTBUFF_BuffUnit(unit, 0, mode);
        if (i <= 1) then
          if (i == 0 and (mode == 0 or mode == 5)) then
            --tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + GlobalCd;
          end
          return i, actionType, spellName, slot, "target", buffType;
        end
    	end
    end  
  end
  ]]--
  
    
  local cGrp = nil;
  local cOrd = nil;
  if (sPlayerClass == "PALADIN" and cClassGroups) then
    cGrp = cClassGroups;
    cOrd = cOrderClass;
  else
    cGrp = cGroups;
    cOrd = cOrderGrp;
  end  
  
  for _, subgroup in ipairs(cOrd) do
    --SMARTBUFF_AddMsgD("Checking subgroup " .. subgroup .. ", " .. GetTime());
  --for subgroup = 0, 8, 1 do
    if (cGrp[subgroup] ~= nil) then
      units = cGrp[subgroup];
      
      -- check group buff
      if (units) then
        i = 1;
        local rbTime = 0;
        while (cBuffs[i] and cBuffs[i].BuffS) do
        
          if (cBuffs[i].BuffG and SMARTBUFF_Buffs[ct][cBuffs[i].BuffS].EnableG and cBuffs[i].IDG ~= nil
            and ((isCombat and SMARTBUFF_Buffs[ct][cBuffs[i].BuffS].CIn) or (not isCombat and SMARTBUFF_Buffs[ct][cBuffs[i].BuffS].COut))
            and UnitMana("player") >= SMARTBUFF_Buffs[ct][cBuffs[i].BuffS].ManaLimit
            and (sPlayerClass ~= "PALADIN" or not cClassGroups or (sPlayerClass == "PALADIN" and (SMARTBUFF_Buffs[ct][cBuffs[i].BuffS][subgroup] or (type(subgroup) == "number" and subgroup == 0))))) then
           
              local tmpUnits = { };
              local buffnS = cBuffs[i].BuffS;
              local buffnG = cBuffs[i].BuffG;
              local btl = 9999;
              local bExp = false;
    	        local target = "";
    	        
              if (sPlayerClass == "PALADIN" and cClassGroups) then
                for _, unit in pairs(units) do
                  local u = UnitClass(unit);
                  if (u) then
                    target = SMARTBUFF_MSG_CLASS .. " " .. u;
                    SMARTBUFF_AddMsgD(target);
                    break;
                  end
                end
              else
                target = SMARTBUFF_MSG_GROUP .. " " .. subgroup;
              end
                          
    	        if (type(subgroup) == "number" and subgroup == 0) then
    	          target = sPlayerName;
    	        end            
              
              rbTime = SMARTBUFF_Buffs[ct][buffnS].RBTime;
              if (rbTime <= 0) then
                rbTime = SMARTBUFF_Options.RebuffTimer;
              end
              
    	        if (cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][buffnG] ~= nil) then
    	          btl = cBuffs[i].DurationG - (GetTime() - cBuffTimer[subgroup][buffnG]);
    	          if (rbTime > 0 and rbTime >= btl) then
    	            bExp = true;
    	            if (mode == 1) then
                    -- clean up buff timer, if expired
                    if (btl < 0) then
                      cBuffTimer[subgroup][buffnG] = nil;
                      --SMARTBUFF_AddMsgD("Group " .. subgroup .. ": " .. buffnS .. " timer reset");
                      tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + 0.5;
                      return;
                    end 
                      
    	              --SMARTBUFF_SetMissingBuffMessage(target, buffnG, false, 1, btl, bExp, false);
    	              --return;
    	            end
    	          end
              end            
              
              --SMARTBUFF_AddMsgD("Checking0 " .. buffnG);
              n = 0;
              m = 0;
              j = 0;
              uLevelL = 100;
              uLevelU = 0;              
              unitL = nil;
              unitU = nil;
              unitB = nil;
              for _, unit in pairs(units) do
                j = j + 1;
                --SMARTBUFF_AddMsgD("Checking1 " .. buffnG .. " " .. unit); 
                
                --if (unit and (UnitIsPlayer(unit) or (sPlayerClass == "PALADIN" and (UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit)))) and not SMARTBUFF_IsInList(unit, UnitName(unit), SMARTBUFF_Buffs[ct][buffnS].IgnoreList)) then
                if (unit and UnitIsPlayer(unit) and not SMARTBUFF_IsInList(unit, UnitName(unit), SMARTBUFF_Buffs[ct][buffnS].IgnoreList)) then

                  --SMARTBUFF_AddMsgD("Checking2 " .. buffnG .. " " .. unit);              
                  n = n + 1;	
    	            if (UnitExists(unit) and not UnitIsDeadOrGhost(unit) and not UnitIsCorpse(unit) and UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitOnTaxi(unit) and (not SMARTBUFF_Options.AdvGrpBuffRange or IsSpellInRange(cBuffs[i].BuffG, unit) == 1)) then
                    --if (sPlayerClass ~= "PALADIN")
                    tmpUnits[n] = unit;
    	              uLevel = UnitLevel(unit);
    	              if (uLevel < uLevelL) then
    	                uLevelL = uLevel;
    	                unitL = unit;
    	              end
    	              if (uLevel > uLevelU) then
    	                uLevelU = uLevel;
    	                unitU = unit;
    	                unitB = unit;
    	              end
    	              local ret, idx, buffname;
    	              ret = nil;
    	              if (SMARTBUFF_Options.AdvGrpBuffCheck) then
                      local _, uc = UnitClass(unit);
                      local uct = UnitCreatureType(unit);
  	                  local ucf = UnitCreatureFamily(unit);
  	                  if (uct == nil) then uct = ""; end
                      if (ucf == nil) then ucf = ""; end  	                  
    	                if ((SMARTBUFF_Buffs[ct][buffnS][uc] and (uct == SMARTBUFF_HUMANOID or (uc == "DRUID" and (uct == SMARTBUFF_BEAST or uct == SMARTBUFF_ELEMENTAL)))) or (SMARTBUFF_Buffs[ct][buffnS]["HPET"] and uct == SMARTBUFF_BEAST and uc ~= "DRUID") or (SMARTBUFF_Buffs[ct][buffnS]["WPET"] and uct == SMARTBUFF_DEMON and ucf ~= SMARTBUFF_DEMONTYPE)) then
    	                  ret, idx, buffname = SMARTBUFF_CheckUnitBuffs(unit, cBuffs[i].BuffS, buffnG);
    	                end
    	              else
    	                ret, idx, buffname = SMARTBUFF_CheckUnitBuffs(unit, buffnG, nil);
    	              end
    	              if (ret ~= nil or bExp) then
    	                m = m + 1;
    	              end
    	            end
    	          end  	          
    	          
    	        end -- end for
          
              if (mode == 1 and m >= SMARTBUFF_Buffs[ct].GrpBuffSize and n >= SMARTBUFF_Buffs[ct].GrpBuffSize) then                  
                SMARTBUFF_SetMissingBuffMessage(target, buffnG, false, 1, btl, bExp, false);
                return;
              end              
              
    	        if (unitL ~= nil and unitU ~=nil and unitB ~= nil and cBuffs[i].IDG ~= nil) then
                idU, rank = SMARTBUFF_CheckUnitLevel(unitU, cBuffs[i].IDG, cBuffs[i].LevelsG);
                idL, rank = SMARTBUFF_CheckUnitLevel(unitL, cBuffs[i].IDG, cBuffs[i].LevelsG);
                
                --SMARTBUFF_AddMsgD(buffnG .. " (" .. rank .. ") " .. m .. " of " .. n .. " not buffed, lowest/highest level " .. uLevelL .. "/" .. uLevelU);            
    	          if (idL ~= nil and idU ~= nil and idL == idU and rank > 0 and m >= SMARTBUFF_Buffs[ct].GrpBuffSize and n >= SMARTBUFF_Buffs[ct].GrpBuffSize) then
      	        
                  reagent = cBuffs[i].ReagentG[rank];
                  if (reagent and mode ~= 1) then
                    rc = SMARTBUFF_CountReagent(reagent);
                    if (rc > 0) then
                      currentUnit = nil;
                      currentSpell = nil;
                      
                      --SMARTBUFF_AddMsgD("Buffing group (" .. unitB .. ") " .. subgroup .. ", " .. idU .. ", " .. j .. ", ");
                      j = SMARTBUFF_doCast(unitB, idU, buffnG, nil, SMARTBUFF_CONST_GROUP)
                      
   	                  if (j == 0) then
                        SMARTBUFF_AddMsg(target .. ": " .. buffnG .. " " .. SMARTBUFF_MSG_BUFFED);
                        SMARTBUFF_AddMsg(SMARTBUFF_MSG_STOCK .. " " .. reagent .. " = " .. (rc - 1));
                                              
                        if (sPlayerClass == "PALADIN") then
                          local _, uc = UnitClass(unitB);
                          if (cBuffTimer[uc] == nil) then
                            cBuffTimer[uc] = { };
                          end
                          cBuffTimer[uc][buffnG] = GetTime();                      
                        else
                          if (cBuffTimer[subgroup] == nil) then
                            cBuffTimer[subgroup] = { };
                          end
                          cBuffTimer[subgroup][buffnG] = GetTime();
                        end
                        
                        -- cleanup single buff timer
                        for _, unit in pairs(tmpUnits) do
                          if (cBuffTimer[unit] and cBuffTimer[unit][cBuffs[i].BuffS]) then
                            cBuffTimer[unit][cBuffs[i].BuffS] = nil;
                          end
                        end
                        
                        --tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + GlobalCd;
                        return 0, SMARTBUFF_ACTION_SPELL, buffnG, -1, unitB, cBuffs[i].Type;
                      end
    	              else
    	                SMARTBUFF_AddMsgWarn(SMARTBUFF_MSG_NOREAGENT .. " " .. reagent .. "! " .. buffnG .. " " .. SMARTBUFF_MSG_DEACTIVATED);
    	                SMARTBUFF_Buffs[ct][cBuffs[i].BuffS].EnableG = false;
    	              end
    	            elseif (reagent and mode == 1) then
    	              SMARTBUFF_SetMissingBuffMessage(target, buffnG, false, 1, btl, bExp, false);
    	              return;
    	            else
    	              --SMARTBUFF_AddMsgD("Reagent = nil");
    	            end
    	          end
    	        end
    	      end

  	      i = i + 1;
  	    end -- END while buffs
  	  end
    	
      -- check single buff
      for _, unit in pairs(units) do
        --SMARTBUFF_AddMsgD("Checking single units " .. unit);
        local spellName, actionType, slot, buffType;
        i, actionType, spellName, slot, _, buffType = SMARTBUFF_BuffUnit(unit, subgroup, mode);
        if (i <= 1) then
          if (i == 0 and mode ~= 1) then
            --tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + GlobalCd;
            if (actionType == SMARTBUFF_ACTION_ITEM) then
              --tLastCheck = tLastCheck + 2;
            end
          end
          return i, actionType, spellName, slot, unit, buffType;
        end
      end
    
    end
  end -- for groups
  
  if (mode == 0) then 
    if (sMsgWarning == "" or sMsgWarning == " ") then
      SMARTBUFF_AddMsg(SMARTBUFF_MSG_NOTHINGTODO);
    else
      SMARTBUFF_AddMsgWarn(sMsgWarning);
      sMsgWarning = "";
    end
  end
  --tLastCheck = GetTime();
  
end
-- END SMARTBUFF_Check


-- Buffs a unit
function SMARTBUFF_BuffUnit(unit, subgroup, mode, spell)
  local ct = currentTemplate;
  local buff = nil;
  local buffname = nil;
  local buffnS = nil;
  local uc = nil;
  local un = nil;
  local uct = nil;
  local ucf = nil;
  local r;
  local i;
  local bt = 0;
  local cd = 0;
  local charges = 0;
  local handtype = "";
  local bExpire = false;
  local bExpireOh = false;
  local isPvP = false;
  local bufftarget = nil;
  local rbTime = 0;
  local bUsable = false;
  
  if (UnitIsPVP("player")) then isPvP = true; end
  
  SMARTBUFF_CheckUnitBuffTimers(unit);  
  
  --SMARTBUFF_AddMsgD("Checking " .. unit);
  
  if (UnitExists(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and not UnitIsCorpse(unit)
    and UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitOnTaxi(unit) and not cBlacklist[unit]
    and ((UnitIsPVP(unit) == nil and (not isPvP or SMARTBUFF_Options.BuffPvP)) or (UnitIsPVP(unit) and (isPvP or SMARTBUFF_Options.BuffPvP)))) then
    --and not SmartBuff_UnitIsIgnored(unit)
    
  	_, uc = UnitClass(unit);
  	un = UnitName(unit);
  	uct = UnitCreatureType(unit);
	  ucf = UnitCreatureFamily(unit);
	  if (uct == nil) then uct = ""; end
    if (ucf == nil) then ucf = ""; end
          
    --if (un) then SMARTBUFF_AddMsgD("Grp " .. subgroup .. " checking " .. un .. " (" .. uct .. "/" .. ucf .. "/".. unit .. ")...", 0, 1, 0.5); end

    i = 1;
    isShapeshifted, sShapename = SMARTBUFF_IsShapeshifted();
    while (cBuffs[i] and cBuffs[i].BuffS) do
      buffnS = cBuffs[i].BuffS;
      bExpire = false;
      bExpireOh = false;
      handtype = "";
      charges = -1;
      bufftarget = nil;
      bUsable = SMARTBUFF_Buffs[ct][buffnS].EnableS;
      
      if (bUsable and spell and spell ~= buffnS) then
        bUsable = false;
        --SMARTBUFF_AddMsgD("Exclusive check on " .. spell .. ", current spell = " .. buffnS);
      end
      
      if (bUsable and SMARTBUFF_Buffs[ct][buffnS].SelfNot and SMARTBUFF_IsPlayer(unit)) then
        bUsable = false;
      end
      
      if (bUsable and UnitMana("player") < SMARTBUFF_Buffs[ct][buffnS].ManaLimit) then
        bUsable = false;
        --SMARTBUFF_AddMsgD(cBuffs[i].BuffS .. " is below the powertype threshold!");
      end
      
      if (bUsable and sPlayerClass == "WARLOCK" and buffnS == SMARTBUFF_SOULLINK and not UnitExists("pet")) then
        bUsable = false;
      end
      
      if (bUsable and not (cBuffs[i].Type == SMARTBUFF_CONST_INV or cBuffs[i].Type == SMARTBUFF_CONST_FOOD)) then
        -- check if you have enough mana/rage/energy to cast
        local isUsable, notEnoughMana = IsUsableSpell(buffnS);
        if (notEnoughMana) then
          bUsable = false;
          --SMARTBUFF_AddMsgD("Buff " .. cBuffs[i].BuffS .. ", not enough mana!");
        elseif (mode ~= 1 and isUsable == nil and buffnS ~= SMARTBUFF_PWS) then
          bUsable = false;
          --SMARTBUFF_AddMsgD("Buff " .. cBuffs[i].BuffS .. " is not usable!");
        end
      end      
      
      if (bUsable and SMARTBUFF_Buffs[ct][buffnS].EnableS and (cBuffs[i].IDS ~= nil or cBuffs[i].Type == SMARTBUFF_CONST_INV or cBuffs[i].Type == SMARTBUFF_CONST_FOOD)
        and ((mode ~= 1 and ((isCombat and SMARTBUFF_Buffs[ct][buffnS].CIn) or (not isCombat and SMARTBUFF_Buffs[ct][buffnS].COut)))
          or (mode == 1 and SMARTBUFF_Buffs[ct][buffnS].Reminder and ((not isCombat and SMARTBUFF_Buffs[ct][buffnS].COut) 
          or (isCombat and (SMARTBUFF_Buffs[ct][buffnS].CIn or SMARTBUFF_Options.ToggleAutoCombat)))))) then
        
        if (not SMARTBUFF_Buffs[ct][buffnS].SelfOnly or (SMARTBUFF_Buffs[ct][buffnS].SelfOnly and SMARTBUFF_IsPlayer(unit))) then
          
          if (InCombatLockdown()) then
            --SMARTBUFF_AddMsgD("Checking " .. buffnS);
          end
          
          -- check if spell has cooldown
	        cd = 0;
          if (cBuffs[i].IDS) then _, cd = GetSpellCooldown(cBuffs[i].IDS, SMARTBUFF_BOOK_TYPE_SPELL); end
  	      if (cd == 0) then
            if (cBuffs[i].IDS and sMsgWarning == SMARTBUFF_MSG_CD) then
              sMsgWarning = " ";
            end
            
            rbTime = SMARTBUFF_Buffs[ct][buffnS].RBTime;
            if (rbTime <= 0) then
              rbTime = SMARTBUFF_Options.RebuffTimer;
            end
  	      
            --SMARTBUFF_AddMsgD(uc .. " " .. ct);
            if (not SMARTBUFF_IsInList(unit, un, SMARTBUFF_Buffs[ct][buffnS].IgnoreList) and ((cBuffs[i].Type == SMARTBUFF_CONST_GROUP 
              and ((SMARTBUFF_Buffs[ct][buffnS][uc] and (uct == SMARTBUFF_HUMANOID or (uc == "DRUID" and (uct == SMARTBUFF_BEAST or uct == SMARTBUFF_ELEMENTAL))))
              or (SMARTBUFF_Buffs[ct][buffnS]["HPET"] and uct == SMARTBUFF_BEAST and uc ~= "DRUID") 
              or (SMARTBUFF_Buffs[ct][buffnS]["WPET"] and uct == SMARTBUFF_DEMON and ucf ~= SMARTBUFF_DEMONTYPE)))
              or (cBuffs[i].Type ~= SMARTBUFF_CONST_GROUP and SMARTBUFF_IsPlayer(unit))
              or SMARTBUFF_IsInList(unit, un, SMARTBUFF_Buffs[ct][buffnS].AddList))) then
              buff = nil;
                            
              -- Tracking ability ------------------------------------------------------------------------
              if (cBuffs[i].Type == SMARTBUFF_CONST_TRACK) then
                
                local iconTrack = GetTrackingTexture();
                if (iconTrack ~= "Interface\\Minimap\\Tracking\\None") then
                --if (iconTrack) then
                  --SMARTBUFF_AddMsgD("Track already enabled: " .. iconTrack);
                else
                  if (sPlayerClass ~= "DRUID" or ((not isShapeshifted and buffnS ~= SMARTBUFF_DRUID_TRACK) or (isShapeshifted and buffnS ~= SMARTBUFF_DRUID_TRACK) or (isShapeshifted and buffnS == SMARTBUFF_DRUID_TRACK and sShapename == SMARTBUFF_DRUID_CAT))) then
                    buff = buffnS;
                  end
                end
              
              -- Food ------------------------------------------------------------------------
              elseif (cBuffs[i].Type == SMARTBUFF_CONST_FOOD) then
              
                buff, index, buffname = SMARTBUFF_CheckUnitBuffs(unit, SMARTBUFF_FOOD_AURA, cBuffs[i].BuffG);
                if (buff == nil and cBuffs[i].DurationS >= 1 and rbTime > 0) then
                  bt = GetPlayerBuffTimeLeft(index);
                  charges = GetPlayerBuffApplications(index);
                  if (charges == nil) then charges = -1; end
                  if (charges > 1) then cBuffs[i].CanCharge = true; end
                  bufftarget = nil;
                end
              
                if (buff) then
                  local cr = SMARTBUFF_CountReagent(buffnS);
                  if (cr > 0) then
                    --SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found");
                    buff = buffnS;
                  else
                    --SMARTBUFF_AddMsgD("No " .. buffnS .. " found");
                    buff = nil;
                  end
                end              
                
              -- Weapon buff ------------------------------------------------------------------------
              elseif (cBuffs[i].Type == SMARTBUFF_CONST_WEAPON or cBuffs[i].Type == SMARTBUFF_CONST_INV) then
                local bMh = false;
                local bOh = false;
                local tMh = -1;
                local tOh = -1;
                local cMh = -1;
                local cOh = -1;
                
	              --SmartBuffTooltip:SetOwner(SmartBuffFrame, "ANCHOR_NONE");
	              SmartBuffTooltip:ClearLines();
                local mainH,_,_ = SmartBuffTooltip:SetInventoryItem("player", 16);
                local offH,_,_ = SmartBuffTooltip:SetInventoryItem("player", 17);
                bMh, tMh, cMh, bOh, tOh, cOh = GetWeaponEnchantInfo();
                
                --SMARTBUFF_AddMsgD("Check weapon Buff");
                
                if (SMARTBUFF_Buffs[ct][buffnS].MH) then
                  if (mainH and SMARTBUFF_CanApplyWeaponBuff(buffnS, 16)) then
					          if (bMh) then
					            if (rbTime > 0 and cBuffs[i].DurationS >= 1) then
					              tMh = floor(tMh/1000);
					              charges = cMh;
					              if (charges == nil) then charges = -1; end
					              if (charges > 1) then cBuffs[i].CanCharge = true; end
					              --SMARTBUFF_AddMsgD(un .. " (WMH): " .. buffnS .. string.format(" %.0f sec left", tMh) .. ", " .. charges .. " charges left");
                        if (tMh <= rbTime or (SMARTBUFF_Options.CheckCharges and cBuffs[i].CanCharge and charges > 0 and charges <= SMARTBUFF_Options.MinCharges)) then
                          buff = buffnS;
                          bt = tMh;
                          bExpire = true;
                        end
						          end
					          else
                      handtype = "main";
					            buff = buffnS;
					          end
					        else
					          --SMARTBUFF_AddMsgD("Weapon Buff cannot be cast, no mainhand weapon equipped or wrong weapon/stone type");
					        end
					      end
                
                if (SMARTBUFF_Buffs[ct][buffnS].OH and not bExpire and handtype == "") then
                  if (offH and SMARTBUFF_CanApplyWeaponBuff(buffnS, 17)) then
					          if (bOh) then
					            if (rbTime > 0 and cBuffs[i].DurationS >= 1) then
					              tOh = floor(tOh/1000);
					              charges = cOh;
					              if (charges == nil) then charges = -1; end
					              if (charges > 1) then cBuffs[i].CanCharge = true; end
					              --SMARTBUFF_AddMsgD(un .. " (WOH): " .. buffnS .. string.format(" %.0f sec left", tOh) .. ", " .. charges .. " charges left");
                        if (tOh <= rbTime or (SMARTBUFF_Options.CheckCharges and cBuffs[i].CanCharge and charges > 0 and charges <= SMARTBUFF_Options.MinCharges)) then
                          buff = buffnS;
                          bt = tOh;
                          bExpireOh = true;                          
                        end					            
						          end
					          else
                      handtype = "off";
					            buff = buffnS;
					          end
					        else
					          --SMARTBUFF_AddMsgD("Weapon Buff cannot be cast, no offhand weapon equipped or wrong weapon/stone type");
					        end
					      end
                
                if (buff and cBuffs[i].Type == SMARTBUFF_CONST_INV) then
                  local cr = SMARTBUFF_CountReagent(buffnS);
                  if (cr > 0) then
                    --SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found");
                  else
                    --SMARTBUFF_AddMsgD("No " .. buffnS .. " found");
                    buff = nil;
                  end
                end                
					      
					    -- Normal buff ------------------------------------------------------------------------
              else
                local index = nil;
                
                -- cleanup single timer, if a group buff exists
                if (unit ~= "target" and cBuffs[i].IDG ~= nil) then
                  buff, index, buffname = SMARTBUFF_CheckUnitBuffs(unit, cBuffs[i].BuffG, nil);
                  if (buff == nil and cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                    cBuffTimer[unit][buffnS] = nil;
                    --SMARTBUFF_AddMsgD(un .. " (S): " .. buffnS .. " timer reset");
                  end                 
                end
                
                -- check timer object
                buff, index, buffname = SMARTBUFF_CheckUnitBuffs(unit, buffnS, cBuffs[i].BuffG);
                if (unit ~= "target" and buff == nil and cBuffs[i].DurationS >= 1 and rbTime > 0) then
                  if (SMARTBUFF_IsPlayer(unit)) then
                    bt = GetPlayerBuffTimeLeft(index);
                    
                    if (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                      local tbt = cBuffs[i].DurationS - (GetTime() - cBuffTimer[unit][buffnS]);
                      if (bt - tbt > rbTime) then
                        bt = tbt;
                      end
                    end
                    
                    charges = GetPlayerBuffApplications(index);
                    if (charges == nil) then charges = -1; end
                    if (charges > 1) then cBuffs[i].CanCharge = true; end
                    bufftarget = nil;
                    --SMARTBUFF_AddMsgD(un .. " (P): " .. index .. ". " .. GetPlayerBuffTexture(index) .. "(" .. charges .. ") - " .. buffnS .. string.format(" %.0f sec left", bt));
                  elseif (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                    bt = cBuffs[i].DurationS - (GetTime() - cBuffTimer[unit][buffnS]);
                    bufftarget = nil;
                    --SMARTBUFF_AddMsgD(un .. " (S): " .. buffnS .. string.format(" %.0f sec left", bt));                    
                  elseif (cBuffs[i].BuffG ~= nil and cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][cBuffs[i].BuffG] ~= nil) then
                    bt = cBuffs[i].DurationG - (GetTime() - cBuffTimer[subgroup][cBuffs[i].BuffG]);
                    if (type(subgroup) == "number") then
                      bufftarget = SMARTBUFF_MSG_GROUP .. " " .. subgroup;
                    else
                      bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
                    end
                    --SMARTBUFF_AddMsgD(bufftarget .. ": " .. cBuffs[i].BuffG .. string.format(" %.0f sec left", bt));                    
                  elseif (cBuffs[i].BuffG ~= nil and cBuffTimer[uc] ~= nil and cBuffTimer[uc][cBuffs[i].BuffG] ~= nil) then
                    bt = cBuffs[i].DurationG - (GetTime() - cBuffTimer[uc][cBuffs[i].BuffG]);
                    bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
                    --SMARTBUFF_AddMsgD(bufftarget .. ": " .. cBuffs[i].BuffG .. string.format(" %.0f sec left", bt));                    
                  else
                    bt = nil;
                  end
                  
                  if ((bt and bt <= rbTime) or (SMARTBUFF_Options.CheckCharges and cBuffs[i].CanCharge and charges > 0 and charges <= SMARTBUFF_Options.MinCharges)) then
                    if (buffname) then
                      buff = buffname;
                    else
                      buff = buffnS;
                    end
                    bExpire = true;
                  end
                end
                
                -- check if the group buff is active, in this case it is not possible to cast the single buff
                if (buffname and mode ~= 1 and buffname ~= buffnS) then
                  buff = nil;
                  --SMARTBUFF_AddMsgD("Group buff is active, single buff canceled!");
                end

              end -- END normal buff

              -- check if shapeshifted and cancel buff if it is not possible to cast it
              if (buff and cBuffs[i].Type ~= SMARTBUFF_CONST_TRACK and cBuffs[i].Type ~= SMARTBUFF_CONST_FORCESELF) then
                --isShapeshifted = true;
                --sShapename = "Moonkingestalt";
                if (isShapeshifted) then
                  if (string.find(cBuffs[i].Exclude, sShapename)) then
                    --SMARTBUFF_AddMsgD("Cast " .. buff .. " while shapeshifted");
                  else
                    if(cBuffs[i].Exclude == SMARTBUFF_DRUID_CAT) then
                      buff = nil;
                    end                  
                    if (buff and mode ~= 1) then
                      sMsgWarning = SMARTBUFF_MSG_SHAPESHIFT .. ": " .. sShapename;
                      buff = nil;
                    end
                  end
                else
                  if(cBuffs[i].Exclude == SMARTBUFF_DRUID_CAT) then
                    buff = nil;
                  end
                end
              end
              
              if (buff) then
                --if (cBuffs[i].IDS) then
                  --SMARTBUFF_AddMsgD("Checking " ..i .. " - " .. cBuffs[i].IDS .. " " .. buffnS);
                --end
                
                -- Cast mode ---------------------------------------------------------------------------------------
                if (mode == 0 or mode == 5) then
                  currentUnit = nil;
                  currentSpell = nil;
                  
                  --try to apply weapon buffs on main/off hand
                  if (cBuffs[i].Type == SMARTBUFF_CONST_INV) then
                    local bag, slot, count, _ = SMARTBUFF_FindReagent(buffnS);
                    if (count > 0 and (handtype == "main" or bExpire)) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_ITEM, buffnS, 16, "player", cBuffs[i].Type;
                    end
                    if (count > 0 and (handtype == "off" or bExpireOh)) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_ITEM, buffnS, 17, "player", cBuffs[i].Type;
                    end                      
                    r = 50;
                  elseif (cBuffs[i].Type == SMARTBUFF_CONST_WEAPON) then
                    if (handtype == "main" or bExpire) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_SPELL, buffnS, 16, "player", cBuffs[i].Type;
                    end
                    if (handtype == "off" or bExpireOh) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_SPELL, buffnS, 17, "player", cBuffs[i].Type;
                    end                      
                    r = 50;
                    
                  -- eat food
                  elseif (cBuffs[i].Type == SMARTBUFF_CONST_FOOD) then
                    local bag, slot, count, _ = SMARTBUFF_FindReagent(buffnS);
                    if (count > 0 or bExpire) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_ITEM, buffnS, 0, "player", cBuffs[i].Type;
                    end
                    r = 50;              
                  
                  -- try to cast buff
                  else
                    r = SMARTBUFF_doCast(unit, cBuffs[i].IDS, buffnS, cBuffs[i].LevelsS, cBuffs[i].Type);
                    if (r == 0) then
                      currentUnit = unit;
                      currentSpell = buffnS;
                    end
                  end
                
                -- Check mode ---------------------------------------------------------------------------------------
                elseif (mode == 1) then
                  currentUnit = nil;
                  currentSpell = nil;
                  if (bufftarget == nil) then bufftarget = un; end
                  
                  if (SMARTBUFF_CheckUnitLevel(unit, cBuffs[i].IDS, cBuffs[i].LevelsS) ~= nil or cBuffs[i].Type == SMARTBUFF_CONST_INV or cBuffs[i].Type == SMARTBUFF_CONST_FOOD) then
                    -- clean up buff timer, if expired
                    if (bt and bt < 0 and (bExpire or bExpireOh)) then 
                      bt = 0;
                      if (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                        cBuffTimer[unit][buffnS] = nil;
                        --SMARTBUFF_AddMsgD(un .. " (S): " .. buffnS .. " timer reset");
                      end
                      if (cBuffs[i].IDG ~= nil) then
                        if (cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][cBuffs[i].BuffG] ~= nil) then
                          cBuffTimer[subgroup][cBuffs[i].BuffG] = nil;
                          --SMARTBUFF_AddMsgD("Group " .. subgroup .. ": " .. buffnS .. " timer reset");
                        end                  
                        if (cBuffTimer[uc] ~= nil and cBuffTimer[uc][cBuffs[i].BuffG] ~= nil) then
                          cBuffTimer[uc][cBuffs[i].BuffG] = nil;
                          --SMARTBUFF_AddMsgD("Class " .. uc .. ": " .. cBuffs[i].BuffG .. " timer reset");
                        end
                      end
                      tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + 0.5;
                      return 0;
                    end
                                       
                    SMARTBUFF_SetMissingBuffMessage(bufftarget, buff, cBuffs[i].CanCharge, charges, bt, bExpire, bExpireOh);
                    SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, cBuffs[i].IconS);
                    return 0;
                  end
                end
                
                if (r == 0) then
                  -- target buffed
                  -- Message will printed in the "SPELLCAST_STOP" event
                  sMsgWarning = "";
                  return 0, SMARTBUFF_ACTION_SPELL, buffnS, -1, unit, cBuffs[i].Type;
                elseif (r == 1) then
                  -- spell cooldown
                  if (mode == 0) then SMARTBUFF_AddMsgWarn(buffnS .. " " .. SMARTBUFF_MSG_CD); end
                  return 1;
                elseif (r == 2) then
                  -- can not target
                  if (mode == 0 and ucf ~= SMARTBUFF_DEMONTYPE) then SMARTBUFF_AddMsgD("Can not target " .. un); end
                elseif (r == 3) then
                  -- target oor
                  if (mode == 0) then SMARTBUFF_AddMsgWarn(un .. " " .. SMARTBUFF_MSG_OOR); end
                  break;
                elseif (r == 4) then
                  -- spell cooldown > maxSkipCoolDown
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " " .. SMARTBUFF_MSG_CD .. " > " .. maxSkipCoolDown); end
                elseif (r == 5) then
                  -- target to low
                  if (mode == 0) then SMARTBUFF_AddMsgD(un .. " is to low to get buffed with " .. buffnS); end
                elseif (r == 6) then
                  -- not enough mana/rage/energy
                  sMsgWarning = SMARTBUFF_MSG_OOM;
                elseif (r == 7) then
                  -- tracking ability is already active
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " not used, other ability already active"); end
                elseif (r == 8) then
                  -- actionslot is not defined
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " has no actionslot"); end
                elseif (r == 9) then
                  -- spell ID not found
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " spellID not found"); end
                elseif (r == 10) then
                  -- target could not buffed
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not buffed on " .. un); end
                elseif (r == 50) then
                  -- weapon buff could not applied
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not applied"); end
                else
                  -- no spell selected
				      	  if (mode == 0) then SMARTBUFF_AddMsgD(SMARTBUFF_MSG_CHAT); end
                end
              else
                -- finished
                if (mode == 0) then SMARTBUFF_AddMsgD(un .. " nothing to buff"); end
              end
            else
              -- target does not need this buff
              if (mode == 0) then SMARTBUFF_AddMsgD(un .. " does not need " .. buffnS); end            
            end
          else
            -- cooldown
            if (sMsgWarning == "") then
              sMsgWarning = SMARTBUFF_MSG_CD;
            end
          end
        end -- group or self
      end
      i = i + 1;
    end -- while buff
      
  end
  return 3;
end
-- END SMARTBUFF_BuffUnit


function SMARTBUFF_IsInList(unit, unitname, list)
  if (list ~= nil) then
    for un in pairs(list) do
      if (un ~= nil and UnitIsPlayer(unit) and un == unitname) then
        return true;
      end
    end
  end
  return false;
end


function SMARTBUFF_SetMissingBuffMessage(target, buff, bCanCharge, nCharges, tBuffTimeLeft, bExpire, bExpireOh)
  -- show splash buff message
  if (SMARTBUFF_Options.ToggleAutoSplash and not SmartBuffOptionsFrame:IsVisible()) then
    local sd = SMARTBUFF_Options.SplashDuration;
    if (SMARTBUFF_Options.CheckCharges and bCanCharge and nCharges > 0 and nCharges <= SMARTBUFF_Options.MinCharges and (bExpire or bExpireOh)) then
      SmartBuffSplashFrame:AddMessage(target .. "\n" .. SMARTBUFF_MSG_REBUFF .. " " .. buff .. ": " .. nCharges .. " " .. SMARTBUFF_MSG_CHARGES .. " " .. SMARTBUFF_MSG_LEFT, 1, 1, 1, 1, sd);
    elseif (bExpire or bExpireOh) then
      SmartBuffSplashFrame:AddMessage(target .. "\n" .. SMARTBUFF_MSG_REBUFF .. " " .. buff .. string.format(": %.0f", tBuffTimeLeft) .. " sec " .. SMARTBUFF_MSG_LEFT, 1, 1, 1, 1, sd);
    else
      SmartBuffSplashFrame:AddMessage(target .. " " .. SMARTBUFF_MSG_NEEDS .. " " .. buff, 1, 1, 1, 1, sd);
    end
  end
  
  -- show chat buff message
  if (SMARTBUFF_Options.ToggleAutoChat) then
    if (SMARTBUFF_Options.CheckCharges and bCanCharge and nCharges > 0 and nCharges <= SMARTBUFF_Options.MinCharges and (bExpire or bExpireOh)) then
      SMARTBUFF_AddMsgWarn(target .. ": " .. SMARTBUFF_MSG_REBUFF .. " " .. buff .. ", " .. nCharges .. " " .. SMARTBUFF_MSG_CHARGES .. " " .. SMARTBUFF_MSG_LEFT, true);
    elseif (bExpire or bExpireOh) then
      SMARTBUFF_AddMsgWarn(target .. ": " .. SMARTBUFF_MSG_REBUFF .. " " .. buff .. string.format(", %.0f", tBuffTimeLeft) .. " sec " .. SMARTBUFF_MSG_LEFT, true);
    else
      SMARTBUFF_AddMsgWarn(target .. " " .. SMARTBUFF_MSG_NEEDS .. " " .. buff, true);
    end
  end
  
  -- play sound
  if (SMARTBUFF_Options.ToggleAutoSound) then
    PlaySound(SMARTBUFF_CONST_AUTOSOUND);
  end
end


-- check if a spell/reagent could applied on a weapon
function SMARTBUFF_CanApplyWeaponBuff(buff, slot)
  local cWeaponTypes = nil;
  if (string.find(buff, SMARTBUFF_WEAPON_SHARP_PATTERN)) then
    cWeaponTypes = SMARTBUFF_WEAPON_SHARP;
  elseif (string.find(buff, SMARTBUFF_WEAPON_BLUNT_PATTERN)) then
    cWeaponTypes = SMARTBUFF_WEAPON_BLUNT;
  else
    cWeaponTypes = SMARTBUFF_WEAPON_STANDARD;
  end
  
  local itemLink = GetInventoryItemLink("player", slot);
  local _, _, itemCode = string.find(itemLink, "(%d+):");
  local _, _, _, _, _, itemType, itemSubType = GetItemInfo(itemCode);

  --if (itemType and itemSubType) then
  --  SMARTBUFF_AddMsgD("Type: " .. itemType .. ", Subtype: " .. itemSubType);
  --end
  
  if (cWeaponTypes and itemSubType) then
    for _, weapon in pairs(cWeaponTypes) do
      --SMARTBUFF_AddMsgD(weapon);
      if (string.find(itemSubType, weapon)) then
        --SMARTBUFF_AddMsgD("Can apply " .. buff .. " on " .. itemSubType);
        return true;
      end
    end
  end                      
  return false;
end
-- END SMARTBUFF_CanApplyWeaponBuff


-- Check the unit blacklist
function SMARTBUFF_checkBlacklist()
  local t = GetTime();
  for unit in pairs(cBlacklist) do
    if (t > (cBlacklist[unit] + SMARTBUFF_Options.BlacklistTimer)) then
      cBlacklist[unit] = nil;
    end
  end
end
-- END SMARTBUFF_checkBlacklist


-- Casts a spell
function SMARTBUFF_doCast(unit, id, spellName, levels, type)
  if (id == nil) then return 9; end
  if (type == SMARTBUFF_CONST_TRACK and (GetTrackingTexture() ~= "Interface\\Minimap\\Tracking\\None")) then  
  --if (type == SMARTBUFF_CONST_TRACK and GetTrackingTexture()) then
    --local iconTrack = GetTrackingTexture();
    --SMARTBUFF_AddMsgD("Track already enabled: " .. iconTrack);
    return 7; 
  end
  	
	-- check if spell has cooldown
	local _, cd = GetSpellCooldown(id, SMARTBUFF_BOOK_TYPE_SPELL)
	if (not cd) then
	  -- move on
	elseif (cd > maxSkipCoolDown) then
	  return 4;
  elseif (cd > 0) then 
    return 1;
  end
  
  -- Rangecheck, NEW TBC
  --SMARTBUFF_AddMsgD("In range: " .. IsSpellInRange(spellName, unit));
	if (type == SMARTBUFF_CONST_GROUP and IsSpellInRange(spellName, unit) ~= 1) then
		return 3;
	end
	
	-- check if target is to low for this spell
	id = SMARTBUFF_CheckUnitLevel(unit, id, levels);
	if (id == nil) then
	  return 5;
	end
     
  -- check if you have enough mana/energy/rage to cast, NEW TBC
  local isUsable, notEnoughMana = IsUsableSpell(spellName);
  if (notEnoughMana) then
    return 6;
  end
  
  return 0;
end
-- END SMARTBUFF_doCast


-- checks if the unit is the player
function SMARTBUFF_IsPlayer(unit)
  if (UnitIsUnit("player", unit)) then
    return true;
  end
  return false;
end
-- END SMARTBUFF_IsPlayer


-- Will return the name of the buff to cast
function SMARTBUFF_CheckUnitBuffs(unit, buffS, buffG, bIgnorePattern) 
  local index = 0;
  local bIndex = 0;
  local buff = nil;
  local timeleft = nil;
  local icon = nil;
  local b = false;
  local pat = "";
  local pattern = "";
  local isPlayer = false;
  
  if (not bIgnorePattern and cPatterns ~= nil) then
    for _, pat in pairs(cPatterns) do
      if (string.find(buffS, pat)) then
        pattern = pat;
        b = true;
        break;
      end
    end
  end
  
  if (SMARTBUFF_IsPlayer(unit)) then
    isPlayer = true;
    index = 0;
  else
    index = 1;
  end
 
  while (index <= maxBuffs) do
    icon = nil;
    buff = nil;
    if (isPlayer) then
      --bIndex = index;
      --name, rank = GetPlayerBuffName(id or "name"[,"rank"]);
      --buff, _ = GetPlayerBuffName(bIndex);
      
      bIndex, _ = GetPlayerBuff(index, "HELPFUL|PASSIVE");
      if (bIndex >= 0) then
        timeleft = GetPlayerBuffTimeLeft(bIndex);
        icon = GetPlayerBuffTexture(bIndex)
      end
    else
      bIndex = index;
      --name, rank, icon, count, duration, timeLeft = UnitBuff("target", i) -- Now returns duration and timeLeft for buffs you can cast (those with times come first in the list)
      buff, _, icon, _, _, timeleft = UnitBuff(unit, bIndex);
    end
      	  
  	if (icon) then
  	  if (not buff) then
        buff = SMARTBUFF_GetBuffName(unit, bIndex, 1);
      end
      if (buff and buffS) then
        --SMARTBUFF_AddMsgD(UnitName(unit) .. ": " .. bIndex .. ". " .. buff .. " - " .. icon, 0, 1, 0.5);
        
        if (b and string.find(buff, pattern)) then
          return nil, bIndex, buffS, timeleft;
        end

        if (string.lower(buffS) == string.lower(buff)) then
          -- BuffS found
          return nil, bIndex, buffS, timeleft;
        elseif (buffG ~= nil and string.lower(buffG) == string.lower(buff)) then
          -- BuffG found
          return nil, bIndex, buffG, timeleft;
        end     
      end
    end
    index = index + 1;
  end
  -- Buff not found, return default buff
  return buffS, nil, nil, nil;
end
-- END SMARTBUFF_CheckUnitBuffs


-- Will return the lower Id of the spell, if the unit level is lower
function SMARTBUFF_CheckUnitLevel(unit, spellId, spellLevels)
  if (spellLevels == nil or spellId == nil) then
    return spellId;
  end
  
  local Id = spellId;
  local uLevel = UnitLevel(unit);
  local spellName, sRank = GetSpellName(Id, SMARTBUFF_BOOK_TYPE_SPELL);
  if (sRank == nil or sRank == "") then 
    sRank = "Rank 1";
  end
  local _, _, spellRank = string.find(sRank, "(%d+)");
  
  spellRank = tonumber(spellRank);
  i = spellRank;
  
  --SMARTBUFF_AddMsgD(spellName .. sRank .. ":" .. spellRank .. ", " .. spellLevels[i]);
  
  while (i >= 1) do
    if (uLevel >= (spellLevels[i] - 10)) then
      break;
    end
    i = i - 1;
  end
  
  if (i > 0) then
    Id = Id - (spellRank - i);
    --SMARTBUFF_AddMsgD(uLevel .. " " .. spellName .. " Rank " .. i .. " - ID = " .. Id);
  else
    Id = nil;
    --SMARTBUFF_AddMsgD(spellName .. ": no rank available for this level");
  end;
  
  return Id, i;
end
-- END SMARTBUFF_CheckUnitLevel


-- Will return the name/description of the buff 
function SMARTBUFF_GetBuffName(unit, buffIndex, line)
	local i = buffIndex;
	local name = nil;

  if (i < 0 or i > maxBuffs) then
    return nil;
  end	  
	--SmartBuffTooltip:SetOwner(SmartBuffFrame, "ANCHOR_NONE");
	SmartBuffTooltip:ClearLines();
  if (SMARTBUFF_IsPlayer(unit)) then
    SmartBuffTooltip:SetPlayerBuff(i);
  else
    SmartBuffTooltip:SetUnitBuff(unit, i);
  end  
	local obj = getglobal("SmartBuffTooltipTextLeft" .. line);
	if (obj) then
    name = obj:GetText();
  end
	return name;
end
-- END SMARTBUFF_GetBuffName


-- Checks if the player is mounted, NEW TBC not longer necessary
function SMARTBUFF_IsMounted()
  local found = false;
  local id = 0;
  local bIndex = nil;
  local buff = nil;
  while (id < 16) do
    bIndex, _ = GetPlayerBuff(id, "HELPFUL|PASSIVE");
    if (bIndex >= 0) then
      icon = GetPlayerBuffTexture(bIndex);
      buff = SMARTBUFF_GetBuffName("player", bIndex, 2);
      --if (buff and icon) then SMARTBUFF_AddMsgD(id .. ". " .. buff .. " - " .. icon); end
      if (buff and icon and string.find(buff, SMARTBUFF_MOUNT)) then
        --SMARTBUFF_AddMsgD("Mounted: " .. buff);
        found = true;
        break;
      end
    end
    id = id + 1;
  end
  return found;
end
-- END Checks if the player is mounted


-- IsFeignDeath(unit)
function SMARTBUFF_IsFeignDeath(unit)
  return UnitIsFeignDeath(unit);
  --[[
  local name, icon;
	for i = 1, 20, 1 do
		name, _, icon = UnitBuff(unit, i);
		if (buff) then
			if (string.find(string.lower(icon), "feigndeath")) then
				return true;
			end
		else
			break;
		end
	end
	]]--
end
-- END SMARTBUFF_IsFeignDeath


-- Loops through all of the debuffs currently active looking for a texture string match
function SMARTBUFF_IsDebuffTexture(unit, debufftex)
  local active = false;
  local i = 1;
  local name, icon;
  -- name,rank,icon,count,type = UnitDebuff("unit", id or "name"[,"rank"])
  while (UnitDebuff(unit, i)) do
    name, _, icon, _, _ = UnitDebuff(unit, i);
    --SMARTBUFF_AddMsgD(i .. ". " .. name .. ", " .. icon);  
    if (string.find(icon, debufftex)) then
      active = true;
      break
    end
    i = i + 1;
  end
  return active;
end
-- END SMARTASPECT_IsDebuffTex


-- Returns the number of a reagent currently in player's bag
function SMARTBUFF_CountReagent(reagent)
  if (reagent == nil) then return 99; end
	local n = 0;
	local bag = 0;
	local slot = 0;
	local itemName, texture, count;
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
		  itemName = GetContainerItemLink(bag, slot);
			if itemName then
				if string.find(itemName, "%[" .. reagent .. "%]") then
					texture, count = GetContainerItemInfo(bag, slot);
					n = n + count;
				end
			end
		end
	end
	return n;
end

function SMARTBUFF_FindReagent(reagent)
  if (reagent == nil) then return 99; end
	local n = 0;
	local bag = 0;
	local slot = 0;
	local itemName, texture, count;
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
		  itemName = GetContainerItemLink(bag, slot);
			if itemName then
				if string.find(itemName, "%[" .. reagent .. "%]") then
					texture, count = GetContainerItemInfo(bag, slot);
          return bag, slot, count, texture;
				end
			end
		end
	end
	return nil, nil, 0, nil;
end
-- END Reagent functions


-- check the current zone and set buff template
function SMARTBUFF_CheckLocation()
  local posX, posY = GetPlayerMapPosition("player");
  local zone = "";
  local i = 0;
  local tmp = nil;
  local b = false;
  
  zone = GetRealZoneText();
  SMARTBUFF_AddMsgD("Current zone: " .. zone .. ", x = " .. posX .. ", y = " .. posY .. " - last zone: " .. sLastInstance);
  if (zone ~= sLastInstance) then
    if (SMARTBUFF_IsPlayerInBG() or IsActiveBattlefieldArena()) then
      tmp = SMARTBUFF_TEMPLATES[4];
    else
      if (SMARTBUFF_Options.AutoSwitchTemplateInst) then
        i = 1;
        for _ in pairs(SMARTBUFF_INSTANCES) do
          if (string.find(string.lower(zone), string.lower(SMARTBUFF_INSTANCES[i]))) then
            b = true;
            break;
          end
          i = i + 1;
        end
        tmp = nil;
        if (b) then 
          if     (i == 1) then tmp = SMARTBUFF_TEMPLATES[5];
          elseif (i == 2) then tmp = SMARTBUFF_TEMPLATES[6];
          elseif (i == 3) then tmp = SMARTBUFF_TEMPLATES[7];
          elseif (i == 4) then tmp = SMARTBUFF_TEMPLATES[8];
          elseif (i == 5) then tmp = SMARTBUFF_TEMPLATES[9];
          elseif (i == 6) then tmp = SMARTBUFF_TEMPLATES[10];
          --elseif (i > 6) then tmp = SMARTBUFF_TEMPLATES[4];
          end
        end
      end
    end
    
    --SMARTBUFF_AddMsgD("Current tmpl: " .. currentTemplate .. " - new tmpl: " .. tmp);
    if (tmp and currentTemplate ~= tmp) then
      SMARTBUFF_AddMsg(SMARTBUFF_OFT_AUTOSWITCHTMP .. ": " .. currentTemplate .. " -> " .. tmp); 
      currentTemplate = tmp;
      sLastInstance = zone;
      SMARTBUFF_SetBuffs();
    end
  end
  isSetZone = false;
end
-- END SMARTBUFF_CheckLocation


-- checks if the player is inside a battleground
function SMARTBUFF_IsPlayerInBG()
  local b = false;
  local status, instanceID;
  for i = 1, MAX_BATTLEFIELD_QUEUES do
    status, _, instanceID, _, _ = GetBattlefieldStatus(i);
    if (status and instanceID ~= 0) then
      --SMARTBUFF_AddMsgD("Status = " .. status .. ", ID = " .. instanceID);
      b = true;
      break;
    end
  end
  return b;
end
-- END IsPlayerInBG


-- Helper functions ---------------------------------------------------------------------------------------
function SMARTBUFF_toggleBool(b, msg)
  if (not b or b == nil) then
    b = true;
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. GR .. "On");
  else
    b = false
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. RD .."Off");
  end
  return b;
end

function SMARTBUFF_BoolState(b, msg)
  if (b) then
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. GR .. "On");
  else
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. RD .."Off");
  end
end

function SMARTBUFF_Split(msg, char)
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
-- END Bool helper functions


-- Init the SmartBuff variables ---------------------------------------------------------------------------------------
function SMARTBUFF_Options_Init()
  if (isInit) then return; end 

	_, sPlayerClass = UnitClass("player");
	sRealmName = GetCVar("RealmName");
	sPlayerName = UnitName("player");
	sID = sRealmName .. ":" .. sPlayerName;
  --AutoSelfCast = GetCVar("autoSelfCast");
  
  
  if (not SMARTBUFF_Buffs) then SMARTBUFF_Buffs = { }; end
  if (not SMARTBUFF_Options) then SMARTBUFF_Options = { }; end
	if (SMARTBUFF_Options.Toggle == nil) then	SMARTBUFF_Options.Toggle = true; end
	
	if (SMARTBUFF_Options.ToggleAuto == nil) then	SMARTBUFF_Options.ToggleAuto = true; end
	if (SMARTBUFF_Options.AutoTimer == nil) then	SMARTBUFF_Options.AutoTimer = 10; end
	if (SMARTBUFF_Options.BlacklistTimer == nil) then	SMARTBUFF_Options.BlacklistTimer = 5; end
	if (SMARTBUFF_Options.ToggleAutoCombat == nil) then	SMARTBUFF_Options.ToggleAutoCombat = false; end
  if (SMARTBUFF_Options.ToggleAutoChat == nil) then	SMARTBUFF_Options.ToggleAutoChat = false; end
  if (SMARTBUFF_Options.ToggleAutoSplash == nil) then	SMARTBUFF_Options.ToggleAutoSplash = true; end
  if (SMARTBUFF_Options.ToggleAutoSound == nil) then	SMARTBUFF_Options.ToggleAutoSound = false; end
  if (SMARTBUFF_Options.CheckCharges == nil) then	SMARTBUFF_Options.CheckCharges = true; end
  --if (SMARTBUFF_Options.ToggleAutoRest == nil) then	SMARTBUFF_Options.ToggleAutoRest = true; end
 	if (SMARTBUFF_Options.RebuffTimer == nil) then	SMARTBUFF_Options.RebuffTimer = 20; end
 	if (SMARTBUFF_Options.SplashDuration == nil) then	SMARTBUFF_Options.SplashDuration = 2; end
  
	if (SMARTBUFF_Options.BuffTarget == nil) then	SMARTBUFF_Options.BuffTarget = false; end
	if (SMARTBUFF_Options.BuffPvP == nil) then	SMARTBUFF_Options.BuffPvP = false; end
	if (SMARTBUFF_Options.BuffInCities == nil) then	SMARTBUFF_Options.BuffInCities = true; end
	if (SMARTBUFF_Options.AdvGrpBuffCheck == nil) then	SMARTBUFF_Options.AdvGrpBuffCheck = false; end
	if (SMARTBUFF_Options.AdvGrpBuffRange == nil) then	SMARTBUFF_Options.AdvGrpBuffRange = true; end
	if (SMARTBUFF_Options.AntiDaze == nil) then	SMARTBUFF_Options.AntiDaze = true; end
	
	if (SMARTBUFF_Options.ScrollWheel ~= nil and SMARTBUFF_Options.ScrollWheelUp == nil) then	SMARTBUFF_Options.ScrollWheelUp = SMARTBUFF_Options.ScrollWheel; end
	if (SMARTBUFF_Options.ScrollWheel ~= nil and SMARTBUFF_Options.ScrollWheelDown == nil) then	SMARTBUFF_Options.ScrollWheelDown = SMARTBUFF_Options.ScrollWheel; end
	if (SMARTBUFF_Options.ScrollWheelUp == nil) then	SMARTBUFF_Options.ScrollWheelUp = true; end
	if (SMARTBUFF_Options.ScrollWheelDown == nil) then	SMARTBUFF_Options.ScrollWheelDown = true; end
	
	if (SMARTBUFF_Options.InCombat == nil) then	SMARTBUFF_Options.InCombat = false; end
	if (SMARTBUFF_Options.AutoSwitchTemplate == nil) then	SMARTBUFF_Options.AutoSwitchTemplate = false; end
	if (SMARTBUFF_Options.AutoSwitchTemplateInst == nil) then	SMARTBUFF_Options.AutoSwitchTemplateInst = false; end

	if (SMARTBUFF_Options.ToggleGrp == nil) then	SMARTBUFF_Options.ToggleGrp = {true, false, false, false, false, false, false, false}; end
	if (SMARTBUFF_Options.ToggleSubGrpChanged == nil) then	SMARTBUFF_Options.ToggleSubGrpChanged = false; end
	if (SMARTBUFF_Options.UISync == nil) then	SMARTBUFF_Options.UISync = true; end
	if (SMARTBUFF_Options.CompMode == nil) then	SMARTBUFF_Options.CompMode = false; end
	
	if (SMARTBUFF_Options.ToggleMsgNormal == nil) then	SMARTBUFF_Options.ToggleMsgNormal = false; end
	if (SMARTBUFF_Options.ToggleMsgWarning == nil) then	SMARTBUFF_Options.ToggleMsgWarning = false; end
	if (SMARTBUFF_Options.ToggleMsgError == nil) then	SMARTBUFF_Options.ToggleMsgError = false; end
	
	if (SMARTBUFF_Options.HideMmButton == nil) then	SMARTBUFF_Options.HideMmButton = false; end
  if (SMARTBUFF_Options.HideSAButton == nil) then	SMARTBUFF_Options.HideSAButton = false; end
	
	if (SMARTBUFF_Options.MinCharges == nil) then	
	  if (sPlayerClass == "SHAMAN" or sPlayerClass == "PRIEST") then
	    SMARTBUFF_Options.MinCharges = 1;
	  else
	    SMARTBUFF_Options.MinCharges = 3;
	  end
	end
	
	if (SMARTBUFF_Options.ShowMiniGrp == nil) then
	  if (sPlayerClass == "DRUID" or sPlayerClass == "MAGE" or sPlayerClass == "PRIEST") then
	    SMARTBUFF_Options.ShowMiniGrp = true;
	  else
	    SMARTBUFF_Options.ShowMiniGrp = false;
	  end
	end
  
  if (not SMARTBUFF_Options.AddList) then SMARTBUFF_Options.AddList = { }; end
  if (not SMARTBUFF_Options.IgnoreList) then SMARTBUFF_Options.IgnoreList = { }; end
	
	if (SMARTBUFF_Options.LastTemplate == nil) then	SMARTBUFF_Options.LastTemplate = SMARTBUFF_TEMPLATES[1]; end
	local b = false;
	while (SMARTBUFF_TEMPLATES[i] ~= nil) do
	  if (SMARTBUFF_TEMPLATES[i] == SMARTBUFF_Options.LastTemplate) then
	    b = true;
	    break;
	  end
	  i = i + 1;
	end
  if (not b) then 
    SMARTBUFF_Options.LastTemplate = SMARTBUFF_TEMPLATES[1];
  end
	currentTemplate = SMARTBUFF_Options.LastTemplate;
  
  if (SMARTBUFF_Options.OldWheelUp == nil) then SMARTBUFF_Options.OldWheelUp = ""; end
  if (SMARTBUFF_Options.OldWheelDown == nil) then SMARTBUFF_Options.OldWheelDown = ""; end
	
	if (SMARTBUFF_Options.SplashX == nil) then SMARTBUFF_Options.SplashX = 100; end
	if (SMARTBUFF_Options.SplashY == nil) then SMARTBUFF_Options.SplashY = -100; end
	if (SMARTBUFF_Options.CurrentFont == nil) then SMARTBUFF_Options.CurrentFont = 9; end
	iCurrentFont = SMARTBUFF_Options.CurrentFont;
	SMARTBUFF_Splash_ChangeFont(0);
	  
  if (SMARTBUFF_Options.FirstStart == nil) then SMARTBUFF_Options.FirstStart = "V0";	end
  if (SMARTBUFF_Options.Debug == nil) then SMARTBUFF_Options.Debug = false;	end 
	
  -- Cosmos support
  if(EarthFeature_AddButton) then 
    EarthFeature_AddButton(
      { id = SMARTBUFF_TITLE;
        name = SMARTBUFF_TITLE;
        subtext = SMARTBUFF_TITLE; 
        tooltip = "";      
        icon = imgSB;
        callback = SMARTBUFF_OptionsFrame_Toggle;
        test = nil;
      } )
  elseif (Cosmos_RegisterButton) then 
    Cosmos_RegisterButton(SMARTBUFF_TITLE, SMARTBUFF_TITLE, SMARTBUFF_TITLE, imgSB, SMARTBUFF_OptionsFrame_Toggle);
  end

	-- CTMod support
	if(CT_RegisterMod) then
		CT_RegisterMod(
			SMARTBUFF_VERS_TITLE,
			SMARTBUFF_SUBTITLE,
			5,
			imgSB,
			SMARTBUFF_DESC,
			"switch",
			"",
			SMARTBUFF_OptionsFrame_Toggle);
	end
    
  --hooksecurefunc("CastSpellByName", CastHook);
  --hooksecurefunc("CastSpell", CastSpellHook);
		
	SMARTBUFF_AddMsg(SMARTBUFF_VERS_TITLE .. " " .. SMARTBUFF_MSG_LOADED, true);
  SMARTBUFF_AddMsg("/sb menu - " .. SMARTBUFF_OFT_MENU, true);
	isInit = true;
  
	SMARTBUFF_CheckMiniMapButton();
  SMARTBUFF_ShowSAButton();
	SMARTBUFF_Splash_Hide();  
	
	if (SMARTBUFF_Options.FirstStart ~= SMARTBUFF_VERSION) then
	  SMARTBUFF_Options.FirstStart = SMARTBUFF_VERSION;
	  SMARTBUFF_OptionsFrame_Open(true);
	else
	  SMARTBUFF_SetBuffs();
	end
  SMARTBUFF_SetUnits();
  SMARTBUFF_RebindKeys();
end
-- END SMARTBUFF_Options_Init


function SMARTBUFF_RebindKeys()
  local i;
  for i = 1, GetNumBindings(), 1 do
    local s = "";
    local command, key1, key2 = GetBinding(i);
    
    if (key1 and key1 == "MOUSEWHEELUP" and command ~= "SmartBuff_KeyButton") then
      SMARTBUFF_Options.OldWheelUp = command;
      --SMARTBUFF_AddMsgD("Old wheel up: " .. command);
    elseif (key1 and key1 == "MOUSEWHEELDOWN" and command ~= "SmartBuff_KeyButton") then
      SMARTBUFF_Options.OldWheelDown = command;
      --SMARTBUFF_AddMsgD("Old wheel down: " .. command);
    end  
    
    if (command and command == "SMARTBUFF_BIND_TRIGGER") then
      s = i .. " = " .. command;
      if (key1) then
        s = s .. ", key1 = " .. key1 .. " rebound";
        SetBindingClick(key1, "SmartBuff_KeyButton");
      end
      if (key2) then
        s = s .. ", key2 = " .. key2 .. " rebound";
        SetBindingClick(key2, "SmartBuff_KeyButton");
      end
      --SMARTBUFF_AddMsgD(s);
      break;
    end
  end
  
  --SetBindingClick("F", "SmartBuff_KeyButton");
  if (SMARTBUFF_Options.ScrollWheelUp) then
    isKeyUpChanged = true;
    SetBindingClick("MOUSEWHEELUP", "SmartBuff_KeyButton", "MOUSEWHEELUP");
    --SMARTBUFF_AddMsgD("Set wheel up");
  else
    if (isKeyUpChanged) then
      isKeyUpChanged = false;
      SetBinding("MOUSEWHEELUP", SMARTBUFF_Options.OldWheelUp);
      --SMARTBUFF_AddMsgD("Set old wheel up: " .. SMARTBUFF_Options.OldWheelUp);
    end
  end
  
  if (SMARTBUFF_Options.ScrollWheelDown) then
    isKeyDownChanged = true;
    SetBindingClick("MOUSEWHEELDOWN", "SmartBuff_KeyButton", "MOUSEWHEELDOWN");
    --SMARTBUFF_AddMsgD("Set wheel down");
  else
    if (isKeyDownChanged) then
      isKeyDownChanged = false;
      SetBinding("MOUSEWHEELDOWN", SMARTBUFF_Options.OldWheelDown);
      --SMARTBUFF_AddMsgD("Set old wheel down: " .. SMARTBUFF_Options.OldWheelDown);
    end
  end  
  --SaveBindings(GetCurrentBindingSet());
end


-- SmartBuff commandline menu ---------------------------------------------------------------------------------------
function SMARTBUFF_command(msg)
  if (not isInit) then
    SMARTBUFF_AddMsgWarn(SMARTBUFF_VERS_TITLE.." not initialized correctly!", true);
    return;
  end
  
  if(msg == "toggle" or msg == "t") then
    SMARTBUFF_OToggle();
    SMARTBUFF_SetUnits();
  elseif (msg == "menu") then
    SMARTBUFF_OptionsFrame_Toggle();
  elseif (msg == "rbt") then
    SMARTBUFF_ResetBuffTimers();
  elseif (msg == "sbt") then
    SMARTBUFF_ShowBuffTimers();
  elseif (msg == "target") then
    if (SMARTBUFF_PreCheck(0)) then
      SMARTBUFF_checkBlacklist();
      SMARTBUFF_BuffUnit("target", 0, 0);
    end  
  elseif (msg == "debug") then
    SMARTBUFF_Options.Debug = SMARTBUFF_toggleBool(SMARTBUFF_Options.Debug, "Debug active = ");  
  elseif (msg == "open") then
    SMARTBUFF_OptionsFrame_Open(true);
  elseif (msg == "sync") then
    SMARTBUFF_SyncBuffTimers();
  elseif (msg == "rafp") then
    SmartBuffSplashFrame:ClearAllPoints();
    SmartBuffSplashFrame:SetPoint("CENTER", UIParent, "CENTER");
    SmartBuff_MiniMapButton:ClearAllPoints();
    SmartBuff_MiniMapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT");
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("CENTER", UIParent, "CENTER");
    SmartBuffOptionsFrame:ClearAllPoints();
    SmartBuffOptionsFrame:SetPoint("CENTER", UIParent, "CENTER");
    SmartBuff_MiniGroup:ClearAllPoints();
    SmartBuff_MiniGroup:SetPoint("CENTER", UIParent, "CENTER");
  elseif (msg == "reload") then
    SMARTBUFF_ShowSubGroupsOptions();
  else
    --SMARTBUFF_Check(0);
    SMARTBUFF_AddMsg(SMARTBUFF_VERS_TITLE, true);
    SMARTBUFF_AddMsg("Syntax: /sb [command] or /smartbuff [command]", true);
    SMARTBUFF_AddMsg("toggle  -  " .. SMARTBUFF_OFT, true);
    SMARTBUFF_AddMsg("menu     -  " .. SMARTBUFF_OFT_MENU, true);
    SMARTBUFF_AddMsg("target  -  " .. SMARTBUFF_OFT_TARGET, true);
    SMARTBUFF_AddMsg("rbt      -  " .. "Reset buff timers", true);
    SMARTBUFF_AddMsg("sbt      -  " .. "Show buff timers", true);
    SMARTBUFF_AddMsg("rafp     -  " .. "Reset all frame positions", true);
    SMARTBUFF_AddMsg("sync     -  " .. "Sync buff timers with UI", true);
  end
end
-- END SMARTBUFF_command


-- SmartBuff options toggle ---------------------------------------------------------------------------------------
function SMARTBUFF_OToggle()
  SMARTBUFF_Options.Toggle = SMARTBUFF_toggleBool(SMARTBUFF_Options.Toggle, "Active = ");
  SMARTBUFF_CheckMiniMapButton();
  if (SMARTBUFF_Options.Toggle) then
    SMARTBUFF_MiniGroup_Show();
    SMARTBUFF_SetUnits();
  else
    if (SmartBuff_MiniGroup:IsVisible()) then
      SmartBuff_MiniGroup:Hide();
    end
  end
end

function SMARTBUFF_OToggleAuto()
  SMARTBUFF_Options.ToggleAuto = not SMARTBUFF_Options.ToggleAuto;
end
function SMARTBUFF_OToggleAutoCombat()
  SMARTBUFF_Options.ToggleAutoCombat = not SMARTBUFF_Options.ToggleAutoCombat;
end
function SMARTBUFF_OToggleAutoChat()
  SMARTBUFF_Options.ToggleAutoChat = not SMARTBUFF_Options.ToggleAutoChat;
end
function SMARTBUFF_OToggleAutoSplash()
  SMARTBUFF_Options.ToggleAutoSplash = not SMARTBUFF_Options.ToggleAutoSplash;
end
function SMARTBUFF_OToggleAutoSound()
  SMARTBUFF_Options.ToggleAutoSound = not SMARTBUFF_Options.ToggleAutoSound;
end

--function SMARTBUFF_OToggleCheckCharges()
--  SMARTBUFF_Options.ToggleCheckCharges = not SMARTBUFF_Options.ToggleCheckCharges;
--end
--function SMARTBUFF_OToggleAutoRest()
--  SMARTBUFF_Options.ToggleAutoRest = not SMARTBUFF_Options.ToggleAutoRest;
--end

function SMARTBUFF_OAutoSwitchTmp()
  SMARTBUFF_Options.AutoSwitchTemplate = not SMARTBUFF_Options.AutoSwitchTemplate;
end
function SMARTBUFF_OAutoSwitchTmpInst()
  SMARTBUFF_Options.AutoSwitchTemplateInst = not SMARTBUFF_Options.AutoSwitchTemplateInst;
end

function SMARTBUFF_OBuffTarget()
  SMARTBUFF_Options.BuffTarget = not SMARTBUFF_Options.BuffTarget;
end

function SMARTBUFF_OBuffPvP()
  SMARTBUFF_Options.BuffPvP = not SMARTBUFF_Options.BuffPvP;
end

function SMARTBUFF_OBuffInCities()
  SMARTBUFF_Options.BuffInCities = not SMARTBUFF_Options.BuffInCities;
end

function SMARTBUFF_OAdvGrpBuffCheck()
  SMARTBUFF_Options.AdvGrpBuffCheck = not SMARTBUFF_Options.AdvGrpBuffCheck;
end
function SMARTBUFF_OAdvGrpBuffRange()
  SMARTBUFF_Options.AdvGrpBuffRange = not SMARTBUFF_Options.AdvGrpBuffRange;
end
function SMARTBUFF_OAntiDaze()
  SMARTBUFF_Options.AntiDaze = not SMARTBUFF_Options.AntiDaze;
end

function SMARTBUFF_OScrollWheelUp()
  SMARTBUFF_Options.ScrollWheelUp = not SMARTBUFF_Options.ScrollWheelUp;
  isKeyUpChanged = true;
end
function SMARTBUFF_OScrollWheelDown()
  SMARTBUFF_Options.ScrollWheelDown = not SMARTBUFF_Options.ScrollWheelDown;
  isKeyDownChanged = true;
end
function SMARTBUFF_OInCombat()
  SMARTBUFF_Options.InCombat = not SMARTBUFF_Options.InCombat;
end

function SMARTBUFF_OToggleGrp(i)
  SMARTBUFF_Options.ToggleGrp[i] = not SMARTBUFF_Options.ToggleGrp[i];
  if (SmartBuff_MiniGroup:IsVisible()) then
    SMARTBUFF_SetUnits();
  end
end

function SMARTBUFF_OToggleMiniGrp()
  SMARTBUFF_Options.ShowMiniGrp = not SMARTBUFF_Options.ShowMiniGrp;
end
function SMARTBUFF_OToggleSubGrpChanged()
  SMARTBUFF_Options.ToggleSubGrpChanged = not SMARTBUFF_Options.ToggleSubGrpChanged;
end

function SMARTBUFF_OToggleUISync()
  SMARTBUFF_Options.UISync = not SMARTBUFF_Options.UISync;
end
function SMARTBUFF_OToggleCompMode()
  SMARTBUFF_Options.CompMode = not SMARTBUFF_Options.CompMode;
end

function SMARTBUFF_OToggleMsgNormal()
  SMARTBUFF_Options.ToggleMsgNormal = not SMARTBUFF_Options.ToggleMsgNormal;
end
function SMARTBUFF_OToggleMsgWarning()
  SMARTBUFF_Options.ToggleMsgWarning = not SMARTBUFF_Options.ToggleMsgWarning;
end
function SMARTBUFF_OToggleMsgError()
  SMARTBUFF_Options.ToggleMsgError = not SMARTBUFF_Options.ToggleMsgError;
end

function SMARTBUFF_OHideMmButton()
  SMARTBUFF_Options.HideMmButton = not SMARTBUFF_Options.HideMmButton;
  SMARTBUFF_CheckMiniMapButton();
end
function SMARTBUFF_OHideSAButton()
  SMARTBUFF_Options.HideSAButton = not SMARTBUFF_Options.HideSAButton;
  SMARTBUFF_ShowSAButton();
end

function SMARTBUFF_OSelfFirst()
  SMARTBUFF_Buffs[currentTemplate].SelfFirst = not SMARTBUFF_Buffs[currentTemplate].SelfFirst;
end

function SMARTBUFF_OToggleBuff(s, i)
  local name = cBuffs[i].BuffS;  
  if (name == nil) then
    return;
  end
  
  if (s == "S") then
    SMARTBUFF_Buffs[currentTemplate][name].EnableS = not SMARTBUFF_Buffs[currentTemplate][name].EnableS;
    if (SMARTBUFF_Buffs[currentTemplate][name].EnableS) then
      SmartBuff_BuffSetup_Show(i);
    else
      SmartBuff_BuffSetup:Hide();
      iLastBuffSetup = -1;
      SmartBuff_PlayerSetup:Hide();
    end
  elseif (s == "G") then
    SMARTBUFF_Buffs[currentTemplate][name].EnableG = not SMARTBUFF_Buffs[currentTemplate][name].EnableG;
  end
  
end

function SMARTBUFF_OToggleDebug()
  SMARTBUFF_Options.Debug = not SMARTBUFF_Options.Debug;
end

function SMARTBUFF_OptionsFrame_Toggle()
  if (not isInit) then return; end
  
	if(SmartBuffOptionsFrame:IsVisible()) then
    if(iLastBuffSetup > 0) then
      SmartBuff_BuffSetup:Hide();
      iLastBuffSetup = -1;
      SmartBuff_PlayerSetup:Hide();
    end	
		SmartBuffOptionsFrame:Hide();
	else
		SmartBuffOptionsFrame:Show();
    SmartBuff_PlayerSetup:Hide();
	end
end

function SMARTBUFF_OptionsFrame_Open(force)
  if (not isInit) then return; end
	if(not SmartBuffOptionsFrame:IsVisible() or force) then
		SmartBuffOptionsFrame:Show();
	end
end

function SmartBuff_BuffSetup_Show(i)
  local icon1 = cBuffs[i].IconS;
  local icon2 = cBuffs[i].IconG;
  local name = cBuffs[i].BuffS;
  local btype = cBuffs[i].Type;
  local ct = currentTemplate;
  local hidden = true;
  local n = 0;

  if (name == nil or btype == SMARTBUFF_CONST_TRACK) then
    SmartBuff_BuffSetup:Hide();
    iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
    return;
  end
  
	if(SmartBuff_BuffSetup:IsVisible() and i == iLastBuffSetup) then
		SmartBuff_BuffSetup:Hide();
		iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
		return;
	else	
	  if (btype == SMARTBUFF_CONST_GROUP) then
      hidden = false;
    end
    
    if (icon2 and SMARTBUFF_Buffs[ct][name].EnableG) then
      SmartBuff_BuffSetup_BuffIcon2:SetNormalTexture(icon2);
      SmartBuff_BuffSetup_BuffIcon2:Show();
    else
      SmartBuff_BuffSetup_BuffIcon2:Hide();
    end
    if (icon1) then
      SmartBuff_BuffSetup_BuffIcon1:SetNormalTexture(icon1);
      if (icon2 and SMARTBUFF_Buffs[ct][name].EnableG) then
        SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 44, -30);
      else
        SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 64, -30);
      end
      SmartBuff_BuffSetup_BuffIcon1:Show();
    else
      SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 24, -30);
      SmartBuff_BuffSetup_BuffIcon1:Hide();
    end
    
    local obj = SmartBuff_BuffSetup_BuffText;
    if (name) then
      obj:SetText(name);
      --SMARTBUFF_AddMsgD(name);
    else
      obj:SetText("");
    end
    
		SmartBuff_BuffSetup_cbSelf:SetChecked(SMARTBUFF_Buffs[ct][name].SelfOnly);
		SmartBuff_BuffSetup_cbSelfNot:SetChecked(SMARTBUFF_Buffs[ct][name].SelfNot);
		SmartBuff_BuffSetup_cbCombatIn:SetChecked(SMARTBUFF_Buffs[ct][name].CIn);
		SmartBuff_BuffSetup_cbCombatOut:SetChecked(SMARTBUFF_Buffs[ct][name].COut);
		SmartBuff_BuffSetup_cbMH:SetChecked(SMARTBUFF_Buffs[ct][name].MH);
		SmartBuff_BuffSetup_cbOH:SetChecked(SMARTBUFF_Buffs[ct][name].OH);
		SmartBuff_BuffSetup_cbReminder:SetChecked(SMARTBUFF_Buffs[ct][name].Reminder);
		SmartBuff_BuffSetup_txtManaLimit:SetNumber(SMARTBUFF_Buffs[ct][name].ManaLimit);
		   
    --SMARTBUFF_AddMsgD("Test Buff setup show 1");
		SmartBuff_BuffSetup_RBTime:SetValue(SMARTBUFF_Buffs[ct][name].RBTime);
		if (cBuffs[i].DurationS > 0) then
		  SmartBuff_BuffSetup_RBTime:SetMinMaxValues(0, cBuffs[i].DurationS);
      getglobal(SmartBuff_BuffSetup_RBTime:GetName().."High"):SetText(cBuffs[i].DurationS);
		  if (cBuffs[i].DurationS <= 60) then
		    SmartBuff_BuffSetup_RBTime:SetValueStep(1);
      elseif (cBuffs[i].DurationS <= 180) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(5);
      elseif (cBuffs[i].DurationS <= 600) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(10);
		  else
		    SmartBuff_BuffSetup_RBTime:SetValueStep(30);
		  end
		  getglobal(SmartBuff_BuffSetup_RBTime:GetName().."Text"):SetText(SMARTBUFF_Buffs[ct][name].RBTime .. "\nsec");
		  SmartBuff_BuffSetup_RBTime:Show();
		else
		  SmartBuff_BuffSetup_RBTime:Hide();
		end
    --SMARTBUFF_AddMsgD("Test Buff setup show 2");
		
		SmartBuff_BuffSetup_txtManaLimit:Hide();
		if (cBuffs[i].Type == SMARTBUFF_CONST_INV or cBuffs[i].Type == SMARTBUFF_CONST_WEAPON) then
      SmartBuff_BuffSetup_cbMH:Show();
      SmartBuff_BuffSetup_cbOH:Show();
    else
      SmartBuff_BuffSetup_cbMH:Hide();
      SmartBuff_BuffSetup_cbOH:Hide();
      if (cBuffs[i].Type ~= SMARTBUFF_CONST_FOOD) then
        SmartBuff_BuffSetup_txtManaLimit:Show();
      end
    end
    
    if (cBuffs[i].Type == SMARTBUFF_CONST_GROUP) then
      SmartBuff_BuffSetup_cbSelf:Show();
      SmartBuff_BuffSetup_cbSelfNot:Show();
      SmartBuff_BuffSetup_btnPriorityList:Show();
      SmartBuff_BuffSetup_btnIgnoreList:Show();    
    else
      SmartBuff_BuffSetup_cbSelf:Hide();
      SmartBuff_BuffSetup_cbSelfNot:Hide();
      SmartBuff_BuffSetup_btnPriorityList:Hide();
      SmartBuff_BuffSetup_btnIgnoreList:Hide();
      SmartBuff_PlayerSetup:Hide();
    end
  
    local cb = nil;
		local btn = nil;
		n = 0;
		for _ in pairs(cClasses) do
		  n = n + 1;
		  cb = getglobal("SmartBuff_BuffSetup_cbClass"..n);
		  btn = getglobal("SmartBuff_BuffSetup_ClassIcon"..n);
		  if (hidden) then 
		    cb:Hide();
		    btn:Hide();
		  else
		    cb:SetChecked(SMARTBUFF_Buffs[ct][name][cClasses[n]]);
		    cb:Show();
		    btn:Show();
		  end
		end
    iLastBuffSetup = i;
    --SMARTBUFF_AddMsgD("Test Buff setup show 3");
 		SmartBuff_BuffSetup:Show();
    
    if (SmartBuff_PlayerSetup:IsVisible()) then
      SmartBuff_PS_Show(iCurrentList);
    end
	end  
end

function SmartBuff_BuffSetup_ManaLimitChanged()
  local i = iLastBuffSetup;
  if (i <= 0) then
    return;
  end
  local ct = currentTemplate;
  local name = cBuffs[i].BuffS;
  SMARTBUFF_Buffs[ct][name].ManaLimit = this:GetNumber();
end

function SmartBuff_BuffSetup_OnClick()
  local i = iLastBuffSetup;
  local ct = currentTemplate;
  if (i <= 0) then
    return;
  end
  local name = cBuffs[i].BuffS;  
 
	SMARTBUFF_Buffs[ct][name].SelfOnly = SmartBuff_BuffSetup_cbSelf:GetChecked();
	SMARTBUFF_Buffs[ct][name].SelfNot = SmartBuff_BuffSetup_cbSelfNot:GetChecked();
	SMARTBUFF_Buffs[ct][name].CIn  = SmartBuff_BuffSetup_cbCombatIn:GetChecked();
	SMARTBUFF_Buffs[ct][name].COut = SmartBuff_BuffSetup_cbCombatOut:GetChecked();
	SMARTBUFF_Buffs[ct][name].MH = SmartBuff_BuffSetup_cbMH:GetChecked();
	SMARTBUFF_Buffs[ct][name].OH = SmartBuff_BuffSetup_cbOH:GetChecked();
	SMARTBUFF_Buffs[ct][name].Reminder = SmartBuff_BuffSetup_cbReminder:GetChecked();
	
	SMARTBUFF_Buffs[ct][name].RBTime = SmartBuff_BuffSetup_RBTime:GetValue();
	getglobal(SmartBuff_BuffSetup_RBTime:GetName().."Text"):SetText(SMARTBUFF_Buffs[ct][name].RBTime .. "\nsec");
  
	if (cBuffs[i].Type == SMARTBUFF_CONST_GROUP) then
	  local n = 0;
	  local cb = nil;
	  for _ in pairs(cClasses) do
	    n = n + 1;
		  cb = getglobal("SmartBuff_BuffSetup_cbClass"..n);
		  SMARTBUFF_Buffs[ct][name][cClasses[n]] = cb:GetChecked();
	  end
	end
  --SMARTBUFF_AddMsgD("Buff setup saved");
end

function SmartBuff_BuffSetup_ToolTip(mode)
  local i = iLastBuffSetup;
  if (i <= 0) then
    return;
  end
  local ids = cBuffs[i].IDS;
  local idg = cBuffs[i].IDG;
  local btype = cBuffs[i].Type
  
  GameTooltip:ClearLines();
  if (btype == SMARTBUFF_CONST_INV or bytpe == SMARTBUFF_CONST_FOOD) then
    local bag, slot, count, texture = SMARTBUFF_FindReagent(cBuffs[i].BuffS);
    if (bag and slot) then
      GameTooltip:SetBagItem(bag, slot);
    end
  else
    if (mode == 1 and ids) then
	    GameTooltip:SetSpell(ids, 1);
	  elseif (mode == 2 and idg) then
	    GameTooltip:SetSpell(idg, 1);
	  end
	end
	GameTooltip:Show();
end
-- END SmartBuff options toggle


-- Options frame functions ---------------------------------------------------------------------------------------
function SMARTBUFF_Options_OnLoad()
end

function SMARTBUFF_Options_OnShow()
  -- Check if the options frame is out of screen area
  local top    = GetScreenHeight() - math.abs(SmartBuffOptionsFrame:GetTop());
  local bottom = GetScreenHeight() - math.abs(SmartBuffOptionsFrame:GetBottom());
  local left   = SmartBuffOptionsFrame:GetLeft();
  local right  = SmartBuffOptionsFrame:GetRight();
  
  --SMARTBUFF_AddMsgD("X: " .. GetScreenWidth() .. ", " .. left .. ", " .. right);
  --SMARTBUFF_AddMsgD("Y: " .. GetScreenHeight() .. ", " .. top .. ", " .. bottom);
  
  if (GetScreenWidth() < left + 20 or GetScreenHeight() < top + 20 or right < 20 or bottom < 20) then
    SmartBuffOptionsFrame:SetPoint("TOPLEFT", UIParent, "CENTER", -SmartBuffOptionsFrame:GetWidth() / 2, SmartBuffOptionsFrame:GetHeight() / 2);
  end
  
  SmartBuff_ShowControls("SmartBuffOptionsFrame", true);
  
  SmartBuffOptionsFrame_cbSB:SetChecked(SMARTBUFF_Options.Toggle);
  SmartBuffOptionsFrame_cbAuto:SetChecked(SMARTBUFF_Options.ToggleAuto);
  SmartBuffOptionsFrameAutoTimer:SetValue(SMARTBUFF_Options.AutoTimer);
  getglobal(SmartBuffOptionsFrameAutoTimer:GetName().."Text"):SetText(SMARTBUFF_OFT_AUTOTIMER.." "..SMARTBUFF_Options.AutoTimer.." sec");
  SmartBuffOptionsFrame_cbAutoCombat:SetChecked(SMARTBUFF_Options.ToggleAutoCombat);
  SmartBuffOptionsFrame_cbAutoChat:SetChecked(SMARTBUFF_Options.ToggleAutoChat);
  SmartBuffOptionsFrame_cbAutoSplash:SetChecked(SMARTBUFF_Options.ToggleAutoSplash);
  SmartBuffOptionsFrame_cbAutoSound:SetChecked(SMARTBUFF_Options.ToggleAutoSound);
  --SmartBuffOptionsFrame_cbCheckCharges:SetChecked(SMARTBUFF_Options.ToggleCheckCharges);
  --SmartBuffOptionsFrame_cbAutoRest:SetChecked(SMARTBUFF_Options.ToggleAutoRest);
  SmartBuffOptionsFrame_cbAutoSwitchTmp:SetChecked(SMARTBUFF_Options.AutoSwitchTemplate);
  SmartBuffOptionsFrame_cbAutoSwitchTmpInst:SetChecked(SMARTBUFF_Options.AutoSwitchTemplateInst);
  SmartBuffOptionsFrame_cbBuffPvP:SetChecked(SMARTBUFF_Options.BuffPvP);
  SmartBuffOptionsFrame_cbBuffTarget:SetChecked(SMARTBUFF_Options.BuffTarget);
  SmartBuffOptionsFrame_cbBuffInCities:SetChecked(SMARTBUFF_Options.BuffInCities);
  SmartBuffOptionsFrame_cbAdvancedGrpBuffCheck:SetChecked(SMARTBUFF_Options.AdvGrpBuffCheck);
  SmartBuffOptionsFrame_cbAdvancedGrpBuffRange:SetChecked(SMARTBUFF_Options.AdvGrpBuffRange);
  SmartBuffOptionsFrame_cbAntiDaze:SetChecked(SMARTBUFF_Options.AntiDaze);
  SmartBuffOptionsFrame_cbScrollWheelUp:SetChecked(SMARTBUFF_Options.ScrollWheelUp);
  SmartBuffOptionsFrame_cbScrollWheelDown:SetChecked(SMARTBUFF_Options.ScrollWheelDown);
  SmartBuffOptionsFrame_cbInCombat:SetChecked(SMARTBUFF_Options.InCombat);
  SmartBuffOptionsFrame_cbMiniGrp:SetChecked(SMARTBUFF_Options.ShowMiniGrp);
  SmartBuffOptionsFrame_cbSubGrpChanged:SetChecked(SMARTBUFF_Options.ToggleSubGrpChanged);
  SmartBuffOptionsFrame_cbMsgNormal:SetChecked(SMARTBUFF_Options.ToggleMsgNormal);
  SmartBuffOptionsFrame_cbMsgWarning:SetChecked(SMARTBUFF_Options.ToggleMsgWarning);
  SmartBuffOptionsFrame_cbMsgError:SetChecked(SMARTBUFF_Options.ToggleMsgError);
  SmartBuffOptionsFrame_cbHideMmButton:SetChecked(SMARTBUFF_Options.HideMmButton);
  SmartBuffOptionsFrame_cbHideSAButton:SetChecked(SMARTBUFF_Options.HideSAButton);
  SmartBuffOptionsFrame_cbUISync:SetChecked(SMARTBUFF_Options.UISync);
  SmartBuffOptionsFrame_cbCompMode:SetChecked(SMARTBUFF_Options.CompMode);
  
  if (IsAddOnLoaded("SmartDebuff")) then
    SmartBuffOptionsFrame_cbSmartDebuff:SetChecked(SMARTDEBUFF_Options.ShowSF);
  end
  
  SmartBuffOptionsFrameRebuffTimer:SetValue(SMARTBUFF_Options.RebuffTimer);
  getglobal(SmartBuffOptionsFrameRebuffTimer:GetName().."Text"):SetText(SMARTBUFF_OFT_REBUFFTIMER.." "..SMARTBUFF_Options.RebuffTimer.." sec");

  SmartBuffOptionsFrameBLDuration:SetValue(SMARTBUFF_Options.BlacklistTimer);
  getglobal(SmartBuffOptionsFrameBLDuration:GetName().."Text"):SetText(SMARTBUFF_OFT_BLDURATION.." "..SMARTBUFF_Options.BlacklistTimer.." sec");

  SMARTBUFF_ShowSubGroupsOptions();
  SMARTBUFF_SetCheckButtonBuffs(0);
  
  SmartBuffOptionsFrame_cbSelfFirst:SetChecked(SMARTBUFF_Buffs[currentTemplate].SelfFirst);
  
  SMARTBUFF_Splash_Show();
  
  SMARTBUFF_AddMsgD("Option frame updated: " .. currentTemplate);
end

function SMARTBUFF_ShowSubGroupsMini()
  SMARTBUFF_ShowSubGroups("SmartBuff_MiniGroup", SMARTBUFF_Options.ToggleGrp);
end

function SMARTBUFF_ShowSubGroupsOptions()
  SMARTBUFF_ShowSubGroups("SmartBuffOptionsFrame", SMARTBUFF_Options.ToggleGrp);
end

function SMARTBUFF_ShowSubGroups(frame, grpTable)
  local i;
	for i = 1, 8, 1 do
	  obj = getglobal(frame.."_cbGrp"..i);
	  if (obj) then
	    obj:SetChecked(grpTable[i]);
	  end
	end
end

function SMARTBUFF_Options_OnHide()
  SmartBuffOptionsFrame:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
  --SmartBuff_BuffSetup:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
  cBuffsCombat = { };  
  SMARTBUFF_SetInCombatBuffs();  
  SmartBuff_BuffSetup:Hide();
  SmartBuff_PlayerSetup:Hide();
  SMARTBUFF_SetUnits();
  SMARTBUFF_Splash_Hide();
  SMARTBUFF_RebindKeys();
  --collectgarbage();
end

function SmartBuff_ShowControls(sName, bShow)
  local children = {getglobal(sName):GetChildren()};
  for i, child in pairs(children) do
    --SMARTBUFF_AddMsgD(i .. ": " .. child:GetName());
    if (i > 1 and string.find(child:GetName(), "^"..sName..".+")) then
      if (bShow) then
        child:Show();
      else
        child:Hide();
      end
    end
  end
end

function SmartBuffOptionsFrameSlider_OnLoad(low, high, step)
  if (this:GetOrientation() ~= "VERTICAL") then
    getglobal(this:GetName().."Low"):SetText(low);
  else
    getglobal(this:GetName().."Low"):SetText("");
  end
  getglobal(this:GetName().."High"):SetText(high);
	this:SetMinMaxValues(low, high);
	this:SetValueStep(step);
end

function SmartBuffOptionsFrameAutoTimer_OnValueChanged()
	SMARTBUFF_Options.AutoTimer = this:GetValue();
	getglobal(this:GetName().."Text"):SetText(SMARTBUFF_OFT_AUTOTIMER.." "..SMARTBUFF_Options.AutoTimer.." sec");
end

function SmartBuffOptionsFrameGrpBuffSize_OnValueChanged()
  local ct = currentTemplate;
  local s = "";
  if (sPlayerClass == "PALADIN") then
    s = SMARTBUFF_OFT_CLASSBUFFSIZE;
  else
    s = SMARTBUFF_OFT_GRPBUFFSIZE;
  end  
  SMARTBUFF_Buffs[ct].GrpBuffSize = this:GetValue();
	getglobal(this:GetName().."Text"):SetText(s.." "..SMARTBUFF_Buffs[ct].GrpBuffSize);
end

function SmartBuffOptionsFrameRebuffTimer_OnValueChanged()
	SMARTBUFF_Options.RebuffTimer = this:GetValue();
	getglobal(this:GetName().."Text"):SetText(SMARTBUFF_OFT_REBUFFTIMER.." "..SMARTBUFF_Options.RebuffTimer.." sec");
end

function SmartBuff_BuffSetup_RBTime_OnValueChanged()
  getglobal(SmartBuff_BuffSetup_RBTime:GetName().."Text"):SetText(this:GetValue() .. "\nsec");
end

function SmartBuffOptionsFrameBLDuration_OnValueChanged()
	SMARTBUFF_Options.BlacklistTimer = this:GetValue();
	getglobal(this:GetName().."Text"):SetText(SMARTBUFF_OFT_BLDURATION.." "..SMARTBUFF_Options.BlacklistTimer.." sec");
end

function SMARTBUFF_SetCheckButtonBuffs(mode) 
	local objS;
	local objG;
	local i = 1;
  local ct = currentTemplate;

  if (mode == 0) then
    SMARTBUFF_SetBuffs();
  end
  
  local s = "";
  if (sPlayerClass == "PALADIN") then
    s = SMARTBUFF_OFT_CLASSBUFFSIZE;
  else
    s = SMARTBUFF_OFT_GRPBUFFSIZE;
  end
  
  SmartBuffOptionsFrameGrpBuffSize:SetValue(SMARTBUFF_Buffs[ct].GrpBuffSize);
  getglobal(SmartBuffOptionsFrameGrpBuffSize:GetName().."Text"):SetText(s.." "..SMARTBUFF_Buffs[ct].GrpBuffSize);
  
  SmartBuffOptionsFrame_cbAntiDaze:Hide();
  SmartBuffOptionsFrame_cbCompMode:Hide();
  
  if (not IsAddOnLoaded("SmartDebuff")) then
    SmartBuffOptionsFrame_cbSmartDebuff:Hide();
  end  
  
  if (sPlayerClass == "PALADIN") then
    --SmartBuffOptionsFrame_cbAdvancedGrpBuffCheck:Hide();
    --SmartBuffOptionsFrameGrpBuffSize:Hide();
  elseif (sPlayerClass == "HUNTER" or sPlayerClass == "ROGUE" or sPlayerClass == "WARRIOR") then
    SmartBuffOptionsFrame_cbAdvancedGrpBuffRange:Hide();
    SmartBuffOptionsFrame_cbAdvancedGrpBuffCheck:Hide();
    SmartBuffOptionsFrameGrpBuffSize:Hide();
    SmartBuffOptionsFrameBLDuration:Hide();
    if (sPlayerClass == "HUNTER") then
      SmartBuffOptionsFrame_cbAntiDaze:Show();
    end
  end
  
	while (i <= maxCheckButtons) do
    objS = getglobal("SmartBuffOptionsFrame_cbBuffS"..i);
    objG = getglobal("SmartBuffOptionsFrame_cbBuffG"..i);
	  if (cBuffs[i] and (cBuffs[i].IDS ~= nil or cBuffs[i].Type == SMARTBUFF_CONST_INV or cBuffs[i].Type == SMARTBUFF_CONST_FOOD)) then
	    if (cBuffs[i].IDG ~= nil and objG ~= nil) then
	      getglobal(objS:GetName().."Text"):SetText("");
	      --getglobal(objG:GetName().."Text"):SetText(cBuffs[i].BuffS .. "\n" .. cBuffs[i].BuffG);
        getglobal(objG:GetName().."Text"):SetText(cBuffs[i].BuffS .. " / " .. SMARTBUFF_MSG_GROUP);
        
	      objG:SetChecked(SMARTBUFF_Buffs[currentTemplate][cBuffs[i].BuffS].EnableG);
	      objG:Show();
	    else
	      if (objG) then objG:Hide(); end
	      getglobal(objS:GetName().."Text"):SetText(cBuffs[i].BuffS);
	    end
      objS:SetChecked(SMARTBUFF_Buffs[currentTemplate][cBuffs[i].BuffS].EnableS);
      objS:Show();
	  else
	    if (objS) then objS:Hide(); end
	    if (objG) then objG:Hide(); end
	  end
	  i = i + 1;
	end
end


function SMARTBUFF_DropDownTemplate_OnShow()
  local i = 0;
	for _, tmp in pairs(SMARTBUFF_TEMPLATES) do
	  i = i + 1;
    --SMARTBUFF_AddMsgD(i .. "." .. tmp);
	  if (tmp == currentTemplate) then
	    break;
	  end
	end
	UIDropDownMenu_Initialize(this, SMARTBUFF_DropDownTemplate_Initialize);
	UIDropDownMenu_SetSelectedID(SmartBuffOptionsFrame_ddTemplates, i);
  UIDropDownMenu_SetWidth(135);
end

function SMARTBUFF_DropDownTemplate_Initialize()
	for k, v in pairs(SMARTBUFF_TEMPLATES) do
		local info = {};
		info.text = SMARTBUFF_TEMPLATES[k];
		info.func = SMARTBUFF_DropDownTemplate_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function SMARTBUFF_DropDownTemplate_OnClick()
  local i = this:GetID();
  local tmp = nil;
	UIDropDownMenu_SetSelectedID(SmartBuffOptionsFrame_ddTemplates, i);
	tmp = SMARTBUFF_TEMPLATES[i];
	--SMARTBUFF_AddMsgD("Selected/Current Buff-Template: " .. tmp .. "/" .. currentTemplate);
	if (currentTemplate ~= tmp) then
    SmartBuff_BuffSetup:Hide();
    iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
    
	  currentTemplate = tmp;
	  SMARTBUFF_Options_OnShow();
	  SMARTBUFF_Options.LastTemplate = currentTemplate;
	end
end
-- END Options frame functions


-- Splash screen functions ---------------------------------------------------------------------------------------
function SMARTBUFF_Splash_Show()
  if (not isInit) then return; end 
  SMARTBUFF_Splash_ChangeFont(1);
  -- "Interface/DialogFrame/UI-DialogBox-Background"
  -- "Interface/Tooltips/UI-Tooltip-Background"
  SmartBuffSplashFrame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background"});
  SmartBuffSplashFrame:EnableMouse(true);
  SmartBuffSplashFrame:Show();
  SmartBuffSplashFrame:SetTimeVisible(60);
end

function SMARTBUFF_Splash_Hide()
  if (not isInit) then return; end 
  SMARTBUFF_Splash_Clear();
  SMARTBUFF_Splash_ChangePos();
  SmartBuffSplashFrame:SetBackdrop(nil);
  SmartBuffSplashFrame:EnableMouse(false);
  SmartBuffSplashFrame:SetFadeDuration(SMARTBUFF_Options.SplashDuration);
  SmartBuffSplashFrame:SetTimeVisible(SMARTBUFF_Options.SplashDuration);
end

function SMARTBUFF_Splash_Clear()
  SmartBuffSplashFrame:Clear();
  --local i;
  --for i = 1, 8, 1 do
  --  SmartBuffSplashFrame:AddMessage(" ", 1, 1, 1, 1, 1);
  --end
end

function SMARTBUFF_Splash_ChangePos()
  local _,_,_, x, y = SmartBuffSplashFrame:GetPoint("CENTER");
  if (SMARTBUFF_Options) then
    SMARTBUFF_Options.SplashX = x;
    SMARTBUFF_Options.SplashY = y;
  end
end

function SMARTBUFF_Splash_ChangeFont(mode)
  if (mode > 1) then
    SMARTBUFF_Splash_ChangePos();    
    iCurrentFont = iCurrentFont + 1;
  end
  if (not cFonts[iCurrentFont]) then
    iCurrentFont = 1;
  end
  SMARTBUFF_Options.CurrentFont = iCurrentFont;
  SmartBuffSplashFrame:ClearAllPoints();
  SmartBuffSplashFrame:SetPoint("TOPLEFT", SMARTBUFF_Options.SplashX, SMARTBUFF_Options.SplashY);
  SmartBuffSplashFrame:SetFontObject(getglobal(cFonts[iCurrentFont]));
  if (mode > 0) then
    SMARTBUFF_Splash_Clear();
    SmartBuffSplashFrame:AddMessage("Demo Text Font: " .. cFonts[iCurrentFont] .. "\ndrag'n'drop to move", 1, 1, 1, 1, 60);
  end
end
-- END Splash screen events


-- Playerlist functions ---------------------------------------------------------------------------------------
function SmartBuff_PlayerSetup_OnShow()
end

function SmartBuff_PlayerSetup_OnHide()
end

function SmartBuff_PS_GetList()
  if (iLastBuffSetup <= 0) then
    return { };
    --[[
    if (iCurrentList == 1) then
      return SMARTBUFF_Options.AddList;
    else
      return SMARTBUFF_Options.IgnoreList;
    end
    ]]--
  end
  
  local name = cBuffs[iLastBuffSetup].BuffS;
  if (iCurrentList == 1) then
    return SMARTBUFF_Buffs[currentTemplate][name].AddList;
  else
    return SMARTBUFF_Buffs[currentTemplate][name].IgnoreList;
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
  if (un and UnitIsPlayer("target") and (UnitInRaid("target") or UnitInParty("target") or SMARTBUFF_Options.Debug)) then
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
      --SMARTBUFF_AddMsgD("Added to UnitList:" .. un .. "(" .. unit .. ")");
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
-- END Playerlist functions


-- Mini group functions ---------------------------------------------------------------------------------------
function SMARTBUFF_MiniGroup_OnShow()
  SmartBuff_MiniGroup_Title:SetText(SMARTBUFF_TITLE .. " - " .. currentTemplate);
  SMARTBUFF_ShowSubGroupsMini();
end

function SMARTBUFF_MiniGroup_OnHide()
end

function SMARTBUFF_MiniGroup_Show()
  if (SMARTBUFF_Options.ShowMiniGrp and iGroupSetup == 3) then
    SmartBuff_MiniGroup:Show();
  else
    if (SmartBuff_MiniGroup:IsVisible()) then
      SmartBuff_MiniGroup:Hide();
    end
  end
end
-- END Mini group functions


-- Secure button functions, NEW TBC ---------------------------------------------------------------------------------------
function SMARTBUFF_ShowSAButton()
	if (SMARTBUFF_Options.HideSAButton) then
	  SmartBuff_KeyButton:Hide();
	else
	  SmartBuff_KeyButton:Show();
	end
end

local sScript;
function SMARTBUFF_OnClick(self)
  SMARTBUFF_AddMsgD("OnClick");
end


local lastBuffType = "";
function SMARTBUFF_OnPreClick(self)
  local mode = 0;
  if (arg1) then
    if (arg1 == "MOUSEWHEELUP" or arg1 == "MOUSEWHEELDOWN") then
      mode = 5;
    end
  end
    
  if (not InCombatLockdown()) then
    self:SetAttribute("type", nil);
    self:SetAttribute("unit", nil);
    self:SetAttribute("spell", nil);
    self:SetAttribute("item", nil);
    self:SetAttribute("target-slot", nil); 
    self:SetAttribute("action", nil);
  end
  
  --sScript = self:GetScript("OnClick");
  --self:SetScript("OnClick", SMARTBUFF_OnClick);
  
  local td;
  if (lastBuffType == "") then
    td = 0.8;
  elseif (lastBuffType == SMARTBUFF_CONST_WEAPON) then
    td = 3;
  elseif (lastBuffType == SMARTBUFF_CONST_INV or lastBuffType == SMARTBUFF_CONST_FOOD) then
    td = 5;
  else
    td = GlobalCd;
  end
  --SMARTBUFF_AddMsgD("Last buff type: " .. lastBuffType .. ", set cd: " .. td);
    
  if (GetTime() < (tAutoBuff + td)) then
    return;
  end
  --SMARTBUFF_AddMsgD("next buff check");
  tAutoBuff = GetTime();
  lastBuffType = "";
  currentUnit = nil;
  currentSpell = nil;  
  
  if (not InCombatLockdown()) then
    local ret, actionType, spellName, slot, unit, buffType = SMARTBUFF_Check(mode);
    if (ret and ret == 0 and actionType and spellName and unit) then
      lastBuffType = buffType;
      self:SetAttribute("type", actionType);
      self:SetAttribute("unit", unit);
      if (actionType == SMARTBUFF_ACTION_SPELL) then
        self:SetAttribute("spell", spellName);
        if (slot and slot > 0) then
          self:SetAttribute("unit", nil);
          self:SetAttribute("target-slot", slot);
        end
        
        local i = cBuffIndex[spellName];        
        if (i) then
          if (cBuffs[i].BuffG ~= spellName) then
            currentUnit = unit;
            currentSpell = spellName;
          end
        end
        
      elseif (actionType == SMARTBUFF_ACTION_ITEM and slot) then
        self:SetAttribute("item", spellName);
        if (slot > 0) then
          self:SetAttribute("target-slot", slot);
        end
      elseif (actionType == "action" and slot) then
        self:SetAttribute("action", slot);
      else
        SMARTBUFF_AddMsgD("Preclick: not supported actiontype -> " .. actionType);
      end
      
      --isClearSplash = true;
      tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + GlobalCd;
    end
  end
end

function SMARTBUFF_OnPostClick(self)
  if (arg1) then
    if (arg1 == "MOUSEWHEELUP") then
      CameraZoomIn(1);
    elseif (arg1 == "MOUSEWHEELDOWN") then
      CameraZoomOut(1);
    end
  end
  
  if (InCombatLockdown()) then return; end
  
  --[[
  if (SMARTBUFF_Options.Toggle) then
    if (SMARTBUFF_Options.InCombat) then
      for spell, data in pairs(cBuffsCombat) do
        if (data and data.Unit and data.ActionType) then
          SmartBuff_KeyButton:SetAttribute("unit", data.Unit);
          SmartBuff_KeyButton:SetAttribute("type", data.ActionType);
          SmartBuff_KeyButton:SetAttribute("spell", spell);
          SmartBuff_KeyButton:SetAttribute("item", nil);
          SmartBuff_KeyButton:SetAttribute("target-slot", nil); 
          SmartBuff_KeyButton:SetAttribute("action", nil);
          SMARTBUFF_AddMsgD("Enter Combat, set button: " .. spell .. " on " .. data.Unit .. ", " .. data.ActionType);
          break;
        end
      end
    end
  end
  ]]--
  
  --local posX, posY = GetPlayerMapPosition("player");
  --SMARTBUFF_AddMsgD("X = " .. posX .. ", Y = " .. posY);  
  --if (UnitCreatureType("target")) then
  --  SMARTBUFF_AddMsgD(UnitCreatureType("target"));
  --end
  
  --[[
  local r = IsSpellInRange("Nachwachsen", "target")
  if(r and r == 1) then
    SMARTBUFF_AddMsgD("Spell in range");
  elseif(r and r == 0) then
    SMARTBUFF_AddMsgD("OOR");
  end
  ]]--
  
  --[[
  local s = "";
  local button = SecureStateChild_GetEffectiveButton(self);
  local type  = SecureButton_GetModifiedAttribute(self, "type", button, "");
  local unit  = SecureButton_GetModifiedAttribute(self, "unit", button, "");
  local spell = SecureButton_GetModifiedAttribute(self, "spell", button, "");
  if (type and unit and spell) then
    s = s .. type .. ", " .. unit .. ", " .. spell;
  end
  ]]--
  
  self:SetAttribute("type", nil);
  self:SetAttribute("unit", nil);
  self:SetAttribute("spell", nil);
  self:SetAttribute("item", nil);
  self:SetAttribute("target-slot", nil);
  
  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, imgSB);
  --SMARTBUFF_AddMsgD("Button reseted, " .. arg1);
  --self:SetScript("OnClick", sScript);
end

function SMARTBUFF_SetButtonTexture(button, texture, text)
  if (InCombatLockdown()) then return; end
  
  if (button and texture and texture ~= sLastTexture) then
    sLastTexture = texture;
    button:SetNormalTexture(texture);
    --SMARTBUFF_AddMsgD("Button slot texture set -> " .. texture);
    if (text) then
      --button.title:SetText(spell);
    end
  end
end
-- END secure button functions


-- Minimap button functions ---------------------------------------------------------------------------------------
-- Sets the correct icon on the minimap button
function SMARTBUFF_CheckMiniMapButton()
  if (SMARTBUFF_Options.Toggle) then
    SmartBuff_MiniMapButton:SetNormalTexture(imgIconOn);
	else
    SmartBuff_MiniMapButton:SetNormalTexture(imgIconOff);
	end
	
	if (SMARTBUFF_Options.HideMmButton) then
	  SmartBuff_MiniMapButton:Hide();
	else
	  SmartBuff_MiniMapButton:Show();
	end
	
	-- Update the Titan Panel icon
	if (TitanPanelBarButton) then
	  TitanPanelSmartBuffButton_SetIcon();
	end
	
	-- Update the FuBar icon
	if (IsAddOnLoaded("FuBar") and IsAddOnLoaded("FuBar_SmartBuffFu")) then
		SMARTBUFF_Fu_SetIcon();
	end
	
end

-- Function to move the minimap button arround the minimap
function SMARTBUFF_IconDraggingFrame_OnUpdate(arg1)
	local pos, r;
	local xpos, ypos = GetCursorPosition();
	local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();

	xpos = xmin-xpos/Minimap:GetEffectiveScale()+70;
	ypos = ypos/Minimap:GetEffectiveScale()-ymin-70;
	pos  = math.deg(math.atan2(ypos,xpos));
  r    = math.sqrt(xpos*xpos + ypos*ypos);
  --SMARTBUFF_AddMsgD("x = " .. xpos .. ", y = " .. ypos .. ", r = " .. r .. ", pos = " .. pos);
  
  if (r < 80) then
    r = 80;  
  elseif(r > 105) then
    r = 105;
  end
  
	xpos = r*cos(pos);
	ypos = r*sin(pos);	
	SmartBuff_MiniMapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-xpos, ypos-52);
	SmartBuff_MiniMapButton:SetUserPlaced(true);  
end
-- END Minimap button functions
