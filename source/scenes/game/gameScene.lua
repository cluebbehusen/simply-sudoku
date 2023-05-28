local pd <const> = playdate
local gfx <const> = pd.graphics

import "board"

class("GameScene").extends()

function GameScene:enter(sceneManager, previousScene, puzzleDifficulty, puzzleNumber)
    self.sceneManager = sceneManager

    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    local boardX = (screenWidth - Board.size) / 2
    local boardY = (screenHeight - Board.size) / 2

    self.board = Board(boardX, boardY, puzzleDifficulty, puzzleNumber, sceneManager)

    local menu = pd.getSystemMenu()

    menu:addMenuItem("main menu", function()
        sceneManager:enter("start")
    end)
    menu:addMenuItem("annotate", function()
        self.board:autoAnnotate()
    end)

    self.keyTimers = {}
end

function GameScene:leave(sceneManager, nextScene, puzzleCompleted)
    self.board:save(puzzleCompleted)

    local menu = pd.getSystemMenu()
    menu:removeAllMenuItems()
    gfx.sprite.removeAll()

    local allTimers = pd.timer.allTimers()
    if not allTimers then
        return
    end

    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end

function GameScene:removeTimer(name)
    if self.keyTimers[name] then
        self.keyTimers[name]:remove()
        self.keyTimers[name] = nil
    end
end

function GameScene:addTimer(name, callback)
    if self.keyTimers[name] then
        self:removeTimer()
    end
    self.keyTimers[name] = pd.timer.keyRepeatTimer(callback)
end

function GameScene:AButtonDown()
    self:addTimer("AButton", function() self.board:AButtonDown() end)
end

function GameScene:AButtonUp()
    self:removeTimer("AButton")
    self.board:AButtonUp()
end

function GameScene:BButtonDown()
    self.board:BButtonDown()
end

function GameScene:upButtonDown()
    self:addTimer("upButton", function() self.board:upButtonDown() end)
end

function GameScene:upButtonUp()
    self:removeTimer("upButton")
end

function GameScene:downButtonDown()
    self:addTimer("downButton", function() self.board:downButtonDown() end)
end

function GameScene:downButtonUp()
    self:removeTimer("downButton")
end

function GameScene:leftButtonDown()
    self:addTimer("leftButton", function() self.board:leftButtonDown() end)
end

function GameScene:leftButtonUp()
    self:removeTimer("leftButton")
end

function GameScene:rightButtonDown()
    self:addTimer("rightButton", function() self.board:rightButtonDown() end)
end

function GameScene:rightButtonUp()
    self:removeTimer("rightButton")
end

function GameScene:gameWillTerminate()
    self.board:save()
end

function GameScene:deviceWillSleep()
    self.board:save()
end
