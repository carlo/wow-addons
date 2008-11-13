local VERSION = tonumber(("$Revision: 50726 $"):match("%d+"))

local PitBull = PitBull
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2007-10-02 20:54:15 -0400 (Tue, 02 Oct 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local _,playerClass = UnitClass("player")

local localization = (GetLocale() == "koKR") and {
	["Position"] = "위치",
	["Position of the text."] = "문자의 위치",
	["Size"] = "크기",
	["Size of the icon."] = "아이콘의 크기",
	["Font size of the text."] = "문자의 글꼴 크기",
	["Portrait"] = "초상화",
	["Full bar"] = "Full 바",
	["Health bar"] = "생명력바",
	["Power bar"] = "마력바",
	["Reputation bar"] = "평판바",
	["Experience bar"] = "경험치바",
	["Threat bar"] = "위협바",
	["Cast bar"] = "시전바",
	["Blank space"] = "빈 공간",
	["Position of the bar relative to other bars."] = "다른 바와 관련된 바의 위치",
	["Height"] = "높이",
	["Relative height of the bar."] = "바의 상대적인 높이",
	["Height percentage"] = "높이 백분률",
	["Percentage of height that the druid mana bar will take up of the normal power bar's height."] = "드루이드 마나바가 평상시 마력바의 높이를 취할 수 있는 높이의 백분률",
	["Side"] = "측면",
	["What side of the unit frame to position the portrait at."] = "초상화가 위치할 유닛 프레임의 측면을 선택합니다.",
		["Top"] = "상단",
		["Bottom"] = "하단",
		["Left"] = "좌측",
		["Right"] = "우측",
		["Center"] = "정중앙",
		["Middle"] = "가운데",
		["Top-left"] = "상단 좌측",
		["Top-right"] = "상단 우측",
		["Bottom-left"] = "하단 좌측",
		["Bottom-right"] = "하단 우측",
		["Outside, Right"] = "바깥측면, 우측",
		["Outside, Left"] = "바깥측면, 좌측",
		["Outside, Above-left"] = "바깥측면, 좌측 위로",
		["Outside, Above-middle"] = "바깥측면, 가운데 위로",
		["Outside, Above-right"] = "바깥측면, 우측 위로",
		["Outside, Below-left"] = "바깥측면, 좌측 아래로",
		["Outside, Below-middle"] = "바깥측면, 가운데 아래로",
		["Outside, Below-right"] = "바깥측면, 우측 아래로",
		["Outside, Left-top"] = "바깥측면, 상단 좌측",
		["Outside, Left-middle"] = "바깥측면, 가운데 좌측",
		["Outside, Left-bottom"] = "바깥측면, 하단 좌측",
		["Outside, Right-top"] = "바깥측면, 상단 우측",
		["Outside, Right-middle"] = "바깥측면, 가운데 우측",
		["Outside, Right-bottom"] = "바깥측면, 하단 우측",
		["Inside, Center"] = "안쪽측면, 정중앙",
		["Inside, Top-left"] = "안쪽측면, 좌측 상단",
		["Inside, Top"] = "안쪽측면, 상단",
		["Inside, Top-right"] = "안쪽측면, 우측 상단",
		["Inside, Bottom-left"] = "안쪽측면, 좌측 하단",
		["Inside, Bottom"] = "안쪽측면, 하단",
		["Inside, Bottom-right"] = "안쪽측면, 우측 하단",
		["Inside, Left"] = "안쪽측면, 좌측",
		["Inside, Right"] = "안쪽측면, 우측",
		["Edge, Top-left"] = "가장자리, 좌측 상단",
		["Edge, Top"] = "가장자리, 상단",
		["Edge, Top-right"] = "가장자리, 우측 상단",
		["Edge, Left"] = "가장자리, 좌측",
		["Edge, Right"] = "가장자리, 우측",
		["Edge, Bottom-left"] = "가장자리, 좌측 하단",
		["Edge, Bottom"] = "가장자리, 하단",
		["Edge, Bottom-right"] = "가장자리, 우측 하단",
	["Relative height of the portrait."] = "초상화의 상대적인 높이",
	["Which side to position all aura icons at."] = "모든 오라 아이콘이 위치할 측면을 선택합니다.",
	["Options to change the side which the auras are on."] = "오라가 위치할 측면 변경을 위한 옵션",
	["Buff side"] = "버프 측면",
	["Which side to position buff icons at."] = "버프 아이콘이 위치할 측면을 선택합니다.",
	["Debuff side"] = "디버프 측면",
	["Which side to position debuff icons at."] = "디버프 아이콘이 위치할 측면을 선택합니다.",
	["What position of the unit frame to position the combo point display at."] = "콤보 포인트를 표시할 위치를 위한 유닛 프레임의 위치를 선택합니다.",
	["Class"] = "직업",
	["Health"] = "생명력",
	["Name"] = "이름",
	["Power"] = "마력",
	["Threat"] = "위협",
	["Combo points"] = "콤보 포인트",
	["Experience"] = "경험치",
	["Reputation"] = "평판",
	["None"] = "없음",
	["Frame"] = "프레임",
	["Hidden"] = "숨김",
	["Hide"] = "숨김", 
	["Custom"] = "사용자",
	["Choose your own custom text."] = "사용자 지정 문자를 선택합니다.",
	["Style"] = "양식",
	["Use a preconfigured style."] = "미리 설정된 양식을 사용합니다.",
	["Style - Custom"] = "양식 - 사용자",
	["Create a custom style for this unit type."] = "이 유닛 유형을 위한 사용자 지정 양식을 생성합니다.",
	["DogTag-1.0 tags. See http://www.wowace.com/wiki/DogTag-1.0"] = "DogTag-1.0 tags. http://www.wowace.com/wiki/DogTag-1.0을 보시요.",
	["Style - Type"] = "양식 - 유형",
	["Choose the type of pre-made styles to work with."] = "미리 만들어진 양식의 유형을 선택합니다.",
	["Enable"] = "활성화",
	["Click to disable this text from being shown."] = "보여지는 것으로 부터 이 문자를 비활성화하려면 클릭하시요.",
	["Name"] = "이름",
	["<Name>"] = "<이름>",
	["Customize the %s text."] = "%s 문자를 사용자 지정 문자로 합니다.",
	["Combat"] = "전투",
	["Other"] = "기타",
	["Create other texts."] = "다른 문자를 생성합니다.",
	["Disabled texts"] = "비활성화 문자",
	["Show some of the disabled texts."] = "비활성화 문자중 몇개를 표시합니다.",
	["New text"] = "새로운 문자",
	["Create a new text."] = "새로운 문자를 생성합니다.",
	["Change settings for the blank space."] = "빈 공간을 위해 설정을 변경합니다.",
	["Enable the blank space."] = "빈 공간을 활성화합니다.",
	["combatText"] = "전투문자",
} or {}

local L = PitBull:L("PitBull-MetaLayout", localization)

local PitBull_Aura = nil

local DogTag = Rock("LibDogTag-2.0")

local newFrame = PitBull.newFrame
local newList, del = Rock:GetRecyclingFunctions("PitBull", "newList", "del")
local deepCopy, deepDel = PitBull.deepCopy, PitBull.deepDel

local MetaLayout = {
	extraFrames = {},
	options = {
		name = {},
		desc = {},
	},
	positions = {},
}
PitBull.MetaLayout = MetaLayout

local MetaLayout_db = PitBull:GetDatabaseNamespace("MetaLayout")
MetaLayout.db = MetaLayout_db
PitBull:SetDatabaseNamespaceDefaults("MetaLayout", "profile", {
	["**"] = {
		auraSide = "bottom",
		--note, these are only used when debuffs are split
		buffSide = "bottom",
		debuffSide = "right",
		
		druidManaBarHeight = 0.25,
		
		texts = {
			['**'] = {
				custom = "",
				style = "Custom",
				styleType = "none",
				position = "frame-center",
				size = 1,
				hidden = true,
			},
			Class = {
				custom = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
				style = "Standard",
				styleType = "class",
				position = "powerBar-left",
				hidden = false,
			},
			Health = {
				custom = "[CurHP]/[MaxHP]",
				style = "Smart",
				styleType = "health",
				position = "healthBar-right",
				hidden = false,
			},
			Name = {
				custom = "[Name]",
				style = "Standard",
				styleType = "name",
				position = "healthBar-left",
				hidden = false,
			},
			Power = {
				custom = "[CurMP]/[MaxMP]",
				style = "Absolute",
				styleType = "power",
				position = "powerBar-right",
				hidden = false,
			},
			Combo = {
				style = "Standard",
				styleType = "combo",
				position = "frame-outright",
				hidden = false,
			},
			Experience = {
				style = "Standard",
				styleType = "experience",
				position = "expBar-center",
				hidden = false,
			},
			Reputation = {
				style = "Standard",
				styleType = "reputation",
				position = "repBar-center",
				hidden = false,
			},
			Threat = {
				custom = "[Threat]/[MaxThreat]",
				style = "Absolute Short",
				styleType = "threat",
				position = "threatBar-right",
				hidden = false,
			},
			combatText = {
				position = "frame-center",
				hidden = false,
			}
		},
		
		icons = {
			['**'] = {
				position = "frame-edgebottomleft",
				size = 1,
			},
			combatIcon = {
				position = "frame-edgebottomleft",
			},
			voiceIcon = {
				position = "frame-edgetopright",
			},
			restIcon = {
				position = "frame-edgebottomleft",
			},
			pvpIcon = {
				position = "frame-edgetopright",
			},
			leaderIcon = {
				position = "frame-edgetopleft",
			},
			masterIcon = {
				position = "frame-edgetopleft",
			},
			raidTargetIcon = {
				position = "frame-edgetop",
			},
		},
		
		bars = {
			['**'] = {
				height = 2,
				position = 1,
			},
			portrait = {
				position = 1,
				side = "left",
			},
			healthBar = {
				height = 5,
				position = 2,
			},
			powerBar = {
				height = 4,
				position = 3,
			},
			expBar = {
				position = 4,
			},
			repBar = {
				position = 5,
			},
			threatBar = {
				position = 6,
			},
			blankSpace = {
				position = 7,
				hidden = true,
			},
			castBar = {
				position = 8,
			},
			fullBar = {
				height = 5,
				position = 9,
			},
		},
	},
	player = {
		texts = {
			Health = {
				style = "Informational",
			}
		}
	},
	pet = {
		texts = {
			Health = {
				style = "Informational",
			}
		}
	},
	target = {
		auraSide = "right",
		comboSide = "inbottomright",
		
		texts = {
			Health = {
				style = "Informational",
			}
		},
		bars = {
			portrait = {
				side = "right",
			}
		}
	}
})

local iconPriorities = {
	-- this dictates the order which icons are laid out in.
	"leaderIcon",
	"masterIcon",
	"raidTargetIcon",
	"restIcon",
	"pvpIcon",
	"combatIcon",
	"voiceIcon",
}
for i,v in ipairs(iconPriorities) do
	iconPriorities[i] = nil
	iconPriorities[v] = i
end

local function iconPriority_sort(alpha, bravo)
	return iconPriorities[alpha] < iconPriorities[bravo]
end

function MetaLayout.extraFrames.blankSpace(unit, frame)
	if MetaLayout_db.profile[frame.group].bars.blankSpace.hidden then
		return
	end
	frame.blankSpace = newFrame("Frame", frame)
end

local barList = {
	blankSpace = true,
	healthBar = true,
	fullBar = true,
	powerBar = true,
	castBar = true,
	repBar = true,
	expBar = true,
	threatBar = true,
	portrait = true,
}

local function figureHeight(multiplier, frame)
	local num = 0
	local db = MetaLayout_db.profile[frame.group].bars
	for k in pairs(barList) do
		if frame[k] and frame[k]:IsShown() then
			if k == "portrait" then
				local portraitSide = MetaLayout_db.profile[frame.group].bars.portrait.side
				if portraitSide == "top" then
					num = num + db[k].height
				end
			else
				num = num + db[k].height
			end
		end
	end
	return db[multiplier].height * frame:GetHeight() / num
end

local function barPosition(id)
	return function(unit, frame)
		local db = MetaLayout_db.profile[frame.group]
		local tmp = newList()
		for k,v in pairs(db.bars) do
			local v_position = v.position
			if not v_position or tmp[v_position] then
				v_position = 1
				while tmp[v_position] do
					v_position = v_position + 1
				end
				v.position = v_position
			end
			tmp[v_position] = true
		end
		tmp = del(tmp)
		local portraitSide = frame.portrait and db.bars.portrait.side
		if portraitSide ~= "left" and portraitSide ~= "right" then
			portraitSide = nil
		end
		local current_barPosition = db.bars[id].position
		local bestAttach
		local bestAttach_num
		for k,v in pairs(db.bars) do
			local v_position = v.position
			if v_position < current_barPosition and frame[k] and (k ~= "portrait" or not portraitSide) then
				if not bestAttach_num or bestAttach_num < v_position then
					bestAttach = k
					bestAttach_num = v_position
				end
			end
		end
		local height = figureHeight(id, frame)
		if id == "powerBar" then
			if frame.druidManaBar then
				height = height * (1 - MetaLayout_db.profile[frame.group].druidManaBarHeight)
			end
		end
		if bestAttach then
			if bestAttach == "powerBar" and frame.druidManaBar then
				bestAttach = 'druidManaBar'
			end
			frame[id]:SetPoint("TOP", frame[bestAttach], "BOTTOM", 0, -1)
			frame[id]:SetHeight(height - 1)
		else
			frame[id]:SetPoint("TOP", frame, "TOP")
			frame[id]:SetHeight(height) -- no pixel spacing, there is always 1 spacing less than bars.
		end
		
		if portraitSide == "left" then
			frame[id]:SetPoint("LEFT", frame.portrait, "RIGHT", 2, 0)
		else
			frame[id]:SetPoint("LEFT", frame, "LEFT")
		end
		if portraitSide == "right" then
			frame[id]:SetPoint("RIGHT", frame.portrait, "LEFT", -2, 0)
		else
			frame[id]:SetPoint("RIGHT", frame, "RIGHT")
		end
	end
end

local blankSpaceFunc = barPosition('blankSpace')
function MetaLayout.positions.blankSpace(unit, frame)
	return blankSpaceFunc(unit, frame)
end
MetaLayout.positions.fullBar = barPosition('fullBar')
MetaLayout.positions.healthBar = barPosition('healthBar')
MetaLayout.positions.powerBar = barPosition('powerBar')
MetaLayout.positions.threatBar = barPosition('threatBar')
if playerClass == "DRUID" then
	function MetaLayout.positions.druidManaBar(unit, frame)
		if not frame.powerBar then
			return
		end
		local height = figureHeight('powerBar', frame) * MetaLayout_db.profile[frame.group].druidManaBarHeight
		frame.druidManaBar:SetPoint("TOPLEFT", frame.powerBar, "BOTTOMLEFT")
		frame.druidManaBar:SetPoint("TOPRIGHT", frame.powerBar, "TOPRIGHT")
		frame.druidManaBar:SetHeight(height-1)
	end
end
MetaLayout.positions.repBar = barPosition('repBar')
MetaLayout.positions.expBar = barPosition('expBar')

local castBarFunc_normal = barPosition('castBar')
function MetaLayout.positions.castBar(unit, frame)
	castBarFunc_normal(unit, frame)
	local height = frame.castBar:GetHeight()
	frame.castBar.bg:ClearAllPoints()
	frame.castBar.bg:SetHeight(height)
	for i = 1, frame.castBar:GetNumPoints() do
		frame.castBar.bg:SetPoint(frame.castBar:GetPoint(i))
		if frame.castBarIcon then
			local point, attach, relpoint, x, y = frame.castBar:GetPoint(i)
			if point == "LEFT" then
				frame.castBar:SetPoint(point, attach, relpoint, x + height, y)
			end
		end
	end
end
function MetaLayout.positions.castBarIcon(unit, frame)
	local height = figureHeight('castBar', frame)
	frame.castBarIcon:SetHeight( height -1)
	frame.castBarIcon:SetWidth( height -1)
	frame.castBarIcon:SetPoint("RIGHT", frame.castBar, "LEFT" )
	frame.castBarIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end
function MetaLayout.positions.castBarText(unit, frame)
	frame.castBarText:ClearAllPoints()
	frame.castBarText:SetAllPoints(frame.castBar)
	frame.castBarText:SetJustifyH("LEFT")
end
function MetaLayout.positions.castBarTimeText(unit, frame)
	frame.castBarTimeText:ClearAllPoints()
	frame.castBarTimeText:SetAllPoints(frame.castBar)
	frame.castBarTimeText:SetJustifyH("RIGHT")
end

local portraitFunc_normal = barPosition('portrait')
function MetaLayout.positions.portrait(unit, frame)
	local portraitSide = MetaLayout_db.profile[frame.group].bars.portrait.side
	local leftOrRight = portraitSide == "left" or portraitSide == "right"
	if not leftOrRight then
		return portraitFunc_normal(unit, frame)
	end
	
	if portraitSide == "left" then
		frame.portrait:SetPoint("LEFT", frame, "LEFT")
	else -- right
		frame.portrait:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	end
	
	local height = frame:GetHeight()
	
	frame.portrait:SetWidth(height)
	frame.portrait:SetHeight(height)
end
if playerClass == "ROGUE" or playerClass == "DRUID" then
	function MetaLayout.positions.comboPoints(unit, frame)
		if frame.group ~= "target" then return end 
		local side = MetaLayout_db.profile[frame.group].comboSide
		
		local side_in = side:match("^(in)")
		local side_rest = side_in and side:sub(3) or side:sub(4)
		local side_main = side_rest:match("^(left)") or side_rest:match("^(right)") or side_rest:match("^(top)") or side_rest:match("^(bottom)")
		if not side_main then -- messed up
			return
		end
		local side_alt = side_rest:sub(side_main:len() + 1)
		
		if side_rest == "right" then
			frame.comboPoints:SetPoint(side_in and "RIGHT" or "LEFT", frame, "RIGHT")
		elseif side_rest == "left" then
			frame.comboPoints:SetPoint(side_in and "LEFT" or "RIGHT", frame, "LEFT")
		elseif side_rest == "top" then
			frame.comboPoints:SetPoint(side_in and "TOP" or "BOTTOM", frame, "TOP")
		elseif side_rest == "bottom" then
			frame.comboPoints:SetPoint(side_in and "BOTTOM" or "TOP", frame, "BOTTOM")
		elseif side_rest == "topright" or side_rest == "righttop" then
			frame.comboPoints:SetPoint(side_in and "TOPRIGHT" or side_rest == "topright" and "BOTTOMRIGHT" or "TOPLEFT", frame, "TOPRIGHT")
		elseif side_rest == "topleft" or side_rest == "lefttop" then
			frame.comboPoints:SetPoint(side_in and "TOPLEFT" or side_rest == "topleft" and "BOTTOMLEFT" or "TOPRIGHT", frame, "TOPLEFT")
		elseif side_rest == "bottomright" or side_rest == "rightbottom" then
			frame.comboPoints:SetPoint(side_in and "BOTTOMRIGHT" or side_rest == "bottomright" and "TOPRIGHT" or "BOTTOMLEFT", frame, "BOTTOMRIGHT")
		elseif side_rest == "bottomleft" or side_rest == "leftbottom" then
			frame.comboPoints:SetPoint(side_in and "BOTTOMLEFT" or side_rest == "bottomleft" and "TOPLEFT" or "BOTTOMRIGHT", frame, "BOTTOMLEFT")
		end
		
		local leftOrRight = side_main == "left" or side_main == "right"
		
		frame.comboPoints:SetWidth(leftOrRight and 10 or 50)
		frame.comboPoints:SetHeight(leftOrRight and 50 or 10)
		
		for i = 1, 5 do
			local combo = frame.comboPoints["combo"..i]
			combo:ClearAllPoints()
			if leftOrRight then
				if side_alt == "top" then
					if i == 1 then
						combo:SetPoint("TOP", frame.comboPoints, "TOP")
					else
						combo:SetPoint("TOP", frame.comboPoints["combo"..(i-1)], "BOTTOM", 0, -2)
					end
				else
					if i == 1 then
						combo:SetPoint("BOTTOM", frame.comboPoints, "BOTTOM")
					else
						combo:SetPoint("BOTTOM", frame.comboPoints["combo"..(i-1)], "TOP", 0, 2)
					end
				end
			else -- top or bottom
				if side_alt == "right" then
					if i == 1 then
						combo:SetPoint("RIGHT", frame.comboPoints, "RIGHT")
					else
						combo:SetPoint("RIGHT", frame.comboPoints["combo"..(i-1)], "LEFT", -2, 0)
					end
				else
					if i == 1 then
						combo:SetPoint("LEFT", frame.comboPoints, "LEFT")
					else
						combo:SetPoint("LEFT", frame.comboPoints["combo"..(i-1)], "RIGHT", 2, 0)
					end
				end
			end
		end
	end
end

function MetaLayout.positions.auraFrame(unit, frame)
	frame.auraFrame:ClearAllPoints()
	local size = PitBull:GetModule("Aura").db.profile[frame.group].buffsize
	frame.auraFrame:SetHeight(size)
	if PitBull:GetModule("Aura").db.profile[frame.group].split then
		local buffside = MetaLayout_db.profile[frame.group].buffSide
		local w = frame:GetWidth()
		frame.auraFrame:SetWidth(w)
		if buffside == "bottom" then
			frame.auraFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -2, -2)
		elseif buffside == "top" then
			frame.auraFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -2, 2)
		elseif buffside == "left" then
			frame.auraFrame:SetPoint("BOTTOMRIGHT", frame, "LEFT", w-size-2, -2)
		elseif buffside == "right" then
			frame.auraFrame:SetPoint("BOTTOMLEFT", frame, "RIGHT", 2, 0)
		elseif buffside == "topleft" then
			frame.auraFrame:SetPoint("TOPRIGHT", frame, "TOPLEFT", w-size-2, 0)
		elseif buffside == "topright" then
			frame.auraFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 2, 0)
		elseif buffside == "bottomleft" then
			frame.auraFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", w-size-2, 0)
		elseif buffside == "bottomright" then
			frame.auraFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 2, 0)
		end
	else
		local side = MetaLayout_db.profile[frame.group].auraSide
		if side == "bottom" then
			frame.auraFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -2, -2)
			frame.auraFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 2, -2)
		elseif side == "top" then
			local split = PitBull:GetModule("Aura").db.profile[frame.group].split
			frame.auraFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -2, split and 18 or 2)
			frame.auraFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 2, split and 18 or 2)
		elseif side == "left" then
			frame.auraFrame:SetWidth(160)
			frame.auraFrame:SetPoint("BOTTOMRIGHT", frame, "LEFT", -2, 0)
		elseif side == "topright" then
			frame.auraFrame:SetWidth(160)
			frame.auraFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 2, 0)
		elseif side == "bottomright" then
			frame.auraFrame:SetWidth(160)
			frame.auraFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 2, 0)
		elseif side == "bottomleft" then
			frame.auraFrame:SetWidth(160)
			frame.auraFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -2, 0)
		elseif side == "topleft" then
			frame.auraFrame:SetWidth(160)
			frame.auraFrame:SetPoint("TOPRIGHT", frame, "TOPLEFT", -2, 0)
		elseif side == "right" then
			frame.auraFrame:SetWidth(160)
			frame.auraFrame:SetPoint("BOTTOMLEFT", frame, "RIGHT", 2, 0)
		end
	end
