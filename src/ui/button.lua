local callback = require("src.ui.callback")
local cursor = require("src.ui.cursor")
local scale = require("src.ui.scale")
local settings = require("settings")
local state = require("src.ui.state")
local style = require("src.ui.style")
local sim = ac.getSim()

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local button = {}

function button.button(label, sizeX, sizeY, fontSize, horizontalAligment, verticalAlignment, flags, fontColor)
        if not horizontalAligment then horizontalAligment = ui.Alignment.Center end

        if not verticalAlignment then verticalAlignment = ui.Alignment.Center end

        if not flags then flags = ui.ButtonFlags.None end

        local textWidth = ui.measureDWriteText(string.upper(label), fontSize * scale.get()).x
        local fontColor = fontColor

        if flags == ui.ButtonFlags.Disabled then
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
                ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
        end

        local tempCursor = ui.getCursor()
        local clicked =
                ui.button("##" .. label, vec2Temp1:set(textWidth + 30 * scale.get(), sizeY * scale.get()), flags)
        local hovered = ui.itemHovered() and not callback.modalDialog

        if flags == ui.ButtonFlags.Disabled then ui.popStyleColor(1) end

        ui.sameLine()
        ui.offsetCursorY(1)
        ui.setCursor(tempCursor)

        ui.dwriteTextAligned(
                string.upper(label),
                fontSize * scale.get(),
                horizontalAligment,
                verticalAlignment,
                vec2Temp1:set(textWidth + 30 * scale.get(), sizeY * scale.get()),
                false,
                fontColor
        )

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.settings(label, sizeX, sizeY, flags, icon)
        local fontSize = sizeY / 5

        local disabled = flags == ui.ButtonFlags.Disabled
        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, vec2Temp1:set(sizeX, sizeY), flags)
        local hovered = ui.itemHovered() and not callback.modalDialog
        local r1, r2 = ui.itemRect()

        local buttonColor = settings.Appearance.uiColorPrimary
        local fontColor = settings.Appearance.uiColorText

        if hovered and not disabled then buttonColor = settings.Appearance.uiColorSecondary end
        if disabled then fontColor = settings.Appearance.uiColorTextDim end

        ui.drawRectFilled(r1, r2, buttonColor, 12 * scale.get())

        ui.addIcon(icon, vec2Temp1:set(sizeY / 4, sizeY / 4), vec2Temp2:set(0.5, 0.25), fontColor)

        if not ui.itemHovered() or disabled then
                ui.drawRect(r1, r2, disabled and rgbm.colors.gray or rgbm.colors.white, 12 * scale.get())
        end

        ui.setCursor(tempCursor)

        style:pushFontBold()
        ui.dwriteTextAligned(
                string.upper(label),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2Temp1:set(sizeX, sizeY * 1.4),
                false,
                fontColor
        )
        ui.popDWriteFont()

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.modal(label, sizeX, sizeY, flags)
        local fontSize = sizeY / 2

        local disabled = flags == ui.ButtonFlags.Disabled

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, vec2Temp1:set(sizeX, sizeY), flags)
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()

        local buttonColor = settings.Appearance.uiColorPrimary

        if hovered then buttonColor = settings.Appearance.uiColorSecondary end

        ui.drawRectFilled(r1, r2, buttonColor, 6 * scale.get())

        if not hovered or disabled then
                ui.drawRect(
                        r1,
                        r2,
                        disabled and rgbm.colors.gray or rgbm.colors.white,
                        6 * scale.get(),
                        ui.CornerFlags.All,
                        1
                )
        end

        ui.sameLine()
        ui.offsetCursorY(1)
        ui.setCursor(tempCursor)

        style:pushFontBold()
        ui.dwriteTextAligned(
                string.upper(label),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2Temp1:set(sizeX, sizeY),
                false,
                rgbm.colors.white
        )

        ui.popDWriteFont()

        return (clicked and not (flags == ui.ButtonFlags.Disabled))
                or (label == "Confirm" and not settings.UI.showConfirmDialogs)
