-------------------------------------------------------------------------------
-- Title: MSBT Options Popups
-- Author: Mik
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {};
local moduleName = "Popups";
MSBTOptions[moduleName] = module;


-------------------------------------------------------------------------------
-- Private constants.
-------------------------------------------------------------------------------

local OUTLINE_MAP = {"", "OUTLINE", "THICKOUTLINE"};
local DEFAULT_TEXT_ALIGN_INDEX = 2;
local DEFAULT_SCROLL_HEIGHT = 260;
local DEFAULT_SCROLL_WIDTH = 40;
local DEFAULT_ANIMATION_STYLE = "Straight";
local DEFAULT_STICKY_ANIMATION_STYLE = "Pow";


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

local popupFrames = {};

-- Backdrop to reuse for the popup frames.
local popupBackdrop = {
  bgFile = "Interface\\Addons\\MSBTOptions\\Artwork\\PlainBackdrop",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  insets = {left = 6, right = 6, top = 6, bottom = 6},
};

-- Backdrop to reuse for the scroll area mover frame.
local moverBackdrop = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
};

-- Reusable table for return settings.
local returnSettings = {};

-- Reusable table to configure popup frames.
local tempConfig = {};

-- Reusable table to hold available conditions.
local availableConditions = {};

-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to certain modules for faster access.
local MSBTControls = MSBTOptions.Controls;
local MSBTLocale = MikSBT.Locale;
local MSBTProfiles = MikSBT.Profiles;
local MSBTAnimations = MikSBT.Animations;
local MSBTTriggers = MikSBT.Triggers;

-- Local references to certain functions for faster access.
local EraseTable = MikSBT.EraseTable;


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when a popup is hidden.
-- ****************************************************************************
local function OnHidePopup(this)
 if (this.hideHandler) then this.hideHandler(); end
end


-- ****************************************************************************
-- Creates a new generic popup.
-- ****************************************************************************
local function CreatePopup()
 local frame = CreateFrame("Frame", nil, UIParent);
 frame:Hide();
 frame:SetMovable(true);
 frame:EnableMouse(true);
 frame:SetToplevel(true);
 frame:SetClampedToScreen(true);
 frame:SetBackdrop(popupBackdrop);
 frame:SetScript("OnHide", OnHidePopup);

 -- Title region.
 local titleRegion = frame:CreateTitleRegion();
 titleRegion:SetAllPoints(frame);

 -- Register the frame with the main module.
 MSBTOptions.Main.RegisterPopupFrame(frame);
 return frame;
end


-- ****************************************************************************
-- Changes the passed popup frame's parent.
-- ****************************************************************************
local function ChangePopupParent(frame, parent)
 -- Changing the parent can cause the frame to be hidden, so ensure the hide
 -- handler isn't called.
 local oldHandler = frame.hideHandler;
 frame.hideHandler = nil;
 frame:SetParent(parent or UIParent);
 MSBTControls.UpdateChildFrameLevels(frame, frame:GetChildren());
 frame.hideHandler = oldHandler;
end


-- ****************************************************************************
-- Disables the controls in the passed table.
-- ****************************************************************************
local function DisableControls(controlsTable)
 for _, frame in pairs(controlsTable) do
  if (frame.Disable) then frame:Disable(); end
 end
end


-- ****************************************************************************
-- Toggles the state of a font dropdown control when an inherit checkbox is
-- changed.
-- ****************************************************************************
local function ToggleDropdownInheritState(dropdown, isInherited, inheritedValue)
 if (isInherited) then
  dropdown:SetSelectedID(inheritedValue);
  dropdown:Disable();
  dropdown:SetAlpha(0.3);
 else
  dropdown:SetAlpha(1);
  dropdown:Enable();
 end
end


-- ****************************************************************************
-- Toggles the state of a font slider control when an inherit checkbox is
-- changed.
-- ****************************************************************************
local function ToggleSliderInheritState(slider, isInherited, inheritedValue)
 if (isInherited) then
  slider:SetValue(inheritedValue);
  slider:Disable();
  slider:SetAlpha(0.3);
 else
  slider:SetAlpha(1);
  slider:Enable();
 end
end




-------------------------------------------------------------------------------
-- Input frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the text in the input frame editbox changes to allow validation.
-- ****************************************************************************
local function ValidateInput(this)
 local frame = popupFrames.inputFrame;
 
 -- Clear validation message and enable okay button.
 frame.validateFontString:SetText("");
 frame.okayButton:Enable();

 if (frame.validateHandler) then
  local message = frame.validateHandler(this:GetText());

  -- Disable the save button and display the validation message if validation failed.
  if (message) then
   frame.validateFontString:SetText(message);
   frame.okayButton:Disable();
  end
 end 
end


-- ****************************************************************************
-- Calls the save handler with the entered input.
-- ****************************************************************************
local function SaveInput()
 local frame = popupFrames.inputFrame;
 if (frame.saveHandler and frame.okayButton:IsEnabled() ~= 0) then
  EraseTable(returnSettings);
  returnSettings.inputText = frame.inputEditbox:GetText();
  returnSettings.secondInputText = frame.secondInputEditbox:GetText();
  returnSettings.saveArg1 = frame.saveArg1;
  frame.saveHandler(returnSettings);
  frame:Hide();
 end
end


-- ****************************************************************************
-- Creates the popup input frame.
-- ****************************************************************************
local function CreateInput()
 local frame = CreatePopup();
 frame:SetWidth(350);
 frame:SetHeight(130);

 -- Input editbox.
 local editbox = MSBTControls.CreateEditbox(frame);
 editbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -25);
 editbox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -25);
 editbox:SetEscapeHandler(
  function (this)
   frame:Hide();
  end
 );
 editbox:SetEnterHandler(SaveInput);
 editbox:SetTextChangedHandler(ValidateInput);
 frame.inputEditbox = editbox;
 
 -- Second input editbox.
 editbox = MSBTControls.CreateEditbox(frame);
 editbox:SetPoint("TOPLEFT", frame.inputEditbox, "BOTTOMLEFT", 0, -10);
 editbox:SetPoint("TOPRIGHT", frame.inputEditbox, "BOTTOMRIGHT", 0, -10);
 editbox:SetEscapeHandler(
  function (this)
   frame:Hide();
  end
 );
 editbox:SetEnterHandler(SaveInput);
 frame.secondInputEditbox = editbox;
 
 
 -- Okay button.
 local button = MSBTControls.CreateOptionButton(frame);
 local objLocale = MSBTLocale.BUTTONS["inputOkay"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 40);
 button:SetClickHandler(SaveInput);
 frame.okayButton = button;

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["inputCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 40);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );
 
 -- Validation text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 20);
 fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 20);
 frame.validateFontString = fontString;

 return frame;
end


-- ****************************************************************************
-- Shows the popup input frame using the passed config.
-- ****************************************************************************
local function ShowInput(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.inputFrame) then popupFrames.inputFrame = CreateInput(); end

 -- Set parent.
 local frame = popupFrames.inputFrame;
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Populate.
 local editbox = frame.inputEditbox
 editbox:SetLabel(configTable.editboxLabel);
 editbox:SetTooltip(configTable.editboxTooltip);
 editbox:SetText("");
 editbox:SetText(configTable.defaultText);

 editbox = frame.secondInputEditbox;
 if (configTable.showSecondEditbox) then
  editbox:Show();
  editbox:SetLabel(configTable.secondEditboxLabel);
  editbox:SetTooltip(configTable.secondEditboxTooltip);
  editbox:SetText(configTable.secondDefaultText);
  frame:SetHeight(170);
 else
  editbox:SetText(nil);
  editbox:Hide();
  frame:SetHeight(130);
 end
 

 -- Configure the frame. 
 frame.showSecondEditbox = configTable.showSecondEditbox;
 frame.validateHandler = configTable.validateHandler;
 frame.saveHandler = configTable.saveHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
 frame.inputEditbox:SetFocus();
end


-------------------------------------------------------------------------------
-- Acknowledge frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup acknowledge frame.
-- ****************************************************************************
local function CreateAcknowledge()
 local frame = CreatePopup();
 frame:SetWidth(350);
 frame:SetHeight(90);
 
 -- Acknowledge text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -20);
 fontString:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -20);
 fontString:SetText(MSBTLocale.MSG_ACKNOWLEDGE_TEXT);

 -- Yes button.
 local button = MSBTControls.CreateOptionButton(frame);
 button:Configure(20, YES, nil);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 15);
 button:SetClickHandler(
  function (this)
   if (frame.acknowledgeHandler) then
    frame.acknowledgeHandler(frame.saveArg1);
    frame:Hide();
   end
  end
 );

 -- No button.
 button = MSBTControls.CreateOptionButton(frame);
 button:Configure(20, NO, nil);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 15);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );
 
 return frame;
end


-- ****************************************************************************
-- Shows the popup acknowledge frame using the passed config.
-- ****************************************************************************
local function ShowAcknowledge(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.acknowledgeFrame) then popupFrames.acknowledgeFrame = CreateAcknowledge(); end


 -- Set parent. 
 local frame = popupFrames.acknowledgeFrame;
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Configure the frame.
 frame.acknowledgeHandler = configTable.acknowledgeHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Font frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Updates the return settings table with the selected font values.
-- ****************************************************************************
local function UpdateFontSettings()
 local frame = popupFrames.fontFrame;

 EraseTable(returnSettings);
 
 if (not frame.hideNormal) then
  returnSettings.normalFontName = not frame.normalFontCheckbox:GetChecked() and frame.normalFontDropdown:GetSelectedID() or nil;
  returnSettings.normalOutlineIndex = not frame.normalOutlineCheckbox:GetChecked() and frame.normalOutlineDropdown:GetSelectedID() or nil;
  returnSettings.normalFontSize = not frame.normalFontSizeCheckbox:GetChecked() and frame.normalFontSizeSlider:GetValue() or nil;
  returnSettings.normalFontAlpha = not frame.normalFontOpacityCheckbox:GetChecked() and frame.normalFontOpacitySlider:GetValue() or nil;
 end
 
 if (not frame.hideCrit) then
  returnSettings.critFontName = not frame.critFontCheckbox:GetChecked() and frame.critFontDropdown:GetSelectedID() or nil;
  returnSettings.critOutlineIndex = not frame.critOutlineCheckbox:GetChecked() and frame.critOutlineDropdown:GetSelectedID() or nil;
  returnSettings.critFontSize = not frame.critFontSizeCheckbox:GetChecked() and frame.critFontSizeSlider:GetValue() or nil;
  returnSettings.critFontAlpha = not frame.critFontOpacityCheckbox:GetChecked() and frame.critFontOpacitySlider:GetValue() or nil;
 end
end


-- ****************************************************************************
-- Updates the normal and crit font previews.
-- ****************************************************************************
local function UpdateFontPreviews()
 local frame = popupFrames.fontFrame;
 local fonts = MSBTAnimations.fonts;

 local fontPath, fontSize, outline;

 if (not frame.hideNormal) then 
  fontPath = fonts[frame.normalFontDropdown:GetSelectedID()];
  fontSize = frame.normalFontSizeSlider:GetValue();
  outline = OUTLINE_MAP[frame.normalOutlineDropdown:GetSelectedID()];
  frame.normalPreviewFontString:SetFont(fontPath, fontSize, outline);
  frame.normalPreviewFontString:SetAlpha(frame.normalFontOpacitySlider:GetValue() / 100);
 end
 
 if (not frame.hideCrit) then
  fontPath = fonts[frame.critFontDropdown:GetSelectedID()];
  fontSize = frame.critFontSizeSlider:GetValue();
  outline = OUTLINE_MAP[frame.critOutlineDropdown:GetSelectedID()];
  if (fontPath and outline) then frame.critPreviewFontString:SetFont(fontPath, fontSize, outline); end
  frame.critPreviewFontString:SetAlpha(frame.critFontOpacitySlider:GetValue() / 100);
 end
end


