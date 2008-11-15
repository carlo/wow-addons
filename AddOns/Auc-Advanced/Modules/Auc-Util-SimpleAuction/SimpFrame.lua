--[[
	Auctioneer Advanced - Simplified Auction Posting
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: AprFrame.lua 3576 2008-10-10 03:07:13Z aesir $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds a simple dialog for
	easy posting of your auctionables when you are at the auction-house.

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
if not AucAdvanced then return end

local lib = AucAdvanced.Modules.Util.SimpleAuction
local private = lib.Private
local const = AucAdvanced.Const
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()
local Const = const

local frame
local TAB_NAME = "Post"

function private.postPickupContainerItemHook(_,_,bag, slot)
	if (CursorHasItem()) then
		frame.CursorItem = {bag = bag, slot = slot}
	else
		frame.CursorItem = nil
	end
end

function private.ShiftFocus(frame, ...)
	local dest
	if IsShiftKeyDown() then
		dest = frame.prevFrame
	else
		dest = frame.nextFrame
	end
	if dest and dest.SetFocus then
		dest:SetFocus()
	else
		frame:ClearFocus()
	end
end

function private.SetPrevNext(frame, prevFrame, nextFrame)
	frame.prevFrame = prevFrame
	frame.nextFrame = nextFrame
	frame:SetScript("OnTabPressed", private.ShiftFocus)
	frame:SetScript("OnEnterPressed", private.ShiftFocus)
end

function private.SigFromLink(link)
	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
	if itype=="item" then
		if enchant ~= 0 then
			return ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			return ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			return ("%d:%d"):format(id, suffix)
		end
		return tostring(id)
	end
	-- returns nil
end

function private.GetMyPrice(link, items)
	local uBid, uBuy
	local n = GetNumAuctionItems("owner")
	if n and n > 0 then
		for i = 1, n do
			local item = AucAdvanced.Scan.GetAuctionItem("owner", i)
			if item then
				if item[const.NAME] == name then
					if items then table.insert(items, item) end
					local bid, buy, owner = item[const.MINBID], item[const.BUYOUT], item[const.OWNER]
					if not uBid then
						uBid = bid
					else
						uBid = min(uBid, bid)
					end
					if not uBuy then
						uBuy = buy
					elseif buy then
						uBuy = min(uBuy, buy)
					end
				end
			end
		end
	end
	return uBid, uBuy
end

--Returns:
--numitems: number of competing items
--items: table with competition
--uBid: bid matching your current auction
--uBuy: buy matching your current auction
--lBid: bid undercutting competition by 1c
--lBuy: buy undercutting competition by 1c
--aSeen: number of items in competing auctions
--aBuy: average price for current competing auctions
function private.GetItems(link)
	local name = GetItemInfo(link)
	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
	local matching = AucAdvanced.API.QueryImage({ itemId = id })
	local aSeen, lBid, lBuy, uBid, uBuy, aBuy, aveBuy = 0
	local player = UnitName("player")
	local items = {}

	local live = false
	if AuctionFrame and AuctionFrame:IsVisible() then
		live = true
		uBid, uBuy = private.GetMyPrice(link, items)
	end
	for pos, item in ipairs(matching) do 
		local bid, buy, owner, stk = item[const.MINBID], item[const.BUYOUT], item[const.OWNER], item[const.COUNT]
		stk = stk or 1
		local bidea, buyea
		if bid and bid > 0 then
			bidea = bid/stk
		end
		if buy and buy > 0 then
			buyea = buy/stk
		end

		if owner and owner == player then
			if not live then
				if not uBid then uBid = bidea else uBid = min(uBid, bidea) end
				if not uBuy then uBuy = buyea elseif buyea then uBuy = min(uBuy, buyea) end
			end
		else
			if not lBid then
				lBid = bidea
			else
				lBid = min(lBid, bidea)
			end
			if not lBuy then
				lBuy = buyea
			elseif buyea then
				lBuy = min(lBuy, buyea)
			end
			if buy then
				aBuy = (aBuy or 0) + buy
				aSeen = (aSeen or 0)+ stk
			end
			table.insert(items, item)
		end
	end
	aveBuy = (aBuy or 0)/(aSeen or 1)
	return #items, items, uBid, uBuy, lBid, lBuy, aSeen, aveBuy
end

local GOLD="ffd100"
local SILVER="e6e6e6"
local COPPER="c8602c"

local GSC_3 = "|cff%s%d|cff000000.|cff%s%02d|cff000000.|cff%s%02d|r"
local GSC_2 = "|cff%s%d|cff000000.|cff%s%02d|r"
local GSC_1 = "|cff%s%d|r"

local function coins(money)
	money = math.floor(tonumber(money) or 0)
	local g = math.floor(money / 10000)
	local s = math.floor(money % 10000 / 100)
	local c = money % 100

	if g > 0 then
		return GSC_3:format(GOLD, g, SILVER, s, COPPER, c)
	elseif s > 0 then
		return GSC_2:format(SILVER, s, COPPER, c)
	else
		return GSC_1:format(COPPER, c)
	end
end
private.coins = coins

function private.SetIconCount(itemCount)
	local size = 18
	if itemCount > 999 then
		local size = 14
	elseif itemCount > 99 then
		local size = 16
	elseif itemCount > 9 then
		local size = 17
	end
	frame.icon.count:SetFont(AucAdvSimpleNumberFontLarge.font, size, "OUTLINE")
	frame.icon.count:SetText(itemCount)
end

function private.UpdateDisplay()
	local link = frame.icon.itemLink
	if not link then return end
	local cBid, cBuy = MoneyInputFrame_GetCopper(frame.minprice), MoneyInputFrame_GetCopper(frame.buyout)
	frame.CurItem.buy, frame.CurItem.bid = cBuy, cBid
	local cStack = frame.stacks.size:GetNumber() or 1
	frame.CurItem.stack = cStack
	local cNum = frame.stacks.num:GetNumber() or 1
	frame.CurItem.number = cNum
	local oStack, oBid, oBuy, oReason, oLink = unpack(frame.detail)
	local lStack = frame.stacks.size.lastSize or oStack
	local total = GetItemCount(link) or 0

	if (total == 0) then
		private.LoadItemLink()
		return
	end
	private.SetIconCount(total)

	local dBid = abs(cBid/lStack*oStack-oBid)
	local dBuy = abs(cBuy/lStack*oStack-oBuy)

	local priceType = "auto"
	if dBid >= 1 or dBuy >= 1 then
		priceType = "fixed"
		frame.err:SetText("Manual pricing on item")
	end

	if priceType == "auto" and cStack ~= oStack then
		private.UpdatePricing()
		return
	elseif priceType == "fixed" and cStack ~= lStack then
		cBid = cBid / lStack * cStack
		cBuy = cBuy / lStack * cStack
		cBid = ceil(cBid)
		cBuy = ceil(cBuy)
		MoneyInputFrame_ResetMoney(frame.minprice)
		MoneyInputFrame_SetCopper(frame.minprice, cBid)
		frame.CurItem.bid = cBid
		frame.CurItem.bidper = cBid/frame.CurItem.stack
		MoneyInputFrame_ResetMoney(frame.buyout)
		MoneyInputFrame_SetCopper(frame.buyout, cBuy)
		frame.CurItem.buy = cBuy
		frame.CurItem.buyper = cBuy/frame.CurItem.stack
		frame.err:SetText("Adjusted price to new stack size")
	end

	if GetSellValue then
		local vendor = GetSellValue(oLink) or 0
		if vendor > cBid / cStack then
			frame.err:SetText("Warning: Bid is below vendor price")
		end
	end

	local coinsBid, coinsBuy, coinsBidEa, coinsBuyEa
	if cBid > 0 then
		coinsBid = coins(cBid)
		coinsBidEa = coins(cBid/cStack)
	else
		coinsBid = "no"
		coinsBidEa = "no"
		frame.err:SetText("Error: No bid price set")
	end
	if cBuy > 0 then
		coinsBuy = coins(cBuy)
		coinsBuyEa = coins(cBuy/cStack)
		if cBuy < cBid then
			frame.err:SetText("Error: Buyout cannot be less than bid price")
		end
	else
		coinsBuy = "no"
		coinsBuyEa = "no"
	end

	local lots = "lot"
	if cNum > 1 then lots = "lots" end

	local text
	if (cStack > 1) then
		text = string.format("Auctioning %d %s of %d sized stacks at %s bid/%s buyout per stack (%s/%s ea)", cNum, lots, cStack, coinsBid, coinsBuy, coinsBidEa, coinsBuyEa)
	else
		text = string.format("Auctioning %d %s of this item at %s bid/%s buyout each", cNum, lots, coinsBid, coinsBuy)
	end
	frame.info:SetText(text)
	frame.stacks.equals:SetText("= "..(cStack * cNum))
end

function private.UpdateCompetition(image)
	local data = {}
	local style = {}
	for i = 1, #image do
		local result = image[i]
		local tLeft = result[Const.TLEFT]
		if (tLeft == 1) then tLeft = "30m"
		elseif (tLeft == 2) then tLeft = "2h"
		elseif (tLeft == 3) then tLeft = "12h"
		elseif (tLeft == 4) then tLeft = "48h"
		end
		local count = result[Const.COUNT]
		data[i] = {
			--result[Const.NAME],
			result[Const.SELLER],
			tLeft,
			count,
			math.floor(0.5+result[Const.MINBID]/count),
			math.floor(0.5+result[Const.CURBID]/count),
			math.floor(0.5+result[Const.BUYOUT]/count),
			result[Const.MINBID],
			result[Const.CURBID],
			result[Const.BUYOUT],
			result[Const.LINK]
		}
		local curbid = result[Const.CURBID]
		if curbid == 0 then
			curbid = result[Const.MINBID]
		end
		--color ignored/self sellers
		local seller = result[Const.SELLER]
		local player = UnitName("player")
		if seller == player then
			if not style[i] then style[i] = {} end
			style[i][1] = { textColor = {0,1,0} }
		elseif AucAdvanced.Modules.Filter.Basic and AucAdvanced.Modules.Filter.Basic.IgnoreList and AucAdvanced.Modules.Filter.Basic.IgnoreList[result[Const.SELLER]] then
			if not style[i] then style[i] = {} end
			style[i][1] = { textColor = {1,0,0} }
		end
	end
	frame.imageview.sheet:SetData(data, style)

	--reset scroll position if new items list is too short to show
	if  not frame.imageview.sheet.rows[1][1]:IsShown() then
		frame.imageview.sheet.panel:ScrollToCoords(0,0)
	end
end

function private.UpdatePricing()
	local link = frame.icon.itemLink
	if not link then return end
	local mid, seen = 0,0
	local stack = frame.stacks.size:GetNumber()
	local _,_,_,_,_,_,_,stx = GetItemInfo(link)
	local total = GetItemCount(link) or 0

	if (total == 0) then
		private.LoadItemLink()
		return
	end
	private.SetIconCount(total)

	stx = min(stx, total)

	if not stack or stack == 0 or stack > stx then
		stack = stx
		frame.stacks.size:SetNumber(stack)
		frame.CurItem.stack = stack
	end

	local num = frame.stacks.num:GetNumber()
	if not num or num == 0 then
		num = 1
		frame.stacks.num:SetNumber(num)
		frame.CurItem.number = num
	end

	local buy, bid
	local reason = ""

	-- We need this out here because it fetches the items from the image
	local imgseen, image, matchBid, matchBuy, lowBid, lowBuy, aSeen, aveBuy = private.GetItems(link)
	private.UpdateCompetition(image)
	
	--check for fixed price
	if frame.CurItem.manual then
		buy = frame.CurItem.buyper
		bid = frame.CurItem.bidper
		reason = "Manual pricing on item"
	end
	if not buy then
		--Check for undercut first
		if frame.options.undercut:GetChecked() then
			if lowBuy and lowBuy > 0 then
				local underBuy, underBid, by = 1,1, "default 1c"

				local model = get("util.simpleauc.undercut")
				local fixed = get("util.simpleauc.undercut.fixed")
				local percent = get("util.simpleauc.undercut.percent")
				local pct = tonumber(percent)/100
				if model == "fixed" then
					underBuy = fixed
					underBid = fixed
					by = "fixed amount: "..coins(fixed)
				else
					underBuy = lowBuy*pct
					underBid = (lowBid or 0)*pct
					by = percent.."% ("..coins(underBuy)..")"
				end

				buy = lowBuy - underBuy
				if lowBid and lowBid > 0 and lowBid <= lowBuy then
					bid = lowBid - underBid
				else
					bid = buy * 0.8
				end
				reason = "Undercutting market by "..by
			end
		--then matching current
		elseif frame.options.matchmy:GetChecked() then
			if matchBuy and matchBuy > 0 then
				buy = matchBuy
				if matchBid and matchBid > 0 and matchBid <= matchBuy then
					bid = matchBid
				else
					bid = buy * 0.8
				end
				reason = "Matching your prices"
			end
		end
		--if no buy price yet, look for marketprice
		if not buy then
			local market, seen = AucAdvanced.API.GetMarketValue(link)
			if market and (market > 0) and (seen > 5 or aSeen < 3) then
				buy = market
				bid = market * 0.8
				reason = "Using market value"
			end
		end
		--look for average of current competition
		if not buy and aveBuy and aveBuy > 0 then
			buy = aveBuy
			bid = buy * 0.8
			reason = "Using current market data"
		end
		--Vendor markup
		if not buy and GetSellValue then
			local vendor = GetSellValue(link)
			if vendor and vendor > 0 then
				buy = vendor * 3
				bid = buy * 0.8
				reason = "Marking up vendor"
			end
		end
	end
	if not buy then
		buy = 0
	end
	if not bid then
		bid = buy * 0.8
	end
	--multiply by stacksize
	bid = bid * stack
	buy = buy * stack
	--We give up
	if bid == 0 then
		bid = 1
		buy = 0
		reason = "Unable to calculate price" 
	end
	
	if (stack * num) > total then
		reason = "Error: You don't have that many"
	end
	bid, buy = ceil(tonumber(bid) or 1), ceil(tonumber(buy) or 0)

	MoneyInputFrame_ResetMoney(frame.minprice)
	MoneyInputFrame_SetCopper(frame.minprice, bid)
	frame.CurItem.bid = bid
	frame.CurItem.bidper = bid/stack

	MoneyInputFrame_ResetMoney(frame.buyout)
	MoneyInputFrame_SetCopper(frame.buyout, buy)
	frame.CurItem.buy = buy
	frame.CurItem.buyper = buy/stack

	frame.detail = { stack, bid, buy, reason, link }
	frame.err:SetText(reason)

	private.UpdateDisplay(reason)
end

--function runs when we're alerted to a possible change in one of the controls.
--we check if something is actually different, and if so, update.
function private.CheckUpdate()
	if not frame.CurItem.link then return end
	local buy = MoneyInputFrame_GetCopper(frame.buyout)
	local bid = MoneyInputFrame_GetCopper(frame.minprice)
	local stack = frame.stacks.size:GetNumber()
	local number = frame.stacks.num:GetNumber()
	local match = frame.options.matchmy:GetChecked()
	local undercut = frame.options.undercut:GetChecked()
	local remember = frame.options.remember:GetChecked()
	local duration = frame.duration.time.selected
	if frame.CurItem.buy ~= buy then --New Buyout manually entered
		frame.CurItem.buy = buy
		frame.CurItem.buyper = buy/(stack or 1)
		frame.CurItem.manual = true
		private.UpdateDisplay()
	elseif frame.CurItem.bid ~= bid then --New Bid manually entered
		frame.CurItem.bid = bid
		frame.CurItem.bidper = bid/(stack or 1)
		frame.CurItem.manual = true
		private.UpdateDisplay()
	elseif stack and stack > 0 and frame.CurItem.stack ~= stack then --new stack size entered
		frame.CurItem.stack = stack
		private.UpdatePricing()
	elseif number and number > 0 and frame.CurItem.number ~= number then --new number of stacks entered
		frame.CurItem.number = number
		private.UpdatePricing()
	elseif frame.CurItem.match ~= match then
		frame.CurItem.match = match
		if match then --turn off other checkboxes 
			frame.CurItem.manual = false
			frame.CurItem.undercut = nil
			frame.options.undercut:SetChecked(false)
			frame.CurItem.remember = nil
			frame.options.remember:SetChecked(false)
		end
		private.UpdatePricing()
	elseif frame.CurItem.undercut ~= undercut then
		frame.CurItem.undercut = undercut
		if undercut then --turn off other checkboxes 
			frame.CurItem.manual = false
			frame.CurItem.match = nil
			frame.options.matchmy:SetChecked(false)
			frame.CurItem.remember = nil
			frame.options.remember:SetChecked(false)
		end
		private.UpdatePricing()
	elseif frame.CurItem.duration ~= duration then
		frame.CurItem.duration = duration
		private.UpdatePricing()
	elseif frame.CurItem.remember ~= remember then
		frame.CurItem.manual = true
		frame.CurItem.remember = remember
		if remember then
			private.SaveConfig()
			frame.CurItem.match = nil
			frame.options.matchmy:SetChecked(false)
			frame.CurItem.undercut = nil
			frame.options.undercut:SetChecked(false)
		else
			private.RemoveConfig()
		end
		private.UpdatePricing()
	else return
	end
	if frame.CurItem.remember then
		private.SaveConfig()
	end
end

function private.IconClicked()
	local objType, _, itemLink = GetCursorInfo()
	local size
	if CursorHasItem() and frame.CursorItem then
		_, size = GetContainerItemInfo(frame.CursorItem.bag, frame.CursorItem.slot)
	end
	frame.CursorItem = nil
	ClearCursor()
	if objType ~= "item" then itemLink = nil end
	private.LoadItemLink(itemLink, size)
end

function private.LoadItemLink(itemLink, size)
	empty(frame.CurItem)
	if itemLink then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink)
		itemLink = AucAdvanced.SanitizeLink(itemLink)
		local itemCount = GetItemCount(itemLink)
		frame.CurItem.link = itemLink
		frame.CurItem.name = itemName
		frame.CurItem.count = itemCount
		frame.icon.itemLink = itemLink
		frame.icon:SetNormalTexture(itemTexture)
		private.SetIconCount(itemCount)

		frame.name:SetText(itemName)
		frame.name:SetTextColor(GetItemQualityColor(itemRarity))
	else
		frame.icon.itemLink = nil
		frame.icon:SetNormalTexture(nil)
		frame.icon.count:SetText("")
		frame.name:SetText("Drop item onto slot")
	end
	frame.info:SetText("To auction an item, drag it from your bag.")
	frame.err:SetText("-- No item selected --")
	frame.stacks.equals:SetText("= 0")
	private.ClearSetting()
	private.LoadConfig()

	if not frame.options.remember:GetChecked() then
		local uBid, uBuy = private.GetMyPrice(itemLink)
		if uBid and get("util.simpleauc.auto.match") then
			frame.options.matchmy:SetChecked(true)
			frame.options.undercut:SetChecked(false)
			frame.CurItem.match = true
			frame.CurItem.undercut = nil
		elseif get("util.simpleauc.auto.undercut") then
			frame.options.matchmy:SetChecked(false)
			frame.options.undercut:SetChecked(true)
			frame.CurItem.match = nil
			frame.CurItem.undercut = true
		end
	end

	
	if itemLink and size then
		frame.stacks.size:SetNumber(size)
	end
	--private.UpdatePricing()
end

function private.DoTooltip()
	if not frame.CurItem.link then return end
	GameTooltip:SetOwner(frame.icon, "ANCHOR_NONE")
	GameTooltip:SetHyperlink(frame.CurItem.link)
	AucAdvanced.ShowItemLink(GameTooltip, frame.CurItem.link, frame.CurItem.count)
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 10, 0)
end

