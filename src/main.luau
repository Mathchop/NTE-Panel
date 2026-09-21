local RunService = game:GetService("RunService")
local GIT_BASE = "https://raw.githubusercontent.com/Mathchop/nte/refs/heads/main/"

if not RunService:IsStudio() then
	print("NOT STUDIO")
	
	local cache = {}
	local loading = {}
	
	local function fetch(url)
		print("FETCHING URL: ".. url)
		return game:HttpGet(url)
	end

	local cache = {}
	local loading = {}
	local known = {}

	local function gitRequire(path)
		local dir = ""
		local caller = (debug.info(2, "s") or ""):gsub("^[@=]", "")
		if known[caller] then
			dir = caller:match("^(.*)/[^/]*$") or ""
		end

		local parts = {}
		if path:sub(1, 2) == "./" or path:sub(1, 3) == "../" then
			for seg in dir:gmatch("[^/]+") do
				table.insert(parts, seg)
			end
		end

		for seg in path:gmatch("[^/]+") do
			if seg == ".." then
				if #parts == 0 then
					error("Le chemin '" .. path .. "' sort de la racine du dépôt", 2)
				end
				table.remove(parts)
			elseif seg ~= "." then
				table.insert(parts, seg)
			end
		end

		local key = (table.concat(parts, "/"):gsub("%.luau$", ""))

		if cache[key] ~= nil then
			return cache[key]
		end
		if loading[key] then
			error("Dépendance circulaire sur '" .. key .. "'")
		end
		loading[key] = true
		
		local finalPath = GIT_BASE .. key .. ".luau?t=" .. os.time()
		print("REQUIRING LUAU OF PATH: "..finalPath)

		local source = fetch(finalPath)
		local fn, err = loadstring(source, "@" .. key)
		if not fn then
			loading[key] = nil
			error("Compilation de " .. key .. " : " .. tostring(err))
		end

		known[key] = true
		local result = fn()
		cache[key] = result
		loading[key] = nil
		return result
	end

	_G.gitRequire = gitRequire
else
	_G.gitRequire = require
end

print(_G)
print("STARTING NTE")
local NTE = _G.gitRequire("./NTE")
NTE.start()