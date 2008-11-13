PROFILER_INTERVAL = 2.5;
PROFILER_STARTED = nil;

SLASH_PROFILERSHOW1 = "/pfshow";
SLASH_PROFILERSHOW2 = "/pf";
SlashCmdList["PROFILERSHOW"] = function(msg)
	Profiler:Show();
end

SLASH_PROFILERCPUSTART1 = "/cpustart";
SlashCmdList["PROFILERCPUSTART"] = function(msg)
	if(GetCVar("scriptProfile")=="1") then
		DEFAULT_CHAT_FRAME:AddMessage("You have already enabled script profiling.");
	else
		SetCVar("scriptProfile", "1");
		ReloadUI();
	end;
end

SLASH_PROFILERCPUSTOP1 = "/cpustop";
SlashCmdList["PROFILERCPUSTOP"] = function(msg)
	if(GetCVar("scriptProfile")=="0") then
		DEFAULT_CHAT_FRAME:AddMessage("You haven't enabled script profiling.");
	else
		SetCVar("scriptProfile", "0");
		ReloadUI();
	end;
end

Profiler_AddonData = {};
ProfilerTempData = {};

function ProfilerScrollFrame_Update()
	local k,line,offset,count,sortType;

	count=0;
	for _, v in pairs(Profiler_AddonData) do
		if(v and v.enabled)then count=count+1 end
	end
	FauxScrollFrame_Update(ProfilerScrollFrame,count,30,12);

	local data = ProfilerTempData;
	for k,_ in pairs(data) do
		data[k] = nil;
	end
	if(count ~= getn(data)) then
		for k,_ in pairs(data) do
			data[k] = nil;
		end
		k = 0;
		for _, v in pairs(Profiler_AddonData) do
			if(v and v.enabled)then
				k = k+1;
				data[k] = v;
			end
		end
	end

	table.sort(data, function (a,b)
		local sortType = Profiler.sortType; --1 name 2 cpu 3cpumax 4cpuavg 5mem 6memmax
		if(sortType==2) then
			return a.CPUCurr > b.CPUCurr;
		elseif(sortType==3) then
			return a.CPUMax > b.CPUMax;
		elseif(sortType==4) then
			return a.CPUAvg > b.CPUAvg;
		elseif(sortType==5) then
			return a.MemCurr > b.MemCurr;
		elseif(sortType==6) then
			return a.MemMax > b.MemMax;
		else
			return a.name < b.name;
		end
	end)
	


	if(not FauxScrollFrame_GetOffset(ProfilerScrollFrame)) then
		offset = 1;
	else
		offset=FauxScrollFrame_GetOffset(ProfilerScrollFrame)+1;
	end

	line=1
	while line<=30 do
		if offset<=table.getn(data) then
			local addon=data[offset];

			getglobal("ProfilerButton"..line):Show();
			getglobal("ProfilerButton"..line).offset = offset;

			getglobal("ProfilerButton"..line.."Name"):SetText(addon.name);
			getglobal("ProfilerButton"..line.."CPUCurr"):SetText(ProfilerFormat("%.2f", addon.CPUCurr));
			getglobal("ProfilerButton"..line.."CPUMax"):SetText(ProfilerFormat("%.2f",addon.CPUMax));
			getglobal("ProfilerButton"..line.."CPUAvg"):SetText(ProfilerFormat("%.2f",addon.CPUAvg));
			getglobal("ProfilerButton"..line.."MemCurr"):SetText(ProfilerFormat("%.1f",addon.MemCurr).."K");
			getglobal("ProfilerButton"..line.."MemMax"):SetText(ProfilerFormat("%.1f",addon.MemMax).."K");

			line=line+1
		else
			getglobal("ProfilerButton"..line):Hide();
			line=line+1
		end
		offset=offset+1
	end
end

function ProfilerFormat(fmt, value)
	if(not value) then return " - "; end;
	local a = format(fmt,value);
	if(a==format(fmt,0)) then return " - "; end;
	return a;
end;

function ProfilerUpdate(elapsed)
	if(PROFILER_STARTED) then
		this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + elapsed; 
		this.TimeSinceLastStart = this.TimeSinceLastStart + elapsed;

		if (this.TimeSinceLastUpdate > PROFILER_INTERVAL) then
			UpdateAddOnMemoryUsage();
			UpdateAddOnCPUUsage();

			for i=1, GetNumAddOns() do
				local name,_,_,enabled = GetAddOnInfo(i);

				if (not Profiler_AddonData[i]) then
					Profiler_AddonData[i] = {};
					Profiler_AddonData[i].name = name;
				end

				local addon = Profiler_AddonData[i];
				addon.enabled = enabled;
				
				addon.MemCurr = GetAddOnMemoryUsage(i);
				if( not addon.MemMax or addon.MemMax < addon.MemCurr ) then addon.MemMax = addon.MemCurr end;

				local cpuCount = GetAddOnCPUUsage(i);
				if(addon.cpuCountLast) then
					addon.CPUCurr = (cpuCount - addon.cpuCountLast) / PROFILER_INTERVAL;
					if( not addon.CPUMax or addon.CPUMax < addon.CPUCurr ) then addon.CPUMax = addon.CPUCurr end;
				end
				addon.cpuCountLast = cpuCount;

				addon.CPUAvg = cpuCount / this.TimeSinceLastStart;
			end
			
			local total = GetScriptCPUUsage();
			if(this.cpuCountLast) then
				ProfilerStart:SetText( format("%.2f",(total - this.cpuCountLast) / PROFILER_INTERVAL) );
			end
			this.cpuCountLast = total;

			if(Profiler:IsVisible()) then ProfilerScrollFrame_Update(); end;
			this.TimeSinceLastUpdate = 0;
		end
	end
end