local syn
local services
local params = {
	RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
	SSI = "saveinstance",
}

local function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

local function rawport(...)
	return loadstring(game:HttpGetAsync(...))()
end

local function information(...)
	return { ... }
end

local cloneref = missing("function", cloneref, function(...) return ... end)
local httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
local everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
local queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
local hui = missing("function", gethui or get_hidden_gui or (syn and syn.protect_gui))
local setthreadidentity = missing("function", setthreadidentity or (syn and syn.set_thread_identity) or syn_context_set or setthreadcontext)
local real_secure_call =
    		secure_call
  		or rsecure_call
  		or protect_call
  		or (syn and syn.secure_call)
  		or (getgenv and getgenv().syn and getgenv().syn.secure_call)
local loader = loadstring or load

services = setmetatable({}, {
	__index = function(_, name)
		return cloneref(game:GetService(name))
	end,
	__call = function(self, name)
		return self[name]
	end
})

--encryptions (skip this, or not)

local function base64encode(data)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  return ((data:gsub('.', function(x)
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r;
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

local function base64decode(data)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  data = data:gsub('[^'..b..'=]', '')
  return (data:gsub('.', function(x)
    if (x == '=') then return '' end
    local r,f='',(b:find(x)-1)
    for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
    return r;
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if (#x ~= 8) then return '' end
    local c=0
    for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
    return string.char(c)
  end))
end

local band = bit32.band
local rrotate = bit32.rrotate
local bxor = bit32.bxor
local rshift = bit32.rshift
local bnot = bit32.bnot

local function str2hexa (s)
  return (s:gsub(".", function(c)
    return string.format("%02x", c:byte())
  end))
end

local function num2s (l, n)
  local s = ""
  for i = 1, n do
    local rem = l % 256
    s = string.char(rem) .. s
    l = (l - rem) / 256
  end
  return s
end

local function s232num (s, i)
  local n = 0
  for j = i, i + 3 do
    n = n*256 + s:byte(j)
  end
  return n
end

local function preproc (msg, len)
  local extra = 64 - ((len + 9) % 64)
  len = num2s(8 * len, 8)
  msg = msg .. "\128" .. string.rep("\0", extra) .. len
  assert(#msg % 64 == 0)
  return msg
end

local function initH256 (H)
  H[1] = 0x6a09e667
  H[2] = 0xbb67ae85
  H[3] = 0x3c6ef372
  H[4] = 0xa54ff53a
  H[5] = 0x510e527f
  H[6] = 0x9b05688c
  H[7] = 0x1f83d9ab
  H[8] = 0x5be0cd19
  return H
end

local k = {
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function digestblock (msg, i, H)
  local w = {}
  for j = 1, 16 do
    w[j] = s232num(msg, i + (j - 1)*4)
  end
  for j = 17, 64 do
    local v = w[j - 15]
    local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
    v = w[j - 2]
    local s1 = bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
    w[j] = w[j - 16] + s0 + w[j - 7] + s1
  end
  local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
  for j = 1, 64 do
    local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
    local maj = bxor(band(a, b), band(a, c), band(b, c))
    local t2 = s0 + maj
    local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
    local ch = bxor(band(e, f), band(bnot(e), g))
    local t1 = h + s1 + ch + k[j] + w[j]
    h = g
    g = f
    f = e
    e = d + t1
    d = c
    c = b
    b = a
    a = t1 + t2
  end
  H[1] = band(H[1] + a)
  H[2] = band(H[2] + b)
  H[3] = band(H[3] + c)
  H[4] = band(H[4] + d)
  H[5] = band(H[5] + e)
  H[6] = band(H[6] + f)
  H[7] = band(H[7] + g)
  H[8] = band(H[8] + h)
end

local function sha256 (msg)
  msg = preproc(msg, #msg)
  local H = initH256({})
  for i = 1, #msg, 64 do
    digestblock(msg, i, H)
  end
  return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) .. num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
end

--// ~ by konstant

do
	assert(getscriptbytecode, "Exploit not supported.")
	assert(type(httprequest) == "function", "No http request function available.")

	local API: string = "http://api.plusgiant5.com"

	local last_call = 0
	local function call(konstantType: string, scriptPath: Script | ModuleScript | LocalScript): string
    	local success: boolean, bytecode: string = pcall(getscriptbytecode, scriptPath)

    	if (not success) then
    	    return `-- Failed to get script bytecode, error:\n\n--[[\n{bytecode}\n--]]`
    	end

    	local time_elapsed = os.clock() - last_call
    	if time_elapsed <= .5 then
    	    task.wait(.5 - time_elapsed)
    	end
    	local httpResult = httprequest({
    	    Url = API .. konstantType,
    	    Body = bytecode,
    	    Method = "POST",
    	    Headers = {
    	        ["Content-Type"] = "text/plain"
    	    },
    	})
    	last_call = os.clock()

    	if (httpResult.StatusCode ~= 200) then
    	    return
    	else
    	    return httpResult.Body
    	end
	end

	local function newdecompile(scriptPath: Script | ModuleScript | LocalScript): string
	    return call("/konstant/decompile", scriptPath)
	end

	local function newdisassemble(scriptPath: Script | ModuleScript | LocalScript): string
	    return call("/konstant/disassemble", scriptPath)
	end

	getgenv().newdecompile = newdecompile
	getgenv().newdisassemble = newdisassemble
end

--// ~ synapse x

local function getsynasset(assetid: number)
	information([[
		this is just quite self explainatory
	]])

	assert(typeof(assetid) ~= number, "make sure its a number goofy")
	return "rbxassetid://" .. assetid
end

syn = {
	--// ~ new synapse functions

	credits = function()
		syn.notify("Api By Xeon", "Discord Server Is https://discord.gg/DNbfshRhgq", 30, getsynasset(135561165984389))
	end,

	service = function(serviceName)
		return services(serviceName)
	end,

	notify = function(title, message, duration, asset)
		syn.service("StarterGui"):SetCore("SendNotification", {
			Title = title or "https://discord.gg/DNbfshRhgq",
			Text = tostring(message) or "",
			Duration = duration or 10,
			Icon = asset or getsynasset(135561165984389)
		})
	end,

	DEX = function()
		syn.web.Import("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua")
	end,

	IY = function()
		syn.web.Import("https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source")
	end,

	helpers = {
		get_remotes = function(service)
			local remotes = {}

			for i, v in ipairs(syn.service(service):GetDescendants()) do
				if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
					table.insert(remotes, v)
				end
			end
			return remotes
		end,
	},

	web = {
		Import = function(rawURL)
			rawport(rawURL)
		end,
		Post = function(url, payload)
			local HttpService = syn.service("HttpService")
			assert(type(url) == "string", "url must be a string")

			local encodedPayload = HttpService:JSONEncode(payload)

			httprequest({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = encodedPayload
			})
		end,
	},

	discord = {
		create_embed = function(content, embedTitle, embedDescription, embedColor, thumbnailUrl, imageUrl, ...)
    		return {
    		    content = content,
    		    embeds = {{
    		        title = embedTitle,
    		        description = embedDescription,
    		        color = embedColor,
    		        thumbnail = thumbnailUrl and { url = thumbnailUrl } or nil,
    		        image = imageUrl and { url = imageUrl } or nil,
    		        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    		        fields = { ... }
    		    }}
    		}
		end,

		post_to_webhook = function(webhook, payload)
			return syn.web.Post(
				webhook,
				payload
			)
		end,

		prompt_to_join_server = function(invitelink)
			print("beta, not finished yet and probably wont until i make my own executer")
			return invitelink
		end,
	},

	scripts = {
		decompile_local_script = function(obj)
			assert(obj:IsA("LocalScript"), "Has to be local script")
			return newdecompile(obj)
		end,
		decompile_module_script = function(obj)
			assert(obj:IsA("ModuleScript"), "Has to be a module script")
			return newdecompile(obj)
		end,
		disassemble_local_script = function(obj)
			assert(obj:IsA("LocalScript"), "Has to be local script")
			return newdisassemble(obj)
		end,
		disassemble_module_script = function(obj)
			assert(obj:IsA("ModuleScript"), "Has to be module script")
			return newdisassemble(obj)
		end,
	},

	manipulation = {
		replace_class = function(obj, replacer)
				information([[
					this to put it simply just deletes a instance and replaces it with another instance thats just like it. if they match whats in the tables
				]])
			assert(typeof(obj) == "Instance", "~ has to be a Instance")
			assert(type(replacer) == "string", "~ replacer must be a string")
			local matches = {
				MeshPart = { "Part" },
				Part = { "MeshPart", "WedgePart", "CornerWedgePart", "Seat", "VehicleSeat", "SpawnLocation" },
				WedgePart = { "Part" },
				CornerWedgePart = { "Part" },
				UnionOperation = { "Part" },
				Seat = { "Part", "VehicleSeat" },
				VehicleSeat = { "Seat", "Part" },
				Model = { "Folder" },
				Folder = { "Model" },
				ScreenGui = { "BillboardGui", "SurfaceGui" },
				BillboardGui = { "ScreenGui", "SurfaceGui" },
				SurfaceGui = { "ScreenGui", "BillboardGui" },
				TextLabel = { "TextButton", "ImageLabel", "ImageButton" },
				TextButton = { "TextLabel", "ImageButton", "ImageLabel" },
				ImageLabel = { "ImageButton", "TextLabel" },
				ImageButton = { "ImageLabel", "TextButton" },
				Decal = { "Texture" },
				Texture = { "Decal" },
				Tool = { "HopperBin" },
				HopperBin = { "Tool" },
				BodyPosition = { "VectorForce" },
				VectorForce = { "BodyPosition" },
				Sound = { "Sound" },
				ParticleEmitter = { "ParticleEmitter" },
				Mesh = { "SpecialMesh" },
				SpecialMesh = { "Mesh" },
			}
			local src = obj.ClassName
			local allowed = matches[src]
			if not allowed then return error("[replacer]: no replacement rules for "..tostring(src), 2) end
			local ok = false
			for _,v in ipairs(allowed) do if v == replacer then ok = true break end end
			if not ok then return error("[replacer]: cannot replace "..tostring(src).." with "..tostring(replacer), 2) end
			local function copy_props(s,d,props)
				for _,p in ipairs(props) do
					local ok1, val = pcall(function() return s[p] end)
					if ok1 then
						pcall(function() d[p] = val end)
					end
				end
			end
			local common = {
				"Name","Archivable","Parent","Transparency","Anchored","CanCollide","CanTouch","CanQuery","CanCollideWith",
				"Size","CFrame","Position","Orientation","Rotation","Velocity","Massless","Material","BrickColor","Color",
				"Reflectance","CastShadow","TopSurface","BottomSurface","Shape","ZIndex","Visible","Enabled","Image","ImageColor3",
				"ImageTransparency","BackgroundColor3","BackgroundTransparency","BorderColor3","BorderSizePixel","Text","Font",
				"TextSize","TextColor3","TextWrapped","TextXAlignment","TextYAlignment","AutomaticSize","LayoutOrder","Active"
			}
			local new = Instance.new(replacer)
			copy_props(obj,new,common)
			new.Name = obj.Name
			local attrs = {}
			pcall(function() attrs = obj:GetAttributes() end)
			for k,v in pairs(attrs) do
				pcall(function() new:SetAttribute(k, v) end)
			end
			local CollectionService = game:GetService("CollectionService")
			pcall(function()
				local tags = CollectionService:GetTags(obj)
				for _,t in ipairs(tags) do CollectionService:AddTag(new, t) end
			end)
			if obj:IsA("MeshPart") and replacer == "Part" then
				local meshId, texId, mt, sScale = nil, nil, nil, nil
				pcall(function() meshId = obj.MeshId end)
				pcall(function() texId = obj.TextureID end)
				pcall(function() mt = obj.MeshType end)
				pcall(function() sScale = obj.Size end)
				local sm = Instance.new("SpecialMesh")
				if meshId and meshId ~= "" then pcall(function() sm.MeshId = meshId end) end
				if texId and texId ~= "" then pcall(function() sm.TextureId = texId end) end
				pcall(function() sm.MeshType = mt end)
			pcall(function() sm.Scale = Vector3.new(1,1,1) end)
				sm.Parent = new
			elseif obj:IsA("Part") and replacer == "MeshPart" then
				local special = obj:FindFirstChildOfClass("SpecialMesh")
				if special then
					pcall(function() new.MeshId = special.MeshId end)
					pcall(function() new.TextureID = special.TextureId end)
				end
				pcall(function() new.CustomPhysicalProperties = obj.CustomPhysicalProperties end)
			end
			if (obj:IsA("Model") and new:IsA("Folder")) or (obj:IsA("Folder") and new:IsA("Model")) then
			for _,child in ipairs(obj:GetChildren()) do
					local c = child:Clone()
					c.Parent = new
				end
			else
				for _,child in ipairs(obj:GetChildren()) do
					local c = child:Clone()
					c.Parent = new
				end
			end
			new.Parent = obj.Parent
			obj:Destroy()
			return new
		end,
		fake_collision = function(point, ...)
			information([[
				for hitbox things, i'll prolly do this once i get a better executer and read more about enviornments nd shi
			]])
			return nil
		end,

		break_console = function()
			syn.notify("BETA", "Your using a very beta function right now, it might fuck up the console")
			
			local coreGui = syn.service("CoreGui")
			local devconsoleMaster = coreGui:FindFirstAncestor("DevConsoleMaster") or coreGui:FindFirstChild("DevConsoleMaster")
			local ConsoleWindow = devconsoleMaster:FindFirstChild("DevConsoleWindow")
			local ConsoleUi = ConsoleWindow:FindFirstChild("DevConsoleUI")
			local MainView = function()
				repeat
					task.wait();
				until ConsoleUi:FindFirstChild("MainView")
				return ConsoleUi:FindFirstChild("MainView")
			end
			local ClientLog = MainView():FindFirstChild("ClientLog")

			for i, v in ipairs(ClientLog:GetChildren()) do
				v:ClearAllChildren()
			end
		end,
	},

	--(don't complain that these functions aren't written fully from nothing, i don't have access to change the backend of executers)

	is_beta = function()
		return true
	end,

	request = function(options)
		if not httprequest then
			warn("request not supported")
			return { Success = false, StatusCode = 0, Body = "", Headers = {} }
		end
		local response = httprequest(options)
		return {
			StatusCode = response.StatusCode or response.Status,
			Body = response.Body,
			Headers = response.Headers,
			Success = response.Success
		}
	end,

	write_clipboard = function(content)
		if everyClipboard then
			everyClipboard(content)
		else
			warn("write_clipboard not supported")
		end
	end,

	queue_on_teleport = function(code)
		if queueteleport then
			return queueteleport(code)
		else
			warn("queue_on_teleport not supported")
		end
	end,

	sticky_code = function(code)
		if queueteleport then
			return queueteleport(code)
		else
			warn("queue_on_teleport not supported")
		end
	end,

	protect_gui = function(gui)
		if hui then
			gui.Parent = hui()
		else
			gui.Parent = game:GetService("CoreGui")
		end
		return gui
	end,

	unprotect_gui = function(gui)
		local players = syn.service("Players")
		local plr = players.LocalPlayer

		if plr and plr:FindFirstChildWhichIsA("PlayerGui") then
			gui.Parent = plr:FindFirstChildWhichIsA("PlayerGui")
		else
			gui.Parent = syn.service("CoreGui")
		end
		return gui
	end,

	synsaveinstance = function(options)
		local protocol = loadstring(game:HttpGet(params.RepoURL .. params.SSI .. ".luau", true), params.SSI)()
		protocol(options)
	end,

	set_thread_identity = function(id)
		if setthreadidentity then
			return setthreadidentity(id)
		else
			warn("set_thread_identity not supported")
		end
	end,

	-- crypt functions

	crypt = {
		encrypt = function(data, key)
			local byte = string.byte
			local char = string.char
			local result = ""
			local j = 1
			for i = 1, #data do
				result = result .. char(bxor(byte(data, i), byte(key, j)))
				j = j + 1
				if j > #key then
					j = 1
				end
			end
			return result
		end,
		decrypt = function(data, key)
			return syn.crypt.encrypt(data, key)
		end,
		base64encode = base64encode,
		base64decode = base64decode,
		hash = sha256,
		derive = function(value, len)
			local h = sha256(value)
			local result = h
			while #result < len do
				h = sha256(h .. value)
				result = result .. h
			end
			return result:sub(1, len)
		end,
		random = function(size)
			if size < 0 or size > 1024 then error("Size must be between 0 and 1024") end
			local result = ""
			for _ = 1, size do
				result = result .. string.char(math.random(0, 255))
			end
			return result
		end,
		custom_encrypt = function(cipher, data, key, iv)
			return syn.crypt.encrypt(data, key)
		end,
		custom_decrypt = function(cipher, data, key, iv)
			return syn.crypt.decrypt(data, key)
		end,
		custom_hash = function(algorithm, data)
			return sha256(data)
		end,
	}
}

syn._context = syn._context or {}

-- other functions

syn.secure_call = function(fn_or_code, ...)
    local args = { ... }
    local callable

    if type(fn_or_code) == "string" then
        local f, err = loader(fn_or_code)
        if not f then error(err, 2) end
        callable = f
    elseif type(fn_or_code) == "function" then
        callable = fn_or_code
    else
        error("secure_call expects a function or string", 2)
    end

    if real_secure_call then
        return real_secure_call(callable, unpack(args))
    else
        return callable(unpack(args))
    end
end

syn._context_set = function(key, value)
	assert(type(key) == "string", "dumbahh")
	syn._context[key] = value
end

syn._context_get = function(key)
	assert(type(key) == "string", "dumbahh")
	return syn._context[key]
end

--// ~ script by marty, discord server is https://discord.gg/DNbfshRhgq join xeon
--// ~ getgenv().syn = syn

do
	print("~ discord server is https://discord.gg/DNbfshRhgq")
	print("~ youtube is https://www.youtube.com/@its-skondo")
	print("~ credit skondo and marty for making this")
end

getgenv().syn = syn
getgenv().getsynasset = getsynasset

return syn