end

function button.selectable(label, horizontalAligment)
        horizontalAligment = horizontalAligment or ui.Alignment.Center

        cursor.offsetCursorX(10)

        local fontSize = style.main.font.body.size
        local fontSpace = style.main.font.body.space
        local size = vec2(ui.availableSpaceX() - 10 * scale.get(), fontSpace)

        local clicked = ui.invisibleButton("##selectable_" .. label, size, ui.ButtonFlags.None)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.modalDialog

        local buttonColor = settings.Appearance.uiColorPrimary
        local fontColor = settings.Appearance.uiColorText

        if hovered then buttonColor = settings.Appearance.uiColorSecondary end

        ui.drawRectFilled(r1, r2, buttonColor, 6 * scale.get())

        ui.setCursor(r1)

        if horizontalAligment ~= 0 then cursor.offsetX(10 * -horizontalAligment) end

        cursor.snap()
        ui.dwriteTextAligned(label, fontSize, horizontalAligment, 0, size, false, fontColor)

        return clicked
end

function button.menu(label, size, horizontalAligment, verticalAlignment, flags, active, bold, cornerFlags)
        if not horizontalAligment then horizontalAligment = ui.Alignment.Center end
        if not verticalAlignment then verticalAlignment = ui.Alignment.Center end
        if not flags then flags = ui.ButtonFlags.None end
        if not cornerFlags then cornerFlags = ui.CornerFlags.All end

        if bold then
                style:pushFontBold()
        else
                style:pushFontRegular()
        end

        local sizeX, sizeY, buttonSize, fontSize

        if type(size) == "number" then
                size = size * scale.get()
                sizeY = size
                fontSize = sizeY * 0.45
                buttonSize = vec2Temp1:set(
                        math.round(ui.measureDWriteText(string.upper(label), fontSize).x + 50 * scale.get()),
                        size
                )
        else
                fontSize = size.y * 0.5
                buttonSize = size
        end

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, buttonSize, flags)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.modalDialog

        local buttonColor = settings.Appearance.uiColorPrimary
        local fontColor = settings.Appearance.uiColorText

        if flags == ui.ButtonFlags.Disabled then
                buttonColor = settings.Appearance.uiColorPrimary * 0.75
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
        elseif hovered then
                buttonColor = settings.Appearance.uiColorSecondary
        elseif active then
                buttonColor = settings.Appearance.uiColorAccent
                fontColor = rgbm.colors.black
        end

        ui.drawRectFilled(r1, r2, buttonColor, 6 * scale.get(), cornerFlags)

        ui.setCursor(r1)
        cursor.snap()
        ui.dwriteTextAligned(
                string.upper(label),
                fontSize,
                horizontalAligment,
                verticalAlignment,
                buttonSize,
                false,
                fontColor
        )

        ui.popDWriteFont()

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.windowTab(label, size, flags, active)
        if not flags then flags = ui.ButtonFlags.None end

        style:pushFontRegular()

        local sizeX, sizeY, buttonSize, fontSize

        size = size * scale.get()
        sizeY = size
        fontSize = style.main.font.body.size
        buttonSize = vec2Temp1:set(
                math.round(ui.measureDWriteText(string.upper(label), fontSize).x + 30 * scale.get()),
                size
        )

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, buttonSize, flags)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.modalDialog

        local buttonColor = rgbm.colors.transparent
        local fontColor = settings.Appearance.uiColorText

        if flags == ui.ButtonFlags.Disabled then
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
        elseif hovered then
                fontColor = settings.Appearance.uiColorSecondary
        elseif active then
                buttonColor = settings.Appearance.uiColorSecondary
                fontColor = settings.Appearance.uiColorText
        end

        if active then buttonColor = settings.Appearance.uiColorSecondary end

        -- fontColor = settings.Appearance.uiColorSecondary

        ui.drawRectFilled(vec2(r1.x, r1.y + size * 0.9), r2, buttonColor, 6, ui.CornerFlags.Top)

        ui.setCursor(tempCursor)
        cursor.snap()
        ui.dwriteTextAligned(string.upper(label), fontSize, 0, 0, buttonSize, false, fontColor)

        ui.popDWriteFont()

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.binding(name, label, binder, size, flags)
        local sizeX = size.x
        local sizeY = size.y
        local fontSize = math.floor(sizeY * 0.4)

        if not flags then flags = ui.ButtonFlags.None end
        -- if flags == ui.ButtonFlags.Disabled then fontColor = settings.Appearance.uiColorTextDim end

        local clicked = ui.invisibleButton("##" .. button.bind, size, flags)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.modalDialog

        local buttonColor = settings.Appearance.uiColorBackgroundShade
        local textColor = settings.Appearance.uiColorText

        if hovered then
                buttonColor = settings.Appearance.uiColorAccent
                textColor = settings.Appearance.uiColorBackground
        end

        if binder._button:down() then buttonColor = settings.Appearance.uiColorSecondary end

        -- if hovered and ui.mouseClicked(ui.MouseButton.Right) then button:unbind(i) end
        ui.drawRectFilled(r1, r2, buttonColor, 6 * scale.get())
        ui.setCursor(r1)

        ui.itemPopup("##unbinding" .. binder.bind, ui.MouseButton.Right, function()
                local popupButtonSize = vec2(200, 30) * scale.get()

                ui.drawRectFilled(0, vec2(200, 30 * 3), rgbm(0.2, 0.2, 0.2, 1))

                ui.setCursor(0)

                if
                        button.menu(
                                "Unbind Keyboard",
                                popupButtonSize,
                                0,
                                0,
                                binder.inputModeBound[3] and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                                false,
                                false,
                                ui.CornerFlags.None
                        )
                then
                        binder:unbind(3)
                        ui.closePopup()
                end

                ui.setCursorX(0)
                if
                        button.menu(
                                "Unbind Gamepad",
                                popupButtonSize,
                                0,
                                0,
                                binder.inputModeBound[2] and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                                false,
                                false,
                                ui.CornerFlags.None
                        )
                then
                        binder:unbind(2)
                        ui.closePopup()
                end

                ui.setCursorX(0)
                if
                        button.menu(
                                "Unbind Controller",
                                popupButtonSize,
                                0,
                                0,
                                binder.inputModeBound[1] and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                                false,
                                false,
                                ui.CornerFlags.None
                        )
                then
                        binder:unbind(1)
                        ui.closePopup()
                end
        end)

        cursor.offsetX(30)
        cursor.snap()
        ui.dwriteTextAligned(
                name .. " " .. label,
                24 * scale.get(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(sizeX * 0.4 - 30 * scale.get(), sizeY),
                false,
                textColor
        )
        ui.sameLine()

        for i = 3, 1, -1 do
                local boundDeviceID, buttonID = button:boundTo(i)
                local disabled = (sim.inputMode + 1 == 3 and i ~= 3) or (sim.inputMode + 1 == 1 and i == 2)
                local tempCursor = ui.getCursor()

                cursor.offsetY(boundDeviceID == "" and 0 or -size.y * 0.1)
                cursor.snap()
                ui.dwriteTextAligned(
                        buttonID,
                        fontSize,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(sizeX * 0.2, sizeY),
                        false,
                        disabled and settings.Appearance.uiColorTextDim or textColor
                )

                ui.setCursor(tempCursor)
                cursor.snap()
                ui.dwriteTextAligned(
                        boundDeviceID,
                        fontSize * 0.5,
                        ui.Alignment.Center,
                        ui.Alignment.End,
                        vec2(sizeX * 0.2, sizeY),
                        false,
                        disabled and settings.Appearance.uiColorTextDim or textColor
                )

                ui.sameLine()
        end

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.bindingAxle(name, label, button, size, flags)
        local sizeX = size.x
        local sizeY = size.y
        local fontSize = math.floor(sizeY * 0.4)

        if not flags then flags = ui.ButtonFlags.None end
        -- if flags == ui.ButtonFlags.Disabled then fontColor = settings.Appearance.uiColorTextDim end

        local clicked = ui.invisibleButton("##" .. button.bind, size, flags)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.modalDialog

        local buttonColor = settings.Appearance.uiColorBackgroundShade
        local textColor = settings.Appearance.uiColorText

        if hovered then
                buttonColor = settings.Appearance.uiColorAccent
                textColor = settings.Appearance.uiColorBackground
        end

        -- if hovered and ui.mouseClicked(ui.MouseButton.Right) then button:unbind(i) end
        ui.drawRectFilled(r1, r2, buttonColor, 6 * scale.get())

        if button.isCentered and button.inputModeBound then
                local axisValue = button:getValue()

                ui.drawRectFilled(
                        vec2(r1.x + size.x * 0.5 + size.x * 0.5 * math.min(axisValue, 0), r1.y),
                        vec2(r1.x + size.x * 0.5, r2.y),
                        settings.Appearance.uiColorSecondary,
                        6 * scale.get(),
                        ui.CornerFlags.Left
                )

                ui.drawRectFilled(
                        vec2(r1.x + size.x * 0.5, r1.y),
                        vec2(r1.x + size.x * 0.5 + size.x * 0.5 * math.max(axisValue, 0), r2.y),
                        settings.Appearance.uiColorSecondary,
                        6 * scale.get(),
                        ui.CornerFlags.Right
                )
        elseif button.inputModeBound then
                local axisValue = math.clamp((button:getValue() - button.min) / (button.max - button.min), -1, 1)

                ui.drawRectFilled(
                        r1,
                        vec2(r1.x + size.x * math.max(axisValue, 0), r2.y),
                        settings.Appearance.uiColorSecondary,
                        6 * scale.get(),
                        ui.CornerFlags.All
                )
        end

        ui.setCursor(r1)

        ui.itemPopup("##unbinding" .. button.bind, ui.MouseButton.Right, function()
                local popupButtonSize = vec2(200, 30) * scale.get()

                ui.drawRectFilled(0, vec2(200, 30), rgbm(0.2, 0.2, 0.2, 1))

                ui.setCursor(0)

                if
                        button.menu(
                                "Unbind Axle",
                                popupButtonSize,
                                0,
                                0,
                                button.inputModeBound and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                                false,
                                false,
                                ui.CornerFlags.None
                        )
                then
                        button:unbind()
                        ui.closePopup()
                end
        end)

        cursor.offsetX(30)
        cursor.snap()
        ui.dwriteTextAligned(
                name .. " " .. label,
                24 * scale.get(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(sizeX * 0.4 - 30 * scale.get(), sizeY),
                false,
                textColor
        )
        ui.sameLine()

        local boundDeviceID, buttonID = button:boundTo(sim.inputMode + 1)
        local tempCursor = ui.getCursor()

        cursor.offsetY(boundDeviceID == "" and 0 or -size.y * 0.1)
        cursor.snap()
        ui.dwriteTextAligned(
                buttonID,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(sizeX * 0.2, sizeY),
                false,
                textColor
        )

        ui.setCursor(tempCursor)
        cursor.snap()
        ui.dwriteTextAligned(
                boundDeviceID,
                fontSize * 0.5,
                ui.Alignment.Center,
                ui.Alignment.End,
                vec2(sizeX * 0.2, sizeY),
                false,
                textColor
        )
        ui.sameLine()

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.drive(label, size, horizontalAligment, verticalAlignment, color, locked, reason)
        style:pushFontBold()

        if not horizontalAligment then horizontalAligment = ui.Alignment.Center end

        if not verticalAlignment then verticalAlignment = ui.Alignment.Center end

        local flags = ui.ButtonFlags.None

        local sizeX = size.x
        local sizeY = size.y
        local fontSize = math.floor(sizeY * 0.55)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize
        local buttonSize = vec2Temp1(sizeX, sizeY)

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, buttonSize, flags)
        local hovered = ui.itemHovered() and not callback.modalDialog
        local r1, r2 = ui.itemRect()

        local buttonColor = color

        if not locked then
                if ui.itemActive() then
                        buttonColor = color * 1.1
                elseif hovered then
                        buttonColor = color * 0.9
                end
        end

        ui.drawRectFilled(r1, r2, buttonColor, 12 * scale.get())

        ui.sameLine()
        ui.setCursor(tempCursor)

        if reason ~= "" then
                cursor.snap()
                ui.dwriteTextAligned(
                        label,
                        fontSize,
                        horizontalAligment,
                        ui.Alignment.Start,
                        buttonSize,
                        false,
                        settings.Appearance.uiColorBackground
                )

                ui.setCursor(tempCursor)
                cursor.snap()
                ui.dwriteTextAligned(
                        reason,
                        fontSize * 0.5,
                        horizontalAligment,
                        ui.Alignment.End,
                        buttonSize,
                        false,
                        settings.Appearance.uiColorBackground
                )
        else
                cursor.snap()
                ui.dwriteTextAligned(label, fontSize, horizontalAligment, verticalAlignment, buttonSize, false)
        end

        if not locked then ui.glowRectFilled(r1, r2, color) end

        ui.popDWriteFont()

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.modern(label, sizeX, sizeY, flags, icon)
        local clicked = ui.modernButton(label, vec2(sizeX, sizeY) * scale.get(), flags, icon, 16 * scale.get())
        local hovered = ui.itemHovered() and not callback.modalDialog
        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function button.icon(label, icon, sizeX, sizeY, flags, flipped, iconScale, active)
        if not iconScale then iconScale = 0.5 end

        local disabled = false
        if bit.band(flags, ui.ButtonFlags.Disabled) ~= 0 then disabled = true end

        local hasLabel = not label:startsWith("##")

        local p = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, vec2(sizeX, sizeY))
        local hovered = ui.itemHovered() and not callback.modalDialog

        -- local r1, r2 = ui.itemRect()
        -- ui.drawRectFilled(r1, r2, rgbm.colors.gray * 0.5)

        local iconColor = settings.Appearance.uiColorAccent

        if disabled then
                iconColor = rgbm(0.3, 0.3, 0.3, 0.8)
        elseif hovered then
                iconColor = settings.Appearance.uiColorSecondary * 2
        elseif active then
                iconColor = settings.Appearance.uiColorSecondary
        end

        if hovered and active then ui.beginOutline() end

        local iconSize = vec2(sizeX, sizeX)
        if flipped then iconSize = vec2(-sizeX, sizeX) end

        ui.addIcon(icon, iconSize * iconScale, vec2(0.5, hasLabel and 0.1 or 0.5), iconColor, 0)

        if hovered and active then ui.endOutline(settings.Appearance.uiColorAccent, 1) end

        if hasLabel then
                ui.setCursor(p)

                local labelWidth = ui.measureDWriteText(label, style.main.font.header.size).x

                ui.offsetCursorX(sizeX * 0.5 - labelWidth * 0.5)
                ui.offsetCursorY(sizeY * 0.5)

                cursor.snap()
                style:pushFontBold()
                ui.dwriteTextAligned(
                        label,
                        style.main.font.header.size,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(labelWidth, sizeY * 0.5),
                        false,
                        iconColor
                )
                ui.popDWriteFont()
        end

        ui.setCursor(p)
        ui.dummy(vec2(sizeX, sizeY))

        return clicked and not disabled
