# Garry's Mod Lua Syntax Checker
GLSC is a free syntax checker for your GLua files (can work for Lua too!)
![image](https://user-images.githubusercontent.com/40930644/187045868-ff6eb96b-9fae-4fe1-aab2-c997970cc04e.png)

## Features
* Easy to use
* Cool for beginners
* Can work with standard Lua
* Can show up to 8 syntax errors

## Usage
1. Unpack **GLSC**
2. Run **main.lua** with file specified in parameters
3. Wait for it to complete

## Notes
* Not 100% accurate
* Not 100% complete
* Requires Lua to run

## Errors
1. Different tabs - Using spaces but not tabs or tab and not spaces
2. Bad tabs - 1 tab instead of 2 or 4 tabs instead of 1
3. Cheops pyramid - Too many tabs at the same time
4. Bad function - Very bad functions to use
5. Semicolon - Use of semicolons
6. Table creation on runtime - Trying to create a table inside a function or if
7. Bunch of locals - Having too much locals, when you can shorten and merge them
8. Static objects on runtime - Trying to create Material, Model or something simillar inside function
