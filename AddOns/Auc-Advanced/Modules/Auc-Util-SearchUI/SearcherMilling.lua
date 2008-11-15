--[[
	Auctioneer Advanced - Search UI - Searcher Milling
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: SearcherMilling.lua 3657 2008-10-19 18:03:26Z dinesh $
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
local lib, parent, private = AucSearchUI.NewSearcher("Milling")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Milling"
-- Set our defaults
default("milling.profit.min", 1)
default("milling.profit.pct", 50)
default("milling.level.custom", false)
default("milling.level.min", 0)
default("milling.level.max", 375)
default("milling.adjust.brokerage", true)
default("milling.allow.bid", true)
default("milling.allow.buy", true)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")

	-- Add the help
	gui:AddSearcher("Milling", "Search for items which can be milled for profit", 100)
	gui:AddHelp(id, "milling searcher",
		"What does this searcher do?",
		"This searcher provides the ability to search for herbs which will mill into pigments that on average will have a greater value than the purchase price of the original herbs.")

	if not (Enchantrix and Enchantrix.Storage and Enchantrix.Storage.GetItemMillingTotals) then
		gui:AddControl(id, "Header",     0,   "Enchantrix not detected")
		gui:AddControl(id, "Note",    0.3, 1, 290, 30,    "Enchantrix must be enabled to search with Milling")
		return
	end

	gui:AddControl(id, "Header",     0,      "Milling search criteria")

	local last = gui:GetLast(id)

	gui:AddControl(id, "MoneyFramePinned",  0, 1, "milling.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "milling.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",          0, 1, "milling.level.custom", "Use custom levels")
	gui:AddControl(id, "Slider",            0, 2, "milling.level.min", 0, 375, 25, "Minimum skill: %s")
	gui:AddControl(id, "Slider",            0, 2, "milling.level.max", 25, 375, 25, "Maximum skill: %s")

	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "milling.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "milling.allow.buy", "Allow Buyouts")

	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "milling.adjust.brokerage", "Subtract auction fees")

	gui:AddControl(id, "Subhead",           0.42,    "Note:")
	gui:AddControl(id, "Note",              0.42, 1, 290, 30, "The \"Pct\" Column is \% of Milling Value")
end

function lib.Search(item)
	if not (Enchantrix and Enchantrix.Storage and Enchantrix.Storage.GetItemMillingTotals) then
		return false, "Enchantrix not detected"
	end
	if (not get("milling.allow.bid")) and (not item[Const.BUYOUT]) or (item[Const.BUYOUT] == 0) then
		return false, "No buyout"
	end
	if item[Const.QUALITY] ~= 1 then -- All millable herbs are "Common" quality
		return false, "Item not millable"
	end
	
	-- Give up if it doesn't mill to anything
	local pigments = Enchantrix.Storage.GetItemMilling(item[Const.LINK])
	if not pigments then
		return false, "Item not millable"
	end

	local _, market
	local minskill = 0
	local maxskill = 375
	if get("milling.level.custom") then
		minskill = get("milling.level.min")
		maxskill = get("milling.level.max")
	else
		maxskill = Enchantrix.Util.GetUserInscriptionSkill()
	end
	
	local skillneeded = Enchantrix.Util.InscriptionSkillRequiredForItem(item[Const.LINK])
	if (skillneeded < minskill) or (skillneeded > maxskill) then
		return false, "Skill not high enough to mill"
	end

	_, _, _, market = Enchantrix.Storage.GetItemMillingTotals(item[Const.LINK])
	if (not market) or (market == 0) then
		return false, "Item not millable"
	end

	--adjust for stack size
	market = market * item[Const.COUNT]

	--adjust for brokerage costs
	local brokerage = get("milling.adjust.brokerage")

	if brokerage then
		market = market * 0.95
	end
	local pct = get("milling.profit.pct")
	local minprofit = get("milling.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	
	if get("milling.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		return "buy", market
	elseif get("milling.allow.bid") and (item[Const.PRICE] <= value) then
		return "bid", market
	end
	
	return false, "Not enough profit"
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-SearchUI/SearcherMilling.lua $", "$Rev: 3657 $")
