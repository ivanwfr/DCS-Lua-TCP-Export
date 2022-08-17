--------------------------------------------------------------------------------
-- Export_task.lua ----- in [Saved Games/DCS/Scripts] -- _TAG (220817:18h:07) --
--------------------------------------------------------------------------------

local ACTIVITY_INTERVAL    = 1.0 -- SET TO 0 TO DISABLE --FIXME
local ACTIVITY_START_DELAY = 0.0
--local log_this           = true

print("@ LOADING Export_task.lua: arg[1]=[".. tostring(arg and arg[1]) .."]:")

-----------------------------------------------------------
-- CUSTOMIZABLE LISTENER-OUTPUT LAYOUT-TEMPLATE -----------
-----------------------------------------------------------
local GRID_ROW_COL_TEXT    = ""
-- STREAM
.."    MTime        SeaAlt           GndAlt             \n"
-- EVENTS
.."    Bank         LatLongAlt_Alt   Position_x         \n"
.."    Heading      LatLongAlt_Lat   Position_y         \n"
.."    Pitch        LatLongAlt_Long  Position_z         \n"
.."    Name         GroupName        Coalition          \n"
.."    Country      UnitName         CoalitionID        \n"
.."    label                                            \n"
.."    Type_level1      Type_level3                     \n"
.."    Type_level2      Type_level4                     \n"
.."    Flags_AI_ON  Flags_IRJamming  Flags_RadarActive  \n"
.."    Flags_Born   Flags_Invisible  Flags_Static       \n"
.."    Flags_Human  Flags_Jamming                       \n"

--[[
:only|update|terminal luae % check_GRID_ROW_COL_TABLE
--]]

---------------------
-- LOCAL FUNCTIONS --
---------------------
--{{{
----- PUBLIC
----- CoroutineResume
----- Export_task_ActivityNextEvent
----- Export_task_AfterNextFrame
----- Export_task_BeforeNextFrame
----- Export_task_Start
----- Export_task_Stop


local Export_task_coroutine_handle
local Export_task_coroutine_start
local build_GRID_ROW_COL_TABLE
local add_object_to_GRID_CELLS
local get_time_and_altitude

local string_split
local table_len

--}}}

--------------------------------------------------------------------------------
-- ENVIRONMENT [script_dir] [Export_log] [Export_socket] [JSON] ----------------
--------------------------------------------------------------------------------
--{{{
local               script_dir = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
             dofile(script_dir.."/Export_log.lua"   )
             dofile(script_dir.."/Export_socket.lua")
local JSON = dofile(script_dir.."/lib/JSON.lua")
      JSON.strictTypes = true -- to support metatable

if log_this then Export_log_set_log_file_name("Export.log") end

local LF              = "\n"
--}}}

--------------------------------------------------------------------------------
-- EXPORT CYCLE ------------------------------------------ (public functions) --
--------------------------------------------------------------------------------
function Export_task_Start() ----------------- CONNECT localhost:5001 -------{{{
    print(". Export_task_Start")

    ----------------------------------------
    -- START SENDING STREAM AND EVENTS -----
    ----------------------------------------
    local msg = "Export_task_Start .. socket_connect .. "..Export_log_time()..":"
    if log_this then
        Export_log( msg )
        print     ( msg )
    end

    local c = socket_connect()

    if ACTIVITY_INTERVAL > 0 then
        Export_task_coroutine_start()
    end

end
--}}}
function Export_task_BeforeNextFrame() ------- SEND  frame data -------------{{{

end
--}}}
function Export_task_AfterNextFrame() -------- SEND  frame data -------------{{{

end
--}}}
function Export_task_ActivityNextEvent(t) ---- SEND  LoGetSelfData --------- {{{

    ----------------------------------------
    -- SEND EVENT OBJECTS ------------------
    ----------------------------------------
    local msg = "Export_task_ActivityNextEvent("..t.."):"
    if log_this then
        Export_log( msg )
        print     ( msg )
    end

    socket_send   ( msg )

    ----------------------------------------
    -- grid_cells {k, v, row,col} ----------
    ----------------------------------------
    local          o = LoGetSelfData()

    local grid_cells = add_object_to_GRID_CELLS( o )

    local       json = JSON:encode( grid_cells )
    if log_this then
        Export_log_FOLD_OPEN()
        Export_log( json )
--      print     ( json )
        Export_log_FOLD_CLOSE()
    end

    socket_send   ( json )

    return  t+1 -- so as to be called again
end
--}}}
function Export_task_Stop() ------------------ CLOSE SOCKET -----------------{{{

    local msg = "Export_task_Stop ... socket_close .... "..Export_log_time()..":"
    if log_this then
        Export_log_FOLD_CLOSE()
        Export_log( msg )
        print     ( msg )
    end

    socket_close()

end
--}}}

