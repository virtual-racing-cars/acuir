local TabBar = require("classes.TabBar")
local configs = require("configs")
local controls = require("controls")
local cui = require("ui.cui")
local keys = require("keys")
local settings = require("settings")
local sim = ac.getSim()

local inputModeStringKeys = {
        "BUTTON",
        "XBOXBUTTON",
        "KEY",
}

local bindings = {}

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
                                inUseString = inUseString .. ", " .. bind.bind
                        else
                                inUseString = bind.bind
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
                                bind:unbind(inputMode)
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

                local assigned, assignedJoy, assignedButton, assignedJoyModificator, assignedModificator =
                        button:assignBind(inputMode)

                if not assigned then
                        ui.popStyleVar(1)

                        return false
                end

                local inUseList = {}

                if inputMode == 1 then
                        for bindButton in controls:iterate() do
                                local controlBind = bindButton.bind
                                local boundJoy = configs.CONTROLS.ini:get(controlBind, "JOY", -1)
                                local boundButton = configs.CONTROLS.ini:get(controlBind, "BUTTON", -1)
                                local boundJoyModificator = configs.CONTROLS.ini:get(controlBind, "JOY_MODIFICATOR", -1)
                                local boundModificator = configs.CONTROLS.ini:get(controlBind, "BUTTON_MODIFICATOR", {})

                                if tonumber(boundModificator[1]) == -1 then boundModificator[1] = nil end

                                if
                                        controlBind ~= button.bind
                                        and tonumber(assignedJoy) == tonumber(boundJoy)
                                        and tonumber(assignedButton) == tonumber(boundButton)
                                        and tonumber(assignedJoyModificator) == tonumber(boundJoyModificator)
                                        and (
                                                #assignedModificator > 0
                                                        and tonumber(assignedModificator[1]) == tonumber(
                                                                boundModificator[1]
                                                        )
                                                or true
                                        )
                                then
                                        table.insert(inUseList, bindButton)
                                end
                        end
                elseif inputMode == 2 then
                        for bindButton in controls:iterate() do
                                local controlBind = bindButton.bind
                                local boundButton = configs.CONTROLS.ini:get(controlBind, "XBOXBUTTON", "")

                                if controlBind ~= button.bind and tonumber(assignedButton) == tonumber(boundButton) then
                                        table.insert(inUseList, bindButton)
                                end
                        end
                elseif inputMode == 3 then
                        for bindButton in controls:iterate() do
                                local controlBind = bindButton.bind
                                local boundButton = configs.CONTROLS.ini:get(controlBind, "KEY", -1)
                                local boundModificator = configs.CONTROLS.ini:get(controlBind, "KEY_MODIFICATOR", {})

                                if
                                        controlBind ~= button.bind
                                        and tonumber(keys.hexIndexList[assignedButton]) == tonumber(boundButton)
                                        and (
                                                #assignedModificator > 0
                                                        and tonumber(assignedModificator[1]) == tonumber(
                                                                boundModificator[1]
                                                        )
                                                or true
                                        )
                                then
                                        table.insert(inUseList, bindButton)
                                end
                        end
                end

                if #inUseList > 0 then
                        bindingInUseDialog(button, name, inputMode, inUseList)
                else
                        button:saveBind(inputMode)

                        ui.popStyleVar(1)
                        return true
                end

                --  then return true end
        end)
end

local function bindingBoxes(binding, name, label, button, bind, yOffset)
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2(ui.windowWidth() - 15 * cui.uiScale(), ui.windowHeight() / 22),
                settings.Appearance.uiColorBackgroundShade,
                6 * cui.uiScale()
        )

        ui.setCursorX(20 * cui.uiScale())
        cui.snapCursor()
        ui.dwriteTextAligned(
                name .. " " .. label,
                24 * cui.uiScale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.4, ui.windowHeight() / 22)
        )
        ui.sameLine()

        ui.setCursorX(ui.windowWidth() * 0.4)

        local bindingWidth = (ui.windowWidth() * 0.2)

        for i = 3, 1, -1 do
                local boundDeviceID, buttonID = button:boundTo(i)
                local disabled = (sim.inputMode + 1 == 3 and i ~= 3)

                if
                        cui.bindingButton(
                                button,
                                i,
                                boundDeviceID,
                                buttonID,
                                vec2(bindingWidth, ui.windowHeight() / 22),
                                disabled and ui.ButtonFlags.Disabled or ui.ButtonFlags.None
                        )
                then
                        bindingDialog(button, name .. " " .. label, i)
                end
                if ui.itemHovered() and ui.mouseClicked(ui.MouseButton.Right) then button:unbind(i) end

                ui.sameLine()
        end

        cui.offsetCursorY(5)
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

