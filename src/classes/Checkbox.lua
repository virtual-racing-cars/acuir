local cui = require("ui.cui")
local settings = require("settings")

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

function drawCheckbox(id, name, height, locked, value)
        local width = height * 4

        local p1 = ui.getCursor()
        local p2 = p1 + vec2(width, height)

        if not value then value = false end
        local value = type(value) == "number" and (tonumber(value) >= 1 and 1 or 0) or (value and 1 or 0)
        local changed = false

        local fontSize = height * 0.9
        local barHeight = height
        local barWidth = width
        local grabberSize = barWidth * 0.5

        ui.setCursorX(p1.x)
        ui.setCursorY(p1.y)
        ui.invisibleButton("checkbox" .. id, vec2Temp1:set(barWidth, barHeight))
        local r1, r2 = ui.itemRect()
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackground * 0.2, 6 * cui.uiScale())

        local hovered = ui.rectHovered(r1, r2)

        if ui.itemClicked() then
                value = value >= 1 and 0 or 1
                changed = true
        end

        ui.setCursorX(r1.x + barWidth + 10 * cui.uiScale())
        ui.setCursorY(r1.y)
        cui.snapCursor()
        ui.dwriteText(name, fontSize, rgbm.colors.white)

        if ui.itemClicked() then
                value = value >= 1 and 0 or 1
                changed = true
        end

        local sliderFill = r1.x + (value * (barWidth - grabberSize))
        if sliderFill > r1.x then
                ui.drawRectFilled(
                        r1,
                        vec2Temp1:set(sliderFill, r2.y),
                        settings.Appearance.uiColorSecondary,
                        6 * cui.uiScale(),
                        ui.CornerFlags.Left
                )
        end
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill, r1.y),
                vec2Temp2:set(r1.x, r2.y),
                settings.Appearance.uiColorBackground * 0.25,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                settings.Appearance.uiColorBackground * 0.25
        )
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill, r1.y),
                r2,
                settings.Appearance.uiColorBackground * 0.25,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                settings.Appearance.uiColorBackground * 0.25
        )

        ui.drawRectFilled(
                vec2(sliderFill, r1.y),
                vec2(sliderFill + grabberSize, r2.y),
                settings.Appearance.uiColorBackground * 0.5,
                6 * cui.uiScale()
        )
        ui.drawRectFilled(
                vec2(sliderFill + 1, r1.y - 1),
                vec2(sliderFill + grabberSize - 1, r2.y + 1),
                settings.Appearance.uiColorAccent,
                5 * cui.uiScale()
        )
        ui.setCursor(vec2(sliderFill, r2.y - barHeight))
        ui.icon(
                ui.Icons.Menu,
                vec2(grabberSize, barHeight),
                settings.Appearance.uiColorBackground * 0.3,
                barHeight * 0.75
        )

        return value >= 1, changed
end
