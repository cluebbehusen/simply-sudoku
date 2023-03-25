class ('Cell').extends()

function Cell:init(x, y, value, given)
    self.x = x
    self.y = y
    self.value = value
    self.given = given
end

function Cell:incrementValue()
    if self.given then
        return
    end
    if self.value == 9 then
        self.value = nil
    elseif self.value == nil then
        self.value = 1
    else
        self.value += 1
    end
end

function Cell:decrementValue()
    if self.given then
        return
    end
    if self.value == 1 then
        self.value = nil
    elseif self.value == nil then
        self.value = 9
    else
        self.value -= 1
    end
end

function Cell:getStringValue()
    return self.value and tostring(self.value) or nil
end