--------------------------------------------------------------------------------
-- DATA STREAM COROUTINE -------------------------------------------------------
--------------------------------------------------------------------------------
-- Export_task_coroutine_handle -------------- STREAMING STEP ---------------{{{
function Export_task_coroutine_handle(t)

repeat

    ----------------------------------------
    -- SEND STREAM DATA --------------------
    ----------------------------------------
    local      msg = "Export_task_coroutine_handle("..t.."):"
    if log_this then
        Export_log ( msg )
        print      ( msg )
    end

    socket_send    ( msg )

    ----------------------------------------
    -- {MTime, SeaAlt, GndAlt} -------------
    ----------------------------------------
    local json     = get_time_and_altitude()
    if log_this then
        Export_log_FOLD_OPEN()
        Export_log ( json )
--      print      ( json )
        Export_log_FOLD_CLOSE()
    end

    socket_send    ( json )

    ----------------------------------------
    -- next call ---------------------------
    ----------------------------------------
    t = coroutine.yield()

until get_Export_socket() == nil

end
--}}}
-- CoroutineResume -- (public funciton) ------ STREAMING STEP INDEX ---------{{{
function CoroutineResume(index,t)

           coroutine.resume(Coroutines[index], t)

    return coroutine.status(Coroutines[index]   ) ~= "dead"
end
--}}}
-- Export_task_coroutine_start ---------------- STREAMING START --------------{{{
function Export_task_coroutine_start()

    local msg = "Export_task_coroutine_start"
    if log_this then
        Export_log(msg)
        print(msg)
    end

    Coroutines                  = {}
    CoroutineIndex              = 1
    Coroutines[CoroutineIndex]  = coroutine.create(Export_task_coroutine_handle)

    LoCreateCoroutineActivity(CoroutineIndex, ACTIVITY_START_DELAY, ACTIVITY_INTERVAL)
end
--}}}

