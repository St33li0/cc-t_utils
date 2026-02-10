
-- Initialise terminal
term.clear()
local tx,ty = term.getSize()
term.setCursorPos(1,1)

-- Load screen buffer
local screenBuffer = require("screenBuffer").new({titleBar = "Botnet Host : "..os.getComputerID().." : "..os.getComputerLabel()})
screenBuffer:clear()
screenBuffer:addCentered("Loading Configuration...\n")
screenBuffer:draw()

-- Load configuration
local configFile = fs.open("botnet/config.json", "r")
local config = textutils.unserializeJSON((configFile.readAll()))
configFile.close()

screenBuffer:clear()
screenBuffer:addCentered("Configuring Modem...\n")
screenBuffer:draw()

if not config.User.HasChosenModem then
    screenBuffer:add("Please choose a modem to use for the botnet.")
    screenBuffer:add("Available modems:")
    screenBuffer:draw()
    local modems = {peripheral.find("modem")}
    if #modems > 1 then
        for i=1, #modems do
            if modems[i].isWireless() then
                screenBuffer:add(i .. ". " .. peripheral.getName(modems[i]) .. " (" .. peripheral.getType(modems[i]) .. ")")
                screenBuffer:draw()
            end
        end
        screenBuffer:add("\nType the name of the modem you want to use, or 'none' to skip:")
        screenBuffer:draw()
        term.setCursorPos(1,ty)
        local choice = read()
        if choice ~= "none" and choice ~= 0 then
                config["wireless_modem"] = modems[tonumber(choice)]
                config.User.HasChosenModem = true
        end
    elseif #modems == 1 then
        if modems[1].isWireless() then
            config["wireless_modem"] = modems[1]
            config.User.HasChosenModem = true
            screenBuffer:add("Automatically selected modem: " .. peripheral.getName(config["wireless_modem"]))
            screenBuffer:draw()
        else
            screenBuffer:add("No wireless modems found. Please connect a wireless modem and try again.")
            screenBuffer:draw()
            os.reboot()
        end
    else
        screenBuffer:add("No modems found. Please connect a modem and try again.")
        screenBuffer:draw()
        os.reboot()
    end
end
screenBuffer:clear()

screenBuffer:addCentered("Starting Botnet Host...\n")
screenBuffer:draw()

rednet.open(peripheral.getName(config["wireless_modem"]))
rednet.host(config.protocol,config.hostname)

screenBuffer:clear()
screenBuffer:addCentered("Botnet Host Running\n")
for k,v in pairs(config) do
    if type(k) == "string" and type(v) ~= "table" then
        screenBuffer:add(k .. "  :  " .. v)
    end
end
screenBuffer:draw()

-- Functions
--- Receive and handle messages from bots
local function handleMessages()
    while true do
        local senderId, message, protocol = rednet.receive(config.protocol)
        if protocol == config.protocol then
            screenBuffer:add("Received message from " .. senderId .. ": " .. message)
            screenBuffer:draw()
            -- Handle message (e.g. add to command queue, update bot status, etc.)
        end
    end
end

--- Periodically save configuration and botnet state
local function saveState()
    while true do
        local configFile = fs.open("botnet/config.json", "w")
        configFile.write(textutils.serializeJSON(config))
        configFile.close()
        -- Save botnet state (e.g. list of connected bots, command queue, etc
        sleep(config.save_interval)
    end
end

--- Get heartbeat from bots and update their status
local function monitorBots()
    while true do
        -- Send heartbeat request to bots
        rednet.broadcast("heartbeat", config.protocol)
        -- Wait for responses and update bot status
        sleep(config.heartbeat_interval)
    end
end

--- Update API
local function updateAPI()
    while true do
        -- Send API updates and apply them if necessary
        sleep(config.api_update_interval)
    end
end

-- Main loop
while true do
    parallel.waitForAny(
        handleMessages,
        saveState,
        monitorBots,
        updateAPI
    )
end