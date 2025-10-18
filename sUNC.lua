local function insert_string(tbl: {}, text: string)
    table.insert(tbl, text)
end

local function callback(t: string? | number | Instance, f, fallback: any?)
    if type(f) == t then return f end
    return fallback
end

local cloneref = callback("function", cloneref, function(service)
    return service
end)

-- * DEBUGGING
-- * SOME EXIT CODES WEREN'T ADDED BECAUSE THERE NOT APART OF THE ROBLOX LUA ENVIORMENT
-- * These are here for us to check for any errors 
local EXIT_CODES, CODES = {
    ["0"] = "success",
    ["1"] = "failed",
    ["3"] = "syntax",
    ["4"] = "memory"
}, {
    success = " 💥",
    errorr = " 😔"
}
                                                                local supportme = "https://buymeacoffee.com/dabsteprbxf"
local function patch(code: string, modifier: (string) -> string)
    -- use modifier to change up "code"
    -- useful at times

    local monkeypatch = code:gsub([["(.-)"]], function(a)
        local m = modifier(a)
        return string.format("%q", m)
    end)

    local patchSuccess, patchResult = pcall(loadstring, monkeypatch)
    if not patchSuccess then
        return
    end
    
    local ok, result = pcall(patchResult)
    if not ok then
        return
    end

    return result
end

do
    local parms = {
        owner = "ProphecySkondo",
        repo = "Misc",
        branch = "main",
    }

    local function Import(file)
        return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/%s/%s/%s.lua"):format(
            parms.owner, parms.repo, parms.branch, file
        )), file .. ".lua")()
    end

    Import("Syn/main")
end

local jar = {} -- store the full check
local RESULT_JAR = {}
local ENV_JAR = 
    (getgenv and getgenv())
    or shared
    or _G
    or "Unknown"
local EXECUTER_NAME = 
    (identifyexecutor and identifyexecutor())
    or (getexecutorname and getexecutorname())
    or (whatexecuter and whatexecuter())
    or "Unknown"
local completed: boolean = false
local errors, working, broken, indicators, xn = 0, 0, 0, {}, setmetatable({}, {
    __index = function(self, name)
        local Service = game:GetService(name)
            or settings():GetService(name)
            or UserSettings():GetService(name)
        
        self[name] = Service
        return cloneref(Service)
    end
})
local finder = setmetatable({}, {
    __index = function(_, path)
        if type(path) ~= "string" then
            return nil
        end

        local value = getfenv(0)

        while value ~= nil and path ~= "" do
            local name, nextPath = string.match(path, "^([^.]+)%.?(.*)$")
            if not name then break end
            value = value[name]
            path = nextPath
        end

        return value
    end
})

local function testMethod(n: string?, callback)
    local completed = false

    local mainThread = task.spawn(function()
        local basicSuccess, basicResult = pcall(function()
            local req = (function() if not callback then return n end end)() -- return n if call back isn't in place
            if not finder[n] then
                -- checks through the meta table we set to see if we get n aka the method
                -- errors increase if it doesn't find
                -- inserts a string to jar giving the errors and n
                errors += 1
                insert_string(jar, "[-] " .. n .. " | " .. "failed | errors: " .. errors .. CODES.errorr)
            else
                -- adds more to working
                working += 1
                insert_string(jar, "[+] " .. n .. " | " .. "worked | working: " .. working .. CODES.success)
            end
        end)

        do
            if not basicSuccess then
                if #basicResult == 0 then
                    basicResult = "Empty Response From Code"
                end
                completed = true
                return
            end
        end

        if basicSuccess then
            local code = basicSuccess and "0" or "1"
            insert_string(RESULT_JAR, basicResult)
            return EXIT_CODES[code]
        end
    end)
end

