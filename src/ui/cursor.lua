local scale = require("src.ui.scale")

local cursor = {}

function cursor.setX(v) ui.setCursorX(v * scale.get()) end

function cursor.setY(v) ui.setCursorY(v * scale.get()) end

function cursor.offsetX(v) ui.offsetCursorX(v * scale.get()) end

function cursor.offsetY(v) ui.offsetCursorY(v * scale.get()) end

function cursor:centerAround(width, height, x, y)
        if x then ui.setCursorX(x - width * 0.5) end
        if y then ui.setCursorY(y - height * 0.5) end
end

function cursor.snap()
        local x, y = ui.getCursorX(), ui.getCursorY()
        x, y = math.floor(x), math.floor(y)

        x = x % 2 ~= 0 and x + 1 or x
        y = y % 2 ~= 0 and y + 1 or y

        ui.setCursorX(x)
        ui.setCursorY(y)
end

return cursor
