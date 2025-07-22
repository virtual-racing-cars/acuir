local app = require("app")
local audio = require("audio")
local callback = require("callback")
local cui = require("ui.cui")
local gearSpeedsWidget = require("ui.widgets.gear_speeds")
local settings = require("settings")
local style = require("ui.cui.style")

local vec2Temp1 = vec2()

local function linkButton(name, size, linked)
        local clicked = ui.invisibleButton("##linkButton" .. name, size)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not callback.dialog

        local color = settings.Appearance.uiColorPrimary * 1.5

        if hovered then
                color = settings.Appearance.uiColorSecondary * 1.5
        elseif linked then
                color = settings.Appearance.uiColorSecondary
        end

        ui.beginRotation()
        ui.addIcon(linked and ui.Icons.Link or ui.Icons.LinkBroken, size.y * 0.4, 0.5, color)
        ui.endRotation(0)

        return clicked
end

local function drawSetupSpinner(si)
        if si.child or si.repair then return end

        si:run(true)

        local spinnerWidth = ui.windowWidth() * 0.5 - 100 * cui.scale()
        local spinnerHeight = style.main.font.header.space * 2.5

        local positions = {
                [0] = 40 * cui.scale(),
                [0.5] = ui.windowWidth() / 2 - spinnerWidth / 2,
                [1] = (ui.windowWidth() - spinnerWidth) - 40 * cui.scale(),
        }

        local xPos = positions[si.xPos]
        local yPos = ((si.yPos + 1) * spinnerHeight / cui.scale()) * cui.scale()
                + (ui.windowHeight() - spinnerHeight * 11) * 0.5

        if si.items then
                if #si.items > 0 then si.format = si.items[si.value + 1] end
        end

        local cornerFlags = ui.CornerFlags.All

        local xBackgroundStartPos = xPos - 15 * cui.scale()
        local xBackgroundEndPos = xPos + spinnerWidth + 15 * cui.scale()

        if (si.mirror or si.mirrorAvailable) and not si.fixed then
                if si.xPos < 0.5 then
                        cornerFlags = ui.CornerFlags.Left
                        xBackgroundEndPos = ui.windowWidth() * 0.5
                elseif si.xPos > 0.5 then
                        cornerFlags = ui.CornerFlags.Right
                        xBackgroundStartPos = ui.windowWidth() * 0.5
                end
        end

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)

        local value, changed, active, hovered =
                cui.spinner(si.id, si.name, spinnerWidth, spinnerHeight, si.fixed, si.value, si, false, true)

        if hovered and si.help and si.help ~= "NULL" and si.help ~= "" then sm.activeHelpString = si.help end

        if si.mirrorAvailable and not si.fixed then
                local linkButtonWidth = 100 * cui.scale()
                ui.setCursorX(ui.windowWidth() * 0.5 - linkButtonWidth * 0.5)
                ui.offsetCursorY(-spinnerHeight * 0.75)
                if linkButton(si.name, vec2Temp1:set(linkButtonWidth, spinnerHeight), si.mirrored) then
                        si.mirrored = not si.mirrored
                end
        end

        if hovered and ui.mouseClicked(ui.MouseButton.Right) then
                si:resetValue()
                audio:trigger()
        end

        if changed or active then
                if si:setValue(value) then audio:trigger() end
        end

        if active or si.fixed then changed = false end

        return changed
end

local WidgetWindow = require("classes.WidgetWindow")

local gearSpeedsWindow = WidgetWindow("gear_speeds")
gearSpeedsWindow:addWidget("Max Speeds", gearSpeedsWidget)

local currentQuickPitPreset = 0
function car_setup(sm)
        sm.activeHelpString = ""

        local changed = false
        local tab = sm.setupTabs[tonumber(app.state.setupTab)]

        if tab.name == "GEARS" then
                gearSpeedsWindow:setPosition(ui.windowWidth() * 0.05, 0)
                gearSpeedsWindow:setSize(ui.windowWidth() * 0.9, ui.windowWidth() * 0.3)
                gearSpeedsWindow:draw()
        end

        if tab.name == "PITSTOP STRATEGY" then
                for _, spinner in ipairs(sm._pitSpinners) do
                        if spinner.yPos > -2 then
                                if spinner.preset == -1 then
                                        drawSetupSpinner(spinner)
                                        currentQuickPitPreset = spinner.value - 1
                                elseif spinner.preset == currentQuickPitPreset then
                                        drawSetupSpinner(spinner)
                                end
                        end
                end
        end

        for _, v in ipairs(tab.setupSpinners) do
                if v.yPos > -2 then
                        if v.tab == "GEARS" and #tab.setupSpinners == 1 then
                                v.xPos = 0.5
                                v.yPos = 2.75
                        end

                        if drawSetupSpinner(v) then changed = true end
                end
        end

        if sm._apps[tab.name] and tab.name ~= "Setup Exchange" then
                sm._apps[tab.name].script[sm._apps[tab.name].setupWindow]()
        end

        if changed then sm:makeUndo() end
end
