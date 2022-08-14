--------------------------------------------------------------------------------
-- check_JSON.lua ------ in [Saved Games/DCS/Scripts] -- _TAG (220814:14h:58) --
--------------------------------------------------------------------------------
print("@LOADING "..arg[0]..":")

--[[
:e C:/LOCAL/DATA/GAMES/DCS_World/Scripts/JSON.lua
--]]
--  FROM LUA TEXT OBJECT ARRAY: {  what = "books" ,  count = 3 } => TO JSON: { "what": "books" , "count": 3 }
--  FROM LUA ............TABLE: [ "Larry", "Curly", "Moe"      ] => TO JSON: { "Larry", "Curly", "Moe" }
local JSON =  dofile("lib/JSON.lua")
      JSON.strictTypes = true -- to support metatable

print()
print('-----------------------------------------')
print('-- LUA_TABLE = { "Larry", "Curly", "Moe"}')
print('-----------------------------------------')
local  LUA_TABLE = { "Larry", "Curly", "Moe"}
local        json_TABLE = JSON:encode       ( LUA_TABLE )
local pretty_json_TABLE = JSON:encode_pretty( LUA_TABLE )
local     decoded_TABLE = JSON:decode(       json_TABLE )
print(" ............json_TABLE: "..        (        json_TABLE))
print(" .....pretty_json_TABLE: "..        ( pretty_json_TABLE))
print(" .........decoded_TABLE: "..tostring(     decoded_TABLE))

print()
print('-----------------------------------------')
print('-- LUA_VALUE = { what="books" , count=3 }')
print('-----------------------------------------')
local  LUA_VALUE = {  what = "books" ,  count = 3 }
local        json_VALUE = JSON:encode       ( LUA_VALUE )
local pretty_json_VALUE = JSON:encode_pretty( LUA_VALUE )
local     decoded_VALUE = JSON:decode(       json_VALUE )
print(" ............json_VALUE: "..        (        json_VALUE))
print(" .....pretty_json_VALUE: "..        ( pretty_json_VALUE))
print(" .........decoded_VALUE: "..tostring(     decoded_VALUE))

print()
print('-----------------------------------------')
print('-- file last_modified'                    )
print('-----------------------------------------')
local file_name              = arg[0]
local stat_cmd               = "stat -c %Y '"..file_name.."'"
print(stat_cmd)
local stat_pipe              = io.popen( stat_cmd );
local stat_last_modified     = stat_pipe:read() --; stat_pipe:close();
print(" ...stat_last_modified=[".. stat_last_modified .."]")

print()
print('-----------------------------------------')
print('-- last modified file'                    )
print('-----------------------------------------')
local script_dir   = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
--print("script_dir=["..script_dir.."]")

local  file_name   =  (script_dir.."/*.lua"                           ):gsub(" ","?")
                    .." "
                    ..("%USERPROFILE%/Saved Games/DCS/Logs/Listen.log"):gsub(" ","?")
--print("file_name = ["..file_name.."]")
local ls_cmd       = "ls -t "..file_name
print(ls_cmd)

local stat_pipe    = io.popen( ls_cmd );
local last_modfied = stat_pipe:read() --; stat_pipe:close();
print("      "..last_modfied)

print()
print("@DONE "..arg[0]..":")

os.exit()

--[[
    :update|only|terminal luae %
    :update|     terminal luae %

:r !touch   $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:w
:r !ls -ltr $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log %:h/*.lua | tail -1

--]]
