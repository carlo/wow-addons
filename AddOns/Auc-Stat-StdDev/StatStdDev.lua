--[[
	Auctioneer Advanced - Standard Deviation Statistics module
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: StatStdDev.lua 3817 2008-11-12 18:48:59Z RockSlice $
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

local libType, libName = "Stat", "StdDev"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill, _TRANS = AucAdvanced.GetModuleLocals()

local data
local ZValues = {.063, .126, .189, .253, .319, .385, .454, .525, .598, .675, .756, .842, .935, 1.037, 1.151, 1.282, 1.441, 1.646, 1.962, 20, 20000}

function lib.CommandHandler(command, ...)
	if (not data) then private.makeData() end
	local myFaction = AucAdvanced.GetFaction()
	if (command == "help") then
		print(_TRANS('SDEV_Help_SlashHelp1') )--Help for Auctioneer Advanced - StdDev
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		print(line, "help}} - ".._TRANS('SDEV_Help_SlashHelp2') ) --this StdDev help
		print(line, "clear}} - ".._TRANS('SDEV_Help_SlashHelp3'):format(myFaction) ) --clear current %s StdDev price database
	elseif (command == "clear") then
		print(_TRANS('SDEV_Help_SlashHelp4').." {{", myFaction, "}}") --Clearing StdDev stats for
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
	end
end

lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	if not AucAdvanced.Settings.GetSetting("stat.stddev.enable") then return end
	if (not data) then private.makeData() end

	-- This function is responsible for processing and storing the stats after each scan
	-- Note: itemData gets reused over and over again, so do not make changes to it, or use
	-- it in places where you rely on it. Make a deep copy of it if you need it after this
	-- function returns.

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	if (itemData.stackSize > 1) then
		buyout = buyout.."/"..itemData.stackSize
	end

	-- Get the signature of this item and find it's stats.
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(itemData.link)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	local faction = AucAdvanced.GetFaction()
	if not data[faction] then data[faction] = {} end
	local stats = private.UnpackStats(data[faction][itemId])
	if not stats[property] then stats[property] = {} end
	if #stats[property] >= 100 then
		table.remove(stats[property], 1)
	end
	table.insert(stats[property], buyout)
	data[faction][itemId] = private.PackStats(stats)
end

local BellCurve = AucAdvanced.API.GenerateBellCurve();
-----------------------------------------------------------------------------------
-- The PDF for standard deviation data, standard bell curve
-----------------------------------------------------------------------------------
function lib.GetItemPDF(hyperlink, faction, realm)
	if not AucAdvanced.Settings.GetSetting("stat.stddev.enable") then return end
	-- Get the data
	local average, mean, _, stddev, variance, count, confidence = lib.GetPrice(hyperlink, faction, realm);
	-- DEFAULT_CHAT_FRAME:AddMessage("-----");
	-- DevTools_Dump{lib.GetPrice(hyperlink,faction,realm)};

	if not (average and stddev) or average == 0 or stddev == 0 then
		return nil;                 -- No data, cannot determine pricing
	end

	local lower, upper = average - 3 * stddev, average + 3 * stddev;

	-- Build the PDF based on standard deviation & average
	BellCurve:SetParameters(average, stddev);
	return BellCurve, lower, upper;   -- This has a __call metamethod so it's ok
end

-----------------------------------------------------------------------------------

function private.GetCfromZ(Z)
	--C = 0.05*i
	if (not Z) then
		return .05
	end
	if (Z > 10) then
		return .99
	end
	local i = 1
	while Z > ZValues[i] do
		i = i + 1
	end
	if i == 1 then
		return .05
	else
		i = i - 1 + ((Z - ZValues[i-1]) / (ZValues[i] - ZValues[i-1]))
		return i*0.05
	end
end

function lib.GetPrice(hyperlink, faction)
	if not AucAdvanced.Settings.GetSetting("stat.stddev.enable") then return end

	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor and factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end
	if not data[faction] then return end

	if not data[faction][itemId] then return end

	local stats = private.UnpackStats(data[faction][itemId])
	if not stats[property] then return end

	local count = #stats[property]
	if (count < 1) then return end

	local total, number = 0, 0
	for i = 1, count do
		local price, stack = strsplit("/", stats[property][i])
		price = tonumber(price) or 0
		stack = tonumber(stack) or 1
		if (stack < 1) then stack = 1 end
		total = total + tonumber(price)
		number = number + stack
	end
	local mean = total / number

	if (count < 2) then return 0,0,0, mean, count end

	local variance = 0
	for i = 1, count do
		local price, stack = strsplit("/", stats[property][i])
		price = tonumber(price) or 0
		stack = tonumber(stack) or 1
		if (stack < 1) then stack = 1 end
		variance = variance + ((mean - price/stack) ^ 2);
	end

	variance = variance / count;
	local stdev = variance ^ 0.5
	total = 0

	local deviation = 1.5 * stdev

	number = 0
	for i = 1, count do
		local price, stack = strsplit("/", stats[property][i])
		price = tonumber(price) or 0
		stack = tonumber(stack) or 1
		if (stack < 1) then stack = 1 end
		if (math.abs(price - mean) < deviation) then
			total = total + price
			number = number + stack
		end
	end

	local confidence = .01
	local average
	if (number > 0) then
		average = total / number
		confidence = (.15*average)*(number^0.5)/(stdev)
		confidence = private.GetCfromZ(confidence)
	end

	return average, mean, false, stdev, variance, count, confidence
end

function lib.GetPriceColumns()
	return "Average", "Mean", false, "Std Deviation", "Variance", "Count"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	if not AucAdvanced.Settings.GetSetting("stat.stddev.enable") then return end
	-- Clean out the old array
	while (#array > 0) do table.remove(array) end

	-- Get our statistics
	local average, mean, _, stdev, variance, count, confidence = lib.GetPrice(hyperlink, faction, realm)

	-- These 3 are the ones that most algorithms will look for
	array.price = average or mean
	array.seen = count
	array.confidence = confidence
	-- This is additional data
	array.normalized = average
	array.mean = mean
	array.deviation = stdev
	array.variance = variance

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

AucAdvanced.Settings.SetDefault("stat.stddev.tooltip", true)

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")
	--gui:MakeScrollable(id)

	gui:AddHelp(id, "what stddev stats",
		_TRANS('SDEV_Help_StdDevStats') ,--What are StdDev stats?
		_TRANS('SDEV_Help_StdDevStatsAnswer') --StdDev stats are the numbers that are generated by the StdDev module consisting of a filtered Standard Deviation calculation of item cost.
		)

	gui:AddHelp(id, "filtered stddev",
		_TRANS('SDEV_Help_Filtered') ,--What do you mean filtered?
		_TRANS('SDEV_Help_FilteredAnswer') --Items outside a (1.5*Standard) variance are ignored and assumed to be wrongly priced when calculating the deviation.
		)

	gui:AddHelp(id, "what standard deviation",
		_TRANS('SDEV_Help_StandardDeviationCalculation') ,--What is a Standard Deviation calculation?
		_TRANS('SDEV_Help_StandardDeviationCalculationAnswer') --In short terms, it is a distance to mean average calculation.
		)

	gui:AddHelp(id, "what normalized",
		_TRANS('SDEV_Help_Normalized') ,--What is the Normalized calculation?
		_TRANS('SDEV_Help_NormalizedAnswer') --In short terms again, it is the average of those values determined within the standard deviation variance calculation.
		)

	gui:AddHelp(id, "what confidence",
		_TRANS('SDEV_Help_Confidence') ,--What does confidence mean?
		_TRANS('SDEV_Help_ConfidenceAnswer') --Confidence is a value between 0 and 1 that determines the strength of the calculations (higher the better).
		)

	gui:AddHelp(id, "why multiply stack size stddev",
		_TRANS('SDEV_Help_WhyMultiplyStack') ,--Why have the option to multiply by stack size?
		_TRANS('SDEV_Help_WhyMultiplyStackAnswer') --The original Stat-StdDev multiplied by the stack size of the item, but some like dealing on a per-item basis.
		)

	gui:AddControl(id, "Header",     0,   _TRANS('SDEV_Interface_StdDevOptions') )--StdDev options
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.stddev.enable", _TRANS('SDEV_Interface_EnableStdDevStats') )--Enable StdDev Stats
	gui:AddTip(id, _TRANS('SDEV_HelpTooltip_EnableStdDevStats') )--Allow StdDev to gather and return price data
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

	gui:AddControl(id, "Checkbox",   0, 1, "stat.stddev.tooltip", _TRANS('SDEV_Interface_Show') )--Show stddev stats in the tooltips?
	gui:AddTip(id, _TRANS('SDEV_HelpTooltip_Show') )--Toggle display of stats from the StdDev module on or off
	gui:AddControl(id, "Checkbox",   0, 2, "stat.stddev.mean", _TRANS('SDEV_Interface_DisplayMean') )--Display Mean
	gui:AddTip(id, _TRANS('SDEV_HelpTooltip_DisplayMean') )--Toggle display of 'Mean' calculation in tooltips on or off
	gui:AddControl(id, "Checkbox",   0, 2, "stat.stddev.normal", _TRANS('SDEV_Interface_DisplayNormalized') )--Display Normalized
	gui:AddTip(id, _TRANS('SDEV_HelpTooltip_DisplayNormalized') )--Toggle display of 'Normalized' calculation in tooltips on or off'
	gui:AddControl(id, "Checkbox",   0, 2, "stat.stddev.stdev", _TRANS('SDEV_Interface_DisplayStandardDeviation') )--Display Standard Deviation
	gui:AddTip(id,_TRANS('SDEV_HelpTooltip_DisplayStandardDeviation') )--Toggle display of 'Standard Deviation' calculation in tooltips on or off
	gui:AddControl(id, "Checkbox",   0, 2, "stat.stddev.confid", _TRANS('SDEV_Interface_DisplayConfidence') )--Display Confidence
	gui:AddTip(id,_TRANS('SDEV_HelpTooltip_DisplayConfidence') )--Toggle display of 'Confidence' calculation in tooltips on or off
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.stddev.quantmul", _TRANS('SDEV_Interface_MultiplyStack') )--Multiply by Stack Size
	gui:AddTip(id,_TRANS('SDEV_HelpTooltip_MultiplyStack') )--Multiplies by current stack size if on
end

function lib.ProcessTooltip(tooltip, name, hyperlink, quality, quantity, cost, ...)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.

	if not AucAdvanced.Settings.GetSetting("stat.stddev.tooltip") then return end

	if not quantity or quantity < 1 then quantity = 1 end
	if not AucAdvanced.Settings.GetSetting("stat.stddev.quantmul") then quantity = 1 end
	local average, mean, _, stdev, var, count, confidence = lib.GetPrice(hyperlink)

	if (mean and mean > 0) then
		tooltip:AddLine(_TRANS('SDEV_Tooltip_PricesPoints'):format(count) )--StdDev prices %d points:

		if AucAdvanced.Settings.GetSetting("stat.stddev.mean") then
			tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_MeanPrice'), mean*quantity)-- Mean price
		end
		if (average and average > 0) then
			if AucAdvanced.Settings.GetSetting("stat.stddev.normal") then
				tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_Normalized'), average*quantity)--  Normalized
				if (quantity > 1) then
					tooltip:AddLine("   ".._TRANS('SDEV_Tooltip_Individually'), average)--  (or individually)
				end
			end
			if AucAdvanced.Settings.GetSetting("stat.stddev.stdev") then
				tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_StdDeviation'), stdev*quantity)--  Std Deviation
                if (quantity > 1) then
                    tooltip:AddLine("   ".._TRANS('SDEV_Tooltip_Individually'), stdev)--  (or individually)
                end

			end
			if AucAdvanced.Settings.GetSetting("stat.stddev.confid") then
				tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_Confidence')..(floor(confidence*1000))/1000)-- Confidence: 
			end
		end
	end
end

function lib.OnLoad(addon)
	private.makeData()
	AucAdvanced.Settings.SetDefault("stat.stddev.tooltip", false)
	AucAdvanced.Settings.SetDefault("stat.stddev.mean", false)
	AucAdvanced.Settings.SetDefault("stat.stddev.normal", false)
	AucAdvanced.Settings.SetDefault("stat.stddev.stdev", true)
	AucAdvanced.Settings.SetDefault("stat.stddev.confid", true)
	AucAdvanced.Settings.SetDefault("stat.stddev.quantmul", true)
	AucAdvanced.Settings.SetDefault("stat.stddev.enable", true)
end

function lib.ClearItem(hyperlink, faction, realm)
	local linkType, itemID, property, factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then
		return
	end
	if (factor ~= 0) then property = property.."x"..factor end
	if not faction then faction = AucAdvanced.GetFaction() end
	if not realm then realm = GetRealmName() end
	if (not data) then private.makeData() end
	if (data[faction]) then
		print(libType.._TRANS('SDEV_Interface_ClearingData'):format(hyperlink, faction))--- StdDev: clearing data for %s for {{%s"}}	
		data[faction][itemID] = nil
	end
end

--[[ Local functions ]]--

function private.DataLoaded()
	-- This function gets called when the data is first loaded. You may do any required maintenence
	-- here before the data gets used.

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
	if (dataItem) then
		private.UnpackStatIter(data, strsplit(",", dataItem))
	end
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

function private.makeData()
	if data then return end
	if (not AucAdvancedStatStdDevData) then AucAdvancedStatStdDevData = {} end
	data = AucAdvancedStatStdDevData
	private.DataLoaded()
end


AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Stat-StdDev/StatStdDev.lua $", "$Rev: 3817 $")
