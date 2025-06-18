local CUI = {}

local audio = require("audio")
local callback = require("callback")
local settings = require("settings")
local style = require("style")
local sim = ac.getSim()
local guiINI = ac.INIConfig.cspModule(ac.CSPModuleID.GUI)

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local storedBools = {}
local defaultWidth = 2560
local defaultHeight = 1440
local windowMaxWidth = 0
local windowMaxHeight = 0

local uiScale = math.min(sim.windowHeight / defaultHeight, sim.windowWidth / defaultWidth)
        / guiINI:get("NEW_UI", "UI_SCALE", 1)

ac.onResolutionChange(
        function(newSize, makingScreenshot)
                uiScale = math.min(newSize.y / defaultHeight, newSize.x / defaultWidth)
                        / guiINI:get("NEW_UI", "UI_SCALE", 1)
        end
)

ac.onCSPConfigChanged(ac.CSPModuleID.GUI, function()
        guiINI = ac.INIConfig.cspModule(ac.CSPModuleID.GUI)

        uiScale = math.min(sim.windowHeight / defaultHeight, sim.windowWidth / defaultWidth)
                / guiINI:get("NEW_UI", "UI_SCALE", 1)
end)

function CUI.loadStoredBool(id, defaultTrue)
        if storedBools[id] == nil then storedBools[id] = defaultTrue and true or false end

        return storedBools[id]
end

function CUI.storeBool(id, value) storedBools[id] = value end

function CUI.windowMaxWidth() return windowMaxWidth end

function CUI.windowMaxHeight() return windowMaxHeight end

function CUI.availableSpaceX() return ui.availableSpaceX() end

function CUI.availableSpaceY() return ui.availableSpaceY() * uiScale end

function CUI.uiScale() return uiScale end

function CUI.setCursorX(v) ui.setCursorX(v * uiScale) end

function CUI.setCursorY(v) ui.setCursorY(v * uiScale) end

function CUI.offsetCursorX(v) ui.offsetCursorX(v * uiScale) end

function CUI.offsetCursorY(v) ui.offsetCursorY(v * uiScale) end

function CUI:setCenterCursorAround(width, height, x, y)
        if x then ui.setCursorX(x - width * 0.5) end
        if y then ui.setCursorY(y - height * 0.5) end
end

function CUI.snapCursor()
        local x, y = ui.getCursorX(), ui.getCursorY()
        x, y = math.floor(x), math.floor(y)

        x = x % 2 ~= 0 and x + 1 or x
        y = y % 2 ~= 0 and y + 1 or y

        ui.setCursorX(x)
        ui.setCursorY(y)
end

function CUI.childWindow(id, size, border, flags, content) ui.childWindow(id, size, false, flags, content) end

function CUI.contentWindow(id, position, size, flags, content, showBackground, scroll)
        CUI.pushWindow(id .. "test", position.x, position.y, size.x, size.y, scroll, flags)

        content()

        CUI.popWindow(scroll, flags)
end

CUI.menuPanAvailable = false
CUI.menuZoomAvailable = false

CUI.modalDialogCallback = nil

function CUI.modalDialog(callback) CUI.modalDialogCallback = callback end

function CUI.menuBanner(label, time, bannerColor, rightSide, callbackType)
        if not callbackType then callbackType = "info" end

        callback[callbackType] = function()
                local xStart = rightSide and ui.windowWidth() or 0
                local xEnd = rightSide and ui.windowWidth() * 0.5 or ui.windowWidth() * 0.5
                local xText = rightSide and ui.windowWidth() * 0.75 or 0
                local alignment = rightSide and ui.Alignment.End or ui.Alignment.Start
                local margin = rightSide and -20 * uiScale or 20 * uiScale

                ui.drawRectFilledMultiColor(
                        vec2(xStart, 0),
                        vec2(xEnd, ui.windowHeight()),
                        bannerColor,
                        rgbm(0, 0, 0, 0),
                        rgbm(0, 0, 0, 0),
                        bannerColor
                )

                ui.setCursor(vec2(xText + margin, 0))

                ui.dwriteTextAligned(
                        label,
                        28 * uiScale,
                        alignment,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.2, ui.windowHeight()),
                        false,
                        rgbm.colors.white
                )

                if time then
                        ui.sameLine()
                        ui.dwriteTextAligned(
                                string.format("%.1f", time),
                                28 * uiScale,
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth() * 0.05, ui.windowHeight()),
                                false,
                                rgbm.colors.white
                        )
                end
        end

        setTimeout(function() callback[callbackType] = nil end, 2, callbackType .. "banner")
