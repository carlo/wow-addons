local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Void Reaver"], function(VoidReaver)
	VoidReaver:RegisterTranslation("enUS", function() return {
		["Knock Away"] = "Knock Away"
	} end)

	VoidReaver:RegisterTranslation("deDE", function() return {
		["Knock Away"] = "Wegschlagen"
	} end)

	VoidReaver:RegisterTranslation("frFR", function() return {
		["Knock Away"] = "Repousser au loin"
	} end)

	VoidReaver:RegisterTranslation("koKR", function() return {
		["Knock Away"] = "날려버리기"
	} end)

	VoidReaver:RegisterTranslation("zhTW", function() return {
		["Knock Away"] = "擊退"
	} end)

	VoidReaver:RegisterTranslation("zhCN", function() return {
		["Knock Away"] = "击退"
	} end)
	
	VoidReaver:RegisterTranslation("esES", function() return {
		["Knock Away"] = "Empujar"
	} end)
	
	local knockAway = VoidReaver:GetTranslation("Knock Away")

	function VoidReaver:Init()
		self:RegisterCombatant(BB["Void Reaver"], true)

		if knockAway then
			self:RegisterModuleVar(knockAway, "VoidReaverKnockbackMultiplier", 0.75)
			self.attacks[knockAway] = function(self, mob, target)
				local multiplier = self:GetModuleVar("VoidReaverKnockbackMultiplier", 0.75)
				self.ModifyThreat(mob, target, multiplier, 0)
			end
		else
			ThreatLib:Debug("Not registering Knock Away for Void Reaver: translation does not exist for %s", GetLocale())
		end
	end

	function VoidReaver:StartFight()
		self:SetNumberOfMobs(1)
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
 