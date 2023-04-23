local pd <const> = playdate
local gfx <const> = pd.graphics

import "board"

class("Game").extends()

function Game:enter()
    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    local boardX = (screenWidth - Board.size) / 2
    local boardY = (screenHeight - Board.size) / 2

    self.board = Board(boardX, boardY, 'puzzles/1.json')
end

function Game:leave()
    gfx.sprite.removeAll()
end

function Game:AButtonDown()
    self.board:incrementSelectedCell()
end

function Game:BButtonDown()
    self.board:decrementSelectedCell()
end

function Game:upButtonDown()
    self.board:selectPrevRow()
end

function Game:downButtonDown()
    self.board:selectNextRow()
end

function Game:leftButtonDown()
    self.board:selectPrevColumn()
end

function Game:rightButtonDown()
    self.board:selectNextColumn()
end
