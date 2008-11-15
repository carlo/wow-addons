--[[
	Auctioneer Advanced - StatPurchased
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: StatPurchased.lua 3767 2008-11-05 17:57:29Z Norganna $
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

local libType, libName = "Stat", "Purchased"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill, _TRANS = AucAdvanced.GetModuleLocals()

local data

function lib.CommandHandler(command, ...)
	local myFaction = AucAdvanced.GetFaction()
	local realm = GetRealmName()
	if (command == "help") then
		print(_TRANS('Help for Auctioneer Advanced - Purchased'))
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, _TRANS('help}} - this') , libName, _TRANS('help') )
		print(line, _TRANS('clear [faction [realm]]}} - clear ') ..libName.._TRANS(' price database').." ("..myFaction.._TRANS(' on ') ..realm.._TRANS(' by default)') )
		print(line, _TRANS('push [faction [realm]]}} - force the ') ..libName.._TRANS(' daily stats for faction to archive (') ..myFaction.._TRANS(' on ') ..realm.._TRANS(' by default)') )
	elseif (command == _TRANS('clear') ) then
		private.ClearData(...)
	elseif (command == _TRANS('push') ) then
		print(_TRANS('Archiving ').."{{", myFaction, "}} ".._TRANS('daily stats and starting a new day'))
		private.PushStats(myFaction, realmname)
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
local auctiondata
function lib.ScanProcessors.begin()
	auctiondata = private.GetAuctionData()
end
function lib.ScanProcessors.complete()
	auctiondata = nil
end

function lib.ScanProcessors.suspend(operation, itemData, oldData)
	if (itemData.buyoutPrice) then
		if (not auctiondata[itemData.id]) then auctiondata[itemData.id] = {} end
		auctiondata[itemData.id].boughtout = true
	end
end

function lib.ScanProcessors.update(operation, itemData, oldData)
	if (itemData.price ~= oldData.price) then
		if (not auctiondata[itemData.id]) then auctiondata[itemData.id] = {} end
		auctiondata[itemData.id].bidon = true
	end
end

function lib.ScanProcessors.delete(operation, itemData, oldData)
	if (itemData.buyoutPrice) then
		local stillpossible = false
		local auctionmaxtime = AucAdvanced.Const.AucMinTimes[itemData.timeLeft] or 86400
		if (time() - itemData.seenTime <= auctionmaxtime) then
			stillpossible = true
		end

		if (stillpossible) then
			if (not auctiondata[itemData.id]) then auctiondata[itemData.id] = {} end
			auctiondata[itemData.id].boughtout = true
		end
	end

	if (not auctiondata[itemData.id]) then return end

	local pricedata = private.GetPriceData()
	local itemType, itemId, property, factor = AucAdvanced.DecodeLink(itemData.link)
	if (factor ~= 0) then property = property.."x"..factor end
	local price = 0
	if not pricedata.daily then pricedata.daily = { created = time() } end
	if not pricedata.daily[itemId] then pricedata.daily[itemId] = "" end

	if (auctiondata[itemData.id].boughtout and itemData.buyoutPrice) then
		price = itemData.buyoutPrice
	else
		price = itemData.price
	end

	price = price / itemData.stackSize
	local stats = private.UnpackStats(pricedata.daily[itemId])
	if not stats[property] then stats[property] = { 0, 0 } end
	stats[property][1] = stats[property][1] + price
	stats[property][2] = stats[property][2] + 1
	pricedata.daily[itemId] = private.PackStats(stats)
	auctiondata[itemData.id] = nil
end

lib.Private = private


-- Determines the sample estimated standard deviation based on the deviation
-- of the daily, 3day, 7day, and 14day averages. This is not technically
-- correct because they are not independent samples (the 7 day average
-- includes data from the 3 day and daily averages, for example). Still
-- it provides a good estimation in the presence of lack of data. If you
-- want to discuss the math behind this estimation, find Shirik
-- @param hyperlink The item to look up
-- @param faction The faction key from which to look up the data
-- @param realm The realm from which to look up the data
-- @return The estimated population mean
-- @return The estimated population standard deviation
-- @return The number of views found to base the standard deviation upon
function private.EstimateStandardDeviation(hyperlink, faction, realm)
    local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	assert(linkType=="item", "Standard deviation estimation requires an item link");

	local dayAverage, avg3, avg7, avg14, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink)

    local dataset = {}
    local count = 0
    if dayAverage then
        tinsert(dataset, dayAverage);
        count = count + 1
    end
    if seenDays >= 3 then
        tinsert(dataset, avg3);
        count = count + 1
        if seenDays >= 7 then
            tinsert(dataset, avg7);
            count = count + 1
            if seenDays >= 14 then
                tinsert(dataset, avg14);
                count = count + 1
           end
        end
    end

    if #dataset == 0 then                               -- No data
         print(_TRANS('Warning: Purchased dataset for ') ..hyperlink.._TRANS(' is empty.') );
        return;
    end

    local mean = private.sum(unpack(dataset))/#dataset;
    local variance = 0;
    for k,v in ipairs(dataset) do
        variance = variance + (mean - v)^2;
    end

    return mean, sqrt(variance), count;
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
    if not get("stat.purchased.enable") then return end --disable purchased if desired

    -- Calculate the SE estimated standard deviation & mean
    local mean, stddev, count = private.EstimateStandardDeviation(hyperlink, faction, realm);

    if stddev ~= stddev or mean ~= mean or not mean or mean == 0 then
        return;                         -- No available data or cannot estimate
    end

    if not count or count == 0 then
    print(mean)
    print(stddev)
    print(count)
    print(_TRANS('count broken! for ') ..hyperlink)
    count = 1
    end
    -- If the standard deviation is zero, we'll have some issues, so we'll estimate it by saying
    -- the std dev is 100% of the mean divided by square root of number of views
    if stddev == 0 then stddev = mean / sqrt(count); end


    -- Calculate the lower and upper bounds as +/- 3 standard deviations
    local lower, upper = mean - 3*stddev, mean + 3*stddev;

    bellCurve:SetParameters(mean, stddev);
    return bellCurve, lower, upper;
