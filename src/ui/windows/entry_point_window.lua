local app = require("app")
local csp = require("csp")
local cui = require("ui.cui")
local settings = require("settings")
local style = require("ui.cui.style")

ac.setWindowOpen("entryWindow", true)

function script.entryWindow(dt)
        style:pushFontRegular()

        cui.pushContentWindow(
                "entry_point_window",
                0,
                0,
                300 * cui.scale(),
                350 * cui.scale(),
                function()
                        ui.dwriteTextAligned(
                                app.name,
                                32 * cui.scale(),
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                ui.windowSize()
                        )
                end,
                function()
                        ui.dwriteTextAligned(
                                app.fullInfo,
                                style.main.font.body.size,
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
                cui.offsetCursorY(15)
                local height = style.main.font.body.size
                for i, v in ipairs(settings.Modules) do
                        cui.setCursorX(15)

                        local newValue, changed = cui.checkbox(
                                v.label,
                                v.label,
                                height,
                                settings.Modules[v.key],
                                i > 3 and ui.ButtonFlags.Disabled or ui.ButtonFlags.None
                        )
                        cui.offsetCursorY(5)

                        if changed then settings.Modules[v.key] = newValue end
                end

                cui.setCursorX(15)
                if
                        cui.menuButton(
                                app.state.appOpen and "Disable" or "Enable",
                                vec2(ui.windowWidth() - 30 * cui.scale(), height * 2)
                        )
                then
                        app.state.appOpen = not app.state.appOpen
                        settings.Modules.autoStart = app.state.appOpen
                end
        else
                ui.dwriteTextAligned(
                        string.format("Below minimum CSP version!\nMin: %s", csp.minVersionString),
                        style.main.font.body.size,
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
