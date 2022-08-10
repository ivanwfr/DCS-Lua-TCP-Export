--------------------------------------------------------------------------------
-- Export_log.lua ------ in [Saved Games/DCS/Scripts] -- _TAG (220810:00h:53) --
--------------------------------------------------------------------------------
print("@@@ LOADING Export_log.lua")





-- %USERPROFILE%/Saved Games/DCS/Logs/Listen_log
--{{{
local script_dir        = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")
local log_file          = nil
local log_file_name     = nil
--}}}
-- log_time {{{
function log_time()
    local curTime      = os.time()

    return ""
    .. string.format(os.date(   "%Y-%m-%d-%H:%M:%S"     , curTime))
    .. string.format(os.date(" (!%Y-%m-%d-%H:%M:%S UTC)", curTime))
end --}}}
-- Export_log {{{
function Export_log(line)
    -- [log_file ../Logs/Export.log] {{{
    if not log_file_name then
        log_file_name   = script_dir.."/../Logs/Export.log"
        log_file        = io.open(log_file_name, "a") -- append to log_file
--      if log_file then
--          local msg     = "Export_log: .. io.open(log_file_name=["..log_file_name.."]) .. ["..log_time().."]"
--          log_file:write(msg.."\n")
--
--      end
    end
    --}}}
    if  log_file then
        log_file:write(line.."\n")
        log_file:flush()
    end
end
--}}}

--[[ vim
    :only
    :update|     terminal   luae Export_LISTEN.lua
    :update|     terminal   luae Export_TEST.lua    TESTING
    :update|     terminal   luae Export_TEST.lua    TERMINATING

:e Export.lua
:e Export_task.lua
"  Export_log.lua
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
