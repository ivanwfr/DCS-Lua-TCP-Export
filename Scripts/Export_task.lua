--------------------------------------------------------------------------------
-- Export_task.lua ----- in [Saved Games/DCS/Scripts] -- _TAG (220814:03h:46) --
--------------------------------------------------------------------------------
print("@@@ LOADING Export_task.lua")

local GRID_ROW_COL
    = { MTime      ={row= 1,col=1} , SeaAlt         ={row= 1,col=2} ,       GndAlt     ={row= 1,col=3}
    ,   Bank       ={row= 2,col=1} , LatLongAlt_Alt ={row= 2,col=2} ,       Position_x ={row= 2,col=3}
    ,   Heading    ={row= 3,col=1} , LatLongAlt_Lat ={row= 3,col=2} ,       Position_y ={row= 3,col=3}
    ,   Pitch      ={row= 4,col=1} , LatLongAlt_Long={row= 4,col=2} ,       Position_z ={row= 4,col=3}
    ,   Name       ={row= 5,col=1} ,       GroupName={row= 5,col=2} ,       Coalition  ={row= 5,col=3}
    ,   Country    ={row= 6,col=1} ,       UnitName ={row= 6,col=2} ,       CoalitionID={row= 6,col=3}
    ,   label      ={row= 7,col=3}
    ,                                    Type_level1={row= 8,col=2} ,       Type_level3={row= 8,col=3}
    ,                                    Type_level2={row= 9,col=2} ,       Type_level4={row= 9,col=3}
    ,   Flags_AI_ON={row=10,col=1} , Flags_IRJamming={row=10,col=2} , Flags_RadarActive={row=10,col=3}
    ,   Flags_Born ={row=11,col=1} , Flags_Invisible={row=11,col=2} , Flags_Static     ={row=11,col=3}
    ,   Flags_Human={row=12,col=1} , Flags_Jamming  ={row=12,col=2}
    }

--[[
local log_this = true
--]]

--------------------------------------------------------------------------------
------------------------------------------------------------------ PARAMETERS --
--------------------------------------------------------------------------------
local LOG_FOLD_OPEN           = "{{{"
local ACTIVITY_START_DELAY    = 0.5
local ACTIVITY_INTERVAL       = 2.0


local LF                      = "\n"

local LOG_FOLD_CLOSE          = "}}}"

--------------------------------------------------------------------------------
--------------------------------------------- ENVIRONMENT [script_dir] [JSON] --
--------------------------------------------------------------------------------
--{{{
local               script_dir = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
             dofile(script_dir.."/Export_log.lua"   )
             dofile(script_dir.."/Export_socket.lua")
local JSON = dofile(script_dir.."/lib/JSON.lua")
      JSON.strictTypes = true -- to support metatable
--}}}

--------------------------------------------------------------------------------
------------------------------------------------------------------------ UTIL --
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
print("get_time_and_altitude: o:"..LF..JSON:encode_pretty(o))--FIXME

    local grid_cells = add_object_to_GRID_CELLS( o )
print("get_time_and_altitude: grid_cells:"..LF..JSON:encode_pretty(grid_cells))--FIXME

--[[
/MTime\|SeaAlt\|GndAlt
--]]
    local json = JSON:encode( grid_cells )

    local str = ""
    ..string.format( " MTime=[%4d]" ,  MTime)
    ..string.format(" SeaAlt=[%5dm]", SeaAlt)
    ..string.format(" GndAlt=[%5dm]", GndAlt)

    return str, json
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

            local     row = (GRID_ROW_COL[k] and GRID_ROW_COL[k].row) or 0
            local     col = (GRID_ROW_COL[k] and GRID_ROW_COL[k].col) or 0
            GRID_CELLS[k] = { val=v , row=row , col=col }
        end

    end

    return GRID_CELLS
end
--}}}

--------------------------------------------------------------------------------
---------------------------------------------------------------- EXPORT CYCLE --
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
------------------------------------------------------- DATA STREAM COROUTINE --
--------------------------------------------------------------------------------
function Export_task_coroutine_handle(t) ----- STREAMING STEP --------------------{{{

repeat

    local       msg = "Export_task_coroutine_handle("..t.."):"
    Export_log( msg)
    socket_send(msg)
    print      (msg)

    str, json = get_time_and_altitude()

--[[--{{{
    msg =       str
    Export_log (msg)
    print      (msg)
    socket_send(msg)
--}}}--]]

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

    LoCreateCoroutineActivity(CoroutineIndex, ACTIVITY_START_DELAY, ACTIVITY_INTERVAL)
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
