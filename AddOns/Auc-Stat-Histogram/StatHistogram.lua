--[[
	Auctioneer Advanced - Histogram Statistics module
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: StatHistogram.lua 3812 2008-11-11 06:36:16Z Shirik $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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

local libType, libName = "Stat", "Histogram"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill, _TRANS = AucAdvanced.GetModuleLocals()

local data
local totaldata
local sessionseen = {}
local stattable = {}
local totalstattable = {}
			for i = 1, 300 do totalstattable[i] = 0 end
local PDcurve = {}
local newstats = {}
local array = {}
local frame
local pricecache

function lib.CommandHandler(command, ...)
	if (not data) then private.makeData() end
	local myFaction = AucAdvanced.GetFaction()
	if (command == "help") then
		print(_TRANS('Help for Auctioneer Advanced - Histogram') )
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line,_TRANS( 'help}} - this Histogram help') )
		print(line, _TRANS('clear}} - clear current') , myFaction, libName, _TRANS('price database') )
	elseif (command == "clear") then
		print(_TRANS('Clearing Histogram stats for {{') , myFaction, "}}")
		data[myFaction] = nil
	end
end

function lib.Processor(callbackType, ...)
	if (not data) then private.makeData() end
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	elseif (callbackType == "scanstats") then
		pricecache = nil
	end
end

function private.GetPriceData()
	if not stattable["count"] then
		debugPrint("GetPriceData: No stattable", libType.."-"..libName)
		return
	end
	local median = 0
	local Qone = 0
	local Qthree = 0
	local percent40, percent30 = 0, 0
	local count = stattable["count"]
	local refactored = false
	debugPrint("getPricedata: "..tostring(stattable["count"]), libType.."-"..libName)
	local recount = 0
	--now find the Q1, median, and Q3 values
	if stattable["min"] == stattable["max"] then
		--no need to do fancy median calculations
		median = stattable["min"]*stattable["step"]
		--count = value at the only index we have
		count = stattable[stattable["min"]]
		stattable["count"] = count
	else
		for i = stattable["min"], stattable["max"] do
			recount = recount + (stattable[i] or 0)
			if Qone == 0 and count > 4 then --Q1 is meaningless with very little data
				if recount >= count/4 then
					Qone = i*stattable["step"]
				end
			end
			if percent30 == 0 then
				if recount >= count*0.3 then
					percent30 = i*stattable["step"]
				end
			end
			if percent40 == 0 then
				if recount >= count*0.4 then
					percent40 = i*stattable["step"]
				end
			end
			if median == 0 then
				if recount >= count/2 then
					median = i*stattable["step"]
				end
			end
			if Qthree == 0 and count > 4 then--Q3 is meaningless with very little data
				if recount >= count * 3/4 then
					Qthree = i*stattable["step"]
				end
			end
		end
		if count ~= recount then
			count = recount --We've just rechecked the count, so save the correct value
			stattable["count"] = count
			refactored = true
		end
	end
	local step = stattable["step"]
	if count > 20 then --we've seen enough to get a fairly decent price to base the precision on
		if (step > (median/85)) and (step > 1) then
			private.refactor(median*3, 300)
			refactored = true
		elseif step < (median/115) then
			private.refactor(median*3, 300)
			refactored = true
		end
	end
	return median, Qone, Qthree, step, count, refactored, percent40, percent30
end

function lib.GetPrice(link, faction)
	if not get("stat.histogram.enable") then return end
	empty(stattable)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end
	if (not data[faction]) or (not data[faction][itemId]) or (not data[faction][itemId][property]) then
		debugPrint("GetPrice: No data", libType.."-"..libName)
		return
	end
	if pricecache and pricecache[faction] and pricecache[faction][itemId] and pricecache[faction][itemId][property] then
		local median, Qone, Qthree, step, count = strsplit(",", pricecache[faction][itemId][property])
		median, Qone, Qthree, step, count = tonumber(median), tonumber(Qone), tonumber(Qthree), tonumber(step), tonumber(count)
		return median, Qone, Qthree, step, count
	end
	private.UnpackStats(data[faction][itemId][property])
	local median, Qone, Qthree, step, count, refactored, percent40, percent30 = private.GetPriceData()
	if refactored then
		--data has been refactored, so we need to repack it
		data[faction][itemId][property] = private.PackStats()
		--get the updated data
		median, Qone, Qthree, step, count = private.GetPriceData()
	end
	--we're done with the data, so clear the table
	empty(stattable)
	if not pricecache then pricecache = {} end
	if not pricecache[faction] then pricecache[faction] = {} end
	if not pricecache[faction][itemId] then pricecache[faction][itemId] = {} end
	pricecache[faction][itemId][property] = strjoin(",", median or "", Qone or "", Qthree or "", step or "", count or "")
	return median, Qone, Qthree, step, count, percent40, percent30
end


function lib.GetPriceColumns()
	return "Median", "Q1", "Q3", "step", "Seen"
end

function lib.GetPriceArray(link, faction)
	if not get("stat.histogram.enable") then return end
	--make sure that array is empty
	empty(array)
	local median, Qone, Qthree, step, count = lib.GetPrice(link, faction)
	--these are the two values that GetMarketPrice cares about
	array.price = median
	array.seen = count
	--additional data
	array.Qone = Qone
	array.Qthree = Qthree
	array.step = step

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function private.ItemPDF(price)
	if not PDcurve["step"] then return 0 end
	local index = math.floor(price/PDcurve["step"])
	if (index >= PDcurve["min"]) and (index <= PDcurve["max"]) then
		return PDcurve[index]
	else
		return 0
	end
end

function lib.GetItemPDF(link, faction)
	if not get("stat.histogram.enable") then return end
	empty(PDcurve)
	empty(stattable)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end
	if not data[faction] then return end
	if not data[faction][itemId] then return end
	if not data[faction][itemId][property] then return end
	local median, Qone, Qthree, step, count, refactored
	if pricecache and pricecache[faction] and pricecache[faction][itemId] and pricecache[faction][itemId][property] then
		median, Qone, Qthree, step, count = strsplit(",", pricecache[faction][itemId][property])
		median, Qone, Qthree, step, count = tonumber(median), tonumber(Qone), tonumber(Qthree), tonumber(step), tonumber(count)
	end

	private.UnpackStats(data[faction][itemId][property])
	if not count or count == 0 then
		median, Qone, Qthree, step, count, refactored = private.GetPriceData()
	end
	if refactored then
		--data has been refactored, so we need to repack it
		data[faction][itemId][property] = private.PackStats()
		--get the updated data
		median, Qone, Qthree, step, count = private.GetPriceData()
	end
	if not count or count == 0 then
		return
	end
	
	if not pricecache then pricecache = {} end
	if not pricecache[faction] then pricecache[faction] = {} end
	if not pricecache[faction][itemId] then pricecache[faction][itemId] = {} end
	pricecache[faction][itemId][property] = strjoin(",", median or "", Qone or "", Qthree or "", step or "", count or "")
	
	local curcount = 0
	local area = 0
	local targetarea = math.min(1, count/30) --if count is less than thirty, we're not very sure about the price

	PDcurve["step"] = step
	PDcurve["min"] = stattable["min"]-1
	PDcurve["max"] = stattable["max"]+1

	for i = stattable["min"], stattable["max"] do
		curcount = curcount + stattable[i]
		if count == stattable[i] then
			PDcurve[i] = 1
		else
			PDcurve[i] = 1-(math.abs(2*curcount - count)/count)
		end
		area = area + step*PDcurve[i]
	end

	local areamultiplier = 1
	if area > 0 then
		areamultiplier = targetarea/area
	end
	for i = PDcurve["min"], PDcurve["max"] do
		PDcurve[i]= (PDcurve[i] or 0) * areamultiplier
	end
	return private.ItemPDF, PDcurve["min"]*PDcurve["step"], PDcurve["max"]*PDcurve["step"], targetarea
end

lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	if not get("stat.histogram.enable") then return end
	if (not data) then private.makeData() end

	-- This function is responsible for processing and storing the stats after each scan
	-- Note: itemData gets reused over and over again, so do not make changes to it, or use
	-- it in places where you rely on it. Make a deep copy of it if you need it after this
	-- function returns.

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	if (itemData.stackSize > 1) then
		buyout = buyout/itemData.stackSize
	end
	local priceindex

	-- Get the signature of this item and find it's stats.
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(itemData.link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end
	empty(stattable)
	local faction = AucAdvanced.GetFaction()
	if not data[faction] then data[faction] = {} end
	if not data[faction][itemId] then data[faction][itemId] = {} end
	if data[faction][itemId][property] then
		private.UnpackStats(data[faction][itemId][property])
	end
	if not stattable["count"] then
		--start out with first 20 prices pushing max to 100.  This should help prevent losing data due to the first price being way too low
		--also keeps data small initially, as we don't need extremely accurate prices with that little data
		stattable["step"] = math.ceil(buyout / 100)
		stattable["count"] = 0
	end
	priceindex = math.ceil(buyout / stattable["step"])
	if stattable["count"] <= 20 then
		stattable["count"] = stattable["count"] + 1
		--get the refactoring out of the way first, because we're not capping the price yet
		--failure to do this now can cause major trouble in the form of massive tables
		if priceindex > 100 then
			private.refactor(buyout, 100)
			priceindex = 100
		end
		if not stattable["min"] then
			stattable["min"] = priceindex
			stattable["max"] = priceindex
			stattable[priceindex] = 0
		elseif stattable["min"] > priceindex then
			for i = priceindex, (stattable["min"]-1) do
				stattable[i] = 0
			end
			stattable["min"] = priceindex
		end
		if not stattable[priceindex] then stattable[priceindex] = 0 end
		stattable[priceindex] = stattable[priceindex] + 1
		data[faction][itemId][property] = private.PackStats()
	elseif priceindex <= 300 then --we don't want prices too high: they'll bloat the data.  If range needs to go higher, we'll refactor later
		stattable["count"] = stattable["count"] + 1
		if not stattable["min"] then --first time we've seen this
			stattable["min"] = priceindex
			stattable["max"] = priceindex
			stattable[priceindex] = 0
		elseif stattable["min"] > priceindex then
			for i = priceindex, (stattable["min"]-1) do
				stattable[i] = 0
			end
			stattable["min"] = priceindex
		elseif stattable["max"] < priceindex then
			for i = (stattable["max"]+1),priceindex do
				stattable[i] = 0
			end
			stattable["max"] = priceindex
		end
		if not stattable[priceindex] then stattable[priceindex] = 0 end
		stattable[priceindex] = stattable[priceindex] + 1
		data[faction][itemId][property] = private.PackStats()
	end
	empty(stattable)
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")

	gui:AddHelp(id, "what histogram stats",
		_TRANS('What are Histogram stats?') ,
		_TRANS('Histogram stats record a histogram of past prices.') )
	gui:AddHelp(id, "what advantages",
		_TRANS('What advantages does Histogram have?') ,
		_TRANS('Histogram stats don\'t have a limitation to how many, ') ..
		_TRANS('or how long, it can keep data, so it can keep track of high-volume items well') )
	gui:AddHelp(id, "what disadvantage",
		_TRANS('What disadvantages does Histogram have?') ,
		_TRANS('Histogram rounds prices slightly to help store them, so there is a slight precision loss.') ..
		_TRANS('  However, it is precise to 1/250th of market price. (an item with market price 250g will have') ..
		_TRANS(' prices stored to the nearest 1g)') )
	gui:AddHelp(id, "what median",
		_TRANS('What is the median?') ,
		_TRANS('The median value is the value where half of the prices seen are above, and half are below.') )
	gui:AddHelp(id, "what IQR",
		_TRANS('What is the IQR?') ,
		_TRANS('The IQR is a measure of spread.  The middle half of the prices seen is confined with the range of IQR.') ..
		_TRANS('  An item with median 100g, and IQR 10g, has very consistent data.  If the IQR was 100g, the prices ') ..
		_TRANS('are all over the place.') )

	frame = gui.tabs[id].content
	private.frame = frame
	
	frame.slot = frame:CreateTexture(nil, "BORDER")
	frame.slot:SetDrawLayer("Artwork") -- or the border shades it
	frame.slot:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -200)
	frame.slot:SetWidth(45)
	frame.slot:SetHeight(45)
	frame.slot:SetTexCoord(0.17, 0.83, 0.17, 0.83)
	frame.slot:SetTexture("Interface\\Buttons\\UI-EmptySlot")
	function frame.IconClicked()
		local objtype, _, link = GetCursorInfo()
		ClearCursor()
		if objtype == "item" then
			lib.SetWorkingItem(link)
		else
			lib.SetWorkingItem()
		end
	end
	function frame.ClickHook(link)
		if not frame.slot:IsVisible() then return end
		lib.SetWorkingItem(link)
	end
	hooksecurefunc("HandleModifiedItemClick", frame.ClickHook)
	frame.icon = CreateFrame("Button", nil, frame)
	frame.icon:SetPoint("TOPLEFT", frame.slot, "TOPLEFT", 2, -2)
	frame.icon:SetPoint("BOTTOMRIGHT", frame.slot, "BOTTOMRIGHT", -2, 2)
	frame.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp")
	frame.icon:SetScript("OnClick", frame.IconClicked)
	frame.icon:SetScript("OnReceiveDrag", frame.IconClicked)
	frame.icon:SetScript("OnEnter", function() --set mouseover tooltip
			if not frame.link then return end
			GameTooltip:SetOwner(frame.icon, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetHyperlink(frame.link)
		end)
	frame.icon:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.name:SetPoint("TOPLEFT", frame.slot, "TOPRIGHT", 5,-2)
	frame.name:SetPoint("RIGHT", frame, "RIGHT", -15)
	frame.name:SetHeight(20)
	frame.name:SetJustifyH("LEFT")
	frame.name:SetJustifyV("TOP")
	frame.name:SetText("Insert or Alt-Click Item to start")
	frame.name:SetTextColor(0.5, 0.5, 0.7)

	frame.bargraph = CreateFrame("Frame", nil, frame)
	frame.bargraph:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -250)
	frame.bargraph:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -250)
	frame.bargraph:SetHeight(300)
	frame.bargraph:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame.bargraph:SetBackdropColor(0, 0, 0.0, 0.5)
	frame.bargraph.bars = {}
	frame.bargraph.pdf = {}
	frame.bargraph.max = 100
	local graphwidth = frame.bargraph:GetWidth()-10
	local graphheight = frame.bargraph:GetHeight()-10
	for i = 1, 300 do
		frame.bargraph.bars[i] = frame.bargraph:CreateTexture(nil)
		local bar = frame.bargraph.bars[i]
		bar:SetPoint("BOTTOMLEFT", frame.bargraph, "BOTTOMLEFT", (graphwidth*(i-1)/300)+5, 5)
		bar:SetWidth(graphwidth/300)
		bar:SetTexture(0.2, 0.8, 0.2)
		function bar:SetValue(value)
			if value == 0 then value = 0.001 end
			self:SetHeight((self:GetParent():GetHeight()-20)*value)
		end
		bar:SetValue(0)
	end
	for i = 1, 300 do
		frame.bargraph.pdf[i] = frame.bargraph:CreateTexture(nil)
		local pdf = frame.bargraph.pdf[i]
		pdf.offset = (graphwidth*(i-1)/300)+5
		pdf:SetPoint("BOTTOMLEFT", frame.bargraph, "BOTTOMLEFT", pdf.offset, 50)
		pdf:SetWidth(graphwidth/300)
		pdf:SetHeight(5)
		pdf:SetTexture(.2, .2, 0.8, .6)
		function pdf:SetValue(value)
			local bottom = (self:GetParent():GetHeight()-20)*value
			self:SetPoint("BOTTOMLEFT", frame.bargraph, "BOTTOMLEFT", self.offset, bottom)
		end
		pdf:SetValue(0)
	end

	frame.key = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.key:SetPoint("BOTTOMRIGHT", frame.bargraph, "TOPRIGHT", 0, 2)
	frame.key:SetPoint("TOPLEFT", frame.bargraph, "TOPLEFT", 5, 22)
	frame.key:SetJustifyH("RIGHT")
	frame.key:SetJustifyV("TOP")
	frame.key:SetText("|cff3fff3fRaw Data   |cffff3f3fMedian   |cff3f3fffPrice Probability")
	
	frame.med = frame.bargraph:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.med:SetPoint("TOP", frame.bargraph, "BOTTOM", -50, -10)
	frame.med:SetPoint("BOTTOM", frame.bargraph, "BOTTOM", -50, -25)
	frame.med:SetWidth(150)

	frame.max = frame.bargraph:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.max:SetPoint("TOPRIGHT", frame.bargraph, "BOTTOMRIGHT", 0, -10)
	frame.max:SetPoint("BOTTOMLEFT", frame.bargraph, "BOTTOMRIGHT", -150, -25)
	
	
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    _TRANS('Histogram options') )
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.histogram.enable", _TRANS('Enable Histogram Stats') )
	gui:AddTip(id, _TRANS('Allow Histogram to gather and return price data') )
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.histogram.tooltip", _TRANS('Show Histogram stats in the tooltips?') )
	gui:AddTip(id, _TRANS('Toggle display of stats from the Histogram module on or off') )
	gui:AddControl(id, "Checkbox",   0, 2, "stat.histogram.median", _TRANS('Display Median') )
	gui:AddTip(id, _TRANS('Toggle display of \'Median\' calculation in tooltips on or off') )
	gui:AddControl(id, "Checkbox",   0, 2, "stat.histogram.iqr", _TRANS('Display IQR') )
	gui:AddTip(id, _TRANS('Toggle display of \'IQR\' calculation in tooltips on or off.  See help for further explanation.') )
	gui:AddControl(id, "Checkbox",   0, 2, "stat.histogram.precision", _TRANS('Display Precision') )
	gui:AddTip(id, _TRANS('Toggle display of \'precision\' calculation in tooltips on or off') )
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.histogram.quantmul", _TRANS('Multiply by Stack Size') )
	gui:AddTip(id, _TRANS('Multiplies by current Stack Size if on') )
	
	gui:AddControl(id, "Subhead",    0,    "Item Data Viewer")
	
