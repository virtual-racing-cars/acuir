local cui = require("src.ui.cui")

local WidgetWindow = class("WidgetWindow")

function WidgetWindow:initialize(id)
        self.id = id .. "_window"
        self.widgets = {}
        self.activeWidgetIndex = 3
end

function WidgetWindow:addWidget(name, widget) table.insert(self.widgets, { name = name, widget = widget }) end

function WidgetWindow:draw(dt)
        local activeWidget = self.widgets[self.activeWidgetIndex]

        cui.pushContentWindow(
                self.id,
                0,
                0,
                ui.windowWidth() * 0.22,
                ui.windowHeight() * 0.75 - 7.5 * cui.uiScale(),
                function()
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
                end,
                activeWidget.drawFooter and activeWidget:drawFooter() or nil,
                false
        )

        activeWidget.widget()

        cui.popContentWindow()
end

return WidgetWindow