function private.UndoTooltip()
	GameTooltip:Hide()
end

--we check for valuechanged on update,  so that multiple controls changing at once will only yield one check
function private.OnUpdate()
	if frame.CurItem.valuechanged then
		frame.CurItem.valuechanged = nil
		private.CheckUpdate()
	end
end

function private.LoadConfig()
	if not frame.CurItem.link then return end
	local id = private.SigFromLink(frame.CurItem.link)
	local settingstring = get("util.simpleauc."..private.realmKey.."."..id)
	if not settingstring then return end
	local bid, buy, duration, number, stack = strsplit(":", settingstring)
	bid = tonumber(bid)
	buy = tonumber(buy)
	duration = tonumber(duration)
	number = tonumber(number)
	stack = tonumber(stack)
	MoneyInputFrame_ResetMoney(frame.minprice)
	MoneyInputFrame_SetCopper(frame.minprice, bid)
	MoneyInputFrame_ResetMoney(frame.buyout)
	MoneyInputFrame_SetCopper(frame.buyout, buy)
	frame.stacks.size:SetNumber(stack)
	frame.stacks.num:SetNumber(number)
	frame.options.undercut:SetChecked(false)
	frame.options.matchmy:SetChecked(false)
	frame.options.remember:SetChecked(true)
	frame.duration.time.selected = duration
	for i, j in pairs(frame.duration.time.intervals) do
		if duration == j then
			frame.duration.time[i]:SetChecked(true)
		else
			frame.duration.time[i]:SetChecked(false)
		end
	end
	frame.CurItem.bid = bid
	frame.CurItem.bidper = bid/stack
	frame.CurItem.buy = buy
	frame.CurItem.buyper = buy/stack
	frame.CurItem.duration = duration
	frame.CurItem.number = number
	frame.CurItem.stack = stack
	frame.CurItem.match = nil
	frame.CurItem.undercut = nil
	frame.CurItem.remember = true
	frame.CurItem.manual = true
	private.UpdatePricing()
