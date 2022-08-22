local        LF = string.char(10)
local       ESC = tostring(string.char(27));
local     CLEAR = ESC..'c'
local       CSI = ESC..'['      -- (Control Sequence Introducer)

local    SGR    = CSI..'0m'     -- (Select Graphic Rendition) (Reset or normal)
local    SGRI   = CSI..'1;4;7m' -- (Select Graphic Rendition) (italic)
local    SGRBUR = CSI..'1;4;7m' -- (Select Graphic Rendition) (bold underline reverse)

local CTL       = CSI..'1;1H'
local CNL       = CSI..'1E'     -- Cursor Next Line
local CUD       = CSI..'1B'     -- Cursor Down
local CUF       = CSI..'1C'     -- Cursor Forward
local CHA_1     = CSI..'1C'     -- Cursor Horizontal Absolute
local CHA16     = CSI..'16C'    -- Cursor Horizontal Absolute
local CHA32     = CSI..'32C'    -- Cursor Horizontal Absolute

local R     = CSI.."1;31m"      --     RED
local G     = CSI.."1;32m"      --   GREEN
local Y     = CSI.."1;33m"      --  YELLOW
local B     = CSI.."1;34m"      --    BLUE
local M     = CSI.."1;35m"      -- MAGENTA
local C     = CSI.."1;36m"      --    CYAN
local N     = CSI.."0m"         --      NC

  io.write(        "CHA_1"             ..LF )
  io.write(        R.."R"              ..LF )
  io.write(        G.."G"              ..LF )
  io.write(        Y.."Y"              ..LF )
  io.write(        B.."B"              ..LF )
  io.write(        M.."M"              ..LF )
  io.write(        C.."C"              ..LF )
  io.write(        N.."N"              ..LF )

--io.write(CLEAR)

  io.write(CTL)
  io.write(CHA16 .."CHA16"             ..CNL)
  io.write(CHA16 ..R.."R"..CUF.."COL 2"..CNL)
  io.write(CHA16 ..G.."G"..CUF.."COL 2"..CNL)
  io.write(CHA16 ..Y.."Y"..CUF.."COL 2"..CNL)
  io.write(CHA16 ..B.."B"..CUF.."COL 2"..CNL)
  io.write(CHA16 ..M.."M"..CUF.."COL 2"..CNL)
  io.write(CHA16 ..C.."C"..CUF.."COL 2"..CNL)
  io.write(CHA16 ..N.."N"..CUF.."COL 2"..CNL)

  io.write(CTL)
  io.write(CHA32 .."CHA32"             ..CNL)
  io.write(        SGRBUR                   )
  io.write(CHA32 ..R.."R"..CUF.."COL 3"..CNL)
  io.write(CHA32 ..G.."G"..CUF.."COL 3"..CNL)
  io.write(CHA32 ..Y.."Y"..CUF.."COL 3"..CNL)
  io.write(CHA32 ..B.."B"..CUF.."COL 3"..CNL)
  io.write(CHA32 ..M.."M"..CUF.."COL 3"..CNL)
  io.write(CHA32 ..C.."C"..CUF.."COL 3"..CNL)
  io.write(CHA32 ..N.."N"..CUF.."COL 3"..CNL)

  io.write(LF..LF.."> "); io.read (1)

--[[
    :only
    :update|!start /b wt  luae %

:!start /b explorer "https://en.wikipedia.org/wiki/ANSI_escape_code"
:!start /b explorer "https://en.wikipedia.org/wiki/Electronic_color_code"
:e $LOCALAPPDATA/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json
--]]

