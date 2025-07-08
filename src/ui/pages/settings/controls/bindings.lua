local TabBar = require("classes.TabBar")
local configs = require("configs")
local controls = require("controls")
local cui = require("ui.cui")
local keys = require("keys")
local settings = require("settings")
local style = require("style")
local sim = ac.getSim()

local inputModeStringKeys = {
        "BUTTON",
        "XBOXBUTTON",
        "KEY",
}

local bindings = {}

local margin = 20

local applicationControlsTabBar = TabBar()
local appsTabBars = {}

local settingsSearchInput = ""
local settingsSearchActive = false

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
                        button:save(inputMode)

                        ui.popStyleVar(1)
                        return true
                end
                ui.sameLine()
                ui.offsetCursorX(5 * cui.uiScale())

                if cui.modalButton("REPLACE OLD", buttonWidth, 50 * cui.uiScale(), ui.ButtonFlags.None) then
                        button:save(inputMode)

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

local function bindingDialog(button, name)
        cui.modalDialog(function()
                ui.setMouseCursor(ui.MouseCursor.None)

                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 5

                local inputPromptString = "Press a Button or Key"
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

                local assigned, assignedInputMode, assignedJoy, assignedButton, assignedJoyModificator, assignedModificator =
                        button:assign()

                if not assigned then
                        ui.popStyleVar(1)

                        return false
                end

                local inUseList = {}

                if assignedInputMode == 0 then
                        for bindButton in controls:iterate() do
                                local controlBind = bindButton.bind
                                local boundJoy = configs.CONTROLS.ini:get(controlBind, "JOY", -1)
                                local boundButton = configs.CONTROLS.ini:get(controlBind, "AXLE", -1)

                                if
                                        controlBind ~= button.bind
                                        and tonumber(assignedJoy) == tonumber(boundJoy)
                                        and tonumber(assignedButton) == tonumber(boundButton)
                                then
                                        table.insert(inUseList, bindButton)
                                end
                        end
                elseif assignedInputMode == 1 then
                        for bindButton in controls:iterate() do
                                local controlBind = bindButton.bind
                                local boundJoy = configs.CONTROLS.ini:get(controlBind, "JOY", -1)
                                local boundButton = configs.CONTROLS.ini:get(controlBind, "BUTTON", -1)
                                local boundJoyModificator = configs.CONTROLS.ini:get(controlBind, "JOY_MODIFICATOR", -1)
                                local boundModificator = configs.CONTROLS.ini:get(controlBind, "BUTTON_MODIFICATOR", {})

                                if tonumber(boundModificator[1]) == -1 or boundModificator[1] == "" then
                                        boundModificator[1] = nil
                                end

                                if
                                        controlBind ~= button.bind
                                        and tonumber(assignedJoy) == tonumber(boundJoy)
                                        and tonumber(assignedButton) == tonumber(boundButton)
                                        and tonumber(assignedJoyModificator) == tonumber(boundJoyModificator)
                                        and table.same(assignedModificator, boundModificator)
                                then
                                        table.insert(inUseList, bindButton)
                                end
                        end
                elseif assignedInputMode == 2 then
                        for bindButton in controls:iterate() do
                                local controlBind = bindButton.bind
                                local boundButton = configs.CONTROLS.ini:get(controlBind, "XBOXBUTTON", "")

                                if controlBind ~= button.bind and assignedButton == boundButton then
                                        table.insert(inUseList, bindButton)
                                end
                        end
                elseif assignedInputMode == 3 then
                        for bindButton in controls:iterate() do
                                local controlBind = bindButton.bind
                                local boundButton = configs.CONTROLS.ini:get(controlBind, "KEY", -1)
                                local boundModificator = configs.CONTROLS.ini:get(controlBind, "KEY_MODIFICATOR", {})

                                if tonumber(boundModificator[1]) == -1 or boundModificator[1] == "" then
                                        boundModificator[1] = nil
                                end

                                if
                                        controlBind ~= button.bind
                                        and tonumber(keys.hexIndexList[assignedButton]) == tonumber(boundButton)
                                        and table.same(assignedModificator, boundModificator)
                                then
                                        ac.log(assignedModificator, boundModificator)

                                        table.insert(inUseList, bindButton)
                                end
                        end
                end

                -- ac.setMousePosition(vec2(ui.windowWidth() * 0.5, ui.windowHeight() * 0.5))

                if #inUseList > 0 then
                        bindingInUseDialog(button, name, assignedInputMode, inUseList)
                else
                        button:save(assignedInputMode)

                        ui.popStyleVar(1)
                        return true
                end

                --  then return true end
        end)
end

local function bindingBoxes(binding, name, label, button, bind, yOffset)
        if
                cui.bindingButton(
                        name,
                        label,
                        button,
                        vec2(ui.windowWidth() - 15 * cui.uiScale(), 64 * cui.uiScale()),
                        ui.ButtonFlags.None or ui.ButtonFlags.None
                )
        then
                bindingDialog(button, name .. " " .. label)
        end

        cui.offsetCursorY(5)
end

local function axisBoxes(binding, name, label, button, bind, yOffset)
        if
                cui.bindingAxleButton(
                        name,
                        label,
                        button,
                        vec2(ui.windowWidth() - 15 * cui.uiScale(), 64 * cui.uiScale()),
                        ui.ButtonFlags.None or ui.ButtonFlags.None
                )
        then
                button:clearAssign()
                bindingDialog(button, name .. " " .. label)
        end

        cui.offsetCursorY(5)
end

local function buttonBinder(controlBinding)
        -- helpInfoButton(controlBinding)

        if controlBinding.isAxis then
                axisBoxes(controlBinding, controlBinding.name, "", controlBinding.button, controlBinding.bind)
                return
        end

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

        if
                controlBinding.isMultiPositionSwitchBind
                and (settings.General.showMPSBinds or not isempty(settingsSearchInput))
        then
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

function bindings:drawHeader()
        if cui.windowTabButton("Bindings", 36, ui.ButtonFlags.None, false) then
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

        local textInputWidth = ui.windowWidth() * 0.25
        local r1, r2 = ui.getCursor(), ui.getCursor() + vec2(textInputWidth, 36 * cui.uiScale())
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackground * 0.25, 6 * cui.uiScale())

        settingsSearchInput, settingsSearchActive = cui.inputText(
                "##controlsSearcher",
                vec2(textInputWidth, 36 * cui.uiScale()),
                "",
                settingsSearchInput,
                "Search Controls...",
                ""
        )

        ui.setCursorX(r2.x - ui.windowHeight() / 22)
        ui.setCursorY(0)
        ui.icon(ui.Icons.ZoomIn, 36 * cui.uiScale(), rgbm.colors.gray, 36 * cui.uiScale() * 0.5)

        ui.sameLine()
        cui.offsetCursorX(30)
        cui.offsetCursorY(9)
        settings.General.showMPSBinds = drawCheckbox(
                "##mapisShowingWeather",
                "Show MPS Binds",
                style.main.font.bodyLarge.size,
                settings.General.showMPSBinds
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

                if #group.content > 0 then
                        if isempty(settingsSearchInput) then
                                cui.setCursorX(20)
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        string.upper(group.name),
                                        style.main.font.bodyLarge.size,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), 32 * cui.uiScale())
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
        end

        cui.popWindow(true)
        cui.popWindow()
end

return bindings
