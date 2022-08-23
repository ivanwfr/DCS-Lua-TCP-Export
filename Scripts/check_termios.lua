local LF        = string.char(10)
local ESC       = tostring(string.char(27));
local CLEAR     = ESC..'c'
local CSI       = ESC..'['      -- (Control Sequence Introducer)

local SGR       = CSI..'0m'     -- (Select Graphic Rendition) (Reset or normal)
local SGRI      = CSI..'3m'     -- (Select Graphic Rendition) (italic)
local SGRBUR    = CSI..'1;4;7m' -- (Select Graphic Rendition) (bold underline reverse)

local CTL       = CSI..'1;1H'   -- Cursor row1 col1
local CNL       = CSI..'1E'     -- Cursor Next Line
local CUD       = CSI..'1B'     -- Cursor Down
local CUF       = CSI..'1C'     -- Cursor Forward
local CHA_1     = CSI..'1C'     -- Cursor Horizontal Absolute
local CHA_8     = CSI..'8C'     -- Cursor Horizontal Absolute
local CHA16     = CSI..'16C'    -- Cursor Horizontal Absolute
local CHA32     = CSI..'32C'    -- Cursor Horizontal Absolute
local CHA48     = CSI..'48C'    -- Cursor Horizontal Absolute

local R         = CSI.."1;31m"  --     RED
local G         = CSI.."1;32m"  --   GREEN
local Y         = CSI.."1;33m"  --  YELLOW
local B         = CSI.."1;34m"  --    BLUE
local M         = CSI.."1;35m"  -- MAGENTA
local C         = CSI.."1;36m"  --    CYAN
local N         = CSI.."0m"     --      NC