end

function button.emoji(label, emoji, sizeX, sizeY, flags, active)
        local disabled = false
        if bit.band(flags, ui.ButtonFlags.Disabled) ~= 0 then disabled = true end

        local clicked = ui.invisibleButton("##" .. label, vec2(sizeX, sizeY))
        local hovered = ui.itemHovered() and not callback.modalDialog
        local r1, r2 = ui.itemRect()

        if hovered then ui.drawRectFilled(r1, r2, rgbm(0.2, 0.2, 0.2, 1), 6 * scale.get()) end
        if hovered and ui.mouseDown(ui.MouseButton.Left) then
                ui.drawRectFilled(r1, r2, rgbm(1, 0.2, 0.2, 1), 6 * scale.get())
        end

        ui.setCursor(r1)
        ui.dwriteTextAligned(emoji, sizeY * 0.6, ui.Alignment.Center, ui.Alignment.Center, r2 - r1)

        return clicked and not disabled
end

local function timeAgo(timestamp)
        local now = os.time()
        local diff = now - tonumber(timestamp)
        local timeNum = diff
        local timeUnit = "second"

        if diff < 60 then
        elseif diff < 3600 then
                timeNum = math.floor(diff / 60)
                timeUnit = "minute"
        elseif diff < 86400 then
                timeNum = math.floor(diff / 3600)
                timeUnit = "hour"
        elseif diff < 604800 then
                timeNum = math.floor(diff / 86400)
                timeUnit = "day"
        elseif diff < 2629746 then -- ~1 month
                timeNum = math.floor(diff / 604800)
                timeUnit = "week"
        elseif diff < 31556952 then -- ~1 year
                timeNum = math.floor(diff / 2629746)
                timeUnit = "month"
        else
                timeNum = math.floor(diff / 31556952)
                timeUnit = "year"
        end

        return string.format("%s %s%s ago", timeNum, timeUnit, timeNum > 1 and "s" or "")
