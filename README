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

## Example

If you have a program called `/bin/hello.lua`, you can run it by typing:
