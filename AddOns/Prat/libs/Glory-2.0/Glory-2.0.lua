--[[
Name: Glory-2.0
Revision: $Rev: 55588 $
Author(s): ckknight (ckknight@gmail.com)
           Elkano (elkano@gmx.de)
           hyperactiveChipmunk (hyperactiveChipmunk@gmail.com)
Website: http://ckknight.wowinterface.com/
Documentation: http://www.wowace.com/wiki/Glory-2.0
SVN: http://svn.wowace.com/wowace/trunk/GloryLib/Glory-2.0
Description: A library for PvP and Battlegrounds.
Dependencies: AceLibrary, Babble-Zone-2.2, Deformat-2.0, AceEvent-2.0, AceConsole-2.0 (optional)
License: LGPL v2.1

Notes: To use this library, the per-character saved variable Glory2DB must be available.
]]

local MAJOR_VERSION = "Glory-2.0"
local MINOR_VERSION = "$Revision: 55588 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("Babble-Zone-2.2") then error(MAJOR_VERSION .. " requires Babble-Zone-2.2") end
if not AceLibrary:HasInstance("Deformat-2.0") then error(MAJOR_VERSION .. " requires Deformat-2.0") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

local new, del
do
	local list = setmetatable({}, {__mode="k"})
	function new()
		local t = next(list)
		if t then
			list[t] = nil
			return t
		else
			return {}
		end
	end
	function del(t)
		setmetatable(t, nil)
		for k in pairs(t) do
			t[k] = nil
		end
		list[t] = true
	end
end

local PATTERN_HORDE_FLAG_PICKED_UP, PATTERN_HORDE_FLAG_DROPPED, PATTERN_HORDE_FLAG_CAPTURED, PATTERN_ALLIANCE_FLAG_PICKED_UP, PATTERN_ALLIANCE_FLAG_DROPPED, PATTERN_ALLIANCE_FLAG_CAPTURED, FACTION_DEFILERS, FACTION_FROSTWOLF_CLAN, FACTION_WARSONG_OUTRIDERS, FACTION_LEAGUE_OF_ARATHOR, FACTION_STORMPIKE_GUARD, FACTION_SILVERWING_SENTINELS

local PATTERN_GWSUII_SCORE, PATTERN_GWSUII_BASES
local BGObjectiveDescriptions, BGChatAnnouncements, BGPatternReplacements, BGAcronyms, BattlefieldZoneObjectiveTimes, BattlefieldZoneResourceData --hC

local deformat = AceLibrary("Deformat-2.0")
local Z = AceLibrary("Babble-Zone-2.2")
local AceEvent = AceLibrary("AceEvent-2.0")

local WARSONG_GULCH = Z["Warsong Gulch"]
local ALTERAC_VALLEY = Z["Alterac Valley"]
local ARATHI_BASIN = Z["Arathi Basin"]
local EYE_OF_THE_STORM = Z["Eye of the Storm"]


local BGBattleGroups, BGServerType, BGServerBattleGroup
if GetCVar("realmList"):match("eu") then
	BGBattleGroups = {
		["Blackout"] = "1",
		["Bloodlust"] = "2",
		["Cyclone"] = "3", 
		["Conviction"] ="4",
		["Rampage"] = "5",
		["Reckoning"] = "6",
		["Ruin"] = "7",
		["Misery"] = "8",
		["Nightfall"] = "9",
	}
	BGServerBattleGroup = {
		["Aerie Peak"] = "8",
		["Agamaggan"] = "1",
		["Aggramar"] = "1",
		["Al'Akir"] = "1",
		["Alonsus"] = "9",
		["Ahn'Qiraj"] = "6",
		["Arathor"] = "1",
		["Argent Dawn"] = "2",
		["Aszune"] = "1",
		["Azjol-Nerub"] = "1",
		["Balnazzar"] = "4",
		["Bladefist"] = "1",
		["Bloodfeather"] = "5",
		["Bloodhoof"] = "1",
		["Bloodscalp"] = "1",
		["Boulderfist"] = "8",
		["Bronzebeard"] = "6",
		["Burning Blade"] = "1",
		["Burning Legion"] = "2",
		["Burning Steppes"] = "9",
		["Chromaggus"] = "6",
		["Crushridge"] = "2",
		["Daggerspine"] = "2",
		["Darkmoon Faire"] = "9",
		["Darkspear"] = "9",
		["Darksorrow"] = "5",
		["Deathwing"] = "2",
		["Defias Brotherhood"] = "5",
		["Dentarg"] = "6",
		["Doomhammer"] = "1",
		["Draenor"] = "1",
		["Dragonblight"] = "1",
		["Dragonmaw"] = "2",
		["Drak'thul"] = "6",
		["Dunemaul"] = "2",
		["Earthen Ring"] = "3",
		["Emerald Dream"] = "1",
		["Emeriss"] = "6",
		["Eonar"] = "8",
		["Executus"] = "6",
		["Frostmane"] = "8",
		["Frostwhisper"] = "5",
		["Genjuros"] = "4",
		["Grim Batol"] = "8",
		["Hakkar"] = "7",
		["Haomarush"] = "5",
		["Hellscream"] = "4",
		["Jaedenar"] = "8",
		["Kazzak"] = "8",
		["Khadgar"] = "6",
		["Kilrogg"] = "8",
		["Kor'gall"] = "9",
		["Kul Tiras"] = "6",
		["Laughing Skull"] = "4",
		["Lightbringer"] = "9",
		["Lightning's Blade"] = "5",
		["Magtheridon"] = "4",
		["Mazrigos"] = "6",
		["Moonglade"] = "6",
		["Neptulon"] = "5",
		["Nordrassil"] = "4",
		["Outland"] = "8",
		["Quel'Thalas"] = "4",
		["Ragnaros"] = "5",
		["Ravencrest"] = "3",
		["Ravenholdt"] = "8",
		["Runetotem"] = "3",
		["Scarshield Legion"] = "7",
		["Shadow Moon"] = "3",
		["Shadowsong"] = "3",
		["Shattered Hand"] = "3",
		["Silvermoon"] = "3",
		["Skullcrusher"] = "3",
		["Spinebreaker"] = "3",
		["Steamwheedle Cartel"] = "7",
		["Stonemaul"] = "8",
		["Stormrage"] = "3",
		["Stormreaver"] = "3",
		["Stormscale"] = "3",
		["Sunstrider"] = "1",
		["Sylvanas"] = "5",
		["Talnivarr"] = "6",
		["Tarren Mill"] = "8",
		["Terenas"] = "3",
		["The Maelstrom"] = "5",
		["The Venture Co."] = "5",
		["Thunderhorn"] = "3",
		["Trollbane"] = "6",
		["Turalyon"] = "3",
		["Twilight's Hammer"] = "1",
		["Twisting Nether"] = "5",
		["Vashj"] = "5",
		["Vek'nilash"] = "8",
		["Warsong"] = "1",
		["Wildhammer"] = "8",
		["Xavius"] = "7",
		["Zenedar"] = "1",
	}
	BGServerType = {
		["Aerie Peak"] = "Normal",
		["Agamaggan"] = "PvP",
		["Aggramar"] = "Normal",
		["Al'Akir"] = "PvP",
		["Alonsus"] = "Normal",
		["Ahn'Qiraj"] = "PvP",
		["Arathor"] = "Normal",
		["Argent Dawn"] = "RP",
		["Aszune"] = "Normal",
		["Azjol-Nerub"] = "Normal",
		["Balnazzar"] = "PvP",
		["Bladefist"] = "PvP",
		["Bloodfeather"] = "PvP",
		["Bloodhoof"] = "Normal",
		["Bloodscalp"] = "PvP",
		["Boulderfist"] = "PvP",
		["Bronzebeard"] = "Normal",
		["Burning Blade"] = "PvP",
		["Burning Legion"] = "PvP",
		["Burning Steppes"] = "PvP",
		["Chromaggus"] = "PvP",
		["Crushridge"] = "PvP",
		["Daggerspine"] = "PvP",
		["Darkmoon Faire"] = "RP",
		["Darkspear"] = "Normal",
		["Darksorrow"] = "PvP",
		["Deathwing"] = "PvP",
		["Defias Brotherhood"] = "RP-PvP",
		["Dentarg"] = "PvP",
		["Doomhammer"] = "Normal",
		["Draenor"] = "Normal",
		["Dragonblight"] = "Normal",
		["Dragonmaw"] = "PvP",
		["Drak'thul"] = "PvP",
		["Dunemaul"] = "PvP",
		["Earthen Ring"] = "RP",
		["Emerald Dream"] = "Normal",
		["Emeriss"] = "PvP",
		["Eonar"] = "Normal",
		["Executus"] = "PvP",
		["Frostmane"] = "PvP",
		["Frostwhisper"] = "PvP",
		["Genjuros"] = "PvP",
		["Grim Batol"] = "PvP",
		["Hakkar"] = "PvP",
		["Haomarush"] = "PvP",
		["Hellscream"] = "Normal",
		["Jaedenar"] = "PvP",
		["Kazzak"] = "PvP",
		["Khadgar"] = "Normal",
		["Kilrogg"] = "Normal",
		["Kor'gall"] = "PvP",
		["Kul Tiras"] = "Normal",
		["Laughing Skull"] = "PvP",
		["Lightbringer"] = "Normal",
		["Lightning's Blade"] = "PvP",
		["Magtheridon"] = "PvP",
		["Mazrigos"] = "PvP",
		["Moonglade"] = "RP",
		["Neptulon"] = "PvP",
		["Nordrassil"] = "Normal",
		["Outland"] = "PvP",
		["Quel'Thalas"] = "Normal",
		["Ragnaros"] = "PvP",
		["Ravencrest"] = "PvP",
		["Ravenholdt"] = "RP-PvP",
		["Runetotem"] = "Normal",
		["Scarshield Legion"] = "RP-PvP",
		["Shadow Moon"] = "PvP",
		["Shadowsong"] = "Normal",
		["Shattered Hand"] = "PvP",
		["Silvermoon"] = "Normal",
		["Skullcrusher"] = "PvP",
		["Spinebreaker"] = "PvP",
		["Steamwheedle Cartel"] = "RP",
		["Stonemaul"] = "PvP",
		["Stormrage"] = "Normal",
		["Stormreaver"] = "PvP",
		["Stormscale"] = "PvP",
		["Sunstrider"] = "PvP",
		["Sylvanas"] = "PvP",
		["Talnivarr"] = "PvP",
		["Tarren Mill"] = "PvP",
		["Terenas"] = "Normal",
		["The Maelstrom"] = "PvP",
		["The Venture Co."] = "RP-PvP",
		["Thunderhorn"] = "Normal",
		["Trollbane"] = "PvP",
		["Turalyon"] = "Normal",
		["Twilight's Hammer"] = "PvP",
		["Twisting Nether"] = "PvP",
		["Vashj"] = "PvP",
		["Vek'nilash"] = "PvP",
		["Warsong"] = "PvP",
		["Wildhammer"] = "Normal",
		["Xavius"] = "PvP",
		["Zenedar"] = "PvP",
	}
elseif GetCVar("realmList"):match("ko") then
	BGBattleGroups = {
		["격노의 전장"] = "1",
		["징벌의 전장"] = "2",
		["야성의 전장"] = "3",
		["비호의 전장"] = "4",
	}
	BGServerBattleGroup = {
		["가로나"] = "1",
		["굴단"] = "2",
		["노르간논"] = "2",
		["달라란"] = "1",
		["데스윙"] = "3",
		["둠해머"] = "2",
		["듀로탄"] = "2",
		["드레노어"] = "1",
		["라그나로스"] = "1",
		["레인"] = "3",
		["렉사르"] = "3",
		["말리고스"] = "2",
		["말퓨리온"] = "1",
		["메디브"] = "2",
		["메카나르"] = "4",
		["무라딘"] = "2",
		["불타는 군단"] = "1",
		["블랙무어"] = "3",
		["블러드후프"] = "2",
		["세나리우스"] = "3",
		["스톰레이지"] = "3",
		["신록의 정원"] = "4",
		["실바나스"] = "2",
		["실버문"] = "1",
		["아스준"] = "2",
		["아즈샤라"] = "2",
		["알레리아"] = "2",
		["알렉스트라자"] = "1",
		["알카트라즈"] = "4",
		["에이그윈"] = "2",
		["엘룬"] = "3",
		["와일드해머"] = "3",
		["우서"] = "1",
		["윈드러너"] = "2",
		["이오나"] = "3",
		["줄진"] = "3",
		["카라잔"] = "3",
		["카르가스"] = "1",
		["캘타스"] = "3",
		["쿨 티라스"] = "3",
		["킬로그"] = "2",
		["티리온"] = "1",
		["폭풍우 요새"] = "4",
		["하이잘"] = "3",
		["헬스크림"] = "1",
	}
	BGServerType = {
		["가로나"] = "PvP",
		["굴단"] = "PvP",
		["노르간논"] = "PvP",
		["달라란"] = "PvP",
		["데스윙"] = "PvP",
		["둠해머"] = "PvP",
		["듀로탄"] = "PvP",
		["드레노어"] = "PvP",
		["라그나로스"] = "PvP",
		["레인"] = "PvP",
		["렉사르"] = "Normal",
		["말리고스"] = "PvP",
		["말퓨리온"] = "PvP",
		["메디브"] = "PvP",
		["메카나르"] = "PvP",
		["무라딘"] = "Normal",
		["불타는 군단"] = "Normal",
		["블랙무어"] = "PvP",
		["블러드후프"] = "Normal",
		["세나리우스"] = "PvP",
		["스톰레이지"] = "Normal",
		["신록의 정원"] = "PvP",
		["실바나스"] = "PvP",
		["실버문"] = "Normal",
		["아스준"] = "PvP",
		["아즈샤라"] = "PvP",
		["알레리아"] = "PvP",
		["알렉스트라자"] = "PvP",
		["알카트라즈"] = "PvP",
		["에이그윈"] = "PvP",
		["엘룬"] = "PvP",
		["와일드해머"] = "Normal",
		["우서"] = "PvP",
		["윈드러너"] = "Normal",
		["이오나"] = "PvP",
		["줄진"] = "PvP",
		["카라잔"] = "PvP",
		["카르가스"] = "PvP",
		["캘타스"] = "PvP",
		["쿨 티라스"] = "PvP",
		["킬로그"] = "PvP",
		["티리온"] = "PvP",
		["폭풍우 요새"] = "PvP",
		["하이잘"] = "PvP",
		["헬스크림"] = "PvP",
	}
