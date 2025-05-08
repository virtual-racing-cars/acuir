local CUI = {}

local audio = require("audio")
local settings = require("settings")
local simutils = require("simutils")
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

local scaleY = math.min(sim.windowHeight / defaultHeight, sim.windowWidth / defaultWidth)
        / guiINI:get("NEW_UI", "UI_SCALE", 1)
local scaleX = scaleY

ac.onResolutionChange(function(newSize, makingScreenshot)
        scaleY = math.min(newSize.y / defaultHeight, newSize.x / defaultWidth) / guiINI:get("NEW_UI", "UI_SCALE", 1)
        scaleX = scaleY
end)

ac.onCSPConfigChanged(ac.CSPModuleID.GUI, function()
        guiINI = ac.INIConfig.cspModule(ac.CSPModuleID.GUI)

        scaleY = math.min(sim.windowHeight / defaultHeight, sim.windowWidth / defaultWidth)
                / guiINI:get("NEW_UI", "UI_SCALE", 1)
        scaleX = scaleY
end)

function CUI.loadStoredBool(id)
        if storedBools[id] == nil then storedBools[id] = false end

        return storedBools[id]
end

function CUI.storeBool(id, value) storedBools[id] = value end

function CUI.windowMaxWidth() return windowMaxWidth end

function CUI.windowMaxHeight() return windowMaxHeight end

function CUI.availableSpaceX() return ui.availableSpaceX() end

function CUI.availableSpaceY() return ui.availableSpaceY() * scaleY end

function CUI.scaleX() return scaleX end

function CUI.scaleY() return scaleY end

function CUI.setCursorX(v) ui.setCursorX(v * scaleX) end

function CUI.setCursorY(v) ui.setCursorY(v * scaleY) end

function CUI.offsetCursorX(v) ui.offsetCursorX(v * scaleX) end

function CUI.offsetCursorY(v) ui.offsetCursorY(v * scaleY) end

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
        CUI.pushWindow(id .. "test", position.x, position.y, size.x, size.y, scroll)

        content()

        CUI.popWindow()
end

CUI.menuPanAvailable = false
CUI.menuZoomAvailable = false

CUI.modalDialogCallback = nil

function CUI.modalDialog(callback) CUI.modalDialogCallback = callback end

function CUI.dwriteTextWrapped(text, font) ui.dwriteTextWrapped(text, font * CUI.scaleY()) end

function CUI.dwriteText(params)
        if params.xPos then ui.setCursorX(params.xPos * CUI.scaleX()) end
        if params.yPos then ui.setCursorY(params.yPos * CUI.scaleY()) end

        local fontSize = params.fontSize * CUI.scaleY()
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

        ui.dwriteText(params.text, fontSize, params.color)
end

function CUI.dwriteTextAligned(params)
        if not params.size then params.size = vec2Temp1:set(350, 100) end

        if params.xPos then ui.setCursorX(params.xPos * CUI.scaleX()) end
        if params.yPos then ui.setCursorY(params.yPos * CUI.scaleY()) end

        ui.dwriteTextAligned(
                params.text,
                params.fontSize * CUI.scaleY(),
                params.xAlign,
                params.yAlign,
                vec2Temp1:set(params.size.x * CUI.scaleX(), params.size.y * CUI.scaleY()),
                false,
                params.color
        )
end

function CUI.button(label, sizeX, sizeY, fontSize, horizontalAligment, verticalAlignment, flags, fontColor)
        if not horizontalAligment then horizontalAligment = ui.Alignment.Center end

        if not verticalAlignment then verticalAlignment = ui.Alignment.Center end

        if not flags then flags = ui.ButtonFlags.None end

        local textWidth = ui.measureDWriteText(string.upper(label), fontSize * scaleX).x
        local fontColor = fontColor

        if flags == ui.ButtonFlags.Disabled then
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
                ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
        end

        local tempCursor = ui.getCursor()
        local clicked = ui.button("##" .. label, vec2Temp1:set(textWidth + 30 * scaleX, sizeY * scaleY), flags)
        local hovered = ui.itemHovered()

        if flags == ui.ButtonFlags.Disabled then ui.popStyleColor(1) end

        ui.sameLine()
        ui.offsetCursorY(1)
        ui.setCursor(tempCursor)

        ui.dwriteTextAligned(
                string.upper(label),
                fontSize * scaleX,
                horizontalAligment,
                verticalAlignment,
                vec2Temp1:set(textWidth + 30 * scaleX, sizeY * scaleY),
                false,
                fontColor
        )

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function CUI.settingsButton(label, sizeX, sizeY, flags, icon)
        local fontSize = sizeY / 5

        local disabled = flags == ui.ButtonFlags.Disabled

        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor1)
        ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.Appearance.uiColor2)
        ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.Appearance.uiColor2)
        local tempCursor = ui.getCursor()
        local clicked = ui.button("##" .. label, vec2Temp1:set(sizeX, sizeY), flags)
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()
        ui.popStyleColor(3)

        ui.addIcon(icon, vec2Temp1:set(sizeY / 4, sizeY / 4), vec2Temp2:set(0.5, 0.25), nil)

        if not ui.itemHovered() or disabled then
                ui.drawRect(r1, r2, disabled and rgbm.colors.gray or rgbm.colors.white, 0, ui.CornerFlags.None, 1)
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
                rgbm.colors.white
        )
        ui.popDWriteFont()

        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function CUI.modalButton(label, sizeX, sizeY, flags)
        local fontSize = sizeY / 2

        local disabled = flags == ui.ButtonFlags.Disabled

        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor1)
        ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.Appearance.uiColor2)
        ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.Appearance.uiColor2)

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
                or (label == "Confirm" and not settings.General.showConfirmDialogs)
