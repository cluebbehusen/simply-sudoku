local pd <const> = playdate
local gfx <const> = pd.graphics

import "completeMessage"

class("CompleteScene").extends()

function CompleteScene:enter(sceneManager)
    self.sceneManager = sceneManager

    CompleteMessage()
end

function CompleteScene:leave()
    gfx.sprite.removeAll()
end

function CompleteScene:AButtonUp()
    self.sceneManager:enter("start")
end
