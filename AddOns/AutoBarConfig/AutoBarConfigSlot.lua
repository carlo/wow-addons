--
-- AutoBarConfigSlot
--
-- Slot Config functions
--
-- Maintained by Azethoth / Toadkiller of Proudmoore.
-- http://code.google.com/p/autobar/
--

--
-- Config Checkbox Handling
--

AutoBarConfigSlot = {};

local _G = getfenv(0);
local L = AceLibrary("AceLocale-2.2"):new("AutoBar");


function AutoBarConfigSlot:View(slotsIndex, playerInfo)
	AutoBarConfigSlotFrameTitleText:SetText(L["VIEWSLOT"]);
	AutoBarConfigSlotFrameViewText:Show();
	AutoBarConfigSlot.editable = false;
	AutoBarConfigSlot:Initialize(slotsIndex, playerInfo);
	AutoBarConfigSlotFrameClearSlotButton:Hide();
	AutoBarConfigSlotFrameEmptySlotButton:Hide();
	AutoBarConfigSlotFrameNoPopup:Disable();
	AutoBarConfigSlotFrameArrangeOnUse:Disable();
	AutoBarConfigSlotFrameRightClickTargetsPet:Disable();
	AutoBarConfigSlotFrameNoPopupText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	AutoBarConfigSlotFrameArrangeOnUseText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	AutoBarConfigSlotFrameRightClickTargetsPetText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	AutoBarConfigSlotFrame:SetBackdropColor(0.30,0.15,0.15);
end


function AutoBarConfigSlot:Edit(slotsIndex, playerInfo)
	AutoBarConfigSlotFrameTitleText:SetText(L["EDITSLOT"].." #" .. slotsIndex);
	AutoBarConfigSlotFrameViewText:Hide();
	AutoBarConfigSlot.editable = true;
	AutoBarConfigSlot:Initialize(slotsIndex, playerInfo);
	AutoBarConfigSlotFrameClearSlotButton:Show();
	AutoBarConfigSlotFrameEmptySlotButton:Show();
	AutoBarConfigSlotFrameNoPopup:Enable();
	AutoBarConfigSlotFrameArrangeOnUse:Enable();
	AutoBarConfigSlotFrameRightClickTargetsPet:Enable();
	AutoBarConfigSlotFrameNoPopupText:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	AutoBarConfigSlotFrameArrangeOnUseText:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	AutoBarConfigSlotFrameRightClickTargetsPetText:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	AutoBarConfigSlotFrame:SetBackdropColor(0.15,0.20,0.15);
end


function AutoBarConfigSlot:Initialize(slotsIndex, playerInfo)
	AutoBarConfigSlot.slots = playerInfo.buttons;
	AutoBarConfigSlot.slotsIndex = slotsIndex;
	_G["AutoBarConfigSlotFrameNoPopupText"]:SetText(L["AUTOBAR_CONFIG_NOPOPUP"]);
	_G["AutoBarConfigSlotFrameArrangeOnUseText"]:SetText(L["AUTOBAR_CONFIG_ARRANGEONUSE"]);
	_G["AutoBarConfigSlotFrameRightClickTargetsPetText"]:SetText(L["AUTOBAR_CONFIG_RIGHTCLICKTARGETSPET"]);
	AutoBarConfigSlot:Update();
	AutoBarConfigSlotFrame:Show();
end


function AutoBarConfigSlot:Update()
	if (not AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex]) then
		AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex] = {};
	end

	local buttonInfo = AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex];
	local noPopupCheckbox = _G["AutoBarConfigSlotFrameNoPopup"];
	local arrangeOnUseCheckbox = _G["AutoBarConfigSlotFrameArrangeOnUse"];
	local rightClickTargetsPetCheckbox = _G["AutoBarConfigSlotFrameRightClickTargetsPet"];
	local index,tmp,i;

	noPopupCheckbox:SetChecked(buttonInfo.noPopup);
	arrangeOnUseCheckbox:SetChecked(buttonInfo.arrangeOnUse);
	rightClickTargetsPetCheckbox:SetChecked(buttonInfo.rightClickTargetsPet);

	tmp = 0;
	for index = 1, AUTOBAR_MAXSLOTCATEGORIES, 1 do
		if (buttonInfo[index]) then
			tmp = index;
		end
	end
	index = 1;
	while (index < tmp) do
		if (buttonInfo[index]) then
			index = index + 1;
		else
			buttonInfo[index] =
			buttonInfo[index+1];
			buttonInfo[index+1] = nil;
			tmp = 0;
			for i = 1, AUTOBAR_MAXSLOTCATEGORIES, 1 do
				if (buttonInfo[i]) then
					tmp = i;
				end
			end
		end
	end

	for index = 1, AUTOBAR_MAXSLOTCATEGORIES, 1 do
		local button = _G["AutoBarConfigSlotFrame_Button"..index];
		local hotkey = _G["AutoBarConfigSlotFrame_Button"..index.."HotKey"];
		local count = _G["AutoBarConfigSlotFrame_Button"..index.."Count"];
		local icon = _G["AutoBarConfigSlotFrame_Button"..index.."Icon"];

		hotkey:Hide();
		if (buttonInfo[index]) then
			count:SetText("");
		else
			count:SetText(L["Empty"]);
		end
		icon:SetTexture(AutoBar:GetTexture(buttonInfo[index]));
		button:Show();
	end
