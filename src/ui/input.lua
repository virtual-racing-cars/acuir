local audio = require("audio")
local cursor = require("src.ui.cursor")
local scale = require("src.ui.scale")
local settings = require("settings")

local vec2Temp1 = vec2()

local inputTextBoxDragIndex = 0
local inputTextBoxCursorIndex = 2
local scrollOffsetX = 0

local input = {}

local function measureUTF8PrefixWidth(charTable, upToIndex, fontSize)
        local width = 0
        for i = 1, upToIndex do
                local char = charTable[i]
                local displayChar = (char == " ") and "." or char
                width = width + ui.measureDWriteText(displayChar, fontSize).x
        end
        return width
end

function input.text(label, size, stringPrefix, stringInput, stringDefault, filter)
        size.x = size.x - 20 * scale.get()
        cursor.offsetX(10)

        local fontSize = size.y * 0.5
        local captured, clicked = ui.interactiveArea("##textinput" .. label, size)
        local r1, r2 = ui.itemRect()

        local hovered = ui.itemHovered() --and not callback.dialog
        local itemActive = ui.itemActive()

        if stringPrefix ~= "" then
                ui.setCursor(r1)
                cursor.snap()
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

                r1.x = ui.getCursorX()
        end

        ui.setCursor(r1)
        ui.pushClipRect(r1, r2)

        if itemActive and hovered then ui.setMouseCursor(ui.MouseCursor.TextInput) end

        local charSizes = {}
        local charPositions = {}
        local utf8Chars = {}
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

        local cursorOffset = measureUTF8PrefixWidth(utf8Chars, inputTextBoxCursorIndex, fontSize)
        local chunkSize = size.x * 0.7
        local cursorX = r1.x + cursorOffset

        if cursorX - scrollOffsetX > r2.x then
                scrollOffsetX = scrollOffsetX + chunkSize
        elseif cursorX - scrollOffsetX < r1.x then
                scrollOffsetX = math.max(scrollOffsetX - chunkSize, 0)
        end

        if charPositions[#charPositions] and charPositions[#charPositions] <= size.x then scrollOffsetX = 0 end

        if #utf8Chars > 0 then
                cursor.snap()
                for i, char in ipairs(utf8Chars) do
                        local posX = r1.x + charPositions[i] - scrollOffsetX
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
        else
                cursor.snap()
                ui.dwriteTextAligned(
                        stringDefault,
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        size,
                        false,
                        settings.Appearance.uiColorTextDim
                )
        end

        if hovered and ui.mouseClicked(ui.MouseButton.Left) then
                local mouseX = ui.mouseLocalPos().x
                inputTextBoxCursorIndex = 0
                for i = 1, #utf8Chars do
                        if mouseX > r1.x + charPositions[i] - scrollOffsetX then inputTextBoxCursorIndex = i end
                end
                inputTextBoxDragIndex = inputTextBoxCursorIndex
        end

        if itemActive and math.abs(ui.mouseDragDelta(ui.MouseButton.Left).x) > 0 then
                inputTextBoxDragIndex = 0
                for i = 1, #utf8Chars do
                        if ui.mouseLocalPos().x > r1.x + charPositions[i] - scrollOffsetX then
                                inputTextBoxDragIndex = i
                        end
                end
        end

        if itemActive then
                local left = r1.x + measureUTF8PrefixWidth(utf8Chars, inputTextBoxDragIndex, fontSize) - scrollOffsetX
                local right = r1.x
                        + measureUTF8PrefixWidth(utf8Chars, inputTextBoxCursorIndex, fontSize)
                        - scrollOffsetX
                if left ~= right then
                        ui.drawRectFilled(
                                vec2(right, ui.getCursorY()),
                                vec2(left, ui.getCursorY() + size.y),
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
                local pos = r1.x + cursorOffset - scrollOffsetX
                ui.drawSimpleLine(
                        vec2(pos, r1.y + 7 * scale.get()),
                        vec2(pos, r2.y - 7 * scale.get()),
                        settings.Appearance.uiColorText * 0.75,
                        2 * scale.get()()
                )
        end

        ui.popClipRect()

        ui.setCursor(r1)
        ui.dummy(size)

        if not itemActive then return stringInput, false end

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

        if
                ui.mouseDoubleClicked(ui.MouseButton.Left)
                or (ui.keyboardButtonDown(ui.KeyIndex.A) and ui.keyboardButtonDown(ui.KeyIndex.Control))
        then
                inputTextBoxDragIndex = 0
                inputTextBoxCursorIndex = numChars

                skip = true
        end

        if ui.keyboardButtonDown(ui.KeyIndex.D) and ui.keyboardButtonDown(ui.KeyIndex.Control) then
                inputTextBoxDragIndex = inputTextBoxCursorIndex
        end

        if ui.keyPressed(ui.Key.C) and ui.keyboardButtonDown(ui.KeyIndex.Control) then
                if inputTextBoxCursorIndex ~= inputTextBoxDragIndex then
                        local selectedText = table.concat(
                                utf8Chars,
                                "",
                                math.min(inputTextBoxCursorIndex, inputTextBoxDragIndex) + 1,
                                math.max(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                        )
                        ac.setClipboardText(selectedText)
                end

                skip = true
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

                skip = true
        end

        if ui.keyPressed(ui.Key.Left) then
                inputTextBoxCursorIndex = math.max(inputTextBoxCursorIndex - 1, 0)
                if not ui.keyboardButtonDown(ui.KeyIndex.Shift) then inputTextBoxDragIndex = inputTextBoxCursorIndex end

                skip = true
        end

        if ui.keyPressed(ui.Key.Right) then
                inputTextBoxCursorIndex = math.min(inputTextBoxCursorIndex + 1, numChars)
                if not ui.keyboardButtonDown(ui.KeyIndex.Shift) then inputTextBoxDragIndex = inputTextBoxCursorIndex end

                skip = true
        end

        if ac.isKeyDown(ui.KeyIndex.Back) or ac.isKeyDown(ui.KeyIndex.Delete) or ac.isKeyDown(ui.KeyIndex.Return) then
                skip = true
        end

        if
                (ac.isKeyDown(ui.KeyIndex.Back) or ac.isKeyDown(ui.KeyIndex.Delete))
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
                        local startIndex = math.min(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                        local endIndex = math.max(inputTextBoxCursorIndex, inputTextBoxDragIndex)
                        for i = endIndex, startIndex + 1, -1 do
                                table.remove(utf8Chars, i)
                        end
                        inputTextBoxCursorIndex = startIndex
                        inputTextBoxDragIndex = startIndex

                        table.insert(utf8Chars, inputTextBoxCursorIndex + 1, charToAdd)
                        inputTextBoxCursorIndex = inputTextBoxCursorIndex + 1
                        inputTextBoxDragIndex = inputTextBoxCursorIndex
                        audio:trigger()
                end
        end

        return table.concat(utf8Chars):gsub("\n", ""), true
end

return input
