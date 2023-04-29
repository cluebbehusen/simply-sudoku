local pd <const> = playdate
local gfx <const> = pd.graphics

import "util/cellImages"

class("Cell").extends(gfx.sprite)

Cell.size = 23
Cell.images = getCellImages(Cell.size)

function Cell:init(x, y, value, specified)
    self.value = value
    self.specified = specified
    self.selected = false

    self:updateImage()
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:add()
end

function Cell:incrementValue()
    if self.specified then
        return false
    end
    if self.value == 9 then
        self.value = nil
    elseif self.value == nil then
        self.value = 1
    else
        self.value += 1
    end
    self:updateImage()
    return true
end

function Cell:decrementValue()
    if self.specified then
        return false
    end
    if self.value == 1 then
        self.value = nil
    elseif self.value == nil then
        self.value = 9
    else
        self.value -= 1
    end
    self:updateImage()
    return true
end

function Cell:setSelected()
    self.selected = true
    self:updateImage()
end

function Cell:setUnselected()
    self.selected = false
    self:updateImage()
end

function Cell:updateImage()
    local imageKey = getImageKey(self.specified, self.value)
    local image = Cell.images[imageKey]

    self:setImage(self.selected and image:invertedImage() or image)
end
