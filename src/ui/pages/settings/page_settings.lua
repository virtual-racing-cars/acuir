local page = {}

local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")

local settingsPages = {
        {
                label = "General",
                icon = ui.Icons.AppWindow,
                enabled = true,
                func = function() pages:goToSettingsGeneral() end,
        },
        {
                label = "Controls",
                icon = ui.Icons.SteeringWheel,
                enabled = false,
                func = function() pages:goToSettingsControls() end,
        },
        {
                label = "Audio",
                icon = ui.Icons.Music,
                enabled = false,
                func = function() pages:goToSettingsAudio() end,
        },
        {
                label = "Appearance",
                icon = ui.Icons.Contrast,
                enabled = false,
                func = function() pages:goToSettingsAppearance() end,
        },
        -- {
        -- 	label = "AI",
        -- 	icon = ui.Icons.AppWindow,
        -- 	enabled = false,
        -- 	func = function()
        -- 		pages:goToSettingsAi()
        -- 	end,
        -- },
}

function page.draw()
        cui.pushWindowFitted("settings_page_window")

        local rowWidth = 1924 * cui.uiScale()
        ui.setCursorX((ui.windowWidth() - rowWidth) / 2)
        cui.setCursorY(366)

        ui.pushStyleVar(ui.StyleVar.ItemSpacing, 122 * cui.uiScale())
        ui.beginGroup()

        for i = 1, #settingsPages do
                local page = settingsPages[i]

                if
                        cui.settingsButton(
                                page.label,
                                560 * cui.uiScale(),
                                300 * cui.uiScale(),
                                page.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                                page.icon
                        )
                then
                        page.func()
                end

                ui.sameLine()
                if i == 3 then
                        ui.setCursorX((ui.windowWidth() - rowWidth) / 2)
                        cui.offsetCursorY(422)
                end
        end

        ui.endGroup()
        ui.popStyleVar(1)

        bottomBar({
                {
                        label = "BACK",
                        enabled = true,
                        func = function() pages:undo() end,
                },
        })

        cui.popWindow()
        return ""
end

return page