end

function lib.GetPrice(hyperlink, faction, realm)
	if not get("stat.purchased.enable") then return end --disable purchased if desired

	if (not faction) or (faction == AucAdvanced.GetFaction()) then
		faction = AucAdvanced.GetFactionGroup()
	end
	realm = realm or GetRealmName()

	local data = private.GetPriceData(faction, realm)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end

	if not data then return end
	local dayTotal, dayCount, dayAverage = 0,0,0
	local seenDays, seenCount, avg3, avg7, avg14 = 0,0,0,0,0

	if data.daily and data.daily[itemId] then
		local stats = private.UnpackStats(data.daily[itemId])
		if stats[property] then
			dayTotal, dayCount = unpack(stats[property])
			dayAverage = dayTotal/dayCount
		end
	end
	if data.means and data.means[itemId] then
		local stats = private.UnpackStats(data.means[itemId])
		if stats[property] then
			seenDays, seenCount, avg3, avg7, avg14 = unpack(stats[property])
		end
	end
	return dayAverage, avg3, avg7, avg14, false, dayTotal, dayCount, seenDays, seenCount
end

function lib.GetPriceColumns()
	return "Daily Avg", "3 Day Avg", "7 Day Avg", "14 Day Avg", false, "Daily Total", "Daily Count", "Seen Days", "Seen Count"
end


local cacheFaction = ""
local cache
local cacheMeta = {__mode="kv"}	-- weak-everything

local tmpReturn={} -- used to return stuff in

