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
        style:pushSpinnerButtonStyle()

        size = size / 2

        local tmpPos = ui.getCursor()

        local flags = ui.ButtonFlags.PressedOnClick
        flags = disabled and flags + ui.ButtonFlags.Disabled or flags

        local clicked = ui.button("##dummyButton" .. direction, size, flags)
        local hovered = ui.itemHovered()
        ui.setCursor(tmpPos)

        local iconColor = hovered and rgbm.colors.red or rgbm.colors.white
        iconColor = disabled and rgbm.colors.gray or iconColor
        ui.icon(ui.Icons.Skip, size, iconColor, direction == SpinnerButtonType.Left and -size or size)

        if clicked then
                spinnerButtonTimer = os.clock() + 0.5
                spinnerButtonTime = os.clock()
        elseif spinnerButtonTimer < os.clock() and ui.itemActive() and ui.mouseDown(ui.MouseButton.Left) then
                clicked = true
                spinnerButtonTimer = (os.clock() - spinnerButtonTime) < 2.5 and os.clock() + 0.1 or os.clock() + 0.075
        end

        style:popSpinnerButtonStyle()

        return clicked
end

local scrollDelayTimer = 0

local function drawSlider(
        id,
        name,
        xPos,
        yPos,
        width,
        height,
        locked,
        value,
        min,
        max,
        step,
        shiftStep,
        round,
        format,
        multiplier,
        offset,
        noScroll
)
        local _value = value
        local value = (value - min) / step
        local max = (max - min) / step
        local changed = false
        local xMax = xPos + width
        local fontSize = math.floor(height * 0.38)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        cui.snapCursor()
        ui.dwriteTextAligned(
                name:gsub("->            ", ""):gsub("             %?", ""),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2Temp1:set(width, height / 2),
                false,
                rgbm.colors.white
        )

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        ui.invisibleButton("invis" .. id, vec2Temp1:set(width, height))

        local active = ui.itemActive() or (itemHeld == id and ui.mouseDown(ui.MouseButton.Left))
        local sliderHovered = ui.mouseLocalPos() > vec2Temp1:set(xPos, yPos)
                and ui.mouseLocalPos() <= vec2Temp2:set(xPos + width, yPos + height)
        local sliderClicked = ui.mouseClicked(ui.MouseButton.Left) and not ui.itemHovered(ui.HoveredFlags.None)
        local sliderScrolling = ui.itemHovered()
                and ui.mouseWheel() ~= 0
                and not noScroll
                and scrollDelayTimer < os.clock()

        if active or (sliderHovered and (sliderClicked or sliderScrolling)) then
                if sliderScrolling then
                        local valueChangeAmount = (ui.keyboardButtonDown(ui.KeyIndex.Shift) and shiftStep or 1)
                        value = ui.mouseWheel() < 0 and (value - valueChangeAmount) or (value + valueChangeAmount)
                else
                        itemHeld = id
                        value = (ui.mouseLocalPos().x - xPos) / (xMax - xPos) * max
                end

                changed = true
        end

        if sliderScrolling then scrollDelayTimer = os.clock() + settings.General.scrollDelayTimeMs / 1000 end

        value = math.round(math.clamp(value, 0, max))

        ui.drawRectFilled(
                vec2Temp1:set(xPos, yPos + height),
                vec2Temp2:set(xPos + ((value / max) * width), yPos + height * 1.083),
                settings.Appearance.uiThemeColor2
        )

        value = value * step + min

        if not sliderScrolling or value == _value then changed = false end

        ui.setCursorX(xPos)
        ui.setCursorY(yPos + height / 2)
        cui.snapCursor()
        ui.dwriteTextAligned(
                string.format(format, value * multiplier + offset),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2Temp1:set(width, height / 2),
                false,
                rgbm.colors.black
        )

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

function drawSpinner(
        id,
        name,
        xPos,
        yPos,
        width,
        height,
        locked,
        value,
        min,
        max,
        step,
        shiftStep,
        round,
        format,
        multiplier,
        offset,
        noScroll,
        helpText
)
        local buttonSize = height / 2
        local value = value
        local changed = false

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)

        ui.drawRectFilled(
                vec2Temp1:set(xPos + height, yPos),
                vec2Temp2:set(xPos + width - height, yPos + buttonSize),
                settings.Appearance.uiThemeColor1
        )

        local hoveredHelp = ui.mouseLocalPos() >= vec2Temp1:set(xPos + height, yPos)
                and ui.mouseLocalPos() < vec2Temp2:set(xPos + width - height, yPos + buttonSize)
                and not cui.modalDialogCallback

        if hoveredHelp and helpText and helpText ~= "NULL" and helpText ~= "" then
                if hoveredId ~= id then
                        hoveredTimer = os.clock() + 0.3
                        hoveredId = id
                end

                if hoveredTimer < os.clock() then
                        ui.tooltip(vec2(10, 20) * cui.uiScale(), function()
                                ui.pushTextWrapPosition(400 * cui.uiScale())
                                helpText = helpText:gsub("\\n", "\n")
                                ui.dwriteText(helpText, 20 * cui.uiScale())
                                ui.popTextWrapPosition()
                        end)
                end
        end

        ui.drawRectFilled(
                vec2Temp1:set(xPos + height, yPos + buttonSize),
                vec2Temp2:set(xPos + width - height, yPos + height),
                locked and settings.Appearance.uiThemeColor3 / 1.25 or settings.Appearance.uiThemeColor3
        )

        local hovered = ui.mouseLocalPos() >= vec2Temp1:set(xPos + buttonSize, yPos)
                and ui.mouseLocalPos() < vec2Temp2:set(xPos + width - buttonSize, yPos + height)
                and not cui.modalDialogCallback

        ui.setCursorX(xPos + buttonSize)
        ui.setCursorY(yPos + buttonSize)
        if hovered and not locked then
                if drawSpinnerButton(SpinnerButtonType.Left, vec2Temp1:set(height, height), value <= min) then
                        if value ~= min then
                                value = value - step
                                changed = true
                        end
                end
        else
                ui.dummy(vec2Temp1:set(height, height))
        end

        local _value, _changed, active = drawSlider(
                id,
                name,
                xPos + height,
                yPos,
                width - (height * 2),
                height,
                locked,
                value,
                min,
                max,
                step,
                shiftStep,
                round,
                format,
                multiplier,
                offset,
                noScroll
        )
        if _changed then
                value = _value
                changed = _changed
        elseif active then
                value = _value
        end

        ui.setCursorX(xPos + width - height)
        ui.setCursorY(yPos + buttonSize)

        if hovered and not locked then
                if drawSpinnerButton(SpinnerButtonType.Right, vec2Temp1:set(height, height), value >= max) then
                        if value ~= max then
                                value = value + step
                                changed = true
                        end
                end
        else
                ui.dummy(vec2Temp1:set(height, height))
        end

        return value, changed, active, hovered
end
