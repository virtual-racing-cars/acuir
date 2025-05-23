package.add("src")
require("ui.main_menu_window")
require("ui.pause_window")
require("ui.pitstop_window")
require("ui.results_window")
require("ui.settings_window")
require("audio")
local app = require("app")
local audio = require("audio")
local callback = require("callback")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages")
local pitstop = require("pitstop")
local race = require("race")
local replay = require("replay")
local settings = require("settings")
local simutils = require("simutils")

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false

local modeLast = ""

ui.onExclusiveHUD(function(mode)
        if not app.state.appOpen or ac.getLastError() then return end

        if mode == "menu" and app.state.setupTab ~= 1 then ui.forceSimplifiedComposition() end

        local dt = ac.getScriptDeltaT()

        if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                SettingsWindow(dt)
                return ""
        end

        if mode == "menu" then
                -- pages:goToSetup()
                -- pages:goToSettings()
                -- pages:goToSettingsGeneral()
                -- pages:goToSession()
                -- pages:goToSession()
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentMainMenu() end

                modeLast = mode

                local voteDetails = ac.getCurrentVoteDetails()
                if voteDetails then
                        if voteDetails.type ~= "unknown" then
                                cui.menuBanner(
                                        string.upper(
                                                string.format(
                                                        "Vote %s %s %s",
                                                        voteDetails.type,
                                                        voteDetails.type == "kick"
                                                                        and ac.getDriverName(voteDetails.targetIndex)
                                                                or "Session",
                                                        voteDetails.voted and "" or "Yes [Y] No [N]"
                                                )
                                        ),
                                        voteDetails.timeLeft,
                                        rgbm.colors.red,
                                        true,
                                        "vote"
                                )
                        end
                end

                return MainMenuWindow(dt)
        end

        -- if mode == "replay" then
        --         audio:driver(dt)

        --         if modeLast ~= mode then pages:setParentMainMenu() end

        --         modeLast = mode

        --         return MainMenuWindow(dt)
        -- end

        if mode == "results" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentResultsMenu() end
                modeLast = mode

                return ResultsMenuWindow()
        end

        if mode == "pause" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentPauseMenu() end
                modeLast = mode

                return PauseMenuWindow()
        end

        if mode == "game" then
                if modeLast ~= mode then pages:setParentMainMenu() end
        end

        modeLast = mode
end)

local fov = csp.sim.cameraFOV

if not app.state.debug then ac.log = function() end end

local isInMainMenuLast = csp.sim.isInMainMenu

function script.update(dt)
        if csp.ui.ctrlDown and csp.ui.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
                settings.General.autoStart = not app.state.appOpen
                app.state.appOpen = not app.state.appOpen
        end

        if app.state.appOpen and csp.sim.isInMainMenu then
                ac.tryToOpenRaceMenu(nil)
                ac.tryToOpenRaceMenu("setup")
        end

        if not app.state.appOpen or ac.getLastError() then
                pitstop:setWindowOpen(false)
                ac.disableQuickMenuPitstop(false)
                return
        end

        if csp.sim.isInMainMenu then
                ac.tryToOpenRaceMenu(nil)
                ac.tryToOpenRaceMenu("setup")

                if ui.mouseDown(ui.MouseButton.Right) or cui.menuZoomAvailable and ui.mouseWheel() ~= 0 then
                        fov = math.clamp(fov - ui.mouseWheel(), 20, 90)
                end

                if
                        ui.mouseDown(ui.MouseButton.Right)
                        or (csp.sim.cameraMode == ac.CameraMode.OnBoardFree or csp.sim.cameraMode == ac.CameraMode.Free)
                then
                        ac.setCameraFOV(fov)
                else
                        fov = csp.sim.cameraFOV
                end
        else
                fov = csp.sim.cameraFOV
        end

        if isInMainMenuLast ~= csp.sim.isInMainMenu then
                if isInMainMenuLast then sm:saveSetup(string.format("_%s_last.ini", ac.getTrackID())) end

                isInMainMenuLast = csp.sim.isInMainMenu
        end

        race:step()
        pitstop:step(dt)
        -- replay:step(dt)

        if callback.sim then
                if callback.sim() then callback.sim = nil end
        end

        local redirectVM = (csp.sim.isInMainMenu and ac.isWindowOpen("main")) or csp.sim.isPaused
        ac.redirectVirtualMirror(redirectVM)
end

function script.pause() end
