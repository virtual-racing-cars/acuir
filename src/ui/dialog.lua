local button = require("src.ui.button")
local callback = require("callback")
local scale = require("src.ui.scale")

local dialog = {}

function dialog.modal(callbackCall) callback.dialog = callbackCall end

function dialog.promptShutdownAC()
        local mouseMoved = false

        dialog.modal(function()
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
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * scale.get())
                if button.modal("Cancel", ui.windowWidth() / 3, 50 * scale.get(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                -- if not mouseMoved then
                --         ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                --         mouseMoved = true
                -- end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * scale.get())
                if button.modal("Confirm", ui.windowWidth() / 3, 50 * scale.get(), ui.ButtonFlags.None) then
                        ac.shutdownAssettoCorsa()
                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end)
end

return dialog
