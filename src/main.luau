local RunService = game:GetService("RunService")
local GIT_BASE = "https://raw.githubusercontent.com/Mathchop/nte/refs/heads/main/"

if not RunService:IsStudio() then
	local cache = {}
	local loading = {}

	local function gitRequire(path, dir)
		dir = dir or ""

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

		local key = table.concat(parts, "/"):gsub("%.luau$", "")

		if cache[key] ~= nil then
			return cache[key]
		end
		if loading[key] then
			error("Dépendance circulaire sur '" .. key .. "'")
		end
		loading[key] = true

		local source = game:HttpGet(GIT_BASE .. key .. ".luau")
		local fn, err = loadstring(source, "@" .. key)
		if not fn then
			loading[key] = nil
			error("Compilation de " .. key .. " : " .. tostring(err))
		end

		local newDir = key:match("^(.*)/[^/]*$") or ""
		local env = setmetatable({
			require = function(p)
				return gitRequire(p, newDir)
			end,
		}, { __index = getfenv() })
		setfenv(fn, env)

		local result = fn()
		cache[key] = result
		loading[key] = nil
		return result
	end
end

local NTE = require("./NTE")
NTE.start()