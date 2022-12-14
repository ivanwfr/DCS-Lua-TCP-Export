--------------------------------------------------------------------------------
-- Export_TEST_STUB.lua  in [Saved Games/DCS/Scripts] -- _TAG (220821:22h:27) --
--------------------------------------------------------------------------------
print("@ LOADING Export_TEST_STUB.lua")

local MAX_COROUTINE_DURATION_SEC = 6

-- LoGetModelTime
--{{{
local         ModelTime = 0
function LoGetModelTime() ModelTime = ModelTime+1; return ModelTime end

--}}}

-- COROUTINES STUBS
-- LoCreateCoroutineActivity(idx_, delay_, interval_) --{{{

local stub_loop_index    = 0
local stub_loop_interval = 1

function LoCreateCoroutineActivity(idx_, delay_, interval_)
--  print("\nExport_stub: LoCreateCoroutineActivity(idx_=" .. idx_ .. ", delay_=" .. delay_ .. ", interval_=" .. interval_ .. "):")

    stub_loop_interval = interval_

    sleep(delay_)

--  LuaExportStart()

--  print("\nExport_stub: LoCreateCoroutineActivity: Entering dispatcher loop:\n")
    repeat
        stub_loop_index = stub_loop_index + 1
        CoroutineResume(idx_, stub_loop_index)
        sleep(interval_)
    until (stub_loop_index * interval_) >= MAX_COROUTINE_DURATION_SEC

--  LuaExportStop()

--  print("\nExport_stub: LoCreateCoroutineActivity: ...stub LoCreateCoroutineActivity ...done ")

end --}}}
-- function GetDevice(num_) {{{
function GetDevice(num_)
--  print("Export_TEST_STUB: GetDevice(num_=" .. num_ .. ")")

    return MainPanel
end --}}}
-- MainPanel.get_argument_value() {{{
local lightSystemValues = { 0.9 , 0.8 , 0.7 , 0.6 , 0.5 , 0.4 , 0.3 , 0.2 , 0.1 , 0 }
MainPanel = {
    get_argument_value = function(self, arg_number_)

        --cal i = 1 + (stub_loop_index % #lightSystemValues)
        local i = 1 + math.floor(#lightSystemValues * (stub_loop_interval * stub_loop_index) / 2.0)
        if(i > #lightSystemValues) then i= #lightSystemValues; end

--      print("MainPanel.get_argument_value: i="..i)

        local v = lightSystemValues[i]

--      print("Export_TEST_STUB: MainPanel:get_argument_value(arg_number_=["..arg_number_.."]) ...return["..v.."]")

        return v
    end
}
--}}}
-- LoGetAltitudeAboveSeaLevel {{{
local altitudes = { 100.0 , 80.0, 50.0 , 40.0 , 30.0 , 20.0 , 10.0 , 5.0 , 3.0 , 2.0 , 1.0 , 0.0 }

function LoGetAltitudeAboveSeaLevel()

    local i = 1 + math.floor(#altitudes * (stub_loop_interval * stub_loop_index) / MAX_COROUTINE_DURATION_SEC)

--print("LoGetAltitudeAboveSeaLevel: i="..i)

    local v = altitudes[i]

--print("Export_TEST_STUB: LoGetAltitudeAboveSeaLevel() ...return["..v.."]")

    v = math.max(v,3) -- keep last same value to show changes coloring

    return v
end
--}}}
-- LoGetAltitudeAboveGroundLevel {{{
local AIRFIELD_ALTITUDE = 2000.0

function LoGetAltitudeAboveGroundLevel()

    return LoGetAltitudeAboveSeaLevel() + AIRFIELD_ALTITUDE

end
--}}}
-- LoGetMechInfo (...devenue introuvable dans DCS 1108) {{{
local speedbrakes = { 0.9 , 0.8 , 0.7 , 0.6 , 0.5 , 0.4 , 0.3 , 0.2 , 0.1 , 0 }
function LoGetMechInfo() -- mechanization info
    local i = 1 + math.floor(#speedbrakes * (stub_loop_interval * stub_loop_index) / MAX_COROUTINE_DURATION_SEC)
--  print("LoGetMechInfo: i="..i)
    local value  = speedbrakes[i]
    local status = 0
    return {
        gear            = {status,value,main = {left = {rod},right = {rod},nose =  {rod}} },
        flaps           = {status,value},
        speedbrakes     = {status,value},
        refuelingboom   = {status,value},
        airintake       = {status,value},
        noseflap        = {status,value},
        parachute       = {status,value},
        wheelbrakes     = {status,value},
        hook            = {status,value},
        wing            = {status,value},
        canopy          = {status,value},
        controlsurfaces = {elevator = {left,right},eleron = {left,right},rudder = {left,right}}
        -- relative vlues (-1,1) (min /max) (sorry:(
    } 
end
--}}}

--- UTIL:
-- sleep(sec) {{{
function sleep(sec)

    socket.select(nil, nil, sec)

end --}}}

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

:e Export_LISTEN.lua
:e Export_TEST.lua
"  Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $TARGETSCRIPTS/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
