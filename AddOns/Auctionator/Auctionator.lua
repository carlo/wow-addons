
local AuctionatorVersion = "1.3.0";
local AuctionatorAuthor  = "Zirco";

local AuctionatorLoaded = false;
local AuctionatorInited = false;

local recommendElements			= {};
local auctionsTabElements		= {};
local auctionsTabLeftElements	= {};

AUCTIONATOR_ENABLE_ALT		= 1;
AUCTIONATOR_OPEN_FIRST		= 0;
AUCTIONATOR_OPEN_ALL_BAGS	= 1;
AUCTIONATOR_DEF_DURATION	= "N";		-- none

local MODE_CREATE_AUCTION = 1;
local MODE_SHOW_ITEMLIST  = 2;

local kDropdown1_text = { "Create Auction", "List Items" };

-- saved variables - amounts to undercut

local auctionator_savedvars_defaults =
	{
	["_5000000"]			= 10000;	-- amount to undercut buyouts over 500 gold
	["_1000000"]			= 2500;
	["_200000"]				= 1000;
	["_50000"]				= 500;
	["_10000"]				= 200;
	["_2000"]				= 100;
	["_500"]				= 5;
	["STARTING_DISCOUNT"]	= 5;	-- PERCENT
	};


local AUCTION_CLASS_WEAPON = 1;
local AUCTION_CLASS_ARMOR  = 2;

-----------------------------------------

local auctionator_orig_AuctionFrameTab_OnClick;
local auctionator_orig_ContainerFrameItemButton_OnClick;
local auctionator_orig_AuctionFrameAuctions_Update;
local auctionator_orig_AuctionsCreateAuctionButton_OnClick;

local KM_NULL_STATE	= 0;
local KM_PREQUERY	= 1;
local KM_INQUERY	= 2;
local KM_POSTQUERY	= 3;
local KM_ANALYZING	= 4;

local processing_state	= KM_NULL_STATE;
local current_page;
local gForceMsgAreaUpdate = true;


local SETTLED				= 1;
local AUCTION_POST_PENDING	= 2;
local STACK_MERGE_PENDING	= 3;
local STACK_SPLIT_PENDING	= 4;


local gAutoSelling = false;
local gAutoSellState;

local gAutoSell_ItemName;
local gAutoSell_ItemLink;
local gAutoSell_GoodStackSize;
local gAutoSell_FullStackSize;
local gAutoSell_StartPrice;
local gAutoSell_BuyoutPrice;
local gAutoSell_Hours;
local gAutoSell_targetBS;
local gAutoSell_targetCount;
local gAutoSell_AuctionNum;
local gAutoSell_NumAuctionsToCreate;
local gAutoSell_TotalItems;

local gOpenAllBags  			= AUCTIONATOR_OPEN_ALL_BAGS;
local gSoftMatchItemName 		= nil;
local gTimeZero;
local gTimeTightZero;

local cslots = {};
local gEmptyBScached = nil;


local scandata;
local gSortedData = {};
local gBaseDataIndex;

local gSortedHistory = {};
local gBaseHistoryIndex;

local gCachedSortedData = {};

local gCurrentItemName = "";
local gCurrentStackSize = 0;
local gCurrentItemLink  = nil;

local gCurrentItemClass;
local gCurrentItemSubclass;

local auctionator_last_item_posted = nil;		-- set to the last item posted, even after the posting so that message and icon can be displayed
local auctionator_last_buyoutprice;
local auctionator_last_item_count;
local auctionator_last_itemlink;

local auctionator_pending_message = nil;

local kFirstBag, kLastBag = 0, 4;

local Auctionator_Confirm_Proc_Yes = nil;

local gStartingTime			= time();
local gHentryTryAgain		= nil;
local gCondensedThisSession = {};

local gHistoryItemList = {};
local ITEM_HIST_NUM_LINES = 20;

-----------------------------------------

local	BoolToString, BoolToNum, NumToBool, pluralizeIf, pluralize, round, chatmsg, chatmsg2, calcNewPrice, roundPriceDown;
local	val2gsc, priceToString, ItemType2AuctionClass, SubType2AuctionSubclass;
local	StringContains, StringEndsWith, StringStartsWith, CopyDeep, monthDay, ToTightTime, FromTightTime;

local BS_GetCount, BS_InCslots, BS_GetEmptySlot, BS_PostAuction, BS_FindGoodStack, BS_MergeSmallStacks, BS_SplitLargeStack;

-----------------------------------------


function Auctionator_EventHandler()

--	chatmsg (event);

	if (event == "VARIABLES_LOADED")			then	Auctionator_OnLoad(); 					end; 
	if (event == "ADDON_LOADED")				then	Auctionator_OnAddonLoaded(); 			end; 
	if (event == "AUCTION_ITEM_LIST_UPDATE")	then	Auctionator_OnAuctionUpdate(); 			end; 
	if (event == "AUCTION_OWNED_LIST_UPDATE")	then	Auctionator_OnAuctionOwnedUpdate(); 	end; 
	if (event == "AUCTION_HOUSE_SHOW")			then	Auctionator_OnAuctionHouseShow(); 		end; 
	if (event == "AUCTION_HOUSE_CLOSED")		then	Auctionator_OnAuctionHouseClosed(); 	end; 
	if (event == "NEW_AUCTION_UPDATE")			then	Auctionator_OnNewAuctionUpdate(); 		end; 
--	if (event == "BAG_UPDATE")					then	Auctionator_OnBagUpdate(); 				end; 

end

-----------------------------------------


function Auctionator_OnLoad()

	chatmsg("Auctionator Loaded");
	
	gTimeZero		= time({year=2000, month=1, day=1, hour=0});
	gTimeTightZero	= time({year=2008, month=8, day=1, hour=0});
	
	AuctionatorLoaded = true;

	if ( IsAddOnLoaded("Blizzard_AuctionUI") ) then		-- need this for AH_QuickSearch since that mod forces Blizzard_AuctionUI to load at a startup
		Auctionator_Init();
	end

end

-----------------------------------------

local gPrevTime = 0;

function Auctionator_OnAddonLoaded()

	local addonName = arg1:lower();

	if (addonName == "blizzard_auctionui") then
		Auctionator_Init();
	end
	
	local now = time();
	
--		chatmsg (addonName.."   time: "..now - gStartingTime);
	
	gPrevTime = now;
	
end

-----------------------------------------

function Auctionator_Init()

	if (AuctionatorInited) then
		return;
	end
	
--	chatmsg("Auctionator Initialized");

	AuctionatorInited = true;

	if (AUCTIONATOR_SAVEDVARS == nil) then
		Auctionator_ResetSavedVars();
	end

	if (AUCTIONATOR_PRICING_HISTORY == nil) then
		AUCTIONATOR_PRICING_HISTORY = {};
	end

	Auctionator_AddSellTab ();
	Auctionator_AddSellPanel ();
	
	Auctionator_SetupHookFunctions ();
	
	auctionsTabElements[1]  = AuctionsScrollFrame;
	auctionsTabElements[2]  = AuctionsButton1;
	auctionsTabElements[3]  = AuctionsButton2;
	auctionsTabElements[4]  = AuctionsButton3;
	auctionsTabElements[5]  = AuctionsButton4;
	auctionsTabElements[6]  = AuctionsButton5;
	auctionsTabElements[7]  = AuctionsButton6;
	auctionsTabElements[8]  = AuctionsButton7;
	auctionsTabElements[9]  = AuctionsButton8;
	auctionsTabElements[10] = AuctionsButton9;
	auctionsTabElements[11] = AuctionsQualitySort;
	auctionsTabElements[12] = AuctionsDurationSort;
	auctionsTabElements[13] = AuctionsHighBidderSort;
	auctionsTabElements[14] = AuctionsBidSort;
	auctionsTabElements[15] = AuctionsCancelAuctionButton;

	auctionsTabLeftElements[1] = StartPrice;
	auctionsTabLeftElements[2] = AuctionsShortAuctionButton;
	auctionsTabLeftElements[3] = AuctionsMediumAuctionButton;
	auctionsTabLeftElements[4] = AuctionsLongAuctionButton;
	auctionsTabLeftElements[5] = BuyoutPrice;
	auctionsTabLeftElements[6] = AuctionsCreateAuctionButton;
	auctionsTabLeftElements[7] = AuctionsItemButton;
	auctionsTabLeftElements[8] = AuctionsDepositMoneyFrame;

	recommendElements[1] = getglobal ("Auctionator_Recommend_Text");
	recommendElements[2] = getglobal ("Auctionator_RecommendPerItem_Text");
	recommendElements[3] = getglobal ("Auctionator_RecommendPerItem_Price");
	recommendElements[4] = getglobal ("Auctionator_RecommendPerStack_Text");
	recommendElements[5] = getglobal ("Auctionator_RecommendPerStack_Price");
	recommendElements[6] = getglobal ("Auctionator_Recommend_Basis_Text");
	recommendElements[7] = getglobal ("Auctionator_RecommendItem_Tex");

	-- create the lines that appear in the item history scroll pane
	
	local line, n;
	
	for n = 1, ITEM_HIST_NUM_LINES do
		local y = -5 - ((n-1)*16);
		line = CreateFrame("BUTTON", "AuctionatorHEntry"..n, Auctionator_Hlist, "Auctionator_HEntryTemplate");
		line:SetPoint("TOPLEFT", 0, y);
	end

	------------------
	
	CreateFrame( "GameTooltip", "MyScanningTooltip" ); -- Tooltip name cannot be nil
	MyScanningTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
	-- Allow tooltip SetX() methods to dynamically add new lines based on these
	MyScanningTooltip:AddFontStrings(
		MyScanningTooltip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
		MyScanningTooltip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ) );


end

-----------------------------------------

function Auctionator_DropDown1_OnLoad (self)
	UIDropDownMenu_Initialize(self, Auctionator_DropDown1_Initialize);
	UIDropDownMenu_SetSelectedValue(Auctionator_DropDown1, MODE_CREATE_AUCTION);
	Auctionator_DropDown1:Show();
end

-----------------------------------------

function Auctionator_DropDown1_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = kDropdown1_text[MODE_CREATE_AUCTION];
	info.value = MODE_CREATE_AUCTION;
	info.func = Auctionator_DropDown1_OnClick;
	info.checked = nil;
	UIDropDownMenu_AddButton(info);

	info.text = kDropdown1_text[MODE_SHOW_ITEMLIST];
	info.value = MODE_SHOW_ITEMLIST;
	info.func = Auctionator_DropDown1_OnClick;
	info.checked = nil;
	UIDropDownMenu_AddButton(info);

end

-----------------------------------------

function Auctionator_DropDown1_OnClick(self)
	
	UIDropDownMenu_SetSelectedValue(Auctionator_DropDown1, self.value);
	Auctionator_HideShowElements ();
	Auctionator_HideShowRBs();
	
	local mode = self.value;
	
	if (mode == MODE_CREATE_AUCTION) then
		local auctionItemName, auctionCount, auctionLink = Auctionator_GetSellItemInfo(); 
		Auctionator_BuildCreateAuctionPriceList (auctionItemName, auctionCount, auctionLink, 300);
	end
	
	if (mode == MODE_SHOW_ITEMLIST) then
		Auctionator_BuildPriceLists ("", 0, "", 120);
		
	end
	
end
-----------------------------------------

