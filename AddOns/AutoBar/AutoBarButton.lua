--
-- AutoBarButton
-- Copyright 2007+ Toadkiller of Proudmoore.
--
-- Buttons for AutoBar
-- http://code.google.com/p/autobar/
--

AutoBarButton = {};
AutoBarButton.dirtyButton = {}
AutoBarButton.dirtyPopupCount = {}
AutoBarButton.dirtyPopupCooldown = {}

--local L = AceLibrary("AceLocale-2.2"):new("AutoBar");
local BS = AceLibrary:GetInstance("Babble-Spell-2.2");
local _G = getfenv(0);


function AutoBarButton:GetHotKeyDisplayText(keyText)
	if (keyText) then
		local displayText = string.gsub(keyText, "-CTRL", "C");
		displayText = string.gsub(displayText, "CTRL", "C");
		displayText = string.gsub(displayText, "-ALT", "A");
		displayText = string.gsub(displayText, "-SHIFT", "S");
		displayText = string.gsub(displayText, "-NUMPAD", "N");
		displayText = string.gsub(displayText, "-BUTTON", "B");
		displayText = string.gsub(displayText, "ALT", "A");
		displayText = string.gsub(displayText, "SHIFT", "S");
		displayText = string.gsub(displayText, "NUMPAD", "N");
		displayText = string.gsub(displayText, "BUTTON", "B");
		displayText = string.gsub(displayText, "MULTIPLY", "*");
		displayText = string.gsub(displayText, "DECIMAL", ".");
		displayText = string.gsub(displayText, "DIVIDE", "/");
		displayText = string.gsub(displayText, "MINUS", "-");
		displayText = string.gsub(displayText, "PLUS", "-");
		return displayText;
	else
		return "";
	end
end


local SPELL_FEED_PET = BS["Feed Pet"];
-- Set the state attributes of the button
function AutoBarButton:SetAttributes(button, baseName, bag, slot, spell, count, itemId, category, itemName, action, macroText)
	local enabled = true;

	-- Handle targeted items
	local castSpell;
	local buttonsIndex = button:GetAttribute("buttonsIndex");
	local buttonInfo = AutoBar.buttons[buttonsIndex];
	button:SetAttribute("target-slot1", nil);
	button:SetAttribute("target-slot2", nil);
	button:SetAttribute("target-bag", nil);
	button:SetAttribute("target-slot", nil);
	button:SetAttribute("*unit2", nil);
	button:SetAttribute("*type1", nil);
	button:SetAttribute("*type2", nil);
	button:SetAttribute("*item1", nil);
	button:SetAttribute("*item2", nil);
	button:SetAttribute("*spell1", nil);
	button:SetAttribute("*spell2", nil);
	button:SetAttribute("*bag1", nil);
	button:SetAttribute("*slot1", nil);
	button:SetAttribute("*bag2", nil);
	button:SetAttribute("*slot2", nil);

	if (AutoBarCategoryList[category]) then
		local targeted = AutoBarCategoryList[category].targetted;
		if (targeted == "CHEST") then
			button:SetAttribute("target-slot1", 5);
			button:SetAttribute("target-slot2", 5);
		elseif (targeted == "SHIELD") then
			button:SetAttribute("target-slot1", 17);
			button:SetAttribute("target-slot2", 17);
		elseif (targeted == "WEAPON") then
			button:SetAttribute("target-slot1", 16);
			button:SetAttribute("target-slot2", 17);
		elseif (AutoBar.CLASS == "HUNTER" and targeted == "PET") then
			-- Right Click targets pet
			if (category and strfind(category, "FOOD")) then
				button:SetAttribute("*type2", "spell");
				button:SetAttribute("*spell2", SPELL_FEED_PET);
				button:SetAttribute("target-bag", bag);
				button:SetAttribute("target-slot", slot);
			else
				button:SetAttribute("*unit2", "pet");
			end
		elseif (targeted) then
			-- Support selfcast-RightMouse
			if (AutoBar.display.disableRightClickSelfCast) then
				button:SetAttribute("*unit2", nil);
			else
				button:SetAttribute("*unit2", "player");
			end
		end

		-- Disable battleground only items outside BG
		if (AutoBarCategoryList[category].battleground and not AutoBar.inBG) then
			enabled = false;
		end

		castSpell = AutoBarCategoryList[category].castSpell;
	end

	if (enabled) then
		if (buttonInfo) then
			-- Handle right click pet targeting for a slot
			if (buttonInfo.rightClickTargetsPet) then
				if (category and strfind(category, "FOOD")) then
					button:SetAttribute("*type2", "spell");
					button:SetAttribute("spell2", SPELL_FEED_PET);
					button:SetAttribute("target-bag", bag);
					button:SetAttribute("target-slot", slot);
				else
					button:SetAttribute("*unit2", "pet");
				end
			end

			if (not castSpell) then
				castSpell = buttonInfo.castSpell;
			end
		end

		button:SetAttribute("*spell1", nil);
		if (castSpell) then
			button:SetAttribute("*type2", "spell");
			button:SetAttribute("*spell2", castSpell);
		else
			button:SetAttribute("*spell2", nil);
		end

		local type2 = button:GetAttribute("*type2")
		button:SetScript("OnAttributeChanged", nil);
		if (not bag and slot) then
			button:SetAttribute("*type1", "item");
			button:SetAttribute("*bag1", nil);
			button:SetAttribute("*slot1", slot);
			button:SetAttribute("*type2", "item");
			button:SetAttribute("*bag2", nil);
			button:SetAttribute("*slot2", slot);
		elseif (bag and slot) then
			local itemLink = GetContainerItemLink(bag, slot)
			local itemString = string.match(itemLink or "", "^|c%x+|H(.+)|h%[.+%]")