end
function MetaLayout.positions.auraFrame2(unit, frame)
	frame.auraFrame2:ClearAllPoints()
	local size = PitBull:GetModule("Aura").db.profile[frame.group].debuffsize
	local w = frame:GetWidth()
	frame.auraFrame2:SetHeight(size)
	frame.auraFrame2:SetWidth(w)
	local debuffside = MetaLayout_db.profile[frame.group].debuffSide
	if debuffside == "bottom" then
		frame.auraFrame2:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -2, -2)
	elseif debuffside == "top" then
		frame.auraFrame2:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -2, 2)
	elseif debuffside == "left" then
		frame.auraFrame2:SetPoint("BOTTOMRIGHT", frame, "LEFT", w-size-2, -2)
	elseif debuffside == "right" then
		frame.auraFrame2:SetPoint("BOTTOMLEFT", frame, "RIGHT", 2, 0)
	elseif debuffside == "topleft" then
		frame.auraFrame2:SetPoint("TOPRIGHT", frame, "TOPLEFT", w-size-2, 0)
	elseif debuffside == "topright" then
		frame.auraFrame2:SetPoint("TOPLEFT", frame, "TOPRIGHT", 2, 0)
	elseif debuffside == "bottomleft" then
		frame.auraFrame2:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", w-size-2, 0)
	elseif debuffside == "bottomright" then
		frame.auraFrame2:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 2, 0)
	end
