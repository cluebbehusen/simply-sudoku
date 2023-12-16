local pd <const> = playdate
local gfx <const> = pd.graphics

import "util/cellImages"

local annotatedImage = gfx.image.new(5, 5)
gfx.pushContext(annotatedImage)
gfx.fillRect(0, 0, 5, 5)
gfx.popContext()

local selectedAnnotatedImage = gfx.image.new(7, 7)
gfx.pushContext(selectedAnnotatedImage)
gfx.fillRect(0, 0, 7, 7)
gfx.popContext()

local selectedImage = gfx.image.new(7, 7)
gfx.pushContext(selectedImage)
gfx.fillRect(0, 0, 7, 7)
gfx.setColor(gfx.kColorWhite)
gfx.fillRect(1, 1, 5, 5)
gfx.popContext()

local annotationPositions = {}
local selectedAnnotationPositions = {}
for i = 1, 9 do
    local x = ((i - 1) % 3) * 7 + 1
    local y = math.floor((i - 1) / 3) * 7 + 1
    annotationPositions[i] = { x + 1, y + 1 }
    selectedAnnotationPositions[i] = { x, y }
end

class("Cell").extends(gfx.sprite)

Cell.size = 23
Cell.images = getCellImages(Cell.size)

--- Creates a new cell
--- @param x number The x position
--- @param y number The y position
--- @param value number The value of the cell (1-9)
--- @param specified boolean Whether the cell is specified (given)
--- @param annotations table<number, boolean> The annotations of the cell
function Cell:init(x, y, value, specified, annotations)
    self.value = value
    self.specified = specified
    self.selected = false
    self.selectedAnnotation = nil
    self.annotations = annotations

    self:updateImage()
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:add()
end

--- Gets the value of the cell
--- @return number value The value of the cell (1-9)
function Cell:getValue()
    return self.value
end

--- Set that the cell is in annotation mode
function Cell:setAnnotating()
    self.selectedAnnotation = 1
    self:updateImage()
end

--- Gets whether the cell is in annotation mode
--- @return boolean isAnnotating Whether the cell is in annotation mode
function Cell:isAnnotating()
    return self.selectedAnnotation ~= nil
end

--- Set that the cell is not in annotation mode
function Cell:unsetAnnotating()
    self.selectedAnnotation = nil
    self:updateImage()
end

--- Return whether the cell has any annotations
--- @return boolean hasAnnotations Whether the cell has any annotations
function Cell:hasAnnotations()
    if not self.annotations then
        return false
    end
    for _, _ in pairs(self.annotations) do
        return true
    end
    return false
end

--- Sets the annotations of the cell
function Cell:setAnnotations(annotations)
    self.annotations = annotations
    self:updateImage()
end

--- Increments the cell value with wraparound
function Cell:incrementValue()
    if self.specified then
        return false
    end
    self.annotations = nil
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

--- Decrements the cell value with wraparound
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

--- Sets the cell as selected
function Cell:setSelected()
    self.selected = true
    self:updateImage()
end

--- Sets the cell as unselected
function Cell:setUnselected()
    self.selected = false
    self:updateImage()
end

--- Selects the next annotation row
function Cell:selectNextAnnotationRow()
    if self.selectedAnnotation >= 7 then
        self.selectedAnnotation -= 9
    end
    self.selectedAnnotation += 3
    self:updateImage()
end

--- Selects the previous annotation row
function Cell:selectPrevAnnotationRow()
    if self.selectedAnnotation <= 3 then
        self.selectedAnnotation += 9
    end
    self.selectedAnnotation -= 3
    self:updateImage()
end

--- Selects the next annotation column
function Cell:selectNextAnnotationColumn()
    if self.selectedAnnotation % 3 == 0 then
        self.selectedAnnotation -= 3
    end
    self.selectedAnnotation += 1
    self:updateImage()
end

--- Selects the previous annotation column
function Cell:selectPrevAnnotationColumn()
    if self.selectedAnnotation % 3 == 1 then
        self.selectedAnnotation += 3
    end
    self.selectedAnnotation -= 1
    self:updateImage()
end

--- Flips the selected annotation
function Cell:flipSelectedAnnotation()
    if not self.annotations then
        self.annotations = {}
    end
    if self.annotations[self.selectedAnnotation] then
        self.annotations[self.selectedAnnotation] = nil
        if not self:hasAnnotations() then
            self.annotations = nil
        end
    else
        self.annotations[self.selectedAnnotation] = true
    end
    self:updateImage()
end

--- Updates the cell image
function Cell:updateImage()
    local imageKey = getImageKey(self.specified, self.value)
    local image = Cell.images[imageKey]

    if self.annotations then
        image = image:copy()
        gfx.pushContext(image)
        for annotation, _ in pairs(self.annotations) do
            if annotation ~= self.selectedAnnotation then
                local x, y = table.unpack(annotationPositions[annotation])
                annotatedImage:draw(x, y)
            end
        end
        gfx.popContext()
    end
    if self.selected and not self.selectedAnnotation then
        self:setImage(image:invertedImage())
        return
    elseif self.selected then
        image = image:copy()
        gfx.pushContext(image)
        local x, y = table.unpack(selectedAnnotationPositions[self.selectedAnnotation])
        local selectedImage = selectedImage
        if self.annotations and self.annotations[self.selectedAnnotation] then
            selectedImage = selectedAnnotatedImage
        end
        selectedImage:draw(x, y)
        gfx.popContext()
    end

    self:setImage(image)
end
