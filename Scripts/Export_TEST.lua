--------------------------------------------------------------------------------
-- Export_TEST.lua ----- in [Saved Games/DCS/Scripts] -- _TAG (220823:16h:33) --
--------------------------------------------------------------------------------
print("@ LOADING Export_TEST.lua: arg[1]=[".. tostring(arg and arg[1]) .."]")

  STARTTEST        = arg and arg[1] and (arg[1] == "STARTTEST"    )
  TERMINATE      = arg and arg[1] and (arg[1] == "TERMINATE")
  EVENT_COUNT    = 12 --FIXME
  EVENT_INTERVAL = 0.5

--{{{
  if not STARTTEST and not TERMINATE then
      print("USAGE:")
      print(" "..arg[0].." STARTTEST")
      print("or")
      print(" "..arg[0].." TERMINATE")
      return(1)
  end
--}}}

----------------------------
--- UTIL -------------------
----------------------------
--{{{
local LF = string.char(10)

--}}}
-- DeepCopy {{{
local function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
--}}}
-- sleep(sec) {{{
local function sleep(sec)

    socket.select(nil, nil, sec)

end --}}}

----------------------------
--- TEST DATA --------------
----------------------------
--{{{
    local ModelTime                = 0
    local AltitudeAboveGroundLevel = 0
    local PilotName                = "PilotName"

    local TEST_WORLDOBJECTS
---[[--{{{
    = {
               Bank= 0.020179338753223,
          Coalition= "Enemies",
        CoalitionID= 2,
            Country= 2,
              Flags= {
                                 AI_ON= true,
                                  Born= true,
                                 Human= true,
                             IRJamming= false,
                             Invisible= false,
                               Jamming= false,
                           RadarActive= false,
                                Static= false
                       },
          GroupName= "Hawg-1",
            Heading= 5.3441992998123,
         LatLongAlt= {
                            Alt= 864.88147749967,
                            Lat= 41.650249796971,
                           Long= 41.556120307471
                       },
               Name= "A-10C",
              Pitch= 0.19496101140976,
           Position= {
                           x= -351660.29305886,
                           y= 864.88147749967,
                           z= 613253.86957764
                       },
               Type= {
                           level1= 1,
                           level2= 1,
                           level3= 6,
                           level4= 58
                       },
           UnitName= "New callsign",
              label= "ACTIVITY[98]"
    }
--}}}--]]
--[[--{{{
    = {
      WorldObject1 = { Name       =    "A-10C"
                     , Country    =    "1_Country"
                     , Coalition  =    "1_Coalition"
                  },
      WorldObject2 = { Name       =    "A-10C"
                     , Country    =    "2_Country"
                     , Coalition  =    "2_Coalition"
                  }
    }
--}}}--]]
--}}}

----------------------------
--- TEST FUNCTIONS ---------
----------------------------
-- LoGetSelfData {{{
function LoGetSelfData ()

    --------------------------------------------------------
    -- SEND SOME RANDOM CHANGE OBJECTS (last == original) --
    --------------------------------------------------------
    local t = LoGetModelTime()

    local o = DeepCopy( TEST_WORLDOBJECTS )

    o.Type.level1     =              t
    if t%3 == 0 then
        o.Bank        = o.Bank    +  t
        o.Heading     = o.Heading +  t
        o.Pitch       = o.Pitch   +  t
        o.Name        = o.Name    .. t
        o.Type.level1 =              t
    end

    return o
end
--}}}

----------------------------
--- TEST SEQUENCE ----------
----------------------------
--{{{
if STARTTEST then

    print("-------------------------------------------------------------------")
    print("--- Export_TEST.lua ["..(arg[1] and arg[1] or " ").."]"             )
    print("-------------------------------------------------------------------")

    dofile("Export_TEST_STUB.lua")
    dofile("Export.lua"    )

    LuaExportStart()

    local  c = get_Export_socket()
    if not c then return 1 end

    if get_SEND_TO_TARGET()      then
        local  msg = "@ SEND_TO_TARGET IS SET .. NOT CALLING LuaExportActivityNextEvent:"
        print( msg )
    else
        for i=1, EVENT_COUNT do
            LuaExportActivityNextEvent(i)
            sleep(EVENT_INTERVAL)
        end
    end

    LuaExportStop()

    print("-------------------------------------------------------------------")
    print("xxx Export_TEST.lua ["..(arg[1] and arg[1] or " ").."] done"        )
    print("-------------------------------------------------------------------")

    sleep(2)
  --io.write(LF.."> "); io.read (1)
end
--}}}

----------------------------
--- TERMINATE LISTENER -----
----------------------------
--{{{
if TERMINATE then
    print("# TERMINATE LISTENER")

    dofile("Export_log.lua")
    dofile("Export_socket.lua")

    socket_connect()

    local      msg = "\n x Export_TEST .. TERMINATE    .. ["..Export_log_time().."]\n"
    Export_log(msg)

    socket_send("quit")

    print("# ...done")

    sleep(2)
  --io.write(LF.."> "); io.read (1)
end
--}}}

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
"` Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $TARGETSCRIPTS/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
