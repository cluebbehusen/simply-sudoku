local pd <const> = playdate
local gfx <const> = pd.graphics

import "completeMessage"
import "mainMenuMessage"

class("CompleteScene").extends()

--- Enters the complete scene
--- @param sceneManager table The scene manager
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

--- Leaves the complete scene
function CompleteScene:leave()
    gfx.sprite.removeAll()
    removeAllTimers()
end

--- Handles the A button up event
function CompleteScene:AButtonUp()
    if not self.transitionEnabled then
        return
    end
    self.sceneManager:enter("start")
end
