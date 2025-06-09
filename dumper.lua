--=== W Konstant for the decompiler ===--

return(function(ass, script, by, sai, ...)
local MAX_ENTRIES=9999;
local MAX_SCRIPTS=200;
local BATCH_SIZE=300;
local PAUSE_TIME=0.05;
local SAVE_INSTANCE=false

mark = [[




                         _  _   /   ___   \ / _     _  _    __ 
 _| o  _  _  _  __ _|   (_|(_| / |_| | |_| Y (_| __|_)/ \ _|__)
(_| | _> (_ (_) | (_| o __|__|/    | | | | | __| | | \\_X(_|__)




]]

local function safeDescendants(root)
    local ok, children = pcall(function() return root:GetDescendants() end)
    return ok and children or {}
end
local function output(text)
	warn("[DECOMPILER]:", tostring(text))
end
local function saveplace()
	saveinstance()
end
if SAVE_INSTANCE==true then
	saveplace()
	output("you don't need save instances and this decompiler at the same time 😭")
	return
end

--=== Main Decompile Function ===--

local function decompileAll()
    local index=0
    local keywordEntries={}
    local otherEntries={}
    local scriptDumps={}
    local remoteGuiDumps={}
	
    local services = {
        ReplicatedStorage=game:GetService("ReplicatedStorage"),
        Workspace=game:GetService("Workspace"),
        Players=game:GetService("Players"),
        StarterGui=game:GetService("StarterGui"),
        StarterPack=game:GetService("StarterPack"),
        Lighting=game:GetService("Lighting"),
        SoundService=game:GetService("SoundService"),
        Chat=game:GetService("Chat"),
    }
    local keywords = { "admin", "mod", "owner", "kick", "ban", "rank", "staff" }
    local validClasses = {
        RemoteEvent       = true,
        RemoteFunction    = true,
        BindableEvent     = true,
        BindableFunction  = true,
        ScreenGui         = true,
        TextLabel         = true,
        TextButton        = true,
        ImageLabel        = true,
        ImageButton       = true,
        Frame             = true,
        ScrollingFrame    = true,
        BillboardGui      = true,
        SurfaceGui        = true,
        TextBox           = true,
    }
    table.insert(remoteGuiDumps, "-- == Remotes & GUIs List ==")
    for srvName, service in pairs(services) do
        for _, obj in ipairs(safeDescendants(service)) do
            if validClasses[obj.ClassName] then
                table.insert(remoteGuiDumps,
                    string.format("[+] Dumped: [%s] %s (%s)",
                        srvName,
                        obj:GetFullName(),
                        obj.ClassName
                    )
                )
            end
        end
        task.wait(PAUSE_TIME)
    end
    for srvName, service in pairs(services) do
        table.insert(keywordEntries, string.format("[+] Scanning %s for entries...", srvName))
        for i, obj in ipairs(safeDescendants(service)) do
            if validClasses[obj.ClassName] then
                local nameLower = obj.Name:lower()
                local matched  = false

                -- matches
                for _, kw in ipairs(keywords) do
                    if nameLower:find(kw, 1, true) then
                        index = index + 1
                        table.insert(keywordEntries,
                            string.format("[%d] %s -- matched '%s'", index, obj:GetFullName(), kw)
                        )
                        matched = true
                        break
                    end
                end
                if not matched then
                    index = index + 1
                    table.insert(otherEntries,
                        string.format("[%d] %s", index, obj:GetFullName())
                    )
                end
                if (#keywordEntries + #otherEntries) >= MAX_ENTRIES then
                    output("Reached MAX_ENTRIES limit")
                    break
                end
            end
            if i % BATCH_SIZE == 0 then task.wait(PAUSE_TIME) end
        end
        task.wait(PAUSE_TIME)
        if (#keywordEntries + #otherEntries) >= MAX_ENTRIES then break end
    end

    --=== LocalScripts ===--

    table.insert(scriptDumps, "-- == Decompiled by Konstant == --")
    local descAll = safeDescendants(game)
    for i, obj in ipairs(descAll) do
        if #scriptDumps > MAX_SCRIPTS then
            warn("-- Reached MAX_SCRIPTS limit --")
            break
        end
        if obj:IsA("LocalScript") then
            local ok, src = pcall(decompile, obj)
            if ok and type(src) == "string" then
                table.insert(scriptDumps,
                    string.format("-- [%s] Source: %s\n%s",
                        obj.ClassName,
                        obj:GetFullName(),
                        src
                    )
                )
            end
        end
        if i % BATCH_SIZE == 0 then task.wait(PAUSE_TIME) end
    end
    local out = {}
    table.insert(out, table.concat(remoteGuiDumps, "\n"))
    table.insert(out, "\n-- == Keyword Entries ==")
    table.insert(out, table.concat(keywordEntries, "\n"))
    table.insert(out, "\n-- == Other Entries ==")
    table.insert(out, table.concat(otherEntries, "\n"))
    table.insert(out, "\n-- == wsg fine shyt😉 ==--")
    table.insert(out, table.concat(scriptDumps, "\n\n"))
    local finalStr = table.concat(out, "\n\n")
    if setclipboard then
        setclipboard(finalStr)
        output(string.format("Dumped %d entries, %d scripts, and %d remotes/GUI.",
            (#keywordEntries + #otherEntries),
            #scriptDumps,
            #remoteGuiDumps - 1
        ))
		output("check clipboard")
    else
        output("get better executer")
	end
end

return print(mark), decompileAll()
end)()
