# Adding a Directory to CC:Tweaked Shell Execution Paths for `/bin`

To make programs in a custom directory (like `/bin`) executable from the CC:Tweaked shell, you need to add that directory to the shell's path variable. The path variable tells the shell where to look for programs when you type a command.

## Steps

1. **Open the Shell Configuration File**

    Edit the shell's startup file, usually named `startup.lua` in the root directory.

2. **Modify the Path Variable**

    Add `/bin` to the path variable. For example, add this line to `startup.lua`:

    ```lua
    shell.setPath(shell.path() .. ":/bin")
    ```

    This appends `/bin` to the existing path.

3. **Save and Restart**

    Save your changes and restart the computer or reload the shell. Now, any program placed in `/bin` can be run directly from the shell.

---

# Scripts
## cat.lua
Concatenate and Display Files
The cat command is used to show the content of files in the terminal.
### Usage
`cat somefile.txt`
## getFile.lua
Utilise in-built http module to get files from the internet and save them.
### Requirements
- [argparse.lua](<https://github.com/St33li0/cc-t_utils/blob/main/modules/argparse.lua>)
### Usage
`getFile [URL] [OutFile]`
```lua
    url = { short = "u", has_value = true },
    output  = { short = "o", has_value = true },
    force = { short = "f", has_value = false }
```
# Modules
## argparse.lua
Command line argument parsing with Unix-like option tags
### Usage
```lua
local argparse = require("argparse")
local opt = {
    verbose = { short = "v", has_value = false },
    log = { short = "l", has_value = true }
}
local args = argparse.parse(arg,opt)
--[[ args =
    options = { verbose:bool,log:string}
    positionals = {string,string} etc.
]]
```
## fsTweaks.lua
Patches global fs function
- getExtension(string: path) -- Takes a string and finds the extension (all chars after last ".")
### Usage
```lua
local fsT = require("fsTweaks")
fsT and print("Okay") or print("Not Okay")
```
## render.lua
Module to provide easy terminal rendering. Holds an internal buffer that can be written but not (easily) read.
### Usage
```lua
local render = require("render")
render.queue({}) -- Provide a table of lines to render
render.update() -- Move buffer to queue (Overwrites queue)
render.display() -- Display queued object
```
