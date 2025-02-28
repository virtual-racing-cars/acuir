local cui = require("ui.cui")
local pitstop = require("pitstop")
local settings = require("settings")
local style = require("style")
local sim = ac.getSim()

local activeItemIndex = 0

local navControlRightButton =
        ac.ControlButton("ACUIR_COCKPIT_X_R", { keyboard = ac.KeyIndex.Left, gamepad = ac.GamepadButton.DPadLeft })
local navControlLeftButton =
        ac.ControlButton("ACUIR_COCKPIT_X_L", { keyboard = ac.KeyIndex.Right, gamepad = ac.GamepadButton.DPadRight })
local navControlDownButton =
        ac.ControlButton("ACUIR_COCKPIT_Y_DN", { keyboard = ac.KeyIndex.Down, gamepad = ac.GamepadButton.DPadDown })
local navControlUpButton =
        ac.ControlButton("ACUIR_COCKPIT_Y_UP", { keyboard = ac.KeyIndex.Up, gamepad = ac.GamepadButton.DPadUp })

navControlLeftButton:onPressed(function() pitstop:setWindowOpen(true) end)

navControlRightButton:onPressed(function() pitstop:setWindowOpen(true) end)

navControlDownButton:onPressed(function()
        pitstop:setWindowOpen(true)

        activeItemIndex = activeItemIndex < #ac.getPitstopSpinners() and activeItemIndex + 1 or 0
end)

navControlUpButton:onPressed(function()
        pitstop:setWindowOpen(true)

        activeItemIndex = activeItemIndex > 0 and activeItemIndex - 1 or #ac.getPitstopSpinners()
end)

local function mfdWidgetSpinner(name, height, index, value, format, min, max, items, wingIndex)
        local buttonSize = height

        ui.invisibleButton("##pswidget" .. name .. index, vec2(ui.windowWidth(), buttonSize))
        local r1, r2 = ui.itemRect()

        local fontSize = math.floor(buttonSize * 0.8)
        fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize

        local active = false
        if activeItemIndex == index then
                active = true
                ui.drawRectFilled(r1, r2, rgbm.colors.red)
        end

        ui.sameLine()
        ui.setCursorX(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                name,
                fontSize,
                ui.Alignment.End,
                ui.Alignment.Center,
                vec2((ui.windowWidth() / 5) * 2, buttonSize)
        )
        ui.sameLine()
        ui.setCursorX(ui.windowWidth() / 2 - ui.windowWidth() / 10)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "< >",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 5, buttonSize)
        )

        local displayValue = items and items[value + 1] or string.format(format, value)

        if wingIndex then
                local delta = displayValue - pitstop.wings[wingIndex].angle

                displayValue = string.format(delta == 0 and "%.0f (%.0f)" or "%+.0f (%.0f)", delta, displayValue)
        else
                displayValue = displayValue:match("%((.-)%)") or displayValue
        end

        ui.sameLine()
        cui.snapCursor()
        ui.dwriteTextAligned(
                displayValue,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2((ui.windowWidth() / 5) * 2, buttonSize)
        )

        if not active then return value end

        if navControlLeftButton:pressed() then value = value > min and value - 1 or max end
        if navControlRightButton:pressed() then value = value < max and value + 1 or min end

        return value
end

function script.pitstopWindow(dt)
        local itemCount = #ac.getPitstopSpinners() <= 9 and #ac.getPitstopSpinners() + 6 or #ac.getPitstopSpinners() + 7
        local itemHeight = 32 * cui.scaleY()
        local windowHeight = itemHeight * itemCount
        local fontSize = math.floor(itemHeight * 0.8)
        fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize
        local windowSize = vec2(itemHeight * 11, windowHeight)

        ui.beginToolWindow("toolWindowTest", ui.cursorScreenPos(), windowSize, true, true)
        style:pushStyleMain()

        ui.drawRectFilled(0, ui.availableSpace(), settings.Appearance.uiColor1 * 0.65)
        ui.drawRectFilled(0, vec2(ui.windowWidth(), itemHeight * 1.2), settings.Appearance.uiColor1 * 0.65)

        ui.setCursor(0)
        ui.dwriteTextAligned(
                "PITSTOP",
                itemHeight,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), itemHeight * 1.2)
        )

        local lastSection = ""
        for _, spinner in ipairs(sm._pitSpinners) do
                if spinner.preset == -1 then
                        local value = mfdWidgetSpinner(
                                spinner.name,
                                itemHeight,
                                spinner.index + 1,
                                spinner.value,
                                spinner.format,
                                spinner.min,
                                spinner.max
                        )
                        spinner:setValue(value)
                elseif spinner.preset == sim.currentQuickPitPreset then
                        if spinner.tab ~= lastSection and spinner.tab then
                                lastSection = spinner.tab
                                ui.setCursorX(0)
                                ui.drawRectFilled(
                                        ui.getCursor(),
                                        ui.getCursor() + vec2(ui.windowWidth(), itemHeight),
                                        settings.Appearance.uiColor1 * 0.65
                                )

                                ui.dwriteTextAligned(
                                        spinner.tab,
                                        fontSize,
                                        ui.Alignment.Center,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), itemHeight)
                                )
                        end
                        local value = mfdWidgetSpinner(
                                spinner.nameAlt,
                                itemHeight,
                                spinner.index,
                                spinner.value,
                                spinner.format,
                                spinner.min,
                                spinner.max,
                                spinner.items,
                                spinner.wingIndex
                        )
                        spinner:setValue(value)
                end
        end

        ui.drawRectFilled(ui.getCursor(), ui.windowSize(), settings.Appearance.uiColor1 * 0.65)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Estimated Stop Time: %.1f s" % pitstop:getEstimatedTime(),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), ui.availableSpaceY()),
                false,
                rgbm.colors.white
        )

        style:popStyleMain()
        ui.endToolWindow()
        ui.setCursor(windowSize)
end
