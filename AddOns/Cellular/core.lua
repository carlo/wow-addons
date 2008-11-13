local Cellular = CreateFrame("Frame", "Cellular", UIParent)

-- LIBRARIES
local smed = AceLibrary("SharedMedia-1.0")
local dew = AceLibrary("Dewdrop-2.0")

-- GLOBALS -> LOCALS
local db, svar
local format, strfind, strsub, strlower, gsub = string.format, string.find, string.sub, string.lower, string.gsub
local tsort, tinsert, tgetn, unpack = table.sort, table.insert, table.getn, unpack
local cfeb = ChatFrameEditBox
local cf_rt, cfeb_oh

-- LOCAL VARS
local you, attached, lastwindow
local nwindows = 0
local windows, usedwindows, recentw = {}, {}, {}
local l_p, l_rt, l_rp, l_x, l_y
local r_p, r_rt, r_rp, r_x, r_y
local e = {
	CHAT_MSG_WHISPER = true,
	CHAT_MSG_WHISPER_INFORM = true, 
	CHAT_MSG_AFK = true, 
	CHAT_MSG_DND = true, 
	CHAT_MSG_IGNORED = true, 
}

-- LOCAL FUNCS
local MinimizeWindow, ShowOptions, GetWindow
Cellular:SetScript("OnEvent", function(this, event, ...)
	this[event](this, ...)
end)
Cellular:RegisterEvent("ADDON_LOADED")

----------------------------------
function Cellular:ADDON_LOADED(a1)
----------------------------------
	if a1 ~= "Cellular" then return end
	self:UnregisterEvent("ADDON_LOADED")
	
	CellularDB = CellularDB or {}
	db = (CellularDB.profiles and CellularDB.profiles.Default) or CellularDB
	if not db.dbinit then
		for k,v in pairs({
			height = 160,
			width = 340,
			pos = { },
			bg = "Tooltip",
			bgcolor = { 0, 0, 0, 1, },
			border = true,
			bordercolor = { 0.7, 0.7, 0.7, 1, },
			alpha = 0.9,
			fontsize = 12,
			incolor = { 1, 0, 1, 1, },
			outcolor = { 0, 1, 1, 1, },
			busymessage = "Sorry, I'm busy right now...I'll chat with you later.",
			history = true,
			maxwindows = 8,
			fade = true,
			automin = false,
			showname = true,
			fontmsg = "Arial Narrow",
			fonttitle = "Arial Narrow",
			dbinit = true,
		}) do
			db[k] = (db[k] ~= nil and db[k]) or v
		end
	end
	-- saved history per char
	Cellular_History = Cellular_History or { }
	svar = Cellular_History
	
	SlashCmdList.CELLULAR = ShowOptions
	SLASH_CELLULAR1, SLASH_CELLULAR2 = "/cellular", "/cell"
	
	smed:Register("statusbar", "Tooltip", "Interface\\Tooltips\\UI-Tooltip-Background")
	
	for value,_ in pairs(e) do
		self:RegisterEvent(value)
	end
	
	you = UnitName("player")
end

--- EVENTS
--------------------------------------------------------------
function Cellular:CHAT_MSG_WHISPER()
	self:IncomingMessage(arg2, arg1, arg6, nil, arg11)
	if not IsAddOnLoaded("ChatSounds") then
		PlaySound("TellMessage")
	end
end
function Cellular:CHAT_MSG_WHISPER_INFORM(arg1, arg2)
	self:OutgoingMessage(arg2, arg1)
end
function Cellular:CHAT_MSG_AFK(arg1, arg2)
	self:IncomingMessage(arg2, "is AFK: "..arg1, nil, 2)
end

function Cellular:CHAT_MSG_DND(arg1, arg2)
	self:IncomingMessage(arg2, "is DND: "..arg1, nil, 3)
end

function Cellular:CHAT_MSG_IGNORED(_, arg2)
	self:IncomingMessage(arg2, "is ignoring you.", nil, 4)
end

