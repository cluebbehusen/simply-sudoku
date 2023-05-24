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
    annotationPositions[i] = {x + 1, y + 1}
    selectedAnnotationPositions[i] = {x, y}
end

class("Cell").extends(gfx.sprite)

Cell.size = 23
Cell.images = getCellImages(Cell.size)

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

function Cell:setAnnotating()
    self.selectedAnnotation = 1
    self:updateImage()
end

function Cell:isAnnotating()
    return self.selectedAnnotation ~= nil
end

function Cell:unsetAnnotating()
    self.selectedAnnotation = nil
    self:updateImage()
end

function Cell:hasAnnotations()
    if not self.annotations then
        return false
    end
    for _, _ in pairs(self.annotations) do
        return true
    end
    return false
end

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

function Cell:selectNextAnnotationRow()
    if self.selectedAnnotation >= 7 then
        self.selectedAnnotation -= 9
    end
    self.selectedAnnotation += 3
    self:updateImage()
end

function Cell:selectPrevAnnotationRow()
    if self.selectedAnnotation <= 3 then
        self.selectedAnnotation += 9
    end
    self.selectedAnnotation -= 3
    self:updateImage()
end

function Cell:selectNextAnnotationColumn()
    if self.selectedAnnotation % 3 == 0 then
        self.selectedAnnotation -= 3
    end
    self.selectedAnnotation += 1
    self:updateImage()
end

function Cell:selectPrevAnnotationColumn()
    if self.selectedAnnotation % 3 == 1 then
        self.selectedAnnotation += 3
    end
    self.selectedAnnotation -= 1
    self:updateImage()
end

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