-- ****************************************************************************
-- Creates the popup font frame.
-- ****************************************************************************
local function CreateFontPopup()
 local frame = CreatePopup();
 frame:SetWidth(450);
 frame:SetHeight(380);

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOP", frame, "TOP", 0, -20);
 frame.titleFontString = fontString;

 
 -- Normal container frame.
 local normalFrame = CreateFrame("Frame", nil, frame);
 normalFrame:SetWidth(195);
 normalFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60);
 normalFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 40);
 frame.normalFrame = normalFrame;


 -- Normal controls container frame.
 local normalControlsFrame = CreateFrame("Frame", nil, normalFrame);
 normalControlsFrame:SetWidth(155);
 normalControlsFrame:SetPoint("TOPLEFT");
 normalControlsFrame:SetPoint("BOTTOMLEFT");
 frame.normalControlsFrame = normalControlsFrame;

 -- Normal font dropdown.
 local dropdown =  MSBTControls.CreateDropdown(normalControlsFrame);
 objLocale = MSBTLocale.DROPDOWNS["normalFont"];
 dropdown:Configure(150, objLocale.label, objLocale.tooltip);
 dropdown:SetListboxHeight(200);
 dropdown:SetPoint("TOPLEFT");
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews();
  end
 );
 frame.normalFontDropdown = dropdown;

 -- Normal outline dropdown.
 dropdown =  MSBTControls.CreateDropdown(normalControlsFrame);
 objLocale = MSBTLocale.DROPDOWNS["normalOutline"];
 dropdown:Configure(150, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.normalFontDropdown, "BOTTOMLEFT", 0, -20);
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews();
  end
 );
 for outlineIndex, outlineName in ipairs(MSBTLocale.OUTLINES) do
  dropdown:AddItem(outlineName, outlineIndex);
 end
 frame.normalOutlineDropdown = dropdown;

 -- Normal font size slider.
 local slider = MSBTControls.CreateSlider(normalControlsFrame);
 objLocale = MSBTLocale.SLIDERS["normalFontSize"]; 
 slider:Configure(150, objLocale.label, objLocale.tooltip);
 slider:SetPoint("TOPLEFT", frame.normalOutlineDropdown, "BOTTOMLEFT", 0, -30);
 slider:SetMinMaxValues(12, 32);
 slider:SetValueStep(1);
 slider:SetValueChangedHandler(
  function(this, value)
    UpdateFontPreviews();
  end
 );
 frame.normalFontSizeSlider = slider;

 -- Normal font opacity slider.
 slider = MSBTControls.CreateSlider(normalControlsFrame);
 objLocale = MSBTLocale.SLIDERS["normalFontOpacity"]; 
 slider:Configure(150, objLocale.label, objLocale.tooltip);
 slider:SetPoint("TOPLEFT", frame.normalFontSizeSlider, "BOTTOMLEFT", 0, -10);
 slider:SetMinMaxValues(1, 100);
 slider:SetValueStep(1);
 slider:SetValueChangedHandler(
  function(this, value)
    UpdateFontPreviews();
  end
 );
 frame.normalFontOpacitySlider = slider;

 -- Normal preview.
 fontString = normalControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("BOTTOM", normalControlsFrame, "BOTTOM", 0, 10);
 fontString:SetText(MSBTLocale.MSG_NORMAL_PREVIEW_TEXT);
 frame.normalPreviewFontString = fontString;



 -- Normal inherit container frame. 
 local normalInheritFrame = CreateFrame("Frame", nil, normalFrame);
 normalInheritFrame:SetWidth(40);
 normalInheritFrame:SetPoint("TOPLEFT", normalControlsFrame, "TOPRIGHT");
 normalInheritFrame:SetPoint("BOTTOMLEFT", normalControlsFrame, "BOTTOMRIGHT");
 frame.normalInheritFrame = normalInheritFrame;
 
 -- Inherit normal font name checkbox.
 local checkbox = MSBTControls.CreateCheckbox(normalInheritFrame);
 objLocale = MSBTLocale.CHECKBOXES["inheritField"]; 
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.normalFontDropdown, "BOTTOMRIGHT", 10, 0);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.normalFontDropdown, isChecked, frame.inheritedNormalFontName);
   UpdateFontPreviews(); 
  end
 );
 frame.normalFontCheckbox = checkbox; 

 -- Inherit normal outline index checkbox.
 checkbox = MSBTControls.CreateCheckbox(normalInheritFrame);
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.normalOutlineDropdown, "BOTTOMRIGHT", 10, 0);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.normalOutlineDropdown, isChecked, frame.inheritedNormalOutlineIndex);
   UpdateFontPreviews(); 
  end
 );
 frame.normalOutlineCheckbox = checkbox; 

 -- Inherit normal font size checkbox.
 checkbox = MSBTControls.CreateCheckbox(normalInheritFrame);
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.normalFontSizeSlider, "BOTTOMRIGHT", 10, 5);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.normalFontSizeSlider, isChecked, frame.inheritedNormalFontSize);
   UpdateFontPreviews(); 
  end
 );
 frame.normalFontSizeCheckbox = checkbox; 

 -- Inherit normal font opacity checkbox.
 checkbox = MSBTControls.CreateCheckbox(normalInheritFrame);
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.normalFontOpacitySlider, "BOTTOMRIGHT", 10, 5);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.normalFontOpacitySlider, isChecked, frame.inheritedNormalFontAlpha);
   UpdateFontPreviews(); 
  end
 );
 frame.normalFontOpacityCheckbox = checkbox; 

 -- Inherit normal column label.
 fontString = normalInheritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("BOTTOM", frame.normalFontCheckbox, "TOP", 0, 7);
 fontString:SetText(MSBTLocale.CHECKBOXES["inheritField"].label);

 
 

 -- Crit container frame.
 local critFrame = CreateFrame("Frame", nil, frame);
 critFrame:SetWidth(195);
 critFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -60);
 critFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 40);
 frame.critFrame = critFrame;

 
 -- Crit controls container frame.
 local critControlsFrame = CreateFrame("Frame", nil, critFrame);
 critControlsFrame:SetWidth(155);
 critControlsFrame:SetPoint("TOPLEFT");
 critControlsFrame:SetPoint("BOTTOMLEFT");
 frame.critControlsFrame = critControlsFrame;

 -- Crit font dropdown.
 dropdown =  MSBTControls.CreateDropdown(critControlsFrame);
 objLocale = MSBTLocale.DROPDOWNS["critFont"];
 dropdown:Configure(150, objLocale.label, objLocale.tooltip);
 dropdown:SetListboxHeight(200);
 dropdown:SetPoint("TOPLEFT");
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews();
  end
 );
 frame.critFontDropdown = dropdown;
 
 -- Crit outline dropdown.
 dropdown =  MSBTControls.CreateDropdown(critControlsFrame);
 objLocale = MSBTLocale.DROPDOWNS["critOutline"];
 dropdown:Configure(150, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.critFontDropdown, "BOTTOMLEFT", 0, -20);
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews();
  end
 );
 for outlineIndex, outlineName in ipairs(MSBTLocale.OUTLINES) do
  dropdown:AddItem(outlineName, outlineIndex);
 end
 frame.critOutlineDropdown = dropdown;

 -- Crit font size slider.
 slider = MSBTControls.CreateSlider(critControlsFrame);
 objLocale = MSBTLocale.SLIDERS["critFontSize"]; 
 slider:Configure(150, objLocale.label, objLocale.tooltip);
 slider:SetPoint("TOPLEFT", frame.critOutlineDropdown, "BOTTOMLEFT", 0, -30);
 slider:SetMinMaxValues(12, 32);
 slider:SetValueStep(1);
 slider:SetValueChangedHandler(
  function(this, value)
    UpdateFontPreviews();
  end
 );
 frame.critFontSizeSlider = slider;

 -- Crit font opacity slider.
 slider = MSBTControls.CreateSlider(critControlsFrame);
 objLocale = MSBTLocale.SLIDERS["critFontOpacity"]; 
 slider:Configure(150, objLocale.label, objLocale.tooltip);
 slider:SetPoint("TOPLEFT", frame.critFontSizeSlider, "BOTTOMLEFT", 0, -10);
 slider:SetMinMaxValues(1, 100);
 slider:SetValueStep(1);
 slider:SetValueChangedHandler(
  function(this, value)
   UpdateFontPreviews();
  end
 );
 frame.critFontOpacitySlider = slider;

 -- Crit Preview. 
 fontString = critControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("BOTTOM", critControlsFrame, "BOTTOM", 0, 10);
 fontString:SetText(MSBTLocale.MSG_CRIT);
 frame.critPreviewFontString = fontString;



 -- Crit inherit container frame. 
 local critInheritFrame = CreateFrame("Frame", nil, critFrame);
 critInheritFrame:SetWidth(40);
 critInheritFrame:SetPoint("TOPLEFT", critControlsFrame, "TOPRIGHT");
 critInheritFrame:SetPoint("BOTTOMLEFT", critControlsFrame, "BOTTOMRIGHT");
 frame.critInheritFrame = critInheritFrame;


 -- Inherit crit font name checkbox.
 local checkbox = MSBTControls.CreateCheckbox(critInheritFrame);
 objLocale = MSBTLocale.CHECKBOXES["inheritField"]; 
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.critFontDropdown, "BOTTOMRIGHT", 10, 0);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.critFontDropdown, isChecked, frame.inheritedCritFontName);
   UpdateFontPreviews(); 
  end
 );
 frame.critFontCheckbox = checkbox; 

 -- Inherit crit outline index checkbox.
 checkbox = MSBTControls.CreateCheckbox(critInheritFrame);
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.critOutlineDropdown, "BOTTOMRIGHT", 10, 0);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.critOutlineDropdown, isChecked, frame.inheritedCritOutlineIndex);
   UpdateFontPreviews(); 
  end
 );
 frame.critOutlineCheckbox = checkbox; 

 -- Inherit crit font size checkbox.
 checkbox = MSBTControls.CreateCheckbox(critInheritFrame);
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.critFontSizeSlider, "BOTTOMRIGHT", 10, 5);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.critFontSizeSlider, isChecked, frame.inheritedCritFontSize);
   UpdateFontPreviews(); 
  end
 );
 frame.critFontSizeCheckbox = checkbox; 

 -- Inherit crit font opacity checkbox.
 checkbox = MSBTControls.CreateCheckbox(critInheritFrame);
 checkbox:Configure(20, nil, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.critFontOpacitySlider, "BOTTOMRIGHT", 10, 5);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.critFontOpacitySlider, isChecked, frame.inheritedCritFontAlpha);
   UpdateFontPreviews(); 
  end
 );
 frame.critFontOpacityCheckbox = checkbox; 

 -- Inherit normal column label.
 fontString = critInheritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("BOTTOM", frame.critFontCheckbox, "TOP", 0, 7);
 fontString:SetText(MSBTLocale.CHECKBOXES["inheritField"].label);

 -- Save button.
 local button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericSave"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20);
 button:SetClickHandler(
  function (this)
   UpdateFontSettings();
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1); end
   frame:Hide();
  end
 );

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );
 

 -- Register the frame with the main module.
 MSBTOptions.Main.RegisterPopupFrame(frame);
 return frame;
end


-- ****************************************************************************
-- Shows the popup font frame using the passed config.
-- ****************************************************************************
local function ShowFont(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.fontFrame) then popupFrames.fontFrame = CreateFontPopup(); end

 -- Set parent.
 local frame = popupFrames.fontFrame; 
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Show / Hide appropriate controls.
 if (configTable.hideNormal) then frame.normalFrame:Hide(); else frame.normalFrame:Show(); end
 if (configTable.hideCrit) then frame.critFrame:Hide(); else frame.critFrame:Show(); end
 if (configTable.hideInherit) then frame.normalInheritFrame:Hide(); else frame.normalInheritFrame:Show(); end
 if (configTable.hideInherit) then frame.critInheritFrame:Hide(); else frame.critInheritFrame:Show(); end
 frame.hideNormal = configTable.hideNormal;
 frame.hideCrit = configTable.hideCrit;


 -- Populate data.
 local dropdown, checkbox, slider;
 frame.titleFontString:SetText(configTable.title); 

 if (not configTable.hideNormal) then 
  -- Normal font name.
  dropdown = frame.normalFontDropdown;
  dropdown:Clear();
  for fontName in pairs(MSBTAnimations.fonts) do
   dropdown:AddItem(fontName, fontName);
  end
  dropdown:Sort();
  checkbox = frame.normalFontCheckbox;
  checkbox:SetChecked(not configTable.normalFontName or false);
  if (configTable.normalFontName) then dropdown:SetSelectedID(configTable.normalFontName); end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedNormalFontName);

  -- Normal outline index.
  dropdown = frame.normalOutlineDropdown;
  checkbox = frame.normalOutlineCheckbox;
  checkbox:SetChecked(not configTable.normalOutlineIndex or false);
  if (configTable.normalOutlineIndex) then dropdown:SetSelectedID(configTable.normalOutlineIndex); end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedNormalOutlineIndex);

  -- Normal font size. 
  slider = frame.normalFontSizeSlider;
  checkbox = frame.normalFontSizeCheckbox;
  checkbox:SetChecked(not configTable.normalFontSize or false);
  if (configTable.normalFontSize) then slider:SetValue(configTable.normalFontSize); end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedNormalFontSize);

  -- Normal font opacity. 
  slider = frame.normalFontOpacitySlider;
  checkbox = frame.normalFontOpacityCheckbox;
  checkbox:SetChecked(not configTable.normalFontAlpha or false);
  if (configTable.normalFontAlpha) then slider:SetValue(configTable.normalFontAlpha); end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedNormalFontAlpha);
 end


 if (not configTable.hideCrit) then
  -- Crit font name.
  dropdown = frame.critFontDropdown;
  dropdown:Clear();
  for fontName in pairs(MSBTAnimations.fonts) do
   dropdown:AddItem(fontName, fontName);
  end
  dropdown:Sort();
  checkbox = frame.critFontCheckbox;
  checkbox:SetChecked(not configTable.critFontName or false);
  if (configTable.critFontName) then dropdown:SetSelectedID(configTable.critFontName); end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedCritFontName);

  -- Crit outline index.
  dropdown = frame.critOutlineDropdown;
  checkbox = frame.critOutlineCheckbox;
  checkbox:SetChecked(not configTable.critOutlineIndex or false);
  if (configTable.critOutlineIndex) then dropdown:SetSelectedID(configTable.critOutlineIndex); end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedCritOutlineIndex);

  -- Crit font size. 
  slider = frame.critFontSizeSlider;
  checkbox = frame.critFontSizeCheckbox;
  checkbox:SetChecked(not configTable.critFontSize or false);
  if (configTable.critFontSize) then slider:SetValue(configTable.critFontSize); end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedCritFontSize);

   -- Crit font opacity. 
  slider = frame.critFontOpacitySlider;
  checkbox = frame.critFontOpacityCheckbox;
  checkbox:SetChecked(not configTable.critFontAlpha or false);
  if (configTable.critFontAlpha) then slider:SetValue(configTable.critFontAlpha); end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedCritFontAlpha);
 end 


 -- Store inherited settings. 
 frame.inheritedNormalFontName = configTable.inheritedNormalFontName;
 frame.inheritedNormalOutlineIndex = configTable.inheritedNormalOutlineIndex;
 frame.inheritedNormalFontSize = configTable.inheritedNormalFontSize;
 frame.inheritedNormalFontAlpha = configTable.inheritedNormalFontAlpha;
 frame.inheritedCritFontName = configTable.inheritedCritFontName;
 frame.inheritedCritOutlineIndex = configTable.inheritedCritOutlineIndex;
 frame.inheritedCritFontSize = configTable.inheritedCritFontSize;
 frame.inheritedCritFontAlpha = configTable.inheritedCritFontAlpha;
 
 
 -- Configure the frame. 
 frame.saveHandler = configTable.saveHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise(); 

 UpdateFontPreviews(); 
