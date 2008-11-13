local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 43260 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Temporus"], function(Temporus)
	local wingBuffet = ThreatLib.L["Wing Buffet"]

	function Temporus:Init()
		self:RegisterCombatant(BB["Temporus"], true)

		if wingBuffet then
			self.attacks[wingBuffet] = function(self, mob, target) self.ModifyThreat(mob, target, 1, 0) end --his knockaway doesn't reduce threat.
		end
	end

	function Temporus:StartFight()
		self:SetNumberOfMobs(1)
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
 