--AutoBar:Print(baseName .. " texture ".. tostring(texture).." itemLink " .. tostring(itemLink) .. " itemString " .. tostring(itemString));
			button:SetAttribute("*type1", "item")
			button:SetAttribute("*item1", itemString);
			if (not type2) then
				button:SetAttribute("*type2", "item")
				button:SetAttribute("*item2", itemString);
			end
--AutoBar:Print(baseName .. " AutoBarButton:SetAttributes bag " .. tostring(bag).. " slot " .. tostring(slot))
		elseif (action) then
			button:SetAttribute("*type1", "action");
			button:SetAttribute("*action1", action);
			button:SetAttribute("*type2", "action");
			button:SetAttribute("*action2", action);
		elseif (macroText) then
			button:SetAttribute("*type1", "macro");
			button:SetAttribute("*macrotext1", macroText);
			button:SetAttribute("*type2", "macro");
			button:SetAttribute("*macrotext2", macroText);
		elseif (spell) then
--AutoBar:Print("AutoBarButton:SetAttributes spell " .. tostring(spell))
			-- Also castSpell on left click
			button:SetAttribute("*type1", "spell")
			button:SetAttribute("*spell1", spell)
			button:SetAttribute("*type2", "spell")
			button:SetAttribute("*spell2", spell)

			-- Temporary till Category support is in for selfCastRightClick & harm & help
			if (not AutoBar.display.disableRightClickSelfCast) then
				button:SetAttribute("*unit2", "player")
			end
		elseif (castSpell) then
			-- Also castSpell on left click if nothing else is available
			button:SetAttribute("*type1", "spell");
			button:SetAttribute("*spell1", castSpell);

			-- Temporary till Category support is in for selfCastRightClick & harm & help
			if (not AutoBar.display.disableRightClickSelfCast) then
				button:SetAttribute("*unit2", "player")
			end
		else
			button:SetAttribute("*type1", nil)
			button:SetAttribute("*type2", nil)
		end
	end
	button:SetAttribute("itemId", itemId);
	button:SetAttribute("category", category);

	AutoBarButton:UpdateTexture(button);
	AutoBarButton:UpdateCooldown(button);
	AutoBarButton:UpdateCount(button);
	AutoBarButton:UpdateUsable(button);
end


