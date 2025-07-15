local cursor = require("ui.cursor")
local scale = require("ui.scale")
local settings = require("settings")
local style = require("ui.style")

local vec2Temp1 = vec2()

local text = {}

function text.writeWrapped(text, font) ui.dwriteTextWrapped(text, font * scale.get()) end

function text.write(params)
        if params.xPos then ui.setCursorX(params.xPos * scale.get()) end
        if params.yPos then ui.setCursorY(params.yPos * scale.get()) end
        text.snapCursor()

        local fontSize = params.fontSize * scale.get()
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

        ui.dwriteText(params.text, fontSize, params.color)
end

function text.writeAligned(params)
        if not params.size then params.size = vec2Temp1:set(350, 100) end

        if params.xPos then ui.setCursorX(params.xPos * scale.get()) end
        if params.yPos then ui.setCursorY(params.yPos * scale.get()) end

        ui.dwriteTextAligned(
                params.text,
                params.fontSize * scale.get(),
                params.xAlign,
                params.yAlign,
                vec2Temp1:set(params.size.x * scale.get(), params.size.y * scale.get()),
                false,
                params.color
        )
end

function text.writeBodyAligned(text, width, height, horizontalAligment, verticalAlignment, color)
        height = height or style.main.font.body.space
        color = color or settings.Appearance.uiColorText
        horizontalAligment = horizontalAligment or ui.Alignment.Center
        verticalAlignment = verticalAlignment or ui.Alignment.Center

        cursor.snap()
        ui.dwriteTextAligned(
                text,
                style.main.font.body.size,
                horizontalAligment,
                verticalAlignment,
                vec2Temp1:set(width, height),
                false,
                color
        )
end

return text
