import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = playdate.graphics

gfx.setFont(gfx.font.new("fonts/system"))

import "util/globals"
import "util/saveData"
import "menu"
import "sceneManager"
import "scenes/game/gameScene"
import "scenes/start/startScene"

maybeInstantiateSaveData()

local scenes = {
    game = GameScene(),
    start = StartScene()
}

local sceneManager = SceneManager(scenes, "start")
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

function pd.gameWillTerminate()
    sceneManager:gameWillTerminate()
end

function pd.deviceWillSleep()
    sceneManager:deviceWillSleep()
end

function pd.update()
    pd.timer.updateTimers()
    gfx.sprite.update()
end
