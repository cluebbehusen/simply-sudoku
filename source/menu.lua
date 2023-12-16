local pd <const> = playdate
local gfx <const> = pd.graphics

class("MenuItem").extends()

function MenuItem:init()
    self.callbacks = {}
end

--- Draws the menu item to the screen
--- @param selected boolean Whether the menu item is selected
--- @param x number The x coordinate
--- @param y number The y coordinate
--- @param width number The width
--- @param height number The height
function MenuItem:draw(selected, x, y, width, height)
    error('This is an abstract method. It must be overwritten.')
end

function MenuItem:invokeCallback(callbackName, ...)
    if self.callbacks and self.callbacks[callbackName] then
        self.callbacks[callbackName](...)
    end
end

class("Menu").extends(gfx.sprite)

Menu.reservedHandlers = {
    "upButtonDown",
    "upButtonUp",
    "downButtonDown",
    "downButtonUp",
}

--- Creates a new menu
--- @param initialMenuItems table[] The initial menu items
--- @param x number The x coordinate of the menu
--- @param y number The y coordinate of the menu
--- @param width number The width of the menu
--- @param height number The height of the menu
--- @param cellHeight number The height of each cell
--- @param cellPadding number The padding of each cell
function Menu:init(initialMenuItems, x, y, width, height, cellHeight, cellPadding)
    self.gridviewWidth = width
    self.gridviewHeight = height
    self.cellHeight = cellHeight
    self.cellPadding = cellPadding

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

--- Moves the menu and adjusts the width and height
--- @param x number The x coordinate of the menu
--- @param y number The y coordinate of the menu
--- @param width number The width of the menu
--- @param height number The height of the menu
function Menu:adjust(x, y, width, height)
    self.gridviewWidth = width
    self.gridviewHeight = height
    self:moveTo(x, y)
end

--- Pushes a new set of menu items to the stack
--- @param menuItems table[] The menu items
function Menu:pushMenuItems(menuItems)
    table.insert(self.stack, menuItems)
    self.gridview:setNumberOfRows(#self.stack[#self.stack])
    self.gridview:setSelectedRow(1)
end

--- Pops the current set of menu items from the stack
function Menu:popMenuItems()
    if #self.stack == 1 then
        return
    end

    table.remove(self.stack)
    self.gridview:setNumberOfRows(#self.stack[#self.stack])
    self.gridview:setSelectedRow(1)
end

--- Removes a timer
--- @param name string The name of the timer
function Menu:removeTimer(name)
    if self.keyTimers[name] then
        self.keyTimers[name]:remove()
        self.keyTimers[name] = nil
    end
end

--- Adds a timer
--- @param name string The name of the timer
--- @param callback function The callback for the timer
function Menu:addTimer(name, callback)
    if self.keyTimers[name] then
        self:removeTimer(name)
    end
    self.keyTimers[name] = pd.timer.keyRepeatTimer(callback)
end

--- Handles the up button down event
function Menu:upButtonDown()
    self:addTimer("upButton", function() self.gridview:selectPreviousRow(true) end)
end

--- Handles the up button up event
function Menu:upButtonUp()
    self:removeTimer("upButton")
end

--- Handles the down button down event
function Menu:downButtonDown()
    self:addTimer("downButton", function() self.gridview:selectNextRow(true) end)
end

--- Handles the down button up event
function Menu:downButtonUp()
    self:removeTimer("downButton")
end

--- Hooks into the input handlers
--- @param handlersToInclude string[] The handlers to hook into
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

--- Emits an event to the selected menu item
--- @param event string The event
--- @vararg any The arguments
function Menu:emit(event, ...)
    local selectedRow = self.gridview:getSelectedRow()
    local selectedMenuItem = self.stack[#self.stack][selectedRow]

    selectedMenuItem:invokeCallback(event, self, ...)
end

--- Draws the menu to the screen
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

--- Force the menu to redraw itself, for cases where the gridview doesn't detect a change
function Menu:forceUpdate()
    self:draw()
end

--- Redraws the menu if the underlying gridview needs to be redrawn
function Menu:update()
    if self.gridview.needsDisplay then
        self:draw()
    end
end
