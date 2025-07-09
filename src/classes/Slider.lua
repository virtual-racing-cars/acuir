local callback = require("callback")
local cui = require("ui.cui")
local settings = require("settings")

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local itemActive = ""
local itemHeld = ""

local scrollDelayTimer = 0

local function drawSlider(id, name, width, height, value, sliderParams, noScroll)
        local p1 = ui.getCursor()

        local min = sliderParams.min
        local max = sliderParams.max
        local step = sliderParams.step
        local shiftStep = sliderParams.shiftStep
        local format = sliderParams.format
        local multiplier = sliderParams.multiplier
        local offset = sliderParams.offset or 0
        local unit = sliderParams.unit

        local valueOriginal = value
        local valueStep = (value - min) / step
        local steps = (max - min) / step
        local changed = false

        local fontSize = height * 0.45
        local barSize = height * 0.45
        local grabberSize = math.max(width / (steps + 1), barSize * 2)

        local sliderNameText = name:gsub("->            ", ""):gsub("             %?", "")

        if sliderParams.default and math.round(sliderParams.default, 4) ~= math.round(value, 4) then
                sliderNameText = sliderNameText .. "*"
        end

        cui.snapCursor()
        ui.dwriteTextAligned(
                sliderNameText,
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Start,
                vec2Temp1:set(width, height),
                false,
                rgbm.colors.white
        )

        ui.setCursorX(p1.x)
        ui.setCursorY(p1.y + height - height * 0.4)
        ui.invisibleButton("slider" .. id, vec2Temp1:set(width, barSize))
        local r1, r2 = ui.itemRect()
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackground * 0.2, 6 * cui.scale())

        local active = ui.itemActive() or (itemHeld == id and ui.mouseDown(ui.MouseButton.Left))
        local hovered = ui.rectHovered(r1, r2)
        local scrolling = hovered and ui.mouseWheel() ~= 0 and not noScroll and scrollDelayTimer < os.clock()
        local dragging = active or (hovered and ui.mouseClicked(ui.MouseButton.Left))

        local sticking = 0

        if active then
                for i = 0, 7 do
                        if sticking == 0 then sticking = ac.getGamepadAxisValue(i, 2) end
                end
        end

        if active then itemActive = id end

        if scrolling then
                local scrollChange = (ui.keyboardButtonDown(ui.KeyIndex.Shift) and shiftStep or 1)
                valueStep = ui.mouseWheel() < 0 and (valueStep - scrollChange) or (valueStep + scrollChange)
                scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs * 0.001
                changed = true
        elseif dragging then
                valueStep = ((ui.mouseLocalPos().x - grabberSize * 0.5 - r1.x) / (width - grabberSize)) * steps
                itemHeld = id
                changed = true
        elseif sticking ~= 0 and scrollDelayTimer < os.clock() then
                valueStep = valueStep + math.round(math.abs(sticking)) * math.sign(sticking)
                scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs * 0.001
                changed = true
        end

        valueStep = math.round(math.clamp(valueStep, 0, steps))

        local sliderFill = r1.x + ((valueStep / steps) * (width - grabberSize))
        if sliderFill > r1.x then
                ui.drawRectFilled(
                        r1,
                        vec2Temp1:set(sliderFill + grabberSize * 0.5, r2.y),
                        settings.Appearance.uiColorSecondary,
                        6 * cui.scale(),
                        ui.CornerFlags.Left
                )
        end
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill + grabberSize * 0.5, r1.y),
                vec2Temp2:set(r1.x, r2.y),
                settings.Appearance.uiColorBackground * 0.25,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                settings.Appearance.uiColorBackground * 0.25
        )
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill + grabberSize * 0.5, r1.y),
                r2,
                settings.Appearance.uiColorBackground * 0.25,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                settings.Appearance.uiColorBackground * 0.25
        )

        ui.beginGradientShade()

        ui.drawRectFilled(
                vec2(sliderFill, r1.y),
                vec2(sliderFill + grabberSize, r2.y),
                settings.Appearance.uiColorPrimary,
                6 * cui.scale()
        )
        if active then
                ui.endGradientShade(
                        vec2(sliderFill, r2.y),
                        vec2(sliderFill, r1.y),
                        settings.Appearance.uiColorSecondary,
                        settings.Appearance.uiColorSecondary * 4,
                        true
                )
        else
                ui.endGradientShade(
                        vec2(sliderFill, r1.y),
                        vec2(sliderFill, r2.y),
                        active and settings.Appearance.uiColorSecondary or settings.Appearance.uiColorAccent,
                        active and settings.Appearance.uiColorSecondary or settings.Appearance.uiColorPrimary * 1.2,
                        true
                )
        end

        ui.drawRect(
                vec2(sliderFill, r1.y),
                vec2(sliderFill + grabberSize, r2.y),
                settings.Appearance.uiColorBackground,
                6 * cui.scale(),
                ui.CornerFlags.All,
                2 * cui.scale()
        )

        local value = valueStep * step + min

        ui.setCursor(p1)
        cui.snapCursor()
        ui.dwriteTextAligned(
                string.format(format, value * multiplier + offset, unit),
                fontSize,
                ui.Alignment.End,
                ui.Alignment.Start,
                vec2Temp1:set(width, height),
                false,
                rgbm.colors.white
        )

        if itemActive == id and not ui.mouseDown(ui.MouseButton.Left) then
                changed = true
                itemHeld = ""
                itemActive = ""
        end

        if value == valueOriginal then changed = false end

        return value, changed, active
end

function drawSpinner(id, name, width, height, locked, value, sliderParams, noScroll)
        local p1 = ui.getCursor()
        local p2 = p1 + vec2(width, height)
        local value = value
        local changed = false

        -- ui.drawRectFilled(p1, p2, rgbm.colors.aqua)

        local hovered = ui.rectHovered(p1, vec2Temp1:set(p2.x, p1.y + height)) and not callback.dialog

        ui.setCursorX(p1.x + width * 0.04)
        ui.setCursorY(p1.y + height * 0.1)
        local _value, _changed, active = drawSlider(id, name, width * 0.92, height * 0.7, value, sliderParams, noScroll)

        if _changed then
                value = _value
                changed = _changed
        elseif active then
                value = _value
        end

        ui.setCursor(p2)

        return value, changed, active, hovered
end
