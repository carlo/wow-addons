--[[
	Auctioneer Advanced - Search UI - Searcher Resale
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: SearcherResale.lua 3716 2008-10-25 17:30:24Z RockSlice $
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
local lib, parent, private = AucSearchUI.NewSearcher("Resale")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Resale"
-- Set our defaults
default("resale.profit.min", 1)
default("resale.profit.pct", 50)
default("resale.seen.check", false)
default("resale.seen.min", 10)
default("resale.adjust.brokerage", true)
default("resale.adjust.deposit", true)
default("resale.adjust.listings", 3)
default("resale.allow.bid", true)
default("resale.allow.buy", true)
default("resale.model", "Appraiser")

function private.GetPriceModels()
	if not private.modelNames then private.modelNames = {} end
	empty(private.modelNames)
	table.insert(private.modelNames,{"market", "Market value"})
	local algoList = AucAdvanced.API.GetAlgorithms()
	for pos, name in ipairs(algoList) do
		table.insert(private.modelNames,{name, "Stats: "..name})
	end
	return private.modelNames
end

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")

	-- Add the help
	gui:AddSearcher("Resale", "Search for undervalued items which can be directly resold for profit", 100)
	gui:AddHelp(id, "resale searcher",
		"What does this searcher do?",
		"This searcher provides the ability to search for items that are being sold under market value, and which you can resell for profit after the fees and deposits are accounted for.")

	gui:AddControl(id, "Header",     0,      "Resale search criteria")

	local last = gui:GetLast(id)

	gui:AddControl(id, "MoneyFramePinned",  0, 1, "resale.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "resale.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",          0, 1, "resale.seen.check", "Check Seen count")
	gui:AddControl(id, "Slider",            0, 2, "resale.seen.min", 1, 100, 1, "Min seen count: %s")

	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "resale.allow.buy", "Allow Buyouts")

	gui:AddControl(id, "Subhead",           0.42,    "Price Valuation Method:")
	gui:AddControl(id, "Selectbox",         0.42, 1, private.GetPriceModels, "resale.model", "Pricing model to use to base price on")
	gui:AddTip(id, "The pricing model that is used to work out the calculated value of items at the Auction House.")
	
	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.adjust.brokerage", "Subtract auction fees")
	gui:AddControl(id, "Checkbox",          0.42, 1, "resale.adjust.deposit", "Subtract deposit")
	gui:AddControl(id, "Slider",            0.42, 1, "resale.adjust.listings", 1, 10, .1, "Ave relistings: %0.1fx")
end

function lib.Search(item)
	local market, seen, _, curModel, pctstring

	if not item[Const.LINK] then
		return false, "No link"
	end
	local model = get("resale.model")
	if model == "market" then
		market, seen = AucAdvanced.API.GetMarketValue(item[Const.LINK])
	elseif model == "Appraiser" and AucAdvanced.Modules.Util.Appraiser then
		market, _, _, seen, curModel = AucAdvanced.Modules.Util.Appraiser.GetPrice(item[Const.LINK])
	else
		market, seen = AucAdvanced.API.GetAlgorithmValue(model, item[Const.LINK])
	end
	if not market then
		return false, "No appraiser price"
	end
	market = market * item[Const.COUNT]

	if (get("resale.seen.check")) and curModel ~= "fixed" then
		if ((not seen) or (seen < get("resale.seen.min"))) then
			return false, "Seen count too low"
		end
	end

	--adjust for brokerage/deposit costs
	local deposit = get("resale.adjust.deposit")
	local brokerage = get("resale.adjust.brokerage")

	if brokerage then
		market = market * 0.95
	end
	if deposit then
		local relistings = get("resale.adjust.listings")
		local rate = AucAdvanced.depositRate or 0.05
		local newfaction
		if rate == .25 then newfaction = "neutral" end
		local amount = GetDepositCost(item[Const.LINK], 12, newfaction, item[Const.COUNT])
		if not amount then
			amount = 0
		else
			amount = amount * relistings
		end
		market = market - amount
	end

	local pct = get("resale.profit.pct")
	local minprofit = get("resale.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	if get("resale.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		return "buy", market
	elseif get("resale.allow.bid") and (item[Const.PRICE] <= value) then
		return "bid", market
	end
	return false, "Not enough profit"
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-SearchUI/SearcherResale.lua $", "$Rev: 3716 $")