end

function CUI.menuButton(label, size, horizontalAligment, verticalAlignment, flags, active, bold)
        if bold then
                style:pushFontBold()
        else
                style:pushFontRegular()
        end

        if not horizontalAligment then horizontalAligment = ui.Alignment.Center end

        if not verticalAlignment then verticalAlignment = ui.Alignment.Center end

        if not flags then flags = ui.ButtonFlags.None end

        local sizeX, sizeY, buttonSize, fontSize

        if type(size) == "number" then
                size = size * scaleY
                sizeY = size
                fontSize = math.floor(sizeY * 0.55)
                fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize
                buttonSize = vec2Temp1:set(
                        math.round(ui.measureDWriteText(string.upper(label), fontSize).x + 100 * CUI.scaleY()),
                        size
                )
        else
                sizeX = size.x
                sizeY = size.y
                fontSize = math.floor(sizeY * 0.55)
                fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize
                buttonSize = vec2Temp1(sizeX, sizeY)
        end

        local fontColor = active and rgbm(0, 0, 0, 1) or nil

        ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.Appearance.uiColor2)
        ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.Appearance.uiColor2)

        if active then ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor3) end

        if flags == ui.ButtonFlags.Disabled then
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
                ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
        end

        local tempCursor = ui.getCursor()
        local clicked = ui.button("##" .. label, buttonSize, flags)
        local hovered = ui.itemHovered()

        if flags == ui.ButtonFlags.Disabled then
                ui.popStyleColor(1)
        elseif hovered then
                fontColor = rgbm(1, 1, 1, 1)
        end

        if active then ui.popStyleColor(1) end

        ui.popStyleColor(2)

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

