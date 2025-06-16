local app = require("app")
local csp = require("csp")
local cui = require("src.ui.cui")
local settings = require("settings")
local style = require("style")

ac.setWindowOpen("entryWindow", true)

function script.entryWindow(dt)
        style:pushFontRegular()

        local windowSize = vec2(475, 175) * cui.uiScale()

        cui.pushContentWindow(
                "entry_point_window",
                0,
                0,
                windowSize.x,
                windowSize.y,
                function()
                        ui.dwriteTextAligned(
                                "ACUIR",
                                ui.windowHeight() * 0.75,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                ui.windowSize()
                        )
                end,
                function()
                        ui.dwriteTextAligned(
                                app.fullInfo,
                                18 * cui.uiScale(),
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                ui.windowSize(),
                                false,
                                settings.Appearance.uiColorTextDim
                        )
                end,
                false
        )
        ui.setCursor(0)

        if csp.versionAllowed then
                if cui.menuButton("Enable HUD", ui.windowSize()) then
                        settings.General.autoStart = not app.state.appOpen
                        app.state.appOpen = not app.state.appOpen
                end
        else
                ui.dwriteTextAligned(
                        string.format("Below minimum CSP version!\nMin: %s", csp.minVersionString),
                        18 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        ui.windowSize(),
                        false,
                        settings.Appearance.uiColorError
                )
        end

        cui.popContentWindow()

        ui.popDWriteFont()
end
