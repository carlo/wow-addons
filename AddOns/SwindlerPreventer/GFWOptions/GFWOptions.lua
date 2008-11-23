------------------------------------------------------------------------------
-- GFWOptions.lua
-- $Id: GFWOptions.lua 643 2008-03-24 03:10:48Z rick $
------------------------------------------------------------------------------

-- WARNING!!!
-- DO NOT MAKE CHANGES TO THIS LIBRARY WITHOUT FIRST CHANGING THE LIBRARY_VERSION_MAJOR
-- STRING (to something unique) OR ELSE YOU MAY BREAK OTHER ADDONS THAT USE THIS LIBRARY!!!
local LIBRARY_VERSION_MAJOR = "GFWOptions-1.0"
local LIBRARY_VERSION_MINOR = tonumber(string.match("$Revision: 643 $", "(%d+)") or 1)

if not DongleStub then error(LIBRARY_VERSION_MAJOR .. " requires DongleStub.") end
if not DongleStub:IsNewerVersion(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR) then return end

local GFWOptions = {};

function GFWOptions:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end

------------------------------------------------------------------------------
-- Internals (panel stuff)
------------------------------------------------------------------------------

local function optionsBuildCommonUI(panel)
	local name = panel:GetName();
	local titleText = panel:CreateFontString(name.."Title", "ARTWORK", "GameFontNormalLarge");
	titleText:SetPoint("TOPLEFT", 16, -16);
	titleText:SetJustifyH("LEFT");
	titleText:SetJustifyV("TOP");
	local title = GetAddOnMetadata(panel.addon, "Title");
	local version = GetAddOnMetadata(panel.addon, "Version");
	titleText:SetText(title .. " " .. version);
	panel.contentAnchor = titleText;
	
	if (panel.description) then
		local subText = panel:CreateFontString(name.."SubText", "ARTWORK", "GameFontHighlightSmall");
		subText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -8);
		subText:SetPoint("RIGHT", -32, 0);
		subText:SetHeight(32);
		subText:SetJustifyH("LEFT");
		subText:SetJustifyV("TOP");
		subText:SetText(panel.description);
		panel.contentAnchor = subText;
	end
end

local function checkDependentControls(control)
	if (control.dependentControls) then
		for _, dependent in pairs(control.dependentControls) do
			local text = getglobal(dependent:GetName().."Text");
			if (control:GetChecked()) then
				if (dependent.menuOptions) then
					UIDropDownMenu_EnableDropDown(dependent);
				else
					dependent:Enable();
					text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				end
			else
				if (dependent.menuOptions) then
					UIDropDownMenu_DisableDropDown(dependent);
				else
					dependent:Disable();
					text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				end
			end
		end
	end
end

local function optionsShow(panel)
	if (not panel.builtUI) then
		optionsBuildCommonUI(panel);
		panel:BuildUI();
		panel.builtUI = true;
	end
	
	-- set UI state
	local addonObj = getglobal(panel.addon);
	local name = panel:GetName();
	panel.existingValues = {};
	for key, default in pairs(addonObj.defaults.profile) do
		local value = addonObj.db.profile[key] or default;
		if (string.sub(key, 1, 2) == "No" and (value == true or value == false)) then
			key = string.sub(key, 3);
			value = not value;
		end
		panel.existingValues[key] = value;
		local control = getglobal(name.."_"..key);
		if (control) then
			local controlType = control:GetFrameType();
			if (controlType == "CheckButton") then
				control:SetChecked(value);
				checkDependentControls(control);
			elseif (controlType == "Slider") then
				control:SetValue(value);
			elseif (control.menuOptions) then
				UIDropDownMenu_Initialize(control, control.initialize);
				UIDropDownMenu_SetSelectedValue(control, value);	
			end
		end
	end
	
end


local function optionsSave(panel)
	-- nothing to do here (for now) since options become effective as they're clicked
end

local function optionsCancel(panel)
	local addonObj = getglobal(panel.addon);
	for key, default in pairs(addonObj.defaults.profile) do
		if (string.sub(key, 1, 2) == "No") then
			key = string.sub(key, 3);
			value = (not value) or nil;
		end
		local value = panel.existingValues[key] or default;
		addonObj.db.profile[key] = value;
	end

	if (addonObj.OptionsChanged) then
		addonObj:OptionsChanged();
	end

end

local function optionsReset(panel)
	local addonObj = getglobal(panel.addon);
	addonObj:ResetProfile();
	
	if (addonObj.OptionsChanged) then
		addonObj:OptionsChanged();
	end
end

------------------------------------------------------------------------------
-- Internals (widgets)
------------------------------------------------------------------------------