--------------------------------------------------------------------------------
-- UTIL ------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- string_split {{{
function string_split(s, sep)
   local   fields = {}
   local      sep = sep or ":"
   local  pattern = "([^"..sep.."]+)"
   s:gsub(pattern , function(c) fields[#fields+1] = c end)
   return  fields
end
--}}}
-- table_len {{{
function table_len(table)
    local len = 0
    for _,_ in pairs(table) do len = len + 1 end
    return len
end
--}}}
-- get_time_and_altitude {{{
function get_time_and_altitude()

    local MTime  =            LoGetModelTime()
    local SeaAlt = math.floor(LoGetAltitudeAboveSeaLevel   ())
    local GndAlt = math.floor(LoGetAltitudeAboveGroundLevel())

    local o
    = {   MTime = MTime
    ,    SeaAlt = SeaAlt
    ,    GndAlt = GndAlt }

    local  grid_cells = add_object_to_GRID_CELLS(o)

    local  json       = JSON:encode(grid_cells)
    return json
end
--}}}

--------------------------------------------------------------------------------
-- GRID_ROW_COL_TABLE ----------------------------------------------------------
--------------------------------------------------------------------------------
-- build_GRID_ROW_COL_TABLE {{{

local GRID_ROW_COL_TABLE = {}

function build_GRID_ROW_COL_TABLE()

    local       rows = string_split(GRID_ROW_COL_TEXT, LF)
    for row=1, #rows do
        local       cols = string_split(rows[row], " ")
        for col=1, #cols do
            local                 label = cols[col]

            -- skip empty cell "-----------" placeholder
            if label:gsub("[^a-zA-Z0-9]","") ~= "" then
                GRID_ROW_COL_TABLE[ label ] = { row=row , col=col }
            end
        end
    end


    if log_this then
        local msg = "build_GRID_ROW_COL_TABLE:"
        ..LF..      "[GRID_ROW_COL_TEXT ]: contains "..#rows.." lines of text"
        ..LF..      "[GRID_ROW_COL_TABLE]:"
        ..LF.. JSON:encode( GRID_ROW_COL_TABLE ):gsub("{\n",""):gsub("},","}\n,")
        Export_log( msg )
        print     ( msg )
    end
    print("@ USING "..table_len( GRID_ROW_COL_TABLE ).." CELLS in [GRID_ROW_COL_TABLE] ")
end
--}}}
-- add_object_to_GRID_CELLS {{{
local                  GRID_CELLS = {}
function add_object_to_GRID_CELLS(o, parent_k)

    if not parent_k then
        GRID_CELLS = {}
    end

    for k,v in pairs(o) do

        ------------------
        -- LABEL [k] -----
        ------------------
        if parent_k then
            k =  parent_k.."_"..k
        end

        ------------------
        -- INNER TABLE ---
        ------------------
        local is_a_table = (type(v) ~= "string") and (type(v) ~= "number") and (type(v) ~= "boolean")
        if    is_a_table then
            add_object_to_GRID_CELLS(v, k)

        ------------------
        -- SINGLE ITEM ---
        ------------------
        else
            v  = (type(v) == "number")
            and   string.format("%2.2f",          v )
            or    string.format("%s"   , tostring(v))

            if     table_len(GRID_ROW_COL_TABLE)== 0 then build_GRID_ROW_COL_TABLE()       end

            local     row = (GRID_ROW_COL_TABLE[k]    and       GRID_ROW_COL_TABLE[k].row) or 0
            local     col = (GRID_ROW_COL_TABLE[k]    and       GRID_ROW_COL_TABLE[k].col) or 0

            GRID_CELLS[k] = { val=v , row=row , col=col }
        end

    end

    return GRID_CELLS
end
--}}}
-- check_GRID_ROW_COL_TABLE --
--{{{
--[[
:only|update|terminal luae % check_GRID_ROW_COL_TABLE
:only 
--]]

if arg and arg[1] and (arg[1] == "check_GRID_ROW_COL_TABLE") then

    if table_len(GRID_ROW_COL_TABLE) == 0 then build_GRID_ROW_COL_TABLE() end

    print("@ DONE "..arg[1]..":")
    print()

    os.exit()
end
--}}}

--[[ vim
    :only
    :update|vert terminal    luae Export_LISTEN.lua
    :update|     terminal    luae Export_TEST.lua    TESTING
    :update|     terminal    luae Export_TEST.lua    TERMINATING
" Windows Terminal
    :update|!start /b wt_ECC luae Export_LISTEN.lua  COLORED
    :update|!start /b        luae Export_TEST.lua    TESTING
    :update|!start /b        luae Export_TEST.lua    TERMINATING

:e Export.lua
"  Export_task.lua
:e Export_log.lua
:e Export_socket.lua

:e Export_LISTEN.lua
:e Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $LOCAL/GAMES/IVANWFR/INPUT/THRUSTMASTER/HOTAS/TARGET/SCRIPTS/ivanwfr/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
