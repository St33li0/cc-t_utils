local drone = {}
drone.__index = drone

function drone.new(id)
    local self = setmetatable({}, drone)
    self.id = id
    self.status = "unknown"
    self.lastSeen = os.time()
    self.position = {x = 0, y = 0, z = 0}
    self.inventory = {}
    self.fuelLevel = 0
    return self
end

-- Turtle (drone) API
if turtle then
    function drone:updateStatus()
        -- Implement logic to update drone status using turtle APIs
        local senderId, message = rednet.receive(config.protocol)
        if message and message.request == "status_update" then
            self.status = message.status or self.status
            self.lastSeen = os.time()
            rednet.send(senderId, {response = "status_response", status = self.status}, config.protocol)
        end
    end

    function drone:updatePosition()
        local senderId, message = rednet.receive(config.protocol)
        if message and message.request == "position_update" then
            self.lastSeen = os.time()
            local success, err, y, z = pcall(gps.locate())
            if success then
                self.position = {x = err, y = y, z = z}
            end
            rednet.send(senderId, {response = "position_response", position = self.position}, config.protocol)
        end
    end

    function drone:updateInventory()
        local senderId, message = rednet.receive(config.protocol)
        if message and message.request == "inventory_update" then
            self.lastSeen = os.time()
            self.inventory = {}
            for slot = 1, 16 do
                local item = turtle.getItemDetail(slot)
                if item then
                    table.insert(self.inventory, {slot = slot, item = item})
                end
            end
            rednet.send(senderId, {response = "inventory_response", inventory = self.inventory}, config.protocol)
        end
    end

    function drone:updateFuelLevel()
        local senderId, message = rednet.receive(config.protocol)
        if message and message.request == "fuel_update" then
            self.lastSeen = os.time()
            self.fuelLevel = turtle.getFuelLevel()
            rednet.send(senderId, {response = "fuel_response", fuelLevel = self.fuelLevel}, config.protocol)
        end
    end
    function drone:setStatus(status)
        if status and type(status) == "string" then
            self.status = status
        end
    end
    function drone:setPosition()
        local s,x,y,z = pcall(gps.locate())
        if s then
            self.position = {x=x,y=y,z=z}
        end
    end
    function drone:setInventory()
        self.inventory = {}
        for slot = 1, 16 do
            local item = turtle.getItemDetail(slot)
            if item then
                table.insert(self.inventory, {slot = slot, item = item})
            end
        end
    end
    function drone:setFuelLevel()
        self.fuelLevel = turtle.getFuelLevel()
    end
end

-- Host Machine API
if not turtle then
    function drone:getStatus()
        -- Implement logic to get drone status from host machine
        rednet.send(self.id, {request = "status_request"}, config.protocol)
        local senderId, message = rednet.receive(config.protocol)
        if senderId == self.id and message and message.response == "status_response" then
            self.status = message.status
            self.lastSeen = os.time()
        end
    end
    function drone:getPosition()
        -- Implement logic to get drone position from host machine
        rednet.send(self.id, {request = "position_request"}, config.protocol)
        local senderId, message = rednet.receive(config.protocol)
        if senderId == self.id and message and message.response == "position_response" then
            self.position = message.position
            self.lastSeen = os.time()
        end
    end
    function drone:getInventory()
        -- Implement logic to get drone inventory from host machine
        rednet.send(self.id, {request = "inventory_request"}, config.protocol)
        local senderId, message = rednet.receive(config.protocol)
        if senderId == self.id and message and message.response == "inventory_response" then
            self.inventory = message.inventory
            self.lastSeen = os.time()
        end
    end
    function drone:getFuelLevel()
        -- Implement logic to get drone fuel level from host machine
        rednet.send(self.id, {request = "fuel_request"}, config.protocol)
        local senderId, message = rednet.receive(config.protocol)
        if senderId == self.id and message and message.response == "fuel_response" then
            self.fuelLevel = message.fuelLevel
            self.lastSeen = os.time()
        end
    end
end

return drone