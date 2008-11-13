--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucEventManager.lua 1746 2007-04-24 22:16:19Z luke1410 $

	AucEventManager - Auctioneer eventing system

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
--]]

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucEventManager.lua $", "$Rev: 1746 $")

-------------------------------------------------------------------------------
-- Function Imports
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local registerEvent;
local unregisterEvent;
local fireEvent;
local getListeners;
local debugPrint;

-------------------------------------------------------------------------------
-- Private Data
-------------------------------------------------------------------------------
local EventListeners = {};

-------------------------------------------------------------------------------
-- Registers for an auctioneer event.
-------------------------------------------------------------------------------
function registerEvent(eventName, callbackFunc)
	return table.insert(getListeners(eventName, true), callbackFunc);
end

-------------------------------------------------------------------------------
-- Unregisters for an auctioneer event.
-------------------------------------------------------------------------------
function unregisterEvent(eventName, callbackFunc)
	local listeners = getListeners(eventName);
	if (listeners) then
		for index, thisCallbackFunc in ipairs(listeners) do
			if (thisCallbackFunc == callbackFunc) then
				table.remove(listeners, index);
				if (#listeners == 0) then
					EventListeners[eventName] = nil;
				end
				return;
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Fires an auctioneer event.
-------------------------------------------------------------------------------
function fireEvent(eventName, ...)
	local listeners = getListeners(eventName);
	if (listeners) then
		for index, callbackFunc in ipairs(listeners) do
			callbackFunc(eventName, ...);
		end
	end
end

-------------------------------------------------------------------------------
-- Gets the list of registered listeners for the specified event.
-------------------------------------------------------------------------------
function getListeners(eventName, create)
	local listeners = EventListeners[eventName];
	if (not listeners and create) then
		listeners = {};
		EventListeners[eventName] = listeners;
	end
	return listeners;
end

-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    title     - (string) the title for the debug message
--                nil, no title specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
-------------------------------------------------------------------------------
function debugPrint(message, title, errorCode, level)
	return Auctioneer.Util.DebugPrint(message, "AucEventManager", title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.EventManager = {
	RegisterEvent = registerEvent;
	UnregisterEvent = unregisterEvent;
	FireEvent = fireEvent;
}