elseif GetCVar("realmList"):match("tw") then
	BGBattleGroups = {
		["嗜血"] = "1",
		["暴怒"] = "2",
	}
	BGServerBattleGroup = {
		["霜之哀傷"] = "2",
		["諾姆瑞根"] = "2",
		["戰歌"] = "1",
		["血頂部族"] = "1",
		["寒冰皇冠"] = "2",
		["阿薩斯"] = "2",
		["眾星之子"] = "2",
		["銀翼要塞"] = "2",
		["憤怒使者"] = "2",
		["聖光之願"] = "2",
		["夜空之歌"] = "2",
		["暴風祭壇"] = "2",
		["血之谷"] = "2",
		["亞雷戈斯"] = "2",
		["語風"] = "2",
		["奧妮克希亞"] = "2",
		["鬼霧峰"] = "2",
		["屠魔山谷"] = "2",
		["米奈希爾"] = "1",
		["冰風崗哨"] = "1",
		["狂熱之刃"] = "1",
		["巴納札爾"] = "1",
		["水晶之刺"] = "1",
		["天空之牆"] = "1",
		["世界之樹"] = "1",
		["雷鱗"] = "1",
		["巨龍之喉"] = "1",
		["冰霜之刺"] = "1",
		["日落沼澤"] = "1",
		["地獄吼"] = "1",
		["暗影之月"] = "1",
		["尖石"] = "1",
	}
	BGServerType = {
		["霜之哀傷"] = "PvP",
		["諾姆瑞根"] = "PvP",
		["戰歌"] = "PvP",
		["血頂部族"] = "PvP",
		["寒冰皇冠"] = "PvP",
		["阿薩斯"] = "PvP",
		["眾星之子"] = "Normal",
		["銀翼要塞"] = "PvP",
		["憤怒使者"] = "PvP",
		["聖光之願"] = "Normal",
		["夜空之歌"] = "PvP",
		["暴風祭壇"] = "Normal",
		["血之谷"] = "PvP",
		["亞雷戈斯"] = "Normal",
		["語風"] = "Normal",
		["奧妮克希亞"] = "Normal",
		["鬼霧峰"] = "PvP",
		["屠魔山谷"] = "PvP",
		["米奈希爾"] = "PvP",
		["冰風崗哨"] = "PvP",
		["狂熱之刃"] = "PvP",
		["巴納札爾"] = "Normal",
		["水晶之刺"] = "PvP",
		["天空之牆"] = "Normal",
		["世界之樹"] = "Normal",
		["雷鱗"] = "PvP",
		["巨龍之喉"] = "PvP",
		["冰霜之刺"] = "PvP",
		["日落沼澤"] = "PvP",
		["地獄吼"] = "PvP",
		["暗影之月"] = "Normal",
		["尖石"] = "PvP",
	}
else
	BGBattleGroups = {
		["Bloodlust"] = "1",
		["Cataclysm"] = "2",
		["Cyclone"] = "3",
		["Emberstorm"] = "4",
		["Frenzy"] = "5",
		["Nightfall"] = "6",
		["Rampage"] = "7",
		["Reckoning"] = "8",
		["Ruin"] = "9",
		["Shadowburn"] = "10",
		["Stormstrike"] = "11",
		["Vengeance"] = "12",
		["Vindication"] = "13",
		["Whirlwind"] = "14",
	}
	BGServerBattleGroup = {
		["Aegwynn"] = "12",
		["Aerie Peak"] = "6",
		["Agamaggan"] = "10",
		["Aggramar"] = "13",
		["Akama"] = "12",
		["Alexstrasza"] = "7",
		["Alleria"] = "7",
		["Altar of Storms"] = "6",
		["Alterac Mountains"] = "6",
		["Aman'Thul"] = "1",
		["Andorhal"] = "11",
		["Anetheron"] = "11",
		["Antonidas"] = "4",
		["Anub'arak"] = "14",
		["Anvilmar"] = "6",
		["Archimonde"] = "11",
		["Argent Dawn"] = "9",
		["Area 52"] = "5",
		["Arthas"] = "9",
		["Arygos"] = "6",
		["Auchindoun"] = "2",
		["Azgalor"] = "9",
		["Azjol-Nerub"] = "3",
		["Azshara"] = "10",
		["Azuremyst"] = "2",
		["Baelgun"] = "10",
		["Balnazzar"] = "7",
		["Barthilas"] = "1",
		["Black Dragonflight"] = "11",
		["Blackhand"] = "7",
		["Blackrock"] = "1",
		["Blackwater Raiders"] = "14",
		["Blackwing Lair"] = "6",
		["Blade's Edge"] = "5",
		["Bladefist"] = "14",
		["Bleeding Hollow"] = "9",
		["Blood Furnace"] = "2",
		["Bloodhoof"] = "9",
		["Bloodscalp"] = "3",
		["Bonechewer"] = "8",
		["Boulderfist"] = "3",
		["Bronzebeard"] = "3",
		["Burning Blade"] = "13",
		["Burning Legion"] = "13",
		["Cenarion Circle"] = "14",
		["Cenarius"] = "14",
		["Cho'gall"] = "7",
		["Chromaggus"] = "12",
		["Coilfang"] = "2",
		["Crushridge"] = "3",
		["Daggerspine"] = "3",
		["Dalaran"] = "11",
		["Dalvengyr"] = "11",
		["Dark Iron"] = "10",
		["Darrowmere"] = "14",
		["Darkspear"] = "3",
		["Dath'Remar"] = "1",
		["Deathwing"] = "6",
		["Demon Soul"] = "6",
		["Dentarg"] = "11",
		["Destromath"] = "7",
		["Dethecus"] = "7",
		["Detheroc"] = "10",
		["Doomhammer"] = "6",
		["Draenor"] = "3",
		["Dragonblight"] = "3",
		["Dragonmaw"] = "8",
		["Drak'thul"] = "12",
		["Draka"] = "12",
		["Drenden"] = "4",
		["Dunemaul"] = "3",
		["Durotan"] = "9",
		["Duskwood"] = "11",
		["Earthen Ring"] = "13",
		["Echo Isles"] = "14",
		["Eitrigg"] = "12",
		["Eldre'Thalas"] = "8",
		["Elune"] = "9",
		["Emerald Dream"] = "10",
		["Eonar"] = "13",
		["Eredar"] = "13",
		["Executus"] = "11",
		["Exodar"] = "5",
		["Farstriders"] = "4",
		["Feathermoon"] = "3",
		["Fenris"] = "14",
		["Firetree"] = "8",
		["Frostmane"] = "8",
		["Frostmourne"] = "1",
		["Frostwolf"] = "1",
		["Garithos"] = "12",
		["Garona"] = "7",
		["Gilneas"] = "13",
		["Greymane"] = "10",
		["Gnomeregan"] = "6",
		["Gorefiend"] = "13",
		["Gorgonnash"] = "7",
		["Gul'dan"] = "7",
		["Gurubashi"] = "8",
		["Hakkar"] = "12",
		["Haomarush"] = "11",
		["Hellscream"] = "7",
		["Hydraxis"] = "4",
		["Hyjal"] = "14",
		["Icecrown"] = "6",
		["Illidan"] = "7",
		["Jaedenar"] = "6",
		["Jubei'Thos"] = "12",
		["Kael'thas"] = "7",
		["Kalecgos"] = "10",
		["Kargath"] = "13",
		["Kel'Thuzad"] = "6",
		["Khadgar"] = "11",
		["Khaz Modan"] = "12",
		["Khaz'goroth"] = "1",
		["Kil'Jaeden"] = "1",
		["Kilrogg"] = "1",
		["Kirin Tor"] = "7",
		["Korgath"] = "12",
		["Korialstraaz"] = "14",
		["Kul Tiras"] = "12",
		["Laughing Skull"] = "13",
		["Lethon"] = "6",
		["Lightbringer"] = "14",
		["Lightning's Blade"] = "13",
		["Lightninghoof"] = "10",
		["Llane"] = "13",
		["Lothar"] = "9",
		["Madoran"] = "9",
		["Maelstrom"] = "10",
		["Magtheridon"] = "9",
		["Maiev"] = "14",
		["Mal'Ganis"] = "11",
		["Malfurion"] = "10",
		["Malorne"] = "12",
		["Malygos"] = "13",
		["Mannoroth"] = "9",
		["Medivh"] = "9",
		["Misha"] = "14",
		["Mok'Nathal"] = "4",
		["Moon Guard"] = "4",
		["Moonrunner"] = "10",
		["Mug'thol"] = "12",
		["Muradin"] = "12",
		["Nagrand"] = "1",
		["Nathrezim"] = "8",
		["Nazgrel"] = "4",
		["Nazjatar"] = "10",
		["Ner'zhul"] = "1",
		["Nordrassil"] = "4",
		["Norgannon"] = "11",
		["Onyxia"] = "6",
		["Perenolde"] = "3",
		["Proudmoore"] = "1",
		["Quel'dorei"] = "4",
		["Ravenholdt"] = "14",
		["Rexxar"] = "12",
		["Rivendare"] = "4",
		["Runetotem"] = "12",
		["Sargeras"] = "10",
		["Scarlet Crusade"] = "8",
		["Scilla"] = "11",
		["Sen'jin"] = "1",
		["Sentinels"] = "6",
		["Shadow Council"] = "8",
		["Shadow Moon"] = "13",
		["Shadowsong"] = "8",
		["Shandris"] = "4",
		["Shattered Halls"] = "2",
		["Shattered Hand"] = "9",
		["Shu'halo"] = "14",
		["Silver Hand"] = "1",
		["Silvermoon"] = "8",
		["Sisters of Elune"] = "14",
		["Skullcrusher"] = "9",
		["Skywall"] = "8",
		["Smolderthorn"] = "8",
		["Spinebreaker"] = "7",
		["Spirestone"] = "8",
		["Staghelm"] = "10",
		["Steamwheedle Cartel"] = "11",
		["Stonemaul"] = "3",
		["Stormrage"] = "9",
		["Stormreaver"] = "7",
		["Stormscale"] = "3",
		["Suramar"] = "3",
		["Tanaris"] = "6",
		["Terenas"] = "8",
		["Terokkar"] = "5",
		["Thaurissan"] = "1",
		["The Forgotten Coast"] = "14",
		["The Scryers"] = "5",
		["The Underbog"] = "2",
		["The Venture Co"] = "6",
		["Thorium Brotherhood"] = "12",
		["Thrall"] = "11",
		["Thunderhorn"] = "13",
		["Thunderlord"] = "13",
		["Tichondrius"] = "1",
		["Tortheldrin"] = "4",
		["Turalyon"] = "11",
		["Twisting Nether"] = "10",
		["Uldaman"] = "6",
		["Uldum"] = "3",
		["Undermine"] = "6",
		["Ursin"] = "10",
		["Uther"] = "14",
		["Vashj"] = "14",
		["Vek'nilash"] = "1",
		["Velen"] = "5",
		["Warsong"] = "9",
		["Whisperwind"] = "7",
		["Wildhammer"] = "10",
		["Windrunner"] = "8",
		["Ysera"] = "11",
		["Ysondre"] = "11",
		["Zangarmarsh"] = "5",
		["Zul'jin"] = "9",
		["Zuluhed"] = "11",
	}
	BGServerType = {
		["Aegwynn"] = "PvP",
		["Aerie Peak"] = "Normal",
		["Agamaggan"] = "PvP",
		["Aggramar"] = "Normal",
		["Akama"] = "PvP",
		["Alexstrasza"] = "Normal",
		["Alleria"] = "Normal",
		["Altar of Storms"] = "PvP",
		["Alterac Mountains"] = "PvP",
		["Aman'Thul"] = "Normal",
		["Andorhal"] = "PvP",
		["Anetheron"] = "PvP",
		["Antonidas"] = "Normal",
		["Anub'arak"] = "PvP",
		["Anvilmar"] = "Normal",
		["Archimonde"] = "PvP",
		["Argent Dawn"] = "RP",
		["Area 52"] = "Normal",
		["Arthas"] = "PvP",
		["Arygos"] = "Normal",
		["Auchindoun"] = "PvP",
		["Azgalor"] = "PvP",
		["Azjol-Nerub"] = "Normal",
		["Azshara"] = "PvP",
		["Azuremyst"] = "Normal",
		["Baelgun"] = "Normal",
		["Balnazzar"] = "PvP",
		["Barthilas"] = "PvP",
		["Black Dragonflight"] = "PvP",
		["Blackhand"] = "Normal",
		["Blackrock"] = "PvP",
		["Blackwater Raiders"] = "RP",
		["Blackwing Lair"] = "PvP",
		["Blade's Edge"] = "Normal",
		["Bladefist"] = "Normal",
		["Bleeding Hollow"] = "PvP",
		["Blood Furnace"] = "PvP",
		["Bloodhoof"] = "Normal",
		["Bloodscalp"] = "PvP",
		["Bonechewer"] = "PvP",
		["Boulderfist"] = "PvP",
		["Bronzebeard"] = "Normal",
		["Burning Blade"] = "PvP",
		["Burning Legion"] = "PvP",
		["Cenarion Circle"] = "RP",
		["Cenarius"] = "Normal",
		["Cho'gall"] = "PvP",
		["Chromaggus"] = "PvP",
		["Coilfang"] = "PvP",
		["Crushridge"] = "PvP",
		["Daggerspine"] = "PvP",
		["Dalaran"] = "Normal",
		["Dalvengyr"] = "PvP",
		["Dark Iron"] = "PvP",
		["Darrowmere"] = "PvP",
		["Darkspear"] = "PvP",
		["Dath'Remar"] = "Normal",
		["Deathwing"] = "PvP",
		["Demon Soul"] = "PvP",
		["Dentarg"] = "PvP",
		["Destromath"] = "PvP",
		["Dethecus"] = "PvP",
		["Detheroc"] = "PvP",
		["Doomhammer"] = "Normal",
		["Draenor"] = "Normal",
		["Dragonblight"] = "Normal",
		["Dragonmaw"] = "PvP",
		["Drak'thul"] = "PvP",
		["Draka"] = "Normal",
		["Drenden"] = "Normal",
		["Dunemaul"] = "PvP",
		["Durotan"] = "Normal",
		["Duskwood"] = "Normal",
		["Earthen Ring"] = "RP",
		["Echo Isles"] = "Normal",
		["Eitrigg"] = "Normal",
		["Eldre'Thalas"] = "Normal",
		["Elune"] = "Normal",
		["Emerald Dream"] = "RP-PvP",
		["Eonar"] = "Normal",
		["Eredar"] = "PvP",
		["Executus"] = "PvP",
		["Exodar"] = "Normal",
		["Farstriders"] = "RP",
		["Feathermoon"] = "RP",
		["Fenris"] = "Normal",
		["Firetree"] = "PvP",
		["Frostmane"] = "PvP",
		["Frostmourne"] = "PvP",
		["Frostwolf"] = "PvP",
		["Garithos"] = "PvP",
		["Garona"] = "Normal",
		["Gilneas"] = "Normal",
		["Greymane"] = "Normal",
		["Gnomeregan"] = "Normal",
		["Gorefiend"] = "PvP",
		["Gorgonnash"] = "PvP",
		["Gul'dan"] = "PvP",
		["Gurubashi"] = "PvP",
		["Hakkar"] = "PvP",
		["Haomarush"] = "PvP",
		["Hellscream"] = "Normal",
		["Hydraxis"] = "Normal",
		["Hyjal"] = "Normal",
		["Icecrown"] = "Normal",
		["Illidan"] = "PvP",
		["Jaedenar"] = "PvP",
		["Jubei'Thos"] = "PvP",
		["Kael'thas"] = "Normal",
		["Kalecgos"] = "PvP",
		["Kargath"] = "Normal",
		["Kel'Thuzad"] = "PvP",
		["Khadgar"] = "Normal",
		["Khaz Modan"] = "Normal",
		["Khaz'goroth"] = "Normal",
		["Kil'Jaeden"] = "PvP",
		["Kilrogg"] = "Normal",
		["Kirin Tor"] = "RP",
		["Korgath"] = "PvP",
		["Korialstraaz"] = "Normal",
		["Kul Tiras"] = "Normal",
		["Laughing Skull"] = "PvP",
		["Lethon"] = "PvP",
		["Lightbringer"] = "Normal",
		["Lightning's Blade"] = "PvP",
		["Lightninghoof"] = "RP-PvP",
		["Llane"] = "Normal",
		["Lothar"] = "Normal",
		["Madoran"] = "Normal",
		["Maelstrom"] = "RP-PvP",
		["Magtheridon"] = "PvP",
		["Maiev"] = "PvP",
		["Mal'Ganis"] = "PvP",
		["Malfurion"] = "Normal",
		["Malorne"] = "PvP",
		["Malygos"] = "Normal",
		["Mannoroth"] = "PvP",
		["Medivh"] = "Normal",
		["Misha"] = "Normal",
		["Mok'Nathal"] = "Normal",
		["Moon Guard"] = "RP",
		["Moonrunner"] = "Normal",
		["Mug'thol"] = "PvP",
		["Muradin"] = "Normal",
		["Nagrand"] = "Normal",
		["Nathrezim"] = "PvP",
		["Nazgrel"] = "Normal",
		["Nazjatar"] = "PvP",
		["Ner'zhul"] = "PvP",
		["Nordrassil"] = "Normal",
		["Norgannon"] = "Normal",
		["Onyxia"] = "PvP",
		["Perenolde"] = "Normal",
		["Proudmoore"] = "Normal",
		["Quel'dorei"] = "Normal",
		["Ravenholdt"] = "RP-PvP",
		["Rexxar"] = "Normal",
		["Rivendare"] = "PvP",
		["Runetotem"] = "Normal",
		["Sargeras"] = "PvP",
		["Scarlet Crusade"] = "RP",
		["Scilla"] = "PvP",
		["Sen'jin"] = "Normal",
		["Sentinels"] = "RP",
		["Shadow Council"] = "RP",
		["Shadow Moon"] = "PvP",
		["Shadowsong"] = "Normal",
		["Shandris"] = "Normal",
		["Shattered Halls"] = "PvP",
		["Shattered Hand"] = "PvP",
		["Shu'halo"] = "PvP",
		["Silver Hand"] = "RP",
		["Silvermoon"] = "Normal",
		["Sisters of Elune"] = "RP",
		["Skullcrusher"] = "PvP",
		["Skywall"] = "Normal",
		["Smolderthorn"] = "PvP",
		["Spinebreaker"] = "PvP",
		["Spirestone"] = "PvP",
		["Staghelm"] = "Normal",
		["Steamwheedle Cartel"] = "RP",
		["Stonemaul"] = "PvP",
		["Stormrage"] = "Normal",
		["Stormreaver"] = "PvP",
		["Stormscale"] = "PvP",
		["Suramar"] = "Normal",
		["Tanaris"] = "Normal",
		["Terenas"] = "Normal",
		["Terokkar"] = "Normal",
		["Thaurissan"] = "Normal",
		["The Forgotten Coast"] = "PvP",
		["The Scryers"] = "Normal",
		["The Underbog"] = "PvP",
		["The Venture Co"] = "RP-PvP",
		["Thorium Brotherhood"] = "RP",
		["Thrall"] = "Normal",
		["Thunderhorn"] = "Normal",
		["Thunderlord"] = "PvP",
		["Tichondrius"] = "PvP",
		["Tortheldrin"] = "PvP",
		["Turalyon"] = "Normal",
		["Twisting Nether"] = "RP-PvP",
		["Uldaman"] = "Normal",
		["Uldum"] = "Normal",
		["Undermine"] = "Normal",
		["Ursin"] = "PvP",
		["Uther"] = "Normal",
		["Vashj"] = "PvP",
		["Vek'nilash"] = "Normal",
		["Velen"] = "Normal",
		["Warsong"] = "PvP",
		["Whisperwind"] = "Normal",
		["Wildhammer"] = "PvP",
		["Windrunner"] = "Normal",
		["Ysera"] = "Normal",
		["Ysondre"] = "PvP",
		["Zangarmarsh"] = "Normal",
		["Zul'jin"] = "Normal",
		["Zuluhed"] = "PvP",
	}
