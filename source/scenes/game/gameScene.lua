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
end

function GameScene:leave()
    gfx.sprite.removeAll()
end

function GameScene:AButtonDown()
    self.board:incrementSelectedCell()
end

function GameScene:BButtonDown()
    self.board:decrementSelectedCell()
end

function GameScene:upButtonDown()
    self.board:selectPrevRow()
end

function GameScene:downButtonDown()
    self.board:selectNextRow()
end

function GameScene:leftButtonDown()
    self.board:selectPrevColumn()
end

function GameScene:rightButtonDown()
    self.board:selectNextColumn()
end
