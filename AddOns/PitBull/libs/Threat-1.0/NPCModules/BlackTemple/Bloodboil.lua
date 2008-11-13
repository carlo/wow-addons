local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Gurtogg Bloodboil"], function(Bloodboil)

	Bloodboil:RegisterTranslation("enUS", function() return {
		["Eject"] = "Eject"
	} end)
	Bloodboil:RegisterTranslation("deDE", function() return {
		["Eject"] = "Rauswurf"
	} end)
	Bloodboil:RegisterTranslation("frFR", function() return {
		["Eject"] = "Ejection"
	} end)
	Bloodboil:RegisterTranslation("esES", function() return {
		["Eject"] = nil
	} end)
	Bloodboil:RegisterTranslation("koKR", function() return {
		["Eject"] = "밀쳐내기"
	} end)
	Bloodboil:RegisterTranslation("zhCN", function() return {
		["Eject"] = "弹射"
	} end)
	Bloodboil:RegisterTranslation("zhTW", function() return {
		["Eject"] = "轟擊"
	} end)

	local eject = Bloodboil:GetTranslation("Eject")

	Bloodboil:UnregisterTranslations()

	function Bloodboil:Init()
		self:RegisterCombatant(BB["Gurtogg Bloodboil"], true)
		if eject then
			self:RegisterModuleVar(eject, "EjectMultiplier", 0.75)
			self.attacks[eject] = function(self, mob, target)
				local multiplier = self:GetModuleVar("EjectMultiplier", 0.75)
				ThreatLib:Debug("Got Bloodboil knockback, setting multiplier on my threat: %s", multiplier)
				self.ModifyThreat(mob, target, multiplier, 0)
			end
		else
			ThreatLib:Debug("Not registering Eject for Void Reaver: translation does not exist for %s", GetLocale())
		end
	end

	function Bloodboil:StartFight()
		self:SetNumberOfMobs(1)
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