end

function CUI.dwriteTextWrapped(text, font) ui.dwriteTextWrapped(text, font * CUI.uiScale()) end

function CUI.dwriteText(params)
        if params.xPos then ui.setCursorX(params.xPos * CUI.uiScale()) end
        if params.yPos then ui.setCursorY(params.yPos * CUI.uiScale()) end
        CUI.snapCursor()

        local fontSize = params.fontSize * CUI.uiScale()
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

        ui.dwriteText(params.text, fontSize, params.color)
end

function CUI.dwriteTextAligned(params)
        if not params.size then params.size = vec2Temp1:set(350, 100) end

        if params.xPos then ui.setCursorX(params.xPos * CUI.uiScale()) end
        if params.yPos then ui.setCursorY(params.yPos * CUI.uiScale()) end

        ui.dwriteTextAligned(
                params.text,
                params.fontSize * CUI.uiScale(),
                params.xAlign,
                params.yAlign,
                vec2Temp1:set(params.size.x * CUI.uiScale(), params.size.y * CUI.uiScale()),
                false,
                params.color
        )
end

function CUI.button(label, sizeX, sizeY, fontSize, horizontalAligment, verticalAlignment, flags, fontColor)
        if not horizontalAligment then horizontalAligment = ui.Alignment.Center end

        if not verticalAlignment then verticalAlignment = ui.Alignment.Center end

        if not flags then flags = ui.ButtonFlags.None end

        local textWidth = ui.measureDWriteText(string.upper(label), fontSize * uiScale).x
        local fontColor = fontColor

        if flags == ui.ButtonFlags.Disabled then
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
                ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
        end

        local tempCursor = ui.getCursor()
        local clicked = ui.button("##" .. label, vec2Temp1:set(textWidth + 30 * uiScale, sizeY * uiScale), flags)
        local hovered = ui.itemHovered()

        if flags == ui.ButtonFlags.Disabled then ui.popStyleColor(1) end

        ui.sameLine()
        ui.offsetCursorY(1)
        ui.setCursor(tempCursor)

        ui.dwriteTextAligned(
                string.upper(label),
                fontSize * uiScale,
                horizontalAligment,
                verticalAlignment,
                vec2Temp1:set(textWidth + 30 * uiScale, sizeY * uiScale),
                false,
                fontColor
        )

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function CUI.settingsButton(label, sizeX, sizeY, flags, icon)
        local fontSize = sizeY / 5

        local disabled = flags == ui.ButtonFlags.Disabled
        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, vec2Temp1:set(sizeX, sizeY), flags)
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()

        local buttonColor = settings.Appearance.uiColorPrimary
        local fontColor = settings.Appearance.uiColorText

        if hovered and not disabled then buttonColor = settings.Appearance.uiColorSecondary end
        if disabled then fontColor = settings.Appearance.uiColorTextDim end

        ui.drawRectFilled(r1, r2, buttonColor, 12 * uiScale)

        ui.addIcon(icon, vec2Temp1:set(sizeY / 4, sizeY / 4), vec2Temp2:set(0.5, 0.25), fontColor)

        if not ui.itemHovered() or disabled then
                ui.drawRect(r1, r2, disabled and rgbm.colors.gray or rgbm.colors.white, 12 * uiScale)
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

function CUI.modalButton(label, sizeX, sizeY, flags)
        local fontSize = sizeY / 2

        local disabled = flags == ui.ButtonFlags.Disabled

        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColorPrimary)
        ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.Appearance.uiColorSecondary)
        ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.Appearance.uiColorSecondary)

        local tempCursor = ui.getCursor()
        local clicked = ui.button("##" .. label, vec2Temp1:set(sizeX, sizeY), flags)
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()

        if not ui.itemHovered() or disabled then
                ui.drawRect(r1, r2, disabled and rgbm.colors.gray or rgbm.colors.white, 0, ui.CornerFlags.None, 1)
        end

        ui.popStyleColor(3)

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