end


-------------------------------------------------------------------------------
-- Partial effects frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup partial effects frame.
-- ****************************************************************************
local function CreatePartialEffects()
 local frame = CreatePopup();
 frame:SetWidth(270);
 frame:SetHeight(260);

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2);

 -- Color partial effects.
 local checkbox = MSBTControls.CreateCheckbox(frame);
 local objLocale = MSBTLocale.CHECKBOXES["colorPartialEffects"];
 checkbox:Configure(24, objLocale.label, objLocale.tooltip);
 checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20);
 checkbox:SetClickHandler(
  function (this, isChecked)
   MSBTProfiles.SetOption(nil, "partialColoringDisabled", not isChecked);
  end
 );
 frame.colorCheckbox = checkbox;


 -- Partial effects.
 local anchor = checkbox;
 local colorswatch;
 for effectType in string.gmatch("crushing glancing absorb block resist vulnerability overheal", "[^%s]+") do
  colorswatch = MSBTControls.CreateColorswatch(frame);
  colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == checkbox and 20 or 0, -10);
  colorswatch:SetColorChangedHandler(
   function (this)
    MSBTProfiles.SetOption(effectType, "colorR", this.r);
    MSBTProfiles.SetOption(effectType, "colorG", this.g);
    MSBTProfiles.SetOption(effectType, "colorB", this.b);
   end
  );
  checkbox = MSBTControls.CreateCheckbox(frame);
  objLocale = MSBTLocale.CHECKBOXES[effectType];
  checkbox:Configure(24, objLocale.label, objLocale.tooltip);
  checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0);
  checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(effectType, "disabled", not isChecked);
   end
  );
  frame[effectType .. "Colorswatch"] = colorswatch;
  frame[effectType .. "Checkbox"] = checkbox; 
  
  anchor = colorswatch;
 end

  return frame;
end


-- ****************************************************************************
-- Shows the popup damage partial effects frame using the passed config.
-- ****************************************************************************
local function ShowPartialEffects(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.partialEffectsFrame) then popupFrames.partialEffectsFrame = CreatePartialEffects(); end

 -- Set parent.
 local frame = popupFrames.partialEffectsFrame;
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Populate data.
 frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.partialColoringDisabled);
 
 local profileEntry;
 for effectType in string.gmatch("crushing glancing absorb block resist vulnerability overheal", "[^%s]+") do
  profileEntry = MSBTProfiles.currentProfile[effectType];
  frame[effectType .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB);
  frame[effectType .. "Checkbox"]:SetChecked(not profileEntry.disabled);
 end
 
 -- Configure the frame.
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Damage color frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup damage colors frame.
-- ****************************************************************************
local function CreateDamageColors()
 local frame = CreatePopup();
 frame:SetWidth(260);
 frame:SetHeight(220);

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2);

 -- Color damage amounts.
 local checkbox = MSBTControls.CreateCheckbox(frame);
 local objLocale = MSBTLocale.CHECKBOXES["colorDamageAmounts"];
 checkbox:Configure(24, objLocale.label, objLocale.tooltip);
 checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20);
 checkbox:SetClickHandler(
  function (this, isChecked)
   MSBTProfiles.SetOption(nil, "damageColoringDisabled", not isChecked);
  end
 );
 frame.colorCheckbox = checkbox;


 -- Damage types.
 local anchor = checkbox;
 local globalStringSchoolIndex = 0;
 local colorswatch, fontString;
 for damageType in string.gmatch("physical holy fire nature frost shadow arcane", "[^%s]+") do
  colorswatch = MSBTControls.CreateColorswatch(frame);
  colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == checkbox and 20 or 0, anchor == checkbox and -10 or -5);
  colorswatch:SetColorChangedHandler(
   function (this)
    MSBTProfiles.SetOption(damageType, "colorR", this.r);
    MSBTProfiles.SetOption(damageType, "colorG", this.g);
    MSBTProfiles.SetOption(damageType, "colorB", this.b);
   end
  );
  checkbox = MSBTControls.CreateCheckbox(frame);
  objLocale = MSBTLocale.CHECKBOXES["colorDamageEntry"];
  checkbox:Configure(24, _G["SPELL_SCHOOL" .. globalStringSchoolIndex .. "_CAP"], objLocale.tooltip);
  checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0);
  checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(damageType, "disabled", not isChecked);
   end
  );
  frame[damageType .. "Colorswatch"] = colorswatch;
  frame[damageType .. "Checkbox"] = checkbox; 
  
  anchor = colorswatch; 
  globalStringSchoolIndex = globalStringSchoolIndex + 1;
 end

 return frame;
end


-- ****************************************************************************
-- Shows the popup damage type colors frame using the passed config.
-- ****************************************************************************
local function ShowDamageColors(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.damageColorsFrame) then popupFrames.damageColorsFrame = CreateDamageColors(); end

 -- Set parent.
 local frame = popupFrames.damageColorsFrame;
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.damageColoringDisabled);

 local profileEntry;
 for damageType in string.gmatch("physical holy fire nature frost shadow arcane", "[^%s]+") do
  profileEntry = MSBTProfiles.currentProfile[damageType];
  frame[damageType .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB);
  frame[damageType .. "Checkbox"]:SetChecked(not profileEntry.disabled);
 end
 
 -- Configure the frame.
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Scroll area config frame functions.
-------------------------------------------------------------------------------

-- **********************************************************************************
-- This function copies the current scroll area settings into the passed table key.
-- **********************************************************************************
local function CopyTempScrollAreaSettings(settingsTable)
 local frame = popupFrames.scrollAreaConfigFrame;
 EraseTable(settingsTable);

 -- Get the original settings.
 local tempSettings;
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  settingsTable[saKey] = {};
  tempSettings = settingsTable[saKey];

  -- Normal.
  tempSettings.animationStyle = saSettings.animationStyle or DEFAULT_ANIMATION_STYLE;
  tempSettings.direction = saSettings.direction;
  tempSettings.behavior = saSettings.behavior;
  tempSettings.textAlignIndex = saSettings.textAlignIndex or DEFAULT_TEXT_ALIGN_INDEX;

  -- Sticky.
  tempSettings.stickyAnimationStyle = saSettings.stickyAnimationStyle or DEFAULT_STICKY_ANIMATION_STYLE;
  tempSettings.stickyDirection = saSettings.stickyDirection;
  tempSettings.stickyBehavior = saSettings.stickyBehavior;
  tempSettings.stickyTextAlignIndex = saSettings.stickyTextAlignIndex or DEFAULT_TEXT_ALIGN_INDEX;

  -- Positioning.
  tempSettings.scrollHeight = saSettings.scrollHeight or DEFAULT_SCROLL_HEIGHT;
  tempSettings.scrollWidth = saSettings.scrollWidth or DEFAULT_SCROLL_WIDTH;
  tempSettings.offsetX = saSettings.offsetX or 0;
  tempSettings.offsetY = saSettings.offsetY or 0;

  -- Speed.
  tempSettings.inheritedAnimationSpeed = MSBTProfiles.currentProfile.animationSpeed;
  tempSettings.animationSpeed = saSettings.animationSpeed;
 end
end


