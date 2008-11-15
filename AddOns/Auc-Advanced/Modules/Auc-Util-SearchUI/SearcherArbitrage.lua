--[[
	Auctioneer Advanced - Search UI - Searcher Arbitrage
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: SearcherArbitrage.lua 3594 2008-10-13 10:01:14Z Norganna $
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
local lib, parent, private = AucSearchUI.NewSearcher("Arbitrage")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Arbitrage"

private.Styles = {
			"Neutral",
			"Cross-Faction",
			"Cross-Realm",
		}
private.Factions = {
			"Neutral",
			"Alliance",
			"Horde",
		}
function private.getStyles()
	return private.Styles
end

function private.getFactions()
	return private.Factions
end

function private.getRealmList()
	if private.realmlist then
		return private.realmlist
	end
	local found = false
	private.realmlist = {}
	local _,current,_ = AucAdvanced.GetFaction()

	local realms = AucAdvancedData.AserArbitrageRealms
	if not realms then
		realms = {}
		AucAdvancedData.AserArbitrageRealms = realms
	end
	local curPlayer = UnitName("player")
	realms[current] = curPlayer
	
	for realm,_ in pairs(realms) do
		if strsub(realm, (strlen(realm)-7)) == "Alliance" then
			realm = strsub(realm, 1, (strlen(realm)-9))
		end
		if strsub(realm, (strlen(realm)-6)) == "Neutral" then
			realm = strsub(realm, 1, (strlen(realm)-8))
		end
		if strsub(realm, (strlen(realm)-4)) == "Horde" then
			realm = strsub(realm, 1, (strlen(realm)-6))
		end
		if current ~= realm then
			table.insert(private.realmlist, realm)
		end
	end
	return private.realmlist
end

-- Set our defaults
default("arbitrage.profit.min", 1)
default("arbitrage.profit.pct", 50)
default("arbitrage.seen.check", false)
default("arbitrage.seen.min", 10)
default("arbitrage.adjust.brokerage", true)
default("arbitrage.adjust.deposit", true)
default("arbitrage.adjust.listings", 3)
default("arbitrage.allow.bid", true)
default("arbitrage.allow.buy", true)
default("arbitrage.search.crossrealmfaction", "Alliance")
default("arbitrage.search.allrealms", {})
default("arbitrage.search.style", "Cross-Faction")

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")
	gui:MakeScrollable(id)

	-- Add the help
	gui:AddSearcher("Arbitrage", "Find items which can be neutral, cross-faction or cross-realm traded", 100)
	gui:AddHelp(id, "arbitrage searcher",
		"What does this searcher do?",
		"This searcher provides the ability to search for specific items that can be traded to neutral, cross faction or cross realm for a profit.")

	gui:AddControl(id, "Header",     0,      "Arbitrage search criteria")

	local last = gui:GetLast(id)

	gui:AddControl(id, "MoneyFramePinned",  0, 1, "arbitrage.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "arbitrage.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",          0, 1, "arbitrage.seen.check", "Check Seen count")
	gui:AddControl(id, "Slider",            0, 2, "arbitrage.seen.min", 1, 100, 1, "Min seen count: %s")

	gui:AddControl(id, "Subhead",           0,      "Search against")
	gui:AddControl(id, "Selectbox",         0.01, 1, private.getStyles(), "arbitrage.search.style", "Search against")
	gui:AddControl(id, "Subhead",           0.01,      "Cross-Realm:")
	gui:AddControl(id, "Selectbox",         0.02, 1, private.getRealmList(), "arbitrage.search.crossrealmrealm", "Realm")
	gui:AddControl(id, "Selectbox",         0.02, 1, private.getFactions(), "arbitrage.search.crossrealmfaction", "Faction")

	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "arbitrage.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "arbitrage.allow.buy", "Allow Buyouts")

	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "arbitrage.adjust.brokerage", "Subtract auction fees")
	gui:AddControl(id, "Checkbox",          0.42, 1, "arbitrage.adjust.deposit", "Subtract deposit")
	gui:AddControl(id, "Slider",            0.42, 1, "arbitrage.adjust.listings", 1, 10, .1, "Ave relistings: %0.1fx")
end

function lib.Search(item)
	local market, seen, _, curModel, pctstring

	-- Get correct faction to compare against
	local comparefaction,_,factionGroup = AucAdvanced.GetFaction()
	local searchstyle = get("arbitrage.search.style")
	if searchstyle == "Neutral" then
		local unitfaction = UnitFactionGroup("player")
		if (factionGroup == unitfaction) then
			comparefaction = GetRealmName().."-Neutral" --If you're at home, compare to neutral
		else
			comparefaction = GetRealmName().."-"..unitfaction --if you're at neutral, compare to home
		end
	elseif searchstyle == "Cross-Faction" then
		local unitfaction = UnitFactionGroup("player")
		if (factionGroup == unitfaction) then
			local faction = "-Alliance"
			if unitfaction == "Alliance" then faction = "-Horde" end --no need to check against both.  If it isn't one, then it must be the other
			comparefaction = GetRealmName()..faction --If you're at home, compare to cross-faction
		else
			comparefaction = GetRealmName().."-"..unitfaction --if you're at neutral, compare to home
		end
	elseif searchstyle == "Cross-Realm" then
		local crossrealmrealm = get("arbitrage.search.crossrealmrealm")
		if crossrealmrealm then
			local crossrealmfaction = get("arbitrage.search.crossrealmfaction")
			comparefaction = crossrealmrealm.."-"..crossrealmfaction
		else
			comparefaction = AucAdvanced.GetFaction()
		end
	else
		comparefaction = AucAdvanced.GetFaction()
	end

	market, _, _, seen, curModel = AucAdvanced.Modules.Util.Appraiser.GetPrice(item[Const.LINK], comparefaction)

	if not market then
		return false, "No appraiser price"
	end
	market = market * item[Const.COUNT]

	if (get("arbitrage.seen.check")) and curModel ~= "fixed" then
		if ((not seen) or (seen < get("arbitrage.seen.min"))) then
			return false, "Seen count too low"
		end
	end

	--adjust for brokerage/deposit costs
	local deposit = get("arbitrage.adjust.deposit")
	local brokerage = get("arbitrage.adjust.brokerage")
	local sig = AucAdvanced.Modules.Util.Appraiser.GetSigFromLink(item[Const.LINK])
	local duration = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".duration") or AucAdvanced.Settings.GetSetting("util.appraiser.duration")

	if brokerage then
		if string.find(comparefaction, "Neutral") then
			market = market * .85
		else
			market = market * .95
		end
	end
	if deposit then
		local relistings = get("arbitrage.adjust.listings")
		--set up correct brokerage/deposit costs for our target AH
		local newfaction
		if strsub(comparefaction, (strlen(comparefaction)-6)) == "Neutral" then
			newfaction = "neutral"
		end
		local amount = GetDepositCost(item[Const.LINK], (AucAdvanced.Settings.GetSetting("util.appraiser.duration")/60), newfaction, item[Const.COUNT])
		if not amount then
			amount = 0
		else
			amount = amount * relistings
		end
		market = market - amount
	end

	local pct = get("arbitrage.profit.pct")
	local minprofit = get("arbitrage.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	if get("arbitrage.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		return "buy", market
	elseif get("arbitrage.allow.bid") and (item[Const.PRICE] <= value) then
		return "bid", market
	end
	return false, "Not enough profit"--..":"..tostring(comparefaction)..":"..tostring(market)
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-SearchUI/SearcherArbitrage.lua $", "$Rev: 3594 $")
