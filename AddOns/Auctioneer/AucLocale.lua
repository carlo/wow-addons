--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucLocale.lua 2451 2007-11-12 23:47:09Z Luke1410 $

	AucLocale
	Functions for localizing Auctioneer
	Thanks to Telo for the LootLink code from which this was based.

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
		You have an implicit licence to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucLocale.lua $", "$Rev: 2451 $")

local Babylonian = LibStub("Babylonian")
assert(Babylonian, "Babylonian is not installed")

local babylonian = Babylonian(AuctioneerLocalizations)

Auctioneer_CustomLocalizations = {
	['TextGeneral'] = GetLocale(),
	['TextCombat'] = GetLocale(),
	['SubTypeBag'] = GetLocale(),
}

function _AUCT(stringKey, locale)
	if (locale) then
		if (type(locale) == "string") then
			return babylonian(locale, stringKey);
		else
			return babylonian(GetLocale(), stringKey);
		end
	elseif (Auctioneer_CustomLocalizations[stringKey]) then
		return babylonian(Auctioneer_CustomLocalizations[stringKey], stringKey)
	else
		return babylonian[stringKey] or stringKey
	end
end