-- ****************************************************************************
-- Changes the normal animation style to the passed value.
-- ****************************************************************************
local function ChangeAnimationStyle(styleKey)
 local frame = popupFrames.scrollAreaConfigFrame;
 local styleSettings = MSBTAnimations.animationStyles[styleKey];
 local firstEntry, name, objLocale;

 -- Normal direction.
 frame.directionDropdown:Clear();
 if (styleSettings.availableDirections) then
  for direction in string.gmatch(styleSettings.availableDirections, "[^;]+") do
   if (not firstEntry) then firstEntry = direction; end
   objLocale = styleSettings.localizationTable;
   name = objLocale and objLocale[direction] or MSBTLocale.ANIMATION_STYLE_DATA[direction] or direction;
   frame.directionDropdown:AddItem(name, direction);
  end
  frame.directionDropdown:SetSelectedID(firstEntry);  
 else
  -- No available directions, so just add a normal entry.
  frame.directionDropdown:AddItem(MSBTLocale.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL");
  frame.directionDropdown:SetSelectedID("MSBT_NORMAL");
 end
 
 -- Normal behavior.
 firstEntry = nil;
 frame.behaviorDropdown:Clear();
 if (styleSettings.availableBehaviors) then
  for behavior in string.gmatch(styleSettings.availableBehaviors, "[^;]+") do
   if (not firstEntry) then firstEntry = behavior; end
   objLocale = styleSettings.localizationTable;
   name = objLocale and objLocale[behavior] or MSBTLocale.ANIMATION_STYLE_DATA[behavior] or behavior;
   frame.behaviorDropdown:AddItem(name, behavior);
  end
  frame.behaviorDropdown:SetSelectedID(firstEntry);  
 else
  -- No available behaviors, so just add a normal entry.
  frame.behaviorDropdown:AddItem(MSBTLocale.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL");
  frame.behaviorDropdown:SetSelectedID("MSBT_NORMAL");
 end
end


-- ****************************************************************************
-- Changes the sticky animation style to the passed value.
-- ****************************************************************************
local function ChangeStickyAnimationStyle(styleKey)
 local frame = popupFrames.scrollAreaConfigFrame;
 local styleSettings = MSBTAnimations.stickyAnimationStyles[styleKey];
 local firstEntry, name, objLocale;

 -- Sticky direction.
 frame.stickyDirectionDropdown:Clear();
 if (styleSettings.availableDirections) then
  for direction in string.gmatch(styleSettings.availableDirections, "[^;]+") do
   if (not firstEntry) then firstEntry = direction; end
   objLocale = styleSettings.localizationTable;
   name = objLocale and objLocale[direction] or MSBTLocale.ANIMATION_STYLE_DATA[direction] or direction;
   frame.stickyDirectionDropdown:AddItem(name, direction);
  end
  frame.stickyDirectionDropdown:SetSelectedID(firstEntry);  
 else
  -- No available directions, so just add a normal entry.
  frame.stickyDirectionDropdown:AddItem(MSBTLocale.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL");
  frame.stickyDirectionDropdown:SetSelectedID("MSBT_NORMAL");
 end
 
 -- Sticky behavior.
 firstEntry = nil;
 frame.stickyBehaviorDropdown:Clear();
 if (styleSettings.availableBehaviors) then
  for behavior in string.gmatch(styleSettings.availableBehaviors, "[^;]+") do
   if (not firstEntry) then firstEntry = behavior; end
   objLocale = styleSettings.localizationTable;
   name = objLocale and objLocale[behavior] or MSBTLocale.ANIMATION_STYLE_DATA[behavior] or behavior;
   frame.stickyBehaviorDropdown:AddItem(name, behavior);
  end
  frame.stickyBehaviorDropdown:SetSelectedID(firstEntry);  
 else
  -- No available behaviors, so just add a normal entry.
  frame.stickyBehaviorDropdown:AddItem(MSBTLocale.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL");
  frame.stickyBehaviorDropdown:SetSelectedID("MSBT_NORMAL");
 end
end


-- ****************************************************************************
-- Changes the scroll area to configure to the passed value.
-- ****************************************************************************
local function ChangeConfigScrollArea(scrollArea)
 local frame = popupFrames.scrollAreaConfigFrame;
 frame.currentScrollArea = scrollArea;
 local saSettings = frame.previewSettings[scrollArea];
 local name, objLocale;

 -- Normal animation style.
 frame.animationStyleDropdown:Clear();
 for styleKey, settings in pairs(MSBTAnimations.animationStyles) do 
  objLocale = settings.localizationTable;
  name = objLocale and objLocale[styleKey] or MSBTLocale.ANIMATION_STYLE_DATA[styleKey] or styleKey;
  frame.animationStyleDropdown:AddItem(name, styleKey);
 end
 frame.animationStyleDropdown:SetSelectedID(saSettings.animationStyle);
 ChangeAnimationStyle(saSettings.animationStyle);

 -- Normal direction, behavior, and text align.
 if (saSettings.direction) then frame.directionDropdown:SetSelectedID(saSettings.direction); end
 if (saSettings.behavior) then frame.behaviorDropdown:SetSelectedID(saSettings.behavior); end
 frame.textAlignDropdown:SetSelectedID(saSettings.textAlignIndex);


 -- Sticky animation style.
 frame.stickyAnimationStyleDropdown:Clear();
 for styleKey, settings in pairs(MSBTAnimations.stickyAnimationStyles) do 
  objLocale = settings.localizationTable;
  name = objLocale and objLocale[styleKey] or MSBTLocale.ANIMATION_STYLE_DATA[styleKey] or styleKey;
  frame.stickyAnimationStyleDropdown:AddItem(name, styleKey);
 end
 frame.stickyAnimationStyleDropdown:SetSelectedID(saSettings.stickyAnimationStyle);
 ChangeStickyAnimationStyle(saSettings.stickyAnimationStyle);

 -- Sticky direction, behavior, and text align.
 if (saSettings.stickyDirection) then frame.stickyDirectionDropdown:SetSelectedID(saSettings.stickyDirection); end
 if (saSettings.stickyBehavior) then frame.stickyBehaviorDropdown:SetSelectedID(saSettings.stickyBehavior); end
 frame.stickyTextAlignDropdown:SetSelectedID(saSettings.stickyTextAlignIndex);

 -- Scroll height and width.
 frame.scrollHeightSlider:SetValue(saSettings.scrollHeight);
 frame.scrollWidthSlider:SetValue(saSettings.scrollWidth);

 -- Animation speed
 frame.animationSpeedCheckbox:SetChecked(not saSettings.animationSpeed or false);
 if (saSettings.animationSpeed) then frame.animationSpeedSlider:SetValue(saSettings.animationSpeed); end
 ToggleSliderInheritState(frame.animationSpeedSlider, frame.animationSpeedCheckbox:GetChecked(), saSettings.inheritedAnimationSpeed);
 
 -- X and Y offset.
 frame.xOffsetEditbox:SetText(saSettings.offsetX);
 frame.yOffsetEditbox:SetText(saSettings.offsetY);
 
 -- Reset the backdrop color of all the scroll area mover frames to grey.
 for _, moverFrame in pairs(frame.moverFrames) do
  moverFrame:SetBackdropColor(0.8, 0.8, 0.8, 1.0);
 end
 
 -- Set the selected scroll area mover frame to red and raise it.
 frame.moverFrames[scrollArea]:SetBackdropColor(0.5, 0.05, 0.05, 1.0);
 frame.moverFrames[scrollArea]:Raise();
end


-- **********************************************************************************
-- This function repositions the mover frame for the passed scroll area.
-- **********************************************************************************
local function RepositionScrollAreaMoverFrame(scrollArea)
 local configFrame = popupFrames.scrollAreaConfigFrame;
 local frame = configFrame.moverFrames[scrollArea];
 local saSettings = configFrame.previewSettings[scrollArea];

 frame:ClearAllPoints();
 frame:SetPoint("BOTTOMLEFT", UIParent, "CENTER", saSettings.offsetX, saSettings.offsetY);
 frame:SetHeight(saSettings.scrollHeight);
 frame:SetWidth(saSettings.scrollWidth);
 frame.fontString:SetText(MSBTAnimations.scrollAreas[scrollArea].name .. " (" .. saSettings.offsetX .. ", " .. saSettings.offsetY .. ")");
 frame:Show();
end


-- **********************************************************************************
-- Save the coordinates of a scroll area mover.
-- **********************************************************************************
local function SaveScrollAreaMoverCoordinates(frame)
 -- Get the UIParent center x and y coords.
 local uiParentX, uiParentY = UIParent:GetCenter();
 local xOffset = math.ceil(this:GetLeft() - uiParentX);
 local yOffset = math.ceil(this:GetBottom() - uiParentY);
 
 -- Save the x and y offsets.
 local configFrame = popupFrames.scrollAreaConfigFrame;
 configFrame.previewSettings[frame.scrollArea].offsetX = xOffset;
 configFrame.previewSettings[frame.scrollArea].offsetY = yOffset;

 -- Populate the x and y offset editboxes if the moved frame is the selected one.
 if (frame.scrollArea == configFrame.scrollAreaDropdown:GetSelectedID()) then
  configFrame.xOffsetEditbox:SetText(xOffset);
  configFrame.yOffsetEditbox:SetText(yOffset);
 end

 -- Reposition the scroll area mover frames to update the coordinates.
 RepositionScrollAreaMoverFrame(frame.scrollArea);
end


-- **********************************************************************************
-- Called when a mouse button is pressed on a mover frame.
-- **********************************************************************************
local function MoverFrameOnMouseDown(this, button)
 if (button == "LeftButton") then this:StartMoving(); end 
end


-- **********************************************************************************
-- Called when a mouse button is released on a mover frame.
-- **********************************************************************************
local function MoverFrameOnMouseUp(this)
 this:StopMovingOrSizing();
 SaveScrollAreaMoverCoordinates(this);

 local configFrame = popupFrames.scrollAreaConfigFrame;
 if (this.scrollArea ~= configFrame.scrollAreaDropdown:GetSelectedID()) then
  configFrame.scrollAreaDropdown:SetSelectedID(this.scrollArea);
  ChangeConfigScrollArea(this.scrollArea);
 end
end


-- **********************************************************************************
-- This function creates a scroll area mover frame for the passed scroll area if
-- it hasn't already been
-- **********************************************************************************
local function CreateScrollAreaMoverFrame(scrollArea)
 local moverFrames = popupFrames.scrollAreaConfigFrame.moverFrames;
 
 if (not moverFrames[scrollArea]) then
  local frame = CreateFrame("FRAME", nil, UIParent);
  frame:Hide();
  frame:SetMovable(true);
  frame:EnableMouse(true);
  frame:SetToplevel(true);
  frame:SetClampedToScreen(true);
  frame:SetBackdrop(moverBackdrop);
  frame:SetScript("OnMouseDown", MoverFrameOnMouseDown);
  frame:SetScript("OnMouseUp", MoverFrameOnMouseUp);
  
  local fontString = frame:CreateFontString(nil, "OVERLAY");
  fontString:SetFont("Fonts\\ARIALN.TTF", 12);
  fontString:SetPoint("CENTER");
  frame.fontString = fontString;

  frame.scrollArea = scrollArea;
  moverFrames[scrollArea] = frame;
 end
end


-- **********************************************************************************
-- Save the passed table to the scroll area settings.
-- **********************************************************************************
local function SaveScrollAreaSettings(settingsTable)
 local frame = popupFrames.scrollAreaConfigFrame;
 
 -- Save the settings in the passed table to the current profile.
 for saKey, saSettings in pairs(settingsTable) do
  -- Normal.
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "animationStyle", saSettings.animationStyle, DEFAULT_ANIMATION_STYLE);
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "direction", saSettings.direction, "MSBT_NORMAL");
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "behavior", saSettings.behavior, "MSBT_NORMAL");  
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "textAlignIndex", saSettings.textAlignIndex, DEFAULT_TEXT_ALIGN_INDEX);
  
  -- Sticky.
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyAnimationStyle", saSettings.stickyAnimationStyle, DEFAULT_STICKY_ANIMATION_STYLE);
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyDirection", saSettings.stickyDirection, "MSBT_NORMAL");
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyBehavior", saSettings.stickyBehavior, "MSBT_NORMAL");
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyTextAlignIndex", saSettings.stickyTextAlignIndex, DEFAULT_TEXT_ALIGN_INDEX);
  
  -- Position.  
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "scrollHeight", saSettings.scrollHeight, DEFAULT_SCROLL_HEIGHT);
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "scrollWidth", saSettings.scrollWidth, DEFAULT_SCROLL_WIDTH);
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "offsetX", saSettings.offsetX);
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "offsetY", saSettings.offsetY);
  
  -- Animation speed.
  local animationSpeed = saSettings.animationSpeed;
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "animationSpeed", animationSpeed, saSettings.inheritedAnimationSpeed);
 end
 MSBTAnimations.UpdateScrollAreas();
end


