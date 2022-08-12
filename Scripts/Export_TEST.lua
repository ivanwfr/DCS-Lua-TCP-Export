--------------------------------------------------------------------------------
-- Export_TEST.lua ----- in [Saved Games/DCS/Scripts] -- _TAG (220810:00h:53) --
--------------------------------------------------------------------------------
print("@@@ LOADING Export_TEST.lua: arg[1]=[".. tostring(arg and arg[1]) .."]")

  TESTING        = arg and arg[1] and (arg[1] == "TESTING"    )
  TERMINATING    = arg and arg[1] and (arg[1] == "TERMINATING")
  if not TESTING and not TERMINATING then
      print("USAGE:")
      print(" "..arg[0].." TESTING")
      print("or")
      print(" "..arg[0].." TERMINATING")
      return(1)
  end
  ACTIVITY_COUNT = 5

--- TEST DATA 
--{{{
    local ModelTime                = 0
    local AltitudeAboveGroundLevel = 0
    local PilotName                = "PilotName"

    local TEST_WORLDOBJECTS = {
      WorldObject1 = { Name       =    "A-10C"
                     , Country    =    "1_Country"
                     , Coalition  =    "1_Coalition"
                  },
      WorldObject2 = { Name       =    "A-10C"
                     , Country    =    "2_Country"
                     , Coalition  =    "2_Coalition"
                  }
    }
--}}}

--- TEST FUNCTIONS
--{{{

    function LoGetModelTime   () ModelTime = ModelTime+1; return ModelTime         end
    function LoGetWorldObjects()                          return TEST_WORLDOBJECTS end

--}}}

--- TEST SEQUENCE
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

    for i=1, ACTIVITY_COUNT do
        LuaExportActivityNextEvent(i)
        sleep(1)
    end

    LuaExportStop()

    print("# ...done")
end
--}}}
--- UTIL:
-- sleep(sec) {{{
function sleep(sec)

    socket.select(nil, nil, sec)

end --}}}

--- TERMINATING LISTENER
--{{{
if TERMINATING then
    print("# TERMINATING LISTENER")

    dofile("Export_log.lua")
    dofile("Export_socket.lua")

    socket_connect()

    local      msg = "\n x Export_TEST .. TERMINATING    .. ["..log_time().."]\n"
    Export_log(msg)

    socket_send("quit")

    print("# ...done")
end
--}}}

--[[ vim
    :only
    :update|     terminal   luae Export_LISTEN.lua
    :update|     terminal   luae Export_TEST.lua    TESTING
    :update|     terminal   luae Export_TEST.lua    TERMINATING

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