end

function lib.SetWorkingItem(link)
	--clear the graph
	frame.name:SetText("Insert or Alt-Click Item to start")
	frame.icon:SetNormalTexture(nil) --set icon texture
	frame.link = nil
	for i = 1,300 do
		frame.bargraph.bars[i]:SetValue(0)
		frame.bargraph.bars[i]:SetTexture(0.2, 0.8, 0.2)
		frame.bargraph.pdf[i]:SetValue(0)
	end
	
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(link)
	if (linkType ~= "item") then return end
	local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(link)
	if not name or not texture then return end
	frame.name:SetText(link)
	frame.link = link
	frame.icon:SetNormalTexture(texture) --set icon texture
	
	empty(stattable)
	if (factor and factor ~= 0) then property = property.."x"..factor end

	local faction = AucAdvanced.GetFaction()
	if (not data[faction]) or (not data[faction][itemId]) or (not data[faction][itemId][property]) then
		debugPrint("GetPrice: No data", libType.."-"..libName)
		return
	end
	private.UnpackStats(data[faction][itemId][property])
	
	local maxvalue = 0
	local indexes = 0
	local count = stattable["count"]
	local recount = 0
	local median = 0
	for i = stattable["min"], stattable["max"] do
		indexes = indexes +1
		if stattable[i] > maxvalue then maxvalue = stattable[i] end
		recount = recount + stattable[i]
		if median == 0 then
			if recount >= count/2 then
				median = i
				frame.bargraph.bars[i]:SetTexture(0.8, 0.2, 0.2)
			end
		end
	end
	for i = stattable["min"], stattable["max"] do
		frame.bargraph.bars[i]:SetValue(stattable[i]/maxvalue)
	end
	
	--now show the PD curve
	empty(PDcurve)
	PDcurve["step"] = stattable["step"]
	PDcurve["min"] = stattable["min"]
	PDcurve["max"] = stattable["max"]
	local curcount = 0
	count = stattable["count"]
	maxvalue = 0
	for i = stattable["min"], stattable["max"] do
		curcount = curcount + stattable[i]
		if count == stattable[i] then
			PDcurve[i] = 1
		else
			PDcurve[i] = 1-(math.abs(2*curcount - count)/count)
		end
		if PDcurve[i] > maxvalue then
			maxvalue = PDcurve[i]
		end
	end
	for i = PDcurve["min"], PDcurve["max"] do
		PDcurve[i]= (PDcurve[i] or 0)
	end
	
	for i = 1,300 do
		if (i >= PDcurve["min"]) and (i <= PDcurve["max"]) then
			frame.bargraph.pdf[i]:SetValue(PDcurve[i])
		else
			frame.bargraph.pdf[i]:SetValue(0)
		end
	end

	frame.med:SetText("Median: "..AucAdvanced.Coins(median*stattable["step"], true))
	frame.max:SetText("Max: "..AucAdvanced.Coins(300*stattable["step"], true))