function lib.GetPriceArray(hyperlink, faction, realm)
	if not get("stat.purchased.enable") then return end --disable purchased if desired

	if (not faction) or (faction == AucAdvanced.GetFaction()) then
		faction = AucAdvanced.GetFactionGroup()
	end
	realm = realm or GetRealmName()

	-- Keep a GCable cache of [hyperlink]={array}
	-- It's tempting to use a single array for returns, but realize that unpacking our data results in dozens of new substrings and several new subtables!
	if faction~=cacheFaction then	-- no we don't need to check the realm, that needs a relog!
		cacheFaction = faction
		cache = setmetatable({}, cacheMeta)
	end
	if not cache[hyperlink] then

		local array = {}
		cache[hyperlink] = array

		-- Get our statistics
		local dayAverage, avg3, avg7, avg14, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink, faction, realm)

		-- array.price and array.seen are the ones that most algorithms will look for
		array.seen = seenCount
		if not AucAdvanced.Settings.GetSetting("stat.purchased.reportsafe") then
			array.price = avg3 or dayAverage
		else
			-- Safe mode: prefer longer-running averages for low-volume items
			if seenCount>100 and seenCount > seenDays*10 then
				array.price = avg3 or dayAverage
				-- print(hyperlink..": seen "..seenCount.." over "..seenDays.. "days. going with avg3")
			else
				local a3 = avg3 or dayAverage
				local a7 = avg7 or a3
				local a14 = avg14 or a7
				if seenCount >= seenDays*7 then
					array.price = (a3+a7)/2
					-- print(hyperlink..": seen "..seenCount.." over "..seenDays.. "days. going with avg(a3,a7)")
				else
					local mix3 = seenCount / (seenDays*7*2) -- 0.07 for 1/1, 0.5 for 7/1
					local mix14 = 0.5-mix3
					local mix7 = 1-mix3-mix14	-- actually always==0.5 :-)
					array.price = a3*mix3 + a7*mix7 + a14*mix14
					-- print(hyperlink..": seen "..seenCount.." over "..seenDays.. "days. mix3="..mix3.." mix7="..mix7.." mix14="..mix14)
				end
			end
		end

		-- This is additional data
		array.avgday = dayAverage
		array.avg3 = avg3
		array.avg7 = avg7
		array.avg14 = avg14
		array.daytotal = dayTotal
		array.daycount = dayCount
		array.seendays = seenDays
	end

	-- now it'd be wonderful to just be able to return it all out...
	-- but unfortunately some callers mess with the returned array! Nice going!
	for k,v in pairs(cache[hyperlink]) do
		tmpReturn[k]=v
	end
	return tmpReturn
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.purchased.tooltip", false)
	AucAdvanced.Settings.SetDefault("stat.purchased.avg3", false)
	AucAdvanced.Settings.SetDefault("stat.purchased.avg7", false)
	AucAdvanced.Settings.SetDefault("stat.purchased.avg14", false)
	AucAdvanced.Settings.SetDefault("stat.purchased.quantmul", true)
	AucAdvanced.Settings.SetDefault("stat.purchased.enable", true)
end

AucAdvanced.Settings.SetDefault("stat.purchased.tooltip", true)
AucAdvanced.Settings.SetDefault("stat.purchased.reportsafe", false)

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")
	--gui:MakeScrollable(id)

	gui:AddHelp(id, "what purchased stats",
		_TRANS('What are purchased stats?') ,
		_TRANS('Purchased stats are the numbers that are generated by the Purchased module, the ') ..
		_TRANS('Purchased module attempts to determine if an auction was bought out or purchased on ') ..
		_TRANS('a bid.  It also calculates a Moving Average (3/7/14).') )

	gui:AddHelp(id, "what moving day average purchased",
		_TRANS('What does \'moving average\' mean?') ,
		_TRANS('Moving average means that it places more value on yesterday\'s moving average ') ..
		_TRANS('than today\'s average.  The determined amount is then used for ') ..
		_TRANS('tomorrow\'s moving average calculation.') )

	gui:AddHelp(id, "how day average calculated purchased",
		_TRANS('How is the moving day averages calculated exactly?') ,
		_TRANS('Todays Moving Average is ((X-1)*YesterdaysMovingAverage + TodaysAverage) / X, ') ..
		_TRANS('where X is the number of days (3,7, or 14).') )

	gui:AddHelp(id, "no day saved purchased",
		_TRANS('So you aren\'t saving a day-to-day average?') ,
		_TRANS('No, that would not only take up space, but heavy calculations on each ') ..
		_TRANS('auction house scan.') )

	gui:AddHelp(id, "why multiply stack size stddev",
		_TRANS('Why have the option to multiply stack size?') ,
		_TRANS('The original Stat-Purchased multiplied by the stack size of the item, ') ..
		_TRANS('but some like dealing on a per-item basis.') )

	gui:AddHelp(id, "report safe safer price prices value low volume item items",
		_TRANS('How are the \'safer\' prices computed?') ,
		_TRANS('For anything seen more than 100 times and selling more than 10 items per day (on average), we simply use the 3 day average.').."\n\n"..
		_TRANS('For others, we value the 7-day average at 50%, and the 3- and 14-day averages at between 0--50% and 50--0%, respectively, depending on how many are seen per day (between 1 and 7).').."\n"
		)


	gui:AddControl(id, "Header",     0,    libName.." options")

	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.purchased.enable", _TRANS('Enable Purchased Stats') )
	gui:AddTip(id, _TRANS('Allow Stat Purchased to gather and return price data') )
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

	gui:AddControl(id, "Checkbox",   0, 1, "stat.purchased.tooltip", _TRANS('Show purchased stats in the tooltips?') )
	gui:AddTip(id, _TRANS('Toggle display of stats from the Purchased module on or off') )
	gui:AddControl(id, "Checkbox",   0, 2, "stat.purchased.avg3", _TRANS('Display Moving 3 Day Average') )
	gui:AddTip(id, _TRANS('Toggle display of 3-Day average from the Purchased module on or off') )
	gui:AddControl(id, "Checkbox",   0, 2, "stat.purchased.avg7", _TRANS('Display Moving 7 Day Average') )
	gui:AddTip(id, _TRANS('Toggle display of 7-Day average from the Purchased module on or off') )
	gui:AddControl(id, "Checkbox",   0, 2, "stat.purchased.avg14", _TRANS('Display Moving 14 Day Average') )
	gui:AddTip(id, _TRANS('Toggle display of 14-Day average from the Purchased module on or off') )

	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

	gui:AddControl(id, "Checkbox",   0, 1, "stat.purchased.reportsafe", _TRANS('Report safer prices for low volume items') )
	gui:AddTip(id, _TRANS('Returns longer averages (7-day, or even 14-day) for low-volume items') )

	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

	gui:AddControl(id, "Checkbox",   0, 1, "stat.purchased.quantmul", _TRANS('Multiply by Stack Size') )
	gui:AddTip(id, _TRANS('Multiplies by current Stack Size if on') )

