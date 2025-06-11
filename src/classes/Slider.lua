local cui = require("ui.cui")
local settings = require("settings")
local style = require("style")

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local itemActive = ""
local itemHeld = ""

local scrollDelayTimer = 0

local function drawGrabber() end

local function drawSlider(id, name, width, height, value, sliderParams, noScroll)
        local p1 = ui.getCursor()
        local p2 = p1 + vec2(width, height)

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

        local fontSize = height * 0.32
        local barSize = height * 0.3
        local grabberSize = math.max(width / (steps + 1), 35)

        cui.snapCursor()
        ui.dwriteTextAligned(
                name:gsub("->            ", ""):gsub("             %?", ""),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Start,
                vec2Temp1:set(width * 0.5, height),
                false,
                rgbm.colors.white
        )

        ui.setCursorX(p1.x)
        ui.setCursorY(p1.y + height - barSize)
        ui.invisibleButton("slider" .. id, vec2Temp1:set(width, barSize))
        local r1, r2 = ui.itemRect()
        ui.drawRectFilled(r1, r2, rgbm.colors.black * 0.2, 5)

        local active = ui.itemActive() or (itemHeld == id and ui.mouseDown(ui.MouseButton.Left))
        local hovered = ui.mouseLocalPos() > p1 and ui.mouseLocalPos() <= p2
        local scrolling = hovered and ui.mouseWheel() ~= 0 and not noScroll and scrollDelayTimer < os.clock()
        local dragging = active or (hovered and ui.mouseClicked(ui.MouseButton.Left))

        if active then itemActive = id end

        if scrolling then
                local scrollChange = (ui.keyboardButtonDown(ui.KeyIndex.Shift) and shiftStep or 1)
                valueStep = ui.mouseWheel() < 0 and (valueStep - scrollChange) or (valueStep + scrollChange)
                scrollDelayTimer = os.clock() + settings.General.scrollDelayTimeMs * 0.001
                changed = true
        elseif dragging then
                valueStep = ((ui.mouseLocalPos().x - grabberSize * 0.5 - r1.x) / (width - grabberSize)) * steps
                itemHeld = id
                changed = true
        end

        valueStep = math.round(math.clamp(valueStep, 0, steps))

        local sliderFill = r1.x + ((valueStep / steps) * (width - grabberSize))
        if sliderFill > r1.x then
                ui.drawRectFilled(
                        r1,
                        vec2Temp1:set(sliderFill, r2.y),
                        settings.Appearance.uiThemeColor2,
                        5,
                        ui.CornerFlags.Left
                )
        end
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill, r1.y),
                vec2Temp2:set(r1.x, r2.y),
                rgbm.colors.black * 0.25,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                rgbm.colors.black * 0.25
        )
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill, r1.y),
                r2,
                rgbm.colors.black * 0.25,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                rgbm.colors.black * 0.25
        )

        ui.drawRectFilled(
                vec2(sliderFill, r1.y - 5),
                vec2(sliderFill + grabberSize, r2.y + 5),
                rgbm.colors.black * 0.5,
                5
        )
        ui.drawRectFilled(
                vec2(sliderFill + 1, r1.y - 3),
                vec2(sliderFill + grabberSize - 1, r2.y + 3),
                active and settings.Appearance.uiThemeColor2 or settings.Appearance.uiThemeColor3 * 0.8,
                4
        )
        ui.setCursor(vec2(sliderFill, r2.y - barSize))
        ui.icon(ui.Icons.Menu, vec2(grabberSize, barSize), rgbm.colors.black * 0.3, barSize)

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

local hoveredId = nil
local hoveredTimer = 0

function drawSpinner(id, name, width, height, locked, value, sliderParams, noScroll)
        local p1 = ui.getCursor()
        local p2 = p1 + vec2(width, height)
        local value = value
        local changed = false

        -- ui.drawRectFilled(p1, p2, rgbm.colors.aqua)

        local hovered = ui.mouseLocalPos() >= p1
                and ui.mouseLocalPos() < vec2Temp1:set(p2.x, p1.y + height * 0.3)
                and not cui.modalDialogCallback

        if hovered and sliderParams.help and sliderParams.help ~= "NULL" and sliderParams.help ~= "" then
                if hoveredId ~= id then
                        hoveredTimer = os.clock() + 0.4
                        hoveredId = id
                end

                if hoveredTimer < os.clock() then
                        ui.tooltip(vec2(10, 20) * cui.uiScale(), function()
                                ui.drawRectFilled(0, ui.windowSize(), rgbm.colors.black)
                                ui.pushTextWrapPosition(400 * cui.uiScale())
                                cui.snapCursor()
                                ui.dwriteText(sliderParams.help:gsub("\\n", "\n"), 20 * cui.uiScale())
                                ui.popTextWrapPosition()
                        end)
                end
        elseif hoveredId == id then
                hoveredId = nil
        end

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
