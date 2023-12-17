local pd <const> = playdate
local gfx <const> = pd.graphics

import "cell"
import "util/boardImage"

class("Board").extends(gfx.sprite)

Board.size = Cell.size * 9 + 12

writeBoardImage(Board.size, Cell.size)

--- Creates a new board
--- @param x number The x position
--- @param y number The y position
--- @param puzzleDifficulty string The difficulty of the puzzle
--- @param puzzleNumber number The number of the puzzle
--- @param sceneManager table The scene manager
function Board:init(x, y, puzzleDifficulty, puzzleNumber, sceneManager)
    self.puzzleDifficulty = puzzleDifficulty
    self.puzzleNumber = puzzleNumber
    self.sceneManager = sceneManager

    local rawPuzzles = json.decodeFile("puzzles/" .. puzzleDifficulty .. ".json")
    local rawPuzzle = rawPuzzles[puzzleNumber]["puzzle"]
    self.solution = rawPuzzles[puzzleNumber]["solution"]

    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    local puzzleSaveData = saveData["puzzles"][self.puzzleDifficulty][self.puzzleNumber]
    local useNumberAnnotations = getAreNumberAnnotationsEnabled()

    local progress = puzzleSaveData["progress"]
    local puzzleAnnotations = puzzleSaveData["annotations"]
    local state = puzzleSaveData["state"]

    self.blockCellChange = state == "completed"

    self.selRow = 1
    self.selColumn = 1

    self.cells = {}
    for row = 1, 9 do
        self.cells[row] = {}
        for column = 1, 9 do
            local specifiedValue = rawPuzzle[row][column]
            local progressValue = progress and progress[row][column] or nil
            if progressValue == 0 then
                progressValue = nil
            end
            local annotations = puzzleAnnotations[row .. '-' .. column]

            local offsetX = x + 2 + (column - 1) * (Cell.size + 1)
            local offsetY = y + 2 + (row - 1) * (Cell.size + 1)
            if specifiedValue ~= 0 then
                self.cells[row][column] = Cell(offsetX, offsetY, specifiedValue, true)
            else
                self.cells[row][column] = Cell(offsetX, offsetY, progressValue, false, annotations)
            end
        end
    end

    self:getSelectedCell():setSelected()

    self:setCenter(0, 0)
    self:setImage(pd.datastore.readImage("board"))
    self:moveTo(x, y)
    self:add()
end

--- Gets the selected cell
--- @return table selectedCell The selected cell
function Board:getSelectedCell()
    return self.cells[self.selRow][self.selColumn]
end

--- Handles the B button down event
function Board:BButtonDown()
    if self:getSelectedCell():getValue() then
        return
    end
    if self:getSelectedCell():isAnnotating() then
        self:getSelectedCell():unsetAnnotating()
    else
        self:getSelectedCell():setAnnotating()
    end
end

--- Handles the A button down event
function Board:AButtonDown()
    if self.blockCellChange then
        return
    end
    if self:getSelectedCell():isAnnotating() then
        self:getSelectedCell():flipSelectedAnnotation()
    else
        self:incrementSelectedCell()
    end
end

--- Handles the A button up event
function Board:AButtonUp()
    if self.blockCellChange then
        return
    end
    if self:getSelectedCell():isAnnotating() then
        return
    end
    self:checkSolved()
end

--- Handles the up button down event
function Board:upButtonDown()
    if self:getSelectedCell():isAnnotating() then
        self:getSelectedCell():selectPrevAnnotationRow()
    else
        self:selectPrevRow()
    end
end

--- Handles the down button down event
function Board:downButtonDown()
    if self:getSelectedCell():isAnnotating() then
        self:getSelectedCell():selectNextAnnotationRow()
    else
        self:selectNextRow()
    end
end

--- Handles the right button down event
function Board:rightButtonDown()
    if self:getSelectedCell():isAnnotating() then
        self:getSelectedCell():selectNextAnnotationColumn()
    else
        self:selectNextColumn()
    end
end

--- Handles the left button down event
function Board:leftButtonDown()
    if self:getSelectedCell():isAnnotating() then
        self:getSelectedCell():selectPrevAnnotationColumn()
    else
        self:selectPrevColumn()
    end
end

--- Selects the next row on the board with wraparound
function Board:selectNextRow()
    self:getSelectedCell():setUnselected()
    if self.selRow == 9 then
        self.selRow = 1
    else
        self.selRow += 1
    end
    self:getSelectedCell():setSelected()
