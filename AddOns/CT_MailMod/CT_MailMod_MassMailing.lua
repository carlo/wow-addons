------------------------------------------------
--                 CT_MailMod                 --
--                                            --
-- Mail several items at once with almost no  --
-- effort at all. Also takes care of opening  --
-- several mail items at once, reducing the   --
-- time spent on maintaining the inbox for    --
-- bank mules and such.                       --
-- Please do not modify or otherwise          --
-- redistribute this without the consent of   --
-- the CTMod Team. Thank you.                 --
------------------------------------------------

local _G = getfenv(0);
local module = _G["CT_MailMod"];

--------------------------------------------
-- Item Attachment

local fusedSlots = { };
local attachContainers = { };
local attachSlots = { };

local function getFuseKey(container, slot)
	return ("%d-%d"):format(container, slot);
end

local function getItemIndex(container, slot)
	return fusedSlots[getFuseKey(container, slot)];
end

local function attachContainerItem(container, slot)
	-- Make sure we don't have this slot in here already
	if ( getItemIndex(container, slot ) ) then
		return;
	end
	
	tinsert(attachContainers, container);
	tinsert(attachSlots, slot);
	fusedSlots[getFuseKey(container, slot)] = #attachSlots;
	module:raiseCustomEvent("MASS_MAILING_ITEM_UPDATE");
end

local function removeContainerItem(container, slot)
	local key = getItemIndex(container, slot);
	if ( key ) then
		tremove(attachContainers, key);
		tremove(attachSlots, key);
		fusedSlots[getFuseKey(container, slot)] = nil;
		module:raiseCustomEvent("MASS_MAILING_ITEM_UPDATE");
	end
end

local function swapContainerItem(oldC, oldS, newC, newS)
	if ( oldC ~= newC or oldS ~= newS ) then
		local hadOld = getItemIndex(oldC, oldS);
		local hadNew = getItemIndex(newC, newS);
		
		if ( hadOld ) then
			attachContainerItem(newC, newS);
		else
			removeContainerItem(newC, newS);
		end
		if ( hadNew ) then
			attachContainerItem(oldC, oldS);
		else
			removeContainerItem(oldC, oldS);
		end
	end
end

local function getNumItems()
	return #attachContainers;
end

local iterItems;
do
	local function iter(_, i)
		i = i - 1;
		local v = attachContainers[i];
		if ( v ) then
			return i, v, attachSlots[i];
		end
	end

	iterItems = function(offset) -- Local
		return iter, nil, getNumItems() + 1 - ( offset or 0 );
	end
end

--------------------------------------------
-- Cursor Management

local getCurrentItem;
do
	local function isValidItem(container, slot)
		if ( container and slot ) then
			local type, _, link = GetCursorInfo();
			if ( type == "item" and link == GetContainerItemLink(container, slot) ) then
				return true;
			end
		end
	end
	
	local currContainer, currSlot; 
	getCurrentItem = function() -- Local
		if ( isValidItem(currContainer, currSlot) ) then
			return currContainer, currSlot;
		else
			currContainer, currSlot = nil;
		end
	end
	
	-- Hook PickupContainerItem
	hooksecurefunc("PickupContainerItem", function(container, slot)
		-- Make sure we actually picked up this item
		if ( isValidItem(container, slot) ) then
			currContainer, currSlot = container, slot;
		elseif ( not CursorHasItem() ) then
			swapContainerItem(currContainer, currSlot, container, slot);
			currContainer, currSlot = nil;
		end
	end)
end

--------------------------------------------
-- Mass Mailing Frame

