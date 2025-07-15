local app = require("app")
local audio = require("audio")
local carSetup = require("src.car_setup")
local cui = require("ui.cui")
local settings = require("settings")
local style = require("src.ui.style")

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local setupTabBar = {}

local function toCapitalCase(str)
        return (str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end))
end

local currentApp = app.state.setupTab - 1

local function tabItem(index, title)
        if
                cui.treeNodeChildButton(
                        title,
                        vec2(ui.availableSpaceX() - 20 * cui.scale(), style.main.font.header.space),
                        currentApp == index,
                        true
                )
        then
                currentApp = index
        end
        cui.offsetCursorY(5)

        if currentApp == index then ui.setScrollY((index - 5) * 48 * cui.scale()) end
end

local scrollDelayTimer = 0

function setupTabBar.body()
        local tabs = sm.setupTabs

        cui.pushWindow("setup_tab_scroll_window", 0, 0, ui.windowWidth(), ui.windowHeight(), true, ui.ButtonFlags.None)

        if ui.windowHovered() and scrollDelayTimer < os.clock() then
                if ui.mouseWheel() > 0 then
                        currentApp = currentApp == 0 and #tabs - 1 or currentApp - 1
                        audio:trigger()
                        scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs / 1000
                elseif ui.mouseWheel() < 0 then
                        currentApp = currentApp >= #tabs - 1 and 0 or currentApp + 1
                        audio:trigger()
                        scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs / 1000
                end
        end

        cui.offsetCursorY(10)
        for i in ipairs(tabs) do
                ui.setCursorX(0)

                tabItem(i - 1, toCapitalCase(tabs[i].name))
        end

        cui.popWindow(true)

        app.state.setupTab = currentApp + 1
end

return setupTabBar
