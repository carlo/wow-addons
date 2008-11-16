--######################### Initial Variables
AuctionMeOff_Prices = {};

local initAuctionMeOff_Prices = AuctionMeOff_Prices;
local AuctionMeOff_origEventFunc = nil;
local AuctionMeOff_origStartFunc = nil;



--######################### Functions
-- Called when the addon is loaded (declared in the xml)
function AuctionMeOff_OnLoad()
	-- When an item is dragged to the auction window
	this:RegisterEvent("NEW_AUCTION_UPDATE");
	-- Addon is loaded
	this:RegisterEvent("ADDON_LOADED");
end


-- Called to prep the auction window
function AuctionMeOff_Event()
	-- If the original event function is not nil, call it
	if (AuctionMeOff_origEventFunc ~= nil) then
		AuctionMeOff_origEventFunc();
	end
	
	-- When an item is dragged to the auction window
	if (event == "NEW_AUCTION_UPDATE") then
		local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
		
		-- If there is no item, remove the values
		if (name == nil) then
			-- Set Money to nothing
			MoneyInputFrame_SetCopper(StartPrice, 0);
			MoneyInputFrame_SetCopper(BuyoutPrice, 0);
			
			-- Set Auction Icon / Deposit price to nil
			AuctionsItemButton:SetNormalTexture(nil);
			AuctionsItemButtonName:SetText(nil);
			AuctionsItemButtonCount:Hide();
			MoneyFrame_Update("AuctionsDepositMoneyFrame", 0);
		else
			-- Set LastAuction to nil
			local LastAuction = nil;
			
			-- Set Auction Icon / Name / Deposit price
			AuctionsItemButton:SetNormalTexture(texture);
			AuctionsItemButtonName:SetText(name);
			
			-- If the item is part of a stack, show stack size
			if (count > 1) then
				AuctionsItemButtonCount:SetText(count);
				AuctionsItemButtonCount:Show();
			else
				AuctionsItemButtonCount:Hide();
			end
			
			MoneyFrame_Update("AuctionsDepositMoneyFrame", CalculateAuctionDeposit(AuctionFrameAuctions.duration));
			
			-- If previous values for the item are set, use those instead
			if (AuctionMeOff_Prices[name] ~= nil) then
				LastAuction = AuctionMeOff_Prices[name];
			end
			
			-- If LastAuction is not nil, then set the prices
			if (LastAuction ~= nil) then
				MoneyInputFrame_SetCopper(StartPrice, LastAuction.bid * count);
				MoneyInputFrame_SetCopper(BuyoutPrice, LastAuction.buyout * count);
				if (LastAuction.duration == 720) then
					AuctionsShortAuctionButton:SetChecked(1);
					AuctionsMediumAuctionButton:SetChecked(0);
					AuctionsLongAuctionButton:SetChecked(0);
					AuctionFrameAuctions.duration = 720;
				elseif (LastAuction.duration == 1440) then
					AuctionsShortAuctionButton:SetChecked(0);
					AuctionsMediumAuctionButton:SetChecked(1);
					AuctionsLongAuctionButton:SetChecked(0);
					AuctionFrameAuctions.duration = 1440;
				elseif (LastAuction.duration == 2880) then
					AuctionsShortAuctionButton:SetChecked(0);
					AuctionsMediumAuctionButton:SetChecked(0);
					AuctionsLongAuctionButton:SetChecked(1);
					AuctionFrameAuctions.duration = 2880;
				end
			else
				MoneyInputFrame_SetCopper(StartPrice, price * count);
				MoneyInputFrame_SetCopper(BuyoutPrice, 0);
			end
		end
	end
end


-- Called to actually start the auction
function AuctionMeOff_Start(start, buyout, duration)
	local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
	--[[DEFAULT_CHAT_FRAME:AddMessage(name .. " " .. count .. " " .. price, 0.0, 1.0, 0.0);
	DEFAULT_CHAT_FRAME:AddMessage("Start Price: " .. start, 0.0, 1.0, 0.0);
	DEFAULT_CHAT_FRAME:AddMessage("Buyout Price: " .. buyout, 0.0, 1.0, 0.0);
	DEFAULT_CHAT_FRAME:AddMessage("Duration: " .. duration, 0.0, 1.0, 0.0);]]--
	
	-- Set the Price for '1' of the item in question
	AuctionMeOff_Prices[name] = {};
	AuctionMeOff_Prices[name].bid = start / count;
	AuctionMeOff_Prices[name].buyout = buyout / count;
	AuctionMeOff_Prices[name].duration = duration;
	
	-- If the original start function is not nil, call it
	if (AuctionMeOff_origStartFunc ~= nil) then
		AuctionMeOff_origStartFunc(start, buyout, duration);
	end
	
	-- Set Money to nothing
	MoneyInputFrame_SetCopper(StartPrice, 0);
	MoneyInputFrame_SetCopper(BuyoutPrice, 0);
	
	-- Set Auction Icon / Deposit price to nil
	AuctionsItemButton:SetNormalTexture(nil);
	AuctionsItemButtonName:SetText(nil);
	AuctionsItemButtonCount:Hide();
	MoneyFrame_Update("AuctionsDepositMoneyFrame", 0);
	
	-- Set Chat Message
	--DEFAULT_CHAT_FRAME:AddMessage("Price for " .. name .. " saved to the Array (Duration for " .. name .. " is " .. duration .. ".", 0.0, 1.0, 0.0);
end


-- Called when an event happens
function AuctionMeOff_OnEvent()	
	-- When an item is dragged to the auction window
	if (event == "NEW_AUCTION_UPDATE") then		
		-- Check origEventFunc
		if (AuctionMeOff_origEventFunc == nil) then
			-- Set origEventFunc to the default function
			AuctionMeOff_origEventFunc = AuctionSellItemButton_OnEvent;
			
			-- Set the default to OUR beginning function
			AuctionSellItemButton_OnEvent = AuctionMeOff_Event;
			
			-- Set origStartFunc to the default function (start auction)
			AuctionMeOff_origStartFunc = StartAuction;
			
			-- Set the default to OUR start function
			StartAuction = AuctionMeOff_Start;
			
			-- Call the 
			AuctionMeOff_Event();
		end
	end
end