end

function private.RemoveConfig()
	if not frame.CurItem.link then return end
	local id = private.SigFromLink(frame.CurItem.link)
	set("util.simpleauc."..private.realmKey.."."..id, nil)
end

function private.SaveConfig()
	if not frame.CurItem.link then return end
	local id = private.SigFromLink(frame.CurItem.link)
	local settingstring = strjoin(":",
		tostring(frame.CurItem.bid),
		tostring(frame.CurItem.buy),
		tostring(frame.CurItem.duration),
		tostring(frame.CurItem.number),
		tostring(frame.CurItem.stack)
		)
	set("util.simpleauc."..private.realmKey.."."..id, settingstring)
end

function private.ClearSetting()
	frame.CurItem.bid = nil
	frame.CurItem.bidper = nil
	frame.CurItem.buy = nil
	frame.CurItem.buyper = nil
	frame.CurItem.stack = nil
	frame.CurItem.number = nil
	frame.CurItem.match = nil
	frame.CurItem.undercut = nil
	frame.CurItem.remember = nil
	frame.CurItem.manual = nil
	frame.CurItem.duration = nil
	MoneyInputFrame_ResetMoney(frame.minprice)
	MoneyInputFrame_ResetMoney(frame.buyout)
	frame.stacks.num:SetNumber(0)
	frame.stacks.size:SetNumber(0)

	local under, match, dur =
		get("util.simpleauc.auto.undercut"),
		get("util.simpleauc.auto.match"),
		get("util.simpleauc.auto.duration")
	if under then match = false end

	frame.options.matchmy:SetChecked(match)
	frame.options.undercut:SetChecked(under)
	frame.options.remember:SetChecked(false)
	frame.duration.time.selected = dur
	frame.duration.time[1]:SetChecked(dur == 12)
	frame.duration.time[2]:SetChecked(dur == 24)
	frame.duration.time[3]:SetChecked(dur == 48)
	private.UpdatePricing()
