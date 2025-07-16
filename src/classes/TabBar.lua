local audio = require("audio")
local cui = require("ui.cui")
local settings = require("settings")
local style = require("ui.cui.style")

local TabBar = class("TabBar")

function TabBar:initialize(id)
        self.id = id
        self.currentTab = 1
        self.scrollDelayTimer = 0
end

function TabBar:draw(tabs)
        if ui.windowHovered() and self.scrollDelayTimer < os.clock() then
                if ui.mouseWheel() > 0 then
                        self.currentTab = self.currentTab == 1 and #tabs or self.currentTab - 1
                        audio:trigger()
                        self.scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs / 1000
                elseif ui.mouseWheel() < 0 then
                        self.currentTab = self.currentTab >= #tabs and 1 or self.currentTab + 1
                        audio:trigger()
                        self.scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs / 1000
                end
        end

        ui.setCursorX(0)
        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColorPrimary)
        cui.setCursorY(10)
        for i in ipairs(tabs) do
                if
                        cui.treeNodeChildButton(
                                toCapitalCase(tabs[i].name),
                                vec2(ui.availableSpaceX() - 20 * cui.scale(), style.main.font.header.space),
                                self.currentTab == i,
                                true
                        )
                then
                        self.currentTab = i
                end

                cui.offsetCursorY(5)

                if self.currentTab == i then ui.setScrollY((i - 5) * 48 * cui.scale()) end
        end

        ui.popStyleColor(1)

        return tabs[self.currentTab]
end

return TabBar