local showMassMailingFrame, hideMassMailingFrame, massMailingFrame;
do
	local function createEditBox(parent, width, labelText)
		local editbox = CreateFrame("EditBox", nil, parent);
		editbox:SetAutoFocus(false);
		editbox:SetMaxLetters(64);
		editbox:SetHistoryLines(1);
		editbox:SetWidth(width); editbox:SetHeight(18);
		editbox:SetFontObject("ChatFontNormal");

		local label = editbox:CreateFontString(nil, "BACKGROUND", "ChatFontNormal");
		label:SetPoint("RIGHT", editbox, "LEFT", -12, 0);
		label:SetJustifyH("RIGHT");
		label:SetText(labelText);

		local left = editbox:CreateTexture(nil, "BACKGROUND");
		left:SetTexture("Interface\\Common\\Common-Input-Border");
		left:SetWidth(8); left:SetHeight(18);
		left:SetPoint("TOPLEFT", editbox, "TOPLEFT", -8, 0);
		left:SetTexCoord(0, 0.0625, 0, 0.625);

		local middle = editbox:CreateTexture(nil, "BACKGROUND");
		middle:SetTexture("Interface\\Common\\Common-Input-Border");
		middle:SetWidth(width-16); middle:SetHeight(18);
		middle:SetPoint("LEFT", left, "RIGHT");
		middle:SetTexCoord(0.0625, 0.9375, 0, 0.625);

		local right = editbox:CreateTexture(nil, "BACKGROUND");
		right:SetTexture("Interface\\Common\\Common-Input-Border");
		right:SetWidth(8); right:SetHeight(18);
		right:SetPoint("LEFT", middle, "RIGHT");
		right:SetTexCoord(0.9375, 1, 0, 0.625);

		return editbox;
	end
	
	local createItemBox;
	do
		local function itemBoxIconOnEnter(self)
			if ( self.link ) then
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
				GameTooltip:SetHyperlink(self.link);
				GameTooltip:Show();
			end
		end
		
		local function itemBoxIconOnLeave(self)
			GameTooltip:Hide();
		end
		
		local function itemBoxOnClick(self)
			if ( not CursorHasItem() ) then
				removeContainerItem(self.container, self.slot);
			end
		end
		
		local function itemBoxOnEnter(self)
			if ( not CursorHasItem() ) then
				self.background:SetTexture(0.3, 0.3, 0.3, 0.25);
				module:displayTooltip(self, module:getText("MASS_MAILING_CLICK_REMOVE"));
			end
		end
		
		local function itemBoxOnLeave(self)
			self.background:SetTexture(0, 0, 0, 0.25);
			module:hideTooltip();
		end
		
		createItemBox = function(parent, static) -- Local
			local button = CreateFrame("Button", nil, parent);
			button:SetWidth(315); button:SetHeight(20);
			if ( not static ) then
				button:SetScript("OnClick", itemBoxOnClick);
				button:SetScript("OnEnter", itemBoxOnEnter);
				button:SetScript("OnLeave", itemBoxOnLeave);
			end
			
			local count = button:CreateFontString(nil, "ARTWORK", "ChatFontNormal");
			count:SetHeight(20);
			count:SetPoint("TOPRIGHT", -10, 0);
			button.count = count;
			
			local name = button:CreateFontString(nil, "ARTWORK", "ChatFontNormal");
			name:SetPoint("TOPLEFT", 20, 0);
			name:SetPoint("BOTTOMRIGHT", count);
			button.name = name;

			local background = button:CreateTexture(nil, "BACKGROUND");
			background:SetAllPoints(button);
			background:SetTexture(0, 0, 0, 0.25);
			button.background = background;

			local icon = CreateFrame("Button", nil, button);
			icon:SetWidth(20); icon:SetHeight(20);
			icon:SetPoint("TOPLEFT", button, "TOPLEFT");
			icon:SetScript("OnEnter", itemBoxIconOnEnter);
			icon:SetScript("OnLeave", itemBoxIconOnLeave);
			button.icon = icon;

			local iconTexture = icon:CreateTexture(nil, "ARTWORK");
			iconTexture:SetAllPoints(icon);
			icon.texture = iconTexture;
			
			return button;
		end
	end

	local function updateMassMailingScrollItems()
		local i, icon, link, texture, count, name = 0;
		local numItems = getNumItems();
		local offset = FauxScrollFrame_GetOffset(CT_MailMod_MassMailing_ScrollFrame);
		
		if ( numItems > 1 ) then
			massMailingFrame.subject:SetAutomatedText(("Multiple Items (%d)"):format(numItems));
		elseif ( numItems == 0 ) then
			massMailingFrame.subject:SetAutomatedText("");
		end
		
		for key, container, slot in iterItems(offset) do
			i = i + 1;
			if ( i > 9 ) then
				break;
			end

			itemBox = massMailingFrame[i];
			if ( not itemBox ) then
				itemBox = createItemBox(massMailingFrame);
				itemBox:SetPoint("TOPLEFT", massMailingFrame.dropButton, "TOPLEFT", 0, -22*i);
				massMailingFrame[i] = itemBox;
			end

			if ( numItems > 9 ) then
				itemBox:SetWidth(298);
			else
				itemBox:SetWidth(315);
			end

			texture, count = GetContainerItemInfo(container, slot);
			link = GetContainerItemLink(container, slot);
			name = GetItemInfo(link);
			
			itemBox:Show();
			itemBox.name:SetText(name);
			itemBox.container = container;
			itemBox.slot = slot;

			icon = itemBox.icon;
			icon.link = link:match("|H(item:[^|]+)|h");
			icon.texture:SetTexture(texture);

			if ( count == 1 ) then
				itemBox.count:SetText("");
			else
				itemBox.count:SetText(count);
			end
			
			if ( numItems == 1 ) then
				massMailingFrame.subject:SetAutomatedText(name);
			end
		end

		for y = i+1, 9, 1 do
			if ( massMailingFrame[y] ) then
				massMailingFrame[y]:Hide();
			end
		end
	end
	
	local function updatePostage()
		MoneyFrame_Update(massMailingFrame.moneyFrame:GetName(), module:getMailCost(getNumItems()));
	end
	module:regCustomEvent("MASS_MAILING_ITEM_UPDATE", updatePostage);

	local function updateMassMailingScroll()
		local numItems = getNumItems();
		FauxScrollFrame_Update(CT_MailMod_MassMailing_ScrollFrame, numItems, 9, 22);
		updateMassMailingScrollItems();
	end
	module:regCustomEvent("MASS_MAILING_ITEM_UPDATE", updateMassMailingScroll);

	local function massMailingFrameSkeleton()
		return "frame#s:384:512#tl#p:MailFrame", {
			"font#s:224:14#mid:6:230#v:GameFontNormal#MASS_MAILING",
			"font#tl:25:-80#s:310:0#v:GameFontNormal#MASS_MAILING_INFO#0.18:0.12:0.06:l",
			"font#tl:25:-150#v:GameFontNormalLarge#MASS_MAILING_ITEMS",
			"texture#br:-35:120#l:25:0#s:0:2#0.18:0.12:0.06",
			"font#br:-110:105#i:postage#v:GameFontNormal#MASS_MAILING_POSTAGE",
			"button#br:-125:83#s:80:20#i:send#v:GameMenuButtonTemplate#MASS_MAILING_SEND",
			"button#br:-45:83#s:80:20#i:cancel#v:GameMenuButtonTemplate#MASS_MAILING_CANCEL",

			["onload"] = function(self)
				-- Editboxes
				local to = createEditBox(self, 220, "To:");
				local subject = createEditBox(self, 220, "Subject:");
				to:SetPoint("TOPLEFT", self, "TOPLEFT", 125, -37);
				subject:SetPoint("TOPLEFT", self, "TOPLEFT", 125, -55);
				self.to, self.subject = to, subject;
				subject.text = "";

				-- Script Definitions
				local function onEscapePressed(self)
					self:ClearFocus();
				end
				local function onTabPressed(self)
					self:ClearFocus();
					( self == to and subject or to ):SetFocus();
				end
				local function onTextChanged(self)
					local text = self:GetText();
					if ( not self.automated and text ~= self.text ) then
						self.custom = true;
					end
					self.text = text;
					self.automated = nil;
				end

				-- Script Calls
				subject:SetScript("OnTextChanged", onTextChanged);
				subject:SetScript("OnEscapePressed", onEscapePressed);
				subject:SetScript("OnTabPressed", onTabPressed);
				to:SetScript("OnTabPressed", onTabPressed);
				to:SetScript("OnEscapePressed", onEscapePressed);

				-- Custom Methods
				function subject:SetAutomatedText(text)
					if ( not self.custom ) then
						self.automated = true;
						self:SetText(text);
					end
				end

				-- Drop button
				local dropButton = createItemBox(self, true);
				self.dropButton = dropButton;
				dropButton:SetPoint("TOPLEFT", self, "TOPLEFT", 25, -170);
				dropButton.name:SetText(module:getText("MASS_MAILING_DROP_ITEMS"));
				dropButton.background:SetTexture(0, 0.4, 0, 0.35);
				dropButton:SetScript("OnClick", function(self)
					local container, slot = getCurrentItem();
					if ( container and slot ) then
						attachContainerItem(container, slot);
						PickupContainerItem(container, slot);
						self:GetScript("OnLeave")(self);
					end
				end);
				dropButton:SetScript("OnReceiveDrag", dropButton:GetScript("OnClick"));
				dropButton:SetScript("OnEnter", function(self)
					if ( CursorHasItem() ) then
						self.background:SetTexture(0.5, 0.82, 0, 0.45);
						module:displayTooltip(self, module:getText("MASS_MAILING_DROP_HERE"));
					end
				end);
				dropButton:SetScript("OnLeave", function(self)
					self.background:SetTexture(0, 0.4, 0, 0.35);
					module:hideTooltip();
				end);

				-- Scroll Frame
				local scrollFrame = CreateFrame("ScrollFrame", "CT_MailMod_MassMailing_ScrollFrame",
					self, "FauxScrollFrameTemplate");
				scrollFrame:SetPoint("TOPLEFT", self, 0, -192);
				scrollFrame:SetPoint("BOTTOMRIGHT", self, -65, 125);
				scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
					FauxScrollFrame_OnVerticalScroll(self, offset, 22, updateMassMailingScroll);
				end);

				-- Money frame
				local moneyFrame = CreateFrame("Frame", "CT_MailMod_MassMailing_PostageMoneyFrame", self, "SmallMoneyFrameTemplate");
				moneyFrame:SetPoint("LEFT", self.postage, "RIGHT", 10, 0);
				moneyFrame.moneyType = "STATIC";
				moneyFrame.hasPickup = 0;
				moneyFrame.info = MoneyTypeInfo["STATIC"];
				self.moneyFrame = moneyFrame;
			end,
		};
	end
	
	showMassMailingFrame = function()
		if ( not massMailingFrame ) then
			massMailingFrame = module:getFrame(massMailingFrameSkeleton);
		end
		massMailingFrame:Show();
		updateMassMailingScroll();
		updatePostage();
	end
	
	hideMassMailingFrame = function()
		if ( massMailingFrame ) then
			massMailingFrame:Hide();
		end
	end
