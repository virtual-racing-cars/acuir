local bindings = {}

require("src.classes.SettingSlider")
local TabBar = require("classes.TabBar")
local controls = require("controls")
local cui = require("ui.cui")
local sim = ac.getSim()
local keys = require("keys")
local controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini")
ac.onControlSettingsChanged(
        function() controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini") end
)

local inputModeStringKeys = {
        "BUTTON",
        "XBOXBUTTON",
        "KEY",
}

controls:initialize()

local margin = 20

local function bindingInUseDialog(button, name, inputMode, inUseBinds)
        cui.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 5

                ui.setCursor(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "Already In Use!",
                        textBoxHeight * 0.5,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                ui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "This bind is already being used by:",
                        textBoxHeight * 0.3,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                local inUseString = ""
                for i, bind in ipairs(inUseBinds) do
                        if i > 1 then
                                inUseString = inUseString .. ", " .. bind.tab .. ":" .. bind.bind
                        else
                                inUseString = bind.tab .. ":" .. bind.bind
                        end
                end

                ui.setCursorX(0)

                cui.snapCursor()
                ui.dwriteTextAligned(
                        inUseString,
                        textBoxHeight * 0.3,
                        nil,
                        ui.Alignment.Start,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                local buttonWidth = (ui.windowWidth() * 0.2) / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth * 1.5 - 10 * cui.uiScale())
                if cui.modalButton("Cancel", buttonWidth, 50 * cui.uiScale(), ui.ButtonFlags.None) then
                        button:clearAssign()

                        ui.popStyleVar(1)
                        return true
                end
                ui.sameLine()
                ui.offsetCursorX(5 * cui.uiScale())

                if cui.modalButton("KEEP ALL", buttonWidth, 50 * cui.uiScale(), ui.ButtonFlags.None) then
                        button:saveBind(inputMode)

                        ui.popStyleVar(1)
                        return true
                end
                ui.sameLine()
                ui.offsetCursorX(5 * cui.uiScale())

                if cui.modalButton("REPLACE OLD", buttonWidth, 50 * cui.uiScale(), ui.ButtonFlags.None) then
                        button:saveBind(inputMode)

                        for _, bind in ipairs(inUseBinds) do
                                controlsINI:setAndSave(bind.bind, inputModeStringKeys[inputMode], -1)
                                controlsINI:setAndSave(bind.bind, inputModeStringKeys[inputMode] .. "_MODIFICATOR", -1)
                        end

                        ui.popStyleVar(1)
                        return true
                end
                ui.sameLine()

                ui.popStyleVar(1)
        end)
end

local function bindingDialog(button, name, inputMode)
        cui.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 5

                local inputPromptString = inputMode < 3 and "Press a Button" or "Press a Key"
                ui.setCursor(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        inputPromptString,
                        textBoxHeight * 0.5,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                ui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "This will assign a control bind for:",
                        textBoxHeight * 0.3,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                ui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        name,
                        textBoxHeight * 0.4,
                        nil,
                        ui.Alignment.Start,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                ui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "Press ESC to cancel",
                        textBoxHeight * 0.4,
                        nil,
                        ui.Alignment.Start,
                        vec2(ui.windowWidth(), textBoxHeight),
                        false,
                        rgbm.colors.red
                )

                if ui.keyPressed(ui.Key.Escape) then
                        button:clearAssign()
                        ui.popStyleVar(1)
                        return true
                end

                local assigned, assignedButton, assignedModificator = button:assignBind(inputMode)

                if assigned then
                        local inUseList = {}
                        for _, bind in pairs(controls.binds) do
                                local controlTab, controlBind = bind.tab, bind.bind
                                local boundButton = controlsINI:get(controlBind, "KEY", -1)
                                local boundModificator = controlsINI:get(controlBind, "KEY_MODIFICATOR", -1)

                                if
                                        controlBind ~= button.bind
                                        and keys.hexIndexList[assignedButton] == boundButton
                                        and assignedModificator == boundModificator
                                then
                                        table.insert(inUseList, bind)
                                        ac.log("Already BOUND!", controlTab, controlBind)
                                end
                        end

                        if #inUseList > 0 then
                                bindingInUseDialog(button, name, inputMode, inUseList)
                        else
                                button:saveBind(inputMode)

                                ui.popStyleVar(1)
                                return true
                        end
                end

                --  then return true end

                ui.popStyleVar(1)
        end)
