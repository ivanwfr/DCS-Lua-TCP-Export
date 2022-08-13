--------------------------------------------------------------------------------
-- Export_LISTEN.lua --- in [Saved Games/DCS/Scripts] -- _TAG (220813:02h:22) --
--------------------------------------------------------------------------------
print("@@@ LOADING Export_LISTEN.lua: arg[1]=[".. tostring(arg and arg[1]) .."]")
local COLORED = arg and arg[1] and (arg[1] == "COLORED")
-- TERMIOS {{{
local LF             = "\n"
local LOG_FOLD_OPEN  = "{{{"
local LOG_FOLD_CLOSE = "}}}"

local   ESC   = tostring(string.char(27));
local CLEAR   = COLORED and (ESC.."c"     ) or "" 
local     R   = COLORED and (ESC.."[1;31m") or "" --     RED
local     G   = COLORED and (ESC.."[1;32m") or "" --   GREEN
local     Y   = COLORED and (ESC.."[1;33m") or "" --  YELLOW
local     B   = COLORED and (ESC.."[1;34m") or "" --    BLUE
local     M   = COLORED and (ESC.."[1;35m") or "" -- MAGENTA
local     C   = COLORED and (ESC.."[1;36m") or "" --    CYAN
local     N   = COLORED and (ESC.."[0m"   ) or "" --      NC

print(CLEAR..N.."  N  "..R.." R"..G.." G "..B.."B  "..C.." C"..M.." M "..Y.."Y")
--}}}
print(C.."@@@ LOADING Export_LISTEN.lua"..N)

local PORT =  5002
local HOST = "*"
local QUIT = "quit"

--------------------------------------------------------------------------------
-- %USERPROFILE%/Saved Games/DCS/Logs/Export_log
--------------------------------------------------------------------------------
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

local msg = LF
.."------------------------------------------------------------------------"..LF
.."--- Export_LISTEN.lua: .. LISTENING IP="..ip.." . port=".. port          ..LF
.."------------------------------------------------------------------------"
Listen_log(msg)
print     (msg)

Listen_log( LOG_FOLD_OPEN  )

--}}}

--------------------------------------------------------------------------------
-- HANDLE CLIENT REQUESTS ------------------------------------------------------
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
-- update_GRID_CELLS {{{
local req_count  = 0
local req_label  = ""
local req        = ""

local REQ_LABEL_EVENT  = "EVENT"
local REQ_LABEL_STREAM = "STREAM"

local GRID_COL_MAX  = 4
local GRID_COL_SEP  = N..".."
local GRID_COL_SIZE = 50

local GRID_CELLS = {}
local          str = ""
local          col = 0
local          row = 0

function update_GRID_CELLS(o,parent_k)

    for k,v in pairs(o) do

        k   = parent_k
        and  (parent_k.."."..k)
        or                   k

        if((type(v) == "string") or (type(v) == "number") or (type(v) == "boolean")) then

            -- CELL FORMAT
            v  = (type(v) == "number" ) and          string.format("%16.2f",          v                   )
            or   (type(v) == "boolean") and          string.format("%16s"  ,          v and "YES" or "NO" )
            or                                       string.format("%16s"  , tostring(v)                  )

            local cell = string.format(" %-20s = %-25s ", k, v)

            -- COLOR
            local new_item   =              not  GRID_CELLS[k]
            local same_value = not new_item and (GRID_CELLS[k].cell == cell)
            local stream_val = req_label == REQ_LABEL_STREAM
            local event_data = req_label == REQ_LABEL_EVENT

            local color
            =      new_item   and N
            or    (stream_val and G or Y)
            or    (event_data and B or C)
            or                    N

            -- CELL CACHE
            if GRID_CELLS[k] then GRID_CELLS[k] = { cell = cell , color = color }
            else                  GRID_CELLS[k] = { cell = cell , color = color }
            end

        else
            update_GRID_CELLS(v, k)
        end

    end

    str = string.gsub(str, "\n$", "") -- strip ending LF

    return str
end
--}}}
-- format_GRID_CELLS {{{
function format_GRID_CELLS()

    local str = ""
    local col = 0
    local row = 0

    for k,v in pairs(GRID_CELLS) do

            -- CELL ROW COL
            col =  col + 1
            if     col > GRID_COL_MAX then str = str..LF          ; col = 1; row = row+1
            elseif col > 1            then str = str..GRID_COL_SEP
            end

            str =  str..GRID_CELLS[k].color.."["..GRID_CELLS[k].cell.."]"

    end

    return str
end
--}}}

local JSON =  dofile(script_dir.."/lib/JSON.lua")
      JSON.strictTypes = true -- to support metatable

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

            msg = LF.."--- Export_LISTEN.lua: "..tostring(err)
            Listen_log(msg)
            print(Y .. msg)

            Listen_log( LOG_FOLD_OPEN  )
        ------------------------------------------------------------------------
        -- HANDLE CLIENT REQUEST -----------------------------------------------
        ------------------------------------------------------------------------
        else
            req = string.gsub(buf, "[ \n]$", "")

            if req == QUIT then

                Listen_log( LOG_FOLD_CLOSE )

                msg = LF.."--- Export_LISTEN.lua ["..req .."] TERMINATING LISTENER"
                Listen_log(msg)
                print(R .. msg)

            else
                local     req_table = string_split(req,"\n") -- REQUEST LINES

                local next_event
                =  (string.gsub(req, "Export_task_ActivityNextEvent.*", "NEXT_EVENT") == "NEXT_EVENT")
                or (string.gsub(req, "Export_task_coroutine_handle.*" , "NEXT_EVENT") == "NEXT_EVENT")

                if    next_event then
                    Listen_log(  LOG_FOLD_CLOSE )
                    print(CLEAR)

                    req_count = (tonumber(string.gsub(req, "[^0-9\.]", "")) or 0 ) -- number-arg

                    req_label =  string.find(req, "Export_task_ActivityNextEvent") and REQ_LABEL_EVENT
                    or           string.find(req, "Export_task_coroutine_handle" ) and REQ_LABEL_STREAM


                    msg = string.format("[%d] %s", req_count, req_label)
                    Listen_log(   msg)
                    print     (M..msg)

                end

                for i=1, #req_table do

                    if((req_count > 0) and (req_count % 10 == 0)) then
                        Listen_log("")
                    end -- SEPARATOR

                    req =      req_table[i]
--print("@@@ req=["..req.."]")

                    --[[ [msg] --{{{
                    msg = string.format("msg=[%s]", tostring(req))
                    Listen_log(msg)
                    print(G .. msg)
                    --}}}--]]

                    ---[[ [JSON] --{{{
                    if string.find(req, "{") then

                        local decoded_req       = JSON:decode          (        req)
                        local        json_VALUE = JSON:encode          (decoded_req)
                        local pretty_json_VALUE = JSON:encode_pretty   (decoded_req)
--print("@@@ json_VALUE=["..json_VALUE.."]")
                                                  update_GRID_CELLS(decoded_req)
                        local grid_str          = format_GRID_CELLS()

                        Listen_log(pretty_json_VALUE)

                        print(Y .. grid_str)

                    end
                    --}}}--]]
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
