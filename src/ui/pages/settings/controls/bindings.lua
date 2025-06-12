local TabBar = require("classes.TabBar")
local configs = require("configs")
local controls = require("controls")
local cui = require("ui.cui")
local sim = ac.getSim()
local keys = require("keys")

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
                                configs.CONTROLS:set(bind.bind, inputModeStringKeys[inputMode], -1)
                                configs.CONTROLS:set(bind.bind, inputModeStringKeys[inputMode] .. "_MODIFICATOR", -1)
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
                                local boundButton = configs.CONTROLS:get(controlBind, "KEY", -1)
                                local boundModificator = configs.CONTROLS:get(controlBind, "KEY_MODIFICATOR", -1)

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

local settingsSearchInput = ""
local settingsSearchActive = false

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

        ui.setCursor(0)
        ui.drawRectFilled(
                0,
                vec2(ui.windowWidth() * 0.4, ui.windowHeight() / 22 - 2 * cui.uiScale()),
                rgbm.colors.black * 0.25
        )

        settingsSearchInput, settingsSearchActive = cui.inputText(
                "##controlsSearcher",
                "",
                settingsSearchInput,
                "",
                vec2(ui.windowWidth() * 0.4, ui.windowHeight() / 22)
        )

        ui.setCursorX(ui.windowWidth() * 0.4 - 30 * cui.uiScale())
        ui.setCursorY((ui.windowHeight() / 22) * 0.25)
        ui.icon(ui.Icons.ZoomIn, (ui.windowHeight() / 22) * 0.5, rgbm.colors.gray)
        ui.setCursorY(ui.windowHeight() / 22)

        cui.setCursorX(10)
        ui.setCursorY(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                isempty(settingsSearchInput) and "Search controls..." or "",
                math.floor(ui.windowHeight() / 22 * 0.55),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.75, ui.windowHeight() / 22),
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

        -- ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm.colors.black)

        if not appsTabBars[app.name] then appsTabBars[app.name] = TabBar() end

        ui.setCursorX(0)
        cui.setCursorY(15)

        for _, tab in ipairs(app.tabs) do
                ui.setCursorX(0)

                if isempty(settingsSearchInput) then
                        ui.drawRectFilled(
                                ui.getCursor(),
                                ui.getCursor() + vec2(ui.windowWidth(), ui.windowHeight() / 22),
                                rgbm.colors.black * 0.25
                        )

                        cui.setCursorX(20)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                string.upper(tab.name),
                                24 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), ui.windowHeight() / 22)
                        )
                end

                for _, controlBinding in pairs(tab.content) do
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
