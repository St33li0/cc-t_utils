-- Get a file from the net using HTTP
local argParse = require("argparse")
local argparse = argParse.parse
local args = argparse(arg,{
    url = { short = "u", has_value = true },
    output  = { short = "o", has_value = true },
    force = { short = "f", has_value = false }
})
-- Init Argument Variables
if not args.options.url then args.options.url = args.positionals[1] or error("No URL provided. Use -u <url> to specify a URL.") end
if not args.options.output then args.options.output = args.positionals[#args.positionals] or error("No output file provided. Use -o <file> to specify an output file.") end
local force = args.options.force or false

local urlsplit = {}
for part in args.options.url:gmatch("[%w%.%-]+") do
    table.insert(urlsplit, part)
end

if urlsplit[2] == "github.com" then -- Handle GitHub URLs to convert to raw.githubusercontent.com
    urlsplit[2] = "raw.githubusercontent.com"
    urlsplit[5] = "refs/heads"
end

local raw = table.concat(urlsplit, "/", 2) -- Rejoin URL parts
raw = "https://"..raw
if http.checkURL(raw) then args.options.url = raw end -- Check if the modified URL is valid, if so use it instead
raw,urlsplit = nil,nil -- Indicate for garbage collection

-- Fetch File
local response = http.checkURL(args.options.url) and http.get(args.options.url) or false
if not response then error("Failed to fetch URL: "..args.options.url) end
if response.getResponseCode() ~= 200 then error("Failed to fetch URL: HTTP "..response.getResponseCode()) end
-- Read Content
local content = response.readAll()
response.close()
-- Write to File
if not force and fs.exists(args.options.output) then error("File already exists. Use -f to overwrite.") end
local file = fs.open(args.options.output, "w")
if not file or file == nil then error("Failed to open file for writing: "..args.options.output) end
file.write(content)
file.close()
print("File saved to "..args.options.output)
