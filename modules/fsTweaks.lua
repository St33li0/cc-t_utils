-- Initialise global table to track patched modules and store the original modules for redundancy
if not _G.patched then _G.patched = {original = {}, patched = {}} end
_G.patched.original["fs"] = fs -- Store original fs module


local fsTweaks = fs
fsTweaks.semver = "0.1.0" -- https://semver.org/
--[[
    Load FS Tweaks Functions into Environment
]]
---@comment Get the file extension from a given path
---@param path string the file path to extract the extension from
---@return string?
fsTweaks.getExtension = function(path)
    return path:match("^.+(%..+)$")
end

-- Store patched fs module
_G.patched.patched["fs"] = fsTweaks

--[[
    Apply Patches to Global FS Module
]]
setmetatable(fs, {
    __index = function(t, k)
        if fsTweaks[k] then
            return fsTweaks[k]
        else
            return _G.patched.original["fs"][k]
        end
    end
})

-- Verify Patch Applied and Return Value
return fsTweaks == fs and true or false