-- ****************************************************************************
-- Creates the popup scroll areas config frames.
-- ****************************************************************************
local function CreateScrollAreaConfig()
 local frame = CreatePopup();
 frame:SetWidth(320);
 frame:SetHeight(535);
 frame:SetPoint("RIGHT");
 frame:SetScript("OnHide",
  function (this)
   for _, moverFrame in pairs(this.moverFrames) do
    moverFrame:Hide();
   end
   MSBTOptions.Main.ShowMainFrame();
  end
 );
 
 -- Scroll area dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["scrollArea"];
 dropdown:Configure(200, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOP", frame, "TOP", 0, -20);
 dropdown:SetChangeHandler(
  function (this, id)
   ChangeConfigScrollArea(id);
  end
 );
 frame.scrollAreaDropdown = dropdown;

 
 -- Top horizontal bar.
 local texture = frame:CreateTexture(nil, "ARTWORK");
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft");
 texture:SetHeight(4);
 texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -70);
 texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -70);
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125);

 
 -- Normal animation style dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["animationStyle"];
 dropdown:Configure(135, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", texture, "BOTTOMLEFT", 5, -15);
 dropdown:SetChangeHandler(
  function (this, id)
   ChangeAnimationStyle(id);
   frame.previewSettings[frame.currentScrollArea].animationStyle = id;
   frame.previewSettings[frame.currentScrollArea].direction = frame.directionDropdown:GetSelectedID();
   frame.previewSettings[frame.currentScrollArea].behavior = frame.behaviorDropdown:GetSelectedID();
  end
 );
 frame.animationStyleDropdown = dropdown;

 -- Sticky animation style dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["stickyAnimationStyle"];
 dropdown:Configure(135, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("LEFT", frame.animationStyleDropdown, "RIGHT", 15, 0);
 dropdown:SetChangeHandler(
  function (this, id)
   ChangeStickyAnimationStyle(id);
   frame.previewSettings[frame.currentScrollArea].stickyAnimationStyle = id;
   frame.previewSettings[frame.currentScrollArea].stickyDirection = frame.stickyDirectionDropdown:GetSelectedID();
   frame.previewSettings[frame.currentScrollArea].stickyBehavior = frame.stickyBehaviorDropdown:GetSelectedID();
  end
 );
 frame.stickyAnimationStyleDropdown = dropdown;

 -- Normal direction dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["direction"];
 dropdown:Configure(135,objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.animationStyleDropdown, "BOTTOMLEFT", 0, -10);
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].direction = id;
  end
 );
 frame.directionDropdown = dropdown;

 -- Sticky direction dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["direction"];
 dropdown:Configure(135, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.stickyAnimationStyleDropdown, "BOTTOMLEFT", 0, -10);
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.scrollAreaDropdown:GetSelectedID()].stickyDirection = id;
  end
 );
 frame.stickyDirectionDropdown = dropdown;

 -- Normal behavior dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["behavior"];
 dropdown:Configure(135, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.directionDropdown, "BOTTOMLEFT", 0, -10);
  dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].behavior = id;
  end
 );
 frame.behaviorDropdown = dropdown;

 -- Sticky behavior dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["behavior"];
 dropdown:Configure(135, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.stickyDirectionDropdown, "BOTTOMLEFT", 0, -10);
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].stickyBehavior = id;
  end
 );
 frame.stickyBehaviorDropdown = dropdown;

 -- Normal text align dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["textAlign"];
 dropdown:Configure(135, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.behaviorDropdown, "BOTTOMLEFT", 0, -10);
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].textAlignIndex = id;
  end
 );
 for index, anchorPoint in ipairs(MSBTLocale.TEXT_ALIGNS) do
  dropdown:AddItem(anchorPoint, index);
 end
 frame.textAlignDropdown = dropdown;

 -- Sticky text align dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["textAlign"];
 dropdown:Configure(135, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame.stickyBehaviorDropdown, "BOTTOMLEFT", 0, -10);
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].stickyTextAlignIndex = id;
  end
 );
 for index, anchorPoint in ipairs(MSBTLocale.TEXT_ALIGNS) do
  dropdown:AddItem(anchorPoint, index);
 end
 frame.stickyTextAlignDropdown = dropdown;

 
 -- Middle horizontal bar.
 texture = frame:CreateTexture(nil, "ARTWORK");
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft");
 texture:SetHeight(4);
 texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -295);
 texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -295);
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125);

 
 -- Scroll height slider.
 local slider = MSBTControls.CreateSlider(frame);
 objLocale = MSBTLocale.SLIDERS["scrollHeight"]; 
 slider:Configure(135, objLocale.label, objLocale.tooltip);
 slider:SetPoint("TOPLEFT", texture, "BOTTOMLEFT", 5, -15);
 slider:SetMinMaxValues(100, 600);
 slider:SetValueStep(5);
 slider:SetValueChangedHandler(
  function(this, value)
   frame.previewSettings[frame.currentScrollArea].scrollHeight = value;
   RepositionScrollAreaMoverFrame(frame.currentScrollArea);
  end
 );
 frame.scrollHeightSlider = slider;

 -- Scroll width slider.
 slider = MSBTControls.CreateSlider(frame);
 objLocale = MSBTLocale.SLIDERS["scrollWidth"]; 
 slider:Configure(135, objLocale.label, objLocale.tooltip);
 slider:SetPoint("LEFT", frame.scrollHeightSlider, "RIGHT", 15, 0);
 slider:SetMinMaxValues(10, 800);
 slider:SetValueStep(10);
 slider:SetValueChangedHandler(
  function(this, value)
   frame.previewSettings[frame.currentScrollArea].scrollWidth = value;
   RepositionScrollAreaMoverFrame(frame.currentScrollArea);
  end
 );
 frame.scrollWidthSlider = slider;

 -- Animation speed slider.
 slider = MSBTControls.CreateSlider(frame);
 objLocale = MSBTLocale.SLIDERS["scrollAnimationSpeed"]; 
 slider:Configure(135, objLocale.label, objLocale.tooltip);
 slider:SetPoint("TOPLEFT", frame.scrollHeightSlider, "BOTTOMLEFT", 0, -10);
 slider:SetMinMaxValues(50, 250);
 slider:SetValueStep(10);
 slider:SetValueChangedHandler(
  function(this, value)
   if (not frame.animationSpeedCheckbox:GetChecked()) then
    frame.previewSettings[frame.currentScrollArea].animationSpeed = value;
   end
  end
 );
 frame.animationSpeedSlider = slider;
 
 -- Inherit animation speed checkbox.
 checkbox = MSBTControls.CreateCheckbox(frame);
 objLocale = MSBTLocale.CHECKBOXES["inheritField"]; 
 checkbox:Configure(20, objLocale.label, objLocale.tooltip);
 checkbox:SetPoint("BOTTOMLEFT", frame.animationSpeedSlider, "BOTTOMRIGHT", 10, 5);
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.animationSpeedSlider, isChecked, frame.previewSettings[frame.currentScrollArea].inheritedAnimationSpeed);
  end
 );
 frame.animationSpeedCheckbox = checkbox; 


 -- X offset editbox.
 local editbox = MSBTControls.CreateEditbox(frame);
 objLocale = MSBTLocale.EDITBOXES["xOffset"]; 
 editbox:Configure(135, objLocale.label, objLocale.tooltip);
 editbox:SetPoint("TOPLEFT", frame.animationSpeedSlider, "BOTTOMLEFT", 0, -10);
 editbox:SetTextChangedHandler(
  function (this)
   local newOffset = tonumber(this:GetText());
   if (newOffset) then
    frame.previewSettings[frame.currentScrollArea].offsetX = newOffset;
    RepositionScrollAreaMoverFrame(frame.currentScrollArea);
   end
  end
 );
 frame.xOffsetEditbox = editbox;

 -- Y offset editbox.
 editbox = MSBTControls.CreateEditbox(frame);
 objLocale = MSBTLocale.EDITBOXES["yOffset"]; 
 editbox:Configure(135, objLocale.label, objLocale.tooltip);
 editbox:SetPoint("LEFT", frame.xOffsetEditbox, "RIGHT", 15, 0);
 editbox:SetTextChangedHandler(
  function (this)
   local newOffset = tonumber(this:GetText());
   if (newOffset) then
    frame.previewSettings[frame.currentScrollArea].offsetY = newOffset;
    RepositionScrollAreaMoverFrame(frame.currentScrollArea);
   end
  end
 );
 frame.yOffsetEditbox = editbox;

 
 -- Bottom horizontal bar.
 texture = frame:CreateTexture(nil, "ARTWORK");
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft");
 texture:SetHeight(4);
 texture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 80);
 texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 80);
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125);


 -- Preview button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["scrollAreasPreview"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 50);
 button:SetClickHandler(
  function (this)
   SaveScrollAreaSettings(frame.previewSettings);
   local name;
   for saKey in pairs(frame.previewSettings) do
    name = MSBTAnimations.scrollAreas[saKey].name;
    MikSBT.DisplayMessage(name, saKey, nil, 255, 0, 0);
    MikSBT.DisplayMessage(name, saKey, nil, 255, 255, 255);
    MikSBT.DisplayMessage(name, saKey, true, 0, 0, 255);
   end
  end
 );
 
 -- Save button.
 local button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericSave"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20);
 button:SetClickHandler(
  function (this)
   SaveScrollAreaSettings(frame.previewSettings);
   frame:Hide();
  end
 );

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20);
 button:SetClickHandler(
  function (this)
   SaveScrollAreaSettings(frame.originalSettings);
   frame:Hide();
  end
 );
 
 -- Track internal values.
 frame.moverFrames = {};
 frame.originalSettings = {};
 frame.previewSettings = {};
 
 -- Give the frame a global name.
 _G["MSBTScrollAreasConfigFrame"] = frame;
 return frame;
end


-- ****************************************************************************
-- Shows the popup scroll area config screen.
-- ****************************************************************************
local function ShowScrollAreaConfig()
 -- Create the frame if it hasn't already been.
 if (not popupFrames.scrollAreaConfigFrame) then popupFrames.scrollAreaConfigFrame = CreateScrollAreaConfig(); end
 
 local frame = popupFrames.scrollAreaConfigFrame;

 -- Backup the original settings for previewing and cancelling.
 CopyTempScrollAreaSettings(frame.originalSettings);
 CopyTempScrollAreaSettings(frame.previewSettings);
 
 -- Populate the scroll areas and setup the mover frames. 
 frame.scrollAreaDropdown:Clear();
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  frame.scrollAreaDropdown:AddItem(saSettings.name, saKey);
  
  -- Create and reposition the scroll area mover frames.
  CreateScrollAreaMoverFrame(saKey);
  RepositionScrollAreaMoverFrame(saKey);
 end
 frame.scrollAreaDropdown:Sort();
 frame.currentScrollArea = "Incoming";
 frame.scrollAreaDropdown:SetSelectedID(frame.currentScrollArea);
 ChangeConfigScrollArea(frame.currentScrollArea);
 
 frame:Show();
end


-------------------------------------------------------------------------------
-- Scroll area selection frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup scroll area selection frame.
-- ****************************************************************************
local function CreateScrollAreaSelection()
 local frame = CreatePopup();
 frame:SetWidth(350);
 frame:SetHeight(150);
 
 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOP", frame, "TOP", 0, -20);
 frame.titleFontString = fontString;

 
 -- Scroll area dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["outputScrollArea"];
 dropdown:Configure(150, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -45);
 frame.scrollAreaDropdown = dropdown;
 
 
 -- Okay button.
 local button = MSBTControls.CreateOptionButton(frame);
 local objLocale = MSBTLocale.BUTTONS["inputOkay"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20);
 button:SetClickHandler(
  function (this)
   if (frame.saveHandler) then frame.saveHandler(frame.scrollAreaDropdown:GetSelectedID(), frame.saveArg1); end
   frame:Hide();   
  end
 );
 frame.okayButton = button;

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["inputCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );
 
 return frame;
end


-- ****************************************************************************
-- Shows the popup scroll area selection frame using the passed config.
-- ****************************************************************************
local function ShowScrollAreaSelection(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.scrollAreaSelectionFrame) then popupFrames.scrollAreaSelectionFrame = CreateScrollAreaSelection(); end
 
 -- Set parent.
 local frame = popupFrames.scrollAreaSelectionFrame;
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.titleFontString:SetText(configTable.title);
 
 -- Scroll areas. 
 frame.scrollAreaDropdown:Clear();
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  frame.scrollAreaDropdown:AddItem(saSettings.name, saKey);
 end
 frame.scrollAreaDropdown:Sort();
 frame.scrollAreaDropdown:SetSelectedID("Incoming");


 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Event frame functions.
-------------------------------------------------------------------------------


-- ****************************************************************************
-- Populates the available sounds for the event along with the passed custom
-- sound file.
-- ****************************************************************************
local function PopulateEventSounds(selectedSound)
 local controls = popupFrames.eventFrame.controls;
 
 local isCustomSound = selectedSound and true;
 controls.soundDropdown:Clear();
 for soundName in pairs(MSBTAnimations.sounds) do
  if (soundName ~= NONE) then controls.soundDropdown:AddItem(MSBTLocale.SOUNDS[soundName] or soundName, soundName); end
  if (soundName == selectedSound) then isCustomSound = nil; end
 end
 controls.soundDropdown:AddItem(NONE, "");
 controls.soundDropdown:Sort();
 if (isCustomSound) then controls.soundDropdown:AddItem(selectedSound, selectedSound); end
 controls.soundDropdown:SetSelectedID(selectedSound or "");
end


-- ****************************************************************************
-- Enables the controls on the event popup.
-- ****************************************************************************
local function EnableEventControls()
 for name, frame in pairs(popupFrames.eventFrame.controls) do
  if (frame.Enable) then frame:Enable(); end
 end
end


-- ****************************************************************************
-- Validates if the passed skill name does not already exist and is valid.
-- ****************************************************************************
local function ValidateSoundFileName(fileName)
 if (not string.find(fileName, ".mp3") and not string.find(fileName, ".wav")) then
  return MSBTLocale.MSG_INVALID_SOUND_FILE;
 end
end


-- ****************************************************************************
-- Adds a custom sound file to for the event.
-- ****************************************************************************
local function AddCustomSoundFile(settings)
 PopulateEventSounds(settings.inputText);
end


-- ****************************************************************************
-- Creates the popup event settings frame.
-- ****************************************************************************
local function CreateEvent()
 local frame = CreatePopup();
 frame:SetWidth(320);
 frame:SetHeight(370);
 frame.controls = {};
 local controls = frame.controls;

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOP", frame, "TOP", 0, -20);
 frame.titleFontString = fontString;

 -- Scroll area dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["outputScrollArea"];
 dropdown:Configure(150, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60);
 controls.scrollAreaDropdown = dropdown;

 -- Output message editbox.
 local editbox = MSBTControls.CreateEditbox(frame);
 local objLocale = MSBTLocale.EDITBOXES["eventMessage"];
 editbox:Configure(250, objLocale.label, nil);
 editbox:SetPoint("TOPLEFT", controls.scrollAreaDropdown, "BOTTOMLEFT", 0, -20);
 controls.messageEditbox = editbox;

 -- Sound dropdown. 
 local dropdown =  MSBTControls.CreateDropdown(frame);
 objLocale = MSBTLocale.DROPDOWNS["sound"];
 dropdown:Configure(150, objLocale.label, objLocale.tooltip);
 dropdown:SetPoint("TOPLEFT", controls.messageEditbox, "BOTTOMLEFT", 0, -20);
 controls.soundDropdown = dropdown;

 -- Edit trigger classes button.
 local button = MSBTControls.CreateIconButton(frame, "Configure");
 local objLocale = MSBTLocale.BUTTONS["customSound"];
 button:SetTooltip(objLocale.tooltip);
 button:SetPoint("LEFT", controls.soundDropdown, "RIGHT", 10, -5);
 button:SetClickHandler(
  function (this)
   local objLocale = MSBTLocale.EDITBOXES["soundFile"];
   EraseTable(tempConfig);
   tempConfig.editboxLabel = objLocale.label;
   tempConfig.editboxTooltip = objLocale.tooltip;
   tempConfig.parentFrame = frame;
   tempConfig.anchorFrame = this;
   tempConfig.anchorPoint = "BOTTOMRIGHT";
   tempConfig.relativePoint = "TOPRIGHT";
   tempConfig.validateHandler = ValidateSoundFileName;
   tempConfig.saveHandler = AddCustomSoundFile;
   tempConfig.hideHandler = EnableEventControls;
   DisableControls(controls);
   ShowInput(tempConfig);
  end
 );
 controls[#controls+1] = button;

 -- Always sticky checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame);
 objLocale = MSBTLocale.CHECKBOXES["stickyEvent"]; 
 checkbox:Configure(28, objLocale.label, objLocale.tooltip);
 checkbox:SetPoint("TOPLEFT", controls.soundDropdown, "BOTTOMLEFT", 0, -20);
 controls.stickyCheckbox = checkbox; 

 
 -- Icon skill editbox.
 editbox = MSBTControls.CreateEditbox(frame);
 local objLocale = MSBTLocale.EDITBOXES["iconSkill"];
 editbox:Configure(250, objLocale.label, objLocale.tooltip);
 editbox:SetPoint("TOPLEFT", controls.stickyCheckbox, "BOTTOMLEFT", 0, -20);
 controls.iconSkillEditbox = editbox;



 -- Save button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericSave"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20);
 button:SetClickHandler(
  function (this)
   EraseTable(returnSettings);
   returnSettings.scrollArea = controls.scrollAreaDropdown:GetSelectedID();
   returnSettings.message = controls.messageEditbox:GetText();
   returnSettings.soundFile = controls.soundDropdown:GetSelectedID();
   returnSettings.alwaysSticky = controls.stickyCheckbox:GetChecked();
   returnSettings.iconSkill = controls.iconSkillEditbox:GetText();
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1); end
   frame:Hide();
  end
 );
 controls[#controls+1] = button;

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );
 controls[#controls+1] = button;

 return frame;
end


-- ****************************************************************************
-- Shows the popup event settings frame using the passed config.
-- ****************************************************************************
local function ShowEvent(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.eventFrame) then popupFrames.eventFrame = CreateEvent(); end
 
 -- Set parent.
 local frame = popupFrames.eventFrame;
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.titleFontString:SetText(configTable.title);

 local controls = frame.controls;
 controls.scrollAreaDropdown:Clear();
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  controls.scrollAreaDropdown:AddItem(saSettings.name, saKey);
 end
 controls.scrollAreaDropdown:Sort();
 controls.scrollAreaDropdown:SetSelectedID(configTable.scrollArea);

 local objLocale = MSBTLocale.EDITBOXES["eventMessage"];
 controls.messageEditbox:SetText(configTable.message);
 controls.messageEditbox:SetTooltip(objLocale.tooltip .. "\n\n" .. (configTable.codes or ""));
 PopulateEventSounds(configTable.soundFile);
 controls.stickyCheckbox:SetChecked(configTable.alwaysSticky);
 controls.iconSkillEditbox:SetText(configTable.iconSkill);


 -- Show / hide always sticky checkbox depending on if the event is a crit or not.
 if (configTable.isCrit) then controls.stickyCheckbox:Hide(); else controls.stickyCheckbox:Show(); end

 -- Show / hide icon skill editbox.
 if (configTable.showIconSkillEditbox) then
  frame:SetHeight(370);
  controls.iconSkillEditbox:Show();
 else
  controls.iconSkillEditbox:Hide();
  frame:SetHeight(310);
 end
 
 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Trigger classes frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup classes frame.
-- ****************************************************************************
local function CreateClasses()
 local frame = CreatePopup();
 frame:SetWidth(270);
 frame:SetHeight(320);
 frame.classCheckboxes = {};
 local classCheckboxes = frame.classCheckboxes;

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2);
 
 -- All classes checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame);
 objLocale = MSBTLocale.CHECKBOXES["allClasses"]; 
 checkbox:Configure(24, objLocale.label, objLocale.tooltip);
 checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40);
 checkbox:SetClickHandler(
  function (this, isChecked)
   frame.classes["ALL"] = isChecked and true or nil;
   if (isChecked) then
    for name, checkFrame in pairs(frame.classCheckboxes) do
     checkFrame:SetChecked(true);
     checkFrame:Disable();
    end
   else
    for name, checkFrame in pairs(classCheckboxes) do
     checkFrame:Enable();
     checkFrame:SetChecked(frame.classes[checkFrame.associatedClass]);
    end
   end
   if (frame.updateHandler) then frame.updateHandler(); end
  end
 );
 frame.allClassesCheckbox = checkbox; 

 local anchor = checkbox;
 for class in string.gmatch("DRUID HUNTER MAGE PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR", "[^ ]+") do
  checkbox = MSBTControls.CreateCheckbox(frame);
  checkbox:Configure(24, MSBTLocale.CLASS_NAMES[class], nil);
  checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == frame.allClassesCheckbox and 20 or 0, anchor == frame.allClassesCheckbox and -10 or 0);
  checkbox:SetClickHandler(
   function (this, isChecked)
    frame.classes[this.associatedClass] = isChecked and true or nil;
    if (frame.updateHandler) then frame.updateHandler(); end
   end
  );
  checkbox.associatedClass = class;
  anchor = checkbox;
  classCheckboxes[class .. "Checkbox"] = checkbox;
 end 

 return frame;
