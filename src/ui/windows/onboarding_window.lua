require("classes.PageManager")
require("ui.common")
local app = require("app")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local style = require("style")
local sim = ac.getSim()

if settings.AppData.shownOnboarding == false then
        app.appOpen = true
        settings.General.autoStart = true
end

local onboardingAcknowledged = false

local function onboardingBody()
        cui.pushWindow(
                "onboarding_window",
                0,
                ui.windowHeight() * 0.3,
                ui.windowWidth(),
                ui.windowHeight() * 0.4,
                false
        )

        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.5)

        ui.setCursor(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "ACUIR",
                100 * cui.uiScale(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), ui.windowHeight() * 0.35)
        )

        ui.setCursor(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Quick Setup",
                30 * cui.uiScale(),
                ui.Alignment.Center,
                ui.Alignment.End,
                vec2(ui.windowWidth(), ui.windowHeight() * 0.35)
        )

        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() * 0.475)

        for i, v in ipairs(settings.Modules) do
                local height = style.main.font.bodyLarge.size

                ui.setCursorX(ui.windowWidth() * 0.5 - height * 6)

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

        ui.setCursorY(ui.windowHeight() * 0.8)
        if cui.menuButton("Continue", vec2(ui.windowWidth(), 60 * cui.uiScale())) then
                onboardingAcknowledged = true
                app.state.screenTransition = os.clock() + 0.5
                setTimeout(function() settings.AppData.shownOnboarding = true end, 0.25, "onboarding_acknowledge")
        end

        ui.setCursor(0)
        ui.dwriteTextAligned(
                app.fullInfo,
                style.main.font.bodyLarge.size,
                ui.Alignment.Center,
                ui.Alignment.End,
                ui.windowSize(),
                false,
                settings.Appearance.uiColorTextDim
        )

        cui.popWindow(false)
end

function OnboardingWindow(dt)
        local exclusiveHudMode = ""

        style:pushStyleMain()
        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

        cui.pushWindowFull("onboarding_window_full")
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground * 0.85)

        if not onboardingAcknowledged then onboardingBody() end

        cui.popWindow()

        style:popStyleMain()

        return app.state.debug and "debug" or exclusiveHudMode
end