-- parse some important system messages when chatting to someone
function Cellular:CHAT_MSG_SYSTEM(text)
	if not text then return end
	-- gone offline
	if strfind(text, "^(.+) has gone offline.") then
		local _,_,name = strfind(text, "^(.+) has gone offline.")
		self:IncomingMessage(name, "has gone offline.", nil, 1)
	-- came online	
	elseif strfind(text, "|Hplayer:(.+)|h%[(.+)%]|h has come online.") then
		local _,_,name = strfind(text, "|Hplayer:(.+)|h%[(.+)%]|h has come online.")
		self:IncomingMessage(name, "has come online.", nil, 1)
	-- declines group	
	elseif strfind(text, "^(.+) declines your group invitation.") then
		local _,_,name = strfind(text, "^(.+) declines your group invitation.")
		self:IncomingMessage(name, "declines your group invitation.", nil, 1)
	end
end
--------------------------------------------------------------

--- HOOKS
-- don't display some messages to the chat frame
hooksecurefunc("ChatFrame_AddMessageGroup", function(this)
	if not this then return end
	for value in pairs(e) do
		this:UnregisterEvent(value)
	end
end)
hooksecurefunc("ChatFrame_RegisterForMessages", function()
	for value in pairs(e) do
		this:UnregisterEvent(value)
	end
end)


--- EDITBOX
-- attach the main chat editbox to the current person you're whispering
local function AttachEditBox(name, id)
	if not attached then
		l_p, l_rt, l_rp, l_x, l_y = cfeb:GetPoint(1)
		r_p, r_rt, r_rp, r_x, r_y = cfeb:GetPoint(2)
	end
	cfeb:ClearAllPoints()
	cfeb:SetPoint("TOPLEFT", windows[id], "BOTTOMLEFT", 0, 6)
	cfeb:SetPoint("TOPRIGHT", windows[id], "BOTTOMRIGHT", 0, 6)
	ChatFrame_OpenChat(format("/w %s ", name))
	attached = id
end

-- reset the editbox to it's normal position
local function ResetEditBox()
	if not attached then return end
	ChatEdit_OnEscapePressed(cfeb)
	cfeb:ClearAllPoints()
	if l_p then
		cfeb:SetPoint(l_p, l_rt, l_rp, l_x, l_y)
	end
	if r_p then
		cfeb:SetPoint(r_p, r_rt, r_rp, r_x, r_y)
	end
	attached = nil
end

-- attach chat editbox to last whisper if visible
local function lChatFrame_ReplyTell(chatframe)
	local id = lastwindow
	if id and windows[id]:IsShown() then
		AttachEditBox(windows[id].name, id)
	end
	cf_rt(chatframe)
end

-- reset editbox when hidden
local function lChatFrame_OnHide()
	cfeb_oh()
	ResetEditBox()
end


local function Busy(name)
	if db.busymessage and db.busymessage ~= "" then
		SendChatMessage(db.busymessage, "WHISPER", nil, name)
	end
end