end

function button.small(id, label, size)
        local clicked = ui.invisibleButton(id, size)
        local hovered = ui.itemHovered()
        local color = settings.Appearance.uiColorPrimary
        local r1, r2 = ui.itemRect()

        if hovered then color = settings.Appearance.uiColorSecondary end

        ui.drawRectFilled(r1, r2, color, 6 * scale.get())

        ui.setCursor(r1)
        cursor.snap()
        ui.dwriteTextAligned(
                label,
                style.main.font.small.size,
                ui.Alignment.Center,
                ui.Alignment.Center,
                size,
                false,
                settings.Appearance.uiColorText
        )

        return clicked
end

function button.smallIcon(id, icon, size)
        local clicked = ui.invisibleButton(id, size)
        local hovered = ui.itemHovered()
        local color = settings.Appearance.uiColorPrimary
        local r1, r2 = ui.itemRect()

        if hovered then color = settings.Appearance.uiColorSecondary end

        ui.drawRectFilled(r1, r2, color, 6 * scale.get())

        ui.addIcon(icon, size * 0.5, vec2(0.5, 0.5), rgbm.colors.white, 0)

        return clicked
end

function button.setupSelect(label, active, createdDate)
        cursor.offsetX(10)

        local fontSpace = style.main.font.body.space
        local fontSize = style.main.font.body.size
        local size = vec2(ui.availableSpaceX() - 10 * scale.get(), fontSpace * 2 + 20 * scale.get())
        local fontColor = settings.Appearance.uiColorText

        local tempCursor = ui.getCursor()
        ui.dummy(size)
        local clicked = ui.itemClicked()
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.modalDialog
        local id = ui.getLastID()
        if hovered and ui.mouseClicked(ui.MouseButton.Right) then clicked = true end

        local color = settings.Appearance.uiColorBackgroundShade

        if hovered then color = settings.Appearance.uiColorSecondary end

        if active then
                if hovered then
                        color = settings.Appearance.uiColorSecondary
                else
                        color = settings.Appearance.uiColorAccent
                end
        end

        -- ui.drawRectFilled(r1, r2, settings.Appearance.uiColorPrimary, 6 * scale.get(), ui.CornerFlags.All)
        ui.drawRect(r1, r2, color, 6 * scale.get(), ui.CornerFlags.All, 3 * scale.get())

        ui.setCursor(r1)
        cursor.offsetY(10)
        cursor.offsetX(10)
        cursor.snap()
        ui.dwriteTextAligned(
                label,
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(size.x, fontSpace),
                false,
                hovered and rgbm(1, 1, 1, 1) or fontColor
        )

        cursor.setX(20)
        cursor.snap()
        ui.dwriteTextAligned(
                timeAgo(createdDate),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(size.x, fontSpace),
                false,
                hovered and rgbm(1, 1, 1, 1) or fontColor
        )

        local deleteClicked, loadClicked, explorerClicked = false, false, false

        if active then
                ui.sameLine()
                ui.setCursorX(0)

                local buttonWidth = 100 * scale.get()

                ui.setCursorX(ui.availableSpaceX() - buttonWidth * 2 - fontSpace - 30 * scale.get())
                deleteClicked = button.small("##delete_setup_" .. label, "Delete", vec2(buttonWidth, fontSpace))
                ui.sameLine()

                cursor.offsetX(5)
                loadClicked = button.small("##load_setup_" .. label, "Load", vec2(buttonWidth, fontSpace))
                ui.sameLine()

                cursor.offsetX(5)

                explorerClicked =
                        button.small("##open_in_explorer_" .. label, ui.Icons.Folder, vec2(fontSpace, fontSpace))
        end

        cursor.offsetY(10)

        return clicked, deleteClicked, loadClicked, explorerClicked, hovered
