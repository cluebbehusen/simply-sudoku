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

class("StartScene").extends()

StartScene.menuWidth = 150
StartScene.menuItemHeight = 33
StartScene.menuItemPadding = 4
StartScene.headerY = 50

function StartScene:enter(sceneManager)
    self.sceneManager = sceneManager

    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    local continuePuzzleMenuItem = StartMenuItem("Continue Puzzle")
    function continuePuzzleMenuItem:AButtonDown()
        sceneManager:enter("game")
    end

    local menuItems = { continuePuzzleMenuItem, StartMenuItem("Select Puzzle"), StartMenuItem("Tutorial") }

    local menuHeight = #menuItems * (StartScene.menuItemHeight + StartScene.menuItemPadding * 2)

    local menuX = (screenWidth - StartScene.menuWidth) / 2
    local menuY = (screenHeight - menuHeight) / 2 + 32

    self.menu = Menu(menuItems, menuX, menuY, StartScene.menuWidth, menuHeight, StartScene.menuItemHeight,
        StartScene.menuItemPadding)
    self.menu:hook({
        "AButtonDown",
        "BButtonDown",
    })

    Header(StartScene.headerY)
end

function StartScene:leave()
    gfx.sprite.removeAll()
end

function StartScene:upButtonDown()
    self.menu:upButtonDown()
end

function StartScene:downButtonDown()
    self.menu:downButtonDown()
end

function StartScene:AButtonDown()
    self.menu:AButtonDown()
end

function StartScene:BButtonDown()
    self.menu:BButtonDown()
end