--
-- Button Update callback functions
--
function AutoBarButton:SetTooltip(button)
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
	else
		GameTooltip:SetOwner(this);
	end

	local p = _G["AutoBarSSHeaderFrame"]
	local buttonType = button:GetAttribute("*type1")

	if (not buttonType) then
		this.updateTooltip = nil;
	elseif (buttonType == "item") then
		local bag = button:GetAttribute("*bag1");
		local slot = button:GetAttribute("*slot1");
		local itemId = button:GetAttribute("itemId");
		local itemLink = button:GetAttribute("*item1");

		if (itemLink) then
			GameTooltip:SetHyperlink(itemLink);
		elseif (bag and slot) then
			GameTooltip:SetBagItem(bag, slot);
		elseif (slot) then
			GameTooltip:SetInventoryItem("player", slot);
		end
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	elseif (buttonType == "spell") then
		local spellName = button:GetAttribute("*spell1");

		if (spellName) then
			spellInfo = AutoBarSearch.spells[spellName]
			GameTooltip:SetSpell(spellInfo.spellId, spellInfo.spellTab);
		end
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	end
end


function AutoBarButton:UpdateUsable(button)
	local itemId = button:GetAttribute("itemId");
	local category = button:GetAttribute("category");
	local spell	= button:GetAttribute("*spell1")

	local isUsable = nil;
	local notEnoughMana = nil;
	if (itemId and not spell) then
		isUsable, notEnoughMana = IsUsableItem(itemId);
	elseif (spell or button:GetAttribute("*type1") == "spell") then
		isUsable = true;
	end
	if (isUsable and category) then
		local categoryInfo = AutoBarCategoryList[category]
		if (categoryInfo) then
			if (categoryInfo.battleground and not AutoBar.inBG) then
				isUsable = false
			else
				local zone = GetRealZoneText()
				if (categoryInfo.location and categoryInfo.location ~= zone) then
					local zoneGroup = AutoBarSearch.zoneGroup[zone]
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarButton:UpdateUsable zoneGroup " .. tostring(zoneGroup))
					if (zoneGroup ~= categoryInfo.location) then
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarButton:UpdateUsable denied categoryInfo.location " .. tostring(categoryInfo.location))
						isUsable = false
					end
				end
			end
		end
	end
	if (isUsable) then
		button.icon:SetVertexColor(1.0, 1.0, 1.0);
		button.normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif (notEnoughMana) then
		button.icon:SetVertexColor(0.5, 0.5, 1.0);
		button.normalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		button.icon:SetVertexColor(0.2, 0.2, 0.2);
		button.normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end


-- Update the list of dirty popup buttons
function AutoBarButton:UpdateCountPopup()
	for button, _ in pairs(AutoBarButton.dirtyPopupCount) do
		self:UpdateCount(button)
		AutoBarButton.dirtyPopupCount[button] = nil
	end
end


function AutoBarButton:UpdateCount(button)
	local countText = getglobal(button:GetName().."Count");
	local itemId = button:GetAttribute("itemId");
	local spell	= button:GetAttribute("*spell1")
	local count = 0;
	if (itemId and not spell) then
		count = GetItemCount(tonumber(itemId));
	end

	if (count > 1) then
		countText:SetText(count);
	else
		countText:SetText("");
	end
end


-- Update the list of dirty popup buttons
function AutoBarButton:UpdateCooldownPopup()
	for button, _ in pairs(AutoBarButton.dirtyPopupCooldown) do
		self:UpdateCooldown(button)
		AutoBarButton.dirtyPopupCooldown[button] = nil
	end
end


function AutoBarButton:UpdateCooldown(button)
	local cooldown = getglobal(button:GetName().."Cooldown");
--	local bag = button:GetAttribute("bag");
--	local slot = button:GetAttribute("slot");
	local itemId = button:GetAttribute("itemId");
	local start, duration, enable;

	cooldown:Show();
--	if (bag and slot) then
--		start, duration, enable = GetContainerItemCooldown(bag, slot);
--	elseif (slot) then
--		start, duration, enable = GetInventoryItemCooldown("player", slot);
--	end
	start, duration, enable = GetItemCooldown(itemId)
	if (start and duration and enable and start > 0 and duration > 0) then
		CooldownFrame_SetTimer(cooldown, start, duration, enable);
	else
		CooldownFrame_SetTimer(cooldown, 0, 0, 0);
	end
end


