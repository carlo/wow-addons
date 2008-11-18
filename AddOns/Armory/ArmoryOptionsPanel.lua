--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryOptionsPanel.lua,v 1.10, 2008-11-11 10:16:30Z, Maxim Baars$
    URL: http://www.wow-neighbours.com

    License:
        This program is free software; you can redistribute it and/or
        modify it under the terms of the GNU General Public License
        as published by the Free Software Foundation; either version 2
        of the License, or (at your option) any later version.

        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program(see GPL.txt); if not, write to the Free Software
        Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

    Note:
        This AddOn's source code is specifically designed to work with
        World of Warcraft's interpreted AddOn system.
        You have an implicit licence to use this AddOn with these facilities
        since that is it's designated purpose as per:
        http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]] 

function ArmoryOptionsPanel_OnLoad(self)
    self.okay = ArmoryOptionsPanel_Okay;
    self.cancel = ArmoryOptionsPanel_Cancel;
    self.default = ArmoryOptionsPanel_Default;
    self.refresh = ArmoryOptionsPanel_Refresh;

    InterfaceOptions_AddCategory(self);

    for i, control in next, self.controls do
        if ( control.text ) then
            getglobal(control:GetName() .. "Text"):SetText(Armory:Proper(control.text));
        end
    end
end

function ArmoryOptionsPanel_Okay(self)
    for _, control in next, self.controls do
        control.init = nil;
    end
end

function ArmoryOptionsPanel_Cancel(self)
    for _, control in next, self.controls do
        if ( control.value ~= control.currValue ) then
            control:SetValue(control.currValue);
        end
        if ( control.currColor and control.colorSet ) then
            control.colorSet(GetTableColor(control.currColor));
        end
        control.init = nil;
    end
end

function ArmoryOptionsPanel_Default(self)
    for _, control in next, self.controls do
        if ( control:GetValue() ~= control.defaultValue ) then
            control:SetValue(control.defaultValue);
        end
        if ( control.colorGet and control.colorSet ) then
            control.colorSet(control.colorGet(true));
        end
    end
end

