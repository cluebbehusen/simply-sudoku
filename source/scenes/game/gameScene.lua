local pd <const> = playdate
local gfx <const> = pd.graphics

import "board"

class("GameScene").extends()

function GameScene:enter()
    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    local boardX = (screenWidth - Board.size) / 2
    local boardY = (screenHeight - Board.size) / 2

    self.board = Board(boardX, boardY, 'puzzles/1.json')

    self.keyTimers = {}
end

function GameScene:leave()
    gfx.sprite.removeAll()
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
    self:addTimer("AButton", function() self.board:incrementSelectedCell() end)
end

function GameScene:AButtonUp()
    self:removeTimer("AButton")
end

function GameScene:BButtonDown()
    self:addTimer("BButton", function() self.board:decrementSelectedCell() end)
end

function GameScene:BButtonUp()
    self:removeTimer("BButton")
end

function GameScene:upButtonDown()
    self:addTimer("upButton", function() self.board:selectPrevRow() end)
end

function GameScene:upButtonUp()
    self:removeTimer("upButton")
end

function GameScene:downButtonDown()
    self:addTimer("downButton", function() self.board:selectNextRow() end)
end

function GameScene:downButtonUp()
    self:removeTimer("downButton")
end

function GameScene:leftButtonDown()
    self:addTimer("leftButton", function() self.board:selectPrevColumn() end)
end

function GameScene:leftButtonUp()
    self:removeTimer("leftButton")
end

function GameScene:rightButtonDown()
    self:addTimer("rightButton", function() self.board:selectNextColumn() end)
end

function GameScene:rightButtonUp()
    self:removeTimer("rightButton")
end