end


local MONTH_LONG_ABBR = "%B"
local MONTH_SHORT_ABBR = "%b"

local locale = GetLocale()
if locale ~= "deDE" and locale ~= "koKR" and locale ~= "esES" and locale ~= "frFR" and locale ~= "zhTW" then
	locale = "enUS"
end

local preparseEventText
local L = {
	["A library for PvP and Battlegrounds."] = "A library for PvP and Battlegrounds.",
	["Battlegrounds"] = "Battlegrounds",
	["Show battlegrounds information"] = "Show battlegrounds information",
	["BG Score"] = "BG Score",
	["WSG Score"] = "WSG Score",
	["AB Score"] = "AB Score",
	["AV Score"] = "AV Score",
	["EotS Score"] = "EotS Score",
	["Current"] = "Current",
	["Standing"] = "Standing",
	["Killing Blows"] = "Killing Blows",
	["Honorable Kills"] = "Honorable Kills",
	["Deaths"] = "Deaths",
	["Bonus Honor"] = "Bonus Honor",
	["Friendly FC"] = "Friendly FC",
	["Hostile FC"] = "Hostile FC",
	["Friendly Bases"] = "Friendly Bases",
	["Hostile Bases"] = "Hostile Bases",
	["Friendly Resources"] = "Friendly Resources",
	["Hostile Resources"] = "Hostile Resources",
	["Friendly Players"] = "Friendly Players",
	["Hostile Players"] = "Hostile Players",
	["Honor"] = "Honor",
	["Show honor information"] = "Show honor information",
	["Today's HKs"] = "Today's HKs",
	["Today's Deaths"] = "Today's Deaths",
	["Today's HK Honor"] = "Today's HK Honor",
	["Today's Bonus Honor"] = "Today's Bonus Honor",
	["Today's Honor"] = "Today's Honor",
	["Flagged"] = "Flagged",
	["Battlegrounds"] = "Battlegrounds",
	["None"] = "None",
	["PvP Cooldown"] = "PvP Cooldown",
	["Rank Limit"] = "Rank Limit",
	["Rating Limit"] = "Rating Limit",
	["Arena Points"] = "Arena Points",
	["Calculate Arena Points"] = "Calculate Arena Points",
	["Rating"] = "Rating",
	["Calcuate Arena Points from Rating"] = "Calcuate Arena Points from Rating",
	["Points"] = "Points",
	["Calcuate Arena Rating from Points"] = "Calcuate Arena Rating from Points",
	["5v5"] = "5v5",
	["3v3"] = "3v3",
	["2v2"] = "2v2",
	["<rating>"] = "<rating>",
	["<points>"] = "<points>",
	["Impossible"] = "Impossible",
}
if locale == "enUS" then
	PATTERN_HORDE_FLAG_PICKED_UP = "The Horde [Ff]lag was picked up by ([^!]+)!"
	PATTERN_HORDE_FLAG_DROPPED = "The Horde [Ff]lag was dropped by (%a+)!"
	PATTERN_HORDE_FLAG_CAPTURED = "(%a+) captured the Horde [Ff]lag!"
	PATTERN_ALLIANCE_FLAG_PICKED_UP = "The Alliance [Ff]lag was picked up by (%a+)!"
	PATTERN_ALLIANCE_FLAG_DROPPED = "The Alliance [Ff]lag was dropped by (%a+)!"
	PATTERN_ALLIANCE_FLAG_CAPTURED = "(%a+) captured the Alliance [Ff]lag!"
	
	FACTION_DEFILERS = "Defilers"
	FACTION_FROSTWOLF_CLAN = "Frostwolf Clan"
	FACTION_WARSONG_OUTRIDERS = "Warsong Outriders"
	
	FACTION_LEAGUE_OF_ARATHOR = "League of Arathor"
	FACTION_STORMPIKE_GUARD = "Stormpike Guard"
	FACTION_SILVERWING_SENTINELS = "Silverwing Sentinels"
	
	BGObjectiveDescriptions = {
		ALLIANCE_CONTROLLED = "Alliance Controlled",
		HORDE_CONTROLLED = "Horde Controlled",
		IN_CONFLICT = "In Conflict",
		UNCONTROLLED = "Uncontrolled",
		DESTROYED = "Destroyed",
	}

	BGChatAnnouncements = {
		BGObjectiveClaimedAnnouncements = {
			PATTERN_OBJECTIVE_CLAIMED_AB = "claims the ([%w ]+).* (%a+) will control",
		},

		BGObjectiveAttackedAnnouncements = {
			PATTERN_OBJECTIVE_ATTACKED_AB = "assaulted the ([%w ]+)",
			PATTERN_OBJECTIVE_ATTACKED_AV0 = "The ([%w ]+) is under attack",
			PATTERN_OBJECTIVE_ATTACKED_AV1 = "^([%w ]+) is under attack",
		},

		BGObjectiveDefendedAnnouncements = {
			PATTERN_OBJECTIVE_DEFENDED_AB = "defended the ([%w ]+)",
		},

		BGObjectiveCapturedAnnouncements = {
			PATTERN_OBJECTIVE_CAPTURED_AB = "The (%a+) has taken the ([%w ]+)",
			PATTERN_OBJECTIVE_CAPTURED_AV0 = "The ([%w ]+) was taken by the (%a+)",
			PATTERN_OBJECTIVE_CAPTURED_AV1 = "^([%w ]+) was taken by the (%a+)",
			PATTERN_OBJECTIVE_CAPTURED_AV2 = "the ([%w ]+) is.*MINE", --and the Irondeep Mine is...MINE!
			PATTERN_OBJECTIVE_CAPTURED_AV3 = "claims the ([%w ]+)", --Snivvle claims the Coldtooth Mine!
		},

		BGObjectiveDestroyedAnnouncements = {
			PATTERN_OBJECTIVE_DESTROYED_AV0 = "The ([%w ]+) was destroyed",
			PATTERN_OBJECTIVE_DESTROYED_AV1 = "^([%w ]+) was destroyed",
		},
	}

	BGPatternReplacements = {
		["mine"] = "gold mine",
		["southern farm"] = "farm"
	}

	BGAcronyms = {
		[ALTERAC_VALLEY] = "AV",
		[ARATHI_BASIN] = "AB",
		[WARSONG_GULCH] = "WSG",
		[EYE_OF_THE_STORM] = "EotS",
	}

	PATTERN_GWSUII_SCORE = "(%d+/%d+)"			--for lifting the score out of the third return value of GetWorldStateUIInfo(index)
	PATTERN_GWSUII_BASES = "Bases: (%d+)"		 --for lifting the number of bases held in Arathi Basin
	PATTERN_GWSUII_RESOURCES = "Resources: (%d+)" --for lifting the number of bases held in Arathi Basin
	PATTERN_OBJECTIVE_HOLDER = "([%w ]+) Controlled"

elseif locale == "frFR" then
	PATTERN_HORDE_FLAG_PICKED_UP = "^Le drapeau de la Horde a \195\169t\195\169 ramass\195\169 par (.-) !$"
	PATTERN_HORDE_FLAG_DROPPED = "^Le drapeau de la Horde a \195\169t\195\169 l\195\162ch\195\169 par (.-) !$"
	PATTERN_HORDE_FLAG_CAPTURED = "^(.-) a pris le drapeau de la Horde !$"
	PATTERN_ALLIANCE_FLAG_PICKED_UP = "^Le drapeau de l'Alliance a \195\169t\195\169 ramass\195\169 par (.-) !$"
	PATTERN_ALLIANCE_FLAG_DROPPED = "^Le drapeau de l'Alliance a \195\169t\195\169 l\195\162ch\195\169 par (.-) !$"
	PATTERN_ALLIANCE_FLAG_CAPTURED = "^(.-) a pris le drapeau de l.*Alliance !$"

	FACTION_DEFILERS = "Profanateurs"
	FACTION_FROSTWOLF_CLAN = "Clan Loup-de-givre" -- XXX - not checked
	FACTION_WARSONG_OUTRIDERS = "Voltigeurs Chanteguerres" -- XXX - not checked

	FACTION_LEAGUE_OF_ARATHOR = "Ligue d'Arathor"
	FACTION_STORMPIKE_GUARD = "Garde Foudrepique"
	FACTION_SILVERWING_SENTINELS = "Sentinelles d'Aile-argent"

	function preparseEventText(text)
		text = text:gsub("\226\128\153", "'");
		text = text:gsub("[lL]'Alliance", "Alliance");
		text = text:gsub("[lL]a Horde", "Horde");
		return text;
	end

	BGObjectiveDescriptions = {
		ALLIANCE_CONTROLLED = "Contr\195\180l\195\169e? par l'Alliance",
		HORDE_CONTROLLED = "Contr\195\180l\195\169e? par la Horde",
		IN_CONFLICT = "[Dd]isput\195\169e?",
		UNCONTROLLED = "Pas contr\195\180l\195\169e?",
		DESTROYED = "D\195\169truite?",
		
		-- Plain string for display
		UNCONTROLLED_PLAIN = "Pas contr\195\180l\195\169(e)",
	}

	BGChatAnnouncements = {
		BGObjectiveClaimedAnnouncements = { 
			PATTERN_OBJECTIVE_CLAIMED_AB0 = "a pris la (.-) !.- (%a+) s'en emparera",
		},
		
		BGObjectiveAttackedAnnouncements = {
			PATTERN_OBJECTIVE_ATTACKED_AB0 = "a attaqu\195\169 l[ae] (.-) !$",
			PATTERN_OBJECTIVE_ATTACKED_AB1 = "a attaqu\195\169 l'(.-) !$",
			PATTERN_OBJECTIVE_ATTACKED_AV0 = "^L[ae] (.-) est attaqu\195\169",
			PATTERN_OBJECTIVE_ATTACKED_AV1 = "^L'(.-) est attaqu\195\169",
		},
		
		BGObjectiveDefendedAnnouncements = {
			PATTERN_OBJECTIVE_DEFENDED_AB0 = "a d\195\169fendu la (.-) !$",
			PATTERN_OBJECTIVE_DEFENDED_AB1 = "a d\195\169fendu l'(.-) !$",
		},
		
		BGObjectiveCapturedAnnouncements = {
			PATTERN_OBJECTIVE_CAPTURED_AB0 = "^(%a+) s'est empar\195\169e? de la (.-) !$",
			PATTERN_OBJECTIVE_CAPTURED_AB1 = "^(%a+) s'est empar\195\169e? de l'(.-) !$",
			PATTERN_OBJECTIVE_CAPTURED_AV0 = "^L[ae] (.-) a \195\169t\195\169 prise? par (%a+) !$",
			PATTERN_OBJECTIVE_CAPTURED_AV1 = "^L'(.-) a \195\169t\195\169 prise? par (%a+) !$",
			PATTERN_OBJECTIVE_CAPTURED_AV2 = "^(%a) s'est empar\195\169e de la (mine de Gouffrefer) !$",
			PATTERN_OBJECTIVE_CAPTURED_AV3 = "(%a) prend la mine de (Froide-dent) !$",
		},
		
		BGObjectiveDestroyedAnnouncements = {
			PATTERN_OBJECTIVE_DESTROYED_AV0 = "^L[ae] (.-) a \195\169t\195\169 d\195\169truit",
		},
	}

	BGPatternReplacements = {
		["mine"] = "mine d'or",
		["ferme du sud"] = "ferme",
		["\195\169curies"] = "ecuries",
		["\195\169curie"] = "ecuries",
	}

	BGAcronyms = {
		[ALTERAC_VALLEY] = "AV",
		[ARATHI_BASIN] = "AB",
		[WARSONG_GULCH] = "WSG",
		[EYE_OF_THE_STORM] = "EotS",
	}

	PATTERN_GWSUII_SCORE = "(%d+/%d+)" -- XXX - for lifting the score out of the third return value of GetWorldStateUIInfo(index)
	PATTERN_GWSUII_BASES = "Bases[^:]*: (%d+)" -- XXX - for lifting the number of bases held in Arathi Basin
	PATTERN_GWSUII_RESOURCES = "Ressources: (%d+)" -- XXX - for lifting the number of bases held in Arathi Basin
	PATTERN_OBJECTIVE_HOLDER = "Contr\195\180l\195\169e? par ([%w%-' ]+)"