function ArmoryOptionsPanel_Refresh(self)
    for _, control in next, self.controls do
        if ( control.GetValue ) then
            if ( control.type == CONTROLTYPE_SLIDER ) then
                control.value = control.getFunc();
                control:SetValue(control.value);
            else
                control.value = control:GetValue();
            end

            if ( not control.init ) then
                control.currValue = control.value;
            end
            control.disabled = control.disabledFunc();

            if ( control.type == CONTROLTYPE_CHECKBOX ) then

                if ( not control.invert ) then
                    control:SetChecked(control.value);
                else
                    control:SetChecked(not control.value);
                end
    
                ArmoryOptionsPanel_RefreshDependentControls(control);

                if ( control.disabled ) then
                    BlizzardOptionsPanel_CheckButton_Disable(control);
                else
                    BlizzardOptionsPanel_CheckButton_Enable(control, 1);
                end

            elseif ( control.type == CONTROLTYPE_SLIDER ) then

                if ( control.disabled ) then
                    BlizzardOptionsPanel_Slider_Disable(control);
                else
                    BlizzardOptionsPanel_Slider_Enable(control);
                end

            end
            
            if ( control.colorGet ) then
                local frame = control:GetParent();
                local swatch = getglobal(frame:GetName().."ColorSwatch");
                
                frame.r, frame.g, frame.b = control.colorGet();
                swatch:GetNormalTexture():SetVertexColor(control.colorGet());

                if ( not control.init ) then
                    control.currColor = {};
                    SetTableColor(control.currColor, control.colorGet());
                end

                if ( control.disabled ) then
                    swatch:Disable();
                    getglobal(frame:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
                else
                    swatch:Enable();
                    getglobal(frame:GetName().."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                end
            end

            control.init = true;
        end
    end
end

function ArmoryOptionsPanel_CheckButton_OnClick(checkButton)
    local setting = false;
    if ( checkButton:GetChecked() ) then
        if ( not checkButton.invert ) then
            setting = true;
        end
    elseif ( checkButton.invert ) then
        setting = true;
    end 

    checkButton:SetValue(setting);

    ArmoryOptionsPanel_RefreshDependentControls(checkButton);
end

function ArmoryOptionsPanel_RegisterControl(control, parentFrame)
    local entry;

    if ( control.label ) then
        entry = Armory.options[control.label];

        if ( control.type == CONTROLTYPE_CHECKBOX ) then    

            control.text = getglobal(control.label.."_TEXT");
            control.tooltipText = getglobal(control.label.."_TOOLTIP");
            control.setFunc = entry.set;
            control.GetValue = entry.get;
            control.SetValue = function(self, value) self.value = value; if ( self.setFunc ) then self.setFunc(self.value) end end;

        elseif ( control.type == CONTROLTYPE_SLIDER ) then

            control.text = getglobal(control.label.."_TEXT");
            control.tooltipText = getglobal(control.label.."_TOOLTIP");
            control.setFunc = entry.set;
            control.getFunc = entry.get;
            control.minValue = entry.minValue;
            control.maxValue = entry.maxValue;
            control:SetMinMaxValues(entry.minValue, entry.maxValue);
            control:SetValueStep(entry.valueStep);
            control.SetDisplayValue = control.SetValue;
            control.SetValue = function(self, value) self:SetDisplayValue(value); self.value = value; self.setFunc(value); end;

        end

        control.defaultValue = control.defaultValue or entry.default;
        control.disabledFunc = entry.disabled or function() end;
    else
        control.disabledFunc = function() end;
    end
    
    local frame = control:GetParent();
    local swatch = getglobal(frame:GetName().."ColorSwatch");
    if ( swatch ) then
        swatch.control = control;
    end

    parentFrame.controls = parentFrame.controls or {};
    table.insert(parentFrame.controls, control);    
end

function ArmoryOptionsPanel_SetupDependentControl(dependency, control, invert)
    if ( not dependency ) then
       return;
    end

    control = control or this;
    control.dependentInvert = invert;

    dependency.dependentControls = dependency.dependentControls or {};
    table.insert(dependency.dependentControls, control);

    if ( control.type ~= CONTROLTYPE_DROPDOWN ) then

        if ( control.type == CONTROLTYPE_SLIDER ) then
            control.oldDisable = BlizzardOptionsPanel_Slider_Disable;
            control.oldEnable = BlizzardOptionsPanel_Slider_Enable;
        else
            control.oldDisable = control.Disable;
            control.oldEnable = control.Enable;
        end

        control.Disable = function (self) self:oldDisable(self) getglobal(self:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
        control.Enable = function (self) self:oldEnable(self) getglobal(self:GetName().."Text"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end;
    else
        control.Disable = function (self) ArmoryDropDownMenu_DisableDropDown(self) end;
        control.Enable = function (self) ArmoryDropDownMenu_EnableDropDown(self) end;
    end
end

function ArmoryOptionsPanel_RefreshDependentControls(checkButton)
    if ( checkButton.dependentControls ) then
        if ( checkButton:GetChecked() ) then
            for _, control in next, checkButton.dependentControls do
                if ( control.dependentInvert ) then
                    control:Disable();
                else
                    control:Enable();
                end
            end
        else
            for _, control in next, checkButton.dependentControls do
                if ( control.dependentInvert ) then
                    control:Enable();
                else
                    control:Disable();
                end
            end
        end
    end
end

function ArmoryOptionsPanel_OpenColorPicker(self)
    ArmoryOptionsPanel.colorPicker = self;
    ArmoryOptionsPanel.colorGet = self.control.colorGet;
    ArmoryOptionsPanel.colorSet = self.control.colorSet;

    local frame = self:GetParent();
    local info = UIDropDownMenu_CreateInfo();

    info.r, info.g, info.b = self.control.colorGet();
    info.swatchFunc = function() 
            ArmoryOptionsPanel.colorSet(ColorPickerFrame:GetColorRGB());
            ArmoryOptionsPanel.colorPicker:GetNormalTexture():SetVertexColor(ColorPickerFrame:GetColorRGB());
        end;
    info.cancelFunc = function()
            ArmoryOptionsPanel.colorSet(ColorPicker_GetPreviousValues());
            ArmoryOptionsPanel.colorPicker:GetNormalTexture():SetVertexColor(ColorPicker_GetPreviousValues());
        end;

    OpenColorPicker(info);
end
