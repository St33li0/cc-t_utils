local args = arg
if not args[1] then error("Arguments Not Found") end
local fsDir = tostring("./"..args[1])
if not fs.exists(fsDir) then error("File Not Found") end
local file = fs.open(fsDir,"r")
local fileContents = file.readAll()
file.close()
local x,y = term.getSize()
-- Split file into lines
local lines = {}
for line in fileContents:gmatch("([^\n]*)\n?") do
  -- Wrap each line to terminal width
  while #line > x do
    table.insert(lines, line:sub(1, x))
    line = line:sub(x + 1)
  end
  table.insert(lines, line)
end
-- Paginate output
local i = 1
while i <= #lines do
  for j = 1, y - 1 do
    if i > #lines then break end
    print(lines[i])
    i = i + 1
  end
  if i <= #lines then
    local p,j = term.getCursorPos()
    write("--More--")
    local event, key = os.pullEvent("key")
    if key == keys.q then break end
    term.clearLine()
    term.setCursorPos(p, j)
  end
end
--print(fileContents)