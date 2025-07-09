local scale = require("src.ui.scale")
local settings = require("settings")

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

function text.writeBodyAligned(text, size, color, horizontalAligment, verticalAlignment)
        if not color then color = settings.Appearance.uiColorText end
        if not horizontalAligment then horizontalAligment = ui.Alignment.Center end
        if not verticalAlignment then verticalAlignment = ui.Alignment.Center end

        text.snapCursor()
        ui.dwriteTextAligned(text, 18 * scale.get(), horizontalAligment, verticalAlignment, size, false, color)
end

return text
