local pd <const> = playdate
local gfx <const> = pd.graphics

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
    gfx.popContext(image)

    image:draw(x, y)
end

class("StartScene").extends()

StartScene.menuWidth = 150
StartScene.menuHeight = 100
StartScene.menuItemHeight = 55

function StartScene:enter()
    local screenHeight = pd.display.getHeight()
    local screenWidth = pd.display.getWidth()

    local menuX = (screenWidth - StartScene.menuWidth) / 2
    local menuY = (screenHeight - StartScene.menuHeight) / 2

    local menuItems = {StartMenuItem("Placeholder")}

    self.menu = Menu(menuItems, menuX, menuY, StartScene.menuWidth, StartScene.menuHeight, StartScene.menuItemHeight)
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

function StartScene:downButtonDown()
    self.menu:downButtonDown()
end

function StartScene:AButtonDown()
    self.menu:AButtonDown()
end

function StartScene:BButtonDown()
    self.menu:BButtonDown()
end
