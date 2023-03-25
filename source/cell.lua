class ('Cell').extends()

function Cell:init(x, y, value)
    self.x = x
    self.y = y
    self.value = value
end

function Cell:getStringValue()
    return tostring(self.value)
end
