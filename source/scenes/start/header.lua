local pd <const> = playdate
local gfx <const> = pd.graphics

class("Header").extends(gfx.sprite)

--- Creates a new header
--- @param x number The x position of the header
function Header:init(x)
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/systemBig"))

    local text = "Simply\nSudoku"
    local textWidth, textHeight = gfx.getTextSize(text)

    local image = gfx.image.new(textWidth, textHeight)

    gfx.pushContext(image)
    gfx.drawTextAligned(text, textWidth / 2, 0, kTextAlignment.center)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:moveTo(x, pd.display.getHeight() / 2)
    self:setImage(image)
    self:add()
end
