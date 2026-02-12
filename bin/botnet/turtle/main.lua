
-- Initialise terminal
term.clear()
local tx,ty = term.getSize()
term.setCursorPos(1,1)

-- Load screen buffer
local screenBuffer = require("screenBuffer").new({titleBar = "Botnet Drone : "..os.getComputerID().." : "..os.getComputerLabel()})
screenBuffer:clear()

screenBuffer:addCentered("Loading Configuration...\n")
screenBuffer:draw()
-- Load configuration
local configFile = fs.open("botnet/config.json", "r")
local config = textutils.unserializeJSON((configFile.readAll()))
configFile.close()

local internal_functions = {}

screenBuffer:clear()
screenBuffer:addCentered("Configuring Modem...\n")
screenBuffer:draw()
-- Load Modem
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

screenBuffer:addCentered("Starting Drone...")
screenBuffer:draw()

local drone = require("models.drone").new(os.getComputerID())
rednet.open(config["wireless_modem"])
drone:setFuelLevel()
drone:setStatus("Booting")
drone:setInventory()
drone:setPosition()

function internal_functions.init_to_host()
    rednet.send(config.hostID,{request="init_drone"},config.protocol)
    local id, message = -1,""
    repeat
        id, message = rednet.receive(config.protocol,10)
    until id == nil or (message.response and id == config.hostID)
    if id == -1 then error("Invalid Code Path") end -- This should never happen but you never know
    if id == nil then error("Timed Out") end
    if message.response == "unknown_drone_id" then
        screenBuffer:add("Unknown to Host PC, Registering...")
        screenBuffer:draw()
        internal_functions.register_to_host()
    end
end

function internal_functions.register_to_host()
    rednet.broadcast({request="register", type="drone"})
    screenBuffer:add("Registering to Host")
    screenBuffer:draw()
    local id, message
    repeat
        id, message = rednet.receive(config.protocol)
    until message and message.response == "send_data"
    drone:setStatus("Registering")
    screenBuffer:add("Received response from Host")
    screenBuffer:draw()
    config.hostID = id
    local requested_data_fields = type(message.request) == "table" and message.request or {}
    local send_data = {}
    for i=1, #requested_data_fields do
        send_data[requested_data_fields[i]] = config[requested_data_fields[i]]
    end
    rednet.send(id,{response = "register_data",data = send_data},config.protocol)
    repeat
        id, message = rednet.receive(config.protocol)
    until id == config.hostID and message and message.response
    if message.reponse == "ok" and message.code == 200 then
        drone:setStatus("No Task")
        screenBuffer:clear()
        screenBuffer:addCentered("Waiting for task...")
        screenBuffer:draw()
        return true
    end
    return false
end

if not config.hostID then
    local ok = internal_functions.register_to_host()
    if ok == false then return nil end
else -- Use init instead of register
    local ok = internal_functions.init_to_host()
    if ok == false then return nil end
end
