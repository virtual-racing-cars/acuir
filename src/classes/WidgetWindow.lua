local cui = require("ui.cui")

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
        -- if self.id == "car_setup_window" then self.activeWidgetIndex = 3 end

        local activeWidget = self.widgets[self.activeWidgetIndex].widget
        local isCollapsed = self.isCollapsed

        cui.pushContentWindow(self.id, self.position.x, self.position.y, self.size.x, self.size.y, function()
                -- if ui.button("Collapse") then isCollapsed = not isCollapsed end
                -- ui.sameLine()

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
        end, activeWidget.drawFooter, false, self.isCollapsed)

        if not self.isCollapsed then activeWidget.body(dt) end

        cui.popContentWindow(self.isCollapsed)

        self.isCollapsed = isCollapsed
end

return WidgetWindow
