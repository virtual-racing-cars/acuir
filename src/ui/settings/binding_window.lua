local bindings = {}

require("classes.TabBar")
local controls = require("controls")
local cui = require("ui.cui")
local settings = require("settings")
controls:initialize()

local controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini")
ac.onControlSettingsChanged(
        function() controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini") end
)

-- local checkBoxSize = 20
-- local checkBoxMargin = 5
-- local checkBoxSizeV = vec2(checkBoxSize, checkBoxSize)
local WINDOW_MARGIN = 20

local function labelAligned(text, yOffset)
        ui.textAligned(text, vec2(1, 1), vec2(100, 22))
        ui.sameLine()
end

local function checkbox(controlBinding)
        local changed = false

        ui.sameLine(ui.windowWidth() - checkBoxSize - WINDOW_MARGIN - 33)
        ui.textAligned("MPS", vec2(0, 0.51), vec2(25, 25))
        ui.sameLine()
        ui.setCursorY(ui.getCursorY() + 3)

        local selectedX = ui.getCursorX()
        local selectedY = ui.getCursorY()

        ui.drawRectFilled(
                vec2(selectedX, selectedY),
                vec2(selectedX + checkBoxSize, selectedY + checkBoxSize),
                rgbm(0.175, 0.175, 0.175, 1)
        )
        if ui.modernButton("##button" .. controlBinding.name, checkBoxSizeV, ui.ButtonFlags.None) then
                controlBinding:toggleMPS()
                changed = true
        end
        if ui.itemHovered(ui.HoveredFlags.AllowWhenBlockedByActiveItem) then
                ui.tooltip(
                        function() ui.text("Toggle binding modes from sequential\nand Multi-Position Switch (MPS)") end
                )
        end

        if controlBinding.mpsToggle then
                ui.sameLine()
                ui.drawRectFilled(
                        vec2(selectedX + checkBoxMargin, selectedY + checkBoxMargin),
                        vec2(selectedX + checkBoxSize - checkBoxMargin, selectedY + checkBoxSize - checkBoxMargin),
                        rgbm.colors.white
                )

                if ac.getPatchVersionCode() > 2664 then
                        if not controlBinding.buttonDown:disabled() or not controlBinding.buttonUp:disabled() then
                                controlBinding.buttonDown:setDisabled(true)
                                controlBinding.buttonUp:setDisabled(true)
                        end
                end
        else
                if ac.getPatchVersionCode() > 2664 then
                        if controlBinding.buttonDown:disabled() or controlBinding.buttonDown:disabled() then
                                controlBinding.buttonDown:setDisabled(false)
                                controlBinding.buttonUp:setDisabled(false)
                        end
                end
        end

        if ac.getPatchVersionCode() > 2664 then
                if SETTINGS.disableBindDeactivation and (controlBinding:disabled() or controlBinding:disabled()) then
                        controlBinding:setDisabled(true)
                        controlBinding:setDisabled(true)
                end
        end

        -- for i = 1, tonumber(bindSection.POS[1]) do
        -- 	local iSection = bind .. "_" .. i
        -- 	local iButtonSection = iSection

        -- 	if tonumber(bindSection.LUA[1]) == 1 then
        -- 		iButtonSection = "__EXT_CAR_" .. iButtonSection
        -- 	end

        -- 	if ac.getPatchVersionCode() > 2664 then
        -- 		if controlBinding.mpsToggle then
        -- 			if controlBinding[iSection]:disabled() then
        -- 				controlBinding[iSection]:setDisabled(false)
        -- 			end
        -- 		else
        -- 			if not controlBinding[iSection]:disabled() then
        -- 				controlBinding[iSection]:setDisabled(true)
        -- 			end
        -- 		end
        -- 	end
        -- end

        ui.setCursorY(selectedY + checkBoxSize + 5)

        return changed
end

local function infoText()
        if carSpecificPresetEnabled then
                if carSpecificPreset ~= "" then
                        ui.textAligned(
                                "Car-Specific Controls: " .. carSpecificPreset,
                                vec2(0.5, 0.5),
                                vec2(ui.availableSpaceX(), 30)
                        )
                end
        else
                ui.textAligned("", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 30))
        end
end

local function helpInfoButton(controlBinding)
        if controlBinding.help ~= "" and controlBinding.help ~= nil then
                ui.sameLine()
                ui.offsetCursorX(-5)
                ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
                ui.iconButton(ui.Icons.Info, vec2(12, 12), rgbm.colors.white, nil, 1)
                if ui.itemHovered(ui.HoveredFlags.AllowWhenBlockedByActiveItem) then
                        ui.tooltip(function() ui.text(controlBinding.help) end)
                end
                ui.popStyleColor(1)
        end

        if controlBinding.isLuaControlled then
                ui.sameLine()
                ui.offsetCursorX(-5)
                ui.icon(ui.Icons.Lua, vec2(12, 12), rgbm.colors.white, nil, 1)
        else
                if controlBinding.isExtendedPhysics then
                        ui.sameLine()
                        ui.offsetCursorX(-5)
                        ui.icon(ui.Icons.Speedometer, vec2(12, 12), rgbm.colors.white, nil, 1)
                end
        end
end

