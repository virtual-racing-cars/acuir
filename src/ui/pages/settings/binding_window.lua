local bindings = {}

require("classes.TabBar")
local controls = require("controls")
local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()
controls:initialize()

local controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini")
ac.onControlSettingsChanged(
        function() controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini") end
)
local WINDOW_MARGIN = 20

local inputModeStringKeys = {
        "BUTTON",
        "XBOXBUTTON",
        "KEY",
}

local function bindingDialog(name, bind, inputMode)
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

                if ui.keyPressed(ui.Key.Escape) then return true end

                local button = controls:listener(inputMode)

                ac.log(bind, button)

                if button ~= nil and button ~= -1 and button ~= "" then
                        controlsINI:setAndSave(bind, inputModeStringKeys[inputMode], button)
                        ac.reloadControlSettings()
                        return true
                end

                ui.popStyleVar(1)
        end)
end

local function bindingBoxes(binding, name, label, button, bind, yOffset)
        -- if not string.find(name, "Gear") then
        --         return
        -- end

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
        local boundDeviceID, buttonID = binding:boundTo()

        if
                cui.bindingButton(
                        bind,
                        boundDeviceID,
                        buttonID,
                        vec2(bindingWidth, ui.windowHeight() / 22),
                        ui.ButtonFlags.None
                )
        then
                bindingDialog(name, bind, 3)
        end

        ui.sameLine()

        if sim.inputMode > 1 then return end

        local boundDeviceID, buttonID = binding:boundTo()

        if
                cui.bindingButton(
                        bind,
                        boundDeviceID,
                        buttonID,
                        vec2(bindingWidth, ui.windowHeight() / 22),
                        ui.ButtonFlags.None
                )
        then
                bindingDialog(name, bind, sim.inputMode + 1)
        end
end

local function buttonBinder(controlBinding)
        -- helpInfoButton(controlBinding)

        if controlBinding.isActivationBind then
                bindingBoxes(controlBinding, controlBinding.name, "", controlBinding.button, controlBinding.bind)
                return
        end

        -- if controlBinding.isMultiPositionSwitchBind then
        -- 	checkbox(controlBinding)
        -- end

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
                ui.setCursorX(WINDOW_MARGIN)

                bindingBoxes(
                        controlBinding,

                        controlBinding.name,
                        controlBinding.buttonDownLabel,
                        controlBinding.buttonDown,
                        controlBinding.bindDown,
                        8
                )
        end

        if controlBinding.isMultiPositionSwitchBind then -- and controlBinding.mpsToggle then
                for index, button in ipairs(controlBinding.buttonPosition) do
                        ui.newLine()
                        ui.setCursorX(WINDOW_MARGIN)

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

        -- footerInfo()
end

return bindings