end


--------------------------------------------
-- Mass Mailing Tab

-- Hook the tab onclick function
do
	local old = MailFrameTab_OnClick;
	function MailFrameTab_OnClick(self, tab)
		if ( tab == 3 ) then
			old(self, 1);
			PanelTemplates_SetTab(MailFrame, 3);
			InboxFrame:Hide();
			showMassMailingFrame();
		else
			old(self, tab);
			hideMassMailingFrame();
		end
	end
end

do
	local tab = CreateFrame("Button", "MailFrameTab3", MailFrame, "FriendsFrameTabTemplate");
	tab:SetID(3);
	tab:SetText(module:getText("MASS_MAILING"));
	tab:SetPoint("LEFT", MailFrameTab2, "RIGHT", -8, 0);
	tab:SetScript("OnClick", function(self) MailFrameTab_OnClick(self:GetID()) end);
	PanelTemplates_SetNumTabs(MailFrame, 3);
end

--------------------------------------------
-- Quick Attachment Binding

do
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self, button)
		if ( IsModifiedClick("CT_MAILMOD_ATTACH_MASSMAIL") ) then
			if ( massMailingFrame and massMailingFrame:IsVisible() ) then
				attachContainerItem(self:GetParent():GetID(), self:GetID());
			end
		end
	end);
end