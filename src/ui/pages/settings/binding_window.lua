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
        for i, tab in ipairs(app.tabs) do
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
end

return bindings