local function optionsClickCheckButton()
	if ( this:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	
	local panel = this:GetParent();
	local addonObj = getglobal(panel.addon);
	local name = panel:GetName();
	local key = string.gsub(this:GetName(), name.."_", "");
	if (this.invert) then
		key = "No"..key;
		addonObj.db.profile[key] = not this:GetChecked();
	else
		addonObj.db.profile[key] = this:GetChecked();
	end

	checkDependentControls(this);
	
	if (addonObj.OptionsChanged) then
		addonObj:OptionsChanged();
	end
end

local function optionsValueChangedSlider()
	local addonObj = getglobal(this:GetParent().addon);
	local name = this:GetParent():GetName();
	local key = string.gsub(this:GetName(), name.."_", "");
	addonObj.db.profile[key] = this:GetValue();

	if (addonObj.OptionsChanged) then
		addonObj:OptionsChanged();
	end
end

------------------------------------------------------------------------------
-- panel API
------------------------------------------------------------------------------

-- panel:CreateCheckButton(key, invert)
local function optionsPanelCreateCheckButton(panel, key, invert, small)
	local name = panel:GetName();
	local template = "InterfaceOptionsCheckButtonTemplate";
	if (small) then
		template = "InterfaceOptionsSmallCheckButtonTemplate";
	end
	local button = CreateFrame("CheckButton", name.."_"..key, panel, template);
	button:SetScript("OnClick", optionsClickCheckButton);
	button.invert = invert;
	
	local addonObj = getglobal(panel.addon);
	local text = addonObj.optionsText[key];
	getglobal(button:GetName().."Text"):SetText(text);
	
	return button;
end

-- panel:CreateSlider(key, min, max, step)
local function optionsPanelCreateSlider(panel, key, minValue, maxValue, step)
	local name = panel:GetName();
	local slider = CreateFrame("Slider", name.."_"..key, panel, "InterfaceOptionsSliderTemplate");
	slider:SetScript("OnValueChanged", optionsValueChangedSlider);
	slider:SetMinMaxValues(minValue or 0, maxValue or 100);
	slider:SetValueStep(step or 1);
	
	local addonObj = getglobal(panel.addon);
	local text = addonObj.optionsText[key];
	getglobal(slider:GetName().."Text"):SetText(text);
	
	local minLabel = addonObj.optionsText[key.."_MinLabel"];
	getglobal(slider:GetName().."Low"):SetText(minLabel or "");
	local maxLabel = addonObj.optionsText[key.."_MaxLabel"];
	getglobal(slider:GetName().."High"):SetText(maxLabel or "");
	
	return slider;
end

-- panel:CreateDropDown(key, options, width)
local function optionsPanelCreateDropDown(panel, key, options, width)
	local panelName = panel:GetName();
	local addonObj = getglobal(panel.addon);
	local name = panelName.."_"..key;
	local dropDown = CreateFrame("Frame", name, panel, "UIDropDownMenuTemplate");
	dropDown.menuOptions = options;
	dropDown.key = key;
	
	dropDown.click = function()
		UIDropDownMenu_SetSelectedValue(dropDown, this.value);	
		addonObj.db.profile[dropDown.key] = this.value;

		if (addonObj.OptionsChanged) then
			addonObj:OptionsChanged();
		end
	end
	
	dropDown.initialize = function()
		local selectedValue = UIDropDownMenu_GetSelectedValue(dropDown);
		
		for value, itemInfo in pairs(dropDown.menuOptions) do
			local info = UIDropDownMenu_CreateInfo();
			if (type(itemInfo) == "string") then
				info.text = itemInfo;
			elseif (type(itemInfo) == "table") then
				for k,v in pairs(itemInfo) do
					info[k] = v;
				end
			end
			info.value = value;
			info.func = dropDown.click;
			info.checked = ( info.value == selectedValue );
			UIDropDownMenu_AddButton(info);			
		end
	end
		
	UIDropDownMenu_Initialize(dropDown, dropDown.initialize);
	UIDropDownMenu_SetWidth((width or 140), dropDown);
	
	local text = addonObj.optionsText[key];
	local label = dropDown:CreateFontString(name.."Label", "ARTWORK", "GameFontNormalSmall");
	label:SetPoint("BOTTOMLEFT", dropDown, "TOPLEFT", 18, 3);
	label:SetText(text);
	
	return dropDown;
end

------------------------------------------------------------------------------
-- GFWOptions API
------------------------------------------------------------------------------

function GFWOptions:CreateMainPanel(addonName, panelName, description)
	local panel = CreateFrame("Frame", panelName);
	panel.addon = addonName;
	panel.description = description;
	
	local title = GetAddOnMetadata(addonName, "Title");		-- this gets us the localized title if needed
	title = string.gsub(title, "Fizzwidget", "GFW");		-- shorter so it fits in the list width
	panel.name = title;
	panel.okay = optionsSave;
	panel.cancel = optionsCancel;
	panel.default = optionsReset;
	
	-- inject API
	panel.CreateCheckButton = optionsPanelCreateCheckButton;
	panel.CreateSlider = optionsPanelCreateSlider;
	panel.CreateDropDown = optionsPanelCreateDropDown;
	
	panel:SetScript("OnShow", optionsShow);
	InterfaceOptions_AddCategory(panel);
	
	return panel;
end

------------------------------------------------------------------------------
-- Library Registration
------------------------------------------------------------------------------

local function activate( newInstance, oldInstance )
	if ( oldInstance ) then -- this is an upgrade activate
		for k, v in pairs(oldInstance) do
			if ( type(v) ~= "function" ) then
				newInstance[k] = v;
			end
		end
		GFWOptions = oldInstance;
	else

	end
end

DongleStub:Register(GFWOptions, activate);