end

--- Selects the previous row on the board with wraparound
function Board:selectPrevRow()
    self:getSelectedCell():setUnselected()
    if self.selRow == 1 then
        self.selRow = 9
    else
        self.selRow -= 1
    end
    self:getSelectedCell():setSelected()
end

--- Selects the next column on the board with wraparound
function Board:selectNextColumn()
    self:getSelectedCell():setUnselected()
    if self.selColumn == 9 then
        self.selColumn = 1
    else
        self.selColumn += 1
    end
    self:getSelectedCell():setSelected()
end

--- Selects the previous column on the board with wraparound
function Board:selectPrevColumn()
    self:getSelectedCell():setUnselected()
    if self.selColumn == 1 then
        self.selColumn = 9
    else
        self.selColumn -= 1
    end
    self:getSelectedCell():setSelected()
end

function Board:incrementSelectedCell()
    self:getSelectedCell():incrementValue()
end

--- Gets whether the board is solved
--- @return boolean isSolved Whether the board is solved
function Board:isSolved()
    for row = 1, 9 do
        for column = 1, 9 do
            if self.cells[row][column].value ~= self.solution[row][column] then
                return false
            end
        end
    end
    return true
end

--- Checks if the board is solved and if so, enters the complete scene
function Board:checkSolved()
    if self:isSolved() then
        self.blockCellChange = true
        pd.timer.performAfterDelay(500, function()
            self.sceneManager:enter("complete", true)
        end)
    end
end

--- Gets whether the given value is in the given row
--- @param value number The value to check
--- @param row number The row to check
--- @return boolean isValueInRow Whether the value is in the row
function Board:isValueInRow(value, row)
    for column = 1, 9 do
        if self.cells[row][column].value == value then
            return true
        end
    end
    return false
end

--- Gets whether the given value is in the given column
--- @param value number The value to check
--- @param column number The column to check
--- @return boolean isValueInColumn Whether the value is in the column
function Board:isValueInColumn(value, column)
    for row = 1, 9 do
        if self.cells[row][column].value == value then
            return true
        end
    end
    return false
end

--- Gets whether the given value is in the given box
--- @param value number The value to check
--- @param row number The row to check
--- @param column number The column to check
--- @return boolean isValueInBox Whether the value is in the box
function Board:isValueInBox(value, row, column)
    local boxRow = math.floor((row - 1) / 3) * 3 + 1
    local boxColumn = math.floor((column - 1) / 3) * 3 + 1
    for i = boxRow, boxRow + 2 do
        for j = boxColumn, boxColumn + 2 do
            if self.cells[i][j].value == value then
                return true
            end
        end
    end
    return false
end

--- Annotates the given cell
function Board:annotateCell(row, column)
    local cell = self.cells[row][column]
    if cell.value then
        return
    end

    local annotations = {}
    for i = 1, 9 do
        annotations[i] = true
    end

    for i = 1, 9 do
        if self:isValueInRow(i, row) then
            annotations[i] = nil
        elseif self:isValueInColumn(i, column) then
            annotations[i] = nil
        elseif self:isValueInBox(i, row, column) then
            annotations[i] = nil
        end
    end

    cell:setAnnotations(annotations)
end

--- Annotates all cells on the board
function Board:autoAnnotate()
    for row = 1, 9 do
        for column = 1, 9 do
            self:annotateCell(row, column)
        end
    end
end

--- Save the board state
--- @param completed boolean Whether the board is completed
function Board:save(completed)
    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    if not completed then
        saveData["lastPlayed"] = {
            ["difficulty"] = self.puzzleDifficulty,
            ["number"] = self.puzzleNumber
        }
    else
        saveData["lastPlayed"] = nil
    end

    local puzzleData = saveData["puzzles"][self.puzzleDifficulty][self.puzzleNumber]
    puzzleData["state"] = completed and "completed" or "in-progress"
    puzzleData["progress"] = {}
    puzzleData["annotations"] = {}
    for row = 1, 9 do
        puzzleData["progress"][row] = {}
        for column = 1, 9 do
            local currentCell = self.cells[row][column]

            local value = currentCell.value
            if not value then
                value = 0
            end

            puzzleData["progress"][row][column] = value

            if not currentCell.specified and not currentCell.value then
                local cellAnnotationKey = row .. '-' .. column
                puzzleData["annotations"][cellAnnotationKey] = currentCell.annotations
            end
        end
    end
    pd.datastore.write(saveData)
end
