local cui = require("ui.cui")

local carSetup = require("src.car_setup")
local settings = require("settings")
local style = require("style")

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
                        settings.Appearance.uiColorSecondary,
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
                        settings.Appearance.uiColorSecondary,
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

function drawLocalSetupFilters()
        cui.offsetCursorX(10)
        cui.offsetCursorY(10)
        local hideChanged = false
        settings.General.hideOtherTrackSetups, hideChanged = drawCheckbox(
                "##isSetupIOHidingOtherTracks",
                "Show Other Tracks",
                20 * cui.uiScale(),
                settings.General.hideOtherTrackSetups
        )
        ui.sameLine()

        if hideChanged then carSetup:load() end

        cui.setCursorX(250)
        local sortChanged = false
        settings.General.sortTrackSetupsAZ, sortChanged = drawCheckbox(
                "##isSetupIOSortingAlpha",
                "Sort A-Z",
                20 * cui.uiScale(),
                settings.General.sortTrackSetupsAZ
        )

        if sortChanged then carSetup:load() end
end

function drawSetupControls(sm)
        local iconButtonHeight = 36 * cui.uiScale()
        local buttonWidth = ui.windowWidth() * 0.99
        local groupBegin = (ui.windowWidth() / 24)
        local fontSize = style.main.font.body.size

        ui.setCursorX(ui.windowWidth() * 0.005)
        cui.offsetCursorY(15)
        cui.combo(
                "##save_setup_track",
                vec2(buttonWidth, iconButtonHeight),
                "Track: " .. carSetup.input.track,
                ui.Alignment.Start,
                false,
                vec2(buttonWidth, 200),
                function()
                        cui.offsetCursorY(4)
                        for i, v in ipairs(carSetup.trackListAll) do
                                ac.log(v)
                                ui.setCursorX(0)
                                if cui.menuButton(v, vec2(ui.windowWidth(), iconButtonHeight)) then
                                        carSetup.input.track = v
                                end
                        end
                end
        )

        ui.setCursorX(ui.windowWidth() * 0.005)
        cui.offsetCursorY(5)

        ui.drawRect(
                ui.getCursor(),
                ui.getCursor() + vec2Temp1:set(buttonWidth, iconButtonHeight),
                settings.Appearance.uiColorText * 0.75,
                6 * cui.uiScale()
        )
        carSetup.input.name = cui.inputText(
                "##SetupName",
                vec2Temp1:set(buttonWidth - iconButtonHeight * 1.3, iconButtonHeight),
                "",
                carSetup.input.name,
                " Setup Name",
                "[%w_ .;,><%-]"
        )
        ui.sameLine()

        ui.setCursorX(ui.windowWidth() - iconButtonHeight * 1.2)

        if
                cui.iconButton(
                        "##chatSetupNameButton",
                        ui.Icons.Cancel,
                        iconButtonHeight,
                        iconButtonHeight,
                        isempty(carSetup.input.name) and ui.ButtonFlags.Disabled or ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                carSetup.input.name = ""
        end
        ui.sameLine()
        ui.newLine()

        cui.offsetCursorY(5)

        local setupFileExists = false
        if carSetup.input.name ~= "" then
                carSetup.input.path = setupsDir .. "\\" .. carSetup.input.track .. "\\" .. carSetup.input.name .. ".ini"
                setupFileExists = io.fileExists(carSetup.input.path)
        end

        cui.offsetCursorY(5)
        ui.setCursorX(ui.windowWidth() * 0.005)

        if
                cui.menuButton(
                        "Load Setup",
                        vec2Temp1:set(buttonWidth * 0.49, iconButtonHeight),
                        nil,
                        nil,
                        setupFileExists and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                        false,
                        false
                )
        then
                cui.menuBanner("Loaded Setup", nil, rgbm.colors.green)
                sm:LoadStuff(carSetup.selected.path)
                carSetup.current = carSetup.selected.track .. "/" .. carSetup.selected.name
        end
        ui.sameLine()
        ui.offsetCursorX(buttonWidth * 0.02)

        -- if
        --         cui.menuButton(
        --                 "Delete Setup",
        --                 vec2Temp1:set(buttonWidth / 2, iconButtonHeight),
        --                 nil,
        --                 nil,
        --                 setupFileExists and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
        --         )
        -- then
        --         if #carSetup.selected.name > 0 then promptDeleteSetup() end
        -- end
        -- ui.sameLine()

        if cui.menuButton("Save Setup", vec2Temp1:set(buttonWidth * 0.49, iconButtonHeight)) then
                if setupFileExists then
                        promptOverwriteSetup(sm)
                else
                        carSetup:save(sm)
                        cui.menuBanner("Saved Setup", nil, rgbm.colors.green)
                end
        end

        buttonWidth = buttonWidth + 10 * cui.uiScale()

        -- if cui.menuButton("Reset Setup To Default", vec2Temp1:set(buttonWidth, iconButtonHeight), nil, nil) then
        --         ac.resetSetupToDefault()
        --         cui.menuBanner("Setup reset to default", nil, rgbm.colors.green)
        -- end
end

local function drawSetupNode(setup, track)
        local setupActive = carSetup.selected.path == setup.path
        local name = string.replace(setup.name, ".ini", "")
        local buttonSize = vec2(ui.windowWidth(), 36 * cui.uiScale())
        local popupButtonSize = vec2(ui.windowWidth() * 0.3, 32 * cui.uiScale())

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

        ui.itemPopup(name .. track, ui.MouseButton.Right, function()
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

                ui.setCursorX(0)
                ui.drawRectFilled(0, popupButtonSize, rgbm(0.2, 0.2, 0.2, 1))
                if cui.menuButton("Load", popupButtonSize, 0, 0, 0, false, false, ui.CornerFlags.None) then
                        cui.menuBanner("Loaded Setup", nil, rgbm.colors.green)
                        sm:LoadStuff(carSetup.selected.path)
                        carSetup.current = carSetup.selected.track .. "/" .. carSetup.selected.name
                end

                ui.setCursorX(0)
                ui.drawRectFilled(ui.getCursor(), ui.getCursor() + popupButtonSize, rgbm(0.2, 0.2, 0.2, 1))
                if cui.menuButton("View in Explorer", popupButtonSize, 0, 0, 0, false, false, ui.CornerFlags.None) then
                        os.showInExplorer(carSetup.selected.path)
                end

                -- ui.setCursorX(0)
                -- ui.drawRectFilled(ui.getCursor(), ui.getCursor() + popupButtonSize, rgbm(0.2, 0.2, 0.2, 1))
                -- if cui.menuButton("Rename...", popupButtonSize, 0, 0, 0, false, false, ui.CornerFlags.None) then
                -- end

                -- ui.setCursorX(0)
                -- ui.drawRectFilled(ui.getCursor(), ui.getCursor() + popupButtonSize, rgbm(0.2, 0.2, 0.2, 1))
                -- if cui.menuButton("Move to...", popupButtonSize, 0, 0, 0, false, false, ui.CornerFlags.None) then
                -- end

                ui.setCursorX(0)
                ui.drawRectFilled(ui.getCursor(), ui.getCursor() + popupButtonSize, rgbm(0.2, 0.2, 0.2, 1))
                if cui.menuButton("Delete", popupButtonSize, 0, 0, 0, false, false, ui.CornerFlags.None) then
                        promptDeleteSetup()
                end
        end)

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

function drawSetupIO(sm)
        if ui.keyPressed(ui.Key.Delete) then
                carSetup:delete()
                cui.menuBanner("Deleted Setup", nil, rgbm.colors.red)
        end

        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade, 6 * cui.uiScale())
        drawLocalSetupFilters()

        cui.pushWindow("load_setups", 0, 40, ui.windowWidth(), ui.windowHeight() - 40, true, ui.ButtonFlags.None)
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground, 6 * cui.uiScale())
        drawSetupList()
        cui.popWindow(true)

        return "finalize"
end
