--------------------------------------------------------------------------------
-- Export_TEST.lua ----- in [Saved Games/DCS/Scripts] -- _TAG (220817:17h:59) --
--------------------------------------------------------------------------------
print("@ LOADING Export_TEST.lua: arg[1]=[".. tostring(arg and arg[1]) .."]")

  TESTING        = arg and arg[1] and (arg[1] == "TESTING"    )
  TERMINATING    = arg and arg[1] and (arg[1] == "TERMINATING")
  EVENT_COUNT    = 12 --FIXME
  EVENT_INTERVAL = 0.5

--{{{
  if not TESTING and not TERMINATING then
      print("USAGE:")
      print(" "..arg[0].." TESTING")
      print("or")
      print(" "..arg[0].." TERMINATING")
      return(1)
  end
--}}}

----------------------------
--- UTIL -------------------
----------------------------
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
if TESTING then

    print("-------------------------------------------------------------------")
    print("--- Export_TEST.lua ["..(arg[1] and arg[1] or " ").."]"             )
    print("-------------------------------------------------------------------")

    dofile("Export_TEST_STUB.lua")
    dofile("Export.lua"    )

    LuaExportStart()

    local  c = get_Export_socket()
    if not c then return 1 end

    for i=1, EVENT_COUNT do
        LuaExportActivityNextEvent(i)
        sleep(EVENT_INTERVAL)
    end

    LuaExportStop()

    print("-------------------------------------------------------------------")
    print("xxx Export_TEST.lua ["..(arg[1] and arg[1] or " ").."] done"        )
    print("-------------------------------------------------------------------")
end
--}}}

----------------------------
--- TERMINATING LISTENER ---
----------------------------
--{{{
if TERMINATING then
    print("# TERMINATING LISTENER")

    dofile("Export_log.lua")
    dofile("Export_socket.lua")

    socket_connect()

    local      msg = "\n x Export_TEST .. TERMINATING    .. ["..Export_log_time().."]\n"
    Export_log(msg)

    socket_send("quit")

    print("# ...done")
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
:e Export_task.lua
:e Export_log.lua
:e Export_socket.lua

:e Export_LISTEN.lua
"` Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $LOCAL/GAMES/IVANWFR/INPUT/THRUSTMASTER/HOTAS/TARGET/SCRIPTS/ivanwfr/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