-- message handlers
do
	-- url patterns copy & paste from old Prat version
	local function Link(link)
		return format(" |cffffffff|Hurl:%s|h[%s]|h|r ", link, link)
	end
	local function Decompose(text)
	    if text then
	        text = gsub(text, " www%.([_A-Za-z0-9-]+)%.(%S+)%s?", Link("www.%1.%2"))
	        text = gsub(text, " (%a+)://(%S+)%s?", Link("%1://%2"))
	        text = gsub(text, " ([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)%.([_A-Za-z0-9-%.]+)%s?", Link("%1@%2.%3"))
	        text = gsub(text, " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?", Link("%1.%2.%3.%4:%5"))
	        text = gsub(text, " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", Link("%1.%2.%3.%4"))
	        text = gsub(text, " ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%s?", Link("%1.%2.%3"))
	        text = gsub(text, " ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%:([_0-9-]+)%s?", Link("%1.%2.%3:%4"))
	    end
	    return text
	end
	local function InsertHistory(name, from, text)
		if db.history then
			local t = svar[name]
			t[tgetn(t) + 1] = format("<%s>[%s]%s", date("%m-%d-%y %H:%M"), from, text)
		end
	end

	-- handles all incoming whisper messages
	local spamname, spamtext, spamtime = "", "", 0
	local ChatEdit_SetLastTellTarget = ChatEdit_SetLastTellTarget
	local GetNumRaidMembers = GetNumRaidMembers
	---------------------------------------------------------------------
	function Cellular:IncomingMessage(name, text, status, special, arg11)
	---------------------------------------------------------------------
		if strsub(text, 1, 4) == "LVPN" or strsub(text, 1, 4) == "LVBM" or strsub(text, 1, 1) == "/" then return end
		if GetNumRaidMembers() > 5 then
			local ctime = GetTime()
			-- cheap bossmod spam protection
			if spamtext == text and spamname ~= "" and spamname ~= name and not strfind(strlower(text), "invite") and ctime - spamtime < 1 then
				spamtime, spamname, spamtext = ctime, name, text
				return
			else
				spamtime, spamname, spamtext = ctime, name, text
			end
		end
		
		-- open/create a new window if necessary
		local id = GetWindow(name, special)
		-- still nothing? must've reached maxed windows allowed
		if not id then
			if not special then
				Busy(name)
			end
			return
		end
		
		lastwindow = id
		local f = windows[id]
		-- remove realm name
		local tname = gsub(name, "-(.+)", "")
		-- handle special messages (system, afk, dnd, etc) and reduces the spam
		if special then
			if special == 1 then
				f.msg:AddMessage(format("[%s] %s %s", date("%H:%M:%S"), name, text), 1, 1, 0)
			else
				local ctime = GetTime()
				if not f.lastspecial or ctime > f.lastspecial + 90 or f.tag ~= special then
					f.lastspecial = ctime
					f.tag = special
					f.msg:AddMessage(format("[%s] %s %s", date("%H:%M:%S"), name, text), 1, 0, 0)
				end
			end
			return
		end
		
		-- show afk/dnd/gm tags
		status = (status and status ~= "" and format(" (%s)", status)) or ""
		text = Decompose(format(" %s", text))

		-- finally add the message to whisper window
		if db.showname then
			f.msg:AddMessage(format("|Hplayer:%s:%s|h[%s][%s]|h%s", name, arg11, date("%H:%M:%S"), tname..status, text), unpack(db.incolor))
		else
			f.msg:AddMessage(format("|Hplayer:%s:%s|h[%s%s]|h%s", name, arg11, date("%H:%M:%S"), status, text), unpack(db.incolor))
		end
		-- if the whisper window is minimized, show how many whispers came during this
		if f.mini then
			f.mininew = f.mininew + 1
			f.nametext:SetText(format("%s (%d)", f.name, f.mininew))
		end
		
		-- add entry to history
		ChatEdit_SetLastTellTarget(name)
		recentw[name] = name
		InsertHistory(name, tname, text)
	end

	-- handles your outgoing messages
	---------------------------------------------
	function Cellular:OutgoingMessage(name, text)
	---------------------------------------------
		if strsub(text, 1, 4) == "LVPN" or strsub(text, 1, 4) == "LVBM" or strsub(text, 1, 1) == "/" then return end
		-- basically same as above, just from you
		
		local id = GetWindow(name)
		if not id then return end
		
		lastwindow = id
		local f = windows[id]
		
		text = Decompose(format(" %s", text))
		if db.showname then
			f.msg:AddMessage(format("[%s][%s]%s", date("%H:%M:%S"), you, text), unpack(db.outcolor))
		else
			f.msg:AddMessage(format("[%s]%s", date("%H:%M:%S"), text), unpack(db.outcolor))
		end
		
		ChatEdit_SetLastTellTarget(name)
		recentw[name] = name
		InsertHistory(name, you, text)
	end
end

--- WINDOW RESERVATIONS

-- setup a new or unused window for a whisperer
local function SetupWindow(name, showmore)
	local f
	-- assumes if a window is hidden, it's unused
	for _,w in ipairs(windows) do
		if not w:IsShown() then
			f = w
			break
		end
	end
	-- cleanup
	for n,id in pairs(usedwindows) do
		if not windows[id] or not windows[id]:IsShown() then
			usedwindows[n] = nil
		end
	end
	-- if no windows are available, make a new one
	if not f then 
		f = Cellular:CreateWindow() 
	end
	-- still no windows, you probably hit maximum allowed
	if not f then return end
	
	-- setup
	f.nametext:SetText(name)
	f.name = name
	f.mininew = 0
	f.lastspecial = nil
	f.tag = nil
	f.msg:Clear()
	f.msg:ScrollToBottom()
	
	-- show recent history if available
	local t = svar[name]
	if t then
		local n = tgetn(t)
		local numlines = (showmore and 80) or 12
		for i = max(1, n-numlines), n, 1 do
			f.msg:AddMessage(t[i], 0.6, 0.6, 0.6)
		end
	else
		svar[name] = {}
	end
	usedwindows[name] = f.id
	f:Show()
	return f.id
