-- LANG

local errors = {
	"Different tabs",
	"Bad tabs",
	"Cheops pyramid",
	"Use of table.HasValue",
	"Semicolon",
	"Use of table.Random",
	"Bunch of locals",
	"Timer simple",
	"Static objects on runtime",
	"Table creation on runtime",
	"Table insert",
}

-- START

local file = io.input(({ ... })[1])

function string:split(sChars) local tbl = {} for str in self:gmatch("([^"..sChars.."]+)") do tbl[#tbl + 1] = str end return tbl end

-- INIT

print("[GLSC] GLua Syntax Checker made by Zohart.\n")

local warns = 0
function log_warning(line, code, comm) warns = warns + 1 print("Line " .. line .. ": " .. code .. " - " .. errors[code] .. (comm and " (" .. comm .. ")" or "")) end

-- VARS

local tabcs, badtabcs, untabcs, untabcsb, untabcsa, statics, tabs = {
	".*if.*then.*",
	".*function.*%(.*%).*",
	".*for.*do.*",
	".*else.*",
}, {
	".*if.*then.*end.*",
	".*function.*%(.*%).*end.*",
	".*for.*do.*end.*",
}, {
	"end",
	"else",
	"elseif",
}, {
	[" "] = true,
	[""] = true,
	["\t"] = true
}, {
	[" "] = true,
	[";"] = true,
	[")"] = true,
	[""] = true,
	["\t"] = true,
	["("] = true
}, {
	"Material",
	"Color",
	"GetConVar",
	"Model",
}, {
	[32] = "spaces",
	[9] = "tabs"
}

-- MAIN

local tabc, lastloc, lasttab = 0
function check_line(str, line)
	local _tab = str:match("(%s*).*")
	local tab = string.byte(_tab or "")

	-- CHECK IF STRING CONTAINS BAD TABS

	local isgood = true

	for k, v in ipairs(badtabcs) do
		if(str:match(v))then isgood = false break end
	end

	-- TABS

	if(isgood)then
		for k, v in ipairs(untabcs) do
			local before, _end, after = str:match("(.*)(" .. v .. ")(.*)")

			if(_end)then
				local bs, as = before:sub(-1, -1), after:sub(1, 1)
				if(untabcsb[bs] and untabcsa[as])then tabc = tabc - 1 break end
			end
		end
	end

	local symb = _tab:sub(1)

	if(lasttab and _tab)then
		local byte = symb:byte()
		if(byte and byte ~= lasttab.byte)then log_warning(line, 1, "using " .. tabs[byte] .. ", not " .. tabs[lasttab.byte]) end
		
		local curr, size = _tab:len(), lasttab.size
		if(str ~= "" and curr ~= size * tabc)then log_warning(line, 2, "got " .. math.floor(curr / size) .. " instead of " .. tabc) end
	elseif(tabc > 0)then
		if(symb ~= "")then lasttab = { size = _tab:len() / tabc, symbol = symb, byte = symb:byte() } end
	elseif(symb ~= "")then
		log_warning(line, 2, "got " .. math.floor(symb:len() / (lasttab and lasttab.size or 1)) .. " instead of 0")
	end

	if(tabc > 2)then log_warning(line, 3, tabc .. " if's for one thing!") end

	-- ALMOST USELESS THINGS

	if(str:match(".*table%.HasValue.*"))then log_warning(line, 4, "check if you can replace it with tab[val]") end
	if(str:match(".*;.*"))then log_warning(line, 5) end
	if(str:match(".*table%.Random.*"))then log_warning(line, 6, "check if you can replace it with tab[math.random(#tab)]") end

	-- LOCALS

	local names, vals = str:match(".*local%s*(.+)%s*=%s*(.+).*")
	if(names)then
		local _names, _vals = names:split(","), vals:split(",")
		
		if(lastloc)then
			for k, v in ipairs(_vals) do
				v = v:gsub("%s", "")

				local skip = false
				for i, j in ipairs(lastloc) do
					j = j:gsub("%s", "")
					
					if(v:find(j))then skip = true break
					elseif(v:find("%\""))then log_warning(line, 7) skip = true break end
				end

				if(skip)then break end
			end
		end

		lastloc = _names
	end

	-- RETURNS

	if(isgood and str:match(".*return.*"))then lastloc = nil end

	-- OTHER

	if(tabc > 0)then

		-- STATICS

		for k, v in ipairs(statics) do
			if(str:match(".*" .. v .. ".*"))then log_warning(line, 9, "creating " .. v) end
		end

		-- TABLES

		if(str:match(".*{.*"))then log_warning(line, 10, "check if you can localize it") end
	else
		if(str:match(".*table%.Insert.*"))then log_warning(line, 11, "are you sure it is needed here?") end
		if(str:match(".*timer%.Simple.*"))then log_warning(line, 8, "are you sure it is needed here?") end
	end

	-- SHOULD NEXT STRING BE A TAB?

	if(isgood)then
		for k, v in ipairs(tabcs) do
			if(str:match(v))then lastloc = nil tabc = tabc + 1 break end
		end
	end
end

-- READ

local start, i = os.clock(), 1
for line in file:lines() do
	check_line(line, i)
	i = i + 1
end

print("\n[GLSC] Scanning complete in " .. os.clock() - start .. "s! Found " .. warns .. " warnings.")
print("\n[GLSC] This information is not 100% perfect and not 100% full. Please check code additionally by yourself.")

while(true)do end
