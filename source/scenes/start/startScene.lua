local pd <const> = playdate
local gfx <const> = pd.graphics

import "header"

class("StartMenuItem").extends(MenuItem)

function StartMenuItem:init(text)
    self.text = text
end

function StartMenuItem:draw(selected, x, y, width, height)
    local image = gfx.image.new(width, height)

    gfx.pushContext(image)
    local textWidth, textHeight = gfx.getTextSize(self.text)
    local offsetX = (width - textWidth) / 2
    local offsetY = (height - textHeight) / 2
    if selected then
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.fillRoundRect(0, 0, width, height, 5)
    else
        gfx.drawRoundRect(0, 0, width, height, 5)
    end
    gfx.drawText(self.text, offsetX, offsetY)
    gfx.popContext()

    image:draw(x, y)
end

function StartMenuItem:BButtonDown(menu)
    menu:popMenuItems()
end

class("StartScene").extends()

StartScene.menuWidth = 150
StartScene.menuItemHeight = 33
StartScene.menuItemPadding = 4
StartScene.headerX = 95

function StartScene:enter(sceneManager)
    self.sceneManager = sceneManager

    local saveData = pd.datastore.read()
    if not saveData then
        error("No save data found")
    end

    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    Header(StartScene.headerX)

    local puzzleMenuItems = {}
    for _, difficulty in ipairs(DIFFICULTIES) do
        puzzleMenuItems[difficulty] = {}
    end

    for i = 1, NUM_PUZZLES do
        for _, difficulty in ipairs(DIFFICULTIES) do
            local puzzleState = saveData["puzzles"][difficulty][i]["state"]
            local additionalIcon = ""
            if puzzleState == "in-progress" then
                additionalIcon = " ⏳"
            elseif puzzleState == "completed" then
                additionalIcon = " ⎷"
            end

            local puzzleMenuItem = StartMenuItem("Puzzle " .. i .. additionalIcon)
            function puzzleMenuItem:AButtonDown()
                sceneManager:enter("game", difficulty, i)
            end

            table.insert(puzzleMenuItems[difficulty], puzzleMenuItem)
        end
    end

    local difficultyMenuItems = {}
    for _, difficulty in ipairs(DIFFICULTIES) do
        local difficultyMenuItem = StartMenuItem(difficulty:gsub("^%l", string.upper))
        function difficultyMenuItem:AButtonDown(menu)
            menu:pushMenuItems(puzzleMenuItems[difficulty])
        end

        table.insert(difficultyMenuItems, difficultyMenuItem)
    end

    local selectPuzzleMenuItem = StartMenuItem("Select Puzzle")
    function selectPuzzleMenuItem:AButtonDown(menu)
        menu:pushMenuItems(difficultyMenuItems)
    end

    local mainMenuItems = { selectPuzzleMenuItem, StartMenuItem("Tutorial") }

    if saveData["lastPlayed"] then
        local continuePuzzleMenuItem = StartMenuItem("Continue Puzzle")
        function continuePuzzleMenuItem:AButtonDown()
            local difficulty = saveData["lastPlayed"]["difficulty"]
            local number = saveData["lastPlayed"]["number"]
            sceneManager:enter("game", difficulty, number)
        end

        table.insert(mainMenuItems, 1, continuePuzzleMenuItem)
    end

    local menuHeight = screenHeight - 20

    local menuX = (screenWidth - StartScene.menuWidth) - 35
    local menuY = (screenHeight - menuHeight) / 2

    self.menu = Menu(mainMenuItems, menuX, menuY, StartScene.menuWidth, menuHeight, StartScene.menuItemHeight,
        StartScene.menuItemPadding)
    self.menu:hook({
        "AButtonDown",
        "BButtonDown",
    })
end

function StartScene:leave()
    gfx.sprite.removeAll()
end

function StartScene:upButtonDown()
    self.menu:upButtonDown()
end

function StartScene:upButtonUp()
    self.menu:upButtonUp()
end

function StartScene:downButtonDown()
    self.menu:downButtonDown()
end

function StartScene:downButtonUp()
    self.menu:downButtonUp()
end

function StartScene:AButtonDown()
    self.menu:AButtonDown()
end

function StartScene:BButtonDown()
    self.menu:BButtonDown()
end
