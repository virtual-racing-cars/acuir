local app = require("app")
local csp = require("csp")
local cui = require("src.ui.cui")
local settings = require("settings")
local style = require("style")

ac.setWindowOpen("entryWindow", true)

function script.entryWindow(dt)
        style:pushFontRegular()

        local windowSize = vec2(300, 450) * cui.uiScale()

        cui.pushContentWindow(
                "entry_point_window",
                0,
                0,
                windowSize.x,
                windowSize.y,
                function()
                        ui.dwriteTextAligned(
                                app.name,
                                32 * cui.uiScale(),
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
                ui.newLine()
                for i, v in ipairs(settings.Modules) do
                        local height = 18 * cui.uiScale()

                        ui.setCursorX(ui.windowWidth() * 0.5 - height * 7)

                        local newValue, changed = drawCheckbox(
                                v.label,
                                v.label,
                                height,
                                settings.Modules[v.key],
                                i > 3 and ui.ButtonFlags.Disabled or ui.ButtonFlags.None
                        )
                        ui.newLine()
                        ui.newLine()

                        if changed then settings.Modules[v.key] = newValue end
                end

                if
                        cui.menuButton(
                                app.state.appOpen and "Disable HUD" or "Enable HUD",
                                vec2(ui.windowWidth(), 36 * cui.uiScale())
                        )
                then
                        settings.Modules.autoStart = not app.state.appOpen
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
