--[[

  BindPad Addon for World of Warcraft

  Auther: Tageshi

--]]

-- Avoid taint of official lua codes.
local i, j;

-- Register BindPad frame to be controlled together with
-- other panels in standard UI.
UIPanelWindows["BindPadFrame"] = { area = "left", pushable = 9, whileDead = 1 };

-- Register BindPad binding frame to be closed on Escape press.
table.insert(UISpecialFrames,"BindPadBindFrame");

local BINDPAD_MAXSLOTS = 42;
local BINDPAD_GENERAL_TAB = 1;
local BINDPAD_SPECIFIC_TAB = 2;
local BINDPAD_SAVEFILE_VERSION = 1.3;

-- Initialize the saved variable for BindPad.
BindPadVars = {
  tab = BINDPAD_GENERAL_TAB,
  version = BINDPAD_SAVEFILE_VERSION,
};

-- Initialize BindPad core object.
BindPadCore = {

};

StaticPopupDialogs["BINDPAD_CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS"] = {
	text = CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		StaticPopup_Show("BINDPAD_CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS2");
	end,
	OnCancel = function()
		BindPadFrameCharacterButton:SetChecked(GetCurrentBindingSet() == 2);
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BINDPAD_CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS2"] = {
	text = BINDPAD_TEXT_ARE_YOU_SURE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		LoadBindings(1);
		SaveBindings(1);
		BindPadVars.tab = 1;
		BindPadFrame_OnShow();
	end,
	OnCancel = function()
		BindPadFrameCharacterButton:SetChecked(GetCurrentBindingSet() == 2);
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BINDPAD_CONFIRM_CHANGE_BINDING_PROFILE"] = {
	text = BINDPAD_TEXT_CONFIRM_CHANGE_BINDING_PROFILE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		LoadBindings(2);
		SaveBindings(2);
		BindPadVars.tab = 2;
		BindPadFrame_OnShow();
	end,
	OnCancel = function()
		BindPadVars.tab = 1;
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

function BindPadFrame_OnLoad()
  if not Print then
    function Print(x)
      ChatFrame1:AddMessage(x, 1.0, 1.0, 1.0);
    end
  end
  PanelTemplates_SetNumTabs(BindPadFrame, 4);

  SlashCmdList["BINDPAD"] = BindPadFrame_Toggle;
  SLASH_BINDPAD1 = "/bindpad";
  SLASH_BINDPAD2 = "/bp";

  BindPadCore.Init();
end

function BindPadFrame_OutputText(text)
  ChatFrame1:AddMessage("[BindPad] "..text, 1.0, 1.0, 0.0);
end

function BindPadFrame_Toggle()
  if BindPadFrame:IsVisible() then
    HideUIPanel(BindPadFrame);
  else
    ShowUIPanel(BindPadFrame);
  end
end

function BindPadFrame_OnShow(id)
  -- Savefile version 1.0 and 1.1 are obsolated.
  if BindPadVars.version == nil or
     BindPadVars.version < 1.2 then
    BindPadVars = {
      tab = BINDPAD_GENERAL_TAB;
    };
    BindPadFrame_OutputText(BINDPAD_TEXT_OBSOLATED);
  end
  -- Set current version number
  BindPadVars.version = BINDPAD_SAVEFILE_VERSION;

  if id then
    BindPadVars.tab = id;
  elseif nil == BindPadVars.tab then
    BindPadVars.tab = 1;
  end
  if GetCurrentBindingSet() == 1 then
    -- Don't show Character Specific Slots tab at first.
    BindPadVars.tab = 1;
    if id then
      StaticPopup_Show("BINDPAD_CONFIRM_CHANGE_BINDING_PROFILE");
    end
  end
  PanelTemplates_SetTab(BindPadFrame, BindPadVars.tab);

  -- Update character button
  BindPadFrameCharacterButton:SetChecked(GetCurrentBindingSet() == 2);

  for i = 1, BINDPAD_MAXSLOTS, 1 do
    local frame = getglobal("BindPadSlot"..i);
    BindPadSlot_UpdateState(frame);
  end
end

function BindPadFrame_OnHide()
end

function BindPadBindFrame_Update()
  StaticPopup_Hide("BINDPAD_CONFIRM_BINDING")
  BindPadBindFrameAction:SetText(BindPadCore.selectedSlot.action);

  local key = GetBindingKey(BindPadCore.selectedSlot.action);
  if key then
    BindPadBindFrameKey:SetText(BINDPAD_TEXT_KEY..BindPadCore.GetBindingText(key, "KEY_"));
  else
    BindPadBindFrameKey:SetText(BINDPAD_TEXT_KEY..BINDPAD_TEXT_NOTBOUND);
  end
end

function BindPadBindFrame_OnKeyDown(key)
  if key=="ESCAPE" then
    BindPadBindFrame:Hide()
    return
  end
  local screenshotKey = GetBindingKey("SCREENSHOT");
  if ( screenshotKey and key == screenshotKey ) then
    Screenshot();
    return;
  end
  local button
  -- Convert the mouse button names
  if ( key == "LeftButton" ) then
    button = "BUTTON1"
  elseif ( key == "RightButton" ) then
    button = "BUTTON2"
  elseif ( key == "MiddleButton" ) then
    button = "BUTTON3"
  elseif ( key == "Button4" ) then
    button = "BUTTON4"
  elseif ( key == "Button5" ) then
    button = "BUTTON5"
  end
  local keyPressed
  if ( button ) then
    if ( button == "BUTTON1" or button == "BUTTON2" ) then
      return;
    end
    keyPressed = button;
  else
    keyPressed = key;
  end
  if keyPressed=="UNKNOWN" or keyPressed=="SHIFT" or keyPressed=="CTRL" or keyPressed=="ALT" then
    return
  end
  if ( IsShiftKeyDown() ) then
    keyPressed = "SHIFT-"..keyPressed
  end
  if ( IsControlKeyDown() ) then
    keyPressed = "CTRL-"..keyPressed
  end
  if ( IsAltKeyDown() ) then
    keyPressed = "ALT-"..keyPressed
  end
  if keyPressed then
    BindPadCore.keyPressed = keyPressed
    local oldAction = GetBindingAction(keyPressed)
    local keyText = BindPadCore.GetBindingText(keyPressed, "KEY_");
    if oldAction~="" and oldAction ~= BindPadCore.selectedSlot.action then
      StaticPopupDialogs["BINDPAD_CONFIRM_BINDING"] = {
        text = format(BINDPAD_TEXT_CONFIRM_BINDING, keyText, (GetBindingText(oldAction,"BINDING_NAME_") or ""), keyText, BindPadCore.selectedSlot.action);
        button1 = "Yes",
        button2 = "No",
        timeout = 0,
        hideOnEscape = 1,
        OnAccept = BindPadBindFrame_SetBindKey,
        OnCancel = BindPadBindFrame_Update
      }
      StaticPopup_Show("BINDPAD_CONFIRM_BINDING")
    else
      BindPadBindFrame_SetBindKey();
    end
  end
end

function BindPadBindFrame_SetBindKey()
  BindPadCore.BindKey();
  BindPadBindFrame_Update();
end

function BindPadBindFrame_Unbind()
  BindPadCore.UnbindSlot(BindPadCore.selectedSlot);
  BindPadBindFrame_Update();
end

function BindPadBindFrame_OnHide()
  -- Close the confirmation dialog frame if it is still open.
  StaticPopup_Hide("BINDPAD_CONFIRM_BINDING")
end

function BindPadSlot_OnUpdate()
  BindPadSlot_UpdateState(this);
end

function BindPadSlot_OnClick(button)
  if GetCursorInfo() then
    -- If cursor has icon to drop, drop it.
    BindPadSlot_OnReceiveDrag();
  elseif IsShiftKeyDown() then
    -- Shift+click to start drag.
    BindPadSlot_OnDragStart();
  else
    -- Otherwise open dialog window to set keybinding.
    BindPadCore.selectedSlot = BindPadCore.GetSlotInfo(this:GetID());
    if nil ~= BindPadCore.selectedSlot.type then
      BindPadBindFrame_Update();
      BindPadBindFrame:Show();
    end
  end
end

function BindPadSlot_OnDragStart()
  BindPadCore.PickupSlot(this:GetID());
  BindPadSlot_UpdateState(this);
end

function BindPadSlot_OnReceiveDrag()
  local type, detail, subdetail = GetCursorInfo();
  if type then
    ClearCursor();
    ResetCursor();
    BindPadCore.PickupSlot(this:GetID());
    BindPadCore.PlaceIntoSlot(this:GetID(), type, detail, subdetail);

    BindPadSlot_UpdateState(this);
    BindPadSlot_OnEnter();
  end
end

function BindPadSlot_OnEnter()
  local padSlot = BindPadCore.GetSlotInfo(this:GetID());

  if padSlot == nil or padSlot.type == nil then
    return;
  end
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT");

  if "ITEM" == padSlot.type then
    local bag,slot = BindPadCore.FindItem(padSlot.name);
    if bag and slot then
      if bag == -1 then
        GameTooltip:SetInventoryItem("player", slot);
      else
        GameTooltip:SetBagItem(bag,slot);
      end
    else
      GameTooltip:SetText(padSlot.name, 1.0, 1.0, 1.0);
    end
  elseif "SPELL" == padSlot.type then
    local spellID = BindPadCore.FindSpellIdByName(padSlot.name, padSlot.rank, padSlot.bookType);
    if spellID then
      GameTooltip:SetSpell(spellID, padSlot.bookType)
    else
      GameTooltip:SetText(BINDPAD_TOOLTIP_UNKNOWN_SPELL..padSlot.name, 1.0, 1.0, 1.0);
    end
  elseif "MACRO" == padSlot.type then
    GameTooltip:SetText(BINDPAD_TOOLTIP_MACRO..padSlot.name, 1.0, 1.0, 1.0);
  end

  if "SPELL" == padSlot.type and padSlot.rank then
    GameTooltip:AddLine(BINDPAD_TOOLTIP_DOWNRANK..padSlot.rank, 1.0, 0.7, 0.7);
  end
  local key = GetBindingKey(padSlot.action);
  if key then
    GameTooltip:AddLine(BINDPAD_TOOLTIP_KEYBINDING..BindPadCore.GetBindingText(key, "KEY_"), 0.8, 0.8, 1.0);
  end

  GameTooltip:Show();
end

function BindPadSlot_UpdateState(this)
  local padSlot = BindPadCore.GetSlotInfo(this:GetID());

  local icon = getglobal(this:GetName().."Icon");
  local name = getglobal(this:GetName().."Name");
  local hotkey = getglobal(this:GetName().."HotKey");

  if padSlot and padSlot.type then
    icon:SetTexture(padSlot.texture);
    icon:Show();

    if name then
      name:SetText(padSlot.name);
    else
      name:SetText("");
    end

    local key = GetBindingKey(padSlot.action);
    if key then
      hotkey:SetText(BindPadCore.GetBindingText(key, "KEY_", 1));
    else
      hotkey:SetText("");
    end

  else
    icon:Hide();
    name:SetText("");
    hotkey:SetText("");
  end

end

--
-- BindPadCore:  A set of core functions
--

function BindPadCore.Init()
end

function BindPadCore.PlaceIntoSlot(id, type, detail, subdetail)

  local padSlot = BindPadCore.GetSlotInfo(id);

  if type == "item" then
    padSlot.linktext = subdetail;
    local name,_,_,_,_,_,_,_,_,texture = GetItemInfo(padSlot.linktext);
    padSlot.name = name;
    padSlot.texture = texture;
    padSlot.type = "ITEM";

  elseif type == "macro" then
    local name, texture = GetMacroInfo(detail);
    padSlot.name = name;
    padSlot.texture = texture;
    padSlot.type = "MACRO";

  elseif type == "spell" then
    local spellName, spellRank = GetSpellName(detail, subdetail);
    local texture = GetSpellTexture(detail, subdetail);
    padSlot.bookType = subdetail;
    padSlot.name = spellName;
    if BindPadCore.IsHighestRank(detail, subdetail) then
      padSlot.rank = nil;
    else
      padSlot.rank = spellRank;
    end
    padSlot.texture = texture;
    padSlot.type = "SPELL";

  else
    BindPadFrame_OutputText(format(BINDPAD_TEXT_CANNOT_PLACE, type));
    return;
  end

  padSlot.action = padSlot.type.." "..padSlot.name;
  if padSlot.rank then
    padSlot.action = padSlot.action.."("..padSlot.rank..")";
  end

  BindPadCore.SetSlotInfo(this:GetID(), padSlot);
end

function BindPadCore.IsCharacterSpecific()
  if BINDPAD_GENERAL_TAB ~= BindPadVars.tab then
    return true;
  end
end

function BindPadCore.GetCharacterName(id)
  local character = GetRealmName().."_"..UnitName("player");
  if (BindPadVars.tab or 0) > BINDPAD_SPECIFIC_TAB then
    character = character.."_"..(BindPadVars.tab);
  end
  return character;
end

function BindPadCore.GetSlotInfo(id)
  if BindPadCore.IsCharacterSpecific() then
    local character = BindPadCore.GetCharacterName(id);
    if nil == BindPadVars[character] then
      BindPadVars[character] = {};
    end
    if nil == BindPadVars[character][id] then
      BindPadVars[character][id] = {};
    end
    return BindPadVars[character][id];
  else
    if nil == BindPadVars[id] then
      BindPadVars[id] = {};
    end
    return BindPadVars[id];
  end
end


function BindPadCore.SetSlotInfo(id, infoArray)
  if BindPadCore.IsCharacterSpecific() then
    local character = BindPadCore.GetCharacterName(id);
    if nil == BindPadVars[character] then
      BindPadVars[character] = {};
    end
    BindPadVars[character][id] = infoArray;
  else
    BindPadVars[id] = infoArray;
  end
end


function BindPadCore.PickupSlot(id)
  local padSlot = BindPadCore.GetSlotInfo(id);
  if "ITEM" == padSlot.type then
    local bag, slot = BindPadCore.FindItem(padSlot.name);
    if bag and slot then
      if bag == -1 then
        PickupInventoryItem(slot);
      else
        PickupContainerItem(bag, slot);
      end
    end

    padSlot.linkText = nil;
    padSlot.name = nil;
    padSlot.texture = nil;
    padSlot.type = nil;
    padSlot.action = nil;

  elseif "SPELL" == padSlot.type then
    local spellID = BindPadCore.FindSpellIdByName(padSlot.name, padSlot.rank, padSlot.bookType);
    if spellID then
      PickupSpell(spellID, padSlot.bookType);
    end
    padSlot.bookType = nil;
    padSlot.name = nil;
    padSlot.rank = nil;
    padSlot.texture = nil;
    padSlot.type = nil;
    padSlot.action = nil;

  elseif "MACRO" == padSlot.type then
    PickupMacro(padSlot.name);
    padSlot.name = nil;
    padSlot.texture = nil;
    padSlot.type = nil;
    padSlot.action = nil;
  end
end


function BindPadCore.BindKey()
  if not InCombatLockdown() then
    local padSlot = BindPadCore.selectedSlot;
    BindPadCore.UnbindSlot(padSlot);

    if "ITEM" == padSlot.type then
      SetBindingItem(BindPadCore.keyPressed, padSlot.name);
    elseif "SPELL" == padSlot.type then
      if padSlot.rank then
        SetBindingSpell(BindPadCore.keyPressed, padSlot.name.."("..padSlot.rank..")");
      else
        SetBindingSpell(BindPadCore.keyPressed, padSlot.name);
      end
    elseif "MACRO" == padSlot.type then
      SetBindingMacro(BindPadCore.keyPressed, padSlot.name);
    end
	SaveBindings(GetCurrentBindingSet());
  else
    BindPadFrame_OutputText(BINDPAD_TEXT_CANNOT_BIND);
  end
end

function BindPadCore.FindItem(name)
  local linktext;

  -- First check the inventory slots
  for i= 0, 19, 1 do
    linktext = GetInventoryItemLink("player", i);
    if (linktext and string.find(linktext, "%["..name.."%]")) then 
      return -1, i;
    end
  end

  -- not found check bags
  for i=NUM_BAG_FRAMES,0,-1 do
    for j=GetContainerNumSlots(i), 1, -1 do
      linktext = GetContainerItemLink(i, j);
      if (linktext and string.find(linktext, "%["..name.."%]")) then 
        return i, j;
      end
    end
  end

  -- not found return nil,nil implicitly
end

function BindPadCore.UnbindSlot(padSlot)
  if not InCombatLockdown() then
    repeat
      local key = GetBindingKey(padSlot.action);
      if key then
        SetBinding(key);
      end
    until key == nil
    SaveBindings(GetCurrentBindingSet());
  end
end

function BindPadCore.GetSpellNum(bookType)
  local spellNum;
  if bookType == BOOKTYPE_PET then
    spellNum = HasPetSpells() or 0;
  else
    local _,_,offset,num = GetSpellTabInfo(GetNumSpellTabs());
    spellNum = offset+num;
  end
  return spellNum;
end

function BindPadCore.IsHighestRank(spellID, bookType)
  local srchSpellName, srchSpellRank = GetSpellName(spellID, bookType);
  for i = BindPadCore.GetSpellNum(bookType), 1, -1 do
    spellName, spellRank = GetSpellName(i, bookType);
    if spellName == srchSpellName then
      return (srchSpellRank == spellRank);
    end
  end 
end

function BindPadCore.FindSpellIdByName(srchName, srchRank, bookType)
  for i = BindPadCore.GetSpellNum(bookType), 1, -1 do
    spellName, spellRank = GetSpellName(i, bookType);
    if spellName == srchName and (nil == srchRank or spellRank == srchRank) then
      return i;
    end
  end 
end

function BindPadCore.GetBindingText(name, prefix, returnAbbr)
  local modKeys = GetBindingText(name, prefix, nil);

  if ( returnAbbr ) then
    modKeys = gsub(modKeys, "CTRL", "c");
    modKeys = gsub(modKeys, "SHIFT", "s");
    modKeys = gsub(modKeys, "ALT", "a");
    modKeys = gsub(modKeys, "STRG", "st");
    modKeys = gsub(modKeys, "(%l)-(%l)-", "%1%2-");
    modKeys = gsub(modKeys, "Num Pad ", "#");
  end

  return modKeys;
end

function BindPadFrame_ChangeBindingProfile()
  	if ( GetCurrentBindingSet() == 1 ) then
		LoadBindings(2);
		SaveBindings(2);
		BindPadFrameCharacterButton:SetChecked(true);
	else
		StaticPopup_Show("BINDPAD_CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS");
	end
end