end

local function bindingBoxes(binding, name, label, button, bind, yOffset)
        ui.setCursorX(20 * cui.uiScale())
        cui.snapCursor()
        ui.dwriteTextAligned(
                name .. " " .. label,
                24 * cui.uiScale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.5, ui.windowHeight() / 22)
        )
        ui.sameLine()

        ui.setCursorX(ui.windowWidth() * 0.5)

        local bindingWidth = (ui.windowWidth() * 0.25)
        local boundDeviceID, buttonID = button:boundTo(3)

        if
                cui.bindingButton(
                        button,
                        3,
                        boundDeviceID,
                        buttonID,
                        vec2(bindingWidth, ui.windowHeight() / 22),
                        ui.ButtonFlags.None
                )
        then
                bindingDialog(button, name .. " " .. label, 3)
        end
        if ui.itemHovered() and ui.mouseClicked(ui.MouseButton.Right) then button:unbind(3) end

        ui.sameLine()

        if sim.inputMode > 1 then return end

        local boundDeviceID, buttonID = button:boundTo(sim.inputMode + 1)

        if
                cui.bindingButton(
                        button,
                        sim.inputMode + 1,
                        boundDeviceID,
                        buttonID,
                        vec2(bindingWidth, ui.windowHeight() / 22),
                        ui.ButtonFlags.None
                )
        then
                bindingDialog(button, name .. " " .. label, sim.inputMode + 1)
        end
        if ui.itemHovered() and ui.mouseClicked(ui.MouseButton.Right) then button:unbind(sim.inputMode + 1) end
end

local function buttonBinder(controlBinding)
        -- helpInfoButton(controlBinding)

        if controlBinding.isActivationBind then
                bindingBoxes(controlBinding, controlBinding.name, "", controlBinding.button, controlBinding.bind)
                return
        end

        if controlBinding.isSequentialBind then
                bindingBoxes(
                        controlBinding,
                        controlBinding.name,
                        controlBinding.buttonUpLabel,
                        controlBinding.buttonUp,
                        controlBinding.bindUp,
                        8
                )
                ui.newLine()
                ui.setCursorX(margin)

                bindingBoxes(
                        controlBinding,

                        controlBinding.name,
                        controlBinding.buttonDownLabel,
                        controlBinding.buttonDown,
                        controlBinding.bindDown,
                        8
                )
        end

        if controlBinding.isMultiPositionSwitchBind then
                for index, button in ipairs(controlBinding.buttonPosition) do
                        ui.newLine()
                        ui.setCursorX(margin)

                        button:setDisabled(false)

                        bindingBoxes(
                                controlBinding,

                                controlBinding.name,
                                controlBinding.buttonPositionLabel[index],
                                button,
                                controlBinding.bindMps[index]
                        )
                end
        end
end

local applicationControlsTabBar = TabBar()
local appsTabBars = {}

local function newSetting(section, id, label, min, max, step, shiftStep, mult, offset, format, unit, help)
        return {
                section = section,
                id = id,
                label = label,
                min = min or 0,
                max = max or 1,
                step = step or 0.01,
                shiftStep = shiftStep or 0.05,
                mult = mult or 100,
                offset = offset or 0,
                format = format or "%.0f %s",
                unit = unit or "%",
                help = help or "",
        }
end

local extraSettings = {}

extraSettings.KEYBOARD = {}

