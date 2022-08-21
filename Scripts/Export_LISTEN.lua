--------------------------------------------------------------------------------
-- Export_LISTEN.lua --- in [Saved Games/DCS/Scripts] -- _TAG (220821:23h:08) --
--------------------------------------------------------------------------------

local log_this       = true

local COLORED        = arg and arg[1] and (arg[1] == "COLORED")
local PORT           =  5002
local HOST           = "*"

-- TERMIOS {{{
local LF             = "\n"

--[[
:!start /b explorer "https://en.wikipedia.org/wiki/Electronic_color_code"
:!start /b explorer "https://en.wikipedia.org/wiki/ANSI_escape_code"
:e $LOCALAPPDATA/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json 
--]]

local   ESC   = tostring(string.char(27))
local CLEAR   = COLORED and (ESC.."c"          .. ESC.."c"          ) or LF.."CLEAR" ------ TERMINAL
---------------------------------- BACKGROUND ......... FOREGROUND ---------------------------------
--cal     N   = COLORED and (ESC.."[38;5;255m"..ESC.."[48;5;232m") or "" -- 0 --   WHITE on BLACK
local     N   = COLORED and (ESC.."[38;5;254m"..ESC.."[48;5;234m") or "" -- 0 --   LIGHT on DARK
local     B   = COLORED and (ESC.."[38;5;94m" ..ESC.."[48;5;232m") or "" -- 1 --   BROWN on BLACK
local     R   = COLORED and (ESC.."[38;5;196m"..ESC.."[48;5;232m") or "" -- 2 --     RED on BLACK
local     O   = COLORED and (ESC.."[38;5;214m"..ESC.."[48;5;232m") or "" -- 3 --  ORANGE on BLACK
local     Y   = COLORED and (ESC.."[38;5;226m"..ESC.."[48;5;232m") or "" -- 4 --  YELLOW on BLACK
local     G   = COLORED and (ESC.."[38;5;28m" ..ESC.."[48;5;232m") or "" -- 5 --   GREEN on BLACK
local     L   = COLORED and (ESC.."[38;5;45m" ..ESC.."[48;5;232m") or "" -- 6 --    BLUE on BLACK
local     M   = COLORED and (ESC.."[38;5;129m"..ESC.."[48;5;232m") or "" -- 7 -- MAGENTA on BLACK
local     E   = COLORED and (ESC.."[38;5;244m"..ESC.."[48;5;232m") or "" -- 8 --    GREY on BLACK
local     W   = COLORED and (ESC.."[38;5;255m"..ESC.."[48;5;232m") or "" -- 9 --   WHITE on BLACK

print(CLEAR..N.."-N-"..B.."-B-"..R.."-R-"..O.."-O-"..Y.."-Y-"..G.."-G-"..L.."-L-"..M.."-M-"..R.."-R-"..W.."-W-"..N)
--}}}
print(   E..LF.."@ LOADING Export_LISTEN.lua: arg[1]=[".. tostring(arg and arg[1]) .."]:"..N)

local QUIT           = "quit"
local GRID_COL_MAX   = 3
local GRID_COL_SIZE  = 50
local GRID_FILL_CHAR = "                                                       "

---------------------
-- LOCAL FUNCTIONS --
---------------------
--{{{

local listen
local listen_done_close_socket_and_log_file

local update_GRID_CELLS
local format_GRID_CELLS
local get_row_col_keys
local handle_request

local sleep
local string_split
local table_len

--}}}

--------------------------------------------------------------------------------
-- BIND SERVER SOCKET .. (lib/socket.lua) --------------------------------------
--------------------------------------------------------------------------------
--{{{
local script_dir        = string.gsub(os.getenv("USERPROFILE")
                        .."/Saved Games/DCS/Scripts", "\\", "/")

--}}}
--{{{

local               script_dir = string.gsub(os.getenv("USERPROFILE") .."/Saved Games/DCS/Scripts", "\\", "/")
             dofile(script_dir.."/Export_log.lua"   )
             dofile(script_dir.."/lib/socket.lua")
local  socket = require("socket"    )

if log_this then Export_log_set_log_file_name("Listen.log") end
--}}}
-- JSON {{{
local JSON =  dofile(script_dir.."/lib/JSON.lua")

      JSON.strictTypes = true -- to support metatable
--}}}

