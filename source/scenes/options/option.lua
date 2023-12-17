local pd <const> = playdate
local gfx <const> = pd.graphics

class("Option").extends(gfx.sprite)

Option.circleDiameter = 16
Option.width = 110
Option.height = 30
Option.padding = 7

--- Creates a new option
--- @param helperText string The text to display
--- @param selected boolean Whether the option is selected
--- @param checked boolean Whether the option is checked
function Option:init(helperText, selected, checked)
    self.selected = selected
    self.checked = checked
    self.helperText = helperText

    self:draw()
    self:setCenter(0, 0)
    self:add()
end

--- Sets the option as selected
function Option:setSelected()
    self.selected = true
    self:draw()
end

--- Sets the option as unselected
function Option:setUnselected()
    self.selected = false
    self:draw()
end

--- Sets the option as checked
function Option:setChecked()
    self.checked = true
    self:draw()
end

--- Sets the option as unchecked
function Option:setUnchecked()
    self.checked = false
    self:draw()
end

--- Draws the option image
function Option:draw()
    local previousFont = gfx.getFont()

    gfx.setFont(gfx.font.new("fonts/system"))

    local image = gfx.image.new(Option.width, Option.height)
    local _, textHeight = gfx.getTextSize(self.helperText)
    local circleOffset = (Option.height - Option.circleDiameter) / 2
    local textOffset = (Option.height - textHeight) / 2

    gfx.pushContext(image)
    if self.selected then
        gfx.fillRoundRect(0, 0, Option.width, Option.height, 5)
        gfx.setColor(gfx.kColorWhite)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    else
        gfx.drawRoundRect(0, 0, Option.width, Option.height, 5)
    end
    if self.checked then
        gfx.fillCircleInRect(Option.padding, circleOffset, Option.circleDiameter, Option.circleDiameter)
    else
        gfx.drawCircleInRect(Option.padding, circleOffset, Option.circleDiameter, Option.circleDiameter)
    end
    gfx.drawText(self.helperText, Option.circleDiameter + Option.padding * 2, textOffset + 2)
    gfx.popContext()

    gfx.setFont(previousFont)

    self:setImage(image)
end