elseif locale == "koKR" then
	PATTERN_HORDE_FLAG_PICKED_UP = "(.+)|1이;가; 호드 깃발을 손에 넣었습니다!"
	PATTERN_HORDE_FLAG_DROPPED = "호드 깃발을 떨어뜨렸습니다!"
	PATTERN_HORDE_FLAG_CAPTURED = "호드 깃발 쟁탈에 성공했습니다!"
	PATTERN_ALLIANCE_FLAG_PICKED_UP = "(.+)|1이;가; 얼라이언스 깃발을 손에 넣었습니다!"
	PATTERN_ALLIANCE_FLAG_DROPPED = "얼라이언스 깃발을 떨어뜨렸습니다!"
	PATTERN_ALLIANCE_FLAG_CAPTURED = "얼라이언스 깃발 쟁탈에 성공했습니다!"
	
	FACTION_DEFILERS = "포세이큰 파멸단"
	FACTION_FROSTWOLF_CLAN = "서리늑대 부족"
	FACTION_WARSONG_OUTRIDERS = "전쟁노래 부족"
	
	FACTION_LEAGUE_OF_ARATHOR = "아라소르 연맹"
	FACTION_STORMPIKE_GUARD = "스톰파이크 경비대"
	FACTION_SILVERWING_SENTINELS = "은빛날개 파수대"
	
	BGObjectiveDescriptions = {
		ALLIANCE_CONTROLLED = "얼라이언스 점령지",
		HORDE_CONTROLLED = "호드 점령지",
		IN_CONFLICT = "분쟁 지역",
		UNCONTROLLED = "미점령 지역",
		DESTROYED = "파괴됨",
	}

	BGChatAnnouncements = {
		BGObjectiveClaimedAnnouncements = {
			PATTERN_OBJECTIVE_CLAIMED_AB = "|1이;가 (.-)|1을;를; 공격했습니다! 방어하지 못하면 1분 안에 (.-)에 넘어갈 것입니다",
		},

		BGObjectiveAttackedAnnouncements = {
			PATTERN_OBJECTIVE_ATTACKED_AB = "^(.-)|1이;가; (.+)|1을;를; 공격했습니다",
			PATTERN_OBJECTIVE_ATTACKED_AV0 = "^(.+)|1이;가; 공격 받고 있습니다",
		},

		BGObjectiveDefendedAnnouncements = {
			PATTERN_OBJECTIVE_DEFENDED_AB = "^(.-)|1이;가; (.+)|1을;를; 방어했습니다",
		},

		BGObjectiveCapturedAnnouncements = {
			PATTERN_OBJECTIVE_CAPTURED_AB = "^(.-)|1이;가; (.+)|1을;를; 점령했습니다",
			PATTERN_OBJECTIVE_CAPTURED_AV0 = "^(.-)|1이;가; (.+)|1을;를; 점령했습니다",
			PATTERN_OBJECTIVE_CAPTURED_AV1 = "the ([%w ]+) is.*MINE", --and the Irondeep Mine is...MINE!
			PATTERN_OBJECTIVE_CAPTURED_AV2 = "|1이;가;* (.-)|을;를; 공격했습니다!", --Snivvle claims the Coldtooth Mine!
		},

		BGObjectiveDestroyedAnnouncements = {
			PATTERN_OBJECTIVE_DESTROYED_AV0 = "|1이;가; (.-)|1을;를; 파괴했습니다",
		},
	}

	BGPatternReplacements = {
	}

	BGAcronyms = {
		[ALTERAC_VALLEY] = "AV", -- CHECK
		[ARATHI_BASIN] = "AB", -- CHECK
		[WARSONG_GULCH] = "WSG", -- CHECK
		[EYE_OF_THE_STORM] = "EotS",
	}

	PATTERN_GWSUII_SCORE = "(%d+/%d+)"			--for lifting the score out of the first return value of GetWorldStateUIInfo(index)
	PATTERN_GWSUII_BASES = "거점: (%d+)"		 --for lifting the number of bases held in Arathi Basin
	PATTERN_GWSUII_RESOURCES = "자원: (%d+)" --for lifting the number of bases held in Arathi Basin
	PATTERN_OBJECTIVE_HOLDER = "(.+) 점령지"

	L = {
		["A library for PvP and Battlegrounds."] = "PvP와 전장과 관련된 정보의 라이브러리입니다.",
		["Battlegrounds"] = "전장",
		["Show battlegrounds information"] = "전장과 관련된 점수를 표시합니다",
		["BG Score"] = "전장 점수",
		["WSG Score"] = "노래방 점수",
		["AB Score"] = "분지 점수",
		["AV Score"] = "알방 점수",
		["EotS Score"] = "폭눈 점수",
		["Current"] = "현재",
		["Standing"] = "계급",
		["Killing Blows"] = "마무리 공격",
		["Honorable Kills"] = "명예 승수",
		["Deaths"] = "사망",
		["Bonus Honor"] = "보너스 명예 점수",
		["Friendly FC"] = "아군 깃발",
		["Hostile FC"] = "적군 깃발",
		["Friendly Bases"] = "아군 거점",
		["Hostile Bases"] = "적군 거점",
		["Friendly Resources"] = "아군 자원",
		["Hostile Resources"] = "적군 자원",
		["Friendly Players"] = "아군 플레이어",
		["Hostile Players"] = "적군 플레이어",
		["Honor"] = "명예",
		["Show honor information"] = "명예점수 관련 정보를 표시합니다",
		["Today's HKs"] = "오늘의 명예승수",
		["Today's Deaths"] = "오늘의 사망",
		["Today's HK Honor"] = "오늘의 명예 점수",
		["Today's Bonus Honor"] = "오늘의 보너스 명예 점수",
		["Today's Honor"] = "오늘의 명예 점수",
		["Flagged"] = "전재 참여중",
		["Battlegrounds"] = "전장",
		["None"] = "없음",
		["PvP Cooldown"] = "PvP 대기시간",
		["Rank Limit"] = "한계 등급",
		["Rating Limit"] = "한계 누적점수",
		["Arena Points"] = "투기장 점수",
		["Calculate Arena Points"] = "투기장 점수를 계산합니다",
		["Rating"] = "평점",
		["Calcuate Arena Points from Rating"] = "투기장 평점으로 투기장 점수를 계산합니다",
		["Points"] = "점수",
		["Calcuate Arena Rating from Points"] = "투기장 점수로 투기장 평점을 계산합니다",
		["5v5"] = "5v5",
		["3v3"] = "3v3",
		["2v2"] = "2v2",
		["<rating>"] = "<평점>",
		["<points>"] = "<점수>",
		["Impossible"] = "불가능",
	}

elseif locale == "deDE" then
	PATTERN_HORDE_FLAG_PICKED_UP = "([^!]+) hat die [Ff]lagge der Horde aufgenommen!"
	PATTERN_HORDE_FLAG_DROPPED = "(%a+) hat die [Ff]lagge der Horde fallen lassen!"
	PATTERN_HORDE_FLAG_CAPTURED = "(%a+) hat die [Ff]lagge der Horde errungen!"
	PATTERN_ALLIANCE_FLAG_PICKED_UP = "(%a+) hat die [Ff]lagge der Allianz aufgenommen!"
	PATTERN_ALLIANCE_FLAG_DROPPED = "(%a+) hat die [Ff]lagge der Allianz fallen lassen!"
	PATTERN_ALLIANCE_FLAG_CAPTURED = "(%a+) hat die [Ff]lagge der Allianz errungen!"
	
	FACTION_DEFILERS = "Die Entweihten"
	FACTION_FROSTWOLF_CLAN = "Frostwolfklan"
	FACTION_WARSONG_OUTRIDERS = "Warsongvorhut"
	
	FACTION_LEAGUE_OF_ARATHOR = "Liga von Arathor"
	FACTION_STORMPIKE_GUARD = "Stormpike Garde"
	FACTION_SILVERWING_SENTINELS = "Silverwing Schildwache"
	
	BGObjectiveDescriptions = {
		ALLIANCE_CONTROLLED = "Kontrolliert von der Allianz",
		HORDE_CONTROLLED = "Kontrolliert von der Horde",
		IN_CONFLICT = "Umk\195\164mpft",
		UNCONTROLLED = "Unkontrolliert",
		DESTROYED = "Zerst\195\182rt",
	}

	BGChatAnnouncements = {
		BGObjectiveClaimedAnnouncements = {
			PATTERN_OBJECTIVE_CLAIMED_AB0 = "hat das (.+) besetzt.* die (%a+) in",
			PATTERN_OBJECTIVE_CLAIMED_AB1 = "hat den (.+) besetzt.* die (%a+) in",
			PATTERN_OBJECTIVE_CLAIMED_AB2 = "hat die (.+) besetzt.* die (%a+) in",
			PATTERN_OBJECTIVE_CLAIMED_AB3 = "hat (S\195\164gewerk) besetzt.* die (%a+) in",
			PATTERN_OBJECTIVE_CLAIMED_AV0 = "hat den (.+) besetzt.* erlangt die (%a+) die Kontrolle"
		},

		BGObjectiveAttackedAnnouncements = {
			PATTERN_OBJECTIVE_ATTACKED_AB0 = "das (.+) angegriffen",
			PATTERN_OBJECTIVE_ATTACKED_AB1 = "den (.+) angegriffen",
			PATTERN_OBJECTIVE_ATTACKED_AB2 = "die (.+) angegriffen",
			PATTERN_OBJECTIVE_ATTACKED_AV0 = "Das (.+) wird angegriffen.*wird die (%a+) es",
			PATTERN_OBJECTIVE_ATTACKED_AV1 = "Der (.+) wird angegriffen.*wird die (%a+) ihn",
			PATTERN_OBJECTIVE_ATTACKED_AV2 = "Die (.+) wird angegriffen.*wird die (%a+) sie",
		},

		BGObjectiveDefendedAnnouncements = {
			PATTERN_OBJECTIVE_DEFENDED_AB0 = "das (.+) verteidigt",
			PATTERN_OBJECTIVE_DEFENDED_AB1 = "den (.+) verteidigt",
			PATTERN_OBJECTIVE_DEFENDED_AB2 = "die (.+) verteidigt",
		},

		BGObjectiveCapturedAnnouncements = {
			PATTERN_OBJECTIVE_CAPTURED_AB0 = "Die (%a+) hat das (.+) eingenommen",
			PATTERN_OBJECTIVE_CAPTURED_AB1 = "Die (%a+) hat den (.+) eingenommen",
			PATTERN_OBJECTIVE_CAPTURED_AB2 = "Die (%a+) hat die (.+) eingenommen",
			PATTERN_OBJECTIVE_CAPTURED_AV0 = "Das (.+) wurde von der (%a+) erobert",
			PATTERN_OBJECTIVE_CAPTURED_AV1 = "Der (.+) wurde von der (%a+) erobert",
			PATTERN_OBJECTIVE_CAPTURED_AV2 = "geh\195\182rt jetzt die (.+)!",
		},

		BGObjectiveDestroyedAnnouncements = {
			PATTERN_OBJECTIVE_DESTROYED_AV0 = "Der (.+) wurde von der (%a+) zerst\195\182rt",
		},
	}

	BGPatternReplacements = {
		["Schmiede"] = "Schmied",
		["Mine"] = "Goldmine",
		["s\195\188dlichen Hof"] = "Hof",
	}

	BGAcronyms = {
		[ALTERAC_VALLEY] = "AV", -- CHECK
		[ARATHI_BASIN] = "AB", -- CHECK
		[WARSONG_GULCH] = "WSG", -- CHECK
		[EYE_OF_THE_STORM] = "EotS",
	}

	PATTERN_GWSUII_SCORE = "(%d+/%d+)" --for lifting the score out of the third return value of GetWorldStateUIInfo(index)
	PATTERN_GWSUII_BASES = "Basen: (%d+)" --for lifting the number of bases held in Arathi Basin
	PATTERN_GWSUII_RESOURCES = "Ressourcen: (%d+)" --for lifting the number of bases held in Arathi Basin -- CHECK
	PATTERN_OBJECTIVE_HOLDER = "Kontrolliert von der ([%w ]+)"
	

elseif locale == "esES" then

	PATTERN_HORDE_FLAG_PICKED_UP = "\194\161([^!]+) ha cogido la [Bb]andera de la Horda!"
	PATTERN_HORDE_FLAG_DROPPED = "\194\161(%a+) ha dejado caer la [Bb]andera de la Horda!"
	PATTERN_HORDE_FLAG_CAPTURED = "\194\161(%a+) ha capturado la [Bb]andera de la Horda!"
	PATTERN_ALLIANCE_FLAG_PICKED_UP = "\194\161(%a+) ha cogido la [Bb]andera de la Alianza!"
	PATTERN_ALLIANCE_FLAG_DROPPED = "\194\161(%a+) ha dejado caer la [Bb]andera de la Alianza!"
	PATTERN_ALLIANCE_FLAG_CAPTURED = "\194\161(%a+) ha capturado la [Bb]andera de la Alianza!"

	FACTION_DEFILERS = "Los Rapi\195\177adores"
	FACTION_FROSTWOLF_CLAN = "Clan Lobo G\195\169lido"
	FACTION_WARSONG_OUTRIDERS = "Escolta Grito de Guerra"
	
	FACTION_LEAGUE_OF_ARATHOR = "Liga de Arathor"
	FACTION_STORMPIKE_GUARD = "Guardia de Pico Tormenta" -- check
	FACTION_SILVERWING_SENTINELS = "Centinelas Ala Plateada" -- check

	BGObjectiveDescriptions = {
		ALLIANCE_CONTROLLED = "Bajo el control de la Alianza",
		HORDE_CONTROLLED = "Bajo el control de la Horda",
		IN_CONFLICT = "En conflicto",
		UNCONTROLLED = "No controlado",
		DESTROYED = "Destru\195\173do",
	}

	BGChatAnnouncements = {
		BGObjectiveClaimedAnnouncements = {
			PATTERN_OBJECTIVE_CLAIMED_AB = "reclama .* ([%w ]+).* (%a+) .* la tomar\195\161",
		},

		BGObjectiveAttackedAnnouncements = {
			PATTERN_OBJECTIVE_ATTACKED_AB = "ha asaltado .* ([%w ]+)",
			PATTERN_OBJECTIVE_ATTACKED_AV0 = "([%w ]+) est\195\161 siendo atacado",
			PATTERN_OBJECTIVE_ATTACKED_AV1 = "Est\195\161n atacando .* ([%w ]+)",
		},

		BGObjectiveDefendedAnnouncements = {
			PATTERN_OBJECTIVE_DEFENDED_AB = "ha defendido .* ([%w ]+)",
		},

		BGObjectiveCapturedAnnouncements = {
			PATTERN_OBJECTIVE_CAPTURED_AB = "La (%a+) ha tomado .* ([%w ]+)",
			PATTERN_OBJECTIVE_CAPTURED_AV0 = "La (%a+) ha capturado .* ([%w ]+)", -- check
			PATTERN_OBJECTIVE_CAPTURED_AV1 = "([%w ]+) ha sido capturado por .* (%a+)", -- not needed in spanish... yet
			PATTERN_OBJECTIVE_CAPTURED_AV2 = "la ([%w ]+) es.*M\195\141A", --and the Irondeep Mine is...MINE!
			PATTERN_OBJECTIVE_CAPTURED_AV3 = "reclama la ([%w ]+)", --Snivvle claims the Coldtooth Mine!
		},

		BGObjectiveDestroyedAnnouncements = {
			PATTERN_OBJECTIVE_DESTROYED_AV0 = "ha destruido .* ([%w ]+)",
			PATTERN_OBJECTIVE_DESTROYED_AV1 = "ha destruido .* ([%w ]+)", -- ?
		},
	}

	BGPatternReplacements = {
		["mina"] = "mina de oro",
		["herrero"] = "herrer\195\173a",
		["establos"] = "establo",
	}

	BGAcronyms = {
		[ALTERAC_VALLEY] = "VdA",
		[ARATHI_BASIN] = "CdA",
		[WARSONG_GULCH] = "GGG",
		[EYE_OF_THE_STORM] = "EotS", -- FIX THIS
	}

	PATTERN_GWSUII_SCORE = "(%d+/%d+)"			--for lifting the score out of the third return value of GetWorldStateUIInfo(index)
	PATTERN_GWSUII_BASES = "Bases: (%d+)"		 --for lifting the number of bases held in Arathi Basin
	PATTERN_GWSUII_RESOURCES = "Recursos: (%d+)" --for lifting the number of bases held in Arathi Basin
	PATTERN_OBJECTIVE_HOLDER = "Bajo el control de la ([%w ]+)"

