local app = require("app")
local csp = require("csp")
local cui = require("src.ui.cui")
local settings = require("settings")
local style = require("src.ui.style")

local inputTextString = ""
local checkboxValue = false
local sliderValue = 5

function testUI(dt)
        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 1))
        cui.pushFittedWindow("full_window")

        ui.bringWindowToFront()
        ui.pushAllowKeyboardFocus(false)

        local width = 400 * cui.scale()
        local height = 50 * cui.scale()

        ui.dwriteText("Combo Box")
        cui.combo("test", vec2(width, height), "Test", ui.Alignment.Center, true, vec2(width, height), function() end)

        ui.newLine()
        ui.dwriteText("Menu Button")
        cui.menuButton("Test", vec2(width, height))
        cui.menuButton("Test", vec2(width, height))

        ui.newLine()
        ui.dwriteText("Icon Button")
        cui.offsetCursorX(50)
        cui.iconButton("Icon Button", ui.Icons.Air, height, height, ui.ButtonFlags.None, false, 0.5, true)

        ui.newLine()
        ui.dwriteText("Emoji Button")
        cui.emojiButton("Test", "😁", height, height, ui.ButtonFlags.None, false)

        ui.newLine()
        ui.dwriteText("Modal Button")
        cui.modalButton("Test", width, height, ui.ButtonFlags.None)

        ui.newLine()
        ui.dwriteText("Tree Node Button")
        cui.treeNodeChildButton("Test", vec2(width, height), false, false, 0, false)
        cui.treeNodeChildButton("Test", vec2(width, height), true, true, 0, false)

        ui.newLine()
        ui.dwriteText("Drive Button")
        cui.driveButton(
                "Drive",
                vec2(width, height),
                ui.Alignment.Center,
                ui.Alignment.Center,
                rgbm.colors.green,
                false,
                ""
        )

        ui.newLine()
        ui.dwriteText("Window Tab Button")
        cui.windowTabButton("Test", height, ui.ButtonFlags.None, true)

        ui.newLine()
        ui.dwriteText("Input Text")
        inputTextString = cui.inputText("Test2222", vec2(width, height), "", inputTextString, "Test", "[%w_ .;,><%-]")

        checkboxValue = drawCheckbox("Checkbox", "Checkbox", height * 0.5, checkboxValue, ui.ButtonFlags.None)

        sliderValue = cui.slider("Slider_Test", "Slider", width, height * 2, false, sliderValue, {
                min = 0,
                max = 100,
                step = 1,
                shiftStep = 1,
                multiplier = 1,
                offset = 0,
                unit = "%",
                format = "%.0f %s",
        })

        sliderValue = cui.spinner("Spinner_Test", "Spinner", width, height * 2, false, sliderValue, {
                min = 0,
                max = 100,
                step = 1,
                shiftStep = 1,
                multiplier = 1,
                offset = 0,
                unit = "%",
                format = "%.0f %s",
        })

        cui.pushContentWindow("test_window", ui.windowWidth() * 0.5, height, width, width)
        cui.popContentWindow()

        cui.pushContentWindow(
                "test_window2",
                ui.windowWidth() * 0.5,
                width * 1.2,
                width,
                width,
                function() cui.windowTabButton("Header", ui.windowHeight(), ui.ButtonFlags.None, false) end
        )
        cui.popContentWindow()

        cui.pushContentWindow("test_window3", ui.windowWidth() * 0.5, width * 2.3, width, width, function()
                cui.windowTabButton("Header + Footer", ui.windowHeight(), ui.ButtonFlags.None, true)
                ui.sameLine()

                cui.windowTabButton("Header", ui.windowHeight(), ui.ButtonFlags.None, false)
        end, function() end)
        cui.popContentWindow()

        ui.popAllowKeyboardFocus()

        cui.popWindow(false)
end
