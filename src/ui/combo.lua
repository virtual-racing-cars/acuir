local cursor = require("src.ui.cursor")
local scale = require("src.ui.scale")
local settings = require("settings")
local state = require("src.ui.state")
local style = require("src.ui.style")
local window = require("src.ui.window")

local combo = {}

function combo.box(id, size, previewValue, previewAlignment, openDown, contentSize, content)
        local id = "##combo" .. id
        local sp1 = ui.cursorScreenPos()
        local clicked = ui.invisibleButton("##comboCurrentCamera", size)
        local hovered = ui.itemHovered() --and not CUI.modalDialogCallback
        local r1, r2 = ui.itemRect()
        local color = settings.Appearance.uiColorText * 0.75
        local open = state.loadStoredBool(id, false)
        local closedIcon = openDown and ui.Icons.Down or ui.Icons.Up
        local openIcon = openDown and ui.Icons.Up or ui.Icons.Down
        local iconAlignemnt = 0.98
        local justOpened = false

        if previewAlignment == ui.Alignment.End then iconAlignemnt = 0.02 end

        if hovered then color = settings.Appearance.uiColorSecondary end
        if clicked then
                state.storeBool(id, not open)
                if not open then justOpened = true end
        end

        ui.drawRect(r1, r2, color, 6 * scale.get())
        ui.addIcon(
                open and openIcon or closedIcon,
                vec2(size.y, size.y) * 0.35,
                vec2(iconAlignemnt, 0.5),
                settings.Appearance.uiColorText
        )

        ui.setCursor(r1)
        cursor.offsetX(10)
        cursor.snap()
        ui.dwriteTextAligned(
                previewValue,
                size.y * 0.5,
                previewAlignment,
                ui.Alignment.Center,
                vec2(size.x - 10 * scale.get(), size.y),
                false,
                settings.Appearance.uiColorText
        )

        local comboOpenPosition = openDown and sp1 + vec2(0, size.y - 5 * scale.get())
                or sp1 - vec2(0, contentSize.y + 5 * scale.get())

        if open then
                ui.transparentWindow(id, comboOpenPosition, contentSize, true, true, function()
                        style:pushStyleMain()
                        ui.bringWindowToFront()
                        ui.setCursor(0)

                        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground, 6 * scale.get())
                        window.push(
                                id .. "scroll_window",
                                0,
                                10 * scale.get(),
                                ui.windowWidth(),
                                ui.windowHeight() - 20 * scale.get(),
                                true
                        )

                        -- if justOpened then ui.setScrollY(0) end

                        content()

                        if
                                not clicked
                                and open
                                and ui.mouseReleased(ui.MouseButton.Left)
                                and not ui.rectHovered(0, vec2(ui.windowWidth(), 10000))
                        then
                                state.storeBool(id, false)
                        end

                        window.pop(true)
                        style:popStyleMain()

                        ui.drawRect(0, ui.windowSize(), settings.Appearance.uiColorText * 0.75, 6 * scale.get())
                end)
        end
end

return combo
