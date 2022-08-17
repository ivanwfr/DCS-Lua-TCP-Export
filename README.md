# DCS

## Digital Combat Simulator Export.lua Listener

### ✔ [ZIP archive on GitHub](../../archive/master.zip)

### `README.md` _TAG (220818:00h:36)

#### Export_LISTEN output in a Microsoft Windows Terminal:
```
![Export_LISTEN.lua](/Screenshots/Animation.gif)

```

#### Microsoft Windows Terminal settings.json [schemes entry] for ECC termio colors:

```
(optional Electronic Color Code 10 colors setup)

%USERPROFILE%/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json

{ "name"                : "ECC",
  "cursorColor"         : "#FF00FF",
  "foreground"          : "#FFFFFF",
  "background"          : "#1C1C1C",
  "selectionBackground" : "#404040",
  "black"               : "#964B00",
  "blue"                : "#6495ED",
  "brightBlack"         : "#964B00",
  "brightBlue"          : "#6495ED",
  "brightCyan"          : "#FFA500",
  "brightGreen"         : "#9ACD32",
  "brightPurple"        : "#EE82EE",
  "brightRed"           : "#FF0000",
  "brightWhite"         : "#A0A0A0",
  "brightYellow"        : "#FFFF00",
  "cyan"                : "#FFA500",
  "green"               : "#9ACD32",
  "purple"              : "#EE82EE",
  "red"                 : "#FF0000",
  "white"               : "#A0A0A0",
  "yellow"              : "#FFFF00"
},
```
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
    |-- Export_LISTEN_Windows_Terminal.lnk
    |-- Export_TEST.lua
    |-- Export_TEST_STUB.lua
    |-- Export_log.lua
    |-- Export_socket.lua
    |-- Export_task.lua
    |-- check_JSON.lua
    |-- check_termios.lua
    |-- desktop.ini
    `-- wt.bat
```