end

function lib.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost, ...)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.

	if not get("stat.histogram.tooltip") then return end

	local quantmul = get("stat.histogram.quantmul")
	if (not quantmul) or (not quantity) or (quantity < 1) then quantity = 1 end
	local median, Qone, Qthree, step, count, percent40, percent30 = lib.GetPrice(hyperlink)
	if not count then
		count = 0
	end
	if median then
		if quantity == 1 then
			tooltip:AddLine(libName.._TRANS(' prices: (seen ') ..tostring(count)..")")
		else
			tooltip:AddLine(libName.._TRANS(' prices x') ..tostring(quantity).._TRANS(': (seen ') ..tostring(count)..")")
		end
		local iqr = Qthree-Qone
		if get("stat.histogram.median") then
			tooltip:AddLine(_TRANS('  median:'), median*quantity)
			if quantity > 1 then
				tooltip:AddLine(_TRANS('   (or individually):'), median)
			end
		end
		if (iqr > 0) and (get("stat.histogram.iqr")) then
			tooltip:AddLine("  IQR:", iqr*quantity)
		end
		if get("stat.histogram.precision") then
		tooltip:AddLine(_TRANS('  precision:'), step*quantity)
		end
	end
end

function lib.OnLoad(addon)
	private.makeData()
	private.makeTotalData()
	AucAdvanced.Settings.SetDefault("stat.histogram.tooltip", false)
	AucAdvanced.Settings.SetDefault("stat.histogram.median", false)
	AucAdvanced.Settings.SetDefault("stat.histogram.iqr", true)
	AucAdvanced.Settings.SetDefault("stat.histogram.precision", false)
	AucAdvanced.Settings.SetDefault("stat.histogram.quantmul", true)
	AucAdvanced.Settings.SetDefault("stat.histogram.enable", true)
