--[[
:e C:/LOCAL/DATA/GAMES/DCS_World/Scripts/JSON.lua
--]]

local JSON =  dofile("lib/JSON.lua")
      JSON.strictTypes = true -- to support metatable

--  FROM LUA TEXT OBJECT ARRAY: {  what = "books" ,  count = 3 } => TO JSON: { "what": "books" , "count": 3 }
--  FROM LUA ............TABLE: [ "Larry", "Curly", "Moe"      ] => TO JSON: { "Larry", "Curly", "Moe" }


print()
print(' --------------------------------------')
print(' LUA_TABLE = { "Larry", "Curly", "Moe"}')
print(' --------------------------------------')
local  LUA_TABLE = { "Larry", "Curly", "Moe"}
local        json_TABLE = JSON:encode       ( LUA_TABLE )
local pretty_json_TABLE = JSON:encode_pretty( LUA_TABLE )
local     decoded_TABLE = JSON:decode(       json_TABLE )
print(" ............json_TABLE: "..        (        json_TABLE))
print(" .....pretty_json_TABLE: "..        ( pretty_json_TABLE))
print(" .........decoded_TABLE: "..tostring(     decoded_TABLE))

print()
print(' --------------------------------------')
print(' LUA_VALUE = { what="books" , count=3 }')
print(' --------------------------------------')
local  LUA_VALUE = {  what = "books" ,  count = 3 }
local        json_VALUE = JSON:encode       ( LUA_VALUE )
local pretty_json_VALUE = JSON:encode_pretty( LUA_VALUE )
local     decoded_VALUE = JSON:decode(       json_VALUE )
print(" ............json_VALUE: "..        (        json_VALUE))
print(" .....pretty_json_VALUE: "..        ( pretty_json_VALUE))
print(" .........decoded_VALUE: "..tostring(     decoded_VALUE))

print()

--[[
    :update|only|terminal luae %
    :update|     terminal luae %
--]]
