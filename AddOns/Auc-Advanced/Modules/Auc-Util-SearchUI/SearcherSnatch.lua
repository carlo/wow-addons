--[[
	Auctioneer Advanced - Search UI - Searcher Snatch
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: SearcherSnatch.lua 3776 2008-11-06 12:48:41Z Nayala $
	URL: http://auctioneeraddon.com/

	This is a plugin module for the SearchUI that assists in searching by refined paramaters

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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Snatch")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Snatch"
lib.Private = private

default("snatch.allow.bid", true)
default("snatch.allow.buy", true)
default("snatch.allow.beginerTooltips", true)
--defaults do not work for tables,  A123456 is still gonna be table A123456  regardless of if it has data or not
if not get("snatch.itemsList") then set("snatch.itemsList", {}) end

private.workingItemLink = nil
local frame

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")
	gui:MakeScrollable(id)

	-- Add the help
	gui:AddSearcher("Snatch", "Search for items which you want to buy when they are available for less than a given price", 100)
	gui:AddHelp(id, "snatch searcher",
		"What does this searcher do?",
		"This searcher provides the ability to snap up items which meet your fixed price constraints. It is useful whenever you say \"I always want to buy this when it is cheaper that X/item\".")

	--we add a single invisible element to set the normal gui
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")
	--Add Drag slot / Item icon
	frame = gui.tabs[id].content
	private.frame = frame

	--Create the snatch list results frame
	frame.snatchlist = CreateFrame("Frame", nil, frame)
	frame.snatchlist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})

	frame.snatchlist:SetBackdropColor(0, 0, 0.0, 0.5)
	frame.snatchlist:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, 2)
	frame.snatchlist:SetPoint("BOTTOM", frame, "BOTTOM", 0, 110)
	frame.snatchlist:SetWidth(360)

	frame.slot = frame:CreateTexture(nil, "BORDER")
	frame.slot:SetDrawLayer("Artwork") -- or the border shades it
	frame.slot:SetPoint("BOTTOM", frame.snatchlist, "BOTTOM", 0, -100)
	frame.slot:SetWidth(45)
	frame.slot:SetHeight(45)
	frame.slot:SetTexCoord(0.17, 0.83, 0.17, 0.83)
	frame.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")


	--ICON box, used to drag item and display Icon
	function frame.IconClicked()
		local objtype, _, link = GetCursorInfo()
		ClearCursor()
		if objtype == "item" then
			lib.SetWorkingItem(link)
		end
	end
	frame.icon = CreateFrame("Button", nil, frame)
	frame.icon:SetPoint("TOPLEFT", frame.slot, "TOPLEFT", 2, -2)
	frame.icon:SetPoint("BOTTOMRIGHT", frame.slot, "BOTTOMRIGHT", -2, 2)
	frame.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	frame.icon:SetScript("OnClick", frame.IconClicked)
	frame.icon:SetScript("OnReceiveDrag", frame.IconClicked)

	frame.slot.help = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.slot.help:SetPoint("LEFT", frame.slot, "RIGHT", 2, 7)
	frame.slot.help:SetText(("Drop item into box")) --"Drop item into box to search."
	frame.slot.help:SetWidth(100)

	if not ( AucAdvanced and AucAdvanced.Modules.Util.Appraiser ) then
		frame.snatchlist.sheet = ScrollSheet:Create(frame.snatchlist, {
		{ "Snatching", "TOOLTIP", 176 },
		{ "Buy each", "COIN", 70 },
		}, private.OnEnterSnatch, private.OnLeave, private.OnClickSnatch, private.OnResize)
	else
		frame.snatchlist.sheet = ScrollSheet:Create(frame.snatchlist, {
		{ "Snatching", "TOOLTIP", 176 },
		{ "Buy each", "COIN", 70},
		{ "App. value", "COIN", 70 },
		}, private.OnEnterSnatch, private.OnLeave, private.OnClickSnatch, private.OnResize)
	end

	-- Bag List
	frame.baglist = CreateFrame("Frame", nil, frame)
	frame.baglist:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})

	frame.baglist:SetBackdropColor(0, 0, 0.0, 0.5)
	frame.baglist:SetPoint("TOPLEFT", frame.snatchlist, "TOPRIGHT", 10, 0)
	--frame.baglist:SetPoint("RIGHT", frame, "RIGHT", -30, -0)
	frame.baglist:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
	frame.baglist:SetPoint("BOTTOM", frame.snatchlist, "BOTTOM", 0, 0)

	frame.bagscan = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.bagscan:SetPoint("TOP", frame.baglist, "BOTTOM", 0, -15)
	frame.bagscan:SetText(("Refresh Bag Data"))
	frame.bagscan:SetWidth(130)
	frame.bagscan:SetScript("OnClick", lib.PopulateBagSheet)
	frame.bagscan:SetScript("OnEnter", function() lib.buttonTooltips( frame.bagscan, "Click to rescan all items currently in your inventory.") end)
	frame.bagscan:SetScript("OnLeave", function() GameTooltip:Hide() end)

	if not ( AucAdvanced and AucAdvanced.Modules.Util.Appraiser ) then
		frame.baglist.sheet = ScrollSheet:Create(frame.baglist, {
			{ "Bag Contents", "TOOLTIP", 208 },
			{ "BTM Rule", "TEXT", 70 },
			}, private.OnEnterBag, private.OnLeave, private.OnClickBag, private.OnResize)
	else
		frame.baglist.sheet = ScrollSheet:Create(frame.baglist, {
			{ "Bag Contents", "TOOLTIP", 208 },
			{ "Appraiser", "COIN", 70 },
			}, private.OnEnterBag, private.OnLeave, private.OnClickBag, private.OnResize)
	end

	frame.money = CreateFrame("Frame", "TEST", frame, "MoneyInputFrameTemplate")
	frame.money.isMoneyFrame = true
	frame.money:SetPoint("LEFT", frame.slot, "RIGHT", 10,-20)

	--Add Item to list button
	frame.additem = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.additem:SetPoint("LEFT", frame.money, "RIGHT", 0, 0)
	frame.additem:SetText(('Add Item'))
	frame.additem:SetScript("OnClick", function()
								local copper = MoneyInputFrame_GetCopper(frame.money)
								lib.AddSnatch(private.workingItemLink, copper)
							end)
	frame.additem:SetScript("OnEnter", function() lib.buttonTooltips( frame.additem, "Click to add current selection to the snatch list") end)
	frame.additem:SetScript("OnLeave", function() GameTooltip:Hide() end)

	--Remove Item from list button
	frame.removeitem = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.removeitem:SetPoint("LEFT", frame.additem, "RIGHT", 10, 0)
	frame.removeitem:SetText(('Remove Item'))
	frame.removeitem:SetScript("OnClick", function() lib.RemoveSnatch(private.workingItemLink) end)
	frame.removeitem:SetScript("OnEnter", function() lib.buttonTooltips( frame.removeitem, "Click to remove current selection from the snatch list") end)
	frame.removeitem:SetScript("OnLeave", function() GameTooltip:Hide() end)

	--Reset snatch list
	frame.resetList = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.resetList:SetPoint("TOP", frame.snatchlist, "BOTTOM", 0, -15)
	frame.resetList:SetText(("Clear List"))
	frame.resetList:SetScript("OnClick", function()
								if ( IsAltKeyDown() and IsShiftKeyDown() and IsControlKeyDown() )then
									private.snatchList = {}
									set("snatch.itemsList", private.snatchList)
									lib.refreshData()
								else
									print("This will clear the snatch list permanently. To use hold ALT+CTR+SHIFT while clicking this button")
								end
							end)
	frame.resetList:SetScript("OnEnter", function() lib.buttonTooltips( frame.resetList, "Shift+ALT+CTR Click to remove all items from the snatch list") end)
	frame.resetList:SetScript("OnLeave", function() GameTooltip:Hide() end)

	private.snatchList =  get("snatch.itemsList")
	--if there was no saved snatchList, create an empty table
	if not private.snatchList then
		private.snatchList = {}
		set("snatch.itemsList", private.snatchList)
	end
	--Set our "last" frame anchor point this will be the "top" area for normal config GUI elements
	local last = gui:GetLast(id)
	local  locationA, Frame, locationB, x, y = last:GetPoint()
		last:SetPoint(locationA, Frame, locationB, x, -270)
	gui:SetLast(id, last)

	gui:AddControl(id, "Subhead",0, "Snatch search settings:")
	gui:AddControl(id, "Note", 0, 1, nil, nil, " ")
	last = gui:GetLast(id)
	gui:AddControl(id, "Checkbox", 0, 1, "snatch.allow.bid", "Allow Bids")
	gui:AddTip(id, "Allow Snatch searcher to sugest bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox", 0, 11,  "snatch.allow.buy", "Allow Buyouts")
	gui:AddTip(id, "Allow Snatch searcher to sugest buyouts")

	gui:AddControl(id, "Note", 0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox", 0, 1,  "snatch.allow.beginerTooltips", "Display beginner popup help.")
	gui:AddTip(id, "Display beginner tooltips.")


	lib.refreshData()
	lib.PopulateBagSheet()
end

--Processor function
--this handles any notifications that SearchUI core needs to send us
function lib.Processor(msg, ...)
	if msg == "config" then --saved search has changed, so reload the ignorelist
		private.snatchList =  get("snatch.itemsList")
		--if there was no saved snatchList, create an empty table
		if not private.snatchList then
			private.snatchList = {}
			set("snatch.itemsList", private.snatchList)
		end
		lib.refreshData()
	end
end

function private.OnEnterSnatch(button, row, index)
	if frame.snatchlist.sheet.rows[row][index]:IsShown() then --Hide tooltip for hidden cells
		local link = frame.snatchlist.sheet.rows[row][index]:GetText()
		local name = GetItemInfo(link)
		if link and name then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(link)
			AucAdvanced.ShowItemLink(GameTooltip, link, 1)
		end
	end
end

function private.OnEnterBag(button, row, index)
	if frame.baglist.sheet.rows[row][index]:IsShown() then --Hide tooltip for hidden cells
		local link = frame.baglist.sheet.rows[row][index]:GetText()
		local name = GetItemInfo(link)
		if link and name then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(link)
		end
	end
end

function private.OnLeave()
	GameTooltip:Hide()
end

function private.OnClickBag(button, row, index)
	local link = frame.baglist.sheet.rows[row][1]:GetText()
	lib.SetWorkingItem(link)
end

function private.OnClickSnatch(button, row, index)
	local link = frame.snatchlist.sheet.rows[row][1]:GetText()
	lib.SetWorkingItem(link)
end

function private.OnResize(...)
	--print(...)
end
--Beginner Tooltips script display for all UI elements
function lib.buttonTooltips(self, text)
	if get("snatch.allow.beginerTooltips") and text and self then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetText(text)
	end
end
--[[
ItemTable[Const.LINK]    = hyperlink
	ItemTable[Const.ILEVEL]  = iLevel
	ItemTable[Const.ITYPE]   = iType
	ItemTable[Const.ISUB]    = iSubType
	ItemTable[Const.IEQUIP]  = iEquip
	ItemTable[Const.PRICE]   = price
	ItemTable[Const.TLEFT]   = timeleft
	ItemTable[Const.NAME]    = name
	ItemTable[Const.COUNT]   = count
	ItemTable[Const.QUALITY] = quality
	ItemTable[Const.CANUSE]  = canUse
	ItemTable[Const.ULEVEL]  = level
	ItemTable[Const.MINBID]  = minBid
	ItemTable[Const.MININC]  = minInc
	ItemTable[Const.BUYOUT]  = buyout
	ItemTable[Const.CURBID]  = curBid
	ItemTable[Const.AMHIGH]  = isHigh
	ItemTable[Const.SELLER]  = owner
	ItemTable[Const.ITEMID]  = itemid
	ItemTable[Const.SUFFIX]  = suffix
	ItemTable[Const.FACTOR]  = factor
	ItemTable[Const.ENCHANT]  = enchant
	ItemTable[Const.SEED]  = seed
]]
--returns if a item meets snatch criteria
function lib.Search(item)
	local itemsig = (":"):join(item[Const.ITEMID], item[Const.SUFFIX] , item[Const.ENCHANT])
	local value = 0
	local stackSize = item[Const.COUNT] or 1

	if private.snatchList[itemsig] then
		value =  stackSize * (private.snatchList[itemsig].price or 0)

		if item[Const.BUYOUT] > 0 and item[Const.BUYOUT] <= value and get("snatch.allow.buy") then
			return "buy", value
		elseif item[Const.PRICE] <= value and get("snatch.allow.bid") then
			return "bid", value
		else
			return false, "Price not low enough or bid/buy not checked."
		end
	end
	return false, "Not in snatch list"
end

--[[Snatch GUI functinality code]]
function lib.AddSnatch(itemlink, price, count)
	local _, itemid, itemsuffix, itemenchant, _ = AucAdvanced.DecodeLink(itemlink)

	if not itemid then return end

	local itemsig = (":"):join(itemid, itemsuffix, itemenchant)

	if price and price<=0 then
		price=nil
	end
	if count and count<=0 then
		count=nil
	end
	--add item to snatch list
	if price then
		private.snatchList[itemsig] = {["link"] =  itemlink, ["price"] = price, ["count"] = count}
	else
		private.snatchList[itemsig] = nil
	end
	set("snatch.itemsList", private.snatchList)
	lib.finishedItem()
end

function lib.RemoveSnatch(itemlink)
	local _, itemid, itemsuffix, itemenchant, itemseed = AucAdvanced.DecodeLink(itemlink)
	if not itemid then return end

	local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
	--remove from snatch list
	private.snatchList[itemsig] = nil
	set("snatch.itemsList", private.snatchList)
	lib.finishedItem()
end
--set UI for next item choice
function lib.finishedItem()
	--reset UI
	frame.slot.help:SetText(("Drop item into box"))
	frame.icon:SetNormalTexture(nil)
	frame.icon:SetScript("OnEnter", function() end)
	MoneyInputFrame_ResetMoney(frame.money)
	--reset current working item
	private.workingItemLink = nil
	--refresh displays
	lib.refreshData()
end
--get the current item we may want to add or remove
function lib.SetWorkingItem(link)
	if type(link)~="string" then return end

	local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(link)
	if not name or not texture then return end

	--Get the current saved value if already in snatch list
	local _, itemid, itemsuffix, itemenchant, _ = AucAdvanced.DecodeLink(link)
	if itemid then
		local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
		if private.snatchList[itemsig] then
			MoneyInputFrame_SetCopper(frame.money, private.snatchList[itemsig].price or 0)
		else
			MoneyInputFrame_ResetMoney(frame.money)
		end
	end

	--set edit box texture and name
	frame.icon:SetNormalTexture(texture) --set icon texture
	frame.icon:SetScript("OnEnter", function() --set mouseover tooltip
			GameTooltip:SetOwner(frame.icon, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetHyperlink(link)
		end)
	frame.icon:SetScript("OnLeave", function() GameTooltip:Hide() end)
	frame.slot.help:SetText(link)

	--set current working item
	private.workingItemLink = link
end

function lib.ClickLinkHook(_, _, link, button)
	if link and private.frame and private.frame:IsShown() then
		if (button == "LeftButton") then --and (IsAltKeyDown()) and itemName then -- Commented mod key, I want to catch any item clicked.
			lib.SetWorkingItem(link)
		end
	end
end
hooksecurefunc("ChatFrame_OnHyperlinkShow", lib.ClickLinkHook)

function lib.refreshData()
	--get appraiser price if possible
	local Data, Style = {}, {}
	for item, v in pairs(private.snatchList) do
		--look up the current appraiser valuation to add to display
		local abid, abuy, appraiser
		if AucAdvanced and AucAdvanced.Modules.Util.Appraiser then
			abid, abuy = AucAdvanced.Modules.Util.Appraiser.GetPrice(v.link, nil, true)
			appraiser = tonumber(abuy) or tonumber(abid)
		end

		table.insert(Data, {v.link, v.price, appraiser or 0})
	end
	if frame then
		frame.snatchlist.sheet:SetData(Data, Style)
	end
end

function lib.PopulateBagSheet()
	local unique = {}
	local bagcontents = {}
	local appraiser = AucAdvanced and AucAdvanced.Modules.Util.Appraiser

	for bag=0,NUM_BAG_SLOTS do
		for slot=1,GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag,slot)
			if itemLink then
				local _, itemid, suffix, enchant, seed = AucAdvanced.DecodeLink(itemLink)
				local sig = ("%d:%d"):format(itemid,suffix)
				if not unique[sig] then
					unique[sig]=true
					local _,itemCount = GetContainerItemInfo(bag,slot)
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink)
					if not appraiser then
						tinsert(bagcontents, {
							itemLink,
							0
						})
					else
						local abid,abuy = appraiser.GetPrice(itemLink, nil, true)
						tinsert(bagcontents, {
							itemLink,
							tonumber(abuy) or tonumber(abid)
						})
					end
				end
			end
		end
	end
	frame.baglist.sheet:SetData(bagcontents) --Set the GUI scrollsheet
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-SearchUI/SearcherSnatch.lua $", "$Rev: 3776 $")