end

-- retrieve window
function GetWindow(name, isSpecial)
	local id = usedwindows[name]
	if (not id or not windows[id]:IsShown()) and not isSpecial then
		id = SetupWindow(name)
		if id and InCombatLockdown() and db.automin then
			MinimizeWindow(windows[id].Minimize)
		end
	end
	return id
end



---- FRAME/VISUAL STUFF

local buttons
-- button functions
do
	local function Who(this)
		SendWho(this:GetParent().name)
	end
	local function bBusy(this)
		Busy(this:GetParent().name)
	end
	local function Invite(this)
		if IsShiftKeyDown() then
			InviteUnit(this:GetParent().name)
		end
	end
	local function Friend(this)
		if IsShiftKeyDown() then
			AddFriend(this:GetParent().name)
		end
	end
	local function Ignore(this)
		if IsShiftKeyDown() then
			AddIgnore(this:GetParent().name)
		end
	end
	local function ScrollUp(this)
		this:GetParent().msg:ScrollUp()
	end
	local function ScrollDown(this)
		this:GetParent().msg:ScrollDown()
	end
	local function ScrollBottom(this)
		this:GetParent().msg:ScrollToBottom()
	end
	function MinimizeWindow(this)
		local f = this:GetParent()
		if not f.mini then
			f.mini = 1
			f:SetHeight(30)
			f.msg:Hide()
			for butt,t in pairs(buttons) do
				if not t.dontmin then
					f[butt]:Hide()
				end
			end
			f.resizer:Hide()
			f.mininew = 0
		else
			f.mini = nil
			f:SetHeight(db.height)
			f.msg:Show()
			for butt in pairs(buttons) do
				f[butt]:Show()
			end
			f.resizer:Show()
			f.nametext:SetText(f.name)
		end
	end
	local function CloseWindow(this)
		local p = this:GetParent()
		if p.mini then
			MinimizeWindow(p.Minimize)
		end
		if attached == p.id then 
			ResetEditBox() 
		end 
		usedwindows[p.name] = nil
		p.name = ""
		p:Hide()
	end
	local function CloseAndDelete(this)
		if IsShiftKeyDown() then
			svar[this:GetParent().name] = nil
			CloseWindow(this)
		end
	end

	buttons = {
		Who			= { p="TOPLEFT", x=6, y=-24, tt=1, path="Interface\\Icons\\INV_Misc_QuestionMark", func=Who, },
		Busy			= { p="TOPLEFT", x=6, y=-46, tt=1, path="Interface\\Icons\\Spell_Holy_Silence", func=bBusy, },
		Invite		= { p="TOPLEFT", x=6, y=-63, tt=2, path="Interface\\Icons\\Spell_Holy_PrayerOfMendingtga", func=Invite, },
		Friend		= { p="TOPLEFT", x=6, y=-80, tt=2, path="Interface\\Icons\\Spell_ChargePositive", func=Friend, },
		Ignore		= { p="TOPLEFT", x=6, y=-100, tt=2, path="Interface\\Icons\\Spell_ChargeNegative", func=Ignore, },
		scrollup		= { p="BOTTOMRIGHT", x=-6, y=42, path="Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up", func=ScrollUp, },
		scrolldown	= { p="BOTTOMRIGHT", x=-6, y=26, path="Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", func=ScrollDown, },
		scrollbottom	= { p="BOTTOMRIGHT", x=-6, y=10, path="Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Up", func=ScrollBottom, },
		Close		= { p="TOPRIGHT", x=-6, y=-6, tt=1, tpl="UIPanelButtonTemplate", func=CloseWindow, bt = "x", dontmin = true, },
		Delete		= { p="TOPRIGHT", x=-22, y=-6, tt=2, tpl="UIPanelButtonTemplate", func=CloseAndDelete, bt = ".", dontmin = true, },
		Minimize		= { p="TOPRIGHT", x=-38, y=-6, tt=1, tpl="UIPanelButtonTemplate", func=MinimizeWindow, bt = "-", dontmin = true, },
	}
