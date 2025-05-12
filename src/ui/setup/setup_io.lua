local cui = require("ui.cui")

local callback = require("callback")
local carSetup = require("src.car_setup")
local settings = require("settings")

local vec2Temp1 = vec2()

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)
local refreshingSetups = false

local function promptDeleteSetup()
        local mouseMoved = false

        cui.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 4

                ui.setCursor(0)
                ui.dwriteTextAligned("Delete Setup", textBoxHeight / 2, nil, nil, vec2(ui.windowWidth(), textBoxHeight))
                local titleTextWidth = ui.measureDWriteText(" Delete Setup ", textBoxHeight / 2).x

                ui.drawSimpleLine(
                        vec2(ui.windowWidth() / 2 - titleTextWidth / 2, ui.getCursorY()),
                        vec2(ui.windowWidth() / 2 + titleTextWidth / 2, ui.getCursorY()),
                        settings.Appearance.uiColor2,
                        3
                )

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        string.format("%s/%s", carSetup.selected.track, carSetup.selected.name),
                        textBoxHeight / 4,
                        nil,
                        nil,
                        vec2(ui.availableSpaceX(), textBoxHeight)
                )

                local buttonWidth = ui.windowWidth() / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scaleY())
                if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scaleY())
                if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
                        carSetup:delete()
                        cui.menuBanner("Deleted Setup", nil, rgbm.colors.red)

                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end, false)
end

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
                        vec2(ui.windowWidth(), textBoxHeight)
                )
                local titleTextWidth = ui.measureDWriteText(" Overwrite Setup ", textBoxHeight / 2).x

                ui.drawSimpleLine(
                        vec2(ui.windowWidth() / 2 - titleTextWidth / 2, ui.getCursorY()),
                        vec2(ui.windowWidth() / 2 + titleTextWidth / 2, ui.getCursorY()),
                        settings.Appearance.uiColor2,
                        3
                )

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        string.format("%s/%s", carSetup.selected.track, carSetup.selected.name),
                        textBoxHeight / 4,
                        nil,
                        nil,
                        vec2(ui.availableSpaceX(), textBoxHeight)
                )

                local buttonWidth = ui.windowWidth() / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scaleY())
                if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scaleY())
                if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
                        carSetup:save(sm)
                        cui.menuBanner("Saved Setup", nil, rgbm.colors.green)

                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end, false)
end

local function saveSetupWindow(sm)
        local iconButtonHeight = ui.windowHeight() * 0.1
        local buttonWidth = (ui.windowWidth() / 24) * 22
        local groupBegin = (ui.windowWidth() / 24)

        local fontSize = math.floor(24 * cui.scaleY())
        fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize

        ui.setCursor(0)

        ui.dwriteTextAligned(
                "Current Setup - " .. carSetup.current,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX(), iconButtonHeight)
        )

        ui.setCursorX(groupBegin)
        carSetup.input.name = cui.inputText(
                "##SetupName",
                carSetup.input.track .. "/",
                carSetup.input.name,
                "[%w_ .;,><%-]",
                vec2Temp1:set(buttonWidth, iconButtonHeight)
        )
        ui.newLine()

        local setupFileExists = false
        if carSetup.input.name ~= "" then
                carSetup.input.path = setupsDir .. "\\" .. carSetup.input.track .. "\\" .. carSetup.input.name .. ".ini"
                setupFileExists = io.fileExists(carSetup.input.path)
        end

        ui.setCursorX(groupBegin)

        cui.offsetCursorY(10)

        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth, iconButtonHeight),
                settings.Appearance.uiColor1
        )

        if
                cui.menuButton(
                        "Load Setup",
                        vec2Temp1:set(buttonWidth, iconButtonHeight),
                        nil,
                        nil,
                        setupFileExists and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                )
        then
                cui.menuBanner("Loaded Setup", nil, rgbm.colors.green)
                sm:LoadStuff(carSetup.selected.path)
                carSetup.current = carSetup.selected.track .. "/" .. carSetup.selected.name
        end
        ui.newLine()

        buttonWidth = buttonWidth - 10 * cui.scaleY()

        ui.setCursorX(groupBegin)
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
                settings.Appearance.uiColor1
        )
        if
                cui.menuButton(
                        "Delete Setup",
                        vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
                        nil,
                        nil,
                        setupFileExists and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                )
        then
                if #carSetup.selected.name > 0 then promptDeleteSetup() end
        end
        ui.sameLine()

        ui.offsetCursorX(10 * cui.scaleY())
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
                settings.Appearance.uiColor1
        )
        if cui.menuButton("Save Setup", vec2Temp1:set(buttonWidth / 2, iconButtonHeight)) then
                if setupFileExists then
                        promptOverwriteSetup(sm)
                else
                        carSetup:save(sm)
                        cui.menuBanner("Saved Setup", nil, rgbm.colors.green)
                end
        end
end

local lastHide = settings.General.hideOtherTrackSetups

function setupIoDraw(sm)
        if lastHide ~= settings.General.hideOtherTrackSetups then carSetup:load() end

        if ui.keyPressed(ui.Key.Delete) then
                carSetup:delete()
                cui.menuBanner("Deleted Setup", nil, rgbm.colors.red)
        end

        cui.contentWindow(
                "setup_io_saved_setups",
                vec2(0, (ui.windowHeight() / 4) * 3),
                vec2(ui.windowWidth(), ui.windowHeight() / 2),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)

                        saveSetupWindow(sm)
                end
        )

        cui.contentWindow(
                "load_setups",
                vec2(0, 0),
                vec2(ui.windowWidth(), (ui.windowHeight() / 4) * 3),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)

                        if refreshingSetups then
                                ui.icon(ui.Icons.LoadingSpinner, ui.availableSpace())
                        else
                                for i, track in ipairs(carSetup.trackList) do
                                        ui.setCursorX(0)
                                        if
                                                cui.treeNode(track, #carSetup.loaded[track], function()
                                                        for i in ipairs(carSetup.loaded[track]) do
                                                                local setup = carSetup.loaded[track][i]
                                                                local setupActive = carSetup.selected.path == setup.path
                                                                local name = string.replace(setup.name, ".ini", "")
                                                                ui.setCursorX(0)

                                                                if
                                                                        cui.treeNodeButton(
                                                                                name,
                                                                                vec2(
                                                                                        ui.windowWidth(),
                                                                                        48 * cui.scaleY()
                                                                                ),
                                                                                setupActive,
                                                                                false
                                                                        )
                                                                then
                                                                        carSetup.selected = {
                                                                                name = name,
                                                                                track = track,
                                                                                path = setup.path,
                                                                                lastWriteTime = setup.lastWriteTime,
                                                                        }

                                                                        carSetup.input = {
                                                                                name = name,
                                                                                track = track,
                                                                                path = setup.path,
                                                                                lastWriteTime = setup.lastWriteTime,
                                                                        }

                                                                        if ac.getUI().isMouseLeftKeyDoubleClicked then
                                                                                sm:LoadStuff(carSetup.selected.path)
                                                                                carSetup.current = carSetup.selected.track
                                                                                        .. "/"
                                                                                        .. carSetup.selected.name
                                                                        end
                                                                end
                                                        end
                                                end, i == 1)
                                        then
                                                carSetup.input.track = track
                                        end
                                end
                        end
                end,
                true,
                true
        )

        return ""
end