end

local function findTextAtPosition(group, position, frame)
	for k, v in pairs(MetaLayout_db.profile[group].texts) do
		if v.position == position then
			local id = "layoutText" .. k
			if not frame or frame[id] then
				return id
			end
			if frame[k] then
				return k
			end
			return nil
		end
	end
end

local function findIconsAtPosition(group, position, frame)
	local t = newList()
	for k, v in pairs(MetaLayout_db.profile[group].icons) do
		if v.position == position and frame[k] then
			t[#t+1] = k
		end
	end
	table.sort(t, iconPriority_sort)
	return t
end

local function findIconAtPositionBeforeIcon(group, position, frame, icon)
	local t = findIconsAtPosition(group, position, frame)
	for i,v in ipairs(t) do
		if v == icon then
			local preicon = t[i-1]
			t = del(t)
			return preicon
		end
	end
	t = del(t)
	return nil
end

local function findLastIconAtPosition(group, position, frame)
	local t = findIconsAtPosition(group, position, frame)
	for i = #t, 1, -1 do
		local icon = t[i]
		t = del(t)
		return icon
	end
	t = del(t)
	return nil
end

local function findFirstIconAtPosition(group, position, frame)
	local t = findIconsAtPosition(group, position, frame)
	for i = 1, #t do
		local icon = t[i]
		t = del(t)
		return icon
	end
	t = del(t)
	return nil
end

local function findTextOrIconAtPosition(group, position, frame, direction)
	local attach, point = ("-"):split(position)
	local approach
	if attach == "frame" then
		if point == "outtopleft" or point == "outtop" or point == "outbottomleft" or point == "outbottom" or point == "outrighttop" or point == "outright" or point == "outrightbottom" or point == "center" or point == "intopleft" or point == "intop" or point == "inbottomleft" or point == "inbottom" or point == "inleft" or point == "edgetopleft" or point == "edgetop" or point == "edgeleft" or point == "edgebottomleft" or point == "edgebottom" then
			approach = direction == "left" and "left-first" or "right-last"
		else
			approach = direction == "left" and "left-last" or "right-first"
		end
	else
		if point == "left" or point == "center" or point == "outright" then
			approach = direction == "left" and "left-first" or "right-last"
		else
			approach = direction == "left" and "left-last" or "right-first"
		end
	end
	if approach == "left-first" then
		return findFirstIconAtPosition(group, position, frame) or findTextAtPosition(group, position, frame)
	elseif approach == "left-last" then
		return findLastIconAtPosition(group, position, frame) or findTextAtPosition(group, position, frame)
	elseif approach == "right-first" then
		return findTextAtPosition(group, position, frame) or findFirstIconAtPosition(group, position, frame)
	else--if approach == "right-last" then
		return findTextAtPosition(group, position, frame) or findLastIconAtPosition(group, position, frame)
	end
end

local function textPosition(id, name)
	return function(unit, frame)
		local group = frame.group
		local position = MetaLayout_db.profile[group].texts[name].position or "hide"
		local attach, point = ("-"):split(position)
		if attach == "hide" then
			return
		end
		if attach and point then
			if attach == "frame" then
				if point == "outtopleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMLEFT", frame[icon], "BOTTOMRIGHT", 3, 0)
					else
						frame[id]:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 2, 5)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("BOTTOM")
					local center = findTextOrIconAtPosition(group, "frame-outtop", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, "frame-outtopright", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "outtopright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMRIGHT", frame[icon], "BOTTOMLEFT", -3, 0)
					else
						frame[id]:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -2, 5)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("BOTTOM")
					local center = findTextOrIconAtPosition(group, "frame-outtop", frame, "right")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "outtop" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMLEFT", frame[icon], "BOTTOMRIGHT", 3, 0)
					else
						frame[id]:SetPoint("BOTTOM", frame, "TOP", 0, 5)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("BOTTOM")
				elseif point == "outbottomleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPLEFT", frame[icon], "TOPRIGHT", 3, 0)
					else
						frame[id]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, -5)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("TOP")
					local center = findTextOrIconAtPosition(group, "frame-outbottom", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, "frame-outbottomright", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "outbottomright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPRIGHT", frame[icon], "TOPLEFT", -3, 0)
					else
						frame[id]:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -2, -5)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("TOP")
					local center = findTextOrIconAtPosition(group, "frame-outbottom", frame, "right")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "outbottom" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPLEFT", frame[icon], "TOPRIGHT", 3, 0)
					else
						frame[id]:SetPoint("TOP", frame, "BOTTOM", 0, -5)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("TOP")
				elseif point == "outlefttop" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPRIGHT", frame[icon], "TOPLEFT", -3, 0)
					else
						frame[id]:SetPoint("TOPRIGHT", frame, "TOPLEFT", -5, -2)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("TOP")
				elseif point == "outleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("RIGHT", frame, "LEFT", -5, 0)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "outleftbottom" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMRIGHT", frame[icon], "BOTTOMLEFT", -3, 0)
					else
						frame[id]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -5, -2)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("BOTTOM")
				elseif point == "outrighttop" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPLEFT", frame[icon], "TOPRIGHT", 3, 0)
					else
						frame[id]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 5, -2)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("TOP")
				elseif point == "outright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("LEFT", frame, "RIGHT", 5, 0)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "outrightbottom" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMLEFT", frame[icon], "BOTTOMRIGHT", 3, 0)
					else
						frame[id]:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 5, 2)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("BOTTOM")
				elseif point == "intopleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPLEFT", frame[icon], "TOPRIGHT", 3, 0)
					else
						frame[id]:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -5)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("TOP")
					local center = findTextOrIconAtPosition(group, "frame-intop", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, "frame-intopright", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "intopright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPRIGHT", frame[icon], "TOPLEFT", -3, 0)
					else
						frame[id]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -5)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("TOP")
					local center = findTextOrIconAtPosition(group, "frame-intop", frame, "right")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "intop" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("TOPLEFT", frame[icon], "TOPRIGHT", 3, 0)
					else
						frame[id]:SetPoint("TOP", frame, "TOP", 2, -5)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("TOP")
				elseif point == "inbottomleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMLEFT", frame[icon], "BOTTOMRIGHT", 3, 0)
					else
						frame[id]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, 5)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("BOTTOM")
					local center = findTextOrIconAtPosition(group, "frame-inbottom", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, "frame-inbottomright", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "inbottomright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMRIGHT", frame[icon], "BOTTOMLEFT", -3, 0)
					else
						frame[id]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 5)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("BOTTOM")
					local center = findTextOrIconAtPosition(group, "frame-inbottom", frame, "right")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "inbottom" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("BOTTOMLEFT", frame[icon], "BOTTOMRIGHT", 3, 0)
					else
						frame[id]:SetPoint("BOTTOM", frame, "BOTTOM", 2, 5)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("BOTTOM")
				elseif point == "inleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("LEFT", frame, "LEFT", 5, 0)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("MIDDLE")
					local center = findTextOrIconAtPosition(group, "frame-center", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, "frame-inright", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "inright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("MIDDLE")
					local center = findTextOrIconAtPosition(group, "frame-center", frame, "right")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "center" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("CENTER", frame, "CENTER", 0, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgetopleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("LEFT", frame, "TOPLEFT", -5, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgetopright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("RIGHT", frame, "TOPRIGHT", 5, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgetop" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("CENTER", frame, "TOP", 0, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgebottomleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("LEFT", frame, "BOTTOMLEFT", -5, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgebottomright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("RIGHT", frame, "BOTTOMRIGHT", 5, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgebottom" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("CENTER", frame, "BOTTOM", 0, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgeleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("LEFT", frame, "LEFT", -5, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "edgeright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("RIGHT", frame, "RIGHT", 5, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				end
			elseif frame[attach] then
				if point == "left" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("LEFT", frame[attach], "LEFT", 3, 0)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("MIDDLE")
					local center = findTextOrIconAtPosition(group, attach .. "-center", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, attach .. "-right", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "center" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("CENTER", frame[attach], "CENTER", 0, 0)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "right" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("RIGHT", frame[attach], "RIGHT", -3, 0)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("MIDDLE")
					local center = findTextOrIconAtPosition(group, attach .. "-center", frame, "left")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "topleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("TOPLEFT", frame[attach], "TOPLEFT", 3, -3)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("TOP")
					local center = findTextOrIconAtPosition(group, attach .. "-top", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, attach .. "-topright", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "topright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("TOPRIGHT", frame[attach], "TOPRIGHT", -3, -3)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("TOP")
					local center = findTextOrIconAtPosition(group, attach .. "-top", frame, "left")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "top" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("TOP", frame[attach], "TOP", 0, -3)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("TOP")
				elseif point == "bottomleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("BOTTOMLEFT", frame[attach], "BOTTOMLEFT", 3, 3)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("BOTTOM")
					local center = findTextOrIconAtPosition(group, attach .. "-bottom", frame, "left")
					if center then
						frame[id]:SetPoint("RIGHT", frame[center], "LEFT", -3, 0)
					else
						local right = findTextOrIconAtPosition(group, attach .. "-bottomright", frame, "left")
						if right then
							frame[id]:SetPoint("RIGHT", frame[right], "LEFT", -3, 0)
						end
					end
				elseif point == "bottomright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("BOTTOMRIGHT", frame[attach], "BOTTOMRIGHT", 3, 3)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("BOTTOM")
					local center = findTextOrIconAtPosition(group, attach .. "-top", frame, "left")
					if center then
						frame[id]:SetPoint("LEFT", frame[center], "RIGHT", 3, 0)
					end
				elseif point == "bottom" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("BOTTOM", frame[attach], "BOTTOM", 0, 3)
					end
					frame[id]:SetJustifyH("CENTER")
					frame[id]:SetJustifyV("BOTTOM")
				elseif point == "outright" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
					else
						frame[id]:SetPoint("LEFT", frame[attach], "RIGHT", 3, 0)
					end
					frame[id]:SetJustifyH("LEFT")
					frame[id]:SetJustifyV("MIDDLE")
				elseif point == "outleft" then
					local icon = findLastIconAtPosition(group, position, frame)
					if icon then
						frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
					else
						frame[id]:SetPoint("RIGHT", frame[attach], "LEFT", -3, 0)
					end
					frame[id]:SetJustifyH("RIGHT")
					frame[id]:SetJustifyV("MIDDLE")
				end
			end
		end
	end
end

local function getHalfWidth(group, position, frame)
	local num = 0
	if findTextAtPosition(group, position, frame) then
		num = num + 20 -- assumes a width of 40
	end
	local icons = findIconsAtPosition(group, position, frame)
	local iconDB = MetaLayout_db.profile[group].icons
	for _,v in ipairs(icons) do
		num = num + 7.5 * iconDB[v].size
	end
	icons = del(icons)
	return -num
end

local function iconPosition(id)
	return function(unit, frame)
		local group = frame.group
		local position = MetaLayout_db.profile[group].icons[id].position
		if position == "hide" then
			return
		end
		local size = MetaLayout_db.profile[group].icons[id].size * 15
		frame[id]:SetWidth(size)
		frame[id]:SetHeight(size)
		local attach, point = ("-"):split(position)
		if attach and point then
			local icon = findIconAtPositionBeforeIcon(group, position, frame, id)
			if icon then
				local left = false
				if attach == "frame" then
					if point == "outtopleft" or point == "outtop" or point == "outbottomleft" or point == "outbottom" or point == "outrighttop" or point == "outright" or point == "outrightbottom" or point == "center" or point == "intopleft" or point == "intop" or point == "inbottomleft" or point == "inbottom" or point == "inleft" or point == "edgetopleft" or point == "edgetop" or point == "edgeleft" or point == "edgebottomleft" or point == "edgebottom" then
						left = true
					end
				else
					if point == "left" or point == "center" or point == "outright" or point == "topleft" or point == "top" or point == "bottomleft" or point == "bottom" then
						left = true
					end
				end
				if left then
					frame[id]:SetPoint("LEFT", frame[icon], "RIGHT", 3, 0)
				else
					frame[id]:SetPoint("RIGHT", frame[icon], "LEFT", -3, 0)
				end
			else
				if attach == "frame" then
					if point == "outtopleft" then
						frame[id]:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 2, 5)
					elseif point == "outtopright" then
						frame[id]:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -2, 5)
					elseif point == "outtop" then
						frame[id]:SetPoint("BOTTOMLEFT", frame, "TOP", getHalfWidth(group, position, frame), 5)
					elseif point == "outbottomleft" then
						frame[id]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, -5)
					elseif point == "outbottomright" then
						frame[id]:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -2, -5)
					elseif point == "outbottom" then
						frame[id]:SetPoint("TOPLEFT", frame, "BOTTOM", getHalfWidth(group, position, frame), -5)
					elseif point == "outlefttop" then
						frame[id]:SetPoint("TOPRIGHT", frame, "TOPLEFT", -5, -2)
					elseif point == "outleft" then
						frame[id]:SetPoint("RIGHT", frame, "LEFT", -5, 0)
					elseif point == "outleftbottom" then
						frame[id]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -5, 2)
					elseif point == "outrighttop" then
						frame[id]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 5, -2)
					elseif point == "outright" then
						frame[id]:SetPoint("LEFT", frame, "RIGHT", 5, 0)
					elseif point == "outrightbottom" then
						frame[id]:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 5, 2)
					elseif point == "center" then
						frame[id]:SetPoint("LEFT", frame, "CENTER", getHalfWidth(group, position, frame), 0)
					elseif point == "intopleft" then
						frame[id]:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -5)
					elseif point == "intop" then
						frame[id]:SetPoint("TOPLEFT", frame, "TOP", getHalfWidth(group, position, frame), -5)
					elseif point == "intopright" then
						frame[id]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -5)
					elseif point == "inbottomleft" then
						frame[id]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, 5)
					elseif point == "inbottom" then
						frame[id]:SetPoint("BOTTOMLEFT", frame, "BOTTOM", getHalfWidth(group, position, frame), 5)
					elseif point == "inbottomright" then
						frame[id]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 5)
					elseif point == "inleft" then
						frame[id]:SetPoint("LEFT", frame, "LEFT", 2, 0)
					elseif point == "inright" then
						frame[id]:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
					elseif point == "edgetopleft" then
						frame[id]:SetPoint("CENTER", frame, "TOPLEFT", 0, 0)
					elseif point == "edgetop" then
						frame[id]:SetPoint("LEFT", frame, "TOP", getHalfWidth(group, position, frame), 0)
					elseif point == "edgetopright" then
						frame[id]:SetPoint("CENTER", frame, "TOPRIGHT", 0, 0)
					elseif point == "edgeleft" then
						frame[id]:SetPoint("CENTER", frame, "LEFT", 0, 0)
					elseif point == "edgeright" then
						frame[id]:SetPoint("CENTER", frame, "RIGHT", 0, 0)
					elseif point == "edgebottomleft" then
						frame[id]:SetPoint("CENTER", frame, "BOTTOMLEFT", 0, 0)
					elseif point == "edgebottom" then
						frame[id]:SetPoint("LEFT", frame, "BOTTOM", getHalfWidth(group, position, frame), 0)
					elseif point == "edgebottomright" then
						frame[id]:SetPoint("CENTER", frame, "BOTTOMRIGHT", 0, 0)
					end
				elseif frame[attach] then
					if point == "left" then
						frame[id]:SetPoint("LEFT", frame[attach], "LEFT", 3, 0)
					elseif point == "center" then
						frame[id]:SetPoint("LEFT", frame[attach], "CENTER", getHalfWidth(group, position, frame), 0)
					elseif point == "right" then
						frame[id]:SetPoint("RIGHT", frame[attach], "RIGHT", -3, 0)
					elseif point == "top" then
						frame[id]:SetPoint("TOPLEFT", frame[attach], "TOP", getHalfWidth(group, position, frame), -3)
					elseif point == "bottom" then
						frame[id]:SetPoint("BOTTOMLEFT", frame[attach], "BOTTOM", getHalfWidth(group, position, frame), 3)
					elseif point == "topleft" then
						frame[id]:SetPoint("TOPLEFT", frame[attach], "TOPLEFT", 3, -3)
					elseif point == "topright" then
						frame[id]:SetPoint("TOPRIGHT", frame[attach], "TOPRIGHT", -3, -3)
					elseif point == "bottomleft" then
						frame[id]:SetPoint("BOTTOMLEFT", frame[attach], "BOTTOMLEFT", 3, 3)
					elseif point == "bottomright" then
						frame[id]:SetPoint("BOTTOMRIGHT", frame[attach], "BOTTOMRIGHT", -3, 3)
					elseif point == "outright" then
						frame[id]:SetPoint("LEFT", frame[attach], "RIGHT", 3, 0)
					elseif point == "outleft" then
						frame[id]:SetPoint("RIGHT", frame[attach], "LEFT", -3, 0)
					end
				end
			end
		end
	end
