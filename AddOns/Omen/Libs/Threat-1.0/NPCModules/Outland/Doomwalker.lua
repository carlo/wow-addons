local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Doomwalker"], function(Doomwalker)
	Doomwalker:RegisterTranslation("enUS", function() return {
		["Engage maximum speed."] = "Engage maximum speed.",
		["Trajectory locked."] = "Trajectory locked."
	} end)

	Doomwalker:RegisterTranslation("deDE", function() return {
		["Engage maximum speed."] = nil,
		["Trajectory locked."] = nil
	} end)

	Doomwalker:RegisterTranslation("frFR", function() return {
		["Engage maximum speed."] = "Vitesse maximale enclenchée.",
		["Trajectory locked."] = "Trajectoire verrouillée."
	} end)

	Doomwalker:RegisterTranslation("koKR", function() return {
		["Engage maximum speed."] = "전속력 추진.",
		["Trajectory locked."] = "경로 설정 완료." -- Check
	} end)

	Doomwalker:RegisterTranslation("zhTW", function() return {
		["Engage maximum speed."] = "啟用最大速度。",
		["Trajectory locked."] = "軌道鎖定。"
	} end)
	
	Doomwalker:RegisterTranslation("zhCN", function() return {
		["Engage maximum speed."] = "提升至最高速度。",
		["Trajectory locked."] = "轨道锁定。"
	} end)

	local overrun = Doomwalker:GetTranslation("Engage maximum speed.")
	local overrun2 = Doomwalker:GetTranslation("Trajectory locked.")
	Doomwalker:UnregisterTranslations()

	function Doomwalker:Init()
		self:RegisterCombatant(BB["Doomwalker"], true)
		self:RegisterChatEvent("yell", BB["Doomwalker"], overrun, self.Overrun)
		self:RegisterChatEvent("yell", BB["Doomwalker"], overrun2, self.Overrun)
	end
	
	function Doomwalker:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Doomwalker:Overrun()
		self:WipeRaidThreatOnMob(BB["Doomwalker"])
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