extraSettings.X360 = {
        {
                label = "X360",
                tweaks = {
                        newSetting("STEER_SPEED", "Steer Speed"),
                        newSetting("STEER_GAMMA", "Gamma"),
                        newSetting("STEER_FILTER", "Filter"),
                        newSetting("SPEED_SENSITIVITY", "Speed Sensitivity"),
                        newSetting("STEER_DEADZONE", "Deadzone"),
                        newSetting("RUMBLE_INTENSITY", "Rumble Intensity"),
                },
        },
}

extraSettings.WHEEL = {

        {
                label = "AXIS",
                content = {
                        {
                                group = "Steering",
                                tweaks = {
                                        newSetting("STEER", "STEER_GAMMA", "Steer Gamma", 0.2, 4, 0.01, nil, 100),
                                        newSetting(
                                                "STEER",
                                                "SPEED_SENSITIVITY",
                                                "Steer Sensitivity",
                                                0,
                                                1,
                                                0.01,
                                                nil,
                                                100
                                        ),
                                },
                        },
                        {
                                group = "Others",
                                tweaks = {
                                        newSetting(
                                                "STEER",
                                                "DEBOUNCING_MS",
                                                "Debounce",
                                                0,
                                                200,
                                                1,
                                                nil,
                                                1,
                                                nil,
                                                nil,
                                                "ms"
                                        ),
                                        newSetting("THROTTLE", "GAMMA", "Throttle Gamma", 0.01, 5, 0.01, nil, 100),
                                        newSetting("BRAKES", "GAMMA", "Brake Gamma", 0.01, 5, 0.01, nil, 100),
                                        newSetting("CLUTCH", "GAMMA", "Clutch Gamma", 0.01, 5, 0.01, nil, 100),
                                        newSetting("HANDBRAKE", "GAMMA", "Handbrake Gamma", 0.01, 5, 0.01, nil, 100),
                                },
                        },
                },
        },
        {
                label = "FFB",
                content = {
                        {
                                group = "FFB",
                                tweaks = {
                                        newSetting("STEER", "FF_GAIN", "FFB Gain", 0, 2, 0.01, nil, 100),
                                        newSetting("STEER", "FF_DAMPER", "FFB Damper"),
                                        newSetting(
                                                "FF_SKIP_STEPS",
                                                "VALUE",
                                                "FFB Skip",
                                                0,
                                                10,
                                                1,
                                                1,
                                                1,
                                                nil,
                                                nil,
                                                "steps"
                                        ),
                                },
                        },
                        {
                                group = "FFB Tweaks",
                                tweaks = {
                                        newSetting("FF_TWEAKS", "MIN_FF", "Minimum Force", 0, 1, 0.01, nil, 100),
                                        newSetting(
                                                "FF_TWEAKS",
                                                "CENTER_BOOST_GAIN",
                                                "Center Boost Gain",
                                                0,
                                                10,
                                                0.01,
                                                nil,
                                                100
                                        ),
                                        newSetting(
                                                "FF_TWEAKS",
                                                "CENTER_BOOST_RANGE",
                                                "Center Boost Range",
                                                0,
                                                1,
                                                0.01,
                                                nil,
                                                100
                                        ),
                                },
                        },
                        {
                                group = "FFB Enhancements",
                                tweaks = {
                                        newSetting("FF_ENHANCEMENT", "CURBS", "Curbs", 0, 2, 0.01, nil, 100),
                                        newSetting("FF_ENHANCEMENT", "ROAD", "Road", 0, 2, 0.01, nil, 100),
                                        newSetting("FF_ENHANCEMENT", "SLIPS", "Slips", 0, 2, 0.01, nil, 100),
                                        newSetting("FF_ENHANCEMENT", "ABS", "ABS", 0, 2, 0.01, nil, 100),
                                },
                        },
                },
        },
}

controlsINI:setAndSave("STEER", "AXLE", 1)
ac.reloadControlSettings()

local currentSection = 1