function Auctionator_HideShowElements ()

	local mode = Auctionator_GetDD1Mode();

	if (mode == MODE_CREATE_AUCTION) then
		Auctionator_ShowElems (auctionsTabLeftElements);
		Auctionator_BatchButton:Show();
		Auctionator_Hlist:Hide();
		Auctionator_Hlist_ScrollFrame:Hide();
	end
	
	if (mode == MODE_SHOW_ITEMLIST) then
		Auctionator_HideElems (auctionsTabLeftElements);
		Auctionator_BatchButton:Hide();
		Auctionator_Hlist:Show();
		Auctionator_Hlist_ScrollFrame:Show();
	end

end

-----------------------------------------

function Auctionator_HideShowRBs (mode)
	
	local auctionItemName = Auctionator_GetSellItemInfo(); 
		
	if (Auctionator_IsModeShowItemList() or auctionItemName ~= "") then
		Auctionator_CurrentAuctions_RB:Show();
		Auctionator_History_RB:Show();
	else
		Auctionator_CurrentAuctions_RB:Hide();
		Auctionator_History_RB:Hide();
	end

end

-----------------------------------------

function Auctionator_GetSellItemInfo ()

	local auctionItemName, auctionTexture, auctionCount = GetAuctionSellItemInfo(); 

	if (auctionItemName == nil) then
		auctionItemName = "";
		auctionCount	= 0;
	end

	local auctionItemLink = nil;

	-- only way to get sell itemlink that I can figure
		
	if (auctionItemName ~= "") then
		MyScanningTooltip:SetAuctionSellItem();
		local name;
		name, auctionItemLink = MyScanningTooltip:GetItem();
		
		if (auctionItemLink == nil) then
			return "",0,nil;
		end
		
	end
	
	return auctionItemName, auctionCount, auctionItemLink;
	
end


-----------------------------------------

function Auctionator_ResetSavedVars ()
	AUCTIONATOR_SAVEDVARS = CopyDeep (auctionator_savedvars_defaults);
end


-----------------------------------------

local _AUCTIONATOR_TAB_INDEX = 0;   -- don't reference this directly; use the function below instead

function Auctionator_FindTab ()
	
	if (_AUCTIONATOR_TAB_INDEX == 0) then
	
		local i = 4;
		while (true)  do
			local tab = getglobal('AuctionFrameTab'..i);
			if (tab == nil) then
				break
			end
				
			if (tab.isAuctionator) then
				_AUCTIONATOR_TAB_INDEX = i;
				break;
			end
			
			i = i + 1;
		end
	end
	
	return _AUCTIONATOR_TAB_INDEX;
end


-----------------------------------------


