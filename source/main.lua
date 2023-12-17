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
import "util/timers"
import "menu"
import "sceneManager"
import "scenes/game/gameScene"
import "scenes/start/startScene"
import "scenes/complete/completeScene"
import "scenes/tutorial/tutorialScene"
import "scenes/options/optionsScene"

maybeInstantiateSaveData()

local scenes = {
    game = GameScene(),
    start = StartScene(),
    complete = CompleteScene(),
    tutorial = TutorialScene(),
    options = OptionsScene(),
}

local sceneManager = SceneManager(scenes, "start")
sceneManager:hook({
    "AButtonDown",
    "AButtonUp",
    "AButtonHeld",
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