function AutoBarButton:UpdateTexture(button)
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarButton:UpdateTexture " .. button:GetName());
	local bag = button:GetAttribute("bag");
	local slot = button:GetAttribute("slot");
	local itemId = button:GetAttribute("itemId");
	local spell	= button:GetAttribute("*spell1")
	local texture;

	if (itemId and not spell) then
		_,_,_,_,_,_,_,_,_,texture = GetItemInfo(tonumber(itemId));
	end
	if (not texture) then
		local spellName
		if (spell) then
			spellName = spell
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarButton:UpdateTexture *spell1 " .. tostring(spell));
		else
			spellName = button:GetAttribute("*spell2")
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarButton:UpdateTexture *spell2 " .. tostring(spellName));
		end
		if (spellName) then
			texture = BS:GetSpellIcon(spellName)
		end
	end
	if (not texture) then
		local category = button:GetAttribute("category");
		texture = AutoBar:GetTexture(category);
	end
	if (texture) then
		button.icon:SetTexture(texture);
		button.icon:Show();
		this.rangeTimer = -1;
	else
		button.icon:Hide();
		this.rangeTimer = nil;
		button.hotKey:SetVertexColor(0.6, 0.6, 0.6);
	end

	if ((not bag) and slot) then
		-- Add a green border if button is an equipped item
		button.border:SetVertexColor(0, 1.0, 0, 0.75);
		button.border:Show();
	elseif (spell) then
		-- Add a blue border if button is a spell
		button.border:SetVertexColor(0, 0, 1.0, 0.75);
		button.border:Show();
	else
		button.border:Hide();
	end

	if (GameTooltip:IsOwned(this)) then
		AutoBarButton:SetTooltip(button);
	else
		this.updateTooltip = nil;
	end

	-- Update Macro Text
--	local macroText = button:GetAttribute("macroText");
--	local macroName = getglobal(button:GetName().."Name");
--	macroName:SetText(macroText);
end


-- Handle a click on a button
function AutoBarButton:PreClick(mousebutton, down)
--	local button = this;
--	if (IsMounted()) then
--		Dismount();
--	end
end


-- Handle a click on a button
function AutoBarButton:PostClick(mousebutton, down)
	local button = this;
	if (down) then
		button:SetChecked(1);
	else
		button:SetChecked(0);
		button:SetNormalTexture("");
		button:SetPushedTexture("");
	end
end


-- Handle a click on a popped up button
function AutoBarButton:PopupPostClick(mousebutton, down)
	local popupButton = this;
	AutoBarButton.dirtyPopupCount[this] = true
	AutoBarButton.dirtyPopupCooldown[this] = true
	popupButton:SetChecked(0);
	popupButton:SetNormalTexture("");
	popupButton:SetPushedTexture("");

	local buttonsIndex = popupButton:GetAttribute("buttonsIndex");
	local buttonInfo = AutoBar.buttons[buttonsIndex];

--DEFAULT_CHAT_FRAME:AddMessage("AutoBarButton:PopupPostClick buttonsIndex " .. buttonsIndex);
	if (buttonInfo.arrangeOnUse and not InCombatLockdown()) then
		local popupButtonIndex = popupButton:GetAttribute("popupButtonIndex");
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarButton:PopupPostClick popupButtonIndex " .. popupButtonIndex);
		if (popupButtonIndex == 0) then
			return
		end
		local index;
		local itemId = popupButton:GetAttribute("itemId");
		local category = popupButton:GetAttribute("category");
		local update = false;
		for index = AUTOBAR_MAXSLOTCATEGORIES, 1, -1 do
			if (buttonInfo[index] == category) then
				local slotIndexA, slotIndexB, categoryIndexA, categoryIndexB
				-- First arrange the slot categories
				local targetIndex = # buttonInfo
				local temp = buttonInfo[index];
				if (index ~= targetIndex) then
					buttonInfo[index] = buttonInfo[targetIndex];
					buttonInfo[targetIndex] = temp;
					slotIndexA = index
					slotIndexB = targetIndex
					update = true;
				end

--DEFAULT_CHAT_FRAME:AddMessage("arrangeOnUse start " .. tostring(category) .. " / " .. tostring(itemId));
				-- Arrange the category if allowed
				if (AutoBarCategoryList[category] and AutoBarCategoryList[category].arrangeOnUse) then
					local categoryList = AutoBarCategoryList[category].items;
					categoryIndexB = # categoryList
					for i, categoryItemId in ipairs(categoryList) do
