require("src.ui.pages.setup.gear_window")
require("src.classes.Slider")
local app = require("app")
local audio = require("audio")
local cui = require("ui.cui")
local settings = require("settings")

local vec2Temp1 = vec2()

local currentApp = app.state.setupTab - 1
local tabBarPosition = 0

local function tabItem(index, title)
        if cui.treeNodeButton(title, vec2(ui.windowWidth(), ui.windowHeight() / 11), currentApp == index, true) then
                currentApp = index
        end

        if currentApp == index then ui.setScrollY((index - 5) * 48 * cui.uiScale()) end
end

local scrollDelayTimer = 0

function toCapitalCase(str)
        return (str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end))
end

function setupTabBar(tabs)
        if ui.windowHovered() and scrollDelayTimer < os.clock() then
                if ui.mouseWheel() > 0 then
                        currentApp = currentApp == 0 and #tabs - 1 or currentApp - 1
                        audio:trigger()
                        scrollDelayTimer = os.clock() + settings.General.scrollDelayTimeMs / 1000
                elseif ui.mouseWheel() < 0 then
                        currentApp = currentApp >= #tabs - 1 and 0 or currentApp + 1
                        audio:trigger()
                        scrollDelayTimer = os.clock() + settings.General.scrollDelayTimeMs / 1000
                end
        end

        ui.setCursorX(tabBarPosition)
        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColorPrimary)
        for i in ipairs(tabs) do
                ui.setCursorX(0)

                tabItem(i - 1, toCapitalCase(tabs[i].name))
        end

        ui.popStyleColor(1)

        return currentApp + 1
end

local spinnerWidth = 700 * cui.uiScale()
local spinnerHeight = 90 * cui.uiScale()

local function linkButton(name, size, linked)
        local clicked = ui.invisibleButton("##linkButton" .. name, size)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not cui.modalDialogCallback
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorPrimary)

        ui.beginRotation()
        ui.addIcon(
                linked and ui.Icons.Link or ui.Icons.LinkBroken,
                size.y * 0.4,
                0.5,
                hovered and rgbm.colors.red or rgbm.colors.white
        )
        ui.endRotation(0)

        return clicked
end

local function drawSetupSpinner(si)
        if si.child or si.repair then return end

        si:run(true)

        local positions = {
                [0] = 40 * cui.uiScale(),
                [0.5] = ui.windowWidth() / 2 - spinnerWidth / 2,
                [1] = (ui.windowWidth() - spinnerWidth) - 40 * cui.uiScale(),
        }

        local xPos = positions[si.xPos]
        local yPos = (si.yPos * spinnerHeight / cui.uiScale()) * cui.uiScale()
                + (ui.windowHeight() - spinnerHeight * 10) * 0.5

        if si.items then
                if #si.items > 0 then si.format = si.items[si.value + 1] end
        end

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + spinnerWidth, yPos + spinnerHeight),
                settings.Appearance.uiColorPrimary
        )

        -- ui.drawRectFilledMultiColor(
        --         vec2(xPos, yPos),
        --         vec2(xPos + spinnerWidth, yPos + spinnerHeight * 0.7),
        --         settings.Appearance.uiColorBackground * 0.2,
        --         settings.Appearance.uiColorBackground * 0.2,
        --         rgbm.colors.transparent,
        --         rgbm.colors.transparent
        -- )

        if si.xPos < 0.5 then
                ui.drawRectFilledMultiColor(
                        vec2(xPos, yPos + spinnerHeight * 0),
                        vec2(xPos + spinnerWidth, yPos + spinnerHeight),
                        settings.Appearance.uiColorBackground * 0.2,
                        rgbm.colors.transparent,
                        rgbm.colors.transparent,
                        settings.Appearance.uiColorBackground * 0.2
                )
        elseif si.xPos > 0.5 then
                ui.drawRectFilledMultiColor(
                        vec2(xPos, yPos + spinnerHeight * 0),
                        vec2(xPos + spinnerWidth, yPos + spinnerHeight),
                        rgbm.colors.transparent,
                        settings.Appearance.uiColorBackground * 0.2,
                        settings.Appearance.uiColorBackground * 0.2,
                        rgbm.colors.transparent
                )
        else
                ui.drawRectFilledMultiColor(
                        vec2(xPos, yPos + spinnerHeight * 0),
                        vec2(xPos + spinnerWidth, yPos + spinnerHeight),
                        rgbm.colors.transparent,
                        rgbm.colors.transparent,
                        settings.Appearance.uiColorBackground * 0.2,
                        settings.Appearance.uiColorBackground * 0.2
                )
        end

        -- ui.drawSimpleLine(
        --         vec2(xPos, yPos + spinnerHeight),
        --         vec2(xPos + spinnerWidth, yPos + spinnerHeight),
        --         settings.Appearance.uiColorBackground,
        --         3
        -- )

        local value, changed, active, hovered =
                drawSpinner(si.id, si.name, spinnerWidth, spinnerHeight, si.fixed, si.value, si, false)

        if si.mirrorAvailable and not si.fixed then
                ui.setCursorX(xPos + spinnerWidth)
                ui.setCursorY(yPos)
                if
                        linkButton(
                                si.name,
                                vec2Temp1:set(
                                        ((ui.windowWidth() - spinnerWidth) - 40 * cui.uiScale()) - ui.getCursorX(),
                                        spinnerHeight
                                ),
                                si.mirrored
                        )
                then
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

local currentQuickPitPreset = 0
function car_setup(sm)
        spinnerWidth = 555 * cui.uiScale()
        spinnerHeight = 100 * cui.uiScale()

        local changed = false
        local tab = sm.setupTabs[tonumber(app.state.setupTab)]

        if tab.name == "GEARS" then gearWindow(#tab.setupSpinners) end

        if tab.name == "PITSTOP STRATEGY" then
                for _, spinner in ipairs(sm._pitSpinners) do
                        if spinner.preset == -1 then
                                drawSetupSpinner(spinner)
                                currentQuickPitPreset = spinner.value - 1
                        elseif spinner.preset == currentQuickPitPreset then
                                drawSetupSpinner(spinner)
                        end
                end
        end

        for _, v in ipairs(tab.setupSpinners) do
                if v.yPos > -2 then
                        if v.tab == "GEARS" and #tab.setupSpinners == 1 then
                                v.xPos = 0.5
                                v.yPos = 7
                        end

                        if drawSetupSpinner(v) then changed = true end
                end
        end

        if sm._apps[tab.name] and tab.name ~= "Setup Exchange" then
                sm._apps[tab.name].script[sm._apps[tab.name].setupWindow]()
        end

        if changed then sm:makeUndo() end
end
