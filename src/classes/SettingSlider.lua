local cui = require("ui.cui")
local settings = require("settings")
local style = require("style")

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local itemActive = ""
local itemHeld = ""

local SpinnerButtonType = { Left = 0, Right = 1 }

local spinnerButtonTimer = 0
local spinnerButtonTime = 0

local function drawSpinnerButton(direction, size, disabled)
        local flags = ui.ButtonFlags.PressedOnClick
        flags = disabled and flags + ui.ButtonFlags.Disabled or flags

        local clicked = ui.invisibleButton("##dummyButton" .. direction, vec2Temp1:set(size, size), flags)
        local hovered = ui.itemHovered()

        local iconColor = hovered and rgbm.colors.red or rgbm.colors.white
        iconColor = disabled and rgbm.colors.gray or iconColor
        ui.addIcon(ui.Icons.Skip, direction == SpinnerButtonType.Left and -size * 0.8 or size * 0.8, 0.5, iconColor)

        if clicked then
                spinnerButtonTimer = os.clock() + 0.5
                spinnerButtonTime = os.clock()
        elseif spinnerButtonTimer < os.clock() and ui.itemActive() and ui.mouseDown(ui.MouseButton.Left) then
                clicked = true
                spinnerButtonTimer = (os.clock() - spinnerButtonTime) < 2.5 and os.clock() + 0.1 or os.clock() + 0.075
        end

        return clicked
end

local scrollDelayTimer = 0

local function drawSlider(id, name, width, height, value, sliderParams, noScroll)
        local p1 = ui.getCursor()
        local p2 = p1 + vec2(width, height)
        local fontSize = height * 0.5
        local barSize = height * 0.35
        local grabberSize = height * 0.3

        local min = sliderParams.min
        local max = sliderParams.max
        local step = sliderParams.step
        local shiftStep = sliderParams.shiftStep
        local format = sliderParams.format
        local multiplier = sliderParams.mult
        local offset = sliderParams.offset
        local unit = sliderParams.unit

        local _value = value
        local value = (value - min) / step
        local max = (max - min) / step
        local changed = false

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
        local active = ui.itemActive() or (itemHeld == id and ui.mouseDown(ui.MouseButton.Left))
        local hovered = ui.mouseLocalPos() > p1 - vec2Temp1:set(grabberSize, 0)
                and ui.mouseLocalPos() <= r2 + vec2Temp1:set(grabberSize, 0)
        local scrolling = hovered and ui.mouseWheel() ~= 0 and not noScroll and scrollDelayTimer < os.clock()
        local updating = active or (hovered and ui.mouseClicked(ui.MouseButton.Left))

        if scrolling then
                local scrollChange = (ui.keyboardButtonDown(ui.KeyIndex.Shift) and shiftStep or 1)
                value = math.clamp(ui.mouseWheel() < 0 and (value - scrollChange) or (value + scrollChange), 0, max)
                scrollDelayTimer = os.clock() + settings.General.scrollDelayTimeMs / 1000
                changed = true
        end

        if updating then
                itemHeld = id
                value = math.clamp((ui.mouseLocalPos().x - r1.x) / (p2.x - r1.x) * max, 0, max)
                changed = true
        end

        local sliderFill = r1.x + ((value / max) * width)
        local sliderFillPosition = vec2Temp1:set(sliderFill, r2.y)
        ui.drawRectFilled(r1, r2, settings.Appearance.uiThemeColor3)
        ui.drawRectFilled(r1, sliderFillPosition, settings.Appearance.uiThemeColor2)
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill, r1.y),
                vec2Temp2:set(r1.x, r2.y),
                rgbm.colors.black * 0.1,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                rgbm.colors.black * 0.1
        )
        ui.drawRectFilledMultiColor(
                vec2Temp1:set(sliderFill, r1.y),
                vec2Temp2:set(r2.x, r2.y),
                rgbm.colors.black * 0.1,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                rgbm.colors.black * 0.1
        )

        local grabberPosition = vec2Temp1:set(sliderFill, r2.y - grabberSize * 0.5)
        ui.drawCircleFilled(grabberPosition, grabberSize + 2, rgbm.colors.black * 0.2, 24)
        ui.drawCircleFilled(grabberPosition, grabberSize, settings.Appearance.uiThemeColor2 * 2, 24)

        value = value * step + min

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

        if not scrolling or value == _value then changed = false end

        if ui.mouseDown(ui.MouseButton.Left) then changed = false end
        if itemActive == id and ui.mouseReleased(ui.MouseButton.Left) then
                changed = true
                itemHeld = ""
                itemActive = ""
        end
        if active then itemActive = id end

        return value, changed, active
end

local hoveredId = nil
local hoveredTimer = 0

function drawSettingsSpinner(id, name, width, height, locked, value, sliderParams, noScroll)
        local p1 = ui.getCursor()
        local p2 = p1 + vec2(width, height)
        local value = value
        local changed = false

        -- ui.drawRectFilled(p1, p2, rgbm.colors.aqua)

        local hovered = ui.mouseLocalPos() >= p1 and ui.mouseLocalPos() < p2 and not cui.modalDialogCallback

        if hovered and sliderParams.helpText and sliderParams.helpText ~= "NULL" and sliderParams.helpText ~= "" then
                if hoveredId ~= id then
                        hoveredTimer = os.clock() + 0.3
                        hoveredId = id
                end

                if hoveredTimer < os.clock() then
                        ui.tooltip(vec2(10, 20) * cui.uiScale(), function()
                                ui.pushTextWrapPosition(400 * cui.uiScale())
                                ui.dwriteText(sliderParams.helpText:gsub("\\n", "\n"), 20 * cui.uiScale())
                                ui.popTextWrapPosition()
                        end)
                end
        end

        ui.setCursorX(p1.x + height * 0.5)
        ui.setCursorY(p1.y + height * 0.15)
        if hovered and not locked then
                if drawSpinnerButton(SpinnerButtonType.Left, height, value <= sliderParams.min) then
                        if value ~= sliderParams.min then
                                value = value - sliderParams.step
                                changed = true
                        end
                end
        end

        ui.setCursorX(p1.x + width - height * 1.55)
        ui.setCursorY(p1.y + height * 0.15)
        if hovered and not locked then
                if drawSpinnerButton(SpinnerButtonType.Right, height, value >= sliderParams.max) then
                        if value ~= sliderParams.max then
                                value = value + sliderParams.step
                                changed = true
                        end
                end
        end

        ui.setCursorX(p1.x + height * 2)
        ui.setCursorY(p1.y)
        local _value, _changed, active =
                drawSlider(id, name, width - (height * 4), height, value, sliderParams, noScroll)

        if _changed then
                value = _value
                changed = _changed
        elseif active then
                value = _value
        end

        ui.setCursor(p2)

        return value, changed, active, hovered
end
