--[[
	Auctioneer Advanced - StatSimple
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: StatSimple.lua 3817 2008-11-12 18:48:59Z RockSlice $
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

local libType, libName = "Stat", "Simple"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill, _TRANS = AucAdvanced.GetModuleLocals()

-- Eliminate some global lookups
local data
local select = select;
local sqrt = sqrt;
local ipairs = ipairs;
local unpack = unpack;
local tinsert = table.insert;
local assert = assert;

function lib.CommandHandler(command, ...)
	local myFaction = AucAdvanced.GetFaction()
	if (command == "help") then
		print(_TRANS('SIMP_Help_SlashHelp1') ) --Help for Auctioneer Advanced - Simple
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, "help}} - ".._TRANS('SIMP_Help_SlashHelp2') ) --this Simple help
		print(line, "clear}} - ".._TRANS('SIMP_Help_SlashHelp3'):format(myFaction) ) --clear current %s Simple price database
		print(line, "push}} - ".._TRANS('SIMP_Help_SlashHelp4'):format(myFaction) ) --force the %s Simple daily stats to archive (start a new day)
	elseif (command == "clear") then
		print(_TRANS('SIMP_Help_SlashHelp5').." {{", myFaction, "}}") --Clearing Simple stats for
		private.ClearData()
	elseif (command == "push") then
		print(_TRANS('SIMP_Help_SlashHelp6'):format(myFaction) ) --Archiving {{%s}} daily stats and starting a new day
		private.PushStats(myFaction)
	end
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end


lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	if not AucAdvanced.Settings.GetSetting("stat.simple.enable") then return end
	-- This function is responsible for processing and storing the stats after each scan
	-- Note: itemData gets reused over and over again, so do not make changes to it, or use
	-- it in places where you rely on it. Make a deep copy of it if you need it after this
	-- function returns.

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	local buyoutper = ceil(buyout/itemData.stackSize)

	-- In this case, we're only interested in the initial create, other
	-- Get the signature of this item and find it's stats.
	local itemType, itemId, property, factor = AucAdvanced.DecodeLink(itemData.link)
	if (factor ~= 0) then property = property.."x"..factor end

	local data = private.GetPriceData()
	if not data.daily then data.daily = { created = time() } end
	if not data.daily[itemId] then data.daily[itemId] = "" end
	local stats = private.UnpackStats(data.daily[itemId])
	if not stats[property] then stats[property] = { 0, 0 , buyoutper } end
	if not stats[property][3] then stats[property][3] = buyoutper end
	stats[property][1] = stats[property][1] + buyout
	stats[property][2] = stats[property][2] + itemData.stackSize
	if stats[property][3] > buyoutper then stats[property][3] = buyoutper end
	data.daily[itemId] = private.PackStats(stats)
end

function lib.GetPrice(hyperlink, faction, realm)
	if not AucAdvanced.Settings.GetSetting("stat.simple.enable") then return end

	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end

	local data = private.GetPriceData(faction, realm)
    -- DevTools_Dump(data). Yeah, don't do that.
	if not data then return end

	local dayTotal, dayCount, dayAverage, minBuyout = 0,0,0,0
	local seenDays, seenCount, avg3, avg7, avg14, avgmins = 0,0,0,0,0,0
    -- Stddev calculations for market price
    local count, daysUsed, k, v = 0, 0, 0, 0 -- used to keep running track of which daily averages we have
    local dataset = {}

	if data.daily and data.daily[itemId] then
		local stats = private.UnpackStats(data.daily[itemId])
		if stats[property] then
			dayTotal, dayCount, minBuyout = unpack(stats[property])
			dayAverage = dayTotal/dayCount
			if not minBuyout then minBuyout = 0 end
			-- Stddev calculations for market price
    		tinsert(dataset,dayAverage)
    		daysUsed = 1
		end
	end
	if data.means and data.means[itemId] then
		local stats = private.UnpackStats(data.means[itemId])
		if stats[property] then
			seenDays, seenCount, avg3, avg7, avg14, avgmins = unpack(stats[property])
			if not avgmins then avgmins = 0 end
			-- Stddev calculations for market price
            if seenDays >= 3 then
                for count = 1, 3-daysUsed do
                    tinsert(dataset, avg3);
                end
                daysUsed = 3
            end
            if seenDays >= 7 then
                for count = 1, 7-daysUsed do
                    tinsert(dataset, avg7);
                end
                daysUsed = 7
            end
            if seenDays >= 14 then
                for count = 1, 14-daysUsed do
                    tinsert(dataset, avg14);
                end
                daysUsed = 14
            end
        end
	end
    local mean = 0
	if dataset and #dataset > 0 then
		mean = private.sum(unpack(dataset))/#dataset;
	end
    local variance = 0;
    for k,v in ipairs(dataset) do
        variance = variance + (mean - v)^2;
    end
    if #dataset == 1 then
        variance = 0
    else
        variance = variance/(#dataset-1)
    end

	return dayAverage, avg3, avg7, avg14, minBuyout, avgmins, false, dayTotal, dayCount, seenDays, seenCount, mean, sqrt(variance)
end

function lib.GetPriceColumns()
	return "Daily Avg", "3 Day Avg", "7 Day Avg", "14 Day Avg", "Min BO", "Avg MBO", false, "Daily Total", "Daily Count", "Seen Days", "Seen Count", "Mean", "StdDev"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	if not AucAdvanced.Settings.GetSetting("stat.simple.enable") then return end
	-- Clean out the old array
	empty(array)

	-- Get our statistics
	local dayAverage, avg3, avg7, avg14, minBuyout, avgmins, _, dayTotal, dayCount, seenDays, seenCount, mean, stddev = lib.GetPrice(hyperlink, faction, realm)

	--if nothing is returned, return nil
	if not dayCount then return end

	-- If reportsafe is on use the mean of all 14 day samples. Else use the "traditional" Simple values.
	if not AucAdvanced.Settings.GetSetting("stat.simple.reportsafe") then
	   if (avg3 and seenDays > 3) or dayCount == 0 then
		  array.price = avg3
	   elseif dayCount > 0 then
		  array.price = dayAverage
	   end
	else
	   array.price = mean
	end
	array.stddev = stddev
	array.seen = seenCount
	array.avgday = dayAverage
	array.avg3 = avg3
	array.avg7 = avg7
	array.avg14 = avg14
	array.mbo = minBuyout
	array.avgmins = avgmins
	array.daytotal = dayTotal
	array.daycount = dayCount
	array.seendays = seenDays



	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

local bellCurve = AucAdvanced.API.GenerateBellCurve();
-- Gets the PDF curve for a given item. This curve indicates
-- the probability of an item's mean price. Uses an estimation
-- of the normally distributed bell curve by performing
-- calculations on the daily, 3-day, 7-day, and 14-day averages
-- stored by SIMP
-- @param hyperlink The item to generate the PDF curve for
-- @param faction The faction key from which to look up the data
-- @param realm The realm from which to look up the data
-- @return The PDF for the requested item, or nil if no data is available
-- @return The lower limit of meaningful data for the PDF (determined
-- as the mean minus 5 standard deviations)
-- @return The upper limit of meaningful data for the PDF (determined
-- as the mean plus 5 standard deviations)
function lib.GetItemPDF(hyperlink, faction, realm)
    -- TODO: This is an estimate. Can we touch this up later? Especially the stddev==0 case

    if not AucAdvanced.Settings.GetSetting("stat.simple.enable") then return end
    if not AucAdvanced.Settings.GetSetting("stat.simple.enable") then return end
    -- Calculate the SE estimated standard deviation & mean
	local dayAverage, avg3, avg7, avg14, minBuyout, avgmins, _, dayTotal, dayCount, seenDays, seenCount, mean, stddev = lib.GetPrice(hyperlink, faction, realm)

    if seenCount == 0 or stddev ~= stddev or mean ~= mean or not mean or mean == 0 then
        return;                         -- No available data or cannot estimate
    end

    -- If the standard deviation is zero, we'll have some issues, so we'll estimate it by saying
    -- the std dev is 100% of the mean divided by square root of number of views
    if stddev == 0 then stddev = mean / sqrt(seenCount); end

    -- Calculate the lower and upper bounds as +/- 3 standard deviations
    local lower, upper = mean - 3*stddev, mean + 3*stddev;

    bellCurve:SetParameters(mean, stddev);
    return bellCurve, lower, upper;
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.simple.tooltip", false)
	AucAdvanced.Settings.SetDefault("stat.simple.avg3", false)
	AucAdvanced.Settings.SetDefault("stat.simple.avg7", false)
	AucAdvanced.Settings.SetDefault("stat.simple.avg14", false)
	AucAdvanced.Settings.SetDefault("stat.simple.minbuyout", true)
	AucAdvanced.Settings.SetDefault("stat.simple.avgmins", true)
	AucAdvanced.Settings.SetDefault("stat.simple.quantmul", true)
	AucAdvanced.Settings.SetDefault("stat.simple.enable", true)
end

local AAStatSimpleData

function lib.ClearItem(hyperlink, faction, realm)
	local linkType, itemID, property, factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then
		return
	end
	if (factor ~= 0) then property = property.."x"..factor end
	if not faction then faction = AucAdvanced.GetFaction() end
	if not realm then
		realm = GetRealmName()
	end
	if (not AAStatSimpleData) then private.LoadData() end
	print(_TRANS('SIMP_Help_SlashHelpClearingData'):format(libType, hyperlink, faction)) --%s - Simple: clearing data for %s for {{%s}}
	
	if (AAStatSimpleData.RealmData[realm] and AAStatSimpleData.RealmData[realm][faction]) then
		AAStatSimpleData.RealmData[realm][faction]["means"][itemID] = nil
		AAStatSimpleData.RealmData[realm][faction]["daily"][itemID] = nil
	end
end


AucAdvanced.Settings.SetDefault("stat.simple.tooltip", true)
AucAdvanced.Settings.SetDefault("stat.simple.quantmul", true)

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules" )

	gui:AddHelp(id, "what simple stats",
		_TRANS('SIMP_Help_SimpleStats') ,--What are simple stats?
		_TRANS('SIMP_Help_SimpleStatsAnswer') 
		)--Simple stats are the numbers that are generated by the Simple module, the Simple module averages all of the prices for items that it sees and provides moving 3, 7, and 14 day averages.  It also provides daily minimum buyout along with a running average minimum buyout within 10% variance.

	gui:AddHelp(id, "what moving day average",
		_TRANS('SIMP_Help_MovingAverage') , --What does \'moving day average\' mean?
		_TRANS('SIMP_Help_MovingAverageAnswer') --Moving average means that it places more value on yesterday\'s moving averagethan today\'s average.  The determined amount is then used for tomorrow\'s moving average calculation.
		)

	gui:AddHelp(id, "how day average calculated",
		_TRANS('SIMP_Help_HowAveragesCalculated') , --How is the moving day averages calculated exactly?
		_TRANS('SIMP_Help_HowAveragesCalculatedAnswer') --Todays Moving Average is ((X-1)*YesterdaysMovingAverage + TodaysAverage) / X, where X is the number of days (3,7, or 14).
		)

	gui:AddHelp(id, "no day saved",
		_TRANS('SIMP_Help_NoDaySaved') ,--So you aren't saving a day-to-day average?
		_TRANS('SIMP_Help_NoDaySaved') )--No, that would not only take up space, but heavy calculations on each auction house scan, and this is only a simple model.

	gui:AddHelp(id, "minimum buyout",
		_TRANS('SIMP_Help_MinimumBuyout') ,--Why do I need to know minimum buyout?
		_TRANS('SIMP_Help_MinimumBuyoutAnswer')--While some items will sell very well at average within 2 days, others may sell only if it is the lowest price listed.  This was an easy calculation to do, so it was put in this module.
		)

	gui:AddHelp(id, "average minimum buyout",
		_TRANS('SIMP_Help_AverageMinimumBuyout') ,--What's the point in an average minimum buyout?
		_TRANS('SIMP_Help_AverageMinimumBuyoutAnswer')--This way you know how good a market is dealing.  If the MBO (minimum buyout) is bigger than the average MBO, then it\'s usually a good time to sell, and if the average MBO is greater than the MBO, then it\'s a good time to buy. 
		)

	gui:AddHelp(id, "average minimum buyout variance",
		_TRANS('SIMP_Help_MinimumBuyoutVariance') ,--What\'s the \'10% variance\' mentioned earlier for?
		_TRANS('SIMP_Help_MinimumBuyoutVarianceAnswer')--If the current MBO is inside a 10% range of the running average, the current MBO is averaged in to the running average at 50% (normal).  If the current MBO is outside the 10% range, the current MBO will only be averaged in at a 12.5% rate. 
		)

	gui:AddHelp(id, "why have variance",
		_TRANS('SIMP_Help_WhyVariance') ,--What\'s the point of a variance on minimum buyout?
		_TRANS('SIMP_Help_WhyVarianceAnswer') --Because some people put their items on the market for rediculous price (too low or too high), so this helps keep the average from getting out of hand.
		)

	gui:AddHelp(id, "why multiply stack size simple",
		_TRANS('SIMP_Help_WhyMultiplyStack') ,--Why have the option to multiply stack size?
		_TRANS('SIMP_Help_WhyMultiplyStackAnswer') --The original Stat-Simple multiplied by the stack size of the item, but some like dealing on a per-item basis.
		)

	gui:AddControl(id, "Header",     0,    _TRANS('SIMP_Interface_SimpleOptions') )--Simple options'
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.simple.enable", _TRANS('SIMP_Interface_EnableSimpleStats') )--Enable Simple Stats
	gui:AddTip(id, _TRANS('SIMP_HelpTooltip_EnableSimpleStats') )--Allow Simple Stats to gather and return price data
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

	gui:AddControl(id, "Checkbox",   0, 1, "stat.simple.tooltip", _TRANS('SIMP_Interface_Show') )--Show simple stats in the tooltips?
	gui:AddTip(id, _TRANS('SIMP_HelpTooltip_Show') )--Toggle display of stats from the Simple module on or off
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.avg3", _TRANS('SIMP_Interface_Toggle3Day') )--Display Moving 3 Day Average
	gui:AddTip(id, _TRANS('SIMP_HelpTooltip_Toggle3Day') )--Toggle display of 3-Day average from the Simple module on or off
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.avg7", _TRANS('SIMP_Interface_Toggle7Day') )--Display Moving 7 Day Average
	gui:AddTip(id, _TRANS('SIMP_HelpTooltip_Toggle7Day') )--Toggle display of 7-Day average from the Simple module on or off
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.avg14", _TRANS('SIMP_Interface_Toggle14Day') )--Display Moving 14 Day Average
	gui:AddTip(id,_TRANS( 'SIMP_HelpTooltip_Toggle14Day') )--Toggle display of 14-Day average from the Simple module on or off
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.minbuyout", _TRANS('SIMP_Interface_MinBuyout') )--Display Daily Minimum Buyout
	gui:AddTip(id, _TRANS('SIMP_HelpTooltip_MinBuyout') )--Toggle display of Minimum Buyout from the Simple module on or offMultiplies by current stack size if on
	gui:AddControl(id, "Checkbox",   0, 2, "stat.simple.avgmins", _TRANS('SIMP_Interface_MinBuyoutAverage') )--Display Average of Daily Minimum Buyouts
	gui:AddTip(id,_TRANS( 'SIMP_HelpTooltip_MinBuyoutAverage') )--Toggle display of Minimum Buyout average from the Simple module on or off
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.simple.quantmul", _TRANS('SIMP_Interface_MultiplyStack') )--Multiply by stack size
	gui:AddTip(id, _TRANS('SIMP_HelpTooltip_MultiplyStack') )--Multiplies by current stack size if on
	gui:AddControl(id, "Checkbox",   0, 1, "stat.simple.reportsafe", _TRANS('SIMP_Interface_LongerAverage') )--Report safer prices for low volume items
	gui:AddTip(id, _TRANS('SIMP_HelpTooltip_LongerAverage') )--Returns longer averages (7-day, or even 14-day) for low-volume items
end

--[[ Local functions ]]--

function private.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.

	if not AucAdvanced.Settings.GetSetting("stat.simple.tooltip") then return end

	if not quantity or quantity < 1 then quantity = 1 end
	if not AucAdvanced.Settings.GetSetting("stat.simple.quantmul") then quantity = 1 end
	local dayAverage, avg3, avg7, avg14, minBuyout, avgmins, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink)
	local dispAvg3 = AucAdvanced.Settings.GetSetting("stat.simple.avg3")
	local dispAvg7 = AucAdvanced.Settings.GetSetting("stat.simple.avg7")
	local dispAvg14 = AucAdvanced.Settings.GetSetting("stat.simple.avg14")
	local dispMinB = AucAdvanced.Settings.GetSetting("stat.simple.minbuyout")
	local dispAvgMBO = AucAdvanced.Settings.GetSetting("stat.simple.avgmins")
	if (not dayAverage) then return end

	if (seenDays + dayCount > 0) then
		tooltip:AddLine(_TRANS('SIMP_Tooltip_SimplePrices') )--Simple prices:

		if (seenDays > 0) then
			if (dayCount>0) then seenDays = seenDays + 1 end
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_SeenNumberDays'):format("|cffddeeff", seenCount+dayCount, "|r", "|cffddeeff", seenDays, "|r") ) --"  Seen %s%s%s over %s%s%s days:")
			
		end
		if (seenDays > 6) and dispAvg14 then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_14DayAverage') , avg14*quantity)--  14 day average
		end
		if (seenDays > 2) and dispAvg7 then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_7DayAverage') , avg7*quantity) --  7 day average
		end
		if (seenDays > 0) and dispAvg3 then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_3DayAverage') , avg3*quantity)--  3 day average
		end
		if (seenDays > 0) and (avgmins > 0) and dispAvgMBO then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_AverageMBO') , avgmins*quantity)--  Average MBO
		end
		if (dayCount > 0) then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_SeenToday'):format("|cffddeeff",dayCount ,"|r") , dayAverage*quantity) --Seen %s%s%s today
		end
		if (dayCount > 0) and (minBuyout > 0) and dispMinB then
			tooltip:AddLine("  ".._TRANS('SIMP_Tooltip_TodaysMBO') , minBuyout*quantity)-- Today's Min BO
		end
	end
end

-- This is a function which migrates the data from a daily average to the
-- Exponential Moving Averages over the 3, 7 and 14 day ranges.
function private.PushStats(faction, realm)
	local dailyAvg

	local data = private.GetPriceData(faction, realm)
	if not data then return end
	if not data.daily then return end
	if not data.means then data.means = {} end

	local pdata, fdata, temp
	for itemId, stats in pairs(data.daily) do
		if (itemId ~= "created") then
			pdata = private.UnpackStats(stats)
			fdata = private.UnpackStats(data.means[itemId] or "")
			for property, info in pairs(pdata) do
				dailyAvg = info[1] / info[2]
				if not info[3] then info[3] = 0 end
				if not fdata[property] then
					fdata[property] = {
						1,
						info[2],
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(info[3])
					}
				else
					fdata[property][1] = fdata[property][1] + 1
					fdata[property][2] = fdata[property][2] + info[2]
					fdata[property][3] = ("%0.01f"):format(((fdata[property][3] * 2) + dailyAvg)/3)
					fdata[property][4] = ("%0.01f"):format(((fdata[property][4] * 6) + dailyAvg)/7)
					fdata[property][5] = ("%0.01f"):format(((fdata[property][5] * 13) + dailyAvg)/14)
					if not fdata[property][6] then fdata[property][6] = 0 end
					temp = fdata[property][6]
					if temp < 1 then
						fdata[property][6] = info[3]
					else
						if info[3] ~= 0 then
							if temp < info[3] then
								if (temp*10/info[3]) < 9 then
									fdata[property][6] = ("%0.01f"):format((temp+info[3])/2)
								else
									fdata[property][6] = ("%0.01f"):format((temp*7+info[3])/8)
								end
							else
								if (info[3]*10/temp) < 9 then
									fdata[property][6] = ("%0.01f"):format((temp+info[3])/2)
								else
									fdata[property][6] = ("%0.01f"):format((temp*7+info[3])/8)
								end
							end
						end
					end
				end
			end
			data.means[itemId] = private.PackStats(fdata)
		end
	end
	data.daily = {}
	data.daily.created = time()
end

function private.UnpackStatIter(data, ...)
	local c = select("#", ...)
	local v
	for i = 1, c do
		v = select(i, ...)
		local property, info = strsplit(":", v)
		property = tonumber(property) or property
		if (property and info) then
			data[property] = {strsplit(";", info)}
			local item
			for i=1, #data[property] do
				item = data[property][i]
				data[property][i] = tonumber(item) or item
			end
		end
	end
end

function private.UnpackStats(dataItem)
	local data = {}
	private.UnpackStatIter(data, strsplit(",", dataItem))
	return data
end

function private.PackStats(data)
	local stats = ""
	local joiner = ""
	for property, info in pairs(data) do
		stats = stats..joiner..property..":"..strjoin(";", unpack(info))
		joiner = ","
	end
	return stats
end


-- The following Functions are the routines used to access the permanent store data
function private.UpgradeDb()
	if (not AucAdvancedStatSimpleData.Version) then
		local newData = {Version = "1.0", RealmData = {}}
		for x, y in pairs(AucAdvancedStatSimpleData) do
			local t = {strsplit(x, "-")}
			local realm, faction
			for _, z in ipairs(t) do
				if (faction) then
					if (realm) then realm = realm.."-"..faction
					else realm = faction end
				end
				faction = z
			end
			if (not newData.RealmData[realm]) then
				newData.RealmData[realm] = {}
			end
			newData.RealmData[realm][faction] = y
		end
		AucAdvancedStatSimpleData = newData
	end
end


function private.LoadData()
	if (AAStatSimpleData) then return end
	if (not AucAdvancedStatSimpleData) then AucAdvancedStatSimpleData = {Version='1.0', RealmData = {}} end
	private.UpgradeDb()
	AAStatSimpleData = AucAdvancedStatSimpleData
	private.DataLoaded()
end

function private.ClearData(faction, realmName)
	if (not AAStatSimpleData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFaction()
	if (realmName) then
		print(_TRANS('SIMP_Interface_ClearingSimple').." {{"..faction.."}}") --Clearing Simple stats for
	else
		realmName = GetRealmName()
		print(_TRANS('SIMP_Interface_ClearingSimpleStats'):format(faction, realmName) )--Clearing Simple stats for {{%s}} on {{%s}}
		
	end
	if (AAStatSimpleData.RealmData[realmName] and AAStatSimpleData.RealmData[realmName][faction]) then
		AAStatSimpleData.RealmData[realmName][faction] = nil
	end
end

function private.GetPriceData(faction, realm)
	if (not AAStatSimpleData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFaction()
	realm = realm or GetRealmName()
	if (not AAStatSimpleData.RealmData[realm]) then AAStatSimpleData.RealmData[realm] = {} end
	if (not AAStatSimpleData.RealmData[realm][faction]) then AAStatSimpleData.RealmData[realm][faction] = {} end
	return AAStatSimpleData.RealmData[realm][faction]
end

function private.DataLoaded()
	if (not AAStatSimpleData) then return end
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
	for realm, realmdata in pairs(AAStatSimpleData.RealmData) do
		for faction, stats in pairs(realmdata) do
			if not stats.daily then stats.daily = { created = time() } end
			if not stats.means then stats.means = {} end
			if stats.daily.created and time() - stats.daily.created > 3600*16 then
				-- This data is more than 16 hours old, we classify this as "yesterday's data"
				private.PushStats(faction, realm)
			end
		end
	end
end

-- Simple function to total all of the values in the tuple
-- @param ... The values to add. Note: tonumber() is called
-- on all passed in values. Type checking is not performed.
-- This may result in silent failures.
-- @return The sum of all of the values passed in
function private.sum(...)
    local total = 0;
    for x = 1, select('#', ...) do
        total = total + select(x, ...);
    end

    return total;
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Stat-Simple/StatSimple.lua $", "$Rev: 3817 $")
