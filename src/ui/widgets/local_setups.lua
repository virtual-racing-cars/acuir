local carSetup = require("car_setup")
local cui = require("ui.cui")
local settings = require("settings")
local style = require("ui.cui.style")

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local localSetupsWidget = {}

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
                        vec2(ui.availableSpaceX(), textBoxHeight)
                )

                local buttonWidth = ui.windowWidth() / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scale())
                if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scale(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scale())
                if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scale(), ui.ButtonFlags.None) then
                        carSetup:delete()
                        cui.menuBanner("Deleted Setup", nil, rgbm.colors.red)

                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end, false)
end

local function drawLocalSetupFilters()
        cui.offsetCursorX(20)
        cui.offsetCursorY(10)
        local hideChanged = false
        settings.General.hideOtherTrackSetups, hideChanged = drawCheckbox(
                "##isSetupIOHidingOtherTracks",
                "Show Other Tracks",
                style.main.font.body.size,
                settings.General.hideOtherTrackSetups
        )
        ui.sameLine()

        if hideChanged then carSetup:load() end

        cui.setCursorX(250)
        local sortChanged = false
        settings.General.sortTrackSetupsAZ, sortChanged = drawCheckbox(
                "##isSetupIOSortingAlpha",
                "Sort A-Z",
                20 * cui.scale(),
                settings.General.sortTrackSetupsAZ
        )

        if sortChanged then carSetup:load() end
end

local function drawSetupNode(setup, track)
        cui.offsetCursorY(5)
        local setupActive = carSetup.selected.path == setup.path
        local name = string.replace(setup.name, ".ini", "")
        local buttonSize = vec2(ui.availableSpaceX() - 20 * cui.scale(), style.main.font.header.space)
        local popupButtonSize = vec2(ui.windowWidth() * 0.3, 32 * cui.scale())

        local clicked, deleteClicked, loadClicked, explorerClicked, hovered =
                cui.setupSelectButton(track .. " / " .. name, setupActive, setup.lastWriteTime)

        if clicked then
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

        if deleteClicked then promptDeleteSetup() end

        if loadClicked then
                cui.menuBanner("Loaded Setup", nil, rgbm.colors.green)
                sm:LoadStuff(carSetup.selected.path)
                carSetup.current = carSetup.selected.track .. "/" .. carSetup.selected.name
        end

        if explorerClicked then os.showInExplorer(carSetup.selected.path) end
end

local function drawSetupList()
        if refreshingSetups then
                ui.icon(ui.Icons.LoadingSpinner, ui.availableSpace())
                return
        end

        ui.setCursorY(0)
        cui.offsetCursorY(10)
        for i, track in ipairs(carSetup.trackList) do
                ui.setCursorX(0)
                if
                        cui.treeNodeButton(track, #carSetup.loaded[track], function()
                                for i in ipairs(carSetup.loaded[track]) do
                                        ui.setCursorX(0)
                                        drawSetupNode(carSetup.loaded[track][i], track)
                                end
                        end, i == 1)
                then
                        carSetup.input.track = track
                end
                cui.offsetCursorY(5)
        end
end

function localSetupsWidget:body()
        if ui.keyPressed(ui.Key.Delete) then
                carSetup:delete()
                cui.menuBanner("Deleted Setup", nil, rgbm.colors.red)
        end

        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade, 6 * cui.scale())
        drawLocalSetupFilters()

        ui.drawRectFilled(
                vec2(0, 40 * cui.scale()),
                ui.windowSize(),
                settings.Appearance.uiColorBackground,
                6 * cui.scale()
        )

        cui.pushWindow(
                "load_setups",
                0,
                40 * cui.scale(),
                ui.windowWidth(),
                ui.windowHeight() - 40 * cui.scale(),
                true,
                ui.ButtonFlags.None
        )
        drawSetupList()
        cui.popWindow(true)

        return "finalize"
end

return localSetupsWidget