function CUI.bindingButton(bind, device, button, size, flags)
        if not flags then flags = ui.ButtonFlags.None end

        local sizeX = size.x
        local sizeY = size.y
        local fontSize = math.floor(sizeY * 0.55)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize
        local fontColor = nil

        ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.Appearance.uiColor2)
        ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.Appearance.uiColor2)

        if flags == ui.ButtonFlags.Disabled then
                fontColor = rgbm(0.6, 0.6, 0.6, 1)
                ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
        end

        local tempCursor = ui.getCursor()
        local clicked = ui.button("##" .. bind, vec2Temp1(sizeX, sizeY), flags)
        local hovered = ui.itemHovered()

        if flags == ui.ButtonFlags.Disabled then
                ui.popStyleColor(1)
        elseif hovered then
                fontColor = rgbm(1, 1, 1, 1)
        end

        ui.popStyleColor(2)

        ui.setCursor(tempCursor)
        CUI.snapCursor()
        ui.dwriteTextAligned(
                button,
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2Temp1(sizeX, sizeY * 0.8),
                false,
                fontColor
        )

        ui.setCursor(tempCursor)
        CUI.snapCursor()
        ui.dwriteTextAligned(
                device,
                fontSize / 2,
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

        if locked then
                ui.pushStyleColor(ui.StyleColor.ButtonHovered, color)
                ui.pushStyleColor(ui.StyleColor.ButtonActive, color)
                ui.pushStyleColor(ui.StyleColor.Button, color)
        else
                ui.pushStyleColor(ui.StyleColor.ButtonHovered, color * 1.1)
                ui.pushStyleColor(ui.StyleColor.ButtonActive, color * 0.9)
                ui.pushStyleColor(ui.StyleColor.Button, color)
        end

        local tempCursor = ui.getCursor()
        local clicked = ui.button("##" .. label, buttonSize, flags)
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()

        ui.popStyleColor(3)

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
                        rgbm.colors.black
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
                        rgbm.colors.black
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
        local clicked = ui.modernButton(label, vec2(sizeX, sizeY) * scaleY, flags, icon, 16 * scaleY)
        local hovered = ui.itemHovered()
        return clicked and not (flags == ui.ButtonFlags.Disabled)
end

function CUI.iconButton(label, icon, sizeX, sizeY, flags, flipped, iconScale)
        if not iconScale then iconScale = 1 end

        local disabled = false
        if bit.band(flags, ui.ButtonFlags.Disabled) ~= 0 then disabled = true end

        local tempCursor = ui.getCursor()
        local clicked = ui.invisibleButton("##" .. label, vec2(sizeX, sizeY))
        local hovered = ui.itemHovered()

        local iconColor = disabled and rgbm(0.3, 0.3, 0.3, 0.8)
                or (hovered and settings.Appearance.uiColor2 or settings.Appearance.uiColor3)

        local iconSize = sizeY
        if flipped then iconSize = -iconSize end

        ui.addIcon(icon, vec2(iconSize, iconSize) * 0.7 * iconScale, vec2(0.5, 0.5), iconColor)

        if not label:startsWith("##") then
                ui.setCursorX(tempCursor.x)
                CUI.snapCursor()
                style:pushFontBold()
                ui.dwriteTextAligned(label, 18 * scaleY, ui.Alignment.Center, ui.Alignment.Start, sizeY, false)
                ui.popDWriteFont()
                ui.setCursor(tempCursor + vec2(sizeX, 0))
        end

        return clicked and not disabled
end

local treeNodeParent = ""
function CUI.treeNodeButton(label, size, active, bold, count)
        if not count then count = 0 end

        local fontSize = math.floor(size.y * 0.55)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize
        local fontColor = active and rgbm(0, 0, 0, 1) or nil

        ui.pushStyleColor(ui.StyleColor.Button, bold and settings.Appearance.uiColor1 or rgbm(0.1, 0.1, 0.1, 1))
        ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.Appearance.uiColor2)
        ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.Appearance.uiColor2)

        if active then ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor3) end

        local tempCursor = ui.getCursor()
        local clicked = ui.button(
                "##" .. label .. treeNodeParent,
                size,
                ui.ButtonFlags.PressedOnClick + ui.ButtonFlags.PressedOnDoubleClick
        )
        local hovered = ui.itemHovered() and not CUI.modalDialogCallback
        local id = ui.getLastID()

        if active then
                ui.popStyleColor(1)

                if hovered then ui.drawRect(tempCursor, tempCursor + size, settings.Appearance.uiColor3) end
        end

        ui.popStyleColor(3)

        ui.sameLine()

        local textOffset = bold and size.x / 60 or size.x / 30
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
        if bold and count > 0 then
                ui.addIcon(
                        CUI.loadStoredBool(id) and ui.Icons.Minus or ui.Icons.Plus,
                        vec2Temp1:set(size.y / 2, size.y / 2),
                        vec2Temp2:set(0.92, 0.5),
                        nil
                )
        end

        return clicked, id
end

function CUI.treeNode(label, count, content, defaultOpen)
        local clicked, id =
                CUI.treeNodeButton(label, vec2Temp1:set(ui.availableSpaceX(), 48 * CUI.scaleY()), false, true, count)
        treeNodeParent = label

        if count < 1 then return clicked end

        if defaultOpen and not storedBools[id] then CUI.storeBool(id, true) end

        local open = CUI.loadStoredBool(id)
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

function CUI.combo(label, size, previewValue, content)
        local cursorXTemp = ui.getCursorX()
        local clicked, id = CUI.treeNodeButton(previewValue, size, false, true)
        local cursorYTemp = ui.getCursorY()

        local open = CUI.loadStoredBool(id)
        if clicked then CUI.storeBool(id, not open) end

        local value = previewValue

        if open then
                ui.setCursorX(cursorXTemp)
                ui.setCursorY(cursorYTemp)

                size.y = size.y * 4

                ui.childWindow(label, size, true, ui.WindowFlags.None, function()
                        clicked, value = content(previewValue)
                end)

                if clicked then CUI.storeBool(id, false) end
        end

        ui.setCursorY(cursorYTemp)

        return value
end

local inputTextBoxDragIndex = 0
local inputTextBoxCursorIndex = 2