end

local getIconSize = setmetatable({}, {__index=function(self, name)
	self[name] = function(group)
		return MetaLayout_db.profile[group].icons[name].size
	end
	return self[name]
end})
local setIconSize = setmetatable({}, {__index=function(self, name)
	self[name] = function(group, value)
		MetaLayout_db.profile[group].icons[name].size = value

		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end
	return self[name]
end})

local getPositionArgs
local function iconOptions(name)
	return function(group)
		return {
			type = 'group',
			groupType = 'inline',
			name = L["Position"],
			desc = L["Position of the text."],
			args = getPositionArgs(group, name, true),
		}, {
			type = 'number',
			name = L["Size"],
			desc = L["Size of the icon."],
			get = getIconSize[name],
			set = setIconSize[name],
			passValue = group,
			min = 0.5,
			max = 4,
			step = 0.01,
			bigStep = 0.05,
			isPercent = true,
		}
	end
end

local function createIconHandler(id)
	MetaLayout.positions[id] = iconPosition(id)
	MetaLayout.options[id] = iconOptions(id)
end

createIconHandler('pvpIcon')
createIconHandler('combatIcon')
createIconHandler('voiceIcon')
createIconHandler('restIcon')
createIconHandler('leaderIcon')
createIconHandler('masterIcon')
createIconHandler('raidTargetIcon')

local barNameToLocal = {
	portrait = L["Portrait"],
	fullBar = L["Full bar"],
	healthBar = L["Health bar"],
	powerBar = L["Power bar"],
	repBar = L["Reputation bar"],
	expBar = L["Experience bar"],
	threatBar = L["Threat bar"],
	castBar = L["Cast bar"],
	blankSpace = L["Blank space"],
}

local barPositionValidate = {}
local function getBarPositionValidate(group, forceUpdate)
	if barPositionValidate[group] then
		if not forceUpdate then
			return barPositionValidate[group]
		end
		for k in pairs(barPositionValidate[group]) do
			barPositionValidate[group][k] = nil
		end
	else
		barPositionValidate[group] = {}
	end
	
	for k,v in pairs(MetaLayout_db.profile[group].bars) do
		barPositionValidate[group][v.position] = k
	end	
	
	local i = 1
	while i <= #barPositionValidate[group] do
		local v = barPositionValidate[group][i]
		local good = false
		if v ~= "portrait" or (MetaLayout_db.profile[group].bars.portrait.side ~= "left" and MetaLayout_db.profile[group].bars.portrait.side ~= "right") then
			for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
				if frame[v] then
					good = true
					break
				end
			end
		end
		if not good then
			table.remove(barPositionValidate[group], i)
			i = i - 1
		else
			barPositionValidate[group][i] = barNameToLocal[v]
		end
		i = i + 1
	end
	
	return barPositionValidate[group]