elseif locale == "zhTW" then
	L["A library for PvP and Battlegrounds."] = "PvP和戰場相關函數的程式庫。"
	L["Battlegrounds"] = "戰場"
	L["Show battlegrounds information"] = "顯示戰場資訊"
	L["BG Score"] = "戰場分數"
	L["WSG Score"] = "戰歌分數"
	L["AB Score"] = "阿拉希分數"
	L["AV Score"] = "奧山分數"
	L["EotS Score"] = "暴風分數"
	L["Current"] = "現在"
	L["Standing"] = "排名"
	L["Killing Blows"] = "殺死敵人"
	L["Honorable Kills"] = "榮譽擊殺"
	L["Deaths"] = "死亡"
	L["Bonus Honor"] = "獲得榮譽"
	L["Friendly FC"] = "友好的持旗者"
	L["Hostile FC"] = "敵對的持旗者"
	L["Friendly Bases"] = "友好的持旗者"
	L["Hostile Bases"] = "敵對的持旗者"
	L["Friendly Resources"] = "友好的資源"
	L["Hostile Resources"] = "敵對的資源"
	L["Friendly Players"] = "友好的玩家"
	L["Hostile Players"] = "敵對的玩家"
	L["Honor"] = "榮譽"
	L["Show honor information"] = "顯示榮譽資訊"
	L["Today's HKs"] = "今日榮譽擊殺"
	L["Today's Deaths"] = "今日死亡"
	L["Today's HK Honor"] = "今日榮譽擊殺榮譽"
	L["Today's Bonus Honor"] = "今日獲得榮譽"
	L["Today's Honor"] = "今日榮譽"
	L["Flagged"] = "PvP狀態中"
	L["Battlegrounds"] = "戰場"
	L["None"] = "無"
	L["PvP Cooldown"] = "PvP剩餘時間"
	L["Rank Limit"] = "級別極限"
	L["Rating Limit"] = "積分極限"
	L["Arena Points"] = "競技場點數"
	L["Calculate Arena Points"] = "計算競技場點數"
	L["Rating"] = "積分"
	L["Calcuate Arena Points from Rating"] = "由競技場積分計算競技場點數"
	L["Points"] = "點數"
	L["Calcuate Arena Rating from Points"] = "由競技場點數計算競技場積分"
	L["5v5"] = "5對5"
	L["3v3"] = "3對3"
	L["2v2"] = "2對2"
	L["<rating>"] = "<積分>"
	L["<points>"] = "<點數>"
	L["Impossible"] = "不可能"

	MONTH_LONG_ABBR = "%m月"
	MONTH_SHORT_ABBR = "%m月"

	PATTERN_HORDE_FLAG_PICKED_UP = "部落的旗幟被(.+)拔掉了!"
	PATTERN_HORDE_FLAG_DROPPED = "部落的旗幟被(.+)丟掉了!"
	PATTERN_HORDE_FLAG_CAPTURED = "(.+)佔據了部落的旗幟!"
	PATTERN_ALLIANCE_FLAG_PICKED_UP = "聯盟的旗幟被(.+)拔掉了!"
	PATTERN_ALLIANCE_FLAG_DROPPED = "聯盟的旗幟被(.+)丟掉了!"
	PATTERN_ALLIANCE_FLAG_CAPTURED = "(.+)佔據了聯盟的旗幟!"
	
	FACTION_DEFILERS = "污染者"
	FACTION_FROSTWOLF_CLAN = "霜狼氏族"
	FACTION_WARSONG_OUTRIDERS = "戰歌偵查騎兵"
	
	FACTION_LEAGUE_OF_ARATHOR = "阿拉索聯軍"
	FACTION_STORMPIKE_GUARD = "雷矛部族"
	FACTION_SILVERWING_SENTINELS = "銀翼哨兵"
	
	BGObjectiveDescriptions = {
		ALLIANCE_CONTROLLED = "聯盟控制",
		HORDE_CONTROLLED = "部落控制",
		IN_CONFLICT = "爭奪中",
		UNCONTROLLED = "未被控制",
		DESTROYED = "摧毀",
	}

	BGChatAnnouncements = {
		BGObjectiveClaimedAnnouncements = {
			PATTERN_OBJECTIVE_CLAIMED_AB = ".+攻佔了(.+)!如果沒有其他人採取行動的話，(.+)將在一分鐘內控制它!",
		},

		BGObjectiveAttackedAnnouncements = {
			PATTERN_OBJECTIVE_ATTACKED_AB = ".+突襲了(.+)!",
			PATTERN_OBJECTIVE_ATTACKED_AV0 = "(.+)受到攻擊!如果不採取措施的話，",
		},

		BGObjectiveDefendedAnnouncements = {
			PATTERN_OBJECTIVE_DEFENDED_AB = ".+守住了(.+)!",
		},

		BGObjectiveCapturedAnnouncements = {
			PATTERN_OBJECTIVE_CAPTURED_AB = "(.+)奪取了(.+)!",
			PATTERN_OBJECTIVE_CAPTURED_AV0 = "(.+)被(.+)佔領了!",
--			PATTERN_OBJECTIVE_CAPTURED_AV1 = "the ([%w ]+) is.*MINE", --and the Irondeep Mine is...MINE!
			PATTERN_OBJECTIVE_CAPTURED_AV2 = "斯尼維爾在此!(.+)是斯尼維爾的!", --Snivvle claims the Coldtooth Mine!
		},

		BGObjectiveDestroyedAnnouncements = {
			PATTERN_OBJECTIVE_DESTROYED_AV = "(.+)被.+摧毀了!",
		},
	}

	BGPatternReplacements = {
		["礦坑"] = "金礦",
		["南邊的農場"] = "農場"
	}

	BGAcronyms = {
		[ALTERAC_VALLEY] = "奧山",
		[ARATHI_BASIN] = "阿拉希",
		[WARSONG_GULCH] = "戰歌",
		[EYE_OF_THE_STORM] = "暴風",
	}

	PATTERN_GWSUII_SCORE = "(%d+/%d+)"			--for lifting the score out of the third return value of GetWorldStateUIInfo(index)
	PATTERN_GWSUII_BASES = "基地:(%d+)"		 --for lifting the number of bases held in Arathi Basin
	PATTERN_GWSUII_RESOURCES = "資源:(%d+)" --for lifting the number of bases held in Arathi Basin
	PATTERN_OBJECTIVE_HOLDER = "(.+)控制"

end

BattlefieldZoneObjectiveTimes = {
	[ARATHI_BASIN] = 62.5,
	[ALTERAC_VALLEY] = 242.5,
}

BattlefieldZoneResourceData = {
	[ARATHI_BASIN] = { [0]=0, 5/6, 10/9, 5/3, 10/3, 30, 2000 }
}

local Glory = {}
local events = {}

AceEvent:embed(events)

local _,race = UnitRace("player")
local isHorde = (race == "Orc" or race == "Troll" or race == "Tauren" or race == "Scourge" or race == "BloodElf")
local playerName = UnitName("player")
local playerRealm = GetRealmName()

local enemyList = {}

local function CheckNewWeek(self)
	--[[
	if not lua51 then
		local _,lastWeekHonor = GetPVPLastWeekStats()
		if lastWeekHonor ~= self.data.lastWeek then
			self.data.lastWeek = lastWeekHonor
			events:TriggerEvent("Glory_NewWeek")
		end
	end
	]]
end

local function CheckNewDay(self)
	local _,yesterdayHonor = GetPVPYesterdayStats()
	local lifetimeHK,_ = GetPVPLifetimeStats()
	local currentTime = time()
	if yesterdayHonor ~= self.data.yesterday and (yesterdayHonor ~= 0 or lifetimeHK ~= 0) or self.data.time and currentTime - self.data.time > 36*60*60 then
		self.data.yesterday = yesterdayHonor
		self.data.hks = {}
		self.data.todayHK = 0
		self.data.todayHKHonor = 0
		self.data.todayBonusHonor = 0
		self.data.todayDeaths = 0
		events:TriggerEvent("Glory_NewDay")
	end
end

local function IncreaseHKs(self, person)
	self.data.todayHK = self.data.todayHK + 1
	self.data.hks[person] = (self.data.hks[person] or 0) + 1
	return self.data.hks[person]
end

local function IncreaseHKHonor(self, amount)
	self.data.todayHKHonor = self.data.todayHKHonor + amount
end

local function IncreaseBonusHonor(self, amount)
	self.data.todayBonusHonor = self.data.todayBonusHonor + amount
end

local function IncreaseBattlegroundsWins(self)
	if self:IsInAlteracValley() then
		self.data.avWin = self.data.avWin + 1
		events:TriggerEvent("Glory_BGWinAV")
	elseif self:IsInArathiBasin() then
		self.data.abWin = self.data.abWin + 1
		events:TriggerEvent("Glory_BGWinAB")
	elseif self:IsInWarsongGulch() then
		self.data.wsgWin = self.data.wsgWin + 1
		events:TriggerEvent("Glory_BGWinWSG")
	elseif self:IsInEyeOfTheStorm() then
		self.data.eotsWin = self.data.eotsWin + 1
		events:TriggerEvent("Glory_BGWinEOTS")
	end
	events:TriggerEvent("Glory_BGWin")
end

local function IncreaseBattlegroundsLosses(self)
	if self:IsInAlteracValley() then
		self.data.avLoss = self.data.avLoss + 1
		events:TriggerEvent("Glory_BGLossAV")
	elseif self:IsInArathiBasin() then
		self.data.abLoss = self.data.abLoss + 1
		events:TriggerEvent("Glory_BGLossAB")
	elseif self:IsInWarsongGulch() then
		self.data.wsgLoss = self.data.wsgLoss + 1
		events:TriggerEvent("Glory_BGLossWSG")
	elseif self:IsInEyeOfTheStorm() then
		self.data.eotsLoss = self.data.eotsLoss + 1
		events:TriggerEvent("Glory_BGLossEOTS")
	end
	events:TriggerEvent("Glory_BGLoss")
end

local function IncreaseDeaths(self)
	self.data.todayDeaths = self.data.todayDeaths + 1
	events:TriggerEvent("Glory_Death")
end

local db

local function VerifyData(self)
	if not self.data then
		if type(Glory2DB) ~= "table" then
			Glory2DB = {}
		end
		db = Glory2DB
		if type(db[MAJOR_VERSION]) ~= "table" then
			db[MAJOR_VERSION] = {}
		end
		self.data = db[MAJOR_VERSION]
	elseif db ~= Glory2DB then
		local old = db
		local new = Glory2DB
		if type(new) ~= "table" then
			Glory2DB = old
		else
			for k in pairs(old) do
				if not new[k] then
					new[k] = old[k]
				elseif new[k].time == nil then
					new[k] = old[k]
				elseif old[k].time == nil then
					-- keep new
				elseif new[k].time < old[k].time then
					new[k] = old[k]
				end
			end
			db = new
			self.data = db[MAJOR_VERSION]
		end
	end
	if not self.data.hks then self.data.hks = {} end
	if not self.data.todayDeaths then self.data.todayDeaths = 0 end
	if not self.data.todayHK then self.data.todayHK = 0 end
	if not self.data.todayHKHonor then self.data.todayHKHonor = 0 end
	if not self.data.todayBonusHonor then self.data.todayBonusHonor = 0 end
	if not self.data.wsgWin then self.data.wsgWin = 0 end
	if not self.data.wsgLoss then self.data.wsgLoss = 0 end
	if not self.data.abWin then self.data.abWin = 0 end
	if not self.data.abLoss then self.data.abLoss = 0 end
	if not self.data.avWin then self.data.avWin = 0 end
	if not self.data.avLoss then self.data.avLoss = 0 end
	if not self.data.eotsWin then self.data.eotsWin = 0 end
	if not self.data.eotsLoss then self.data.eotsLoss = 0 end
	if not self.data.yesterday then self.data.yesterday = 0 end
	if not self.data.lastWeek then self.data.lastWeek = 0 end
	
	CheckNewDay(self)
	CheckNewWeek(self)
	events:UNIT_FACTION()
end

function events:ADDON_LOADED()
	VerifyData(Glory)
end

function events:VARIABLES_LOADED()
	VerifyData(Glory)
end

function events:PLAYER_LOGOUT()
	Glory.data.time = time()
end

function events:CHAT_MSG_COMBAT_HONOR_GAIN(text)
	CheckNewDay(Glory)
	local name, rank, honor = deformat(text, COMBATLOG_HONORGAIN)
	if name then
		local realm = enemyList[name] or playerRealm
		if realm ~= playerRealm then
			name = name .. "-" .. realm
		end
		local kills = IncreaseHKs(Glory, name)
		local factor
		factor = (11 - kills) / 10
		if factor < 0 then
			factor = 0
		end
		local realHonor = ceil(honor * factor)
		IncreaseHKHonor(Glory, realHonor)
		events:TriggerEvent("Glory_GainHK", rank, name, realHonor, kills)
		return
	end
	
	local bonus = deformat(text, COMBATLOG_HONORAWARD)
	if bonus then
		bonus = tonumber(bonus)
		IncreaseBonusHonor(Glory, bonus)
		events:TriggerEvent("Glory_GainBonusHonor", bonus)
	end
end

--[[
function events:CHAT_MSG_BG_SYSTEM_NEUTRAL(text)
	if text:lower():find(VICTORY_TEXT0:lower()) then
		if isHorde then
			IncreaseBattlegroundsWins(Glory)
		else
			IncreaseBattlegroundsLosses(Glory)
		end
	elseif text:lower():find(VICTORY_TEXT1:lower()) then
		if not isHorde then
			IncreaseBattlegroundsWins(Glory)
		else
			IncreaseBattlegroundsLosses(Glory)
		end
	end
end
--]]

local lastUpdate = GetTime()
function events:UPDATE_BATTLEFIELD_STATUS()
	if not GetBattlefieldWinner() or lastUpdate > GetTime() then
		return
	end
	lastUpdate = GetTime() + 125
	if GetBattlefieldWinner() == 0 then
		if isHorde then
			IncreaseBattlegroundsWins(Glory)
		else
			IncreaseBattlegroundsLosses(Glory)
		end
	elseif GetBattlefieldWinner() == 1 then
		if not isHorde then
			IncreaseBattlegroundsWins(Glory)
		else
			IncreaseBattlegroundsLosses(Glory)
		end	
	end
end