end


-- ****************************************************************************
-- Shows the popup classes frame.
-- ****************************************************************************
local function ShowClasses(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame or not configTable.classes) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.classesFrame) then popupFrames.classesFrame = CreateClasses(); end
 
 -- Set parent.
 local frame = popupFrames.classesFrame;
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 if (configTable.classes["ALL"]) then
  frame.allClassesCheckbox:SetChecked(true);
  for name, checkFrame in pairs(frame.classCheckboxes) do
   checkFrame:SetChecked(true);
   checkFrame:Disable();
  end  
 else
  frame.allClassesCheckbox:SetChecked(false);
  for name, checkFrame in pairs(frame.classCheckboxes) do
   checkFrame:Enable();
   checkFrame:SetChecked(configTable.classes[checkFrame.associatedClass]);
  end
 end
 

 -- Configure the frame.
 frame.classes = configTable.classes;
 frame.updateHandler = configTable.updateHandler;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Trigger conditions frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Toggles the parameter controls to match the selected condition type.
-- ****************************************************************************
local function ToggleParameterControl(value)
 local frame = popupFrames.conditionFrame;
 frame.parameterEditbox:Hide();
 frame.parameterSlider:Hide();

 local controlData = frame.conditionControlMap[frame.conditionDropdown:GetSelectedID()];
 local controlType = controlData and controlData.control;
 if (controlType == "Editbox") then
  frame.parameterEditbox:Show();
  frame.parameterEditbox:SetText(value);
 elseif (controlType == "Slider") then
  frame.parameterSlider:SetMinMaxValues(controlData.minValue, controlData.maxValue)
  frame.parameterSlider:SetValueStep(controlData.step);
  frame.parameterSlider:SetValue(value or controlData.default);
  frame.parameterSlider:Show();
 end
 
end


-- ****************************************************************************
-- Creates the popup condition frame.
-- ****************************************************************************
local function CreateCondition()
 local frame = CreatePopup();
 frame:SetWidth(350);
 frame:SetHeight(175);

 -- Condition type dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame);
 local objLocale = MSBTLocale.DROPDOWNS["conditionType"];
 dropdown:Configure(200, objLocale.label, nil);
 dropdown:SetListboxHeight(160);
 dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40);
 dropdown:SetChangeHandler(
  function (this, id)
    ToggleParameterControl(nil);
  end
 );
 frame.conditionDropdown = dropdown;

 -- Parameter editbox.
 local editbox = MSBTControls.CreateEditbox(frame);
 objLocale = MSBTLocale.EDITBOXES["conditionParam"];
 editbox:Configure(0, objLocale.label, objLocale.tooltip);
 editbox:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -10);
 editbox:SetPoint("RIGHT", frame, "RIGHT", -20, 0);
 frame.parameterEditbox = editbox;
 
 -- Parameter slider.
 local slider = MSBTControls.CreateSlider(frame);
 objLocale = MSBTLocale.SLIDERS["conditionParam"]; 
 slider:Configure(180, objLocale.label, objLocale.tooltip);
 slider:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -10);
 frame.parameterSlider = slider;

 -- Save button.
 local button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericSave"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20);
 button:SetClickHandler(
  function (this)
   EraseTable(returnSettings);
   returnSettings.conditionType = frame.conditionDropdown:GetSelectedID();
   if (frame.parameterEditbox:IsShown()) then
    returnSettings.conditionParam = frame.parameterEditbox:GetText();
   elseif (frame.parameterSlider:IsShown()) then
    returnSettings.conditionParam = frame.parameterSlider:GetValue();
   else
    returnSettings.conditionParam = "true";
   end
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1); end
   frame:Hide();
  end
 );

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );

 -- What controls to show for each condition type.
 frame.conditionControlMap = {
  -- Main conditions.
  SelfHealth				= {control="Slider", minValue=1, maxValue=100, step=1, default=40},
  SelfMana					= {control="Slider", minValue=1, maxValue=100, step=1, default=35},
  PetHealth					= {control="Slider", minValue=1, maxValue=100, step=1, default=40},
  EnemyHealth				= {control="Slider", minValue=1, maxValue=100, step=1, default=40},
  FriendlyHealth			= {control="Slider", minValue=1, maxValue=100, step=1, default=40},
  SelfBuff					= {control="Editbox"},
  SelfDebuff				= {control="Editbox"},
  TargetBuff				= {control="Editbox"},
  TargetDebuff				= {control="Editbox"},
  TargetDebuffApplication	= {control="Editbox"},
  SearchPattern				= {control="Editbox"},

  -- Secondary conditions.
  SpellReady			= {control="Editbox"},
  SpellUsable			= {control="Editbox"},
  BuffInactive			= {control="Editbox"},
  MinPower				= {control="Slider", minValue=1, maxValue=100, step=1, default=20},
  WarriorStance			= {control="Slider", minValue=1, maxValue=3, step=1, default=1},
  TriggerCooldown		= {control="Slider", minValue=1, maxValue=30, step=1, default=5},
  DebuffApplicationNum	= {control="Slider", minValue=1, maxValue=10, step=1, default=5},
 };

 return frame;
end


-- ****************************************************************************
-- Shows the popup conditions frame.
-- ****************************************************************************
local function ShowCondition(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.conditionFrame) then popupFrames.conditionFrame = CreateCondition(); end
 
 -- Set parent.
 local frame = popupFrames.conditionFrame;
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.conditionDropdown:HideSelections();
 frame.conditionDropdown:Clear();
 for conditionType, conditionName in pairs(availableConditions) do
  frame.conditionDropdown:AddItem(conditionName, conditionType);
 end
 frame.conditionDropdown:Sort();
 frame.conditionDropdown:SetSelectedID(configTable.conditionType);
 
 ToggleParameterControl(configTable.conditionParam);

 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Trigger events frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when one of the trigger event checkboxes is clicked.
-- ****************************************************************************
local function TriggerEventsCheckboxOnClick(this, isChecked)
 local line = this:GetParent();
 local triggerEvents = line:GetParent():GetParent().triggerEvents;
 triggerEvents[line.triggerEvent] = isChecked and true or nil;
end


-- ****************************************************************************
-- Called by listbox to create a line for trigger events.
-- ****************************************************************************
local function CreateTriggerEventsLine(this)
 local frame = CreateFrame("Button", nil, this);
 frame:EnableMouse(false);
 
 -- Trigger event checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame);
 checkbox:Configure(24, nil, nil);
 checkbox:SetPoint("LEFT");
 checkbox:SetClickHandler(TriggerEventsCheckboxOnClick);
 frame.triggerEventCheckbox = checkbox;

 return frame;
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function DisplayTriggerEventsLine(this, line, key, isSelected)
 line.triggerEvent = key;
 line.triggerEventCheckbox:SetLabel(key);
 line.triggerEventCheckbox:SetChecked(this.triggerEvents and this.triggerEvents[key]);
end


-- ****************************************************************************
-- Creates the popup trigger events frame.
-- ****************************************************************************
local function CreateTriggerEvents()
 local frame = CreatePopup();
 frame:SetWidth(410);
 frame:SetHeight(280);

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2);

 -- Trigger events listbox.
 local listbox = MSBTControls.CreateListbox(frame);
 listbox:Configure(375, 225, 25);
 listbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40);
 listbox:SetCreateLineHandler(CreateTriggerEventsLine);
 listbox:SetDisplayHandler(DisplayTriggerEventsLine);
 frame.triggerEventsListbox = listbox;
 for _, event in pairs(MSBTTriggers.GetSupportedSearchPatternEvents()) do
  listbox:AddItem(event);
 end

 return frame;
end


-- ****************************************************************************
-- Shows the popup trigger events frame.
-- ****************************************************************************
local function ShowTriggerEvents(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame or not configTable.triggerEvents) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.triggerEventsFrame) then popupFrames.triggerEventsFrame = CreateTriggerEvents(); end

 -- Set parent.
 local frame = popupFrames.triggerEventsFrame;
 ChangePopupParent(frame, configTable.parentFrame);
 
 -- Populate the data.
 frame.triggerEventsListbox.triggerEvents = configTable.triggerEvents;

 -- Configure the frame.
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Trigger frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Updates the available conditions based on which conditions are selected.
-- ****************************************************************************
local function UpdateAvailableConditions(conditionTypes, usedConditions, curConditionType)
 local frame = popupFrames.triggerFrame;
 
 -- Only make available the conditions that either aren't already used
 -- or can have multiple entries.
 EraseTable(availableConditions);
 local addCondition;
 for conditionType, conditionName in pairs(conditionTypes) do
  addCondition = true;
  if (curConditionType and curConditionType ~= conditionType) then
   for _, usedConditionType in ipairs(usedConditions) do
    if (usedConditionType == conditionType) then addCondition = false; end
   end
  end
  if (addCondition or frame.nonExclusiveTypes[conditionType]) then availableConditions[conditionType] = conditionName; end
 end
