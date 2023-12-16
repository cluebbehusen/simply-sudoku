local pd <const> = playdate
local gfx <const> = pd.graphics

import "board"

class("GameScene").extends()

--- Enters the game scene
--- @param sceneManager table The scene manager
--- @param previousScene string The previous scene
--- @param puzzleDifficulty string The puzzle difficulty
--- @param puzzleNumber number The puzzle number
function GameScene:enter(sceneManager, previousScene, puzzleDifficulty, puzzleNumber)
    self.sceneManager = sceneManager

    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    local boardX = (screenWidth - Board.size) / 2
    local boardY = (screenHeight - Board.size) / 2

    self.board = Board(boardX, boardY, puzzleDifficulty, puzzleNumber, sceneManager)

    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end
    local puzzleState = saveData["puzzles"][puzzleDifficulty][puzzleNumber]["state"]

    local menu = pd.getSystemMenu()

    if puzzleState == "completed" then
        menu:addMenuItem("main menu", function()
            sceneManager:enter("start", true)
        end)
    else
        menu:addMenuItem("main menu", function()
            sceneManager:enter("start")
        end)
        menu:addMenuItem("tutorial", function()
            sceneManager:enter("tutorial")
        end)
        menu:addMenuItem("annotate", function()
            self.board:autoAnnotate()
        end)
    end

    self.keyTimers = {}

    local navigationHandlerKeys = {
        "upButton",
        "downButton",
        "leftButton",
        "rightButton"
    }
    for _, v in ipairs(navigationHandlerKeys) do
        local downHandler = v .. "Down"
        local upHandler = v .. "Up"
        self[upHandler] = function() self:removeTimer(v) end
        self[downHandler] = function() self:addTimer(v, function() self.board[downHandler](self.board) end) end
    end
end

--- Leaves the game scene
--- @param sceneManager table The scene manager
--- @param nextScene string The next scene
--- @param puzzleCompleted boolean Whether the puzzle was completed
function GameScene:leave(sceneManager, nextScene, puzzleCompleted)
    self.board:save(puzzleCompleted)

    local menu = pd.getSystemMenu()
    menu:removeAllMenuItems()
    gfx.sprite.removeAll()
    removeAllTimers()
end

--- Removes a timer
--- @param name string The timer name
function GameScene:removeTimer(name)
    if self.keyTimers[name] then
        self.keyTimers[name]:remove()
        self.keyTimers[name] = nil
    end
end

--- Adds a timer
--- @param name string The timer name
--- @param callback function The callback for the timer
function GameScene:addTimer(name, callback)
    if self.keyTimers[name] then
        self:removeTimer(name)
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

function GameScene:gameWillTerminate()
    self.board:save()
end

function GameScene:deviceWillSleep()
    self.board:save()
end
