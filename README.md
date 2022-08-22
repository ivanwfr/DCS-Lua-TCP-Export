# DCS

## Digital Combat Simulator Export.lua Listener

### ✔ [ZIP archive on GitHub](../../archive/master.zip)

### `README.md` _TAG (220822:15h:33)

#### Export_LISTEN output in a Microsoft Windows Terminal:
![Export_LISTEN.lua](/Screenshots/Animation.gif)

#### Files
<!--
}!!tree --dirsfirst          | sed -e 's/^/    /'
}!!tree --dirsfirst Scripts/ | sed -e 's/^/    /'
-->
```
    .
    |-- Logs    -> %USERPROFILE%\Saved\ Games\DCS\Logs
    |-- Scripts -> %USERPROFILE%\Saved\ Games\DCS\Scripts
    `-- README.md

    Screenshots
    `-- Animation.gif

    Scripts
    |-- lib
    |   |-- JSON.lua
    |   `-- socket.lua
    |-- Export.lua
    |-- Export_LISTEN.lua
    |-- Export_TEST.lua
    |-- Export_TEST_STUB.lua
    |-- Export_log.lua
    |-- Export_socket.lua
    |-- Export_task.lua
    |-- check_JSON.lua
    |-- check_termios.lua
    |-- luae_2_STARTTEST.lnk
    |-- luae_3_TERMINATE.lnk
    |-- wt.bat
    |-- wt_1_LISTEN.lnk
    |-- wt_2_STARTTEST.lnk
    `-- wt_3_TERMINATE.lnk

```
#### Files functionalities


- Export.lua

  - Implements the 5 functions triggered by the launch of a Mission:
    - Start - the first action at the start of a mission
    - Before video frame action
    - After  video frame action
    - Each Model Time (second) triggered action
    - Stop - the last action at the end of a mission

  - The first function named *LuaExportStart* is used
    as a way to hookup this custom implementation by
    loading the ***Export_task.lua*** file of this project

  - The other 4 functions should be ignored as they 
    will be overridden by the other lua files.
    This way, the ***Export.lua*** file will be loaded only once
    by a game session so that the other lua files can
    be modified and loaded afresh when restarting a mission
    (...or some other event).


- Export_task.lua

  This is the first file to be loaded when a mission starts.

  - It contains a list of lines organized as a template
    for the layout of the information exported by the game.

  - It imports 3 other files that take care of 
    logging the export process, implements the TCP socket
    connection to the listening process and the JSON
    marshalling of the encoded stream of data that will
    be decoded by the listener using the same JSON library.

  - *Export_task_Start* will connect a socket to the
    listener process and initiate any provided user
    coroutine.

  - Pre and...
  - Post Frame event handlers are left empty for the moment.

  - Coroutine activity sample sends 3 sampled data
    as an example of what needs to be done to make this work.


- Export_socket.lua

  - TCP client socket to the listener server.


- Export_log.lua

  - Export Data logging.


- Export_LISTEN.lua

  - TCP server socket accepting Export connections.


- Export_TEST.lua

  - Development tool sending sample data to ***Export.lua.***


- Export_TEST_STUB.lua

  - Development tool faking some required game's inner functions.