--DEFAULT_CHAT_FRAME:AddMessage("arrangeOnUse ".. i .. " / " .. categoryItemId .. " categoryIndexB " .. categoryIndexB);
						if (categoryItemId == itemId and i ~= categoryIndexB) then
							categoryIndexA = i
							temp = categoryList[i]
							categoryList[i] = categoryList[categoryIndexB]
							categoryList[categoryIndexB] = temp
--DEFAULT_CHAT_FRAME:AddMessage("arrangeOnUse i " .. tostring(i) .. " categoryList[i] " .. tostring(categoryList[i]));
--DEFAULT_CHAT_FRAME:AddMessage("arrangeOnUse categoryIndexB " .. tostring(categoryIndexB) .. " categoryList[categoryIndexB] " .. tostring(categoryList[categoryIndexB]));
							update = true;
							break;
						end
					end
				end

				AutoBarSearch.items:Rearrange(buttonsIndex, slotIndexA, slotIndexB, category, categoryIndexA, categoryIndexB)

				-- ToDo: only update the button itself
				if (update) then
					AutoBarButton.dirtyButton[buttonsIndex] = true
					AutoBar.delayLayoutUpdate:Start()
				end
				break;
			end
		end
	end
end


-- Set the visual look and feel for the button
function AutoBarButton:InitializeVisual(button)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	button:SetPushedTexture("");

	local buttonName = button:GetName();
	local oldNT = _G[buttonName.."NormalTexture"];
	oldNT:Hide();

	button.normalTexture = button:CreateTexture(buttonName .. "BTNT");
	button.normalTexture:SetAllPoints(oldNT);

	button.border = _G[buttonName.."Border"];
--	button.border:SetAllPoints(button);

	button.hotKey = _G[buttonName.."HotKey"];
	button.icon = _G[buttonName.."Icon"];
end


-- Set the visual look and feel for the button
function AutoBarButton:SetVisual(baseName)
	local button = _G[baseName];
	local buttonWidth, buttonHeight = AutoBar:GetButtonSize();
	local scale = buttonWidth / 36;
	local alpha = AutoBar.display.alpha / 10;

	local countText = _G[baseName.."Count"];
	local cooldown = _G[baseName.."Cooldown"];

	button:SetAlpha(alpha);
	button.normalTexture:SetAlpha(alpha);
	button:SetWidth(buttonWidth);
	button:SetHeight(buttonHeight);
	button:SetScale(scale);
--	button.border:SetWidth(2*buttonWidth*62/36);
--	button.border:SetHeight(2*buttonHeight*62/36);
--	button.border:SetTexCoord(0, 1, 0, 1);
-- /script AutoBarSAB1.border:SetHeight(72)
	AutoBar:RefreshStyle(button);

	local fonttext, fontsize, fontoptions;
	if (AutoBar.display.hideKeyText) then
		button.hotKey:Hide();
	else
		fonttext, fontsize, fontoptions = button.hotKey:GetFont();
		button.hotKey:SetJustifyH("LEFT");
		button.hotKey:SetJustifyV("TOP");
		button.hotKey:SetPoint("TOPLEFT", baseName, "TOPLEFT", 2, -2);
		button.hotKey:Show();
	end
	if (AutoBar.display.hideCount) then
		countText:Hide();
	else
		countText:Show();
		fonttext, fontsize, fontoptions = countText:GetFont();
		countText:SetFont(fonttext, 14 * scale, fontoptions);
	end

	cooldown:SetScale(math.max(buttonWidth-1, buttonHeight-1) / 36);
end




-- /script DEFAULT_CHAT_FRAME:AddMessage(tostring(AutoBarProfile.basic[2].castSpell))
-- /script DEFAULT_CHAT_FRAME:AddMessage(tostring(AutoBar.buttons[2].castSpell))
-- /script AutoBarSAB1Border:Hide()
-- /dump AutoBarSAB1
-- /script DEFAULT_CHAT_FRAME:AddMessage("f:"..tostring(GetCVar("flyable")))
