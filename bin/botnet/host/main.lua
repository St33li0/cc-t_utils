
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
                config["wireless_modem"] = peripheral.getName(modems[tonumber(choice)])
                config.User.HasChosenModem = true
        end
    elseif #modems == 1 then
        if modems[1].isWireless() then
            config["wireless_modem"] = peripheral.getName(modems[1])
            config.User.HasChosenModem = true
            screenBuffer:add("Automatically selected modem: " .. config["wireless_modem"])
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

screenBuffer:addCentered("Initializing Botnet Network...\n")
screenBuffer:draw()

local drone = require("models.drone")
local bots = {} -- Table to store bot information (ID, status, last seen, etc.)

screenBuffer:clear()

screenBuffer:addCentered("Starting Botnet Host...\n")
screenBuffer:draw()

rednet.open(config["wireless_modem"])
rednet.host(config.protocol,config.hostname)

screenBuffer:clear()
screenBuffer:addCentered("Botnet Host Running\n")
for k,v in pairs(config) do
    if type(k) == "string" and type(v) ~= "table" and type(v) ~= "function" then
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
            screenBuffer:add("Received message from " .. senderId .. ": " .. ((message.request or message.response) or ""))
            screenBuffer:draw()
            -- Handle message (e.g. add to command queue, update bot status, etc.)
        end
    end
end

--- Periodically save configuration and botnet state
local function saveState()
    while true do
        local cf = fs.open("botnet/config.json", "w")
        cf.write(textutils.serializeJSON(config))
        cf.close()

        math.randomseed(os.time()*10485)
        sleep(config.save_interval+math.random(0, 10))
    end
end

--- Get heartbeat from bots and update their status
local function monitorBots()
    while true do
        -- Send heartbeat request to bots
        rednet.broadcast("heartbeat", config.protocol)
        -- Wait for responses and update bot status
        repeat
            local id, message = rednet.receive(config.protocol)
            if message and message.header == "heartbeat_response" then
                screenBuffer:add("Received heartbeat response from bot " .. id)
                screenBuffer:draw()
                -- Update bot status in config or bot list
            end
        until not id or not message or message.header ~= "heartbeat_response"
        math.randomseed(os.time()*10485)
        sleep(config.botnet_interval+math.random(0, 5))
    end
end

--- Update API
local function updateAPI()
    while true do
        -- Send API updates and apply them if necessary
        math.randomseed(os.time()*10485)
        sleep(config.api_update_interval+math.random(50, 200))
    end
end

local function catchTerminateAndSave()
    while true do
        local event, param = os.pullEventRaw("terminate")
        if event == "terminate" then
            screenBuffer:clear()
            screenBuffer:addCentered("Terminating...")
            local cf = fs.open("botnet/config.json", "w")
            cf.write(textutils.serializeJSON(config))
            cf.close()
            os.shutdown()
        end
    end
end

-- Main loop
while true do
    parallel.waitForAny(
        handleMessages,
        saveState,
        monitorBots,
        updateAPI,
        catchTerminateAndSave
    )
end