end


-- main whisper windows
-- backdrop table
local bdt = {
	tileSize = 16,
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}
do
	-- button creation and layout handler
	local CreateButton
	do
		local gtt = GameTooltip
		local function BOnEnter1(this)
			gtt:SetOwner(this, "ANCHOR_BOTTOMLEFT")
			gtt:SetText(this.text) 
			gtt:Show()
		end
		local function BOnEnter2(this)
			gtt:SetOwner(this, "ANCHOR_BOTTOMLEFT")
			gtt:SetText(this.text) 
			gtt:AddLine(" Shift-click to execute")
			gtt:Show()
		end
		local function BOnLeave() gtt:Hide() end
		local function BDown(this) this:SetAlpha(0.3) end
		local function BUp(this) this:SetAlpha(0.6) end

		function CreateButton(parent, name, w, h, texture, func, point, x, y, tt, template, bt)
			local b = CreateFrame("Button", nil, parent, template)
			b.text = name
			b:SetWidth(w)
			b:SetHeight(h)
			b:SetPoint(point, parent, point, x, y)
			if texture then
				b:SetNormalTexture(texture)
				b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
			end
			b:SetScript("OnMouseDown", BDown)
			b:SetScript("OnMouseUp", BUp)
			b:SetScript("OnClick", func)
			if tt then
				b:SetScript("OnEnter", (tt == 1 and BOnEnter1) or BOnEnter2)
				b:SetScript("OnLeave", BOnLeave)
			end
			if bt then
				b:SetText(bt)
			end
			b:SetAlpha(0.6)
			parent[name] = b
		end
	end
	
	local function UpdateSizes() 
		local w,h = db.width, db.height
		for _,f in pairs(windows) do
			f:SetWidth(w)
			f:SetHeight(h)
		end
	end
	local function ResizeStart(this)
		this:GetParent():StartSizing("BOTTOMRIGHT")
		this.sizing = 1
	end
	local function ResizeEnd(this)
		if this.sizing then
			local p = this:GetParent()
			p:StopMovingOrSizing()
			this.sizing = nil
			db.height = floor(p:GetHeight() + 0.5)
			db.width = floor(p:GetWidth() + 0.5)
			UpdateSizes()
		end
	end
	local function DragStart(this)
		this:StartMoving()
	end
	local function DragStop(this)
		this:StopMovingOrSizing()
		db.pos[this.id] = db.pos[this.id] or {}
		local t = db.pos[this.id]
		t.p, t.rp, t.x, t.y = "TOPLEFT", "BOTTOMLEFT", this:GetLeft(), this:GetTop()
		this:ClearAllPoints()
		this:SetPoint(t.p, UIParent, t.rp, t.x, t.y)
	end
	local function MainClick(this, a1)
		if a1 == "LeftButton" then
			if attached == this.id then
				cfeb:Hide()
			else
				AttachEditBox(this.name, this.id) 
			end
		else
			ShowOptions()
		end
	end
	local function DoubleClick(this)
		MinimizeWindow(this.Minimize)
	end
	local function OnLinkClick(_,a1,a2,a3)
		if strsub(a1, 1, 3) == "url" then
			StaticPopupDialogs.SHOW_URL = StaticPopupDialogs.SHOW_URL or StaticPopupDialogs.URL_COPY or {
				text = "URL for Copy & Paste",
				button2 = "Close",
				hasEditBox = 1,
				hasWideEditBox = 1,
				showAlert = 1,
				OnShow = function()
					local editBox = _G[this:GetName().."WideEditBox"]
					editBox:SetText(a1:sub(5))
					editBox:SetFocus()
					editBox:HighlightText(0)
					local button = _G[this:GetName().."Button2"]
					button:ClearAllPoints()
					button:SetWidth(200)
					button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
					_G[this:GetName().."AlertIcon"]:Hide()
				end,
				EditBoxOnEscapePressed = function() this:GetParent():Hide() end,
				timeout = 0,
				whileDead = 1,
				hideOnEscape = 1
			}
			StaticPopup_Show("SHOW_URL", a1)
		else
			ChatFrame_OnHyperlinkShow(a1, a2, a3)
		end
	end
	local function Wheel(this, a1)
		if not a1 then return end
		if a1 > 0 then
			this.msg:ScrollUp()
			this.msg:ScrollUp()
		else
			this.msg:ScrollDown()
			this.msg:ScrollDown()
		end 
	end
	--------------------------------
	function Cellular:CreateWindow()
	--------------------------------
		if nwindows >= db.maxwindows then return end
		nwindows = nwindows + 1
		
		if nwindows == 1 then
			self:RegisterEvent("CHAT_MSG_SYSTEM")

			cf_rt = ChatFrame_ReplyTell
			ChatFrame_ReplyTell = lChatFrame_ReplyTell
			
			cfeb_oh = cfeb:GetScript("OnHide") or function() end
			cfeb:SetScript("OnHide", lChatFrame_OnHide)
		end
		
		-- the main frame, lots to do
		local f = CreateFrame("Button", nil, UIParent)
		f:SetWidth(db.width)
		f:SetHeight(db.height)
		local pos = db.pos[nwindows]
		if pos then
			f:SetPoint(pos.p or "TOPLEFT", UIParent, pos.rp or "TOPLEFT", pos.x, pos.y)
		else
			f:SetPoint("CENTER", UIParent, "CENTER", (nwindows-1)*20, -(nwindows-1)*20)
		end
		bdt.bgFile = smed:Fetch("statusbar", db.bg)
		bdt.tile = db.bg == "Tooltip"
		bdt.edgeFile = (db.border and "Interface\\Tooltips\\UI-Tooltip-Border") or ""
		f:SetBackdrop(bdt)
		f:SetBackdropColor(unpack(db.bgcolor))
		f:SetBackdropBorderColor(unpack(db.bordercolor))
		f.id = nwindows
		f:SetMovable(true)
		f:SetResizable(true)
		f:EnableMouseWheel(true)
		f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", DragStart)
		f:SetScript("OnDragStop", DragStop)
		f:SetScript("OnClick", MainClick)
		f:SetScript("OnDoubleClick", DoubleClick)
		f:SetScript("OnMouseWheel", Wheel)
		f:SetClampedToScreen(true)
		
		-- resizing button
		f:SetMinResize(140, 130)
		f.resizer = CreateFrame("Button", nil, f, "UIPanelButtonGrayTemplate")
		f.resizer:SetHeight(8)
		f.resizer:SetWidth(8)
		f.resizer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
		f.resizer:SetScript("OnMouseDown", ResizeStart)
		f.resizer:SetScript("OnMouseUp", ResizeEnd)
		
		-- scrolling text
		f.msg = CreateFrame("ScrollingMessageFrame", nil, f)
		f.msg:SetPoint("TOPLEFT", 24, -18)
		f.msg:SetPoint("BOTTOMRIGHT", -20, 8)
		f.msg:UnregisterAllEvents()
		f.msg:SetFont(smed:Fetch("font", db.fontmsg), db.fontsize)
		f.msg:SetJustifyH("LEFT")
		f.msg:SetTimeVisible(120)
		f.msg:SetMaxLines(100)
		f.msg:SetFading(db.fade)
		f.msg:SetScript("OnHyperlinkClick", OnLinkClick)
		f.msg:Show()
		
		-- title text
		f.nametext = f:CreateFontString(nil, "OVERLAY")
		f.nametext:SetFont(smed:Fetch("font", db.fonttitle), 12)
		f.nametext:SetJustifyH("LEFT")
		f.nametext:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -7)
		f.nametext:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -8, -18)

		f:SetAlpha(db.alpha)
		-- all the buttons
		for b,t in pairs(buttons) do
			CreateButton(f, b, 16, 16, t.path, t.func, t.p, t.x, t.y, t.tt, t.tpl, t.bt)
		end
		
		windows[nwindows] = f
		return f
	end