local settingsSearchInput = ""
local settingsSearchActive = false

function bindings:drawHeader()
        if cui.menuButton("Bindings", 40, 0, 0, 0, false, false, ui.CornerFlags.Top) then
        end
end

function bindings:draw()
        cui.pushWindow("settings_button_bind_tabbar", 0, 0, ui.windowWidth() * 0.2, ui.windowHeight(), false)
        ui.setCursor(0)
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground, 6 * cui.uiScale())

        local app = applicationControlsTabBar:draw(controls.tabs)
        cui.popWindow()

        cui.pushWindow(
                "settings_button_binds_window2",
                ui.windowWidth() * 0.2 + 10 * cui.uiScale(),
                0,
                ui.windowWidth() * 0.8 - 10 * cui.uiScale(),
                ui.windowHeight(),
                false
        )

        local textInputWidth = ui.windowWidth() * 0.3
        local r1, r2 = ui.getCursor(), ui.getCursor() + vec2(textInputWidth, ui.windowHeight() / 22)
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackground * 0.25, 6 * cui.uiScale())

        settingsSearchInput, settingsSearchActive = cui.inputText(
                "##controlsSearcher",
                "",
                settingsSearchInput,
                "",
                vec2(textInputWidth, ui.windowHeight() / 22)
        )

        ui.setCursorX(r2.x - ui.windowHeight() / 22)
        ui.setCursorY(0)
        ui.icon(ui.Icons.ZoomIn, ui.windowHeight() / 22, rgbm.colors.gray, (ui.windowHeight() / 22) * 0.5)

        ui.setCursor(r1)
        cui.offsetCursorX(10)
        cui.snapCursor()
        ui.dwriteTextAligned(
                isempty(settingsSearchInput) and "Search controls..." or "",
                (ui.windowHeight() / 22) * 0.55,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(textInputWidth, ui.windowHeight() / 22),
                false,
                rgbm.colors.gray
        )

        ui.setCursorY(0)
        ui.setCursorX(ui.windowWidth() * 0.4)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Keyboard",
                24 * cui.uiScale(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.2, ui.windowHeight() / 22)
        )
        ui.sameLine()
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Gamepad",
                24 * cui.uiScale(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.2, ui.windowHeight() / 22)
        )
        ui.sameLine()
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Wheel",
                24 * cui.uiScale(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.2, ui.windowHeight() / 22)
        )

        cui.pushWindow(
                "settings_button_binds_window3",
                0,
                ui.windowHeight() / 22,
                ui.windowWidth(),
                ui.windowHeight() - ui.windowHeight() / 22,
                true
        )

        -- ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackground)

        if not appsTabBars[app.name] then appsTabBars[app.name] = TabBar() end

        ui.setCursorX(0)
        cui.setCursorY(15)

        for _, group in ipairs(app.groups) do
                ui.setCursorX(0)

                if isempty(settingsSearchInput) then
                        cui.setCursorX(20)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                string.upper(group.name),
                                24 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), ui.windowHeight() / 22)
                        )
                end

                for _, controlBinding in pairs(group.content) do
                        local startIndex, endIndex = string.find(
                                string.upper(controlBinding.name),
                                string.upper(settingsSearchInput),
                                1,
                                true
                        )

                        if settingsSearchInput == "" or startIndex or endIndex then
                                buttonBinder(controlBinding)

                                ui.newLine()
                        end
                end
        end

        cui.popWindow(true)
        cui.popWindow()
end

return bindings
