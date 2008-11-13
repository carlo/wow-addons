-------------------------------------------------------------------------------
-- SmartBuff
-- Created by Aeldra (EU-Proudmoore)
--
-- Titan Panel support
-------------------------------------------------------------------------------

TITAN_SMARTBUFF_ID =  SMARTBUFF_TITLE;
TITAN_SMARTBUFF_MENU_TEXT = SMARTBUFF_TITLE;
TITAN_SMARTBUFF_BUTTON_LABEL = SMARTBUFF_TITLE;
TITAN_SMARTBUFF_TOOLTIP = SMARTBUFF_TITLE;
TITAN_SMARTBUFF_ICON_ON = "Interface\\AddOns\\SmartBuff\\Icons\\IconEnabled";
TITAN_SMARTBUFF_ICON_OFF = "Interface\\AddOns\\SmartBuff\\Icons\\IconDisabled";
TITAN_SMARTBUFF_ENABLE = "Enable SmartBuff";
TITAN_SMARTBUFF_BUTTONSHOW = "Show UI Button";
TITAN_SMARTBUFF_BUTTONRESET = "Reset UI Button";
TITAN_SMARTBUFF_TOOLTIP_CONTENTS = "";

function TitanPanelSmartBuffButton_OnLoad()
	this.registry = { 
		id = TITAN_SMARTBUFF_ID,
		menuText = TITAN_SMARTBUFF_MENU_TEXT,
		--buttonTextFunction = TitanPanelSmartBuffButton_GetButtonText,
		tooltipTitle = TITAN_SMARTBUFF_TOOLTIP,
		tooltipTextFunction = "TitanPanelSmartBuffButton_GetTooltipText",
		icon = TITAN_SMARTBUFF_ICON_ON,
		iconWidth = 16,
		savedVariables = {
			ShowIcon = 1,
		--	ShowLabelText = 1,
		}    
	};
	--SMARTBUFF_AddMsgD("SB Titan loaded");
end

function TitanPanelSmartBuffButton_OnShow()
  TitanPanelSmartBuffButton_SetIcon();
  --SMARTBUFF_AddMsgD("SB Titan showed");
end

function TitanPanelSmartBuffButton_OnClick()
  -- LeftButton
  -- RightButton
  -- IsShiftKeyDown()
  if (arg1 == "LeftButton" and IsAltKeyDown()) then
    if (IsAddOnLoaded("SmartDebuff")) then
      SMARTDEBUFF_ToggleSF();
    end  
	elseif (arg1 == "RightButton") then
	  TitanPanelSmartBuff_Toggle();
	elseif (arg1 == "LeftButton") then
		SMARTBUFF_OptionsFrame_Toggle();    
	end
  --TitanPanelButton_OnClick(arg1);
	--SMARTBUFF_AddMsgD("SB Titan clicked");
end

function TitanPanelSmartBuffButton_SetIcon()
	local icon = TitanPanelSmartBuffButtonIcon;
	if (icon and SMARTBUFF_Options) then
    if (SMARTBUFF_Options.Toggle) then
      icon:SetTexture(TITAN_SMARTBUFF_ICON_ON);
	  else
      icon:SetTexture(TITAN_SMARTBUFF_ICON_OFF);
	  end
	end
end

function TitanPanelSmartBuffButton_OnEvent()
  if (TitanPanelButton_UpdateButton) then
    TitanPanelButton_UpdateButton(TITAN_SMARTBUFF_ID);	
    TitanPanelButton_UpdateTooltip();
    --TitanPanelSmartBuffButton_SetIcon();
    --SMARTBUFF_AddMsgD("SB Titan update button event");
  end
end

function TitanPanelSmartBuffButton_GetButtonText(id)
  return "SmartBuff", "";
end

function TitanPanelSmartBuffButton_GetTooltipText()
  return SMARTBUFF_TITAN_TT;
end

function TitanPanelSmartBuff_Toggle()
  SMARTBUFF_OToggle();
end

function TitanPanelRightClickMenu_PrepareSmartBuffMenu()
  --[[
  TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_SMARTBUFF_ID].menuText);
  local info = {};

  info = {};
  info.text = "Show options";
  info.func = SMARTBUFF_OptionsFrame_Toggle;
  info.checked = SmartBuffOptionsFrame:IsVisible();
  UIDropDownMenu_AddButton(info);

  info = {};
  info.text = SMARTBUFF_OFT;
  info.func = TitanPanelSmartBuff_Toggle;
  info.checked = SMARTBUFF_Options.Toggle;
  UIDropDownMenu_AddButton(info);

  TitanPanelRightClickMenu_AddSpacer();
  TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, TITAN_SMARTBUFF_ID, TITAN_PANEL_MENU_FUNC_HIDE);
  ]]--
  
  --SMARTBUFF_AddMsgD("SB Titan menu prepeared");
end