end


--[[ Local functions ]]--
function private.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine what you should
	-- display in the tooltip.
	if not AucAdvanced.Settings.GetSetting("stat.purchased.tooltip") then return end

	if not quantity or quantity < 1 then quantity = 1 end
	if not AucAdvanced.Settings.GetSetting("stat.purchased.quantmul") then quantity = 1 end
	local dayAverage, avg3, avg7, avg14, _, dayTotal, dayCount, seenDays, seenCount = lib.GetPrice(hyperlink)
	if (not dayAverage) then return end
	local dispAvg3 = AucAdvanced.Settings.GetSetting("stat.purchased.avg3")
	local dispAvg7 = AucAdvanced.Settings.GetSetting("stat.purchased.avg7")
	local dispAvg14 = AucAdvanced.Settings.GetSetting("stat.purchased.avg14")

	if (seenDays + dayCount > 0) then
		tooltip:AddLine(_TRANS('Purchased prices:'))

		if (seenDays > 0) then
			if (dayCount>0) then seenDays = seenDays + 1 end
			tooltip:AddLine(_TRANS('  Seen').." |cffddeeff"..(seenCount+dayCount).."|r ".._TRANS('over').." |cffddeeff"..seenDays.."|r ".._TRANS('days:'))
		end
		if (seenDays > 6) and dispAvg14 then
			tooltip:AddLine(_TRANS('  14 day average'), avg14*quantity)
		end
		if (seenDays > 2) and dispAvg7 then
			tooltip:AddLine(_TRANS('  7 day average'), avg7*quantity)
		end
		if (seenDays > 0) and dispAvg3 then
			tooltip:AddLine(_TRANS('  3 day average'), avg3*quantity)
		end
		if (dayCount > 0) then
			tooltip:AddLine(_TRANS('  Seen').." |cffddeeff"..dayCount.."|r ".._TRANS('today'), dayAverage*quantity)
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

	local pdata
	for itemId, stats in pairs(data.daily) do
		if (itemId ~= "created") then
			pdata = private.UnpackStats(stats)
			fdata = private.UnpackStats(data.means[itemId] or "")
			for property, info in pairs(pdata) do
				dailyAvg = info[1] / info[2]
				if not fdata[property] then
					fdata[property] = {
						1,
						info[2],
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(dailyAvg),
						("%0.01f"):format(dailyAvg),
					}
				else
					fdata[property][1] = fdata[property][1] + 1
					fdata[property][2] = fdata[property][2] + info[2]
					fdata[property][3] = ("%0.01f"):format(((fdata[property][3] * 2) + dailyAvg)/3)
					fdata[property][4] = ("%0.01f"):format(((fdata[property][4] * 6) + dailyAvg)/7)
					fdata[property][5] = ("%0.01f"):format(((fdata[property][5] * 13) + dailyAvg)/14)
				end
			end
			data.means[itemId] = private.PackStats(fdata)
		end
	end
	data.daily = { created = time() }
