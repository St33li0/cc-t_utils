local buffer = {}
local render = {}
local termWidth, termHeight
local canRender = true

--[[
This is a stupid script, please ignore or make good.
If you wasted your time here, please increment the counter: 1
    ToDo:
    - Word wrap (wrap-around respects words, not just character count)
    - Paginate output (support scrolling through long output)
    - Add color support for text rendering
    - Support for custom line heights or spacing
    - Add alignment options (left, center, right)
    - Implement double buffering for flicker-free rendering
    - Add API for clearing buffer or render state
    - Support for rendering tables or structured data
    - Add hooks/events for render updates
    - Optimize buffer management for large outputs
]]


local function update_term()
    termWidth, termHeight = term.getSize()
end

local function queue_buffer(lines)
    update_term()
    for _, line in ipairs(lines) do
        local wrap = line.wrap
        local txt = line.text or ""
        print(wrap)
        if wrap then
            while #txt > termWidth do
                table.insert(buffer, txt:sub(1, termWidth))
                txt = txt:sub(termWidth + 1)
            end;goto continue
        end
        table.insert(buffer, txt:sub(1, termWidth))
        ::continue::
    end
end

local function update_render()
    canRender = false
    render = buffer
    canRender = true
    buffer = {}
end

local function display_render()
    update_term()
    term.clear()
    term.setCursorPos(1,1)
    print("Rendering...")
    --while not canRender do os.pullEvent("yield") end
    for i=1, #render do
        if i > termHeight then break end
        print(render[i])
    end
end

local module = {}
module.queue = queue_buffer
module.update = update_render
module.display = display_render
return module