end

local treeNodeParent = ""
function button.treeNodeChild(label, size, active, bold, count, defaultOpen)
        cursor.offsetX(10)
        if not count then count = 0 end

        local fontSize = style.main.font.header.size
        local fontSpace = style.main.font.header.space
        local fontColor = settings.Appearance.uiColorText
        local size = vec2(ui.availableSpaceX() - 10 * scale.get(), fontSpace + 20 * scale.get())
        local offset = bold and 0 or size.y

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton(
                "##" .. label .. treeNodeParent,
                size,
                ui.ButtonFlags.PressedOnClick + ui.ButtonFlags.PressedOnDoubleClick
        )
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.modalDialog
        local id = ui.getLastID()
        local open = state.loadStoredBool(id, defaultOpen)
        if hovered and ui.mouseClicked(ui.MouseButton.Right) then clicked = true end

        local color = bold and settings.Appearance.uiColorPrimary or settings.Appearance.uiColorBackgroundShade

        if hovered then color = settings.Appearance.uiColorSecondary end

        if active then
                fontColor = settings.Appearance.uiColorBackground

                if hovered then
                        color = settings.Appearance.uiColorSecondary
                else
                        color = settings.Appearance.uiColorAccent
                end
        end

        ui.drawRectFilled(r1, r2, color, 6 * scale.get())

        if active and hovered then ui.drawRect(r1, r2, settings.Appearance.uiColorAccent, 6 * scale.get()) end

        local text = count > 0 and string.format("%s (%s)", label, count) or string.format("%s", label)

        ui.setCursor(r1)
        cursor.offsetX(10)
        cursor.snap()
        ui.dwriteTextAligned(
                text,
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                size,
                false,
                hovered and rgbm(1, 1, 1, 1) or fontColor
        )
        ui.sameLine()

        ui.offsetCursorX(-size.y - 10 * scale.get())

        if bold and count > 0 then
                ui.icon(
                        state.loadStoredBool(id) and ui.Icons.Minus or ui.Icons.Plus,
                        vec2Temp1:set(size.y, size.y),
                        rgbm.colors.white,
                        size.y * 0.5
                )
        else
                ui.dummy(size.y)
        end

        return clicked, open, id, hovered
end

function button.treeNode(label, count, content, defaultOpen)
        local clicked, open, id = button.treeNodeChild(
                label,
                vec2Temp1:set(ui.availableSpaceX() - 20 * scale.get(), style.main.font.header.space),
                false,
                true,
                count,
                defaultOpen
        )
        treeNodeParent = label

        if count < 1 then return clicked end

        if clicked then state.storeBool(id, not open) end

        if open then
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                ui.beginGroup(ui.availableSpaceX())
                content()
                ui.endGroup()
                ui.popStyleVar(1)
        end

        return clicked
end

return button
