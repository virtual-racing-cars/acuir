local cui = require("ui.cui")

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
                        settings.Appearance.uiThemeColor2,
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
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.uiScale())
                if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.uiScale(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.uiScale())
                if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.uiScale(), ui.ButtonFlags.None) then
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
                        settings.Appearance.uiThemeColor2,
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
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.uiScale())
                if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.uiScale(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.uiScale())
                if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.uiScale(), ui.ButtonFlags.None) then
                        carSetup:save(sm)
                        cui.menuBanner("Saved Setup", nil, rgbm.colors.green)

                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end, false)
end

local function drawSetupControls(sm)
        local iconButtonHeight = 42 * cui.uiScale()
        local buttonWidth = (ui.windowWidth() / 24) * 22
        local groupBegin = (ui.windowWidth() / 24)
        local fontSize = 22 * cui.uiScale()

        ui.setCursor(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Current Setup - " .. carSetup.current,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX(), fontSize * 2)
        )

        ui.setCursorX(groupBegin)
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth, iconButtonHeight),
                settings.Appearance.uiThemeColor1
        )
        ui.drawRect(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth, iconButtonHeight),
                rgbm.colors.white * 0.65
        )
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
                settings.Appearance.uiThemeColor1
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

        cui.offsetCursorY(10)

        buttonWidth = buttonWidth - 10 * cui.uiScale()

        ui.setCursorX(groupBegin)
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
                settings.Appearance.uiThemeColor1
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

        ui.offsetCursorX(10 * cui.uiScale())
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
                settings.Appearance.uiThemeColor1
        )
        if cui.menuButton("Save Setup", vec2Temp1:set(buttonWidth / 2, iconButtonHeight)) then
                if setupFileExists then
                        promptOverwriteSetup(sm)
                else
                        carSetup:save(sm)
                        cui.menuBanner("Saved Setup", nil, rgbm.colors.green)
                end
        end

        buttonWidth = buttonWidth + 10 * cui.uiScale()

        cui.offsetCursorY(10)

        ui.setCursorX(groupBegin)
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth, iconButtonHeight),
                settings.Appearance.uiThemeColor1
        )

        if cui.menuButton("Reset Setup To Default", vec2Temp1:set(buttonWidth, iconButtonHeight), nil, nil) then
                ac.resetSetupToDefault()
                cui.menuBanner("Setup reset to default", nil, rgbm.colors.green)
        end
end

local rightClicked = ""

local function drawSetupNode(setup, track)
        local setupActive = carSetup.selected.path == setup.path
        local name = string.replace(setup.name, ".ini", "")
        local buttonSize = vec2(ui.windowWidth(), 48 * cui.uiScale())

        if cui.treeNodeButton(name, buttonSize, setupActive, false) then
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
                        carSetup.current = carSetup.selected.track .. "/" .. carSetup.selected.name
                        cui.menuBanner("Loaded Setup", nil, rgbm.colors.green)
                end
        end

        if ui.itemHovered() and ui.mouseClicked(ui.MouseButton.Right) then rightClicked = setup.path end

        ui.sameLine()
        ui.setCursorX(0)
        ui.dwriteTextAligned(
                os.date("%Y-%m-%d %H:%M", tonumber(setup.lastWriteTime)),
                16 * cui.uiScale(),
                ui.Alignment.End,
                0,
                vec2(ui.windowWidth() * 0.98, buttonSize.y),
                false,
                ui.itemHovered() and rgbm.colors.white or rgbm.colors.gray
        )

        if setup.path == rightClicked then
                ui.setCursorX(0)
                ui.drawRectFilled(ui.getCursor(), ui.getCursor() + buttonSize, rgbm(0.2, 0.2, 0.2, 1))

                local popupClicked = false
                if cui.menuButton("Load", vec2(ui.windowWidth() * 0.5, buttonSize.y), 0, 0) then
                        cui.menuBanner("Loaded Setup", nil, rgbm.colors.green)
                        sm:LoadStuff(carSetup.selected.path)
                        carSetup.current = carSetup.selected.track .. "/" .. carSetup.selected.name
                        popupClicked = true
                end

                local popupHovered = ui.itemHovered()

                ui.sameLine()

                if cui.menuButton("Delete", vec2(ui.windowWidth() * 0.5, buttonSize.y), 0, 0) then
                        promptDeleteSetup()
                        popupClicked = true
                end

                if not popupHovered then popupHovered = ui.itemHovered() end
                if popupHovered or popupClicked then return end

                if ui.mouseReleased(ui.MouseButton.Left) then rightClicked = "" end
        end
end

local function drawSetupList()
        if refreshingSetups then
                ui.icon(ui.Icons.LoadingSpinner, ui.availableSpace())
                return
        end

        ui.setCursorY(0)

        for i, track in ipairs(carSetup.trackList) do
                ui.setCursorX(0)
                if
                        cui.treeNode(track, #carSetup.loaded[track], function()
                                for i in ipairs(carSetup.loaded[track]) do
                                        ui.setCursorX(0)
                                        drawSetupNode(carSetup.loaded[track][i], track)
                                end
                        end, i == 1)
                then
                        carSetup.input.track = track
                end
        end
end

local lastHide = settings.General.hideOtherTrackSetups

function drawSetupIO(sm)
        if lastHide ~= settings.General.hideOtherTrackSetups then carSetup:load() end

        if ui.keyPressed(ui.Key.Delete) then
                carSetup:delete()
                cui.menuBanner("Deleted Setup", nil, rgbm.colors.red)
        end

        cui.pushWindow("load_setups", 0, 0, ui.windowWidth(), ui.windowHeight() * 0.5, true, ui.ButtonFlags.None)
        ui.drawRectFilled(0, ui.windowSize(), rgbm.colors.black)

        drawSetupList()
        cui.popWindow(true)

        cui.pushWindow("setup_io_saved_setups", 0, ui.windowHeight() * 0.5, ui.windowWidth(), ui.windowHeight() / 2)
        drawSetupControls(sm)

        cui.popWindow()

        return ""
end
