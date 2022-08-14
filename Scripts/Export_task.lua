--------------------------------------------------------------------------------
-- Export_task.lua ----- in [Saved Games/DCS/Scripts] -- _TAG (220814:19h:14) --
--------------------------------------------------------------------------------
--int("@@@ LOADING Export_task.lua")
print("@ LOADING Export_task.lua: arg[1]=[".. tostring(arg and arg[1]) .."]:")

-----------------------------------------------------------
-- CUSTOMIZABLE LISTENER-OUTPUT LAYOUT-TEMPLATE -----------
-----------------------------------------------------------
local GRID_ROW_COL_TEXT    = ""
.."    MTime        SeaAlt           GndAlt             \n"
.."    Bank         LatLongAlt_Alt   Position_x         \n"
.."    Heading      LatLongAlt_Lat   Position_y         \n"
.."    Pitch        LatLongAlt_Long  Position_z         \n"
.."    Name         GroupName        Coalition          \n"
.."    Country      UnitName         CoalitionID        \n"
.."    label        -----------      -----------        \n"
.."    -----------  Type_level1      Type_level3        \n"
.."    -----------  Type_level2      Type_level4        \n"
.."    Flags_AI_ON  Flags_IRJamming  Flags_RadarActive  \n"
.."    Flags_Born   Flags_Invisible  Flags_Static       \n"
.."    Flags_Human  Flags_Jamming                       \n"

--------------------------------
-- RECURRING DATA STREAM -------
--------------------------------
local ACTIVITY_START_DELAY = 0.5
local ACTIVITY_INTERVAL    = 1.0 -- SET TO 0 TO DISABLE

--local log_this = true

--------------------------------------------------------------------------------
-- ENVIRONMENT [script_dir] [JSON] ---------------------------------------------
--------------------------------------------------------------------------------
--{{{
local               script_dir = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
             dofile(script_dir.."/Export_log.lua"   )
             dofile(script_dir.."/Export_socket.lua")
local JSON = dofile(script_dir.."/lib/JSON.lua")
      JSON.strictTypes = true -- to support metatable

local LF              = "\n"
local LOG_FOLD_OPEN  = "{{{"
local LOG_FOLD_CLOSE = "}}}"
--}}}

local GRID_ROW_COL_TABLE = {}

-- string_split {{{
function string_split(s, sep)
   local   fields = {}
   local      sep = sep or ":"
   local  pattern = "([^"..sep.."]+)"
   s:gsub(pattern , function(c) fields[#fields+1] = c end)
   return  fields
end
--}}}
-- build_GRID_ROW_COL_TABLE {{{
local function build_GRID_ROW_COL_TABLE()

--[[
:only|update|terminal luae % check_GRID_ROW_COL_TABLE
:only 
--]]

    local       rows = string_split(GRID_ROW_COL_TEXT, LF)
print("...#rows["..#rows.."]")

    for row=1, #rows do
        local       cols = string_split(rows[row], " ")
        for col=1, #cols do
            local                 label = cols[col]

            -- skip empty cell "-----------" placeholder
            if label:gsub("-","") ~= "" then
                GRID_ROW_COL_TABLE[ label ] = { row=row , col=col }
            end
        end
    end

  print("GRID_ROW_COL_TABLE:"..LOG_FOLD_OPEN..LF..JSON:encode       (GRID_ROW_COL_TABLE):gsub("{\n",""):gsub("},","}\n,")..LF..LOG_FOLD_CLOSE)

end
--}}}
-- check_GRID_ROW_COL_TABLE {{{
if arg and arg[1] and (arg[1] == "check_GRID_ROW_COL_TABLE") then

    if #GRID_ROW_COL_TABLE == 0 then build_GRID_ROW_COL_TABLE() end

    print("@ DONE arg[1]:")
    print()
    os.exit()
end
--}}}

--------------------------------------------------------------------------------
-- UTIL ------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
            and   string.format("%.2f",          v )
            or    string.format("%s"  , tostring(v))

            if              #GRID_ROW_COL_TABLE == 0 then build_GRID_ROW_COL_TABLE()       end

            local     row = (GRID_ROW_COL_TABLE[k]    and       GRID_ROW_COL_TABLE[k].row) or 0
            local     col = (GRID_ROW_COL_TABLE[k]    and       GRID_ROW_COL_TABLE[k].col) or 0

            GRID_CELLS[k] = { val=v , row=row , col=col }
        end

    end

    return GRID_CELLS
end
--}}}