function CUI.menuButton(label, size, horizontalAligment, verticalAlignment, flags, active, bold, cornerFlags)
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
                size = size * uiScale
                sizeY = size
                fontSize = sizeY * 0.6
                buttonSize = vec2Temp1:set(
                        math.round(ui.measureDWriteText(string.upper(label), fontSize).x + 50 * CUI.uiScale()),
                        size
                )
        else
                sizeX = size.x
                sizeY = size.y
                fontSize = sizeY * 0.65
                buttonSize = vec2Temp1(sizeX, sizeY)
        end

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, buttonSize, flags)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered()

        local buttonColor = rgbm.colors.transparent
        local fontColor = settings.Appearance.uiColorText

        if flags == ui.ButtonFlags.Disabled then
                buttonColor = settings.Appearance.uiColorBackground
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
        elseif hovered then
                buttonColor = settings.Appearance.uiColorSecondary
        elseif active then
                buttonColor = settings.Appearance.uiColorAccent
                fontColor = rgbm.colors.black
        end

        ui.drawRectFilled(r1, r2, buttonColor, 6, cornerFlags)

        ui.setCursor(tempCursor)
        CUI.snapCursor()
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

function CUI.bindingButton(button, inputMode, device, buttonLabel, size, flags)
        if not flags then flags = ui.ButtonFlags.None end

        local sizeX = size.x
        local sizeY = size.y
        local fontSize = math.floor(sizeY * 0.4)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize
        local fontColor = rgbm.colors.white

        if flags == ui.ButtonFlags.Disabled then fontColor = settings.Appearance.uiColorTextDim end

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. inputMode .. button.bind, vec2Temp1(sizeX, sizeY), flags)
        local hovered = ui.itemHovered()

        if flags == ui.ButtonFlags.Disabled then
        elseif not hovered and device == "" then
                fontColor = settings.Appearance.uiColorTextDim
        end

        ui.setCursor(tempCursor)
        CUI.offsetCursorY(device == "" and 0 or -sizeY * 0.15)
        CUI.snapCursor()
        ui.dwriteTextAligned(
                buttonLabel,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2Temp1(sizeX, sizeY),
                false,
                fontColor
        )

        ui.setCursor(tempCursor)
        CUI.snapCursor()
        ui.dwriteTextAligned(
                device,
                fontSize * 0.75,
                ui.Alignment.Center,
                ui.Alignment.End,
                vec2Temp1(sizeX, sizeY),
                false,
                fontColor
        )

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function CUI.specialButton(label, size, horizontalAligment, verticalAlignment, color, locked, reason)
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
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()

        local buttonColor = color

        if not locked then
                if ui.itemActive() then
                        buttonColor = color * 1.1
                elseif hovered then
                        buttonColor = color * 0.9
                end
        end

        ui.drawRectFilled(r1, r2, buttonColor, 12 * uiScale)

        ui.sameLine()
        ui.setCursor(tempCursor)

        if reason ~= "" then
                CUI.snapCursor()
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
                CUI.snapCursor()
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
                CUI.snapCursor()
                ui.dwriteTextAligned(label, fontSize, horizontalAligment, verticalAlignment, buttonSize, false)
        end

        if not locked then ui.glowRectFilled(r1, r2, color) end

        ui.popDWriteFont()

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function CUI.modernButton(label, sizeX, sizeY, flags, icon)
        local clicked = ui.modernButton(label, vec2(sizeX, sizeY) * uiScale, flags, icon, 16 * uiScale)
        local hovered = ui.itemHovered()
        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function CUI.iconButton(label, icon, sizeX, sizeY, flags, flipped, iconScale, active)
        if not iconScale then iconScale = 1 end

        local disabled = false
        if bit.band(flags, ui.ButtonFlags.Disabled) ~= 0 then disabled = true end

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, vec2(sizeX, sizeY))
        local hovered = ui.itemHovered()

        local iconColor = settings.Appearance.uiColorAccent

        if disabled then
                iconColor = rgbm(0.3, 0.3, 0.3, 0.8)
        elseif hovered then
                iconColor = settings.Appearance.uiColorSecondary * 2
        elseif active then
                iconColor = settings.Appearance.uiColorSecondary
        end

        local iconSize = sizeY * 0.8
        if flipped then iconSize = -iconSize end

        ui.addIcon(icon, vec2(iconSize, iconSize) * 0.7 * iconScale, vec2(0.5, 0.5), iconColor, 0)

        if not label:startsWith("##") then
                ui.setCursorX(tempCursor.x - sizeX * 0.5)
                CUI.snapCursor()
                style:pushFontBold()
                ui.dwriteTextAligned(
                        label,
                        18 * uiScale,
                        ui.Alignment.Center,
                        ui.Alignment.Start,
                        vec2(sizeX * 2, sizeY),
                        false,
                        iconColor
                )
                ui.popDWriteFont()
                ui.setCursor(tempCursor + vec2(sizeX, 0))
        end

        return clicked and not disabled