end


-- ****************************************************************************
-- Updates the classes font string based on what classes are selected.
-- ****************************************************************************
local function UpdateClassesText()
 local frame = popupFrames.triggerFrame;
 
 -- Get localized list of seleced classes.
 local selectedClasses = "";
 if (frame.classes["ALL"]) then
  selectedClasses = MSBTLocale.CHECKBOXES["allClasses"].label;
 else
  for className in pairs(frame.classes) do
   selectedClasses = selectedClasses .. MSBTLocale.CLASS_NAMES[className] .. ", ";
  end

  -- Strip off the extra comma and space.
  selectedClasses = string.sub(selectedClasses, 1, -3);
 end

 frame.classesFontString:SetText(selectedClasses);
end


-- ****************************************************************************
-- Updates the main conditions listbox.
-- ****************************************************************************
local function UpdateMainConditions()
 local frame = popupFrames.triggerFrame;
 local hasSearchPattern = false;
 frame.mainConditionsListbox:Clear();
 for index, conditionType in pairs(frame.mainConditions) do
  frame.mainConditionsListbox:AddItem(index)
  if (conditionType == "SearchPattern") then hasSearchPattern = true; end
 end
 
 if (hasSearchPattern) then
  frame.eventTypesButton:Enable();
 else
  frame.eventTypesButton:Disable();
 end
end


-- ****************************************************************************
-- Updates the secondary conditions listbox.
-- ****************************************************************************
local function UpdateSecondaryConditions()
 local frame = popupFrames.triggerFrame;
 frame.secondaryConditionsListbox:Clear();
 for index in pairs(frame.secondaryConditions) do
  frame.secondaryConditionsListbox:AddItem(index)
 end
end


-- ****************************************************************************
-- Enables the controls on the trigger popup.
-- ****************************************************************************
local function EnableTriggerControls()
 for name, frame in pairs(popupFrames.triggerFrame.controls) do
  if (frame.Enable) then frame:Enable(); end
 end
 
 -- Ensure the trigger event types button is enabled or disabled properly.
 UpdateMainConditions();
end


-- ****************************************************************************
-- Saves the main condition the user entered to the trigger frame.
-- ****************************************************************************
local function SaveMainCondition(settings, conditionNum)
 local frame = popupFrames.triggerFrame;
 frame.mainConditions[conditionNum] = settings.conditionType;
 frame.mainConditionParams[conditionNum] = settings.conditionParam;
 UpdateMainConditions();
end


-- ****************************************************************************
-- Saves the secondary condition the user entered to the trigger frame.
-- ****************************************************************************
local function SaveSecondaryCondition(settings, conditionNum)
 local frame = popupFrames.triggerFrame;
 frame.secondaryConditions[conditionNum] = settings.conditionType;
 frame.secondaryConditionParams[conditionNum] = settings.conditionParam;
 UpdateSecondaryConditions();
end


-- ****************************************************************************
-- Called when one of the main condition edit buttons is clicked.
-- ****************************************************************************
local function EditConditionButtonOnClick(this)
 local frame = popupFrames.triggerFrame;
 local line = this:GetParent();
 
 local conditionTypes, conditions, conditionParams;
 if (line.isMainCondition) then
  conditionTypes = MSBTLocale.TRIGGER_MAIN_CONDITIONS;
  conditions = frame.mainConditions;
  conditionParams = frame.mainConditionParams;
 else
  conditionTypes = MSBTLocale.TRIGGER_SECONDARY_CONDITIONS;
  conditions = frame.secondaryConditions;
  conditionParams = frame.secondaryConditionParams; 
 end
 
 UpdateAvailableConditions(conditionTypes, conditions, conditions[line.conditionNum]);

 EraseTable(tempConfig);
 tempConfig.conditionType = conditions[line.conditionNum];
 tempConfig.conditionParam = conditionParams[line.conditionNum];
 tempConfig.saveHandler = line.isMainCondition and SaveMainCondition or SaveSecondaryCondition;
 tempConfig.saveArg1 = line.conditionNum;
 tempConfig.parentFrame = frame;
 tempConfig.anchorFrame = this;
 tempConfig.anchorPoint = line.isMainCondition and "TOPLEFT" or "BOTTOMLEFT";
 tempConfig.relativePoint = line.isMainCondition and "BOTTOMLEFT" or "TOPLEFT";
 tempConfig.hideHandler = EnableTriggerControls;
 DisableControls(frame.controls);
 ShowCondition(tempConfig);
end


-- ****************************************************************************
-- Called when one of the main condition delete buttons is clicked.
-- ****************************************************************************
local function DeleteConditionButtonOnClick(this)
 local frame = popupFrames.triggerFrame;
 local line = this:GetParent();
 if (line.isMainCondition) then
  table.remove(frame.mainConditions, line.conditionNum);
  table.remove(frame.mainConditionParams, line.conditionNum);
  UpdateMainConditions();
 else
  table.remove(frame.secondaryConditions, line.conditionNum);
  table.remove(frame.secondaryConditionParams, line.conditionNum);
  UpdateSecondaryConditions();
 end
end


