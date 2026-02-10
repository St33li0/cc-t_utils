-- Host Startup File
if not fs.exists("botnet/config.json") then
    if fs.isDir("botnet") then
        fs.delete("botnet")
    end
    if not fs.isDir("disk") then
        error("Disk drive not found. Please insert a disk drive to continue.")
    end
    fs.copy("disk/host", "botnet")
    shell.run("cp disk/shared/* botnet/")
    shell.run("set shell.allow_disk_startup false")
    shell.setPath(shell.path()..":botnet")
    print("Choose a name for your botnet host machine: ")
    local hostName = read()
    os.setComputerLabel(hostName)
    print("Host name set to: " .. hostName)
    print("Setting Configuration...")
    local config = {
        ["protocol"] = "",
        ["hostname"] = hostName,
        ["wireless_modem"] = {},
        ["server_port"] = 1337,
        ["client_port"] = 1338,
        ["save_interval"] = 60,
        ["botnet_interval"] = 30,
        ["api_update_interval"] = 500,
        User = {
            HasChosenModem = false,
        }
    }
    local tx,ty = term.getSize()
    local temp = {}
    while true do
        term.clear()
        local i = 1
        for k,v in pairs(config) do
            term.setCursorPos(1, ty - (#temp + 2) - i )
            term.clearLine()
            if type(k) == "string" and type(v) ~= "table" then
                print(k .. ": " .. (temp[k] or v))
            end
            i = i + 1
        end
        term.setCursorPos(1, ty-1)
        term.clearLine()
        write("Input (key=value): ")
        local input = read()
        if input == "done" then
            break
        end
        local key, value = input:match("([^=]+)=([^=]+)")
        if key and value and config[key] ~= nil then
            temp[key] = value
        end
    end
    term.clear()
    term.setCursorPos(1,1)
    print("Use this configuration?")
    for k,v in pairs(temp) do
        if type(k) == "string" then
            print(k .. ": " .. v)
        end
    end
    print("Type 'yes' to confirm, or 'no' to cancel.")
    local confirm = read()
    if confirm:lower() == "yes" then
        for k,v in pairs(temp) do
            config[k] = v
        end
    else
        print("Configuration cancelled. Deleting config for reboot.")
        if fs.exists("botnet/config.json") then
            fs.delete("botnet/config.json")
        end
        print("Rebooting...")
        os.reboot()
    end
    if not config["protocol"] or config["protocol"] == "" then config["protocol"] = "botnet_"..tostring(config["server_port"]) end
    local cf = fs.open("botnet/config.json", "w")
    cf.write(textutils.serializeJSON(config))
    cf.close()
    print("Configuration saved.")
    shell.run("botnet/main")
else
    print("Configuration file found. Starting botnet host...")
    shell.run("botnet/main")
end