end


-- Options Function
do
	-- update history list
	local list = {}
	local function UpdateHistoryList()
		for index in pairs(list) do
			list[index] = nil
		end
		for name in pairs(svar) do
			tinsert(list, name)
		end
		tsort(list)
	end
	local function UpdateLook()
		bdt.bgFile = smed:Fetch("statusbar", db.bg)
		bdt.tile = (db.bg == "Tooltip")
		bdt.edgeFile = (db.border and "Interface\\Tooltips\\UI-Tooltip-Border") or ""
		for _,f in ipairs(windows) do
			f:SetBackdrop(bdt)
			f:SetBackdropColor(unpack(db.bgcolor))
			f:SetBackdropBorderColor(unpack(db.bordercolor))
			f:SetAlpha(db.alpha)
			f.msg:SetFont(smed:Fetch("font", db.fontmsg), db.fontsize)
			f.msg:SetFading(db.fade)
			f.nametext:SetFont(smed:Fetch("font", db.fonttitle), 12)
		end
	end
	local function set(k,v,v2,v3,v4)
		if k == "show" then
			GetWindow(v)
		elseif k == "clear" then
			if IsShiftKeyDown() then
				svar[v] = nil
				UpdateHistoryList()
			end
		else
			if type(db[k]) == "table" then
				db[k][1], db[k][2], db[k][3], db[k][4] = v, v2, v3, v4
			else
				db[k] = v
			end
			UpdateLook()
		end
	end
	local function get(k)
		if type(db[k]) == "table" then
			return unpack(db[k])
		else
			return db[k]
		end
	end
	local function clear(k)
		if k == "clearall" and IsShiftKeyDown() then
			for name in pairs(svar) do
				svar[name] = nil
			end
			UpdateHistoryList()
		end
	end
	local opts = {
		type="group",
		args = {
			header = { type="header", name="|cff88ff88Cellular|r", order=1, },
			frame = {
				type="group", name="Appearance", desc="Appearance",
				pass=true, set=set, get=get,
				order=2,
				args = {
					bg = { type="text", name="Background texture", desc="Background texture", validate=smed:List("statusbar"), order=1, },
					bgcolor = { type="color", name="Background color", desc="Background color", order=2, hasAlpha=true, },
					border = { type="toggle", name="Show border", desc="Show border", order=3, },
					bordercolor = { type="color", name="Border color", desc="Border color", order=4, hasAlpha=true, },
					fonttitle = { type="text", name="Title font", desc="Title font", validate=smed:List("font"), order=5, },
					fontmsg = { type="text", name="Message font", desc="Message font", validate=smed:List("font"), order=6, },
					fontsize = { type="range", name="Message font size", desc="Message font size", min=6, max=30, step=1, order=7, },
					incolor = { type="color", name="Incoming color", desc="Text color for incoming messages", order=8, hasAlpha=true, },
					outcolor = { type="color", name="Outgoing color", desc="Text color for outgoing messages", order=9, hasAlpha=true, },
					alpha = { type="range", name="Opacity", desc="Opacity", min=0.05, max=1, step=0.01, order=10, },
				},
			},
			behavior = {
				type="group", name="Behavior", desc="Behavior",
				pass=true, set=set, get=get,
				order=3,
				args = {
					maxwindows = { type="range", name="Max windows", desc="Maximum number of windows allowed to be created", min=1, max=12, step=1, order=1, },
					fade = { type="toggle", name="Fade", desc="Enables fading old messages", order=2, },
					showname = { type="toggle", name="Show name", desc="Display whisperers' name with messages", order=3, },
					automin = { type="toggle", name="Combat minimize", desc="Auto minimize new windows if in combat", order=4, },
				},
			},
			busymessage = { type="text", name="Busy Message", desc="Set your busy message", usage="", set=set, get=get, passValue="busymessage", order=4, },
			history = {
				type="group", name="History", desc="History",
				pass=true, set=set, get=get, func=clear,
				order=8,
				args = {
					history = { type="toggle", name="Enabled", desc="Toggle history logging", order=1, },
					recent = { type="text", name="Show recent", desc="Show recent", get=false, passValue="show", validate=recentw, order=2, },
					show = { type="text", name="Show", desc="Show", get=false, validate=list, order=3, },
					clear = { type="text", name="Clear", desc="Clear an entry (must hold shift key to execute)", get=false, validate=list, order=4, },
					clearall = { type="execute", name="Clear All", desc="Clear all entries (must hold shift key to execute)", order=5, },
				},
			},
		},
	}
	function ShowOptions()
		UpdateHistoryList()
		dew:Open( UIParent, 'children', function() dew:FeedAceOptionsTable(opts) end, 'cursorX', true, 'cursorY', true )  
	end
end
