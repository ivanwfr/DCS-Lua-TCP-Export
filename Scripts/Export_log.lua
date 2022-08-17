--------------------------------------------------------------------------------
-- Export_log.lua ------ in [Saved Games/DCS/Scripts] -- _TAG (220817:17h:58) --
--------------------------------------------------------------------------------
print("@ LOADING Export_log.lua")

local log_ENABLED = false -- @see also Listen.log

local script_dir = string.gsub(os.getenv("USERPROFILE").."/Saved Games/DCS/Scripts", "\\", "/")

--------------------------------------------------------------------------------
-- LOG -------------------------------------------------------------------------
--------------------------------------------------------------------------------
--{{{
local LOG_FOLD_OPEN  = "{{{"
local LOG_FOLD_CLOSE = "}}}"

local log_file       = nil
local log_file_name  = nil
local log_is_opened  = false
--}}}
-- Export_log_set_log_file_name {{{
function Export_log_set_log_file_name(_log_file_name)

    if  log_file_name == _log_file_name then
        return
    end

    if  log_file then
        Export_log_close()
    end

    if _log_file_name then
        log_file_name = script_dir.."/../Logs/".._log_file_name
        log_file      = io.open(log_file_name, "w") -- override log_file

        log_ENABLED   = true -- caller's [log_this] has precedence
    end

end
--}}}
-- Export_log {{{
function Export_log(line)

    if not log_ENABLED then return end

    if not log_file_name then
        log_file_name   = script_dir.."/../Logs/Export.log"
        log_file        = io.open(log_file_name, "w") -- override log_file
    end

    if  log_file then
        log_file:write(line.."\n")
        log_file:flush()
    end

end
--}}}
-- Export_log_FOLD_OPEN {{{
function Export_log_FOLD_OPEN()

    if not log_ENABLED then return end

    if log_is_opened then
        Export_log( LOG_FOLD_CLOSE )
    end
    Export_log    ( LOG_FOLD_OPEN  )
    log_is_opened = true
end
--}}}
-- Export_log_FOLD_CLOSE {{{
function Export_log_FOLD_CLOSE()

    if not log_ENABLED then return end

    if log_is_opened then
        Export_log( LOG_FOLD_CLOSE )
        log_is_opened = false
    end
end
--}}}
-- Export_log_time {{{
function Export_log_time()

    local curTime =  os.time()

    return string.format(os.date(   "%Y-%m-%d-%H:%M:%S"     , curTime))
    ..     string.format(os.date(" (!%Y-%m-%d-%H:%M:%S UTC)", curTime))

end
--}}}
-- Export_log_close {{{
function Export_log_close()

    if  log_file then
        log_file:close()
        log_file      = nil
    end

    if log_file_name then
        log_file_name = nil
    end

end
--}}}


--[[ vim
    :only
    :update|vert terminal    luae Export_LISTEN.lua
    :update|     terminal    luae Export_TEST.lua    TESTING
    :update|     terminal    luae Export_TEST.lua    TERMINATING
" Windows Terminal
    :update|!start /b wt     luae Export_LISTEN.lua  COLORED
    :update|!start /b        luae Export_TEST.lua    TESTING
    :update|!start /b        luae Export_TEST.lua    TERMINATING

:e Export.lua
:e Export_task.lua
"  Export_log.lua
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
