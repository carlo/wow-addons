--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryItemFilter.lua,v 1.4, 2008-10-21 11:58:15Z, Maxim Baars$
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

function ArmoryItemFilter_Create()
    if ( not Armory.itemFilter ) then
        Armory.itemFilter = {
            enabled = false,
            quality = {},
            classes = {},
            options = {},
            dropdowns = {},
        };
        
        ArmoryItemFilter_InitGeneral();
        ArmoryItemFilter_InitQuality();
        ArmoryItemFilter_InitClasses();
    end
end

function ArmoryItemFilter_Load(self)
    Armory.itemFilter.quality = Armory:ItemFilterSetting("Quality");
    Armory.itemFilter.classes = Armory:ItemFilterSetting("Classes");
    ArmoryItemFilter_Select();
end

function ArmoryItemFilter_InitGeneral()
    table.insert(Armory.itemFilter.options, 
        { text = ARMORY_FILTER_ENABLE, 
          func = ArmoryItemFilter_Enable,
        }
    );
    table.insert(Armory.itemFilter.options, 
        { text = ARMORY_FILTER_ALL, 
          func = ArmoryItemFilter_Select,
          type = "all", 
        }
    );
    table.insert(Armory.itemFilter.options, 
        { text = ARMORY_FILTER_CLEAR, 
          func = ArmoryItemFilter_Select,
          type = "clear"
        }
    );
    table.insert(Armory.itemFilter.options, 
        { text = CLOSE, 
          func = function() ArmoryHideDropDownMenu(1); end,
        }
    );
    table.insert(Armory.itemFilter.options, { text = "", header = true })
end

function ArmoryItemFilter_InitQuality()
    table.insert(Armory.itemFilter.options, { text = QUALITY, header = true });
    
    for i = 0, #ITEM_QUALITY_COLORS - 2  do
        table.insert(Armory.itemFilter.options, 
            { text = getglobal("ITEM_QUALITY"..i.."_DESC"),
              type = "quality",
              func = ArmoryItemFilter_Set,
              value = tostring(i),
              color = ITEM_QUALITY_COLORS[i].hex,
            }
        );
    end
end

function ArmoryItemFilter_InitClasses()
    table.insert(Armory.itemFilter.options, { text = TYPE, header = true });
    
    for i, itemClass in ipairs({ GetAuctionItemClasses() }) do
        table.insert(Armory.itemFilter.options, 
            { text = itemClass,
              type = "classes",
              func = ArmoryItemFilter_Set,
              value = itemClass,
            }
        );
    end
end

function ArmoryItemFilter_SelectDropDown(dropdown, onUpdate)
    Armory.itemFilter.dropdowns[dropdown] = onUpdate or function() end;
    Armory.itemFilter.dropdown = dropdown;
end

function ArmoryItemFilter_Update()
    for _, onUpdate in pairs(Armory.itemFilter.dropdowns) do
        onUpdate(true);
    end
end

function ArmoryItemFilter_Enable(self, arg1, arg2, checked)
    if ( checked ) then
        Armory.itemFilter.options[arg2].text = ARMORY_FILTER_DISABLE;
    else
        Armory.itemFilter.options[arg2].text = ARMORY_FILTER_ENABLE;
    end
    Armory.itemFilter.options[arg2].checked = checked;
    Armory.itemFilter.enabled = checked;

    ArmoryItemFilterDropDown_SetText();
    ArmoryItemFilterDropDown_Refresh();
    ArmoryItemFilter_Update();
end

function ArmoryItemFilter_Select(self, arg1)
    for i = 1, #Armory.itemFilter.options do
        local option = Armory.itemFilter.options[i];
        if ( option.type == "quality" or option.type == "classes" ) then
            if ( arg1 ) then
                Armory.itemFilter[option.type][option.value] = (arg1 ~= "clear");
            end
            option.checked = Armory.itemFilter[option.type][option.value];
        end
    end
    
    ArmoryItemFilterDropDown_Refresh();
    
    if ( arg1 ) then
        ArmoryItemFilter_Update();
    end
end

function ArmoryItemFilter_Set(self, arg1, arg2, checked)
    Armory.itemFilter.options[arg2].checked = checked;
    Armory.itemFilter[arg1][self.value] = checked;
    ArmoryItemFilter_Update();
end

function ArmoryItemFilter(link)
    if ( ArmoryItemFilter_IsEnabled() ) then
        local _, _, itemRarity, _, _, itemType = GetItemInfo(link);
        if ( ArmoryItemFilter_HasFilter("quality") and not Armory.itemFilter.quality[tostring(itemRarity)] ) then
            return false;
        elseif ( ArmoryItemFilter_HasFilter("classes") and not Armory.itemFilter.classes[itemType] ) then
            return false;
        end
    end

    return true;
end

function ArmoryItemFilter_IsEnabled()
    return (Armory.itemFilter and Armory.itemFilter.enabled);
end

function ArmoryItemFilter_HasFilter(type)
    for _, value in pairs(Armory.itemFilter[type]) do
        if ( value ) then
            return true;
        end
    end
end

function ArmoryItemFilter_InitializeDropDown(dropdown)
    ArmoryItemFilter_Create();
    ArmoryItemFilter_SelectDropDown(dropdown);
    
    ArmoryDropDownMenu_Initialize(dropdown, ArmoryItemFilterDropDown_Initialize, "MENU");
    ArmoryDropDownMenu_JustifyText(dropdown, "LEFT");
    ArmoryItemFilterDropDown_SetText();
    
    local filterText = getglobal(dropdown:GetName().."Button");
    filterText:SetScript("OnEnter", ArmoryItemFilterDropDown_OnEnter);
    filterText:SetScript("OnLeave", ArmoryItemFilterDropDown_OnLeave);
end

function ArmoryItemFilterDropDown_Initialize()
    -- Setup buttons
    for i = 1, #Armory.itemFilter.options do
        local info = ArmoryDropDownMenu_CreateInfo();
        local option = Armory.itemFilter.options[i];
        info.text = option.text;
        info.colorCode = option.color; 
        info.isTitle = option.header;
        info.notClickable = info.isTitle;
        info.notCheckable = not (option.type == "quality" or option.type == "classes");
        info.func = option.func;
        info.value = option.value;
        info.checked = option.checked;
        info.keepShownOnClick = 1;
        info.arg1 = option.type;
        info.arg2 = i;
        
        ArmoryDropDownMenu_AddButton(info);
    end
end

function ArmoryItemFilterDropDown_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(ARMORY_FILTER_TOOLTIP, nil, nil, nil, nil, 1);
end

function ArmoryItemFilterDropDown_OnLeave(self)
    GameTooltip:Hide();
end

function ArmoryItemFilterDropDown_SetText()
    for dropdown in pairs(Armory.itemFilter.dropdowns) do
        if ( Armory.itemFilter.enabled ) then
            ArmoryDropDownMenu_SetText(dropdown, format(ARMORY_FILTER_LABEL, ARMORY_CMD_SET_ON));
        else
            ArmoryDropDownMenu_SetText(dropdown, format(ARMORY_FILTER_LABEL, ARMORY_CMD_SET_OFF));
        end
    end
end

function ArmoryItemFilterDropDown_Refresh()
    if ( Armory.itemFilter.dropdown and Armory.itemFilter.dropdown:IsShown() ) then
        ArmoryHideDropDownMenu(1);
        if ( ARMORY_DROPDOWNMENU_OPEN_MENU == Armory.itemFilter.dropdown:GetName() ) then
            ArmoryToggleDropDownMenu(1, nil, Armory.itemFilter.dropdown);
        end
    end
end

