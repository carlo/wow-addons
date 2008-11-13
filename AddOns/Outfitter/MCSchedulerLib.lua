local	gMCSchedulerLib_Version = 4;

if not MCSchedulerLib or MCSchedulerLib.Version < gMCSchedulerLib_Version then
	if not MCSchedulerLib then
		local	vEventFrame = MCSchedulerLibFrame;
		
		if not vEventFrame then
			vEventFrame = CreateFrame("FRAME", "MCSchedulerLibFrame", UIParent);
		end
		
		MCSchedulerLib =
		{
			EventFrame = vEventFrame,
			HasTasks = false,
			NeedSorted = false,
			Tasks = {},
			
			IteratorIndex = nil,
			IteratorCount = nil,
		};
	end
	
	function MCSchedulerLib:DebugPerformance()
		self.PerfMonitor = MCDebugLib:NewPerfMonitor("MCSchedulerLib");
	end
	
	function MCSchedulerLib:ScheduleTask(pDelay, pFunction, pParam)
		local	vTask =
		{
			Time = GetTime() + pDelay,
			Function = pFunction,
			Param = pParam,
		};
		
		self:InsertTask(vTask);
	end
	
	function MCSchedulerLib:ScheduleUniqueTask(pDelay, pFunction, pParam)
		if self:FindTask(pFunction, pParam) then
			return;
		end
		
		self:ScheduleTask(pDelay, pFunction, pParam);
	end
	
	function MCSchedulerLib:ScheduleRepeatingTask(pInterval, pFunction, pParam, pInitialDelay)
		local	vTask =
		{
			Interval = pInterval,
			Function = pFunction,
			Param = pParam,
		};
		
		if pInitialDelay then
			vTask.Time = GetTime() + pInitialDelay;
		else
			vTask.Time = GetTime() + pInterval;
		end
		
		self:InsertTask(vTask);
	end
	
	function MCSchedulerLib:ScheduleUniqueRepeatingTask(pInterval, pFunction, pParam, pInitialDelay)
		if self:FindTask(pFunction, pParam) then
			return;
		end
		
		self:ScheduleRepeatingTask(pInterval, pFunction, pParam, pInitialDelay);
	end
	
	function MCSchedulerLib:SetTaskInterval(pInterval, pFunction, pParam)
		local	vTask, vIndex = self:FindTask(pFunction, pParam);
		
		if not vTask then
			return;
		end
		
		if vTask.Interval == pInterval then
			return;
		end
		
		if vTask.Interval then
			vTask.Time = vTask.Time - vTask.Interval;
		end
		
		vTask.Interval = pInterval;

		if vTask.Interval then
			vTask.Time = vTask.Time + vTask.Interval;
		end
		
		self.NeedSorted = true;
	end
	
	function MCSchedulerLib:SetTaskDelay(pDelay, pFunction, pParam)
		local	vTask, vIndex = self:FindTask(pFunction, pParam);
		
		if not vTask then
			return;
		end
		
		vTask.Time = GetTime() + pDelay;
		
		self.NeedSorted = true;
	end
	
	function MCSchedulerLib:InsertTask(pTask)
		if not pTask then
			MCDebugLib:ErrorMessage("MCSchedulerLib:InsertTask: Inserting a nil task");
			return;
		end
		
		table.insert(self.Tasks, pTask);
		
		self.NeedSorted = true;
		
		if not self.HasTasks then
			self.EventFrame:Show();
			self.HasTasks = true;
		end
	end
	
	function MCSchedulerLib:UnscheduleAllTasks(pFunction, pParam)
		while self:UnscheduleTask(pFunction, pParam) do
		end
	end
	
	function MCSchedulerLib:UnscheduleTask(pFunction, pParam)
		local	vTask, vIndex = self:FindTask(pFunction, pParam);
		
		if not vTask then
			return false;
		end
		
		table.remove(self.Tasks, vIndex);
		
		if self.IteratorIndex
		and vIndex < self.IteratorIndex then
			self.IteratorIndex = self.IteratorIndex - 1;
		end
		
		if #self.Tasks == 0 then
			self.HasTasks = false;
			self.EventFrame:Hide();
		end
		
		return true;
	end
	
	function MCSchedulerLib:FindTask(pFunction, pParam)
		for vIndex, vTask in ipairs(self.Tasks) do
			if (pFunction == nil or vTask.Function == pFunction)
			and (pParam == nil or vTask.Param == pParam) then
				return vTask, vIndex;
			end
		end -- for
	end
	
	MCSchedulerLib.OnUpdateRunning = false;
	
	function MCSchedulerLib:OnUpdate(pElapsed)
		-- Prevent from re-entering
		
		if self.OnUpdateRunning then
			-- MCDebugLib:TestMessage("MCSchedulerLib:OnUpdate already running");
			return;
		end
		
		self.OnUpdateRunning = true;
		
		local	vResult, vMessage = pcall(self.OnUpdate2, self, pElapsed);
		
		if not vResult then
			MCDebugLib:ErrorMessage("MCSchedulerLib Internal Error: "..vMessage);
		end
		
		self.OnUpdateRunning = false;
	end
	
	function MCSchedulerLib:OnUpdate2(pElapsed)
		local	vTime = GetTime();
		
		if self.PerfMonitor then
			self.PerfMonitor:FunctionEnter(vTime);
		end
		
		--
		
		if self.NeedSorted then
			self.NeedSorted = false;
			table.sort(self.Tasks, self.CompareTasks);
		end
		
		self.IteratorIndex = 1;
		
		while self.IteratorIndex <= #self.Tasks do
			local	vTask = self.Tasks[self.IteratorIndex];
			
			if not vTask then
				MCDebugLib:ErrorMessage("nil task at index "..self.IteratorIndex);
				table.remove(self.Tasks, self.IteratorIndex);
			else
				if vTask.Time > vTime then
					break;
				end
				
				-- Re-schedule or remove the task before calling its function
				-- in case the function decides it wants to remove the task too
				
				if vTask.Interval == nil then
					table.remove(self.Tasks, self.IteratorIndex);
				else
					vTask.Time = vTime + vTask.Interval;
					
					if vTask.Interval > 0 then
						self.NeedSorted = true;
					end
					
					self.IteratorIndex = self.IteratorIndex + 1;
				end
				
				-- Call the function
				
				local	vResult, vMessage;
				
				if vTask.Param ~= nil then
					vResult, vMessage = pcall(vTask.Function, vTask.Param, vTime);
				else
					vResult, vMessage = pcall(vTask.Function, vTime);
				end
				
				if not vResult then
					MCDebugLib:ErrorMessage(vMessage);
				end
			end
		end -- while
		
		self.IteratorIndex = nil;
		
		if #self.Tasks == 0 then
			self.HasTasks = false;
			self.EventFrame:Hide();
		end
		
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
	
	function MCSchedulerLib.CompareTasks(pTask1, pTask2)
		return pTask1.Time < pTask2.Time;
	end
	
	MCSchedulerLib.EventFrame:SetScript("OnUpdate", function () MCSchedulerLib:OnUpdate(arg1) end);
	
	MCSchedulerLib.Version = gMCSchedulerLib_Version;
end