local METHODS = {
    "hookfunction", "hookmetamethod", "print", -- stable
    "newcclosure", "islclosure", "iscclosure",
    "getrawmetatable", "setrawmetatable", "getnamecallmethod",
    "setnamecallmethod", "checkcaller", "getgenv",
    "getrenv", "getfenv", "setfenv",
    "getexecutorname", "identifyexecutor", "getexecutorversion",
    "syn.request", "http_request", "request",
    "http.request", "game:HttpGetAsync", "game:HttpGet",
    "writefile", "readfile", "appendfile",
    "isfile", "isfolder", "makefolder",
    "delfile", "delfolder", "listfiles",
    "loadfile", "loadstring", "load",
    "getgc", "getobjects", "getinstances",
    "getnilinstances", "getloadedmodules", "getloadedmodules",
    "getrunningscripts", "getscripts", "getscriptbytecode",
    "getscripthash", "getsenv", "getfenv",
    "getupvalues", "debug.getupvalues", "debug.getupvalue",
    "debug.setupvalue", "debug.getprotos", "debug.getproto",
    "debug.getstack", "debug.setstack", "debug.setconstant",
    "getcallbackvalue", "getconnections", "getconnections",
    "fireclickdetector", "firetouchinterest", "firesignal",
    "fireproximityprompt", "getcustomasset", "gethiddenproperty",
    "sethiddenproperty", "isscriptable", "setscriptable",
    "isreadonly", "setreadonly", "cloneref",
    "crypt.encrypt", "crypt.decrypt", "crypt.hash",
    "lz4compress", "lz4decompress", "setclipboard",
    "getclipboard", "queue_on_teleport", "queueonteleport",
    "syn.queue_on_teleport", "syn.protect_gui", "gethui",
    "gethiddenui", "get_hidden_gui", "Drawing.new",
    "Drawing.Fonts", "isrenderobj", "getrenderproperty",
    "setrenderproperty", "cleardrawcache", "WebSocket.connect",
    "setthreadidentity", "getthreadidentity", "setidentity",
    "getidentity", "getcallingscript", "getnamecallmethod",
    "setfpscap", "isrbxactive", "mouse1click",
    "mouse1press", "mouse1release", "mouse2click",
    "mousemoveabs", "mousemoverel", "mousescroll"
}

do
    local zz = [[
~ SUNC SCRIPT BY SAI (inspired by ltseverydayyou) | JOIN XEON
~ EXECUTER IS ]] .. EXECUTER_NAME

    insert_string(jar, '\n\n' .. zz)
end

-- * Ascii api text generator (just cuz, it isn't required)
-- * syn.request will be used, but it'll work for this script since we're using a nother version of syn
-- * thanks to thelicato for the api; its just https://github.com/thelicato/asciified/tree/main

local api = {
    ["starter"] = "https://asciified.thelicato.io/api/v2/ascii?text=", -- the text
    ["mid"] = "&font=", -- the font
}

local function ascii(text: string, font: string)
    -- i could've just used string.format really
    assert(type(text) == 'string', "Expected string got " .. text)
    assert(type(font) == 'string', "Expected string got" .. font)

    local url = api["starter"] .. tostring(text) .. api["mid"] .. tostring(font)
    
    local asciiRequest, asciiResult = pcall(function()
        return syn.request({
            Url = url,
            Method = "GET"
        })
    end)

    if not asciiRequest then
        if asciiResult == 0 then
            asciiResult = "api error"
        end
        return
    end

    if asciiRequest and asciiResult.Body then
        return asciiResult.Body
    else
        return "empty"
    end
end

local main = (function()
    local totalMethods = #METHODS
    local successPercent = 0
    
    local thread = pcall(function()
        for _, methd in ipairs(METHODS) do
            testMethod(methd)
        end 

        task.wait(0.2) -- give thread some time

        -- * MATH GOES HERE
        -- * GET THE PERCENTAGE OF SUNC FROM THE ONES THAT ARE WORKING
        if totalMethods > 0 then
            successPercent = (working / totalMethods) * 100
        end

        insert_string(jar, string.format("SUNC SUCCESS RATE %.2f%%", successPercent))
        insert_string(jar, "\n\n" .. ascii("sub to sai", "Bloody"))
    end)
end)()

return jar
