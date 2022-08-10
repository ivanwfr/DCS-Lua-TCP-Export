--------------------------------------------------------------------------------
-- Export_task.lua ----- in [Saved Games/DCS/Scripts] -- _TAG (220810:19h:16) --
--------------------------------------------------------------------------------
print("@@@ LOADING Export_task.lua")

-- PARAMETERS
local ACTIVITY_START_DELAY    = 0.5
local ACTIVITY_INTERVAL       = 0.5

local LF                      = "\n"
local LOG_FOLD_OPEN           = "{{{"
local LOG_FOLD_CLOSE          = "}}}"

-- ENVIRONMENT
local  script_dir    = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
dofile(script_dir.."/Export_log.lua"   )
dofile(script_dir.."/Export_socket.lua")

-- UTIL
-- get_time_and_altitude {{{
function get_time_and_altitude()

     return string.format( " MTime=[%4d]" ,            LoGetModelTime()                )
     ..     string.format(" SeaAlt=[%5dm]", math.floor(LoGetAltitudeAboveSeaLevel   ()))
     ..     string.format(" GndAlt=[%5dm]", math.floor(LoGetAltitudeAboveGroundLevel()))

end
--}}}
-- get_label_object_tostring {{{
function get_label_object_tostring(label,o)

    local str = " "..label..":\n"

    for k,v in pairs(o) do
        str = str..string.format("  %20s = [%-20s]\n", k, tostring(v))
    end

    str = string.gsub(str, "\n$", "")

    return str
end
--}}}

-- EXPORT CYCLE
function Export_task_Start() ----------------- CONNECT localhost:5001 ------------{{{
print("Export_task_Start")

    local msg = "Export_task_Start .. socket_connect .. "..log_time()..":"..LF..LOG_FOLD_OPEN
    Export_log(msg)
    print(msg)
    local c = socket_connect()

    Export_task_coroutine_start()

end
--}}}
function Export_task_BeforeNextFrame() ------- SEND  frame data -------------{{{

end
--}}}
function Export_task_AfterNextFrame() -------- SEND  frame data -------------{{{

end
--}}}
function Export_task_ActivityNextEvent(t) ---- SEND  LoGetWorldObjects ----------- {{{

    local msg = "Export_task_ActivityNextEvent("..t.."):"
    Export_log(msg)
    socket_send(msg)
    print      (msg)

    local   o = LoGetWorldObjects()
    for k,v in pairs(o) do
        if(v.Name == "A-10C") then--FIXME
            msg   =     get_label_object_tostring("ACTIVITY["..t.."] k=["..k.."]",v)
            Export_log(msg)
            socket_send(msg)
            print      (msg)
        end
    end

    return  t+1 -- so as to be called again
end
--}}}
function Export_task_Stop() ------------------ CLOSE SOCKET ----------------------{{{
print("Export_task_Stop")

    local msg = LOG_FOLD_CLOSE..LF.."Export_task_Stop ... socket_close .... "..log_time()..":"
    Export_log(msg)
    print(msg)

    socket_close()

    if  log_file then
        log_file:flush()
--      log_file:close()
--      log_file = nil
    end
end
--}}}

-- DATA STREAM COROUTINE
-- Export_task_coroutine_handle {{{
function Export_task_coroutine_handle(t)

repeat

    msg =       get_time_and_altitude()
    Export_log (msg)
    print      (msg)
    socket_send(msg)

    t = coroutine.yield()

until get_Export_socket() == nil

end
--}}}
-- Export_task_coroutine_start {{{
function Export_task_coroutine_start()

    local msg = "Export_task_coroutine_start"
    Export_log(msg)
    print(msg)

    Coroutines                  = {}
    CoroutineIndex              = 1
    Coroutines[CoroutineIndex]  = coroutine.create(Export_task_coroutine_handle) 

    LoCreateCoroutineActivity(CoroutineIndex, ACTIVITY_START_DELAY, ACTIVITY_INTERVAL)
end
--}}}
-- CoroutineResume {{{
function CoroutineResume(index, t)

--  local msg = "CoroutineResume"
--  Export_log(msg)
--  print(msg)

           coroutine.resume(Coroutines[index], t)

    return coroutine.status(Coroutines[index]   ) ~= "dead"
end
--}}}


--[[ vim
    :only
    :update|     terminal   luae Export_LISTEN.lua
    :update|     terminal   luae Export_TEST.lua    TESTING
    :update|     terminal   luae Export_TEST.lua    TERMINATING

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
