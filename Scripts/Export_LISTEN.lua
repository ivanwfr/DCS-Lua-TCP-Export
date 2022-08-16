--------------------------------------------------------------------------------
-- Export_LISTEN.lua --- in [Saved Games/DCS/Scripts] -- _TAG (220816:02h:02) --
--------------------------------------------------------------------------------

local COLORED        = arg and arg[1] and (arg[1] == "COLORED")

local PORT           =  5002
local HOST           = "*"

local QUIT           = "quit"

local GRID_COL_MAX   = 3
local GRID_COL_SIZE  = 50
local GRID_FILL_CHAR = "-------------------------------------------------------"

-- TERMIOS {{{
local LF             = "\n"
local LOG_FOLD_OPEN  = "{{{"
local LOG_FOLD_CLOSE = "}}}"

local   ESC   = tostring(string.char(27))
local CLEAR   = COLORED and (ESC.."c"     ) or LF.."CLEAR"
local     R   = COLORED and (ESC.."[1;31m") or "" --     RED
local     G   = COLORED and (ESC.."[1;32m") or "" --   GREEN
local     Y   = COLORED and (ESC.."[1;33m") or "" --  YELLOW
local     B   = COLORED and (ESC.."[1;34m") or "" --    BLUE
local     M   = COLORED and (ESC.."[1;35m") or "" -- MAGENTA
local     C   = COLORED and (ESC.."[1;36m") or "" --    CYAN
local     N   = COLORED and (ESC.."[0m"   ) or "" --      NC

print(CLEAR..N.."  N  "..R.." R"..G.." G "..B.."B  "..C.." C"..M.." M "..Y.."Y")
--}}}
print(LF..C.."@@@ LOADING Export_LISTEN.lua: arg[1]=[".. tostring(arg and arg[1]) .."]"..N)

--{{{
local script_dir        = string.gsub(os.getenv("USERPROFILE")
                        .."/Saved Games/DCS/Scripts", "\\", "/")

local log_file          = nil
local log_file_name     = nil

--}}}

---------------------
-- LOCAL FUNCTIONS --
---------------------
--{{{
local Listen_log
local format_GRID_CELLS
local get_row_col_keys
local handle_request
local listen
local listen_done_close_socket_and_log_file
local log_time
local sleep
local string_split
local table_len
local update_GRID_CELLS

--}}}

--------------------------------------------------------------------------------
-- BIND SERVER SOCKET .. (lib/socket.lua) --------------------------------------
--------------------------------------------------------------------------------
--{{{
if not socket then
    local  script_dir = string.gsub(os.getenv("USERPROFILE") .."/Saved Games/DCS/Scripts", "\\", "/")
    dofile(script_dir.."/lib/socket.lua")
    local  socket = require("socket"    )
end
--}}}
-- JSON {{{
local JSON =  dofile(script_dir.."/lib/JSON.lua")

      JSON.strictTypes = true -- to support metatable
--}}}

