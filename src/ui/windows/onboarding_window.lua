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

local vrcLogoFullImage = "assets\\img\\vrc_logo_full.png"
local acuirLogoFullImage = "assets\\img\\acuir_logo_full.png"

local function onboardingBody()
        cui.pushWindow(
                "onboarding_window",
                0,
                ui.windowHeight() * 0.2,
                ui.windowWidth(),
                ui.windowHeight() * 0.6,
                false
        )

        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.5)
        ui.drawRect(vec2(-20, 0), ui.windowSize() + vec2(20), settings.Appearance.uiColorAccent * 0.5)

        ui.setCursor(0)

        cui.offsetCursorY(50)

        local acuirLogoFullImageSize = ui.imageSize(acuirLogoFullImage) * cui.scale() * 0.5

        ui.setCursorX(ui.windowWidth() * 0.5 - acuirLogoFullImageSize.x * 0.5)
        ui.image(acuirLogoFullImage, acuirLogoFullImageSize)
        cui.offsetCursorY(65)

        for i, v in ipairs(settings.Modules) do
                local height = style.main.font.body.size

                ui.setCursorX(ui.windowWidth() * 0.5 - 100)

                local label = v.label

                if i > 3 then label = label .. " (WIP)" end

                local newValue, changed = cui.checkbox(
                        v.label,
                        label,
                        height,
                        settings.Modules[v.key],
                        i > 3 and ui.ButtonFlags.Disabled or ui.ButtonFlags.None
                )
                ui.newLine()
                ui.newLine()

                if changed then settings.Modules[v.key] = newValue end
        end

        cui.offsetCursorY(15)
        ui.setCursorX(ui.windowWidth() * 0.5 - ui.windowWidth() * 0.5)
        if cui.menuButton("Continue", vec2(ui.windowWidth(), 60 * cui.scale())) then
                onboardingAcknowledged = true
                app.state.screenTransition = os.clock() + 0.5
                setTimeout(function() settings.AppData.shownOnboarding = true end, 0.25, "onboarding_acknowledge")
        end

        local vrcLogoFullImageSize = ui.imageSize(vrcLogoFullImage) * cui.scale() * 0.2

        ui.setCursorX(ui.windowWidth() * 0.5 - vrcLogoFullImageSize.x * 0.5)
        ui.offsetCursorY(ui.availableSpaceY() * 0.5 - vrcLogoFullImageSize.y * 0.5)
        ui.image(vrcLogoFullImage, vrcLogoFullImageSize)
        cui.offsetCursorY(30)

        ui.dwriteTextAligned(
                app.fullInfo,
                style.main.font.body.size,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), style.main.font.body.space),
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
