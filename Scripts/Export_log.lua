--------------------------------------------------------------------------------
-- Export_log.lua ------ in [Saved Games/DCS/Scripts] -- _TAG (220814:19h:11) --
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
