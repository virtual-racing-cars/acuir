require("src.ui.setup.gear_window")
require("src.classes.Slider")
local app = require("app")
local audio = require("audio")
local cui = require("ui.cui")
local settings = require("settings")

local currentApp = app.state.setupTab - 1
local tabBarPosition = 0
local tabItemPositions = { [0] = 0 }

local function tabItem(index, title)
        if currentApp == index then ui.setScrollFromPosY((index - 1) * 56) end

        if cui.treeNodeButton(title, vec2(ui.windowWidth(), 56 * cui.uiScale()), currentApp == index, true) then
                currentApp = index
        end
end

ac.onResolutionChange(function(newSize, makingScreenshot)
        for i in ipairs(tabItemPositions) do
                tabItemPositions[i] = nil
        end
        currentApp = 0
        tabBarPosition = 0
end)

local scrollDelayTimer = 0

function setupTabBar(tabs)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), 56 * cui.uiScale()), settings.Appearance.uiColor1 / 1.3)

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
        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor1)
        for i in ipairs(tabs) do
                ui.setCursorX(0)
                tabItem(i - 1, tabs[i].name)
        end

        ui.popStyleColor(1)

        return currentApp + 1
end

local function linkButton(name, size, linked)
        ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
        ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(0, 0, 0, 0))
        ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(0, 0, 0, 0))

        local tmpPos = ui.getCursor()
        local clicked = ui.button("##linkButton" .. name, size, ui.ButtonFlags.PressedOnClick)
        local hovered = ui.itemHovered() and not cui.modalDialogCallback
        ui.setCursor(tmpPos)

        ui.beginRotation()
        ui.icon(
                linked and ui.Icons.Link or ui.Icons.LinkBroken,
                size,
                hovered and rgbm.colors.red or rgbm.colors.white,
                size
        )
        ui.endRotation(0)

        ui.popStyleColor(3)

        return clicked
end

local spinnerWidth = 600 * cui.uiScale()
local spinnerHeight = 90 * cui.uiScale()

local function drawSetupSpinner(sm, si)
        if si.child or si.repair then return end

        si:run(true)

        local positions = {
                [0] = -20 * cui.uiScale(),
                [0.5] = ui.windowWidth() / 2 - spinnerWidth / 2,
                [1] = (ui.windowWidth() - spinnerWidth) + 20 * cui.uiScale(),
        }

        local xPos = positions[si.xPos]
        local yPos = (si.yPos * 110 + 90) * cui.uiScale()

        if si.items then
                if #si.items > 0 then si.format = si.items[si.value + 1] end
        end

        local value, changed, active, hovered = drawSpinner(
                si.id,
                si.name,
                xPos,
                yPos,
                spinnerWidth,
                spinnerHeight,
                si.fixed,
                si.value,
                si.min,
                si.max,
                si.step,
                1,
                0,
                si.format,
                si.multiplier,
                0,
                false,
                si.help
        )

        if si.mirrorAvailable and not si.fixed then
                ui.setCursorX(ui.windowWidth() / 2 - spinnerHeight / 4)
                ui.setCursorY(yPos + spinnerHeight / 4)
                if linkButton(si.name, vec2(spinnerHeight / 2, spinnerHeight / 2), si.mirrored) then
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
        spinnerWidth = 640 * cui.uiScale()
        spinnerHeight = 75 * cui.uiScale()

        local changed = false
        local tab = sm.setupTabs[tonumber(app.state.setupTab)]

        if tab.name == "GEARS" then gearWindow(#tab.setupSpinners) end

        if tab.name == "PITSTOP STRATEGY" then
                for _, spinner in ipairs(sm._pitSpinners) do
                        if spinner.preset == -1 then
                                drawSetupSpinner(sm, spinner)
                                currentQuickPitPreset = spinner.value - 1
                        elseif spinner.preset == currentQuickPitPreset then
                                drawSetupSpinner(sm, spinner)
                        end
                end
        end

        for _, v in pairs(tab.setupSpinners) do
                if v.yPos > -2 then
                        if v.tab == "GEARS" and #tab.setupSpinners == 1 then
                                v.xPos = 0.5
                                v.yPos = 6
                        end

                        if drawSetupSpinner(sm, v) then changed = true end
                end
        end

        if sm._apps[tab.name] and tab.name ~= "Setup Exchange" then
                sm._apps[tab.name].script[sm._apps[tab.name].setupWindow]()
        end

        if changed then sm:makeUndo() end
end
