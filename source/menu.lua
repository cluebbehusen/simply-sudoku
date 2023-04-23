local pd <const> = playdate
local gfx <const> = pd.graphics

class("Menu").extends()

function Menu:init(initialMenuItems, x, y, width, height, cellHeight)
    self.stack = {}
    self:pushMenuItems(initialMenuItems)

    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.gridview = pd.ui.gridview.new(0, cellHeight)
end

function Menu:pushMenuItems(menuItems)
    table.insert(self.stack, menuItems)
end

function Menu:popMenuItems()
    table.remove(self.stack)
end

function Menu:upButtonDown()
    self.gridview:selectPreviousRow(true)
end

function Menu:downButtonDown()
    self.gridview:selectNextRow(true)
end

function Menu:hook(handlersToInclude)
    for _, handler in pairs(handlersToInclude) do
        if handler == "upButtonDown" or hander == "downButtonDown"
            error("upButtonDown and downButtonDown are reserved for Menu.")
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
end
