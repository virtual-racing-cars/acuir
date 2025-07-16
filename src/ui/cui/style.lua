local settings = require("settings")

local style = {
        main = {
                colors = {
                        { ui.StyleColor.ScrollbarGrab, settings.Appearance.uiColorAccent },
                        { ui.StyleColor.ScrollbarBg, settings.Appearance.uiColorBackground },
                },
                var = {
                        { ui.StyleVar.ScrollbarSize, 5 },
                        { ui.StyleVar.ScrollbarRounding, 6 },
                        { ui.StyleVar.ItemSpacing, 0 },
                },
                font = {
                        type = ui.DWriteFont("Rajdhani", ac.dirname() .. "\\assets\\fonts\\"),
                        title = { size = 30, space = 40 },
                        header = { size = 20, space = 36 },
                        body = { size = 18, space = 34 },
                        small = { size = 16, space = 32 },
                },
                corners = { innerSize = 6, outerSize = 16 },
                margins = { innerSize = 10, outerSize = 15 },
        },
}

-- function refreshScale()
--         uiScale = math.min(sim.windowHeight / defaultHeight, sim.windowWidth / defaultWidth)
--                 / guiINI:get("NEW_UI", "UI_SCALE", 1)
--                 * settings.UI.mainMenuScale

--         style:refresh(uiScale)
-- end

function style:refresh(scale)
        style.main = {
                colors = {
                        { ui.StyleColor.ScrollbarGrab, settings.Appearance.uiColorAccent },
                        { ui.StyleColor.ScrollbarBg, settings.Appearance.uiColorBackground },
                },
                var = {
                        { ui.StyleVar.ScrollbarSize, 5 * scale },
                        { ui.StyleVar.ScrollbarRounding, 6 * scale },
                        { ui.StyleVar.ItemSpacing, 0 },
                },
                font = {
                        type = ui.DWriteFont("Rajdhani", ac.dirname() .. "\\assets\\fonts\\"),
                        title = { size = 30 * scale, space = 40 * scale },
                        header = { size = 20 * scale, space = 36 * scale },
                        body = { size = 18 * scale, space = 34 * scale },
                        small = { size = 16 * scale, space = 32 * scale },
                },
                corners = { innerSize = 6 * scale, outerSize = 16 * scale },
                margins = { innerSize = 10 * scale, outerSize = 15 * scale },
        }
end

function style:pushFontRegular() ui.pushDWriteFont(style.main.font.type:weight(ui.DWriteFont.Weight.SemiBold)) end

function style:pushFontBold() ui.pushDWriteFont(style.main.font.type:weight(ui.DWriteFont.Weight.Bold)) end

function style:pushStyleMain()
        for _, v in pairs(style.main.colors) do
                ui.pushStyleColor(v[1], v[2])
        end

        for _, v in pairs(style.main.var) do
                ui.pushStyleVar(v[1], v[2])
        end

        style:pushFontRegular()
end

function style:popStyleMain()
        ui.popStyleColor(#style.main.colors)
        ui.popStyleVar(#style.main.var)
        ui.popDWriteFont()
end

return style
