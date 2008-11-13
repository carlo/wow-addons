local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 55218 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Zul'jin"], function(Zuljin)
	Zuljin:RegisterTranslation("enUS", function() return {
		["Got me some new tricks... like me brudda bear...."] = "Got me some new tricks... like me brudda bear....",
		["Dere be no hidin' from da eagle!"] = "Dere be no hidin' from da eagle!",
		["Let me introduce you to me new bruddas: fang and claw!"] = "Let me introduce you to me new bruddas: fang and claw!",
		["Ya don' have to look to da sky to see da dragonhawk!"] = "Ya don' have to look to da sky to see da dragonhawk!",
	} end)

	Zuljin:RegisterTranslation("koKR", function() return {
		["Got me some new tricks... like me brudda bear...."] = "새로운 기술을 익혔지... 내 형제, 곰처럼...",
		["Dere be no hidin' from da eagle!"] = "독수리의 눈을 피할 수는 없다!",
		["Let me introduce you to me new bruddas: fang and claw!"] = "내 새로운 형제, 송곳니와 발톱을 보아라!",
		["Ya don' have to look to da sky to see da dragonhawk!"] = "용매를 하늘에서만 찾을 필요는 없다!",
	} end)

	Zuljin:RegisterTranslation("frFR", function() return {
		["Got me some new tricks... like me brudda bear...."] = "J'ai des nouveaux tours… comme mon frère ours…",
		["Dere be no hidin' from da eagle!"] = "L'aigle, il vous trouvera partout !",
		["Let me introduce you to me new bruddas: fang and claw!"] = "J'vous présente mes nouveaux frères : griffe et croc !",
		["Ya don' have to look to da sky to see da dragonhawk!"] = "Pas besoin d'lever les yeux au ciel pour voir l'faucon-dragon !",
	} end)

	Zuljin:RegisterTranslation("zhTW", function() return {
		["Got me some new tricks... like me brudda bear...."] = "賜給我一些新的力量……讓我像熊一樣……",
		["Dere be no hidin' from da eagle!"] = "在雄鷹之下無所遁形!",
		["Let me introduce you to me new bruddas: fang and claw!"] = "讓我來介紹我的新兄弟:尖牙和利爪!",
		["Ya don' have to look to da sky to see da dragonhawk!"] = "你不需要仰望天空才看得到龍鷹!",
	} end)


	local bear = Zuljin:GetTranslation("Got me some new tricks... like me brudda bear....")
	local eagle = Zuljin:GetTranslation("Dere be no hidin' from da eagle!")
	local lynx = Zuljin:GetTranslation("Let me introduce you to me new bruddas: fang and claw!")
	local dragonhawk = Zuljin:GetTranslation("Ya don' have to look to da sky to see da dragonhawk!")

	Zuljin:UnregisterTranslations()

	local function clear(self)
		self:WipeAllRaidThreat()
	end

	function Zuljin:Init()
		self:RegisterCombatant(BB["Zul'jin"], true)

		self:RegisterChatEvent("yell", BB["Zul'jin"], bear, clear)
		self:RegisterChatEvent("yell", BB["Zul'jin"], eagle, clear)
		self:RegisterChatEvent("yell", BB["Zul'jin"], lynx, clear)
		self:RegisterChatEvent("yell", BB["Zul'jin"], dragonhawk, clear)
	end

	function Zuljin:StartFight()
		self:SetNumberOfMobs(1)
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
