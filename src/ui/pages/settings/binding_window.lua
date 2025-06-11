local bindings = {}

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

local gamepadAxisList = {
        [0] = "L2",
        [1] = "R2",
        [2] = "Left stick (Y+)",
        [3] = "Left stick (Y−)",
        [4] = "Right stick (Y+)",
        [5] = "Right stick (Y−)",
        [6] = "Left stick (X+)",
        [7] = "Left stick (X−)",
        [8] = "Right stick (X+)",
        [9] = "Right stick (X−)",
}

local yesNoList = {
        [0] = "No",
        [1] = "Yes",
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

        local boundDeviceID, buttonID = button:boundTo(sim.inputMode + 1)

        if
                cui.bindingButton(
                        button,
                        sim.inputMode + 1,
                        boundDeviceID,
                        buttonID,
                        vec2(bindingWidth, ui.windowHeight() / 22),
                        sim.inputMode > 1 and ui.ButtonFlags.Disabled or ui.ButtonFlags.None
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

local function newSetting(setting)
        return {
                cfg = setting.cfg or controls.cfg.controls,
                section = setting.section,
                id = setting.id,
                label = setting.label,
                min = setting.min or 0,
                max = setting.max or 1,
                step = setting.step or 0.01,
                shiftStep = setting.shiftStep or 0.05,
                multiplier = setting.multiplier or 100,
                offset = setting.offset or 0,
                format = setting.format or "%.0f %s",
                unit = setting.unit or "%",
                help = setting.help or "",
                graph = setting.graph or false,
                items = setting.items or nil,
        }
end

local extraSettings = {}

extraSettings.KEYBOARD = {
        {
                label = "KEYBOARD TWEAKS",
                content = {
                        {
                                group = "Keyboard Steering",
                                tweaks = {
                                        newSetting({
                                                section = "KEYBOARD",
                                                id = "STEERING_SPEED",
                                                label = "Speed",
                                                min = 0,
                                                max = 4,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "KEYBOARD",
                                                id = "STEERING_OPPOSITE_DIRECTION_SPEED",
                                                label = "Opp. Direction Speed",
                                                min = 0,
                                                max = 4,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "KEYBOARD",
                                                id = "STEER_RESET_SPEED",
                                                label = "Reset Speed",
                                                min = 0,
                                                max = 4,
                                                multiplier = 100,
                                        }),
                                },
                        },
                        {
                                group = "Mouse Steering",
                                tweaks = {
                                        newSetting({
                                                section = "KEYBOARD",
                                                id = "MOUSE_STEER",
                                                label = "Mouse Steering",
                                                min = 0,
                                                max = 1,
                                                step = 1,
                                                multiplier = 1,
                                                items = yesNoList,
                                        }),
                                        newSetting({
                                                section = "KEYBOARD",
                                                id = "MOUSE_ACCELERATOR_BRAKE",
                                                label = "Mouse Accel. and Brake",
                                                min = 0,
                                                max = 1,
                                                step = 1,
                                                multiplier = 1,
                                                items = yesNoList,
                                        }),
                                        newSetting({
                                                cfg = controls.cfg.cspGeneral,
                                                section = "CONTROL",
                                                id = "NO_MOUSE_STEERING_FOR_INACTIVE",
                                                label = "No mouse steer in background",
                                                min = 0,
                                                max = 1,
                                                step = 1,
                                                multiplier = 1,
                                                items = yesNoList,
                                        }),
                                        newSetting({
                                                section = "KEYBOARD",
                                                id = "MOUSE_SPEED",
                                                label = "Speed",
                                                min = 0,
                                                max = 3,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "__EXT_KEYBOARD",
                                                id = "SHIFT_WITH_WHEEL",
                                                label = "Shift gears with mouse wheel",
                                                min = 0,
                                                max = 1,
                                                step = 1,
                                                multiplier = 1,
                                                items = yesNoList,
                                        }),
                                        newSetting({
                                                section = "__EXT_KEYBOARD",
                                                id = "SHIFT_WITH_XBUTTONS",
                                                label = "Shift with 4th and 5th buttons",
                                                min = 0,
                                                max = 1,
                                                step = 1,
                                                multiplier = 1,
                                                items = yesNoList,
                                        }),
                                },
                        },
                        {
                                group = "Forced Throttle",
                                tweaks = {
                                        newSetting({
                                                section = "__EXT_KEYBOARD_GAS_RAW",
                                                id = "OVERRIDE",
                                                label = "Enable Forced Throttle",
                                                min = 0,
                                                max = 1,
                                                step = 1,
                                                multiplier = 1,
                                                items = yesNoList,
                                        }),
                                        newSetting({
                                                section = "__EXT_KEYBOARD_GAS_RAW",
                                                id = "LAG_UP",
                                                label = "Filter (up)",
                                                min = 0,
                                                max = 0.99,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "__EXT_KEYBOARD_GAS_RAW",
                                                id = "LAG_DOWN",
                                                label = "Filter (down)",
                                                min = 0,
                                                max = 0.99,
                                                multiplier = 100,
                                        }),
                                },
                        },
                },
        },
}

extraSettings.X360 = {
        {
                label = "GAMEPAD TWEAKS",
                content = {
                        {
                                group = "Steering",
                                tweaks = {
                                        newSetting({
                                                section = "X360",
                                                id = "STEER_SPEED",
                                                label = "Speed",
                                                min = 0,
                                                max = 2,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "X360",
                                                id = "STEER_GAMMA",
                                                label = "Gamma",
                                                min = 1,
                                                max = 5,
                                                multiplier = 100,
                                                graph = true,
                                        }),
                                        newSetting({
                                                section = "X360",
                                                id = "STEER_FILTER",
                                                label = "Filter",
                                                min = 0,
                                                max = 1,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "X360",
                                                id = "SPEED_SENSITIVITY",
                                                label = "Speed Sensitivity",
                                                min = 0,
                                                max = 1,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "X360",
                                                id = "STEER_DEADZONE",
                                                label = "Deadzone",
                                                min = 0,
                                                max = 1,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "X360",
                                                id = "RUMBLE_INTENSITY",
                                                label = "Rumble Intensity",
                                                min = 0,
                                                max = 1,
                                                multiplier = 100,
                                        }),
                                },
                        },
                        {
                                group = "Tweaks",
                                tweaks = {
                                        newSetting({
                                                section = "X360",
                                                id = "AXIS_REMAP_THROTTLE",
                                                label = "Remap Throttle",
                                                min = 0,
                                                step = 1,
                                                max = #gamepadAxisList - 1,
                                                multiplier = 1,
                                                items = gamepadAxisList,
                                        }),
                                        newSetting({
                                                section = "X360",
                                                id = "AXIS_REMAP_BRAKES",
                                                label = "Remap Brakes",
                                                min = 0,
                                                step = 1,
                                                max = #gamepadAxisList - 1,
                                                multiplier = 1,
                                                items = gamepadAxisList,
                                        }),
                                },
                        },
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
                                        newSetting({
                                                section = "STEER",
                                                id = "SPEED_SENSITIVITY",
                                                label = "Steer Sensitivity",
                                        }),
                                        newSetting({
                                                section = "STEER",
                                                id = "STEER_GAMMA",
                                                label = "Steer Gamma",
                                                min = 0.2,
                                                max = 4,
                                                multiplier = 100,
                                                graph = true,
                                        }),
                                },
                        },
                        {
                                group = "Others",
                                tweaks = {

                                        newSetting({
                                                section = "THROTTLE",
                                                id = "GAMMA",
                                                label = "Throttle Gamma",
                                                min = 0.01,
                                                max = 5,
                                                step = 0.01,
                                                multiplier = 100,
                                                graph = true,
                                        }),
                                        newSetting({
                                                section = "BRAKES",
                                                id = "GAMMA",
                                                label = "Brake Gamma",
                                                min = 0.01,
                                                max = 5,
                                                step = 0.01,
                                                multiplier = 100,
                                                graph = true,
                                        }),
                                        newSetting({
                                                section = "CLUTCH",
                                                id = "GAMMA",
                                                label = "Clutch Gamma",
                                                min = 0.01,
                                                max = 5,
                                                step = 0.01,
                                                multiplier = 100,
                                                graph = true,
                                        }),
                                        newSetting({
                                                section = "HANDBRAKE",
                                                id = "GAMMA",
                                                label = "Handbrake Gamma",
                                                min = 0.01,
                                                max = 5,
                                                step = 0.01,
                                                multiplier = 100,
                                                graph = true,
                                        }),

                                        newSetting({
                                                section = "STEER",
                                                id = "DEBOUNCING_MS",
                                                label = "Debounce",
                                                min = 0,
                                                max = 200,
                                                step = 1,
                                                multiplier = 1,
                                                unit = "ms",
                                        }),
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
                                        newSetting({
                                                section = "STEER",
                                                id = "FF_GAIN",
                                                label = "Gain",
                                                min = 0,
                                                max = 2,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                        newSetting({ section = "STEER", id = "FILTER_FF", label = "Filter" }),
                                        newSetting({
                                                section = "FF_SKIP_STEPS",
                                                id = "VALUE",
                                                label = "Skip Steps",
                                                min = 0,
                                                max = 10,
                                                step = 1,
                                                multiplier = 1,
                                                unit = "steps",
                                        }),
                                },
                        },
                        {
                                group = "FFB Tweaks",
                                tweaks = {
                                        newSetting({
                                                section = "FF_TWEAKS",
                                                id = "MIN_FF",
                                                label = "Minimum Force",
                                                min = 0,
                                                max = 1,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "FF_TWEAKS",
                                                id = "CENTER_BOOST_GAIN",
                                                label = "Center Boost Gain",
                                                min = 0,
                                                max = 10,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "FF_TWEAKS",
                                                id = "CENTER_BOOST_RANGE",
                                                label = "Center Boost Range",
                                                min = 0,
                                                max = 1,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                },
                        },

                        {
                                group = "FFB Enhancements",
                                tweaks = {
                                        newSetting({
                                                section = "FF_ENHANCEMENT",
                                                id = "CURBS",
                                                label = "Curbs",
                                                min = 0,
                                                max = 2,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "FF_ENHANCEMENT",
                                                id = "ROAD",
                                                label = "Road",
                                                min = 0,
                                                max = 2,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "FF_ENHANCEMENT",
                                                id = "SLIPS",
                                                label = "Slips",
                                                min = 0,
                                                max = 2,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                        newSetting({
                                                section = "FF_ENHANCEMENT",
                                                id = "ABS",
                                                label = "ABS",
                                                min = 0,
                                                max = 2,
                                                step = 0.01,
                                                multiplier = 100,
                                        }),
                                        -- newSetting({
                                        --         section = "FF_ENHANCEMENT_2",
                                        --         id = "UNDERSTEER",
                                        --         label = "Understeer",
                                        --         min = 0,
                                        --         max = 2,
                                        --         step = 0.01,
                                        --         multiplier = 100,
                                        -- }),
                                },
                        },
                        -- {
                        --         group = "Low Speed FFB Reduction",
                        --         tweaks = {
                        --                 newSetting({
                        --                         cfg = controls.cfg.system,
                        --                         section = "LOW_SPEED_FF",
                        --                         id = "SPEED_KMH",
                        --                         label = "Speed Threshold",
                        --                         min = 0,
                        --                         max = 30,
                        --                         step = 1,
                        --                         multiplier = 1,
                        --                         unit = "km/h",
                        --                 }),
                        --                 newSetting({
                        --                         cfg = controls.cfg.system,
                        --                         section = "LOW_SPEED_FF",
                        --                         id = "MIN_VALUE",
                        --                         label = "Min. Level",
                        --                         min = 0,
                        --                         max = 2,
                        --                         step = 0.01,
                        --                         multiplier = 100,
                        --                 }),
                        --         },
                        -- },

                        -- {
                        --         group = "FFB Damper",
                        --         tweaks = {
                        --                 newSetting({
                        --                         cfg = controls.cfg.system,
                        --                         section = "FF_EXPERIMENTAL",
                        --                         id = "DAMPER_GAIN",
                        --                         label = "Gain",
                        --                         min = 0,
                        --                         max = 2,
                        --                         step = 0.01,
                        --                         multiplier = 100,
                        --                 }),
                        --                 newSetting({
                        --                         cfg = controls.cfg.system,
                        --                         section = "FF_EXPERIMENTAL",
                        --                         id = "DAMPER_MIN_LEVEL",
                        --                         label = "Min. Level",
                        --                         min = 0,
                        --                         max = 2,
                        --                         step = 0.01,
                        --                         multiplier = 100,
                        --                 }),
                        --         },
                        -- },
                },
        },
}

controlsINI:setAndSave("STEER", "AXLE", 1)

-- The following curve based stuff was written originally by Ilja for Controller Tweaks
local function drawCurveBase(size)
        cui.offsetCursorY(10)
        local from, range = ui.getCursor(), size:clone()
        ui.dummy(range)
        ui.drawRectFilled(from, from + range, rgbm(0.1, 0.1, 0.1, 0.5))
        from.y, range.y = from.y + range.y, -range.y
        cui.offsetCursorY(20)
        return from, range
end

local function drawGammaCurve(value, label)
        ui.setCursorX(ui.windowWidth() * 0.1)
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.2))
        for i = 0, 30 do
                local x = (i / 30) ^ 2
                ui.pathLineTo(f + vec2(x, x ^ value) * s)
        end
        ui.pathStroke(ac.getUI().accentColor, false, 3)
end

local function drawGamepadGammaCurve()
        ui.setCursorX(ui.windowWidth() * 0.1)
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.2))
        local b = ac.getGamepadAxisValue(
                0,
                controls.cfg.controls.data.X360.STEER_THUMB == "LEFT" and ac.GamepadAxis.LeftThumbX
                        or ac.GamepadAxis.RightThumbX
        )
        local relSteer = ac.getCar(0).steer / 396
        ui.drawLine(
                f + vec2(0, (0.5 + 0.5 * relSteer) * s.y),
                f + vec2(s.x, (0.5 + 0.5 * relSteer) * s.y),
                rgbm.colors.gray,
                2
        )
        ui.drawLine(f + vec2((0.5 + 0.5 * b) * s.x, 0), f + vec2((0.5 + 0.5 * b) * s.x, s.y), rgbm.colors.gray, 2)

        local v = controls.cfg.controls.data.X360.STEER_GAMMA
        if v == 0 then v = 1 end
        for i0 = 0, 1 do
                for i = 0, 30 do
                        local x = (i / 30) ^ 2
                        if i0 == 1 then
                                ui.pathLineTo(f + vec2(0.5 + 0.5 * x, 0.5 + 0.5 * x ^ v) * s)
                        else
                                ui.pathLineTo(f + vec2(0.5 - 0.5 * x, 0.5 - 0.5 * x ^ v) * s)
                        end
                end
                ui.pathStroke(ac.getUI().accentColor, false, 3)
        end
end

local curves = {}
local curvesCache = {}

local function loadCurve(curve) return ac.DataLUT11.load(ac.getFolder(ac.FolderID.Cfg) .. "\\" .. curve) end

local function drawCurve(curve, label)
        ui.setCursorX(ui.windowWidth() * 0.1)
        local c = table.getOrCreate(curvesCache, curve, loadCurve, curve)
        if not c then
                ui.text("Curve is missing or damaged")
                return
        end
        local f, s = drawCurveBase(vec2(ui.windowWidth() * 0.8, ui.windowWidth() * 0.8))
        for i = 0, 30 do
                ui.pathLineTo(f + vec2(i / 30, c:get(i / 30)) * s)
        end
        ui.pathStroke(ac.getUI().accentColor, false, 5)
end

local function reloadCurves()
        curves = io.scanDir(ac.getFolder(ac.FolderID.Cfg), "*.lut")
        if
                controls.cfg.ffPostProcess.data.LUT.CURVE
                and not table.indexOf(curves, controls.cfg.ffPostProcess.data.LUT.CURVE)
        then
                table.insert(curves, controls.cfg.ffPostProcess.data.LUT.CURVE)
        end
        if
                controls.cfg.ffPostProcess.original.LUT.CURVE
                and not table.indexOf(curves, controls.cfg.ffPostProcess.original.LUT.CURVE)
        then
                table.insert(curves, controls.cfg.ffPostProcess.original.LUT.CURVE)
        end
        table.sort(curves, function(a, b) return a < b end)
        table.clear(curvesCache)
end
reloadCurves()

local currentSection = 1

local drawGraphCallback
local drawGraphCallbackTimeoutID

function bindings:draw()
        cui.pushWindow("settings_button_bind_tabbar", 0, 0, ui.windowWidth() * 0.25, ui.windowHeight(), false)
        ui.setCursor(0)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm.colors.black * 0.25)
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
                                vec2(ui.windowWidth() / #deviceTabs, 50 * cui.uiScale()),
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
                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "CAR.FFB",
                        "Car FFB Gain",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
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
                                multiplier = 100,
                                offset = 0,
                                format = "%.0f %s",
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed or active then ac.setFFBMultiplier(value) end
        end

        for _, tweakSection in
                ipairs(extraSettings[controlsINI:get("HEADER", "INPUT_METHOD", "WHEEL")][currentSection].content)
        do
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        tweakSection.group,
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.uiScale())
                )

                for _, tweak in ipairs(tweakSection.tweaks) do
                        ui.setCursorX(ui.windowWidth() * 0.01)

                        local oldValue = tweak.cfg:get(tweak.section, tweak.id)

                        if tweak.items then tweak.format = tweak.items[oldValue] end

                        local value, changed, active, hovered = drawSpinner(
                                tweak.section .. tweak.id,
                                tweak.label,
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
                                false,
                                oldValue,
                                tweak,
                                true
                        )

                        if changed then tweak.cfg:set(tweak.section, tweak.id, value) end

                        if tweak.graph then
                                if sim.inputMode == ac.UserInputMode.Gamepad then
                                        drawGamepadGammaCurve()
                                else
                                        drawGammaCurve(value)
                                end
                        end
                end
        end

        if currentSection == 2 then
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "FFB Gyro",
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.uiScale())
                )

                local currentGyroMode = (
                        controls.cfg.ffbTweaks.data.BASIC.ENABLED
                                and controls.cfg.ffbTweaks.data.GYRO2.ENABLED
                                and 3
                        or controls.cfg.system.data.FF_EXPERIMENTAL.ENABLE_GYRO and 2
                        or 1
                )
                local gyroStrings = controls.cfg.ffbTweaks.data.BASIC.ENABLED and { "None", "Standard", "FFB Tweaks" }
                        or { "None", "Standard" }

                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "GYRO.GYRO",
                        "Range compression",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
                        false,
                        currentGyroMode,
                        {
                                min = 1,
                                max = #gyroStrings,
                                step = 1,
                                shiftStep = 1,
                                multiplier = 1,
                                offset = 0,
                                format = gyroStrings[currentGyroMode],
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed then
                        controls.cfg.system:set("FF_EXPERIMENTAL", "ENABLE_GYRO", value == 2)
                        controls.cfg.ffbTweaks:set("GYRO2", "ENABLED", value == 3)
                end
        end

        if controls.cfg.ffbTweaks.data.BASIC.ENABLED and currentSection == 2 then
                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "FFB Post-Processing",
                        24 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), 36 * cui.uiScale())
                )

                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "POSTPROCESSING.RANGE_COMPRESSION",
                        "Range compression",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
                        false,
                        controls.cfg.ffbTweaks:get("POSTPROCESSING", "RANGE_COMPRESSION"),
                        {
                                min = 0.5,
                                max = 4,
                                step = 0.01,
                                shiftStep = 1,
                                multiplier = 100,
                                offset = 0,
                                format = "%.0f %s",
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed then controls.cfg.ffbTweaks:set("POSTPROCESSING", "RANGE_COMPRESSION", value) end

                if controls.cfg.ffbTweaks.data.POSTPROCESSING.RANGE_COMPRESSION ~= 1 then
                        ui.setCursorX(ui.windowWidth() * 0.01)
                        local value, changed, active, hovered = drawSpinner(
                                "POSTPROCESSING.RANGE_COMPRESSION_ASSIST",
                                "Use Car Steer Assist",
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
                                false,
                                controls.cfg.ffbTweaks:get("POSTPROCESSING", "RANGE_COMPRESSION_ASSIST"),
                                {
                                        min = 0,
                                        max = 1,
                                        step = 1,
                                        shiftStep = 1,
                                        multiplier = 1,
                                        offset = 0,
                                        format = controls.cfg.ffbTweaks:get(
                                                "POSTPROCESSING",
                                                "RANGE_COMPRESSION_ASSIST"
                                        )
                                                                == 1
                                                        and "Yes"
                                                or "No",
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed then
                                controls.cfg.ffbTweaks:set("POSTPROCESSING", "RANGE_COMPRESSION_ASSIST", value)
                        end
                end
        end

        if false then --currentSection == 2 then
                local currentPPMode = controls.cfg.ffPostProcess.data.HEADER.ENABLED
                                and (controls.cfg.ffPostProcess.data.HEADER.TYPE == "GAMMA" and 2 or 3)
                        or 1

                local ppModeStrings = { "Disabled", "Gamma", "LUT" }
                ui.setCursorX(ui.windowWidth() * 0.01)
                local value, changed, active, hovered = drawSpinner(
                        "PP.MODE",
                        "Post-Process Mode",
                        ui.windowWidth() * 0.98,
                        80 * cui.uiScale(),
                        false,
                        currentPPMode,
                        {
                                min = 1,
                                max = #ppModeStrings,
                                step = 1,
                                shiftStep = 1,
                                multiplier = 1,
                                offset = 0,
                                format = ppModeStrings[currentPPMode],
                                unit = "%",
                                help = "",
                        },
                        true
                )

                if changed then
                        currentPPMode = value
                        controls.cfg.ffPostProcess:set("HEADER", "ENABLED", currentPPMode ~= 1)
                        if currentPPMode ~= 1 then
                                controls.cfg.ffPostProcess:set(
                                        "HEADER",
                                        "TYPE",
                                        currentPPMode == 2 and "GAMMA" or "LUT"
                                )
                        end
                end

                if currentPPMode == 2 then
                        ui.setCursorX(ui.windowWidth() * 0.01)
                        local value, changed, active, hovered = drawSpinner(
                                "PP.GAMMA.VALUE",
                                "Gamma",
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
                                false,
                                controls.cfg.ffPostProcess:get("GAMMA", "VALUE"),
                                {
                                        min = 0.3,
                                        max = 3,
                                        step = 0.01,
                                        shiftStep = 0.01,
                                        multiplier = 100,
                                        offset = 0,
                                        format = "%.0f %s",
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed then controls.cfg.ffPostProcess:set("GAMMA", "VALUE", value) end

                        drawGammaCurve(
                                controls.cfg.ffPostProcess.data.GAMMA.VALUE,
                                "Decrease above 100% to boost smaller forces, increase above 100% to attenuate smaller forces:"
                        )
                elseif currentPPMode == 3 then
                        -- ui.alignTextToFramePadding()
                        -- ui.text("Curve:")
                        -- ui.sameLine(68)
                        -- ui.setNextItemWidth(ui.availableSpaceX() - 24)
                        -- ui.combo("##ppFile", cfgFFPostProcess.data.LUT.CURVE or "None", function()
                        --         for i = 1, #curves do
                        --                 if ui.selectable(curves[i], curves[i] == cfgFFPostProcess.data.LUT.CURVE) then
                        --                         cfgFFPostProcess:set("LUT", "CURVE", curves[i])
                        --                 end
                        --                 if ui.itemHovered() then ui.tooltip(function() drawCurve(curves[i]) end) end
                        --         end
                        --         ui.separator()
                        --         if ui.selectable("Add new curve from LUT…") then importNewCurve() end
                        --         if ui.itemHovered() then
                        --                 ui.setTooltip(
                        --                         "Select a LUT file and it will be copied to “Documents/Assetto Corsa/cfg” and selected"
                        --                 )
                        --         end
                        --         if ui.selectable("Create new curve using WheelCheck…") then
                        --                 ac.setWindowOpen("createLUT", true)
                        --         end
                        --         if ui.itemHovered() then
                        --                 ui.setTooltip("Create new curve for your steering wheel using WheelCheck")
                        --         end
                        -- end)

                        local currentCurve = controls.cfg.ffPostProcess.data.LUT.CURVE or curves[1]
                        local currentCurveIndex = 2

                        for i = 1, #curves do
                                if curves[i] == currentCurve then currentCurveIndex = i end
                        end

                        ui.setCursorX(ui.windowWidth() * 0.01)
                        local value, changed, active, hovered = drawSpinner(
                                "LUT.CURVES",
                                "Curves ( %s )" % #curves,
                                ui.windowWidth() * 0.98,
                                80 * cui.uiScale(),
                                false,
                                currentCurveIndex,
                                {
                                        min = 1,
                                        max = #curves,
                                        step = 1,
                                        shiftStep = 1,
                                        multiplier = 1,
                                        offset = 0,
                                        format = curves[currentCurveIndex],
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed then
                                currentCurveIndex = value
                                controls.cfg.ffPostProcess:set("LUT", "CURVE", curves[currentCurveIndex])
                        end

                        drawCurve(curves[currentCurveIndex])
                else
                        ui.dummy(ui.windowWidth() * 0.8 + 118 * cui.uiScale())
                end
        end

        cui.popWindow(true)

        cui.popWindow()
end

return bindings
