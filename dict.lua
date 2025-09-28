local synapse: table = assert(syn, "~ get your syn module at https://github.com/ProphecySkondo/Misc/blob/main/Syn/main.lua")

local zyn: table = {
	invite = syn.discord.prompt_to_join_server;
}
local link: string = "vpNQTYgA"
local globalenv: table = getgenv and getgenv() or _G or shared
local globalcontainer: table = globalenv.globalcontainer

do
	assert(globalenv, "~")

	if not globalcontainer then
		globalcontainer = {}
		globalenv.globalcontainer = globalcontainer
	end
end

local genvs: table = { _G, shared }
if getgenv then
	table.insert(genvs, getgenv())
end

local calllimit: number = 0

do
	local function determineCalllimit(): nil
		calllimit = calllimit + 1
		determineCalllimit()
	end
	pcall(determineCalllimit)
end

local function isEmpty(dict: table): boolean
	for _ in next, dict do
		return
	end
	return true
end

local depth: number, printresults: boolean, hardlimit: number, query: table, antioverflow: table, matchedall: boolean -- prevents infinite / cross-reference
local function recurseEnv(env: table, envname: string): nil
	if globalcontainer == env then
		return
	end
	if antioverflow[env] then
		return
	end
	antioverflow[env] = true

	depth = depth + 1
	for name, val in next, env do
		if matchedall then
			break
		end

		local Type: string = type(val)

		if Type == "table" then
			if depth < hardlimit then
				recurseEnv(val, name)
			else
				-- warn("almost stack overflow")
			end
		elseif Type == "function" then -- This optimizes the speeds but if someone manages (??) to fool this then rip
			name = string.lower(tostring(name))
			local matched: table
			for methodname, pattern in next, query do
				if pattern(name, envname) then
					globalcontainer[methodname] = val
					if not matched then
						matched = {}
					end
					table.insert(matched, methodname)
					if printresults then
						print(methodname, name)
					end
				end
			end
			if matched then
				for _, methodname in next, matched do
					query[methodname] = nil
				end
				matchedall = isEmpty(query)
				if matchedall then
					break
				end
			end
		end
	end
	depth = depth - 1
end

local function finder(Query: table, ForceSearch: boolean, CustomCallLimit: number, PrintResults: boolean): nil
	antioverflow = {}
	query = {}

	do
		local function Find(String: string, Pattern: string): boolean
			return string.find(String, Pattern, nil, true)
		end
		for methodname, pattern in next, Query do
			if not globalcontainer[methodname] or ForceSearch then
				if not Find(pattern, "return") then
					pattern = "return " .. pattern
				end
				query[methodname] = loadstring(pattern)
			end
		end
	end

	depth = 0
	printresults = PrintResults
	hardlimit = CustomCallLimit or calllimit

	recurseEnv(genvs)

	do
		local env: table = getfenv()
		for methodname in next, Query do
			if not globalcontainer[methodname] then
				globalcontainer[methodname] = env[methodname]
			end
		end
	end

	hardlimit = nil
	depth = nil
	printresults = nil

	antioverflow = nil
	query = nil
end

do
	zyn.invite(link)
end

return finder, globalcontainer
