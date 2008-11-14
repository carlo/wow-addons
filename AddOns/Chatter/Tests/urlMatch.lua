local urls = {
	"http://www.wowace.com/projects/broker_durability/repositories/mainline/",
	"www.lol-lol.com"
}

local tlds
local style = "|cffffffff|Hurl:%s|h[%s]|h|r"
local function Link(link, ...)
	if link == nil then
		return ""
	end
	return "[[" .. link .. "]]"
end
local function Link_TLD(link, tld, ...)
	if link == nil or tld == nil then
		return ""
	end
	return "[[" .. link .. "]]"
end

local patterns = {
		-- X://Y url
	{ pattern = "^(%a[%w%.+-]+://%S+)", matchfunc=Link},
	{ pattern = "%f[%S](%a[%w%.+-]+://%S+)", matchfunc=Link},
		-- www.X.Y url
	{ pattern = "^(www%.[-%w_%%]+%.%S+)", matchfunc=Link},
	{ pattern = "%f[%S](www%.[-%w_%%]+%.%S+)", matchfunc=Link},
		-- "W X"@Y.Z email (this is seriously a valid email)
	--{ pattern = '^(%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
	--{ pattern = '%f[%S](%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
		-- X@Y.Z email
	{ pattern = "(%S+@[-%w_%%%.]+%.(%a%a+))", matchfunc=Link_TLD},
		-- XXX.YYY.ZZZ.WWW:VVVV/UUUUU IPv4 address with port and path
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW:VVVV IPv4 address with port (IP of ts server for example)
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW/VVVVV IPv4 address with path
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", matchfunc=Link},
		-- XXX.YYY.ZZZ.WWW IPv4 address
	{ pattern = "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", matchfunc=Link},
	{ pattern = "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", matchfunc=Link},
		-- X.Y.Z:WWWW/VVVVV url with port and path
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", matchfunc=Link_TLD},
		-- X.Y.Z:WWWW url with port (ts server for example)
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", matchfunc=Link_TLD},
		-- X.Y.Z/WWWWW url with path
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
		-- X.Y.Z url
	{ pattern = "^([-%w_%%%.]+[-%w_%%]%.(%a%a+))", matchfunc=Link_TLD},
	{ pattern = "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+))", matchfunc=Link_TLD},
}

for k, url in ipairs(urls) do
	s = ("some text blah blah %s blah blah"):format(url)
	local matched = false
	for i, v in ipairs(patterns) do
		ns = string.gsub(s, v.pattern, v.matchfunc)
		if ns:match("%[%" .. url .. "%]%]") then
			matched = true
		end
	end
	print(matched and "valid" or "INVALID", url)
end
