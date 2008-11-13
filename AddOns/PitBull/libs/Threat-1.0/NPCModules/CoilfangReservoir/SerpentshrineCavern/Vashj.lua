local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54174 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Lady Vashj"], BB["Coilfang Elite"], BB["Coilfang Strider"], function(Vashj)
	Vashj:RegisterTranslation("enUS", function() return {
		["The time is now! Leave none standing! "] = "The time is now! Leave none standing! ",
		["You may want to take cover. "] = "You may want to take cover. ",
	} end)

	Vashj:RegisterTranslation("koKR", function() return {
		["The time is now! Leave none standing! "] = "때가 왔다! 한 놈도 살려두지 마라!",
		["You may want to take cover. "] = "숨을 곳이나 마련해 둬라!",
	} end)

	Vashj:RegisterTranslation("frFR", function() return {
		["The time is now! Leave none standing! "] = "L'heure est venue ! N'épargnez personne !",
		["You may want to take cover. "] = "Il faudrait peut-être vous mettre à l'abri.",
	} end)

	Vashj:RegisterTranslation("deDE", function() return {
		["The time is now! Leave none standing! "] = "Die Zeit ist gekommen! Lasst keinen am Leben!",
		["You may want to take cover. "] = "You may want to take cover.",
	} end)

	Vashj:RegisterTranslation("zhTW", function() return {
		["The time is now! Leave none standing! "] = "機會來了!一個活口都不要留下!",
		["You may want to take cover. "] = "你們最好找掩護。",
	} end)

	Vashj:RegisterTranslation("zhCN", function() return {
		["The time is now! Leave none standing! "] = "机会来了！一个活口都不要留下！",
		["You may want to take cover. "] = "你们最好找掩护。",
	} end)
	
	local phase2 = Vashj:GetTranslation("The time is now! Leave none standing! ")
	local phase3 = Vashj:GetTranslation("You may want to take cover. ")

	Vashj:UnregisterTranslations()

	function Vashj:Init()
		self:RegisterCombatant(BB["Lady Vashj"], true)
		self:RegisterCombatant(BB["Coilfang Elite"], self.eliteDeath)
		self:RegisterCombatant(BB["Coilfang Strider"], self.striderDeath)

		self:RegisterChatEvent("yell", BB["Lady Vashj"], phase2, self.Phase)
		self:RegisterChatEvent("yell", BB["Lady Vashj"], phase3, self.Phase)
	end

	function Vashj:StartFight()
		-- SetNumberOfMobs is used as a divisor for global threat. Be sure to set it correctly, and to account for mob deaths during the fight
		-- If you are unsure of the participants, or you want to just be safe, leave this at 1
		self:SetNumberOfMobs(1)
	end

	function Vashj:Phase()
		self:WipeRaidThreatOnMob(BB["Lady Vashj"])
	end

	function Vashj:eliteDeath()
		self:WipeRaidThreatOnMob(BB["Coilfang Elite"])
	end

	function Vashj:striderDeath()
		self:WipeRaidThreatOnMob(BB["Coilfang Strider"])
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