end


function AutoBarConfigSlot:OnCheck()
	local buttonInfo = AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex];
	local buttonName = this:GetName();

	if (type(buttonInfo) == "table") then
		if (buttonName == "AutoBarConfigSlotFrameNoPopup") then
			buttonInfo.noPopup = this:GetChecked();
		elseif (buttonName == "AutoBarConfigSlotFrameArrangeOnUse") then
			buttonInfo.arrangeOnUse = this:GetChecked();
		elseif (buttonName == "AutoBarConfigSlotFrameRightClickTargetsPet") then
			buttonInfo.rightClickTargetsPet = this:GetChecked();
		end
	end
	AutoBarConfigSlot:Update();
	AutoBarProfile:ButtonsChanged();
end


function AutoBarConfigSlot:ButtonOnClick(mousebutton)
	ResetCursor();
	AutoBar.dragging = nil;

	if (not AutoBarConfigSlot.editable) then
		return;
	end

	if (CursorHasItem() and AutoBarConfigSlot.editable) then
		local cursorType = GetCursorInfo();
		if (cursorType == "item") then
			AutoBarConfigSlot.ButtonOnReceiveDrag();
			return;
		end
	end

	local slotInfo = AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex];
	local category = nil;
	AutoBarChooseCategoryFrame.editting = this:GetID();
	if (AutoBarChooseCategoryFrame.editting > # slotInfo + 1) then
		AutoBarChooseCategoryFrame.editting = # slotInfo + 1
	end
	category = slotInfo[AutoBarChooseCategoryFrame.editting];

	if (not AutoBarConfigSlot.editable) then
		AutoBarChooseCategoryFrame.editting = nil;
		if (AutoBarCategoryList[category]) then
			AutoBarChooseCategoryFrame.categoryexplore = category;
		else
			return;
		end
	end

	AutoBarChooseCategoryFrame:Show();
end


function AutoBarConfigSlot.ButtonOnDragStart()
	local fromIndex = this:GetID();
	AutoBar.SetDraggingIndex("AutoBarConfigSlotFrame", fromIndex);
	SetCursor("BUY_CURSOR");
end


function AutoBarConfigSlot.ButtonOnReceiveDrag()
	local toIndex = this:GetID();
	local fromIndex = AutoBar.GetDraggingIndex("AutoBarConfigSlotFrame");

--	DEFAULT_CHAT_FRAME:AddMessage("AutoBarConfig.ButtonOnReceiveDrag " .. tostring(fromIndex) .. " -> " .. toIndex, 1, 0.5, 0);

	if (fromIndex and fromIndex ~= toIndex) then
		AutoBarConfigSlot:MoveButtonItems(AutoBarConfigSlot.slotsIndex, fromIndex, toIndex);
	elseif (CursorHasItem()) then
		local cursorType, dragId = GetCursorInfo();
		if (cursorType == "item" and dragId) then
			local slotInfo = AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex];
			if (# slotInfo < toIndex) then
				toIndex = # slotInfo + 1
			end
			if (toIndex > AUTOBAR_MAXSLOTCATEGORIES) then
				toIndex = AUTOBAR_MAXSLOTCATEGORIES
			end
			AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex][toIndex] = dragId;
			ClearCursor();
		end
	end
	AutoBarConfigSlot:Update();
	AutoBarProfile:ButtonsChanged();
	AutoBar.dragging = nil;
	ResetCursor();
end


function AutoBarConfigSlot:MoveButtonItems(button, fromIndex, toIndex)
	if (type(AutoBarConfigSlot.slots[button]) == "table") then
		if (not AutoBarConfigSlot.slots[button][fromIndex] or fromIndex == toIndex) then
			-- Move to self so do nothing
			return;
		end
		if (not AutoBarConfigSlot.slots[button][fromIndex]) then
			-- Dont allow swapping empties into the list
			return;
		end
		local temp = AutoBarConfigSlot.slots[button][fromIndex];
		if (not AutoBarConfigSlot.slots[button][toIndex]) then
			-- Move to the end
			table.remove(AutoBarConfigSlot.slots[button], fromIndex);
			table.insert(AutoBarConfigSlot.slots[button], temp);
		else
			-- Swap the two
			AutoBarConfigSlot.slots[button][fromIndex] = AutoBarConfigSlot.slots[button][toIndex];
			AutoBarConfigSlot.slots[button][toIndex] = temp;
		end
	end
end


-- Delete all items in a slot.
function AutoBarConfigSlot:EmptySlotButtonOnClick()
	AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex] = {};
	AutoBarConfigSlot:Update();
	AutoBarProfile:ButtonsChanged();
end


-- Delete all items in a slot.
function AutoBarConfigSlot:ClearSlotButtonOnClick()
	AutoBarConfigSlot.slots[AutoBarConfigSlot.slotsIndex] = {"AAACLEAR"};
	AutoBarConfigSlot:Update();
	AutoBarProfile:ButtonsChanged();
end


