local app = require("app")
local cui = require("ui.cui")
local pitstop = require("pitstop")
local settings = require("settings")
local style = require("ui.cui.style")
local sim = ac.getSim()

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()
local vec2Temp3 = vec2()

local activeItemIndex = 0

local navControlRightButton = ac.ControlButton(
        "ACUIR_COCKPIT_X_R",
        { keyboard = { key = ui.KeyIndex.Right }, gamepad = ac.GamepadButton.DPadRight, period = 0.1 }
):setAlwaysActive(true)

local navControlLeftButton = ac.ControlButton(
        "ACUIR_COCKPIT_X_L",
        { keyboard = { key = ui.KeyIndex.Left }, gamepad = ac.GamepadButton.DPadLeft, period = 0.1 }
):setAlwaysActive(true)

local navControlDownButton = ac.ControlButton(
        "ACUIR_COCKPIT_Y_DN",
        { keyboard = { key = ui.KeyIndex.Down }, gamepad = ac.GamepadButton.DPadDown, period = 0.1 }
):setAlwaysActive(true)

local navControlUpButton = ac.ControlButton(
        "ACUIR_COCKPIT_Y_UP",
        { keyboard = { key = ui.KeyIndex.Up }, gamepad = ac.GamepadButton.DPadUp, period = 0.1 }
):setAlwaysActive(true)

local delayTimer = 0

local function isPitMenuNavAvailable()
        return app.state.appOpen and sim.isLive and not sim.isInMainMenu and settings.Modules.newQuickPitMenu
end

navControlLeftButton:onPressed(function()
        if not isPitMenuNavAvailable() then return end
        pitstop:setWindowOpen(true)
end)
navControlLeftButton:onReleased(function()
        if sim.isInMainMenu or sim.isPaused or not sim.isLive then return end
        delayTimer = 0
end)

navControlRightButton:onPressed(function()
        if not isPitMenuNavAvailable() then return end
        pitstop:setWindowOpen(true)
end)
navControlRightButton:onReleased(function()
        if sim.isInMainMenu or sim.isPaused or not sim.isLive then return end
        delayTimer = 0
end)

navControlDownButton:onPressed(function()
        if not isPitMenuNavAvailable() then return end

        pitstop:setWindowOpen(true)

        if delayTimer > os.clock() then return end

        activeItemIndex = activeItemIndex < #ac.getPitstopSpinners() and activeItemIndex + 1 or 0

        if delayTimer < os.clock() - 1 then
                delayTimer = os.clock() + 0.5
        else
                delayTimer = os.clock() + 0.1
        end
end)
navControlDownButton:onReleased(function()
        if sim.isInMainMenu or sim.isPaused or not sim.isLive then return end

        delayTimer = 0
end)

navControlUpButton:onPressed(function()
        if not isPitMenuNavAvailable() then return end

        pitstop:setWindowOpen(true)

        if delayTimer > os.clock() then return end

        activeItemIndex = activeItemIndex > 0 and activeItemIndex - 1 or #ac.getPitstopSpinners()

        if delayTimer < os.clock() - 1 then
                delayTimer = os.clock() + 0.5
        else
                delayTimer = os.clock() + 0.1
        end
end)
navControlUpButton:onReleased(function()
        if sim.isInMainMenu or sim.isPaused or not sim.isLive then return end

        delayTimer = 0
end)

local function mfdWidgetSpinner(name, height, index, value, format, min, max, items, wingIndex)
        local buttonSize = height

        ui.invisibleButton("##pswidget" .. name .. index, vec2Temp1:set(ui.windowWidth(), buttonSize))
        local r1, r2 = ui.itemRect()

        local fontSize = style.main.font.body.size

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
                vec2Temp1:set((ui.windowWidth() / 5) * 2, buttonSize)
        )
        ui.sameLine()
        ui.setCursorX(ui.windowWidth() / 2 - ui.windowWidth() / 10)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "< >",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2Temp1:set(ui.windowWidth() / 5, buttonSize)
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
                vec2Temp1:set((ui.windowWidth() / 5) * 2, buttonSize)
        )

        if not active then return value end

        if navControlLeftButton:pressed() and delayTimer <= os.clock() then
                value = value > min and value - 1 or max
                if delayTimer < os.clock() - 1 then
                        delayTimer = os.clock() + 0.5
                else
                        delayTimer = os.clock() + 0.1
                end
        end
        if navControlRightButton:pressed() and delayTimer <= os.clock() then
                value = value < max and value + 1 or min
                if delayTimer < os.clock() - 1 then
                        delayTimer = os.clock() + 0.5
                else
                        delayTimer = os.clock() + 0.1
                end
        end

        return value
end

function script.pitstopWindow(dt)
        if not app.state.appOpen or not settings.Modules.newQuickPitMenu then
                pitstop:setWindowOpen(false)
                ac.disableQuickMenuPitstop(false)
                return
        end

        local itemCount = #ac.getPitstopSpinners() <= 9 and #ac.getPitstopSpinners() + 5 or #ac.getPitstopSpinners() + 6
        local itemHeight = style.main.font.body.space
        local windowHeight = itemHeight * itemCount
        local fontSize = style.main.font.body.size
        local windowSize = vec2Temp3:set(itemHeight * 9, windowHeight)

        ui.transparentWindow("toolWindowTest", ui.cursorScreenPos(), windowSize, true, function()
                style:pushStyleMain()

                ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground, 12 * cui.scale())
                ui.drawRectFilled(
                        0,
                        vec2Temp1:set(ui.windowWidth(), style.main.font.header.space),
                        settings.Appearance.uiColorPrimary,
                        12 * cui.scale(),
                        ui.CornerFlags.Top
                )

                ui.setCursor(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "PITSTOP",
                        style.main.font.header.size,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2Temp1:set(ui.windowWidth(), style.main.font.header.space)
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
                                                ui.getCursor() + vec2Temp1:set(ui.windowWidth(), itemHeight),
                                                settings.Appearance.uiColorPrimary * 0.65
                                        )

                                        cui.snapCursor()
                                        ui.dwriteTextAligned(
                                                spinner.tab,
                                                style.main.font.header.size,
                                                ui.Alignment.Center,
                                                ui.Alignment.Center,
                                                vec2Temp1:set(ui.windowWidth(), itemHeight)
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

                ui.drawRectFilled(
                        ui.getCursor(),
                        ui.windowSize(),
                        settings.Appearance.uiColorPrimary,
                        12 * cui.scale(),
                        ui.CornerFlags.Bottom
                )
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "Estimated Stop Time: %.1f s" % pitstop:getEstimatedTime(),
                        fontSize,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2Temp1:set(ui.windowWidth(), ui.availableSpaceY()),
                        false,
                        settings.Appearance.uiColorOrange
                )

                style:popStyleMain()
        end)

        ui.setCursor(windowSize)
end
