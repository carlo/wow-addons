local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 40796 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Terestian Illhoof"], BB["Kil'rek"], function(Illhoof)
	function Illhoof:Init()
		self:RegisterCombatant(BB["Kil'rek"], self.clearKilrekThreat)
		self:RegisterCombatant(BB["Terestian Illhoof"], true)
	end

	function Illhoof:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Illhoof:clearKilrekThreat()
		self:WipeRaidThreatOnMob(BB["Kil'rek"])
	end
end)

end