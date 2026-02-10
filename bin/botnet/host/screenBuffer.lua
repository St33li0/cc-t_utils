local screenBuffer = {}
screenBuffer.__index = screenBuffer

local function centeredPrint(tx,text)
    local x = math.floor((tx - #text) / 2) + 1
    local _,y = term.getCursorPos()
    term.setCursorPos(x, y)
    write(text.."\n")
end

function screenBuffer.new(args)
    local self = setmetatable({}, screenBuffer)
    self.titleBar = args.titleBar or ""
    self.lines = args.lines or {}
    self.tx,self.ty = term.getSize()
    return self
end

function screenBuffer:draw()
    term.clear()
    term.setCursorPos(1,1)
    centeredPrint(self.tx, self.titleBar)
    for i, drawFunc in ipairs(self.lines) do
        term.setCursorPos(1, i + 1)
        drawFunc()
    end
end

function screenBuffer:add(text)
    table.insert(self.lines, function() write(text.."\n" or "\n") end)
    if #self.lines > self.ty - 2 then
        table.remove(self.lines, 1)
    end
end

function screenBuffer:addCentered(text)
    table.insert(self.lines, function() centeredPrint(self.tx,text or "") end)
    if #self.lines > self.ty - 2 then
        table.remove(self.lines, 1)
    end
end

function screenBuffer:clear()
    self.lines = {}
    self:draw()
end

function screenBuffer:setTitle(title)
    if title ~= "" then
        self.titleBar = title
    end
end

function screenBuffer:getTitle()
    return self.titleBar
end

return screenBuffer