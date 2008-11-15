--[[-
LibExtraTip

LibExtraTip is a library of API functions for manipulating additional information into GameTooltips by either adding information to the bottom of existing tooltips (embedded mode) or by adding information to an extra "attached" tooltip construct which is placed to the bottom of the existing tooltip.

Copyright (C) 2008, by the respecive below authors.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

@author Matt Richard (Tem)
@author Ken Allan <ken@norganna.org>
@libname LibExtraTip
@version 1.0
--]]

local MAJOR,MINOR,REVISION = "LibExtraTip", 1, "$Revision: 164 $"

-- A string unique to this version to prevent frame name conflicts.
local LIBSTRING = MAJOR.."_"..MINOR.."_"..REVISION
local lib = LibStub:NewLibrary(MAJOR.."-"..MINOR, REVISION)
if not lib then return end

-- Call function to deactivate any outdated version of the library.
-- (calls the OLD version of this function, NOT the one defined in this
-- file's scope)
if lib.Deactivate then lib:Deactivate() end

-- Forward definition of a few locals that get defined at the bottom of
-- the file.
local tooltipMethods
local ExtraTipClass

-- Money Icon setup
local iconpath = "Interface\\MoneyFrame\\UI-"
local goldicon = "%d|T"..iconpath.."GoldIcon:::1:-2|t"
local silvericon = "%s|T"..iconpath.."SilverIcon:::1:-2|t"
local coppericon = "%s|T"..iconpath.."CopperIcon:::1:-2|t"

-- Function that gets run when an item is set on a registered tooltip.
local function OnTooltipSetItem(tooltip)
	local self = lib
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:OnTooltipSetItem()")

	if self.sortedCallbacks and #self.sortedCallbacks > 0 then
		tooltip:Show()
		local _,item = tooltip:GetItem()

		-- For generated tooltips
		if not item and reg.item then item = reg.item end

		if item and not reg.hasItem then
			local name,link,quality,ilvl,minlvl,itype,isubtype,stack,equiploc,texture = GetItemInfo(item)
			if link then
				name = name or "unknown" -- WotLK bug
				reg.hasItem = true
				local extraTip = self:GetFreeExtraTipObject()
				reg.extraTip = extraTip
				extraTip:Attach(tooltip)
				extraTip:AddLine(ITEM_QUALITY_COLORS[quality].hex .. name)

				local quantity = reg.quantity

				reg.additional.item = item
				reg.additional.quantity = quantity or 1
				reg.additional.name = name
				reg.additional.link = link
				reg.additional.quality = quality
				reg.additional.itemLevel = ilvl
				reg.additional.minLevel = minlvl
				reg.additional.itemType = itype
				reg.additional.itemSubtype = isubtype
				reg.additional.stackSize = stack
				reg.additional.equipLocation = equiploc
				reg.additional.texture = texture
				
				for i,callback in ipairs(self.sortedCallbacks) do
					callback(tooltip,item,quantity,name,link,quality,ilvl,minlvl,itype,isubtype,stack,equiploc,texture)
				end
				tooltip:Show()
				if reg.extraTipUsed then reg.extraTip:Show() end
			end
		end
	end
end

-- Function that gets run when a registered tooltip's item is cleared.
local function OnTooltipCleared(tooltip)
	local self = lib
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:OnTooltipCleared()")
	
	if reg.ignoreOnCleared then return end
	
	if reg.extraTip then
		table.insert(self.extraTippool, reg.extraTip)
		reg.extraTip:Hide()
		reg.extraTip:Release()
		reg.extraTip = nil
	end
	reg.extraTipUsed = nil
	reg.minWidth = 0
	reg.quantity = nil
	reg.hasItem = nil
	table.wipe(reg.additional)
end

-- Function that gets run when a registered tooltip's size changes.
local function OnSizeChanged(tooltip,w,h)
	local self = lib
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:OnSizeChanged()")

	local extraTip = reg.extraTip
	if extraTip then
		extraTip:NeedsRefresh(true)
	end
end

function lib:GetFreeExtraTipObject()
	if not self.extraTippool then self.extraTippool = {} end
	return table.remove(self.extraTippool) or ExtraTipClass:new()
end

local hooks = {}

-- Called to apply a pre-hook on the given tooltip's method.
local function hook(tip,method,hook)
	local orig = tip[method]
	hooks[tip] = hooks[tip] or {origs = {}, hooks = {}}
	hooks[tip].origs[method] = orig
	local reg = lib.tooltipRegistry[tip]
	local h = function(self,...)
		OnTooltipCleared(tip)
		reg.ignoreOnCleared = true
		if hooks[tip].hooks[method] then
			hook(self,reg,...)
		end
		local a,b,c,d = orig(self,...)
		reg.ignoreOnCleared = nil
		return a,b,c,d
	end
	hooks[tip].hooks[method] = h
	tip[method] = h
end

-- Called to remove all our pre-hooks on the given tooltip's method, or
-- deactivate our hooks if not possible.
local function unhook(tip,method)
	if tip[method] == hooks[tip].hooks[method] then
		-- We still own the top of the hook stack, just pop off
		tip[method] = hooks[tip].origs[method]
	else -- We don't own the top so deactivate our hook
		hooks[tip].hooks[method] = nil
	end
end

-- Called to apply a pre-hook on the given tooltip's event.
local function hookscript(tip,script,hook)
	local orig = tip:GetScript(script)
	hooks[tip] = hooks[tip] or {origs = {}, hooks = {}}
	hooks[tip].origs[script] = orig
	local h = function(...)
		if hooks[tip].hooks[script] then
			hook(...)
		end
		if orig then orig(...) end
	end
	hooks[tip].hooks[script] = h
	tip:SetScript(script,h)
end

-- Called to remove all our pre-hooks on the given tooltip's event, or
-- deactivate our hooks if not possible.
local function unhookscript(tip,script)
	if tip:GetScript(script) == hooks[tip].hooks[script] then
		tip:SetScript(script,hooks[tip].origs[script])
	else
		hooks[tip].hooks[script] = nil
	end
end

--[[-
	Adds the provided tooltip to the list of tooltips to monitor for items.
	@param tooltip GameTooltip object
	@return true if tooltip is registered
	@since 1.0
]]
function lib:RegisterTooltip(tooltip)
	if not tooltip or type(tooltip) ~= "table" or type(tooltip.GetObjectType) ~= "function" or tooltip:GetObjectType() ~= "GameTooltip" then return end

	if not self.tooltipRegistry then
		self.tooltipRegistry = {}
		self:GenerateTooltipMethodTable()
	end

	if not self.tooltipRegistry[tooltip] then
		local reg = {}
		self.tooltipRegistry[tooltip] = reg
		reg.additional = {}

		hookscript(tooltip,"OnTooltipSetItem",OnTooltipSetItem)
		hookscript(tooltip,"OnTooltipCleared",OnTooltipCleared)
		hookscript(tooltip,"OnSizeChanged",OnSizeChanged)

		for k,v in pairs(tooltipMethods) do
			hook(tooltip,k,v)
		end
		return true
	end
end

--[[-
	Checks to see if the tooltip has been registered with LibExtraTip
	@param tooltip GameTooltip object
	@return true if tooltip is registered
	@since 1.0
]]
function lib:IsRegistered(tooltip)
	if not self.tooltipRegistry or not self.tooltipRegistry[tooltip] then
		return
	end
	return true
end

local sortFunc

--[[-
	Adds a callback to be informed of any registered tooltip's activity.
	Callbacks are passed the following parameters (in order):
		* tooltip: The tooltip object being shown (GameTooltip object)
		* item: The item being shown (in {@wowwiki:ItemLink} format)
		* quantity: The quantity of the item being shown (may be nil when the quantity is unavailable)
		* return values from {@wowwiki:API_GetItemInfo|GetItemInfo} (in order)
	@param callback the method to be called
	@param priority the priority of the callback (optional, default 200)
	@since 1.0
]]
function lib:AddCallback(callback,priority)
-- Lower priority gets called before higher priority.  Default is 200.
	if not callback or type(callback) ~= "function" then return end

	if not self.callbacks then
		self.callbacks = {}
		self.sortedCallbacks = {}
		local callbacks = self.callbacks
		sortFunc = function(a,b)
			return callbacks[a] < callbacks[b]
		end
	end

	self.callbacks[callback] = priority or 200
	table.insert(self.sortedCallbacks,callback)
	table.sort(self.sortedCallbacks,sortFunc)
end

--[[-
	Removes the given callback from the list of callbacks.
	@param callback the callback to remove from notifications
	@return true if successfully removed
	@since 1.0
]]
function lib:RemoveCallback(callback)
	if not (self.callbacks and self.callbacks[callback]) then return end
	self.callbacks[callback] = nil
	for i,c in ipairs(self.sortedCallbacks) do
		if c == callback then
			table.remove(self.sortedCallbacks,i)
			return true
		end
	end
end

--[[-
	Sets the default embed mode of the library (default false)
	A false embedMode causes AddLine, AddDoubleLine and AddMoneyLine to add lines to the attached tooltip rather than embed added lines directly in the item tooltip.
	This setting only takes effect when embed mode is not specified on individual AddLine, AddDoubleLine and AddMoneyLine commands.
	@param flag boolean flag if true embeds by default
	@since 1.0
]]
function lib:SetEmbedMode(flag)
	self.embedMode = flag and true or false
end

--[[-
	Adds a line to a registered tooltip.
	@param tooltip GameTooltip object
	@param text the contents of the tooltip line
	@param r red component of the tooltip line color (optional)
	@param g green component of the tooltip line color (optional)
	@param b blue component of the tooltip line color (optional)
	@param embed override the lib's embedMode setting (optional)
	@see SetEmbedMode
	@since 1.0
]]
function lib:AddLine(tooltip,text,r,g,b,embed)
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:AddLine()")

	if r and not g then embed = r r = nil end
	embed = embed ~= nil and embed or self.embedMode
	if not embed then
		reg.extraTip:AddLine(text,r,g,b)
		reg.extraTipUsed = true
	else
		tooltip:AddLine(text,r,g,b)
	end
end

--[[-
	Adds a two-columned line to the tooltip.
	@param tooltip GameTooltip object
	@param textLeft the left column's contents
	@param textRight the left column's contents
	@param r red component of the tooltip line color (optional)
	@param g green component of the tooltip line color (optional)
	@param b blue component of the tooltip line color (optional)
	@param embed override the lib's embedMode setting (optional)
	@see SetEmbedMode
	@since 1.0
]]
function lib:AddDoubleLine(tooltip,textLeft,textRight,lr,lg,lb,rr,rg,rb,embed)
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:AddDoubleLine()")

	if lr and not lg and not rr then embed = lr lr = nil end
	if lr and lg and rr and not rg then embed = rr rr = nil end
	embed = embed ~= nil and embed or self.embedMode
	if not embed then
		reg.extraTip:AddDoubleLine(textLeft,textRight,lr,lg,lb,rr,rg,rb)
		reg.extraTipUsed = true
	else
		tooltip:AddDoubleLine(textLeft,textRight,lr,lg,lb,rr,rg,rb)
	end
end

--[[-
	Creates a string representation of the money value passed using embedded textures for the icons
	@param money the money value to be converted in copper
	@param concise when false (default), the representation of 1g is "1g 00s 00c" when true, it is simply "1g" (optional)
	@since 1.0
]]
function lib:GetMoneyText(money, concise)
	local g = math.floor(money / 10000)
	local s = math.floor(money % 10000 / 100)
	local c = math.floor(money % 100)
	
	local moneyText = ""
	
	local f = false
	if g > 0 then
		moneyText = goldicon:format(g)
		f = true
	end
	
	if s > 0 or (concise and f and c > 0) or (not concise and f) then
		moneyText = moneyText..(f and " " or "")..silvericon:format(f and "%02d" or "%d"):format(s)
		f = true
	end
	
	if not concise or c > 0 or not f then
		moneyText = moneyText .. (f and " " or "")..coppericon:format(f and "%02d" or "%d"):format(c)
	end
	
	return moneyText
end

--[[-
	Adds a line with text in the left column and a money frame in the right.
	The money parameter is given in copper coins (i.e. 1g 27s 5c would be 12705)
	@param tooltip GameTooltip object
	@param text the contents of the tooltip line
	@param money the money value to be displayed (in copper)
	@param r red component of the tooltip line color (optional)
	@param g green component of the tooltip line color (optional)
	@param b blue component of the tooltip line color (optional)
	@param embed override the lib's embedMode setting (optional)
	@see SetEmbedMode
	@since 1.0
]]
function lib:AddMoneyLine(tooltip,text,money,r,g,b,embed)
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:AddMoneyLine()")
	
	if r and not g then embed = r r = nil end
	
	local moneyText = self:GetMoneyText(money)
	self:AddDoubleLine(tooltip,text,moneyText,r,g,b,1,1,1,embed)
end

--[[-
	Sets a tooltip to hyperlink with specified quantity
	@param tooltip GameTooltip object
	@param link hyperlink to display in the tooltip
	@param quantity quantity of the item to display
	@param detail additional detail items to set for the callbacks
	@return nil
	@since 1.0
]]
function lib:SetHyperlinkAndCount(tooltip, link, quantity, detail)
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:SetHyperlinkAndCount()")

	OnTooltipCleared(tooltip)
	reg.quantity = quantity
	reg.item = link
	reg.additional.event = "SetHyperlinkAndCount"
	reg.additional.eventLink = link
	if detail then
		for k,v in pairs(detail) do
			reg.additional[k] = v
		end
	end
	reg.ignoreOnCleared = true
	hooks[tooltip].origs["SetHyperlink"](tooltip,link)
	reg.ignoreOnCleared = nil
end

--[[-
	Get the additional information from a tooltip event.
	Often additional event details are available about the situation under which the tooltip was invoked, such as:
		* The call that triggered the tooltip.
		* The slot/inventory/index of the item in question.
		* Whether the item is usable or not.
		* Auction price information.
		* Ownership information.
		* Any data provided by the Get*Info() functions.
	If you require access to this information for the current tooltip, call this function to retrieve it.
	@param tooltip GameTooltip object
	@return table containing the additional information
	@since 1.0
]]
function lib:GetTooltipAdditional(tooltip)
	local reg = self.tooltipRegistry[tooltip]
	assert(reg, "Unknown tooltip passed to LibExtraTip:GetTooltipAdditional()")

	if reg then
		return reg.additional
	end
	return nil
end



--[[ INTERNAL USE ONLY
	Deactivates this version of the library, rendering it inert.
	Needed to run before an upgrade of the library takes place.
	@since 1.0
]]
function lib:Deactivate()
	if self.tooltipRegistry then
		for tooltip in self.tooltipRegistry do
			unhookscript(tooltip,"OnTooltipSetItem")
			unhookscript(tooltip,"OnTooltipCleared")
			unhookscript(tooltip,"OnSizeChanged")
			for k,v in pairs(tooltipMethods) do
				unhook(tooltip,k)
			end
		end
	end
end

--[[ INTERNAL USE ONLY
	Activates this version of the library.
	Configures this library for use by setting up its variables and reregistering any previously registered tooltips.
	@since 1.0
]]
function lib:Activate()
	if self.tooltipRegistry then
		local oldreg = self.tooltipRegistry
		self.tooltipRegistry = nil
		for tooltip in oldreg do
			self:RegisterTooltip(tooltip)
		end
	end
end

--[[ INTERNAL USE ONLY
	Generates a tooltip method table.
	The tooltip method table supplies hooking information for the tooltip registration functions, including the methods to hook and a function to run that parses the hooked functions parameters.
	@since 1.0
]]
function lib:GenerateTooltipMethodTable() -- Sets up hooks to give the quantity of the item
	local reg = self.tooltipRegistry
	tooltipMethods = {
		SetAction = function(self,reg, actionid)
			local t = GetActionInfo(actionid)
			if t == "item" then
				reg.quantity = GetActionCount(actionid)
				reg.additional.event = "SetAction"
				reg.additional.actionid = actionid
			end		
		end,
		
		SetAuctionItem = function(self,reg,type,index)
			local _,_,q,cu,min,inc,bo,ba,hb,own = GetAuctionItemInfo(type,index)
			reg.quantity = q
			reg.additional.event = "SetAuctionItem"
			reg.additional.eventType = type
			reg.additional.eventIndex = index
			reg.additional.canUse = cu
			reg.additional.minBid = min
			reg.additional.minIncrement = inc
			reg.additional.buyoutPrice = bo
			reg.additional.bidAmount = ba
			reg.additional.highBidder = hb
			reg.additional.owner = own
		end,

		SetAuctionSellItem = function(self,reg)
			local name,texture,quantity,quality,canUse,price = GetAuctionSellItemInfo()
			reg.quantity = quantity
			reg.additional.event = "SetAuctionSellItem"
			reg.additional.canUse = canUse
		end,
		
		SetBagItem = function(self,reg,bag,slot)
			local _,q,l,_,r= GetContainerItemInfo(bag,slot)
			reg.quantity = q
			reg.additional.event = "SetBagItem"
			reg.additional.eventContainer = bag
			reg.additional.eventIndex = slot
			reg.additional.readable = r
			reg.additional.locked = l
		end,
		
		SetBuybackItem = function(self,reg,index)
			local name,texture,price,quantity = GetBuybackItemInfo(index)
			reg.quantity = quantity
			reg.additional.event = "SetBuybackItem"
			reg.additional.eventIndex = index
		end,
		
		SetGuildBankItem = function(self,reg,tab,index)
			local texture,quantity,locked = GetGuildBankItemInfo(tab,index)
			reg.quantity = quantity
			reg.additional.event = "SetGuildBankItem"
			reg.additional.eventContainer = tab
			reg.additional.eventIndex = index
			reg.additional.locked = locked
		end,
		
		SetInboxItem = function(self,reg,index)
			local _,_,q,_,cu = GetInboxItem(index)
			reg.quantity = q
			reg.additional.event = "SetInboxItem"
			reg.additional.eventIndex = index
			reg.additional.canUse = cu
		end,

		SetLootItem = function(self,reg,index)
			local _,_,q = GetLootSlotInfo(index)
			reg.quantity = q
			reg.additional.event = "SetLootItem"
			reg.additional.eventIndex = index
		end,
		
		SetLootRollItem = function(self,reg,index)
			local texture, name, count, quality = GetLootRollItemInfo(index)
			reg.quantity = q
			reg.additional.event = "SetLootRollItem"
			reg.additional.eventIndex = index
		end,

		SetMerchantItem = function(self,reg,index)
			local _,_,p,q,na,cu,ec = GetMerchantItemInfo(index)
			reg.quantity = q
			reg.additional.event = "SetLootItem"
			reg.additional.eventIndex = index
			reg.additional.price = p
			reg.additional.numAvailable = na
			reg.additional.canUse = cu
			reg.additional.extendedCost = ec
		end,

		SetQuestItem = function(self,reg,type,index)
			local _,_,q,_,cu = GetQuestItemInfo(type,index)
			reg.quantity = q
			reg.additional.event = "SetQuestItem"
			reg.additional.eventType = type
			reg.additional.eventIndex = index
			reg.additional.canUse = cu
		end,
		
		SetQuestLogItem = function(self,reg,type,index)
			local _,q,cu
			if type == "choice" then
				_,_,q,_,cu = GetQuestLogChoiceInfo(index)
			else
				_,_,q,_,cu = GetQuestLogRewardInfo(index)
			end
			reg.quantity = q
			reg.additional.event = "SetQuestLogItem"
			reg.additional.eventType = type
			reg.additional.eventIndex = index
			reg.additional.canUse = cu
		end,
		
		SetSendMailItem = function(self,reg,index)
			local name,texture,quantity = GetSendMailItem(index)
			reg.quantity = quantity
			reg.additional.event = "SetSendMailItem"
			reg.additional.eventIndex = index
		end,	

		SetTradePlayerItem = function(self,reg,index)
			local name, texture, quantity = GetTradePlayerItemInfo(index)
			reg.quantity = quantity
			reg.additional.event = "SetTradePlayerItem"
			reg.additional.eventIndex = index
		end,
		
		SetTradeTargetItem = function(self,reg,index)
			local name, texture, quantity = GetTradeTargetItemInfo(index)
			reg.quantity = quantity
			reg.additional.event = "SetTradeTargetItem"
			reg.additional.eventIndex = index
		end,
		
		SetTradeSkillItem = function(self,reg,index,reagentIndex)
			reg.additional.event = "SetTradeSkillItem"
			reg.additional.eventIndex = index
			reg.additional.eventReagentIndex = reagentIndex
			if reagentIndex then
				local _,_,q,rc = GetTradeSkillReagentInfo(index,reagentIndex)
				reg.quantity = q
				reg.additional.playerReagentCount = rc
			else
				reg.quantity = GetTradeSkillNumMade(index)
			end
		end,

		SetHyperlink = function(self,reg,link)
			reg.additional.event = "SetHyperlink"
			reg.additional.eventLink = link
		end,
	}
end

do -- ExtraTip "class" definition
	local methods = {"InitLines","Attach","Show","MatchSize","Release","NeedsRefresh"}
	local scripts = {"OnShow","OnHide","OnSizeChanged"}
	local numTips = 0
	local class = {}
	ExtraTipClass = class

	local addLine,addDoubleLine,show = GameTooltip.AddLine,GameTooltip.AddDoubleLine,GameTooltip.Show

	local line_mt = {
		__index = function(t,k)
			local v = getglobal(t.name..k)
			rawset(t,k,v)
			return v
		end
	}

	function class:new()
		local n = numTips + 1
		numTips = n
		local o = CreateFrame("GameTooltip",LIBSTRING.."Tooltip"..n,UIParent,"GameTooltipTemplate")

		for _,method in pairs(methods) do
			o[method] = self[method]
		end

		for _,script in pairs(scripts) do
			o:SetScript(script,self[script])
		end

		o.left = setmetatable({name = o:GetName().."TextLeft"},line_mt)
		o.right = setmetatable({name = o:GetName().."TextRight"},line_mt)
		return o
	end

	function class:Attach(tooltip)
		self.parent = tooltip
		self:SetParent(tooltip)
		self:SetOwner(tooltip,"ANCHOR_NONE")
		self:SetPoint("TOP",tooltip,"BOTTOM")
	end

	function class:Release()
		self.parent = nil
		self:SetParent(nil)
		self.minWidth = 0
	end

	function class:InitLines()
		local n = self:NumLines()
		local changedLines = self.changedLines
		if not changedLines or changedLines < n then
			for i = changedLines or 1,n do
				local left,right = self.left[i],self.right[i]
				local font
				if i == 1 then
					font = GameFontNormal
				else
					font = GameFontNormalSmall
				end

				local r,g,b,a

				r,g,b,a = left:GetTextColor()
				left:SetFontObject(font)
				left:SetTextColor(r,g,b,a)

				r,g,b,a = right:GetTextColor()
				right:SetFontObject(font)
				right:SetTextColor(r,g,b,a)
			end
			self.changedLines = n
		end
	end

	local function refresh(self)
		self:NeedsRefresh(false)
		self:MatchSize()
	end

	function class:NeedsRefresh(flag)
		if flag then
			self:SetScript("OnUpdate",refresh)
		else
			self:SetScript("OnUpdate",nil)
		end
	end

	function class:OnSizeChanged(w,h)
		local p = self.parent
		if not p then return end
		local l,r,t,b = p:GetClampRectInsets()
		p:SetClampRectInsets(l,r,t,-h) -- should that be b-h?  Is playing nice even needed? Anyone who needs to mess with the bottom clamping inset will probably interfere with us anyway, right?
		self:NeedsRefresh(true)
	end

	function class:OnHide()
		local p = self.parent
		if not p then return end
		local l,r,t,b = p:GetClampRectInsets()
		p:SetClampRectInsets(l,r,t,0)
	end
		

	-- The right-side text is statically positioned to the right of the left-side text.
	-- As a result, manually changing the width of the tooltip causes the right-side text to not be in the right place.
	local function fixRight(tooltip,lefts,rights)
		local name,rn,ln,left,right
		local getglobal = getglobal
		if not lefts then
			name = tooltip:GetName()
			rn = name .. "TextRight"
			ln = name .. "TextLeft"
		end
		for i=1,tooltip:NumLines() do
			if not lefts then
				left = getglobal(ln..i)
				right = getglobal(rn..i)
			else
				left = lefts[i]
				right = rights[i]
			end
			if right:IsVisible() then
				right:ClearAllPoints()
				right:SetPoint("LEFT",left,"RIGHT")
				right:SetPoint("RIGHT",-10,0)
				right:SetJustifyH("RIGHT")
			end
		end
	end

	function class:MatchSize()
		local p = self.parent
		local pw = p:GetWidth()
		local w = self:GetWidth()
		local d = pw - w
		if d > .2 then
			self.sizing = true
			self:SetWidth(pw)
			fixRight(self,self.left,self.right)
		elseif d < -.2 then
			self.sizing = true
			p:SetWidth(w)
			fixRight(p)
		end
	end

	function class:Show()
		show(self)
		self:InitLines()
	end

end

-- More housekeeping upgrade stuff
lib:SetEmbedMode(lib.embedMode)
lib:Activate()


--[[ Test Code -----------------------------------------------------

local LT = LibStub("LibExtraTip-1")

LT:RegisterTooltip(GameTooltip)
LT:RegisterTooltip(ItemRefTooltip)

--[=[
LT:AddCallback(function(tip,item,quantity,name,link,quality,ilvl)
	LT:AddDoubleLine(tip,"Item Level:",ilvl,nil,nil,nil,1,1,1,0)
	LT:AddDoubleLine(tip,"Item Level:",ilvl,1,1,1,0)
	LT:AddDoubleLine(tip,"Item Level:",ilvl,0)
end,0)
--]=]
LT:AddCallback(function(tip,item,quantity,name,link,quality,ilvl)
	quantity = quantity or 1
	local price = GetSellValue(item)
	if price then
		LT:AddMoneyLine(tip,"Sell to vendor"..(quantity > 1 and "("..quantity..")" or "") .. ":",price*quantity,1)
	end
	LT:AddDoubleLine(tip,"Item Level:",ilvl,1)
end)

-- Test Code ]]-----------------------------------------------------

