local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54286 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Kael'thas Sunstrider"], BB["Thaladred the Darkener"], BB["Lord Sanguinar"], BB["Grand Astromancer Capernian"], BB["Master Engineer Telonicus"], function(Kaelthas)

	Kaelthas:RegisterTranslation("enUS", function() return {
		["Impressive. Let us see how your nerves hold up against the Darkener, Thaladred! "] = true,
		["You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!"] = true,
		["Capernian will see to it that your stay here is a short one."] = true,
		["Well done, you have proven worthy to test your skills against my master engineer, Telonicus."] = true,
		["Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor."] = true,
		["As you see, I have many weapons in my arsenal...."] = true,
		["Alas, sometimes one must take matters into one's own hands. Balamore shanal!"] = true,
	} end)

	Kaelthas:RegisterTranslation("deDE", function() return {
		["Impressive. Let us see how your nerves hold up against the Darkener, Thaladred! "] = "Eindrucksvoll. Aber werdet Ihr auch mit Thaladred, dem Verfinsterer fertig?",
		["You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!"] = "Ihr habt gegen einige meiner besten Berater bestanden... aber niemand kommt gegen die Macht des Bluthammers an. Zittert vor F\195\188rst Blutdurst!",
		["Capernian will see to it that your stay here is a short one."] = "Capernian wird daf\195\188r sorgen, dass Euer Aufenthalt hier nicht lange w\195\164hrt.",
		["Well done, you have proven worthy to test your skills against my master engineer, Telonicus."] = "Gut gemacht. Ihr habt Euch w\195\188rdig erwiesen, gegen meinen Meisteringenieur, Telonicus, anzutreten.",
		["Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor."] = "Vielleicht habe ich Euch untersch\195\164tzt. Es w\195\164re unfair, Euch gegen meine vier Berater gleichzeitig k\195\164mpfen zu lassen, aber... mein Volk wurde auch nie fair behandelt. Ich vergelte nur Gleiches mit Gleichem.",
		["As you see, I have many weapons in my arsenal...."] = "Wie Ihr seht, habe ich viele Waffen in meinem Arsenal...",
		["Alas, sometimes one must take matters into one's own hands. Balamore shanal!"] = "Ach, manchmal muss man die Sache selbst in die Hand nehmen. Balamore shanal!",
	} end)

	Kaelthas:RegisterTranslation("frFR", function() return {
		["Impressive. Let us see how your nerves hold up against the Darkener, Thaladred! "] = "Impressionnant. Voyons comment tiendront vos nerfs face à l'Assombrisseur, Thaladred !",
		["You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!"] = "Vous avez tenu tête à certains de mes plus talentueux conseillers… Mais personne ne peut résister à la puissance du Marteau de sang. Je vous présente le seigneur Sanguinar !",
		["Capernian will see to it that your stay here is a short one."] = "Capernian fera en sorte que votre séjour ici ne se prolonge pas.",
		["Well done, you have proven worthy to test your skills against my master engineer, Telonicus."] = "Bien, vous êtes dignes de mesurer votre talent à celui de mon maître ingénieur, Telonicus.",
		["Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor."] = "Peut-être vous ai-je sous-estimés. Il ne serait pas très loyal de vous faire combattre mes quatre conseillers en même temps, mais… mon peuple n'a jamais été traité avec loyauté. Je ne fais que rendre la politesse.",
		["As you see, I have many weapons in my arsenal...."] = "Comme vous le voyez, j'ai plus d'une corde à mon arc…",
		["Alas, sometimes one must take matters into one's own hands. Balamore shanal!"] = "Il est hélas parfois nécessaire de prendre les choses en main soi-même. Balamore shanal !",
	} end)

	Kaelthas:RegisterTranslation("koKR", function() return {
		["Impressive. Let us see how your nerves hold up against the Darkener, Thaladred! "] = "암흑의 인도자 탈라드레드를 상대로 얼마나 버틸지 볼까?",
		["You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!"] = "최고의 조언가를 상대로 잘도 버텨냈군. 허나 그 누구도 붉은 망치의 힘에는 대항할 수 없지. 보아라, 군주 생귀나르를!",
		["Capernian will see to it that your stay here is a short one."] = "카퍼니안, 놈들이 여기 온 것을 후회하게 해 줘라.",
		["Well done, you have proven worthy to test your skills against my master engineer, Telonicus."] = "좋아, 그 정도 실력이면 수석기술자 텔로니쿠스를 상대해 볼만하겠어.",
		["Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor."] = "네놈들을 과소평가했나 보군. 모두를 한꺼번에 상대하라는 건 불공평한 처사지만, 나의 백성도 공평한 대접을 받은 적 없기는 매한가지. 받은 대로 돌려주겠다.",
		["As you see, I have many weapons in my arsenal...."] = "보다시피 내 무기고에는 굉장한 무기가 아주 많지.",
		["Alas, sometimes one must take matters into one's own hands. Balamore shanal!"] = "때론 직접 나서야 할 때도 있는 법이지. 발라모어 샤날!",
	} end)

	Kaelthas:RegisterTranslation("zhTW", function() return {
		["Impressive. Let us see how your nerves hold up against the Darkener, Thaladred! "] = "了不起。讓我們看看你們這些大膽的狂徒如何反抗扭曲預言家薩拉瑞德的力量!",
		["You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!"] = "你已經努力的打敗了我的幾位最忠誠的諫言者…但是沒有人可以抵抗血錘的力量。等著看桑古納爾的力量吧!",
		["Capernian will see to it that your stay here is a short one."] = "卡普尼恩將保證你們不會在這裡停留太久。",
		["Well done, you have proven worthy to test your skills against my master engineer, Telonicus."] = "做得好，你已經證明你的實力足以挑戰我的工程大師泰隆尼卡斯。",
		["Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor."] = "也許我低估了你。要你一次對付四位諫言者也許對你來說是不太公平，但是……我的人民從未得到公平的對待。我只是以牙還牙而已。",
		["As you see, I have many weapons in my arsenal...."] = "你們看，我的個人收藏中有許多武器……",
		["Alas, sometimes one must take matters into one's own hands. Balamore shanal!"] = "唉，有些時候，有些事情，必須得親自解決才行。(薩拉斯語)受死吧!",
	} end)
	
	Kaelthas:RegisterTranslation("zhCN", function() return {
		["Impressive. Let us see how your nerves hold up against the Darkener, Thaladred! "] = "让我们来看看你们如何面对亵渎者萨拉德雷！",
		["You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!"] = "你们击败了我最强大的顾问……但是没有人能战胜鲜血之锤。出来吧，萨古纳尔男爵！",
		["Capernian will see to it that your stay here is a short one."] = "卡波妮娅会很快解决你们的。",
		["Well done, you have proven worthy to test your skills against my master engineer, Telonicus."] = "干得不错。看来你们有能力挑战我的首席技师，塔隆尼库斯。",
		["Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor."] = "也许我确实低估了你们。虽然让你们同时面对我的四位顾问显得有些不公平，但是我的人民从来都没有得到过公平的待遇。我只是在以牙还牙。",
		["As you see, I have many weapons in my arsenal...."] = "你们看，我的个人收藏中有许多武器……",
		["Alas, sometimes one must take matters into one's own hands. Balamore shanal!"] = "唉，有些时候，有些事情，必须得亲自解决才行。Balamore shanal！",
	} end)

	local thaladredTrigger = Kaelthas:GetTranslation("Impressive. Let us see how your nerves hold up against the Darkener, Thaladred! ")
	local sanguinarTrigger = Kaelthas:GetTranslation("You have persevered against some of my best advisors... but none can withstand the might of the Blood Hammer. Behold, Lord Sanguinar!")
	local capernianTrigger = Kaelthas:GetTranslation("Capernian will see to it that your stay here is a short one.")
	local telonicusTrigger = Kaelthas:GetTranslation("Well done, you have proven worthy to test your skills against my master engineer, Telonicus.")
	local allAdvisorsTrigger = Kaelthas:GetTranslation("Perhaps I underestimated you. It would be unfair to make you fight all four advisors at once, but... fair treatment was never shown to my people. I'm just returning the favor.")
	local weaponTrigger = Kaelthas:GetTranslation("As you see, I have many weapons in my arsenal....")
	local kaelTrigger = Kaelthas:GetTranslation("Alas, sometimes one must take matters into one's own hands. Balamore shanal!")

	Kaelthas:UnregisterTranslations()

	local advisorDeathCount = 0
	local weaponDeathCount = 0

	function Kaelthas:Init()
		self:RegisterCombatant(BB["Kael'thas Sunstrider"], true)
		self:RegisterCombatant(BB["Thaladred the Darkener"], self.advisorDeath)
		self:RegisterCombatant(BB["Lord Sanguinar"], self.advisorDeath)
		self:RegisterCombatant(BB["Grand Astromancer Capernian"], self.advisorDeath)
		self:RegisterCombatant(BB["Master Engineer Telonicus"], self.advisorDeath)

		self:RegisterCombatant(BB["Devastation"], self.weaponDeath)
		self:RegisterCombatant(BB["Cosmic Infuser"], self.weaponDeath)
		self:RegisterCombatant(BB["Infinity Blades"], self.weaponDeath)
		self:RegisterCombatant(BB["Staff of Disintegration"], self.weaponDeath)
		self:RegisterCombatant(BB["Warp Slicer"], self.weaponDeath)
		self:RegisterCombatant(BB["Netherstrand Longbow"], self.weaponDeath)
		self:RegisterCombatant(BB["Phaseshift Bulwark"], self.weaponDeath)

		self:RegisterChatEvent("yell", BB["Kael'thas Sunstrider"], thaladredTrigger, self.advisorTransition)
		self:RegisterChatEvent("yell", BB["Kael'thas Sunstrider"], sanguinarTrigger, self.advisorTransition)
		self:RegisterChatEvent("yell", BB["Kael'thas Sunstrider"], capernianTrigger, self.advisorTransition)
		self:RegisterChatEvent("yell", BB["Kael'thas Sunstrider"], telonicusTrigger, self.advisorTransition)
		self:RegisterChatEvent("yell", BB["Kael'thas Sunstrider"], weaponTrigger, self.weaponTransition)
		self:RegisterChatEvent("yell", BB["Kael'thas Sunstrider"], allAdvisorsTrigger, self.allAdvisorTransition)
		self:RegisterChatEvent("yell", BB["Kael'thas Sunstrider"], kaelTrigger, self.kaelTransition)
	end

	function Kaelthas:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Kaelthas:advisorDeath(victimName, killerName)
		-- self:WipeRaidThreatOnMob(victimName)
		self:SetNumberOfMobs(self:GetNumberOfMobs() - 1)
		advisorDeathCount = advisorDeathCount + 1
	end

	function Kaelthas:weaponDeath(victimName, killerName)
		-- self:WipeRaidThreatOnMob(victimName)
		self:SetNumberOfMobs(self:GetNumberOfMobs() - 1)
		weaponDeathCount = weaponDeathCount + 1
	end

	function Kaelthas:advisorTransition()
		self:SetNumberOfMobs(1)
		self:WipeAllRaidThreat()
	end

	function Kaelthas:weaponTransition()
		self:WipeAllRaidThreat()
		self:SetNumberOfMobs(7)
		weaponDeathCount = 0
	end

	function Kaelthas:allAdvisorTransition()
		if weaponDeathCount == 7 then
			self:SetNumberOfMobs(4)
			self:WipeAllRaidThreat()
		else
			self:SetNumberOfMobs(self:GetNumberOfMobs() + 4)
			self:WipeRaidThreatOnMob(BB["Thaladred the Darkener"])
			self:WipeRaidThreatOnMob(BB["Lord Sanguinar"])
			self:WipeRaidThreatOnMob(BB["Grand Astromancer Capernian"])
			self:WipeRaidThreatOnMob(BB["Master Engineer Telonicus"])
		end
		advisorDeathCount = 0
	end

	function Kaelthas:kaelTransition()
		if weaponDeathCount == 7 and advisorDeathCount == 4 then
			self:SetNumberOfMobs(1)
			self:WipeAllRaidThreat()
		else
			self:SetNumberOfMobs(self:GetNumberOfMobs() + 1)
			self:WipeRaidThreatOnMob(BB["Kael'thas Sunstrider"])
		end
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end