end

local function createBarOptions_position(id, group, disableFunc)
	local function position_get(group)
		getBarPositionValidate(group, true)
		return barNameToLocal[id]
	end
	local function position_set(group, value)
		local barName
		for k,v in pairs(barNameToLocal) do
			if value == v then
				barName = k
				break
			end
		end
		assert(barName)
		local barDB = MetaLayout_db.profile[group].bars
		local new_position = barDB[barName].position
		local old_position = barDB[id].position
		local step = 1
		if new_position < old_position then
			step = -1
		end
		for k, v in pairs(barDB) do
			local v_position = v.position
			if (new_position <= v_position and v_position < old_position) or (old_position < v_position and v_position <= new_position) then
				barDB[k].position = v_position - step
			end
		end
		barDB[id].position = new_position
		getBarPositionValidate(group, true)
		
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end
	return {
		name = L["Position"],
		desc = L["Position of the bar relative to other bars."],
		type = 'choice',
		choices = getBarPositionValidate(group),
		passValue = group,
		get = position_get,
		set = position_set,
		disabled = disableFunc,
	}
end

local function barOptions(id)
	local function height_get(group)
		return MetaLayout_db.profile[group].bars[id].height
	end
	local function height_set(group, value)
		MetaLayout_db.profile[group].bars[id].height = value
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end
	return function(group, disableFunc)
		return {
			name = L["Height"],
			desc = L["Relative height of the bar."],
			type = 'number',
			passValue = group,
			get = height_get,
			set = height_set,
			min = 1,
			max = 12,
			step = 1,
			disabled = disableFunc,
		}, createBarOptions_position(id, group, disableFunc)
	end
end

MetaLayout.options.fullBar = barOptions('fullBar')
MetaLayout.options.healthBar = barOptions('healthBar')
MetaLayout.options.powerBar = barOptions('powerBar')
MetaLayout.options.threatBar = barOptions('threatBar')
MetaLayout.options.castBar = barOptions('castBar')
MetaLayout.options.expBar = barOptions('expBar')
MetaLayout.options.repBar = barOptions('repBar')

if playerClass == "DRUID" then
	local function druidManaBarHeight_get(group)
		return MetaLayout_db.profile[group].druidManaBarHeight
	end
	local function druidManaBarHeight_set(group, value)
		MetaLayout_db.profile[group].druidManaBarHeight = value
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end
	function MetaLayout.options.druidManaBar(group)
		if group == "player" then
			return {
				name = L["Height percentage"],
				desc = L["Percentage of height that the druid mana bar will take up of the normal power bar's height."],
				type = 'number',
				passValue = group,
				get = druidManaBarHeight_get,
				set = druidManaBarHeight_set,
				min = 0.05,
				max = 0.95,
				step = 0.01,
				bigStep = 0.05,
				isPercent = true,
			}
		end
	end
end

local function portraitSide_get(group)
	return MetaLayout_db.profile[group].bars.portrait.side
end
local function portraitSide_set(group, value)
	MetaLayout_db.profile[group].bars.portrait.side = value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end
end
local function portraitSide_isLeftOrRight(group)
	local portraitSide = MetaLayout_db.profile[group].bars.portrait.side
	return portraitSide == "left" or portraitSide == "right"
end
local function portraitHeight_get(group)
	return MetaLayout_db.profile[group].bars.portrait.height
end
local function portraitHeight_set(group, value)
	MetaLayout_db.profile[group].bars.portrait.height = value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end
end
function MetaLayout.options.portrait(group)
	local t = createBarOptions_position('portrait', group)
	t.disabled = portraitSide_isLeftOrRight
	return {
		name = L["Side"],
		desc = L["What side of the unit frame to position the portrait at."],
		type = 'choice',
		choices = {
			left = L["Left"],
			right = L["Right"],
			top = L["Center"],
		},
		get = portraitSide_get,
		set = portraitSide_set,
		passValue = group
	}, 	{
		name = L["Height"],
		desc = L["Relative height of the portrait."],
		type = 'number',
		passValue = group,
		get = portraitHeight_get,
		set = portraitHeight_set,
		min = 1,
		max = 12,
		step = 1,
		disabled = portraitSide_isLeftOrRight,
	}, t
end

local function auraSide_get(group)
	return MetaLayout_db.profile[group].auraSide
end
local function auraSide_set(group, value)
	MetaLayout_db.profile[group].auraSide = value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end
end

local function buffSide_get(group)
	return MetaLayout_db.profile[group].buffSide
end
local function buffSide_set(group, value)
	MetaLayout_db.profile[group].buffSide = value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end
end

local function debuffSide_get(group)
	return MetaLayout_db.profile[group].debuffSide
end
local function debuffSide_set(group, value)
	MetaLayout_db.profile[group].debuffSide = value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end
end

local function splitOptions_isHidden(group)
	local aura = PitBull:HasModule("Aura") and PitBull:GetModule("Aura")
	if not aura or not aura.db or not aura.db.profile or not aura.db.profile[group] then
		return true
	end
	return not aura.db.profile[group].split
end

local function nonsplitOptions_isHidden(group)
	local aura = PitBull:HasModule("Aura") and PitBull:GetModule("Aura")
	if not aura or not aura.db or not aura.db.profile or not aura.db.profile[group] then
		return true
	end
	return aura.db.profile[group].split
end

function MetaLayout.options.auraFrame(group)
	return {
		name = L["Side"],
		desc = L["Which side to position all aura icons at."],
		type = 'choice',
		choices = {
			left = "Left",
			topleft = "Top-left",
			bottomleft = "Bottom-left",
			right = "Right",
			topright = "Top-right",
			bottomright = "Bottom-right",
			top = "Top",
			bottom = "Bottom",
		},
		get = auraSide_get,
		set = auraSide_set,
		passValue = group,
		hidden = function(group)
			for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
				if frame.auraFrame2 then
					return true
				end
			end	
			return false
		end,
		disabled = function(group)
			for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
				if frame.auraFrame then
					return false
				end
			end	
			return true
		end,
	}, {
		name = L["Side"],
		desc = L["Options to change the side which the auras are on."],
		type = 'group',
		hidden = function()
			for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
				if frame.auraFrame2 then
					return false
				end
			end
			return true
		end,
		passValue = group,
		args = {
			buffside = {
				name = L["Buff side"],
				desc = L["Which side to position buff icons at."],
				type = 'choice',
				choices = {
					left = "Left",
					topleft = "Top-left",
					bottomleft = "Bottom-left",
					right = "Right",
					topright = "Top-right",
					bottomright = "Bottom-right",
					top = "Top",
					bottom = "Bottom",
				},
				get = buffSide_get,
				set = buffSide_set,
				passValue = group,
				disabled = splitOptions_isHidden,
			},
			debuffside = {
				name = L["Debuff side"],
				desc = L["Which side to position debuff icons at."],
				type = 'choice',
				choices = {
					left = "Left",
					topleft = "Top-left",
					bottomleft = "Bottom-left",
					right = "Right",
					topright = "Top-right",
					bottomright = "Bottom-right",
					top = "Top",
					bottom = "Bottom",
				},
				get = debuffSide_get,
				set = debuffSide_set,
				passValue = group,
				disabled = splitOptions_isHidden,
			},
		}
	}
end

if playerClass == "ROGUE" or playerClass == "DRUID" then
	local function comboSide_get(group)
		return MetaLayout_db.profile[group].comboSide
	end
	local function comboSide_set(group, value)
		MetaLayout_db.profile[group].comboSide = value
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end

	MetaLayout.options.name.comboPoints = L["Combo points"]
	MetaLayout.options.desc.comboPoints = L["Options for the combo point display."]
	function MetaLayout.options.comboPoints(group)
		if group == "target" then
			return {
				name = L["Position"],
				desc = L["What position of the unit frame to position the combo point display at."],
				type = 'choice',
				choices = {
					outleft = "Outside, Left",
					outlefttop = "Outside, Left-top",
					outleftbottom = "Outside, Left-bottom",
					outright = "Outside, Right",
					outrighttop = "Outside, Right-top",
					outrightbottom = "Outside, Right-bottom",
					outtop = "Outside, Above",
					outtopleft = "Outside, Above-left",
					outtopright = "Outside, Above-right",
					outbottom = "Outside, Below",
					outbottomleft = "Outside, Below-left",
					outbottomright = "Outside, Below-right",
					
					inleft = "Inside, Left",
					inlefttop = "Inside, Left-top",
					inleftbottom = "Inside, Left-bottom",
					inright = "Inside, Right",
					inrighttop = "Inside, Right-top",
					inrightbottom = "Inside, Right-bottom",
					intop = "Inside, Top",
					intopleft = "Inside, Top-left",
					intopright = "Inside, Top-right",
					inbottom = "Inside, Bottom",
					inbottomleft = "Inside, Bottom-left",
					inbottomright = "Inside, Bottom-right",
				},
				get = comboSide_get,
				set = comboSide_set,
				passValue = group,
			}
		end
	end
end

local textStyles = {
	class = {
		["Standard"]            = "[Classification] [Level:DifficultyColor] [SmartClass:ClassColor] [DruidForm:Paren] [SmartRace]",
		["Player Classes Only"] = "[Classification] [Level:DifficultyColor] [PlayerClass:ClassColor] [DruidForm:Paren] [SmartRace]",
		["Short"]               = "[DifficultyColor][Level][Plus][White] [SmartRace]",
	},
	health = {
		["Absolute"]       = "[Status:SureHP:PercentHP:Percent]",
		["Absolute Short"] = "[Status:SureHP:Short:PercentHP:Percent]",
		["Difference"]     = "[Status:SmartMissingHP]",
		["Percent"]        = "[Status:PercentHP:Percent]",
		["Mini"]           = "[CurHP:VeryShort]",
		["Smart"]          = "[IsFriend?Status:MissingHP:HideZero:Short:Color(ff7f7f)!Status:SmartHP:Short]",
		["Absolute and Percent"]  = "[~Status?FractionalHP:Short] || [Status:PercentHP:Percent]",
		["Informational"]  = "[IsFriend?~Status?MissingHP:HideZero:Short:Color(ff7f7f)] || [~Status?FractionalHP:Short] || [Status:PercentHP:Percent]"
	},
	name = {
		["Standard"]             = "[Name] [AFKDND:Angle]",
		["Hostility Colored"]    = "[Name:HostileColor] [AFKDND:Angle]",
		["Class Colored"]        = "[Name:ClassColor] [AFKDND:Angle]",
		["Long"]                 = "[Level] [Name:ClassColor] [AFKDND:Angle]",
		["Long w/ Druid form"]   = "[Level] [Name:ClassColor] [DruidForm:Paren] [AFKDND:Angle]",
	},
	power = {
		["Absolute"]       = "[~HasNoMP?FractionalMP]",
		["Absolute Short"] = "[~HasNoMP?FractionalMP:Short]",
		["Difference"]     = "[MissingMP:Negate]",
		["Percent"]        = "[PercentMP:Percent]",
		["Mini"]           = "[~HasNoMP?CurMP:VeryShort]",
		["Smart"]          = "[MissingMP:HideZero:Short:Color(7f7fff)]",
	},
	threat = {
		["Absolute"]       = "[~HasNoThreat?Threat]",
		["Absolute Short"] = "[~HasNoThreat?Threat:Short]",
		["Fractional"]     = "[~HasNoThreat?FractionalThreat]",
		["Fractional Short"] = "[~HasNoThreat?FractionalThreat:Short]",
		["Difference"]     = "[~HasNoThreat?MissingThreat:Negate]",
		["Percent"]        = "[~HasNoThreat?PercentThreat:Percent]",
		["Mini"]           = "[~HasNoThreat?Threat:VeryShort]",
	},
	combo = (playerClass == "DRUID" or playerClass == "ROGUE") and {
		["Standard"]       = "[IsEnergy#player?Combos:HideZero]",
	} or nil,
	experience = {
		["Standard"]       = "[FractionalXP] [PercentXP:Percent:Paren] [PercentRestXP:HideZero:Percent:Prepend(R: )]",
		["On Mouse-over"]       = "[IsMouseover?FractionalXP] [IsMouseover?PercentXP:Percent:Paren] [IsMouseover?PercentRestXP:HideZero:Percent:Prepend(R: )]",
	},
	reputation = {
		["Standard"]       = "[~IsMouseOver?FractionalRep] [~IsMouseOver?PercentRep:Percent:Paren!RepName]",
	},
}

