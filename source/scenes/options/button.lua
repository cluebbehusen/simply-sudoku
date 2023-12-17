local pd <const> = playdate
local gfx <const> = pd.graphics

class("Button").extends(gfx.sprite)

Button.width = 110
Button.height = 30

--- Creates a new button
--- @param text string The text to display
--- @param selected boolean Whether the button is selected
function Button:init(text, selected)
    self.selected = selected
    self.text = text

    self:draw()
    self:setCenter(0, 0)
    self:add()
end

--- Sets the button as selected
function Button:setSelected()
    self.selected = true
    self:draw()
end

--- Sets the button as unselected
function Button:setUnselected()
    self.selected = false
    self:draw()
end

--- Draws the button image
function Button:draw()
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/system"))

    local image = gfx.image.new(Button.width, Button.height)
    local textWidth, textHeight = gfx.getTextSize(self.text)
    local textXOffset = (Button.width - textWidth) / 2
    local textYOffset = (Button.height - textHeight) / 2 + 2

    gfx.pushContext(image)
    if self.selected then
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.fillRoundRect(0, 0, Button.width, Button.height, 5)
    else
        gfx.drawRoundRect(0, 0, Button.width, Button.height, 5)
    end
    gfx.drawText(self.text, textXOffset, textYOffset)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:setImage(image)
end
