require("classes.PageManager")
require("ui.common")
local app = require("app")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local style = require("ui.cui.style")
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
                style.main.font.huge.size,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), ui.windowHeight() * 0.35)
        )

        ui.setCursor(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Developed by Virtual Racing Cars (VRC)",
                style.main.font.title.size,
                ui.Alignment.Center,
                ui.Alignment.End,
                vec2(ui.windowWidth(), ui.windowHeight() * 0.35)
        )

        ui.setCursorY(ui.windowHeight() * 0.8)
        if cui.menuButton("Continue", vec2(ui.windowWidth(), 60 * cui.scale())) then
                onboardingAcknowledged = true
                app.state.screenTransition = os.clock() + 0.5
                setTimeout(function() settings.AppData.shownOnboarding = true end, 0.25, "onboarding_acknowledge")
        end

        ui.setCursor(0)
        ui.dwriteTextAligned(
                app.fullInfo,
                style.main.font.body.size,
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

        cui.pushFullWindow("onboarding_window_full")
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground * 0.85)

        if not onboardingAcknowledged then onboardingBody() end

        cui.popWindow()

        return app.state.debug and "debug" or exclusiveHudMode
end