--------------------------------------------------------------------------------
-- UPDATE AND FORMAT DATA
--------------------------------------------------------------------------------
-- update_GRID_CELLS {{{

local req_count        = 0
local req_label        = ""
local req              = ""

local REQ_LABEL_EVENT  = "EVENT"
local REQ_LABEL_STREAM = "STREAM"

local GRID_COL_SEP     = N..".."

local GRID_CELLS       = {}
local GRID_COL_SIZE    = {}
local row_col_keys     = {}

function update_GRID_CELLS(o,parent_k)
    for k,v in pairs(o) do
        -------------------
        -- PARENT-CHAIN ---
        -------------------
        --{{{
        k   = parent_k
        and  (parent_k.."."..k)
        or                   k

        --}}}
        -------------------
        -- KEY..VALUE -----
        -------------------
        --{{{
        if((type(v.val) == "string") or (type(v.val) == "number") or (type(v.val) == "boolean")) then

            -------------------------------------------
            -- CELL FORMAT -- f( number..not number) --
            -------------------------------------------
            local val
            =  (type(v.val) == "number" ) and string.format("%2.2f" ,          v.val                   )
            or (type(v.val) == "boolean") and string.format("%s"    ,          v.val and "YES" or "NO" )
            or                                string.format("%s"    , tostring(v.val)                  )

            local cell                      = string.format(" %15s = %-15s ", k, val)

            -------------------------------------------
            -- COLOR ------------ f(new value type) ---
            -------------------------------------------
            local new_item   =              not  GRID_CELLS[k]
            local same_value = not new_item and (GRID_CELLS[k].cell == cell)
            local stream_val = req_label == REQ_LABEL_STREAM
            local event_data = req_label == REQ_LABEL_EVENT

            local color
            =      new_item   and                 Y
            or     stream_val and (same_value and G or Y)
            or     event_data and (same_value and B or C)
            or                                    N

            -------------------------------------------
            -- CELL CACHE ----------- f(row col val) --
            -------------------------------------------
            if GRID_CELLS[k] then
                local old_cell = GRID_CELLS[k]
                if    old_cell.row ~= v.row
                or    old_cell.col ~= v.col
                then
                    row_col_keys = {} -- because ROW,COL has changed
                end
            end
            GRID_CELLS  [k] = { cell=cell , row=v.row , col=v.col , color = color }

            -------------------------------------------
            -- LOG CHANGES ----------------------------
            -------------------------------------------
            if new_item then
                Listen_log("NEW ["..k.."]:"..JSON:encode(GRID_CELLS[k]))
            elseif not same_value then
                Listen_log("MOD ["..k.."]:"..JSON:encode(GRID_CELLS[k]))
            end

            --------------------------------------------
            -- GRID-COLUMN MAX WIDTH -------------------
            --------------------------------------------
            local col = v.col or 0

            GRID_COL_SIZE[col] = math.max(GRID_COL_SIZE[col] or 0, string.len(cell))

        --}}}
        -------------------
        -- SUB-OBJECT -----
        -------------------
        --{{{
        else
            update_GRID_CELLS(v, k)

        end
        --}}}
    end
end
--}}}
-- table_len {{{
function table_len(table)
    local len = 0
    for _,_ in pairs(table) do len = len + 1 end
    return len
end
--}}}
-- get_row_col_keys {{{
function get_row_col_keys(grid_cells)

    local grid_cells_len = table_len(grid_cells)
--print("get_row_col_keys("..grid_cells_len.." grid_cells):")

    if #row_col_keys >= grid_cells_len then
--print("get_row_col_keys: ...OLD "..#row_col_keys.."/"..grid_cells_len.." row_col_keys):")

        return row_col_keys
    end

    -- MAKE A SORTED COLLECTION OF KEYS BY INCREASING ROW,COL
    row_col_keys = {}

    -- add alphanumeric row_col prefix
    for k,v in pairs(grid_cells) do
        if (v.row and v.col) and (v.row>0 and v.col>0) then
            local r_c = string.format("(%2d %2d)__", v.row, v.col)

            table.insert(row_col_keys, r_c..k)
        end
    end

    -- sort alphanumeric oder
    table.sort( row_col_keys )

    -- clear alphanumeric row_col prefix
    for k,v in  pairs(row_col_keys) do

        row_col_keys[k] = row_col_keys[k]:gsub(".*__","")

    end

--print("get_row_col_keys: ...NEW "..#row_col_keys.."/"..grid_cells_len.." row_col_keys):")
    return row_col_keys
end
--}}}
-- format_GRID_CELLS {{{
local timestamp = 0
function format_GRID_CELLS(timestamp)

    ----------------------------------------
    -- GET [row_col_keys] SPECIFIIED ROW,COL
    ----------------------------------------
    local   row_col_keys = get_row_col_keys( GRID_CELLS )

    ----------------------------------------
    -- DO CELLS WITH A SPECIFIIED ROW,COL---
    ----------------------------------------
    --{{{
    local sep
    local cell
    local eol

    local str = ""

    local row = 1
    local col = 1
    local idx = 1

    while idx <= #row_col_keys do
        local k = row_col_keys[idx]
        local v = GRID_CELLS[k]
        -- CELL OR BLANK {{{
        if  v.row and (v.row == row)
        and v.col and (v.col == col)
        then
            v.timestamp = timestamp
            cell        = v.cell
            if GRID_COL_SIZE[col] then
                while string.len(cell) <  GRID_COL_SIZE[col] do cell = " "..cell.." " end
                cell    = v.color.."["..string.format("%-"..GRID_COL_SIZE[col].."s",  cell).."]"
            else
                cell    = v.color.."["..                                              cell .."]"
            end
            idx         = idx+1
        --}}}
        -- FILL BLANK GRID-CELLS {{{
        else
            if GRID_COL_SIZE[col] then
                cell = string.format("[%."..GRID_COL_SIZE[col].."s]", GRID_FILL_CHAR)
            else
                cell = ""
            end

            if     (v.row  < row)                   -- missed row
                or (v.row == row) and (v.col < col) -- missed col
                then
                idx         = idx+1
            end
        end
        --}}}
        -- CONTENT {{{
        sep      = (col > 1) and string.len(cell)>0 and GRID_COL_SEP or ""
        eol      = (col == GRID_COL_MAX) and LF                    or ""
        str      = str .. sep .. cell .. eol
        --}}}
        -- NEXT GRID CELL {{{
        col     = col + 1
        if  col > GRID_COL_MAX then
            row = row+1
            col = 1
        end
        --}}}
    end
    --}}}

    ----------------------------------------
    -- DO CELLS MISSING A SPECIFIIED ROW,COL
    ----------------------------------------
    --{{{
    row = row+1
    col = 1
    local warn_missing_msg = "xxx MISSING ROW-COL from Export_task.GRID_ROW_COL_TEXT:"

    for k,v in pairs(GRID_CELLS) do
        if not v.timestamp or (v.timestamp ~= timestamp) then
            -- [warn_missing_msg] {{{
            v.timestamp = timestamp
            if GRID_COL_SIZE[col] then
                cell        = v.color.."["..string.format("%-"..GRID_COL_SIZE[col].."s",v.cell).."]"
            else
                cell        = v.color.."["..                                            v.cell .."]"
            end
            if warn_missing_msg then
                str = str..LF..warn_missing_msg..LF

                warn_missing_msg = nil -- consume displayed warn_missing_msg
            end
            --}}}
            -- CONTENT {{{
            sep      = (col > 1            ) and GRID_COL_SEP or ""
            eol      = (col == GRID_COL_MAX) and LF           or ""
            str      = str .. sep .. cell .. eol
            --}}}
            -- NEXT GRID CELL {{{
            col    = col + 1
            if col > GRID_COL_MAX then
               row = row+1
               col = 1
            end
            --}}}
        end
    end
    --}}}

    ----------------------------------------
    -- RETURN DELTA HIGHLIGHTED VALUES -----
    ----------------------------------------
    str = string.gsub(str, "[ \n]$", "")
    return str
end
--}}}

--------------------------------------------------------------------------------
-- HANDLE CLIENT REQUESTS
--------------------------------------------------------------------------------
-- listen {{{
function listen()

    local   server =  assert( socket.bind(HOST , PORT))
    local ip, port = server:getsockname()

    local msg = LF
    .."------------------------------------------------------------------------"..LF
    .."--- Export_LISTEN.lua: .. LISTENING IP="..ip.." . port=".. port          ..LF
    .."------------------------------------------------------------------------"
    Listen_log(msg)
    print     (msg)

    while req       ~= QUIT do
        ---------------------------
        -- ACCEPT CLIENT CONNECTION
        ---------------------------
        --{{{
        local client = server:accept() -- SERVER SOCKET: ACCEPT CONNECTION

        msg = "Export_LISTEN.lua .. socket_accept .. "..log_time()..":"
        Listen_log(msg)
        print(Y .. msg)
        --}}}

        ---------------------------
        -- HANDLE CLIENT REQUESTS -
        ---------------------------
        --{{{
        req          = ""
        repeat
            ------------------------------------------------------------------------
            -- READ CLIENT REQUEST -------------------------------------------------
            ------------------------------------------------------------------------
            buf,err = client:receive()

            ------------------------------------------------------------------------
            -- HANDLE SOCKET ERROR -------------------------------------------------
            ------------------------------------------------------------------------
            --{{{
            if  err then

                Listen_log( LOG_FOLD_CLOSE )

                msg = LF.."--- Export_LISTEN.lua: "..tostring(err)
                Listen_log(msg)
                print(Y .. msg)

            --}}}

            ------------------------------------------------------------------------
            -- HANDLE CLIENT REQUEST -----------------------------------------------
            ------------------------------------------------------------------------
            --{{{
            else
                req = string.gsub(buf, "[ \n]$", "")

                if req == QUIT then

                    Listen_log( LOG_FOLD_CLOSE )

                    msg = LF.."--- Export_LISTEN.lua ["..req .."] TERMINATING LISTENER .... "..log_time()..":"
                    Listen_log(msg)
                    print(R .. msg)

                else
                    handle_request( req )

                end
            end
            --}}}

        until err or req==QUIT
        --}}}

    end

    -------------------------------
    -- CLOSE CLIENT CONNECTION ----
    -------------------------------
    --{{{
    listen_done_close_socket_and_log_file(ip,port)

    --}}}

end
--}}}
-- handle_request {{{
local string_split
function handle_request( req )
    -- NEW EVENT OR STREAM-DATA {{{

    local next_event
    =  (string.gsub(req, "Export_task_ActivityNextEvent.*", "NEXT_EVENT") == "NEXT_EVENT")
    or (string.gsub(req, "Export_task_coroutine_handle.*" , "NEXT_EVENT") == "NEXT_EVENT")

    if next_event then

        Listen_log(  LOG_FOLD_CLOSE )
        Listen_log(  LOG_FOLD_OPEN  )

        req_count = (tonumber(string.gsub(req, "[^0-9\.]", "")) or 0 ) -- number-arg

        req_label =  string.find(req, "Export_task_ActivityNextEvent") and REQ_LABEL_EVENT
        or           string.find(req, "Export_task_coroutine_handle" ) and REQ_LABEL_STREAM

    end

    --}}}
    -- REQUEST LINES {{{

    local     req_table = string_split(req,"\n")
    for i=1, #req_table do

        --------------------------
        -- JSON STRINGS PARSING --
        --------------------------
        req =      req_table[i]
        if string.find(req, "{") then

            ------------------------------------------------
            -- COLLECT NEW..OLD [KEYS] AND..OR [VALUES] ----
            ------------------------------------------------
            update_GRID_CELLS( JSON:decode(req) )

            ------------------------------------------------
            -- LAYOUT --------------------------------------
            ------------------------------------------------
            timestamp      =                    timestamp+1
            local grid_str = format_GRID_CELLS( timestamp  )

            ------------------------------------------------
            -- DISPLAY -------------------------------------
            ------------------------------------------------
            if COLORED then
                print(CLEAR..                    grid_str  )
            else
                print(CLEAR.." "..req_label..LF..grid_str  )
            end

        end
    end
    --}}}
end
--}}}
-- listen_done_close_socket_and_log_file {{{

local sleep

function listen_done_close_socket_and_log_file(ip,port)
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
end
--}}}

--------------------------------------------------------------------------------
-- UTIL ------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- log_time {{{
function log_time()

    local curTime =  os.time()

    return ""
    .. string.format(os.date(   "%Y-%m-%d-%H:%M:%S"     , curTime))
    .. string.format(os.date(" (!%Y-%m-%d-%H:%M:%S UTC)", curTime))

end
--}}}
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
-- string_split(s, sep) {{{
function string_split(s, sep)
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

--------------------------------------------------------------------------------
-- START SERVER ----------------------------------------------------------------
--------------------------------------------------------------------------------
listen()

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