function Auctionator_AuctionFrameTab_OnClick (self, index)

	if ( not index ) then
		index = self:GetID();
	end

	getglobal("Auctionator_Sell_Panel"):Hide();

	if (index == 3) then		
		Auctionator_ShowElems (auctionsTabElements);
		Auctionator_ShowElems (auctionsTabLeftElements);
	end
	
	if (index ~= Auctionator_FindTab()) then
		auctionator_orig_AuctionFrameTab_OnClick (nil, index);
		auctionator_last_item_posted = nil;
		gForceMsgAreaUpdate = true;
		Auctionator_HideAllDialogs();
		AuctionFrameMoneyFrame:Show();
		gAutoSelling = false;
		
	elseif (index == Auctionator_FindTab()) then
		AuctionFrameTab_OnClick(nil, 3);
		
		PanelTemplates_SetTab(AuctionFrame, Auctionator_FindTab());
		
		AuctionFrameTopLeft:SetTexture	("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopLeft");
		AuctionFrameTop:SetTexture		("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top");
		AuctionFrameTopRight:SetTexture	("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight");
		AuctionFrameBotLeft:SetTexture	("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotLeft");
		AuctionFrameBot:SetTexture		("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		AuctionFrameBotRight:SetTexture	("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotRight");

		AuctionFrameMoneyFrame:Hide();
		
		Auctionator_HideElems (auctionsTabElements);


		Auctionator_HideShowElements ();
		Auctionator_HideShowRBs ();
		
		getglobal("Auctionator_Sell_Panel"):Show();

--		Auctionator_HideElems (recommendElements);

		if (gOpenAllBags == 1) then
			OpenAllBags(true);
			gOpenAllBags = 0;
		end
		
	
	end

end



-----------------------------------------

function Auctionator_Test1 ()
	local itemName, count, itemLink = Auctionator_GetSellItemInfo(); 

	local now = time();
	local h = 3600;
	local d = 24 * h;
	local m = 30 * d;

	Auctionator_AddHistoricalPrice (itemName, 10000, 12, itemLink, now - 6*h)
	Auctionator_AddHistoricalPrice (itemName, 20000, 12, itemLink, now - 7*h)
	Auctionator_AddHistoricalPrice (itemName, 30000, 12, itemLink, now - 8*h)
	Auctionator_AddHistoricalPrice (itemName, 40000, 12, itemLink, now - 1*d)
	Auctionator_AddHistoricalPrice (itemName, 50000, 12, itemLink, now - 7*d)
	Auctionator_AddHistoricalPrice (itemName, 60000, 12, itemLink, now - (7*d + 3*h))
	Auctionator_AddHistoricalPrice (itemName, 70000, 12, itemLink, now - (7*d + 4*h))
	Auctionator_AddHistoricalPrice (itemName, 80000, 12, itemLink, now - (7*d + 5*h))
	Auctionator_AddHistoricalPrice (itemName, 90000, 12, itemLink, now - (7*d + 6*h))
	Auctionator_AddHistoricalPrice (itemName, 100000, 12, itemLink, now - (2*m + 6*d))
	Auctionator_AddHistoricalPrice (itemName, 110000, 12, itemLink, now - (2*m + 7*d))
	Auctionator_AddHistoricalPrice (itemName, 120000, 12, itemLink, now - (2*m + 12*d))
	Auctionator_AddHistoricalPrice (itemName, 130000, 12, itemLink, now - (2*m + 14*d))
	Auctionator_AddHistoricalPrice (itemName, 140000, 12, itemLink, now - 3*m)
	Auctionator_AddHistoricalPrice (itemName, 150000, 12, itemLink, now - 4*m)
	Auctionator_AddHistoricalPrice (itemName, 160000, 12, itemLink, now - 5*m)
	Auctionator_AddHistoricalPrice (itemName, 170000, 12, itemLink, now - 36*m)
	Auctionator_AddHistoricalPrice (itemName, 180000, 12, itemLink, now - 37*m)
	Auctionator_AddHistoricalPrice (itemName, 190000, 12, itemLink, now - 38*m)
end

-----------------------------------------

function Auctionator_Test2 ()
	local itemName, count, itemLink = Auctionator_GetSellItemInfo(); 

	local now = time();
	local h = 3600;
	local d = 24 * h;
	local m = 30 * d;

	local jj;
	
	for jj = 1,60,2 do
		Auctionator_AddHistoricalPrice (itemName, (jj+1000), 12, itemLink, now - (40+jj)*h);
	end
end


-----------------------------------------

function Auctionator_Test3 ()
	local itemName, count, itemLink = Auctionator_GetSellItemInfo(); 

	Auctionator_Condense_History (itemName);
	
end

-----------------------------------------

function Auctionator_IsModeCreateAuction ()
	return (Auctionator_GetDD1Mode() == MODE_CREATE_AUCTION);
end

-----------------------------------------

function Auctionator_IsModeShowItemList ()
	return (Auctionator_GetDD1Mode() == MODE_SHOW_ITEMLIST);
end

-----------------------------------------

function Auctionator_GetDD1Mode ()
	return UIDropDownMenu_GetSelectedValue(Auctionator_DropDown1);
end

-----------------------------------------


function Auctionator_ContainerFrameItemButton_OnModifiedClick (button)
	
	if (	AUCTIONATOR_ENABLE_ALT == 0
		or  not	AuctionFrame:IsShown()
		or	not	IsAltKeyDown())
	then
		return auctionator_orig_ContainerFrameItemButton_OnModifiedClick (button);
	end;

	if (not Auctionator_TabSelected()) then
	
		AuctionFrameTab_OnClick (nil, Auctionator_FindTab());
	
	end
	
	local bagID  = this:GetParent():GetID();
	local slotID = this:GetID();

	PickupContainerItem(bagID, slotID);

	local infoType = GetCursorInfo()

	if (infoType == "item") then
		ClickAuctionSellItemButton();
		ClearCursor();
	end

end


-----------------------------------------

function BeginAutoSell ()

	local maxStacks = math.floor (gAutoSell_TotalItems / gAutoSell_GoodStackSize);

	if (Auctionator_Batch_NumAuctions:GetNumber() > maxStacks) then
		Auctionator_Error_Text:SetText ("You can create at most "..maxStacks.." auctions");
		Auctionator_Error_Frame:Show ();
		return;
	end

	Auctionator_Batch_Frame:Hide();
	
--	chatmsg ("BeginAutoSell");
		
	gAutoSell_NumAuctionsToCreate = Auctionator_Batch_NumAuctions:GetNumber();

	auctionator_last_item_posted = gAutoSell_ItemName;
	auctionator_last_buyoutprice = gAutoSell_BuyoutPrice;
	auctionator_last_item_count  = gAutoSell_GoodStackSize;
	auctionator_last_itemlink	 = gAutoSell_ItemLink;

	local bagID, slotID, numslots;

	-- build a table of all the slots that contain the item
	
	cslots			= {};
	gEmptyBScached	= nil;
	
	for bagID = kFirstBag, kLastBag do
		numslots = GetContainerNumSlots (bagID);
		for slotID = 1,numslots do
			local itemLink = GetContainerItemLink(bagID, slotID);
			if (itemLink) then
				local itemName = GetItemInfo(itemLink);
				if (itemName == gAutoSell_ItemName) then
					local bs = {};
					bs.bagID  = bagID;
					bs.slotID = slotID;
					tinsert (cslots, bs);
				end
			end
		end
	end
	
	-- get it going (see the idle loop)
	
	gAutoSellState			= SETTLED
	gAutoSelling			= true;
	gAutoSell_AuctionNum	= 1;
end




-----------------------------------------

function Auctionator_AuctionFrameAuctions_Update()
	
	auctionator_orig_AuctionFrameAuctions_Update();

	if (Auctionator_TabSelected()  and	AuctionFrame:IsShown()) then
		Auctionator_HideElems (auctionsTabElements);
	end

	
end

-----------------------------------------
-- Intercept the Create Auction click so
-- that we can note the auction values
-----------------------------------------

function Auctionator_AuctionsCreateAuctionButton_OnClick()
	
	if (Auctionator_TabSelected() and AuctionFrame:IsShown()) then
		
		if (MoneyInputFrame_GetCopper(BuyoutPrice) == 0) then
			Auctionator_Confirm_Text:SetText ("Are you sure you want to create\nan auction with no buyout price?");
			Auctionator_Confirm_Frame:Show ();
			Auctionator_Confirm_Proc_Yes = Auctionator_CreateAuction_Click;
		else
			Auctionator_CreateAuction_Click()
		end

	else
		auctionator_orig_AuctionsCreateAuctionButton_OnClick();
	end
	

end

-----------------------------------------

function Auctionator_CreateAuction_Click()
	
	auctionator_last_buyoutprice = MoneyInputFrame_GetCopper(BuyoutPrice);
	auctionator_last_item_posted = gCurrentItemName;
	auctionator_last_item_count  = gCurrentStackSize;
	auctionator_last_itemlink	 = gCurrentItemLink;
	
	auctionator_orig_AuctionsCreateAuctionButton_OnClick();
end

-----------------------------------------

function Auctionator_LogMsg (itemlink, itemcount, price)

	local logmsg = "Auction created for "..itemlink;
	if (itemcount > 1) then
		logmsg = logmsg.."x"..itemcount;
	end
	
	logmsg = logmsg.."   "..priceToString(price);
	
	chatmsg (logmsg, .2, .8, .4);
		
end

-----------------------------------------

function Auctionator_OnAuctionOwnedUpdate ()

	if (gAutoSelling) then
		if (gAutoSellState == AUCTION_POST_PENDING) then
			gAutoSellState = SETTLED;
			gAutoSell_AuctionNum = gAutoSell_AuctionNum + 1;
		end
	end

	if (gAutoSelling) then
	
		Auctionator_Recommend_Text:SetText ("Auction #"..(gAutoSell_AuctionNum-1).." created for "..gAutoSell_ItemName);
		MoneyFrame_Update ("Auctionator_RecommendPerStack_Price", gAutoSell_BuyoutPrice);
		Auctionator_SetTextureButton ("Auctionator_RecommendItem_Tex", gAutoSell_GoodStackSize, gAutoSell_ItemLink);

		Auctionator_LogMsg (gAutoSell_ItemLink, gAutoSell_GoodStackSize, gAutoSell_BuyoutPrice);

		if (gAutoSell_AuctionNum-1 == gAutoSell_NumAuctionsToCreate) then
			Auctionator_AddHistoricalPrice (gAutoSell_ItemName, gAutoSell_BuyoutPrice / gAutoSell_GoodStackSize, gAutoSell_GoodStackSize, gAutoSell_ItemLink);
			gCachedSortedData[gAutoSell_ItemName] = nil;		-- invalidate the cache
		end

	elseif (auctionator_last_item_posted) then
	
		Auctionator_LogMsg (auctionator_last_itemlink, auctionator_last_item_count, auctionator_last_buyoutprice);
		
		Auctionator_Recommend_Text:SetText ("Auction created for "..auctionator_last_item_posted);
		MoneyFrame_Update ("Auctionator_RecommendPerStack_Price", auctionator_last_buyoutprice);
		Auctionator_SetTextureButton ("Auctionator_RecommendItem_Tex", auctionator_last_item_count, auctionator_last_itemlink);

		Auctionator_AddHistoricalPrice (auctionator_last_item_posted, auctionator_last_buyoutprice / auctionator_last_item_count, auctionator_last_item_count, auctionator_last_itemlink);

		gCachedSortedData[auctionator_last_item_posted] = nil;		-- invalidate the cache
		
		auctionator_last_item_posted = nil;
	else
		return;
	end


	Auctionator_ShowElems (recommendElements);

	AuctionatorMessageFrame:Hide();
	AuctionatorMessage2Frame:Hide();
	Auctionator_RecommendPerItem_Price:Hide();
	Auctionator_RecommendPerItem_Text:Hide();
	Auctionator_Recommend_Basis_Text:Hide();

	Auctionator_Col1_Heading:Hide();
	Auctionator_Col4_Heading:Hide();

end

-----------------------------------------

function Auctionator_OnNewAuctionUpdate()


end

-----------------------------------------

function Auctionator_SetupHookFunctions ()
	
	auctionator_orig_AuctionFrameTab_OnClick = AuctionFrameTab_OnClick;
	AuctionFrameTab_OnClick = Auctionator_AuctionFrameTab_OnClick;
	
	auctionator_orig_ContainerFrameItemButton_OnModifiedClick = ContainerFrameItemButton_OnModifiedClick;
	ContainerFrameItemButton_OnModifiedClick = Auctionator_ContainerFrameItemButton_OnModifiedClick;
	
	auctionator_orig_AuctionFrameAuctions_Update = AuctionFrameAuctions_Update;
	AuctionFrameAuctions_Update = Auctionator_AuctionFrameAuctions_Update;
	
	auctionator_orig_AuctionsCreateAuctionButton_OnClick = AuctionsCreateAuctionButton_OnClick;
	AuctionsCreateAuctionButton_OnClick = Auctionator_AuctionsCreateAuctionButton_OnClick;
	
end

-----------------------------------------

function Auctionator_AddSellPanel ()
	
	local frame = CreateFrame("FRAME", "Auctionator_Sell_Panel", AuctionFrame, "Auctionator_Sell_Template");
	frame:Hide();

--	PanelTemplates_SetNumTabs(frame, 2);
--	PanelTemplates_SetTab(frame, 1);
end

-----------------------------------------

function Auctionator_AddSellTab ()
	
	local n = AuctionFrame.numTabs+1;
	
	local framename = "AuctionFrameTab"..n;

	local frame = CreateFrame("Button", framename, AuctionFrame, "AuctionTabTemplate");

	frame:SetID(n);
	frame:SetText("Auctionator");
	frame.isAuctionator = true;
	
	frame:SetPoint("LEFT", getglobal("AuctionFrameTab"..n-1), "RIGHT", -8, 0);

	PanelTemplates_SetNumTabs (AuctionFrame, n);
	PanelTemplates_EnableTab  (AuctionFrame, n);
end

-----------------------------------------

function Auctionator_HideElems (tt)

	if (not tt) then
		return;
	end
	
	for i,x in ipairs(tt) do
		x:Hide();
	end
end

-----------------------------------------

function Auctionator_ShowElems (tt)

	for i,x in ipairs(tt) do
		x:Show();
	end
end

-----------------------------------------

function Auctionator_OnAuctionUpdate ()

	if (processing_state ~= KM_POSTQUERY) then
		return;
	end
	
	if (not Auctionator_TabSelected()) then
		return;
	end;
	
	processing_state = KM_ANALYZING;
	
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	
--	chatmsg("auctions:"..numBatchAuctions.." out of  "..totalAuctions)

	if (totalAuctions >= 50) then
		Auctionator_SetMessage ("Scanning auctions: page "..current_page);
	end
	
	if (numBatchAuctions > 0) then
	
		local x;
		
		for x = 1, numBatchAuctions do
		
			local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", x);

			if (name == gCurrentItemName or StringStartsWith (name, gSoftMatchItemName)) then
			
				local sd = {};
				
				sd["stackSize"]		= count;
				sd["buyoutPrice"]	= buyoutPrice;
				sd["owner"]			= owner;
				
				if (gSoftMatchItemName) then
					sd["suffix"]	= string.sub (name, strlen (gSoftMatchItemName) + 2);
				else
					sd["suffix"]	= "";
				end
				
				tinsert (scandata, sd);
				
			end
		end
	end


	if (numBatchAuctions == 50) then
				
		processing_state = KM_PREQUERY;	
		
	else		-- scan complete
	
--		chatmsg ("scan complete");
		
		processing_state = KM_NULL_STATE;

		Auctionator_Process_Historydata ();
		Auctionator_Process_Scandata ();
		Auctionator_SetupNewAuctionItem ();
		Auctionator_UpdateRecommendation();
		
	end
end

-----------------------------------------

function Auctionator_SetupNewAuctionItem ()

	Auctionator_FindBestHistoricalAuction();
	Auctionator_FindBestCurrentAuction();

	if (Auctionator_History_RB:GetChecked()) then
		Auctionator_ShowHistory();
	else
		Auctionator_ShowCurrentAuctions();
	end

end


-----------------------------------------

function Auctionator_SetMessage (msg)
	Auctionator_HideElems (recommendElements);
	Auctionator_HideElems (overallElements);

	if (gCurrentItemLink) then
		Auctionator_Recommend_Text:Show ();
		Auctionator_Recommend_Text:SetText (gCurrentItemName);
		Auctionator_RecommendItem_Tex:Show();
		Auctionator_SetTextureButton ("Auctionator_RecommendItem_Tex", 1);

		AuctionatorMessage2Frame:SetText (msg);
		AuctionatorMessage2Frame:Show();
		AuctionatorMessageFrame:Hide();
	else
		AuctionatorMessageFrame:SetText (msg);
		AuctionatorMessageFrame:Show();
		AuctionatorMessage2Frame:Hide();
	end
end


-----------------------------------------

function Auctionator_SortAuctionData (x, y)

	return x.itemPrice < y.itemPrice;
	
end


-----------------------------------------

function Auctionator_SortHistoryData (x, y)

	return x.when > y.when;

end

-----------------------------------------

function BuildHtag (type, y, m, d)

	local t = time({year=y, month=m, day=d, hour=0});

	return tostring (ToTightTime(t))..":"..type;
end

-----------------------------------------

function ParseHtag (tag)
	local when, type = strsplit(":", tag);
	
	if (type == nil) then
		type = "hx";
	end
	
	when = FromTightTime (tonumber (when));
	
	return when, type;
end

-----------------------------------------

function ParseHist (tag, hist)

	local when, type = ParseHtag(tag);
	
	local price, count	= strsplit(":", hist);
			
	price = tonumber (price);
	
	local stacksize, numauctions;

	if (type == "hx") then
		stacksize	= tonumber (count);
		numauctions	= 1;
	else
		stacksize = 0;
		numauctions	= tonumber (count);
	end
	
	return when, type, price, stacksize, numauctions;

end

-----------------------------------------

function CalcAbsTimes (when, whent)

	local absYear	= whent.year - 2000;
	local absMonth	= (absYear * 12) + whent.month;
	local absDay	= floor ((when - gTimeZero) / (60*60*24));
	
	return absYear, absMonth, absDay;
	
end

-----------------------------------------

function Auctionator_Condense_History (itemname)

	if (AUCTIONATOR_PRICING_HISTORY[itemname] == nil) then
		return;
	end

	local tempHistory = {};
	
	local now			= time();
	local nowt			= date("*t", now);

	local absNowYear, absNowMonth, absNowDay = CalcAbsTimes (now, nowt);
	
	local n = 1;
	local tag, hist, newtag, stacksize, numauctions;
	for tag, hist in pairs (AUCTIONATOR_PRICING_HISTORY[itemname]) do
		if (tag ~= "is") then
		
			local when, type, price, stacksize, numauctions = ParseHist (tag, hist);
			
			local whnt = date("*t", when);
			
			local absYear, absMonth, absDay	= CalcAbsTimes (when, whnt);
			
			if (absNowYear - absYear >= 3) then
				newtag = BuildHtag ("hy", whnt.year, 1, 1);
			elseif (absNowMonth - absMonth >= 2) then
				newtag = BuildHtag ("hm", whnt.year, whnt.month, 1);
			elseif (absNowDay - absDay >= 2) then
				newtag = BuildHtag ("hd", whnt.year, whnt.month, whnt.day);
			else
				newtag = tag;
			end
			
			tempHistory[n] = {};
			tempHistory[n].price		= price;
			tempHistory[n].numauctions	= numauctions;
			tempHistory[n].stacksize	= stacksize;
			tempHistory[n].when			= when;
			tempHistory[n].newtag		= newtag;
			n = n + 1;
		end
	end

	-- clear all the existing history
	
	local is = AUCTIONATOR_PRICING_HISTORY[itemname]["is"];
	
	AUCTIONATOR_PRICING_HISTORY[itemname] = {};
	AUCTIONATOR_PRICING_HISTORY[itemname]["is"] = is;
	
	-- repopulate the history
	
	local x;
	
	for x = 1,#tempHistory do
	
		local thist		= tempHistory[x];
		local newtag	= thist.newtag;
		
		if (AUCTIONATOR_PRICING_HISTORY[itemname][newtag] == nil) then
		
			local when, type = ParseHtag (newtag);

			local count = thist.numauctions;
			if (type == "hx") then
				count = thist.stacksize;
			end
			
			AUCTIONATOR_PRICING_HISTORY[itemname][newtag] = tostring(thist.price)..":"..tostring(count);
			
		else
		
			local hist = AUCTIONATOR_PRICING_HISTORY[itemname][newtag];
			
			local when, type, price, stacksize, numauctions = ParseHist (newtag, hist);

			local newNumAuctions = numauctions + thist.numauctions;
			local newPrice		 = ((price * numauctions) + (thist.price * thist.numauctions)) / newNumAuctions;
			
			AUCTIONATOR_PRICING_HISTORY[itemname][newtag] = tostring(newPrice)..":"..tostring(newNumAuctions);
		end
	end

end

-----------------------------------------

function Auctionator_Process_Historydata ()

	-- Condense the data if needed - only once per session for each item
	
	if (gCondensedThisSession[gCurrentItemName] == nil) then
	
		gCondensedThisSession[gCurrentItemName] = true;
	
		Auctionator_Condense_History(gCurrentItemName);
	end


	-- build the sorted history list

	gSortedHistory = {};

	if (AUCTIONATOR_PRICING_HISTORY[gCurrentItemName]) then
		local n = 1;
		local tag, hist;
		for tag, hist in pairs (AUCTIONATOR_PRICING_HISTORY[gCurrentItemName]) do
			if (tag ~= "is") then
				local when, type, price, stacksize, numauctions = ParseHist (tag, hist);
				
				gSortedHistory[n] = {};
				gSortedHistory[n].itemPrice		= price;
				gSortedHistory[n].buyoutPrice	= price;
				gSortedHistory[n].stackSize		= stacksize;
				gSortedHistory[n].when			= when;
				gSortedHistory[n].yours			= true;
				gSortedHistory[n].type			= type;
				
				if (stacksize == 0) then
					gSortedHistory[n].stackSize = numauctions;
				end
				
				n = n + 1;
			end
		end
	end

	table.sort (gSortedHistory, Auctionator_SortHistoryData);

	Auctionator_SetRBcolor ("Auctionator_History_RBText", #gSortedHistory);

end

-----------------------------------------

function Auctionator_Process_Scandata ()

	gSortedData = {};
 
	----- Condense the scan data into a table that has only a single entry per stacksize/price combo

	local i,sd;
	local conddata = {};
	local isEmpty  = true;
	
	gSortedData.hasStack				= false;
	gSortedData.when					= time();
	gSortedData.itemname				= gCurrentItemName;
	gSortedData.bestPrices				= {};
	gSortedData.absoluteBest			= nil;				-- the overall cheapest auction
	gSortedData.numMatches				= 0;
	gSortedData.numMatchesWithBuyout	= 0;

	for i,sd in ipairs (scandata) do
	
		local ownercode = "x";
		
		if (sd.owner == UnitName("player")) then
			ownercode = "y";
		end
		
		local key = "_"..sd.stackSize.."_"..sd.buyoutPrice.."_"..ownercode.."_"..sd.suffix;
		
		if (conddata[key] and gSoftMatchItemName == nil) then
			conddata[key].count = conddata[key].count + 1;
		else
			local data = {};
			
			data.stackSize 		= sd.stackSize;
			data.buyoutPrice	= sd.buyoutPrice;
			data.itemPrice		= sd.buyoutPrice / sd.stackSize;
			data.suffix			= sd.suffix;
			data.count			= 1;
			data.type			= "n";		-- normal
			data.yours			= (sd.owner == UnitName("player"));
			
			conddata[key] = data;
			
			isEmpty = false;
			if (sd.stackSize > 1) then
				gSortedData.hasStack = true;
			end
		end

	end

	----- create a table of these entries

	local n = 1;

	local i, v;
	
	for i,v in pairs (conddata) do
		gSortedData[n] = v;
		n = n + 1;
	end

	----- add in the most recent 3 historical prices
	
--[[
	local k;
	
	for k = 1, 3 do
		if (k <= #gSortedHistory) then
			gSortedData[n+k-1] = gSortedHistory[k];
		end
	end
]]--

	-- sort the table by itemPrice
	
	table.sort (gSortedData, Auctionator_SortAuctionData);

	-- analyze and store some info about the data

	gSortedData.absoluteBest			= nil;				
	gSortedData.bestPrices				= {};		-- a table with one entry per stacksize that is the cheapest auction for that particular stacksize
	gSortedData.numMatches				= 0;
	gSortedData.numMatchesWithBuyout	= 0;
	
	local j, sd;
	
	----- find the best price per stacksize and overall -----
	
	for j,sd in ipairs(gSortedData) do
	
		if (sd.type == "n") then
		
			if (gSoftMatchItemName == nil or gCurrentItemName == gSoftMatchItemName.." "..sd.suffix) then
		
				gSortedData.numMatches = gSortedData.numMatches + 1;

				if (sd.itemPrice > 0) then

					gSortedData.numMatchesWithBuyout = gSortedData.numMatchesWithBuyout + 1;

					if (gSortedData.bestPrices[sd.stackSize] == nil or gSortedData.bestPrices[sd.stackSize].itemPrice >= sd.itemPrice) then
						gSortedData.bestPrices[sd.stackSize] = sd;
					end
				
					if (gSortedData.absoluteBest == nil or gSortedData.absoluteBest.itemPrice > sd.itemPrice) then
						gSortedData.absoluteBest = sd;
					end
				end
				
			end
		end
	end
	
	-- set the color of the radio button

	Auctionator_SetRBcolor ("Auctionator_CurrentAuctions_RBText", #gSortedData);
	
	-- save it all in the cache

	gCachedSortedData[gCurrentItemName] = gSortedData;
end

-----------------------------------------

function Auctionator_SetRBcolor (rbname, count)
	
	local text = getglobal(rbname);
	
	if (count == 0) then
		text:SetTextColor(0.7, 0.7, 0.3);
	else
		text:SetTextColor(1, 1, 0);
	end
end

-----------------------------------------

function Auctionator_ShowingCurrentAuctions ()
	return not Auctionator_History_RB:GetChecked();
end

-----------------------------------------

function Auctionator_UpdateRecommendation ()

	local basedata;

	if (Auctionator_ShowingCurrentAuctions()) then

		if (not gBaseDataIndex) then
			if (gSortedData.numMatches == 0 and #gSortedData == 0) then
				Auctionator_SetMessage ("No current auctions found");
			elseif (gSortedData.numMatches == 0) then
				Auctionator_SetMessage ("No current auctions found\n\n(related auctions shown)");
			elseif (gSortedData.numMatchesWithBuyout == 0) then
				Auctionator_SetMessage ("No current auctions with buyouts found");
			else
				Auctionator_SetMessage ("");
			end
			return;
		end
		
		basedata = gSortedData[gBaseDataIndex];
	else
		if (not gBaseHistoryIndex) then
			Auctionator_SetMessage ("Auctionator has yet to record any auctions for this item");
			return;
		end

		basedata = gSortedHistory[gBaseHistoryIndex];
	end

	if (not Auctionator_IsModeCreateAuction()) then
		Auctionator_HideElems (recommendElements);
		AuctionatorMessageFrame:Hide();
		AuctionatorMessage2Frame:Hide();
		
		Auctionator_Recommend_Text:Show ();
		Auctionator_Recommend_Text:SetText (gCurrentItemName);
		Auctionator_RecommendItem_Tex:Show();
		
		Auctionator_SetTextureButton ("Auctionator_RecommendItem_Tex", 1);
		return;
	end

	
	local newBuyoutPrice = math.floor (basedata.itemPrice * gCurrentStackSize);

	if (not basedata.yours) then
		newBuyoutPrice = calcNewPrice (newBuyoutPrice);
	end
	
	local discount = 1.00 - (AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT / 100);
	
	local newStartPrice = calcNewPrice(math.floor(newBuyoutPrice * discount)); 
	
	Auctionator_ShowElems (recommendElements);
	AuctionatorMessageFrame:Hide();
	AuctionatorMessage2Frame:Hide();
	
	Auctionator_Recommend_Text:SetText ("Recommended Buyout Price");
	Auctionator_RecommendPerStack_Text:SetText ("for your stack of "..gCurrentStackSize);
	
	Auctionator_SetTextureButton ("Auctionator_RecommendItem_Tex", gCurrentStackSize);
	

	MoneyFrame_Update ("Auctionator_RecommendPerItem_Price",  round(newBuyoutPrice / gCurrentStackSize));
	MoneyFrame_Update ("Auctionator_RecommendPerStack_Price", round(newBuyoutPrice));
	
	MoneyInputFrame_SetCopper (BuyoutPrice, newBuyoutPrice);
	MoneyInputFrame_SetCopper (StartPrice,  newStartPrice);

	local cheapestStack = gSortedData.bestPrices[gCurrentStackSize];
	
	if (gSortedData.absoluteBest and basedata.stackSize == gSortedData.absoluteBest.stackSize and basedata.buyoutPrice == gSortedData.absoluteBest.buyoutPrice) then
		Auctionator_Recommend_Basis_Text:SetText ("(based on cheapest current auction)");
	elseif (cheapestStack and basedata.stackSize == cheapestStack.stackSize and basedata.buyoutPrice == cheapestStack.buyoutPrice) then
		Auctionator_Recommend_Basis_Text:SetText ("(based on cheapest stack of the same size)");
	else
		Auctionator_Recommend_Basis_Text:SetText ("(based on selected auction)");
	end
	
	Auctionator_CheckForMultiples();

end

-----------------------------------------

function Auctionator_CheckForMultiples ()

	if (Auctionator_Find_More (gCurrentItemName, gCurrentStackSize)) then
		Auctionator_BatchButton:Enable();
	else
		Auctionator_BatchButton:Disable();
	end

end

-----------------------------------------

function Auctionator_Find_More (pItemName, pItemCount)

	local bagID, slotID, numslots;
	local foundSoFar = 0;

	for bagID = kFirstBag, kLastBag do
		numslots = GetContainerNumSlots (bagID);
		for slotID = 1,numslots do
			local itemLink = GetContainerItemLink(bagID, slotID);
			if (itemLink) then
				local itemName				= GetItemInfo(itemLink);
				local texture, itemCount	= GetContainerItemInfo(bagID, slotID);
				
				if (itemName == pItemName) then
					foundSoFar = foundSoFar + itemCount;
					if (foundSoFar >= pItemCount * 2) then
						return true;
					end
				end
			end
		end
	end

	return false;

end

-----------------------------------------

function Auctionator_SetTextureButton(elementName, count, itemlink)

	if (not itemlink) then
		itemlink = gCurrentItemLink;
	end
	
	texture = GetItemIcon (itemlink);
	
	local textureElement = getglobal (elementName);
	local countElement   = getglobal (elementName.."Count");

	if (texture) then
		textureElement:SetNormalTexture (texture);
		if (count > 1) then
			countElement:SetText (count);
			countElement:Show();
		else
			countElement:Hide();
		end
	else
		textureElement:Hide();
	end

end

-----------------------------------------

function Auctionator_SetRecTooltip ()
	if (gCurrentItemLink) then
		GameTooltip:SetHyperlink (gCurrentItemLink);
	elseif (auctionator_last_itemlink) then
		GameTooltip:SetHyperlink (auctionator_last_itemlink);
	end
end

-----------------------------------------

function Auctionator_OnAuctionHouseShow()

	gOpenAllBags = AUCTIONATOR_OPEN_ALL_BAGS;

	if (AUCTIONATOR_OPEN_FIRST ~= 0) then
		AuctionFrameTab_OnClick (nil, Auctionator_FindTab());
	end

	gCurrentItemName = "";
	Auctionator_SetMessage ("Drag an item to the Auction Item area\n\nto see recommended pricing information");

end

-----------------------------------------

function Auctionator_OnAuctionHouseClosed()

	Auctionator_HideAllDialogs();
	gAutoSelling = false;
end

-----------------------------------------

function Auctionator_HideAllDialogs()

	AuctionatorOptionsFrame:Hide();
	AuctionatorDescriptionFrame:Hide();
	AuctionatorUndercuttingConfig:Hide();
	AuctionatorBasicOptionsFrame:Hide();
	Auctionator_Batch_Frame:Hide();
	Auctionator_Error_Frame:Hide();
	Auctionator_Mask:Hide();
	
end



-----------------------------------------

function Auctionator_BasicOptionsUpdate(self, elapsed)

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (self.TimeSinceLastUpdate > 0.25) then
	
		self.TimeSinceLastUpdate = 0;

		if (AuctionatorOption_Def_Duration_CB:GetChecked()) then
			AuctionatorOption_Durations:Show();
		else
			AuctionatorOption_Durations:Hide();
		end
		
	end
end

-----------------------------------------

function Auctionator_OnUpdate(self, elapsed)

	if (Auctionator_TabSelected()) then
		Auctionator_Idle (self, elapsed);
	end

end


-----------------------------------------

function Auctionator_Idle(self, elapsed)

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	
	if (AuctionatorMessageFrame == nil) then
		return;
	end
	
	if (self.TimeSinceLastUpdate > 0.25) then
	
		self.TimeSinceLastUpdate = 0;

		if (gHentryTryAgain) then
			Auctionator_HEntryOnClick();
			return;
		end
	
		Auctionator_Idle_CheckNewIfQueryNeeded (self); 	------- check whether to send a new auction query to get the next page -------

		if (gAutoSelling) then
			Auctionator_Idle_AutoSelling (self);
		end

	end

	Auctionator_Idle_CheckForNewAuctionItem (self);		------- check whether the "sell" item has changed -------
end
	
---------------------------------------------------------

function Auctionator_Idle_CheckNewIfQueryNeeded (self)

	if (processing_state == KM_PREQUERY) then
		if (CanSendAuctionQuery()) then
			processing_state = KM_IN_QUERY;

			if (gSoftMatchItemName) then
				QueryAuctionItems (gSoftMatchItemName, "", "", nil, gCurrentItemClass, gCurrentItemSubclass, current_page, nil, nil);
			else
				QueryAuctionItems (gCurrentItemName, "", "", nil, gCurrentItemClass, gCurrentItemSubclass, current_page, nil, nil);
			end
			
			processing_state = KM_POSTQUERY;
			current_page = current_page + 1;
		end
	end
end

---------------------------------------------------------

local gPrevAuctionItemName	= "";
local gPrevAuctionCount		= 0;
local gPrevAuctionItemLink	= nil;

---------------------------------------------------------

function Auctionator_Idle_CheckForNewAuctionItem (self)

	local auctionItemName, auctionCount, auctionLink = Auctionator_GetSellItemInfo(); 

	if (gPrevAuctionItemLink ~= auctionLink or gPrevAuctionCount ~= auctionCount) then

		UIDropDownMenu_SetSelectedValue(Auctionator_DropDown1, MODE_CREATE_AUCTION);
		UIDropDownMenu_SetText (Auctionator_DropDown1, kDropdown1_text[MODE_CREATE_AUCTION]);	-- needed to fix bug in UIDropDownMenu

		Auctionator_HideShowElements();
		Auctionator_BuildCreateAuctionPriceList (auctionItemName, auctionCount, auctionLink);
		
		Auctionator_HideShowRBs ();
	end
end

---------------------------------------------------------

function Auctionator_BuildCreateAuctionPriceList (auctionItemName, auctionCount, auctionLink, cacheThreshold)
	gPrevAuctionItemLink = auctionLink;
	gPrevAuctionCount	 = auctionCount;
	
	Auctionator_CurrentAuctions_RB:SetChecked();
	Auctionator_History_RB:SetChecked(nil);
	
	Auctionator_BuildPriceLists (auctionItemName, auctionCount, auctionLink, cacheThreshold);
end

---------------------------------------------------------

function Auctionator_BuildPriceLists (auctionItemName, auctionCount, auctionLink, cacheThreshold)

	if (auctionItemName == nil) then
		auctionItemName = "";
		auctionCount	= 0;
	end

	if (cacheThreshold == nil) then
		cacheThreshold = 20;		-- 20 seconds default
	end

--chatmsg ("Auctionator_BuildPriceLists  gCurrentItemName: "..gCurrentItemName.."   auctionItemName: "..auctionItemName);

	if (gCurrentItemName ~= auctionItemName or gCurrentStackSize ~= auctionCount or gForceMsgAreaUpdate) then

		gForceMsgAreaUpdate = false;
		
		gSortedData = {};
		
		gCurrentItemName = "";
		Auctionator_RedisplayAuctions();

		gCurrentItemName	= auctionItemName;
		gCurrentStackSize	= auctionCount;
		gCurrentItemLink	= nil;
		
		Auctionator_RecommendPerItem_Price:Hide();
		Auctionator_RecommendPerStack_Price:Hide();
		Auctionator_BatchButton:Disable();
		
--		chatmsg ("Building Price List");
		
		processing_state = KM_NULL_STATE;
		
		gBaseDataIndex = nil;
		
		if (gCurrentItemName == "") then
		
			if (auctionator_last_item_posted == nil) then
				Auctionator_SetMessage ("Drag an item to the Auction Item area\n\nto see recommended pricing information");
			end
			
		else
			Auctionator_SetMessage ("");

			if (AUCTIONATOR_DEF_DURATION == "S") then AuctionsRadioButton_OnClick(1); end;
			if (AUCTIONATOR_DEF_DURATION == "M") then AuctionsRadioButton_OnClick(2); end;
			if (AUCTIONATOR_DEF_DURATION == "L") then AuctionsRadioButton_OnClick(3); end;
			
			gCurrentItemLink = auctionLink;
			
			local a, b, c, d, e, sType, sSubType = GetItemInfo(gCurrentItemLink);

			gSoftMatchItemName = nil;

			gCurrentItemClass		= 0;
			gCurrentItemSubclass	= 0;
				
			if (gCurrentItemLink) then

				local printable = gsub(gCurrentItemLink, "\124", "\124\124");

				gCurrentItemClass		= ItemType2AuctionClass (sType);
				gCurrentItemSubclass	= SubType2AuctionSubclass (gCurrentItemClass, sSubType);

				if (gCurrentItemClass == AUCTION_CLASS_WEAPON or gCurrentItemClass == AUCTION_CLASS_ARMOR) then
					local z = string.find (string.lower(auctionItemName), " of ", 1, true);
					if (z ~= nil) then
						gSoftMatchItemName = string.sub (auctionItemName, 1, z-1);
						if (not StringContains (gSoftMatchItemName, " ")) then
							gSoftMatchItemName = nil;
						end
					end
				end
			end
			
			local cacheHit = false;
			
			if (gCachedSortedData[gCurrentItemName] ~= nil) then		-- see if we can use the cache
			
				if (time() - gCachedSortedData[gCurrentItemName].when > cacheThreshold) then
					gCachedSortedData[gCurrentItemName] = nil;
				else
-- chatmsg ("cacheHit: "..time() - gCachedSortedData[gCurrentItemName].when.." seconds");
					cacheHit = true;
					
					gSortedData = gCachedSortedData[gCurrentItemName];
				
					Auctionator_Process_Historydata ();
					Auctionator_SetupNewAuctionItem();
					Auctionator_UpdateRecommendation();
					
					Auctionator_SetRBcolor ("Auctionator_CurrentAuctions_RBText", #gSortedData);
				end
			end

			if (not cacheHit) then	-- if not found in cache, kick off a scan
			
-- chatmsg ("starting scan");
				
				SortAuctionItems("list", "buyout");

				if (IsAuctionSortReversed("list", "buyout")) then
					SortAuctionItems("list", "buyout");
				end
			 
				current_page = 0;
				processing_state = KM_PREQUERY;

				scandata = {};
				scandata["exactMatches"] = 0;
			end
		end

	end

end


-----------------------------------------

function BS_GetCount(bs)

	local texture, count = GetContainerItemInfo (bs.bagID, bs.slotID);
	if (texture ~= nil) then
		return count;
	end
	
	return 0;
		
end

-----------------------------------------

function BS_InCslots(xbs)

	local i, bs;
	
	for i,bs in pairs(cslots) do
		if (xbs.bagID == bs.bagID and xbs.slotID == bs.slotID) then
			return true;
		end
	end

	return false;
	
end

-----------------------------------------

function BS_GetEmptySlot()


	if (gEmptyBScached == nil or BS_GetCount (gEmptyBScached) ~= 0) then
	
		gEmptyBScached = nil;
		
		for bagID = kFirstBag, kLastBag do
			numslots = GetContainerNumSlots (bagID);
			for slotID = 1,numslots do
				local itemLink = GetContainerItemLink(bagID, slotID);
				if (itemLink == nil) then
					gEmptyBScached = {};
					gEmptyBScached.bagID  = bagID;
					gEmptyBScached.slotID = slotID;
					
					-- add to cslots if not already there
					
					if (not BS_InCslots (gEmptyBScached)) then
--						chatmsg ("Inserting "..bagID.."/"..slotID);
						tinsert (cslots, gEmptyBScached);
					end
					
					return gEmptyBScached;
				end
			end
		end
	end
	
	return gEmptyBScached;
end



-----------------------------------------

function BS_PostAuction(bs)

	PickupContainerItem (bs.bagID, bs.slotID);

	local infoType = GetCursorInfo()

	if (infoType == "item") then
		ClickAuctionSellItemButton();
		ClearCursor();
	end
	
	StartAuction (gAutoSell_StartPrice, gAutoSell_BuyoutPrice, gAutoSell_Hours * 60);
		
end

-----------------------------------------

function BS_FindGoodStack()

	local dstr = "";
	local i;
	
	for i, bs in pairs (cslots) do
	
		dstr = dstr..BS_GetCount (bs).." ";
		
		if (BS_GetCount (bs) == gAutoSell_GoodStackSize) then
--			chatmsg ("FindGood: "..dstr);
			return bs
		end
	
	end
	
--	chatmsg ("FindGoodx: "..dstr);
	
	return nil;
	
end

-----------------------------------------

function BS_MergeSmallStacks()			-- find the 2 smallest stacks and merge them together if possible

	if (#cslots < 2) then
		return false;
	end
	
	local i, bs;
	
	local zbs	= nil;		-- smallest
	local ybs	= nil;		-- second smallest
	
	local zcount = 10000;
	local ycount = 10000;
	
	for i, bs in pairs (cslots) do
		local count = BS_GetCount (bs);
	
		if (count > 0) then
			if (count < zcount) then
				ybs = zbs;	ycount = zcount;
				zbs = bs;	zcount = count;
			elseif (count < ycount) then
				ybs = bs;	ycount = count;
			end
		end
	end
	
	if (zcount == 10000 or ycount == 10000) then
		return false;
	end
		
	-- try to make a "good" stack

	if (zcount < gAutoSell_GoodStackSize and ycount + zcount >= gAutoSell_GoodStackSize) then
		SplitContainerItem  (ybs.bagID, ybs.slotID, gAutoSell_GoodStackSize - zcount);
		PickupContainerItem (zbs.bagID, zbs.slotID);
	
		gAutoSell_targetBS		= zbs;
		gAutoSell_targetCount	= gAutoSell_GoodStackSize;
		
		return true;
	
	end
			
	-- merge them best as possible
	
	local numToMove = zcount;
	if (zcount + ycount > gAutoSell_FullStackSize) then
		numToMove = gAutoSell_FullStackSize - ycount;
	end
	
	if (numToMove > 0) then
		SplitContainerItem  (zbs.bagID, zbs.slotID, numToMove);
		PickupContainerItem (ybs.bagID, ybs.slotID);

		gAutoSell_targetBS		= ybs;
		gAutoSell_targetCount	= ycount + numToMove;

		return true;
	end
	
	return false;
	
end


-----------------------------------------

function BS_SplitLargeStack()

	local i, bs;
	
	local emptyBS = BS_GetEmptySlot ();

	for i, bs in pairs (cslots) do
		local count = BS_GetCount (bs);
	
		if (count > gAutoSell_GoodStackSize) then
			if (emptyBS) then
				SplitContainerItem  (bs.bagID, bs.slotID, gAutoSell_GoodStackSize);
				PickupContainerItem (emptyBS.bagID, emptyBS.slotID);

				gAutoSell_targetBS		= emptyBS;
				gAutoSell_targetCount	= gAutoSell_GoodStackSize;
				return true;
			end
		end
	
	end
			
	return false;

end

-----------------------------------------

function Auctionator_Idle_AutoSelling()

	if (CursorHasItem()) then
		return;
	end
	
	if (gAutoSellState == AUCTION_POST_PENDING) then
		return;
	end
	
	if (gAutoSellState == STACK_MERGE_PENDING or gAutoSellState == STACK_SPLIT_PENDING) then
		
		if (BS_GetCount (gAutoSell_targetBS) == gAutoSell_targetCount) then
			ClearCursor();
			gAutoSellState = SETTLED;
		else
			return;
		end
	end

	if (gAutoSellState ~= SETTLED) then
		return
	end
	
	-- let's see if we're done
	
	if (gAutoSell_AuctionNum > gAutoSell_NumAuctionsToCreate) then
		gAutoSelling = false;
		return;
	end
	
	
	-- if there's a stack that's ready to sell, sell it
	
	local goodBS = BS_FindGoodStack();
	
	if (goodBS) then
		BS_PostAuction (goodBS);
		gAutoSellState = AUCTION_POST_PENDING;
		return;
	end
		
	-- see if we can split a larger stack to get a sellable stack
	
	local success = BS_SplitLargeStack();
	if (success) then
		gAutoSellState = STACK_SPLIT_PENDING;
		return;
	end
	
	-- see if we can merge two smaller stacks
	
	local success = BS_MergeSmallStacks();
	if (success) then
		gAutoSellState = STACK_MERGE_PENDING;
		return;
	end

	
	-- nothing left to do - we're done
	
	gAutoSelling = false;

end

-----------------------------------------

function Auctionator_RedisplayHlist ()

	gHistoryItemList	= {};
	local n		= 1;
	
	for name,hist in pairs (AUCTIONATOR_PRICING_HISTORY) do
		gHistoryItemList[n] = name;
		n = n + 1;
	end

	table.sort (gHistoryItemList);
	
	local numrows = #gHistoryItemList;
	
	local line;							-- 1 through NN of our window to scroll
	local dataOffset;					-- an index into our data calculated from the scroll offset
	
	FauxScrollFrame_Update (Auctionator_Hlist_ScrollFrame, numrows, ITEM_HIST_NUM_LINES, 16);

	for line = 1,ITEM_HIST_NUM_LINES do

		dataOffset = line + FauxScrollFrame_GetOffset (Auctionator_Hlist_ScrollFrame);

		local lineEntry = getglobal ("AuctionatorHEntry"..line);
		
		lineEntry:SetID(dataOffset);
		
		if (dataOffset <= numrows and gHistoryItemList[dataOffset]) then
			
			local lineEntry_text = getglobal("AuctionatorHEntry"..line.."_EntryText");

			lineEntry_text:SetText	(gHistoryItemList[dataOffset]);

			if (gHistoryItemList[dataOffset] == gCurrentItemName) then
				lineEntry:SetButtonState ("PUSHED", true);
			else
				lineEntry:SetButtonState ("NORMAL", false);
			end

			lineEntry:Show();
		else
			lineEntry:Hide();
		end
	end

end


-----------------------------------------

function Auctionator_HEntryOnClick()
	
	local line = this;
	
	if (gHentryTryAgain) then
		line = gHentryTryAgain;
		gHentryTryAgain = nil;
	end
	
	local entryIndex = line:GetID();

	local itemName	 = gHistoryItemList[entryIndex];
	
	local itemId, suffixId, uniqueId = strsplit(":", AUCTIONATOR_PRICING_HISTORY[itemName]["is"])

	local itemId	= tonumber(itemId);

	if (suffixId == nil) then	suffixId = 0;
	else		 				suffixId = tonumber(suffixId);	
	end
	
	if (uniqueId == nil) then	uniqueId = 0;
	else		 				uniqueId = tonumber(suffixId);	
	end
	
	local itemString = "item:"..itemId..":0:0:0:0:0:"..suffixId..":"..uniqueId;

	local _, itemLink, _, _, _, _, _, _ = GetItemInfo(itemString);
	
	if (itemLink == nil) then		-- pull it into the cache and go back to the idle loop to wait for it to appear
		MyScanningTooltip:SetHyperlink(itemString);
		gHentryTryAgain = line;
--		chatmsg ("pulling "..itemName.." into the local cache");
		return;
	end

	if (Auctionator_History_RB:GetChecked()) then
		gCurrentItemName = itemName;
		gCurrentItemLink = itemLink;
		Auctionator_Process_Historydata ();
		Auctionator_ShowHistory ();
		Auctionator_UpdateRecommendation();
	else
		Auctionator_BuildPriceLists (itemName, 0, itemLink, 120);
	end
	
	Auctionator_RedisplayHlist();	 -- for the highlight
	
	PlaySound ("igMainMenuOptionCheckBoxOn");
end

-----------------------------------------

function Auctionator_ShowWhichRB (id)

	if (processing_state ~= KM_NULL_STATE) then		-- if we're scanning auctions don't respond
		return;
	end

	PlaySound("igMainMenuOptionCheckBoxOn");

	if (id == 1) then
		if (gSortedData == nil or gSortedData.itemname ~= gCurrentItemName) then
			gForceMsgAreaUpdate = true;		-- hack
			Auctionator_BuildPriceLists (gCurrentItemName, 0, gCurrentItemLink, 120);
		end
		Auctionator_ShowCurrentAuctions ();
	else
		Auctionator_ShowHistory ();
	end

	Auctionator_UpdateRecommendation();

end


-----------------------------------------

function Auctionator_RedisplayAuctions ()
	if (Auctionator_ShowingCurrentAuctions()) then
		Auctionator_ShowCurrentAuctions();
	else
		Auctionator_ShowHistory();
	end
end

-----------------------------------------

function Auctionator_BuildHistItemText(data)

	local stacktext = "";
--	if (data.stackSize > 1) then
--		stacktext = " (stack of "..data.stackSize..")";
--	end
	
	local now		= time();
	local nowtime	= date ("*t");

	local when		= data.when;
	local whentime	= date ("*t", when);
	
	local numauctions = data.stackSize;

	local datestr = "";
	
	if (data.type == "hy") then
		return "average of your auctions for "..whentime.year;
	elseif (data.type == "hm") then
		if (nowtime.year == whentime.year) then
			return "average of your auctions for "..date("%B", when);
		else
			return "average of your auctions for "..date("%B %Y", when);
		end
	elseif (data.type == "hd") then
		return "average of your auctions for "..monthDay(whentime);
	else
		return "your auction on "..monthDay(whentime)..date(" at %I:%M %p", when);
	end
end			

-----------------------------------------

function monthDay (when)

	local t = time(when);
	
	local s = date("%b ", t);
	
	return s..when.day;

end

-----------------------------------------

function Auctionator_ShowCurrentAuctions()

	Auctionator_CurrentAuctions_RB:SetChecked();
	Auctionator_History_RB:SetChecked(nil);

	Auctionator_Col1_Heading:Hide();
	Auctionator_Col3_Heading:Hide();
	Auctionator_Col4_Heading:Hide();

	local numrows = #gSortedData;

	if (numrows > 0) then
		Auctionator_Col1_Heading:Show();
		Auctionator_Col3_Heading:Show();
		Auctionator_Col4_Heading:Show();
	end

	Auctionator_Col3_Heading:SetText ("Current Auctions");

	if (gSortedData.hasStack) then
		Auctionator_Col4_Heading:SetText ("Total Price");
	else
		Auctionator_Col4_Heading:SetText ("");
	end

--	local includeSomeHistory = Auctionator_IsModeCreateAuction();
	local includeSomeHistory = false;

	local line		 = 0;															-- 1 through 12 of our window to scroll
	local dataOffset = FauxScrollFrame_GetOffset (AuctionatorScrollFrame);			-- an index into our data calculated from the scroll offset
	
	FauxScrollFrame_Update (AuctionatorScrollFrame, numrows, 12, 16);

	while (line < 12) do

		dataOffset	= dataOffset + 1;
		line		= line + 1;
		
		local lineEntry = getglobal ("AuctionatorEntry"..line);
		
		lineEntry:SetID(dataOffset);
		
		if (dataOffset > numrows or not gSortedData[dataOffset]) then
		
			lineEntry:Hide();
			
		else
			local data = gSortedData[dataOffset];

			local lineEntry_item_tag = "AuctionatorEntry"..line.."_PerItem_Price";
			
			local lineEntry_item		= getglobal(lineEntry_item_tag);
			local lineEntry_itemtext	= getglobal("AuctionatorEntry"..line.."_PerItem_Text");
			local lineEntry_text		= getglobal("AuctionatorEntry"..line.."_EntryText");
			local lineEntry_stack		= getglobal("AuctionatorEntry"..line.."_StackPrice");

			lineEntry_itemtext:SetText	("");
			lineEntry_text:SetText	("");
			lineEntry_stack:SetText	("");
			
			local entrytext = "";
			
			if (data.type == "hx" and not includeSomeHistory) then
				line = line - 1;
			end
			
			if (data.type == "hx" and includeSomeHistory) then
				lineEntry_item:Show ();
				lineEntry_text:SetText (Auctionator_BuildHistItemText (data));
				lineEntry_text:SetTextColor (0.8, 0.8, 1.0);
				MoneyFrame_Update (lineEntry_item_tag, round(data.itemPrice) );
				
				lineEntry:Show();
			end
			
			if (data.type == "n") then
			
				lineEntry:Show();

				if (gSoftMatchItemName) then
				
					entrytext = gSoftMatchItemName.." "..data.suffix;
					
					if ( entrytext == gCurrentItemName ) then	lineEntry_text:SetTextColor (1.0, 1.0, 1.0);
					else										lineEntry_text:SetTextColor (0.5, 0.5, 0.5);
					end
				else
					entrytext = string.format ("%i %s of %i", data.count, pluralizeIf ("stack", data.count), data.stackSize);

					if ( data.stackSize == gCurrentStackSize or gCurrentStackSize == 0) then	lineEntry_text:SetTextColor (1.0, 1.0, 1.0);
					else																		lineEntry_text:SetTextColor (0.6, 0.6, 0.6);
					end;
				end

				if (data.yours) then
					 entrytext = entrytext.." (yours)";
				end

				lineEntry_text:SetText (entrytext);
			
				if (data.buyoutPrice == 0) then
					lineEntry_item:Hide();
					lineEntry_itemtext:Show();
					lineEntry_itemtext:SetText ("no buyout price");
				else
					lineEntry_item:Show();
					lineEntry_itemtext:Hide();
					MoneyFrame_Update (lineEntry_item_tag, round(data.buyoutPrice/data.stackSize) );
					if (gSoftMatchItemName == nil and data.stackSize > 1) then
						lineEntry_stack:SetText (priceToString(data.buyoutPrice));
						lineEntry_stack:SetTextColor (0.6, 0.6, 0.6);
					end
				end
			end
		end
	end

	Auctionator_HighlightEntry (gBaseDataIndex);		-- need this for when called from onVerticalScroll
end

-----------------------------------------

function Auctionator_ShowHistory ()

	Auctionator_History_RB:SetChecked();
	Auctionator_CurrentAuctions_RB:SetChecked(nil);

	Auctionator_Col1_Heading:Hide();
	Auctionator_Col3_Heading:Hide();
	Auctionator_Col4_Heading:Hide();

	Auctionator_Col3_Heading:SetText ("History");

	
	local numrows = #gSortedHistory;
	
	if (numrows > 0) then
		Auctionator_Col1_Heading:Show();
		Auctionator_Col3_Heading:Show();
	end
	
	local line;							-- 1 through 12 of our window to scroll
	local dataOffset;					-- an index into our data calculated from the scroll offset
	
	FauxScrollFrame_Update (AuctionatorScrollFrame, numrows, 12, 16);

	for line = 1,12 do

		dataOffset = line + FauxScrollFrame_GetOffset (AuctionatorScrollFrame);
		
		local lineEntry = getglobal ("AuctionatorEntry"..line);
		
		lineEntry:SetID(dataOffset);
		
		if (dataOffset <= numrows and gSortedHistory[dataOffset]) then
			
			local data = gSortedHistory[dataOffset];

			local lineEntry_item_tag = "AuctionatorEntry"..line.."_PerItem_Price";

			local lineEntry_item		= getglobal(lineEntry_item_tag);
			local lineEntry_itemtext	= getglobal("AuctionatorEntry"..line.."_PerItem_Text");
			local lineEntry_text		= getglobal("AuctionatorEntry"..line.."_EntryText");
			local lineEntry_stack		= getglobal("AuctionatorEntry"..line.."_StackPrice");

			lineEntry_item:Show();
			lineEntry_itemtext:Hide();
			lineEntry_stack:SetText	("");

			MoneyFrame_Update (lineEntry_item_tag, round(data.itemPrice) );
			
			lineEntry_text:SetText (Auctionator_BuildHistItemText (data));
			lineEntry_text:SetTextColor (0.8, 0.8, 1.0);
				
			lineEntry:Show();
		else
			lineEntry:Hide();
		end
	end

	Auctionator_HighlightEntry (gBaseHistoryIndex);		-- need this for when called from onVerticalScroll
end

-----------------------------------------

function Auctionator_FindBestCurrentAuction()

	gBaseDataIndex = nil;
	
	local basedata = gSortedData.absoluteBest;
	
	if (gSortedData.bestPrices[gCurrentStackSize]) then
		basedata = gSortedData.bestPrices[gCurrentStackSize];
	end

	local numrows = #gSortedData;
	
	local n;
	
	for n = 1,numrows do

		local data = gSortedData[n];

		if (basedata and data.itemPrice == basedata.itemPrice and data.stackSize == basedata.stackSize and data.suffix == basedata.suffix and data.yours == basedata.yours) then
			gBaseDataIndex = n;
			break;
		end
	end
end

-----------------------------------------

function Auctionator_FindBestHistoricalAuction()

	gBaseHistoryIndex = nil;
	
	if (gSortedHistory and #gSortedHistory > 0) then
		gBaseHistoryIndex = 1;
	end
end

-----------------------------------------

function Auctionator_HighlightEntry(entryIndex)
	local line;				-- 1 through 12 of our window to scroll

	for line = 1,12 do
	
		local lineEntry = getglobal ("AuctionatorEntry"..line);

		if (lineEntry:GetID() == entryIndex and Auctionator_IsModeCreateAuction()) then
			lineEntry:SetButtonState ("PUSHED", true);
		else
			lineEntry:SetButtonState ("NORMAL", false);
		end
	end
end

-----------------------------------------

function Auctionator_EntryOnClick()
	
	if (Auctionator_Batch_Frame:IsShown()) then
		return;
	end

	local entryIndex = this:GetID();
	
--	chatmsg (entryIndex);
	
	if (Auctionator_ShowingCurrentAuctions()) then
		gBaseDataIndex = entryIndex;
	else
		gBaseHistoryIndex = entryIndex;
	end
	
	Auctionator_HighlightEntry (entryIndex);
	Auctionator_UpdateRecommendation();


	PlaySound ("igMainMenuOptionCheckBoxOn");
end

-----------------------------------------

function AuctionatorMoneyFrame_OnLoad()

	this.small = 1;
	MoneyFrame_SetType(this, "AUCTION");
end


-----------------------------------------

function Auctionator_ShowBatchFrame()

	gAutoSell_ItemName			= gCurrentItemName;
	gAutoSell_ItemLink			= gCurrentItemLink;
	gAutoSell_GoodStackSize		= gCurrentStackSize;
	gAutoSell_StartPrice		= MoneyInputFrame_GetCopper(StartPrice);
	gAutoSell_BuyoutPrice		= MoneyInputFrame_GetCopper(BuyoutPrice);
	gAutoSell_Hours				= AuctionFrameAuctions.duration / 60;

	local _, _, _, _, _, _, _, iStackCount = GetItemInfo (gAutoSell_ItemName);

	gAutoSell_FullStackSize = iStackCount;
	gAutoSell_TotalItems	= 0;
	
	for bagID = kFirstBag, kLastBag do
		numslots = GetContainerNumSlots (bagID);
		for slotID = 1,numslots do
			local itemLink = GetContainerItemLink(bagID, slotID);
			if (itemLink) then
				local itemName				= GetItemInfo(itemLink);
				local texture, itemCount	= GetContainerItemInfo(bagID, slotID);

				if (itemName == gAutoSell_ItemName) then
					gAutoSell_TotalItems = gAutoSell_TotalItems + itemCount;
				end
			end
		end		
	end

	local numStacks = math.floor (gAutoSell_TotalItems / gAutoSell_GoodStackSize);


	local text =  "You have "..gAutoSell_TotalItems.." "..pluralizeIf (gAutoSell_ItemName).." in your bags.";

	
	Auctionator_SetTextureButton ("Auctionator_Batch_Texture", gAutoSell_GoodStackSize);

	MoneyFrame_Update ("Auctionator_Batch_Start_Price",  gAutoSell_StartPrice);
	MoneyFrame_Update ("Auctionator_Batch_Buyout_Price", gAutoSell_BuyoutPrice);

	Auctionator_Batch_Duration:SetText (gAutoSell_Hours.." hours");
	Auctionator_Batch_Itemname:SetText (gAutoSell_ItemName);
	
	Auctionator_Batch_NumAuctions:SetText (numStacks);
	
	Auctionator_Batch_Frame:Show();
end

-----------------------------------------

function Auctionator_ShowOptionsFrame()

	AuctionatorOptionsFrame:Show();
	AuctionatorOptionsFrame:SetBackdropColor(0,0,0,100);
	
	AuctionatorConfigFrameTitle:SetText ("Auctionator Options for "..UnitName("player"));
	
	local expText = "<html><body>"
					.."<h1>What is Auctionator?</h1><br/>"
					.."<p>"
					.."Figuring out a good buyout price when posting auctions can be tedious and time-consuming.  If you're like most people, you first browse the current "
					.."auctions to get a sense of how much your item is currently selling for.  Then you undercut the lowest price by a bit.  If you're creating multiple auctions "
					.."you're bouncing back and forth between the Browse tab and the Auctions tab, doing lots of division in "
					.."your head, and doing lots of clicking and typing."
					.."</p><br/><h1>How it works</h1><br/><p>"
					.."Auctionator makes this whole process easy and streamlined.  When you select an item to auction, Auctionator displays a summary of all the current auctions for "
					.."that item sorted by per-item price.  Auctionator also calculates a recommended buyout price based on the cheapest per-item price for your item.  If you're "
					.."selling a stack rather than a single item, Auctionator bases its recommended buyout price on the cheapest stack of the same size."
					.."</p><br/><p>"
					.."If you don't like Auctionator's recommendation, you can click on any line in the summary and Auctionator will recalculate the recommended buyout price based "
					.."on that auction.  Of course, you can always override Auctionator's recommendation by just typing in your own buyout price."
					.."</p><br/><p>"
					.."With Auctionator, creating an auction is usually just a matter of picking an item to auction and clicking the Create Auction button."
					.."</p>"
					.."</body></html>"
					;



	AuctionatorDescriptionHTML:SetText (expText);
	AuctionatorDescriptionHTML:SetSpacing (3);

	AuctionatorVersionText:SetText ("Version: "..AuctionatorVersion);

	AuctionatorOption_Enable_Alt_CB:SetChecked (NumToBool(AUCTIONATOR_ENABLE_ALT));
	AuctionatorOption_Open_First_CB:SetChecked (NumToBool(AUCTIONATOR_OPEN_FIRST));
	AuctionatorOption_Open_All_Bags_CB:SetChecked (NumToBool(AUCTIONATOR_OPEN_ALL_BAGS));

	AuctionatorOption_Def_Duration_CB:SetChecked (AUCTIONATOR_DEF_DURATION == "S" or AUCTIONATOR_DEF_DURATION == "M" or AUCTIONATOR_DEF_DURATION == "L");
	
	Auctionator_SetDurationOptionRB (AUCTIONATOR_DEF_DURATION);
end

 
-----------------------------------------

function Auctionator_SetDurationOptionRB(name)

	Auctionator_RB_S:SetChecked (StringEndsWith (name, "S"));
	Auctionator_RB_M:SetChecked (StringEndsWith (name, "M"));
	Auctionator_RB_L:SetChecked (StringEndsWith (name, "L"));

end

-----------------------------------------

function AuctionatorBasicOptionsSave()

	AUCTIONATOR_ENABLE_ALT		= BoolToNum(AuctionatorOption_Enable_Alt_CB:GetChecked ());
	AUCTIONATOR_OPEN_FIRST		= BoolToNum(AuctionatorOption_Open_First_CB:GetChecked ());
	AUCTIONATOR_OPEN_ALL_BAGS	= BoolToNum(AuctionatorOption_Open_All_Bags_CB:GetChecked ());

	AUCTIONATOR_DEF_DURATION = "N";
	
	if (AuctionatorOption_Def_Duration_CB:GetChecked()) then
		if (Auctionator_RB_S:GetChecked())	then	AUCTIONATOR_DEF_DURATION = "S"; end;
		if (Auctionator_RB_M:GetChecked())	then	AUCTIONATOR_DEF_DURATION = "M"; end;
		if (Auctionator_RB_L:GetChecked())	then	AUCTIONATOR_DEF_DURATION = "L"; end;
	end
end

-----------------------------------------

function Auctionator_ShowBasicOptionsFrame()

	AuctionatorBasicOptionsFrame:Show();

end

-----------------------------------------

function Auctionator_UCConfigLine_Setup(thresh, lineText)

	getglobal("UC_"..thresh.."_RangeText"):SetText (lineText);
	
	MoneyInputFrame_SetCopper (getglobal("UC_"..thresh.."_MoneyInput"), AUCTIONATOR_SAVEDVARS["_"..thresh]);

end

-----------------------------------------

function Auctionator_ShowUCConfigFrame()

	Auctionator_UCConfigLine_Setup (5000000,	"over 500 gold");
	Auctionator_UCConfigLine_Setup (1000000,	"over 100 gold");
	Auctionator_UCConfigLine_Setup (200000,		"over 20 gold");
	Auctionator_UCConfigLine_Setup (50000,		"over 5 gold");
	Auctionator_UCConfigLine_Setup (10000,		"over 1 gold");
	Auctionator_UCConfigLine_Setup (2000,		"over 20 silver");
	Auctionator_UCConfigLine_Setup (500,		"over 5 silver");  

	Auctionator_Starting_Discount:SetText (AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT);


--	AuctionatorOptionsFrame:Hide();
	AuctionatorUndercuttingConfig:Show();
--	Auctionator_Mask:Show();


end


-----------------------------------------

function Auctionator_UCConfigLine_Save(thresh)

	AUCTIONATOR_SAVEDVARS["_"..thresh]	= MoneyInputFrame_GetCopper(getglobal("UC_"..thresh.."_MoneyInput"));

end

-----------------------------------------

function AuctionatorUCConfigSave()

	Auctionator_UCConfigLine_Save (5000000);
	Auctionator_UCConfigLine_Save (1000000);
	Auctionator_UCConfigLine_Save (200000);
	Auctionator_UCConfigLine_Save (50000);
	Auctionator_UCConfigLine_Save (10000);
	Auctionator_UCConfigLine_Save (2000);
	Auctionator_UCConfigLine_Save (500);

	AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT = Auctionator_Starting_Discount:GetNumber ();

end


-----------------------------------------

function Auctionator_ShowOptionTooltip (elem)

	local name = elem:GetName();
	local titleText;
	local text;
	
	if (StringContains (name, "Enable_Alt")) then
		titleText = "Enable alt-key shortcut";
		text = "If this option is checked, holding the Alt key down while clicking an item in your bags will switch to the Auctionator panel, place the item in the Auction Item area, and start the scan.";
	end
	
	if (StringContains (name, "Open_First")) then
		titleText = "Automatically open Auctionator panel";
		text = "If this option is checked, the Auctionator panel will display first whenever you open the Auction House window.";
	end
	
	if (StringContains (name, "Open_All_Bags")) then
		titleText = "Automatically open all bags";
		text = "If this option is checked, ALL your bags will be opened when you first open the Auctionator panel.";
	end
	
	if (StringContains (name, "Def_Duration")) then
		titleText = "Set a default duration";
		text = "If this option is checked, every time you initiate a new auction the auction duration will be reset to the default duration you've selected.";
	end
	
	
	
	
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOM");
	GameTooltip:SetText(titleText, 0.9, 1.0, 1.0);
	GameTooltip:AddLine(text, 0.5, 0.5, 1.0, 1);
	GameTooltip:Show();

end



-----------------------------------------

function Auctionator_TabSelected()

	if (not AuctionFrame or not AuctionFrame:IsShown()) then
		return false;
	end

	return (PanelTemplates_GetSelectedTab (AuctionFrame) == Auctionator_FindTab());
end

-----------------------------------------

function Auctionator_Confirm_Yes()

	if (Auctionator_Confirm_Proc_Yes) then
		Auctionator_Confirm_Proc_Yes();
		Auctionator_Confirm_Proc_Yes = nil;
	end
	
	Auctionator_Confirm_Frame:Hide();
	
end


-----------------------------------------

function Auctionator_Confirm_No()

	Auctionator_Confirm_Frame:Hide();
	
end


-----------------------------------------

function Auctionator_AddHistoricalPrice (itemName, price, stacksize, itemLink, testwhen)
	
	if (not AUCTIONATOR_PRICING_HISTORY[itemName] ) then
		AUCTIONATOR_PRICING_HISTORY[itemName] = {};
	end

	local found, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
	local _, itemId, _, _, _, _, _, suffixId, uniqueId = strsplit(":", itemString)

	local is = itemId;
	
	if (suffixId ~= 0) then
		is = is..":"..suffixId;
		if (tonumber(suffixId) < 0) then
			is = is..":"..uniqueId;
		end
	end
	
	AUCTIONATOR_PRICING_HISTORY[itemName]["is"]  = is;
	
	local hist = tostring (round (price))..":"..stacksize;
	
	local roundtime = floor (time() / 60) * 60;		-- so multiple auctions close together don't generate too many entries
	
	local tag = tostring(ToTightTime(roundtime));
	
	if (testwhen) then
		tag = tostring(ToTightTime(testwhen));
	end

	AUCTIONATOR_PRICING_HISTORY[itemName][tag] = hist;
	
end

-----------------------------------------

function Auctionator_HasHistoricalData (itemName)
	
	if (AUCTIONATOR_PRICING_HISTORY[itemName] ) then
		return true;
	end

	return false;
end



--[[***************************************************************

	All function below here are local utility functions.
	These should be declared local at the top of this file.

--*****************************************************************]]

function ToTightTime(t)

	return floor((t - gTimeTightZero)/60);

end

-----------------------------------------

function FromTightTime(tt)

	return (tt*60) + gTimeTightZero;
	
end

-----------------------------------------

function BoolToString (b)
	if (b) then
		return "true";
	end
	
	return "false";
end

-----------------------------------------

function BoolToNum (b)
	if (b) then
		return 1;
	end
	
	return 0;
end

-----------------------------------------

function NumToBool (n)
	if (n == 0) then
		return false;
	end
	
	return true;
end

-----------------------------------------

function pluralizeIf (word, count)

	if (count and count == 1) then
		return word;
	else
		return pluralize(word);
	end
end

-----------------------------------------

function pluralize (word)

	return word.."s";

end

-----------------------------------------

function round (v)
	return math.floor (v + 0.5);
end

-----------------------------------------

function chatmsg (msg, red, green, blue)
	if (DEFAULT_CHAT_FRAME) then
		if (msg == nil) then
			DEFAULT_CHAT_FRAME:AddMessage ("nil", red, green, blue);
		else
			DEFAULT_CHAT_FRAME:AddMessage (msg, red, green, blue);
		end
	end
end

-----------------------------------------

function chatmsg2 (msg1, msg2)
	if (DEFAULT_CHAT_FRAME) then
		local msg = "";
		
		if (type(msg1) == "boolean") then	msg1 = BoolToString(msg1);	end;
		if (type(msg2) == "boolean") then	msg2 = BoolToString(msg2);	end;
		
		if (msg1 == nil) then msg = "nil";
		else				  msg = msg1;
		end
		
		if (msg2 == nil) then msg = msg.." nil";
		else				  msg = msg.." "..msg2;
		end
		
		DEFAULT_CHAT_FRAME:AddMessage (msg);
	end
end

-----------------------------------------

function calcNewPrice (price)

	if	(price > 5000000)	then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._5000000);	end;
	if	(price > 1000000)	then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._1000000);	end;
	if	(price >  200000)	then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._200000);	end;
	if	(price >   50000)	then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._50000);	end;
	if	(price >   10000)	then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._10000);	end;
	if	(price >    2000)	then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._2000);	end;
	if	(price >     500)	then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._500);		end;
	if	(price >       0)	then return math.floor (price - 1);	end;

	return 0;
end

-----------------------------------------
-- roundPriceDown - rounds a price down to the next lowest multiple of a.
--				  - if the result is not at least a/2 lower, rounds down by a again.
--
--	examples:  	(128790, 500)  ->  128500 
--				(128700, 500)  ->  128000 
--				(128400, 500)  ->  128000
-----------------------------------------

function roundPriceDown (price, a)
	
	local newprice = math.floor(price / a) * a;
	
	if ((price - newprice) < a/2) then
		newprice = newprice - a;
	end
	
	if (newprice == price) then
		newprice = newprice - 1;
	end
	
	return newprice;
	
end

-----------------------------------------

function val2gsc (v)
	local rv = round(v)
	
	local g = math.floor (rv/10000);
	
	rv = rv - g*10000;
	
	local s = math.floor (rv/100);
	
	rv = rv - s*100;
	
	local c = rv;
			
	return g, s, c
end

-----------------------------------------

function priceToString (val)

	local gold, silver, copper  = val2gsc(val);

	local st = "";
	

	if (gold ~= 0) then
		st = gold.."g ";
	end


	if (st ~= "") then
		st = st..format("%02is ", silver);
	elseif (silver ~= 0) then
		st = st..silver.."s ";
	end

		
	if (st ~= "") then
		st = st..format("%02ic", copper);
	elseif (copper ~= 0) then
		st = st..copper.."c";
	end
	
	return st;
end


-----------------------------------------

function StringContains (s, sub)
	if (sub == nil or sub == "") then
		return false;
	end
	
	local start, stop = string.find (string.lower(s), string.lower(sub), 1, true);

	return (start ~= nil);
end

-----------------------------------------

function StringEndsWith (s, sub)
	
	if (sub == nil or sub == "") then
		return false;
	end

	local i = string.len(s) - string.len(sub);

	if (i < 0) then
		return false;
	end

	local sEnd = string.sub (s, i+1);
	
	return (string.lower (sEnd) == string.lower (sub));
	
end

-----------------------------------------

function StringStartsWith (s, sub)

	if (sub == nil or sub == "") then
		return false;
	end

	local sublen = string.len (sub);
	
	if (string.len (s) < sublen) then
		return false;
	end
	
	return (string.lower (string.sub(s, 1, sublen)) == string.lower(sub));
	
end

-----------------------------------------

function CopyDeep (src)

	local result = {};
	
	for n, v in pairs (src) do
		result[n] = v;
	end

	return result;

end

-----------------------------------------

function ItemType2AuctionClass(itemType)
	local itemClasses = { GetAuctionItemClasses() };
	if #itemClasses > 0 then
	local itemClass;
		for x, itemClass in pairs(itemClasses) do
			if (itemClass == itemType) then
				return x;
			end
		end
	end
end


-----------------------------------------

function SubType2AuctionSubclass(auctionClass, itemSubtype)
	local itemClasses = { GetAuctionItemSubClasses(auctionClass) };
	if #itemClasses > 0 then
	local itemClass;
		for x, itemClass in pairs(itemClasses) do
			if (itemClass == itemSubtype) then
				return x;
			end
		end
	end
end






