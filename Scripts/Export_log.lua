--------------------------------------------------------------------------------
-- Export_log.lua ------ in [Saved Games/DCS/Scripts] -- _TAG (220813:02h:14) --
--------------------------------------------------------------------------------
print("@@@ LOADING Export_log.lua")

local Export_log_DISABLED = true
-- HAVING Listen.log TO SEE WHAT REACHED THE SERVER MAY BE ENOUGH



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
    if   Export_log_DISABLED then return end

--[[ CALLERS of Export_log: {{{ --FIXME use log_this to avoid calling Export_log would be best
/^[^/]*\<Export_log\>\s*[(=),}]

Export_log.lua:18  log_time:26: function Export_log(line)

Export_socket.lua:31  socket_connect:33:     Export_log(msg)
Export_socket.lua:31  socket_connect:39:         Export_log(msg)
Export_socket.lua:53  socket_send:57:         Export_log(msg)
Export_socket.lua:53  socket_send:68:             Export_log(msg)
Export_socket.lua:80  socket_send_to_TARGET:97:             Export_log(msg)

Export_task.lua:70  Export_task_Start:74:     Export_log(msg)
Export_task.lua:91  Export_task_ActivityNextEvent:94:     Export_log( msg)
Export_task.lua:91  Export_task_ActivityNextEvent:101:     Export_log( msg)
Export_task.lua:91  Export_task_ActivityNextEvent:113: --            Export_log( msg)
Export_task.lua:91  Export_task_ActivityNextEvent:120: --            Export_log( msg)
Export_task.lua:132  Export_task_Stop:136:     Export_log(msg)
Export_task.lua:151  Export_task_coroutine_handle:156:     Export_log( msg)
Export_task.lua:151  Export_task_coroutine_handle:164:     Export_log (msg)
Export_task.lua:151  Export_task_coroutine_handle:171:     Export_log( msg)
Export_task.lua:184  Export_task_coroutine_start:187:     Export_log(msg)
Export_task.lua:198  CoroutineResume:201: --  Export_log(msg)

Export_TEST.lua:119  sleep:136:     Export_log(msg)

}}}--]]

    -- [log_file ../Logs/Export.log] {{{
    if not log_file_name then
        log_file_name   = script_dir.."/../Logs/Export.log"
        log_file        = io.open(log_file_name, "w") -- override log_file
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
    :update|vert terminal   luae Export_LISTEN.lua
    :update|     terminal   luae Export_TEST.lua    TESTING
    :update|     terminal   luae Export_TEST.lua    TERMINATING
" Windows Terminal
    :update|!start /b    wt luae Export_LISTEN.lua  COLORED
    :update|!start /b       luae Export_TEST.lua    TESTING
    :update|!start /b       luae Export_TEST.lua    TERMINATING

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