local styleTypeValidate = {
	class = L["Class"],
	health = L["Health"],
	name = L["Name"],
	power = L["Power"],
	threat = L["Threat"],
	combo = (playerClass == "DRUID" or playerClass == "ROGUE") and L["Combo points"] or nil,
	experience = L["Experience"],
	reputation = L["Reputation"],
	none = L["None"],
}

local styleTypeValidateDesc = {}

local defaultShownTexts = {
	Health = true,
	Class = true,
	Name = true,
	Power = true,
	Threat = function(group) return not group:find("target$") end,
	Combo = (playerClass == "DRUID" or playerClass == "ROGUE") and function(group) return group == "target" end or nil,
	Experience = function(group) return group == "player" or group == "pet" end,
	Reputation = function(group) return group == "player" end,
}

local function textExtraFrameCreation(id, name, func)
	assert(type(name) == "string")
	return function(unit, frame)
		if func and not func(frame.group) then
			return
		end
		if type(defaultShownTexts[name]) == "function" and not defaultShownTexts[name](frame.group) then
			return
		end
		local db = MetaLayout_db.profile[frame.group].texts[name]
		if db.hidden then
			return
		end
		local text = newFrame("FontString", frame.overlay, "OVERLAY")
		frame[id] = text
		local font, fontsize = PitBull:GetFont()
		text:SetFont(font, fontsize * db.size)
		text:SetShadowColor(0, 0, 0, 1)
		text:SetShadowOffset(0.8, -0.8)
		text:SetNonSpaceWrap(false)
		text:SetJustifyH("LEFT")
		local code
		if db.style == "Custom" then
			code = db.custom
		else
			local styles = textStyles[db.styleType]
			code = styles and styles[db.style] or ''
		end
		
		local position = MetaLayout_db.profile[frame.group].texts[name].position or "hide"
		local attach = ("-"):split(position, 2)
		if attach == "blankSpace" then
			if MetaLayout_db.profile[frame.group].bars.blankSpace.hidden then
				return
			end
		elseif attach == "hide" or (attach ~= "frame" and not frame[attach]) then
			return
		end
		if not PitBull.configMode or name == "Name" or code:find("[%[:%?!][Nn][Aa][Mm][Ee][%]:%?!]") then
			DogTag:AddFontString(text, frame, unit, code or '')
		else
			text:SetText("[" .. name .. "]")
		end
	end
end

local getTextStyle = setmetatable({}, {__index=function(self, name)
	self[name] = function(group)
		return MetaLayout_db.profile[group].texts[name].style
	end
	return self[name]
end})
local setTextStyle = setmetatable({}, {__index=function(self, name)
	local id = "layoutText" .. name
	self[name] = function(group, value)
		local db = MetaLayout_db.profile[group].texts[name]
		db.style = value

		local code
		if value == "Custom" then
			code = db.custom
		else
			local styles = textStyles[db.styleType]
			code = styles and styles[value] or ''
			db.custom = code
		end
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if not PitBull.configMode or name == "Name" or code:find("[%[:%?!][Nn][Aa][Mm][Ee][%]:%?!]") then
				DogTag:AddFontString(frame[id], frame, unit, code or '')
			else
				frame[id]:SetText("[" .. name .. "]")
			end
		end
	end
	return self[name]
end})

local getTextCustom = setmetatable({}, {__index=function(self, name)
	self[name] = function(group)
		return MetaLayout_db.profile[group].texts[name].custom
	end
	return self[name]
end})
local setTextCustom = setmetatable({}, {__index=function(self, name)
	local id = "layoutText" .. name
	self[name] = function(group, value)
		value = DogTag:FixCasing(value)
		local db = MetaLayout_db.profile[group].texts[name]
		db.custom = value

		if db.style ~= "Custom" then
			return
		end
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if not PitBull.configMode or name == "Name" or value:find("[%[:%?!][Nn][Aa][Mm][Ee][%]:%?!]") then
				DogTag:AddFontString(frame[id], frame, unit, value)
			else
				frame[id]:SetText("[" .. name .. "]")
			end
			
		end
	end
	return self[name]
end})

local getTextSize = setmetatable({}, {__index=function(self, name)
	self[name] = function(group)
		return MetaLayout_db.profile[group].texts[name].size
	end
	return self[name]
end})
local setTextSize = setmetatable({}, {__index=function(self, name)
	self[name] = function(group, value)
		MetaLayout_db.profile[group].texts[name].size = value

		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end
	return self[name]
end})

local getHiddenTextsValidate
local setTextEnabled = setmetatable({}, {__index=function(self, name)
	self[name] = function(group, value)
		MetaLayout_db.profile[group].texts[name].hidden = not value
		
		getHiddenTextsValidate(group, true)
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
		
		Rock("LibRockConfig-1.0"):RefreshConfigMenu(PitBull)
	end
	return self[name]
end})

local basePositionValidate = {
	["fullBar-left"] = ("%s/%s"):format(L["Full"], L["Left"]),
	["fullBar-center"] = ("%s/%s"):format(L["Full"], L["Middle"]),
	["fullBar-right"] = ("%s/%s"):format(L["Full"], L["Right"]),
	["fullBar-outright"] = ("%s/%s"):format(L["Full"], L["Outside, Right"]),
	["fullBar-outleft"] = ("%s/%s"):format(L["Full"], L["Outside, Left"]),

	["healthBar-left"] = ("%s/%s"):format(L["Health"], L["Left"]),
	["healthBar-center"] = ("%s/%s"):format(L["Health"], L["Middle"]),
	["healthBar-right"] = ("%s/%s"):format(L["Health"], L["Right"]),
	["healthBar-outright"] = ("%s/%s"):format(L["Health"], L["Outside, Right"]),
	["healthBar-outleft"] = ("%s/%s"):format(L["Health"], L["Outside, Left"]),
	
	["powerBar-left"] = ("%s/%s"):format(L["Power"], L["Left"]),
	["powerBar-center"] = ("%s/%s"):format(L["Power"], L["Middle"]),
	["powerBar-right"] = ("%s/%s"):format(L["Power"], L["Right"]),
	["powerBar-outright"] = ("%s/%s"):format(L["Power"], L["Outside, Right"]),
	["powerBar-outleft"] = ("%s/%s"):format(L["Power"], L["Outside, Left"]),
	
	["threatBar-left"] = ("%s/%s"):format(L["Threat"], L["Left"]),
	["threatBar-center"] = ("%s/%s"):format(L["Threat"], L["Middle"]),
	["threatBar-right"] = ("%s/%s"):format(L["Threat"], L["Right"]),
	["threatBar-outright"] = ("%s/%s"):format(L["Threat"], L["Outside, Right"]),
	["threatBar-outleft"] = ("%s/%s"):format(L["Threat"], L["Outside, Left"]),
	
	["expBar-left"] = ("%s/%s"):format(L["Experience"], L["Left"]),
	["expBar-center"] = ("%s/%s"):format(L["Experience"], L["Middle"]),
	["expBar-right"] = ("%s/%s"):format(L["Experience"], L["Right"]),
	["expBar-outright"] = ("%s/%s"):format(L["Experience"], L["Outside, Right"]),
	["expBar-outleft"] = ("%s/%s"):format(L["Experience"], L["Outside, Left"]),
	
	["repBar-left"] = ("%s/%s"):format(L["Reputation"], L["Left"]),
	["repBar-center"] = ("%s/%s"):format(L["Reputation"], L["Middle"]),
	["repBar-right"] = ("%s/%s"):format(L["Reputation"], L["Right"]),
	["repBar-outright"] = ("%s/%s"):format(L["Reputation"], L["Outside, Right"]),
	["repBar-outleft"] = ("%s/%s"):format(L["Reputation"], L["Outside, Left"]),
	
	["blankSpace-left"] = ("%s/%s"):format(L["Blank space"], L["Left"]),
	["blankSpace-center"] = ("%s/%s"):format(L["Blank space"], L["Middle"]),
	["blankSpace-right"] = ("%s/%s"):format(L["Blank space"], L["Right"]),
	["blankSpace-outright"] = ("%s/%s"):format(L["Blank space"], L["Outside, Right"]),
	["blankSpace-outleft"] = ("%s/%s"):format(L["Blank space"], L["Outside, Left"]),
	
	["portrait-left"] = ("%s/%s"):format(L["Portrait"], L["Left"]),
	["portrait-right"] = ("%s/%s"):format(L["Portrait"], L["Right"]),
	["portrait-top"] = ("%s/%s"):format(L["Portrait"], L["Top"]),
	["portrait-center"] = ("%s/%s"):format(L["Portrait"], L["Middle"]),
	["portrait-bottom"] = ("%s/%s"):format(L["Portrait"], L["Bottom"]),
	["portrait-topleft"] = ("%s/%s"):format(L["Portrait"], L["Top-left"]),
	["portrait-topright"] = ("%s/%s"):format(L["Portrait"], L["Top-right"]),
	["portrait-bottomleft"] = ("%s/%s"):format(L["Portrait"], L["Bottom-left"]),
	["portrait-bottomright"] = ("%s/%s"):format(L["Portrait"], L["Bottom-right"]),
	
	["frame-outtopleft"] = ("%s/%s"):format(L["Frame"], L["Outside, Above-left"]),
	["frame-outtop"] = ("%s/%s"):format(L["Frame"], L["Outside, Above-middle"]),
	["frame-outtopright"] = ("%s/%s"):format(L["Frame"], L["Outside, Above-right"]),
	["frame-outbottomleft"] = ("%s/%s"):format(L["Frame"], L["Outside, Below-left"]),
	["frame-outbottom"] = ("%s/%s"):format(L["Frame"], L["Outside, Below-middle"]),
	["frame-outbottomright"] = ("%s/%s"):format(L["Frame"], L["Outside, Below-right"]),
	["frame-outlefttop"] = ("%s/%s"):format(L["Frame"], L["Outside, Left-top"]),
	["frame-outleft"] = ("%s/%s"):format(L["Frame"], L["Outside, Left-middle"]),
	["frame-outleftbottom"] = ("%s/%s"):format(L["Frame"], L["Outside, Left-bottom"]),
	["frame-outrighttop"] = ("%s/%s"):format(L["Frame"], L["Outside, Right-top"]),
	["frame-outright"] = ("%s/%s"):format(L["Frame"], L["Outside, Right-middle"]),
	["frame-outrightbottom"] = ("%s/%s"):format(L["Frame"], L["Outside, Right-bottom"]),
	
	["frame-center"] = ("%s/%s"):format(L["Frame"], L["Inside, Center"]),
	["frame-intopleft"] = ("%s/%s"):format(L["Frame"], L["Inside, Top-left"]),
	["frame-intop"] = ("%s/%s"):format(L["Frame"], L["Inside, Top"]),
	["frame-intopright"] = ("%s/%s"):format(L["Frame"], L["Inside, Top-right"]),
	["frame-inbottomleft"] = ("%s/%s"):format(L["Frame"], L["Inside, Bottom-left"]),
	["frame-inbottom"] = ("%s/%s"):format(L["Frame"], L["Inside, Bottom"]),
	["frame-inbottomright"] = ("%s/%s"):format(L["Frame"], L["Inside, Bottom-right"]),
	["frame-inleft"] = ("%s/%s"):format(L["Frame"], L["Inside, Left"]),
	["frame-inright"] = ("%s/%s"):format(L["Frame"], L["Inside, Right"]),
	
	["frame-edgetopleft"] = ("%s/%s"):format(L["Frame"], L["Edge, Top-left"]),
	["frame-edgetop"] = ("%s/%s"):format(L["Frame"], L["Edge, Top"]),
	["frame-edgetopright"] = ("%s/%s"):format(L["Frame"], L["Edge, Top-right"]),
	["frame-edgeleft"] = ("%s/%s"):format(L["Frame"], L["Edge, Left"]),
	["frame-edgeright"] = ("%s/%s"):format(L["Frame"], L["Edge, Right"]),
	["frame-edgebottomleft"] = ("%s/%s"):format(L["Frame"], L["Edge, Bottom-left"]),
	["frame-edgebottom"] = ("%s/%s"):format(L["Frame"], L["Edge, Bottom"]),
	["frame-edgebottomright"] = ("%s/%s"):format(L["Frame"], L["Edge, Bottom-right"]),
	
	["hide"] = L["Hidden"],
}

