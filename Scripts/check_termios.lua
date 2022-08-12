local    LF = string.char(10)
local   ESC = tostring(string.char(27));
local CLEAR = ESC..'c'

local R     = ESC.."[1;31m"               --     RED
local G     = ESC.."[1;32m"               --   GREEN
local Y     = ESC.."[1;33m"               --  YELLOW
local B     = ESC.."[1;34m"               --    BLUE
local M     = ESC.."[1;35m"               -- MAGENTA
local C     = ESC.."[1;36m"               --    CYAN
local N     = ESC.."[0m"                  --      NC

io.write("R: ".. ESC.."[1;31m" .. "XXX"..LF)
io.write("G: ".. ESC.."[1;32m" .. "XXX"..LF)
io.write("Y: ".. ESC.."[1;33m" .. "XXX"..LF)
io.write("B: ".. ESC.."[1;34m" .. "XXX"..LF)
io.write("M: ".. ESC.."[1;35m" .. "XXX"..LF)
io.write("C: ".. ESC.."[1;36m" .. "XXX"..LF)
io.write("N: ".. ESC.."[0m"    .. "XXX"..LF)

--[[
    :update|only|terminal luae %
--]]

