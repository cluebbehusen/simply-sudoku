local pd <const> = playdate
local gfx <const> = pd.graphics

--- Creates a string key for an annotation image
--- @param selected boolean Whether the annotation is selected
--- @param annotated boolean Whether the annotation is annotated
--- @param value? number The value of the annotation; if value doesn't exist, dot is assumed
function getAnnotationImageKey(selected, annotated, value)
    local selectedString = selected and "selected" or "unselected"
    local annotatedString = annotated and "annotated" or "unannotated"
    local valueString = value and tostring(value) or "dot"
    return selectedString .. "-" .. annotatedString .. "-" .. valueString
end

--- Gets the image for an unselected annotated dot annotation
--- @return table image The image
local function getUnselectedAnnotedDotImage()
    local image = gfx.image.new(5, 5)
    gfx.pushContext(image)
    gfx.fillRect(0, 0, 5, 5)
    gfx.setColor(gfx.kColorWhite)
    gfx.popContext()
    return image
end

--- Gets the image for a selected annotated dot annotation
--- @return table image The image
local function getSelectedAnnotatedDotImage()
    local image = gfx.image.new(7, 7)
    gfx.pushContext(image)
    gfx.fillRect(0, 0, 7, 7)
    gfx.popContext()
    return image
end

--- Gets the image for an unselected annotated value annotation
--- @param value number The value of the annotation
--- @return table image The image
local function getUnselectedAnnotatedValueImage(value)
    local image = gfx.image.new(5, 5)
    local previousFont = gfx.getFont()
    gfx.setFont(gfx.font.new("fonts/smallNumbers"))
    gfx.pushContext(image)
    gfx.drawText(tostring(value), 0, 0)
    gfx.popContext()
    gfx.setFont(previousFont)
    return image
end

--- Gets the image for a selected annotated value annotation
--- @param value number The value of the annotation
--- @return table image The image
local function getSelectedAnnotatedValueImage(value)
    local image = gfx.image.new(7, 7)
    local previousFont = gfx.getFont()
    gfx.setFont(gfx.font.new("fonts/smallNumbers"))
    gfx.pushContext(image)
    gfx.drawRect(0, 0, 7, 7)
    gfx.drawText(tostring(value), 1, 1)
    gfx.popContext()
    gfx.setFont(previousFont)
    return image
end

--- Gets the image for a selected unannotated annotation
local function getSelectedUnannotatedImage()
    local image = gfx.image.new(7, 7)
    gfx.pushContext(image)
    gfx.fillRect(0, 0, 7, 7)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(1, 1, 5, 5)
    gfx.popContext()
    return image
end

--- Creates a table of annotation images for faster loading later
--- @return table images The table of annotation images
function getAnnotationImages()
    local images = {}

    images[getAnnotationImageKey(true, false)] = getSelectedUnannotatedImage()

    images[getAnnotationImageKey(false, true)] = getUnselectedAnnotedDotImage()
    images[getAnnotationImageKey(true, true)] = getSelectedAnnotatedDotImage()

    for i = 1, 9 do
        images[getAnnotationImageKey(false, true, i)] = getUnselectedAnnotatedValueImage(i)
        images[getAnnotationImageKey(true, true, i)] = getSelectedAnnotatedValueImage(i)
    end

    return images
end
