import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local fontPaths = {
    [gfx.font.kVariantNormal] = "fonts/normal",
    [gfx.font.kVariantBold] = "fonts/bold",
}
local fontFamily = gfx.font.newFamily(fontPaths)
assert(fontFamily)
gfx.setFontFamily(fontFamily)

import "board"

Board('puzzles/1.json')

function playdate.update()
    pd.timer.updateTimers()
    gfx.sprite.update()

    pd.drawFPS(380, 10)
end