end

function lib.ClearItem(hyperlink, faction)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end
	if not data[faction] then return end
	if not data[faction][itemId] then return end
	data[faction][itemId][property] = nil
	print(libType.."-"..libName.._TRANS(': clearing data for ') ..hyperlink.._TRANS(' for ').."{{"..faction.."}}")
end

--[[ Local functions ]]--

function private.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
	--Forces all data to be refactored if the database hasn't been updated yet
	local VERSION = 2
	if (data["version"]) and (data["version"] >= VERSION) then return end
	local function findallprices()
		print("Auc-Stat-Histogram: Updating database.  Please be patient")
		local i = 1
		for faction, itemlist in pairs(data) do
			if type(itemlist) == "table" then
				for itemId, proplist in pairs(itemlist) do
					for prop, datastring in pairs(proplist) do
						i = i+1
						empty(stattable)
						private.UnpackStats(datastring)
						local _,_,_,_,_,refactored = private.GetPriceData()
						if refactored then
							data[faction][itemId][prop] = private.PackStats()
						end
						if i%5000 == 0 then
							coroutine.yield()
						end
					end
				end
			end
		end
		print("Auc-Stat-Histogram: Database is updated.  Thank You for your patience")
		data["version"] = VERSION
	end
	local co = coroutine.create(findallprices)
	coroutine.resume(co)
	local function onupdate()
		if coroutine.status(co) ~= "dead" then
			coroutine.resume(co)
		end
	end
	local onupdateframe = CreateFrame("Frame")
	onupdateframe:SetScript("OnUpdate", onupdate)
