--[[
	Auctioneer Advanced - VendMarkup
	Version: 5.1.3824 (SnaggleTooth)
	Revision: $Id: vendMarkup.lua 3576 2008-10-10 03:07:13Z aesir $
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

local libType, libName = "Util", "VendMarkup"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

function lib.GetPrice(hyperlink, faction, realm)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end

	if (itemId and itemId > 0) and (type(GetSellValue) == "function") then
		local vendorFor = GetSellValue(itemId)
		if not vendorFor then return end
		local multiplier = AucAdvanced.Settings.GetSetting("util.vendmarkup.multiplier") / 100
		vendorFor = vendorFor * multiplier
		return vendorFor
	end
end

function lib.GetPriceColumns()
	return "Vendor Price Markup"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	-- Clean out the old array
	while (#array > 0) do table.remove(array) end

	-- Get our statistics
	local vendorPrice = lib.GetPrice(hyperlink, faction, realm)

	-- These 2 are the ones that most algorithms will look for
	array.price = vendorPrice

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function lib.Processor(callbackType, ...)
	if callbackType == "config" then
		private.SetupConfigGui(...)
	end
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("util.vendmarkup.multiplier", 300)
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function

	local id = gui:AddTab(libName, libType.." Modules")

	gui:AddHelp(id, "what vendmarkup",
		"What is the Vendor Markup module?",
		"This module will give you the price to vendor an item multiplied by a percentage of that vendor's price to give you the vendor markup price.\n"..
		"This vendor markup is most often used when posting items for auction which do not have any data, you can tell Appraiser to use the vendor markup for the buyout price, and that will give you a good starting point for what the item might sell for.\n")

	gui:AddControl(id, "Header",     0, libName.." options")

	gui:AddControl(id, "TinyNumber", 0, 1, "util.vendmarkup.multiplier" or 300, 100, 1000, "Vendor markup (in percent)")

end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.1.x_WotLK_Release/Auc-Util-VendMarkup/vendMarkup.lua $", "$Rev: 3576 $")