function bindings:draw()
        cui.pushWindow("settings_button_bind_tabbar", 0, 0, ui.windowWidth() * 0.25, ui.windowHeight(), false)
        ui.setCursor(0)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm.colors.black)
        local app = applicationControlsTabBar:draw(controls.tabs)
        cui.popWindow()

        cui.pushWindow(
                "settings_button_binds_window2",
                ui.windowWidth() * 0.25,
                0,
                ui.windowWidth() * 0.5,
                ui.windowHeight(),
                false
        )

        ui.setCursorY(0)
        ui.setCursorX(ui.windowWidth() * 0.5)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Keyboard",
                24 * cui.uiScale(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.25, 50 * cui.uiScale())
        )
        ui.sameLine()
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Controllers",
                24 * cui.uiScale(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.25, 50 * cui.uiScale())
        )

        cui.pushWindow(
                "settings_button_binds_window3",
                0,
                ui.windowHeight() / 22,
                ui.windowWidth(),
                ui.windowHeight() - ui.windowHeight() / 22,
                true
        )

        -- ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm.colors.black)

        if not appsTabBars[app.name] then appsTabBars[app.name] = TabBar() end

        ui.setCursor(0)
        for _, tab in ipairs(app.tabs) do
                ui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        tab.name,
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 50 * cui.uiScale())
                )

                for _, controlBinding in pairs(tab.content) do
                        buttonBinder(controlBinding)
                        ui.newLine()
                end
        end

        cui.popWindow(true)
        cui.popWindow()

        cui.pushWindow(
                "settings_controls_ffb",
                ui.windowWidth() * 0.75,
                0,
                ui.windowWidth() * 0.25,
                ui.windowHeight(),
                false
        )

        ui.setCursor(0)

        local deviceTabs = extraSettings[controlsINI:get("HEADER", "INPUT_METHOD", "WHEEL")]
        for i, tab in ipairs(deviceTabs) do
                if
                        cui.menuButton(
                                tab.label,
                                vec2(ui.windowWidth() / #deviceTabs, 50),
                                0,
                                0,
                                0,
                                currentSection == i,
                                false
                        )
                then
                        currentSection = i
                end
                ui.sameLine()
        end

        cui.pushWindow(
                "settings_controls_ffb",
                0,
                50 * cui.uiScale(),
                ui.windowWidth(),
                ui.windowHeight() - 50 * cui.uiScale(),
                true
        )
        ui.setCursor(0)
        ui.offsetCursorY(20)

        if currentSection == 2 then
                ui.setCursorX(ui.windowWidth() / 2 - 600 * cui.uiScale() / 2)
                local value, changed, active, hovered = drawSettingsSpinner(
                        "CAR.FFB",
                        "Car FFB Gain",
                        620 * cui.uiScale(),
                        40 * cui.uiScale(),
                        false,
                        ac.getCar(0).ffbMultiplier,
                        {
                                section = "CAR",
                                id = "CARFFB",
                                label = "Car FFB",
                                min = 0,
                                max = 2,
                                step = 0.01,
                                shiftStep = 1,
                                mult = 100,
                                offset = 0,
                                format = "%.0f %s",
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed or active then ac.setFFBMultiplier(value) end
        end
        ui.offsetCursorY(20)

        local i = 0
        for _, tweakSection in
                ipairs(extraSettings[controlsINI:get("HEADER", "INPUT_METHOD", "WHEEL")][currentSection].content)
        do
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        tweakSection.group,
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 48 * cui.uiScale())
                )

                for _, tweak in ipairs(tweakSection.tweaks) do
                        ui.setCursorX(ui.windowWidth() / 2 - 600 * cui.uiScale() / 2)

                        local value, changed, active, hovered = drawSettingsSpinner(
                                tweak.section .. tweak.id,
                                tweak.label,
                                620 * cui.uiScale(),
                                40 * cui.uiScale(),
                                false,
                                controlsINI:get(tweak.section, tweak.id, 0),
                                tweak,
                                false
                        )

                        if changed or active then
                                controlsINI:setAndSave(tweak.section, tweak.id, value)
                                ac.reloadControlSettings()
                        end

                        i = i + 1

                        ui.offsetCursorY(20)
                end
        end
        cui.popWindow(true)

        cui.popWindow()
end

return bindings