-- ECC (Electronic Color Code) ----------------------------------------------------------
--{{{
---------------------- BACKGROUND ------ FOREGROUND  ------------------------
--cal c0        = CSI.."38;5;255m"..CSI.."48;5;232m" -- 0 --   WHITE on BLACK
local c0        = CSI.."38;5;254m"..CSI.."48;5;234m" -- 0 --   LIGHT on DARK
local c1        = CSI.."38;5;94m" ..CSI.."48;5;232m" -- 1 --   BROWN on BLACK
local c2        = CSI.."38;5;196m"..CSI.."48;5;232m" -- 2 --     RED on BLACK
local c3        = CSI.."38;5;214m"..CSI.."48;5;232m" -- 3 --  ORANGE on BLACK
local c4        = CSI.."38;5;226m"..CSI.."48;5;232m" -- 4 --  YELLOW on BLACK
local c5        = CSI.."38;5;28m" ..CSI.."48;5;232m" -- 5 --   GREEN on BLACK
local c6        = CSI.."38;5;45m" ..CSI.."48;5;232m" -- 6 --    BLUE on BLACK
local c7        = CSI.."38;5;129m"..CSI.."48;5;232m" -- 7 -- MAGENTA on BLACK
local c8        = CSI.."38;5;244m"..CSI.."48;5;232m" -- 8 --    GREY on BLACK
local c9        = CSI.."38;5;255m"..CSI.."48;5;232m" -- 9 --   WHITE on BLACK
--}}}

  io.write(CTL)
  io.write(CHA_1 .."CHA_1"               ..LF )
  io.write(CHA_1 ..R.."R"                ..LF )
  io.write(CHA_1 ..G.."G"                ..LF )
  io.write(CHA_1 ..Y.."Y"                ..LF )
  io.write(CHA_1 ..B.."B"                ..LF )
  io.write(CHA_1 ..M.."M"                ..LF )
  io.write(CHA_1 ..C.."C"                ..LF )
  io.write(CHA_1 ..N.."N"                ..LF )

  io.write(CTL)
  io.write(CHA16 .."CHA16"               ..LF )
  io.write(CHA16 ..R.."R"..CUF.."COL 16" ..CNL)
  io.write(CHA16 ..G.."G"..CUF.."COL 16" ..CNL)
  io.write(CHA16 ..Y.."Y"..CUF.."COL 16" ..CNL)
  io.write(CHA16 ..B.."B"..CUF.."COL 16" ..CNL)
  io.write(CHA16 ..M.."M"..CUF.."COL 16" ..CNL)
  io.write(CHA16 ..C.."C"..CUF.."COL 16" ..CNL)
  io.write(CHA16 ..N.."N"..CUF.."COL 16" ..CNL)

  io.write(CTL)
  io.write(CHA_8 .."CHA_8"               ..CNL)
  io.write(CHA_8 ..c0..". c0 ."          ..LF )
  io.write(CHA_8 ..c1..". c1 ."          ..LF )
  io.write(CHA_8 ..c2..". c2 ."          ..LF )
  io.write(CHA_8 ..c3..". c3 ."          ..LF )
  io.write(CHA_8 ..c4..". c4 ."          ..LF )
  io.write(CHA_8 ..c5..". c5 ."          ..LF )
  io.write(CHA_8 ..c6..". c6 ."          ..LF )
  io.write(CHA_8 ..c7..". c7 ."          ..LF )
  io.write(CHA_8 ..c8..". c8 ."          ..LF )
  io.write(CHA_8 ..c9..". c9 ."          ..LF )

  io.write(CTL)
  io.write(CHA32 .."CHA32"     ..SGRBUR   ..CNL)
  io.write(CHA32 ..R.."R"..CUF.."COL 32"  ..CNL)
  io.write(CHA32 ..G.."G"..CUF.."COL 32"  ..CNL)
  io.write(CHA32 ..Y.."Y"..CUF.."COL 32"  ..CNL)
  io.write(CHA32 ..B.."B"..CUF.."COL 32"  ..CNL)
  io.write(CHA32 ..M.."M"..CUF.."COL 32"  ..CNL)
  io.write(CHA32 ..C.."C"..CUF.."COL 32"  ..CNL)
  io.write(CHA32 ..N.."N"..CUF.."COL 32"  ..CNL)

  io.write(CTL)
  io.write(CHA48 .."CHA48"               ..CNL)
  io.write(CHA48 .."CSI       = ESC..'['      -- (Control Sequence Introducer)"                       ..CNL)
  io.write(CHA48 .."SGR       = CSI..'0m'     -- (Select Graphic Rendition) (Reset or normal)"        ..CNL)
  io.write(CHA48 .."SGRI      = CSI..'1;4;7m' -- (Select Graphic Rendition) (italic)"                 ..CNL)
  io.write(CHA48 .."SGRBUR    = CSI..'1;4;7m' -- (Select Graphic Rendition) (bold underline reverse)" ..CNL)
  io.write(CHA48 .."CTL       = CSI..'1;1H'   -- Cursor row1 col1"                                    ..CNL)
  io.write(CHA48 .."CNL       = CSI..'1E'     -- Cursor Next Line"                                    ..CNL)
  io.write(CHA48 .."CUD       = CSI..'1B'     -- Cursor Down"                                         ..CNL)
  io.write(CHA48 .."CUF       = CSI..'1C'     -- Cursor Forward"                                      ..CNL)
  io.write(CHA48 .."CHA_1     = CSI..'1C'     -- Cursor Horizontal Absolute"                          ..CNL)
  io.write(CHA48 .."CHA16     = CSI..'16C'    -- Cursor Horizontal Absolute"                          ..CNL)
  io.write(CHA48 .."CHA32     = CSI..'32C'    -- Cursor Horizontal Absolute"                          ..CNL)
  io.write(CHA48 .."CHA48     = CSI..'48C'    -- Cursor Horizontal Absolute"                                         ..CNL)

  io.write(LF..LF.."> "); io.read (1) -- user input before closing terminal

--[[
    :only
    :update|!start /b wt  luae %

:!start /b explorer "https://en.wikipedia.org/wiki/ANSI_escape_code"
:!start /b explorer "https://en.wikipedia.org/wiki/Electronic_color_code"
:e $LOCALAPPDATA/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json
--]]

