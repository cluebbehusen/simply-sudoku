import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/sprites"

import "board"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local font = gfx.font.new('fonts/standard')
assert(font)
gfx.setFont(font)

Board()

function playdate.update()
    pd.timer.updateTimers()
    gfx.sprite.update()
end