function events:CHAT_MSG_BG_SYSTEM_HORDE(text)
	if Glory:IsInWarsongGulch() then
		local hordeFC = text:match(PATTERN_ALLIANCE_FLAG_PICKED_UP)
		if hordeFC then
			Glory.hordeFC = hordeFC
			events:TriggerEvent("Glory_AllianceFlagPickedUp", Glory.hordeFC)
			events:TriggerEvent("Glory_AllianceFlagCarrierUpdate", Glory.hordeFC)
			if not isHorde then
				events:TriggerEvent("Glory_FriendlyFlagPickedUp", Glory.hordeFC)
				events:TriggerEvent("Glory_FriendlyFlagCarrierUpdate", Glory.hordeFC)
			else
				events:TriggerEvent("Glory_HostileFlagPickedUp", Glory.hordeFC)
				events:TriggerEvent("Glory_HostileFlagCarrierUpdate", Glory.hordeFC)
			end
			return
		end
		
		if text:find(PATTERN_ALLIANCE_FLAG_CAPTURED) then
			local hordeFC = Glory.hordeFC
			Glory.allianceFC = nil
			Glory.hordeFC = nil
			events:TriggerEvent("Glory_AllianceFlagCaptured", hordeFC)
			if not isHorde then
				events:TriggerEvent("Glory_FriendlyFlagCaptured", hordeFC)
			else
				events:TriggerEvent("Glory_HostileFlagCaptured", hordeFC)
			end
			events:TriggerEvent("Glory_FriendlyFlagCarrierUpdate", nil)
			events:TriggerEvent("Glory_HostileFlagCarrierUpdate", nil)
			events:TriggerEvent("Glory_AllianceFlagCarrierUpdate", nil)
			events:TriggerEvent("Glory_HordeFlagCarrierUpdate", nil)
			return
		end
		
		if text:find(PATTERN_HORDE_FLAG_DROPPED) then
			local allianceFC = Glory.allianceFC
			Glory.allianceFC = nil
			events:TriggerEvent("Glory_HordeFlagDropped", allianceFC)
			if isHorde then
				events:TriggerEvent("Glory_FriendlyFlagDropped", allianceFC)
				events:TriggerEvent("Glory_HostileFlagCarrierUpdate", nil)
			else
				events:TriggerEvent("Glory_HostileFlagDropped", allianceFC)
				events:TriggerEvent("Glory_FriendlyFlagCarrierUpdate", nil)
			end
			return
		end
	elseif Glory:IsInArathiBasin() or Glory:IsInAlteracValley() then
		events:BattlefieldObjectiveEventProcessing(text)
	end
end
 
function events:CHAT_MSG_BG_SYSTEM_ALLIANCE(text)
	if Glory:IsInWarsongGulch() then
		local allianceFC = text:match(PATTERN_HORDE_FLAG_PICKED_UP)
		if allianceFC then
			Glory.allianceFC = allianceFC
			events:TriggerEvent("Glory_HordeFlagPickedUp", Glory.allianceFC)
			if isHorde then
				events:TriggerEvent("Glory_FriendlyFlagPickedUp", Glory.allianceFC)
				events:TriggerEvent("Glory_HostileFlagCarrierUpdate", Glory.allianceFC)
			else
				events:TriggerEvent("Glory_HostileFlagPickedUp", Glory.allianceFC)
				events:TriggerEvent("Glory_FriendlyFlagCarrierUpdate", Glory.allianceFC)
			end
			return
		end
		
		if text:find(PATTERN_HORDE_FLAG_CAPTURED) then
			local alliance = Glory.allianceFC
			Glory.allianceFC = nil
			Glory.hordeFC = nil
			events:TriggerEvent("Glory_HordeFlagCaptured", allianceFC)
			if isHorde then
				events:TriggerEvent("Glory_FriendlyFlagCaptured", allianceFC)
			else
				events:TriggerEvent("Glory_HostileFlagCaptured", allianceFC)
			end
			events:TriggerEvent("Glory_FriendlyFlagCarrierUpdate", nil)
			events:TriggerEvent("Glory_HostileFlagCarrierUpdate", nil)
			events:TriggerEvent("Glory_AllianceFlagCarrierUpdate", nil)
			events:TriggerEvent("Glory_HordeFlagCarrierUpdate", nil)
			return
		end
		
		if text:find(PATTERN_ALLIANCE_FLAG_DROPPED) then
			local hordeFC = Glory.hordeFC
			Glory.hordeFC = nil
			events:TriggerEvent("Glory_AllianceFlagDropped", hordeFC)
			if not isHorde then
				events:TriggerEvent("Glory_FriendlyFlagDropped", hordeFC)
				events:TriggerEvent("Glory_HostileFlagCarrierUpdate", nil)
			else
				events:TriggerEvent("Glory_HostileFlagDropped", hordeFC)
				events:TriggerEvent("Glory_FriendlyFlagCarrierUpdate", nil)
			end
			return
		end
	elseif Glory:IsInArathiBasin() or Glory:IsInAlteracValley() then
		events:BattlefieldObjectiveEventProcessing(text)
	end
end

function events:CHAT_MSG_MONSTER_YELL(text)
	if Glory:IsInAlteracValley() then
		if not text:lower():find(VICTORY_TEXT0:lower()) and not text:lower():find(VICTORY_TEXT1:lower()) then
			events:BattlefieldObjectiveEventProcessing(text)
		end
	end
end
 
function events:BattlefieldObjectiveEventProcessing(text) 
	local node, faction
	text = preparseEventText and preparseEventText(text) or text;
	for k, pattern in pairs(BGChatAnnouncements.BGObjectiveClaimedAnnouncements) do
		node, faction = text:match(pattern)
		if node then
			if node == FACTION_ALLIANCE or node == FACTION_HORDE then
				node, faction = faction, node
			end
			events:OnObjectiveClaimed(BGPatternReplacements[node] or node, faction)
			events:TriggerEvent("Glory_ObjectiveClaimed", BGPatternReplacements[node] or node, faction)
			return
		end
	end
	for k, pattern in pairs(BGChatAnnouncements.BGObjectiveCapturedAnnouncements) do
		node, faction = text:match(pattern)
		if node then
			if node == FACTION_ALLIANCE or node == FACTION_HORDE then
				node, faction = faction, node
			end
			events:OnObjectiveCaptured(BGPatternReplacements[node] or node, faction)
			events:TriggerEvent("Glory_ObjectiveCaptured", BGPatternReplacements[node] or node, faction)
			return
		end
	end
	for k, pattern in pairs(BGChatAnnouncements.BGObjectiveAttackedAnnouncements) do
		node = text:match(pattern)
		if node then
			events:OnObjectiveAttacked(BGPatternReplacements[node] or node)
			events:TriggerEvent("Glory_ObjectiveAttacked", BGPatternReplacements[node] or node)
			return
		end
	end
	for k, pattern in pairs(BGChatAnnouncements.BGObjectiveDefendedAnnouncements) do
		node = text:match(pattern)
		if node then
			events:OnObjectiveDefended(BGPatternReplacements[node] or node)
			events:TriggerEvent("Glory_ObjectiveDefended", BGPatternReplacements[node] or node)
			return
		end
	end
	for k, pattern in pairs(BGChatAnnouncements.BGObjectiveDestroyedAnnouncements) do
		node = text:match(pattern)
		if node then
			events:OnObjectiveDestroyed(BGPatternReplacements[node] or node)
			events:TriggerEvent("Glory_ObjectiveDestroyed", BGPatternReplacements[node] or node)
			return
		end
	end
end 

function events:CHAT_MSG_COMBAT_FACTION_CHANGE(text)
	local faction, rep = deformat(text, FACTION_STANDING_INCREASED)
	if faction and rep then
		if faction == FACTION_DEFILERS or faction == FACTION_FROSTWOLF_CLAN or faction == FACTION_WARSONG_OUTRIDERS or faction == FACTION_LEAGUE_OF_ARATHOR or faction == FACTION_STORMPIKE_GUARD or faction == FACTION_SILVERWING_SENTINELS then
			events:TriggerEvent("Glory_FactionGain", faction, rep)
		end
	end
end

function events:CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS()
	Glory.lastHostileTime = GetTime()
end
events.CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = events.CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS

function events:UNIT_FACTION()
	if not UnitIsPVP("player") and Glory.permaPvP then
		Glory.permaPvP = false
		events:TriggerEvent("Glory_UpdatePermanentPvP", Glory.permaPvP)
	end
	if UnitIsPVP("player") or Glory:IsInBattlegrounds() then
		Glory.pvpTime = GetTime()
		events:TriggerEvent("Glory_UpdatePvPCooldown", Glory:GetPvPCooldown())
	else
		events:TriggerEvent("Glory_UpdatePvPCooldown", 0)
	end
end

function events:UPDATE_WORLD_STATES()
	local resData = BattlefieldZoneResourceData[Glory:GetActiveBattlefieldZone()]
	if resData and Glory:GetNumAllianceBases() and Glory:GetNumHordeBases() then
		-- Common
		local goalResources = resData[table.getn(resData)]
		-- Alliance
		resources = Glory:GetAllianceScoreString():match("(%d+)/")
		bases = Glory:GetNumAllianceBases()
		if resources and bases and (resources ~= Glory.aLastResources or bases ~= Glory.aLastBases) then
			Glory.aResourceTTV = (goalResources - resources) / resData[bases]
			Glory.aLastResources = resources
			Glory.aLastBases = bases
			Glory.aLastUpdate = GetTime()
		end
		-- Horde
		resources = Glory:GetHordeScoreString():match("(%d+)/")
		bases = Glory:GetNumHordeBases()
		if resources and bases and (resources ~= Glory.hLastResources or bases ~= Glory.hLastBases) then
			Glory.hResourceTTV = (goalResources - resources) / resData[bases]
			Glory.hLastResources = resources
			Glory.hLastBases = bases
			Glory.hLastUpdate = GetTime()
		end
	end
end

function events:PLAYER_ENTERING_WORLD()
	events:UNIT_FACTION()
--	SetMapToCurrentZone()
	if Glory:IsInBattlegrounds()--[[ and GetNumMapLandmarks() > 0]] then
		events:InitializeBattlefieldObjectives()
	else
		events:ClearBattlefieldObjectives()
	end
end

function events:PLAYER_DEAD()
	if GetTime() <= Glory.lastHostileTime + 15 then
		IncreaseDeaths(Glory)
	end
end

function events:UPDATE_BATTLEFIELD_SCORE()
	for k,v in pairs(enemyList) do
		enemyList[k] = nil
	end
	for i = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction = GetBattlefieldScore(i)
		if faction == (isHorde and 1 or 0) then
			local realName, realm = name:match("(.*)%-(.*)")
			if not realName then
				realName = name
				realm = playerRealm
			end
			enemyList[realName] = realm
		end
	end
end

do
	local ratios = {
		[2] = 0.76,
		[3] = 0.88,
		[5] = 1,
	}

	function Glory:GetArenaPointsFromRating(rating, teamsize)
		rating = tonumber(rating)
		teamsize = tonumber(type(teamsize) == "string" and teamsize:match("%d") or teamsize)
		if not rating then
			self:error("Invalid arg1: must be a number")
		end
		if not teamsize or not ratios[teamsize] then
			self:error("Invalid arg2: must be a team size")
		end
		local points
		if rating > 1500 then
			points = 1511.26 / (1 + 1639.28 * math.exp(-0.00412 * rating))
		else
			points = 0.22 * rating + 14
		end
		return math.floor(0.5 + points * ratios[teamsize])
	end

	function Glory:GetArenaRatingFromPoints(points, teamsize)
		points = tonumber(points)
		teamsize = tonumber(type(teamsize) == "string" and teamsize:match("%d") or teamsize)
		if not points then
			self:error("Invalid arg1: must be a number")
		end
		if not teamsize or not ratios[teamsize] then
			self:error("Invalid arg2: must be a team size")
		end

		rating = math.log((1426.79 / (918.836 * points/ratios[teamsize])) - (1/918.836)) / (-0.00386405)

		if rating <= 1500 then
			rating = ((points/ratios[teamsize]) + 194) / 0.38
		end
		if (rating > 0) and (rating <= 4000) then
			return math.floor(rating - 0.5)
		else
			return L["Impossible"]
		end
	end
end

function Glory:IsInBattlegrounds()
--	local zone = GetRealZoneText()
--	return zone == WARSONG_GULCH or zone == ARATHI_BASIN or zone == ALTERAC_VALLEY
--	return (MiniMapBattlefieldFrame.status == "active")
	return (select(2,IsInInstance()) == "pvp")
end

function Glory:IsInWarsongGulch()
	return GetRealZoneText() == WARSONG_GULCH
end

function Glory:IsInArathiBasin()
	return GetRealZoneText() == ARATHI_BASIN
end

function Glory:IsInAlteracValley()
	return GetRealZoneText() == ALTERAC_VALLEY
end

function Glory:IsInEyeOfTheStorm()
	return GetRealZoneText() == EYE_OF_THE_STORM
end

local function copyTable(to, from)
	for k, v in pairs(from) do
		to[k] = v
	end
	return to
end

local tdate, start, done
local firstbg = { [2006] = 2, [2007] = 2 }
local function GetBattlegroundWeek(bgdate)
	if bgdate.year < 2006 then
		Glory:error("Cannot calculate battleground weekends for dates before year 2006. A date in year %s was given.", bgdate.year)
	end
	local bgweekday = math.fmod(bgdate.wday + 4, 7) + 1
	local bgweek = math.floor((bgdate.yday + 6 - bgweekday) / 7) + 1
	if not firstbg[bgdate.year] then
		if not tdate then
			tdate = {}
		end
		tdate = copyTable(tdate, bgdate)
		tdate.day = 1
		tdate.month = 1
		tdate = date("*t", time(tdate))
		local d = math.fmod(tdate.wday + 4, 7) + 1
		tdate.day = 31
		tdate.month = 12
		tdate.year = tdate.year - 1
		tdate = date("*t", time(tdate))
		local _, _, bg = GetBattlegroundWeek(tdate)
		if d == 1 then
			firstbg[bgdate.year] = math.fmod(bg, 4) + 1
		else
			firstbg[bgdate.year] = bg
		end
	end
	local bg = math.fmod(bgweek + firstbg[bgdate.year] - 2, 4) + 1
	return bgweekday, bgweek, bg
end

local function GetCurrentOrNextBattlegroundWeekend(week)
	local now = date("*t")
	local bgweekday, bgweek, bg = GetBattlegroundWeek(now)
	local bginweeks
	if bg <= week then
		bginweeks = week - bg
	else
		bginweeks = week + 4 - bg
	end
	if not start then
		start = {}
	end
	start = copyTable(start, now)
	start.day = start.day + 4 - bgweekday + 7 * bginweeks
	start.hour = 0
	start.min = 0
	start.sec = 0
	start = date("*t", time(start))
	if not done then
		done = {}
	end
	done = copyTable(done, now)
	done.day = done.day + 7 - bgweekday + 7 * bginweeks
	done.hour = 23
	done.min = 59
	done.sec = 59
	done = date("*t", time(done))
	local sMonth
	local dMonth
	if start.month == done.month then
		sMonth = date(MONTH_LONG_ABBR, time(start))
		dMonth = sMonth
	else
		sMonth = date(MONTH_SHORT_ABBR, time(start))
		dMonth = date(MONTH_SHORT_ABBR, time(done))
	end
	return sMonth, start.day, dMonth, done.day, time(start) <= time(now) and time(now) <= time(done)
end

function Glory:GetCurrentOrNextAlteracWeekend()
	return GetCurrentOrNextBattlegroundWeekend(1)
end

function Glory:GetCurrentOrNextWarsongWeekend()
	return GetCurrentOrNextBattlegroundWeekend(2)
