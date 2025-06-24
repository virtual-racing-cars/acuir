local cui = require("src.ui.cui")
local sim = ac.getSim()

local WidgetTab = class("WidgetTab")

function WidgetTab:initialize() end

local Widget = class("Widget")

function Widget:initialize(name)
        self.name = name
        self.docked = false
        self.collapsed = false
        self.pinned = false

        self.customPosition = false

        self.position = vec2(0, 0)
        self.size = vec2(0, 0)

        self.tabs = { name }
        self.currentTab = 1
end

function Widget:addTab(name) table.insert(self.tabs, name) end

function Widget:setPosition(x, y)
        if self.customPosition then return end

        self.position.x = x
        self.position.y = y
end

function Widget:setSize(x, y)
        self.size.x = x
        self.size.y = y
end

function Widget:drawFloatingStyle() end

function Widget:drawMenuStyle()
        cui.pushWidgetWindow(self.name, self.position.x, self.position.y, self.size.x, self.size.y, function()
                for i, tabName in ipairs(self.tabs) do
                        if
                                cui.windowTabButton(
                                        tabName,
                                        36,
                                        ui.ButtonFlags.None,
                                        #self.tabs > 1 and i == self.currentTab
                                )
                        then
                                self.currentTab = i
                        end
                end

                if self.header then self.header() end
        end, self.footer)

        self.body()

        cui.popWidgetWindow()
end

function Widget:draw()
        if not self.docked and (sim.isInMainMenu or sim.isPaused) then
                self:drawMenuStyle()
        else
                self:drawFloatingStyle()
        end
end

return Widget