--------------------------------------------------------------------------------
-- UPDATE AND FORMAT DATA
--------------------------------------------------------------------------------
-- update_GRID_CELLS {{{

local req              = ""
local req_type         = ""

local REQ_TYPE_EVENT  = "EVENT"
local REQ_TYPE_STREAM = "STREAM"

local GRID_COL_SEP     = N.." "

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
            local stream_val = req_type == REQ_TYPE_STREAM
            local event_data = req_type == REQ_TYPE_EVENT

            local color
            =      new_item   and                      W
            or     stream_val and (same_value and B or O)
            or     event_data and (same_value and G or Y)
            or                                         R

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
            if log_this then
                if new_item then
                    Export_log("NEW ["..k.."]:"..JSON:encode(GRID_CELLS[k]))
                elseif not same_value then
                    Export_log("MOD ["..k.."]:"..JSON:encode(GRID_CELLS[k]))
                end
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

   local str  = LF

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
                cell    = v.color.." "..string.format("%-"..GRID_COL_SIZE[col].."s",  cell).." "
            else
                cell    = v.color.." "..                                              cell .." "
            end
            idx         = idx+1
        --}}}
        -- FILL BLANK GRID-CELLS {{{
        else
            if GRID_COL_SIZE[col] then
                cell = N .. string.format(" %."..GRID_COL_SIZE[col].."s ", GRID_FILL_CHAR)
            else
                cell = ""
            end

            if     (v.row  < row)                   -- missed row (already occupied)
                or (v.row == row) and (v.col < col) -- missed col (already occupied)
                then
                idx         = idx+1
            end
        end
        --}}}
        -- CONTENT {{{
        --p      = (col > 1) and string.len(cell)>0 and GRID_COL_SEP or ""
        sep      =                                      GRID_COL_SEP
        eol      = (col == GRID_COL_MAX)            and LF           or ""
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
            if warn_missing_msg then
                str = str..LF..warn_missing_msg..LF

                warn_missing_msg = nil -- consume displayed warn_missing_msg
            end
            --}}}
            -- CONTENT {{{
            v.timestamp = timestamp

            if GRID_COL_SIZE[col] then
                cell        = v.color.." "..string.format("%-"..GRID_COL_SIZE[col].."s",v.cell).." "
            else
                cell        = v.color.." "..                                            v.cell .." "
            end

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
--  str = string.gsub(str, "[ \n]$", "")
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
    .."@ Export_LISTEN.lua:"                   ..LF
    .."@ LISTENING IP="..ip.." . port=".. port ..LF
    .."@ "..Export_log_time()                  ..LF

    print(LF..E..msg..N)

    if log_this then
        Export_log_FOLD_CLOSE()
        Export_log(msg)
    end

    while req       ~= QUIT do
        ---------------------------
        -- ACCEPT CLIENT CONNECTION
        ---------------------------
        --{{{
        local client = server:accept() -- SERVER SOCKET: ACCEPT CONNECTION

        if log_this then
            local      msg = ""
            ..". Export_LISTEN.lua .. socket_accept .. "..Export_log_time()..":"

            print(Y..  msg ..N)

            Export_log(msg)
        end
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
                local msg = "xxx Export_LISTEN.lua:"  .. LF
                ..          "xxx "..Export_log_time() .. LF
                ..          "xxx "..tostring(err)

                print(O..  msg ..N)

                if log_this then
                    Export_log_FOLD_CLOSE()
                    Export_log(msg)
                end
            --}}}

            ------------------------------------------------------------------------
            -- HANDLE CLIENT REQUEST -----------------------------------------------
            ------------------------------------------------------------------------
            --{{{
            else
                req = string.gsub(buf, "[ \n]$", "")

                if req == QUIT then

                    local      msg = LF
                    .."xxx Export_LISTEN.lua ["..req .."]"
                    .."TERMINATE LISTENER .... "
                    ..Export_log_time()..":"

                    print( R.. msg ..N)

                    if log_this then
                        Export_log_FOLD_CLOSE()
                        Export_log(msg)
                    end

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


--      local req_num = (tonumber(string.gsub(req, "[^0-9\.]", "")) or 0 ) -- number-arg

        req_type =  string.find(req, "Export_task_ActivityNextEvent") and REQ_TYPE_EVENT
        or          string.find(req, "Export_task_coroutine_handle" ) and REQ_TYPE_STREAM

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

            if log_this then Export_log_FOLD_OPEN() end

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
                print(CLEAR..                   grid_str)
            else
                print(CLEAR.." "..req_type..LF..grid_str)
            end

            if log_this then Export_log_FOLD_CLOSE() end
        end
    end
    --}}}
end
--}}}
-- listen_done_close_socket_and_log_file {{{

local sleep

function listen_done_close_socket_and_log_file(ip,port)
    if log_this then
        local msg = LF
        ..". --------------------------------------------------------------"..LF
        ..". -- Export_LISTEN.lua: .. CLOSING   IP="..ip.." . port=".. port ..LF
        ..". --------------------------------------------------------------"..LF
        Export_log(  msg   )
        print(    E..msg..N)

        Export_log_close()
    end

    if  client then
        client:close()
        client = nil
    end

    sleep(2)
end
--}}}

--------------------------------------------------------------------------------
-- UTIL ------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
    :update|vert terminal    luae Export_LISTEN.lua
    :update|     terminal    luae Export_TEST.lua    STARTTEST
    :update|     terminal    luae Export_TEST.lua    TERMINATE
" Windows Terminal
    :update|!start /b wt     luae Export_LISTEN.lua  COLORED
    :update|!start /b        luae Export_TEST.lua    STARTTEST
    :update|!start /b        luae Export_TEST.lua    TERMINATE

:e Export.lua
:e Export_task.lua
:e Export_log.lua
:e Export_socket.lua

"  Export_LISTEN.lua
:e Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $TARGETSCRIPTS/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