end

function CUI.emojiButton(label, emoji, sizeX, sizeY, flags, active)
        local disabled = false
        if bit.band(flags, ui.ButtonFlags.Disabled) ~= 0 then disabled = true end

        local clicked = ui.invisibleButton("##" .. label, vec2(sizeX, sizeY))
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()

        if hovered then ui.drawRectFilled(r1, r2, rgbm(0.2, 0.2, 0.2, 1)) end
        if hovered and ui.mouseDown(ui.MouseButton.Left) then ui.drawRectFilled(r1, r2, rgbm(1, 0.2, 0.2, 1)) end

        ui.setCursor(r1)
        ui.dwriteTextAligned(emoji, sizeY * 0.6, ui.Alignment.Center, ui.Alignment.Center, r2 - r1)

        return clicked and not disabled
end

local treeNodeParent = ""
function CUI.treeNodeButton(label, size, active, bold, count, defaultOpen)
        if not count then count = 0 end

        local fontSize = math.floor(size.y * 0.55)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize
        local fontColor = settings.Appearance.uiColorText

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton(
                "##" .. label .. treeNodeParent,
                size,
                ui.ButtonFlags.PressedOnClick + ui.ButtonFlags.PressedOnDoubleClick
        )
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not CUI.modalDialogCallback
        local id = ui.getLastID()
        local open = CUI.loadStoredBool(id, defaultOpen)
        if hovered and ui.mouseClicked(ui.MouseButton.Right) then clicked = true end

        local color = bold and settings.Appearance.uiColorBackground or settings.Appearance.uiColorBackgroundShade

        if hovered then color = settings.Appearance.uiColorSecondary end

        if active then
                fontColor = settings.Appearance.uiColorBackground

                if hovered then
                        color = settings.Appearance.uiColorSecondary
                else
                        color = settings.Appearance.uiColorAccent
                end
        end

        ui.drawRectFilled(r1, r2, color, 6 * uiScale)

        if active and hovered then
                ui.drawRect(r1, r2, settings.Appearance.uiColorAccent, 6 * uiScale, ui.CornerFlags.All, 1)
        end

        ui.sameLine()

        local textOffset = bold and size.x / 20 or size.x / 40
        ui.setCursor(tempCursor)
        ui.offsetCursorX(textOffset)

        local text = count > 0 and string.format(" %s (%s)", label, count) or string.format(" %s", label)
        CUI.snapCursor()
        ui.dwriteTextAligned(
                text,
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2Temp1:set(size.x - textOffset, size.y),
                false,
                hovered and rgbm(1, 1, 1, 1) or fontColor
        )

        ui.setCursorY(tempCursor.y + size.y)

        if bold and count > 0 then
                ui.addIcon(
                        CUI.loadStoredBool(id) and ui.Icons.Minus or ui.Icons.Plus,
                        vec2Temp1:set(size.y / 2, size.y / 2),
                        vec2Temp2:set(0.92, 0.5),
                        settings.Appearance.uiColorText
                )
        end

        return clicked, open, id, hovered
end

function CUI.treeNode(label, count, content, defaultOpen)
        local clicked, open, id = CUI.treeNodeButton(
                label,
                vec2Temp1:set(ui.availableSpaceX(), 36 * CUI.uiScale()),
                false,
                true,
                count,
                defaultOpen
        )
        treeNodeParent = label

        if count < 1 then return clicked end

        if clicked then CUI.storeBool(id, not open) end

        if open then
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                ui.beginGroup(ui.availableSpaceX())
                content()
                ui.endGroup()
                ui.popStyleVar(1)
        end

        return clicked
