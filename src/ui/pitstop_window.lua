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
local function mfdWidgetSpinner(name, height, index, value, format, min, max, items)
        local buttonSize = height

        ui.invisibleButton("##pswidget" .. name .. index, vec2(ui.windowWidth(), buttonSize))
        local hovered = ui.itemHovered()
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
                vec2(ui.windowWidth() / 3, buttonSize)
        )
        ui.sameLine()
        ui.setCursorX(ui.windowWidth() / 2 - ui.windowWidth() / 12)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "< >",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 6, buttonSize)
        )

        local displayValue = items and items[value + 1] or string.format(format, value)
        ui.sameLine()
        cui.snapCursor()
        ui.dwriteTextAligned(
                displayValue,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX(), buttonSize)
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
        if not quickPitMenuFocused then return end
        activeItemIndex = activeItemIndex > 0 and activeItemIndex - 1 or #ac.getPitstopSpinners()
end)

local car = ac.getCar(0)
local carINI = ac.INIConfig.carData(0, "car.ini")
local setupINI = ac.INIConfig.carData(0, "setup.ini")
local pitstopTimes = {
        FUEL = {
                stepTime = carINI:get("PIT_STOP", "FUEL_LITER_TIME_SEC", 0),
                time = function(addFuel, stepTime)
                        return (addFuel + math.min(car.maxFuel - (car.fuel + addFuel), 0)) * stepTime
                end,
        },
        COMPOUND = {
                stepTime = carINI:get("PIT_STOP", "TYRE_CHANGE_TIME_SEC", 0),
                time = function(compound, stepTime) return compound >= 0 and stepTime or 0 end,
        },
        WING_1 = {
                stepTime = setupINI:get("WING_1", "PITSTOP", 0),
                time = function(offset, stepTime) return offset ~= 0 and stepTime or 0 end,
        },
        WING_2 = {
                stepTime = setupINI:get("WING_2", "PITSTOP", 0),
                time = function(offset, stepTime) return offset ~= 0 and stepTime or 0 end,
        },
        REPAIR_BODY = {
                stepTime = carINI:get("PIT_STOP", "BODY_REPAIR_TIME_SEC", 0),
                time = function(repair, stepTime)
                        if repair == 0 then return 0 end

                        local totalBodyDamage = 0
                        for i = 0, 3 do
                                totalBodyDamage = totalBodyDamage + car.damage[i] * 100
                        end

                        return totalBodyDamage / 10 * stepTime
                end,
        },
        REPAIR_ENGINE = {
                stepTime = carINI:get("PIT_STOP", "ENGINE_REPAIR_TIME_SEC", 0),
                time = function(repair, stepTime)
                        return repair == 1 and (1000 - car.engineLifeLeft) / 100 * stepTime or 0
                end,
        },
        REPAIR_SUSPENSION = {
                stepTime = carINI:get("PIT_STOP", "SUSP_REPAIR_TIME_SEC", 0),
                time = function(repair, stepTime)
                        if repair == 0 then return 0 end

                        local totalSuspensionDamage = 0
                        for i = 0, 3 do
                                totalSuspensionDamage = totalSuspensionDamage + car.wheels[i].suspensionDamage * 100
                        end

                        return totalSuspensionDamage / 10 * stepTime
                end,
        },
}

ac.setWindowOpen("pitstopStrategyWidget", quickPitMenuFocused)
ac.disableQuickMenuPitstop(true)
function script.pitstopStrategyWidget(dt)
        local itemCount = #ac.getPitstopSpinners() <= 9 and #ac.getPitstopSpinners() + 7 or #ac.getPitstopSpinners() + 8
        local itemHeight = 32 * cui.scaleY()
        local windowHeight = itemHeight * itemCount
        local fontSize = math.floor(itemHeight * 0.8)
        fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize

        ui.beginToolWindow("toolWindowTest", ui.cursorScreenPos(), vec2(itemHeight * 14, windowHeight), true, true)
        style:pushStyleMain()
        ac.disableQuickMenuPitstop(true)

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

        local pitstopTimeEstimate = 0
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
                                spinner.items
                        )
                        spinner:setValue(value)

                        local timeSlot = pitstopTimes[spinner.id]

                        if timeSlot then
                                pitstopTimeEstimate = pitstopTimeEstimate
                                        + timeSlot.time(spinner.value, timeSlot.stepTime)
                        end
                end
        end
        ui.dummy(itemHeight)

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Estimated Stop Time: %.1f s" % pitstopTimeEstimate,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), fontSize)
        )

        style:popStyleMain()

        ui.endToolWindow()
        ui.setCursor(vec2(400, 500) * cui.scaleY())
end
