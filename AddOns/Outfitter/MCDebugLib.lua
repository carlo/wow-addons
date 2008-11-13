local	gMCDebugLib_Version = 4;

if not MCDebugLib or MCDebugLib.Version < gMCDebugLib_Version then
	if not MCDebugLib then
		MCDebugLib = {};
	end
	
	function MCDebugLib:Initialize()
		if self.Initialized then
			return;
		end
		
		self.Initialized = true;
		
		hooksecurefunc(
				"ChatFrame_ConfigEventHandler",
				function (event)
					if event == "UPDATE_CHAT_WINDOWS"
					and not MCDebugLib.DebugFrame then
						MCDebugLib:FindDebugFrame()
					end
				end);
		
		self:FindDebugFrame();
	end
	
	function MCDebugLib:FindDebugFrame()
		if self.DebugFrame then
			return;
		end
		
		for vChatIndex = 1, NUM_CHAT_WINDOWS do
			local	vChatFrame = getglobal("ChatFrame"..vChatIndex);
			
			if vChatFrame
			and (vChatFrame:IsVisible() or vChatFrame.isDocked) then
				local	vTab = getglobal("ChatFrame"..vChatIndex.."Tab");
				local	vName = vTab:GetText();
				
				if vName == "Debug" then
					self.DebugFrame = vChatFrame;
					if self.DebugFrame:GetMaxLines() < 1000 then
						self.DebugFrame:SetMaxLines(1000);
					end
				end
			end
		end
		
		if self.DebugFrame then
			self:NoteMessage("MCDebugLib: Found debugging chat frame");
		end
	end
	
	function MCDebugLib:DebugMessage(pMessage, pPrefix)
		if not self.Initialized then
			self:Initialize();
		end
		
		if self.DebugFrame then
			if not pPrefix then
				pPrefix = "DEBUG: ";
			end
			
			self.DebugFrame:AddMessage(pPrefix..pMessage, 0.9, 0.6, 1.0);
			
			local vTabFlash = getglobal(self.DebugFrame:GetName().."TabFlash");
			
			vTabFlash:Show();
			UIFrameFlash(vTabFlash, 0.25, 0.25, 60, nil, 0.5, 0.5);
		end
	end

	function MCDebugLib:ErrorMessage(pMessage)
		DEFAULT_CHAT_FRAME:AddMessage(pMessage, 0.8, 0.3, 0.5);
	end
	
	function MCDebugLib:TestMessage(pMessage)
		self:DebugMessage(pMessage, "TEST: ");
	end
	
	function MCDebugLib:NoteMessage(pMessage)
		DEFAULT_CHAT_FRAME:AddMessage(pMessage, 0.6, 1.0, 0.3);
	end
	
	function MCDebugLib:DumpArray(pPrefixString, pValue, pMaxDepth)
		if not pValue then
			self:TestMessage(pPrefixString.." = nil");
			return;
		end
		
		local	vType = type(pValue);
		
		if vType == "number" then
			self:TestMessage(pPrefixString.." = "..pValue);
		elseif vType == "string" then
			self:TestMessage(pPrefixString.." = \""..pValue.."\"");
		elseif vType == "boolean" then
			if pValue then
				self:TestMessage(pPrefixString.." = true");
			else
				self:TestMessage(pPrefixString.." = false");
			end
		elseif vType == "table" then
			local	vMaxDepth;
			
			if pMaxDepth then
				vMaxDepth = pMaxDepth;
			else
				vMaxDepth = 5;
			end
			
			if vMaxDepth == 0 then
				self:TestMessage(pPrefixString.." = {...}");
			else
				local	vFoundElement = false;
				
				for vIndex, vElement in pairs(pValue) do
					vFoundElement = true;
					
					local	vPrefix;
					
					if type(vIndex) == "number" then
						vPrefix = pPrefixString.."["..vIndex.."]";
					else
						vPrefix = pPrefixString.."."..vIndex;
					end
					
					self:DumpArray(vPrefix, vElement, vMaxDepth - 1);
				end
				
				if not vFoundElement then
					self:TestMessage(pPrefixString.." = {}");
				end
			end
		else
			self:TestMessage(pPrefixString.." "..vType);
		end
	end
	
	function MCDebugLib:ShowCallStack(pPrefix, pDepth)
		if not pPrefix then
			pPrefix = "";
		end
		
		if not pDepth then
			pDepth = 3;
		end
		
		local	vStackString = debugstack(3, pDepth, 0);
		
		for vMessageLine in string.gmatch(vStackString, "(.-)\n") do
			local	_, _, vFile, vLine, vFunction = string.find(vMessageLine, "([%w%.]+):(%d+): in function .(.*)'");
			
			if not vFunction then
				_, _, vFunction, vLine, vFile = string.find(vMessageLine, "%[string \"(.*)\"%]:(%d+): in (.*)");
				
				if not vFunction then
					_, _, _, vFunction = string.find(vMessageLine, "(%[C%]): in function .(.*)'");
					
					if vFunction then
						vFunction = "[C] "..vFunction;
						vFile = nil;
						vLine = nil;
					end
				end
			end
			
			if vFunction then
				if vFile then
					if not vLine then
						vLine = 0;
					end
					
					MCDebugLib:DebugMessage(pPrefix..vFunction.." ("..vFile..", "..vLine..")");
				else
					MCDebugLib:DebugMessage(pPrefix..vFunction);
				end
			end
		end
	end
	
	function MCDebugLib:NewBuckets(pInterval)
		local	vBuckets =
		{
			Interval = pInterval,
			BucketStartTime = GetTime(),
			BucketIndex = 1,
			NumBuckets = math.floor(pInterval),
			Buckets = {[1] = {Value = 0, Time = 0}},
			
			AddSample = self.BucketsAddSample,
			GetValue = self.BucketsGetValue,
		};
		
		return vBuckets;
	end
	
	function MCDebugLib:BucketsAddSample(pValue, pTime)
		local	vBucket = self.Buckets[self.BucketIndex];
		
		vBucket.Value = vBucket.Value + pValue;
		
		local	vElapsed = pTime - self.BucketStartTime;
		
		if vElapsed > 1 then
			vBucket.Time = vElapsed;
			
			self.BucketStartTime = pTime;
			self.BucketIndex = self.BucketIndex + 1;
			
			if self.BucketIndex > self.NumBuckets then
				self.BucketIndex = 1;
			end
			
			vBucket = self.Buckets[self.BucketIndex];
			
			if not vBucket then
				vBucket = {};
				self.Buckets[self.BucketIndex] = vBucket;
			end
			
			vBucket.Value = 0;
			vBucket.Time = 0;
		end
	end
	
	function MCDebugLib:BucketsGetValue()
		local	vTotalElapsed = 0;
		local	vTotalValue = 0;
		
		for vIndex, vBucket in ipairs(self.Buckets) do
			if vBucket.Time > 0 then
				vTotalElapsed = vTotalElapsed + vBucket.Time;
				vTotalValue = vTotalValue + vBucket.Value;
			end
		end
		
		if vTotalElapsed == 0 then
			return 0, 0;
		end
		
		return vTotalValue / vTotalElapsed, vTotalElapsed;
	end
	
	function MCDebugLib:NewPerfMonitor(pLabel)
		local	vPerfMonitor =
		{
			Label = pLabel,
			CPUBuckets = self:NewBuckets(10),
			MemBuckets = self:NewBuckets(10),
			
			FunctionEnter = self.PerfMonitorFunctionEnter,
			FunctionExit = self.PerfMonitorFunctionExit,
			DumpValue = self.PerfMonitorDumpValue,
		};
		
		return vPerfMonitor;
	end
	
	function MCDebugLib:PerfMonitorFunctionEnter(pTime)
		self.StartTime = pTime;
		self.StartMem = gcinfo();
	end
	
	function MCDebugLib:PerfMonitorFunctionExit(pTime)
		local	vEndMem = gcinfo();
		
		self.CPUBuckets:AddSample(pTime - self.StartTime, pTime);
		self.MemBuckets:AddSample(vEndMem - self.StartMem, pTime);
	end
	
	function MCDebugLib:PerfMonitorDumpValue()
		local	vCPUTime, vTotalTime = self.CPUBuckets:GetValue();
		local	vMemRate = self.MemBuckets:GetValue();
		local	vCPUPercent;
		
		if vTotalTime > 0 then
			vCPUPercent = 100 * vCPUTime / vTotalTime;
		else
			vCPUPercent = 0;
		end
		
		MCDebugLib:TestMessage(string.format("%s: CPU: %.1f%% Mem: %dKB/sec", self.Label, vCPUPercent, vMemRate));
	end
	
	function MCDebugLib.BoolToString(pValue)
		if pValue then
			return "true";
		else
			return "false";
		end
	end
	
	function MCDebugLib:ShowFrameStatus(pFrame, pPrefix)
		self:TestMessage(string.format("%sVisible: %s Protected: %s Width: %d Height: %d Level: %d", pPrefix or pFrame:GetName(), self.BoolToString(pFrame:IsVisible()), self.BoolToString(pFrame:IsProtected()), pFrame:GetWidth(), pFrame:GetHeight(), pFrame:GetFrameLevel()));
	end
	
	function MCDebugLib:ShowParentTree(pFrame, pPrefix)
		if not pPrefix then
			pPrefix = "";
		end
		
		local	vParent = pFrame:GetParent();
		
		if vParent then
			self:TestMessage(pPrefix.."Parent: "..vParent:GetName());
			
			if vParent ~= UIParent then
				self:ShowFrameStatus(vParent, pPrefix.."    ");
				self:ShowParentTree(vParent, pPrefix.."    ");
			end
		end
	end
	
	function MCDebugLib:ShowAnchorTree(pFrame, pPrefix)
		if not pPrefix then
			pPrefix = "";
		end
		
		local	vIndex = 1;
		local	vDidAnchor = {};
		
		local	vIndex = 1;
		
		while true do
			local	vPoint, vRelativeTo, vRelativePoint, vOffsetX, vOffsetY = pFrame:GetPoint(vIndex);
			
			if not vPoint
			or not vRelativeTo then
				break;
			end
			
			MCDebugLib:TestMessage(string.format("%sAnchor %d: %s, %s, %s, %d, %d", pPrefix, vIndex, vPoint, vRelativeTo:GetName(), vRelativePoint, vOffsetX, vOffsetY));
			
			if vRelativeTo ~= UIParent
			and not vDidAnchor[vRelativeTo] then
				vDidAnchor[vRelativeTo] = true;
				
				self:TestMessage(pPrefix.."RelativeTo: "..vRelativeTo:GetName());
				self:ShowFrameStatus(vRelativeTo, pPrefix.."    ");
				self:ShowAnchorTree(vRelativeTo, pPrefix.."    ");
			end
			
			vIndex = vIndex + 1;
		end
		
		if vIndex == 1 then
			MCDebugLib:TestMessage(pPrefix.." No Anchors");
		end
	end
	
	function MCDebugLib:ShowFrameTree(pFrame)
		self:TestMessage("ShowFrameTree: "..pFrame:GetName());
		self:ShowFrameStatus(pFrame, "    ");
		self:ShowParentTree(pFrame, "    ");
		self:ShowAnchorTree(pFrame, "    ");
	end
	
	MCDebugLib.Version = gMCDebugLib_Version;
end
