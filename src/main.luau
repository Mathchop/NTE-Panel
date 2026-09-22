local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GIT_USER = "Mathchop"
local GIT_REPO = "NTE-Panel"
local GIT_BRANCH = "test"

local gitCache = {}
local gitLoading = {}
local gitKnown = {}

local gitShaCache = nil

local requireFunc: () -> ()

local function gitEnv(target: number | string, dir: string?)
	local env = setmetatable({
		gitRequire = RunService:IsStudio() and require or requireFunc,
		directory = dir or ""
	}, {__index = getfenv()})

	setfenv(target, env)
end

local function getGitRawUrl(sha: string?, path: string)
	return ("https://raw.githubusercontent.com/%s/%s/%s/%s"):format(GIT_USER, GIT_REPO, sha or GIT_BRANCH, path)
end

local function fetchGitSha()
	if gitShaCache then
		return gitShaCache
	end
	
	local url = ("https://api.github.com/repos/%s/%s/commits/%s"):format(GIT_USER, GIT_REPO, GIT_BRANCH)
	print("FETCHING GIT SHA: ".. url)

	local response = request({
		Url = url,
		Method = "GET",
		Headers = {
			["User-Agent"] = "NTE-Panel",
			["Accept"] = "application/vnd.github+json",
		},
	})

	if response and response.Body then
		local data = HttpService:JSONDecode(response.Body)

		print("GOT SHA!: "..data.sha)
		
		gitShaCache = data.sha
		return data.sha
	end
end

local function fetchRaw(sha: string?, path: string)
	local url = getGitRawUrl(sha, path)
	print("FETCHING GIT RAW: "..url)

	return game:HttpGet(url)
end

if not RunService:IsStudio() then
	print("NOT STUDIO")

	requireFunc = function(path)
		local dir = ""
		local caller = (debug.info(2, "s") or ""):gsub("^[@=]", "")

		if gitKnown[caller] then
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

		if gitCache[key] ~= nil then
			return gitCache[key]
		end

		if gitLoading[key] then
			error("Dépendance circulaire sur '" .. key .. "'")
		end

		gitLoading[key] = true

		local sha = fetchGitSha()
		local finalPath = "src/".. key ..".luau"

		local source = fetchRaw(sha, finalPath)
		local content, err = loadstring(source, "@" .. key)

		if not content then
			gitLoading[key] = nil
			error("Compilation de " .. key .. " : " .. tostring(err))
		end

		local newDir = key:match("^(.*)/[^/]*$") or ""
		gitEnv(content, newDir)

		gitKnown[key] = true

		local result = content()
		gitCache[key] = result
		gitLoading[key] = nil
		return result
	end
	
	_G.gitRequire = requireFunc
else
	_G.gitRequire = require
end

gitEnv(1)

print("STARTING NTE")
local NTE = _G.gitRequire("./NTE")
NTE.start()