end

function private.PostAuction()
	if not frame.CurItem.link then
		print("Posting Failed: No Item Selected")
		return
	end
	local link = frame.CurItem.link
	local number = frame.CurItem.number
	local stack = frame.CurItem.stack
	local bid = frame.CurItem.bid
	local buy = frame.CurItem.buy
	local duration = frame.CurItem.duration or 48
	if frame.CurItem.count < (stack * number) then
		print("Posting Failed: Not enough items available")
		return
	end
	local sig = private.SigFromLink(link)
	print("Posting "..number.." stacks of "..stack.."x "..link.." at Bid:"..coins(bid)..", BO:"..coins(buy).." for "..duration.."h")
	AucAdvanced.Post.PostAuction(sig, stack, bid, buy, duration*60, number)
end

function private.CreateFrames()
	if frame then return end

	local SelectBox = LibStub:GetLibrary("SelectBox")
	local ScrollSheet = LibStub:GetLibrary("ScrollSheet")

	frame = CreateFrame("Frame", "AucAdvSimpFrame", AuctionFrame)
	private.frame = frame
	private.realmKey, private.realm = AucAdvanced.GetFaction()
	local DiffFromModel = 0
	local MatchString = ""
	frame.list = {}
	frame.cache = {}
	frame.CurItem = {}
	frame.detail = {0,0,0,"",""}
	Stubby.RegisterFunctionHook("PickupContainerItem", 200, private.postPickupContainerItemHook)

	frame:SetParent(AuctionFrame)
	frame:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT")
	frame:SetPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT")
	frame:SetScript("OnUpdate", private.OnUpdate)

	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.title:SetPoint("TOP", frame,  "TOP", 0, -20)
	frame.title:SetText("Simple Auction - Simplified auction posting interface.")

	frame.slot = frame:CreateTexture(nil, "BORDER")
	frame.slot:SetPoint("TOPLEFT", frame, "TOPLEFT", 80, -45)
	frame.slot:SetWidth(50)
	frame.slot:SetHeight(50)
	frame.slot:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	frame.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")

	frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.name:SetPoint("TOPLEFT", frame.slot, "TOPRIGHT", 10, -2)
	frame.name:SetText("Drop item onto slot")

	frame.info = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.info:SetPoint("TOPLEFT", frame.name, "BOTTOMLEFT", 0, -3)
	frame.info:SetText("To auction an item, drag it from your bag.")

	frame.err = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.err:SetPoint("TOPLEFT", frame.info, "BOTTOMLEFT", 0, 0)
	frame.err:SetTextColor(1,0.2,0,1)
	frame.err:SetText("-- No item selected --")

	frame.icon = CreateFrame("Button", nil, frame)
	frame.icon:SetPoint("TOPLEFT", frame.slot, "TOPLEFT", 3, -3)
	frame.icon:SetWidth(42)
	frame.icon:SetHeight(42)
	frame.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	frame.icon:SetScript("OnClick", private.IconClicked)
	frame.icon:SetScript("OnReceiveDrag", private.IconClicked)
	frame.icon:SetScript("OnEnter", private.DoTooltip)
	frame.icon:SetScript("OnLeave", private.UndoTooltip)

	local numberFont = CreateFont("AucAdvSimpleNumberFontLarge")
	numberFont:CopyFontObject(GameFontHighlight)
	numberFont.font = numberFont:GetFont()
	numberFont:SetFont(numberFont.font, 12, "OUTLINE")
	numberFont:SetShadowColor(0,0,0)
	numberFont:SetShadowOffset(3,-2)

	frame.icon.count = frame.icon:CreateFontString(nil, "OVERLAY", "AucAdvSimpleNumberFontLarge")
	frame.icon.count:SetPoint("BOTTOMLEFT", frame.icon, "BOTTOMLEFT", 3, 5)

	frame.minprice = CreateFrame("Frame", "AucAdvSimpFrameStart", frame, "MoneyInputFrameTemplate")
	frame.minprice.isMoneyFrame = true
	frame.minprice:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -120)
	MoneyInputFrame_SetOnValueChangedFunc(frame.minprice, function()
			frame.CurItem.valuechanged = true
		end)
	frame.minprice.label = frame.minprice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.minprice.label:SetPoint("BOTTOMLEFT", frame.minprice, "TOPLEFT", 0, 0)
	frame.minprice.label:SetText("Starting price:")
	AucAdvSimpFrameStartGold:SetWidth(50)

	frame.buyout = CreateFrame("Frame", "AucAdvSimpFrameBuyout", frame, "MoneyInputFrameTemplate")
	frame.buyout.isMoneyFrame = true
	frame.buyout:SetPoint("TOPLEFT", frame.minprice, "BOTTOMLEFT", 0, -20)
	MoneyInputFrame_SetOnValueChangedFunc(frame.buyout, function()
			frame.CurItem.valuechanged = true
		end)
	frame.buyout.label = frame.buyout:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.buyout.label:SetPoint("BOTTOMLEFT", frame.buyout, "TOPLEFT", 0, 0)
	frame.buyout.label:SetText("Buyout price:")
	AucAdvSimpFrameBuyoutGold:SetWidth(50)

	frame.duration = CreateFrame("Frame", "AucAdvSimpFrameDuration", frame)
	frame.duration:SetPoint("TOPLEFT", frame.buyout, "BOTTOMLEFT", 0, -20)
	frame.duration:SetWidth(140)
	frame.duration:SetHeight(20)
	frame.duration.label = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.duration.label:SetPoint("BOTTOMLEFT", frame.duration, "TOPLEFT", 0, 0)
	frame.duration.label:SetText("Duration:");
	
	frame.duration.time = {
		intervals = {12, 24, 48},
		selected = 48,
		OnClick = function (obj, ...)
			frame.CurItem.valuechanged = true
			local self = frame.duration.time
			for pos, dur in ipairs(self.intervals) do
				if obj == self[pos] then
					self.selected = dur
					self[pos]:SetChecked(true)
				else
					self[pos]:SetChecked(false)
				end
			end
		end,
	}
	local t = frame.duration.time
	for pos, dur in ipairs(t.intervals) do
		t[pos] = CreateFrame("CheckButton", "AucAdvSimpFrameDuration"..dur, frame.duration, "OptionsCheckButtonTemplate")
		t[pos]:SetPoint("TOPLEFT", frame.duration, "TOPLEFT", (pos-1)*53,0)
		t[pos]:SetHitRectInsets(-1, -25, -1, -1)
		t[pos].label = t[pos]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		t[pos].label:SetPoint("LEFT", t[pos], "RIGHT", 0, 0)
		t[pos].label:SetText(dur.."h")
		t[pos].dur = dur
		t[pos]:SetScript("OnClick", t.OnClick)
		if dur == t.selected then
			t[pos]:SetChecked(true)
		else
			t[pos]:SetChecked(false)
		end
	end

	frame.stacks = CreateFrame("Frame", "AucAdvSimpFrameStacks", frame)
	frame.stacks:SetPoint("TOPLEFT", frame.duration, "BOTTOMLEFT", 0, -20)
	frame.stacks:SetWidth(140)
	frame.stacks:SetHeight(20)
	frame.stacks.label = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.stacks.label:SetPoint("BOTTOMLEFT", frame.stacks, "TOPLEFT", 0, 0)
	frame.stacks.label:SetText("Stacks: (number x size)");

	frame.stacks.num = CreateFrame("EditBox", "AucAdvSimpFrameStackNum", frame.stacks, "InputBoxTemplate")
	frame.stacks.num:SetPoint("TOPLEFT", frame.stacks, "TOPLEFT", 5, 0)
	frame.stacks.num:SetAutoFocus(false)
	frame.stacks.num:SetHeight(18)
	frame.stacks.num:SetWidth(40)
	frame.stacks.num:SetNumeric(true)
	frame.stacks.num:SetScript("OnTextChanged", function() frame.CurItem.valuechanged = true end)

	frame.stacks.mult = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.stacks.mult:SetPoint("BOTTOMLEFT", frame.stacks.num, "BOTTOMRIGHT", 5, 0)
	frame.stacks.mult:SetText("x")

	frame.stacks.size = CreateFrame("EditBox", "AucAdvSimpFrameStackSize", frame.stacks, "InputBoxTemplate")
	frame.stacks.size:SetPoint("TOPLEFT", frame.stacks.num, "TOPRIGHT", 20, 0)
	frame.stacks.size:SetAutoFocus(false)
	frame.stacks.size:SetHeight(18)
	frame.stacks.size:SetWidth(30)
	frame.stacks.size:SetNumeric(true)
	frame.stacks.size:SetScript("OnTextChanged", function() frame.CurItem.valuechanged = true end)

	frame.stacks.equals = frame.duration:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.stacks.equals:SetPoint("BOTTOMLEFT", frame.stacks.size, "BOTTOMRIGHT", 5, 0)
	frame.stacks.equals:SetText("= 0")

	frame.options = CreateFrame("Frame", "AucAdvSimpFrameOptions", frame)
	frame.options:SetPoint("TOPLEFT", frame.stacks, "BOTTOMLEFT", 0, -20)
	frame.options:SetWidth(140)
	frame.options:SetHeight(300)
	frame.options.label = frame.options:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.options.label:SetPoint("BOTTOMLEFT", frame.options, "TOPLEFT", 0, 0)
	frame.options.label:SetText("Options:")

	frame.create = CreateFrame("Button", "AucAdvSimpFrameCreate", frame, "OptionsButtonTemplate")
	frame.create:SetPoint("BOTTOMRIGHT", AuctionFrameMoneyFrame, "TOPRIGHT", 0, 10)
	frame.create:SetWidth(140)
	frame.create:SetText("Create Auction")
	frame.create:SetScript("OnClick", private.PostAuction)

	frame.clear = CreateFrame("Button", "AucAdvSimpFrameRemember", frame, "OptionsButtonTemplate")
	frame.clear:SetPoint("BOTTOMRIGHT", frame.create, "TOPRIGHT", 0, 5)
	frame.clear:SetWidth(140)
	frame.clear:SetText("Clear Setting")
	frame.clear:SetScript("OnClick", function() private.ClearSetting() private.RemoveConfig() end)

	MoneyInputFrame_SetPreviousFocus(frame.minprice, frame.stacks.size)
	MoneyInputFrame_SetNextFocus(frame.minprice, AucAdvSimpFrameBuyoutGold)
	MoneyInputFrame_SetPreviousFocus(frame.buyout, AucAdvSimpFrameStartCopper)
	MoneyInputFrame_SetNextFocus(frame.buyout, frame.stacks.num)
	private.SetPrevNext(frame.stacks.num, AucAdvSimpFrameBuyoutCopper, frame.stacks.size)
	private.SetPrevNext(frame.stacks.size, frame.stacks.num, AucAdvSimpFrameStartGold)
	
	function frame.options:AddOption(option, text)
		local item = CreateFrame("CheckButton", "AucAdvSimpFrameOption_"..option, self, "OptionsCheckButtonTemplate")
		if self.last then
			item:SetPoint("TOPLEFT", self.last, "BOTTOMLEFT", 0,7)
		else
			item:SetPoint("TOPLEFT", self, "TOPLEFT", 0,0)
		end
		self.last = item

		item:SetHitRectInsets(-1, -140, 3, 3)
		item:SetScript("OnClick", function() frame.CurItem.valuechanged = true end)


		item.label = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		item.label:SetPoint("LEFT", item, "RIGHT", 0, 0)
		item.label:SetText(text)

		self[option] = item
	end

	frame.options:AddOption("matchmy", "Match my current")
	frame.options:AddOption("undercut", "Undercut competitors")
	frame.options:AddOption("remember", "Remember fixed price")

	function frame.ClickBagHook(_,_,obj,button)
		if (not get("util.simpleauc.clickhook")) then return end
		local bag = this:GetParent():GetID()
		local slot = this:GetID()
		local link = GetContainerItemLink(bag, slot)
		local _, size = GetContainerItemInfo(bag, slot)
		if link then
			if (button == "LeftButton") and (IsAltKeyDown()) then
				private.LoadItemLink(link, size)

				if not private.clickdata then private.clickdata = {} end
				local last = private.clickdata
				local now = GetTime()
				if last[1] == bag and last[2] == slot and now - last[3] < 0.5 then
					-- Is a double click
					print("Auto auctioning double-alt-clicked item")
					if not frame.options.remember:GetChecked() then
						frame.options.undercut:SetChecked(true)
					end
					private.CheckUpdate()
					private.PostAuction()
				end
				last[1] = bag
				last[2] = slot
				last[3] = now
			end
		end
	end

	frame.tab = CreateFrame("Button", "AuctionFrameTabUtilSimple", AuctionFrame, "AuctionTabTemplate")
	frame.tab:SetText(TAB_NAME)
	frame.tab:Show()
	PanelTemplates_DeselectTab(frame.tab)
	AucAdvanced.AddTab(frame.tab, frame)

	function frame.tab.OnClick(_, _, index)
		if not index then index = this:GetID() end
		local tab = getglobal("AuctionFrameTab"..index)
		if (tab and tab:GetName() == "AuctionFrameTabUtilSimple") then
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft")
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top")
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight")
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft")
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot")
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotRight")
			AuctionFrameMoneyFrame:Show()
			frame:Show()
			AucAdvanced.Scan.GetImage()
			--frame.GenerateList(true)
		else
			AuctionFrameMoneyFrame:Show()
			frame:Hide()
		end
	end

	function frame.ClickAnythingHook(link)
		if not get("util.simpleauc.clickhookany") then return end
		-- Ugly: we assume arg1/arg3 is still set from the original OnClick/OnHyperLinkClick handler
		if (arg1=="LeftButton" or arg3=="LeftButton") and IsAltKeyDown() then
			frame.SelectItem(nil, nil, link)
		end
	end

	
	frame.imageview = CreateFrame("Frame", nil, frame)
	frame.imageview:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	frame.imageview:SetBackdropColor(0, 0, 0, 1)
	frame.imageview:SetPoint("TOPLEFT", frame, "TOPLEFT", 185, -100)
	frame.imageview:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, 0)
	frame.imageview:SetPoint("BOTTOM", frame, "BOTTOM", 0, 35)
	--records the column width changes
	--store width by header name, that way if column reorginizing is added we apply size to proper column
	function private.onResize(self, column, width)
		if not width then
			set("util.simpleauc.columnwidth."..self.labels[column]:GetText(), "default") --reset column if no width is passed. We use CTRL+rightclick to reset column
			self.labels[column].button:SetWidth(get("util.simpleauc.columnwidth."..self.labels[column]:GetText()))
		else
			set("util.simpleauc.columnwidth."..self.labels[column]:GetText(), width)
		end
	end
	function private.onClick(button, row, index)
		
	end
	frame.imageview.sheet = ScrollSheet:Create(frame.imageview, {
		{ "Seller", "TEXT", get("util.simpleauc.columnwidth.Seller")}, --89
		{ "Left",   "INT",  get("util.simpleauc.columnwidth.Left")}, --32
		{ "Stk",    "INT",  get("util.simpleauc.columnwidth.Stk")}, --32
		{ "Min/ea", "COIN", get("util.simpleauc.columnwidth.Min/ea"), { DESCENDING=true } }, --65
		{ "Cur/ea", "COIN", get("util.simpleauc.columnwidth.Cur/ea"), { DESCENDING=true } }, --65
		{ "Buy/ea", "COIN", get("util.simpleauc.columnwidth.Buy/ea"), { DESCENDING=true, DEFAULT=true } }, --65
		{ "MinBid", "COIN", get("util.simpleauc.columnwidth.MinBid"), { DESCENDING=true } }, --76
		{ "CurBid", "COIN", get("util.simpleauc.columnwidth.CurBid"), { DESCENDING=true } }, --76
		{ "Buyout", "COIN", get("util.simpleauc.columnwidth.Buyout"), { DESCENDING=true } }, --80
		{ "", "TEXT", get("util.simpleauc.columnwidth.BLANK")}, --Hidden column to carry the link --0
	}, nil, nil, private.onClick, private.onResize, nil)
	
	frame.config = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	frame.config:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -25, -13)
	frame.config:SetText("Configure")
	frame.config:SetScript("OnClick", function()
		AucAdvanced.Settings.Show()
		private.gui:ActivateTab(private.guiId)
	end)

	frame.scanbutton = CreateFrame("Button", "AucAdvScanButton", AuctionFrameBrowse, "OptionsButtonTemplate")
	frame.scanbutton:SetText("Scan")
	frame.scanbutton:SetParent("AuctionFrameBrowse")
	frame.scanbutton:SetPoint("LEFT", "AuctionFrameMoneyFrame", "RIGHT", 5,0)
	frame.scanbutton:SetScript("OnClick", function()
		if not AucAdvanced.Scan.IsScanning() then
			AucAdvanced.Scan.StartScan("", "", "", nil, nil, nil, nil, nil)
		end
	end)

	if get("util.simpleauc.scanbutton") then
		frame.scanbutton:Show()
	else
		frame.scanbutton:Hide()
	end

	Stubby.RegisterFunctionHook("ContainerFrameItemButton_OnModifiedClick", -300, frame.ClickBagHook)
	hooksecurefunc("AuctionFrameTab_OnClick", frame.tab.OnClick)

	hooksecurefunc("HandleModifiedItemClick", frame.ClickAnythingHook)

	function frame:OnEvent(event, ...)
		if event == "BAG_UPDATE" then
			private.UpdateDisplay()
		end
	end

	frame:SetScript("OnEvent", frame.OnEvent)
	frame:RegisterEvent("BAG_UPDATE")
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
