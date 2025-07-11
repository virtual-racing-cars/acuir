local Widget = require("src.classes.Widget")
local cui = require("src.ui.cui")
local settings = require("settings")
local simutils = require("simutils")
local style = require("src.ui.style")
local sim = ac.getSim()

local sessionControlWidget = Widget("Session Control")

function sessionControlWidget:body()
        local driveButtonHeight = ui.windowHeight()

        if
                cui.iconTopBarButton(
                        sim.isOnlineRace and "Vote Restart" or "Restart",
                        ui.Icons.Reset,
                        ui.windowWidth() * 0.5,
                        driveButtonHeight,
                        simutils.sessionRestartable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                        false,
                        0.15
                )
        then
                if sim.isOnlineRace then
                        ac.castVote("restart", true)
                else
                        ac.tryToRestartSession()
                end
        end
        ui.sameLine()

        ui.setCursorY(0)
        if
                cui.iconTopBarButton(
                        sim.isOnlineRace and "Vote Skip Session" or "Skip",
                        ui.Icons.Skip,
                        ui.windowWidth() * 0.5,
                        driveButtonHeight,
                        simutils.sessionSkippable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                        false,
                        0.15
                )
        then
                if sim.isOnlineRace then
                        ac.castVote("skip", true)
                else
                        ac.tryToSkipSession()
                end
        end

        if not ac.canCastVote() and sim.isOnlineRace then
                ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorSecondary * 0.9, 6)
                ui.setCursor(0)
                ui.dwriteTextAligned(
                        "Voting Cooldown %.0f s" % ac.timeToNextVote(),
                        style.main.font.title.size,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        ui.windowSize()
                )
        end
end

return sessionControlWidget