local setTextPosition = setmetatable({}, {__index=function(self, name)
	self[name] = function(group, value)
		if type(group) == "table" then
			group, value = unpack(group)
		end
		if value ~= "hide" then
			local frame = findTextAtPosition(group, value)
			if frame then
				frame = frame:gsub("^layoutText", "")
				MetaLayout_db.profile[group].texts[frame].position = MetaLayout_db.profile[group].texts[name].position
			end
		end
		MetaLayout_db.profile[group].texts[name].position = value
	
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end
	return self[name]
end})
local getTextPosition = setmetatable({}, {__index=function(self, name)
	self[name] = function(group)
		if type(group) == "table" then
			local value
			group, value = unpack(group)
			return MetaLayout_db.profile[group].texts[name].position == value
		end
		return MetaLayout_db.profile[group].texts[name].position
	end
	return self[name]
end})

local setIconPosition = setmetatable({}, {__index=function(self, name)
	self[name] = function(group, value)
		if type(group) == "table" then
			group, value = unpack(group)
		end
		MetaLayout_db.profile[group].icons[name].position = value
	
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			PitBull:UpdateLayout(frame)
		end
	end
	return self[name]
end})
local getIconPosition = setmetatable({}, {__index=function(self, name)
	self[name] = function(group)
		if type(group) == "table" then
			local value
			group, value = unpack(group)
			return MetaLayout_db.profile[group].icons[name].position == value
		end
		return MetaLayout_db.profile[group].icons[name].position
	end
	return self[name]
end})

local getPositionArgs_hidden = setmetatable({}, {__index = function(self, attach)
	self[attach] = function(group)
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame[attach] then
				return false
			end
		end
		return true
	end
	return self[attach]
end})
local positionArgs = {}
function getPositionArgs(group, name, icon)
	if not positionArgs[group] then
		positionArgs[group] = {}
	end
	if positionArgs[group][name] then
		return positionArgs[group][name]
	end
	local t = {}
	positionArgs[group][name] = t
	
	for k, v in pairs(basePositionValidate) do
		local attach, point = ('-'):split(k)
		local attachName, pointName = ('/'):split(v)
		if point then
			if not t[attach] then
				t[attach] = {
					type = 'choice',
					name = attachName,
					desc = attachName,
					choices = {},
					get = not icon and getTextPosition[name] or getIconPosition[name],
					set = not icon and setTextPosition[name] or setIconPosition[name],
					passValue = group,
					hidden = attach ~= "frame" and getPositionArgs_hidden[attach]
				}
			end
			t[attach].choices[k] = pointName
		else
			t[attach] = {
				type = 'boolean',
				name = v,
				desc = v,
				get = not icon and getTextPosition[name] or getIconPosition[name],
				set = not icon and setTextPosition[name] or setIconPosition[name],
				passValue = { group, k },
			}
		end
	end
	return t
end

local styleValidates = {}
local styleValidateDescs = {}
local function getStyleValidate(group, name, forceUpdate)
	if not styleValidates[group] then
		styleValidates[group] = {}
		styleValidateDescs[group] = {}
	end
	if styleValidates[group][name] then
		if not forceUpdate then
			return styleValidates[group][name]
		end
		for k in pairs(styleValidates[group][name]) do
			styleValidates[group][name][k] = nil
			styleValidateDescs[group][name][k] = nil
		end
	end
 	local t = styleValidates[group][name] or {}
	local u = styleValidateDescs[group][name] or {}
	styleValidates[group][name] = t
	styleValidateDescs[group][name] = u
	local db = MetaLayout_db.profile[group].texts[name]
	local styleType = db.styleType
	local styles = textStyles[styleType]
	t["Hide"] = L["Hide"]
	u["Hide"] = ""
	t["Custom"] = L["Custom"]
	u["Custom"] = L["Choose your own custom text."]
	if styles then
		for k, v in pairs(styles) do
			t[k] = L[k]
			u[k] = v
		end
	end
	return t
end
local function getStyleValidateDescs(group, name)
	getStyleValidate(group, name) -- to update
	return styleValidateDescs[group][name]
end

local getTextStyleType = setmetatable({}, {__index=function(self, name)
	self[name] = function(group)
		return MetaLayout_db.profile[group].texts[name].styleType
	end
	return self[name]
end})
local setTextStyleType = setmetatable({}, {__index=function(self, name)
	local id = "layoutText" .. name
	self[name] = function(group, value)
		local db = MetaLayout_db.profile[group].texts[name]
		db.styleType = value
		
		getStyleValidate(group, name, true)
		
		if db.style == "Custom" then
			return
		end
		
		local styles = textStyles[db.styleType]
		if not styles then
			db.style = "Custom"
		elseif not styles[db.style] then
			if styles["Standard"] then
				db.style = "Standard"
			elseif styles["Absolute"] then
				db.style = "Absolute"
			else
				db.style = "Custom"
			end
		end
		local code
		if db.style == "Custom" then
			code = db.custom
		else
			code = styles[db.style] or ''
			db.custom = code
		end
		
		for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
			if not PitBull.configMode or name == "Name" or code:find("[%[:%?!][Nn][Aa][Mm][Ee][%]:%?!]") then
				DogTag:AddFontString(frame[id], frame, unit, code or '')
			else
				frame[id]:SetText("[" .. name .. "]")
			end
		end
	end
	return self[name]
end})

local function retTrue() return true end
local function retFalse() return false end

local function textOptions(id, name, noStyle)
	assert(type(name) == "string")
	if not noStyle then
		return function(group)
			return {
				type = 'choice',
				name = L["Style"],
				desc = L["Use a preconfigured style."],
				choices = getStyleValidate(group, name),
				choiceDescs = getStyleValidateDescs(group, name),
				get = getTextStyle[name],
				set = setTextStyle[name],
				passValue = group,
			}, {
				type = 'string',
				name = L["Style - Custom"],
				desc = L["Create a custom style for this unit type."],
				get = getTextCustom[name],
				set = setTextCustom[name],
				usage = L["LibDogTag-2.0 tags. See http://www.wowace.com/wiki/LibDogTag-2.0"],
				passValue = group,
			}, {
				type = 'choice',
				name = L["Style - Type"],
				desc = L["Choose the type of pre-made styles to work with."],
				get = getTextStyleType[name],
				set = setTextStyleType[name],
				passValue = group,
				choices = styleTypeValidate,
				choiceDescs = styleTypeValidateDesc,
			}, {
				type = 'group',
				groupType = 'inline',
				name = L["Position"],
				desc = L["Position of the text."],
				args = getPositionArgs(group, name),
			}, {
				type = 'number',
				name = L["Size"],
				desc = L["Font size of the text."],
				get = getTextSize[name],
				set = setTextSize[name],
				passValue = group,
				min = 0.25,
				max = 3,
				step = 0.01,
				bigStep = 0.05,
				isPercent = true,
			}, {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Click to disable this text from being shown."],
				get = retTrue,
				set = setTextEnabled[name],
				passValue = group,
			}
		end
	else
		return function(group)
			return {
				type = 'group',
				groupType = 'inline',
				name = L["Position"],
				desc = L["Position of the text."],
				args = getPositionArgs(group, name),
			}
		end
	end
end

local function createArbitraryText(name, extraFrameFunc)
	if name == "Combo" then
		if playerClass ~= "DRUID" and playerClass ~= "ROGUE" then
			return
		end
	end
	local textOptionsArg
	if extraFrameFunc == true then
		extraFrameFunc = nil
		textOptionsArg = true
	end
	local id = textOptionsArg and name or "layoutText" .. name
	if MetaLayout.positions[id] or (MetaLayout.positions[name] and name:find("[Tt][Ee][Xx][Tt]")) then
		return
	end
	MetaLayout.positions[id] = textPosition(id, name)
	if not textOptionsArg then
		MetaLayout.extraFrames[id] = textExtraFrameCreation(id, name, extraFrameFunc)
	end
	-- L[name] should be changed to L:HasTranslation(id) and L[id]
	MetaLayout.options.name[id] = L[name]
	MetaLayout.options.desc[id] = L["Customize the %s text."]:format(L[name])
	MetaLayout.options[id] = textOptions(id, name, textOptionsArg)