--------------------------------------------------------------------------------
-- EXPORT CYCLE ----------------------------------------------------------------
--------------------------------------------------------------------------------
function Export_task_Start() ----------------- CONNECT localhost:5001 ------------{{{
print("Export_task_Start")

    local      msg = "Export_task_Start .. socket_connect .. "..log_time()..":"..LF..LOG_FOLD_OPEN
    Export_log(msg)
    print     (msg)

    local c = socket_connect()

    Export_task_coroutine_start() --FIXME

end
--}}}
function Export_task_BeforeNextFrame() ------- SEND  frame data -------------{{{

end
--}}}
function Export_task_AfterNextFrame() -------- SEND  frame data -------------{{{

end
--}}}
function Export_task_ActivityNextEvent(t) ---- SEND  LoGetSelfData --------------- {{{

    -- STREAM OR EVENT
    local           msg = "Export_task_ActivityNextEvent("..t.."):"
    if log_this then
        Export_log( msg)
        print      (msg)
    end
    socket_send(msg)

    -- k,v , row,col
    local    o = LoGetSelfData( )

    local grid_cells = add_object_to_GRID_CELLS( o )

--print("@@@ Export_task.Export_task_ActivityNextEvent: grid_cells:"..LF..JSON:encode_pretty(grid_cells))

    local json = JSON:encode( grid_cells )
--print("@@@ json:"..LF..json)

    -- SEND grid_cells
    msg        = json
    if log_this then
        Export_log (msg)
        print      (msg)
    end
    socket_send(msg)

    return  t+1 -- so as to be called again
end
--}}}
function Export_task_Stop() ------------------ CLOSE SOCKET ----------------------{{{

    local      msg = LOG_FOLD_CLOSE..LF.."Export_task_Stop ... socket_close .... "..log_time()..":"
    Export_log(msg)
    print     (msg)

    socket_close()

    if  log_file then
        log_file:flush()
    end
end
--}}}

--------------------------------------------------------------------------------
-- DATA STREAM COROUTINE -------------------------------------------------------
--------------------------------------------------------------------------------
function Export_task_coroutine_handle(t) ----- STREAMING STEP --------------------{{{

repeat

    local       msg = "Export_task_coroutine_handle("..t.."):"
    Export_log( msg)
    socket_send(msg)
    print      (msg)

    json = get_time_and_altitude()

---[[--{{{
    msg   =     json
    Export_log( msg)
    socket_send(msg)
    print      (msg)
--}}}--]]
    local json = JSON:encode( o )

    t = coroutine.yield()

until get_Export_socket() == nil

end
--}}}
function CoroutineResume(index,t)------------- STREAMING STEP INDEX --------------{{{

           coroutine.resume(Coroutines[index], t)

    return coroutine.status(Coroutines[index]   ) ~= "dead"
end
--}}}
function Export_task_coroutine_start()   ----- STREAMING START -------------------{{{

    local msg = "Export_task_coroutine_start"
    Export_log(msg)
    print(msg)

    Coroutines                  = {}
    CoroutineIndex              = 1
    Coroutines[CoroutineIndex]  = coroutine.create(Export_task_coroutine_handle)

    if ACTIVITY_INTERVAL > 0 then
        LoCreateCoroutineActivity(CoroutineIndex, ACTIVITY_START_DELAY, ACTIVITY_INTERVAL)
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
