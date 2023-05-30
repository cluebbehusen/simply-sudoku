local pd <const> = playdate
local gfx <const> = pd.graphics

class("MenuItem").extends()

function MenuItem:draw(selected, x, y, width, height)
    error('This is an abstract method. It must be overwritten.')
end

class("Menu").extends(gfx.sprite)

Menu.reservedHandlers = {
    "upButtonDown",
    "upButtonUp",
    "downButtonDown",
    "downButtonUp",
}

function Menu:init(initialMenuItems, menuOwner, x, y, width, height, cellHeight, cellPadding)
    self.gridviewWidth = width
    self.gridviewHeight = height
    self.cellHeight = cellHeight
    self.cellPadding = cellPadding

    self.menuOwner = menuOwner

    self.gridview = pd.ui.gridview.new(0, cellHeight)
    self.gridview:setCellPadding(0, 0, cellPadding, cellPadding)

    self.stack = {}
    self:pushMenuItems(initialMenuItems)

    local stack = self.stack
    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
        local menuItem = stack[#stack][row]

        menuItem:draw(selected, x, y, width, height)
    end

    self.keyTimers = {}

    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:add()
end

function Menu:adjust(x, y, width, height)
    self.gridviewWidth = width
    self.gridviewHeight = height
    self:moveTo(x, y)
end

function Menu:pushMenuItems(menuItems)
    table.insert(self.stack, menuItems)
    self.gridview:setNumberOfRows(#self.stack[#self.stack])
    self.gridview:setSelectedRow(1)
end

function Menu:popMenuItems()
    if #self.stack == 1 then
        return
    end

    table.remove(self.stack)
    self.gridview:setNumberOfRows(#self.stack[#self.stack])
    self.gridview:setSelectedRow(1)
end

function Menu:removeTimer(name)
    if self.keyTimers[name] then
        self.keyTimers[name]:remove()
        self.keyTimers[name] = nil
    end
end

function Menu:addTimer(name, callback)
    if self.keyTimers[name] then
        self:removeTimer()
    end
    self.keyTimers[name] = pd.timer.keyRepeatTimer(callback)
end

function Menu:upButtonDown()
    self:addTimer("upButton", function() self.gridview:selectPreviousRow(true) end)
end

function Menu:upButtonUp()
    self:removeTimer("upButton")
end

function Menu:downButtonDown()
    self:addTimer("downButton", function() self.gridview:selectNextRow(true) end)
end

function Menu:downButtonUp()
    self:removeTimer("downButton")
end

function Menu:hook(handlersToInclude)
    for _, handler in ipairs(handlersToInclude) do
        for _, reservedHandler in ipairs(self.reservedHandlers) do
            if handler == reservedHandler then
                error(handler .. " is reserved for Menu.")
            end
        end
        self[handler] = function(...) self:emit(handler, ...) end
    end
end

function Menu:emit(event, ...)
    local selectedRow = self.gridview:getSelectedRow()
    local selectedMenuItem = self.stack[#self.stack][selectedRow]

    if selectedMenuItem[event] then
        selectedMenuItem[event](selectedMenuItem, self, ...)
    end
    local menuItemEvent = "MenuItem" .. event
    if self.menuOwner[menuItemEvent] then
        self.menuOwner[menuItemEvent](self.menuOwner, selectedMenuItem, self, ...)
    end
end

function Menu:draw()
    local actualHeight = #self.stack[#self.stack] * (self.cellHeight + self.cellPadding * 2)

    local adjustedHeight = actualHeight
    local adjustedY = (self.gridviewHeight - actualHeight) / 2

    if actualHeight > self.gridviewHeight then
        adjustedHeight = self.gridviewHeight
        adjustedY = 0
    end

    local menuImage = gfx.image.new(self.gridviewWidth, self.gridviewHeight)

    gfx.pushContext(menuImage)
    self.gridview:drawInRect(0, adjustedY, self.gridviewWidth, adjustedHeight)
    gfx.popContext()

    self:setImage(menuImage)
end

function Menu:forceUpdate()
    self:draw()
end

function Menu:update()
    if self.gridview.needsDisplay then
        self:draw()
    end
end