end

function private.makeData()
	if data then return end
	if (not AucAdvancedStatHistogramData) then AucAdvancedStatHistogramData = {} end
	data = AucAdvancedStatHistogramData
	private.DataLoaded()
end
function private.makeTotalData()
	if totaldata then return end
	AucAdvancedStatHistogramTotalData = ""
	totaldata = AucAdvancedStatHistogramTotalData
	--private.DataLoaded()
end

function private.UnpackStats(dataItem)
	empty(stattable)
	if dataItem then
		local firstvalue, maxvalue, step, count, newdataItem = strsplit(";",dataItem)
		if not newdataItem then
			debugPrint("Unpack: dataItem only 4 long", libType.."-"..libName)
			return
		end
		stattable["min"] = tonumber(firstvalue)
		stattable["max"] = tonumber(maxvalue)
		stattable["step"] = tonumber(step)
		stattable["count"] = tonumber(count)
		local index = stattable["min"]
		if not index then
			print(dataItem)
		end
		for n in newdataItem:gmatch("[0-9]+") do
			stattable[index] = tonumber(n)
			index = index + 1
		end
	else
		debugPrint("Unpack: No data passed", libType.."-"..libName)
	end
end

function private.PackStats()
	local tempstr = ""
	local datastr = ""
	local imin = stattable["min"]
	tempstr = strjoin(";",imin,stattable["max"], stattable["step"], stattable["count"])
		datastr = tostring(stattable[imin] or 0)--this gets rid of the string starting as ",1,0,0..."
	for i = imin+1,stattable["max"] do
		datastr = datastr..","..tostring(stattable[i] or 0)
	end
	tempstr = tempstr..";"..datastr
	return tempstr
