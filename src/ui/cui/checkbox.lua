local cursor = require("ui.cui.cursor")
local scale = require("ui.cui.scale")
local settings = require("settings")
local state = require("ui.cui.state")
local style = require("ui.cui.style")
local window = require("ui.cui.window")

local checkbox = {}

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

function checkbox.checkbox(id, name, height, value, flags)
        local disabled = false

        if flags == ui.ButtonFlags.Disabled then disabled = true end

        local fontSize = height
        local width = ui.measureDWriteText(name, fontSize).x + height + 10 * scale.get()

        local p1 = ui.getCursor()
        local p2 = p1 + vec2(width, height)

        if not value then value = false end
        local value = type(value) == "number" and value >= 1 or (value and true or false)
        local changed = false

        ui.setCursorX(p1.x)
        ui.setCursorY(p1.y)
        ui.invisibleButton("checkbox" .. id, vec2Temp1:set(width, height), flags)
        local r1, r2 = ui.itemRect()
        local hovered = ui.rectHovered(r1, r2)

        local fillColor = settings.Appearance.uiColorSecondary
        local fontColor = settings.Appearance.uiColorText

        if disabled then
                fillColor = settings.Appearance.uiColorBackgroundShade
                fontColor = settings.Appearance.uiColorTextDim
        elseif ui.itemClicked() then
                value = not value
                changed = true
        end

        ui.setCursor(r1)
        cursor.snap()
        ui.dwriteTextAligned(name, fontSize, ui.Alignment.End, 0, vec2Temp1:set(width, height), false, fontColor)

        ui.drawRectFilled(
                r1,
                vec2Temp2:set(r1.x + height, r2.y),
                (value or disabled) and fillColor or settings.Appearance.uiColorBackground,
                4 * scale.get()
        )
        ui.drawRect(
                r1,
                vec2Temp2:set(r1.x + height, r2.y),
                value and settings.Appearance.uiColorText or settings.Appearance.uiColorTextDim,
                4 * scale.get(),
                ui.CornerFlags.All,
                2 * scale.get()
        )

        return value, changed
end

return checkbox
