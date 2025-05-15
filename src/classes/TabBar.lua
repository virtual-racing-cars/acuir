local audio = require("audio")
local cui = require("ui.cui")
local settings = require("settings")

TabBar = class("TabBar")

function TabBar:initialize(id)
        self.id = id
        self.currentTab = 1
        self.position = 0
        self.itemPositions = { [0] = 0 }
        self.scrollDisabled = false

        ac.onResolutionChange(function(newSize, makingScreenshot)
                for i in ipairs(self.itemPositions) do
                        self.itemPositions[i] = nil
                end
                self.currentTab = 1
                self.position = 0
        end)
end

function TabBar:draw(tabs)
        if ui.mouseLocalPos() >= vec2(0, 0) and ui.mouseLocalPos() < vec2(ui.windowWidth(), 56 * cui.uiScale()) then
                if ui.mouseWheel() > 0 then
                        self.currentTab = self.currentTab >= #tabs and 1 or self.currentTab + 1
                        audio:trigger()
                elseif ui.mouseWheel() < 0 then
                        self.currentTab = self.currentTab == 1 and #tabs or self.currentTab - 1
                        audio:trigger()
                end
        end

        if not self.scrollDisabled and self.itemPositions[self.currentTab] then
                self.position = math.applyLag(
                        self.position,
                        -math.max(self.itemPositions[self.currentTab] - ui.windowWidth() / 2, 0),
                        0.4,
                        ac.getScriptDeltaT()
                )
        end

        ui.setCursorX(self.position)
        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiThemeColor1)
        for i in ipairs(tabs) do
                local buttonSize = self.scrollDisabled and vec2(ui.windowWidth() / #tabs, 56 * cui.uiScale()) or 56
                if
                        cui.menuButton(
                                tabs[i].name,
                                buttonSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                ui.ButtonFlags.None,
                                self.currentTab == i
                        )
                then
                        self.currentTab = i
                end

                ui.sameLine()
                ui.offsetCursorX(-1)

                if not self.itemPositions[i] then self.itemPositions[i] = ui.getCursorX() end
        end

        if self.itemPositions[#tabs] <= ui.windowWidth() then self.scrollDisabled = true end

        ui.popStyleColor(1)

        return tabs[self.currentTab]
end
