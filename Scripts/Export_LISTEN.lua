--------------------------------------------------------------------------------
-- Export_LISTEN.lua --- in [Saved Games/DCS/Scripts] -- _TAG (220812:03h:45) --
--------------------------------------------------------------------------------
-- TERMIOS {{{
local LOG_FOLD_OPEN           = "{{{"
local LOG_FOLD_CLOSE          = "}}}"

local   ESC = tostring(string.char(27));
local CLEAR = ESC.."c"
local     R = ESC.."[1;31m"     --     RED
local     G = ESC.."[1;32m"     --   GREEN
local     Y = ESC.."[1;33m"     --  YELLOW
local     B = ESC.."[1;34m"     --    BLUE
local     M = ESC.."[1;35m"     -- MAGENTA
local     C = ESC.."[1;36m"     --    CYAN
local     N = ESC.."[0m"        --      NC

--}}}
print(CLEAR..N.."  N  "..R.." R"..G.." G "..B.."B  "..C.." C"..M.." M "..Y.."Y")

print(C.."@@@ LOADING Export_LISTEN.lua"..N)

local PORT =  5002
local HOST = "*"
local QUIT = "quit"

-- %USERPROFILE%/Saved Games/DCS/Logs/Export_log
--{{{
local script_dir        = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
local log_file          = nil
local log_file_name     = nil
--}}}
-- log_time {{{
local function log_time()
    local curTime      = os.time()

    return ""
    .. string.format(os.date(   "%Y-%m-%d-%H:%M:%S"     , curTime))
    .. string.format(os.date(" (!%Y-%m-%d-%H:%M:%S UTC)", curTime))
end --}}}
-- Listen_log {{{
function Listen_log(line)
    -- [log_file ../Logs/Listen.log] {{{
    if not log_file_name then
        log_file_name   = script_dir.."/../Logs/Listen.log"
        log_file        = io.open(log_file_name, "w") -- override log_file
    end
    --}}}
    if  log_file then
        log_file:write(line.."\n")
        log_file:flush()
    end
end
--}}}

--------------------------------------------------------------------------------
-- BIND SERVER SOCKET ----------------------------------------------------------
--------------------------------------------------------------------------------
-- lib/socket.lua {{{
if not socket then
    local  script_dir  = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
    dofile(script_dir.."/lib/socket.lua")
    local  socket = require("socket"    )
end
--}}}
-- socket_bind {{{
local   server =  assert( socket.bind(HOST , PORT))
local ip, port = server:getsockname()

local       LF = "\n"
local msg = LF
.."------------------------------------------------------------------------"..LF
.."--- Export_LISTEN.lua: .. LISTENING IP="..ip.." . port=".. port          ..LF
.."------------------------------------------------------------------------"
Listen_log(msg)
print     (msg)

Listen_log( LOG_FOLD_OPEN  )
print(B ..  LOG_FOLD_OPEN  )

--}}}

--------------------------------------------------------------------------------
-- CLIENT REQUEST LOOP ---------------------------------------------------------
--------------------------------------------------------------------------------
-- string_split(s, sep) {{{
local function string_split(s, sep)
   local   fields = {}
   local      sep = sep or ":"
   local  pattern = "([^"..sep.."]+)"
   s:gsub(pattern , function(c) fields[#fields+1] = c end)
   return  fields
end
--}}}
-- sleep(sec) {{{
function sleep(sec)

    socket.select(nil, nil, sec)

end --}}}

local JSON =  dofile("lib/JSON.lua")
      JSON.strictTypes = true -- to support metatable

local req_count  = 0
local req        = ""
while req       ~= QUIT do
--{{{
    local client = server:accept() -- SERVER SOCKET: ACCEPT CONNECTION
    req          = ""
    repeat
        ------------------------------------------------------------------------
        -- READ CLIENT REQUEST -------------------------------------------------
        ------------------------------------------------------------------------
        buf,err = client:receive()
        if  err then

            Listen_log( LOG_FOLD_CLOSE )
            print(B ..  LOG_FOLD_CLOSE )

            msg = LF.."--- Export_LISTEN.lua: "..tostring(err)
            Listen_log(msg)
            print(Y .. msg)

            Listen_log( LOG_FOLD_OPEN  )
            print(B ..  LOG_FOLD_OPEN  )
        ------------------------------------------------------------------------
        -- HANDLE CLIENT REQUEST -----------------------------------------------
        ------------------------------------------------------------------------
        else
            req = string.gsub(buf, "[ \n]$", "")

            if req == QUIT then

                Listen_log( LOG_FOLD_CLOSE )
                print(B ..  LOG_FOLD_CLOSE )

                msg = LF.."--- Export_LISTEN.lua ["..req .."] TERMINATING LISTENER"
                Listen_log(msg)
                print(R .. msg)

            else
                local     req_table = string_split(req,"\n") -- REQUEST LINES

                local next_event = (string.gsub(req, "Export_task_ActivityNextEvent.*", "next_event") == "next_event")
                if    next_event then
                    req_count = (tonumber(string.gsub(req, "[^0-9\.]", "")) or 0) -- number-arg
                    Listen_log(  LOG_FOLD_CLOSE )
                    print(CLEAR..LOG_FOLD_CLOSE )
                end

                for i=1, #req_table do

                    req =      req_table[i]

                    -- SEPARATOR
                    if((req_count > 0) and (req_count % 10 == 0)) then print() end

                    msg = next_event
                    and    string.format( "%4d | %s", req_count, tostring(req))
                    or     string.format( "%4s | %s", ""       , tostring(req))
                    Listen_log(msg)
                    print(G .. msg)

                    -- JSON
                    if string.find(req, "{") then
                        local  decoded_req =       JSON:decode( req )
                        print(" x DECODED LUA OBJECT xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
                        print(" x decoded_req: "..tostring(decoded_req))
                        print(" - PRETTY JSON OBJECT ----------------------------------------------------------")
                        local pretty_json_VALUE = JSON:encode_pretty(decoded_req)
                        print(pretty_json_VALUE)
                        print(" x xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
                    end

                end

                if next_event then
                    Listen_log(  LOG_FOLD_OPEN  )
                end
            end
        end
    until err or req==QUIT 

end
--}}}

--------------------------------------------------------------------------------
-- CLOSE SERVER ----------------------------------------------------------------
--------------------------------------------------------------------------------
--{{{
msg = LF
.."------------------------------------------------------------------------"..LF
.."--- Export_LISTEN.lua: .. CLOSING   IP="..ip.." . port=".. port          ..LF
.."------------------------------------------------------------------------"..LF
Listen_log(msg)
print(R .. msg)

if  client then
    client:close()
    client = nil
end

if  log_file then
    log_file:close()
    log_file = nil
end

sleep(2)
--}}}

--[[ vim
    :only
    :update|     terminal   luae Export_LISTEN.lua
    :update|     terminal   luae Export_TEST.lua    TESTING
    :update|     terminal   luae Export_TEST.lua    TERMINATING
    :!start /b                   Export_LISTEN.sh

:e Export.lua
:e Export_task.lua
:e Export_log.lua
:e Export_socket.lua

"  Export_LISTEN.lua
:e Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $LOCAL/GAMES/IVANWFR/INPUT/THRUSTMASTER/HOTAS/TARGET/SCRIPTS/ivanwfr/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
