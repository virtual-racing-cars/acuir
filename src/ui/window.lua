local scale = require("src.ui.scale")
local settings = require("settings")
local style = require("src.ui.style")

local vec2Temp1 = vec2()

local window = {}

function window.child(id, size, border, flags, content) ui.childWindow(id, size, false, flags, content) end

function window.content(id, position, size, flags, content, showBackground, scroll)
        window.push(id .. "test", position.x, position.y, size.x, size.y, scroll, flags)

        content()

        window.pop(scroll, flags)
end

function window.push(id, x, y, width, height, scroll, flags)
        if not flags then flags = 0 end

        local windowFlags = bit.bor(ui.WindowFlags.NoResize + flags)

        if not scroll then windowFlags = windowFlags + ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse end

        local tabWidth = width
        local tabHeight = height

        ui.setCursorX(x)
        ui.setCursorY(y)

        ui.pushStyleVar(ui.StyleVar.WindowPadding, 0)

        ui.beginChild(id, vec2(tabWidth, tabHeight), false, windowFlags)
        ui.setCursor(0)

        if not scroll then ui.pushClipRect(0, vec2(tabWidth, tabHeight)) end
end

function window.pop(scroll, flags)
        if not scroll then
                ui.popClipRect()
        elseif flags ~= ui.WindowFlags.NoScrollWithMouse then
                if ui.getScrollY() < 5 * scale.get() then ui.setScrollY(0) end
                if ui.getScrollMaxY() - ui.getScrollY() < 5 * scale.get() then ui.setScrollY(ui.getScrollMaxY()) end
        end

        ui.endChild()
        ui.popStyleVar(1)
end

function window.pushContent(id, x, y, width, height, headerFunc, footerFunc, hideBackground, noCorners)
        window.push(id .. "_background", x, y, width, height)

        local headerSize = style.main.font.body.space
        local footerSize = headerSize
        local marginSize = 10 * scale.get()
        local innerCurve = 6 * scale.get()

        ui.beginGradientShade()
        ui.drawRectFilled(
                0,
                ui.windowSize(),
                settings.Appearance.uiColorPrimary,
                noCorners and 0 or marginSize + innerCurve
        )
        ui.endGradientShade(
                vec2Temp1:set(ui.windowWidth(), 0),
                ui.windowSize(),
                settings.Appearance.uiColorPrimary,
                settings.Appearance.uiColorBackgroundShade,
                true
        )

        x = marginSize
        y = marginSize
        width = width - marginSize * 2
        height = height - marginSize * 2

        if headerFunc then
                ui.setCursor(0)
                window.push(id .. "_header", x, y, width, headerSize)
                ui.setCursor(0)
                headerFunc()
                window.pop()

                height = height - headerSize
                y = y + headerSize
        end

        if footerFunc then
                height = height - footerSize

                ui.setCursor(0)
                window.push(id .. "_footer", x, y + height + marginSize, width, footerSize - marginSize)
                ui.setCursor(0)
                footerFunc()
                window.pop()
        end

        window.push(id .. "_content", x, y, width, height)

        if not hideBackground then
                ui.drawRectFilled(
                        0,
                        ui.windowSize(),
                        settings.Appearance.uiColorBackground,
                        noCorners and 0 or 12 * scale.get(),
                        ui.CornerFlags.Bottom
                )
        end
end

function window.popContent()
        window.pop()
        window.pop()
end

function window.pushWidget(id, x, y, width, height, headerFunc, footerFunc)
        local id = "WIDGET_" .. id

        window.push(id .. "_WINDOW", x, y, width, height)

        local headerSize = 36 * scale.get()
        local footerSize = 36 * scale.get()
        local marginSize = 8 * scale.get()
        local innerCurve = 6 * scale.get()

        ui.beginGradientShade()
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorPrimary, marginSize + innerCurve)
        ui.endGradientShade(
                vec2Temp1:set(ui.windowWidth(), 0),
                ui.windowSize(),
                settings.Appearance.uiColorPrimary,
                settings.Appearance.uiColorBackgroundShade,
                true
        )

        x = marginSize
        y = marginSize
        width = width - marginSize * 2
        height = height - marginSize * 2

        if headerFunc then
                ui.setCursor(0)
                window.push(id .. "_HEADER", x, y, width, headerSize)
                ui.setCursor(0)
                headerFunc()
                window.pop()

                height = height - headerSize
                y = y + headerSize
        end

        if footerFunc then
                height = height - footerSize

                ui.setCursor(0)
                window.push(id .. "_FOOTER", x, y + height + marginSize, width, footerSize - marginSize)
                ui.setCursor(0)
                footerFunc()
                window.pop()
        end

        window.push(id .. "_BODY", x, y, width, height)

        ui.drawRectFilled(
                0,
                ui.windowSize(),
                settings.Appearance.uiColorBackground,
                6 * scale.get(),
                ui.CornerFlags.All
        )
end

function window.popWidget()
        window.pop()
        window.pop()
end

function window.pushFitted(id, flags, scroll)
        local childWindowWith = (2560 - 60) * scale.get()
        local childWindowHeight = (1440 - 60) * scale.get()

        window.push(
                id,
                (ui.windowWidth() - childWindowWith) * 0.5,
                (ui.windowHeight() - childWindowHeight) * 0.5,
                childWindowWith,
                childWindowHeight,
                scroll
        )
end

function window.pushFull(id, flags, scroll) window.push(id, 0, 0, ui.windowWidth(), ui.windowHeight(), scroll) end

function window.getWindow(windowName)
        local appWindows = ac.getAppWindows()
        local window = nil

        for i = 1, #appWindows do
                local app = appWindows[i]
                if app ~= nil and app.title == windowName and app.name ~= nil then
                        window = ac.accessAppWindow(app.name)
                end
        end
        return window
end

return window