end

--private.refactor(pmax, precision)
--pmax is the max for the distribution
--redistributes the price data so that pmax is at precision
--this does cause some loss of accuracy, but should only be necessary every once in a great while
--and increases future accuracy.
--If data points would end up having an index > 750, they get cut off.  They're more than 3x market price, and should not be taken into account anyway
--called by the GetPrice function when price is detected as being too far off an index of 250
--Also called when adding new data early on that would push the max up.
function private.refactor(pmax, precision)
	if type(stattable) ~= "table" or type(pmax)~="number" or pmax == 0 then
		return
	end
	empty(newstats)
	newstats["step"] = math.ceil(pmax/precision)
	local conversion = stattable["step"]/newstats["step"]
	newstats["min"] = math.ceil(conversion*stattable["min"])
	newstats["max"] = math.ceil(conversion*stattable["max"])
	local count = 0
	if newstats["max"] > 300 then
		--we need to crop off the top end
		newstats["max"] = 300
		stattable["max"] = math.floor(300/conversion)
	end
	for i = newstats["min"], newstats["max"] do
		newstats[i] = 0
	end
	for i = stattable["min"], stattable["max"] do
		local j = math.ceil(conversion*i)
		if not newstats[j] then newstats[j] = 0 end
		newstats[j]= newstats[j] + stattable[i]
		count = count + stattable[i]
	end
	empty(stattable)
	for i,j in pairs(newstats) do
		stattable[i] = j
	end
	stattable["count"] = count
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Stat-Histogram/StatHistogram.lua $", "$Rev: 3812 $")
