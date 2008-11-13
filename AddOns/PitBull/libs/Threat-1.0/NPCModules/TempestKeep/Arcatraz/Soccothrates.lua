local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Wrath-Scryer Soccothrates"], function(Soccothrates)
	Soccothrates:RegisterTranslation("enUS", function() return {
		["Knock Away"] = "Knock Away"
	} end)

	Soccothrates:RegisterTranslation("deDE", function() return {
		["Knock Away"] = "Wegschlagen"
	} end)

	Soccothrates:RegisterTranslation("frFR", function() return {
		["Knock Away"] = "Repousser au loin"
	} end)

	Soccothrates:RegisterTranslation("koKR", function() return {
		["Knock Away"] = "날려버리기"
	} end)

	Soccothrates:RegisterTranslation("zhTW", function() return {
		["Knock Away"] = "擊退"
	} end)
	
	Soccothrates:RegisterTranslation("zhCN", function() return {
		["Knock Away"] = "击退"
	} end)

	local knockAway = Soccothrates:GetTranslation("Knock Away")

	function Soccothrates:Init()
		self:RegisterCombatant(BB["Wrath-Scryer Soccothrates"], true)

		if knockAway then
			self.attacks[knockAway] = function(self, mob, target) self.ModifyThreat(mob, target, 1, 0) end --his knockaway doesn't reduce threat.
		end
	end

	function Soccothrates:StartFight()
		self:SetNumberOfMobs(1)
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
 