function CUI.inputTextBox(label, stringPrefix, stringInput, size)
        local fontSize = math.floor(size.y * 0.55)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

        local tempCursor = ui.getCursor()

        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor1)
        ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.Appearance.uiColor1)
        ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.Appearance.uiColor1)
        local clicked = ui.button("##" .. label, size, ui.ButtonFlags.None)
        ui.popStyleColor(3)

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
        for i = 1, #stringInput do
                charSizes[i] = ui.measureDWriteText(stringInput:gsub(" ", "."):sub(i, i), fontSize).x
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

        CUI.snapCursor()
        for i in ipairs(charSizes) do
                ui.dwriteTextAligned(
                        stringInput:sub(i, i),
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
                local charSizeAccum = tempCursor.x
                inputTextBoxCursorIndex = 0
                for i = 1, #stringInput do
                        if ui.mouseLocalPos().x > charSizeAccum then inputTextBoxCursorIndex = i end
                        charSizeAccum = charSizeAccum + charSizes[i]
                end
                inputTextBoxDragIndex = inputTextBoxCursorIndex
        end

        if itemActive and math.abs(ui.mouseDragDelta(ui.MouseButton.Left).x) > 0 then
                local charSizeAccum = tempCursor.x
                inputTextBoxDragIndex = 0
                for i = 1, #stringInput do
                        if ui.mouseLocalPos().x > charSizeAccum then inputTextBoxDragIndex = i end
                        charSizeAccum = charSizeAccum + charSizes[i]
                end
        end

        if itemActive then
                local left = tempCursor.x
                        + ui.measureDWriteText(stringInput:gsub(" ", "."):sub(1, inputTextBoxDragIndex), fontSize).x
                local right = tempCursor.x
                        + ui.measureDWriteText(stringInput:gsub(" ", "."):sub(1, inputTextBoxCursorIndex), fontSize).x

                ui.drawRectFilled(
                        vec2(right, ui.getCursorY()),
                        vec2(right + (left - right), ui.getCursorY() + size.y - 2),
                        rgbm.colors.red / 2
                )
        end

        if
                not ui.mouseDown(ui.MouseButton.Left) and itemActive and math.floor(os.clock() * 2) % 2 == 0
                or (hovered and ui.mouseClicked(ui.MouseButton.Left))
        then
                local pos = tempCursor.x
                        + ui.measureDWriteText(stringInput:gsub(" ", "."):sub(1, inputTextBoxCursorIndex), fontSize).x
                ui.drawSimpleLine(
                        vec2(pos, r1.y + 10 * CUI.scaleY()),
                        vec2(pos, r1.y - 10 * CUI.scaleY()) + vec2(0, size.y),
                        rgbm.colors.white / 1.25,
                        2 * CUI.scaleY()
                )
        end

        ui.drawRect(r1, r2, settings.Appearance.uiColor1 * 2, 0, ui.CornerFlags.None, 2)

        ui.popClipRect()

        return itemActive
end

function CUI.inputText(label, stringPrefix, stringInput, filter, size)
        if not CUI.inputTextBox(label, stringPrefix, stringInput, size) then return stringInput, false end

        local captured = ui.captureKeyboard(true, true, true)
        local charToAdd = nil
        local skip = false

        if ui.mouseDoubleClicked(ui.MouseButton.Left) then
                inputTextBoxDragIndex = 0
                inputTextBoxCursorIndex = #stringInput
        end

        if ui.keyPressed(ui.Key.D) and ui.keyboardButtonDown(ui.KeyIndex.Control) then
                inputTextBoxDragIndex = #stringInput
                inputTextBoxCursorIndex = inputTextBoxCursorIndex
                return stringInput, true
        end

        if ui.keyPressed(ui.Key.Left) then
                inputTextBoxCursorIndex = math.max(inputTextBoxCursorIndex - 1, 0)

                if not ui.keyboardButtonDown(ui.KeyIndex.Shift) then inputTextBoxDragIndex = inputTextBoxCursorIndex end
        end

        if ui.keyPressed(ui.Key.Right) then
                inputTextBoxCursorIndex = math.min(inputTextBoxCursorIndex + 1, #stringInput)

                if not ui.keyboardButtonDown(ui.KeyIndex.Shift) then inputTextBoxDragIndex = inputTextBoxCursorIndex end
        end

        if ui.keyPressed(ui.Key.A) and ui.keyboardButtonDown(ui.KeyIndex.Control) then
                inputTextBoxDragIndex = 0
                inputTextBoxCursorIndex = #stringInput
        end

        if ui.keyPressed(ui.Key.Backspace) or ui.keyPressed(ui.Key.Delete) then captured = "" end

        if
                (ui.keyPressed(ui.Key.Backspace) or ui.keyPressed(ui.Key.Delete) or #captured > 0)
                and #stringInput > 0
                and inputTextBoxDragIndex ~= inputTextBoxCursorIndex
        then
                if inputTextBoxCursorIndex >= inputTextBoxDragIndex then
                        stringInput = stringInput:sub(1, inputTextBoxDragIndex)
                                .. stringInput:sub(inputTextBoxCursorIndex + 1)
                        inputTextBoxCursorIndex = inputTextBoxDragIndex
                end

                if inputTextBoxDragIndex > inputTextBoxCursorIndex then
                        stringInput = stringInput:sub(1, inputTextBoxCursorIndex)
                                .. stringInput:sub(inputTextBoxDragIndex + 1)
                        inputTextBoxDragIndex = inputTextBoxCursorIndex
                end
                audio:trigger()
        elseif ui.keyPressed(ui.Key.Backspace) and #stringInput > 0 then
                ac.debug("inputTextBoxCursorIndex", inputTextBoxCursorIndex)
                ac.debug("inputTextBoxDragIndex", inputTextBoxDragIndex)
                skip = true
                stringInput = stringInput:sub(1, inputTextBoxCursorIndex - 1)
                inputTextBoxCursorIndex = inputTextBoxCursorIndex - 1
                inputTextBoxDragIndex = inputTextBoxCursorIndex
        elseif ui.keyPressed(ui.Key.Delete) and #stringInput > 0 then
                stringInput = stringInput:sub(1, inputTextBoxCursorIndex)
                        .. stringInput:sub(inputTextBoxCursorIndex + 2)
                inputTextBoxCursorIndex = inputTextBoxCursorIndex
                inputTextBoxDragIndex = inputTextBoxCursorIndex
        end

        if #captured > 0 and not skip then
                charToAdd = captured:queue()
                if #charToAdd == 1 and charToAdd:match(filter) then
                        inputTextBoxCursorIndex = inputTextBoxCursorIndex + 1
                        inputTextBoxDragIndex = inputTextBoxCursorIndex

                        stringInput = stringInput:sub(1, inputTextBoxCursorIndex - 1)
                                .. charToAdd
                                .. stringInput:sub(inputTextBoxCursorIndex)

                        audio:trigger()
                end
        end

        stringInput = stringInput:gsub("\n", "")

        return stringInput, true
end

function CUI:promptShutdownAC()
        local mouseMoved = false

        CUI.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 4

                ui.setCursor(0)
                ui.dwriteTextAligned("Quit Session", textBoxHeight / 2, nil, nil, vec2(ui.windowWidth(), textBoxHeight))
                local titleTextWidth = ui.measureDWriteText(" Quit Session ", textBoxHeight / 2).x

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "Abandon the current session and return to Content Manager?",
                        textBoxHeight / 4,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                local buttonWidth = ui.windowWidth() / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * CUI.scaleY())
                if CUI.modalButton("Cancel", ui.windowWidth() / 3, 50 * CUI.scaleY(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * CUI.scaleY())
                if CUI.modalButton("Confirm", ui.windowWidth() / 3, 50 * CUI.scaleY(), ui.ButtonFlags.None) then
                        ac.shutdownAssettoCorsa()
                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end)
end

function CUI.dummy(x, y) ui.dummy(vec2Temp1:set(x * scaleY, y * scaleY)) end

local margins = 15

function CUI.pushWindow(id, x, y, width, height, scroll)
        local windowFlags = bit.bor(ui.WindowFlags.NoResize)

        if not scroll then windowFlags = windowFlags + ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse end

        local tabWidth = width
        local tabHeight = height

        ui.setCursorX(x)
        ui.setCursorY(y)

        ui.pushStyleVar(ui.StyleVar.WindowPadding, 0)
        ui.beginChild(id, vec2(tabWidth, tabHeight), true, windowFlags)

        if not scroll then ui.pushClipRect(vec2(0, 0), vec2(tabWidth, tabHeight)) end

        ui.setCursorX(margins)
        ui.setCursorY(margins)

        ui.beginGroup(tabWidth)
end

function CUI.popWindow(scroll)
        if not scroll then ui.popClipRect() end

        ui.endGroup()
        ui.endChild()
        ui.popStyleVar(1)
end

function CUI.pushWindowFitted(id, flags, scroll)
        local childWindowWith = (2560 - 120) * CUI.scaleX()
        local childWindowHeight = (1440 - 80) * CUI.scaleX()

        CUI.pushWindow(
                id,
                (ui.windowWidth() - childWindowWith) / 2,
                (ui.windowHeight() - childWindowHeight) / 2,
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