end

function Glory:GetCurrentOrNextArathiWeekend()
	return GetCurrentOrNextBattlegroundWeekend(3)
end

function Glory:GetCurrentOrNextEyeOfTheStormWeekend()
	return GetCurrentOrNextBattlegroundWeekend(4)
end

function Glory:_TogglePVP() --should probably change permaPVP to 1/0 instead of true/nil
	if GetPVPDesired() == 1 then
		self.permaPVP = true
	else
		self.permaPVP = nil
	end
	events:TriggerEvent("Glory_UpdatePermanentPvP", self.permaPvP)
	self.pvpTime = GetTime()
end

function Glory:GetTodayHKs(person, realm)
	if person then
		self:argCheck(person, 2, "string")
		if realm and realm ~= playerRealm then
			self:argCheck(realm, 3, "string")
			person = person .. "-" .. realm
		end
		return self.data.hks[person] or 0
	else
		return self.data.todayHK
	end
end

function Glory:GetTodayDeaths()
	return self.data.todayDeaths
end

function Glory:GetTodayHKHonor()
	return self.data.todayHKHonor
end

function Glory:GetTodayBonusHonor()
	return self.data.todayBonusHonor
end

function Glory:GetTodayHonor()
	return self.data.todayHKHonor + self.data.todayBonusHonor
end

function Glory:GetBattlegroundsWins()
	return self.data.wsgWin + self.data.abWin + self.data.avWin + self.data.eotsWin
end

function Glory:GetWarsongGulchWins()
	return self.data.wsgWin
end

function Glory:GetArathiBasinWins()
	return self.data.abWin
end

function Glory:GetAlteracValleyWins()
	return self.data.avWin
end

function Glory:GetEyeOfTheStormWins()
	return self.data.eotsWin
end

function Glory:GetBattlegroundsLosses()
	return self.data.wsgLoss + self.data.abLoss + self.data.avLoss + self.data.eotsLoss
end

function Glory:GetWarsongGulchLosses()
	return self.data.wsgLoss
end

function Glory:GetArathiBasinLosses()
	return self.data.abLoss
end

function Glory:GetAlteracValleyLosses()
	return self.data.avLoss
end

function Glory:GetEyeOfTheStormLosses()
	return self.data.eotsLoss
end

function Glory:ResetBGScores()
	self.data.wsgWin = 0
	self.data.wsgLoss = 0
	self.data.abWin = 0
	self.data.abLoss = 0
	self.data.avWin = 0
	self.data.avLoss = 0
	self.data.eotsWin = 0
	self.data.eotsLoss = 0
	events:TriggerEvent("Glory_BGResetScores")
end

function Glory:IsPermanentPvP()
	return self.permaPvP
end

function Glory:GetPvPCooldown()
	if self:IsInBattlegrounds() or self.permaPvP then
		return 300
	end
	local t = self.pvpTime - GetTime() + 300
	if t < 0 or not UnitIsPVP("player") then
		return 0
	else
		return t
	end
end

function Glory:GetRankLimitInfo()
	local level = UnitLevel("player")
	if level < 10 then
		return NONE, 0
	elseif level <= 32 then
		return GetPVPRankInfo(7)
	elseif level <= 37 then
		return GetPVPRankInfo(8)
	elseif level <= 40 then
		return GetPVPRankInfo(9)
	elseif level <= 43 then
		return GetPVPRankInfo(10)
	elseif level <= 45 then
		return GetPVPRankInfo(11)
	elseif level <= 47 then
		return GetPVPRankInfo(12)
	elseif level <= 50 then
		return GetPVPRankInfo(13)
	elseif level <= 52 then
		return GetPVPRankInfo(14)
	elseif level <= 54 then
		return GetPVPRankInfo(15)
	elseif level <= 56 then
		return GetPVPRankInfo(16)
	elseif level <= 58 then
		return GetPVPRankInfo(17)
	else
		return GetPVPRankInfo(18)
	end
end

function Glory:GetRatingLimit()
	local level = UnitLevel("player")
	if level < 10 then
		return 0
	elseif level <= 29 then
		return 6500
	elseif level <= 35 then
		return 7150 + (level - 30) * 975
	elseif level <= 39 then
		return 13325 + (level - 36) * 1300
	elseif level <= 43 then
		return 18850 + (level - 40) * 1625
	elseif level <= 52 then
		return 26000 + (level - 44) * 2275
	elseif level <= 59 then
		return 46800 + (level - 53) * 2600
	else
		return 65000
	end
end

function Glory:GetStanding(name)
	name = name or playerName
	self:argCheck(name, 2, "string")
	for i=1, GetNumBattlefieldScores() do
		if name == GetBattlefieldScore(i) then
			return i
		end
	end
end

function Glory:GetKillingBlows(name)
	name = name or playerName
	self:argCheck(name, 2, "string")
	for i=1, GetNumBattlefieldScores() do
		local unit, killingBlows = GetBattlefieldScore(i)
		if unit == name then
			return killingBlows
		end
	end
end

function Glory:GetHonorableKills(name)
	name = name or playerName
	self:argCheck(name, 2, "string")
	for i=1, GetNumBattlefieldScores() do
		local unit, _, honorableKills = GetBattlefieldScore(i)
		if unit == name then
			return honorableKills
		end
	end
end

function Glory:GetDeaths(name)
	name = name or playerName
	self:argCheck(name, 2, "string")
	for i=1, GetNumBattlefieldScores() do
		local unit, _, _, deaths = GetBattlefieldScore(i)
		if unit == name then
			return deaths
		end
	end
end

function Glory:GetBonusHonor(name)
	name = name or playerName
	self:argCheck(name, 2, "string")
	for i=1, GetNumBattlefieldScores() do
		local unit, _, _, _, bonusHonor = GetBattlefieldScore(i)
		if unit == name then
			return bonusHonor
		end
	end
end

function Glory:GetDamageDone(name)
	name = name or playerName
	self:argCheck(name, 2, "string")
	for i=1, GetNumBattlefieldScores() do
		local unit, _, _, _, _, _, _, _, _, damagedone = GetBattlefieldScore(i)
		if unit == name then
			return damagedone
		end
	end
end

function Glory:GetHealingDone(name)
	name = name or playerName
	self:argCheck(name, 2, "string")
	for i=1, GetNumBattlefieldScores() do
		local unit, _, _, _, _, _, _, _, _, _, healingdone = GetBattlefieldScore(i)
		if unit == name then
			return healingdone
		end
	end
end

function Glory:GetActiveBattlefieldZone()
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local status, mapName = GetBattlefieldStatus(i)
		if status == "active" then
			return mapName
		end
	end
end

function Glory:GetActiveBattlefieldUniqueID()
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local status, mapName, instanceID = GetBattlefieldStatus(i)
		if status == "active" then
			return mapName .. " " .. instanceID
		end
	end
end

local function queuedBattlefieldIndicesIter(_, position)
	position = position + 1
	while position <= MAX_BATTLEFIELD_QUEUES do
		local status, name = GetBattlefieldStatus(position)
		if status == "queued" then
			return position, name
		end
		position = position + 1
	end
	return nil
end
function Glory:IterateQueuedBattlefieldZones()
	return queuedBattlefieldIndicesIter, nil, 0
end

local function GetHolder(self, node)
	local poi = self:NodeToPOI(node)
	if self:IsUncontrolled(node) then
		return BGObjectiveDescriptions.UNCONTROLLED_PLAIN or BGObjectiveDescriptions.UNCONTROLLED
	end
	if poi and not self:IsDestroyed(poi) then
		description = select(2, GetMapLandmarkInfo(poi))
		if description and description:find(PATTERN_OBJECTIVE_HOLDER) then
			local faction = description:match(PATTERN_OBJECTIVE_HOLDER)
			if faction:find(FACTION_ALLIANCE) then
				return FACTION_ALLIANCE
			elseif faction:find(FACTION_HORDE) then
				return FACTION_HORDE
			else
				return faction
			end
		end
	end
end

function Glory:IsBattlefieldObjective(node)
	self:argCheck(node, 2, "string", "number")
	local poi = self:NodeToPOI(node)
	if poi and (GetHolder(self, node) or self:IsInConflict(node) or self:IsDestroyed(node)) then
		return true
	end
	return false
end

function Glory:IsInConflict(node)
	self:argCheck(node, 2, "string", "number")
	local poi = self:NodeToPOI(node)
	if poi then
		local _, description = GetMapLandmarkInfo(poi)
		if description and description:match(BGObjectiveDescriptions.IN_CONFLICT) then
			return true
		end
	end
	return false
end

function Glory:IsAllianceControlled(node)
	self:argCheck(node, 2, "string", "number")
	local poi = self:NodeToPOI(node)
	if poi then
		local _, description = GetMapLandmarkInfo(poi)
		if description and description:match(BGObjectiveDescriptions.ALLIANCE_CONTROLLED) then
			return true
		end
	end
	return false
end

function Glory:IsHordeControlled(node)
	self:argCheck(node, 2, "string", "number")
	local poi = self:NodeToPOI(node)
	if poi then
		local description = select(2, GetMapLandmarkInfo(poi))
		if description and description:match(BGObjectiveDescriptions.HORDE_CONTROLLED) then
			return true
		end
	end
	return false
end

if isHorde then
	Glory.IsFriendlyControlled = Glory.IsHordeControlled
	Glory.IsHostileControlled = Glory.IsAllianceControlled
else
	Glory.IsFriendlyControlled = Glory.IsAllianceControlled
	Glory.IsHostileControlled = Glory.IsHordeControlled
end

function Glory:IsUncontrolled(node)
	self:argCheck(node, 2, "string", "number")
	local poi = self:NodeToPOI(node)
	if poi then
		local description = select(2, GetMapLandmarkInfo(poi))
		if description and description:match(BGObjectiveDescriptions.UNCONTROLLED) then
			return true
		end
	end
	return
end

function Glory:IsDestroyed(node)
	self:argCheck(node, 2, "string", "number")
	local poi = self:NodeToPOI(node)
	if poi then
		local description = select(2, GetMapLandmarkInfo(poi))
		if description and description:match(BGObjectiveDescriptions.DESTROYED) then
			return true
		end
	end
	return
end

local function GetBattlefieldObjectiveStatus(index)
	if not next(Glory.battlefieldObjectiveStatus) and GetNumMapLandmarks() > 0 then
		events:InitializeBattlefieldObjectives()
	end
	if index ~= nil and Glory.battlefieldObjectiveStatus then
		return Glory.battlefieldObjectiveStatus[index];
	else
		return Glory.battlefieldObjectiveStatus;
	end
end

function Glory:GetTimeAttacked(node)
	self:argCheck(node, 2, "string", "number")
	local nodeStatus = GetBattlefieldObjectiveStatus(node);
	return nodeStatus and nodeStatus.timeAttacked
end

function Glory:GetTimeToCapture(node)
	self:argCheck(node, 2, "string", "number")
	local t = BattlefieldZoneObjectiveTimes[self:GetActiveBattlefieldZone()] or 0
	local nodeStatus = GetBattlefieldObjectiveStatus(node);
	return nodeStatus and nodeStatus.timeAttacked and t - GetTime() + nodeStatus.timeAttacked
end

function Glory:GetName(node)
	self:argCheck(node, 2, "string", "number")
	local nodeStatus = GetBattlefieldObjectiveStatus(node);
	return nodeStatus and nodeStatus.name
end

function Glory:GetDefender(node)
	self:argCheck(node, 2, "string", "number")
	local nodeStatus = GetBattlefieldObjectiveStatus(node);
	return nodeStatus and nodeStatus.defender 
end

function Glory:GetAttacker(node)
	self:argCheck(node, 2, "string", "number")
	local nodeStatus = GetBattlefieldObjectiveStatus(node);
	return nodeStatus and nodeStatus.attacker
end

local function objectiveNodesIter(t, position)
	local k = next(t, position)
	while k ~= nil and type(k) ~= "number" do
		k = next(t, position)
	end
	return k
end

function Glory:IterateObjectiveNodes()
	return objectiveNodesIter, self.battlefieldObjectiveStatus, nil
end

local function sortedObjectiveNodesIter(t, position)
	position = position + 1
	if position <= table.getn(t) then
		return position, t[position]
	else
		t = del(t)
		return nil
	end
end
local mySort
function Glory:IterateSortedObjectiveNodes()
	local t = new()
	for poi in pairs(GetBattlefieldObjectiveStatus()) do
		if type(poi) == "number" then
			table.insert(t, poi)
		end
	end
	if not mySort then
		mySort = function(a, b)
			local nodeA = GetBattlefieldObjectiveStatus(a);
			local nodeB = GetBattlefieldObjectiveStatus(b);
			return nodeA.ypos and nodeB.ypos and nodeA.ypos < nodeB.ypos
		end
	end
	table.sort(t, mySort)
	return sortedObjectiveNodesIter, t, 0
end

function events:ClearBattlefieldObjectives()
	for i = 1, table.getn(Glory.battlefieldObjectiveStatus) do
		local o = Glory.battlefieldObjectiveStatus[i]
		if o then
			if Glory.battlefieldObjectiveStatus[o.node] == o then
				Glory.battlefieldObjectiveStatus[o.node] = nil
			end
			Glory.battlefieldObjectiveStatus[i] = del(o)
		end
	end
	for k in pairs(Glory.battlefieldObjectiveStatus) do
		Glory.battlefieldObjectiveStatus[k] = del(Glory.battlefieldObjectiveStatus[k])
		k = nil
	end
end

function events:InitializeBattlefieldObjectives()
	events:ClearBattlefieldObjectives()
	local map = GetMapInfo()
	if map ~= "WarsongGulch" and map ~= "ArathiBasin" and map ~= "AlteracValley" and map ~= "NetherstormArena" then
		return
	end
	local numPOIS = GetNumMapLandmarks()
	for i=1, numPOIS do
		if Glory:IsBattlefieldObjective(i) then
			local node, _, _, _, y = GetMapLandmarkInfo(i)
			Glory.battlefieldObjectiveStatus[i] = {
				name = node,
				ypos = y,
				defender = GetHolder(Glory, i),
				inConflict = Glory:IsInConflict(i),
				isDestroyed = Glory:IsDestroyed(i),
			}
			Glory.battlefieldObjectiveStatus[node] = Glory.battlefieldObjectiveStatus[i]
		end
	end
end

function events:OnObjectiveClaimed(node, faction)
	local poi = Glory:NodeToPOI(node)
	if poi then
		local n = GetBattlefieldObjectiveStatus(poi)
		if n then
			n.attacker = faction
			n.inConflict = true
			n.timeAttacked = GetTime()
		end
	end	
end

function events:OnObjectiveCaptured(node, faction)
	local poi = Glory:NodeToPOI(node)
	if poi then
		local n = GetBattlefieldObjectiveStatus(poi)
		if n then
			n.defender = faction or GetHolder(Glory, node)
			n.attacker = nil
			n.inConflict = nil
			n.timeAttacked = nil
		end
	end
end

function events:OnObjectiveAttacked(node)
	local poi = Glory:NodeToPOI(node)
	if poi then
		local n = GetBattlefieldObjectiveStatus(poi)
		if n then
			if n.defender == FACTION_ALLIANCE then
				n.attacker = FACTION_HORDE
			else
				n.attacker = FACTION_ALLIANCE
			end
			n.inConflict = true
			n.timeAttacked = GetTime()
		end
	end
end

function events:OnObjectiveDefended(node)
	local poi = Glory:NodeToPOI(node)
	if poi then
		local n = GetBattlefieldObjectiveStatus(poi)
		if n then
			n.attacker = nil
			n.inConflict = nil
			n.timeAttacked = nil
		end
	end
