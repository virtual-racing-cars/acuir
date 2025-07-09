require("src.classes.Slider")
local app = require("app")
local audio = require("audio")
local cui = require("ui.cui")
local gearSpeedsWidget = require("src.ui.widgets.gear_speeds")
local settings = require("settings")
local style = require("src.ui.style")

local vec2Temp1 = vec2()

local currentApp = app.state.setupTab - 1

local function tabItem(index, title)
        if
                cui.treeNodeButton(
                        title,
                        vec2(ui.availableSpaceX() - 20 * cui.scale(), style.main.font.header.space),
                        currentApp == index,
                        true
                )
        then
                currentApp = index
        end
        cui.offsetCursorY(5)

        if currentApp == index then ui.setScrollY((index - 5) * 48 * cui.scale()) end
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
                        scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs / 1000
                elseif ui.mouseWheel() < 0 then
                        currentApp = currentApp >= #tabs - 1 and 0 or currentApp + 1
                        audio:trigger()
                        scrollDelayTimer = os.clock() + settings.UI.scrollDelayTimeMs / 1000
                end
        end

        cui.offsetCursorY(10)
        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColorPrimary)
        for i in ipairs(tabs) do
                ui.setCursorX(0)

                tabItem(i - 1, toCapitalCase(tabs[i].name))
        end

        ui.popStyleColor(1)

        return currentApp + 1
end

local function linkButton(name, size, linked)
        local clicked = ui.invisibleButton("##linkButton" .. name, size)
        local r1, r2 = ui.itemRect()
        local hovered = ui.itemHovered() and not cui.modalDialogCallback
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorPrimary)
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackground)

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
        local spinnerWidth = ui.windowWidth() * 0.42
        local spinnerHeight = style.main.font.title.size * 2.5

        if si.child or si.repair then return end

        si:run(true)

        local positions = {
                [0] = 40 * cui.scale(),
                [0.5] = ui.windowWidth() / 2 - spinnerWidth / 2,
                [1] = (ui.windowWidth() - spinnerWidth) - 40 * cui.scale(),
        }

        local xPos = positions[si.xPos]
        local yPos = (si.yPos * 1.2 * spinnerHeight / cui.scale()) * cui.scale()
                + (ui.windowHeight() - spinnerHeight * 10) * 0.5

        if si.items then
                if #si.items > 0 then si.format = si.items[si.value + 1] end
        end

        local cornerFlags = ui.CornerFlags.All

        if (si.mirror or si.mirrorAvailable) and not si.fixed then
                if si.xPos < 0.5 then
                        cornerFlags = ui.CornerFlags.Left
                elseif si.xPos > 0.5 then
                        cornerFlags = ui.CornerFlags.Right
                end
        end

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        ui.drawRectFilled(
                vec2(xPos, yPos - spinnerHeight * 0.18),
                vec2(xPos + spinnerWidth, yPos + spinnerHeight * 1.18),
                settings.Appearance.uiColorBackground,
                6 * cui.scale(),
                cornerFlags
        )

        -- ui.drawRectFilledMultiColor(
        --         vec2(xPos, yPos),
        --         vec2(xPos + spinnerWidth, yPos + spinnerHeight * 0.7),
        --         settings.Appearance.uiColorBackground * 0.2,
        --         settings.Appearance.uiColorBackground * 0.2,
        --         rgbm.colors.transparent,
        --         rgbm.colors.transparent
        -- )

        -- if si.xPos < 0.5 then
        --         ui.drawRectFilledMultiColor(
        --                 vec2(xPos, yPos + spinnerHeight * 0),
        --                 vec2(xPos + spinnerWidth, yPos + spinnerHeight),
        --                 settings.Appearance.uiColorBackground * 0.2,
        --                 rgbm.colors.transparent,
        --                 rgbm.colors.transparent,
        --                 settings.Appearance.uiColorBackground * 0.2
        --         )
        -- elseif si.xPos > 0.5 then
        --         ui.drawRectFilledMultiColor(
        --                 vec2(xPos, yPos + spinnerHeight * 0),
        --                 vec2(xPos + spinnerWidth, yPos + spinnerHeight),
        --                 rgbm.colors.transparent,
        --                 settings.Appearance.uiColorBackground * 0.2,
        --                 settings.Appearance.uiColorBackground * 0.2,
        --                 rgbm.colors.transparent
        --         )
        -- else
        --         ui.drawRectFilledMultiColor(
        --                 vec2(xPos, yPos + spinnerHeight * 0),
        --                 vec2(xPos + spinnerWidth, yPos + spinnerHeight),
        --                 rgbm.colors.transparent,
        --                 rgbm.colors.transparent,
        --                 settings.Appearance.uiColorBackground * 0.2,
        --                 settings.Appearance.uiColorBackground * 0.2
        --         )
        -- end

        local value, changed, active, hovered =
                drawSpinner(si.id, si.name, spinnerWidth, spinnerHeight, si.fixed, si.value, si, false)

        if hovered and si.help and si.help ~= "NULL" and si.help ~= "" then sm.activeHelpString = si.help end

        -- sm.activeHelpString = sm.activeHelpString == "" and si.help or sm.activeHelpString

        if si.mirrorAvailable and not si.fixed then
                ui.setCursorX(xPos + spinnerWidth)
                ui.setCursorY(yPos - spinnerHeight * 0.18)
                if
                        linkButton(
                                si.name,
                                vec2Temp1:set(
                                        ((ui.windowWidth() - spinnerWidth) - 40 * cui.scale()) - ui.getCursorX(),
                                        spinnerHeight * 1.36
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
        sm.activeHelpString = ""

        local changed = false
        local tab = sm.setupTabs[tonumber(app.state.setupTab)]

        if tab.name == "GEARS" then
                gearSpeedsWidget:setPosition(ui.windowWidth() * 0.05, 0)

                gearSpeedsWidget:setSize(ui.windowWidth() * 0.9, ui.windowWidth() * 0.3)
                gearSpeedsWidget:draw()

                -- gearWindow(#tab.setupSpinners) end
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
                                v.yPos = 3
                        end

                        if drawSetupSpinner(v) then changed = true end
                end
        end

        if sm._apps[tab.name] and tab.name ~= "Setup Exchange" then
                sm._apps[tab.name].script[sm._apps[tab.name].setupWindow]()
        end

        if changed then sm:makeUndo() end
end
