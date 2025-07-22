local carSetup = require("car_setup")
local cui = require("ui.cui")
local settings = require("settings")
local setupExchangeAPI = require("setup_exchange")
local style = require("ui.cui.style")

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local saveSetupWidget = {}

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

local function promptOverwriteSetup()
        local mouseMoved = false

        cui.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 4

                ui.setCursor(0)
                ui.dwriteTextAligned(
                        "Overwrite Setup",
                        textBoxHeight / 2,
                        nil,
                        nil,
                        vec2Temp1:set(ui.windowWidth(), textBoxHeight)
                )
                local titleTextWidth = ui.measureDWriteText(" Overwrite Setup ", textBoxHeight / 2).x

                ui.drawSimpleLine(
                        vec2Temp1:set(ui.windowWidth() / 2 - titleTextWidth / 2, ui.getCursorY()),
                        vec2Temp2:set(ui.windowWidth() / 2 + titleTextWidth / 2, ui.getCursorY()),
                        settings.Appearance.uiColorSecondary,
                        3
                )

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        string.format("%s/%s", carSetup.selected.track, carSetup.selected.name),
                        textBoxHeight / 4,
                        nil,
                        nil,
                        vec2Temp1:set(ui.availableSpaceX(), textBoxHeight)
                )

                local buttonWidth = ui.windowWidth() / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scale())
                if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scale(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2Temp1:set(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scale())
                if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scale(), ui.ButtonFlags.None) then
                        carSetup:save(sm)
                        cui.menuBanner("Saved Setup", nil, rgbm.colors.green)

                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end, false)
end

function saveSetupWidget:body()
        local iconButtonHeight = style.main.font.body.size * 2
        local buttonWidth = ui.availableSpaceX() - 20 * cui.scale()
        local groupBegin = (ui.windowWidth() / 24)

        cui.setCursorX(10)
        cui.offsetCursorY(15)
        cui.combo(
                "##save_setup_track",
                vec2Temp1:set(buttonWidth, iconButtonHeight),
                carSetup.input.track,
                ui.Alignment.Start,
                false,
                vec2Temp2:set(buttonWidth, 200),
                function()
                        cui.offsetCursorY(4)
                        for i, v in ipairs(carSetup.trackListAll) do
                                ui.setCursorX(0)
                                if cui.selectable(v, ui.Alignment.Start) then carSetup.input.track = v end
                                cui.offsetCursorY(5)
                        end
                end
        )

        cui.setCursorX(10)
        cui.offsetCursorY(10)

        ui.drawRect(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth, iconButtonHeight),
                settings.Appearance.uiColorText * 0.75,
                6 * cui.scale()
        )
        carSetup.input.name = cui.inputText(
                "##SetupName",
                vec2Temp1:set(buttonWidth - iconButtonHeight * 1.3, iconButtonHeight),
                "",
                carSetup.input.name,
                "Setup Name",
                "[%w_ .;,><%-]"
        )
        ui.sameLine()

        ui.setCursorX(ui.windowWidth() - iconButtonHeight - 15 * cui.scale())

        if
                cui.iconButton(
                        "##cancel_car_input",
                        ui.Icons.Cancel,
                        iconButtonHeight,
                        iconButtonHeight,
                        isempty(carSetup.input.name) and ui.ButtonFlags.Disabled or ui.ButtonFlags.None,
                        false
                )
        then
                carSetup.input.name = ""
        end
        ui.sameLine()
        ui.newLine()

        cui.offsetCursorY(10)

        local setupFileExists = false
        if carSetup.input.name ~= "" then
                carSetup.input.path = setupsDir .. "\\" .. carSetup.input.track .. "\\" .. carSetup.input.name .. ".ini"
                setupFileExists = io.fileExists(carSetup.input.path)
        end

        ui.setCursorY(ui.windowHeight() - iconButtonHeight * 2 - 15 * 2 * cui.scale())

        cui.offsetCursorY(10)
        cui.setCursorX(10)

        if
                cui.menuButton(
                        "Save Setup",
                        vec2Temp1:set(buttonWidth, iconButtonHeight),
                        0,
                        0,
                        (carSetup.input.name and #carSetup.input.name:trim() > 0) and ui.ButtonFlags.None
                                or ui.ButtonFlags.Disabled
                )
        then
                if setupFileExists then
                        promptOverwriteSetup(sm)
                else
                        carSetup.input.name = carSetup.input.name:trim()
                        carSetup:save(sm)
                        cui.menuBanner("Setup Saved", nil, rgbm.colors.green)
                end
        end

        cui.offsetCursorY(10)
        cui.setCursorX(10)
        if
                cui.menuButton(
                        "Share on Setup Exchange",
                        vec2Temp1:set(buttonWidth, iconButtonHeight),
                        0,
                        0,
                        (carSetup.input.name and #carSetup.input.name:trim() > 0 and setupExchangeAPI.session.id ~= nil)
                                        and 0
                                or ui.ButtonFlags.Disabled
                )
        then
                setupExchangeAPI:shareSetup(carSetup.input.name:trim())
                cui.menuBanner("Setup Shared", nil, rgbm.colors.green)
        end

        buttonWidth = buttonWidth + 10 * cui.scale()

        -- if cui.menuButton("Reset Setup To Default", vec2Temp1:set(buttonWidth, iconButtonHeight), nil, nil) then
        --         ac.resetSetupToDefault()
        --         cui.menuBanner("Setup reset to default", nil, rgbm.colors.green)
        -- end
end

return saveSetupWidget
