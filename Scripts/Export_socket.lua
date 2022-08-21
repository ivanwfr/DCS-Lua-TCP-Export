--------------------------------------------------------------------------------
-- Export_socket.lua --- in [Saved Games/DCS/Scripts] -- _TAG (220821:18h:15) --
--------------------------------------------------------------------------------
print("@ LOADING Export_socket.lua")

local           HOST = "localhost"
local           PORT =  5002
local    TARGET_PORT =  5001
--[[--FIXME
local SEND_TO_TARGET = true
--local     log_this = true
--]]

-- ENVIRONMENT {{{
local  script_dir  = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
dofile(script_dir.."/Export_log.lua"   )

if log_this then Export_log_set_log_file_name("Export.log") end

local LF = "\n"

--}}}

-- FUNCTIONS {{{

----- PUBLIC
----- get_Export_socket
----- get_SEND_TO_TARGET
----- socket_close
----- socket_connect
----- socket_send

----- PRIVATE
local get_TARGET_PREFIX
local socket_send_to_TARGET

--}}}

--------------------------------------------------------------------------------
-- CLIENT SOCKET CONNECT .. CLOSE ----------------------------------------------
--------------------------------------------------------------------------------
-- ENVIRONMENT {{{
if not socket then
    local  script_dir = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
    dofile(script_dir.."/lib/socket.lua")
    local  socket = require("socket"    )
end
--}}}
-- socket_connect {{{
function socket_connect()
    -- log {{{
    local msg
    = "  TCP CLIENT SOCKET CONNECT"
    ..(SEND_TO_TARGET and "SEND_TO_TARGET" or "")

    if log_this then
        Export_log(msg)
        print( LF..msg)
    end
    --}}}
    local port = SEND_TO_TARGET and TARGET_PORT or PORT
    c, err     = socket.connect(HOST, port)
    -- Handle Error {{{
    if err then
        local msg = "*** Export_socket .. socket.connect("..HOST.." , "..port..") .. err=["..err.."]"
        if log_this then
            Export_log(msg)
        end
        print(     LF..msg)
    end
    --}}}
    -- Socket option {{{
    if   c then c:setoption("tcp-nodelay", true) end

    --}}}
    return c
end
--}}}
-- socket_close {{{
function socket_close()
    if  c then
        c:close()
        c = nil
    end
end
--}}}

--------------------------------------------------------------------------------
-- CLIENT SOCKET SEND REQUEST --------------------------------------------------
--------------------------------------------------------------------------------
-- socket_send {{{
function socket_send(msg)

    -- NOT CONNECTED {{{
    if not c then
        local msg = "*** Export_socket .. socket_send .. [NOT CONNECTED]"
        if log_this then
            Export_log(msg)
        end
        print( LF..msg)

        return
    end
    --}}}

    if         SEND_TO_TARGET then
        socket_send_to_TARGET( msg )
    else
        -- Send Message {{{
        local cnt, err = c:send(msg.."\n")
        --}}}
        -- Handle Error {{{
        if err then
            local msg = "*** socket_send: cnt=["..tostring(cnt).."] , err=["..tostring(err).."]"
            if log_this then
                Export_log(msg)
            end
            print( LF..msg)

            c = nil
        end
        --}}}
    end

end
--}}}
-- socket_send_to_TARGET {{{
function socket_send_to_TARGET(msg)

-- NOTE {{{
-- @see $TARGETSCRIPTS/../include/hid.tmh
-- NOTE: TCP needs 2Bytes at the start of each frame
--       indicating the size of the packet
--       ( 2 + size of data that will follow)
--}}}

    msg = "JSON="..msg

    local len = string.len( msg )
print("socket_send_to_TARGET(msg len="..len..") :"..LF..msg)

    while len > 0 and c do
        -- Send Message {{{

        local bln
        = string.len( msg )

        local buf
        =  get_TARGET_PREFIX(msg)
        .. msg

        local cnt, err = c:send(buf)

        --}}}
        -- Handle Error {{{
        if err then
            local msg = "*** socket_send_to_TARGET: cnt=["..tostring(cnt).."] , err=["..tostring(err).."]"
            if log_this then
                Export_log(msg)
            end
            print( LF..msg)

            c = nil
        end
        --}}}
        len = len - bln
    end

end
--}}}
-- get_Export_socket {{{
function get_Export_socket()

    return c
end
--}}}
-- get_SEND_TO_TARGET {{{
function get_SEND_TO_TARGET()

    return SEND_TO_TARGET
end
--}}}
-- get_TARGET_PREFIX {{{
function get_TARGET_PREFIX(msg)

    local len = 2+string.len(msg)
    local bl1 =  len       % 256
    local bl2 = (len -bl1) / 256
    local pfx = string.char(bl1,bl2)

--print("msg=[".. tostring( msg ) .."]")--FIXME
--print("pfx=[".. tostring( pfx ) .."]")--FIXME
    return pfx
end
--}}}

--[[ vim
    :only
    :update|vert terminal    luae Export_LISTEN.lua
    :update|     terminal    luae Export_TEST.lua    TESTING
    :update|     terminal    luae Export_TEST.lua    TERMINATING
" Windows Terminal
    :update|!start /b wt     luae Export_LISTEN.lua  COLORED
    :update|!start /b        luae Export_TEST.lua    TESTING
    :update|!start /b        luae Export_TEST.lua    TERMINATING

:e Export.lua
:e Export_task.lua
:e Export_log.lua
"  Export_socket.lua

:e Export_LISTEN.lua
:e Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $TARGETSCRIPTS/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
