local cui = require("src.ui.cui")
local sim = ac.getSim()

local WidgetTab = class("WidgetTab")

function WidgetTab:initialize() end

local Widget = class("Widget")

function Widget:initialize(name)
        self.name = name
        self.docked = false

        self.position = vec2(0, 0)
        self.size = vec2(0, 0)

        self.tabs = {}
        self.currentTab = 0
end

function Widget:drawFloatingStyle() end

function Widget:drawMenuStyle(body, header, footer)
        cui.pushContentWindow(
                "lap_times_window",
                0,
                0,
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 255 * cui.uiScale(),
                header,
                footer
        )

        cui.popContentWindow()
end

function Widget:draw()
        if sim.isLive then
                self:drawFloatingStyle()
        else
                self:drawMenuStyle()
        end
end
