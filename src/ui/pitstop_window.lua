local cui = require("ui.cui")
local settings = require("settings")
local style = require("style")
local sim = ac.getSim()

local quickPitMenuFocused = true

local navControlToggleMenus = ac.ControlButton("ACUIR_COCKPIT_MENUS")
local navControlRightButton =
        ac.ControlButton("ACUIR_COCKPIT_X_R", { keyboard = ac.KeyIndex.Left, gamepad = ac.GamepadButton.DPadLeft })
local navControlLeftButton =
        ac.ControlButton("ACUIR_COCKPIT_X_L", { keyboard = ac.KeyIndex.Right, gamepad = ac.GamepadButton.DPadRight })
local navControlDownButton =
        ac.ControlButton("ACUIR_COCKPIT_Y_DN", { keyboard = ac.KeyIndex.Down, gamepad = ac.GamepadButton.DPadDown })
local navControlUpButton =
        ac.ControlButton("ACUIR_COCKPIT_Y_UP", { keyboard = ac.KeyIndex.Up, gamepad = ac.GamepadButton.DPadUp })

local activeItemIndex = 0
local function mfdWidgetSpinner(name, index, value, format, min, max, items)
        ui.invisibleButton("##pswidget" .. name .. index, vec2(ui.windowWidth(), 24 * cui.scaleY()))
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()

        local active = false
        if activeItemIndex == index then
                active = true
                ui.drawRectFilled(r1, r2, rgbm.colors.red)
        end

        ui.sameLine()
        ui.setCursorX(0)
        ui.dwriteTextAligned(
                name,
                18,
                ui.Alignment.End,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 24 * cui.scaleY())
        )
        ui.sameLine()
        ui.setCursorX(ui.windowWidth() / 2 - ui.windowWidth() / 12)
        ui.dwriteTextAligned(
                "< - / + >",
                18,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 6, 24 * cui.scaleY())
        )

        local displayValue = items and items[value + 1] or string.format(format, value)
        ui.sameLine()
        ui.offsetCursorY(-1)
        ui.dwriteTextAligned(
                displayValue,
                18,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX(), 24 * cui.scaleY() + 1)
        )

        if not active then return value end

        if navControlLeftButton:pressed() then value = value > min and value - 1 or max end
        if navControlRightButton:pressed() then value = value < max and value + 1 or min end

        return value
end

local acCarControls = ac.overrideCarControls(0)

navControlToggleMenus:onPressed(function()
        if not quickPitMenuFocused then
                ac.setWindowOpen("pitstopStrategyWidget", true)
                quickPitMenuFocused = true
        else
                ac.setWindowOpen("pitstopStrategyWidget", false)
                quickPitMenuFocused = false
        end
end)

navControlLeftButton:onPressed(function()
        if not quickPitMenuFocused then acCarControls.lookLeft = true end
end)

navControlLeftButton:onReleased(function() acCarControls.lookLeft = false end)

navControlRightButton:onPressed(function()
        if not quickPitMenuFocused then acCarControls.lookRight = true end
end)

navControlRightButton:onReleased(function() acCarControls.lookRight = false end)

navControlDownButton:onPressed(function()
        if not quickPitMenuFocused then acCarControls.lookBack = true end

        activeItemIndex = activeItemIndex < #ac.getPitstopSpinners() and activeItemIndex + 1 or 0
end)

navControlDownButton:onReleased(function() acCarControls.lookBack = false end)

navControlUpButton:onPressed(function()
        if quickPitMenuFocused then return end
        activeItemIndex = activeItemIndex > 0 and activeItemIndex - 1 or #ac.getPitstopSpinners()
end)

ac.setWindowOpen("pitstopStrategyWidget", false)
function script.pitstopStrategyWidget(dt)
        style:pushStyleMain()
        ac.disableQuickMenuPitstop(true)

        ui.drawRectFilled(0, ui.availableSpace(), settings.Appearance.uiColor1 * 0.65)
        ui.drawRectFilled(0, vec2(ui.windowWidth(), 40 * cui.scaleY()), settings.Appearance.uiColor1 * 0.65)

        ui.setCursor(0)

        ui.dwriteTextAligned(
                "PITSTOP",
                20,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), 40 * cui.scaleY())
        )
        ui.offsetCursorY(5)

        local lastSection = ""
        for _, spinner in ipairs(sm._pitSpinners) do
                if spinner.preset == -1 then
                        local value = mfdWidgetSpinner(
                                spinner.name,
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
                                ui.dwriteTextAligned(
                                        spinner.tab,
                                        18,
                                        ui.Alignment.Center,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), 24 * cui.scaleY())
                                )
                        end
                        local value = mfdWidgetSpinner(
                                spinner.nameAlt,
                                spinner.index,
                                spinner.value,
                                spinner.format,
                                spinner.min,
                                spinner.max,
                                spinner.items
                        )
                        spinner:setValue(value)
                        ac.debug(spinner.name, spinner.value)
                end
        end

        if navControlDownButton:pressed() then
                activeItemIndex = activeItemIndex < #ac.getPitstopSpinners() and activeItemIndex + 1 or 0
        end

        if navControlUpButton:pressed() then
                activeItemIndex = activeItemIndex > 0 and activeItemIndex - 1 or #ac.getPitstopSpinners()
        end

        style:popStyleMain()
end
