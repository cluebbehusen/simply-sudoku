import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = playdate.graphics

gfx.setFont(gfx.font.new("fonts/system"))

import "menu"
import "sceneManager"
import "scenes/game/gameScene"
import "scenes/start/startScene"

local sceneManager = SceneManager(StartScene())
sceneManager:hook({
    "AButtonDown",
    "AButtonUp",
    "BButtonDown",
    "BButtonUp",
    "upButtonDown",
    "upButtonUp",
    "downButtonDown",
    "downButtonUp",
    "leftButtonDown",
    "leftButtonUp",
    "rightButtonDown",
    "rightButtonUp",
})

function playdate.update()
    pd.timer.updateTimers()
    gfx.sprite.update()

    pd.drawFPS(380, 10)
end
