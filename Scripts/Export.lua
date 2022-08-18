--------------------------------------------------------------------------------
-- Export.lua ---------- in [Saved Games/DCS/Scripts] -- _TAG (220818:04h:13) --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--- CUSTOM SCRIPTS ARE RELOADED ON EACH MISSION START --------------------------
--------------------------------------------------------------------------------
local dir = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")

function LuaExportStart            ( ) dofile(dir.."/Export_task.lua") Export_task_Start            ( ) end
function LuaExportBeforeNextFrame  ( )                                 Export_task_BeforeNextFrame  ( ) end
function LuaExportAfterNextFrame   ( )                                 Export_task_AfterNextFrame   ( ) end
function LuaExportActivityNextEvent(t)                          return Export_task_ActivityNextEvent(t) end
function LuaExportStop             ( )                                 Export_task_Stop             ( ) end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[ vim
:only
    :update|vert terminal    luae Export_LISTEN.lua
    :update|     terminal    luae Export_TEST.lua    TESTING
    :update|     terminal    luae Export_TEST.lua    TERMINATING
" Windows Terminal
    :update|!start /b wt     luae Export_LISTEN.lua  COLORED
    :update|!start /b        luae Export_TEST.lua    TESTING
    :update|!start /b        luae Export_TEST.lua    TERMINATING

"  Export.lua
:e Export_task.lua
:e Export_log.lua
:e Export_socket.lua

:e Export_LISTEN.lua
:e Export_TEST.lua
:e Export_TEST_STUB.lua

:e $LOCAL/DATA/GAMES/DCS_World/Scripts/Export.lua
:e $TARGETSCRIPTS/util/util_GameCB.tmc

:e $USERPROFILE/Saved\ Games/DCS/Logs/Export.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/Listen.log
:e $USERPROFILE/Saved\ Games/DCS/Logs/dcs.log
--]]