local function bindingDialog(name, bind)
        cui.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 5

                ui.setCursor(0)
                ui.dwriteTextAligned(
                        "Press a Button",
                        textBoxHeight * 0.5,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "This will assign a control bind for:",
                        textBoxHeight * 0.3,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        name,
                        textBoxHeight * 0.4,
                        nil,
                        ui.Alignment.Start,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                ui.setCursorX(0)
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

                local button = controls:listener(2)

                ac.log(bind, button)

                if button ~= -1 then
                        controlsINI:setAndSave(bind, "XBOXBUTTON", button)
                        ac.reloadControlSettings()
                        return true
                end

                ui.popStyleVar(1)
        end)
end

local function bindingBoxes(name, label, button, bind, yOffset)
        -- if not string.find(name, "Gear") then
        --         return
        -- end

        ui.setCursorX(20 * cui.uiScale())
        ui.dwriteTextAligned(
                name .. " " .. label,
                24 * cui.uiScale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 2, 50 * cui.uiScale())
        )
        ui.sameLine()

        local bindingWidth = (ui.windowWidth() / 2)
        local boundDeviceID, buttonID = controls:boundTo(2, bind)

        if
                cui.bindingButton(
                        bind,
                        boundDeviceID,
                        buttonID,
                        vec2(bindingWidth, 50 * cui.uiScale()),
                        ui.ButtonFlags.None
                )
        then
                bindingDialog(name, bind)
        end
end

local function buttonBinder(controlBinding)
        -- helpInfoButton(controlBinding)

        if controlBinding.isActivationBind then
                bindingBoxes(controlBinding.name, "", controlBinding.button, controlBinding.bind)
                return
        end

        -- if controlBinding.isMultiPositionSwitchBind then
        -- 	checkbox(controlBinding)
        -- end

        if controlBinding.isSequentialBind then
                bindingBoxes(
                        controlBinding.name,
                        controlBinding.buttonUpLabel,
                        controlBinding.buttonUp,
                        controlBinding.bindUp,
                        8
                )
                ui.newLine()
                ui.setCursorX(WINDOW_MARGIN)

                bindingBoxes(
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

local function drawAppControlsTabBar(app)
        ui.setCursor(0)
        cui.pushWindow(
                "bindings_list_subwindow",
                0,
                56 * cui.uiScale(),
                ui.windowWidth(),
                ui.windowHeight() - 56 * cui.uiScale(),
                true
        )

        ui.setCursor(0)
        for i, tab in ipairs(app.tabs) do
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
end

local function footerInfo()
        -- ui.drawSimpleLine(vec2(0, 600), vec2(100, 600), rgbm.colors.aqua)
        -- ui.drawSimpleLine(vec2(451, 600), vec2(351, 600), rgbm.colors.aqua)
        ui.setCursorY(ui.windowHeight() - 28)
        ui.setCursorX(0)
        ui.textAligned("Info            Extended Physics            Lua    ", vec2(0.5, 0), vec2(ui.windowWidth()))
        ui.setCursorY(ui.windowHeight() - 26)
        ui.setCursorX(130)
        ui.icon(ui.Icons.Info, vec2(12, 12), rgbm.colors.white, nil, 1)
        ui.sameLine(275)
        ui.icon(ui.Icons.Speedometer, vec2(12, 12), rgbm.colors.white, nil, 1)
        ui.sameLine(340)
        ui.icon(ui.Icons.Lua, vec2(12, 12), rgbm.colors.white, nil, 1)
end

local function deviceListWindow()
        cui.pushWindow(
                "device_list_window",
                (ui.windowWidth() / 5),
                0,
                (ui.windowWidth() / 5) * 4,
                56 * cui.uiScale(),
                false
        )
        -- ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(10, 0, 0, 1))

        ui.setCursor(0)
        ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)

        if cui.menuButton("Wheel Controller", 56 * 0.8 * cui.uiScale(), 0, 0, 0, false, false) then
        end
        ui.sameLine()

        if cui.menuButton("XInput Controller", 56 * 0.8 * cui.uiScale(), 0, 0, 0, false, false) then
        end
        ui.sameLine()

        if cui.menuButton("Keyboard & Mouse", 56 * 0.8 * cui.uiScale(), 0, 0, 0, false, false) then
        end
        ui.sameLine()

        ui.popStyleColor(1)

        cui.popWindow()
end

function bindings:draw()
        -- infoText()

        deviceListWindow()

        cui.pushWindow(
                "settings_button_binds_window",
                0,
                56 * cui.uiScale(),
                ui.windowWidth() / 2,
                ui.windowHeight() - 56 * cui.uiScale(),
                false
        )

        cui.popWindow()

        cui.pushWindow(
                "settings_button_binds_window2",
                ui.windowWidth() / 2,
                56 * cui.uiScale(),
                ui.windowWidth() / 2,
                ui.windowHeight() - 56 * cui.uiScale(),
                false
        )
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm.colors.black)

        ui.setCursor(0)
        local app = applicationControlsTabBar:draw(controls.apps)
        ui.newLine()
        if not appsTabBars[app.name] then appsTabBars[app.name] = TabBar() end

        drawAppControlsTabBar(app)

        cui.popWindow()
        -- footerInfo()
end

return bindings