end

function CUI.combo(id, size, previewValue, content)
        local id = "##combo" .. id
        local sp1 = ui.cursorScreenPos()
        local clicked = ui.invisibleButton("##comboCurrentCamera", size)
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()
        local color = settings.Appearance.uiColorText
        local open = CUI.loadStoredBool(id, false)

        if hovered then color = settings.Appearance.uiColorSecondary end
        if clicked then CUI.storeBool(id, not open) end

        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorPrimary, 6 * CUI.uiScale())
        ui.addIcon(open and ui.Icons.Down or ui.Icons.Up, vec2(size.y, size.y) * 0.5, vec2(0.98, 0.5), color)

        ui.setCursor(r1)
        CUI.snapCursor()
        ui.dwriteTextAligned(previewValue, size.y * 0.65, ui.Alignment.Center, ui.Alignment.Center, size, false, color)

        if open then
                ui.transparentWindow(id, sp1 - vec2(0, size.y * 8), vec2(size.x, size.y * 8), true, true, function()
                        ui.bringWindowToFront()
                        ui.setCursor(0)

                        CUI.pushWindow(id .. "scroll_window", 0, 0, ui.windowWidth(), ui.windowHeight(), true)
                        ui.drawRectFilled(
                                ui.getCursor(),
                                vec2(ui.windowWidth(), 1000),
                                settings.Appearance.uiColorBackground,
                                6 * uiScale
                        )

                        content()

                        if
                                not clicked
                                and open
                                and ui.mouseReleased(ui.MouseButton.Left)
                                and not ui.rectHovered(0, vec2(ui.windowWidth(), 10000))
                        then
                                CUI.storeBool(id, false)
                        end

                        CUI.popWindow(true)
                end)
        end
end

local inputTextBoxDragIndex = 0
local inputTextBoxCursorIndex = 2
local scrollOffsetX = 0

local function measureUTF8PrefixWidth(charTable, upToIndex, fontSize)
        local width = 0
        for i = 1, upToIndex do
                local char = charTable[i]
                local displayChar = (char == " ") and "." or char
                width = width + ui.measureDWriteText(displayChar, fontSize).x
        end
        return width
end