end

createArbitraryText('combatText', true)

local hiddenTextsValidate = {}
function getHiddenTextsValidate(group, forceUpdate)
	if hiddenTextsValidate[group] then
		if not forceUpdate then
			return hiddenTextsValidate[group]
		end
		for k in pairs(hiddenTextsValidate[group]) do
			hiddenTextsValidate[group][k] = nil
		end
	end
	local t = hiddenTextsValidate[group] or {}
	hiddenTextsValidate[group] = t
	for k,v in pairs(defaultShownTexts) do
		if MetaLayout_db.profile[group].texts[k].hidden then
			t[k] = L[k]
			if type(v) == "function" then
				if not v(group) then
					t[k] = nil
				end
			end
		end
	end
	for k,v in pairs(MetaLayout_db.profile[group].texts) do
		if v.hidden then
			t[k] = L[k]
			if type(defaultShownTexts[k]) == "function" then
				if not defaultShownTexts[k](group) then
					t[k] = nil
				end
			end
		end
	end
	return t
end

local function otherTexts_hidden_set(group, name)
	MetaLayout_db.profile[group].texts[name].hidden = false
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end
	getHiddenTextsValidate(group, true)
	Rock("LibRockConfig-1.0"):RefreshConfigMenu(PitBull)
end

local function otherTexts_hidden_disabled(group)
	return not next(hiddenTextsValidate[group])
end

local function otherTexts_new_set(group, name)
	if not MetaLayout_db.profile[group].texts[name].hidden then
		return
	end
	if name == "Combat" or name == L["Combat"] then
		return
	end
	MetaLayout_db.profile[group].texts[name].hidden = false
	if MetaLayout_db.profile[group].texts[name].custom == "" then
		MetaLayout_db.profile[group].texts[name].custom = name
	end
	createArbitraryText(name)
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end	
	Rock("LibRockConfig-1.0"):RefreshConfigMenu(PitBull)
end

function MetaLayout.options.alwaysText(group)
	return {
		type = 'group',
		name = L["Other"],
		desc = L["Create other texts."],
		order = 101,
		args = {
			hidden = {
				type = 'choice',
				name = L["Disabled texts"],
				desc = L["Show some of the disabled texts."],
				get = retFalse,
				set = otherTexts_hidden_set,
				choices = getHiddenTextsValidate(group),
				passValue = group,
				disabled = otherTexts_hidden_disabled
			},
			new = {
				type = 'string',
				name = L["New text"],
				desc = L["Create a new text."],
				get = false,
				set = otherTexts_new_set,
				passValue = group,
				usage = L["<Name>"]
			}
		},
	}
end

local function blankSpace_enable_get(group)
	return not MetaLayout_db.profile[group].bars.blankSpace.hidden
end
local function blankSpace_disable_get(group)
	return MetaLayout_db.profile[group].bars.blankSpace.hidden
end
local function blankSpace_enable_set(group, value)
	MetaLayout_db.profile[group].bars.blankSpace.hidden = not value
	for unit, frame in PitBull:IterateUnitFramesByGroup(group) do
		PitBull:UpdateLayout(frame)
	end
end
local blackSpace_optionsFunc = barOptions('blankSpace')
function MetaLayout.options.alwaysBar(group)
	return {
		type = 'group',
		name = L["Blank space"],
		desc = L["Change settings for the blank space."],
		args = {
			{
				name = L["Enable"],
				desc = L["Enable the blank space."],
				type = 'boolean',
				passValue = group,
				get = blankSpace_enable_get,
				set = blankSpace_enable_set,
			}, blackSpace_optionsFunc(group, blankSpace_disable_get)
		},
		order = 50,
	}
end

PitBull:RegisterMetaLayout(MetaLayout)

function MetaLayout:OnInitialize()
	f = nil
	for k in pairs(defaultShownTexts) do
		createArbitraryText(k)
	end
	for group, data in pairs(MetaLayout_db.profile) do
		for k in pairs(data.texts) do
			createArbitraryText(k)
		end
	end
end

local function nilDefault(value, default, setToDefault)
	if value == default or value == nil or type(value) ~= type(default) then
		if setToDefault then
			return default
		else
			return nil
		end
	else
		return value
	end
end

function MetaLayout:ExportLayout(group)
	local layout = newList()
	layout.pbRevision = PitBull.revision
	
	local db = MetaLayout_db.profile[group]
	
	layout.texts = newList()
	for k,v in pairs(db.texts) do
		local hidden = nilDefault(v.hidden, false) or v.position == "hide"
		if not hidden then
			local t = newList()
			layout.texts[k] = t
			t.size = nilDefault(v.size, 1)
			t.style = nilDefault(v.style, "Custom")
			t.styleType = nilDefault(v.styleType, "none")
			t.position = nilDefault(v.position, "frame-center", true)
			t.custom = nilDefault(v.custom, "")
		end
	end
	
	layout.icons = newList()
	for k,v in pairs(db.icons) do
		local t = newList()
		layout.icons[k] = t
		t.size = nilDefault(v.size, 1)
		t.position = nilDefault(v.position, "frame-edgebottomleft", true)
	end
	
	layout.bars = newList()
	for k,v in pairs(db.bars) do
		local t = newList()
		layout.bars[k] = t
		t.height = nilDefault(v.height, 2)
		t.position = nilDefault(v.position, 1, true)
		t.side = v.side
		if type(t.side) ~= "string" then
			t.side = nil
		end
		t.hidden = nilDefault(v.hidden, false)
	end
	
	return layout
end

local function toDefault(value, default)
	if value == nil or type(value) ~= type(default) then
		return default
	else
		return value
	end
end

local function recurseCheckNonKosher(t)
	-- only tables, strings, numbers, and booleans are kosher values.
	local type_t = type(t)
	if type_t == "table" then
		for k, v in pairs(t) do
			if recurseCheckNonKosher(k) or recurseCheckNonKosher(v) then
				return true
			end
		end
		return false
	end
	return type_t ~= "number" and type_t ~= "string" and type_t ~= "boolean" and type_t ~= "nil"
end

local function handleLayout(layout)
	if type(layout) ~= "table" then
		return nil, "Error, Layout must be a table."
	end
	local pbRevision = layout.pbRevision
	if type(pbRevision) ~= "number" then
		return nil, ("Error, %q must be a number."):format("pbRevision")
	end

	if pbRevision > PitBull.revision then
		return nil, ("Error importing layout made with a newer version of PitBull: %d > %d."):format(pbRevision, PitBull.revision)
	end
	
	if type(layout.texts) ~= "table" then
		return nil, ("Error, %q must be a table."):format("texts")
	elseif type(layout.icons) ~= "table" then
		return nil, ("Error, %q must be a table."):format("icons")
	elseif type(layout.bars) ~= "table" then
		return nil, ("Error, %q must be a table."):format("bars")
	end
	
	layout = deepCopy(layout)
	
	if recurseCheckNonKosher(layout) then
		return nil, "Error, improper values found in resultant table."
	end
	
	for k,v in pairs(layout.texts) do
		if type(k) == "string" and type(v) == "table" then
			v.size = toDefault(v.size, 1)
			v.style = toDefault(v.style, "Custom")
			v.styleType = toDefault(v.styleType, "none")
			v.position = toDefault(v.position, "frame-center")
			v.custom = toDefault(v.custom, "")
		else
			layout.texts[k] = deepDel(v)
		end
	end

	for k,v in pairs(layout.icons) do
		if type(k) == "string" and type(v) == "table" then
			v.size = toDefault(v.size, 1)
			v.position = toDefault(v.position, "frame-edgebottomleft")
		else
			layout.icons[k] = deepDel(v)
		end
	end

	for k,v in pairs(layout.bars) do
		if type(k) == "string" and type(v) == "table" then
			v.height = toDefault(v.height, 2)
			v.position = toDefault(v.position, 1)
			v.side = v.side -- handle later
			v.hidden = toDefault(v.hidden, false) or nil
		else
			layout.bars[k] = deepDel(v)
		end
	end
	
	-- check for syntax errors maybe
	return layout
end

function MetaLayout:IsValidLayout(layout)
	layout, problem = handleLayout(layout)
	if not layout then
		return layout, problem
	end
	
	layout = deepDel(layout)
	return true
end

function MetaLayout:ImportLayout(group, layout)
	layout, problem = handleLayout(layout)
	if not layout then
		return layout, problem
	end
	
	local db = MetaLayout_db.profile[group]
	for k,v in pairs(db.texts) do
		db.texts[k] = del(v)
	end
	for k,v in pairs(layout.texts) do
		local t = newList()
		db.texts[k] = t
		t.size = v.size
		t.style = v.style
		t.styleType = v.styleType
		t.position = v.position
		t.custom = v.custom
		t.hidden = false
	end
	for k,v in pairs(MetaLayout_db.defaults.profile['**'].texts) do
		if not layout.texts[k] and k ~= '*' and k ~= '**' then
			local t = newList()
			db.texts[k] = t
			for l,u in pairs(v) do
				t[l] = u
			end
			if MetaLayout_db.defaults.profile[group] and MetaLayout_db.defaults.profile[group].texts then
				for l,u in pairs(MetaLayout_db.defaults.profile[group].texts) do
					t[l] = u
				end
			end
			t.hidden = true
		end
	end
	
	for k,v in pairs(db.icons) do
		db.icons[k] = del(v)
	end
	for k,v in pairs(layout.icons) do
		local t = newList()
		db.icons[k] = t
		t.size = v.size
		t.position = v.position
	end
	
	for k,v in pairs(db.bars) do
		db.bars[k] = del(v)
	end
	for k,v in pairs(layout.bars) do
		local t = newList()
		db.bars[k] = t
		t.height = v.height
		t.position = v.position
		t.side = v.side
		t.hidden = v.hidden
	end
	
	layout = deepDel(layout)
	
	return true
end

function MetaLayout:IsCurrentLayout(group, layout, debug)
	layout, problem = handleLayout(layout)
	if not layout then
		return layout, problem
	end
	
	local good = true
	local db = MetaLayout_db.profile[group]
	for k,v in pairs(layout.texts) do
		local t = db.texts[k]
		if type(t) ~= "table" or t.size ~= v.size or t.style ~= v.style or t.styleType ~= v.styleType or t.position ~= v.position or t.custom ~= v.custom or not t.hidden ~= not v.hidden then
			layout = deepDel(layout)
			return false
		end
	end
	for k, v in pairs(db.texts) do
		if not v.hidden and not layout.texts[k] then
			layout = deepDel(layout)
			return false
		end
	end
	
	for k,v in pairs(layout.icons) do
		local t = db.icons[k]
		if type(t) ~= "table" or t.size ~= v.size or t.position ~= v.position then
			layout = deepDel(layout)
			return false
		end
	end
	
	for k,v in pairs(layout.bars) do
		local t = db.bars[k]
		if type(t) ~= "table" or t.height ~= v.height or t.position ~= v.position or t.side ~= v.side or not t.hidden ~= not v.hidden then
			layout = deepDel(layout)
			return false
		end
	end
	
	layout = deepDel(layout)
	
	return true
end