end

function private.UnpackStatIter(data, ...)
	local c = select("#", ...)
	local v
	for i = 1, c do
		v = select(i, ...)
		local property, info = strsplit(":", v)
		property = tonumber(property)
		if (property and info) then
			data[property] = { strsplit(";", info) }
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

local tmp={}
function private.PackStats(data)
	local n=1
	for property, info in pairs(data) do
		tmp[n]=property
		tmp[n+1]=":"
		tmp[n+2]=strjoin(";", unpack(info))
		tmp[n+3]=","
		n=n+4
	end
	return table.concat(tmp, "", 1, n-1)   -- n-1 to skip last ","
end

-- The following Functions are the routines used to access the permanent store data
local AAStatPurchasedData

function private.UpgradeDb()
	-- Do Nothing
end

function private.ClearData(faction, realmName)
	if (not AAStatPurchasedData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFactionGroup()
	if (realmName) then
		print(_TRANS('Clearing Purchased stats for').." {{"..faction.."}}")
	else
		realmName = GetRealmName()
		print(_TRANS('Clearing Purchased stats for').." {{"..faction.."}} ".._TRANS('on').." {{"..realmName.."}}")
	end
	if (AAStatPurchasedData.RealmData[realmName] and AAStatPurchasedData.RealmData[realmName][faction]) then
		AAStatPurchasedData.RealmData[realmName][faction] = nil
	end
end

function lib.ClearItem(hyperlink, faction)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end
	local realm
	if faction then
		realm, faction = strsplit("-", faction)
	else
		realm = GetRealmName()
		faction = AucAdvanced.GetFactionGroup()
	end
	if (not AAStatPurchasedData) then private.LoadData() end
	if (AAStatPurchasedData.RealmData[realm] and AAStatPurchasedData.RealmData[realm][faction]) then
		if AAStatPurchasedData.RealmData[realm][faction]["stats"] and AAStatPurchasedData.RealmData[realm][faction]["stats"]["means"] then
			AAStatPurchasedData.RealmData[realm][faction]["stats"]["means"][itemId] = nil
			print(libType.._TRANS('- Purchased: clearing data for ') ..hyperlink.._TRANS(' for').." {{"..faction.."}}")
		end
	end
end

function private.GetAuctionData(faction, realm)
	if (not AAStatPurchasedData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFactionGroup()
	realm = realm or GetRealmName()
	if (not AAStatPurchasedData.RealmData[realm]) then AAStatPurchasedData.RealmData[realm] = {} end
	if (not AAStatPurchasedData.RealmData[realm][faction]) then AAStatPurchasedData.RealmData[realm][faction] = {auctionData={}, stats={}} end
	return AAStatPurchasedData.RealmData[realm][faction].auctionData
end

function private.GetPriceData(faction, realm)
	if (not AAStatPurchasedData) then private.LoadData() end
	faction = faction or AucAdvanced.GetFactionGroup()
	realm = realm or GetRealmName()
	if (not AAStatPurchasedData.RealmData[realm]) then AAStatPurchasedData.RealmData[realm] = {} end
	if (not AAStatPurchasedData.RealmData[realm][faction]) then AAStatPurchasedData.RealmData[realm][faction] = {auctionData={}, stats={}} end
	return AAStatPurchasedData.RealmData[realm][faction].stats
end

function private.DataLoaded()
	if (not AAStatPurchasedData) then return end
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.
	for realm, realmdata in pairs(AAStatPurchasedData.RealmData) do
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

function private.LoadData()
	if (AAStatPurchasedData) then return end
	if (not AucAdvancedStatPurchasedData) then AucAdvancedStatPurchasedData = {Version='1.0', RealmData = {}} end
	private.UpgradeDb()
	AAStatPurchasedData = AucAdvancedStatPurchasedData
	private.DataLoaded()
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Stat-Purchased/StatPurchased.lua $", "$Rev: 3767 $")