function CUI.inputTextBox(label, stringPrefix, stringInput, size)
        local fontSize = math.floor(size.y * 0.55)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

        local tempCursor = ui.getCursor()

        local clicked = ui.invisibleButton("##textinput" .. label, size, ui.ButtonFlags.None)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered()
        local id = ui.getLastID()
        local itemActive = CUI.loadStoredBool(id)

        ui.pushClipRect(r1, r2)

        ui.setCursor(tempCursor)
        local textOffset = size.x / 60
        ui.offsetCursorX(textOffset)
        ui.offsetCursorY(1)

        if clicked then CUI.storeBool(id, clicked) end

        if hovered then
                ui.setMouseCursor(ui.MouseCursor.TextInput)
        elseif ui.mouseClicked(ui.MouseButton.Left) then
                CUI.storeBool(id, false)
        end

        local charSizes = {}
        local charPositions = {}
        local utf8Chars = {}
        do
                local i = 1
                local xOffset = 0
                while i <= #stringInput do
                        local cp, len = stringInput:codePointAt(i)
                        if not cp then break end
                        local char = stringInput:sub(i, i + len - 1)
                        utf8Chars[#utf8Chars + 1] = char
                        local displayChar = (char == " ") and "." or char
                        local w = ui.measureDWriteText(displayChar, fontSize).x
                        charSizes[#charSizes + 1] = w
                        charPositions[#charPositions + 1] = xOffset
                        xOffset = xOffset + w
                        i = i + len
                end
        end

        CUI.snapCursor()
        ui.dwriteTextAligned(
                stringPrefix,
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2Temp1:set(ui.measureDWriteText(stringPrefix, fontSize).x, size.y),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        tempCursor = ui.getCursor()

        local cursorOffset = measureUTF8PrefixWidth(utf8Chars, inputTextBoxCursorIndex, fontSize)

        local boxPadding = 6
        local chunkSize = size.x * 0.5
        local boxLeft = tempCursor.x
        local boxRight = tempCursor.x + size.x
        local cursorX = boxLeft + cursorOffset

        if cursorX - scrollOffsetX > boxRight - boxPadding then
                scrollOffsetX = scrollOffsetX + chunkSize
        elseif cursorX - scrollOffsetX < boxLeft + boxPadding then
                scrollOffsetX = math.max(scrollOffsetX - chunkSize, 0)
        end

        local totalTextWidth = charPositions[#charPositions] and (charPositions[#charPositions] + charSizes[#charSizes])
                or 0
        if totalTextWidth <= size.x - textOffset * 2 then scrollOffsetX = 0 end

        ui.sameLine()
        tempCursor = ui.getCursor()

        CUI.snapCursor()
        for i, char in ipairs(utf8Chars) do
                local posX = tempCursor.x + charPositions[i] - scrollOffsetX
                ui.setCursorX(posX)
                ui.dwriteTextAligned(
                        char,
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2Temp1:set(charSizes[i], size.y),
                        false,
                        rgbm.colors.white
                )
                ui.sameLine()
        end

        if hovered and ui.mouseClicked(ui.MouseButton.Left) then
                local mouseX = ui.mouseLocalPos().x
                inputTextBoxCursorIndex = 0
                for i = 1, #utf8Chars do
                        if mouseX > tempCursor.x + charPositions[i] - scrollOffsetX then inputTextBoxCursorIndex = i end
                end
                inputTextBoxDragIndex = inputTextBoxCursorIndex
        end

        if itemActive and math.abs(ui.mouseDragDelta(ui.MouseButton.Left).x) > 0 then
                local mouseX = ui.mouseLocalPos().x
                inputTextBoxDragIndex = 0
                for i = 1, #utf8Chars do
                        if mouseX > tempCursor.x + charPositions[i] - scrollOffsetX then inputTextBoxDragIndex = i end
                end
        end

        if itemActive then
                local left = tempCursor.x
                        + measureUTF8PrefixWidth(utf8Chars, inputTextBoxDragIndex, fontSize)
                        - scrollOffsetX
                local right = tempCursor.x
                        + measureUTF8PrefixWidth(utf8Chars, inputTextBoxCursorIndex, fontSize)
                        - scrollOffsetX
                if left ~= right then
                        ui.drawRectFilled(
                                vec2(right, ui.getCursorY()),
                                vec2(left, ui.getCursorY() + size.y - 2),
                                rgbm.colors.red / 2
                        )
                end
        end

        local drawCursor = (
                not ui.mouseDown(ui.MouseButton.Left)
                and itemActive
                and math.floor(os.clock() * 2) % 2 == 0
        ) or (hovered and ui.mouseClicked(ui.MouseButton.Left))

        if drawCursor then
                local pos = tempCursor.x + cursorOffset - scrollOffsetX
                ui.drawSimpleLine(
                        vec2(pos, r1.y + 10 * CUI.uiScale()),
                        vec2(pos, r1.y - 10 * CUI.uiScale()) + vec2(0, size.y),
                        rgbm.colors.white / 1.25,
                        2 * CUI.uiScale()
                )
        end

        ui.popClipRect()

        return itemActive
end

function CUI.inputText(label, stringPrefix, stringInput, filter, size)
        if not CUI.inputTextBox(label, stringPrefix, stringInput, size) then return stringInput, false end

        local captured = ui.captureKeyboard(true, true, true)
        local charToAdd = nil
        local skip = false

        local utf8Chars = {}
        do
                local i = 1
                while i <= #stringInput do
                        local cp, len = stringInput:codePointAt(i)
                        if not cp then break end
                        utf8Chars[#utf8Chars + 1] = stringInput:sub(i, i + len - 1)
                        i = i + len
                end
        end

        local numChars = #utf8Chars

        if ui.mouseDoubleClicked(ui.MouseButton.Left) then
                inputTextBoxDragIndex = 0
                inputTextBoxCursorIndex = numChars
        end

        if ui.keyPressed(ui.Key.A) and ui.keyboardButtonDown(ui.KeyIndex.Control) then
                inputTextBoxDragIndex = 0
                inputTextBoxCursorIndex = numChars
        end

        if ui.keyPressed(ui.Key.C) and ui.keyboardButtonDown(ui.KeyIndex.Control) then
                if inputTextBoxCursorIndex ~= inputTextBoxDragIndex then
                        local i1 = math.min(inputTextBoxCursorIndex, inputTextBoxDragIndex) + 1
                        local i2 = math.max(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                        local selectedText = table.concat(utf8Chars, "", i1, i2)
                        ac.setClipboardText(selectedText)
                end
        end

        if ui.keyPressed(ui.Key.V) and ui.keyboardButtonDown(ui.KeyIndex.Control) then
                local clip = ui.getClipboardText()
                if clip and #clip > 0 then
                        if inputTextBoxCursorIndex ~= inputTextBoxDragIndex then
                                local startIndex = math.min(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                                local endIndex = math.max(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                                for i = endIndex, startIndex + 1, -1 do
                                        table.remove(utf8Chars, i)
                                end
                                inputTextBoxCursorIndex = startIndex
                                inputTextBoxDragIndex = startIndex
                        end

                        local i = 1
                        while i <= #clip do
                                local cp, len = clip:codePointAt(i)
                                if not cp then break end
                                local ch = clip:sub(i, i + len - 1)
                                if ch:match(filter) then
                                        table.insert(utf8Chars, inputTextBoxCursorIndex + 1, ch)
                                        inputTextBoxCursorIndex = inputTextBoxCursorIndex + 1
                                        inputTextBoxDragIndex = inputTextBoxCursorIndex
                                end
                                i = i + len
                        end
                end
        end

        if ui.keyPressed(ui.Key.Left) then
                inputTextBoxCursorIndex = math.max(inputTextBoxCursorIndex - 1, 0)
                if not ui.keyboardButtonDown(ui.KeyIndex.Shift) then inputTextBoxDragIndex = inputTextBoxCursorIndex end
        end

        if ui.keyPressed(ui.Key.Right) then
                inputTextBoxCursorIndex = math.min(inputTextBoxCursorIndex + 1, numChars)
                if not ui.keyboardButtonDown(ui.KeyIndex.Shift) then inputTextBoxDragIndex = inputTextBoxCursorIndex end
        end

        if ac.isKeyDown(ui.KeyIndex.Back) or ac.isKeyDown(ui.KeyIndex.Delete) or ac.isKeyDown(ui.KeyIndex.Return) then
                skip = true
        end

        if
                (ac.isKeyDown(ui.KeyIndex.Back) or ui.keyPressed(ui.Key.Delete))
                and inputTextBoxCursorIndex ~= inputTextBoxDragIndex
        then
                local startIndex = math.min(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                local endIndex = math.max(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                for i = endIndex, startIndex + 1, -1 do
                        table.remove(utf8Chars, i)
                end
                inputTextBoxCursorIndex = startIndex
                inputTextBoxDragIndex = startIndex
                skip = true
                audio:trigger()
        elseif ui.keyPressed(ui.Key.Backspace) and inputTextBoxCursorIndex > 0 then
                table.remove(utf8Chars, inputTextBoxCursorIndex)
                inputTextBoxCursorIndex = inputTextBoxCursorIndex - 1
                inputTextBoxDragIndex = inputTextBoxCursorIndex
                skip = true
                audio:trigger()
        elseif ui.keyPressed(ui.Key.Delete) and inputTextBoxCursorIndex < numChars then
                table.remove(utf8Chars, inputTextBoxCursorIndex + 1)
                inputTextBoxDragIndex = inputTextBoxCursorIndex
                skip = true
                audio:trigger()
        end

        if #captured > 0 and not skip then
                charToAdd = captured:queue()
                if #charToAdd > 0 and charToAdd:match(filter) then
                        table.insert(utf8Chars, inputTextBoxCursorIndex + 1, charToAdd)
                        inputTextBoxCursorIndex = inputTextBoxCursorIndex + 1
                        inputTextBoxDragIndex = inputTextBoxCursorIndex
                        audio:trigger()
                end
        end

        return table.concat(utf8Chars):gsub("\n", ""), true
end

function CUI:promptShutdownAC()
        local mouseMoved = false

        CUI.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 4

                ui.setCursor(0)
                ui.dwriteTextAligned("Quit Session", textBoxHeight / 2, nil, nil, vec2(ui.windowWidth(), textBoxHeight))
                local titleTextWidth = ui.measureDWriteText(" Quit Session ", textBoxHeight / 2).x

                if sm:isUndoAvailable() then
                        ui.setCursorX(0)
                        ui.dwriteTextAligned(
                                "You have unsaved changes to the current setup!",
                                textBoxHeight / 4,
                                nil,
                                nil,
                                vec2(ui.windowWidth(), textBoxHeight / 4),
                                false,
                                rgbm.colors.orange
                        )
                end

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "Abandon the current session and return to Content Manager?",
                        textBoxHeight / 4,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                local buttonWidth = ui.windowWidth() / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * CUI.uiScale())
                if CUI.modalButton("Cancel", ui.windowWidth() / 3, 50 * CUI.uiScale(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                -- if not mouseMoved then
                --         ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                --         mouseMoved = true
                -- end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * CUI.uiScale())
                if CUI.modalButton("Confirm", ui.windowWidth() / 3, 50 * CUI.uiScale(), ui.ButtonFlags.None) then
                        ac.shutdownAssettoCorsa()
                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end)
end

function CUI.dummy(x, y) ui.dummy(vec2Temp1:set(x * uiScale, y * uiScale)) end

local margins = 14

-- ui.setCursorX(margins)
-- ui.setCursorY(margins)
-- ui.drawRectFilled(0, ui.windowSize(), rgbm.colors.red / 2, 20)

-- ui.beginChild(id, vec2(tabWidth - margins * 2, tabHeight - margins * 2), false, windowFlags)

function CUI.pushWindow(id, x, y, width, height, scroll, flags)
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

function CUI.popWindow(scroll, flags)
        if not scroll then
                ui.popClipRect()
        elseif flags ~= ui.WindowFlags.NoScrollWithMouse then
                if ui.getScrollY() < 5 * uiScale then ui.setScrollY(0) end
                if ui.getScrollMaxY() - ui.getScrollY() < 5 * uiScale then ui.setScrollY(ui.getScrollMaxY()) end
        end

        ui.endChild()
        ui.popStyleVar(1)
end

function CUI.pushContentWindow(id, x, y, width, height, headerFunc, footerFunc, hideBackground, noCorners)
        CUI.pushWindow(id .. "_background", x, y, width, height)

        ui.beginGradientShade()
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorPrimary, noCorners and 0 or 16 * uiScale)
        ui.endGradientShade(
                vec2Temp1:set(ui.windowWidth(), 0),
                ui.windowSize(),
                settings.Appearance.uiColorPrimary,
                settings.Appearance.uiColorBackgroundShade,
                true
        )

        x = 10 * uiScale
        y = 10 * uiScale
        width = width - x * 2
        height = height - y * 2

        local headerSize = 50 * uiScale
        local footerSize = 40 * uiScale

        if headerFunc then
                ui.setCursor(0)
                CUI.pushWindow(id .. "_header", x, y, width, headerSize)
                ui.setCursor(0)
                headerFunc()
                CUI.popWindow()

                height = height - headerSize
                y = y + headerSize
        end

        if footerFunc then
                height = height - footerSize

                ui.setCursor(0)
                CUI.pushWindow(id .. "_footer", x, y + height + 10 * uiScale, width, footerSize - 10 * uiScale)
                ui.setCursor(0)
                footerFunc()
                CUI.popWindow()
        end

        CUI.pushWindow(id .. "_content", x, y, width, height)

        if not hideBackground then
                ui.drawRectFilled(
                        0,
                        ui.windowSize(),
                        settings.Appearance.uiColorBackground,
                        noCorners and 0 or 6 * uiScale
                )
        end
end

function CUI.popContentWindow()
        CUI.popWindow()
        CUI.popWindow()
end

function CUI.pushWindowFitted(id, flags, scroll)
        local childWindowWith = (2560 - 60) * uiScale
        local childWindowHeight = (1440 - 60) * uiScale

        CUI.pushWindow(
                id,
                (ui.windowWidth() - childWindowWith) * 0.5,
                (ui.windowHeight() - childWindowHeight) * 0.5,
                childWindowWith,
                childWindowHeight,
                scroll
        )
end

function CUI.pushWindowFull(id, flags, scroll) CUI.pushWindow(id, 0, 0, ui.windowWidth(), ui.windowHeight(), scroll) end

function CUI.getWindow(windowName)
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

return CUI