-- ****************************************************************************
-- Called by listbox to create a line for conditions.
-- ****************************************************************************
local function CreateConditionsLine(this)
 local controls = popupFrames.triggerFrame.controls;
 local frame = CreateFrame("Button", nil, this);
 frame:EnableMouse(false);

 -- Edit condition button.
 local button = MSBTControls.CreateIconButton(frame, "Configure");
 local objLocale = MSBTLocale.BUTTONS["editCondition"];
 button:SetTooltip(objLocale.tooltip);
 button:SetPoint("LEFT", frame, "LEFT", 0, 0);
 button:SetClickHandler(EditConditionButtonOnClick);
 frame.editConditionButton = button;
 controls[#controls+1] = button;
 
 
 -- Delete condition button.
 button = MSBTControls.CreateIconButton(frame, "Delete");
 objLocale = MSBTLocale.BUTTONS["deleteCondition"];
 button:SetTooltip(objLocale.tooltip);
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0);
 button:SetClickHandler(DeleteConditionButtonOnClick);
 controls[#controls+1] = button;
 
 -- Condition text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("LEFT", frame.editConditionButton, "RIGHT", 5, 0);
 fontString:SetPoint("RIGHT", controls[#controls], "LEFT", -10, 0);
 fontString:SetJustifyH("LEFT");
 fontString:SetTextColor(1, 1, 1);
 frame.conditionFontString = fontString;

 return frame;
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function DisplayMainConditionsLine(this, line, key, isSelected)
 line.isMainCondition = true;
 line.conditionNum = key;
 local frame = popupFrames.triggerFrame;
 local objLocale = MSBTLocale.TRIGGER_MAIN_CONDITIONS;
 local conditionName = objLocale[frame.mainConditions[key]];
 local conditionParam = frame.mainConditionParams[key];
 local conditionText = conditionName;
 if (conditionParam and conditionParam ~= "true") then
  conditionText = conditionText .. " - " .. conditionParam;
 end
 line.conditionFontString:SetText(conditionText);
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function DisplaySecondaryConditionsLine(this, line, key, isSelected)
 line.conditionNum = key;
 local frame = popupFrames.triggerFrame;
 local objLocale = MSBTLocale.TRIGGER_SECONDARY_CONDITIONS;
 local conditionName = objLocale[frame.secondaryConditions[key]];
 local conditionParam = frame.secondaryConditionParams[key];
 local conditionText = conditionName;
 if (conditionParam and conditionParam ~= "true") then
  conditionText = conditionText .. " - " .. conditionParam;
 end
 line.conditionFontString:SetText(conditionText);
end


-- ****************************************************************************
-- Creates the popup trigger settings frame.
-- ****************************************************************************
local function CreateTriggerPopup()
 local frame = CreatePopup();
 frame:SetWidth(400);
 frame:SetHeight(460);
 frame.controls = {};
 local controls = frame.controls;

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOP", frame, "TOP", 0, -20);
 frame.titleFontString = fontString;

 -- Trigger classes label.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50);
 fontString:SetText(MSBTLocale.MSG_TRIGGER_CLASSES .. ":");
 frame.classesLabel = fontString;

 -- Edit trigger classes button.
 local button = MSBTControls.CreateIconButton(frame, "Configure");
 local objLocale = MSBTLocale.BUTTONS["editTriggerClasses"];
 button:SetTooltip(objLocale.tooltip);
 button:SetPoint("TOPLEFT", frame.classesLabel, "BOTTOMLEFT", 10, -5);
 button:SetClickHandler(
  function (this)
   EraseTable(tempConfig);
   tempConfig.parentFrame = frame;
   tempConfig.anchorFrame = this;
   tempConfig.classes = frame.classes;
   tempConfig.updateHandler = UpdateClassesText;
   tempConfig.hideHandler = EnableTriggerControls;
   DisableControls(controls);
   ShowClasses(tempConfig);
  end
 );
 controls[#controls+1] = button;

 -- Classes text.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("LEFT", controls[#controls], "RIGHT", 10, -5);
 fontString:SetPoint("RIGHT", frame, "RIGHT", -20, 0);
 fontString:SetHeight(30);
 fontString:SetJustifyH("LEFT");
 fontString:SetJustifyV("TOP");
 fontString:SetTextColor(1, 1, 1);
 frame.classesFontString = fontString;

 -- Main conditions label.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOPLEFT", controls[#controls], "BOTTOMLEFT", -10, -15);
 fontString:SetText(MSBTLocale.MSG_MAIN_CONDITIONS .. ":");
 frame.mainConditionsLabel = fontString;
 
 -- Add main condition button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["addMainCondition"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("LEFT", frame.mainConditionsLabel, "RIGHT", 10, 0);
 button:SetClickHandler(
  function (this)
   UpdateAvailableConditions(MSBTLocale.TRIGGER_MAIN_CONDITIONS, frame.mainConditions, nil);
   EraseTable(tempConfig);
   tempConfig.conditionType = "SelfBuff";
   tempConfig.conditionParam = nil;
   tempConfig.saveHandler = SaveMainCondition;
   tempConfig.saveArg1 = #frame.mainConditions + 1;
   tempConfig.parentFrame = frame;
   tempConfig.anchorFrame = this;
   tempConfig.hideHandler = EnableTriggerControls;
   DisableControls(frame.controls);
   ShowCondition(tempConfig);
  end
 );
 controls[#controls+1] = button;

 -- Main conditions listbox.
 local listbox = MSBTControls.CreateListbox(frame);
 listbox:Configure(350, 100, 25);
 listbox:SetPoint("TOPLEFT", frame.mainConditionsLabel, "BOTTOMLEFT", 10, -10);
 listbox:SetCreateLineHandler(CreateConditionsLine);
 listbox:SetDisplayHandler(DisplayMainConditionsLine);
 frame.mainConditionsListbox = listbox;
 controls[#controls+1] = listbox;


 -- Secondary conditions label.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOPLEFT", frame.mainConditionsListbox, "BOTTOMLEFT", -10, -15);
 fontString:SetText(MSBTLocale.MSG_SECONDARY_CONDITIONS .. ":");
 frame.secondaryConditionsLabel = fontString;
 
 -- Add secondary condition button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["addSecondaryCondition"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("LEFT", frame.secondaryConditionsLabel, "RIGHT", 10, 0);
 button:SetClickHandler(
  function (this)
   UpdateAvailableConditions(MSBTLocale.TRIGGER_SECONDARY_CONDITIONS, frame.secondaryConditions, nil);
   EraseTable(tempConfig);
   tempConfig.conditionType = "TriggerCooldown";
   tempConfig.conditionParam = nil;
   tempConfig.saveHandler = SaveSecondaryCondition;
   tempConfig.saveArg1 = #frame.secondaryConditions + 1;
   tempConfig.parentFrame = frame;
   tempConfig.anchorFrame = this;
   tempConfig.anchorPoint = "BOTTOMLEFT";
   tempConfig.relativePoint = "TOPLEFT";
   tempConfig.hideHandler = EnableTriggerControls;
   DisableControls(frame.controls);
   ShowCondition(tempConfig);
  end
 );
 controls[#controls+1] = button;

 -- Secondary conditions listbox.
 listbox = MSBTControls.CreateListbox(frame);
 listbox:Configure(350, 100, 25);
 listbox:SetPoint("TOPLEFT", frame.secondaryConditionsLabel, "BOTTOMLEFT", 10, -10);
 listbox:SetCreateLineHandler(CreateConditionsLine);
 listbox:SetDisplayHandler(DisplaySecondaryConditionsLine);
 frame.secondaryConditionsListbox = listbox;
 controls[#controls+1] = listbox;

 -- Trigger event types button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["triggerEventTypes"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("TOPLEFT", frame.secondaryConditionsListbox, "BOTTOMLEFT", -10, -10);
 button:SetClickHandler(
  function (this)
   EraseTable(tempConfig);
   tempConfig.triggerEvents = frame.triggerEvents;
   tempConfig.parentFrame = frame;
   tempConfig.anchorFrame = this;
   tempConfig.anchorPoint = "BOTTOMLEFT";
   tempConfig.relativePoint = "TOPLEFT";
   tempConfig.hideHandler = EnableTriggerControls;
   DisableControls(controls);
   ShowTriggerEvents(tempConfig);
  end
 );
 frame.eventTypesButton = button;
 controls[#controls+1] = button;

 
 -- Save button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericSave"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20);
 button:SetClickHandler(
  function (this)
   EraseTable(returnSettings);
   -- Make the classes string.
   if (not frame.classes["ALL"]) then
    local sortedClasses = frame.sortedClasses;
    EraseTable(sortedClasses);
    for class in pairs(frame.classes) do
     sortedClasses[#sortedClasses+1] = class;
    end
    table.sort(sortedClasses);
    returnSettings.classes = table.concat(sortedClasses, ",");
   end

   -- Make the main conditions string.
   if (next(frame.mainConditions)) then
    local conditions = "";
    for conditionNum, conditionParam in ipairs(frame.mainConditions) do
     conditions = conditions .. conditionParam .. "=" .. frame.mainConditionParams[conditionNum] .. "&&";
    end
    returnSettings.mainConditions = conditions;
   end

   -- Make the secondary conditions string.
   if (next(frame.secondaryConditions)) then
    local conditions = "";
    for conditionNum, conditionParam in ipairs(frame.secondaryConditions) do
     conditions = conditions .. conditionParam .. "=" .. frame.secondaryConditionParams[conditionNum] .. "&&";
    end
    returnSettings.secondaryConditions = conditions;
   end

   -- Make the trigger events string.
   if (next(frame.triggerEvents) and frame.eventTypesButton:IsEnabled() ~= 0) then
    local events = "";
    for event in pairs(frame.triggerEvents) do
     events = events .. event .. ",";
    end
    returnSettings.triggerEvents = string.sub(events, 1, -2);
   end

   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1); end
   frame:Hide();
  end
 );
 controls[#controls+1] = button;

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );
 controls[#controls+1] = button;


 frame.classes = {};
 frame.sortedClasses = {};
 frame.mainConditions = {};
 frame.mainConditionParams = {};
 frame.secondaryConditions = {};
 frame.secondaryConditionParams = {};
 frame.triggerEvents = {};

 -- The condition types that can have multiple parameters.
 frame.nonExclusiveTypes = {
  SelfBuff		= true,
  SelfDebuff	= true,
  TargetBuff	= true,
  TargetDebuff	= true,
  SearchPattern	= true,
  SpellReady	= true,
  SpellUsable	= true,
  BuffInactive	= true,
 };
 
 return frame;
end


-- ****************************************************************************
-- Shows the popup trigger settings frame using the passed config.
-- ****************************************************************************
local function ShowTrigger(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.triggerFrame) then popupFrames.triggerFrame = CreateTriggerPopup(); end
 
 -- Set parent.
 local frame = popupFrames.triggerFrame;
 ChangePopupParent(frame, configTable.parentFrame)

 
 -- Populate data.
 local triggerKey = configTable.triggerKey;
 local settings = MSBTProfiles.currentProfile.triggers[triggerKey];
 frame.titleFontString:SetText(configTable.title); 

 -- Classes.
 EraseTable(frame.classes);
 if (settings.classes) then
  for className in string.gmatch(settings.classes, "[^,]+") do
   frame.classes[className] = true;
  end
 else
  frame.classes["ALL"] = true;
 end
 UpdateClassesText();
 
 -- Main conditions.
 EraseTable(frame.mainConditions);
 EraseTable(frame.mainConditionParams);
 if (settings.mainConditions) then
  for conditionType, conditionParam in string.gmatch(settings.mainConditions, "(.-)=(.-)&&") do
   frame.mainConditions[#frame.mainConditions+1] = conditionType;
   frame.mainConditionParams[#frame.mainConditionParams+1] = conditionParam;
  end
 end
 UpdateMainConditions();
 
 -- Secondary conditions.
 EraseTable(frame.secondaryConditions);
 EraseTable(frame.secondaryConditionParams);
 if (settings.secondaryConditions) then
  for conditionType, conditionParam in string.gmatch(settings.secondaryConditions, "(.-)=(.-)&&") do
   frame.secondaryConditions[#frame.secondaryConditions+1] = conditionType;
   frame.secondaryConditionParams[#frame.secondaryConditionParams+1] = conditionParam;
  end
 end
 UpdateSecondaryConditions();
 
 -- Trigger events.
 EraseTable(frame.triggerEvents);
 if (settings.triggerEvents) then
  for triggerEvent in string.gmatch(settings.triggerEvents, "[^,]+") do
   frame.triggerEvents[triggerEvent] = true;
  end
 end
 

 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end


-------------------------------------------------------------------------------
-- Skill list frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the skill list popup.
-- ****************************************************************************
local function EnableSkillListControls()
 for name, frame in pairs(popupFrames.skillListFrame.controls) do
  if (frame.Enable) then frame:Enable(); end
 end
end


-- ****************************************************************************
-- Validates if the passed skill name does not already exist and is valid.
-- ****************************************************************************
local function ValidateSkillListName(skillName)
 if (not skillName or skillName == "") then
  return MSBTLocale.MSG_INVALID_SKILL_NAME;
 end

 if (popupFrames.skillListFrame.skills[skillName]) then
  return MSBTLocale.MSG_SKILL_ALREADY_EXISTS;
 end
end


-- ****************************************************************************
-- Adds the passed skill name to the list of skills.
-- ****************************************************************************
local function SaveSkillListName(settings)
 local skillName = settings.inputText;
 local frame = popupFrames.skillListFrame;
 if (frame.listType == "throttle") then
  frame.skills[skillName] = 3;
 elseif (frame.listType == "substitution") then
  frame.skills[skillName] = settings.secondInputText;
 else
  frame.skills[skillName] = true;
 end

 frame.skillsListbox:AddItem(skillName, true);
end


-- ****************************************************************************
-- Called when one of the delete skill buttons is pressed.
-- ****************************************************************************
local function DeleteSkillButtonOnClick(this)
 local line = this:GetParent();
 popupFrames.skillListFrame.skills[line.skillName] = false;
 popupFrames.skillListFrame.skillsListbox:RemoveItem(line.itemNumber);
end


-- ****************************************************************************
-- Called when one of the time slider changes.
-- ****************************************************************************
local function TimeSliderOnValueChanged(this, value)
 local line = this:GetParent();
 popupFrames.skillListFrame.skills[line.skillName] = value;
end


-- ****************************************************************************
-- Called by listbox to create a line for skill list popup.
-- ****************************************************************************
local function CreateSkillListLine(this)
 local controls = popupFrames.skillListFrame.controls;
 local frame = CreateFrame("Button", nil, this);
 frame:EnableMouse(false);

 -- Delete skill button.
 local button = MSBTControls.CreateIconButton(frame, "Delete");
 objLocale = MSBTLocale.BUTTONS["deleteSkill"];
 button:SetTooltip(objLocale.tooltip);
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0);
 button:SetClickHandler(DeleteSkillButtonOnClick);
 frame.deleteButton = button;
 controls[#controls+1] = button;

 -- Time slider.
 local slider = MSBTControls.CreateSlider(frame);
 objLocale = MSBTLocale.SLIDERS["skillThrottleTime"]; 
 slider:Configure(120, objLocale.label, objLocale.tooltip);
 slider:SetPoint("RIGHT", frame.deleteButton, "LEFT", -10, -5);
 slider:SetMinMaxValues(1, 5);
 slider:SetValueStep(1);
 slider:SetValueChangedHandler(TimeSliderOnValueChanged);
 frame.timeSlider = slider;
 controls[#controls+1] = slider;

 -- Skill name text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("LEFT", frame, "LEFT", 5, 0);
 fontString:SetPoint("RIGHT", frame.timeSlider, "LEFT", -10, 0);
 fontString:SetJustifyH("LEFT");
 fontString:SetTextColor(1, 1, 1);
 frame.skillFontString = fontString;

 return frame;
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function DisplaySkillListLine(this, line, key, isSelected)
 local frame = popupFrames.skillListFrame;
 line.skillName = key;
 if (frame.listType == "throttle") then
  line.skillFontString:SetText(key);
  line.skillFontString:SetPoint("RIGHT", line.timeSlider, "LEFT", -10, 0);
  line.timeSlider:Show();
  line.timeSlider:SetValue(frame.skills[key] or 3);
 elseif (frame.listType == "substitution") then
  line.skillFontString:SetText(key .. " - " .. tostring(frame.skills[key]));
  line.skillFontString:SetPoint("RIGHT", line.deleteButton, "LEFT", -10, 0);
  line.timeSlider:Hide();
 else
  line.skillFontString:SetText(key);
  line.skillFontString:SetPoint("RIGHT", line.deleteButton, "LEFT", -10, 0);
  line.timeSlider:Hide();
 end
end


-- ****************************************************************************
-- Creates the popup skill list frame.
-- ****************************************************************************
local function CreateSkillList()
 local frame = CreatePopup();
 frame:SetWidth(400);
 frame:SetHeight(300);
 frame.controls = {};
 local controls = frame.controls;

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOP", frame, "TOP", 0, -20);
 frame.titleFontString = fontString;
 
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50);
 fontString:SetText(MSBTLocale.MSG_SKILLS .. ":");
 frame.skillsFontString = fontString;
 
 -- Add skill button.
 local button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["addSkill"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("LEFT", frame.skillsFontString, "RIGHT", 10, 0);
 button:SetClickHandler(
  function (this)
   local objLocale = MSBTLocale.EDITBOXES["skillName"];
   EraseTable(tempConfig);
   tempConfig.editboxLabel = objLocale.label;
   tempConfig.editboxTooltip = objLocale.tooltip;
   tempConfig.parentFrame = frame;
   tempConfig.anchorFrame = this;
   tempConfig.validateHandler = ValidateSkillListName;
   tempConfig.saveHandler = SaveSkillListName;
   tempConfig.hideHandler = EnableSkillListControls;
   if (frame.listType == "substitution") then
    objLocale = MSBTLocale.EDITBOXES["substitutionText"];
    tempConfig.showSecondEditbox = true;
    tempConfig.secondEditboxLabel = objLocale.label;
    tempConfig.secondEditboxTooltip = objLocale.tooltip;
   end
   DisableControls(controls);
   ShowInput(tempConfig);
  end
 );
 frame.addSkillButton = button;
 controls[#controls+1] = button;
 
 -- Skills listbox.
 local listbox = MSBTControls.CreateListbox(frame);
 listbox:Configure(355, 180, 30);
 listbox:SetPoint("TOPLEFT", frame.skillsFontString, "BOTTOMLEFT", 10, -10);
 listbox:SetCreateLineHandler(CreateSkillListLine);
 listbox:SetDisplayHandler(DisplaySkillListLine);
 frame.skillsListbox = listbox;
 controls[#controls+1] = listbox;
 
 -- Save button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericSave"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20);
 button:SetClickHandler(
  function (this)
   if (frame.saveHandler) then frame.saveHandler(frame.saveArg1); end
   frame:Hide();
  end
 );
 controls[#controls+1] = button;

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame);
 objLocale = MSBTLocale.BUTTONS["genericCancel"];
 button:Configure(20, objLocale.label, objLocale.tooltip);
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20);
 button:SetClickHandler(
  function (this)
   frame:Hide();
  end
 );
 controls[#controls+1] = button;
 
 return frame; 
end


-- ****************************************************************************
-- Shows the popup skill list frame using the passed config.
-- ****************************************************************************
local function ShowSkillList(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame or not configTable.skills) then return; end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.skillListFrame) then popupFrames.skillListFrame = CreateSkillList(); end
 
 -- Set parent.
 local frame = popupFrames.skillListFrame;
 ChangePopupParent(frame, configTable.parentFrame)

 
 -- Populate data.
 frame.titleFontString:SetText(configTable.title); 
 
 -- Skills.
 frame.listType = configTable.listType;
 frame.skills = configTable.skills;
 frame.skillsListbox:Clear();
 for skillName, value in pairs(configTable.skills) do
  if (value) then frame.skillsListbox:AddItem(skillName); end
 end

 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler;
 frame.saveArg1 = configTable.saveArg1;
 frame.hideHandler = configTable.hideHandler;
 frame:ClearAllPoints();
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT");
 frame:Show();
 frame:Raise();
end




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Functions.
module.DisableControls				= DisableControls;
module.ShowInput					= ShowInput;
module.ShowAcknowledge				= ShowAcknowledge;
module.ShowFont						= ShowFont;
module.ShowPartialEffects			= ShowPartialEffects;
module.ShowDamageColors				= ShowDamageColors;
module.ShowScrollAreaConfig			= ShowScrollAreaConfig;
module.ShowScrollAreaSelection		= ShowScrollAreaSelection;
module.ShowEvent					= ShowEvent;
module.ShowTrigger					= ShowTrigger;
module.ShowSkillList				= ShowSkillList;
module.ShowSubstitutionList			= ShowSubstitutionList;