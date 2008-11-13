local	gMCEventLib_Version = 3;

if not MCEventLib or MCEventLib.Version < gMCEventLib_Version then
	if not MCEventLib then
		local	vEventFrame = MCEventLibFrame;
		
		if not vEventFrame then
			vEventFrame = CreateFrame("FRAME", "MCEventLibFrame", UIParent);
		end
		
		MCEventLib =
		{
			EventFrame = vEventFrame,
			EventHandlers = {},
			Iterators = {},
		};
	end
	
	function MCEventLib:DebugPerformance()
		self.PerfMonitor = MCDebugLib:NewPerfMonitor("MCEventLib");
	end
	
	function MCEventLib:RegisterEvent(pEventID, pFunction, pRefParam, pBlind)
		local	vHandlers = self.EventHandlers[pEventID];
		
		if not vHandlers then
			vHandlers = {};
			self.EventHandlers[pEventID] = vHandlers;
			self.EventFrame:RegisterEvent(pEventID);
		end
		
		local	vHandler =
		{
			Function = pFunction,
			RefParam = pRefParam,
			Blind = pBlind,
		};
		
		table.insert(vHandlers, vHandler);
	end
	
	function MCEventLib:UnregisterEvent(pEventID, pFunction, pRefParam)
		local	vHandlers = self.EventHandlers[pEventID];
		
		if not vHandlers then
			return;
		end
		
		for vIndex, vHandler in ipairs(vHandlers) do
			if (not pFunction or vHandler.Function == pFunction)
			and (not pRefParam or vHandler.RefParam == pRefParam) then
				table.remove(vHandlers, vIndex);
				
				if #vHandlers == 0 then
					self.EventHandlers[pEventID] = nil;
					self.EventFrame:UnregisterEvent(pEventID);
				end
				
				local	vIterator = self.Iterators[pEventID];
				
				if vIterator then
					if vIndex <= vIterator.Index then
						vIterator.Index = vIterator.Index -1;
					end
					
					vIterator.Count = vIterator.Count - 1;
				end
				
				return;
			end -- if
		end -- while
	end
	
	function MCEventLib:UnregisterAllEvents(pFunction, pRefParam)
		for vEventID, vHandlers in pairs(self.EventHandlers) do
			for vIndex, vHandler in ipairs(vHandlers) do
				if (not pFunction or vHandler.Function == pFunction)
				and (not pRefParam or vHandler.RefParam == pRefParam) then
					table.remove(vHandlers, vIndex);
					
					if #vHandlers == 0 then
						self.EventHandlers[vEventID] = nil;
						self.EventFrame:UnregisterEvent(vEventID);
					end
					
					local	vIterator = self.Iterators[vEventID];
					
					if vIterator then
						if vIndex <= vIterator.Index then
							vIterator.Index = vIterator.Index -1;
						end
						
						vIterator.Count = vIterator.Count - 1;
					end
					
					break;
				end -- if
			end -- for
		end -- for
	end
	
	function MCEventLib:DispatchEvent(pEventID, pArg1, pArg2, pArg3, pArg4)
		local	vHandlers = self.EventHandlers[pEventID];
		
		if not vHandlers then
			return;
		end
		
		local	vIterator = self.Iterators[pEventID];
		
		if vIterator then
			return;
		end
		
		if self.PerfMonitor then
			self.PerfMonitor:FunctionEnter(GetTime());
		end
		
		vIterator = {Index = 1, Count = #vHandlers};
		
		self.Iterators[pEventID] = vIterator;
		
		while vIterator.Index <= vIterator.Count do
			local	vHandler = vHandlers[vIterator.Index];
			local	vSucceeded, vMessage;
			
			if vHandler.Blind then
				if vHandler.RefParam ~= nil then
					vSucceeded, vMessage = pcall(vHandler.Function, vHandler.RefParam, pArg1, pArg2, pArg3, pArg4);
				else
					vSucceeded, vMessage = pcall(vHandler.Function, pArg1, pArg2, pArg3, pArg4);
				end
			else
				if vHandler.RefParam ~= nil then
					vSucceeded, vMessage = pcall(vHandler.Function, vHandler.RefParam, pEventID, pArg1, pArg2, pArg3, pArg4);
				else
					vSucceeded, vMessage = pcall(vHandler.Function, pEventID, pArg1, pArg2, pArg3, pArg4);
				end
			end
			
			if not vSucceeded then
				MCDebugLib:ErrorMessage(vMessage);
			end
			
			vIterator.Index = vIterator.Index + 1;
		end
		
		self.Iterators[pEventID] = nil;

		if self.PerfMonitor then
			local	vEndTime = GetTime();
			
			self.PerfMonitor:FunctionExit(vEndTime);
			
			if not self.LastDumpTime
			or vEndTime - self.LastDumpTime > 2 then
				self.LastDumpTime = vEndTime;
				
				self.PerfMonitor:DumpValue();
			end
		end
	end
	
	function MCEventLib.BlockedActionEvent(pEventID, pSource, pAction)
		MCDebugLib:DebugMessage(pEventID..": "..pSource.." ("..(pAction or "")..")");
	end
	
	MCEventLib.EventFrame:SetScript("OnEvent", function () MCEventLib:DispatchEvent(event, arg1, arg2, arg3, arg4) end);
	
	MCEventLib.Version = gMCEventLib_Version;
	
	MCEventLib:RegisterEvent("MACRO_ACTION_FORBIDDEN", MCEventLib.BlockedActionEvent);
	MCEventLib:RegisterEvent("ADDON_ACTION_FORBIDDEN", MCEventLib.BlockedActionEvent);
	MCEventLib:RegisterEvent("MACRO_ACTION_BLOCKED", MCEventLib.BlockedActionEvent);
	MCEventLib:RegisterEvent("ADDON_ACTION_BLOCKED", MCEventLib.BlockedActionEvent);
end
