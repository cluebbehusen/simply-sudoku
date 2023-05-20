local pd <const> = playdate
local gfx <const> = pd.graphics

class("Header").extends(gfx.sprite)

function Header:init(y)
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/systemBig"))

    local text = "Simply Sudoku"
    local textWidth, textHeight = gfx.getTextSize(text)

    local image = gfx.image.new(textWidth, textHeight)

    gfx.pushContext(image)
    gfx.drawText(text, 0, 0)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:moveTo(pd.display.getWidth() / 2, y)
    self:setImage(image)
    self:add()
end
