local _G = _G
local tonumber = _G.tonumber
local ipairs = _G.ipairs
local AceLibrary = _G.AceLibrary

local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 49383 $"):match("%d+"))

if not _G.ThreatLib_MINOR_VERSION or MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

MINOR_VERSION = _G.ThreatLib_MINOR_VERSION
_G.ThreatLib_MINOR_VERSION = nil

local ThreatLib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not ThreatLib then
	return
end
local oldLib
if oldMinor then
	oldLib = {}
	for k,v in pairs(ThreatLib) do
		ThreatLib[k] = nil
		oldLib[k] = v
	end
end

function ThreatLib:GetLibraryVersion()
	return MAJOR_VERSION, MINOR_VERSION
end

_G.ThreatLib = ThreatLib
for _,v in ipairs(_G.ThreatLib_funcs) do
	v()
end
_G.ThreatLib_funcs = nil
_G.ThreatLib = nil

local PreUpvalueFixers = ThreatLib.PreUpvalueFixers
ThreatLib.PreUpvalueFixers = nil

local UpvalueFixers = ThreatLib.UpvalueFixers
ThreatLib.UpvalueFixers = nil

for _, v in ipairs(PreUpvalueFixers) do
	v()
end

for _, v in ipairs(UpvalueFixers) do
	v(ThreatLib, oldLib)
end
oldLib = nil

_G.collectgarbage('collect') -- get rid of the old functions and such
