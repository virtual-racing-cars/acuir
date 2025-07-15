local cui = require("src.ui.cui")

local WidgetWindow = class("WidgetWindow")

function WidgetWindow:initialize(id)
        self.id = id .. "_window"
        self.widgets = {}
        self.activeWidgetIndex = 1

        self.docked = false
        self.collapsed = false
        self.pinned = false

        self.customPosition = false

        self.position = vec2(0, 0)
        self.size = vec2(0, 0)
end

function WidgetWindow:addWidget(name, widget) table.insert(self.widgets, { name = name, widget = widget }) end

function WidgetWindow:setPosition(x, y)
        if self.customPosition then return end

        self.position.x = x
        self.position.y = y
end

function WidgetWindow:setSize(x, y)
        self.size.x = x
        self.size.y = y
end

function WidgetWindow:draw(dt)
        local activeWidget = self.widgets[self.activeWidgetIndex].widget

        cui.pushContentWindow(self.id, self.position.x, self.position.y, self.size.x, self.size.y, function()
                for i, v in ipairs(self.widgets) do
                        if
                                cui.windowTabButton(
                                        v.name,
                                        ui.windowHeight(),
                                        ui.ButtonFlags.None,
                                        self.activeWidgetIndex == i
                                )
                        then
                                self.activeWidgetIndex = i
                        end
                        ui.sameLine()
                end
        end, activeWidget.drawFooter, false)

        activeWidget.body(dt)

        cui.popContentWindow()
end

return WidgetWindow
