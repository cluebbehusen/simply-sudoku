local pd <const> = playdate
local gfx <const> = pd.graphics

import "completeMessage"
import "mainMenuMessage"

class("CompleteScene").extends()

function CompleteScene:enter(sceneManager)
    self.sceneManager = sceneManager
    self.transitionEnabled = false

    CompleteMessage()
    local mainMenuMessage = MainMenuMessage()

    pd.timer.performAfterDelay(1000, function()
        mainMenuMessage:add()
        self.transitionEnabled = true
    end)
end

function CompleteScene:leave()
    gfx.sprite.removeAll()
    local allTimers = pd.timer.allTimers()
    if not allTimers then
        return
    end

    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end

function CompleteScene:AButtonUp()
    self.sceneManager:enter("start")
end
