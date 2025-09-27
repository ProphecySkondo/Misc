--([[This Script Was Made By https://discord.gg/DNbfshRhgq]]):gsub(".+", function(a)
--	print(a)
--end)

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

local cloneref = missing("function", cloneref, function(...) return ... end)
local httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
local everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
local queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
local hui = missing("function", gethui or get_hidden_gui or (syn and syn.protect_gui))

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

--// bag work

syn = {
	--// new synapse functions ðŸ˜­
	
	grab_service = function(serviceName)
		return services(serviceName)
	end,

	notify = function(title, message, duration, asset)
		syn.grab_service("StarterGui"):SetCore("SendNotification", {
			Title = title or "https://discord.gg/DNbfshRhgq",
			Text = tostring(message) or "",
			Duration = duration or 10,
			Icon = asset or ""
		})
	end,

	webImport = function(rawURL)
		rawport(rawURL)
	end,

	--// syn functions

	is_beta = function()
		return true
	end,

	request = function(options)
		local response = httprequest(options)
		return {
			StatusCode = response.StatusCode or response.Status,
			Body = response.Body,
			Headers = response.Headers,
			Success = response.Success
		}
	end,

	write_clipboard = function(content)
		everyClipboard(content)
	end,
	
	queue_on_teleport = function(code)
		return queueteleport(code)
	end,

	protect_gui = function(gui)
		gui.Parent = hui()
		return gui
	end,

	unprotect_gui = function(gui)
		local players = syn.grab_service("Players")
		local plr = players.LocalPlayer

		if plr and plr:FindFirstChildWhichIsA("PlayerGui") then
			gui.Parent = plr:FindFirstChildWhichIsA("PlayerGui")
		else
			gui.Parent = syn.grab_service("CoreGui")
		end
		return gui
	end,
	
	synsaveinstance = function(options)
		local protocol = loadstring(game:HttpGet(params.RepoURL .. params.SSI .. ".luau", true), params.SSI)()
		protocol(options)
	end,

	secure_call = function(...)
		return ... -- im not goated enough
	end,

	--// crypt functions
	
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
		base64 = {
			encode = base64encode,
			decode = base64decode,
		},
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
		custom = {
			encrypt = function(cipher, data, key, iv)
				return syn.crypt.encrypt(data, key)
			end,
			decrypt = function(cipher, data, key, iv)
				return syn.crypt.decrypt(data, key)
			end,
			hash = function(algorithm, data)
				return sha256(data)
			end,
		},
	}
}

-- script by marty, discord server is https://discord.gg/DNbfshRhgq join xeon
-- getgenv().syn = syn

do
	print("discord server is https://discord.gg/DNbfshRhgq")
	print("youtube is https://www.youtube.com/@its-skondo")
	print("credit skondo and marty for making this")
end

getgenv().syn = syn

return syn