end

function events:OnObjectiveDestroyed(node)
	local poi = Glory:NodeToPOI(node)
	if poi then
		local n = GetBattlefieldObjectiveStatus(poi)
		if n then
			n.isDestroyed = true
			n.defender = nil
			n.attacker = nil
			n.inConflict = nil
			n.timeAttacked = nil
		end
	end
end

function Glory:GetAllianceFlagCarrier()
	return self.allianceFC
end

function Glory:GetHordeFlagCarrier()
	return self.hordeFC
end

if isHorde then
	Glory.GetFriendlyFlagCarrier = Glory.GetHordeFlagCarrier
	Glory.GetHostileFlagCarrier = Glory.GetAllianceFlagCarrier
else
	Glory.GetFriendlyFlagCarrier = Glory.GetAllianceFlagCarrier
	Glory.GetHostileFlagCarrier = Glory.GetHordeFlagCarrier
end

function Glory:GetFlagCarrier(faction)
	self:argCheck(faction, 2, "string", "number")
	if faction == FACTION_ALLIANCE or faction == "Alliance" or faction == 1 then
		return self.allianceFC
	else
		return self.hordeFC
	end
end

function Glory:GetNumAllianceBases()
	local _, _, s = GetWorldStateUIInfo(1)
	if s then
		local bases = tostring(s):match(PATTERN_GWSUII_BASES)
		return tonumber(bases)
	end
end

function Glory:GetNumHordeBases()
	local _, _, s = GetWorldStateUIInfo(2)
	if s then
		local bases = tostring(s):match(PATTERN_GWSUII_BASES)
		return tonumber(bases)
	end
end

if isHorde then
	Glory.GetNumFriendlyBases = Glory.GetNumHordeBases
	Glory.GetNumHostileBases = Glory.GetNumAllianceBases
else
	Glory.GetNumFriendlyBases = Glory.GetNumAllianceBases
	Glory.GetNumHostileBases = Glory.GetNumHordeBases
end

function Glory:GetNumBases(team)
	self:argCheck(team, 2, "string", "number")
	if team == FACTION_ALLIANCE or team == "Alliance" or team == 1 then
		return self:GetNumAllianceBases()
	else
		return self:GetNumHordeBases()
	end
end

function Glory:GetNumAllianceResources()
	local _, _, s = GetWorldStateUIInfo(1)
	if s then
		local resources = s:match(PATTERN_GWSUII_RESOURCES)
		return tonumber(resources)
	end
end

function Glory:GetNumHordeResources()
	local _, _, s = GetWorldStateUIInfo(2)
	if s then
		local resources = s:match(PATTERN_GWSUII_RESOURCES)
		return tonumber(resources)
	end
end

if isHorde then
	Glory.GetNumFriendlyResources = Glory.GetNumHordeResources
	Glory.GetNumHostileResources = Glory.GetNumAllianceResources
else
	Glory.GetNumFriendlyResources = Glory.GetNumAllianceResources
	Glory.GetNumHostileResources = Glory.GetNumHordeResources
end

function Glory:GetNumTeamResources(team)
	self:argCheck(team, 2, "string", "number")
	if team == FACTION_ALLIANCE or team == "Alliance" or team == 1 then
		return self:GetNumAllianceResources()
	else
		return self:GetNumHordeResources()
	end
end

function Glory:GetAllianceTTV()
	return self.aResourceTTV - GetTime() + self.aLastUpdate
end

function Glory:GetHordeTTV()
	return self.hResourceTTV - GetTime() + self.hLastUpdate
end

function Glory:GetTeamTTV(team)
	self:argCheck(team, 2, "string", "number")
	if team == FACTION_ALLIANCE or team == "Alliance" or team == 1 then
		return self:GetAllianceTTV()
	else
		return self:GetHordeTTV()
	end
end

if isHorde then
	Glory.GetFriendlyTTV = Glory.GetHordeTTV
	Glory.GetHostileTTV = Glory.GetAllianceTTV
else
	Glory.GetFriendlyTTV = Glory.GetAllianceTTV
	Glory.GetHostileTTV = Glory.GetHordeTTV
end
	
function Glory:GetAllianceScoreString()
	local _, _, s = GetWorldStateUIInfo(1)
	if s then
		local scoreString = s:match(PATTERN_GWSUII_SCORE)
		return scoreString
	end
end

function Glory:GetHordeScoreString()
	local _, _, s = GetWorldStateUIInfo(2)
	if s then
		local scoreString = s:match(PATTERN_GWSUII_SCORE)
		return scoreString
	end
end

if isHorde then
	Glory.GetFriendlyScoreString = Glory.GetHordeScoreString
	Glory.GetHostileScoreString = Glory.GetAllianceScoreString
else
	Glory.GetFriendlyScoreString = Glory.GetAllianceScoreString
	Glory.GetHostileScoreString = Glory.GetHordeScoreString
end

function Glory:GetTeamScoreString(team)
	if team == FACTION_ALLIANCE or team == "Alliance" or team == 1 then
		return self:GetAllianceScoreString()
	else
		return self:GetHordeScoreString()
	end
end

function Glory:GetNumAlliancePlayers()
	local numPlayers = 0
	for i = 1, GetNumBattlefieldScores() do
		local _, _, _, _, _, faction = GetBattlefieldScore(i)
		if faction == 1 then
			numPlayers = numPlayers + 1
		end
	end
	return numPlayers
end

function Glory:GetNumHordePlayers()
	local numPlayers = 0
	for i = 1, GetNumBattlefieldScores() do
		local _, _, _, _, _, faction = GetBattlefieldScore(i)
		if faction == 0 then
			numPlayers = numPlayers + 1
		end
	end
	return numPlayers
end

if isHorde then
	Glory.GetNumFriendlyPlayers = Glory.GetNumHordePlayers
	Glory.GetNumHostilePlayers = Glory.GetNumAlliancePlayers
else
	Glory.GetNumFriendlyPlayers = Glory.GetNumAlliancePlayers
	Glory.GetNumHostilePlayers = Glory.GetNumHordePlayers
end

function Glory:GetNumPlayers(team)
	self:argCheck(team, 2, "string", "number")
	if team == FACTION_ALLIANCE or team == "Alliance" or team == 1 then
		return self:GetNumAlliancePlayers()
	else
		return self:GetNumHordePlayers()
	end
end

function Glory:SafeNodeToPOI(node)
	if type(node) == "number" and node > 0 and node <= GetNumMapLandmarks() then
		return node
	elseif type(node) == "string" then
		for i = 1, GetNumMapLandmarks() do
			if node:lower() == GetMapLandmarkInfo(i):lower() then
				return i
			end
		end
	elseif type(node) ~= "number" then
		self:error("Bad argument #2 to `NodeToPOI' (string or number expected, got %s)", tostring(type(node)))
	else
		self:error("Bad argument #2 to `NodeToPOI' (out of bounds: [1, %d] expected, got %d)", GetNumMapLandmarks(), node)
	end
end

function Glory:NodeToPOI(node)
	if type(node) == "number" then return node end
	if type(node) == "string" then
		for i = 1, GetNumMapLandmarks() do
			if node:lower() == GetMapLandmarkInfo(i):lower() then return i end
		end
	end
end

function Glory:GetBGAcronym(bgName)
	self:argCheck(bgName, 2, "string")
	return BGAcronyms[bgName] or bgName
end

function Glory:GetServerType(servName)
	self:argCheck(servName, 2, "string", "nil")
	if not servName then
		servName = GetRealmName()
	end 
	return BGServerType[servName] or "unknown"
end

function Glory:GetBattlegroupName(servName)
	self:argCheck(servName, 2, "string", "nil")
	if not servName then
		servName = GetRealmName()
	end 
	local bg = BGServerBattleGroup[servName]
	for k,v in pairs(BGBattleGroups) do
		if v == bg then
			bg = k
		end
	end
	return bg or "unknown"
end

function Glory:GetBattlegroupNum(servName)
	self:argCheck(servName, 2, "string", "nil")
	if not servName then
		servName = GetRealmName()
	end 
	return BGServerBattleGroup[servName] or "unknown"
end


function Glory:GetBattlegroupServers(servName, resultTable)
	self:argCheck(servName, 2, "string", "nil")
	self:argCheck(servName, 3, "table", "nil")
	if not servName then
		servName = GetRealmName()
	end
	local count = 0
	local num = BGServerBattleGroup[servName] 
	for k,v in pairs(BGServerBattleGroup) do
		if v == num then 
			if resultTable then
				table.insert(resultTable, k)
			end
			count = count + 1
		end
	end

	return count
end
function Glory:GetFactionColor(faction)
	self:argCheck(faction, 2, "string", "number", "nil")
	if faction then
		if faction == "Alliance" or faction == FACTION_ALLIANCE or faction == 1 then
			faction = "ALLIANCE"
		elseif faction == "Horde" or faction == FACTION_HORDE or faction == 0 or faction == 2 then
			faction = "HORDE"
		end
		local cti = ChatTypeInfo["BG_SYSTEM_" .. faction]
		if cti then
			return cti.r, cti.g, cti.b
		end
	end
	return 0.7, 0.7, 0.7
end

function Glory:GetFactionHexColor(faction)
	local r, g, b = self:GetFactionColor(faction)
	return string.format("%02X%02X%02X", 255*r, 255*g, 255*b)
end

local function activate(self, oldLib, oldDeactivate)
	Glory = self
	if oldLib then
		self.registry = oldLib.registry
	else
		self.registry = {}
	end
	events:RegisterEvent("ADDON_LOADED")
	events:RegisterEvent("VARIABLES_LOADED")
	events:RegisterEvent("PLAYER_LOGOUT")
	events:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
	--events:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
	events:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	events:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	events:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
	events:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	events:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
	events:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
	events:RegisterEvent("UPDATE_WORLD_STATES")
	events:RegisterEvent("PLAYER_ENTERING_WORLD")
	events:RegisterEvent("UNIT_FACTION")
	events:RegisterEvent("PLAYER_DEAD")
	events:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
	events:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	events:VARIABLES_LOADED()
	events:ScheduleRepeatingEvent(function()
		if self:IsInBattlegrounds() then
			RequestBattlefieldScoreData()
		end
	end, 15)
	
	if not oldLib then
		local function hook()
			AceLibrary(MAJOR_VERSION):_TogglePVP()
		end
		hooksecurefunc("TogglePVP", hook)
		hooksecurefunc("SetPVP", hook)
	end
	
	self.battlefieldObjectiveStatus = new()
	self.pvpTime = 0
	self.currentBonusHonor = 0
	self.lastHostileTime = 0
	self.aLastResources = 0
	self.hLastResources = 0
	self.aLastBases = 0
	self.hLastBases = 0
	self.aLastUpdate = 0
	self.hLastUpdate = 0
	self.aResourceTTV = 0
	self.hResourceTTV = 0

	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

local function deactivate(oldLib)
	events:CancelAllScheduledEvents()
	events:UnregisterAllEvents()
end

local function external(self, major, instance)
	if major == "AceConsole-2.0" then
		local print = print
		if DEFAULT_CHAT_FRAME then
			function print(key, value)
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff7f" .. tostring(key) .. ": [|r" .. tostring(value) .. "|cffffff7f]|r")
			end
		end
		instance.RegisterChatCommand(self, { "/glory", "/glorylib" }, {
			name = MAJOR_VERSION .. "." .. MINOR_VERSION:gsub(".-(%d+).*", "%1"),
			desc = L["A library for PvP and Battlegrounds."],
			type = "group",
			args = {
				bg = {
					name = L["Battlegrounds"],
					desc = L["Show battlegrounds information"],
					type = "execute",
					func = function()
						print(L["BG Score"], self:GetBattlegroundsWins() .. "-" .. self:GetBattlegroundsLosses())
						print(L["WSG Score"], self:GetWarsongGulchWins() .. "-" .. self:GetWarsongGulchLosses())
						print(L["AB Score"], self:GetArathiBasinWins() .. "-" .. self:GetArathiBasinLosses())
						print(L["AV Score"], self:GetAlteracValleyWins() .. "-" .. self:GetAlteracValleyLosses())
						print(L["EotS Score"], self:GetEyeOfTheStormWins() .. "-" .. self:GetEyeOfTheStormLosses())
						if self:IsInBattlegrounds() then
							print(L["Current"], self:GetActiveBattlefieldUniqueID())
							print(L["Standing"], self:GetStanding())
							print(L["Killing Blows"], self:GetKillingBlows())
							print(L["Honorable Kills"], self:GetHonorableKills())
							print(L["Deaths"], self:GetDeaths())
							print(L["Bonus Honor"], self:GetBonusHonor())
							if self:IsInWarsongGulch() then
								print(L["Friendly FC"], (self:GetFriendlyFlagCarrier() or NONE))
								print(L["Hostile FC"], (self:GetHostileFlagCarrier() or NONE))
							else
								print(L["Friendly Bases"], self:GetNumFriendlyBases())
								print(L["Hostile Bases"], self:GetNumHostileBases())
								print(L["Friendly Resources"], self:GetNumFriendlyResources())
								print(L["Hostile Resources"], self:GetNumHostileResources())
							end
							print(L["Friendly Players"], self:GetNumFriendlyPlayers())
							print(L["Hostile Players"], self:GetNumHostilePlayers())
						end
					end
				},
				honor = {
					name = L["Honor"],
					desc = L["Show honor information"],
					type = "execute",
					func = function()
						print(L["Today's HKs"], self:GetTodayHKs())
						print(L["Today's Deaths"], self:GetTodayDeaths())
						print(L["Today's HK Honor"], self:GetTodayHKHonor())
						print(L["Today's Bonus Honor"], self:GetTodayBonusHonor())
						print(L["Today's Honor"], self:GetTodayHonor())
						local s
						if self:IsPermanentPvP() then
							s = L["Flagged"]
						elseif self:IsInBattlegrounds() then
							s = L["Battlegrounds"]
						else
							local t = self:GetPvPCooldown()
							if t == 0 then
								s = L["None"]
							else
								local min = floor(t / 60)
								local sec = floor(mod(t, 60))
								s = string.format("%d:%02d", min, sec)
							end
						end
						print(L["PvP Cooldown"], s)
						print(L["Rank Limit"], string.format("%s (%d)", self:GetRankLimitInfo()))
						print(L["Rating Limit"], self:GetRatingLimit())
					end
				},
				arena = {
					name = L["Arena Points"],
					desc = L["Calculate Arena Points"],
					type = "group",
					args = {
						rating = {
							name = L["Rating"],
							desc = L["Calcuate Arena Points from Rating"],
							type = "text",
							get = false,
							set = function(v)
								print(L["5v5"],self:GetArenaPointsFromRating(v,5))
								print(L["3v3"],self:GetArenaPointsFromRating(v,3))
								print(L["2v2"],self:GetArenaPointsFromRating(v,2))
							end,
							usage = L["<rating>"],
							validate = function(v)
								return tonumber(v)
							end,
						},
						point = {
							name = L["Points"],
							desc = L["Calcuate Arena Rating from Points"],
							type = "text",
							get = false,
							set = function(v)
								print(L["5v5"],self:GetArenaRatingFromPoints(v,5))
								print(L["3v3"],self:GetArenaRatingFromPoints(v,3))
								print(L["2v2"],self:GetArenaRatingFromPoints(v,2))
							end,
							usage = L["<points>"],
							validate = function(v)
								return tonumber(v)
							end,
						},
					}
				}
			}
		}, "GLORY")
	end
end

AceLibrary:Register(Glory, MAJOR_VERSION, MINOR_VERSION, activate, deactivate, external)

