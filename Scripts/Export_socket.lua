--------------------------------------------------------------------------------
-- Export_socket.lua --- in [Saved Games/DCS/Scripts] -- _TAG (220814:19h:12) --
--------------------------------------------------------------------------------
print("@@@ LOADING Export_socket.lua")

local           PORT =  5002
local           HOST = "localhost"
--[[
local SEND_TO_TARGET = true -- UNCOMMENT TO FORMAT MESSAGES FOR TARGET SCRIPT
--]]

--[[
local       log_this = true
--]]

-- ENVIRONMENT
--     Export_log.lua {{{
local LF = "\n"

if not Export_log then
    local  script_dir  = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
    dofile(script_dir.."/Export_log.lua"   )
end
--}}}

--------------------------------------------------------------------------------
-- CONNECT CLIENT SOCKET -------------------------------------------------------
--------------------------------------------------------------------------------
-- lib/socket.lua {{{
if not socket then
    local  script_dir = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
    dofile(script_dir.."/lib/socket.lua")
    local  socket = require("socket"    )
end
--}}}
-- socket_connect {{{
function socket_connect()
    local msg = "  TCP CLIENT SOCKET CONNECT"
    if log_this then
        Export_log(msg)
        print("socket_connect:"..LF..msg)
    end

    c, err = socket.connect(HOST, PORT)
    if err then
        msg = "*** Export_socket .. socket.connect("..HOST.." , "..PORT..") .. err=["..err.."]"
        if log_this then
            Export_log(msg)
            print("socket_connect:"..LF..msg)
        end
    end

    if   c then c:setoption("tcp-nodelay", true) end

    return c
end
--}}}

--------------------------------------------------------------------------------
-- CLIENT REQUEST LOOP ---------------------------------------------------------
--------------------------------------------------------------------------------
-- socket_send {{{
function socket_send(msg)

    if not c then
        local msg = "*** Export_socket .. socket_send .. [NOT CONNECTED]"
        if log_this then
            Export_log(msg)
            print("socket_send:"..LF..msg)
        end

        return
    end

    if not SEND_TO_TARGET then
        --cket.try(      c:send(msg.."\n") )
        local cnt, err = c:send(msg.."\n")
        if err then
            local msg = "*** socket_send: cnt=["..tostring(cnt).."] , err=["..tostring(err).."]"
            if log_this then
                Export_log(msg)
                print("socket_send:"..LF..msg)
            end

            c = nil
        end
    else
        socket_send_to_TARGET( msg )
    end

end
--}}}
-- socket_send_to_TARGET {{{
function socket_send_to_TARGET(msg)

-- NOTE {{{
-- @see $LOCAL/GAMES/IVANWFR/INPUT/THRUSTMASTER/HOTAS/TARGET/SCRIPTS/include/hid.tmh
-- NOTE: TCP needs 2Bytes at the start of each frame
--       indicating the size of the packet
--       ( 2 + size of data that will follow)
--}}}

    local len = 2+string.len( msg )
    while len > 0 and c do
        local bln = math.min(255,len)
        local buf = string.char(bln,0)..msg
        --cket.try(      c:send(buf) )
        local cnt, err = c:send(buf)
        if err then
            local msg = "*** socket_send_to_TARGET: cnt=["..tostring(cnt).."] , err=["..tostring(err).."]"
            if log_this then
                Export_log(msg)
                print("socket_send_to_TARGET:"..LF..msg)
            end

            c = nil
        end
        len = len -bln
    end

end
--}}}
-- get_Export_socket {{{
function get_Export_socket()

    return c
end
--}}}

--------------------------------------------------------------------------------
-- CLOSE CLIENT ----------------------------------------------------------------
--------------------------------------------------------------------------------
-- socket_close {{{
function socket_close()
    if  c then
        c:close()
        c = nil
    end
end
--}}}

--[[ vim
    :only
    :update|vert terminal   luae Export_LISTEN.lua
    :update|     terminal   luae Export_TEST.lua    TESTING
    :update|     terminal   luae Export_TEST.lua    TERMINATING
" Windows Terminal
    :update|!start /b    wt luae Export_LISTEN.lua  COLORED
    :update|!start /b       luae Export_TEST.lua    TESTING
    :update|!start /b       luae Export_TEST.lua    TERMINATING

:e Export.lua
:e Export_task.lua
:e Export_log.lua
"  Export_socket.lua

:e Export_LISTEN.lua
:e Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $LOCAL/GAMES/IVANWFR/INPUT/THRUSTMASTER/HOTAS/TARGET/SCRIPTS/ivanwfr/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
